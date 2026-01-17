/// Game events that occur during simulation
/// These are broadcasted to clients to keep them synchronized with server state
import gleam/dynamic/decode
import gleam/json
import shared/enemy
import shared/player
import shared/projectile

// =============================================================================
// TYPES
// =============================================================================

/// Events that occur during simulation (for broadcasting to clients)
pub type GameEvent {
  /// A projectile was created
  ProjectileCreated(projectile: projectile.Projectile)
  /// A projectile was destroyed
  ProjectileDestroyed(id: projectile.Id, reason: DestroyReason)
  /// An enemy was spawned
  EnemySpawned(enemy: enemy.Enemy)
  /// An enemy died
  EnemyDied(id: enemy.Id)
  /// A player took damage
  PlayerDamaged(player_id: player.Id, damage: Float, new_health: Float)
}

/// Reason a projectile was destroyed
pub type DestroyReason {
  HitEnemy(enemy_id: enemy.Id)
  HitPlayer(player_id: player.Id)
  Expired
}

// =============================================================================
// JSON ENCODING
// =============================================================================

/// Encode a GameEvent to JSON
pub fn encode(event: GameEvent) -> json.Json {
  case event {
    ProjectileCreated(proj) ->
      json.object([
        #("type", json.string("projectile_created")),
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
  }
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

// =============================================================================
// JSON DECODING
// =============================================================================

/// Decoder for GameEvent from JSON
pub fn decoder() -> decode.Decoder(GameEvent) {
  use event_type <- decode.field("type", decode.string)
  case event_type {
    "projectile_created" -> {
      use proj <- decode.field("projectile", projectile.decoder())
      decode.success(ProjectileCreated(proj))
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

    _ -> decode.failure(EnemyDied(enemy.Id(0)), "GameEvent")
  }
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
