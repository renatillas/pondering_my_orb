/// Fixed tick rate scheduler for server-authoritative gameplay.
/// Runs at 20 Hz (50ms per tick) for deterministic game simulation.
import gleam/time/duration
import gleam/time/timestamp

// =============================================================================
// CONSTANTS
// =============================================================================

/// Server tick rate in Hz (ticks per second)
pub const tick_rate_hz = 20

/// Duration of one tick in milliseconds
pub const tick_duration_ms = 50

// =============================================================================
// TYPES
// =============================================================================

pub type TickScheduler {
  TickScheduler(current_tick: Int, last_tick_time: timestamp.Timestamp)
}

// =============================================================================
// FUNCTIONS
// =============================================================================

/// Create a new tick scheduler
pub fn new() -> TickScheduler {
  TickScheduler(current_tick: 0, last_tick_time: timestamp.system_time())
}

/// Advance to the next tick
pub fn advance_tick(scheduler: TickScheduler) -> TickScheduler {
  TickScheduler(
    current_tick: scheduler.current_tick + 1,
    last_tick_time: timestamp.system_time(),
  )
}

/// Get the current tick number
pub fn current_tick(scheduler: TickScheduler) -> Int {
  scheduler.current_tick
}

/// Get the tick duration for physics calculations
pub fn get_delta_time() -> duration.Duration {
  duration.milliseconds(tick_duration_ms)
}

/// Calculate when the next tick should occur (in milliseconds from now)
pub fn next_tick_delay_ms() -> Int {
  tick_duration_ms
}
