import gleam/option.{type Option, None, Some}
import gleam/result
import gleam_community/maths
import pondering_my_orb/health_bar
import pondering_my_orb/id.{type Id}
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/spritesheet
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

const jump_velocity = 5.0

pub type EnemyType {
  EnemyType1
  EnemyType2
}

pub type Enemy(id) {
  Enemy(
    id: id,
    max_health: Int,
    current_health: Int,
    damage: Float,
    damage_range: Float,
    attack_cooldown: Float,
    time_since_last_attack: Float,
    speed: Float,
    position: Vec3(Float),
    velocity: Vec3(Float),
    rotation: Vec3(Float),
    physics_body: physics.RigidBody,
    // Sprite animation
    enemy_type: EnemyType,
    spritesheet: Option(spritesheet.Spritesheet),
    animation: Option(spritesheet.Animation),
    animation_state: spritesheet.AnimationState,
  )
}

pub fn new(
  id id: id,
  health health: Int,
  damage damage: Float,
  damage_range damage_range: Float,
  attack_cooldown attack_cooldown: Float,
  speed speed: Float,
  position position: Vec3(Float),
  enemy_type enemy_type: EnemyType,
) {
  let physics_body =
    physics.new_rigid_body(physics.Dynamic)
    |> physics.with_collider(physics.Capsule(
      offset: transform.identity,
      half_height: 1.0,
      radius: 0.5,
    ))
    |> physics.with_friction(0.0)
    |> physics.with_linear_damping(2.0)
    |> physics.with_lock_rotation_x()
    |> physics.with_lock_rotation_y()
    |> physics.with_lock_rotation_z()
    |> physics.build()

  Enemy(
    id: id,
    max_health: health,
    current_health: health,
    damage:,
    damage_range:,
    attack_cooldown:,
    time_since_last_attack: attack_cooldown,
    speed:,
    position:,
    velocity: vec3f.zero,
    rotation: Vec3(0.0, 0.0, 0.0),
    physics_body:,
    enemy_type:,
    spritesheet: None,
    animation: None,
    animation_state: spritesheet.initial_state("idle"),
  )
}

pub fn render(enemy: Enemy(Id), camera_position: Vec3(Float)) -> scene.Node(Id) {
  // Extract the enemy ID number
  let enemy_id_num = case enemy.id {
    id.Enemy(_, num) -> num
    _ -> 0
  }

  // Create health bar picture
  let health_bar_picture =
    health_bar.create(enemy.current_health, enemy.max_health)

  // Calculate billboard rotation to face camera (for health bar)
  let health_bar_position =
    Vec3(enemy.position.x, enemy.position.y +. 1.5, enemy.position.z)

  // Calculate direction from health bar to camera (for billboard)
  let to_camera = vec3f.subtract(camera_position, health_bar_position)
  // Use atan2 to get Y rotation to face camera
  let y_rotation = maths.atan2(to_camera.x, to_camera.z)

  // Create invisible physics body
  let assert Ok(invisible_geometry) =
    geometry.cylinder(
      radius_top: 0.01,
      radius_bottom: 0.01,
      height: 0.01,
      radial_segments: 4,
    )
  let assert Ok(invisible_material) =
    material.new()
    |> material.with_color(0xff0000)
    |> material.with_opacity(0.0)
    |> material.build()

  let physics_body =
    scene.mesh(
      id: enemy.id,
      geometry: invisible_geometry,
      material: invisible_material,
      transform: transform.at(position: enemy.position),
      physics: Some(enemy.physics_body),
    )

  // Choose between sprite or fallback mesh
  let enemy_visual = case enemy.spritesheet, enemy.animation {
    Some(sheet), Some(anim) -> {
      scene.animated_sprite(
        id: id.enemy_sprite(enemy_id_num),
        spritesheet: sheet,
        animation: anim,
        state: enemy.animation_state,
        width: 2.0,
        height: 2.5,
        transform: transform.at(position: enemy.position)
          |> transform.with_euler_rotation(enemy.rotation),
        pixel_art: True,
        physics: option.None,
      )
    }
    _, _ -> {
      // Fallback to cylinder if sprites not loaded yet
      let assert Ok(capsule) =
        geometry.cylinder(
          radius_top: 0.5,
          radius_bottom: 0.5,
          height: 2.0,
          radial_segments: 10,
        )
      let assert Ok(material) =
        material.new() |> material.with_color(0xff0000) |> material.build()

      scene.mesh(
        id: id.enemy_sprite(enemy_id_num),
        geometry: capsule,
        material:,
        transform: transform.at(position: enemy.position),
        physics: option.None,
      )
    }
  }

  scene.empty(
    id: id.enemy_group(enemy_id_num),
    transform: transform.identity,
    children: [
      physics_body,
      enemy_visual,
      // Health bar sprite above enemy - billboard to face camera
      scene.canvas(
        id: id.enemy_health_bar(enemy_id_num),
        picture: health_bar_picture,
        texture_width: 128,
        texture_height: 32,
        width: 1.5,
        height: 0.15,
        transform: transform.at(position: health_bar_position)
          |> transform.with_euler_rotation(Vec3(0.0, y_rotation, 0.0)),
      ),
    ],
  )
}

pub fn basic(
  id id: id,
  position position: Vec3(Float),
  enemy_type enemy_type: EnemyType,
) {
  new(
    id:,
    health: 20,
    damage: 00.0,
    damage_range: 1.0,
    attack_cooldown: 1.0,
    speed: 7.5,
    position:,
    enemy_type:,
  )
}

pub fn set_spritesheet(
  enemy: Enemy(id),
  spritesheet: spritesheet.Spritesheet,
  animation: spritesheet.Animation,
) -> Enemy(id) {
  Enemy(..enemy, spritesheet: Some(spritesheet), animation: Some(animation))
}

pub fn update_animation(enemy: Enemy(id), delta_time: Float) -> Enemy(id) {
  let animation_state = case enemy.animation {
    Some(anim) -> spritesheet.update(enemy.animation_state, anim, delta_time)
    None -> enemy.animation_state
  }

  Enemy(..enemy, animation_state:)
}

/// Apply velocity to enemy's physics body to move towards target
pub fn update(
  enemy: Enemy(id),
  target target: Vec3(Float),
  camera_position camera_position: Vec3(Float),
  enemy_velocity enemy_velocity: Vec3(Float),
  physics_world physics_world: physics.PhysicsWorld(Id),
  delta_time delta_time: Float,
  enemy_attacks_player_msg enemy_attacks_player_msg: fn(Float, Vec3(Float)) ->
    msg,
) -> #(Enemy(id), Effect(msg)) {
  // Calculate direction to target (keep it horizontal)
  let direction =
    vec3f.direction(enemy.position, target)
    |> vec3.replace_y(0.0)

  // Dead zone: stop moving if very close to target (within 0.5 units)
  let horizontal_velocity = case vec3f.length(direction) >. 0.5 {
    True -> vec3f.normalize(direction) |> vec3f.scale(enemy.speed)
    False -> Vec3(0.0, 0.0, 0.0)
  }

  let climb_velocity =
    climb_velocity(enemy, direction, physics_world, enemy_velocity)

  let velocity =
    Vec3(horizontal_velocity.x, climb_velocity, horizontal_velocity.z)

  // Calculate billboard rotation to face camera
  let to_camera = vec3f.subtract(camera_position, enemy.position)
  let y_rotation = maths.atan2(to_camera.x, to_camera.z)
  let rotation = Vec3(0.0, y_rotation, 0.0)

  // Update attack cooldown timer
  let time_since_last_attack = enemy.time_since_last_attack +. delta_time

  // Check if enemy can attack (in range AND cooldown expired)
  let can_attack =
    can_damage(enemy, target)
    && time_since_last_attack >=. enemy.attack_cooldown

  let #(time_since_last_attack, effects) = case can_attack {
    True -> #(
      0.0,
      effect.from(fn(dispatch) {
        dispatch(enemy_attacks_player_msg(enemy.damage, enemy.position))
      }),
    )
    False -> #(time_since_last_attack, effect.none())
  }

  #(Enemy(..enemy, velocity:, rotation:, time_since_last_attack:), effects)
}

fn climb_velocity(
  enemy: Enemy(id),
  direction: Vec3(Float),
  physics_world: physics.PhysicsWorld(Id),
  enemy_velocity: Vec3(Float),
) -> Float {
  // Normalize direction for raycast
  let normalized_direction = vec3f.normalize(direction)

  // Cast ray horizontally forward from lower body (knee height)
  // Start the ray OUTSIDE the enemy's capsule (radius 0.5) to avoid self-hits
  let raycast_origin =
    Vec3(
      enemy.position.x +. normalized_direction.x *. 0.7,
      enemy.position.y -. 0.7,
      // Lower body level
      enemy.position.z +. normalized_direction.z *. 0.7,
    )

  // Cast ray purely horizontally forward
  let raycast_direction =
    Vec3(normalized_direction.x, 0.0, normalized_direction.z)

  case
    physics.raycast(
      physics_world,
      origin: raycast_origin,
      direction: raycast_direction,
      max_distance: 1.0,
    )
  {
    Ok(hit) if hit.id.layer == id.PlayerLayer || hit.id.layer == id.EnemyLayer ->
      enemy_velocity.y
    Ok(_) -> jump_velocity
    Error(Nil) -> enemy_velocity.y
  }
}

pub fn can_damage(enemy: Enemy(id), player_position: Vec3(Float)) -> Bool {
  let distance = vec3f.distance(player_position, enemy.position)
  distance <. enemy.damage_range
}

pub fn after_physics_update(
  enemy: Enemy(id),
  physics_world: physics.PhysicsWorld(id),
) {
  let new_position =
    physics.get_transform(physics_world, enemy.id)
    |> result.map(transform.position)
    |> result.unwrap(or: enemy.position)
  Enemy(..enemy, position: new_position)
}
