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
    initial_transform: transform.Transform,
    physics_body: physics.RigidBody,
  )
}

pub fn new(
  id id: id,
  health health: Int,
  damage damage: Int,
  speed speed: Float,
  initial_transform initial_transform: transform.Transform,
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
    initial_transform:,
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
    transform: enemy.initial_transform,
    physics: option.Some(enemy.physics_body),
  )
}

pub fn basic(id id: id, at initial_transform: transform.Transform) {
  new(id:, health: 10, damage: 10, speed: 3.0, initial_transform:)
}

/// Apply velocity to enemy's physics body to move towards target
pub fn follow(
  enemy: Enemy(id),
  enemy_position enemy_position: vec3.Vec3(Float),
  target target: transform.Transform,
  enemy_velocity enemy_velocity: vec3.Vec3(Float),
  set_velocity set_velocity,
) -> physics.PhysicsWorld(id) {
  // Get current position from physics body

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
  // Combine horizontal movement with vertical physics (gravity)
  let final_velocity =
    echo vec3.Vec3(
      horizontal_velocity.x,
      enemy_velocity.y,
      horizontal_velocity.z,
    )
      as "final velocity"

  // Apply velocity and clear unwanted angular velocity

  set_velocity(final_velocity)
}
