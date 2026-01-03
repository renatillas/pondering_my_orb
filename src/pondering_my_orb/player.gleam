import gleam/float
import gleam/list
import gleam/option.{type Option}
import gleam/time/duration
import tiramisu
import tiramisu/camera
import tiramisu/effect
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui
import vec/vec2.{type Vec2, Vec2}
import vec/vec2f
import vec/vec3.{Vec3}

import pondering_my_orb/game_physics/layer
import pondering_my_orb/health
import pondering_my_orb/id
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/spell_bag
import pondering_my_orb/magic_system/wand
import pondering_my_orb/player/magic

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    position: vec3.Vec3(Float),
    zoom: Float,
    magic: magic.Model,
    health: health.Health,
  )
}

pub type Msg {
  Tick
  MagicMsg(magic.Msg)
  TakeDamage(Float)
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

const initial_health = 100.0

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
      health: health.new(initial_health),
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

/// Update player. Accepts taggers for cross-module dispatch.
pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  bridge bridge: ui.Bridge(ui_msg, game_msg),
  toggle_edit_mode toggle_edit_mode,
  player_state_updated player_state_updated,
  altar_nearby altar_nearby,
  effect_mapper effect_mapper,
) -> #(Model, effect.Effect(game_msg)) {
  case msg {
    Tick -> {
      let new_model = tick(model, ctx)

      // Send player state to magic module
      let update_magic_effect =
        effect.dispatch(
          effect_mapper(MagicMsg(magic.UpdatePlayerState(new_model.position, new_model.zoom))),
        )

      // Check for wand switching input
      let wand_switch_effect = get_wand_switch_effect(ctx, effect_mapper)

      // Check for edit mode toggle (I key)
      let edit_mode_effect = case input.is_key_just_pressed(ctx.input, input.KeyI) {
        True -> ui.to_lustre(bridge, toggle_edit_mode)
        False -> effect.none()
      }

      // Sync player state to UI
      let ui_sync_effect = build_ui_sync_effect(new_model, bridge, player_state_updated, altar_nearby)

      #(
        new_model,
        effect.batch([
          effect.tick(effect_mapper(Tick)),
          update_magic_effect,
          wand_switch_effect,
          edit_mode_effect,
          ui_sync_effect,
        ]),
      )
    }
    MagicMsg(magic_msg) -> {
      let #(new_magic, magic_effect) = magic.update(model.magic, magic_msg, ctx)
      let new_model = Model(..model, magic: new_magic)
      #(new_model, effect.map(magic_effect, fn(m) { effect_mapper(MagicMsg(m)) }))
    }
    TakeDamage(amount) -> {
      let new_health = health.damage(model.health, amount)
      #(Model(..model, health: new_health), effect.none())
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

  // Mouse wheel for zoom (only when Shift is NOT held - Shift+scroll is for wand switching)
  let shift_held = input.is_key_pressed(ctx.input, input.ShiftLeft)
    || input.is_key_pressed(ctx.input, input.ShiftRight)
  let wheel_delta = input.mouse_wheel_delta(ctx.input)
  let zoom_change = case shift_held {
    True -> 0.0  // Scroll used for wand switching when shift held
    False -> wheel_delta *. zoom_speed *. dt
  }
  let new_zoom =
    float.clamp(model.zoom +. zoom_change, min: min_zoom, max: max_zoom)

  // Calculate desired movement
  let desired_x = world_movement.x *. move_speed *. dt
  let desired_z = world_movement.y *. move_speed *. dt
  let desired_translation = Vec3(desired_x, 0.0, desired_z)

  // Use character controller for collision-aware movement
  let new_position = case ctx.physics_world {
    option.Some(physics_world) -> {
      let player_id = id.to_string(id.Player)
      case
        physics.compute_character_movement(
          physics_world,
          player_id,
          desired_translation,
        )
      {
        Ok(safe_movement) ->
          Vec3(
            model.position.x +. safe_movement.x,
            model.position.y,
            model.position.z +. safe_movement.z,
          )
        Error(_) ->
          // Fallback if character controller not ready yet
          Vec3(
            model.position.x +. desired_x,
            model.position.y,
            model.position.z +. desired_z,
          )
      }
    }
    option.None ->
      // No physics world, use direct movement
      Vec3(
        model.position.x +. desired_x,
        model.position.y,
        model.position.z +. desired_z,
      )
  }

  Model(..model, position: new_position, zoom: new_zoom)
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
// WAND SWITCHING
// =============================================================================

/// Check for wand switch inputs and return appropriate effect
fn get_wand_switch_effect(ctx: tiramisu.Context, effect_mapper) -> effect.Effect(game_msg) {
  // Number keys 1-4 for direct wand selection
  let key_effect = case
    input.is_key_just_pressed(ctx.input, input.Digit1),
    input.is_key_just_pressed(ctx.input, input.Digit2),
    input.is_key_just_pressed(ctx.input, input.Digit3),
    input.is_key_just_pressed(ctx.input, input.Digit4)
  {
    True, _, _, _ -> effect.dispatch(effect_mapper(MagicMsg(magic.SwitchWand(0))))
    _, True, _, _ -> effect.dispatch(effect_mapper(MagicMsg(magic.SwitchWand(1))))
    _, _, True, _ -> effect.dispatch(effect_mapper(MagicMsg(magic.SwitchWand(2))))
    _, _, _, True -> effect.dispatch(effect_mapper(MagicMsg(magic.SwitchWand(3))))
    _, _, _, _ -> effect.none()
  }

  // Shift + scroll wheel for wand cycling
  let shift_held =
    input.is_key_pressed(ctx.input, input.ShiftLeft)
    || input.is_key_pressed(ctx.input, input.ShiftRight)
  let wheel_delta = input.mouse_wheel_delta(ctx.input)

  let scroll_effect = case shift_held, wheel_delta {
    True, d if d >. 0.0 -> effect.dispatch(effect_mapper(MagicMsg(magic.SwitchWandRelative(-1))))
    True, d if d <. 0.0 -> effect.dispatch(effect_mapper(MagicMsg(magic.SwitchWandRelative(1))))
    _, _ -> effect.none()
  }

  effect.batch([key_effect, scroll_effect])
}

// =============================================================================
// UI SYNC
// =============================================================================

fn build_ui_sync_effect(
  model: Model,
  bridge: ui.Bridge(ui_msg, game_msg),
  player_state_updated,
  altar_nearby,
) -> effect.Effect(game_msg) {
  let #(slots, selected, mana, max_mana, spell_bag) = magic.get_wand_ui_state(model.magic)

  ui.to_lustre(
    bridge,
    player_state_updated(
      slots,
      selected,
      mana,
      max_mana,
      spell_bag,
      model.health,
      get_wand_names(model),
      get_active_wand_index(model),
      altar_nearby,
    ),
  )
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> List(scene.Node) {
  let assert option.Some(physics_world) = ctx.physics_world
  let assert Ok(player_geo) = geometry.box(Vec3(1.0, 2.0, 1.0))
  let assert Ok(player_mat) =
    material.new()
    |> material.with_color(0x4ecdc4)
    |> material.build()

  // Physics body for collision with enemies and walls
  // Layer 0 = Player, collides with layer 1 = Enemies, layer 2 = Walls
  // Character controller enables collision-aware movement
  let physics_body =
    physics.new_rigid_body(physics.Kinematic)
    |> physics.with_collider(physics.Capsule(
      offset: transform.identity,
      half_height: 1.0,
      radius: 0.5,
    ))
    |> physics.with_collision_groups(
      membership: [layer.player],
      can_collide_with: [layer.enemy, layer.map],
    )
    |> physics.with_character_controller(
      offset: 1.0,
      up_vector: Vec3(0.0, 1.0, 0.0),
      slide_enabled: True,
    )
    |> physics.with_collision_events()
    |> physics.with_friction(0.0)
    |> physics.build()

  let camera_node = create_camera(model, ctx)

  let player_node =
    scene.mesh(
      id: id.to_string(id.Player),
      geometry: player_geo,
      material: player_mat,
      transform: transform.at(position: model.position),
      physics: option.Some(physics_body),
    )
    |> scene.with_children([camera_node])

  // Projectiles from magic module
  let projectile_nodes = magic.view(model.magic, physics_world)

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

/// Get wand state for UI synchronization (active wand)
pub fn get_wand_ui_state(
  model: Model,
) -> #(List(Option(spell.Spell)), Option(Int), Float, Float, spell_bag.SpellBag) {
  magic.get_wand_ui_state(model.magic)
}

/// Get wand inventory for UI
pub fn get_wand_inventory(model: Model) -> List(Option(wand.Wand)) {
  magic.get_wand_inventory(model.magic)
}

/// Get wand names for UI display
pub fn get_wand_names(model: Model) -> List(Option(String)) {
  magic.get_wand_inventory(model.magic)
  |> list.map(fn(wand_opt) {
    case wand_opt {
      option.Some(w) -> option.Some(w.name)
      option.None -> option.None
    }
  })
}

/// Get active wand index
pub fn get_active_wand_index(model: Model) -> Int {
  magic.get_active_wand_index(model.magic)
}

/// Get current projectiles for collision detection
pub fn get_projectiles(model: Model) -> List(spell.Projectile) {
  magic.get_projectiles(model.magic)
}
