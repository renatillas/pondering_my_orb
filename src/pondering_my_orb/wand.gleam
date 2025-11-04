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
    total_recharge_time_addition: Float,
  )
  /// Not enough mana to cast
  NotEnoughMana(required: Float, available: Float)
  /// No damaging spell found (all modifiers)
  NoSpellToCast
  /// Reached end of wand
  WandEmpty
}

/// Immutable context for a cast operation
type CastContext {
  CastContext(
    position: Vec3(Float),
    direction: Vec3(Float),
    target_position: option.Option(Vec3(Float)),
    player_center: option.Option(Vec3(Float)),
    existing_projectiles: List(spell.Projectile),
    projectile_starting_index: Int,
  )
}

/// Internal state that evolves during a cast operation
type CastState {
  CastState(
    current_index: Int,
    remaining_draw: Int,
    accumulated_modifiers: iv.Array(spell.ModifierSpell),
    projectiles: List(spell.Projectile),
    casting_indices: List(Int),
    total_mana_used: Float,
    total_cast_delay_addition: Float,
    total_recharge_time_addition: Float,
    projectile_id: Int,
    wrapped_during_cast: Bool,
    original_start_index: Int,
    spells_per_cast: Int,
  )
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
      let context =
        CastContext(
          position:,
          direction:,
          target_position:,
          player_center:,
          existing_projectiles:,
          projectile_starting_index:,
        )

      let initial_state =
        CastState(
          current_index: start_index,
          remaining_draw: wand.spells_per_cast,
          accumulated_modifiers: iv.new(),
          projectiles: [],
          casting_indices: [],
          total_mana_used: 0.0,
          total_cast_delay_addition: 0.0,
          total_recharge_time_addition: 0.0,
          projectile_id: projectile_starting_index,
          wrapped_during_cast: False,
          original_start_index: start_index,
          spells_per_cast: wand.spells_per_cast,
        )

      process_with_draw(wand, initial_state, context)
    }
  }
}

/// Maximum number of orbiting projectiles allowed at once
const max_orbiting_projectiles = 8

/// Default orbit radius for orbiting projectiles
const orbit_radius = 3.0

/// Threshold for checking if direction is aligned with world up vector
const direction_alignment_threshold = 0.99

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

/// Create a success result from the current cast state
fn create_success_result(
  wand: Wand,
  state: CastState,
  wrapped_flag: Bool,
) -> #(CastResult, Wand) {
  let new_mana = wand.current_mana -. state.total_mana_used
  let updated_wand = Wand(..wand, current_mana: new_mana)

  let wand_length = iv.length(wand.slots)
  let next_index = state.current_index % wand_length
  let has_spells_ahead = has_any_spell_from(wand.slots, next_index)

  let did_wrap = wrapped_flag || !has_spells_ahead

  #(
    CastSuccess(
      projectiles: state.projectiles,
      remaining_mana: new_mana,
      next_cast_index: next_index,
      casting_indices: state.casting_indices,
      did_wrap:,
      total_cast_delay_addition: state.total_cast_delay_addition,
      total_recharge_time_addition: state.total_recharge_time_addition,
    ),
    updated_wand,
  )
}

/// Process an empty slot (continue without consuming draw)
fn process_empty_slot(
  wand: Wand,
  state: CastState,
  wrapped_index: Int,
  wrapped_flag: Bool,
  context: CastContext,
) -> #(CastResult, Wand) {
  let next_state =
    CastState(
      ..state,
      current_index: state.current_index + 1,
      casting_indices: [wrapped_index, ..state.casting_indices],
      wrapped_during_cast: wrapped_flag,
    )
  process_with_draw(wand, next_state, context)
}

/// Process a modifier spell (accumulate without consuming draw)
fn process_modifier_spell(
  wand: Wand,
  state: CastState,
  modifier: spell.ModifierSpell,
  wrapped_index: Int,
  wrapped_flag: Bool,
  context: CastContext,
) -> #(CastResult, Wand) {
  let new_modifiers = iv.prepend(state.accumulated_modifiers, modifier)
  let next_state =
    CastState(
      ..state,
      current_index: state.current_index + 1,
      accumulated_modifiers: new_modifiers,
      casting_indices: [wrapped_index, ..state.casting_indices],
      wrapped_during_cast: wrapped_flag,
    )
  process_with_draw(wand, next_state, context)
}

/// Process a multicast spell
fn process_multicast_spell(
  wand: Wand,
  state: CastState,
  multicast: spell.MulticastSpell,
  wrapped_index: Int,
  wrapped_flag: Bool,
  context: CastContext,
) -> #(CastResult, Wand) {
  let new_draw = state.remaining_draw - 1 + multicast.draw_add
  let new_mana_used = state.total_mana_used +. multicast.mana_cost

  case wand.current_mana >=. new_mana_used {
    True -> {
      let next_state =
        CastState(
          ..state,
          current_index: state.current_index + 1,
          remaining_draw: new_draw,
          casting_indices: [wrapped_index, ..state.casting_indices],
          total_mana_used: new_mana_used,
          wrapped_during_cast: wrapped_flag,
        )
      process_with_draw(wand, next_state, context)
    }
    False -> #(
      NotEnoughMana(required: new_mana_used, available: wand.current_mana),
      wand,
    )
  }
}

/// Process the next spell in the wand
fn process_next_spell(
  wand: Wand,
  state: CastState,
  context: CastContext,
  wand_length: Int,
) -> #(CastResult, Wand) {
  let wrapped_index = state.current_index % wand_length
  let is_wrapping = state.current_index >= wand_length
  let wrapped_flag = state.wrapped_during_cast || is_wrapping

  // Check if we've completed a full cycle
  let completed_cycle =
    wrapped_flag && wrapped_index >= state.original_start_index

  case completed_cycle {
    True ->
      case state.projectiles {
        [] -> #(NoSpellToCast, wand)
        _ -> create_success_result(wand, state, wrapped_flag)
      }

    False ->
      process_spell_at_index(wand, state, wrapped_index, wrapped_flag, context)
  }
}

/// Process the spell at the current index
fn process_spell_at_index(
  wand: Wand,
  state: CastState,
  wrapped_index: Int,
  wrapped_flag: Bool,
  context: CastContext,
) -> #(CastResult, Wand) {
  case iv.get(wand.slots, wrapped_index) {
    Error(_) -> #(WandEmpty, wand)
    Ok(None) ->
      process_empty_slot(wand, state, wrapped_index, wrapped_flag, context)
    Ok(Some(current_spell)) ->
      case current_spell {
        spell.ModifierSpell(_, modifier) ->
          process_modifier_spell(
            wand,
            state,
            modifier,
            wrapped_index,
            wrapped_flag,
            context,
          )

        spell.MulticastSpell(_, multicast) ->
          process_multicast_spell(
            wand,
            state,
            multicast,
            wrapped_index,
            wrapped_flag,
            context,
          )

        spell.DamageSpell(id, damaging) ->
          process_damage_spell(
            wand,
            id,
            damaging,
            wrapped_index,
            wrapped_flag,
            state,
            context,
          )
      }
  }
}

/// Process spells with the draw system
/// Continues processing spells until draw is exhausted, with wrapping support
fn process_with_draw(
  wand: Wand,
  state: CastState,
  context: CastContext,
) -> #(CastResult, Wand) {
  let wand_length = iv.length(wand.slots)

  // Check if wand is empty
  case wand_length {
    0 -> #(WandEmpty, wand)
    _ ->
      case state.remaining_draw <= 0 {
        // Draw exhausted - end the cast
        True ->
          case state.projectiles {
            [] -> #(NoSpellToCast, wand)
            _ -> create_success_result(wand, state, state.wrapped_during_cast)
          }

        // Continue processing spells
        False -> process_next_spell(wand, state, context, wand_length)
      }
  }
}

/// Check if any modifier in the array has adds_trigger set to True
fn has_trigger_modifier(modifiers: iv.Array(spell.ModifierSpell)) -> Bool {
  iv.fold(modifiers, False, fn(acc, mod) { acc || mod.adds_trigger })
}

/// Collect all indices between start and end (inclusive)
/// Handles wrapping around wand length
fn collect_indices_between(
  start_index: Int,
  end_index: Int,
  wand_length: Int,
) -> List(Int) {
  collect_indices_loop(start_index, end_index, wand_length, [])
}

fn collect_indices_loop(
  current: Int,
  end: Int,
  wand_length: Int,
  acc: List(Int),
) -> List(Int) {
  case current > end {
    True -> list.reverse(acc)
    False -> {
      let wrapped_index = current % wand_length
      collect_indices_loop(current + 1, end, wand_length, [wrapped_index, ..acc])
    }
  }
}

/// Collect modifiers between start and end index (exclusive of end)
/// Used to apply modifiers to trigger payloads
fn collect_modifiers_between(
  slots: iv.Array(Option(Spell)),
  start_index: Int,
  end_index: Int,
  wand_length: Int,
) -> iv.Array(spell.ModifierSpell) {
  collect_modifiers_loop(slots, start_index, end_index, wand_length, iv.new())
}

fn collect_modifiers_loop(
  slots: iv.Array(Option(Spell)),
  current: Int,
  end: Int,
  wand_length: Int,
  acc: iv.Array(spell.ModifierSpell),
) -> iv.Array(spell.ModifierSpell) {
  case current >= end {
    True -> acc
    False -> {
      let wrapped_index = current % wand_length
      let new_acc = case iv.get(slots, wrapped_index) {
        Ok(Some(spell.ModifierSpell(_, modifier))) -> iv.append(acc, modifier)
        _ -> acc
      }
      collect_modifiers_loop(slots, current + 1, end, wand_length, new_acc)
    }
  }
}

/// Find the next damage spell in the wand starting from the given index
/// Returns Option(#(spell.Id, spell.DamageSpell, Int)) with the spell and the index where it was found
/// Only searches forward from start_index, does not wrap back to find spells before it
fn find_next_damage_spell(
  slots: iv.Array(Option(Spell)),
  start_index: Int,
) -> option.Option(#(spell.Id, spell.DamageSpell, Int)) {
  let length = iv.length(slots)
  find_next_damage_spell_loop(slots, start_index, start_index, length, 0)
}

fn find_next_damage_spell_loop(
  slots: iv.Array(Option(Spell)),
  current_index: Int,
  original_start: Int,
  length: Int,
  iterations: Int,
) -> option.Option(#(spell.Id, spell.DamageSpell, Int)) {
  // Prevent infinite loops - max one full cycle
  case iterations >= length {
    True -> option.None
    False -> {
      let wrapped_index = current_index % length
      // Don't return spells at or before the original start during wrapping
      let is_wrapped = current_index >= length
      let would_go_backwards = is_wrapped && wrapped_index <= original_start

      case would_go_backwards {
        True -> option.None
        False -> {
          case iv.get(slots, wrapped_index) {
            Ok(Some(spell.DamageSpell(id, damage_spell))) ->
              option.Some(#(id, damage_spell, current_index))
            Ok(Some(_)) | Ok(None) | Error(_) ->
              find_next_damage_spell_loop(
                slots,
                current_index + 1,
                original_start,
                length,
                iterations + 1,
              )
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
  wrapped_index: Int,
  wrapped_flag: Bool,
  state: CastState,
  context: CastContext,
) -> #(CastResult, Wand) {
  // Check if orbiting spell at limit - skip if so
  case
    id,
    is_orbiting_at_limit(context.existing_projectiles, state.projectiles)
  {
    spell.OrbitingSpell, True -> {
      // Only clear modifiers if we're done with multicast spells
      let new_accumulated_modifiers = case
        state.remaining_draw - 1 >= state.spells_per_cast
      {
        True -> state.accumulated_modifiers
        False -> iv.new()
      }

      let next_state =
        CastState(
          ..state,
          current_index: state.current_index + 1,
          remaining_draw: state.remaining_draw - 1,
          accumulated_modifiers: new_accumulated_modifiers,
          wrapped_during_cast: wrapped_flag,
        )
      process_with_draw(wand, next_state, context)
    }
    _, _ -> {
      let modified =
        spell.apply_modifiers(id, damaging, state.accumulated_modifiers)
      let new_mana_used = state.total_mana_used +. modified.total_mana_cost
      let new_cast_delay =
        state.total_cast_delay_addition +. modified.final_cast_delay
      let new_recharge_time =
        state.total_recharge_time_addition +. modified.final_recharge_time

      // Check mana availability
      case wand.current_mana <. new_mana_used {
        True -> #(
          NotEnoughMana(required: new_mana_used, available: wand.current_mana),
          wand,
        )
        False -> {
          let spread_direction =
            apply_spread(
              context.direction,
              wand.spread +. modified.final_spread,
            )

          let projectile_type =
            create_projectile_type(
              id,
              damaging,
              context.target_position,
              context.player_center,
              context.position,
              modified.final_speed,
              context.existing_projectiles,
              state.projectiles,
            )

          let projectile_position =
            calculate_projectile_position(projectile_type, context.position)

          // Check if this spell needs a trigger payload
          let needs_trigger =
            damaging.has_trigger
            || has_trigger_modifier(state.accumulated_modifiers)

          let #(trigger_payload, payload_info) = case needs_trigger {
            True -> {
              // Look ahead for the next damage spell to use as payload
              case find_next_damage_spell(wand.slots, state.current_index + 1) {
                option.Some(#(payload_id, payload_spell, payload_index)) -> {
                  // Collect modifiers between trigger and payload
                  let wand_length = iv.length(wand.slots)
                  let payload_modifiers =
                    collect_modifiers_between(
                      wand.slots,
                      state.current_index + 1,
                      payload_index,
                      wand_length,
                    )

                  // Apply collected modifiers to the payload
                  let payload_modified =
                    spell.apply_modifiers(
                      payload_id,
                      payload_spell,
                      payload_modifiers,
                    )
                  #(option.Some(payload_modified), option.Some(payload_index))
                }
                option.None -> #(option.None, option.None)
              }
            }
            False -> #(option.None, option.None)
          }

          let projectile =
            spell.Projectile(
              id: state.projectile_id,
              spell: modified,
              position: projectile_position,
              direction: spread_direction,
              time_alive: 0.0,
              animation_state: spritesheet.initial_state("projectile"),
              visuals: damaging.visuals,
              projectile_type: projectile_type,
              trigger_payload: trigger_payload,
            )

          // Only clear modifiers if we're done with multicast spells
          let new_accumulated_modifiers = case
            state.remaining_draw - 1 >= state.spells_per_cast
          {
            True -> state.accumulated_modifiers
            False -> iv.new()
          }

          // If we consumed a payload spell, advance index past it and track all consumed slots
          let #(next_index, updated_casting_indices) = case payload_info {
            option.Some(payload_index) -> {
              // Collect all indices from current+1 to payload_index (inclusive)
              let wand_length = iv.length(wand.slots)
              let indices_to_add =
                collect_indices_between(
                  state.current_index + 1,
                  payload_index,
                  wand_length,
                )
              let all_indices =
                list.append(indices_to_add, [
                  wrapped_index,
                  ..state.casting_indices
                ])
              #(payload_index + 1, all_indices)
            }
            option.None -> #(state.current_index + 1, [
              wrapped_index,
              ..state.casting_indices
            ])
          }

          let next_state =
            CastState(
              ..state,
              current_index: next_index,
              remaining_draw: state.remaining_draw - 1,
              accumulated_modifiers: new_accumulated_modifiers,
              projectiles: [projectile, ..state.projectiles],
              casting_indices: updated_casting_indices,
              total_mana_used: new_mana_used,
              total_cast_delay_addition: new_cast_delay,
              total_recharge_time_addition: new_recharge_time,
              projectile_id: state.projectile_id + 1,
              wrapped_during_cast: wrapped_flag,
            )

          process_with_draw(wand, next_state, context)
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

/// Get perpendicular basis vectors for the given direction
/// Returns #(right, up) vectors perpendicular to the direction
fn get_perpendicular_basis(
  direction: Vec3(Float),
) -> #(Vec3(Float), Vec3(Float)) {
  let world_up = Vec3(0.0, 1.0, 0.0)

  // Use alternative up vector if direction is too aligned with world up
  let up_vector = case
    float.absolute_value(vec3f.dot(direction, world_up))
    >. direction_alignment_threshold
  {
    True -> Vec3(1.0, 0.0, 0.0)
    False -> world_up
  }

  let right = vec3f.cross(direction, up_vector) |> vec3f.normalize()
  let up = vec3f.cross(right, direction) |> vec3f.normalize()

  #(right, up)
}

/// Rotate a vector around an axis by an angle
fn rotate_vector(
  vector: Vec3(Float),
  axis: Vec3(Float),
  angle: Float,
) -> Vec3(Float) {
  let cos_angle = maths.cos(angle)
  let sin_angle = maths.sin(angle)

  Vec3(
    vector.x *. cos_angle +. axis.x *. sin_angle,
    vector.y *. cos_angle +. axis.y *. sin_angle,
    vector.z *. cos_angle +. axis.z *. sin_angle,
  )
  |> vec3f.normalize()
}

/// Generate a random value between -1 and 1
fn random_spread_factor() -> Float {
  float.random() *. 2.0 -. 1.0
}

/// Apply spread (inaccuracy) to a direction vector
/// spread_degrees: the maximum deviation in degrees (e.g., 5.0 means ±5 degrees)
fn apply_spread(direction: Vec3(Float), spread_degrees: Float) -> Vec3(Float) {
  case spread_degrees {
    0.0 -> direction
    _ -> {
      let spread_radians = spread_degrees *. maths.pi() /. 180.0

      let horizontal_angle = random_spread_factor() *. spread_radians
      let vertical_angle = random_spread_factor() *. spread_radians

      let #(right, up) = get_perpendicular_basis(direction)

      // Apply vertical rotation first
      let after_vertical = rotate_vector(direction, up, vertical_angle)

      // Then apply horizontal rotation
      rotate_vector(after_vertical, right, horizontal_angle)
    }
  }
}
