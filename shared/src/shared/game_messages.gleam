/// Game messages for client-server communication.
/// These messages are serialized as JSON and sent over WebSocket connections.
import gleam/dynamic/decode
import gleam/json
import gleam/result
import gleam/string
import gleam/time/timestamp
import shared/enemy
import shared/player.{type Player}
import shared/projectile
import shared/room
import shared/vec3 as shared_vec3
import vec/vec3

// ----------------------------------------------------------------------------
// Client -> Server Messages
// ----------------------------------------------------------------------------

/// Messages sent from the client to the server.
pub type ClientMessage {
  /// Request to join a game room.
  JoinRoom(room_id: String, player_name: String)
  /// Request to leave the current room.
  LeaveRoom
  /// Player input for server-authoritative gameplay
  PlayerInput(tick: Int, action: PlayerAction)
  /// Legacy: Update the player's position (will be deprecated)
  PlayerUpdate(position: vec3.Vec3(Float))
  /// Ping the server to measure latency.
  Ping(timestamp: timestamp.Timestamp)
}

/// Actions a player can perform
pub type PlayerAction {
  /// No action this tick
  None
  /// Move to a position (click-to-move)
  MoveToPosition(target: vec3.Vec3(Float))
  /// Switch active wand slot (0-3 for hotkeys 1-4)
  SwitchWand(slot: Int)
  /// Cast spell at target position
  CastSpell(target: vec3.Vec3(Float))
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
    PlayerInput(tick, action) ->
      json.object([
        #("type", json.string("player_input")),
        #("tick", json.int(tick)),
        #("action", encode_player_action(action)),
      ])
    PlayerUpdate(position) ->
      json.object([
        #("type", json.string("player_update")),
        #("position", shared_vec3.encode(position)),
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
    MoveToPosition(target) ->
      json.object([
        #("type", json.string("move_to_position")),
        #("target", shared_vec3.encode(target)),
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
      "player_update" -> {
        use position <- decode.field("position", shared_vec3.decoder())
        decode.success(PlayerUpdate(position))
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
    "move_to_position" -> {
      use target <- decode.field("target", shared_vec3.decoder())
      decode.success(MoveToPosition(target))
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
// Server -> Client Messages
// ----------------------------------------------------------------------------

/// Messages sent from the server to the client.
pub type ServerMessage {
  /// Confirmation that the player has joined a room.
  RoomJoined(room_id: room.Id, player_id: player.Id, players: List(Player))
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
    projectiles: List(projectile.Projectile),
    enemies: List(enemy.Enemy),
  )
  /// A projectile was spawned
  ProjectileSpawned(projectile: projectile.Projectile)
  /// A projectile was destroyed
  ProjectileDestroyed(id: projectile.Id, reason: DestroyReason)
  /// An enemy was spawned
  EnemySpawned(enemy: enemy.Enemy)
  /// An enemy died
  EnemyDied(id: enemy.Id)
  /// A player took damage
  PlayerDamaged(player_id: player.Id, damage: Float, new_health: Float)
  /// Response to a ping.
  Pong(
    client_timestamp: timestamp.Timestamp,
    server_timestamp: timestamp.Timestamp,
  )
  /// An error has occurred.
  Error(message: String)
}

/// Reason a projectile was destroyed
pub type DestroyReason {
  HitEnemy(enemy_id: enemy.Id)
  HitPlayer(player_id: player.Id)
  Expired
}

/// Encode a ServerMessage to JSON string for transmission.
pub fn encode_server_message(msg: ServerMessage) -> String {
  case msg {
    RoomJoined(room_id, player_id, players) -> {
      let room.Id(room_serial) = room_id
      let player.Id(player_serial) = player_id
      json.object([
        #("type", json.string("room_joined")),
        #("room_id", json.int(room_serial)),
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
    GameStateUpdate(tick, players, projectiles, enemies) ->
      json.object([
        #("type", json.string("game_state_update")),
        #("tick", json.int(tick)),
        #("players", json.array(players, player.encode)),
        #("projectiles", json.array(projectiles, projectile.encode)),
        #("enemies", json.array(enemies, enemy.encode)),
      ])
    ProjectileSpawned(proj) ->
      json.object([
        #("type", json.string("projectile_spawned")),
        #("projectile", projectile.encode(proj)),
      ])
    ProjectileDestroyed(id, reason) -> {
      let projectile.Id(proj_id) = id
      json.object([
        #("type", json.string("projectile_destroyed")),
        #("id", json.int(proj_id)),
        #("reason", encode_destroy_reason(reason)),
      ])
    }
    EnemySpawned(enm) ->
      json.object([
        #("type", json.string("enemy_spawned")),
        #("enemy", enemy.encode(enm)),
      ])
    EnemyDied(id) -> {
      let enemy.Id(enemy_id) = id
      json.object([
        #("type", json.string("enemy_died")),
        #("id", json.int(enemy_id)),
      ])
    }
    PlayerDamaged(player_id, damage, new_health) -> {
      let player.Id(pid) = player_id
      json.object([
        #("type", json.string("player_damaged")),
        #("player_id", json.int(pid)),
        #("damage", json.float(damage)),
        #("new_health", json.float(new_health)),
      ])
    }
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
    Error(message) ->
      json.object([
        #("type", json.string("error")),
        #("message", json.string(message)),
      ])
  }
  |> json.to_string
}

fn encode_destroy_reason(reason: DestroyReason) -> json.Json {
  case reason {
    HitEnemy(enemy_id) -> {
      let enemy.Id(eid) = enemy_id
      json.object([
        #("type", json.string("hit_enemy")),
        #("enemy_id", json.int(eid)),
      ])
    }
    HitPlayer(player_id) -> {
      let player.Id(pid) = player_id
      json.object([
        #("type", json.string("hit_player")),
        #("player_id", json.int(pid)),
      ])
    }
    Expired -> json.object([#("type", json.string("expired"))])
  }
}

/// Decode a ServerMessage from JSON string.
pub fn decode_server_message(data: String) -> Result(ServerMessage, String) {
  let decoder = {
    use msg_type <- decode.field("type", decode.string)
    case msg_type {
      "room_joined" -> {
        use room_id <- decode.field("room_id", decode.int)
        use player_id <- decode.field("player_id", decode.int)
        use players <- decode.field("players", decode.list(player.decoder()))
        decode.success(RoomJoined(
          room.Id(room_id),
          player.Id(player_id),
          players,
        ))
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
        use projectiles <- decode.field(
          "projectiles",
          decode.list(projectile.decoder()),
        )
        use enemies <- decode.field("enemies", decode.list(enemy.decoder()))
        decode.success(GameStateUpdate(tick, players, projectiles, enemies))
      }
      "projectile_spawned" -> {
        use proj <- decode.field("projectile", projectile.decoder())
        decode.success(ProjectileSpawned(proj))
      }
      "projectile_destroyed" -> {
        use id <- decode.field("id", decode.int)
        use reason <- decode.field("reason", destroy_reason_decoder())
        decode.success(ProjectileDestroyed(projectile.Id(id), reason))
      }
      "enemy_spawned" -> {
        use enm <- decode.field("enemy", enemy.decoder())
        decode.success(EnemySpawned(enm))
      }
      "enemy_died" -> {
        use id <- decode.field("id", decode.int)
        decode.success(EnemyDied(enemy.Id(id)))
      }
      "player_damaged" -> {
        use player_id <- decode.field("player_id", decode.int)
        use damage <- decode.field("damage", decode.float)
        use new_health <- decode.field("new_health", decode.float)
        decode.success(PlayerDamaged(player.Id(player_id), damage, new_health))
      }
      "pong" -> {
        use client_timestamp <- decode.field("client_timestamp", decode.int)
        use server_timestamp <- decode.field("server_timestamp", decode.int)
        decode.success(Pong(
          timestamp.from_unix_seconds(client_timestamp),
          timestamp.from_unix_seconds(server_timestamp),
        ))
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

fn destroy_reason_decoder() -> decode.Decoder(DestroyReason) {
  use reason_type <- decode.field("type", decode.string)
  case reason_type {
    "hit_enemy" -> {
      use enemy_id <- decode.field("enemy_id", decode.int)
      decode.success(HitEnemy(enemy.Id(enemy_id)))
    }
    "hit_player" -> {
      use player_id <- decode.field("player_id", decode.int)
      decode.success(HitPlayer(player.Id(player_id)))
    }
    "expired" -> decode.success(Expired)
    _ -> decode.failure(Expired, "DestroyReason")
  }
}
