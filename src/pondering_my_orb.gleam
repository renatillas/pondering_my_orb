import gleam/bool
import gleam/option.{type Option, None, Some}
import gleam/result
import tiramisu.{type Context}
import tiramisu/background
import tiramisu/camera
import tiramisu/debug
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/input
import tiramisu/light
import tiramisu/material
import tiramisu/physics.{type PhysicsWorld}
import tiramisu/scene
import tiramisu/transform.{type Transform}
import vec/vec3.{type Vec3, Vec3}

pub type Msg {
  Tick
}

pub type Id {
  AmbientLight
  DirectionalLight

  Camera

  Ground
  Player
}

pub type Model {
  Model(camera_position: Vec3(Float))
}

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: None,
    background: background.Color(0x1a1a2e),
    init:,
    view:,
    update:,
  )
}

fn init(_ctx: Context(Id)) -> #(Model, Effect(Msg), Option(PhysicsWorld(Id))) {
  let physics_world =
    physics.new_world(
      physics.WorldConfig(gravity: Vec3(x: 0.0, y: -9.81, z: 0.0)),
    )

  #(
    Model(camera_position: Vec3(x: 0.0, y: 10.0, z: 10.0)),
    effect.tick(Tick),
    Some(physics_world),
  )
}

fn update(
  model: Model,
  _msg: Msg,
  ctx: Context(Id),
) -> #(Model, Effect(Msg), Option(PhysicsWorld(Id))) {
  let assert option.Some(physics_world) = ctx.physics_world
  // debug.show_collider_wireframes(physics_world, True)

  let camera_position = model.camera_position

  let impulse = Vec3(x: 0.0, y: 0.0, z: 0.0)

  let impulse = case input.is_key_pressed(ctx.input, input.KeyW) {
    True -> Vec3(..impulse, z: impulse.z -. 0.1)
    False -> impulse
  }

  let impulse = case input.is_key_pressed(ctx.input, input.KeyS) {
    True -> Vec3(..impulse, z: impulse.z +. 0.1)

    False -> impulse
  }

  let impulse = case input.is_key_pressed(ctx.input, input.KeyA) {
    True -> Vec3(..impulse, x: impulse.x -. 0.1)
    False -> impulse
  }

  let impulse = case input.is_key_pressed(ctx.input, input.KeyD) {
    True -> Vec3(..impulse, x: impulse.x +. 0.1)
    False -> impulse
  }

  let impulse = case input.is_key_just_pressed(ctx.input, input.Space) {
    True -> Vec3(..impulse, y: 5.0)
    False -> impulse
  }

  let updated_physics_world =
    physics.apply_impulse(physics_world, Player, impulse)
    |> physics.step()

  let assert Ok(player_transform) = physics.get_transform(physics_world, Player)
  let player_position = transform.position(player_transform)

  let camera_position =
    Vec3(
      x: player_position.x,
      y: player_position.y +. 5.0,
      z: player_position.z +. 10.0,
    )

  #(Model(camera_position:), effect.tick(Tick), Some(updated_physics_world))
}

fn view(model: Model, ctx: Context(Id)) -> List(scene.Node(Id)) {
  let assert option.Some(physics_world) = ctx.physics_world

  let player_transform =
    physics.get_transform(physics_world, Player)
    |> result.unwrap(transform.at(Vec3(x: 0.0, y: 10.0, z: 0.0)))

  [
    setup_ground(),
    setup_player(),
    setup_camera(player_transform, model.camera_position),
    ..setup_lights()
  ]
}

fn setup_camera(
  player_transform: Transform,
  position: Vec3(Float),
) -> scene.Node(Id) {
  let assert Ok(camera) =
    camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  scene.Camera(
    id: Camera,
    camera:,
    transform: transform.at(position:),
    look_at: Some(transform.position(player_transform)),
    active: True,
    viewport: None,
  )
}

fn setup_ground() {
  scene.Mesh(
    id: Ground,
    geometry: {
      let assert Ok(box) = geometry.box(40.0, 0.2, 40.0)
      box
    },
    material: {
      let assert Ok(material) =
        material.new()
        |> material.with_color(0x808080)
        |> material.with_metalness(0.3)
        |> material.with_roughness(0.7)
        |> material.build()

      material
    },
    transform: transform.at(Vec3(x: 0.0, y: 0.0, z: 0.0)),
    physics: Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.identity,
        width: 40.0,
        height: 0.2,
        depth: 40.0,
      ))
      |> physics.with_restitution(0.0)
      |> physics.build(),
    ),
  )
}

fn setup_player() {
  scene.Mesh(
    id: Player,
    geometry: {
      let assert Ok(cylinder) =
        geometry.cylinder(
          radius_top: 1.0,
          radius_bottom: 1.0,
          height: 2.0,
          radial_segments: 32,
        )
      cylinder
    },
    material: {
      let assert Ok(material) =
        material.new()
        |> material.with_color(0xff4444)
        |> material.with_metalness(0.2)
        |> material.with_roughness(0.8)
        |> material.build()

      material
    },
    transform: transform.at(Vec3(x: 0.0, y: 10.0, z: 0.0)),
    physics: option.Some(
      physics.new_rigid_body(physics.Dynamic)
      |> physics.with_collider(physics.Cylinder(
        offset: transform.identity,
        half_height: 1.0,
        radius: 1.0,
      ))
      |> physics.with_mass(1.0)
      |> physics.with_restitution(0.5)
      |> physics.with_friction(0.5)
      |> physics.build(),
    ),
  )
}

fn setup_lights() -> List(scene.Node(Id)) {
  let ambient_light =
    scene.Light(
      id: AmbientLight,
      light: {
        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
        light
      },
      transform: transform.identity,
    )

  let directional_light =
    scene.Light(
      id: DirectionalLight,
      light: {
        let assert Ok(light) =
          light.directional(color: 0xffffff, intensity: 2.0)
        light
      },
      transform: transform.at(Vec3(x: 5.0, y: 10.0, z: 7.5)),
    )

  [ambient_light, directional_light]
}
