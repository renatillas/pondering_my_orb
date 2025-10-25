import gleam/int
import gleam/list
import gleam/option
import iv
import pondering_my_orb/enemy.{type Enemy}
import tiramisu/effect
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

pub type Spell {
  DamageSpell(DamageSpell)
  ModifierSpell(ModifierSpell)
}

pub type DamageSpell {
  Damage(
    name: String,
    mana_cost: Float,
    damage: Float,
    projectile_speed: Float,
    projectile_lifetime: Float,
    projectile_size: Float,
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
) -> Spell {
  DamageSpell(Damage(
    name:,
    damage:,
    projectile_speed:,
    projectile_lifetime:,
    mana_cost:,
    projectile_size:,
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
pub fn spark() -> Spell {
  damaging_spell(
    name: "Spark",
    damage: 10.0,
    projectile_speed: 15.0,
    projectile_lifetime: 2.0,
    mana_cost: 5.0,
    projectile_size: 0.3,
  )
}

/// Powerful projectile spell
pub fn fireball() -> Spell {
  damaging_spell(
    name: "Fireball",
    damage: 50.0,
    projectile_speed: 10.0,
    projectile_lifetime: 3.0,
    mana_cost: 20.0,
    projectile_size: 0.8,
  )
}

/// Heavy damage spell
pub fn lightning() -> Spell {
  damaging_spell(
    name: "Lightning Bolt",
    damage: 100.0,
    projectile_speed: 30.0,
    projectile_lifetime: 1.0,
    mana_cost: 35.0,
    projectile_size: 0.2,
  )
}

pub type ProjectileHit(id) {
  ProjectileHit(enemy_id: id, damage: Float, projectile_direction: Vec3(Float))
}

/// Update projectiles and return hit information for knockback
pub fn update_with_hits(
  projectiles: List(Projectile),
  enemies: List(Enemy(id)),
  delta_time: Float,
  damage_enemy_msg: fn(id, Float, Vec3(Float)) -> msg,
) -> #(List(Projectile), effect.Effect(msg), List(ProjectileHit(id))) {
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
            // Projectile hit this enemy
            let hit =
              ProjectileHit(
                enemy.id,
                projectile.spell.final_damage,
                projectile.direction,
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
    |> list.filter(fn(projectile) {
      projectile.time_alive <. projectile.spell.final_lifetime
    })

  // Create effects for each hit enemy
  let effects =
    list.map(hits, fn(hit) {
      effect.from(fn(dispatch) {
        dispatch(damage_enemy_msg(
          hit.enemy_id,
          hit.damage,
          hit.projectile_direction,
        ))
      })
    })

  #(final_projectiles, effect.batch(effects), hits)
}

pub fn update(
  projectiles: List(Projectile),
  enemies: List(Enemy(id)),
  delta_time: Float,
  damage_enemy_msg: fn(id, Float, Vec3(Float)) -> msg,
) -> #(List(Projectile), effect.Effect(msg)) {
  let #(projectiles, effect, _hits) =
    update_with_hits(projectiles, enemies, delta_time, damage_enemy_msg)
  #(projectiles, effect)
}

fn update_position(projectile: Projectile, delta_time: Float) -> Projectile {
  let Vec3(x, y, z) = projectile.position
  let Vec3(dx, dy, dz) = projectile.direction

  let speed = projectile.spell.final_speed
  let new_x = x +. dx *. speed *. delta_time
  let new_y = y +. dy *. speed *. delta_time
  let new_z = z +. dz *. speed *. delta_time

  let new_time_alive = projectile.time_alive +. delta_time

  Projectile(
    ..projectile,
    position: Vec3(new_x, new_y, new_z),
    time_alive: new_time_alive,
  )
}

pub fn view(
  id: fn(Int) -> id,
  projectiles: List(Projectile),
) -> List(scene.Node(id)) {
  list.map(projectiles, fn(projectile) {
    let assert Ok(sphere) =
      geometry.sphere(
        radius: projectile.spell.final_size,
        width_segments: 8,
        height_segments: 6,
      )

    let assert Ok(material) =
      material.new()
      |> material.with_color(0xff4444)
      |> material.build()

    scene.mesh(
      id: id(int.random(1_000_000)),
      geometry: sphere,
      material:,
      transform: transform.at(projectile.position),
      physics: option.None,
    )
  })
}
