import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}
import shared/health
import shared/vec3 as shared_vec3
import shared/wand
import vec/vec3.{type Vec3}

// =============================================================================
// TYPES
// =============================================================================

pub type Player {
  Player(
    id: Id,
    name: String,
    position: Vec3(Float),
    rotation: Float,
    health: health.Health,
    active_wand_slot: Int,
    movement_state: MovementState,
    speed: Float,
  )
}

pub type WandInventory {
  WandInventory(
    slot_0: Option(wand.Wand),
    slot_1: Option(wand.Wand),
    slot_2: Option(wand.Wand),
    slot_3: Option(wand.Wand),
  )
}

pub type MovementState {
  Idle
  MovingToPosition(target: Vec3(Float), speed: Float)
}

pub type Id {
  Id(Int)
}

// =============================================================================
// CONSTRUCTORS
// =============================================================================

/// Create a new player with default values
pub fn new(id: Id, name: String, position: Vec3(Float)) -> Player {
  Player(
    id: id,
    name: name,
    position: position,
    rotation: 0.0,
    health: health.new(100.0),
    active_wand_slot: 0,
    movement_state: Idle,
    speed: 10.0,
  )
}

// =============================================================================
// JSON ENCODING / DECODING
// =============================================================================

/// Encode a Player to JSON for network transmission.
pub fn encode(state: Player) -> json.Json {
  let Id(player_id) = state.id
  json.object([
    #("id", json.int(player_id)),
    #("name", json.string(state.name)),
    #("position", shared_vec3.encode(state.position)),
    #("rotation", json.float(state.rotation)),
    #("health", health.encode(state.health)),
    #("active_wand_slot", json.int(state.active_wand_slot)),
    #("movement_state", encode_movement_state(state.movement_state)),
    #("speed", json.float(state.speed)),
  ])
}

/// Decoder for Player from JSON.
pub fn decoder() -> decode.Decoder(Player) {
  use id <- decode.field("id", decode.int)
  use name <- decode.field("name", decode.string)
  use position <- decode.field("position", shared_vec3.decoder())
  use rotation <- decode.field("rotation", decode.float)
  use health <- decode.field("health", health.decoder())
  use active_wand_slot <- decode.field("active_wand_slot", decode.int)
  use movement_state <- decode.field("movement_state", movement_state_decoder())
  use speed <- decode.field("speed", decode.float)
  decode.success(Player(
    id: Id(id),
    name:,
    position:,
    rotation:,
    health:,
    active_wand_slot:,
    movement_state:,
    speed:,
  ))
}

// =============================================================================
// HELPER ENCODERS / DECODERS
// =============================================================================

fn encode_movement_state(state: MovementState) -> json.Json {
  case state {
    Idle -> json.object([#("type", json.string("idle"))])
    MovingToPosition(target, speed) ->
      json.object([
        #("type", json.string("moving")),
        #("target", shared_vec3.encode(target)),
        #("speed", json.float(speed)),
      ])
  }
}

fn movement_state_decoder() -> decode.Decoder(MovementState) {
  use state_type <- decode.field("type", decode.string)
  case state_type {
    "idle" -> decode.success(Idle)
    "moving" -> {
      use target <- decode.field("target", shared_vec3.decoder())
      use speed <- decode.field("speed", decode.float)
      decode.success(MovingToPosition(target, speed))
    }
    _ -> decode.failure(Idle, "MovementState")
  }
}

pub fn move_to_position(
  player: Player,
  target: Vec3(Float),
  speed: Float,
) -> Player {
  Player(..player, movement_state: MovingToPosition(target, speed))
}
