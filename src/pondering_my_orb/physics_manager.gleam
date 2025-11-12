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
/// Returns: #(updated_physics_world, new_velocity, is_grounded)
pub fn update_physics(
  physics_world: physics.PhysicsWorld(id.Id),
  player: Player,
  player_velocity: Vec3(Float),
  player_impulse: Vec3(Float),
  enemies: List(Enemy(id.Id)),
  pending_player_knockback: Option(Vec3(Float)),
  delta_time: Float,
) -> #(physics.PhysicsWorld(id.Id), Vec3(Float), Bool) {
  // For kinematic character controller: compute desired translation
  let gravity_acceleration = -20.0
  // Match world gravity
  let dt = delta_time /. 1000.0
  // Convert ms to seconds

  // Get current Y velocity from player state (NOT from physics world - kinematic bodies don't store velocity)
  let current_y_velocity = player_velocity.y

  // Apply gravity and jumping to Y velocity
  let new_y_velocity =
    current_y_velocity +. player_impulse.y +. gravity_acceleration *. dt

  // Calculate full desired translation including vertical movement
  let desired_translation =
    vec3.Vec3(
      player_velocity.x *. dt,
      new_y_velocity *. dt,
      player_velocity.z *. dt,
    )

  // Get CURRENT position from physics (not from game state)
  let current_position = case
    physics.get_transform(physics_world, id.player())
  {
    Ok(transform) -> transform.position(transform)
    Error(_) -> player.position
  }

  // Use character controller for collision-aware movement
  let safe_translation = case
    physics.compute_character_movement(
      physics_world,
      id.player(),
      desired_translation,
    )
  {
    Ok(movement) -> movement
    Error(_) -> desired_translation
  }

  // Check if grounded after computing movement
  let is_grounded = case physics.is_character_grounded(physics_world, id.player()) {
    Ok(grounded) -> grounded
    Error(_) -> False
  }

  // Reset Y velocity if grounded and moving downward
  let final_y_velocity = case is_grounded, new_y_velocity <. 0.0 {
    True, True -> 0.0
    _, _ -> new_y_velocity
  }

  // Calculate new position from CURRENT physics position
  let new_position =
    vec3.Vec3(
      current_position.x +. safe_translation.x,
      current_position.y +. safe_translation.y,
      current_position.z +. safe_translation.z,
    )

  // Store velocity for next frame
  let velocity_to_store =
    vec3.Vec3(player_velocity.x, final_y_velocity, player_velocity.z)

  let updated_physics =
    physics_world
    // For kinematic bodies, use set_kinematic_translation (not update_body_transform!)
    // This ensures proper collision detection
    |> physics.set_kinematic_translation(id.player(), new_position)
    // Apply pending player knockback
    |> apply_player_knockback(pending_player_knockback)
    // Set velocities for all enemies
    |> apply_enemy_velocities(enemies)

  // Return the updated physics world, the new velocity, and grounded state
  // (velocity must be tracked in game state, not physics world, for kinematic bodies)
  #(updated_physics, velocity_to_store, is_grounded)
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
  delta_time: Float,
) -> physics.PhysicsWorld(id.Id) {
  physics_world
  |> physics.step(delta_time)
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
