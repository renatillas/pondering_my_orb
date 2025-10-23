import gleam/float
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option
import gleam/result
import gleam_community/maths
import pondering_my_orb/enemy
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/spell
import pondering_my_orb/wand
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
import vec/vec3

pub type Id {
  Camera
  Boxes
  Ambient
  Directional
  Ground
  Cube1
  Cube2
  Enemy(Int)
  Player
  Projectile(Int)
}

pub type Model {
  Model(
    next_enemy_id: Int,
    enemies: List(enemy.Enemy(Id)),
    ground: option.Option(map.Obstacle(map.Ground)),
    boxes: option.Option(map.Obstacle(map.Box)),
    player: player.Player,
    player_bindings: input.InputBindings(player.PlayerAction),
    // Camera
    pointer_locked: Bool,
    camera_distance: Float,
    camera_height: Float,
    // Projectiles
    projectiles: List(spell.Projectile),
  )
}

pub type Msg {
  Tick
  EnemyAttacksPlayer(Int)
  EnemyKilled(Id)
  ProjectileDamagedEnemy(Id, Float)
  EnemySpawned
  EnemySpawnStarted(Int)
  AssetsLoaded(assets: asset.BatchLoadResult)
  PointerLocked
  PointerLockFailed
}

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x1a1a2e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(_ctx: tiramisu.Context(Id)) -> #(Model, Effect(Msg), option.Option(_)) {
  let assets = [
    asset.FBXAsset("PSX_Dungeon/Models/Box.fbx", option.None),
    asset.FBXAsset(
      "PSX_Dungeon/Models/Floor_Tiles.fbx",
      option.Some("PSX_Dungeon/Textures/"),
    ),
    asset.TextureAsset("PSX_Dungeon/Textures/TEX_Ground_04.png"),
    asset.TextureAsset("PSX_Dungeon/Textures/TEX_Crate_01.png"),
  ]

  let start_spawning_enemies =
    effect.interval(ms: 5000, msg: EnemySpawned, on_created: EnemySpawnStarted)

  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: vec3.Vec3(0.0, -9.81, 0.0)))

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
      ground: option.None,
      boxes: option.None,
      enemies: [],
      player: player.init(),
      player_bindings:,
      pointer_locked: False,
      camera_distance: 5.0,
      camera_height: 2.0,
      projectiles: [],
      next_enemy_id: 0,
    ),
    effects,
    option.Some(physics_world),
  )
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), option.Option(_)) {
  let assert option.Some(physics_world) = ctx.physics_world

  case msg {
    Tick -> {
      let #(player, impulse, pointer_locked, input_effects) =
        player.handle_input(
          model.player,
          velocity: physics.get_velocity(physics_world, Player)
            |> result.unwrap(vec3.Vec3(0.0, 0.0, 0.0)),
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
              |> result.unwrap(vec3.Vec3(0.0, 0.0, 0.0)),
            physics_world:,
            player_id: Player,
            enemy_attacks_player_msg: EnemyAttacksPlayer,
          )
        })
        |> list.unzip()

      let physics_world =
        physics.set_velocity(physics_world, Player, player.velocity)
        |> physics.apply_impulse(Player, impulse)
        |> list.fold(over: enemies, from: _, with: fn(acc, enemy) {
          physics.set_velocity(acc, enemy.id, enemy.velocity)
        })

      let physics_world = physics.step(physics_world)

      let player_position =
        physics.get_transform(physics_world, Player)
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
        Ok(wand.CastSuccess(projectile, _, _)) -> {
          [projectile, ..model.projectiles]
        }
        _ -> model.projectiles
      }

      let #(updated_projectiles, spell_effect) =
        spell.update(
          projectiles,
          nearest_enemy,
          ctx.delta_time,
          ProjectileDamagedEnemy,
        )

      #(
        Model(
          ..model,
          player:,
          pointer_locked:,
          enemies:,
          projectiles: updated_projectiles,
        ),
        effect.batch([
          effect.tick(Tick),
          effect.batch(enemy_effects),
          effect.batch(input_effects),
          spell_effect,
        ]),
        option.Some(physics_world),
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
        option.Some(physics_world),
      )
    }
    EnemySpawned -> #(
      Model(
        ..model,
        enemies: [
          enemy.basic(
            Enemy(model.next_enemy_id),
            position: vec3.Vec3(0.0, 3.0, 0.0),
          ),
          ..model.enemies
        ],
        next_enemy_id: model.next_enemy_id + 1,
      ),
      effect.none(),
      option.Some(physics_world),
    )
    EnemySpawnStarted(_) -> #(model, effect.none(), option.Some(physics_world))
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
          option.Some(physics_world),
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
          option.Some(physics_world),
        )
        _ -> #(model, effect.none(), option.Some(physics_world))
      }
    }
    EnemyKilled(_) -> #(model, effect.none(), option.Some(physics_world))
  }
}

fn update_model_with_assets(
  model: Model,
  assets: asset.BatchLoadResult,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), option.Option(physics.PhysicsWorld(Id))) {
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
        float.random() *. 20.0 -. 10.0,
        0.5,
        float.random() *. 20.0 -. 10.0,
      ))
      |> transform.scale_by(vec3.Vec3(0.12, 0.12, 0.12))
    })
    |> map.box(box_fbx.scene, _)
    |> option.Some

  let ground =
    list.flatten(
      list.map(list.range(0, 36), fn(x) {
        list.map(list.range(0, 36), fn(z) {
          transform.identity
          |> transform.with_position(vec3.Vec3(
            int.to_float(x) -. 18.0,
            0.0,
            int.to_float(z) -. 18.0,
          ))
          |> transform.with_scale(vec3.Vec3(0.05, 0.05, 0.05))
        })
      }),
    )
    |> map.ground(floor_fbx.scene, _)
    |> option.Some

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

  let vec3.Vec3(_player_pitch, player_yaw, _) = model.player.rotation
  let vec3.Vec3(player_x, player_y, player_z) = model.player.position

  let behind_x = -1.0 *. maths.sin(player_yaw) *. model.camera_distance
  let behind_z = -1.0 *. maths.cos(player_yaw) *. model.camera_distance

  let camera_position =
    vec3.Vec3(
      player_x +. behind_x,
      player_y +. model.camera_height,
      player_z +. behind_z,
    )

  let look_at_target = vec3.Vec3(player_x, player_y +. 1.0, player_z)

  let ground = case model.ground {
    option.Some(ground) -> [map.render_ground(ground, Ground)]
    option.None -> []
  }

  let boxes = case model.boxes {
    option.Some(boxes) -> [map.render_box(boxes, Boxes)]
    option.None -> []
  }

  let projectiles = spell.view(Projectile, model.projectiles)

  let enemy = model.enemies |> list.map(enemy.render)

  list.flatten([
    enemy,
    ground,
    boxes,
    projectiles,
    [
      player.render(Player, model.player),
      scene.camera(
        id: Camera,
        camera: cam,
        transform: transform.at(position: camera_position),
        look_at: option.Some(look_at_target),
        active: True,
        viewport: option.None,
      ),
      scene.light(
        id: Ambient,
        light: {
          let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
          light
        },
        transform: transform.identity,
      ),
      scene.light(
        id: Directional,
        light: {
          let assert Ok(light) =
            light.directional(color: 0xffffff, intensity: 2.0)
          light
        },
        transform: transform.at(position: vec3.Vec3(5.0, 10.0, 7.5)),
      ),
    ],
  ])
}
