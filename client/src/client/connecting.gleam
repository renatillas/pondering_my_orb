/// Connecting Screen - Loading state while joining a room
import gleam/option.{type Option, None}

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(room_id: String, room_name: Option(String), player_name: String)
}

pub type Msg {
  Timeout
}

// =============================================================================
// INIT
// =============================================================================

pub fn init(room_id: String, player_name: String) -> #(Model, Nil) {
  #(Model(room_id: room_id, room_name: None, player_name: player_name), Nil)
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(model: Model, msg: Msg) -> #(Model, Nil) {
  case msg {
    Timeout -> {
      // Handled by parent
      #(model, Nil)
    }
  }
}
