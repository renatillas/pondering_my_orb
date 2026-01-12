import gleam/dynamic/decode
import gleam/json
import gleam/option
import shared/id

/// Damage event for UI feedback.
pub type Damage {
  Damage(
    enemy_id: Int,
    damage: Float,
    remaining_health: Float,
    source_player_id: option.Option(id.Id),
  )
}

// Encoders for game state types

pub fn encode(event: Damage) -> json.Json {
  json.object([
    #("enemy_id", json.int(event.enemy_id)),
    #("damage", json.float(event.damage)),
    #("remaining_health", json.float(event.remaining_health)),
    #("source_player_id", case event.source_player_id {
      option.Some(id.Player(pid)) -> json.int(pid)
      _ -> json.null()
    }),
  ])
}

// Decoders for game state types

pub fn decoder() -> decode.Decoder(Damage) {
  use enemy_id <- decode.field("enemy_id", decode.int)
  use damage <- decode.field("damage", decode.float)
  use remaining_health <- decode.field("remaining_health", decode.float)
  use source_player_id <- decode.field(
    "source_player_id",
    decode.optional(decode.int),
  )
  decode.success(Damage(
    enemy_id,
    damage,
    remaining_health,
    option.map(source_player_id, id.Player),
  ))
}
