import gleam/time/timestamp
import gleeunit
import server/tick

pub fn main() {
  gleeunit.main()
}

pub fn placeholder_test() {
  let assert 1 = 1
}

pub fn instant_tick_returns_tick_duration_test() {
  let scheduler = tick.new(timestamp.from_unix_seconds_and_nanoseconds(0, 0))

  assert tick.tick_duration_ms
    == tick.next(scheduler, timestamp.from_unix_seconds_and_nanoseconds(0, 0))
}

pub fn half_tick_returns_half_tick_duration_test() {
  let scheduler = tick.new(timestamp.from_unix_seconds_and_nanoseconds(0, 0))
  let half_tick = tick.tick_duration_ms / 2

  assert half_tick
    == tick.next(
      scheduler,
      timestamp.from_unix_seconds_and_nanoseconds(0, half_tick * 1_000_000),
    )
}

pub fn full_tick_returns_zero_duration_test() {
  let scheduler = tick.new(timestamp.from_unix_seconds_and_nanoseconds(0, 0))
  let full_tick = tick.tick_duration_ms
  assert 0
    == tick.next(
      scheduler,
      timestamp.from_unix_seconds_and_nanoseconds(0, full_tick * 1_000_000),
    )
}

pub fn more_than_full_tick_returns_zero_duration_test() {
  let scheduler = tick.new(timestamp.from_unix_seconds_and_nanoseconds(0, 0))
  let full_tick = tick.tick_duration_ms + 100

  assert 0
    == tick.next(
      scheduler,
      timestamp.from_unix_seconds_and_nanoseconds(0, full_tick * 1_000_000),
    )
}
