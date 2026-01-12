/// Network module for multiplayer WebSocket communication.
/// Uses tiramisu's effect system with JavaScript FFI for WebSocket operations.
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import shared/enemy
import shared/game_messages.{
  type ClientMessage, type ServerMessage, decode_server_message,
  encode_client_message,
}
import shared/id
import shared/player
import shared/projectile
import tiramisu
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}

// ----------------------------------------------------------------------------
// Model
// ----------------------------------------------------------------------------

/// Connection state for the multiplayer session.
pub type ConnectionState {
  Disconnected
  Connecting
  Connected(room_id: String, player_id: id.Id)
}

/// Remote player with interpolation data.
pub type RemotePlayer {
  RemotePlayer(
    state: player.Player,
    /// Current render position (interpolated)
    render_position: Vec3(Float),
    /// Target position from server
    target_position: Vec3(Float),
  )
}

/// Network model containing connection state and remote player data.
pub type Model {
  Model(
    connection_state: ConnectionState,
    server_url: String,
    remote_players: List(RemotePlayer),
    latency_ms: Int,
  )
}

// ----------------------------------------------------------------------------
// Messages
// ----------------------------------------------------------------------------

/// Messages for network operations.
pub type Msg {
  /// Tick for interpolating remote player positions
  Tick
  /// Connect to a game server
  Connect(server_url: String, room_id: String, player_name: String)
  /// Disconnect from the server
  Disconnect
  /// WebSocket opened successfully
  SocketOpened
  /// WebSocket closed
  SocketClosed
  /// Received a server message
  ReceivedMessage(String)
  /// Send local player state to the server
  SendPlayerUpdate(position: Vec3(Float), rotation: Float)
  /// Send input update to the server (shoot button + aim direction)
  SendInputUpdate(shoot_pressed: Bool, aim_direction: Vec3(Float))
  /// Send ping to measure latency
  SendPing
  /// Request game tick from server (client-driven simulation)
  RequestGameTick
}

// ----------------------------------------------------------------------------
// Init
// ----------------------------------------------------------------------------

/// Initialize the network module in a disconnected state.
pub fn init() -> #(Model, Effect(Msg)) {
  let model =
    Model(
      connection_state: Disconnected,
      server_url: "",
      remote_players: [],
      latency_ms: 0,
    )
  // Start tick cycle for interpolation
  #(model, effect.dispatch(Tick))
}

// ----------------------------------------------------------------------------
// Update
// ----------------------------------------------------------------------------

/// Taggers for routing enemy state to other modules.
pub type EnemyTaggers(game_msg) {
  EnemyTaggers(
    on_full_game_state: fn(List(enemy.Enemy)) -> game_msg,
    on_enemy_spawned: fn(id.Id, Vec3(Float)) -> game_msg,
    on_enemies_updated: fn(List(enemy.Delta)) -> game_msg,
    on_enemy_died: fn(Int) -> game_msg,
  )
}

/// Taggers for routing projectile state to other modules.
pub type ProjectileTaggers(game_msg) {
  ProjectileTaggers(
    on_set_projectiles: fn(List(projectile.Projectile)) -> game_msg,
    on_add_projectiles: fn(List(projectile.Projectile)) -> game_msg,
    on_remove_projectiles: fn(List(Int)) -> game_msg,
  )
}

/// Update the network module.
pub fn update(
  model: Model,
  msg: Msg,
  effect_mapper: fn(Msg) -> game_msg,
  enemy_taggers: EnemyTaggers(game_msg),
  projectile_taggers: ProjectileTaggers(game_msg),
  _ctx: tiramisu.Context,
) -> #(Model, Effect(game_msg)) {
  case msg {
    Tick -> {
      // Interpolate remote player positions
      let interpolated_players =
        list.map(model.remote_players, interpolate_player_position)
      let new_model = Model(..model, remote_players: interpolated_players)
      #(new_model, effect.dispatch(effect_mapper(Tick)))
    }

    Connect(server_url, room_id, player_name) ->
      handle_connect(model, server_url, room_id, player_name, effect_mapper)

    Disconnect -> handle_disconnect(model, effect_mapper)

    SocketOpened -> {
      // Socket opened - connection state will be updated when we receive RoomJoined
      #(model, effect.none())
    }

    SocketClosed -> {
      let new_model =
        Model(..model, connection_state: Disconnected, remote_players: [])
      #(new_model, effect.none())
    }

    ReceivedMessage(data) ->
      handle_received_message(
        model,
        data,
        effect_mapper,
        enemy_taggers,
        projectile_taggers,
      )

    SendPlayerUpdate(position, rotation) ->
      send_client_message(model, game_messages.PlayerUpdate(position, rotation))

    SendInputUpdate(shoot_pressed, aim_direction) ->
      send_client_message(
        model,
        game_messages.InputUpdate(shoot_pressed, aim_direction),
      )

    SendPing -> send_client_message(model, game_messages.Ping(get_timestamp()))

    RequestGameTick -> send_client_message(model, game_messages.RequestGameTick)
  }
}

/// Handle connect request.
fn handle_connect(
  model: Model,
  server_url: String,
  room_id: String,
  player_name: String,
  effect_mapper: fn(Msg) -> game_msg,
) -> #(Model, Effect(game_msg)) {
  // Build the WebSocket URL
  let ws_url = server_url <> "/ws/" <> room_id

  let new_model =
    Model(
      ..model,
      server_url: server_url,
      connection_state: Connecting,
      remote_players: [],
    )

  // Create effect to connect WebSocket
  let connect_effect =
    effect.from(fn(dispatch) {
      do_connect(ws_url, room_id, player_name, fn(msg) {
        dispatch(effect_mapper(msg))
      })
    })

  #(new_model, connect_effect)
}

/// Handle disconnect request.
fn handle_disconnect(
  model: Model,
  effect_mapper: fn(Msg) -> game_msg,
) -> #(Model, Effect(game_msg)) {
  let new_model =
    Model(..model, connection_state: Disconnected, remote_players: [])

  let disconnect_effect =
    effect.from(fn(dispatch) {
      do_disconnect()
      dispatch(effect_mapper(SocketClosed))
    })

  #(new_model, disconnect_effect)
}

/// Handle received WebSocket message.
fn handle_received_message(
  model: Model,
  data: String,
  _effect_mapper: fn(Msg) -> game_msg,
  enemy_taggers: EnemyTaggers(game_msg),
  projectile_taggers: ProjectileTaggers(game_msg),
) -> #(Model, Effect(game_msg)) {
  case decode_server_message(data) {
    Ok(server_msg) ->
      handle_server_message(
        model,
        server_msg,
        enemy_taggers,
        projectile_taggers,
      )
    Error(_) -> #(model, effect.none())
  }
}

/// Handle server messages.
fn handle_server_message(
  model: Model,
  msg: ServerMessage,
  enemy_taggers: EnemyTaggers(game_msg),
  projectile_taggers: ProjectileTaggers(game_msg),
) -> #(Model, Effect(game_msg)) {
  case msg {
    game_messages.RoomJoined(room_id, player_id, players) -> {
      // Convert PlayerState list to RemotePlayer list
      let remote_players =
        list.map(players, fn(player) {
          RemotePlayer(
            state: player,
            render_position: player.position,
            target_position: player.position,
          )
        })

      let new_model =
        Model(
          ..model,
          connection_state: Connected(
            room_id: {
              let assert id.Room(rid) = room_id
              int.to_string(rid)
            },
            player_id: player_id,
          ),
          remote_players: remote_players,
        )
      #(new_model, effect.none())
    }

    game_messages.PlayerJoined(player) -> {
      let remote_player =
        RemotePlayer(
          state: player,
          render_position: player.position,
          target_position: player.position,
        )
      let new_model =
        Model(..model, remote_players: [remote_player, ..model.remote_players])
      #(new_model, effect.none())
    }

    game_messages.PlayerLeft(player_id) -> {
      let new_players =
        model.remote_players
        |> list.filter(fn(p) { p.state.id != player_id })
      let new_model = Model(..model, remote_players: new_players)
      #(new_model, effect.none())
    }

    game_messages.PlayerStates(states) -> {
      let own_id = get_own_player_id(model)

      let remote_states =
        states
        |> list.filter(fn(p) { Some(p.id) != own_id })

      // Update existing remote players or create new ones
      let updated_players =
        list.map(remote_states, fn(state) {
          // Find existing remote player
          case
            list.find(model.remote_players, fn(p) { p.state.id == state.id })
          {
            Ok(existing) -> {
              // Update target position, keep render position for interpolation
              RemotePlayer(
                ..existing,
                state: state,
                target_position: state.position,
              )
            }
            Error(_) -> {
              // New player - no interpolation needed yet
              RemotePlayer(
                state: state,
                render_position: state.position,
                target_position: state.position,
              )
            }
          }
        })

      let new_model = Model(..model, remote_players: updated_players)
      #(new_model, effect.none())
    }

    game_messages.SpellCastBroadcast(_caster_id, _wand_index, _direction) -> {
      // TODO: Handle remote spell cast visualization
      #(model, effect.none())
    }

    game_messages.FullGameState(_tick, enemies, projectiles) -> {
      // Dispatch full enemy state to enemy module
      let enemy_effect =
        effect.dispatch(enemy_taggers.on_full_game_state(enemies))

      // Dispatch full projectile state
      let projectile_effect =
        effect.dispatch(projectile_taggers.on_set_projectiles(projectiles))

      #(model, effect.batch([enemy_effect, projectile_effect]))
    }

    game_messages.GameDelta(
      _tick,
      enemy_spawns,
      enemy_updates,
      enemy_deaths,
      projectile_spawns,
      projectile_removals,
      _damage_events,
    ) -> {
      // Dispatch enemy updates to enemy module
      let spawn_effects =
        list.map(enemy_spawns, fn(enemy) {
          effect.dispatch(enemy_taggers.on_enemy_spawned(
            enemy.id,
            enemy.position,
          ))
        })

      let update_effect = case enemy_updates {
        [] -> effect.none()
        updates -> effect.dispatch(enemy_taggers.on_enemies_updated(updates))
      }

      let death_effects =
        list.map(enemy_deaths, fn(enemy_id) {
          effect.dispatch(enemy_taggers.on_enemy_died(enemy_id))
        })

      // Dispatch projectile updates
      // Only update if we have projectiles (don't clear on empty list)
      let projectile_update_effect = case projectile_spawns {
        [] -> effect.none()
        projectiles ->
          effect.dispatch(projectile_taggers.on_set_projectiles(projectiles))
      }

      // Note: projectile_removals is now redundant since we're setting all projectiles
      let _ = projectile_removals

      #(
        model,
        effect.batch(
          list.flatten([
            spawn_effects,
            [update_effect],
            death_effects,
            [projectile_update_effect],
          ]),
        ),
      )
    }

    game_messages.EnemySpawned(_enemy_id, _position, _health) -> {
      // Legacy message - prefer GameDelta
      #(model, effect.none())
    }

    game_messages.EnemyDied(_enemy_id, _killer_id) -> {
      // Legacy message - prefer GameDelta
      #(model, effect.none())
    }

    game_messages.Pong(client_timestamp, _server_timestamp) -> {
      let now = get_timestamp()
      let rtt = now - client_timestamp
      let latency = rtt / 2
      let new_model = Model(..model, latency_ms: latency)
      #(new_model, effect.none())
    }

    game_messages.Error(_message) -> {
      // TODO: Handle server errors
      #(model, effect.none())
    }
  }
}

/// Send a client message over the WebSocket.
fn send_client_message(
  model: Model,
  msg: ClientMessage,
) -> #(Model, Effect(game_msg)) {
  case model.connection_state {
    Connected(_, _) -> {
      let json_str = encode_client_message(msg)
      let send_effect = effect.from(fn(_dispatch) { do_send(json_str) })
      #(model, send_effect)
    }
    _ -> #(model, effect.none())
  }
}

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------

/// Interpolate a remote player's position toward their target.
fn interpolate_player_position(remote: RemotePlayer) -> RemotePlayer {
  // Use fixed-step interpolation similar to enemy interpolation
  // Higher alpha = faster/snappier movement, lower = smoother but more lag
  let alpha = 0.7

  let delta_x = remote.target_position.x -. remote.render_position.x
  let delta_y = remote.target_position.y -. remote.render_position.y
  let delta_z = remote.target_position.z -. remote.render_position.z

  // Calculate distance
  let distance_squared =
    delta_x *. delta_x +. delta_y *. delta_y +. delta_z *. delta_z

  // If very close, snap to target
  case distance_squared <. 0.0001 {
    True -> {
      RemotePlayer(..remote, render_position: remote.target_position)
    }
    False -> {
      // Lerp toward target
      let new_x = remote.render_position.x +. delta_x *. alpha
      let new_y = remote.render_position.y +. delta_y *. alpha
      let new_z = remote.render_position.z +. delta_z *. alpha
      let new_pos = Vec3(new_x, new_y, new_z)
      RemotePlayer(..remote, render_position: new_pos)
    }
  }
}

/// Get the local player's ID if connected.
fn get_own_player_id(model: Model) -> Option(id.Id) {
  case model.connection_state {
    Connected(_, player_id) -> Some(player_id)
    _ -> None
  }
}

/// Check if connected to a server.
pub fn is_connected(model: Model) -> Bool {
  case model.connection_state {
    Connected(_, _) -> True
    _ -> False
  }
}

/// Get the list of remote players.
pub fn get_remote_players(model: Model) -> List(RemotePlayer) {
  model.remote_players
}

/// Get the current latency in milliseconds.
pub fn get_latency(model: Model) -> Int {
  model.latency_ms
}

// ----------------------------------------------------------------------------
// View
// ----------------------------------------------------------------------------

/// Render remote players as simple colored capsules.
pub fn view(model: Model) -> List(scene.Node) {
  model.remote_players
  |> list.map(view_remote_player)
}

/// Render a single remote player.
fn view_remote_player(remote: RemotePlayer) -> scene.Node {
  let player = remote.state

  // Create a box geometry and material for the remote player
  let geo_result = geometry.box(size: Vec3(0.8, 2.0, 0.8))
  let mat_result =
    material.new()
    |> material.with_color(0x00ff88)
    |> material.with_emissive(0x00ff88)
    |> material.with_emissive_intensity(0.3)
    |> material.build()

  case geo_result, mat_result {
    Ok(geo), Ok(mat) -> {
      let assert id.Player(pid) = player.id

      // Create player mesh using interpolated render position
      let player_mesh =
        scene.mesh(
          id: "remote-player-" <> int.to_string(pid),
          geometry: geo,
          material: mat,
          transform: transform.at(position: Vec3(
            remote.render_position.x,
            remote.render_position.y +. 1.0,
            remote.render_position.z,
          )),
          physics: option.None,
        )

      // Add name label above player
      let name_label =
        scene.css2d(
          id: "remote-player-label-" <> int.to_string(pid),
          html: "<div style='color: #00ff88; font-family: monospace; font-size: 12px; text-align: center; pointer-events: none;'>Player</div>",
          transform: transform.at(position: Vec3(0.0, 1.5, 0.0)),
        )

      player_mesh
      |> scene.with_children([name_label])
    }
    _, _ -> {
      // Fallback: return empty node if geometry/material fails
      let assert id.Player(pid) = player.id
      scene.empty(
        id: "remote-player-" <> int.to_string(pid),
        transform: transform.identity,
        children: [],
      )
    }
  }
}

// ----------------------------------------------------------------------------
// FFI
// ----------------------------------------------------------------------------

@external(javascript, "./network_ffi.mjs", "connect")
fn do_connect(
  url: String,
  room_id: String,
  player_name: String,
  dispatch: fn(Msg) -> Nil,
) -> Nil

@external(javascript, "./network_ffi.mjs", "disconnect")
fn do_disconnect() -> Nil

@external(javascript, "./network_ffi.mjs", "send")
fn do_send(message: String) -> Nil

@external(javascript, "./network_ffi.mjs", "getTimestamp")
fn get_timestamp() -> Int
