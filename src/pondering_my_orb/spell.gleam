import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
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

// Constants for projectile and effect behavior
const beam_first_frame_threshold = 0.05

const projectile_hit_lifetime = 1.5

const beam_lightning_offset = 0.2

const min_projectile_size = 0.1

pub type Id {
  Fireball
  LightningBolt
  Spark
  Piercing
  DoubleSpell
  AddMana
  AddDamage
  OrbitingSpell
}

pub type Spell {
  DamageSpell(id: Id, kind: DamageSpell)
  ModifierSpell(id: Id, kind: ModifierSpell)
  MulticastSpell(id: Id, kind: MulticastSpell)
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

/// Composable effects that spells can apply on hit
pub type SpellEffect {
  /// Damages all enemies within radius of impact
  AreaOfEffect(radius: Float)
  /// Applies burning status effect to hit enemies
  ApplyBurning(duration: Float, damage_per_second: Float)
  /// Projectile passes through enemies instead of being destroyed
  PiercingShot
}

pub type DamageSpell {
  Damage(
    name: String,
    mana_cost: Float,
    damage: Float,
    projectile_speed: Float,
    projectile_lifetime: Float,
    projectile_size: Float,
    cast_delay_addition: Float,
    critical_chance: Float,
    spread: Float,
    visuals: SpellVisuals,
    ui_sprite: String,
    on_hit_effects: List(SpellEffect),
    is_beam: Bool,
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
    cast_delay_multiplier: Float,
    cast_delay_addition: Float,
    recharge_multiplier: Float,
    recharge_addition: Float,
    critical_chance_multiplier: Float,
    critical_chance_addition: Float,
    spread_multiplier: Float,
    spread_addition: Float,
    added_effects: List(SpellEffect),
    ui_sprite: String,
  )
}

pub fn default_modifier(name: String, ui_sprite: String) {
  Modifier(
    name:,
    mana_cost: 0.0,
    damage_multiplier: 1.0,
    damage_addition: 0.0,
    projectile_speed_multiplier: 1.0,
    projectile_speed_addition: 0.0,
    projectile_size_multiplier: 1.0,
    projectile_size_addition: 0.0,
    projectile_lifetime_multiplier: 1.0,
    projectile_lifetime_addition: 0.0,
    cast_delay_multiplier: 1.0,
    cast_delay_addition: 0.0,
    recharge_multiplier: 1.0,
    recharge_addition: 0.0,
    critical_chance_multiplier: 1.0,
    critical_chance_addition: 0.0,
    spread_multiplier: 1.0,
    spread_addition: 0.0,
    added_effects: [],
    ui_sprite:,
  )
}

/// Type of projectile behavior
pub type ProjectileType {
  /// Standard projectile that moves through space
  Standard
  /// Beam that connects two points (like lightning)
  Beam(target_position: Vec3(Float))
  /// Orbits around a center point (typically the player)
  Orbiting(
    center_position: Vec3(Float),
    orbit_angle: Float,
    orbit_radius: Float,
    orbit_speed: Float,
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
    projectile_type: ProjectileType,
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
    final_cast_delay: Float,
    final_recharge_time: Float,
    final_critical_chance: Float,
    final_spread: Float,
    total_mana_cost: Float,
  )
}

/// Apply a list of modifiers to a damaging spell
pub fn apply_modifiers(
  id: Id,
  base_spell: DamageSpell,
  modifiers: iv.Array(ModifierSpell),
) -> ModifiedSpell {
  // Collect all added effects from modifiers
  let added_effects =
    iv.fold(modifiers, [], fn(acc, mod) { list.append(acc, mod.added_effects) })

  // Merge added effects with base spell effects
  let final_effects = list.append(base_spell.on_hit_effects, added_effects)

  // Update base spell with merged effects
  let modified_base_spell = Damage(..base_spell, on_hit_effects: final_effects)

  // Fold over all modifiers to calculate final values
  let #(
    damage,
    speed,
    size,
    lifetime,
    cast_delay,
    recharge_time,
    crit_chance,
    spread,
  ) =
    iv.fold(
      modifiers,
      #(
        base_spell.damage,
        base_spell.projectile_speed,
        base_spell.projectile_size,
        base_spell.projectile_lifetime,
        base_spell.cast_delay_addition,
        0.0,
        base_spell.critical_chance,
        base_spell.spread,
      ),
      fn(acc, mod) {
        let #(
          damage,
          speed,
          size,
          lifetime,
          cast_delay,
          recharge_time,
          crit_chance,
          spread,
        ) = acc
        #(
          damage +. mod.damage_addition,
          speed +. mod.projectile_speed_addition,
          size +. mod.projectile_size_addition,
          lifetime +. mod.projectile_lifetime_addition,
          cast_delay +. mod.cast_delay_addition,
          recharge_time +. mod.recharge_addition,
          crit_chance +. mod.critical_chance_addition,
          spread +. mod.spread_addition,
        )
      },
    )
  let #(
    final_damage,
    final_speed,
    final_size,
    final_lifetime,
    final_cast_delay,
    final_recharge_time,
    final_critical_chance,
    final_spread,
    total_mana_cost,
  ) =
    iv.fold(
      modifiers,
      #(
        damage,
        speed,
        size,
        lifetime,
        cast_delay,
        recharge_time,
        crit_chance,
        spread,
        base_spell.mana_cost,
      ),
      fn(acc, mod) {
        let #(
          damage,
          speed,
          size,
          lifetime,
          cast_delay,
          recharge_time,
          crit_chance,
          spread,
          mana_cost,
        ) = acc
        #(
          damage *. mod.damage_multiplier,
          speed *. mod.projectile_speed_multiplier,
          size *. mod.projectile_size_multiplier,
          lifetime *. mod.projectile_lifetime_multiplier,
          cast_delay *. mod.cast_delay_multiplier,
          recharge_time *. mod.recharge_multiplier,
          crit_chance *. mod.critical_chance_multiplier,
          spread *. mod.spread_multiplier,
          mana_cost +. mod.mana_cost,
        )
      },
    )

  ModifiedSpell(
    base: DamageSpell(id:, kind: modified_base_spell),
    final_damage:,
    final_speed:,
    final_size:,
    final_lifetime:,
    final_cast_delay:,
    final_recharge_time:,
    final_critical_chance:,
    final_spread:,
    total_mana_cost:,
  )
}

// Pre-defined spells for convenience

/// Basic projectile spell
pub fn spark(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: Spark,
    kind: Damage(
      name: "Spark",
      damage: 3.0,
      projectile_speed: 50.0,
      projectile_lifetime: 2.0,
      mana_cost: 5.0,
      projectile_size: 1.0,
      cast_delay_addition: 0.05,
      critical_chance: 0.05,
      spread: 5.0,
      visuals:,
      ui_sprite: "spell_icons/spark.png",
      on_hit_effects: [AreaOfEffect(2.0)],
      is_beam: False,
    ),
  )
}

/// Heavy damage spell - Beam type that connects player to enemy
pub fn lightning(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: LightningBolt,
    kind: Damage(
      name: "Lightning Bolt",
      damage: 100.0,
      projectile_speed: 0.0,
      projectile_lifetime: 0.3,
      mana_cost: 100.0,
      projectile_size: 1.0,
      cast_delay_addition: 0.0,
      critical_chance: 0.15,
      spread: 0.0,
      visuals:,
      ui_sprite: "spell_icons/lightning_bolt.png",
      on_hit_effects: [AreaOfEffect(10.0)],
      is_beam: True,
    ),
  )
}

/// Firebolt - Explodes on impact, damaging enemies in an area and setting them on fire
pub fn fireball(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: Fireball,
    kind: Damage(
      name: "Firebolt",
      damage: 5.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.5,
      mana_cost: 15.0,
      projectile_size: 2.0,
      cast_delay_addition: 0.0,
      critical_chance: 0.1,
      spread: 10.0,
      visuals:,
      ui_sprite: "spell_icons/fireball.png",
      on_hit_effects: [
        AreaOfEffect(radius: 5.0),
        ApplyBurning(duration: 3.0, damage_per_second: 1.0),
      ],
      is_beam: False,
    ),
  )
}

/// Orbiting Spell - Creates a projectile that orbits around the player and damages enemies on contact
pub fn orbiting_spell(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: OrbitingSpell,
    kind: Damage(
      name: "Orbiting Spell",
      damage: 4.0,
      projectile_speed: 2.0,
      projectile_lifetime: 30.0,
      mana_cost: 50.0,
      projectile_size: 1.5,
      cast_delay_addition: 0.0,
      critical_chance: 0.05,
      spread: 0.0,
      visuals:,
      ui_sprite: "spell_icons/orbiting_shards.png",
      on_hit_effects: [],
      is_beam: False,
    ),
  )
}

pub fn rapid_fire() -> Spell {
  ModifierSpell(
    id: AddDamage,
    kind: Modifier(
      ..default_modifier("Rapid Fire", "spell_icons/rapid_fire.png"),
      cast_delay_addition: -17.0,
      recharge_addition: -0.33,
    ),
  )
}

/// Double Spell - casts 2 spells at once (no mana cost)
pub fn double_spell() -> Spell {
  MulticastSpell(
    id: DoubleSpell,
    kind: Multicast(
      name: "Double Spell",
      mana_cost: 0.0,
      spell_count: Fixed(2),
      draw_add: 2,
      ui_sprite: "spell_icons/double_spell.png",
    ),
  )
}

pub fn add_mana() -> Spell {
  ModifierSpell(
    id: AddMana,
    kind: Modifier(
      ..default_modifier("Add Mana", "spell_icons/mana.png"),
      mana_cost: -30.0,
    ),
  )
}

pub fn add_damage() -> Spell {
  ModifierSpell(
    id: AddDamage,
    kind: Modifier(
      ..default_modifier("Add Damage", "spell_icons/add_damage.png"),
      damage_addition: 10.0,
    ),
  )
}

pub fn piercing() -> Spell {
  ModifierSpell(
    id: Piercing,
    kind: Modifier(
      ..default_modifier("Piercing", "spell_icons/piercing.png"),
      mana_cost: 130.0,
      added_effects: [PiercingShot],
    ),
  )
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
    // Effects to apply to the hit enemy
    spell_effects: List(SpellEffect),
  )
}

/// Helper to get the base damage spell from a modified spell
fn get_base_damage_spell(modified: ModifiedSpell) -> DamageSpell {
  case modified.base {
    DamageSpell(_, damage_spell) -> damage_spell
    _ -> panic as "Expected DamageSpell"
  }
}

/// Check if a spell has the PiercingShot effect
fn has_piercing(spell_effects: List(SpellEffect)) -> Bool {
  list.any(spell_effects, fn(effect) {
    case effect {
      PiercingShot -> True
      _ -> False
    }
  })
}

/// Convert spell effects to enemy applied effects (avoids circular dependency)
pub fn spell_effects_to_applied(
  effects: List(SpellEffect),
) -> List(enemy.AppliedSpellEffect) {
  list.filter_map(effects, fn(effect) {
    case effect {
      AreaOfEffect(radius) -> Ok(enemy.AppliedAreaOfEffect(radius))
      ApplyBurning(duration, dps) -> Ok(enemy.AppliedBurning(duration, dps))
      // PiercingShot is handled at projectile level, not applied to enemies
      PiercingShot -> Error(Nil)
    }
  })
}

/// Realign orbiting projectiles evenly around the player
/// Preserves rotation by using first projectile's angle as reference
fn realign_orbiting_projectiles(
  projectiles: List(Projectile),
  player_position: Vec3(Float),
) -> List(Projectile) {
  let #(orbiting, non_orbiting) =
    list.partition(projectiles, fn(p) {
      case p.projectile_type {
        Orbiting(..) -> True
        _ -> False
      }
    })

  let orbiting_count = list.length(orbiting)
  use <- bool.guard(orbiting_count == 0, return: projectiles)

  let assert [first, ..] = orbiting
  let assert Orbiting(_, base_rotation, _, _) = first.projectile_type

  let angle_spacing = maths.pi() *. 2.0 /. int.to_float(orbiting_count)

  let realigned_orbiting =
    list.index_map(orbiting, fn(p, index) {
      let assert Orbiting(_, _, radius, speed) = p.projectile_type

      let angle = int.to_float(index) *. angle_spacing +. base_rotation
      let normalized_angle = normalize_angle(angle)

      let position =
        Vec3(
          player_position.x +. radius *. maths.cos(normalized_angle),
          player_position.y,
          player_position.z +. radius *. maths.sin(normalized_angle),
        )

      let direction =
        Vec3(
          -1.0 *. maths.sin(normalized_angle),
          0.0,
          maths.cos(normalized_angle),
        )

      Projectile(
        ..p,
        position: position,
        direction: direction,
        projectile_type: Orbiting(
          center_position: player_position,
          orbit_angle: normalized_angle,
          orbit_radius: radius,
          orbit_speed: speed,
        ),
      )
    })

  list.append(realigned_orbiting, non_orbiting)
}

/// Normalize angle to 0-2π range
fn normalize_angle(angle: Float) -> Float {
  let two_pi = maths.pi() *. 2.0
  let normalized = angle -. two_pi *. float.floor(angle /. two_pi)
  normalized
}

pub fn update(
  projectiles: List(Projectile),
  enemies: List(Enemy(id)),
  delta_time: Float,
  damage_enemy_msg: fn(id, Float, Vec3(Float), List(SpellEffect)) -> msg,
  player_position: Vec3(Float),
) -> #(List(Projectile), List(ProjectileHit(id)), effect.Effect(msg)) {
  let updated_projectiles =
    list.map(projectiles, fn(p) {
      update_position(p, delta_time /. 1000.0, player_position)
    })

  let aligned_projectiles =
    realign_orbiting_projectiles(updated_projectiles, player_position)

  // Check each projectile against each enemy for collisions
  let #(hits, remaining_projectiles) =
    list.fold(
      over: aligned_projectiles,
      from: #([], []),
      with: fn(acc, projectile) {
        let #(hits, remaining) = acc

        // Handle beams differently - they only hit on spawn, but persist visually
        case projectile.projectile_type {
          Beam(target_position) -> {
            // Beams always remain visible (added to remaining)
            // But only create hits on their first frame
            case projectile.time_alive <. beam_first_frame_threshold {
              True -> {
                // First frame - check for hit and create damage
                let hit_enemy =
                  list.find(enemies, fn(enemy) {
                    vec3f.distance(target_position, enemy.position) <=. 2.0
                  })

                case hit_enemy {
                  Ok(enemy) -> {
                    let base_spell = get_base_damage_spell(projectile.spell)
                    let hit =
                      ProjectileHit(
                        id: projectile.id,
                        direction: projectile.direction,
                        enemy_id: enemy.id,
                        damage: projectile.spell.final_damage,
                        position: target_position,
                        time_alive: 0.0,
                        animation_state: spritesheet.initial_state("hit"),
                        spritesheet: projectile.visuals.hit_spritesheet,
                        animation: projectile.visuals.hit_animation,
                        spell_effects: base_spell.on_hit_effects,
                      )
                    #([hit, ..hits], [projectile, ..remaining])
                  }
                  Error(_) -> #(hits, [projectile, ..remaining])
                }
              }
              False -> {
                // Not first frame - just keep rendering
                #(hits, [projectile, ..remaining])
              }
            }
          }
          Standard -> {
            // Standard projectiles: check collision and remove on hit (unless piercing)
            let hit_enemy =
              list.find(enemies, fn(enemy) {
                vec3f.distance(projectile.position, enemy.position) <=. 1.0
              })

            case hit_enemy {
              Ok(enemy) -> {
                let base_spell = get_base_damage_spell(projectile.spell)
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
                    spell_effects: base_spell.on_hit_effects,
                  )
                // Keep piercing projectiles in remaining list
                case has_piercing(base_spell.on_hit_effects) {
                  True -> #([hit, ..hits], [projectile, ..remaining])
                  False -> #([hit, ..hits], remaining)
                }
              }
              Error(_) -> #(hits, [projectile, ..remaining])
            }
          }
          Orbiting(..) -> {
            // Orbiting projectiles: check collision, but don't remove on hit (persistent orbit)
            let hit_enemy =
              list.find(enemies, fn(enemy) {
                vec3f.distance(projectile.position, enemy.position) <=. 1.0
              })

            case hit_enemy {
              Ok(enemy) -> {
                let base_spell = get_base_damage_spell(projectile.spell)
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
                    spell_effects: base_spell.on_hit_effects,
                  )

                #([hit, ..hits], [projectile, ..remaining])
              }
              Error(_) -> #(hits, [projectile, ..remaining])
            }
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

  // Create effects for each hit
  // For AOE spells, we need to damage all enemies in radius
  let effects =
    list.flat_map(hits, fn(hit) {
      // Get AOE radius if any
      let aoe_radius =
        list.find_map(hit.spell_effects, fn(effect) {
          case effect {
            AreaOfEffect(radius) -> Ok(radius)
            _ -> Error(Nil)
          }
        })
        |> result.unwrap(0.0)

      // Find all enemies in AOE range
      case aoe_radius >. 0.0 {
        True -> {
          // Damage all enemies within AOE radius
          list.filter_map(enemies, fn(enemy) {
            let distance = vec3f.distance(hit.position, enemy.position)
            case distance <=. aoe_radius {
              True ->
                Ok(
                  effect.from(fn(dispatch) {
                    dispatch(damage_enemy_msg(
                      enemy.id,
                      hit.damage,
                      hit.direction,
                      hit.spell_effects,
                    ))
                  }),
                )
              False -> Error(Nil)
            }
          })
        }
        False -> {
          // Single target - only damage the hit enemy
          [
            effect.from(fn(dispatch) {
              dispatch(damage_enemy_msg(
                hit.enemy_id,
                hit.damage,
                hit.direction,
                hit.spell_effects,
              ))
            }),
          ]
        }
      }
    })

  #(final_projectiles, hits, effect.batch(effects))
}

fn update_position(
  projectile: Projectile,
  delta_time: Float,
  player_position: Vec3(Float),
) -> Projectile {
  let new_time_alive = projectile.time_alive +. delta_time

  // Update animation state using projectile's own animation
  let new_animation_state =
    spritesheet.update(
      projectile.animation_state,
      projectile.visuals.projectile_animation,
      delta_time *. 1000.0,
    )

  // Beam projectiles don't move, standard projectiles do, orbiting projectiles orbit
  case projectile.projectile_type {
    Beam(_) ->
      Projectile(
        ..projectile,
        time_alive: new_time_alive,
        animation_state: new_animation_state,
      )
    Standard -> {
      let Vec3(x, y, z) = projectile.position
      let Vec3(dx, dy, dz) = projectile.direction

      let speed = projectile.spell.final_speed
      let new_x = x +. dx *. speed *. delta_time
      let new_y = y +. dy *. speed *. delta_time
      let new_z = z +. dz *. speed *. delta_time

      Projectile(
        ..projectile,
        position: Vec3(new_x, new_y, new_z),
        time_alive: new_time_alive,
        animation_state: new_animation_state,
      )
    }
    Orbiting(
      center_position: _,
      orbit_angle: current_angle,
      orbit_radius: radius,
      orbit_speed: speed,
    ) -> {
      Projectile(
        ..projectile,
        time_alive: new_time_alive,
        animation_state: new_animation_state,
        projectile_type: Orbiting(
          center_position: player_position,
          orbit_angle: current_angle +. speed *. delta_time,
          orbit_radius: radius,
          orbit_speed: speed,
        ),
      )
    }
  }
}

/// Update projectile hits and remove those that have finished
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
  |> list.filter(fn(hit) { hit.time_alive <. projectile_hit_lifetime })
}

pub fn view(
  id: fn(Int) -> id,
  projectiles: List(Projectile),
  camera_position: Vec3(Float),
) -> List(scene.Node(id)) {
  list.flat_map(projectiles, fn(projectile) {
    case projectile.projectile_type {
      Standard -> [view_standard_projectile(id, projectile, camera_position)]
      Beam(target_position) ->
        view_beam_projectile(id, projectile, target_position, camera_position)
      Orbiting(_, _, _, _) -> [
        view_standard_projectile(id, projectile, camera_position),
      ]
    }
  })
}

fn view_standard_projectile(
  id: fn(Int) -> id,
  projectile: Projectile,
  camera_position: Vec3(Float),
) -> scene.Node(id) {
  // Constrained billboard: sprite faces camera while aligning with travel direction
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
}

fn view_beam_projectile(
  id: fn(Int) -> id,
  projectile: Projectile,
  target_position: Vec3(Float),
  camera_position: Vec3(Float),
) -> List(scene.Node(id)) {
  // Calculate beam direction and length
  let beam_vector = vec3f.subtract(target_position, projectile.position)
  let beam_length = vec3f.length(beam_vector)
  let beam_direction = vec3f.normalize(beam_vector)

  // Size of each sprite segment - ensure it's not zero or negative
  let segment_size = float.max(projectile.spell.final_size, min_projectile_size)
  let segment_count = float.ceiling(beam_length /. segment_size)
  let segment_count_int = float.floor(segment_count) |> float.round()

  // Create list of segments along the beam
  list.range(0, segment_count_int - 1)
  |> list.map(fn(i) {
    // Calculate position for this segment
    let t = int.to_float(i) *. segment_size
    let segment_pos =
      Vec3(
        projectile.position.x +. beam_direction.x *. t,
        projectile.position.y +. beam_direction.y *. t,
        projectile.position.z +. beam_direction.z *. t,
      )

    // Add slight random offset perpendicular to beam for lightning effect
    let offset_amount = beam_lightning_offset
    let random_offset_x = { float.random() -. 0.5 } *. offset_amount
    let random_offset_y = { float.random() -. 0.5 } *. offset_amount

    // Find perpendicular vectors to beam_direction
    let up = Vec3(0.0, 1.0, 0.0)
    let right = vec3f.normalize(vec3f.cross(beam_direction, up))
    let actual_up = vec3f.normalize(vec3f.cross(right, beam_direction))

    let offset_pos =
      Vec3(
        segment_pos.x
          +. right.x
          *. random_offset_x
          +. actual_up.x
          *. random_offset_y,
        segment_pos.y
          +. right.y
          *. random_offset_x
          +. actual_up.y
          *. random_offset_y,
        segment_pos.z
          +. right.z
          *. random_offset_x
          +. actual_up.z
          *. random_offset_y,
      )

    // Build rotation facing camera
    let rotation =
      constrained_billboard_rotation(
        offset_pos,
        beam_direction,
        camera_position,
      )

    scene.animated_sprite(
      id: id(projectile.id * 1000 + i),
      spritesheet: projectile.visuals.projectile_spritesheet,
      animation: projectile.visuals.projectile_animation,
      state: projectile.animation_state,
      width: segment_size,
      height: segment_size,
      transform: transform.at(position: offset_pos)
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
  // The hit sprite should face the camera
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
