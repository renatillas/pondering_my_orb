import gleam/float
import gleam/option
import gleam/time/duration
import tiramisu
import tiramisu/camera
import tiramisu/input
import tiramisu/scene
import tiramisu/transform
import vec/vec3

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(x: Float, z: Float, zoom: Float)
}

pub type Msg {
  Tick
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

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> Model {
  Model(x: 0.0, z: 0.0, zoom: initial_zoom)
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(model: Model, msg: Msg, ctx: tiramisu.Context) -> Model {
  case msg {
    Tick -> {
      let dt = duration.to_seconds(ctx.delta_time)

      // Screen-relative input for isometric view
      // Calculate net screen direction (opposing keys cancel out)
      let up_pressed =
        input.is_key_pressed(ctx.input, input.KeyW)
        || input.is_key_pressed(ctx.input, input.ArrowUp)
      let down_pressed =
        input.is_key_pressed(ctx.input, input.KeyS)
        || input.is_key_pressed(ctx.input, input.ArrowDown)
      let left_pressed =
        input.is_key_pressed(ctx.input, input.KeyA)
        || input.is_key_pressed(ctx.input, input.ArrowLeft)
      let right_pressed =
        input.is_key_pressed(ctx.input, input.KeyD)
        || input.is_key_pressed(ctx.input, input.ArrowRight)

      // Net vertical: -1 = up, +1 = down, 0 = neither/both
      let screen_y = case up_pressed, down_pressed {
        True, False -> -1.0
        False, True -> 1.0
        _, _ -> 0.0
      }

      // Net horizontal: -1 = left, +1 = right, 0 = neither/both
      let screen_x = case left_pressed, right_pressed {
        True, False -> -1.0
        False, True -> 1.0
        _, _ -> 0.0
      }

      // Convert screen directions to world space for isometric view:
      // Screen up    -> world (-X, -Z) = toward top of diamond
      // Screen down  -> world (+X, +Z) = toward bottom of diamond
      // Screen left  -> world (-X, +Z) = toward left of diamond
      // Screen right -> world (+X, -Z) = toward right of diamond
      let diagonal = 0.7071

      // Transform screen coords to world coords
      // world_x = screen_y * diagonal + screen_x * diagonal
      // world_z = screen_y * diagonal - screen_x * diagonal
      let raw_x = screen_y *. diagonal +. screen_x *. diagonal
      let raw_z = screen_y *. diagonal -. screen_x *. diagonal

      // Normalize if moving diagonally
      let #(move_x, move_z) = case screen_x != 0.0 && screen_y != 0.0 {
        True -> #(raw_x *. diagonal, raw_z *. diagonal)
        False -> #(raw_x, raw_z)
      }

      // Mouse wheel for zoom
      let wheel_delta = input.mouse_wheel_delta(ctx.input)
      let zoom_change = wheel_delta *. zoom_speed *. dt

      // Update camera position
      let new_x = model.x +. move_x *. move_speed *. dt
      let new_z = model.z +. move_z *. move_speed *. dt
      let new_zoom =
        float.clamp(model.zoom +. zoom_change, min: min_zoom, max: max_zoom)

      Model(x: new_x, z: new_z, zoom: new_zoom)
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> scene.Node {
  // Isometric camera with orthographic projection
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

  // Isometric camera position: offset equally on X and Z, plus height
  // This creates the diamond view where grid corners point up/down/left/right
  let camera_pos =
    transform.at(position: vec3.Vec3(
      model.x +. camera_distance,
      camera_distance,
      model.z +. camera_distance,
    ))
  let target_pos = transform.at(position: vec3.Vec3(model.x, 0.0, model.z))
  let camera_transform =
    transform.look_at(
      from: camera_pos,
      to: target_pos,
      up: option.Some(vec3.Vec3(0.0, 1.0, 0.0)),
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
