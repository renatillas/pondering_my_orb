import gleam/float
import gleam/int
import gleam/option.{type Option, Some}
import gleam_community/maths
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id
import tiramisu/spritesheet
import vec/vec3.{type Vec3, Vec3}

/// Configuration for enemy spawning
pub type SpawnConfig {
  SpawnConfig(
    player_position: Vec3(Float),
    next_enemy_id: Int,
    enemy1_spritesheet: Option(spritesheet.Spritesheet),
    enemy1_animation: Option(spritesheet.Animation),
    enemy2_spritesheet: Option(spritesheet.Spritesheet),
    enemy2_animation: Option(spritesheet.Animation),
  )
}

/// Spawns a new enemy around the player
pub fn spawn_enemy(config: SpawnConfig) -> Enemy(id.Id) {
  let min_spawn_radius = 10.0
  let max_spawn_radius = 20.0
  let spawn_height = 1.0

  let random_angle = float.random() *. 2.0 *. maths.pi()
  let random_distance =
    min_spawn_radius
    +. { float.random() *. { max_spawn_radius -. min_spawn_radius } }

  let offset_x = maths.cos(random_angle) *. random_distance
  let offset_z = maths.sin(random_angle) *. random_distance

  let spawn_position =
    Vec3(
      config.player_position.x +. offset_x,
      spawn_height,
      config.player_position.z +. offset_z,
    )

  // 15% chance to spawn elite enemy
  let is_elite = float.random() <. 0.15

  // Elite enemies use sprite 2, normal enemies use sprite 1
  let enemy_type = case is_elite {
    True -> enemy.EnemyType2
    False -> enemy.EnemyType1
  }

  // Create enemy
  let new_enemy = case is_elite {
    True ->
      enemy.elite(
        id.enemy(config.next_enemy_id),
        position: spawn_position,
        enemy_type: enemy_type,
      )
    False ->
      enemy.basic(
        id.enemy(config.next_enemy_id),
        position: spawn_position,
        enemy_type: enemy_type,
      )
  }

  // Set spritesheet based on whether elite or not
  case
    is_elite,
    config.enemy1_spritesheet,
    config.enemy1_animation,
    config.enemy2_spritesheet,
    config.enemy2_animation
  {
    // Elite enemies use sprite 2
    True, _, _, Some(sheet), Some(anim) ->
      enemy.set_spritesheet(new_enemy, sheet, anim)
    // Normal enemies use sprite 1
    False, Some(sheet), Some(anim), _, _ ->
      enemy.set_spritesheet(new_enemy, sheet, anim)
    _, _, _, _, _ -> new_enemy
  }
}

/// Checks if spawn interval should decrease
pub fn should_decrease_spawn_interval(
  old_time: Float,
  new_time: Float,
  current_interval: Int,
  threshold: Float,
) -> Bool {
  { float.floor(new_time /. threshold) >. float.floor(old_time /. threshold) }
  && current_interval > 500
}

/// Calculates new spawn interval (decrease by 10%, minimum 500ms)
pub fn calculate_new_interval(current_interval: Int) -> Int {
  int.max(500, current_interval * 90 / 100)
}
