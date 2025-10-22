import gleam/option
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3
import vec/vec3f

const jump_velocity = 5.0

pub type Enemy(id) {
  Enemy(
    id: id,
    max_health: Int,
    current_health: Int,
    damage: Int,
    damage_range: Float,
    speed: Float,
    position: vec3.Vec3(Float),
    physics_body: physics.RigidBody,
  )
}

pub fn new(
  id id: id,
  health health: Int,
  damage damage: Int,
  damage_range damage_range: Float,
  speed speed: Float,
  position position: vec3.Vec3(Float),
) {
  let physics_body =
    physics.new_rigid_body(physics.Dynamic)
    |> physics.with_collider(physics.Capsule(
      offset: transform.identity,
      half_height: 1.0,
      radius: 0.5,
    ))
    |> physics.with_friction(0.0)
    |> physics.with_angular_damping(100.0)
    |> physics.with_lock_rotation_x()
    |> physics.with_lock_rotation_z()
    |> physics.build()

  Enemy(
    id: id,
    max_health: health,
    current_health: health,
    damage:,
    damage_range:,
    speed:,
    position:,
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
    transform: transform.at(enemy.position),
    physics: option.Some(enemy.physics_body),
  )
}

pub fn basic(id id: id, position position: vec3.Vec3(Float)) {
  new(id:, health: 10, damage: 10, damage_range: 1.0, speed: 3.0, position:)
}

/// Apply velocity to enemy's physics body to move towards target
pub fn follow(
  enemy: Enemy(id),
  target target: vec3.Vec3(Float),
  enemy_velocity enemy_velocity: vec3.Vec3(Float),
  physics_world physics_world: physics.PhysicsWorld(id),
  player_id player_id: id,
) {
  // Calculate direction to target (keep it horizontal)
  let direction =
    vec3f.direction(enemy.position, target)
    |> vec3.replace_y(0.0)

  // Dead zone: stop moving if very close to target (within 0.5 units)
  let horizontal_velocity = case vec3f.length(direction) >. 0.5 {
    True -> vec3f.normalize(direction) |> vec3f.scale(enemy.speed)
    False -> vec3.Vec3(0.0, 0.0, 0.0)
  }

  // Check for obstacles in front using raycast (only when moving)
  let is_moving = vec3f.length(horizontal_velocity) >. 0.1

  let climb_velocity = case is_moving {
    True -> {
      // Normalize direction for raycast
      let normalized_direction = vec3f.normalize(direction)

      // Cast ray horizontally forward from lower body (knee height)
      // Start the ray OUTSIDE the enemy's capsule (radius 0.5) to avoid self-hits
      let raycast_origin =
        vec3.Vec3(
          enemy.position.x +. normalized_direction.x *. 0.7,
          enemy.position.y -. 0.7,
          // Lower body level
          enemy.position.z +. normalized_direction.z *. 0.7,
        )

      // Cast ray purely horizontally forward
      let raycast_direction =
        vec3.Vec3(normalized_direction.x, 0.0, normalized_direction.z)

      case
        physics.raycast(
          physics_world,
          origin: raycast_origin,
          direction: raycast_direction,
          max_distance: 1.0,
        )
      {
        Ok(hit) if hit.id == player_id -> enemy_velocity.y
        Ok(_) -> jump_velocity
        Error(Nil) -> enemy_velocity.y
      }
    }
    False -> enemy_velocity.y
    // Not moving, don't climb
  }

  let final_velocity =
    vec3.Vec3(horizontal_velocity.x, climb_velocity, horizontal_velocity.z)

  final_velocity
}

pub fn can_damage(enemy: Enemy(id), player_position: vec3.Vec3(Float)) -> Bool {
  let distance = vec3f.distance(player_position, enemy.position)
  distance <. enemy.damage_range
}

pub fn with_position(enemy: Enemy(id), position position: vec3.Vec3(Float)) {
  Enemy(..enemy, position:)
}
