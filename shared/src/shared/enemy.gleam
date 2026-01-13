import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}
import shared/health
import shared/player
import shared/vec3 as shared_vec3
import vec/vec3.{type Vec3}

// =============================================================================
// TYPES
// =============================================================================

pub type Enemy {
  Enemy(
    id: Id,
    health: health.Health,
    enemy_type: EnemyType,
    position: Vec3(Float),
    velocity: Vec3(Float),
    target_player: Option(player.Id),
  )
}

pub type EnemyType {
  Zombie
  // More types can be added later: Shooter, Flyer, Boss, etc.
}

pub type Id {
  Id(Int)
}

// =============================================================================
// JSON ENCODING / DECODING
// =============================================================================

/// Encode an Enemy to JSON for network transmission
pub fn encode(enemy: Enemy) -> json.Json {
  let Id(enemy_id) = enemy.id
  let target_id = case enemy.target_player {
    option.Some(player.Id(pid)) -> json.int(pid)
    option.None -> json.null()
  }

  json.object([
    #("id", json.int(enemy_id)),
    #("enemy_type", encode_enemy_type(enemy.enemy_type)),
    #("position", shared_vec3.encode(enemy.position)),
    #("velocity", shared_vec3.encode(enemy.velocity)),
    #("health", health.encode(enemy.health)),
    #("target_player", target_id),
  ])
}

fn encode_enemy_type(enemy_type: EnemyType) -> json.Json {
  case enemy_type {
    Zombie -> json.string("zombie")
  }
}

/// Decoder for Enemy from JSON
pub fn decoder() -> decode.Decoder(Enemy) {
  use id <- decode.field("id", decode.int)
  use enemy_type <- decode.field("enemy_type", enemy_type_decoder())
  use position <- decode.field("position", shared_vec3.decoder())
  use velocity <- decode.field("velocity", shared_vec3.decoder())
  use health <- decode.field("health", health.decoder())
  use target_player <- decode.field(
    "target_player",
    decode.optional(decode.int),
  )

  let target_player_id = case target_player {
    option.Some(pid) -> option.Some(player.Id(pid))
    option.None -> option.None
  }

  decode.success(Enemy(
    id: Id(id),
    enemy_type: enemy_type,
    position: position,
    velocity: velocity,
    health: health,
    target_player: target_player_id,
  ))
}

fn enemy_type_decoder() -> decode.Decoder(EnemyType) {
  use type_str <- decode.then(decode.string)
  case type_str {
    "zombie" -> decode.success(Zombie)
    _ -> decode.failure(Zombie, "EnemyType")
  }
}
