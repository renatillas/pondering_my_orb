import gleam/dynamic/decode
import gleam/json

// =============================================================================
// TYPES
// =============================================================================

pub type GameState {
  GameState(tick: Int, next_projectile_id: Int, next_enemy_id: Int)
}

// =============================================================================
// CONSTRUCTORS
// =============================================================================

/// Create an empty game state
pub fn new() -> GameState {
  GameState(tick: 0, next_projectile_id: 0, next_enemy_id: 0)
}

// =============================================================================
// JSON ENCODING / DECODING
// =============================================================================

/// Encode a GameState to JSON for network transmission
/// Used for sending full state snapshots
pub fn encode(state: GameState) -> json.Json {
  json.object([
    #("tick", json.int(state.tick)),
    #("next_projectile_id", json.int(state.next_projectile_id)),
    #("next_enemy_id", json.int(state.next_enemy_id)),
  ])
}

/// Decoder for GameState from JSON
pub fn decoder() -> decode.Decoder(GameState) {
  use tick <- decode.field("tick", decode.int)
  use next_projectile_id <- decode.field("next_projectile_id", decode.int)
  use next_enemy_id <- decode.field("next_enemy_id", decode.int)

  decode.success(GameState(
    tick: tick,
    next_projectile_id: next_projectile_id,
    next_enemy_id: next_enemy_id,
  ))
}
