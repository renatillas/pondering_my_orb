import gleam/bool
import gleam/float
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import paint/canvas
import pondering_my_orb/camera
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id.{type Id}
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/spell
import pondering_my_orb/ui
import pondering_my_orb/wand
import tiramisu
import tiramisu/asset
import tiramisu/background
import tiramisu/debug
import tiramisu/effect.{type Effect}
import tiramisu/input
import tiramisu/light
import tiramisu/physics
import tiramisu/scene
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
    // Enemies
    enemies: List(Enemy(Id)),
    enemy_spawner_id: Option(Int),
    next_enemy_id: Int,
    // Inventory
    inventory_open: Bool,
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
  EnemyAttacksPlayer(damage: Float, enemy_position: Vec3(Float))
  // Projectiles
  ProjectileDamagedEnemy(Id, Float, Vec3(Float))
  EnemyKilled(Id)
  // Camera
  PointerLocked
  PointerLockFailed
  // Inventory
  ToggleInventory
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

  let effects =
    effect.batch([
      effect.from(fn(_) { debug.show_collider_wireframes(physics_world, True) }),
    ])

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
      enemies: [],
      enemy_spawner_id: None,
      next_enemy_id: 0,
      inventory_open: False,
    ),
    effects,
    Some(physics_world),
  )
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), Option(_)) {
  let assert Some(physics_world) = ctx.physics_world

  echo msg

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

      echo model.enemy_spawner_id

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
    ToggleInventory -> {
      let new_inventory_state = !model.inventory_open

      // Exit pointer lock when opening inventory, request it when closing
      let pointer_lock_effect = case new_inventory_state {
        True -> effect.exit_pointer_lock()
        False ->
          effect.request_pointer_lock(
            on_success: PointerLocked,
            on_error: PointerLockFailed,
          )
      }

      // Update camera pointer_locked state when closing inventory
      let new_camera = case new_inventory_state {
        False -> camera.Camera(..model.camera, pointer_locked: False)
        True -> model.camera
      }

      #(
        Model(..model, inventory_open: new_inventory_state, camera: new_camera),
        pointer_lock_effect,
        ctx.physics_world,
      )
    }
    Tick -> {
      // Only process game logic if game is in playing phase
      use <- bool.guard(model.game_phase != Playing, return: #(
        model,
        effect.none(),
        // NOTE: do tick?
        ctx.physics_world,
      ))

      // Check for I key press to toggle inventory
      let inventory_toggle_effect = case
        input.is_key_just_pressed(ctx.input, input.KeyI)
      {
        True -> effect.from(fn(dispatch) { dispatch(ToggleInventory) })
        False -> effect.none()
      }

      // Apply time scale when inventory is open (stop game completely)
      let time_scale = case model.inventory_open {
        True -> 0.0
        False -> 1.0
      }
      let scaled_delta = ctx.delta_time *. time_scale

      // Only handle player input if inventory is closed
      let #(player, impulse, camera_pitch, input_effects) = case
        model.inventory_open
      {
        False ->
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
        True -> #(model.player, vec3f.zero, model.camera.pitch, [])
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

      let #(updated_projectiles, spell_effect, projectile_hits) =
        spell.update_with_hits(
          model.projectiles,
          model.enemies,
          scaled_delta,
          ProjectileDamagedEnemy,
        )

      // Only update physics if game is not paused (inventory closed)
      let physics_world = case model.inventory_open {
        False -> {
          physics.set_velocity(physics_world, id.player(), player.velocity)
          |> physics.apply_impulse(id.player(), impulse)
          // Apply pending player knockback AFTER setting velocity
          |> fn(pw) {
            case model.pending_player_knockback {
              Some(knockback) ->
                physics.apply_impulse(pw, id.player(), knockback)
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
              Vec3(hit.projectile_direction.x, 0.0, hit.projectile_direction.z)
              |> vec3f.normalize()
              |> vec3f.scale(knockback_force)

            let total_knockback = Vec3(horizontal_x, 1.0, horizontal_z)

            physics.apply_impulse(pw, hit.enemy_id, total_knockback)
          })
          |> physics.step()
        }
        True -> physics_world
      }

      let player_position =
        physics.get_transform(physics_world, id.player())
        |> result.map(transform.position)
        |> result.unwrap(or: model.player.position)

      let enemies =
        list.map(enemies, enemy.after_physics_update(_, physics_world))

      let nearest_enemy = player.nearest_enemy_position(player, enemies)

      let #(player, cast_result, death_effect) =
        player
        |> player.with_position(player_position)
        |> player.update(nearest_enemy, scaled_delta, PlayerDied)

      // Add newly cast projectile
      let updated_projectiles = case cast_result {
        Some(projectile) -> [projectile, ..updated_projectiles]
        None -> updated_projectiles
      }

      let ui_effect =
        tiramisu_ui.dispatch_to_lustre(
          ui.GameStateUpdated(ui.GameState(
            player_health: player.current_health,
            player_max_health: player.max_health,
            player_mana: player.wand.current_mana,
            player_max_mana: player.wand.max_mana,
            wand_slots: player.wand.slots,
            spell_bag: player.spell_bag,
            inventory_open: model.inventory_open,
          )),
        )

      // Update screen shake timer
      let camera =
        camera.update(
          model.camera,
          player:,
          new_pitch: camera_pitch,
          delta_time: scaled_delta,
        )

      let effects =
        effect.batch([
          effect.tick(Tick),
          effect.batch(enemy_effects),
          effect.batch(input_effects),
          spell_effect,
          ui_effect,
          inventory_toggle_effect,
          death_effect,
        ])

      #(
        Model(
          ..model,
          player:,
          camera:,
          projectiles: updated_projectiles,
          enemies:,
          pending_player_knockback: None,
        ),
        effects,
        Some(physics_world),
      )
    }
    AssetsLoaded(assets:) -> update_model_with_assets(model, assets, ctx)
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
        ),
        effect.none(),
        ctx.physics_world,
      )
    }
    EnemySpawned -> {
      // Don't spawn enemies when inventory is open or game is paused
      case model.inventory_open {
        True -> #(model, effect.none(), Some(physics_world))
        False -> #(
          Model(
            ..model,
            enemies: [
              enemy.basic(
                id.enemy(model.next_enemy_id),
                position: Vec3(0.0, 3.0, 0.0),
              ),
              ..model.enemies
            ],
            next_enemy_id: model.next_enemy_id + 1,
          ),
          effect.none(),
          Some(physics_world),
        )
      }
    }
    EnemySpawnStarted(id) -> #(
      Model(..model, enemy_spawner_id: Some(id)),
      effect.none(),
      Some(physics_world),
    )
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
          Model(
            ..model,
            enemies: list.filter(model.enemies, fn(enemy) {
              killed_enemy.id != enemy.id
            }),
          ),
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
    EnemyKilled(_) -> #(model, effect.none(), Some(physics_world))
    UIMessage(ui_msg) -> {
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
            player.Player(
              ..model.player,
              wand: updated_wand,
              spell_bag: spell_bag,
            )

          #(
            Model(..model, player: updated_player),
            effect.none(),
            ctx.physics_world,
          )
        }
      }
    }
  }
}

fn update_model_with_assets(
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
      effect.from(fn(_) {
        asset.apply_texture_to_object(
          box_fbx.scene,
          box_texture,
          asset.NearestFilter,
        )
      }),
      effect.interval(
        ms: 2000,
        msg: EnemySpawned,
        on_created: EnemySpawnStarted,
      ),
    ])
  #(
    Model(..model, ground:, boxes:, game_phase: Playing),
    effects,
    ctx.physics_world,
  )
}

fn view(model: Model, _ctx: tiramisu.Context(Id)) -> List(scene.Node(Id)) {
  use <- bool.guard(model.game_phase != Playing, return: [])

  let camera = camera.view(model.camera, model.player)

  let ground = case model.ground {
    Some(ground) -> [map.view_ground(ground, id.ground())]
    None -> []
  }

  let boxes = case model.boxes {
    Some(boxes) -> [map.view_box(boxes, id.box())]
    None -> []
  }

  let projectiles = spell.view(id.projectile, model.projectiles)

  // Pass camera position for billboard rotation
  let enemy = model.enemies |> list.map(enemy.render(_, model.camera.position))
  list.flatten([
    enemy,
    ground,
    boxes,
    projectiles,
    [
      player.render(id.player(), model.player),
      camera,
      scene.light(
        id: id.ambient(),
        light: {
          let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
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
  ])
}
