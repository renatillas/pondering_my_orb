////
//// Shared message type for Tiramisu <-> Lustre communication.
////
//// Both sides understand this type and convert it to their internal messages
//// using a wrapper function.
////

import gleam/option.{type Option}
import pondering_my_orb/health
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/spell_bag

/// Wand info for UI display when near an altar
pub type WandDisplayInfo {
  WandDisplayInfo(
    name: String,
    slot_count: Int,
    spells_per_cast: Int,
    cast_delay_ms: Int,
    recharge_time_ms: Int,
    max_mana: Float,
    mana_recharge_rate: Float,
    spread: Float,
    spell_names: List(String),
  )
}

/// Messages that flow between Tiramisu (game) and Lustre (UI).
pub type BridgeMsg {
  // =========================================================================
  // Game → UI: State updates
  // =========================================================================

  /// Full player state update sent from game to UI
  PlayerStateUpdated(
    wand_slots: List(Option(spell.Spell)),
    selected: Option(Int),
    mana: Float,
    max_mana: Float,
    spell_bag: spell_bag.SpellBag,
    health: health.Health,
    wand_names: List(Option(String)),
    active_wand_index: Int,
    altar_nearby: Option(WandDisplayInfo),
  )

  /// Toggle edit mode (I key)
  ToggleEditMode

  // =========================================================================
  // UI → Game: User actions
  // =========================================================================

  /// User clicked on a wand slot
  SelectSlot(Int)

  /// User dragged a spell from bag to slot
  PlaceSpellInSlot(spell.Id, Int)

  /// User removed a spell from slot (dragged to bag)
  RemoveSpellFromSlot(Int)

  /// User reordered wand slots via drag
  ReorderWandSlots(from: Int, to: Int)
}
