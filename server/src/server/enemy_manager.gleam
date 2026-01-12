/// Server-side enemy spawning and movement logic.
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/time/duration
import gleam_community/maths
import server/game_state
import shared/enemy
import shared/health
import shared/id
import vec/vec3

/// Result of updating enemy spawning
pub type SpawnResult {
  SpawnResult(
    state: game_state.GameState,
    spawned_enemy: option.Option(enemy.Enemy),
  )
}

/// Update enemy spawning based on timer
pub fn update_spawning(
  state: game_state.GameState,
  player_positions: List(vec3.Vec3(Float)),
  dt: Float,
) -> SpawnResult {
  // Don't spawn if no players
  case player_positions {
    [] -> SpawnResult(state: state, spawned_enemy: option.None)
    _ -> {
      // Accumulate spawn timer (dt is in seconds, spawn_timer is in milliseconds)
      let new_spawn_timer = state.spawn_timer +. dt *. 1000.0

      // Check if it's time to spawn
      case new_spawn_timer >=. state.config.spawn_interval {
        True -> {
          // Reset spawn timer
          let state_with_timer = game_state.GameState(..state, spawn_timer: 0.0)

          // Pick a random player to spawn near
          case pick_random_position(player_positions) {
            option.Some(target_pos) -> {
              let #(new_state, enemy_spawned) =
                spawn_enemy(state_with_timer, target_pos)
              SpawnResult(
                state: new_state,
                spawned_enemy: option.Some(enemy_spawned),
              )
            }
            option.None ->
              SpawnResult(state: state_with_timer, spawned_enemy: option.None)
          }
        }
        False ->
          SpawnResult(
            state: game_state.GameState(..state, spawn_timer: new_spawn_timer),
            spawned_enemy: option.None,
          )
      }
    }
  }
}

/// Spawn a new enemy near the given position
fn spawn_enemy(
  state: game_state.GameState,
  near_position: vec3.Vec3(Float),
) -> #(game_state.GameState, enemy.Enemy) {
  let config = state.config

  // Random angle around the player
  let angle = float.random() *. 2.0 *. maths.pi()

  // Random distance between min and max
  let distance =
    config.spawn_distance_min
    +. float.random()
    *. { config.spawn_distance_max -. config.spawn_distance_min }
    *. { config.spawn_distance_max -. config.spawn_distance_min }

  // Calculate position
  let vec3.Vec3(px, _, pz) = near_position
  let x = px +. maths.cos(angle) *. distance
  let z = pz +. maths.sin(angle) *. distance

  // Clamp to arena bounds
  let clamped_x = float.min(config.arena_max, float.max(config.arena_min, x))
  let clamped_z = float.min(config.arena_max, float.max(config.arena_min, z))

  // Create enemy
  let spawned_enemy =
    enemy.Enemy(
      id: id.Enemy(state.next_enemy_id),
      position: vec3.Vec3(clamped_x, 1.0, clamped_z),
      health: health.new(config.enemy_health),
      damage: config.enemy_damage,
      speed: config.enemy_speed,
      attack_cooldown: duration.seconds(0),
    )

  // Add to game state
  let new_state =
    game_state.GameState(
      ..state,
      enemies: dict.insert(state.enemies, spawned_enemy.id, spawned_enemy),
      next_enemy_id: state.next_enemy_id + 1,
    )

  #(new_state, spawned_enemy)
}

/// Update enemy movement toward nearest player
pub fn update_movement(
  state: game_state.GameState,
  player_positions: List(vec3.Vec3(Float)),
  dt: Float,
) -> game_state.GameState {
  case player_positions {
    [] -> state
    _ -> {
      // Update all enemies
      let new_enemies =
        dict.map_values(state.enemies, fn(_enemy_id, enemy_item) {
          move_enemy_toward_nearest_player(
            enemy_item,
            player_positions,
            state.config.arena_min,
            state.config.arena_max,
            state.config.enemy_attack_range,
            dt,
          )
        })

      game_state.GameState(..state, enemies: new_enemies)
    }
  }
}

/// Move a single enemy toward the nearest player
fn move_enemy_toward_nearest_player(
  enemy_item: enemy.Enemy,
  player_positions: List(vec3.Vec3(Float)),
  arena_min: Float,
  arena_max: Float,
  attack_range: Float,
  dt: Float,
) -> enemy.Enemy {
  // Find nearest player
  case find_nearest_position(enemy_item.position, player_positions) {
    option.None -> enemy_item
    option.Some(#(nearest_pos, nearest_dist)) -> {
      // Move toward player if outside attack range
      case nearest_dist >. attack_range {
        False -> enemy_item
        True -> {
          let vec3.Vec3(ex, ey, ez) = enemy_item.position
          let vec3.Vec3(px, _, pz) = nearest_pos

          let dx = px -. ex
          let dz = pz -. ez

          // Normalize direction
          case nearest_dist >. 0.0 {
            False -> enemy_item
            True -> {
              let dir_x = dx /. nearest_dist
              let dir_z = dz /. nearest_dist

              // Apply movement
              let new_x = ex +. dir_x *. enemy_item.speed *. dt
              let new_z = ez +. dir_z *. enemy_item.speed *. dt

              // Clamp to arena
              let clamped_x = float.min(arena_max, float.max(arena_min, new_x))
              let clamped_z = float.min(arena_max, float.max(arena_min, new_z))

              enemy.Enemy(
                ..enemy_item,
                position: vec3.Vec3(clamped_x, ey, clamped_z),
              )
            }
          }
        }
      }
    }
  }
}

/// Find the nearest position from a list of positions
fn find_nearest_position(
  from: vec3.Vec3(Float),
  positions: List(vec3.Vec3(Float)),
) -> option.Option(#(vec3.Vec3(Float), Float)) {
  case positions {
    [] -> option.None
    [first, ..rest] -> {
      let first_dist = distance_2d(from, first)
      find_nearest_helper(from, rest, first, first_dist)
      |> option.Some
    }
  }
}

/// Helper for finding nearest position
fn find_nearest_helper(
  from: vec3.Vec3(Float),
  positions: List(vec3.Vec3(Float)),
  current_nearest: vec3.Vec3(Float),
  current_dist: Float,
) -> #(vec3.Vec3(Float), Float) {
  case positions {
    [] -> #(current_nearest, current_dist)
    [pos, ..rest] -> {
      let dist = distance_2d(from, pos)
      case dist <. current_dist {
        True -> find_nearest_helper(from, rest, pos, dist)
        False -> find_nearest_helper(from, rest, current_nearest, current_dist)
      }
    }
  }
}

/// Calculate 2D distance between two Vec3 positions (ignoring Y)
fn distance_2d(a: vec3.Vec3(Float), b: vec3.Vec3(Float)) -> Float {
  let vec3.Vec3(ax, _, az) = a
  let vec3.Vec3(bx, _, bz) = b
  let dx = bx -. ax
  let dz = bz -. az
  let assert Ok(distance) = float.square_root(dx *. dx +. dz *. dz)
  distance
}

/// Pick a random position from a list
fn pick_random_position(
  positions: List(vec3.Vec3(Float)),
) -> option.Option(vec3.Vec3(Float)) {
  let len = list.length(positions)
  case len {
    0 -> option.None
    _ -> {
      let index = float.truncate(float.random() *. int.to_float(len))
      pick_at_index(positions, index)
    }
  }
}

/// Get element at index from list
fn pick_at_index(
  positions: List(vec3.Vec3(Float)),
  index: Int,
) -> option.Option(vec3.Vec3(Float)) {
  pick_at_index_helper(positions, index, 0)
}

fn pick_at_index_helper(
  positions: List(vec3.Vec3(Float)),
  target: Int,
  current: Int,
) -> option.Option(vec3.Vec3(Float)) {
  case positions {
    [] -> option.None
    [first, ..] if current == target -> option.Some(first)
    [_, ..rest] -> pick_at_index_helper(rest, target, current + 1)
  }
}
