import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id
import pondering_my_orb/player.{type Player}
import tiramisu/physics
import tiramisu/transform
import vec/vec3.{type Vec3}

/// Updates the physics world with player, enemies, and projectile knockback
pub fn update_physics(
  physics_world: physics.PhysicsWorld(id.Id),
  _player: Player,
  player_velocity: Vec3(Float),
  player_impulse: Vec3(Float),
  enemies: List(Enemy(id.Id)),
  pending_player_knockback: Option(Vec3(Float)),
) -> physics.PhysicsWorld(id.Id) {
  physics_world
  |> physics.set_velocity(id.player(), player_velocity)
  |> physics.apply_impulse(id.player(), player_impulse)
  // Apply pending player knockback AFTER setting velocity
  |> apply_player_knockback(pending_player_knockback)
  // Set velocities for all enemies
  |> apply_enemy_velocities(enemies)
}

/// Applies knockback to the player if pending
fn apply_player_knockback(
  physics_world: physics.PhysicsWorld(id.Id),
  pending_knockback: Option(Vec3(Float)),
) -> physics.PhysicsWorld(id.Id) {
  case pending_knockback {
    Some(knockback) ->
      physics.apply_impulse(physics_world, id.player(), knockback)
    None -> physics_world
  }
}

/// Applies velocities to all enemies
fn apply_enemy_velocities(
  physics_world: physics.PhysicsWorld(id.Id),
  enemies: List(Enemy(id.Id)),
) -> physics.PhysicsWorld(id.Id) {
  list.fold(over: enemies, from: physics_world, with: fn(acc, enemy) {
    physics.set_velocity(acc, enemy.id, enemy.velocity)
  })
}

/// Steps the physics simulation and updates player rotation
pub fn step_physics(
  physics_world: physics.PhysicsWorld(id.Id),
  player_quaternion: transform.Quaternion,
  delta_time: Float,
) -> physics.PhysicsWorld(id.Id) {
  physics_world
  |> physics.step(delta_time)
  // After physics step, manually set the player rotation
  |> update_player_rotation(player_quaternion)
}

/// Updates the player's rotation while keeping physics position
fn update_player_rotation(
  physics_world: physics.PhysicsWorld(id.Id),
  player_quaternion: transform.Quaternion,
) -> physics.PhysicsWorld(id.Id) {
  let player_transform = case
    physics.get_transform(physics_world, id.player())
  {
    Ok(current_transform) -> {
      // Keep physics position, but use player's input rotation
      current_transform
      |> transform.with_quaternion_rotation(player_quaternion)
    }
    Error(_) ->
      transform.at(position: vec3.Vec3(0.0, 0.0, 0.0))
      |> transform.with_quaternion_rotation(player_quaternion)
  }
  physics.update_body_transform(physics_world, id.player(), player_transform)
}

/// Gets the player's position from physics world
pub fn get_player_position(
  physics_world: physics.PhysicsWorld(id.Id),
  fallback: Vec3(Float),
) -> Vec3(Float) {
  physics.get_transform(physics_world, id.player())
  |> result.map(transform.position)
  |> result.unwrap(or: fallback)
}
