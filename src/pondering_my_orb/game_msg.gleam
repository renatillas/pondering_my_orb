/// Shared message types for bridge communication
/// All game messages go through this type to support the tiramisu-lustre bridge
import gleam/option.{type Option}

import pondering_my_orb/magic_system/spell
import pondering_my_orb/map
import pondering_my_orb/player

// =============================================================================
// GAME MESSAGES (sent TO tiramisu game)
// =============================================================================

pub type ToGame {
  /// Player tick - handles movement, casting, projectiles
  PlayerMsg(player.Msg)
  /// Wrapped map module messages
  MapMsg(map.Msg)
  /// Physics step messages
  PhysicsMsg(PhysicsMsg)
}

/// Physics messages for pre/post step hooks
pub type PhysicsMsg {
  /// Before physics runs - apply forces, set velocities here
  PreStep
  /// Physics step executes
  Step
  /// After physics - read collision events, check positions
  PostStep
}

// =============================================================================
// UI MESSAGES (sent TO lustre UI)
// =============================================================================

pub type ToUI {
  /// User clicked a slot in the UI
  SlotClicked(Int)
  /// Game sends wand state update
  WandUpdated(
    wand_slots: List(Option(spell.Spell)),
    selected: Option(Int),
    mana: Float,
    max_mana: Float,
    available_spells: List(spell.Spell),
  )
}
