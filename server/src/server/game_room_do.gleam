import conversation.{type JsRequest, type JsResponse}
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type DecodeError}
import gleam/float
import gleam/int
import gleam/io
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/time/duration
import gleam/time/timestamp
import plinth/cloudflare/durable_object.{type State, type WebSocket}
import plinth/cloudflare/response
import server/game_simulation
import server/game_tick
import shared/game_messages.{
  type ClientMessage, type ServerMessage, decode_client_message,
  encode_server_message,
}
import shared/game_state
import shared/player
import shared/room
import shared/spell
import shared/wand
import vec/vec3.{type Vec3, Vec3}

/// The full state of the game room Durable Object
pub type GameRoomDOState {
  GameRoomDOState(
    players: Dict(player.Id, PlayerInfo),
    next_player_id: Int,
    game_state: game_state.GameState,
    tick_scheduler: game_tick.TickScheduler,
    // Buffer for player inputs received between ticks
    player_inputs: Dict(player.Id, game_messages.PlayerAction),
  )
}

/// Information about a connected player
pub type PlayerInfo {
  PlayerInfo(state: player.Player, ws: WebSocket)
}

/// Initialize a new game room state
pub fn init_state() -> GameRoomDOState {
  GameRoomDOState(
    players: dict.new(),
    next_player_id: 1,
    game_state: game_state.new(),
    tick_scheduler: game_tick.new(),
    player_inputs: dict.new(),
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
  state: State,
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
      let pid = room_state.next_player_id
      let new_attachment = json.object([#("player_id", json.int(pid))])
      durable_object.websocket_serialize_attachment(ws, new_attachment)
      player.Id(pid)
    }
    Error(_) -> panic as "Failed to decode player ID from attachment"
  }

  // Parse the message
  case decode_client_message(message) {
    Ok(msg) -> {
      // Handle the message
      let #(new_state, messages) =
        handle_message(state, room_state, player_id, ws, msg)

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
      let player.Id(pid) = player_id
      io.println("[GameRoom] Player " <> int.to_string(pid) <> " disconnected")

      // Remove player from WebSocket connections dict
      let new_players = dict.delete(room_state.players, player_id)

      // Remove player from game simulation dict
      let new_game_players =
        dict.delete(room_state.game_state.players, player_id)
      let new_game_state =
        game_state.GameState(..room_state.game_state, players: new_game_players)

      // Broadcast player_left to remaining players
      broadcast_to_all(
        new_players,
        encode_server_message(game_messages.PlayerLeft(player_id)),
      )

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
  state: State,
  room_state: GameRoomDOState,
  player_id: player.Id,
  ws: WebSocket,
  msg: ClientMessage,
) -> #(GameRoomDOState, List(#(player.Id, ServerMessage))) {
  case msg {
    game_messages.JoinRoom(room_id, player_name) -> {
      handle_join(state, room_state, player_id, ws, room_id, player_name)
    }
    game_messages.LeaveRoom -> handle_leave(room_state, player_id)
    game_messages.PlayerInput(_tick, action) -> {
      // Buffer the input for the next tick
      let new_inputs = dict.insert(room_state.player_inputs, player_id, action)
      let new_state = GameRoomDOState(..room_state, player_inputs: new_inputs)
      #(new_state, [])
    }
    game_messages.PlayerUpdate(position) ->
      handle_player_update(room_state, player_id, position)
    game_messages.Ping(timestamp) ->
      handle_ping(room_state, player_id, timestamp)
  }
}

/// Handle player joining
fn handle_join(
  state: State,
  room_state: GameRoomDOState,
  player_id: player.Id,
  ws: WebSocket,
  _room_id: String,
  player_name: String,
) -> #(GameRoomDOState, List(#(player.Id, ServerMessage))) {
  // Start tick loop if this is the first player
  case dict.size(room_state.players) {
    0 -> start_tick_loop(state)
    _ -> Nil
  }
  // Create new player state with the new constructor
  let new_player =
    player.new(player_id, player_name, Vec3(0.0, 0.9, 0.0))
    |> give_starter_wand()

  let player_info = PlayerInfo(state: new_player, ws: ws)

  // Get existing players
  let existing_players =
    dict.values(room_state.players)
    |> list.map(fn(info) { info.state })

  // Add new player to room_state.players (WebSocket connections)
  let new_players = dict.insert(room_state.players, player_id, player_info)

  // Add new player to game_state.players (simulation state)
  let new_game_players =
    dict.insert(room_state.game_state.players, player_id, new_player)
  let new_game_state =
    game_state.GameState(..room_state.game_state, players: new_game_players)

  // Increment next player ID
  let new_state =
    GameRoomDOState(
      ..room_state,
      players: new_players,
      game_state: new_game_state,
      next_player_id: room_state.next_player_id + 1,
    )

  // Send room_joined to new player
  // Use a fixed room ID of 1 for now (single room support)
  let join_msg =
    game_messages.RoomJoined(room.Id(1), player_id, existing_players)

  // Broadcast player_joined to existing players
  let broadcast_msg = game_messages.PlayerJoined(new_player)

  // Build message list
  let messages =
    dict.keys(room_state.players)
    |> list.map(fn(pid) { #(pid, broadcast_msg) })
    |> list.prepend(#(player_id, join_msg))

  #(new_state, messages)
}

/// Handle player leaving
fn handle_leave(
  room_state: GameRoomDOState,
  player_id: player.Id,
) -> #(GameRoomDOState, List(#(player.Id, ServerMessage))) {
  // Parse player ID

  // Remove player from room_state.players (WebSocket connections)
  let new_players = dict.delete(room_state.players, player_id)

  // Remove player from game_state.players (simulation state)
  let new_game_players = dict.delete(room_state.game_state.players, player_id)
  let new_game_state =
    game_state.GameState(..room_state.game_state, players: new_game_players)

  // Close WebSocket
  case dict.get(room_state.players, player_id) {
    Ok(player_info) ->
      durable_object.websocket_close(player_info.ws, 1000, "Player left")
    Error(_) -> Nil
  }

  let new_state =
    GameRoomDOState(
      ..room_state,
      players: new_players,
      game_state: new_game_state,
    )

  // Broadcast to remaining players
  let broadcast_msg = game_messages.PlayerLeft(player_id)
  let messages =
    dict.keys(new_players)
    |> list.map(fn(pid) { #(pid, broadcast_msg) })

  #(new_state, messages)
}

/// Handle player position update
fn handle_player_update(
  room_state: GameRoomDOState,
  player_id: player.Id,
  position: Vec3(Float),
) -> #(GameRoomDOState, List(#(player.Id, ServerMessage))) {
  // Parse player ID

  case dict.get(room_state.players, player_id) {
    Ok(player_info) -> {
      let updated_state = player.Player(..player_info.state, position: position)
      let updated_info = PlayerInfo(..player_info, state: updated_state)
      let new_players = dict.insert(room_state.players, player_id, updated_info)
      let new_state = GameRoomDOState(..room_state, players: new_players)

      // Broadcast updated player states to all players
      let player_states =
        dict.values(new_players)
        |> list.map(fn(info) { info.state })

      let player_states_msg = game_messages.PlayerStates(player_states)
      let messages =
        dict.keys(new_players)
        |> list.map(fn(pid) { #(pid, player_states_msg) })

      #(new_state, messages)
    }
    Error(_) -> #(room_state, [])
  }
}

/// Handle ping
fn handle_ping(
  room_state: GameRoomDOState,
  player_id: player.Id,
  client_timestamp: timestamp.Timestamp,
) -> #(GameRoomDOState, List(#(player.Id, ServerMessage))) {
  let server_timestamp = timestamp.system_time()
  let pong_msg = game_messages.Pong(client_timestamp, server_timestamp)
  #(room_state, [#(player_id, pong_msg)])
}

/// Helper: Broadcast message to all players
fn broadcast_to_all(players: Dict(player.Id, PlayerInfo), message: String) {
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
) -> Result(Option(player.Id), List(DecodeError)) {
  let decoder =
    decode.at(
      ["player_id"],
      decode.optional(decode.int |> decode.map(player.Id)),
    )
  decode.run(attachment, decoder)
}

// =============================================================================
// TICK PROCESSING (Called by alarm handler)
// =============================================================================

/// Process a game tick (called by alarm() in server_ffi.mjs)
/// This is the main server loop that runs at 20 Hz
pub fn process_tick(
  state: State,
  room_state: GameRoomDOState,
) -> GameRoomDOState {
  // Advance the tick counter
  let new_scheduler = game_tick.advance_tick(room_state.tick_scheduler)
  let current_tick = game_tick.current_tick(new_scheduler)

  // Get delta time for physics
  let delta_time = game_tick.get_delta_time()

  // Run game simulation
  let #(new_game_state, events) =
    game_simulation.tick(
      room_state.game_state,
      room_state.player_inputs,
      delta_time,
    )

  // Update the state with new game state and clear input buffer
  let new_state =
    GameRoomDOState(
      ..room_state,
      tick_scheduler: new_scheduler,
      game_state: new_game_state,
      player_inputs: dict.new(),
    )

  // Broadcast GameStateUpdate to all players
  broadcast_game_state_update(new_state.players, current_tick, new_game_state)

  // Broadcast individual events (projectile spawns, deaths, etc.)
  broadcast_events(new_state.players, events)

  // Schedule the next tick (50ms from now)
  // Cloudflare alarms expect a Unix timestamp in milliseconds
  let storage = durable_object.storage(state)
  let now_seconds = timestamp.system_time() |> timestamp.to_unix_seconds
  let now_ms = float.round(now_seconds *. 1000.0)
  let next_tick_ms = now_ms + game_tick.next_tick_delay_ms()
  let _promise = durable_object.set_alarm(storage, next_tick_ms)

  new_state
}

/// Start the tick loop when the first player joins
pub fn start_tick_loop(state: State) {
  let storage = durable_object.storage(state)

  // Schedule alarm 50ms from now
  let now_seconds = timestamp.system_time() |> timestamp.to_unix_seconds
  let now_ms = float.round(now_seconds *. 1000.0)
  let next_tick_ms = now_ms + game_tick.next_tick_delay_ms()
  let _promise = durable_object.set_alarm(storage, next_tick_ms)

  Nil
}

// =============================================================================
// BROADCAST HELPERS
// =============================================================================

/// Broadcast GameStateUpdate to all connected players
fn broadcast_game_state_update(
  players: Dict(player.Id, PlayerInfo),
  tick: Int,
  game_state: game_state.GameState,
) {
  // Convert game_state to message format
  let players_list = dict.values(game_state.players)
  let projectiles_list = dict.values(game_state.projectiles)
  let enemies_list = dict.values(game_state.enemies)

  let msg =
    game_messages.GameStateUpdate(
      tick: tick,
      players: players_list,
      projectiles: projectiles_list,
      enemies: enemies_list,
    )

  let encoded = encode_server_message(msg)
  broadcast_to_all(players, encoded)
}

/// Broadcast game events to all players
fn broadcast_events(
  players: Dict(player.Id, PlayerInfo),
  events: List(game_simulation.GameEvent),
) {
  list.each(events, fn(event) {
    let msg = case event {
      game_simulation.ProjectileCreated(projectile) ->
        game_messages.ProjectileSpawned(projectile)
      game_simulation.ProjectileDestroyed(id, reason) -> {
        let destroy_reason = case reason {
          game_simulation.HitEnemy(enemy_id) -> game_messages.HitEnemy(enemy_id)
          game_simulation.HitPlayer(player_id) ->
            game_messages.HitPlayer(player_id)
          game_simulation.Expired -> game_messages.Expired
        }
        game_messages.ProjectileDestroyed(id, destroy_reason)
      }
      game_simulation.EnemySpawned(enemy) -> game_messages.EnemySpawned(enemy)
      game_simulation.EnemyDied(id) -> game_messages.EnemyDied(id)
      game_simulation.PlayerDamaged(player_id, damage, new_health) ->
        game_messages.PlayerDamaged(player_id, damage, new_health)
    }
    let encoded = encode_server_message(msg)
    broadcast_to_all(players, encoded)
  })
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Give a player a starter wand with some basic spells
fn give_starter_wand(new_player: player.Player) -> player.Player {
  // Create a simple starter wand with 3 spark spells
  let starter_wand =
    wand.new(
      name: "Starter Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: duration.milliseconds(100),
      recharge_time: duration.milliseconds(200),
      spells_per_cast: 1,
      spread: 0.0,
    )

  // Add spells to the wand
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 0, spell.spark())
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 1, spell.spark())
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 2, spell.spark())

  // Put the wand in slot 0
  let new_wands =
    player.WandInventory(
      slot_0: option.Some(starter_wand),
      slot_1: option.None,
      slot_2: option.None,
      slot_3: option.None,
    )

  player.Player(..new_player, wands: new_wands, active_wand_slot: 0)
}
