/// Game messages for client-server communication.
/// These messages are serialized as JSON and sent over WebSocket connections.
import gleam/dynamic/decode
import gleam/json
import gleam/result
import shared/damage
import shared/enemy
import shared/id
import shared/player.{type Player}
import shared/projectile
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
  /// Update the player's position and rotation.
  PlayerUpdate(position: vec3.Vec3(Float), rotation: Float)
  /// Update input state (shoot button pressed, aim direction)
  InputUpdate(shoot_pressed: Bool, aim_direction: vec3.Vec3(Float))
  /// Ping the server to measure latency.
  Ping(timestamp: Int)
  /// Request a game tick (client-driven simulation)
  RequestGameTick
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
        #("position", shared_vec3.encode(position)),
        #("rotation", json.float(rotation)),
      ])
    InputUpdate(shoot_pressed, aim_direction) ->
      json.object([
        #("type", json.string("input_update")),
        #("shoot_pressed", json.bool(shoot_pressed)),
        #("aim_direction", shared_vec3.encode(aim_direction)),
      ])
    Ping(timestamp) ->
      json.object([
        #("type", json.string("ping")),
        #("timestamp", json.int(timestamp)),
      ])
    RequestGameTick ->
      json.object([#("type", json.string("request_game_tick"))])
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
        use position <- decode.field("position", shared_vec3.decoder())
        use rotation <- decode.field("rotation", decode.float)
        decode.success(PlayerUpdate(position, rotation))
      }
      "input_update" -> {
        use shoot_pressed <- decode.field("shoot_pressed", decode.bool)
        use aim_direction <- decode.field(
          "aim_direction",
          shared_vec3.decoder(),
        )
        decode.success(InputUpdate(shoot_pressed, aim_direction))
      }
      "ping" -> {
        use timestamp <- decode.field("timestamp", decode.int)
        decode.success(Ping(timestamp))
      }
      "request_game_tick" -> decode.success(RequestGameTick)
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
  RoomJoined(room_id: id.Id, player_id: id.Id, players: List(Player))
  /// A new player has joined the room.
  PlayerJoined(player: Player)
  /// A player has left the room.
  PlayerLeft(player_id: id.Id)
  /// Periodic state update for all players in the room.
  PlayerStates(states: List(Player))
  /// A player has cast a spell.
  SpellCastBroadcast(
    caster_id: id.Id,
    wand_index: Int,
    direction: vec3.Vec3(Float),
  )
  /// Full game state sync (sent on join and periodically for reconciliation).
  FullGameState(
    tick: Int,
    enemies: List(enemy.Enemy),
    projectiles: List(projectile.Projectile),
  )
  /// Incremental game state update (sent every tick).
  GameDelta(
    tick: Int,
    enemy_spawns: List(enemy.Enemy),
    enemy_updates: List(enemy.Delta),
    enemy_deaths: List(Int),
    projectile_spawns: List(projectile.Projectile),
    projectile_removals: List(Int),
    damage_events: List(damage.Damage),
  )
  /// An enemy has spawned (legacy, prefer GameDelta).
  EnemySpawned(enemy_id: Int, position: vec3.Vec3(Float), health: Float)
  /// An enemy has died (legacy, prefer GameDelta).
  EnemyDied(enemy_id: Int, killer_id: id.Id)
  /// Response to a ping.
  Pong(client_timestamp: Int, server_timestamp: Int)
  /// An error has occurred.
  Error(message: String)
}

/// Encode a ServerMessage to JSON string for transmission.
pub fn encode_server_message(msg: ServerMessage) -> String {
  case msg {
    RoomJoined(room_id, player_id, players) -> {
      let assert id.Room(rid) = room_id
      let assert id.Player(pid) = player_id
      json.object([
        #("type", json.string("room_joined")),
        #("room_id", json.int(rid)),
        #("player_id", json.int(pid)),
        #("players", json.array(players, player.encode)),
      ])
    }
    PlayerJoined(player) ->
      json.object([
        #("type", json.string("player_joined")),
        #("player", player.encode(player)),
      ])
    PlayerLeft(player_id) -> {
      let assert id.Player(pid) = player_id
      json.object([
        #("type", json.string("player_left")),
        #("player_id", json.int(pid)),
      ])
    }
    PlayerStates(states) ->
      json.object([
        #("type", json.string("player_states")),
        #("states", json.array(states, player.encode)),
      ])
    SpellCastBroadcast(caster_id, wand_index, direction) -> {
      let assert id.Player(cid) = caster_id
      json.object([
        #("type", json.string("spell_cast_broadcast")),
        #("caster_id", json.int(cid)),
        #("wand_index", json.int(wand_index)),
        #("direction", shared_vec3.encode(direction)),
      ])
    }
    FullGameState(tick, enemies, projectiles) ->
      json.object([
        #("type", json.string("full_game_state")),
        #("tick", json.int(tick)),
        #("enemies", json.array(enemies, enemy.encode)),
        #("projectiles", json.array(projectiles, projectile.encode)),
      ])
    GameDelta(
      tick,
      enemy_spawns,
      enemy_updates,
      enemy_deaths,
      projectile_spawns,
      projectile_removals,
      damage_events,
    ) ->
      json.object([
        #("type", json.string("game_delta")),
        #("tick", json.int(tick)),
        #("enemy_spawns", json.array(enemy_spawns, enemy.encode)),
        #("enemy_updates", json.array(enemy_updates, enemy.encode_update)),
        #("enemy_deaths", json.array(enemy_deaths, json.int)),
        #("projectile_spawns", json.array(projectile_spawns, projectile.encode)),
        #("projectile_removals", json.array(projectile_removals, json.int)),
        #("damage_events", json.array(damage_events, damage.encode)),
      ])
    EnemySpawned(enemy_id, position, health) ->
      json.object([
        #("type", json.string("enemy_spawned")),
        #("enemy_id", json.int(enemy_id)),
        #("position", shared_vec3.encode(position)),
        #("health", json.float(health)),
      ])
    EnemyDied(enemy_id, killer_id) -> {
      let assert id.Player(kid) = killer_id
      json.object([
        #("type", json.string("enemy_died")),
        #("enemy_id", json.int(enemy_id)),
        #("killer_id", json.int(kid)),
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
        use room_id <- decode.field("room_id", decode.int)
        use player_id <- decode.field("player_id", decode.int)
        use players <- decode.field("players", decode.list(player.decoder()))
        decode.success(RoomJoined(
          id.Room(room_id),
          id.Player(player_id),
          players,
        ))
      }
      "player_joined" -> {
        use player <- decode.field("player", player.decoder())
        decode.success(PlayerJoined(player))
      }
      "player_left" -> {
        use player_id <- decode.field("player_id", decode.int)
        decode.success(PlayerLeft(id.Player(player_id)))
      }
      "player_states" -> {
        use states <- decode.field("states", decode.list(player.decoder()))
        decode.success(PlayerStates(states))
      }
      "spell_cast_broadcast" -> {
        use caster_id <- decode.field("caster_id", decode.int)
        use wand_index <- decode.field("wand_index", decode.int)
        use direction <- decode.field("direction", shared_vec3.decoder())
        decode.success(SpellCastBroadcast(
          id.Player(caster_id),
          wand_index,
          direction,
        ))
      }
      "full_game_state" -> {
        use tick <- decode.field("tick", decode.int)
        use enemies <- decode.field("enemies", decode.list(enemy.decoder()))
        use projectiles <- decode.field(
          "projectiles",
          decode.list(projectile.decoder()),
        )
        decode.success(FullGameState(tick, enemies, projectiles))
      }
      "game_delta" -> {
        use tick <- decode.field("tick", decode.int)
        use enemy_spawns <- decode.field(
          "enemy_spawns",
          decode.list(enemy.decoder()),
        )
        use enemy_updates <- decode.field(
          "enemy_updates",
          decode.list(enemy.update_decoder()),
        )
        use enemy_deaths <- decode.field(
          "enemy_deaths",
          decode.list(decode.int),
        )
        use projectile_spawns <- decode.field(
          "projectile_spawns",
          decode.list(projectile.decoder()),
        )
        use projectile_removals <- decode.field(
          "projectile_removals",
          decode.list(decode.int),
        )
        use damage_events <- decode.field(
          "damage_events",
          decode.list(damage.decoder()),
        )
        decode.success(GameDelta(
          tick,
          enemy_spawns,
          enemy_updates,
          enemy_deaths,
          projectile_spawns,
          projectile_removals,
          damage_events,
        ))
      }
      "enemy_spawned" -> {
        use enemy_id <- decode.field("enemy_id", decode.int)
        use position <- decode.field("position", shared_vec3.decoder())
        use health <- decode.field("health", decode.float)
        decode.success(EnemySpawned(enemy_id, position, health))
      }
      "enemy_died" -> {
        use enemy_id <- decode.field("enemy_id", decode.int)
        use killer_id <- decode.field("killer_id", decode.int)
        decode.success(EnemyDied(enemy_id, id.Player(killer_id)))
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
