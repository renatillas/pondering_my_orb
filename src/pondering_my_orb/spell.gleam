import gleam/list
import gleam/option
import gleam_community/maths
import iv
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id
import tiramisu/effect
import tiramisu/scene
import tiramisu/spritesheet
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

pub type Spell {
  DamageSpell(DamageSpell)
  ModifierSpell(ModifierSpell)
  MulticastSpell(MulticastSpell)
}

pub type MulticastCount {
  Fixed(Int)
  AllRemaining
}

pub type MulticastSpell {
  Multicast(
    name: String,
    mana_cost: Float,
    spell_count: MulticastCount,
    draw_add: Int,
    ui_sprite: String,
  )
}

/// Visual configuration for spell effects
pub type SpellVisuals {
  SpellVisuals(
    projectile_spritesheet: spritesheet.Spritesheet,
    projectile_animation: spritesheet.Animation,
    hit_spritesheet: spritesheet.Spritesheet,
    hit_animation: spritesheet.Animation,
  )
}

pub type DamageSpell {
  Damage(
    name: String,
    mana_cost: Float,
    damage: Float,
    projectile_speed: Float,
    projectile_lifetime: Float,
    projectile_size: Float,
    visuals: SpellVisuals,
    ui_sprite: String,
  )
}

pub type ModifierSpell {
  Modifier(
    name: String,
    mana_cost: Float,
    damage_multiplier: Float,
    damage_addition: Float,
    projectile_speed_multiplier: Float,
    projectile_speed_addition: Float,
    projectile_size_multiplier: Float,
    projectile_size_addition: Float,
    projectile_lifetime_multiplier: Float,
    projectile_lifetime_addition: Float,
    ui_sprite: String,
  )
}

/// Represents a projectile created by casting a spell
pub type Projectile {
  Projectile(
    id: Int,
    spell: ModifiedSpell,
    position: Vec3(Float),
    direction: Vec3(Float),
    time_alive: Float,
    animation_state: spritesheet.AnimationState,
    visuals: SpellVisuals,
  )
}

/// Result of applying modifiers to a damaging spell
pub type ModifiedSpell {
  ModifiedSpell(
    base: Spell,
    final_damage: Float,
    final_speed: Float,
    final_size: Float,
    final_lifetime: Float,
    total_mana_cost: Float,
  )
}

/// Create a new damaging spell
pub fn damaging_spell(
  name name: String,
  damage damage: Float,
  projectile_speed projectile_speed: Float,
  projectile_lifetime projectile_lifetime: Float,
  mana_cost mana_cost: Float,
  projectile_size projectile_size: Float,
  visuals visuals: SpellVisuals,
  ui_sprite ui_sprite: String,
) -> Spell {
  DamageSpell(Damage(
    name:,
    damage:,
    projectile_speed:,
    projectile_lifetime:,
    mana_cost:,
    projectile_size:,
    visuals:,
    ui_sprite:,
  ))
}

/// Create a new modifier spell
pub fn modifier_spell(
  name name: String,
  damage_multiplier damage_multiplier: Float,
  damage_addition damage_addition: Float,
  projectile_speed_multiplier projectile_speed_multiplier: Float,
  projectile_speed_addition projectile_speed_addition: Float,
  projectile_size_multiplier projectile_size_multiplier: Float,
  projectile_size_addition projectile_size_addition: Float,
  projectile_lifetime_multiplier projectile_lifetime_multiplier: Float,
  projectile_lifetime_addition projectile_lifetime_addition: Float,
  mana_cost mana_cost: Float,
  ui_sprite ui_sprite: String,
) -> Spell {
  ModifierSpell(Modifier(
    name:,
    mana_cost:,
    damage_multiplier:,
    damage_addition:,
    projectile_speed_multiplier:,
    projectile_speed_addition:,
    projectile_size_multiplier:,
    projectile_size_addition:,
    projectile_lifetime_multiplier:,
    projectile_lifetime_addition:,
    ui_sprite:,
  ))
}

/// Apply a list of modifiers to a damaging spell
pub fn apply_modifiers(
  base_spell: DamageSpell,
  modifiers: iv.Array(ModifierSpell),
) -> ModifiedSpell {
  // Fold over all modifiers to calculate final values
  let #(damage, speed, size, lifetime) =
    iv.fold(
      modifiers,
      #(
        base_spell.damage,
        base_spell.projectile_speed,
        base_spell.projectile_size,
        base_spell.projectile_lifetime,
      ),
      fn(acc, mod) {
        let #(damage, speed, size, lifetime) = acc
        #(
          damage +. mod.damage_addition,
          speed +. mod.projectile_speed_addition,
          size +. mod.projectile_size_addition,
          lifetime +. mod.projectile_lifetime_addition,
        )
      },
    )
  let #(final_damage, final_speed, final_size, final_lifetime, total_mana_cost) =
    iv.fold(
      modifiers,
      #(damage, speed, size, lifetime, base_spell.mana_cost),
      fn(acc, mod) {
        let #(damage, speed, size, lifetime, mana_cost) = acc
        #(
          damage *. mod.damage_multiplier,
          speed *. mod.projectile_speed_multiplier,
          size *. mod.projectile_size_multiplier,
          lifetime *. mod.projectile_lifetime_multiplier,
          mana_cost *. mod.projectile_lifetime_multiplier,
        )
      },
    )

  ModifiedSpell(
    base: DamageSpell(base_spell),
    final_damage:,
    final_speed:,
    final_size:,
    final_lifetime:,
    total_mana_cost:,
  )
}

// Pre-defined spells for convenience

/// Basic projectile spell
pub fn spark(visuals: SpellVisuals) -> Spell {
  damaging_spell(
    name: "Spark",
    damage: 10.0,
    projectile_speed: 10.0,
    projectile_lifetime: 2.0,
    mana_cost: 5.0,
    projectile_size: 1.0,
    visuals:,
    ui_sprite: "spells/spark.png",
  )
}

/// Powerful projectile spell
pub fn fireball(visuals: SpellVisuals) -> Spell {
  damaging_spell(
    name: "Fireball",
    damage: 20.0,
    projectile_speed: 15.0,
    projectile_lifetime: 3.0,
    mana_cost: 10.0,
    projectile_size: 5.0,
    visuals:,
    ui_sprite: "spells/fireball.png",
  )
}

/// Heavy damage spell
pub fn lightning(visuals: SpellVisuals) -> Spell {
  damaging_spell(
    name: "Lightning Bolt",
    damage: 100.0,
    projectile_speed: 30.0,
    projectile_lifetime: 1.0,
    mana_cost: 35.0,
    projectile_size: 0.2,
    visuals:,
    ui_sprite: "spells/lightning.png",
  )
}

/// Double Spell - casts 2 spells at once (no mana cost)
pub fn double_spell() -> Spell {
  MulticastSpell(Multicast(
    name: "Double Spell",
    mana_cost: 0.0,
    spell_count: Fixed(2),
    draw_add: 2,
    ui_sprite: "spells/double_spell.png",
  ))
}

/// Triple Spell - casts 3 spells at once
pub fn triple_spell() -> Spell {
  MulticastSpell(Multicast(
    name: "Triple Spell",
    mana_cost: 2.0,
    spell_count: Fixed(3),
    draw_add: 3,
    ui_sprite: "spells/triple.png",
  ))
}

/// Quadruple Spell - casts 4 spells at once
pub fn quadruple_spell() -> Spell {
  MulticastSpell(Multicast(
    name: "Quadruple Spell",
    mana_cost: 5.0,
    spell_count: Fixed(4),
    draw_add: 4,
    ui_sprite: "spells/quadruple.png",
  ))
}

/// Octuple Spell - casts 8 spells at once
pub fn octuple_spell() -> Spell {
  MulticastSpell(Multicast(
    name: "Octuple Spell",
    mana_cost: 30.0,
    spell_count: Fixed(8),
    draw_add: 8,
    ui_sprite: "spells/octuple.png",
  ))
}

/// Myriad Spell - casts all remaining spells
pub fn myriad_spell() -> Spell {
  MulticastSpell(Multicast(
    name: "Myriad Spell",
    mana_cost: 50.0,
    spell_count: AllRemaining,
    draw_add: 99,
    ui_sprite: "spells/myriad.png",
  ))
}

pub type ProjectileHit(id) {
  ProjectileHit(
    id: Int,
    enemy_id: id,
    damage: Float,
    direction: Vec3(Float),
    position: Vec3(Float),
    time_alive: Float,
    animation_state: spritesheet.AnimationState,
    spritesheet: spritesheet.Spritesheet,
    animation: spritesheet.Animation,
  )
}

pub fn update(
  projectiles: List(Projectile),
  enemies: List(Enemy(id)),
  delta_time: Float,
  damage_enemy_msg: fn(id, Float, Vec3(Float)) -> msg,
) -> #(List(Projectile), List(ProjectileHit(id)), effect.Effect(msg)) {
  let updated_projectiles =
    list.map(projectiles, update_position(_, delta_time /. 1000.0))

  // Check each projectile against each enemy for collisions
  let #(hits, remaining_projectiles) =
    list.fold(
      over: updated_projectiles,
      from: #([], []),
      with: fn(acc, projectile) {
        let #(hits, remaining) = acc

        // Find which enemy (if any) this projectile hit
        let hit_enemy =
          list.find(enemies, fn(enemy) {
            vec3f.distance(projectile.position, enemy.position) <=. 1.0
          })

        case hit_enemy {
          Ok(enemy) -> {
            // Projectile hit this enemy - create explosion using projectile's visuals
            let hit =
              ProjectileHit(
                id: projectile.id,
                direction: projectile.direction,
                enemy_id: enemy.id,
                damage: projectile.spell.final_damage,
                position: projectile.position,
                time_alive: 0.0,
                animation_state: spritesheet.initial_state("hit"),
                spritesheet: projectile.visuals.hit_spritesheet,
                animation: projectile.visuals.hit_animation,
              )
            #([hit, ..hits], remaining)
          }
          Error(_) -> {
            // Projectile didn't hit anything, keep it
            #(hits, [projectile, ..remaining])
          }
        }
      },
    )

  // Filter out projectiles that have exceeded their lifetime
  let final_projectiles =
    remaining_projectiles
    |> list.fold(from: [], with: fn(acc, projectile) {
      case projectile.time_alive <. projectile.spell.final_lifetime {
        True -> [projectile, ..acc]
        False -> {
          acc
        }
      }
    })

  // Create effects for each hit enemy
  let effects =
    list.map(hits, fn(hit) {
      effect.from(fn(dispatch) {
        dispatch(damage_enemy_msg(hit.enemy_id, hit.damage, hit.direction))
      })
    })

  #(final_projectiles, hits, effect.batch(effects))
}

fn update_position(projectile: Projectile, delta_time: Float) -> Projectile {
  let Vec3(x, y, z) = projectile.position
  let Vec3(dx, dy, dz) = projectile.direction

  let speed = projectile.spell.final_speed
  let new_x = x +. dx *. speed *. delta_time
  let new_y = y +. dy *. speed *. delta_time
  let new_z = z +. dz *. speed *. delta_time

  let new_time_alive = projectile.time_alive +. delta_time

  // Update animation state using projectile's own animation
  let new_animation_state =
    spritesheet.update(
      projectile.animation_state,
      projectile.visuals.projectile_animation,
      delta_time *. 1000.0,
    )

  Projectile(
    ..projectile,
    position: Vec3(new_x, new_y, new_z),
    time_alive: new_time_alive,
    animation_state: new_animation_state,
  )
}

/// Update explosions and remove those that have finished
pub fn update_projectile_hits(
  projectile_hits: List(ProjectileHit(id)),
  delta_time: Float,
) -> List(ProjectileHit(id)) {
  projectile_hits
  |> list.map(fn(hit) {
    let new_time_alive = hit.time_alive +. delta_time /. 1000.0
    let new_animation_state =
      spritesheet.update(hit.animation_state, hit.animation, delta_time)

    ProjectileHit(
      ..hit,
      time_alive: new_time_alive,
      animation_state: new_animation_state,
    )
  })
  |> list.filter(fn(explosion) { explosion.time_alive <. 1.5 })
}

pub fn view(
  id: fn(Int) -> id,
  projectiles: List(Projectile),
  camera_position: Vec3(Float),
) -> List(scene.Node(id)) {
  list.map(projectiles, fn(projectile) {
    // Constrained billboard: sprite faces camera while aligning with travel direction
    // The fireball sprite animates left-to-right, so we want:
    // - Sprite's horizontal axis aligned with travel direction (trail points backward)
    // - Sprite faces the camera as much as possible

    // Build rotation from direction and camera position
    let rotation =
      constrained_billboard_rotation(
        projectile.position,
        projectile.direction,
        camera_position,
      )

    scene.animated_sprite(
      id: id(projectile.id),
      spritesheet: projectile.visuals.projectile_spritesheet,
      animation: projectile.visuals.projectile_animation,
      state: projectile.animation_state,
      width: projectile.spell.final_size,
      height: projectile.spell.final_size,
      transform: transform.at(position: projectile.position)
        |> transform.with_quaternion_rotation(rotation),
      pixel_art: True,
      physics: option.None,
    )
  })
}

/// Create a constrained billboard rotation where:
/// - The sprite's X-axis aligns with the travel direction (fireball moves along X)
/// - The sprite's Z-axis (face normal) points toward the camera as much as possible
fn constrained_billboard_rotation(
  position: Vec3(Float),
  direction: Vec3(Float),
  camera_position: Vec3(Float),
) -> transform.Quaternion {
  // X-axis: travel direction (normalized)
  let x_axis = vec3f.normalize(direction)

  // Vector from projectile to camera
  let to_camera = vec3f.subtract(camera_position, position)
  let to_camera_norm = vec3f.normalize(to_camera)

  // Project to_camera onto the plane perpendicular to X-axis (travel direction)
  // This gives us the direction the sprite should face while staying perpendicular to motion
  let dot_product = vec3f.dot(to_camera_norm, x_axis)
  let parallel_component = vec3f.scale(x_axis, dot_product)
  let perpendicular_component =
    vec3f.subtract(to_camera_norm, parallel_component)

  // Z-axis: perpendicular component (sprite faces this direction)
  // If perpendicular component is too small, camera is aligned with travel - use world up
  let z_axis = case vec3f.length(perpendicular_component) <. 0.01 {
    True -> {
      // Camera aligned with travel direction, use world up for fallback
      let world_up = Vec3(0.0, 1.0, 0.0)
      let dot_up = vec3f.dot(world_up, x_axis)
      let par_up = vec3f.scale(x_axis, dot_up)
      vec3f.subtract(world_up, par_up) |> vec3f.normalize()
    }
    False -> vec3f.normalize(perpendicular_component)
  }

  // Y-axis: complete the right-handed orthonormal basis
  // Y = Z × X (cross product gives perpendicular vector)
  let y_axis = vec3f.cross(z_axis, x_axis) |> vec3f.normalize()

  // Build quaternion from the three orthonormal axes
  transform.quaternion_from_basis(x_axis, y_axis, z_axis)
}

pub fn view_hits(
  hit: ProjectileHit(id),
  camera_position: Vec3(Float),
) -> scene.Node(id.Id) {
  // Full 3D billboard using proper quaternion-based look-at
  // The explosion sprite should face the camera
  let from_transform = transform.at(position: hit.position)
  let to_transform = transform.at(position: camera_position)
  let look_at_transform =
    transform.look_at(from: from_transform, to: to_transform, up: option.None)

  // Get the rotation quaternion from the look-at transform
  let look_rotation = transform.rotation_quaternion(look_at_transform)

  // Three.js lookAt orients -Z toward target, but sprites face +Z
  // Add 180-degree Y rotation to flip the sprite
  let flip_quat = transform.euler_to_quaternion(Vec3(0.0, maths.pi(), 0.0))
  let flipped_look = transform.multiply_quaternions(look_rotation, flip_quat)

  // For a simple billboard, just use the flipped lookAt (don't add camera roll)
  // If you want the sprite to also roll with camera, multiply by camera_rotation
  let final_rotation = flipped_look

  scene.animated_sprite(
    id: id.explosion(hit.id),
    spritesheet: hit.spritesheet,
    animation: hit.animation,
    state: hit.animation_state,
    width: 8.0,
    height: 8.0,
    transform: transform.at(position: hit.position)
      |> transform.with_quaternion_rotation(final_rotation),
    pixel_art: True,
    physics: option.None,
  )
}

// Mock functions for testing
@external(javascript, "./spell_ffi.mjs", "mockSpritesheet")
pub fn mock_spritesheet() -> spritesheet.Spritesheet

@external(javascript, "./spell_ffi.mjs", "mockAnimation")
pub fn mock_animation() -> spritesheet.Animation
