/// Player module - handles local player movement, input, camera, and rendering
import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
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
import vec/vec2.{type Vec2}
import vec/vec3.{type Vec3, Vec3}

import shared/game_message
import shared/player
import shared/vec3 as shared_vec3

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    player: player.Player,
    // Client-side interpolated position for smooth rendering
    render_position: Vec3(Float),
    zoom: Float,
    server_tick: Int,
    // Other players from server
    other_players: dict.Dict(player.Id, player.Player),
    // Last sent input state (for change detection)
    last_input: #(Bool, Bool, Bool, Bool),
    // Shared rendering resources (created once in init)
    player_geometry: geometry.Geometry,
    player_material: material.Material,
  )
}

pub type Msg {
  Tick
  UpdateFromServer(player.Player)
  UpdateOtherPlayers(dict.Dict(player.Id, player.Player))
  ServerMessageReceived(game_message.ServerMessage)
}

// =============================================================================
// CONSTANTS
// =============================================================================

const zoom_speed = 50.0

const min_zoom = 5.0

const max_zoom = 100.0

const initial_zoom = 30.0

const camera_distance = 50.0

// Interpolation factor for smooth movement (0.0 = no smoothing, 1.0 = instant)
// Higher values = more responsive but less smooth
// Lower values = smoother but more laggy feeling
const position_lerp_factor = 0.2

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  // Create shared rendering resources once
  let assert Ok(player_geo) = geometry.box(Vec3(0.8, 1.8, 0.8))
  let assert Ok(player_mat) =
    material.new()
    |> material.with_color(0x00FF00)
    |> material.with_emissive(0x00FF00)
    |> material.with_emissive_intensity(0.5)
    |> material.build()

  let initial_position = Vec3(0.0, 0.9, 0.0)
  let model =
    Model(
      player: player.new(player.Id(0), "LocalPlayer", initial_position),
      render_position: initial_position,
      zoom: initial_zoom,
      server_tick: 0,
      other_players: dict.new(),
      last_input: #(False, False, False, False),
      player_geometry: player_geo,
      player_material: player_mat,
    )

  #(model, effect.dispatch(Tick))
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  effect_mapper: fn(Msg) -> game_msg,
  send_to_server: fn(game_message.ClientMessage) -> game_msg,
) -> #(Model, effect.Effect(game_msg), option.Option(physics.PhysicsWorld)) {
  case msg {
    Tick -> {
      let #(new_model, tick_effects) = tick(model, ctx, send_to_server)
      #(
        new_model,
        effect.batch([effect.dispatch(effect_mapper(Tick)), tick_effects]),
        option.None,
      )
    }

    UpdateFromServer(player_data) -> {
      // Update position from server (server-authoritative)
      let new_model = Model(..model, player: player_data)
      #(new_model, effect.none(), option.None)
    }

    UpdateOtherPlayers(other_players) -> {
      // Update other players from server
      let new_model = Model(..model, other_players: other_players)
      #(new_model, effect.none(), option.None)
    }

    ServerMessageReceived(server_msg) -> {
      let new_model = handle_server_message(model, server_msg)
      #(new_model, effect.none(), option.None)
    }
  }
}

/// Internal tick function - handles input and sends to server
fn tick(
  model: Model,
  ctx: tiramisu.Context,
  send_to_server: fn(game_message.ClientMessage) -> game_msg,
) -> #(Model, effect.Effect(game_msg)) {
  let dt = duration.to_seconds(ctx.delta_time)

  // Handle WASD movement input
  let w = input.is_key_pressed(ctx.input, input.KeyW)
  let a = input.is_key_pressed(ctx.input, input.KeyA)
  let s = input.is_key_pressed(ctx.input, input.KeyS)
  let d = input.is_key_pressed(ctx.input, input.KeyD)

  // Only send input when it CHANGES (bandwidth optimization)
  let current_input = #(w, a, s, d)
  let #(move_effect, new_last_input) = case current_input == model.last_input {
    True -> {
      // Input hasn't changed - don't send
      #(effect.none(), model.last_input)
    }
    False -> {
      // Input changed - send to server and update last_input
      #(
        effect.dispatch(
          send_to_server(game_message.PlayerInput(
            tick: model.server_tick,
            action: game_message.Move(w, a, s, d),
          )),
        ),
        current_input,
      )
    }
  }

  // Handle spell casting (right-click)
  let cast_effect = case input.is_right_button_pressed(ctx.input) {
    True -> {
      // Raycast to get target position for spell
      let mouse_pos = input.mouse_position(ctx.input)
      let target =
        raycast_to_ground(
          mouse_pos,
          model.zoom,
          model.player.position,
          ctx.canvas_size,
        )

      // Send CastSpell to server via tagger
      effect.dispatch(
        send_to_server(game_message.PlayerInput(
          tick: model.server_tick,
          action: game_message.CastSpell(target),
        )),
      )
    }
    False -> effect.none()
  }

  // Handle zoom
  let zoom_delta = input.mouse_wheel_delta(ctx.input) *. zoom_speed *. dt
  let new_zoom = float.clamp(model.zoom -. zoom_delta, min_zoom, max_zoom)

  // Interpolate render position toward server's authoritative position
  let new_render_position =
    shared_vec3.lerp(
      model.render_position,
      model.player.position,
      position_lerp_factor,
    )

  let new_model =
    Model(
      ..model,
      zoom: new_zoom,
      render_position: new_render_position,
      last_input: new_last_input,
    )

  #(new_model, effect.batch([move_effect, cast_effect]))
}

/// Raycast from screen coordinates to ground plane (y=0.9)
fn raycast_to_ground(
  mouse_pos: Vec2(Float),
  zoom: Float,
  player_pos: Vec3(Float),
  canvas_size: Vec2(Float),
) -> Vec3(Float) {
  // Convert mouse screen coordinates to normalized device coordinates (NDC)
  let ndc_x = { mouse_pos.x /. canvas_size.x *. 2.0 } -. 1.0
  let ndc_y = 1.0 -. { mouse_pos.y /. canvas_size.y *. 2.0 }

  // For orthographic camera, NDC maps to view space with zoom scale
  let view_x = ndc_x *. zoom
  let view_y = ndc_y *. zoom

  let cos_45 = 0.7071067811865476

  // Camera right vector in world XZ plane: moving screen right goes +X and -Z
  let right_x = cos_45
  let right_z = 0.0 -. cos_45

  // Camera up projected to ground plane: moving screen up goes -X and -Z
  let up_x = 0.0 -. cos_45
  let up_z = 0.0 -. cos_45

  Vec3(
    player_pos.x +. { view_x *. right_x } +. { view_y *. up_x },
    0.9,
    player_pos.z +. { view_x *. right_z } +. { view_y *. up_z },
  )
}

/// Handle server messages (dispatched from network module via tagger)
fn handle_server_message(model: Model, msg: game_message.ServerMessage) -> Model {
  case msg {
    game_message.RoomJoined(player_id, existing_players) -> {
      let player.Id(pid) = player_id
      io.println("🎮 Joined room with player ID: " <> int.to_string(pid))

      // Update our player ID
      let updated_player = player.Player(..model.player, id: player_id)

      // Add existing players
      let other_players =
        dict.from_list(
          existing_players
          |> list.map(fn(p) { #(p.id, p) }),
        )

      Model(..model, player: updated_player, other_players: other_players)
    }

    game_message.PlayerJoined(new_player) -> {
      let player.Id(pid) = new_player.id
      io.println("👋 Player joined: " <> int.to_string(pid))

      // Add new player to other_players
      let new_other_players =
        dict.insert(model.other_players, new_player.id, new_player)
      Model(..model, other_players: new_other_players)
    }

    game_message.PlayerLeft(player_id) -> {
      let player.Id(pid) = player_id
      io.println("👋 Player left: " <> int.to_string(pid))

      // Remove player from other_players
      let new_other_players = dict.delete(model.other_players, player_id)
      Model(..model, other_players: new_other_players)
    }

    game_message.GameStateUpdate(tick, players, _projectiles, _enemies) -> {
      // Update other players from server
      let other_players =
        dict.from_list(
          players
          |> list.filter(fn(p) { p.id != model.player.id })
          |> list.map(fn(p) { #(p.id, p) }),
        )

      // Update our player from server (server-authoritative)
      let updated_player = case
        list.find(players, fn(p) { p.id == model.player.id })
      {
        Ok(server_player) -> server_player
        Error(_) -> model.player
      }

      Model(
        ..model,
        server_tick: tick,
        other_players: other_players,
        player: updated_player,
      )
    }

    _ -> model
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, _ctx: tiramisu.Context) -> List(scene.Node) {
  // True isometric camera angle
  let horizontal_offset = camera_distance /. 1.4142

  // Use interpolated render position for smooth camera following
  let camera_pos =
    Vec3(
      model.render_position.x +. horizontal_offset,
      model.render_position.y +. camera_distance,
      model.render_position.z +. horizontal_offset,
    )

  let camera_transform = transform.at(position: camera_pos)
  let target_transform = transform.at(position: model.render_position)
  let camera_node =
    scene.camera(
      id: "main_camera",
      camera: camera.orthographic(
        left: 0.0 -. model.zoom,
        right: model.zoom,
        top: model.zoom,
        bottom: 0.0 -. model.zoom,
        near: 0.1,
        far: 200.0,
      ),
      transform: transform.look_at(
        from: camera_transform,
        to: target_transform,
        up: option.Some(Vec3(0.0, 1.0, 0.0)),
      ),
      active: True,
      viewport: option.None,
      postprocessing: option.None,
    )

  // Use interpolated render position for smooth player mesh rendering
  let player_node =
    scene.mesh(
      id: "player",
      geometry: model.player_geometry,
      material: model.player_material,
      transform: transform.at(position: model.render_position),
      physics: option.None,
    )

  // Render other players
  let other_player_nodes =
    dict.to_list(model.other_players)
    |> list.map(fn(entry) {
      let #(player_id, other_player) = entry
      let player.Id(pid) = player_id
      scene.mesh(
        id: "player_" <> int.to_string(pid),
        geometry: model.player_geometry,
        material: model.player_material,
        transform: transform.at(position: other_player.position),
        physics: option.None,
      )
    })

  [camera_node, player_node]
  |> list.append(other_player_nodes)
}
