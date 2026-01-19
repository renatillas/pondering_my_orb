/// Room information types for multi-room support.
/// Contains the RoomInfo type and RoomStatus enum for tracking game rooms.
import gleam/dynamic/decode
import gleam/json
import gleam/time/timestamp

// =============================================================================
// TYPES
// =============================================================================

/// Information about a game room
pub type RoomInfo {
  RoomInfo(
    id: String,
    name: String,
    player_count: Int,
    max_players: Int,
    status: RoomStatus,
    created_at: timestamp.Timestamp,
  )
}

/// Status of a game room
pub type RoomStatus {
  /// Room is waiting for players (< 2 players)
  Waiting
  /// Room has active gameplay (2+ players)
  Active
}

// =============================================================================
// JSON ENCODING
// =============================================================================

/// Encode RoomInfo to JSON
pub fn encode(info: RoomInfo) -> json.Json {
  json.object([
    #("id", json.string(info.id)),
    #("name", json.string(info.name)),
    #("player_count", json.int(info.player_count)),
    #("max_players", json.int(info.max_players)),
    #("status", encode_status(info.status)),
    #(
      "created_at",
      json.int(timestamp.to_unix_seconds_and_nanoseconds(info.created_at).0),
    ),
  ])
}

/// Encode RoomStatus to JSON
pub fn encode_status(status: RoomStatus) -> json.Json {
  case status {
    Waiting -> json.string("waiting")
    Active -> json.string("active")
  }
}

// =============================================================================
// JSON DECODING
// =============================================================================

/// Decoder for RoomInfo
pub fn decoder() -> decode.Decoder(RoomInfo) {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)
  use player_count <- decode.field("player_count", decode.int)
  use max_players <- decode.field("max_players", decode.int)
  use status <- decode.field("status", status_decoder())
  use created_at_seconds <- decode.field("created_at", decode.int)

  decode.success(RoomInfo(
    id: id,
    name: name,
    player_count: player_count,
    max_players: max_players,
    status: status,
    created_at: timestamp.from_unix_seconds(created_at_seconds),
  ))
}

/// Decoder for RoomStatus
pub fn status_decoder() -> decode.Decoder(RoomStatus) {
  decode.then(decode.string, fn(status_str) {
    case status_str {
      "waiting" -> decode.success(Waiting)
      "active" -> decode.success(Active)
      _ -> decode.failure(Waiting, "RoomStatus")
    }
  })
}
