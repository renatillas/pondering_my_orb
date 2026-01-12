/// Networked player state - a subset of the full client state
/// that is synchronized between players in a multiplayer session.
import gleam/dynamic/decode
import gleam/json
import shared/id.{type PlayerId, PlayerId}
import vec/vec3.{type Vec3, Vec3}

/// The networked state of a player that is shared with other players.
pub type PlayerState {
  PlayerState(
    id: PlayerId,
    position: Vec3(Float),
    rotation: Float,
    health: Float,
    max_health: Float,
    active_wand_index: Int,
  )
}

/// Encode a PlayerState to JSON for network transmission.
pub fn encode(state: PlayerState) -> json.Json {
  let PlayerId(player_id) = state.id
  json.object([
    #("id", json.string(player_id)),
    #(
      "position",
      json.object([
        #("x", json.float(state.position.x)),
        #("y", json.float(state.position.y)),
        #("z", json.float(state.position.z)),
      ]),
    ),
    #("rotation", json.float(state.rotation)),
    #("health", json.float(state.health)),
    #("max_health", json.float(state.max_health)),
    #("active_wand_index", json.int(state.active_wand_index)),
  ])
}

/// Decoder for PlayerState from JSON.
pub fn decoder() -> decode.Decoder(PlayerState) {
  use id <- decode.field("id", decode.string)
  use position <- decode.field("position", vec3_decoder())
  use rotation <- decode.field("rotation", decode.float)
  use health <- decode.field("health", decode.float)
  use max_health <- decode.field("max_health", decode.float)
  use active_wand_index <- decode.field("active_wand_index", decode.int)
  decode.success(PlayerState(
    id: PlayerId(id),
    position: position,
    rotation: rotation,
    health: health,
    max_health: max_health,
    active_wand_index: active_wand_index,
  ))
}

/// Decoder for Vec3(Float).
pub fn vec3_decoder() -> decode.Decoder(Vec3(Float)) {
  use x <- decode.field("x", decode.float)
  use y <- decode.field("y", decode.float)
  use z <- decode.field("z", decode.float)
  decode.success(Vec3(x, y, z))
}

/// Encode a Vec3 to JSON.
pub fn encode_vec3(v: Vec3(Float)) -> json.Json {
  json.object([
    #("x", json.float(v.x)),
    #("y", json.float(v.y)),
    #("z", json.float(v.z)),
  ])
}
