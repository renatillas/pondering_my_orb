import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/javascript/promise
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam_community/maths
import paint/canvas
import pondering_my_orb/camera
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id.{type Id}
import pondering_my_orb/map
import pondering_my_orb/player
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
import tiramisu/input
import tiramisu/light
import tiramisu/physics
import tiramisu/scene
import tiramisu/spritesheet
import tiramisu/transform
import tiramisu/ui as tiramisu_ui
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

const screen_shake_duration = 0.5

pub type GamePhase {
  StartScreen
  LoadingScreen
  Playing
  GameOver
}

pub type Model {
  Model(
    game_phase: GamePhase,
    restarted: Bool,
    // Map
    ground: Option(map.Obstacle(map.Ground)),
    boxes: Option(map.Obstacle(map.Box)),
    // Player
    player: player.Player,
    player_bindings: input.InputBindings(player.PlayerAction),
    pending_player_knockback: Option(Vec3(Float)),
    // Camera settings
    camera: camera.Camera,
    // Projectiles
    projectiles: List(spell.Projectile),
    projectile_hits: List(spell.ProjectileHit(Id)),
    next_projectile_id: Int,
    // Enemies
    enemies: List(Enemy(Id)),
    enemy_spawner_id: Option(Int),
    next_enemy_id: Int,
    enemy_spawn_interval_ms: Int,
    game_time_elapsed_ms: Float,
    // XP System
    xp_shards: List(xp_shard.XPShard),
    next_xp_shard_id: Int,
    xp_spritesheet: Option(spritesheet.Spritesheet),
    xp_animation: Option(spritesheet.Animation),
    // Spell Effects
    fireball_spritesheet: Option(spritesheet.Spritesheet),
    fireball_animation: Option(spritesheet.Animation),
    explosion_spritesheet: Option(spritesheet.Spritesheet),
    // Level-up rewards
    showing_spell_rewards: Bool,
    // Pause state
    is_paused: Bool,
    // Score
    score: score.Score,
  )
}

pub type Msg {
  Tick
  // Game Phase
  GameStarted
  PlayerDied
  GameRestarted
  // Map
  AssetsLoaded(assets: asset.BatchLoadResult)
  // Enemies
  EnemySpawnStarted(Int)
  EnemySpawned
  EnemySpawnIntervalDecreased
  EnemyAttacksPlayer(damage: Float, enemy_position: Vec3(Float))
  // Projectiles
  ProjectileDamagedEnemy(Id, Float, Vec3(Float))
  EnemyKilled(Id)
  // XP & Leveling
  PlayerLeveledUp(new_level: Int)
  // Camera
  PointerLocked
  PointerLockFailed
  // UI
  UIMessage(ui.UiToGameMsg)
}

pub fn main() -> Nil {
  // Initialize paint library for sprite rendering
  canvas.define_web_component()

  // Start the Lustre UI overlay
  ui.start(UIMessage)

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
    physics.new_world(physics.WorldConfig(gravity: Vec3(0.0, -9.81, 0.0)))

  let player_bindings = player.default_bindings()

  #(
    Model(
      game_phase: StartScreen,
      restarted: False,
      ground: None,
      boxes: None,
      player: player.init(),
      player_bindings:,
      pending_player_knockback: None,
      camera: camera.init(),
      projectiles: [],
      projectile_hits: [],
      next_projectile_id: 0,
      enemies: [],
      enemy_spawner_id: None,
      next_enemy_id: 0,
      enemy_spawn_interval_ms: 2000,
      game_time_elapsed_ms: 0.0,
      xp_shards: [],
      next_xp_shard_id: 0,
      xp_spritesheet: None,
      xp_animation: None,
      fireball_spritesheet: None,
      fireball_animation: None,
      explosion_spritesheet: None,
      showing_spell_rewards: False,
      is_paused: False,
      score: score.init(),
    ),
    effect.from(fn(_) { debug.show_collider_wireframes(physics_world, False) }),
    Some(physics_world),
  )
}

/// Generate a pool of 3 random spell rewards for leveling up
fn generate_spell_rewards(visuals: spell.SpellVisuals) -> List(spell.Spell) {
  // Define a pool of possible spells to choose from
  let possible_spells = [
    // Damage spells
    spell.spark(visuals),
    spell.fireball(visuals),
    spell.lightning(visuals),
    // Modifier spells
  ]

  // Shuffle and take 3 random spells
  list.shuffle(possible_spells)
  |> list.take(3)
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let assert Some(physics_world) = ctx.physics_world

  case msg {
    GameStarted -> {
      let assets = [
        asset.FBXAsset("PSX_Dungeon/Models/Box.fbx", None),
        asset.FBXAsset(
          "PSX_Dungeon/Models/Floor_Tiles.fbx",
          Some("PSX_Dungeon/Textures/"),
        ),
        asset.TextureAsset("PSX_Dungeon/Textures/TEX_Ground_04.png"),
        asset.TextureAsset("PSX_Dungeon/Textures/TEX_Crate_01.png"),
        asset.TextureAsset("spr_coin_azu.png"),
        asset.TextureAsset("SPRITESHEET_Files/FireBall_2_64x64.png"),
        asset.TextureAsset("SPRITESHEET_Files/Explosion_2_64x64.png"),
        asset.TextureAsset("mago_idle.png"),
        asset.TextureAsset("mago_attacking.png"),
      ]

      let effects =
        effect.batch([
          effect.from_promise(promise.map(
            asset.load_batch_simple(assets),
            AssetsLoaded,
          )),
          tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.LoadingScreen)),
        ])

      #(Model(..model, game_phase: LoadingScreen), effects, ctx.physics_world)
    }
    PlayerDied -> {
      let effect =
        effect.batch([
          effect.exit_pointer_lock(),
          tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.GameOver)),
        ])

      #(Model(..model, game_phase: GameOver), effect, ctx.physics_world)
    }
    GameRestarted -> {
      let cancel_spawner_effect = case model.enemy_spawner_id {
        Some(id) -> effect.cancel_interval(id)
        None -> effect.none()
      }

      let #(new_model, new_effects, new_physics_world) = init(ctx)

      #(
        Model(..new_model, restarted: True),
        effect.batch([
          new_effects,
          cancel_spawner_effect,
          tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.StartScreen)),
        ]),
        new_physics_world,
      )
    }
    Tick -> handle_tick(model, physics_world, ctx)
    AssetsLoaded(assets:) -> handle_assets_loaded(model, assets, ctx)
    PointerLocked -> #(
      Model(
        ..model,
        camera: camera.Camera(..model.camera, pointer_locked: True),
      ),
      effect.none(),
      ctx.physics_world,
    )
    PointerLockFailed -> #(
      Model(
        ..model,
        camera: camera.Camera(..model.camera, pointer_locked: False),
      ),
      effect.none(),
      ctx.physics_world,
    )
    EnemyAttacksPlayer(damage:, enemy_position:) -> {
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
        Model(
          ..model,
          player: player.take_damage(model.player, damage),
          pending_player_knockback: pending_knockback,
          camera: camera.Camera(
            ..model.camera,
            shake_time: screen_shake_duration,
          ),
          score: score.take_damage(model.score),
        ),
        effect.none(),
        ctx.physics_world,
      )
    }
    EnemySpawned -> {
      // Don't spawn enemies when showing spell rewards or paused
      use <- bool.guard(
        model.showing_spell_rewards || model.is_paused,
        return: #(model, effect.none(), Some(physics_world)),
      )

      let min_spawn_radius = 10.0
      let max_spawn_radius = 20.0
      let spawn_height = 1.0

      let random_angle = float.random() *. 2.0 *. maths.pi()
      let random_distance =
        min_spawn_radius
        +. { float.random() *. { max_spawn_radius -. min_spawn_radius } }

      let offset_x = maths.cos(random_angle) *. random_distance
      let offset_z = maths.sin(random_angle) *. random_distance

      let spawn_position =
        Vec3(
          model.player.position.x +. offset_x,
          spawn_height,
          model.player.position.z +. offset_z,
        )

      #(
        Model(
          ..model,
          enemies: [
            enemy.basic(id.enemy(model.next_enemy_id), position: spawn_position),
            ..model.enemies
          ],
          next_enemy_id: model.next_enemy_id + 1,
        ),
        effect.none(),
        Some(physics_world),
      )
    }
    EnemySpawnStarted(id) -> #(
      Model(..model, enemy_spawner_id: Some(id)),
      effect.none(),
      Some(physics_world),
    )
    EnemySpawnIntervalDecreased -> {
      // Calculate new spawn interval (decrease by 10%, minimum 500ms)
      let new_interval = int.max(500, model.enemy_spawn_interval_ms * 90 / 100)

      // Cancel old spawner and create new one with faster interval
      let cancel_effect = case model.enemy_spawner_id {
        Some(id) -> effect.cancel_interval(id)
        None -> effect.none()
      }

      #(
        Model(..model, enemy_spawn_interval_ms: new_interval),
        effect.batch([
          cancel_effect,
          effect.interval(
            ms: new_interval,
            msg: EnemySpawned,
            on_created: EnemySpawnStarted,
          ),
        ]),
        Some(physics_world),
      )
    }
    ProjectileDamagedEnemy(enemy_id, damage, _knockback_direction) -> {
      // Knockback is now applied during Tick, so just handle damage here
      let enemy =
        list.find(model.enemies, fn(enemy) { enemy.id == enemy_id })
        |> result.map(fn(enemy) {
          enemy.Enemy(
            ..enemy,
            current_health: enemy.current_health - float.round(damage),
          )
        })

      case enemy {
        Ok(killed_enemy) if killed_enemy.current_health <= 0 -> #(
          model,
          effect.from(fn(dispatch) { dispatch(EnemyKilled(killed_enemy.id)) }),
          ctx.physics_world,
        )
        Ok(damaged_enemy) -> #(
          Model(
            ..model,
            enemies: list.map(model.enemies, fn(enemy) {
              case enemy.id == damaged_enemy.id {
                True -> damaged_enemy
                False -> enemy
              }
            }),
          ),
          effect.none(),
          ctx.physics_world,
        )
        _ -> #(model, effect.none(), ctx.physics_world)
      }
    }
    EnemyKilled(enemy_id) -> {
      // Spawn XP shard at enemy position
      let enemy_position =
        list.find(model.enemies, fn(e) { e.id == enemy_id })
        |> result.map(fn(e) { e.position })
        |> result.unwrap(Vec3(0.0, 0.0, 0.0))

      let new_shard = xp_shard.new(model.next_xp_shard_id, enemy_position)

      #(
        Model(
          ..model,
          enemies: list.filter(model.enemies, fn(enemy) { enemy_id != enemy.id }),
          xp_shards: [new_shard, ..model.xp_shards],
          next_xp_shard_id: model.next_xp_shard_id + 1,
          score: score.enemy_killed(model.score),
        ),
        effect.none(),
        Some(physics_world),
      )
    }
    PlayerLeveledUp(_new_level) -> {
      // Generate spell rewards and send to UI
      case
        model.fireball_spritesheet,
        model.fireball_animation,
        model.explosion_spritesheet
      {
        Some(fireball_spritesheet),
          Some(fireball_animation),
          Some(explosion_spritesheet)
        -> {
          let explosion_animation =
            spritesheet.animation(
              name: "explosion",
              frames: list.range(1, 44),
              frame_duration: 40.0,
              loop: spritesheet.Once,
            )

          let visuals =
            spell.SpellVisuals(
              projectile_spritesheet: fireball_spritesheet,
              projectile_animation: fireball_animation,
              hit_spritesheet: explosion_spritesheet,
              hit_animation: explosion_animation,
            )

          let spell_rewards = generate_spell_rewards(visuals)

          #(
            Model(..model, showing_spell_rewards: True),
            effect.batch([
              tiramisu_ui.dispatch_to_lustre(ui.ShowSpellRewards(spell_rewards)),
              effect.exit_pointer_lock(),
            ]),
            Some(physics_world),
          )
        }
        _, _, _ -> #(model, effect.none(), Some(physics_world))
      }
    }
    UIMessage(ui_msg) -> handle_ui_message(model, ui_msg, physics_world, ctx)
  }
}

fn handle_tick(
  model: Model,
  physics_world: physics.PhysicsWorld(Id),
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(physics.PhysicsWorld(Id))) {
  // Only process game logic if game is in playing phase
  use <- bool.guard(model.game_phase != Playing, return: #(
    model,
    effect.none(),
    ctx.physics_world,
  ))

  // Freeze game when showing spell rewards or paused
  let time_scale = case model.showing_spell_rewards, model.is_paused {
    True, _ -> 0.0
    _, True -> 0.0
    False, False -> 1.0
  }
  let scaled_delta = ctx.delta_time *. time_scale

  // Track game time and check if we should decrease spawn interval
  let new_game_time = model.game_time_elapsed_ms +. scaled_delta
  let interval_decrease_threshold = 15_000.0
  // Every 15 seconds
  let should_decrease_interval =
    {
      float.floor(new_game_time /. interval_decrease_threshold)
      >. float.floor(model.game_time_elapsed_ms /. interval_decrease_threshold)
    }
    && model.enemy_spawn_interval_ms > 500

  // Only handle player input if spell rewards are not showing and game is not paused
  let #(player, impulse, camera_pitch, input_effects) = case
    model.showing_spell_rewards,
    model.is_paused
  {
    False, False ->
      player.handle_input(
        model.player,
        velocity: physics.get_velocity(physics_world, id.player())
          |> result.unwrap(Vec3(0.0, 0.0, 0.0)),
        input_state: ctx.input,
        bindings: model.player_bindings,
        pointer_locked: model.camera.pointer_locked,
        camera_pitch: model.camera.pitch,
        physics_world:,
        pointer_locked_msg: PointerLocked,
        pointer_lock_failed_msg: PointerLockFailed,
      )
    _, _ -> #(model.player, vec3f.zero, model.camera.pitch, [])
  }

  let #(enemies, enemy_effects) =
    list.map(model.enemies, fn(enemy) {
      enemy.update(
        enemy,
        target: player.position,
        enemy_velocity: physics.get_velocity(physics_world, enemy.id)
          |> result.unwrap(Vec3(0.0, 0.0, 0.0)),
        physics_world:,
        delta_time: scaled_delta /. 1000.0,
        enemy_attacks_player_msg: EnemyAttacksPlayer,
      )
    })
    |> list.unzip()

  // Update projectiles and create explosions on collision
  let #(updated_projectiles, projectile_hits, spell_effect) =
    spell.update(
      model.projectiles,
      model.enemies,
      scaled_delta,
      ProjectileDamagedEnemy,
    )

  // Update existing explosions and add new ones
  let all_hits = list.append(model.projectile_hits, projectile_hits)
  let updated_hits = spell.update_projectile_hits(all_hits, scaled_delta)

  // Only update physics if game is not paused (not showing spell rewards or manually paused)
  let physics_world = case model.showing_spell_rewards, model.is_paused {
    False, False -> {
      physics.set_velocity(physics_world, id.player(), player.velocity)
      |> physics.apply_impulse(id.player(), impulse)
      // Apply pending player knockback AFTER setting velocity
      |> fn(pw) {
        case model.pending_player_knockback {
          Some(knockback) -> physics.apply_impulse(pw, id.player(), knockback)
          _ -> pw
        }
      }
      |> list.fold(over: enemies, from: _, with: fn(acc, enemy) {
        physics.set_velocity(acc, enemy.id, enemy.velocity)
      })
      // Apply projectile knockback to enemies
      |> list.fold(over: projectile_hits, from: _, with: fn(pw, hit) {
        let knockback_force = 80.0
        let Vec3(horizontal_x, _, horizontal_z) =
          Vec3(hit.direction.x, 0.0, hit.direction.z)
          |> vec3f.normalize()
          |> vec3f.scale(knockback_force)

        let total_knockback = Vec3(horizontal_x, 1.0, horizontal_z)

        physics.apply_impulse(pw, hit.enemy_id, total_knockback)
      })
      |> physics.step()
      // After physics step, manually set the player rotation
      |> fn(pw) {
        let player_transform = case physics.get_transform(pw, id.player()) {
          Ok(current_transform) -> {
            // Keep physics position, but use player's input rotation
            current_transform
            |> transform.with_quaternion_rotation(player.quaternion_rotation)
          }
          Error(_) ->
            transform.at(position: player.position)
            |> transform.with_quaternion_rotation(player.quaternion_rotation)
        }
        physics.update_body_transform(pw, id.player(), player_transform)
      }
    }
    _, _ -> physics_world
  }

  // Read position from physics, rotation is controlled by input
  let player_position =
    physics.get_transform(physics_world, id.player())
    |> result.map(transform.position)
    |> result.unwrap(or: model.player.position)

  let enemies = list.map(enemies, enemy.after_physics_update(_, physics_world))

  let nearest_enemy = player.nearest_enemy_position(player, enemies)

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
    list.fold(updated_xp_shards, #([], 0), fn(acc, shard) {
      let #(shards, xp) = acc
      case xp_shard.should_collect(shard, player_position) {
        True -> #(shards, xp + xp_shard.xp_value)
        False -> #([shard, ..shards], xp)
      }
    })

  let #(player, leveled_up) =
    player
    |> player.with_position(player_position)
    |> player.add_xp(collected_xp)

  let #(player, cast_result, death_effect, next_projectile_id) =
    player.update(
      player,
      nearest_enemy,
      scaled_delta,
      PlayerDied,
      model.next_projectile_id,
    )

  // Add newly cast projectile
  let updated_projectiles = case cast_result {
    Some(projectile) -> [projectile, ..updated_projectiles]
    None -> updated_projectiles
  }

  let new_score = score.update(player, model.score, scaled_delta)

  let ui_effect =
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
        // Score
        score: new_score,
      )),
    )

  // Dispatch level-up message if player leveled up
  let level_up_effect = case leveled_up {
    True ->
      effect.from(fn(dispatch) { dispatch(PlayerLeveledUp(player.level)) })
    False -> effect.none()
  }

  // Update screen shake timer
  let camera =
    camera.update(
      model.camera,
      player:,
      new_pitch: camera_pitch,
      delta_time: scaled_delta,
    )

  // Create interval decrease effect if needed
  let interval_decrease_effect = case should_decrease_interval {
    True -> effect.from(fn(dispatch) { dispatch(EnemySpawnIntervalDecreased) })
    False -> effect.none()
  }

  let effects =
    effect.batch([
      effect.tick(Tick),
      effect.batch(enemy_effects),
      effect.batch(input_effects),
      spell_effect,
      ui_effect,
      death_effect,
      level_up_effect,
      interval_decrease_effect,
    ])

  #(
    Model(
      ..model,
      player:,
      camera:,
      projectiles: updated_projectiles,
      projectile_hits: updated_hits,
      next_projectile_id:,
      enemies:,
      xp_shards: remaining_shards,
      pending_player_knockback: None,
      score: new_score,
      game_time_elapsed_ms: new_game_time,
    ),
    effects,
    Some(physics_world),
  )
}

fn handle_assets_loaded(
  model: Model,
  assets: asset.BatchLoadResult,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(physics.PhysicsWorld(Id))) {
  let assert Ok(floor_fbx) =
    asset.get_fbx(assets.cache, "PSX_Dungeon/Models/Floor_Tiles.fbx")
  let assert Ok(floor_texture) =
    asset.get_texture(assets.cache, "PSX_Dungeon/Textures/TEX_Ground_04.png")
  let assert Ok(box_fbx) =
    asset.get_fbx(assets.cache, "PSX_Dungeon/Models/Box.fbx")
  let assert Ok(box_texture) =
    asset.get_texture(assets.cache, "PSX_Dungeon/Textures/TEX_Crate_01.png")

  // Load XP coin texture and create spritesheet
  let assert Ok(xp_texture) =
    asset.get_texture(assets.cache, "spr_coin_azu.png")
  let assert Ok(xp_spritesheet) =
    spritesheet.from_grid(xp_texture, columns: 4, rows: 1)

  let xp_animation =
    spritesheet.animation(
      name: "idle",
      frames: [0, 1, 2, 3],
      frame_duration: 500.0,
      loop: spritesheet.Repeat,
    )

  // Load fireball texture and create spritesheet
  let assert Ok(fireball_texture) =
    asset.get_texture(assets.cache, "SPRITESHEET_Files/FireBall_2_64x64.png")
  let assert Ok(fireball_spritesheet) =
    spritesheet.from_grid(fireball_texture, columns: 45, rows: 1)

  let fireball_animation =
    spritesheet.animation(
      name: "fireball",
      frames: list.range(1, 45),
      frame_duration: 50.0,
      loop: spritesheet.Repeat,
    )

  // Load explosion texture and create spritesheet
  let assert Ok(explosion_texture) =
    asset.get_texture(assets.cache, "SPRITESHEET_Files/Explosion_2_64x64.png")
  let assert Ok(explosion_spritesheet) =
    spritesheet.from_grid(explosion_texture, columns: 44, rows: 1)

  let explosion_animation =
    spritesheet.animation(
      name: "explosion",
      frames: list.range(1, 44),
      frame_duration: 40.0,
      loop: spritesheet.Once,
    )

  // Create spell visuals for fireball
  let fireball_visuals =
    spell.SpellVisuals(
      projectile_spritesheet: fireball_spritesheet,
      projectile_animation: fireball_animation,
      hit_spritesheet: explosion_spritesheet,
      hit_animation: explosion_animation,
    )

  // Load player sprite textures (single frame images)
  let assert Ok(mago_idle_texture) =
    asset.get_texture(assets.cache, "mago_idle.png")
  let assert Ok(mago_idle_spritesheet) =
    spritesheet.from_grid(mago_idle_texture, columns: 1, rows: 1)
  let mago_idle_animation =
    spritesheet.animation(
      name: "idle",
      frames: [0],
      frame_duration: 150.0,
      loop: spritesheet.Repeat,
    )

  let assert Ok(mago_attacking_texture) =
    asset.get_texture(assets.cache, "mago_attacking.png")
  let assert Ok(mago_attacking_spritesheet) =
    spritesheet.from_grid(mago_attacking_texture, columns: 1, rows: 1)
  let mago_attacking_animation =
    spritesheet.animation(
      name: "attacking",
      frames: [0],
      frame_duration: 80.0,
      loop: spritesheet.Repeat,
    )

  // Set up player's initial spell and sprites
  let assert Ok(updated_wand) =
    wand.set_spell(model.player.wand, 0, spell.fireball(fireball_visuals))
  let updated_player =
    player.Player(..model.player, wand: updated_wand)
    |> player.set_spritesheets(
      mago_idle_spritesheet,
      mago_idle_animation,
      mago_attacking_spritesheet,
      mago_attacking_animation,
    )

  let boxes =
    list.map(list.range(0, 19), fn(_) {
      transform.identity
      |> transform.with_position(vec3.Vec3(
        { float.random() *. 100.0 } -. 50.0,
        3.788888888,
        { float.random() *. 100.0 } -. 50.0,
      ))
    })
    |> map.box(box_fbx.scene, _)
    |> Some

  let ground =
    list.flatten(
      list.map(list.range(0, 36), fn(x) {
        list.map(list.range(0, 36), fn(z) {
          transform.identity
          |> transform.with_position(Vec3(
            int.to_float(x) -. 18.0,
            0.0,
            int.to_float(z) -. 18.0,
          ))
          |> transform.with_scale(Vec3(0.05, 0.05, 0.05))
        })
      }),
    )
    |> map.ground(floor_fbx.scene, _)
    |> Some

  let effects =
    effect.batch([
      effect.from(fn(_) {
        asset.apply_texture_to_object(
          floor_fbx.scene,
          floor_texture,
          asset.NearestFilter,
        )
      }),
      effect.tick(Tick),
      tiramisu_ui.dispatch_to_lustre(ui.GamePhaseChanged(ui.Playing)),
      effect.request_pointer_lock(
        on_success: PointerLocked,
        on_error: PointerLockFailed,
      ),
      effect.from(fn(_) {
        asset.apply_texture_to_object(
          box_fbx.scene,
          box_texture,
          asset.NearestFilter,
        )
      }),
      effect.interval(
        ms: model.enemy_spawn_interval_ms,
        msg: EnemySpawned,
        on_created: EnemySpawnStarted,
      ),
    ])

  #(
    Model(
      ..model,
      player: updated_player,
      ground:,
      boxes:,
      game_phase: Playing,
      xp_spritesheet: Some(xp_spritesheet),
      xp_animation: Some(xp_animation),
      fireball_spritesheet: Some(fireball_spritesheet),
      fireball_animation: Some(fireball_animation),
      explosion_spritesheet: Some(explosion_spritesheet),
    ),
    effects,
    ctx.physics_world,
  )
}

fn handle_ui_message(
  model: Model,
  ui_msg: ui.UiToGameMsg,
  physics_world: physics.PhysicsWorld(Id),
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(physics.PhysicsWorld(Id))) {
  case ui_msg {
    ui.GameStarted -> #(
      model,
      effect.from(fn(dispatch) { dispatch(GameStarted) }),
      Some(physics_world),
    )
    ui.GameRestarted -> #(
      model,
      effect.from(fn(dispatch) { dispatch(GameRestarted) }),
      Some(physics_world),
    )
    ui.UpdatePlayerInventory(wand_slots, spell_bag) -> {
      // Update player's wand and spell bag from UI changes
      let updated_wand = wand.Wand(..model.player.wand, slots: wand_slots)
      let updated_player =
        player.Player(..model.player, wand: updated_wand, spell_bag: spell_bag)

      #(
        Model(..model, player: updated_player),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.SpellRewardSelected(selected_spell) -> {
      // Add the selected spell to the player's spell bag
      io.println("=== SPELL REWARD SELECTED ===")
      let spell_name = case selected_spell {
        spell.DamageSpell(dmg) -> dmg.name
        spell.ModifierSpell(mod) -> mod.name
      }
      io.println("Selected spell: " <> spell_name)

      let updated_spell_bag =
        spell_bag.add_spell(model.player.spell_bag, selected_spell)

      let spell_count = spell_bag.list_spells(updated_spell_bag) |> list.length
      io.println("Total spells in bag: " <> int.to_string(spell_count))

      let updated_player =
        player.Player(..model.player, spell_bag: updated_spell_bag)

      // Keep the game paused, modal stays open for inventory management
      #(
        Model(..model, player: updated_player),
        effect.none(),
        ctx.physics_world,
      )
    }
    ui.LevelUpComplete -> {
      // User is done managing inventory, resume the game
      io.println("=== LEVEL UP COMPLETE ===")

      #(
        Model(..model, showing_spell_rewards: False),
        effect.request_pointer_lock(
          on_success: PointerLocked,
          on_error: PointerLockFailed,
        ),
        ctx.physics_world,
      )
    }
    ui.GamePaused -> {
      io.println("=== GAME PAUSED ===")
      #(
        Model(..model, is_paused: True),
        effect.exit_pointer_lock(),
        ctx.physics_world,
      )
    }
    ui.GameResumed -> {
      io.println("=== GAME RESUMED ===")
      // Pointer lock is requested by the UI, not here
      #(Model(..model, is_paused: False), effect.none(), ctx.physics_world)
    }
  }
}

fn view(model: Model, _ctx: tiramisu.Context(Id)) -> scene.Node(Id) {
  use <- bool.guard(
    model.game_phase != Playing,
    return: scene.empty(id.scene(), transform.identity, []),
  )

  let camera = camera.view(model.camera, model.player)

  let ground = case model.ground {
    Some(ground) -> [map.view_ground(ground, id.ground())]
    None -> []
  }

  let boxes = case model.boxes {
    Some(boxes) -> [map.view_box(boxes, id.box())]
    None -> []
  }

  // Render projectiles with sprites
  let projectiles =
    spell.view(id.projectile, model.projectiles, model.camera.position)

  // Render explosions with sprites
  let explosions =
    list.map(model.projectile_hits, spell.view_hits(_, model.camera.position))

  // Render XP shards
  let xp_shards = case model.xp_spritesheet, model.xp_animation {
    Some(sheet), Some(animation) ->
      list.map(model.xp_shards, fn(shard) {
        xp_shard.render(shard, model.camera.position, sheet, animation)
      })
    _, _ -> []
  }

  // Pass camera position for billboard rotation
  let enemy = model.enemies |> list.map(enemy.render(_, model.camera.position))
  scene.empty(
    id: id.scene(),
    transform: transform.identity,
    children: list.flatten([
      enemy,
      ground,
      boxes,
      projectiles,
      explosions,
      xp_shards,
      [
        player.view(id.player(), model.player),
        camera,
        scene.light(
          id: id.ambient(),
          light: {
            let assert Ok(light) =
              light.ambient(color: 0xffffff, intensity: 0.5)
            light
          },
          transform: transform.identity,
        ),
        scene.light(
          id: id.directional(),
          light: {
            let assert Ok(light) =
              light.directional(color: 0xffffff, intensity: 2.0)
            light
          },
          transform: transform.at(position: Vec3(5.0, 10.0, 7.5)),
        ),
      ],
    ]),
  )
}
