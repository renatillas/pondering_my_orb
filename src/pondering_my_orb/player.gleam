import gleam/option
import gleam_community/maths
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3
import vec/vec3f

const mouse_sensitivity = 0.003

const jumping_speed = 15.0

pub type PlayerAction {
  Forward
  Backward
  Left
  Right
  Jump
}

pub type Player {
  Player(
    max_health: Int,
    current_health: Int,
    speed: Float,
    position: vec3.Vec3(Float),
    rotation: vec3.Vec3(Float),
  )
}

pub fn new(
  health health: Int,
  speed speed: Float,
  position position: vec3.Vec3(Float),
  rotation rotation: vec3.Vec3(Float),
) {
  Player(
    max_health: health,
    current_health: health,
    speed:,
    position:,
    rotation:,
  )
}

pub fn render(id: id, player: Player) {
  let assert Ok(capsule) =
    geometry.cylinder(
      radius_top: 0.5,
      radius_bottom: 0.5,
      height: 2.5,
      radial_segments: 10,
    )
  let assert Ok(material) =
    material.new() |> material.with_color(0x00ff00) |> material.build()
  scene.Mesh(
    id:,
    geometry: capsule,
    material:,
    transform: transform.at(player.position)
      |> transform.with_rotation(player.rotation),
    physics: option.Some(
      physics.new_rigid_body(physics.Dynamic)
      |> physics.with_collider(physics.Capsule(
        offset: transform.identity,
        half_height: 1.0,
        radius: 0.5,
      ))
      |> physics.with_restitution(0.0)
      |> physics.with_lock_rotation_x()
      |> physics.with_lock_rotation_z()
      |> physics.build(),
    ),
  )
}

pub fn init() -> Player {
  new(
    health: 100,
    speed: 5.0,
    position: vec3.Vec3(0.0, 2.0, 0.0),
    rotation: vec3.Vec3(0.0, 0.0, 0.0),
  )
}

pub fn update(
  player: Player,
  position: vec3.Vec3(Float),
  rotation: vec3.Vec3(Float),
) -> Player {
  Player(..player, position: position, rotation: rotation)
}

pub fn with_position(player: Player, position: vec3.Vec3(Float)) -> Player {
  Player(..player, position: position)
}

pub fn default_bindings() -> input.InputBindings(PlayerAction) {
  input.new_bindings()
  |> input.bind_key(input.KeyW, Forward)
  |> input.bind_key(input.KeyS, Backward)
  |> input.bind_key(input.KeyA, Left)
  |> input.bind_key(input.KeyD, Right)
  |> input.bind_key(input.Space, Jump)
}

fn direction_from_yaw(yaw: Float) -> #(#(Float, Float), #(Float, Float)) {
  let forward_x = maths.sin(yaw)
  let forward_z = maths.cos(yaw)
  let right_x = maths.cos(yaw)
  let right_z = -1.0 *. maths.sin(yaw)

  #(#(forward_x, forward_z), #(right_x, right_z))
}

fn calculate_velocity(
  input_state: input.InputState,
  bindings: input.InputBindings(PlayerAction),
  player_move_speed: Float,
  player_velocity: vec3.Vec3(Float),
  directions: #(#(Float, Float), #(Float, Float)),
) -> vec3.Vec3(Float) {
  let #(forward_x, forward_z) = directions.0
  let #(right_x, right_z) = directions.1

  let velocity_x = case
    input.is_action_pressed(input_state, bindings, Forward),
    input.is_action_pressed(input_state, bindings, Backward)
  {
    True, False -> forward_x *. player_move_speed
    False, True -> -1.0 *. forward_x *. player_move_speed
    _, _ -> 0.0
  }

  let velocity_z = case
    input.is_action_pressed(input_state, bindings, Forward),
    input.is_action_pressed(input_state, bindings, Backward)
  {
    True, False -> forward_z *. player_move_speed
    False, True -> -1.0 *. forward_z *. player_move_speed
    _, _ -> 0.0
  }

  let velocity_x = case
    input.is_action_pressed(input_state, bindings, Left),
    input.is_action_pressed(input_state, bindings, Right)
  {
    True, False -> velocity_x +. right_x *. player_move_speed
    False, True -> velocity_x -. right_x *. player_move_speed
    _, _ -> velocity_x
  }

  let velocity_z = case
    input.is_action_pressed(input_state, bindings, Left),
    input.is_action_pressed(input_state, bindings, Right)
  {
    True, False -> velocity_z +. right_z *. player_move_speed
    False, True -> velocity_z -. right_z *. player_move_speed
    _, _ -> velocity_z
  }

  vec3.Vec3(velocity_x, player_velocity.y, velocity_z)
}

pub fn handle_input(
  player: Player,
  velocity player_velocity: vec3.Vec3(Float),
  input_state input_state: input.InputState,
  bindings bindings: input.InputBindings(PlayerAction),
  pointer_locked pointer_locked: Bool,
  physics_world physics_world: physics.PhysicsWorld(id),
) -> #(Player, vec3.Vec3(Float), vec3.Vec3(Float)) {
  let vec3.Vec3(player_pitch, player_yaw, player_roll) = player.rotation
  let #(mouse_dx, _mouse_dy) = input.mouse_delta(input_state)

  let player_yaw = case pointer_locked {
    True -> player_yaw -. mouse_dx *. mouse_sensitivity
    False -> player_yaw
  }

  let direction = direction_from_yaw(player_yaw)

  let velocity =
    calculate_velocity(
      input_state,
      bindings,
      player.speed,
      player_velocity,
      direction,
    )

  let impulse = calculate_jump(player, physics_world, input_state, bindings)

  let updated_player =
    Player(..player, rotation: vec3.Vec3(player_pitch, player_yaw, player_roll))

  #(updated_player, velocity, impulse)
}

fn calculate_jump(
  player: Player,
  physics_world: physics.PhysicsWorld(id),
  input_state: input.InputState,
  bindings: input.InputBindings(PlayerAction),
) -> vec3.Vec3(Float) {
  let raycast_origin =
    vec3.Vec3(player.position.x, player.position.y -. 1.6, player.position.z)

  // Cast ray purely horizontally forward
  let raycast_direction = vec3.Vec3(0.0, -0.5, 0.0)

  case
    physics.raycast(
      physics_world,
      origin: raycast_origin,
      direction: raycast_direction,
      max_distance: 1.0,
    ),
    input.is_action_just_pressed(input_state, bindings, Jump)
  {
    Ok(_), True -> vec3.Vec3(0.0, jumping_speed, 0.0)
    _, _ -> vec3f.zero
  }
}
