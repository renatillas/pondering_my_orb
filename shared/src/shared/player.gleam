/// Networked player state - a subset of the full client state
/// that is synchronized between players in a multiplayer session.
import gleam/dynamic/decode
import gleam/json
import shared/health
import shared/id
import shared/vec3 as shared_vec3
import vec/vec3.{type Vec3}

/// The networked state of a player that is shared with other players.
pub type Player {
  Player(
    id: id.Id,
    position: Vec3(Float),
    rotation: Float,
    health: health.Health,
    active_wand_index: Int,
  )
}

/// Encode a PlayerState to JSON for network transmission.
pub fn encode(state: Player) -> json.Json {
  let assert id.Player(player_id) = state.id
  json.object([
    #("id", json.int(player_id)),
    #("position", shared_vec3.encode(state.position)),
    #("rotation", json.float(state.rotation)),
    #("health", json.float(state.health |> health.current)),
    #("max_health", json.float(state.health |> health.max)),
    #("active_wand_index", json.int(state.active_wand_index)),
  ])
}

/// Decoder for PlayerState from JSON.
pub fn decoder() -> decode.Decoder(Player) {
  use id <- decode.field("id", decode.int)
  use position <- decode.field("position", shared_vec3.decoder())
  use rotation <- decode.field("rotation", decode.float)
  use current <- decode.field("health", decode.float)
  use max <- decode.field("max_health", decode.float)
  use active_wand_index <- decode.field("active_wand_index", decode.int)
  decode.success(Player(
    id: id.Player(id),
    position: position,
    rotation: rotation,
    health: health.with_current(current:, max:),
    active_wand_index: active_wand_index,
  ))
}
