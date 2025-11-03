import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/javascript/promise
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import iv
import paint/canvas
import pondering_my_orb/asset_loader
import pondering_my_orb/camera
import pondering_my_orb/damage_number
import pondering_my_orb/enemy
import pondering_my_orb/enemy_spawner
import pondering_my_orb/game_loop
import pondering_my_orb/game_state.{
  type Model, type Msg, GameOver, LoadingScreen, Playing,
}
import pondering_my_orb/id.{type Id}
import pondering_my_orb/loot
import pondering_my_orb/player
import pondering_my_orb/reward_system
import pondering_my_orb/scene_renderer
import pondering_my_orb/score
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/ui
import pondering_my_orb/wand
import pondering_my_orb/xp_shard
import tiramisu
import tiramisu/asset
import tiramisu/background
import tiramisu/debug
import tiramisu/effect.{type Effect}
import tiramisu/physics
import tiramisu/scene
import tiramisu/ui as tiramisu_ui
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

const screen_shake_duration = 0.5

pub fn main() -> Nil {
  // Initialize paint library for sprite rendering
  canvas.define_web_component()

  // Start the Lustre UI overlay
  ui.start(game_state.UIMessage)

  tiramisu.run(
    dimensions: None,
    background: background.Color(0x1a1a2e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(_ctx: tiramisu.Context(Id)) -> #(Model, Effect(Msg), Option(_)) {
  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: Vec3(0.0, -20.0, 0.0)))

  #(
    game_state.init_model(),
    effect.from(fn(_) { debug.show_collider_wireframes(physics_world, False) }),
    Some(physics_world),
  )
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let assert Some(physics_world) = ctx.physics_world

  case msg {
    game_state.GameStarted -> handle_game_started(model, ctx)
    game_state.PlayerDied -> handle_player_died(model, ctx)
    game_state.GameRestarted -> handle_game_restarted(model, ctx)
    game_state.Tick -> game_loop.handle_tick(model, physics_world, ctx)
    game_state.AssetsLoaded(assets:) -> handle_assets_loaded(model, assets, ctx)
    game_state.PointerLocked -> #(
      game_state.Model(
        ..model,
        camera: camera.Camera(..model.camera, pointer_locked: True),
      ),
      effect.none(),
      ctx.physics_world,
    )
    game_state.PointerLockFailed -> #(
      game_state.Model(
        ..model,
        camera: camera.Camera(..model.camera, pointer_locked: False),
      ),
      effect.none(),
      ctx.physics_world,
    )
    game_state.EnemyAttacksPlayer(damage:, enemy_position:) ->
      handle_enemy_attacks_player(model, damage, enemy_position, ctx)
    game_state.EnemySpawned -> handle_enemy_spawned(model, physics_world)
    game_state.EnemySpawnStarted(id) -> #(
      game_state.Model(..model, enemy_spawner_id: Some(id)),
      effect.none(),
      Some(physics_world),
    )
    game_state.EnemySpawnIntervalDecreased ->
      handle_enemy_spawn_interval_decreased(model, physics_world)
    game_state.ProjectileDamagedEnemy(
      enemy_id,
      damage,
      _knockback_direction,
      spell_effects,
    ) ->
      handle_projectile_damaged_enemy(
        model,
        enemy_id,
        damage,
        spell_effects,
        ctx,
      )
    game_state.EnemyKilled(enemy_id) ->
      handle_enemy_killed(model, enemy_id, physics_world)
    game_state.PlayerLeveledUp(_new_level) ->
      handle_player_leveled_up(model, physics_world)
    game_state.UIMessage(ui_msg) ->
      handle_ui_message(model, ui_msg, physics_world, ctx)
  }
}

fn view(model: Model, _ctx: tiramisu.Context(Id)) -> scene.Node(Id) {
  scene_renderer.render(model)
}

/// Handle game start
fn handle_game_started(
  model: Model,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let assets = asset_loader.get_asset_list()

  let effects =
    effect.batch([
      effect.from_promise(promise.map(
        asset.load_batch_simple(assets),
        game_state.AssetsLoaded,
      )),
      tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.LoadingScreen)),
    ])

  #(
    game_state.Model(..model, game_phase: LoadingScreen),
    effects,
    ctx.physics_world,
  )
}

/// Handle player death
fn handle_player_died(
  model: Model,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let effect =
    effect.batch([
      effect.exit_pointer_lock(),
      tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.GameOver)),
    ])

  #(game_state.Model(..model, game_phase: GameOver), effect, ctx.physics_world)
}

/// Handle game restart
fn handle_game_restarted(
  model: Model,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let cancel_spawner_effect = case model.enemy_spawner_id {
    Some(id) -> effect.cancel_interval(id)
    None -> effect.none()
  }

  let #(new_model, new_effects, new_physics_world) = init(ctx)

  #(
    game_state.Model(..new_model, restarted: True),
    effect.batch([
      new_effects,
      cancel_spawner_effect,
      tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.StartScreen)),
    ]),
    new_physics_world,
  )
}

/// Handle assets loaded
fn handle_assets_loaded(
  model: Model,
  assets: asset.BatchLoadResult,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let bundle = asset_loader.load_assets(assets.cache)

  // Set up player's initial spell and sprites
  let assert Ok(updated_wand) =
    wand.set_spell(
      model.player.wand,
      0,
      spell.orbiting_spell(
        dict.get(bundle.spell_visuals, spell.OrbitingSpell)
        |> result.unwrap(spell.SpellVisuals(
          projectile_spritesheet: spell.mock_spritesheet(),
          projectile_animation: spell.mock_animation(),
          hit_spritesheet: spell.mock_spritesheet(),
          hit_animation: spell.mock_animation(),
        )),
      ),
    )
  let updated_player =
    player.Player(..model.player, wand: updated_wand)
    |> player.set_spritesheets(
      bundle.player_idle_spritesheet,
      bundle.player_idle_animation,
      bundle.player_attacking_spritesheet,
      bundle.player_attacking_animation,
    )

  let effects =
    effect.batch([
      effect.tick(game_state.Tick),
      tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.Playing)),
      effect.request_pointer_lock(
        on_success: game_state.PointerLocked,
        on_error: game_state.PointerLockFailed,
      ),
      effect.interval(
        ms: model.enemy_spawn_interval_ms,
        msg: game_state.EnemySpawned,
        on_created: game_state.EnemySpawnStarted,
      ),
    ])

  #(
    game_state.Model(
      ..model,
      player: updated_player,
      ground: Some(bundle.ground),
      foliage: Some(bundle.foliage),
      game_phase: Playing,
      xp_spritesheet: Some(bundle.xp_spritesheet),
      xp_animation: Some(bundle.xp_animation),
      enemy1_spritesheet: Some(bundle.enemy1_spritesheet),
      enemy1_animation: Some(bundle.enemy1_animation),
      enemy2_spritesheet: Some(bundle.enemy2_spritesheet),
      enemy2_animation: Some(bundle.enemy2_animation),
      visuals: bundle.spell_visuals,
    ),
    effects,
    ctx.physics_world,
  )
}

/// Handle enemy attacks player
fn handle_enemy_attacks_player(
  model: Model,
  damage: Float,
  enemy_position: Vec3(Float),
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  // Calculate knockback direction from enemy to player
  let knockback_direction =
    Vec3(
      model.player.position.x -. enemy_position.x,
      0.0,
      model.player.position.z -. enemy_position.z,
    )
    |> vec3f.normalize()

  // Always apply knockback when enemy attacks
  let pending_knockback = Some(vec3f.scale(knockback_direction, 3000.0))

  #(
    game_state.Model(
      ..model,
      player: player.take_damage(model.player, damage),
      pending_player_knockback: pending_knockback,
      camera: camera.Camera(..model.camera, shake_time: screen_shake_duration),
      score: score.take_damage(model.score),
    ),
    effect.none(),
    ctx.physics_world,
  )
}

/// Handle enemy spawned
fn handle_enemy_spawned(
  model: Model,
  physics_world: physics.PhysicsWorld(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  // Don't spawn enemies when showing spell rewards or paused
  use <- bool.guard(model.showing_spell_rewards || model.is_paused, return: #(
    model,
    effect.none(),
    Some(physics_world),
  ))

  let spawn_config =
    enemy_spawner.SpawnConfig(
      player_position: model.player.position,
      next_enemy_id: model.next_enemy_id,
      enemy1_spritesheet: model.enemy1_spritesheet,
      enemy1_animation: model.enemy1_animation,
      enemy2_spritesheet: model.enemy2_spritesheet,
      enemy2_animation: model.enemy2_animation,
    )

  let new_enemy = enemy_spawner.spawn_enemy(spawn_config)

  #(
    game_state.Model(
      ..model,
      enemies: [new_enemy, ..model.enemies],
      next_enemy_id: model.next_enemy_id + 1,
    ),
    effect.none(),
    Some(physics_world),
  )
}

/// Handle enemy spawn interval decreased
fn handle_enemy_spawn_interval_decreased(
  model: Model,
  physics_world: physics.PhysicsWorld(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let new_interval =
    enemy_spawner.calculate_new_interval(model.enemy_spawn_interval_ms)

  // Cancel old spawner and create new one with faster interval
  let cancel_effect = case model.enemy_spawner_id {
    Some(id) -> effect.cancel_interval(id)
    None -> effect.none()
  }

  #(
    game_state.Model(..model, enemy_spawn_interval_ms: new_interval),
    effect.batch([
      cancel_effect,
      effect.interval(
        ms: new_interval,
        msg: game_state.EnemySpawned,
        on_created: game_state.EnemySpawnStarted,
      ),
    ]),
    Some(physics_world),
  )
}

/// Handle projectile damaged enemy
fn handle_projectile_damaged_enemy(
  model: Model,
  enemy_id: Id,
  damage: Float,
  spell_effects: List(spell.SpellEffect),
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let applied_effects = spell.spell_effects_to_applied(spell_effects)

  let enemy =
    list.find(model.enemies, fn(enemy) { enemy.id == enemy_id })
    |> result.map(fn(enemy) {
      enemy.Enemy(..enemy, current_health: enemy.current_health -. damage)
      |> enemy.apply_spell_effects(applied_effects)
    })

  case enemy {
    Ok(killed_enemy) if killed_enemy.current_health <=. 0.0 -> {
      // Spawn damage number for kill
      let damage_num =
        damage_number.new(
          id.damage_number(model.next_damage_number_id),
          damage,
          killed_enemy.position,
          False,
        )

      #(
        game_state.Model(
          ..model,
          damage_numbers: [damage_num, ..model.damage_numbers],
          next_damage_number_id: model.next_damage_number_id + 1,
        ),
        effect.from(fn(dispatch) {
          dispatch(game_state.EnemyKilled(killed_enemy.id))
        }),
        ctx.physics_world,
      )
    }
    Ok(damaged_enemy) -> {
      // Spawn damage number for hit
      let damage_num =
        damage_number.new(
          id.damage_number(model.next_damage_number_id),
          damage,
          damaged_enemy.position,
          False,
        )

      #(
        game_state.Model(
          ..model,
          enemies: list.map(model.enemies, fn(enemy) {
            case enemy.id == damaged_enemy.id {
              True -> damaged_enemy
              False -> enemy
            }
          }),
          damage_numbers: [damage_num, ..model.damage_numbers],
          next_damage_number_id: model.next_damage_number_id + 1,
        ),
        effect.none(),
        ctx.physics_world,
      )
    }
    _ -> #(model, effect.none(), ctx.physics_world)
  }
}

/// Handle enemy killed
fn handle_enemy_killed(
  model: Model,
  enemy_id: Id,
  physics_world: physics.PhysicsWorld(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  // Find killed enemy
  let enemy =
    list.find(model.enemies, fn(e) { e.id == enemy_id })
    |> result.unwrap(enemy.basic(
      id.enemy(0),
      Vec3(0.0, 0.0, 0.0),
      enemy.EnemyType1,
    ))

  // Spawn XP shard at enemy position
  let new_shard = xp_shard.new(model.next_xp_shard_id, enemy.position)

  // Spawn loot drop if enemy was elite
  let #(loot_drops, next_loot_id) = case enemy.is_elite {
    True -> {
      // Get spell visuals for each spell type
      let spark_visuals =
        dict.get(model.visuals, spell.Spark)
        |> result.unwrap(spell.SpellVisuals(
          projectile_spritesheet: spell.mock_spritesheet(),
          projectile_animation: spell.mock_animation(),
          hit_spritesheet: spell.mock_spritesheet(),
          hit_animation: spell.mock_animation(),
        ))

      let fireball_visuals =
        dict.get(model.visuals, spell.Fireball)
        |> result.unwrap(spell.SpellVisuals(
          projectile_spritesheet: spell.mock_spritesheet(),
          projectile_animation: spell.mock_animation(),
          hit_spritesheet: spell.mock_spritesheet(),
          hit_animation: spell.mock_animation(),
        ))

      let lightning_visuals =
        dict.get(model.visuals, spell.LightningBolt)
        |> result.unwrap(spell.SpellVisuals(
          projectile_spritesheet: spell.mock_spritesheet(),
          projectile_animation: spell.mock_animation(),
          hit_spritesheet: spell.mock_spritesheet(),
          hit_animation: spell.mock_animation(),
        ))

      // Create spell instances with their proper visuals
      let available_spells = [
        spell.spark(spark_visuals),
        spell.fireball(fireball_visuals),
        spell.lightning(lightning_visuals),
      ]

      let new_loot =
        loot.generate_elite_drop(
          id.loot_drop(model.next_loot_drop_id),
          enemy.position,
          available_spells,
        )

      #([new_loot, ..model.loot_drops], model.next_loot_drop_id + 1)
    }
    False -> #(model.loot_drops, model.next_loot_drop_id)
  }

  #(
    game_state.Model(
      ..model,
      enemies: list.filter(model.enemies, fn(enemy) { enemy_id != enemy.id }),
      xp_shards: [new_shard, ..model.xp_shards],
      next_xp_shard_id: model.next_xp_shard_id + 1,
      loot_drops: loot_drops,
      next_loot_drop_id: next_loot_id,
      score: score.enemy_killed(model.score),
    ),
    effect.none(),
    Some(physics_world),
  )
}

/// Handle player leveled up
fn handle_player_leveled_up(
  model: Model,
  physics_world: physics.PhysicsWorld(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let spell_rewards = reward_system.generate_spell_rewards(model.visuals)

  #(
    game_state.Model(..model, showing_spell_rewards: True),
    effect.batch([
      tiramisu_ui.dispatch_to_lustre(ui.ShowSpellRewards(spell_rewards)),
      effect.exit_pointer_lock(),
    ]),
    Some(physics_world),
  )
}

/// Handle UI messages
fn handle_ui_message(
  model: Model,
  ui_msg: ui.UiToGameMsg,
  physics_world: physics.PhysicsWorld(Id),
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(physics.PhysicsWorld(Id))) {
  case ui_msg {
    ui.GameStarted -> #(
      model,
      effect.from(fn(dispatch) { dispatch(game_state.GameStarted) }),
      Some(physics_world),
    )
    ui.GameRestarted -> #(
      model,
      effect.from(fn(dispatch) { dispatch(game_state.GameRestarted) }),
      Some(physics_world),
    )
    ui.UpdatePlayerInventory(wand_slots, spell_bag) -> {
      // Update player's wand and spell bag from UI changes
      let updated_wand = wand.Wand(..model.player.wand, slots: wand_slots)
      let updated_player =
        player.Player(..model.player, wand: updated_wand, spell_bag: spell_bag)

      #(
        game_state.Model(..model, player: updated_player),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.SpellRewardSelected(selected_spell) -> {
      let updated_spell_bag =
        spell_bag.add_spell(model.player.spell_bag, selected_spell)

      let spell_count = spell_bag.list_spells(updated_spell_bag) |> list.length
      io.println("Total spells in bag: " <> int.to_string(spell_count))

      let updated_player =
        player.Player(..model.player, spell_bag: updated_spell_bag)

      #(
        game_state.Model(..model, player: updated_player),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.LevelUpComplete -> {
      io.println("=== LEVEL UP COMPLETE ===")

      #(
        game_state.Model(..model, showing_spell_rewards: False),
        effect.request_pointer_lock(
          on_success: game_state.PointerLocked,
          on_error: game_state.PointerLockFailed,
        ),
        ctx.physics_world,
      )
    }
    ui.GamePaused -> {
      io.println("=== GAME PAUSED ===")
      #(
        game_state.Model(..model, is_paused: True),
        effect.exit_pointer_lock(),
        ctx.physics_world,
      )
    }
    ui.GameResumed -> {
      io.println("=== GAME RESUMED ===")
      #(
        game_state.Model(..model, is_paused: False),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.UpdateCameraDistance(distance) -> {
      #(
        game_state.Model(
          ..model,
          camera: camera.Camera(..model.camera, distance:),
        ),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.ApplyLoot(loot_type) -> {
      case loot_type {
        loot.PerkLoot(perk_value) -> {
          // Apply perk to player
          let updated_player = player.apply_perk(model.player, perk_value)
          #(
            game_state.Model(..model, player: updated_player),
            effect.none(),
            ctx.physics_world,
          )
        }
        loot.WandLoot(new_wand) -> {
          // Transfer all spells from old wand to spell bag
          let old_wand_spells =
            iv.to_list(model.player.wand.slots)
            |> list.filter_map(fn(maybe_spell) {
              case maybe_spell {
                option.Some(spell) -> Ok(spell)
                option.None -> Error(Nil)
              }
            })

          // Add all old spells to spell bag
          let updated_spell_bag =
            list.fold(old_wand_spells, model.player.spell_bag, fn(bag, spell) {
              spell_bag.add_spell(bag, spell)
            })

          // Replace wand and update spell bag
          let updated_player =
            player.Player(
              ..model.player,
              wand: new_wand,
              spell_bag: updated_spell_bag,
            )

          #(
            game_state.Model(..model, player: updated_player),
            effect.none(),
            ctx.physics_world,
          )
        }
      }
    }
    ui.CloseLootUI -> {
      // Close wand selection UI and freeze game
      #(
        game_state.Model(..model, showing_wand_selection: True),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.WandSelectionComplete -> {
      // User finished selecting wand, unfreeze game
      #(
        game_state.Model(..model, showing_wand_selection: False),
        effect.none(),
        ctx.physics_world,
      )
    }
    // Debug menu handlers
    ui.DebugMenuOpened -> {
      io.println("=== DEBUG MENU OPENED ===")
      #(
        game_state.Model(..model, is_paused: True, is_debug_menu_open: True),
        effect.batch([
          effect.exit_pointer_lock(),
          tiramisu_ui.dispatch_to_lustre(ui.ToggleDebugMenu),
          tiramisu_ui.dispatch_to_lustre(ui.SetPaused(True)),
        ]),
        ctx.physics_world,
      )
    }
    ui.DebugMenuClosed -> {
      io.println("=== DEBUG MENU CLOSED ===")
      #(
        game_state.Model(..model, is_paused: False, is_debug_menu_open: False),
        effect.batch([
          tiramisu_ui.dispatch_to_lustre(ui.ToggleDebugMenu),
          tiramisu_ui.dispatch_to_lustre(ui.SetPaused(False)),
          effect.request_pointer_lock(
            on_success: game_state.PointerLocked,
            on_error: game_state.PointerLockFailed,
          ),
        ]),
        ctx.physics_world,
      )
    }
    ui.DebugAddSpellToBag(id) -> {
      let spell = case id {
        spell.AddDamage -> spell.add_damage()
        spell.AddMana -> spell.add_mana()
        spell.AddTrigger -> spell.add_trigger()
        spell.DoubleSpell -> spell.double_spell()
        spell.Fireball -> {
          let assert Ok(visuals) = dict.get(echo model.visuals, id)
          spell.fireball(visuals)
        }
        spell.LightningBolt -> {
          let assert Ok(visuals) = dict.get(echo model.visuals, id)
          spell.lightning(visuals)
        }
        spell.OrbitingSpell -> {
          let assert Ok(visuals) = dict.get(echo model.visuals, id)
          spell.orbiting_spell(visuals)
        }
        spell.Piercing -> spell.piercing()
        spell.Spark -> {
          let assert Ok(visuals) = dict.get(echo model.visuals, id)
          spell.spark(visuals)
        }
        spell.SparkWithTrigger -> {
          let assert Ok(visuals) = dict.get(echo model.visuals, id)
          spell.spark_with_trigger(visuals)
        }
        spell.RapidFire -> spell.rapid_fire()
      }
      let updated_spell_bag = spell_bag.add_spell(model.player.spell_bag, spell)
      let updated_player =
        player.Player(..model.player, spell_bag: updated_spell_bag)
      #(
        game_state.Model(..model, player: updated_player),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.DebugUpdateWandStat(stat_update) -> {
      let updated_wand = case stat_update {
        ui.SetMaxMana(value) -> wand.Wand(..model.player.wand, max_mana: value)
        ui.SetManaRechargeRate(value) ->
          wand.Wand(..model.player.wand, mana_recharge_rate: value)
        ui.SetCastDelay(value) ->
          wand.Wand(..model.player.wand, cast_delay: value)
        ui.SetRechargeTime(value) ->
          wand.Wand(..model.player.wand, recharge_time: value)
        ui.SetSpread(value) -> wand.Wand(..model.player.wand, spread: value)
        ui.SetCapacity(new_capacity) -> {
          // Resize wand slots array
          let current_slots = model.player.wand.slots
          let current_capacity = iv.length(current_slots)

          let new_slots = case new_capacity > current_capacity {
            True -> {
              // Add empty slots
              let slots_to_add = new_capacity - current_capacity
              list.range(0, slots_to_add - 1)
              |> list.fold(current_slots, fn(acc, _) {
                iv.append(acc, option.None)
              })
            }
            False -> {
              // Remove slots from the end, moving spells back to bag if needed
              iv.to_list(current_slots)
              |> list.take(new_capacity)
              |> iv.from_list
            }
          }

          wand.Wand(..model.player.wand, slots: new_slots)
        }
      }
      let updated_player = player.Player(..model.player, wand: updated_wand)
      #(
        game_state.Model(..model, player: updated_player),
        effect.none(),
        ctx.physics_world,
      )
    }
  }
}
