/// Player module - handles local player movement, input, and rendering
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
import vec/vec2.{type Vec2, Vec2}
import vec/vec3.{type Vec3, Vec3}

import shared/enemy
import shared/game_message
import shared/player
import shared/projectile
import shared/vec3 as shared_vec3

// =============================================================================
// TYPES
// =============================================================================

/// Client-side wrapper for projectiles with interpolated render position
pub type ClientProjectile {
  ClientProjectile(
    projectile: projectile.Projectile,
    render_position: Vec3(Float),
  )
}

pub type Model {
  Model(
    player: player.Player,
    // Client-side interpolated position for smooth rendering
    render_position: Vec3(Float),
    zoom: Float,
    server_tick: Int,
    // Other players from server
    other_players: dict.Dict(player.Id, player.Player),
    // Projectiles from server with client-side interpolation
    projectiles: dict.Dict(projectile.Id, ClientProjectile),
    // Enemies from server
    enemies: dict.Dict(enemy.Id, enemy.Enemy),
    // Shared rendering resources (created once in init)
    player_geometry: geometry.Geometry,
    player_material: material.Material,
    projectile_geometry: geometry.Geometry,
    projectile_material: material.Material,
    enemy_geometry: geometry.Geometry,
    enemy_material: material.Material,
  )
}

pub type Msg {
  Tick
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

// Projectiles move faster, so they need more aggressive interpolation
const projectile_lerp_factor = 0.35

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

  // Projectile rendering resources
  let assert Ok(projectile_geo) = geometry.sphere(0.3, Vec2(8, 6))
  let assert Ok(projectile_mat) =
    material.new()
    |> material.with_color(0xFF4400)
    |> material.with_emissive(0xFF4400)
    |> material.with_emissive_intensity(1.0)
    |> material.build()

  // Enemy rendering resources
  let assert Ok(enemy_geo) = geometry.box(Vec3(0.8, 1.8, 0.8))
  let assert Ok(enemy_mat) =
    material.new()
    |> material.with_color(0xFF0000)
    |> material.with_emissive(0xFF0000)
    |> material.with_emissive_intensity(0.8)
    |> material.build()

  let initial_position = Vec3(0.0, 0.9, 0.0)
  let model =
    Model(
      player: player.new(player.Id(0), "LocalPlayer", initial_position),
      render_position: initial_position,
      zoom: initial_zoom,
      server_tick: 0,
      other_players: dict.new(),
      projectiles: dict.new(),
      enemies: dict.new(),
      player_geometry: player_geo,
      player_material: player_mat,
      projectile_geometry: projectile_geo,
      projectile_material: projectile_mat,
      enemy_geometry: enemy_geo,
      enemy_material: enemy_mat,
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

  // Handle click-to-move (left-click held)
  let move_effect = case input.is_left_button_pressed(ctx.input) {
    True -> {
      // Raycast from mouse to ground plane to get world position
      let mouse_pos = input.mouse_position(ctx.input)
      let target =
        raycast_to_ground(
          mouse_pos,
          model.zoom,
          model.player.position,
          ctx.canvas_size,
        )

      // Send MoveToPosition to server via tagger
      effect.dispatch(
        send_to_server(game_message.PlayerInput(
          tick: model.server_tick,
          action: game_message.MoveToPosition(target),
        )),
      )
    }
    False -> effect.none()
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

  // Interpolate all projectile render positions
  let new_projectiles =
    dict.map_values(model.projectiles, fn(_id, client_proj) {
      let new_proj_render_pos =
        shared_vec3.lerp(
          client_proj.render_position,
          client_proj.projectile.position,
          projectile_lerp_factor,
        )
      ClientProjectile(
        projectile: client_proj.projectile,
        render_position: new_proj_render_pos,
      )
    })

  let new_model =
    Model(
      ..model,
      zoom: new_zoom,
      render_position: new_render_position,
      projectiles: new_projectiles,
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

    game_message.GameStateUpdate(tick, players, projectiles, enemies) -> {
      // Update other players from server
      let other_players =
        dict.from_list(
          players
          |> list.filter(fn(p) { p.id != model.player.id })
          |> list.map(fn(p) { #(p.id, p) }),
        )

      // Update projectiles from server
      // For each server projectile, create or update ClientProjectile with interpolation
      let projectiles_dict =
        projectiles
        |> list.fold(dict.new(), fn(acc, server_proj) {
          case dict.get(model.projectiles, server_proj.id) {
            // Existing projectile - keep render position for interpolation
            Ok(existing) ->
              dict.insert(
                acc,
                server_proj.id,
                ClientProjectile(
                  projectile: server_proj,
                  render_position: existing.render_position,
                ),
              )
            // New projectile - start at server position
            Error(_) ->
              dict.insert(
                acc,
                server_proj.id,
                ClientProjectile(
                  projectile: server_proj,
                  render_position: server_proj.position,
                ),
              )
          }
        })

      // Update enemies from server
      let enemies_dict =
        dict.from_list(
          enemies
          |> list.map(fn(e) { #(e.id, e) }),
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
        projectiles: projectiles_dict,
        enemies: enemies_dict,
        player: updated_player,
      )
    }

    _ -> model
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, _ctx: tiramisu.Context) -> scene.Node {
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

  // Render projectiles with interpolated positions
  let projectile_nodes =
    dict.to_list(model.projectiles)
    |> list.map(fn(entry) {
      let #(proj_id, client_proj) = entry
      let projectile.Id(pid) = proj_id
      scene.mesh(
        id: "projectile_" <> int.to_string(pid),
        geometry: model.projectile_geometry,
        material: model.projectile_material,
        transform: transform.at(position: client_proj.render_position),
        physics: option.None,
      )
    })

  // Render enemies
  let enemy_nodes =
    dict.to_list(model.enemies)
    |> list.map(fn(entry) {
      let #(enemy_id, enemy_data) = entry
      let enemy.Id(eid) = enemy_id
      scene.mesh(
        id: "enemy_" <> int.to_string(eid),
        geometry: model.enemy_geometry,
        material: model.enemy_material,
        transform: transform.at(position: enemy_data.position),
        physics: option.None,
      )
    })

  let all_children =
    [camera_node, player_node]
    |> list.append(other_player_nodes)
    |> list.append(projectile_nodes)
    |> list.append(enemy_nodes)

  scene.empty(
    id: "player_root",
    transform: transform.identity,
    children: all_children,
  )
}
