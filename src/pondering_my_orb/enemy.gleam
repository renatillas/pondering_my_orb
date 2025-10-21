import gleam/option
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3
import vec/vec3f

pub type Enemy(id) {
  Enemy(
    id: id,
    max_health: Int,
    current_health: Int,
    damage: Int,
    speed: Float,
    transform: transform.Transform,
    physics_body: physics.RigidBody,
  )
}

pub fn new(
  id id: id,
  health health: Int,
  damage damage: Int,
  speed speed: Float,
  transform transform: transform.Transform,
) {
  let physics_body =
    physics.new_rigid_body(physics.Dynamic)
    |> physics.with_collider(physics.Capsule(
      offset: transform.identity,
      half_height: 1.0,
      radius: 0.5,
    ))
    |> physics.with_angular_damping(100.0)
    |> physics.with_lock_rotation_x()
    |> physics.with_lock_rotation_z()
    |> physics.build()

  Enemy(
    id: id,
    max_health: health,
    current_health: health,
    damage:,
    speed:,
    transform:,
    physics_body:,
  )
}

pub fn render(enemy: Enemy(id)) {
  let assert Ok(capsule) =
    geometry.cylinder(
      radius_top: 0.5,
      radius_bottom: 0.5,
      height: 2.0,
      radial_segments: 10,
    )
  let assert Ok(material) =
    material.new() |> material.with_color(0xff0000) |> material.build()
  scene.Mesh(
    enemy.id,
    geometry: capsule,
    material:,
    transform: enemy.transform,
    physics: option.Some(enemy.physics_body),
  )
}

pub fn basic(id: id, transform: transform.Transform) {
  new(id:, health: 10, damage: 10, speed: 3.0, transform:)
}

/// Apply velocity to enemy's physics body to move towards target
pub fn follow(
  enemy: Enemy(id),
  target: transform.Transform,
  physics_world: physics.PhysicsWorld(id),
) -> physics.PhysicsWorld(id) {
  // Get current position from physics body
  let enemy_position = case physics.get_transform(physics_world, enemy.id) {
    Ok(t) -> transform.position(t)
    Error(_) -> transform.position(enemy.transform)
  }

  let target_position = transform.position(target)

  // Calculate direction to target (keep it horizontal)
  let direction =
    vec3f.direction(enemy_position, target_position)
    |> vec3.replace_y(0.0)

  // Dead zone: stop moving if very close to target (within 0.5 units)
  let horizontal_velocity = case vec3f.length(direction) >. 0.5 {
    True -> vec3f.normalize(direction) |> vec3f.scale(enemy.speed)
    False -> vec3.Vec3(0.0, 0.0, 0.0)
  }

  // Get current velocity to preserve Y component (gravity)
  let current_velocity = case physics.get_velocity(physics_world, enemy.id) {
    Ok(vel) -> vel
    Error(_) -> vec3.Vec3(0.0, 0.0, 0.0)
  }

  // Combine horizontal movement with vertical physics (gravity)
  let final_velocity =
    vec3.Vec3(horizontal_velocity.x, current_velocity.y, horizontal_velocity.z)

  // Apply velocity and clear unwanted angular velocity
  physics_world
  |> physics.set_velocity(enemy.id, final_velocity)
}
