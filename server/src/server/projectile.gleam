/// ProjectileActor - manages individual projectile state using OTP actor pattern
import gleam/erlang/process.{type Subject}
import gleam/float
import gleam/int
import gleam/otp/actor
import gleam/time/duration.{type Duration}
import logging
import vec/vec3f

import shared/enemy
import shared/projectile

// =============================================================================
// TYPES
// =============================================================================

/// Messages sent TO the projectile actor
pub type Msg {
  /// Tick for movement and lifetime tracking
  Tick(delta_time: Duration)
  /// Hit an enemy (causes projectile to expire)
  Hit(enemy_id: enemy.Id)
}

/// Messages sent FROM projectile actor back to the room
pub type ToRoomMsg {
  /// Projectile state changed (position updated)
  StateChanged(projectile: projectile.Projectile)
  /// Projectile expired (lifetime exceeded or collision)
  Expired(id: projectile.Id)
}

/// Projectile actor state
type State(room_msg) {
  State(
    projectile: projectile.Projectile,
    room: Subject(room_msg),
    to_room: fn(ToRoomMsg) -> room_msg,
  )
}

// =============================================================================
// ACTOR LIFECYCLE
// =============================================================================

pub type SpawnArguments(room_msg) {
  SpawnArguments(
    projectile: projectile.Projectile,
    room: Subject(room_msg),
    to_room: fn(ToRoomMsg) -> room_msg,
  )
}

/// Start a new projectile actor
pub fn start(
  spawn_arguments: SpawnArguments(room_msg),
) -> Result(actor.Started(Subject(Msg)), actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    let state =
      State(
        projectile: spawn_arguments.projectile,
        room: spawn_arguments.room,
        to_room: spawn_arguments.to_room,
      )

    actor.initialised(state)
    |> actor.returning(self)
    |> Ok
  })
  |> actor.on_message(handle_message)
  |> actor.start
}

// =============================================================================
// MESSAGE HANDLING
// =============================================================================

fn handle_message(
  state: State(room_msg),
  msg: Msg,
) -> actor.Next(State(room_msg), Msg) {
  case msg {
    Tick(delta_time) -> handle_tick(state, delta_time)
    Hit(enemy_id) -> handle_hit(state, enemy_id)
  }
}

fn handle_tick(
  state: State(room_msg),
  delta_time: Duration,
) -> actor.Next(State(room_msg), Msg) {
  let dt_seconds = duration.to_seconds(delta_time)

  // 1. Update position based on velocity
  let new_position =
    vec3f.add(
      state.projectile.position,
      vec3f.scale(state.projectile.velocity, by: dt_seconds),
    )

  // 2. Update time_alive
  let new_time_alive = duration.add(state.projectile.time_alive, delta_time)

  // 3. Check if lifetime exceeded
  let lifetime_seconds =
    duration.to_seconds(state.projectile.spell.final_lifetime)
  let time_alive_seconds = duration.to_seconds(new_time_alive)

  case time_alive_seconds >=. lifetime_seconds {
    True -> {
      // Projectile expired - notify room and stop actor
      logging.log(
        logging.Debug,
        "Projectile expired after " <> duration_to_string(new_time_alive),
      )
      process.send(state.room, state.to_room(Expired(state.projectile.id)))
      actor.stop()
    }

    False -> {
      // Update projectile state
      let new_projectile =
        projectile.Projectile(
          ..state.projectile,
          position: new_position,
          time_alive: new_time_alive,
        )

      // Notify room of state change
      process.send(state.room, state.to_room(StateChanged(new_projectile)))

      let new_state = State(..state, projectile: new_projectile)
      actor.continue(new_state)
    }
  }
}

fn handle_hit(
  state: State(room_msg),
  enemy_id: enemy.Id,
) -> actor.Next(State(room_msg), Msg) {
  logging.log(
    logging.Debug,
    "Projectile "
      <> projectile_id_to_string(state.projectile.id)
      <> " hit enemy "
      <> enemy_id_to_string(enemy_id),
  )

  // Notify room that projectile expired
  process.send(state.room, state.to_room(Expired(state.projectile.id)))

  // Stop the actor
  actor.stop()
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

fn projectile_id_to_string(id: projectile.Id) -> String {
  let projectile.Id(n) = id
  int.to_string(n)
}

fn enemy_id_to_string(id: enemy.Id) -> String {
  let enemy.Id(n) = id
  int.to_string(n)
}

fn duration_to_string(dur: Duration) -> String {
  let seconds = duration.to_seconds(dur)
  float.to_string(seconds) <> "s"
}
