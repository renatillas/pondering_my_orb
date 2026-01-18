////
//// Bridge message types for Tiramisu-Lustre communication.
////
//// This module defines the shared message types that flow between the game
//// (Tiramisu) and the UI overlay (Lustre). Messages are bidirectional:
//// - Game → UI: State updates (health, mana, wand info)
//// - UI → Game: User actions (future: slot switching, etc.)
////

import gleam/option.{type Option}

// =============================================================================
// BRIDGE MESSAGES
// =============================================================================

/// Messages that cross the bridge between game and UI
pub type BridgeMsg {
  // Game → UI updates
  UpdateHealth(current: Float, max: Float)
  UpdateMana(current: Float, max: Float)
  UpdateActiveWand(WandInfo)
  // UI → Game actions (future expansion)
  // SwitchWandSlot(Int)
  // CastSpell(Int)
}

// =============================================================================
// UI DATA TYPES
// =============================================================================

/// Information about the active wand to display in UI
pub type WandInfo {
  WandInfo(
    slot_count: Int,
    spells: List(Option(SpellInfo)),
    current_mana: Float,
    max_mana: Float,
    spread: Float,
    cast_delay_ms: Int,
    recharge_time_ms: Int,
    cooldown_progress: Float,
    // 0.0-100.0 percentage of cooldown completed
  )
}

/// Information about a spell to display in spell slot
pub type SpellInfo {
  SpellInfo(name: String, icon_path: String, mana_cost: Float)
}
