/// Game messages for client-server communication.
/// These messages are serialized as JSON and sent over WebSocket connections.
import gleam/dynamic/decode
import gleam/json
import gleam/result
import shared/id.{type PlayerId, type RoomId, PlayerId, RoomId}
import shared/player_state.{type PlayerState}
import vec/vec3.{type Vec3}

// ----------------------------------------------------------------------------
// Client -> Server Messages
// ----------------------------------------------------------------------------

/// Messages sent from the client to the server.
pub type ClientMessage {
  /// Request to join a game room.
  JoinRoom(room_id: String, player_name: String)
  /// Request to leave the current room.
  LeaveRoom
  /// Update the player's position and rotation.
  PlayerUpdate(position: Vec3(Float), rotation: Float)
  /// Cast a spell from a wand.
  SpellCast(wand_index: Int, direction: Vec3(Float))
  /// Ping the server to measure latency.
  Ping(timestamp: Int)
}

/// Encode a ClientMessage to JSON string for transmission.
pub fn encode_client_message(msg: ClientMessage) -> String {
  case msg {
    JoinRoom(room_id, player_name) ->
      json.object([
        #("type", json.string("join_room")),
        #("room_id", json.string(room_id)),
        #("player_name", json.string(player_name)),
      ])
    LeaveRoom -> json.object([#("type", json.string("leave_room"))])
    PlayerUpdate(position, rotation) ->
      json.object([
        #("type", json.string("player_update")),
        #("position", player_state.encode_vec3(position)),
        #("rotation", json.float(rotation)),
      ])
    SpellCast(wand_index, direction) ->
      json.object([
        #("type", json.string("spell_cast")),
        #("wand_index", json.int(wand_index)),
        #("direction", player_state.encode_vec3(direction)),
      ])
    Ping(timestamp) ->
      json.object([
        #("type", json.string("ping")),
        #("timestamp", json.int(timestamp)),
      ])
  }
  |> json.to_string
}

/// Decode a ClientMessage from JSON string.
pub fn decode_client_message(data: String) -> Result(ClientMessage, String) {
  let decoder = {
    use msg_type <- decode.field("type", decode.string)
    case msg_type {
      "join_room" -> {
        use room_id <- decode.field("room_id", decode.string)
        use player_name <- decode.field("player_name", decode.string)
        decode.success(JoinRoom(room_id, player_name))
      }
      "leave_room" -> decode.success(LeaveRoom)
      "player_update" -> {
        use position <- decode.field("position", player_state.vec3_decoder())
        use rotation <- decode.field("rotation", decode.float)
        decode.success(PlayerUpdate(position, rotation))
      }
      "spell_cast" -> {
        use wand_index <- decode.field("wand_index", decode.int)
        use direction <- decode.field("direction", player_state.vec3_decoder())
        decode.success(SpellCast(wand_index, direction))
      }
      "ping" -> {
        use timestamp <- decode.field("timestamp", decode.int)
        decode.success(Ping(timestamp))
      }
      _ -> decode.failure(LeaveRoom, "ClientMessage")
    }
  }
  json.parse(data, decoder)
  |> result.map_error(fn(_) { "Failed to parse client message" })
}

// ----------------------------------------------------------------------------
// Server -> Client Messages
// ----------------------------------------------------------------------------

/// Messages sent from the server to the client.
pub type ServerMessage {
  /// Confirmation that the player has joined a room.
  RoomJoined(room_id: RoomId, player_id: PlayerId, players: List(PlayerState))
  /// A new player has joined the room.
  PlayerJoined(player: PlayerState)
  /// A player has left the room.
  PlayerLeft(player_id: PlayerId)
  /// Periodic state update for all players in the room.
  PlayerStates(states: List(PlayerState))
  /// A player has cast a spell.
  SpellCastBroadcast(
    caster_id: PlayerId,
    wand_index: Int,
    direction: Vec3(Float),
  )
  /// An enemy has spawned.
  EnemySpawned(enemy_id: Int, position: Vec3(Float), health: Float)
  /// An enemy has died.
  EnemyDied(enemy_id: Int, killer_id: PlayerId)
  /// Response to a ping.
  Pong(client_timestamp: Int, server_timestamp: Int)
  /// An error has occurred.
  Error(message: String)
}

/// Encode a ServerMessage to JSON string for transmission.
pub fn encode_server_message(msg: ServerMessage) -> String {
  case msg {
    RoomJoined(room_id, player_id, players) -> {
      let RoomId(rid) = room_id
      let PlayerId(pid) = player_id
      json.object([
        #("type", json.string("room_joined")),
        #("room_id", json.string(rid)),
        #("player_id", json.string(pid)),
        #("players", json.array(players, player_state.encode)),
      ])
    }
    PlayerJoined(player) ->
      json.object([
        #("type", json.string("player_joined")),
        #("player", player_state.encode(player)),
      ])
    PlayerLeft(player_id) -> {
      let PlayerId(pid) = player_id
      json.object([
        #("type", json.string("player_left")),
        #("player_id", json.string(pid)),
      ])
    }
    PlayerStates(states) ->
      json.object([
        #("type", json.string("player_states")),
        #("states", json.array(states, player_state.encode)),
      ])
    SpellCastBroadcast(caster_id, wand_index, direction) -> {
      let PlayerId(cid) = caster_id
      json.object([
        #("type", json.string("spell_cast_broadcast")),
        #("caster_id", json.string(cid)),
        #("wand_index", json.int(wand_index)),
        #("direction", player_state.encode_vec3(direction)),
      ])
    }
    EnemySpawned(enemy_id, position, health) ->
      json.object([
        #("type", json.string("enemy_spawned")),
        #("enemy_id", json.int(enemy_id)),
        #("position", player_state.encode_vec3(position)),
        #("health", json.float(health)),
      ])
    EnemyDied(enemy_id, killer_id) -> {
      let PlayerId(kid) = killer_id
      json.object([
        #("type", json.string("enemy_died")),
        #("enemy_id", json.int(enemy_id)),
        #("killer_id", json.string(kid)),
      ])
    }
    Pong(client_timestamp, server_timestamp) ->
      json.object([
        #("type", json.string("pong")),
        #("client_timestamp", json.int(client_timestamp)),
        #("server_timestamp", json.int(server_timestamp)),
      ])
    Error(message) ->
      json.object([
        #("type", json.string("error")),
        #("message", json.string(message)),
      ])
  }
  |> json.to_string
}

/// Decode a ServerMessage from JSON string.
pub fn decode_server_message(data: String) -> Result(ServerMessage, String) {
  let decoder = {
    use msg_type <- decode.field("type", decode.string)
    case msg_type {
      "room_joined" -> {
        use room_id <- decode.field("room_id", decode.string)
        use player_id <- decode.field("player_id", decode.string)
        use players <- decode.field(
          "players",
          decode.list(player_state.decoder()),
        )
        decode.success(RoomJoined(RoomId(room_id), PlayerId(player_id), players))
      }
      "player_joined" -> {
        use player <- decode.field("player", player_state.decoder())
        decode.success(PlayerJoined(player))
      }
      "player_left" -> {
        use player_id <- decode.field("player_id", decode.string)
        decode.success(PlayerLeft(PlayerId(player_id)))
      }
      "player_states" -> {
        use states <- decode.field(
          "states",
          decode.list(player_state.decoder()),
        )
        decode.success(PlayerStates(states))
      }
      "spell_cast_broadcast" -> {
        use caster_id <- decode.field("caster_id", decode.string)
        use wand_index <- decode.field("wand_index", decode.int)
        use direction <- decode.field("direction", player_state.vec3_decoder())
        decode.success(SpellCastBroadcast(
          PlayerId(caster_id),
          wand_index,
          direction,
        ))
      }
      "enemy_spawned" -> {
        use enemy_id <- decode.field("enemy_id", decode.int)
        use position <- decode.field("position", player_state.vec3_decoder())
        use health <- decode.field("health", decode.float)
        decode.success(EnemySpawned(enemy_id, position, health))
      }
      "enemy_died" -> {
        use enemy_id <- decode.field("enemy_id", decode.int)
        use killer_id <- decode.field("killer_id", decode.string)
        decode.success(EnemyDied(enemy_id, PlayerId(killer_id)))
      }
      "pong" -> {
        use client_timestamp <- decode.field("client_timestamp", decode.int)
        use server_timestamp <- decode.field("server_timestamp", decode.int)
        decode.success(Pong(client_timestamp, server_timestamp))
      }
      "error" -> {
        use message <- decode.field("message", decode.string)
        decode.success(Error(message))
      }
      _ -> decode.failure(Error("unknown"), "ServerMessage")
    }
  }
  json.parse(data, decoder)
  |> result.map_error(fn(_) { "Failed to parse server message" })
}
