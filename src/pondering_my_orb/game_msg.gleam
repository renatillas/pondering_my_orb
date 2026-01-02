/// Shared message types for bridge communication
/// All game messages go through this type to support the tiramisu-lustre bridge
import gleam/option.{type Option}

import pondering_my_orb/enemy
import pondering_my_orb/game_physics
import pondering_my_orb/health
import pondering_my_orb/magic_system/spell
import pondering_my_orb/map
import pondering_my_orb/player

// =============================================================================
// GAME MESSAGES (sent TO tiramisu game)
// =============================================================================

pub type ToGame {
  /// Player tick - handles movement, casting, projectiles
  PlayerMsg(player.Msg)
  /// Enemy tick - handles spawning, movement, attacks
  EnemyMsg(enemy.Msg)
  /// Wrapped map module messages
  MapMsg(map.Msg)
  /// Physics step messages
  PhysicsMsg(game_physics.Msg)
}

// =============================================================================
// UI MESSAGES (sent TO lustre UI)
// =============================================================================

pub type ToUI {
  /// User clicked a slot in the UI
  SlotClicked(Int)
  /// Game sends player state update (wand + health)
  PlayerStateUpdated(
    wand_slots: List(Option(spell.Spell)),
    selected: Option(Int),
    mana: Float,
    max_mana: Float,
    available_spells: List(spell.Spell),
    health: health.Health,
  )
}
