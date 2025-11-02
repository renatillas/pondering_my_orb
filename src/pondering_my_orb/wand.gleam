import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam_community/maths
import iv
import pondering_my_orb/spell.{type Spell}
import tiramisu/spritesheet
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

/// Represents a wand with spell slots
pub type Wand {
  Wand(
    name: String,
    slots: iv.Array(Option(Spell)),
    max_mana: Float,
    current_mana: Float,
    mana_recharge_rate: Float,
    cast_delay: Float,
    recharge_time: Float,
    spells_per_cast: Int,
    spread: Float,
  )
}

/// Result of casting from a wand
pub type CastResult {
  /// Successfully cast spells (can be multiple due to draw system)
  CastSuccess(
    projectiles: List(spell.Projectile),
    remaining_mana: Float,
    next_cast_index: Int,
    casting_indices: List(Int),
    did_wrap: Bool,
    total_cast_delay_addition: Float,
  )
  /// Not enough mana to cast
  NotEnoughMana(required: Float, available: Float)
  /// No damaging spell found (all modifiers)
  NoSpellToCast
  /// Reached end of wand
  WandEmpty
}

/// Create a new wand
pub fn new(
  name name: String,
  slot_count slot_count: Int,
  max_mana max_mana: Float,
  mana_recharge_rate mana_recharge_rate: Float,
  cast_delay cast_delay: Float,
  recharge_time recharge_time: Float,
  spells_per_cast spells_per_cast: Int,
  spread spread: Float,
) -> Wand {
  Wand(
    name:,
    slots: iv.repeat(None, slot_count),
    max_mana:,
    current_mana: max_mana,
    mana_recharge_rate:,
    cast_delay:,
    recharge_time:,
    spells_per_cast:,
    spread:,
  )
}

/// Create a new wand with random stats
pub fn new_random(name: String) -> Wand {
  let slot_count = case float.random() {
    r if r <. 0.5 -> 2
    _ -> 3
  }

  let cast_delay = 0.15 +. float.random() *. 0.1
  let recharge_time = 0.33 +. float.random() *. 0.14
  let max_mana = 80.0 +. float.random() *. 50.0
  let mana_recharge_rate = 25.0 +. float.random() *. 15.0
  let spread = 0.0

  new(
    name:,
    slot_count:,
    max_mana:,
    mana_recharge_rate:,
    cast_delay:,
    recharge_time:,
    spells_per_cast: 1,
    spread:,
  )
}

pub fn set_spell(wand: Wand, slot_index: Int, spell: Spell) -> Result(Wand, Nil) {
  case iv.get(wand.slots, slot_index) {
    Ok(None) -> {
      use slots <- result.map(iv.set(
        wand.slots,
        at: slot_index,
        to: Some(spell),
      ))
      Wand(..wand, slots:)
    }
    Error(Nil) | Ok(Some(_)) -> Error(Nil)
  }
}

pub fn remove_spell(wand: Wand, slot_index: Int) -> Result(Wand, Nil) {
  use slots <- result.map(iv.delete(from: wand.slots, at: slot_index))
  Wand(..wand, slots:)
}

pub fn get_spell(wand: Wand, slot_index: Int) -> Result(Option(Spell), Nil) {
  wand.slots
  |> iv.get(slot_index)
}

/// Cast spells from the wand starting at a given index using the draw system
/// Processes spells until draw is exhausted, collecting all projectiles
pub fn cast(
  wand: Wand,
  start_index: Int,
  position: Vec3(Float),
  direction: Vec3(Float),
  projectile_starting_index: Int,
  target_position: option.Option(Vec3(Float)),
  player_center: option.Option(Vec3(Float)),
  existing_projectiles: List(spell.Projectile),
) -> #(CastResult, Wand) {
  case start_index >= iv.length(wand.slots) {
    True -> #(WandEmpty, wand)
    False -> {
      // Start with the wand's spells_per_cast as initial draw
      process_with_draw(
        wand,
        start_index,
        wand.spells_per_cast,
        iv.new(),
        [],
        [],
        0.0,
        0.0,
        position,
        direction,
        projectile_starting_index,
        target_position,
        player_center,
        existing_projectiles,
        False,
        start_index,
      )
    }
  }
}

/// Maximum number of orbiting projectiles allowed at once
const max_orbiting_projectiles = 8

/// Count existing orbiting projectiles
fn count_orbiting_projectiles(projectiles: List(spell.Projectile)) -> Int {
  projectiles
  |> list.filter(fn(p) {
    case p.projectile_type {
      spell.Orbiting(_, _, _, _) -> True
      _ -> False
    }
  })
  |> list.length
}

/// Process spells with the draw system
/// Continues processing spells until draw is exhausted, with wrapping support
fn process_with_draw(
  wand: Wand,
  current_index: Int,
  remaining_draw: Int,
  accumulated_modifiers: iv.Array(spell.ModifierSpell),
  projectiles: List(spell.Projectile),
  casting_indices: List(Int),
  total_mana_used: Float,
  total_cast_delay_addition: Float,
  position: Vec3(Float),
  direction: Vec3(Float),
  projectile_id: Int,
  target_position: option.Option(Vec3(Float)),
  player_center: option.Option(Vec3(Float)),
  existing_projectiles: List(spell.Projectile),
  wrapped_during_cast: Bool,
  original_start_index: Int,
) -> #(CastResult, Wand) {
  let wand_length = iv.length(wand.slots)

  // Check if wand is empty
  case wand_length {
    0 -> #(WandEmpty, wand)
    _ -> {
      // Check if we're out of draw
      case remaining_draw <= 0 {
        True -> {
          // End of cast cycle
          case projectiles {
            [] -> #(NoSpellToCast, wand)
            _ -> {
              let new_mana = wand.current_mana -. total_mana_used
              let updated_wand = Wand(..wand, current_mana: new_mana)

              let next_index = current_index % wand_length
              let has_spells_ahead = has_any_spell_from(wand.slots, next_index)

              // Wrap if we actually wrapped during the cast OR no spells remain ahead
              let did_wrap = wrapped_during_cast || !has_spells_ahead

              #(
                CastSuccess(
                  projectiles:,
                  remaining_mana: new_mana,
                  next_cast_index: next_index,
                  casting_indices:,
                  did_wrap:,
                  total_cast_delay_addition:,
                ),
                updated_wand,
              )
            }
          }
        }
        False -> {
          // Wrap index if we've gone past the end
          let wrapped_index = current_index % wand_length
          // Track if we wrapped around (processing spells from beginning after passing end)
          let is_wrapping = current_index >= wand_length
          let wrapped_flag = wrapped_during_cast || is_wrapping

          // Stop if we've wrapped back to or past the original start (completed full cycle)
          // This prevents infinite loops when draw remains but all spells processed
          let completed_cycle =
            wrapped_flag && wrapped_index >= original_start_index
          case completed_cycle {
            True -> {
              // End cast - we've processed all available spells
              case projectiles {
                [] -> #(NoSpellToCast, wand)
                _ -> {
                  let new_mana = wand.current_mana -. total_mana_used
                  let updated_wand = Wand(..wand, current_mana: new_mana)
                  let next_index = wrapped_index
                  let has_spells_ahead =
                    has_any_spell_from(wand.slots, next_index)
                  let did_wrap = wrapped_flag || !has_spells_ahead

                  #(
                    CastSuccess(
                      projectiles:,
                      remaining_mana: new_mana,
                      next_cast_index: next_index,
                      casting_indices:,
                      did_wrap:,
                      total_cast_delay_addition:,
                    ),
                    updated_wand,
                  )
                }
              }
            }
            False -> {
              // Continue processing
              // Get current spell slot
              case iv.get(wand.slots, wrapped_index) {
                Error(_) -> #(WandEmpty, wand)
                Ok(None) -> {
                  // Empty slot, skip but don't consume draw (like modifiers)
                  // This allows multicasts to continue past empty slots
                  process_with_draw(
                    wand,
                    current_index + 1,
                    remaining_draw,
                    accumulated_modifiers,
                    projectiles,
                    [wrapped_index, ..casting_indices],
                    total_mana_used,
                    total_cast_delay_addition,
                    position,
                    direction,
                    projectile_id,
                    target_position,
                    player_center,
                    existing_projectiles,
                    wrapped_flag,
                    original_start_index,
                  )
                }
                Ok(Some(current_spell)) -> {
                  // Process the spell based on type
                  case current_spell {
                    spell.ModifierSpell(_, mod) -> {
                      // Modifiers: accumulate but DON'T consume draw (they draw the next spell automatically)
                      // Modifier mana cost is included in the modified spell's total cost, not charged separately
                      let new_modifiers = iv.prepend(accumulated_modifiers, mod)

                      process_with_draw(
                        wand,
                        current_index + 1,
                        remaining_draw,
                        new_modifiers,
                        projectiles,
                        [wrapped_index, ..casting_indices],
                        total_mana_used,
                        total_cast_delay_addition,
                        position,
                        direction,
                        projectile_id,
                        target_position,
                        player_center,
                        existing_projectiles,
                        wrapped_flag,
                        original_start_index,
                      )
                    }

                    spell.MulticastSpell(_, multicast) -> {
                      // Multicast: consume 1 draw, add draw_add, process next spells
                      let new_draw = remaining_draw - 1 + multicast.draw_add
                      let new_mana_used = total_mana_used +. multicast.mana_cost

                      // Check mana
                      case wand.current_mana >=. new_mana_used {
                        True ->
                          process_with_draw(
                            wand,
                            current_index + 1,
                            new_draw,
                            accumulated_modifiers,
                            projectiles,
                            [wrapped_index, ..casting_indices],
                            new_mana_used,
                            total_cast_delay_addition,
                            position,
                            direction,
                            projectile_id,
                            target_position,
                            player_center,
                            existing_projectiles,
                            wrapped_flag,
                            original_start_index,
                          )
                        False -> #(
                          NotEnoughMana(
                            required: new_mana_used,
                            available: wand.current_mana,
                          ),
                          wand,
                        )
                      }
                    }

                    spell.DamageSpell(id, damaging) ->
                      process_damage_spell(
                        wand,
                        id,
                        damaging,
                        current_index,
                        wrapped_index,
                        remaining_draw,
                        accumulated_modifiers,
                        projectiles,
                        casting_indices,
                        total_mana_used,
                        total_cast_delay_addition,
                        position,
                        direction,
                        projectile_id,
                        target_position,
                        player_center,
                        existing_projectiles,
                        wrapped_flag,
                        original_start_index,
                      )
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

/// Process a damage spell (handles both orbiting and standard projectiles)
fn process_damage_spell(
  wand: Wand,
  id: spell.Id,
  damaging: spell.DamageSpell,
  current_index: Int,
  wrapped_index: Int,
  remaining_draw: Int,
  accumulated_modifiers: iv.Array(spell.ModifierSpell),
  projectiles: List(spell.Projectile),
  casting_indices: List(Int),
  total_mana_used: Float,
  total_cast_delay_addition: Float,
  position: Vec3(Float),
  direction: Vec3(Float),
  projectile_id: Int,
  target_position: option.Option(Vec3(Float)),
  player_center: option.Option(Vec3(Float)),
  existing_projectiles: List(spell.Projectile),
  wrapped_during_cast: Bool,
  original_start_index: Int,
) -> #(CastResult, Wand) {
  // Check if orbiting spell at limit - skip if so
  case id, is_orbiting_at_limit(existing_projectiles, projectiles) {
    spell.OrbitingSpell, True ->
      process_with_draw(
        wand,
        current_index + 1,
        remaining_draw - 1,
        iv.new(),
        projectiles,
        casting_indices,
        total_mana_used,
        total_cast_delay_addition,
        position,
        direction,
        projectile_id,
        target_position,
        player_center,
        existing_projectiles,
        wrapped_during_cast,
        original_start_index,
      )
    _, _ -> {
      let modified = spell.apply_modifiers(id, damaging, accumulated_modifiers)
      let new_mana_used = total_mana_used +. modified.total_mana_cost
      let new_cast_delay =
        total_cast_delay_addition +. modified.final_cast_delay

      // Check mana availability
      case wand.current_mana <. new_mana_used {
        True -> #(
          NotEnoughMana(required: new_mana_used, available: wand.current_mana),
          wand,
        )
        False -> {
          let spread_direction =
            apply_spread(direction, wand.spread +. modified.final_spread)

          let projectile_type =
            create_projectile_type(
              id,
              damaging,
              target_position,
              player_center,
              position,
              modified.final_speed,
              existing_projectiles,
              projectiles,
            )

          let projectile_position =
            calculate_projectile_position(projectile_type, position)

          let projectile =
            spell.Projectile(
              id: projectile_id,
              spell: modified,
              position: projectile_position,
              direction: spread_direction,
              time_alive: 0.0,
              animation_state: spritesheet.initial_state("projectile"),
              visuals: damaging.visuals,
              projectile_type: projectile_type,
            )

          process_with_draw(
            wand,
            current_index + 1,
            remaining_draw - 1,
            iv.new(),
            [projectile, ..projectiles],
            [wrapped_index, ..casting_indices],
            new_mana_used,
            new_cast_delay,
            position,
            direction,
            projectile_id + 1,
            target_position,
            player_center,
            existing_projectiles,
            wrapped_during_cast,
            original_start_index,
          )
        }
      }
    }
  }
}

/// Check if orbiting projectiles are at maximum limit
fn is_orbiting_at_limit(
  existing_projectiles: List(spell.Projectile),
  current_projectiles: List(spell.Projectile),
) -> Bool {
  let total =
    count_orbiting_projectiles(existing_projectiles)
    + count_orbiting_projectiles(current_projectiles)
  total >= max_orbiting_projectiles
}

/// Create the appropriate projectile type based on spell
fn create_projectile_type(
  id: spell.Id,
  damaging: spell.DamageSpell,
  target_position: option.Option(Vec3(Float)),
  player_center: option.Option(Vec3(Float)),
  cast_position: Vec3(Float),
  speed: Float,
  existing_projectiles: List(spell.Projectile),
  current_projectiles: List(spell.Projectile),
) -> spell.ProjectileType {
  case damaging.is_beam, target_position, id {
    True, option.Some(target), _ -> spell.Beam(target)
    _, _, spell.OrbitingSpell ->
      create_orbiting_projectile_type(
        player_center,
        cast_position,
        speed,
        existing_projectiles,
        current_projectiles,
      )
    _, _, _ -> spell.Standard
  }
}

/// Create an orbiting projectile type with proper spacing
fn create_orbiting_projectile_type(
  player_center: option.Option(Vec3(Float)),
  cast_position: Vec3(Float),
  speed: Float,
  existing_projectiles: List(spell.Projectile),
  current_projectiles: List(spell.Projectile),
) -> spell.ProjectileType {
  let center = option.unwrap(player_center, cast_position)
  let orbit_radius = 3.0

  let total_count =
    count_orbiting_projectiles(existing_projectiles)
    + count_orbiting_projectiles(current_projectiles)

  let angle_spacing =
    maths.pi() *. 2.0 /. int.to_float(max_orbiting_projectiles)
  let initial_angle = int.to_float(total_count) *. angle_spacing

  spell.Orbiting(
    center_position: center,
    orbit_angle: initial_angle,
    orbit_radius: orbit_radius,
    orbit_speed: speed,
  )
}

/// Calculate starting position for projectile based on type
fn calculate_projectile_position(
  projectile_type: spell.ProjectileType,
  default_position: Vec3(Float),
) -> Vec3(Float) {
  case projectile_type {
    spell.Orbiting(center, angle, radius, _) ->
      Vec3(
        center.x +. radius *. maths.cos(angle),
        center.y,
        center.z +. radius *. maths.sin(angle),
      )
    _ -> default_position
  }
}

pub fn recharge_mana(wand: Wand, delta_time: Float) -> Wand {
  let new_mana =
    float.min(
      wand.max_mana,
      wand.current_mana +. wand.mana_recharge_rate *. delta_time,
    )
  Wand(..wand, current_mana: new_mana)
}

pub fn spell_count(wand: Wand) -> Int {
  wand.slots
  |> iv.filter(fn(slot) {
    case slot {
      Some(_) -> True
      None -> False
    }
  })
  |> iv.length
}

pub fn is_slot_empty(wand: Wand, slot_index: Int) -> Bool {
  case get_spell(wand, slot_index) {
    Ok(None) -> True
    Ok(Some(_)) -> False
    Error(Nil) -> True
  }
}

pub fn reorder_slots(
  wand: Wand,
  from_index: Int,
  to_index: Int,
) -> Result(Wand, Nil) {
  use new_slots <- result.map(reorder_array(wand.slots, from_index, to_index))
  Wand(..wand, slots: new_slots)
}

fn reorder_array(
  items: iv.Array(a),
  from_index: Int,
  to_index: Int,
) -> Result(iv.Array(a), Nil) {
  case iv.get(items, from_index), iv.delete(items, from_index) {
    Ok(removed_item), Ok(list_without_item) -> {
      iv.insert(list_without_item, to_index, removed_item)
    }
    _, _ -> Ok(items)
  }
}

/// Check if there are any spells from start_index to end of slots
fn has_any_spell_from(slots: iv.Array(Option(Spell)), start_index: Int) -> Bool {
  let length = iv.length(slots)
  check_slots_from(slots, start_index, length)
}

fn check_slots_from(
  slots: iv.Array(Option(Spell)),
  current: Int,
  length: Int,
) -> Bool {
  case current >= length {
    True -> False
    False -> {
      case iv.get(slots, current) {
        Ok(Some(_)) -> True
        _ -> check_slots_from(slots, current + 1, length)
      }
    }
  }
}

/// Apply spread (inaccuracy) to a direction vector
/// spread_degrees: the maximum deviation in degrees (e.g., 5.0 means ±5 degrees)
fn apply_spread(direction: Vec3(Float), spread_degrees: Float) -> Vec3(Float) {
  case spread_degrees {
    0.0 -> direction
    _ -> {
      // Convert spread from degrees to radians
      let spread_radians = spread_degrees *. maths.pi() /. 180.0

      // Generate random angles within the spread cone
      // Random value between -spread and +spread
      let horizontal_angle = { float.random() *. 2.0 -. 1.0 } *. spread_radians
      let vertical_angle = { float.random() *. 2.0 -. 1.0 } *. spread_radians

      // Get perpendicular vectors to the direction
      // Use world up vector to find a perpendicular
      let world_up = Vec3(0.0, 1.0, 0.0)

      // Check if direction is too aligned with world up
      let up_vector = case
        float.absolute_value(vec3f.dot(direction, world_up)) >. 0.99
      {
        True -> Vec3(1.0, 0.0, 0.0)
        False -> world_up
      }

      // Calculate right vector (perpendicular to direction and up)
      let right = vec3f.cross(direction, up_vector) |> vec3f.normalize()

      // Calculate true up vector (perpendicular to direction and right)
      let up = vec3f.cross(right, direction) |> vec3f.normalize()

      // Apply rotations
      // Rotate around right axis (vertical spread)
      let cos_v = maths.cos(vertical_angle)
      let sin_v = maths.sin(vertical_angle)
      let after_vertical =
        Vec3(
          direction.x *. cos_v +. up.x *. sin_v,
          direction.y *. cos_v +. up.y *. sin_v,
          direction.z *. cos_v +. up.z *. sin_v,
        )
        |> vec3f.normalize()

      // Rotate around original direction axis (horizontal spread)
      let cos_h = maths.cos(horizontal_angle)
      let sin_h = maths.sin(horizontal_angle)
      let final_direction =
        Vec3(
          after_vertical.x *. cos_h +. right.x *. sin_h,
          after_vertical.y *. cos_h +. right.y *. sin_h,
          after_vertical.z *. cos_h +. right.z *. sin_h,
        )
        |> vec3f.normalize()

      final_direction
    }
  }
}
