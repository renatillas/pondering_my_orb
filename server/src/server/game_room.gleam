/// Durable Object for managing a single game room.
/// Handles WebSocket connections and game state synchronization.
///
/// Note: The actual Durable Object class is implemented in JavaScript (server_ffi.mjs)
/// because Cloudflare Workers require JavaScript classes for Durable Objects.
/// This module provides Gleam types and functions for the game logic.
import gleam/dict.{type Dict}
import gleam/list
import shared/game_messages.{
  type ClientMessage, type ServerMessage, JoinRoom, LeaveRoom, Ping,
  PlayerJoined, PlayerLeft, PlayerStates, PlayerUpdate, Pong, RoomJoined,
  SpellCast, SpellCastBroadcast,
}
import shared/id.{PlayerId, RoomId}
import shared/player_state.{type PlayerState, PlayerState}
import vec/vec3.{type Vec3, Vec3}

/// The state of a game room.
pub type GameRoomState {
  GameRoomState(players: Dict(String, PlayerState), next_player_id: Int)
}

/// Initialize a new game room state.
pub fn init() -> GameRoomState {
  GameRoomState(players: dict.new(), next_player_id: 1)
}

/// Handle an incoming message from a player.
pub fn handle_message(
  state: GameRoomState,
  player_id: String,
  msg: ClientMessage,
) -> #(GameRoomState, List(#(String, ServerMessage))) {
  case msg {
    JoinRoom(room_id, player_name) -> handle_join(state, room_id, player_name)

    LeaveRoom -> handle_leave(state, player_id)

    PlayerUpdate(position, rotation) ->
      handle_player_update(state, player_id, position, rotation)

    SpellCast(wand_index, direction) ->
      handle_spell_cast(state, player_id, wand_index, direction)

    Ping(timestamp) -> handle_ping(state, player_id, timestamp)
  }
}

/// Handle a player joining the room.
fn handle_join(
  state: GameRoomState,
  room_id: String,
  _player_name: String,
) -> #(GameRoomState, List(#(String, ServerMessage))) {
  let player_id = "player_" <> int_to_string(state.next_player_id)
  let new_player =
    PlayerState(
      id: PlayerId(player_id),
      position: Vec3(0.0, 0.0, 0.0),
      rotation: 0.0,
      health: 100.0,
      max_health: 100.0,
      active_wand_index: 0,
    )

  let new_state =
    GameRoomState(
      players: dict.insert(state.players, player_id, new_player),
      next_player_id: state.next_player_id + 1,
    )

  // Get list of existing players for the new player
  let existing_players = dict.values(state.players)

  // Message to send to the new player
  let join_msg =
    RoomJoined(RoomId(room_id), PlayerId(player_id), existing_players)

  // Message to broadcast to existing players
  let broadcast_msg = PlayerJoined(new_player)

  // Build message list: new player gets RoomJoined, others get PlayerJoined
  let messages =
    dict.keys(state.players)
    |> list.map(fn(pid) { #(pid, broadcast_msg) })
    |> list.prepend(#(player_id, join_msg))

  #(new_state, messages)
}

/// Handle a player leaving the room.
fn handle_leave(
  state: GameRoomState,
  player_id: String,
) -> #(GameRoomState, List(#(String, ServerMessage))) {
  let new_state =
    GameRoomState(..state, players: dict.delete(state.players, player_id))

  // Broadcast to remaining players
  let broadcast_msg = PlayerLeft(PlayerId(player_id))
  let messages =
    dict.keys(new_state.players)
    |> list.map(fn(pid) { #(pid, broadcast_msg) })

  #(new_state, messages)
}

/// Handle a player position update.
fn handle_player_update(
  state: GameRoomState,
  player_id: String,
  position: Vec3(Float),
  rotation: Float,
) -> #(GameRoomState, List(#(String, ServerMessage))) {
  case dict.get(state.players, player_id) {
    Ok(player) -> {
      let updated_player =
        PlayerState(..player, position: position, rotation: rotation)
      let new_state =
        GameRoomState(
          ..state,
          players: dict.insert(state.players, player_id, updated_player),
        )
      // No immediate broadcast - state sync happens periodically
      #(new_state, [])
    }
    Error(_) -> #(state, [])
  }
}

/// Handle a spell cast.
fn handle_spell_cast(
  state: GameRoomState,
  player_id: String,
  wand_index: Int,
  direction: Vec3(Float),
) -> #(GameRoomState, List(#(String, ServerMessage))) {
  // Broadcast the spell cast to all players (including the caster for confirmation)
  let broadcast_msg =
    SpellCastBroadcast(PlayerId(player_id), wand_index, direction)
  let messages =
    dict.keys(state.players)
    |> list.map(fn(pid) { #(pid, broadcast_msg) })

  #(state, messages)
}

/// Handle a ping request.
fn handle_ping(
  state: GameRoomState,
  player_id: String,
  client_timestamp: Int,
) -> #(GameRoomState, List(#(String, ServerMessage))) {
  // Respond with pong to the requesting player
  let server_timestamp = get_current_timestamp()
  let pong_msg = Pong(client_timestamp, server_timestamp)
  #(state, [#(player_id, pong_msg)])
}

/// Get all player states for periodic broadcast.
pub fn get_player_states(state: GameRoomState) -> List(PlayerState) {
  dict.values(state.players)
}

/// Broadcast player states to all connected players.
pub fn broadcast_states(state: GameRoomState) -> List(#(String, ServerMessage)) {
  let states = get_player_states(state)
  let msg = PlayerStates(states)
  dict.keys(state.players)
  |> list.map(fn(pid) { #(pid, msg) })
}

// Helper function to get current timestamp
@external(javascript, "../server_ffi.mjs", "getCurrentTimestamp")
fn get_current_timestamp() -> Int

// Helper function to convert int to string
@external(javascript, "../server_ffi.mjs", "intToString")
fn int_to_string(n: Int) -> String
