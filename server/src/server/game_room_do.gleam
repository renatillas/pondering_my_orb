import conversation.{type JsRequest, type JsResponse}
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type DecodeError}
import gleam/float
import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import plinth/cloudflare/durable_object.{type State, type WebSocket}
import plinth/cloudflare/response
import server/enemy_manager
import server/game_state
import server/projectile_manager
import shared/game_messages.{
  type ClientMessage, type ServerMessage, decode_client_message,
  encode_server_message,
}
import shared/health
import shared/id
import shared/player
import vec/vec3.{type Vec3, Vec3}

/// The full state of the game room Durable Object
pub type GameRoomDOState {
  GameRoomDOState(
    players: Dict(id.Id, PlayerInfo),
    next_player_id: Int,
    // Gleam game state for enemies and projectiles
    game_state: game_state.GameState,
    // Track last tick time to prevent duplicate ticks in same frame
    last_tick_timestamp: Int,
  )
}

/// Per-player wand state for server-authoritative casting
pub type WandState {
  WandState(
    cast_cooldown_ms: Float,
    // Cooldown in milliseconds
    last_input: PlayerInput,
  )
}

/// Player input state
pub type PlayerInput {
  PlayerInput(shoot_pressed: Bool, aim_direction: vec3.Vec3(Float))
}

/// Information about a connected player
pub type PlayerInfo {
  PlayerInfo(state: player.Player, ws: WebSocket, wand_state: WandState)
}

/// Initialize a new game room state
pub fn init_state() -> GameRoomDOState {
  GameRoomDOState(
    players: dict.new(),
    next_player_id: 1,
    game_state: game_state.init(),
    last_tick_timestamp: 0,
  )
}

/// Handle incoming HTTP/WebSocket requests
pub fn fetch(state: State, request: JsRequest) -> Promise(JsResponse) {
  // Check if it's a WebSocket upgrade request
  case response.is_websocket_upgrade(request) {
    True -> handle_websocket_upgrade(state, request)
    False -> {
      // Return error for non-WebSocket requests
      response.error_response(400, "Expected WebSocket")
    }
  }
}

/// Handle WebSocket upgrade requests
fn handle_websocket_upgrade(
  state: State,
  _request: JsRequest,
) -> Promise(JsResponse) {
  // Create WebSocket pair
  let pair = durable_object.new_websocket_pair()
  let client = durable_object.websocket_pair_client(pair)
  let server = durable_object.websocket_pair_server(pair)

  // Accept the server WebSocket with hibernation support
  durable_object.accept_websocket(state, server)

  // Attach player ID to the WebSocket (will be retrieved in message handlers)
  // We'll use JSON to serialize the attachment
  let attachment = json.object([#("player_id", json.null())])
  durable_object.websocket_serialize_attachment(server, attachment)

  // Return upgrade response with client WebSocket
  response.websocket_upgrade_response(client)
}

/// Handle incoming WebSocket messages (called by Cloudflare)
pub fn websocket_message(
  _state: State,
  ws: WebSocket,
  message: String,
  room_state: GameRoomDOState,
) -> GameRoomDOState {
  // Get player ID from WebSocket attachment
  let attachment = durable_object.websocket_deserialize_attachment(ws)
  let player_id = case decode_player_id(attachment) {
    Ok(Some(pid)) -> pid
    Ok(None) -> {
      // First message - assign player ID
      let pid = "player_" <> int.to_string(room_state.next_player_id)
      let new_attachment = json.object([#("player_id", json.string(pid))])
      durable_object.websocket_serialize_attachment(ws, new_attachment)
      pid
    }
    Error(_) -> {
      // Error decoding - assign new player ID
      let pid = "player_" <> int.to_string(room_state.next_player_id)
      let new_attachment = json.object([#("player_id", json.string(pid))])
      durable_object.websocket_serialize_attachment(ws, new_attachment)
      pid
    }
  }

  // Parse the message
  case decode_client_message(message) {
    Ok(msg) -> {
      // Handle the message
      let #(new_state, messages) =
        handle_message(room_state, player_id, ws, msg)

      // Send all response messages
      list.each(messages, fn(msg_data) {
        let #(target_player_id, server_msg) = msg_data
        case dict.get(new_state.players, target_player_id) {
          Ok(player_info) -> {
            let encoded = encode_server_message(server_msg)
            durable_object.websocket_send(player_info.ws, encoded)
          }
          Error(_) -> Nil
        }
      })

      new_state
    }
    Error(_) -> {
      // Send error message
      send_error(ws, "Failed to parse message")
      room_state
    }
  }
}

/// Handle WebSocket close events (called by Cloudflare)
pub fn websocket_close(
  _state: State,
  ws: WebSocket,
  _code: Int,
  _reason: String,
  _was_clean: Bool,
  room_state: GameRoomDOState,
) -> GameRoomDOState {
  // Get player ID from WebSocket attachment
  let attachment = durable_object.websocket_deserialize_attachment(ws)
  case decode_player_id(attachment) {
    Ok(Some(player_id)) -> {
      // Parse player ID
      let parsed_player_id = player_id |> id.from_string

      // Remove player from state
      let new_players = dict.delete(room_state.players, parsed_player_id)

      // Broadcast player_left to remaining players
      broadcast_to_all(
        new_players,
        encode_server_message(game_messages.PlayerLeft(parsed_player_id)),
      )

      // Reset game state if no players left
      let new_game_state = case dict.size(new_players) {
        0 -> game_state.reset(room_state.game_state)
        _ -> room_state.game_state
      }

      GameRoomDOState(
        ..room_state,
        players: new_players,
        game_state: new_game_state,
      )
    }
    _ -> room_state
  }
}

/// Handle WebSocket error events (called by Cloudflare)
pub fn websocket_error(
  state: State,
  ws: WebSocket,
  _error: Dynamic,
  room_state: GameRoomDOState,
) -> GameRoomDOState {
  // Just close the connection
  websocket_close(state, ws, 1011, "WebSocket error", False, room_state)
}

/// Handle an incoming client message
fn handle_message(
  room_state: GameRoomDOState,
  player_id: String,
  ws: WebSocket,
  msg: ClientMessage,
) -> #(GameRoomDOState, List(#(id.Id, ServerMessage))) {
  case msg {
    game_messages.JoinRoom(room_id, _player_name) -> {
      handle_join(room_state, player_id, ws, room_id)
    }
    game_messages.LeaveRoom -> handle_leave(room_state, player_id)
    game_messages.PlayerUpdate(position, rotation) ->
      handle_player_update(room_state, player_id, position, rotation)
    game_messages.InputUpdate(shoot_pressed, aim_direction) ->
      handle_input_update(room_state, player_id, shoot_pressed, aim_direction)
    game_messages.Ping(timestamp) ->
      handle_ping(room_state, player_id, timestamp)
    game_messages.RequestGameTick -> handle_game_tick(room_state, player_id, ws)
  }
}

/// Handle player joining
fn handle_join(
  room_state: GameRoomDOState,
  player_id: String,
  ws: WebSocket,
  _room_id: String,
) -> #(GameRoomDOState, List(#(id.Id, ServerMessage))) {
  // Parse player ID from string format "player_1" to id.Id
  let parsed_player_id = player_id |> id.from_string

  // Create new player state
  let new_player =
    player.Player(
      id: parsed_player_id,
      position: Vec3(0.0, 0.0, 0.0),
      rotation: 0.0,
      health: health.Health(current: 100.0, max: 100.0),
      active_wand_index: 0,
    )

  // Initialize wand state with no cooldown and no input
  let initial_wand_state =
    WandState(
      cast_cooldown_ms: 0.0,
      last_input: PlayerInput(
        shoot_pressed: False,
        aim_direction: Vec3(0.0, 0.0, 1.0),
      ),
    )

  let player_info =
    PlayerInfo(state: new_player, ws: ws, wand_state: initial_wand_state)

  // Get existing players
  let existing_players =
    dict.values(room_state.players)
    |> list.map(fn(info) { info.state })

  // Add new player
  let new_players =
    dict.insert(room_state.players, parsed_player_id, player_info)

  // Increment next player ID
  let new_state =
    GameRoomDOState(
      ..room_state,
      players: new_players,
      next_player_id: room_state.next_player_id + 1,
    )

  // Send room_joined to new player
  // Use a fixed room ID of 1 for now (single room support)
  let join_msg =
    game_messages.RoomJoined(id.Room(1), parsed_player_id, existing_players)

  // Send full game state to new player
  let enemy_states = game_state.get_enemy_states(room_state.game_state)
  let enemy_count = list.length(enemy_states)

  // Debug logging
  console_log(
    "[GameRoom] Sending FullGameState to "
    <> player_id
    <> " with "
    <> int.to_string(enemy_count)
    <> " enemies",
  )

  let full_state_msg =
    game_messages.FullGameState(
      tick: room_state.game_state.tick,
      enemies: enemy_states,
      projectiles: game_state.get_projectile_states(room_state.game_state),
    )

  // Broadcast player_joined to existing players
  let broadcast_msg = game_messages.PlayerJoined(new_player)

  // Build message list
  let messages =
    dict.keys(room_state.players)
    |> list.map(fn(pid) { #(pid, broadcast_msg) })
    |> list.prepend(#(parsed_player_id, full_state_msg))
    |> list.prepend(#(parsed_player_id, join_msg))

  #(new_state, messages)
}

/// Handle player leaving
fn handle_leave(
  room_state: GameRoomDOState,
  player_id: String,
) -> #(GameRoomDOState, List(#(id.Id, ServerMessage))) {
  // Parse player ID
  let parsed_player_id = player_id |> id.from_string

  // Remove player
  let new_players = dict.delete(room_state.players, parsed_player_id)

  // Close WebSocket
  case dict.get(room_state.players, parsed_player_id) {
    Ok(player_info) ->
      durable_object.websocket_close(player_info.ws, 1000, "Player left")
    Error(_) -> Nil
  }

  // Reset game state if no players left
  let new_game_state = case dict.size(new_players) {
    0 -> game_state.reset(room_state.game_state)
    _ -> room_state.game_state
  }

  let new_state =
    GameRoomDOState(
      ..room_state,
      players: new_players,
      game_state: new_game_state,
    )

  // Broadcast to remaining players
  let broadcast_msg = game_messages.PlayerLeft(parsed_player_id)
  let messages =
    dict.keys(new_players)
    |> list.map(fn(pid) { #(pid, broadcast_msg) })

  #(new_state, messages)
}

/// Handle player position update
fn handle_player_update(
  room_state: GameRoomDOState,
  player_id: String,
  position: Vec3(Float),
  rotation: Float,
) -> #(GameRoomDOState, List(#(id.Id, ServerMessage))) {
  // Parse player ID
  let parsed_player_id = player_id |> id.from_string

  case dict.get(room_state.players, parsed_player_id) {
    Ok(player_info) -> {
      let updated_state =
        player.Player(
          ..player_info.state,
          position: position,
          rotation: rotation,
        )
      let updated_info = PlayerInfo(..player_info, state: updated_state)
      let new_players =
        dict.insert(room_state.players, parsed_player_id, updated_info)
      let new_state = GameRoomDOState(..room_state, players: new_players)
      #(new_state, [])
    }
    Error(_) -> #(room_state, [])
  }
}

/// Handle spell cast
/// Handle player input update (shoot button + aim direction)
/// Server decides when to spawn projectiles based on cooldown
fn handle_input_update(
  room_state: GameRoomDOState,
  player_id: String,
  shoot_pressed: Bool,
  aim_direction: Vec3(Float),
) -> #(GameRoomDOState, List(#(id.Id, ServerMessage))) {
  // Parse player ID
  let parsed_player_id = player_id |> id.from_string

  // Update player's input state
  case dict.get(room_state.players, parsed_player_id) {
    Ok(player_info) -> {
      // Update input state
      let new_input =
        PlayerInput(shoot_pressed: shoot_pressed, aim_direction: aim_direction)
      let updated_wand_state =
        WandState(..player_info.wand_state, last_input: new_input)
      let updated_player_info =
        PlayerInfo(..player_info, wand_state: updated_wand_state)

      let updated_players =
        dict.insert(room_state.players, parsed_player_id, updated_player_info)
      let updated_room_state =
        GameRoomDOState(..room_state, players: updated_players)

      // No immediate messages - casting happens in game tick
      #(updated_room_state, [])
    }
    Error(_) -> {
      // Player not found
      #(room_state, [])
    }
  }
}

/// Process player casting inputs and spawn projectiles when cooldown allows
fn process_player_casting(
  room_state: GameRoomDOState,
  game_state: game_state.GameState,
  dt: Float,
) -> #(GameRoomDOState, game_state.GameState) {
  // Wand cooldown in seconds (150ms default cast delay)
  let cast_cooldown_ms = 150.0
  let dt_ms = dt *. 1000.0

  // Process each player
  let #(updated_players, updated_game_state) =
    dict.fold(
      room_state.players,
      #(dict.new(), game_state),
      fn(acc, player_id, player_info) {
        let #(players_acc, state_acc) = acc

        // Reduce cooldown
        let new_cooldown =
          float.max(0.0, player_info.wand_state.cast_cooldown_ms -. dt_ms)

        // Check if player wants to shoot and cooldown is ready
        let should_cast =
          player_info.wand_state.last_input.shoot_pressed
          && new_cooldown <=. 0.0

        case should_cast {
          True -> {
            // Spawn projectile
            let config = state_acc.config
            let #(new_state, _spawned_projectile) =
              projectile_manager.spawn_projectile(
                state_acc,
                player_id,
                player_info.state.position,
                player_info.wand_state.last_input.aim_direction,
                config.default_projectile_damage,
                config.default_projectile_speed,
                config.default_projectile_size,
                config.default_projectile_lifetime,
              )

            // Reset cooldown
            let updated_wand_state =
              WandState(
                ..player_info.wand_state,
                cast_cooldown_ms: cast_cooldown_ms,
              )
            let updated_player_info =
              PlayerInfo(..player_info, wand_state: updated_wand_state)

            #(
              dict.insert(players_acc, player_id, updated_player_info),
              new_state,
            )
          }
          False -> {
            // Just update cooldown
            let updated_wand_state =
              WandState(
                ..player_info.wand_state,
                cast_cooldown_ms: new_cooldown,
              )
            let updated_player_info =
              PlayerInfo(..player_info, wand_state: updated_wand_state)

            #(
              dict.insert(players_acc, player_id, updated_player_info),
              state_acc,
            )
          }
        }
      },
    )

  let updated_room_state =
    GameRoomDOState(..room_state, players: updated_players)
  #(updated_room_state, updated_game_state)
}

/// Handle ping
fn handle_ping(
  room_state: GameRoomDOState,
  player_id: String,
  client_timestamp: Int,
) -> #(GameRoomDOState, List(#(id.Id, ServerMessage))) {
  // Parse player ID
  let parsed_player_id = player_id |> id.from_string

  let server_timestamp = current_timestamp()
  let pong_msg = game_messages.Pong(client_timestamp, server_timestamp)
  #(room_state, [#(parsed_player_id, pong_msg)])
}

/// Handle game tick request
fn handle_game_tick(
  room_state: GameRoomDOState,
  _player_id: String,
  _ws: WebSocket,
) -> #(GameRoomDOState, List(#(id.Id, ServerMessage))) {
  let now = current_timestamp()

  // Debounce: Only process one tick per 16ms (60 FPS max)
  // This prevents multiple players from causing duplicate ticks
  let min_tick_interval = 16
  case now - room_state.last_tick_timestamp < min_tick_interval {
    True -> {
      // Too soon - skip this tick request
      #(room_state, [])
    }
    False -> {
      // Get delta time and update tick
      let #(state_with_time, dt) =
        game_state.get_delta_time(room_state.game_state)

      // Get player positions for enemy spawning/movement
      let player_positions =
        dict.values(room_state.players)
        |> list.map(fn(player_info) { player_info.state.position })

      // Update enemy spawning
      let spawn_result =
        enemy_manager.update_spawning(state_with_time, player_positions, dt)

      // Update enemy movement
      let state_with_movement =
        enemy_manager.update_movement(spawn_result.state, player_positions, dt)

      // Process player input and spawn projectiles based on cooldown
      let #(updated_room_state, casting_state) =
        process_player_casting(room_state, state_with_movement, dt)

      // Update projectiles (movement, collisions, lifetime)
      let projectile_result =
        projectile_manager.update_projectiles(casting_state, dt)

      // Build delta message
      let enemy_spawns = case spawn_result.spawned_enemy {
        Some(enemy) -> [enemy]
        None -> []
      }

      let enemy_updates = game_state.get_enemy_updates(projectile_result.state)

      // Get all current projectiles for synchronization
      let all_projectiles = dict.values(projectile_result.state.projectiles)

      // Only broadcast game delta if there are changes
      let has_game_updates = case
        enemy_spawns,
        enemy_updates,
        all_projectiles,
        projectile_result.projectile_removals,
        projectile_result.damage_events,
        projectile_result.enemy_deaths
      {
        [], [], [], [], [], [] -> False
        _, _, _, _, _, _ -> True
      }

      let delta_msg =
        game_messages.GameDelta(
          tick: projectile_result.state.tick,
          enemy_spawns: enemy_spawns,
          enemy_updates: enemy_updates,
          enemy_deaths: projectile_result.enemy_deaths,
          projectile_spawns: all_projectiles,
          projectile_removals: projectile_result.projectile_removals,
          damage_events: projectile_result.damage_events,
        )

      // Get all player states for broadcasting
      let player_states =
        dict.values(updated_room_state.players)
        |> list.map(fn(player_info) { player_info.state })

      // Debug: Log player count
      console_log(
        "[GameTick] Broadcasting "
        <> int.to_string(list.length(player_states))
        <> " player states",
      )

      let player_states_msg = game_messages.PlayerStates(player_states)

      // Broadcast to ALL players (not just the requester)
      let messages =
        dict.keys(updated_room_state.players)
        |> list.flat_map(fn(pid) {
          // Always send player states
          let player_state_message = #(pid, player_states_msg)

          // Conditionally send game delta if there are updates
          case has_game_updates {
            True -> [player_state_message, #(pid, delta_msg)]
            False -> [player_state_message]
          }
        })

      let new_room_state =
        GameRoomDOState(
          ..updated_room_state,
          game_state: projectile_result.state,
          last_tick_timestamp: now,
        )

      #(new_room_state, messages)
    }
  }
}

/// Helper: Broadcast message to all players
fn broadcast_to_all(players: Dict(id.Id, PlayerInfo), message: String) {
  dict.values(players)
  |> list.each(fn(player_info) {
    durable_object.websocket_send(player_info.ws, message)
  })
}

/// Helper: Send error message to a player
fn send_error(ws: WebSocket, error_message: String) {
  let error_msg =
    json.object([
      #("type", json.string("error")),
      #("message", json.string(error_message)),
    ])
    |> json.to_string

  durable_object.websocket_send(ws, error_msg)
}

/// Helper: Decode player ID from WebSocket attachment
fn decode_player_id(
  attachment: Dynamic,
) -> Result(Option(String), List(DecodeError)) {
  let decoder = decode.at(["player_id"], decode.optional(decode.string))
  decode.run(attachment, decoder)
}

// ============================================================================
// FFI Helper Functions
// ============================================================================

@external(javascript, "../server_ffi.mjs", "getCurrentTimestamp")
fn current_timestamp() -> Int

@external(javascript, "../server_ffi.mjs", "consoleLog")
fn console_log(message: String) -> Nil
