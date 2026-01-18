/// Fixed tick rate scheduler for server-authoritative gameplay.
/// Runs at 60 Hz (~16.67ms per tick) for smooth, responsive gameplay.
import gleam/int
import gleam/time/duration
import gleam/time/timestamp

// =============================================================================
// CONSTANTS
// =============================================================================

/// Server tick rate in Hz (ticks per second - actual: 62.5Hz)
pub const tick_rate_hz = 60

/// Duration of one tick in milliseconds (16ms for clean division)
pub const tick_duration_ms = 16

// =============================================================================
// TYPES
// =============================================================================

pub opaque type TickScheduler {
  TickScheduler(current_tick: Int, last_tick_time: timestamp.Timestamp)
}

// =============================================================================
// FUNCTIONS
// =============================================================================

/// Create a new tick scheduler
pub fn new(now) -> TickScheduler {
  TickScheduler(current_tick: 0, last_tick_time: now)
}

/// Advance to the next tick
pub fn advance(scheduler: TickScheduler) -> TickScheduler {
  TickScheduler(
    current_tick: scheduler.current_tick + 1,
    last_tick_time: timestamp.system_time(),
  )
}

/// Advance to the next tick with a specific timestamp (prevents drift)
pub fn advance_with_time(
  scheduler: TickScheduler,
  now: timestamp.Timestamp,
) -> TickScheduler {
  TickScheduler(current_tick: scheduler.current_tick + 1, last_tick_time: now)
}

/// Update the last tick time to current time (for finalize)
pub fn update_time(scheduler: TickScheduler) -> TickScheduler {
  TickScheduler(..scheduler, last_tick_time: timestamp.system_time())
}

/// Get the current tick number
pub fn current(scheduler: TickScheduler) -> Int {
  scheduler.current_tick
}

/// Get the tick duration for physics calculations
/// Always returns the fixed tick duration (16ms) for deterministic simulation
pub fn delta_time(_scheduler: TickScheduler) -> duration.Duration {
  duration.milliseconds(tick_duration_ms)
}

/// Calculate when the next tick should occur (in milliseconds from now)
pub fn next(scheduler: TickScheduler, now: timestamp.Timestamp) -> Int {
  scheduler.last_tick_time
  |> timestamp.add(duration.milliseconds(tick_duration_ms))
  |> timestamp.difference(now)
  |> fn(duration) {
    let #(seconds, nanoseconds) = duration.to_seconds_and_nanoseconds(duration)
    { -seconds * 1000 } + { -nanoseconds / 1_000_000 }
  }
  |> int.clamp(min: 0, max: tick_duration_ms)
}
