/// Game messages for client-server communication.
/// These messages are serialized as JSON and sent over WebSocket connections.
import gleam/dynamic/decode
import gleam/json
import gleam/option
import gleam/result
import gleam/string
import gleam/time/timestamp
import shared/enemy
import shared/game_event
import shared/player.{type Player}
import shared/projectile
import shared/room_info
import shared/vec3 as shared_vec3
import shared/wand
import vec/vec3

// ----------------------------------------------------------------------------
// Client -> Server Messages
// ----------------------------------------------------------------------------

/// Messages sent from the client to the server.
pub type ClientMessage {
  /// Request to list all available rooms.
  ListRooms
  /// Request to create a new room.
  CreateRoom(room_name: String, max_players: Int)
  /// Request to join a game room.
  JoinRoom(room_id: String, player_name: String)
  /// Request to leave the current room.
  LeaveRoom
  /// Player input for server-authoritative gameplay
  PlayerInput(tick: Int, action: PlayerAction)
  /// Ping the server to measure latency.
  Ping(timestamp: timestamp.Timestamp)
}

/// Actions a player can perform
pub type PlayerAction {
  /// No action this tick
  None
  /// WASD movement input
  Move(w: Bool, a: Bool, s: Bool, d: Bool)
  /// Switch active wand slot (0-3 for hotkeys 1-4)
  SwitchWand(slot: Int)
  /// Cast spell at target position
  CastSpell(target: vec3.Vec3(Float))
}

/// Encode a ClientMessage to JSON string for transmission.
pub fn encode_client_message(msg: ClientMessage) -> String {
  case msg {
    ListRooms -> json.object([#("type", json.string("list_rooms"))])
    CreateRoom(room_name, max_players) ->
      json.object([
        #("type", json.string("create_room")),
        #("room_name", json.string(room_name)),
        #("max_players", json.int(max_players)),
      ])
    JoinRoom(room_id, player_name) ->
      json.object([
        #("type", json.string("join_room")),
        #("room_id", json.string(room_id)),
        #("player_name", json.string(player_name)),
      ])
    LeaveRoom -> json.object([#("type", json.string("leave_room"))])
    PlayerInput(tick, action) ->
      json.object([
        #("type", json.string("player_input")),
        #("tick", json.int(tick)),
        #("action", encode_player_action(action)),
      ])
    Ping(timestamp) ->
      json.object([
        #("type", json.string("ping")),
        #(
          "timestamp",
          json.int(timestamp.to_unix_seconds_and_nanoseconds(timestamp).0),
        ),
      ])
  }
  |> json.to_string
}

fn encode_player_action(action: PlayerAction) -> json.Json {
  case action {
    None -> json.object([#("type", json.string("none"))])
    Move(w, a, s, d) ->
      json.object([
        #("type", json.string("move")),
        #("w", json.bool(w)),
        #("a", json.bool(a)),
        #("s", json.bool(s)),
        #("d", json.bool(d)),
      ])
    SwitchWand(slot) ->
      json.object([
        #("type", json.string("switch_wand")),
        #("slot", json.int(slot)),
      ])
    CastSpell(target) ->
      json.object([
        #("type", json.string("cast_spell")),
        #("target", shared_vec3.encode(target)),
      ])
  }
}

/// Decode a ClientMessage from JSON string.
pub fn decode_client_message(data: String) -> Result(ClientMessage, String) {
  let decoder = {
    use msg_type <- decode.field("type", decode.string)
    case msg_type {
      "list_rooms" -> decode.success(ListRooms)
      "create_room" -> {
        use room_name <- decode.field("room_name", decode.string)
        use max_players <- decode.field("max_players", decode.int)
        decode.success(CreateRoom(room_name, max_players))
      }
      "join_room" -> {
        use room_id <- decode.field("room_id", decode.string)
        use player_name <- decode.field("player_name", decode.string)
        decode.success(JoinRoom(room_id, player_name))
      }
      "leave_room" -> decode.success(LeaveRoom)
      "player_input" -> {
        use tick <- decode.field("tick", decode.int)
        use action <- decode.field("action", player_action_decoder())
        decode.success(PlayerInput(tick, action))
      }
      "ping" -> {
        use timestamp <- decode.field("timestamp", decode.int)
        decode.success(Ping(timestamp.from_unix_seconds(timestamp)))
      }
      _ -> decode.failure(LeaveRoom, "ClientMessage")
    }
  }
  json.parse(data, decoder)
  |> result.map_error(fn(error) {
    "Failed to parse client message" <> string.inspect(error)
  })
}

fn player_action_decoder() -> decode.Decoder(PlayerAction) {
  use action_type <- decode.field("type", decode.string)
  case action_type {
    "none" -> decode.success(None)
    "move" -> {
      use w <- decode.field("w", decode.bool)
      use a <- decode.field("a", decode.bool)
      use s <- decode.field("s", decode.bool)
      use d <- decode.field("d", decode.bool)
      decode.success(Move(w, a, s, d))
    }
    "switch_wand" -> {
      use slot <- decode.field("slot", decode.int)
      decode.success(SwitchWand(slot))
    }
    "cast_spell" -> {
      use target <- decode.field("target", shared_vec3.decoder())
      decode.success(CastSpell(target))
    }
    _ -> decode.failure(None, "PlayerAction")
  }
}

// ----------------------------------------------------------------------------
// Helper Functions for Wand Inventory
// ----------------------------------------------------------------------------

/// Encode a WandInventory to JSON
fn encode_wand_inventory(inv: player.WandInventory) -> json.Json {
  json.object([
    #("slot_0", encode_optional_wand(inv.slot_0)),
    #("slot_1", encode_optional_wand(inv.slot_1)),
    #("slot_2", encode_optional_wand(inv.slot_2)),
    #("slot_3", encode_optional_wand(inv.slot_3)),
  ])
}

/// Encode an optional wand (Some(wand) or None)
fn encode_optional_wand(wand_opt: option.Option(wand.Wand)) -> json.Json {
  case wand_opt {
    option.Some(w) -> wand.encode(w)
    option.None -> json.null()
  }
}

/// Decoder for player wand triple #(player.Id, player.WandInventory, #(Int, Int, Int, Int))
fn player_wand_pair_decoder() -> decode.Decoder(
  #(player.Id, player.WandInventory, #(Int, Int, Int, Int)),
) {
  use player_id <- decode.field("player_id", decode.int)
  use wands <- decode.field("wands", wand_inventory_decoder())
  use cooldowns_list <- decode.field("cooldowns", decode.list(decode.int))

  // Convert list to tuple (expect exactly 4 elements)
  let cooldowns = case cooldowns_list {
    [cd0, cd1, cd2, cd3] -> #(cd0, cd1, cd2, cd3)
    _ -> #(0, 0, 0, 0)
    // Default to no cooldowns if unexpected format
  }

  decode.success(#(player.Id(player_id), wands, cooldowns))
}

/// Decoder for WandInventory
fn wand_inventory_decoder() -> decode.Decoder(player.WandInventory) {
  use slot_0 <- decode.field("slot_0", decode.optional(wand.decoder()))
  use slot_1 <- decode.field("slot_1", decode.optional(wand.decoder()))
  use slot_2 <- decode.field("slot_2", decode.optional(wand.decoder()))
  use slot_3 <- decode.field("slot_3", decode.optional(wand.decoder()))
  decode.success(player.WandInventory(
    slot_0: slot_0,
    slot_1: slot_1,
    slot_2: slot_2,
    slot_3: slot_3,
  ))
}

// ----------------------------------------------------------------------------
// Server -> Client Messages
// ----------------------------------------------------------------------------

/// Messages sent from the server to the client.
pub type ServerMessage {
  /// Confirmation that the player has joined a room.
  RoomJoined(player_id: player.Id, players: List(Player))
  /// A new player has joined the room.
  PlayerJoined(player: Player)
  /// A player has left the room.
  PlayerLeft(player_id: player.Id)
  /// Periodic state update for all players in the room (legacy).
  PlayerStates(states: List(Player))
  /// Full game state update (tick-based, server-authoritative)
  GameStateUpdate(
    tick: Int,
    players: List(Player),
    player_wands: List(
      #(player.Id, player.WandInventory, #(Int, Int, Int, Int)),
    ),
    projectiles: List(projectile.Projectile),
    enemies: List(enemy.Enemy),
  )
  /// A game event occurred (projectiles, enemies, damage)
  GameEvent(event: game_event.GameEvent)
  /// Response to a ping.
  Pong(
    client_timestamp: timestamp.Timestamp,
    server_timestamp: timestamp.Timestamp,
  )
  /// List of available rooms
  RoomList(rooms: List(room_info.RoomInfo))
  /// Confirmation that a room was created
  RoomCreated(room_id: String, room_info: room_info.RoomInfo)
  /// Room is full and cannot be joined
  RoomFull(room_id: String)
  /// Room not found
  RoomNotFound(room_id: String)
  /// An error has occurred.
  Error(message: String)
}

/// Encode a ServerMessage to JSON string for transmission.
pub fn encode_server_message(msg: ServerMessage) -> String {
  case msg {
    RoomJoined(player_id, players) -> {
      let player.Id(player_serial) = player_id
      json.object([
        #("type", json.string("room_joined")),
        #("player_id", json.int(player_serial)),
        #("players", json.array(players, player.encode)),
      ])
    }
    PlayerJoined(player_state) ->
      json.object([
        #("type", json.string("player_joined")),
        #("player", player.encode(player_state)),
      ])
    PlayerLeft(player_id) -> {
      let player.Id(player_serial) = player_id
      json.object([
        #("type", json.string("player_left")),
        #("player_id", json.int(player_serial)),
      ])
    }
    PlayerStates(states) ->
      json.object([
        #("type", json.string("player_states")),
        #("states", json.array(states, player.encode)),
      ])
    GameStateUpdate(tick, players, player_wands, projectiles, enemies) ->
      json.object([
        #("type", json.string("game_state_update")),
        #("tick", json.int(tick)),
        #("players", json.array(players, player.encode)),
        #(
          "player_wands",
          json.array(player_wands, fn(triple) {
            let #(player_id, wand_inv, cooldowns) = triple
            let player.Id(id_int) = player_id
            let #(cd0, cd1, cd2, cd3) = cooldowns
            json.object([
              #("player_id", json.int(id_int)),
              #("wands", encode_wand_inventory(wand_inv)),
              #("cooldowns", json.array([cd0, cd1, cd2, cd3], json.int)),
            ])
          }),
        ),
        #("projectiles", json.array(projectiles, projectile.encode)),
        #("enemies", json.array(enemies, enemy.encode)),
      ])
    GameEvent(event) ->
      json.object([
        #("type", json.string("game_event")),
        #("event", game_event.encode(event)),
      ])
    Pong(client_timestamp, server_timestamp) ->
      json.object([
        #("type", json.string("pong")),
        #(
          "client_timestamp",
          json.int(
            timestamp.to_unix_seconds_and_nanoseconds(client_timestamp).0,
          ),
        ),
        #(
          "server_timestamp",
          json.int(
            timestamp.to_unix_seconds_and_nanoseconds(server_timestamp).0,
          ),
        ),
      ])
    RoomList(rooms) ->
      json.object([
        #("type", json.string("room_list")),
        #("rooms", json.array(rooms, room_info.encode)),
      ])
    RoomCreated(room_id, room_info_data) ->
      json.object([
        #("type", json.string("room_created")),
        #("room_id", json.string(room_id)),
        #("room_info", room_info.encode(room_info_data)),
      ])
    RoomFull(room_id) ->
      json.object([
        #("type", json.string("room_full")),
        #("room_id", json.string(room_id)),
      ])
    RoomNotFound(room_id) ->
      json.object([
        #("type", json.string("room_not_found")),
        #("room_id", json.string(room_id)),
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
        use player_id <- decode.field("player_id", decode.int)
        use players <- decode.field("players", decode.list(player.decoder()))
        decode.success(RoomJoined(player.Id(player_id), players))
      }
      "player_joined" -> {
        use player_state <- decode.field("player", player.decoder())
        decode.success(PlayerJoined(player_state))
      }
      "player_left" -> {
        use player_id <- decode.field("player_id", decode.int)
        decode.success(PlayerLeft(player.Id(player_id)))
      }
      "player_states" -> {
        use states <- decode.field("states", decode.list(player.decoder()))
        decode.success(PlayerStates(states))
      }
      "game_state_update" -> {
        use tick <- decode.field("tick", decode.int)
        use players <- decode.field("players", decode.list(player.decoder()))
        use player_wands <- decode.field(
          "player_wands",
          decode.list(player_wand_pair_decoder()),
        )
        use projectiles <- decode.field(
          "projectiles",
          decode.list(projectile.decoder()),
        )
        use enemies <- decode.field("enemies", decode.list(enemy.decoder()))
        decode.success(GameStateUpdate(
          tick,
          players,
          player_wands,
          projectiles,
          enemies,
        ))
      }
      "game_event" -> {
        use event <- decode.field("event", game_event.decoder())
        decode.success(GameEvent(event))
      }
      "pong" -> {
        use client_timestamp <- decode.field("client_timestamp", decode.int)
        use server_timestamp <- decode.field("server_timestamp", decode.int)
        decode.success(Pong(
          timestamp.from_unix_seconds(client_timestamp),
          timestamp.from_unix_seconds(server_timestamp),
        ))
      }
      "room_list" -> {
        use rooms <- decode.field("rooms", decode.list(room_info.decoder()))
        decode.success(RoomList(rooms))
      }
      "room_created" -> {
        use room_id <- decode.field("room_id", decode.string)
        use room_info_data <- decode.field("room_info", room_info.decoder())
        decode.success(RoomCreated(room_id, room_info_data))
      }
      "room_full" -> {
        use room_id <- decode.field("room_id", decode.string)
        decode.success(RoomFull(room_id))
      }
      "room_not_found" -> {
        use room_id <- decode.field("room_id", decode.string)
        decode.success(RoomNotFound(room_id))
      }
      "error" -> {
        use message <- decode.field("message", decode.string)
        decode.success(Error(message))
      }
      _ -> decode.failure(Error("Unknown message type"), "ServerMessage")
    }
  }
  json.parse(data, decoder)
  |> result.map_error(fn(error) {
    "Failed to parse server message" <> string.inspect(error)
  })
}
