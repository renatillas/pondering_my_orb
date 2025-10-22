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

const damage_cooldown_duration = 2.0

const heal_delay = 3.0

const heal_rate = 2.0

const heal_interval = 0.5

pub type Id {
  Camera
  Boxes
  Ambient
  Directional
  Ground
  Cube1
  Cube2
  Enemy
  Player
}

pub type Model {
  Model(
    enemy: enemy.Enemy(Id),
    ground: option.Option(map.Obstacle(map.Ground)),
    boxes: option.Option(map.Obstacle(map.Box)),
    player: player.Player,
    player_bindings: input.InputBindings(player.PlayerAction),
    // Camera
    pointer_locked: Bool,
    camera_distance: Float,
    camera_height: Float,
  )
}

pub type Msg {
  Tick
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
    ])

  let enemy = enemy.basic(Enemy, position: vec3.Vec3(10.0, 5.5, 10.0))
  let player_bindings = player.default_bindings()

  #(
    Model(
      ground: option.None,
      boxes: option.None,
      enemy:,
      player: player.init(),
      player_bindings:,
      pointer_locked: False,
      camera_distance: 5.0,
      camera_height: 2.0,
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
      let should_request_lock = case model.pointer_locked {
        False ->
          input.is_left_button_just_pressed(ctx.input)
          || input.is_key_just_pressed(ctx.input, input.KeyC)
        True -> False
      }

      let pointer_lock_effect = case should_request_lock {
        True ->
          effect.request_pointer_lock(
            on_success: PointerLocked,
            on_error: PointerLockFailed,
          )
        False -> effect.none()
      }

      let #(should_exit_pointer_lock, exit_lock_effect) = case
        input.is_key_just_pressed(ctx.input, input.Escape),
        model.pointer_locked
      {
        True, True -> #(True, effect.exit_pointer_lock())
        _, _ -> #(False, effect.none())
      }

      let #(player, player_desired_velocity, impulse) =
        player.handle_input(
          model.player,
          velocity: physics.get_velocity(physics_world, Player)
            |> result.unwrap(vec3.Vec3(0.0, 0.0, 0.0)),
          input_state: ctx.input,
          bindings: model.player_bindings,
          pointer_locked: model.pointer_locked,
          physics_world:,
        )

      let enemy_desired_velocity =
        enemy.follow(
          model.enemy,
          target: player.position,
          enemy_velocity: physics.get_velocity(physics_world, Enemy)
            |> result.unwrap(vec3.Vec3(0.0, 0.0, 0.0)),
          physics_world:,
          player_id: Player,
        )

      let physics_world =
        physics.set_velocity(physics_world, Player, player_desired_velocity)
        |> physics.apply_impulse(Player, impulse)
        |> physics.set_velocity(Enemy, enemy_desired_velocity)

      let physics_world = physics.step(physics_world)

      let player_position =
        physics.get_transform(physics_world, Player)
        |> result.map(transform.position)
        |> result.unwrap(or: model.player.position)

      let enemy_position =
        physics.get_transform(physics_world, Enemy)
        |> result.map(transform.position)
        |> result.unwrap(or: model.enemy.position)

      let player =
        player
        |> player.with_position(player_position)
        |> player.apply_tick()

      let enemy = model.enemy |> enemy.with_position(position: enemy_position)

      let enemy_can_damage = enemy.can_damage(enemy, player.position)

      let player = case enemy_can_damage, player.is_vulnerable {
        True, True -> player.take_damage(player, model.enemy.damage)
        _, _ -> player
      }

      let player = case player.should_passive_heal {
        True -> player.passive_heal(player)
        False -> player
      }

      let pointer_locked = case should_exit_pointer_lock {
        True -> False
        False -> model.pointer_locked
      }
      #(
        Model(..model, player:, pointer_locked:, enemy:),
        effect.batch([
          effect.tick(Tick),
          pointer_lock_effect,
          exit_lock_effect,
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

  let enemy = [enemy.render(model.enemy)]

  list.flatten([
    enemy,
    ground,
    boxes,
    [
      player.render(Player, model.player),
      scene.Camera(
        id: Camera,
        camera: cam,
        transform: transform.at(position: camera_position),
        look_at: option.Some(look_at_target),
        active: True,
        viewport: option.None,
      ),
      scene.Light(
        id: Ambient,
        light: {
          let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
          light
        },
        transform: transform.identity,
      ),
      scene.Light(
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
