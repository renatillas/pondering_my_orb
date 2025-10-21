import gleam/option
import gleam_community/maths
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

const mouse_sensitivity = 0.003

pub type PlayerAction {
  Forward
  Backward
  Left
  Right
}

pub type Player {
  Player(
    max_health: Int,
    current_health: Int,
    speed: Float,
    player_position: vec3.Vec3(Float),
    player_rotation: vec3.Vec3(Float),
  )
}

pub fn new(
  health health: Int,
  speed speed: Float,
  player_position player_position: vec3.Vec3(Float),
  player_rotation player_rotation: vec3.Vec3(Float),
) {
  Player(
    max_health: health,
    current_health: health,
    speed:,
    player_position:,
    player_rotation:,
  )
}

pub fn render(id: id, player: Player) {
  let assert Ok(capsule) =
    geometry.cylinder(
      radius_top: 0.5,
      radius_bottom: 0.5,
      height: 2.0,
      radial_segments: 10,
    )
  let assert Ok(material) =
    material.new() |> material.with_color(0x00ff00) |> material.build()
  scene.Mesh(
    id:,
    geometry: capsule,
    material:,
    transform: transform.at(player.player_position)
      |> transform.with_rotation(player.player_rotation),
    physics: option.None,
  )
}

pub fn init() -> Player {
  new(
    health: 100,
    speed: 0.1,
    player_position: vec3.Vec3(0.0, 0.0, 0.0),
    player_rotation: vec3.Vec3(0.0, 0.0, 0.0),
  )
}

pub fn update(
  player: Player,
  position: vec3.Vec3(Float),
  rotation: vec3.Vec3(Float),
) -> Player {
  Player(..player, player_position: position, player_rotation: rotation)
}

pub fn default_bindings() -> input.InputBindings(PlayerAction) {
  input.new_bindings()
  |> input.bind_key(input.KeyW, Forward)
  |> input.bind_key(input.KeyS, Backward)
  |> input.bind_key(input.KeyA, Left)
  |> input.bind_key(input.KeyD, Right)
}

fn direction_from_yaw(yaw: Float) -> #(#(Float, Float), #(Float, Float)) {
  let forward_x = maths.sin(yaw)
  let forward_z = maths.cos(yaw)
  let right_x = maths.cos(yaw)
  let right_z = -1.0 *. maths.sin(yaw)

  #(#(forward_x, forward_z), #(right_x, right_z))
}

fn calculate_movement(
  input_state: input.InputState,
  bindings: input.InputBindings(PlayerAction),
  player_move_speed: Float,
  player_pos: #(Float, Float),
  directions: #(#(Float, Float), #(Float, Float)),
) -> #(Float, Float) {
  let #(player_x, player_z) = player_pos
  let #(forward_x, forward_z) = directions.0
  let #(right_x, right_z) = directions.1

  let player_x = case input.is_action_pressed(input_state, bindings, Forward) {
    True -> player_x +. forward_x *. player_move_speed
    False -> player_x
  }
  let player_z = case input.is_action_pressed(input_state, bindings, Forward) {
    True -> player_z +. forward_z *. player_move_speed
    False -> player_z
  }

  let player_x = case input.is_action_pressed(input_state, bindings, Backward) {
    True -> player_x -. forward_x *. player_move_speed
    False -> player_x
  }
  let player_z = case input.is_action_pressed(input_state, bindings, Backward) {
    True -> player_z -. forward_z *. player_move_speed
    False -> player_z
  }

  let player_x = case input.is_action_pressed(input_state, bindings, Left) {
    True -> player_x +. right_x *. player_move_speed
    False -> player_x
  }
  let player_z = case input.is_action_pressed(input_state, bindings, Left) {
    True -> player_z +. right_z *. player_move_speed
    False -> player_z
  }

  let player_x = case input.is_action_pressed(input_state, bindings, Right) {
    True -> player_x -. right_x *. player_move_speed
    False -> player_x
  }
  let player_z = case input.is_action_pressed(input_state, bindings, Right) {
    True -> player_z -. right_z *. player_move_speed
    False -> player_z
  }

  #(player_x, player_z)
}

pub fn handle_input(
  player: Player,
  input_state: input.InputState,
  bindings: input.InputBindings(PlayerAction),
  pointer_locked: Bool,
) -> Player {
  let vec3.Vec3(player_pitch, player_yaw, player_roll) = player.player_rotation
  let #(mouse_dx, _mouse_dy) = input.mouse_delta(input_state)

  let player_yaw = case pointer_locked {
    True -> player_yaw -. mouse_dx *. mouse_sensitivity
    False -> player_yaw
  }

  let direction = direction_from_yaw(player_yaw)
  let vec3.Vec3(player_x, player_y, player_z) = player.player_position

  let #(player_x, player_z) =
    calculate_movement(
      input_state,
      bindings,
      player.speed,
      #(player_x, player_z),
      direction,
    )

  Player(
    ..player,
    player_position: vec3.Vec3(player_x, player_y, player_z),
    player_rotation: vec3.Vec3(player_pitch, player_yaw, player_roll),
  )
}
