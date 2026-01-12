import gleam/float

// =============================================================================
// TYPES
// =============================================================================

pub type Health {
  Health(current: Float, max: Float)
}

// =============================================================================
// CONSTRUCTORS
// =============================================================================

/// Create a new Health with full health
pub fn new(max: Float) -> Health {
  Health(current: max, max: max)
}

/// Create a Health with specific current and max values
pub fn with_current(current: Float, max: Float) -> Health {
  Health(current: float.clamp(current, min: 0.0, max: max), max: max)
}

// =============================================================================
// OPERATIONS
// =============================================================================

/// Apply damage, reducing current health (clamped to 0)
pub fn damage(health: Health, amount: Float) -> Health {
  Health(..health, current: float.max(0.0, health.current -. amount))
}

/// Heal, increasing current health (clamped to max)
pub fn heal(health: Health, amount: Float) -> Health {
  Health(..health, current: float.min(health.max, health.current +. amount))
}

/// Set current health to max
pub fn restore(health: Health) -> Health {
  Health(..health, current: health.max)
}

// =============================================================================
// QUERIES
// =============================================================================

/// Check if health is depleted (current <= 0)
pub fn is_dead(health: Health) -> Bool {
  health.current <=. 0.0
}

/// Check if health is full
pub fn is_full(health: Health) -> Bool {
  health.current >=. health.max
}

/// Get health as a percentage (0.0 to 1.0)
pub fn percentage(health: Health) -> Float {
  health.current /. health.max
}

/// Get current health value
pub fn current(health: Health) -> Float {
  health.current
}

/// Get max health value
pub fn max(health: Health) -> Float {
  health.max
}
