/// Shared enemy types for client-server communication.
/// Server-authoritative enemy state that is synchronized over the network.
import gleam/dynamic/decode
import gleam/float
import gleam/json
import gleam/time/duration
import shared/health
import shared/id
import shared/vec3 as shared_vec3
import vec/vec3

const default_enemy_damage = 10.0

const default_enemy_speed = 8.0

/// Core enemy state synchronized between client and server.
/// The server is authoritative for this data.
pub type Enemy {
  Enemy(
    id: id.Id,
    position: vec3.Vec3(Float),
    health: health.Health,
    damage: Float,
    speed: Float,
    attack_cooldown: duration.Duration,
  )
}

/// Lightweight position-only update for enemies (delta sync).
pub type Delta {
  Delta(id: id.Id, position: vec3.Vec3(Float))
}

// ----------------------------------------------------------------------------
// JSON Encoding
// ----------------------------------------------------------------------------

/// Encode an Enemy to JSON for network transmission.
pub fn encode(enemy: Enemy) -> json.Json {
  json.object([
    #("id", json.string(enemy.id |> id.to_string)),
    #("position", shared_vec3.encode(enemy.position)),
    #("health", json.float(enemy.health |> health.current)),
    #("max_health", json.float(enemy.health |> health.max)),
    #("damage", json.float(enemy.damage)),
    #("speed", json.float(enemy.speed)),
    #(
      "attack_cooldown",
      json.float(enemy.attack_cooldown |> duration.to_seconds),
    ),
  ])
}

/// Encode an EnemyUpdate to JSON for network transmission.
pub fn encode_update(update: Delta) -> json.Json {
  json.object([
    #("id", json.int(update.id |> id.to_serial)),
    #("position", shared_vec3.encode(update.position)),
  ])
}

// ----------------------------------------------------------------------------
// JSON Decoding
// ----------------------------------------------------------------------------

/// Decoder for Enemy from JSON.
pub fn decoder() -> decode.Decoder(Enemy) {
  use id <- decode.field("id", decode.string)
  use position <- decode.field("position", shared_vec3.decoder())
  use current <- decode.field("health", decode.float)
  use max <- decode.field("max_health", decode.float)
  use damage <- decode.field("damage", decode.float)
  use speed <- decode.field("speed", decode.float)
  use attack_cooldown <- decode.field("attack_cooldown", decode.float)
  decode.success(Enemy(
    id |> id.from_string,
    position,
    health.with_current(current:, max:),
    damage,
    speed,
    duration.seconds(float.round(attack_cooldown)),
  ))
}

/// Decoder for EnemyUpdate from JSON.
pub fn update_decoder() -> decode.Decoder(Delta) {
  use id <- decode.field("id", decode.int)
  use position <- decode.field("position", shared_vec3.decoder())
  decode.success(Delta(id.Enemy(id), position))
}

pub fn new(id) {
  Enemy(
    id:,
    position: vec3.Vec3(0.0, 0.0, 0.0),
    health: health.with_current(100.0, 100.0),
    damage: default_enemy_damage,
    speed: default_enemy_speed,
    attack_cooldown: duration.seconds(1),
  )
}
