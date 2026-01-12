/// Server-side game state for authoritative multiplayer.
/// This module manages enemies, projectiles, and game tick timing.
import gleam/dict
import gleam/int
import gleam/list
import shared/enemy.{type Enemy}
import shared/id
import shared/projectile.{type Projectile}

/// Game configuration
pub type GameConfig {
  GameConfig(
    // Enemy spawning
    spawn_interval: Float,
    // milliseconds
    spawn_distance_min: Float,
    spawn_distance_max: Float,
    arena_min: Float,
    arena_max: Float,
    // Enemy stats
    enemy_health: Float,
    enemy_damage: Float,
    enemy_speed: Float,
    enemy_attack_range: Float,
    // Projectile defaults
    default_projectile_speed: Float,
    default_projectile_damage: Float,
    default_projectile_size: Float,
    default_projectile_lifetime: Float,
  )
}

/// Main game state
pub type GameState {
  GameState(
    tick: Int,
    last_tick_time: Int,
    // milliseconds
    enemies: dict.Dict(id.Id, Enemy),
    next_enemy_id: Int,
    spawn_timer: Float,
    // milliseconds
    projectiles: dict.Dict(Int, Projectile),
    next_projectile_id: Int,
    config: GameConfig,
  )
}

/// Initialize a new game state with default configuration
pub fn init() -> GameState {
  GameState(
    tick: 0,
    last_tick_time: current_timestamp(),
    enemies: dict.new(),
    next_enemy_id: 1,
    spawn_timer: 0.0,
    projectiles: dict.new(),
    next_projectile_id: 1,
    config: default_config(),
  )
}

/// Default game configuration
pub fn default_config() -> GameConfig {
  GameConfig(
    spawn_interval: 2000.0,
    spawn_distance_min: 15.0,
    spawn_distance_max: 30.0,
    arena_min: -70.0,
    arena_max: 70.0,
    enemy_health: 10.0,
    enemy_damage: 10.0,
    enemy_speed: 8.0,
    enemy_attack_range: 2.0,
    default_projectile_speed: 5.0,
    // Slow speed for debugging visibility
    default_projectile_damage: 3.0,
    default_projectile_size: 3.0,
    // Large size for debugging visibility
    default_projectile_lifetime: 5000.0,
    // Long lifetime for debugging
  )
}

/// Reset game state (e.g., when all players leave)
pub fn reset(state: GameState) -> GameState {
  GameState(
    ..state,
    tick: 0,
    last_tick_time: current_timestamp(),
    enemies: dict.new(),
    next_enemy_id: 1,
    spawn_timer: 0.0,
    projectiles: dict.new(),
    next_projectile_id: 1,
  )
}

/// Get delta time since last tick and increment tick counter
pub fn get_delta_time(state: GameState) -> #(GameState, Float) {
  let now = current_timestamp()
  let dt = int.to_float(now - state.last_tick_time) /. 1000.0
  let new_state = GameState(..state, last_tick_time: now, tick: state.tick + 1)
  #(new_state, dt)
}

/// Get all enemies
pub fn get_enemy_states(state: GameState) -> List(Enemy) {
  dict.values(state.enemies)
}

/// Get all projectiles
pub fn get_projectile_states(state: GameState) -> List(Projectile) {
  dict.values(state.projectiles)
}

/// Get all enemy position updates
pub fn get_enemy_updates(state: GameState) -> List(enemy.Delta) {
  dict.values(state.enemies)
  |> list.map(fn(e) { enemy.Delta(id: e.id, position: e.position) })
}

/// Clamp a float value between min and max
/// Get current timestamp in milliseconds
@external(javascript, "../server_ffi.mjs", "getCurrentTimestamp")
fn current_timestamp() -> Int
