/// EnemyActor - manages individual enemy state using OTP actor pattern
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/time/duration.{type Duration}
import logging
import vec/vec3.{type Vec3}
import vec/vec3f

import shared/enemy
import shared/health
import shared/player

// =============================================================================
// TYPES
// =============================================================================

/// Messages sent TO the enemy actor
pub type Msg {
  /// Tick for AI movement and updates
  Tick(delta_time: Duration, nearby_players: Dict(player.Id, Vec3(Float)))
  /// Take damage from a projectile or player
  TakeDamage(amount: Float)
}

/// Messages sent FROM enemy actor back to the room
pub type ToRoomMsg {
  /// Enemy state changed (position, health updated)
  StateChanged(enemy: enemy.Enemy)
  /// Enemy died (health depleted)
  Died(id: enemy.Id)
}

/// Enemy actor state
type State(room_msg) {
  State(
    enemy: enemy.Enemy,
    room: Subject(room_msg),
    to_room: fn(ToRoomMsg) -> room_msg,
  )
}

// =============================================================================
// ACTOR LIFECYCLE
// =============================================================================

pub type SpawnArguments(room_msg) {
  SpawnArguments(
    enemy: enemy.Enemy,
    room: Subject(room_msg),
    to_room: fn(ToRoomMsg) -> room_msg,
  )
}

/// Start a new enemy actor
pub fn start(
  spawn_arguments: SpawnArguments(room_msg),
) -> Result(actor.Started(Subject(Msg)), actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    let state =
      State(
        enemy: spawn_arguments.enemy,
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
    Tick(delta_time, nearby_players) ->
      handle_tick(state, delta_time, nearby_players)
    TakeDamage(amount) -> handle_take_damage(state, amount)
  }
}

fn handle_tick(
  state: State(room_msg),
  delta_time: Duration,
  nearby_players: Dict(player.Id, Vec3(Float)),
) -> actor.Next(State(room_msg), Msg) {
  // 1. Update AI behavior based on enemy type
  let new_enemy = case state.enemy.enemy_type {
    enemy.Zombie -> update_zombie_ai(state.enemy, delta_time, nearby_players)
  }

  // 2. Notify room of state change
  process.send(state.room, state.to_room(StateChanged(new_enemy)))

  let new_state = State(..state, enemy: new_enemy)
  actor.continue(new_state)
}

fn handle_take_damage(
  state: State(room_msg),
  amount: Float,
) -> actor.Next(State(room_msg), Msg) {
  // Apply damage to health
  let new_health = health.damage(state.enemy.health, amount)

  logging.log(
    logging.Debug,
    "Enemy "
      <> enemy_id_to_string(state.enemy.id)
      <> " took "
      <> float.to_string(amount)
      <> " damage. Health: "
      <> float.to_string(health.current(new_health))
      <> "/"
      <> float.to_string(health.max(new_health)),
  )

  // Check if dead
  case health.is_dead(new_health) {
    True -> {
      logging.log(
        logging.Info,
        "Enemy " <> enemy_id_to_string(state.enemy.id) <> " died",
      )
      process.send(state.room, state.to_room(Died(state.enemy.id)))
      actor.stop()
    }

    False -> {
      let new_enemy = enemy.Enemy(..state.enemy, health: new_health)
      process.send(state.room, state.to_room(StateChanged(new_enemy)))
      let new_state = State(..state, enemy: new_enemy)
      actor.continue(new_state)
    }
  }
}

// =============================================================================
// AI BEHAVIOR
// =============================================================================

/// Zombie AI: Move toward the nearest player
fn update_zombie_ai(
  enemy_state: enemy.Enemy,
  delta_time: Duration,
  nearby_players: Dict(player.Id, Vec3(Float)),
) -> enemy.Enemy {
  let dt_seconds = duration.to_seconds(delta_time)

  // Find nearest player
  case find_nearest_player(enemy_state.position, nearby_players) {
    option.None -> {
      // No players nearby - stand still
      enemy.Enemy(
        ..enemy_state,
        velocity: vec3.Vec3(0.0, 0.0, 0.0),
        target_player: option.None,
      )
    }

    option.Some(#(player_id, player_pos)) -> {
      // Move toward player ONLY in horizontal plane (XZ)
      // Keep Y constant at 0.9 (ground level)
      let enemy_pos_2d =
        vec3.Vec3(enemy_state.position.x, 0.0, enemy_state.position.z)
      let player_pos_2d = vec3.Vec3(player_pos.x, 0.0, player_pos.z)

      let direction_2d = vec3f.direction(enemy_pos_2d, to: player_pos_2d)
      let zombie_speed = 2.0
      // Units per second

      // Calculate new position (only move in XZ, keep Y=0.9)
      let movement = vec3f.scale(direction_2d, by: zombie_speed *. dt_seconds)
      let new_position_2d = vec3f.add(enemy_pos_2d, movement)
      let new_position = vec3.Vec3(new_position_2d.x, 0.9, new_position_2d.z)

      // Set velocity for client-side interpolation (horizontal only)
      let velocity = vec3f.scale(direction_2d, by: zombie_speed)

      enemy.Enemy(
        ..enemy_state,
        position: new_position,
        velocity: velocity,
        target_player: option.Some(player_id),
      )
    }
  }
}

/// Find the nearest player to the enemy
fn find_nearest_player(
  enemy_pos: Vec3(Float),
  players: Dict(player.Id, Vec3(Float)),
) -> option.Option(#(player.Id, Vec3(Float))) {
  dict.to_list(players)
  |> list.fold(option.None, fn(nearest, player) {
    let #(player_id, player_pos) = player
    let distance = vec3f.distance(enemy_pos, with: player_pos)

    case nearest {
      option.None -> option.Some(#(player_id, player_pos))
      option.Some(#(_nearest_id, nearest_pos)) -> {
        let nearest_distance = vec3f.distance(enemy_pos, with: nearest_pos)
        case distance <. nearest_distance {
          True -> option.Some(#(player_id, player_pos))
          False -> nearest
        }
      }
    }
  })
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

fn enemy_id_to_string(id: enemy.Id) -> String {
  let enemy.Id(n) = id
  int.to_string(n)
}

/// Create a new zombie enemy at a position
pub fn new_zombie(id: enemy.Id, position: Vec3(Float)) -> enemy.Enemy {
  enemy.Enemy(
    id: id,
    health: health.new(50.0),
    enemy_type: enemy.Zombie,
    position: position,
    velocity: vec3.Vec3(0.0, 0.0, 0.0),
    target_player: option.None,
  )
}
