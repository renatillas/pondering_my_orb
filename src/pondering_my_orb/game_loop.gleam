import gleam/bool
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import iv
import pondering_my_orb/camera
import pondering_my_orb/collision_handler
import pondering_my_orb/damage_number
import pondering_my_orb/enemy
import pondering_my_orb/enemy_spawner
import pondering_my_orb/game_state.{type Model, type Msg, Playing}
import pondering_my_orb/id
import pondering_my_orb/loot
import pondering_my_orb/physics_manager
import pondering_my_orb/player
import pondering_my_orb/score
import pondering_my_orb/spell
import pondering_my_orb/ui
import pondering_my_orb/xp_shard
import tiramisu
import tiramisu/effect.{type Effect}
import tiramisu/input
import tiramisu/physics
import tiramisu/ui as tiramisu_ui
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

const interval_decrease_threshold = 15_000.0

pub fn handle_tick(
  model: Model,
  physics_world: physics.PhysicsWorld(id.Id),
  ctx: tiramisu.Context(id.Id),
) -> #(Model, Effect(Msg), Option(physics.PhysicsWorld(id.Id))) {
  // Only process game logic if game is in playing phase
  use <- bool.guard(model.game_phase != Playing, return: #(
    model,
    effect.none(),
    ctx.physics_world,
  ))

  // Calculate time scale based on pause states
  let time_scale = calculate_time_scale(model)
  let scaled_delta = ctx.delta_time *. time_scale

  // Track game time and check if we should decrease spawn interval
  let new_game_time = model.game_time_elapsed_ms +. scaled_delta
  let should_decrease_interval =
    enemy_spawner.should_decrease_spawn_interval(
      model.game_time_elapsed_ms,
      new_game_time,
      model.enemy_spawn_interval_ms,
      interval_decrease_threshold,
    )

  // Handle player input (if game is not paused)
  let #(player, impulse, camera_pitch, input_effects) =
    handle_player_input(model, physics_world, ctx)

  // Check for debug menu toggle (M key)
  let debug_menu_effect = case
    input.is_key_just_pressed(ctx.input, input.KeyM)
  {
    True -> {
      io.println(
        "M key pressed! Debug menu open: "
        <> case model.is_debug_menu_open {
          True -> "true"
          False -> "false"
        },
      )
      effect.from(fn(dispatch) {
        dispatch(
          game_state.UIMessage(case model.is_debug_menu_open {
            True -> ui.DebugMenuClosed
            False -> ui.DebugMenuOpened
          }),
        )
      })
    }
    False -> effect.none()
  }

  // Update all enemies
  let #(enemies, enemy_effects) =
    update_enemies(
      model.enemies,
      player.position,
      model.camera.position,
      physics_world,
      scaled_delta,
    )

  // Update physics (if game is not paused)
  let physics_world = case model.showing_spell_rewards, model.is_paused {
    False, False -> {
      physics_manager.update_physics(
        physics_world,
        player,
        player.velocity,
        impulse,
        enemies,
        model.pending_player_knockback,
      )
      |> physics_manager.step_physics(player.quaternion_rotation, scaled_delta)
    }
    _, _ -> physics_world
  }

  // Read position from physics, rotation is controlled by input
  let player_position =
    physics_manager.get_player_position(physics_world, model.player.position)

  let enemies = list.map(enemies, enemy.after_physics_update(_, physics_world))
  let nearest_enemy = player.nearest_enemy_position(player, enemies)

  // Update projectiles and create explosions on collision
  let #(updated_projectiles, projectile_hits, spell_effect) =
    spell.update(
      model.projectiles,
      model.enemies,
      scaled_delta,
      game_state.ProjectileDamagedEnemy,
      player_position,
    )

  // Update existing explosions and add new ones
  let all_hits = list.append(model.projectile_hits, projectile_hits)
  let updated_hits = spell.update_projectile_hits(all_hits, scaled_delta)

  // Update XP shards with animation
  let updated_xp_shards = case model.xp_animation {
    Some(animation) ->
      list.map(model.xp_shards, fn(shard) {
        xp_shard.update(shard, animation, scaled_delta)
      })
    None -> model.xp_shards
  }

  // Check for XP shard collection
  let #(remaining_shards, collected_xp) =
    collision_handler.collect_xp_shards(updated_xp_shards, player_position)

  // Update loot drop positions after physics
  let updated_loot_drops =
    list.map(model.loot_drops, loot.update_position(_, physics_world))

  // Add XP and check for level up
  let #(player_with_xp, leveled_up) =
    player
    |> player.with_position(player_position)
    |> player.add_xp(collected_xp)

  // Check for loot pickups and send toast to UI
  let #(remaining_loot, loot_pickup_effects) =
    collision_handler.collect_loot(
      updated_loot_drops,
      player_with_xp.position,
      ui.LootPickedUp,
    )

  // Check for chest opening
  let #(updated_chests, chest_opening_effects) =
    collision_handler.open_chests(
      model.chests,
      player_with_xp.position,
      game_state.ChestOpened,
    )

  let player = player_with_xp

  // Update damage numbers
  let updated_damage_numbers =
    list.map(model.damage_numbers, damage_number.update(_, scaled_delta))
    |> list.filter(fn(num) { !damage_number.is_expired(num) })

  // Update player (casting, health, etc.)
  let #(
    player,
    new_projectiles,
    casting_spell_indices,
    death_effect,
    next_projectile_id,
  ) =
    player.update(
      player,
      nearest_enemy,
      scaled_delta,
      game_state.PlayerDied,
      model.next_projectile_id,
      updated_projectiles,
    )

  // Add newly cast projectiles
  let updated_projectiles = list.append(new_projectiles, updated_projectiles)

  // Update score
  let new_score = score.update(player, model.score, scaled_delta)

  // Create UI effect with current game state
  let ui_effect =
    create_ui_update_effect(player, new_score, casting_spell_indices)

  // Dispatch level-up message if player leveled up
  let level_up_effect = case leveled_up {
    True ->
      effect.from(fn(dispatch) {
        dispatch(game_state.PlayerLeveledUp(player.level))
      })
    False -> effect.none()
  }

  // Update camera
  let updated_camera =
    camera.update(
      model.camera,
      player: player,
      new_pitch: camera_pitch,
      delta_time: scaled_delta,
    )

  // Create interval decrease effect if needed
  let interval_decrease_effect = case should_decrease_interval {
    True ->
      effect.from(fn(dispatch) {
        dispatch(game_state.EnemySpawnIntervalDecreased)
      })
    False -> effect.none()
  }

  let effects =
    effect.batch([
      effect.tick(game_state.Tick),
      effect.batch(enemy_effects),
      effect.batch(input_effects),
      spell_effect,
      ui_effect,
      death_effect,
      level_up_effect,
      interval_decrease_effect,
      effect.batch(loot_pickup_effects),
      effect.batch(chest_opening_effects),
      debug_menu_effect,
    ])

  #(
    game_state.Model(
      ..model,
      player: player,
      camera: updated_camera,
      projectiles: updated_projectiles,
      projectile_hits: updated_hits,
      next_projectile_id: next_projectile_id,
      enemies: enemies,
      xp_shards: remaining_shards,
      loot_drops: remaining_loot,
      chests: updated_chests,
      damage_numbers: updated_damage_numbers,
      pending_player_knockback: None,
      score: new_score,
      game_time_elapsed_ms: new_game_time,
    ),
    effects,
    Some(physics_world),
  )
}

/// Calculate time scale based on pause states
fn calculate_time_scale(model: Model) -> Float {
  case
    model.showing_spell_rewards,
    model.showing_wand_selection,
    model.showing_perk_slot_machine,
    model.is_paused
  {
    True, _, _, _ -> 0.0
    _, True, _, _ -> 0.0
    _, _, True, _ -> 0.0
    _, _, _, True -> 0.0
    False, False, False, False -> 1.0
  }
}

/// Handle player input (or freeze if paused)
fn handle_player_input(
  model: Model,
  physics_world: physics.PhysicsWorld(id.Id),
  ctx: tiramisu.Context(id.Id),
) -> #(player.Player, Vec3(Float), Float, List(Effect(Msg))) {
  case
    model.showing_spell_rewards,
    model.showing_wand_selection,
    model.is_paused
  {
    False, False, False ->
      player.handle_input(
        model.player,
        velocity: physics.get_velocity(physics_world, id.player())
          |> result.unwrap(Vec3(0.0, 0.0, 0.0)),
        input_state: ctx.input,
        bindings: model.player_bindings,
        pointer_locked: model.camera.pointer_locked,
        camera_pitch: model.camera.pitch,
        physics_world: physics_world,
        pointer_locked_msg: game_state.PointerLocked,
        pointer_lock_failed_msg: game_state.PointerLockFailed,
      )
    _, _, _ -> #(model.player, vec3f.zero, model.camera.pitch, [])
  }
}

/// Update all enemies
fn update_enemies(
  enemies: List(enemy.Enemy(id.Id)),
  player_position: Vec3(Float),
  camera_position: Vec3(Float),
  physics_world: physics.PhysicsWorld(id.Id),
  scaled_delta: Float,
) -> #(List(enemy.Enemy(id.Id)), List(Effect(Msg))) {
  list.map(enemies, fn(enemy_item) {
    let #(updated_enemy, effects) =
      enemy.update(
        enemy_item,
        target: player_position,
        camera_position: camera_position,
        enemy_velocity: physics.get_velocity(physics_world, enemy_item.id)
          |> result.unwrap(Vec3(0.0, 0.0, 0.0)),
        physics_world: physics_world,
        delta_time: scaled_delta /. 1000.0,
        enemy_attacks_player_msg: game_state.EnemyAttacksPlayer,
      )
    // Update enemy animations
    let updated_enemy = enemy.update_animation(updated_enemy, scaled_delta)
    // Update status effects (burning, etc.)
    let updated_enemy =
      enemy.update_status_effects(updated_enemy, scaled_delta /. 1000.0)
    #(updated_enemy, effects)
  })
  |> list.unzip()
}

/// Create UI update effect with current game state
fn create_ui_update_effect(
  player: player.Player,
  score: score.Score,
  casting_spell_indices: List(Int),
) -> Effect(Msg) {
  tiramisu_ui.dispatch_to_lustre(
    ui.GameStateUpdated(ui.GameState(
      player_health: player.current_health,
      player_max_health: player.max_health,
      player_mana: player.wand.current_mana,
      player_max_mana: player.wand.max_mana,
      wand_slots: player.wand.slots,
      spell_bag: player.spell_bag,
      player_xp: player.current_xp,
      player_xp_to_next_level: player.xp_to_next_level,
      player_level: player.level,
      score: score,
      casting_spell_indices: casting_spell_indices,
      spells_per_cast: player.wand.spells_per_cast,
      cast_delay: player.wand.cast_delay,
      recharge_time: player.wand.recharge_time,
      time_since_last_cast: player.auto_cast.time_since_last_cast,
      current_spell_index: player.auto_cast.current_spell_index,
      is_recharging: player.auto_cast.is_recharging,
      wand_max_mana: player.wand.max_mana,
      wand_mana_recharge_rate: player.wand.mana_recharge_rate,
      wand_cast_delay: player.wand.cast_delay,
      wand_recharge_time: player.wand.recharge_time,
      wand_capacity: iv.length(player.wand.slots),
      wand_spread: player.wand.spread,
    )),
  )
}
