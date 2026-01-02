import gleam/float
import gleam/option.{type Option}
import gleam/time/duration
import tiramisu
import tiramisu/camera
import tiramisu/effect
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec2.{type Vec2, Vec2}
import vec/vec2f
import vec/vec3.{Vec3}

import pondering_my_orb/magic_system/spell
import pondering_my_orb/player/magic

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(position: vec3.Vec3(Float), zoom: Float, magic: magic.Model)
}

pub type Msg {
  Tick
  MagicMsg(magic.Msg)
}

// =============================================================================
// CONSTANTS
// =============================================================================

const move_speed = 30.0

const zoom_speed = 50.0

const min_zoom = 5.0

const max_zoom = 100.0

const initial_zoom = 30.0

const camera_distance = 50.0

// Isometric direction vectors (screen -> world)
const isometric_up = Vec2(-0.7071, -0.7071)

const isometric_right = Vec2(0.7071, -0.7071)

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  let #(magic_model, magic_effect) = magic.init()

  #(
    Model(
      position: vec3.Vec3(x: 0.0, y: 1.0, z: 0.0),
      zoom: initial_zoom,
      magic: magic_model,
    ),
    effect.batch([
      effect.tick(Tick),
      effect.map(magic_effect, MagicMsg),
    ]),
  )
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg)) {
  case msg {
    Tick -> {
      let new_model = tick(model, ctx)
      // Send player state to magic module
      let update_magic_effect =
        effect.dispatch(
          MagicMsg(magic.UpdatePlayerState(new_model.position, new_model.zoom)),
        )
      #(new_model, effect.batch([effect.tick(Tick), update_magic_effect]))
    }
    MagicMsg(magic_msg) -> {
      let #(new_magic, magic_effect) = magic.update(model.magic, magic_msg, ctx)
      let new_model = Model(..model, magic: new_magic)
      #(new_model, effect.map(magic_effect, MagicMsg))
    }
  }
}

/// Internal tick function - handles movement only
fn tick(model: Model, ctx: tiramisu.Context) -> Model {
  update_movement(model, ctx)
}

fn update_movement(model: Model, ctx: tiramisu.Context) -> Model {
  let dt = duration.to_seconds(ctx.delta_time)

  // Get screen-space input direction
  let screen_input = get_screen_input(ctx)

  // Convert to world space and normalize if non-zero
  let world_movement = screen_to_world_movement(screen_input)

  // Mouse wheel for zoom
  let wheel_delta = input.mouse_wheel_delta(ctx.input)
  let zoom_change = wheel_delta *. zoom_speed *. dt

  // Update player position
  let new_x = model.position.x +. world_movement.x *. move_speed *. dt
  let new_z = model.position.z +. world_movement.y *. move_speed *. dt
  let new_zoom =
    float.clamp(model.zoom +. zoom_change, min: min_zoom, max: max_zoom)

  Model(
    ..model,
    position: vec3.Vec3(x: new_x, y: model.position.y, z: new_z),
    zoom: new_zoom,
  )
}

fn get_screen_input(ctx: tiramisu.Context) -> Vec2(Float) {
  let up =
    input.is_key_pressed(ctx.input, input.KeyW)
    || input.is_key_pressed(ctx.input, input.ArrowUp)
  let down =
    input.is_key_pressed(ctx.input, input.KeyS)
    || input.is_key_pressed(ctx.input, input.ArrowDown)
  let left =
    input.is_key_pressed(ctx.input, input.KeyA)
    || input.is_key_pressed(ctx.input, input.ArrowLeft)
  let right =
    input.is_key_pressed(ctx.input, input.KeyD)
    || input.is_key_pressed(ctx.input, input.ArrowRight)

  // Calculate net screen direction (opposing keys cancel)
  let screen_y = case up, down {
    True, False -> 1.0
    False, True -> -1.0
    _, _ -> 0.0
  }

  let screen_x = case left, right {
    True, False -> -1.0
    False, True -> 1.0
    _, _ -> 0.0
  }

  Vec2(screen_x, screen_y)
}

fn screen_to_world_movement(screen_input: Vec2(Float)) -> Vec2(Float) {
  // Combine isometric directions based on screen input
  let from_vertical = vec2f.scale(isometric_up, by: screen_input.y)
  let from_horizontal = vec2f.scale(isometric_right, by: screen_input.x)
  let combined = vec2f.add(from_vertical, from_horizontal)

  // Normalize if moving to maintain consistent speed
  case vec2f.length(combined) >. 0.0 {
    True -> vec2f.normalize(combined)
    False -> vec2f.zero
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> List(scene.Node) {
  let assert Ok(player_geo) = geometry.box(Vec3(1.0, 2.0, 1.0))
  let assert Ok(player_mat) =
    material.new()
    |> material.with_color(0x4ecdc4)
    |> material.build()

  let camera_node = create_camera(model, ctx)

  let player_node =
    scene.mesh(
      id: "player",
      geometry: player_geo,
      material: player_mat,
      transform: transform.at(position: model.position),
      physics: option.None,
    )
    |> scene.with_children([camera_node])

  // Projectiles from magic module
  let projectile_nodes = magic.view(model.magic)

  [player_node, ..projectile_nodes]
}

// =============================================================================
// CAMERA
// =============================================================================

fn create_camera(model: Model, ctx: tiramisu.Context) -> scene.Node {
  let ortho_size = model.zoom
  let aspect = ctx.canvas_size.x /. ctx.canvas_size.y

  let cam =
    camera.orthographic(
      left: 0.0 -. ortho_size *. aspect,
      right: ortho_size *. aspect,
      top: ortho_size,
      bottom: 0.0 -. ortho_size,
      near: 0.1,
      far: 1000.0,
    )

  let camera_pos =
    transform.at(position: Vec3(
      camera_distance,
      camera_distance,
      camera_distance,
    ))
  let target_pos = transform.at(position: Vec3(0.0, 0.0, 0.0))
  let camera_transform =
    transform.look_at(
      from: camera_pos,
      to: target_pos,
      up: option.Some(Vec3(0.0, 1.0, 0.0)),
    )

  scene.camera(
    id: "main-camera",
    camera: cam,
    transform: camera_transform,
    active: True,
    viewport: option.None,
    postprocessing: option.None,
  )
}

// =============================================================================
// STATE HELPERS
// =============================================================================

/// Get wand state for UI synchronization
pub fn get_wand_ui_state(
  model: Model,
) -> #(List(Option(spell.Spell)), Option(Int), Float, Float, List(spell.Spell)) {
  magic.get_wand_ui_state(model.magic)
}
