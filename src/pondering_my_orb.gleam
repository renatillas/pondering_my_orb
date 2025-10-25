import gleam/float
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam_community/maths
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id.{type Id}
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/spell
import pondering_my_orb/ui
import tiramisu
import tiramisu/asset
import tiramisu/background
import tiramisu/camera
import tiramisu/debug
import tiramisu/effect.{type Effect}
import tiramisu/input
import tiramisu/light
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui as tiramisu_ui
import vec/vec3.{Vec3}

pub type Model {
  Model(
    // Map
    ground: Option(map.Obstacle(map.Ground)),
    boxes: Option(map.Obstacle(map.Box)),
    // Player
    player: player.Player,
    player_bindings: input.InputBindings(player.PlayerAction),
    // Camera settings
    pointer_locked: Bool,
    camera_distance: Float,
    camera_height: Float,
    // Projectiles
    projectiles: List(spell.Projectile),
    // Enemies
    enemies: List(Enemy(Id)),
    next_enemy_id: Int,
  )
}

pub type Msg {
  Tick
  // Map
  AssetsLoaded(assets: asset.BatchLoadResult)
  // Enemies
  EnemySpawnStarted(Int)
  EnemySpawned
  EnemyAttacksPlayer(Int)
  // Projectiles
  ProjectileDamagedEnemy(Id, Float)
  EnemyKilled(Id)
  // Camera
  PointerLocked
  PointerLockFailed
}

pub fn main() -> Nil {
  // Start the Lustre UI overlay
  ui.start()

  tiramisu.run(
    dimensions: None,
    background: background.Color(0x1a1a2e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(_ctx: tiramisu.Context(Id)) -> #(Model, Effect(Msg), Option(_)) {
  let assets = [
    asset.FBXAsset("PSX_Dungeon/Models/Box.fbx", None),
    asset.FBXAsset(
      "PSX_Dungeon/Models/Floor_Tiles.fbx",
      Some("PSX_Dungeon/Textures/"),
    ),
    asset.TextureAsset("PSX_Dungeon/Textures/TEX_Ground_04.png"),
    asset.TextureAsset("PSX_Dungeon/Textures/TEX_Crate_01.png"),
  ]

  let start_spawning_enemies =
    effect.interval(ms: 2000, msg: EnemySpawned, on_created: EnemySpawnStarted)

  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: Vec3(0.0, -9.81, 0.0)))

  let effects =
    effect.batch([
      effect.from_promise(promise.map(
        asset.load_batch_simple(assets),
        AssetsLoaded,
      )),
      effect.tick(Tick),
      effect.from(fn(_) { debug.show_collider_wireframes(physics_world, True) }),
      start_spawning_enemies,
    ])

  let player_bindings = player.default_bindings()

  #(
    Model(
      ground: None,
      boxes: None,
      player: player.init(),
      player_bindings:,
      pointer_locked: False,
      camera_distance: 5.0,
      camera_height: 2.0,
      projectiles: [],
      enemies: [],
      next_enemy_id: 0,
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

  case msg {
    Tick -> {
      let #(player, impulse, pointer_locked, input_effects) =
        player.handle_input(
          model.player,
          velocity: physics.get_velocity(physics_world, id.player())
            |> result.unwrap(Vec3(0.0, 0.0, 0.0)),
          input_state: ctx.input,
          bindings: model.player_bindings,
          pointer_locked: model.pointer_locked,
          physics_world:,
          pointer_locked_msg: PointerLocked,
          pointer_lock_failed_msg: PointerLockFailed,
        )

      let #(enemies, enemy_effects) =
        list.map(model.enemies, fn(enemy) {
          enemy.update(
            enemy,
            target: player.position,
            enemy_velocity: physics.get_velocity(physics_world, enemy.id)
              |> result.unwrap(Vec3(0.0, 0.0, 0.0)),
            physics_world:,
            enemy_attacks_player_msg: EnemyAttacksPlayer,
          )
        })
        |> list.unzip()

      let physics_world =
        physics.set_velocity(physics_world, id.player(), player.velocity)
        |> physics.apply_impulse(id.player(), impulse)
        |> list.fold(over: enemies, from: _, with: fn(acc, enemy) {
          physics.set_velocity(acc, enemy.id, enemy.velocity)
        })

      let physics_world = physics.step(physics_world)

      let player_position =
        physics.get_transform(physics_world, id.player())
        |> result.map(transform.position)
        |> result.unwrap(or: model.player.position)

      let enemies =
        list.map(enemies, enemy.after_physics_update(_, physics_world))

      let nearest_enemy = player.nearest_enemy_position(player, enemies)

      let #(player, cast_result) =
        player
        |> player.with_position(player_position)
        |> player.update(nearest_enemy, ctx.delta_time)

      let projectiles = case cast_result {
        Some(projectile) -> {
          [projectile, ..model.projectiles]
        }
        None -> model.projectiles
      }

      let #(updated_projectiles, spell_effect) =
        spell.update(
          projectiles,
          nearest_enemy,
          ctx.delta_time,
          ProjectileDamagedEnemy,
        )

      let ui_effect =
        tiramisu_ui.dispatch_to_lustre(
          ui.GameStateUpdated(ui.GameState(
            player_health: player.current_health,
            player_max_health: player.max_health,
            player_mana: player.wand.current_mana,
            player_max_mana: player.wand.max_mana,
            wand_slots: player.wand.slots,
          )),
        )

      #(
        Model(
          ..model,
          player:,
          pointer_locked:,
          projectiles: updated_projectiles,
          enemies:,
        ),
        effect.batch([
          effect.tick(Tick),
          effect.batch(enemy_effects),
          effect.batch(input_effects),
          spell_effect,
          ui_effect,
        ]),
        Some(physics_world),
      )
    }
    AssetsLoaded(assets:) -> update_model_with_assets(model, assets, ctx)
    PointerLocked -> #(
      Model(..model, pointer_locked: True),
      effect.none(),
      ctx.physics_world,
    )
    PointerLockFailed -> #(
      Model(..model, pointer_locked: False),
      effect.none(),
      ctx.physics_world,
    )
    EnemyAttacksPlayer(amount) -> {
      #(
        Model(..model, player: player.take_damage(model.player, amount)),
        effect.none(),
        Some(physics_world),
      )
    }
    EnemySpawned -> #(
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
    EnemySpawnStarted(_) -> #(model, effect.none(), Some(physics_world))
    ProjectileDamagedEnemy(id, damage) -> {
      let enemy =
        list.find(model.enemies, fn(enemy) { enemy.id == id })
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
          Some(physics_world),
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
          Some(physics_world),
        )
        _ -> #(model, effect.none(), Some(physics_world))
      }
    }
    EnemyKilled(_) -> #(model, effect.none(), Some(physics_world))
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
      effect.from(fn(_) {
        asset.apply_texture_to_object(
          box_fbx.scene,
          box_texture,
          asset.NearestFilter,
        )
      }),
    ])
  #(Model(..model, ground:, boxes:), effects, ctx.physics_world)
}

fn view(model: Model, _ctx: tiramisu.Context(Id)) -> List(scene.Node(Id)) {
  let assert Ok(cam) =
    camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  let Vec3(_player_pitch, player_yaw, _) = model.player.rotation
  let Vec3(player_x, player_y, player_z) = model.player.position

  let behind_x = -1.0 *. maths.sin(player_yaw) *. model.camera_distance
  let behind_z = -1.0 *. maths.cos(player_yaw) *. model.camera_distance

  let camera_position =
    Vec3(
      player_x +. behind_x,
      player_y +. model.camera_height,
      player_z +. behind_z,
    )

  let look_at_target = Vec3(player_x, player_y +. 1.0, player_z)

  let ground = case model.ground {
    Some(ground) -> [map.view_ground(ground, id.ground())]
    None -> []
  }

  let boxes = case model.boxes {
    Some(boxes) -> [map.view_box(boxes, id.box())]
    None -> []
  }

  let projectiles = spell.view(id.projectile, model.projectiles)

  let enemy = model.enemies |> list.map(enemy.render)
  list.flatten([
    enemy,
    ground,
    boxes,
    projectiles,
    [
      player.render(id.player(), model.player),
      scene.camera(
        id: id.camera(),
        camera: cam,
        transform: transform.at(position: camera_position),
        look_at: Some(look_at_target),
        active: True,
        viewport: None,
      ),
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
