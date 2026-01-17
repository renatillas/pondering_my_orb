/// Fixed tick rate scheduler for server-authoritative gameplay.
/// Runs at 20 Hz (50ms per tick) for deterministic game simulation.
import gleam/int
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

/// Get the current tick number
pub fn current(scheduler: TickScheduler) -> Int {
  scheduler.current_tick
}

/// Get the tick duration for physics calculations
pub fn delta_time(scheduler: TickScheduler) -> duration.Duration {
  scheduler.last_tick_time
  |> timestamp.difference(timestamp.system_time())
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
