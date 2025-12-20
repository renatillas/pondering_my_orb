import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/time/duration
import gleam_community/maths
import iv
import pondering_my_orb/magic_system/spell
import vec/vec3
import vec/vec3f

const base_cast_delay = 150

const base_recharge_time = 330

/// Represents a wand with spell slots
pub type Wand {
  Wand(
    name: String,
    slots: iv.Array(option.Option(spell.Spell)),
    max_mana: Float,
    current_mana: Float,
    mana_recharge_rate: Float,
    cast_delay: duration.Duration,
    recharge_time: duration.Duration,
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
    total_cast_delay_addition: duration.Duration,
    total_recharge_time_addition: duration.Duration,
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
    position: vec3.Vec3(Float),
    direction: vec3.Vec3(Float),
    target_position: option.Option(vec3.Vec3(Float)),
    player_center: option.Option(vec3.Vec3(Float)),
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
    total_cast_delay_addition: duration.Duration,
    total_recharge_time_addition: duration.Duration,
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
  cast_delay cast_delay: duration.Duration,
  recharge_time recharge_time: duration.Duration,
  spells_per_cast spells_per_cast: Int,
  spread spread: Float,
) -> Wand {
  Wand(
    name:,
    slots: iv.repeat(option.None, slot_count),
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

  let cast_delay = duration.milliseconds(base_cast_delay + int.random(100))
  let recharge_time =
    duration.milliseconds(base_recharge_time + int.random(140))
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

pub fn set_spell(
  wand: Wand,
  slot_index: Int,
  spell: spell.Spell,
) -> Result(Wand, Nil) {
  case iv.get(wand.slots, slot_index) {
    Ok(option.None) -> {
      use slots <- result.map(iv.set(
        wand.slots,
        at: slot_index,
        to: option.Some(spell),
      ))
      Wand(..wand, slots:)
    }
    Error(Nil) | Ok(option.Some(_)) -> Error(Nil)
  }
}

pub fn remove_spell(wand: Wand, slot_index: Int) -> Result(Wand, Nil) {
  use slots <- result.map(iv.delete(from: wand.slots, at: slot_index))
  Wand(..wand, slots:)
}

pub fn get_spell(
  wand: Wand,
  slot_index: Int,
) -> Result(option.Option(spell.Spell), Nil) {
  wand.slots
  |> iv.get(slot_index)
}

/// Cast spells from the wand starting at a given index using the draw system
/// Processes spells until draw is exhausted, collecting all projectiles
pub fn cast(
  wand: Wand,
  start_index: Int,
  position: vec3.Vec3(Float),
  direction: vec3.Vec3(Float),
  projectile_starting_index: Int,
  target_position: option.Option(vec3.Vec3(Float)),
  player_center: option.Option(vec3.Vec3(Float)),
  existing_projectiles: List(spell.Projectile),
) -> #(CastResult, Wand) {
  case start_index >= iv.size(wand.slots) {
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
          total_cast_delay_addition: duration.milliseconds(0),
          total_recharge_time_addition: duration.milliseconds(0),
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


// ============================================================================
// State Machine Helper Functions
// ============================================================================

/// Check if an index has wrapped around the wand
fn is_index_wrapped(index: Int, wand_length: Int) -> Bool {
  index >= wand_length
}

/// Check if we've completed a full cycle through the wand
/// Returns true if we've wrapped and reached or passed the original start index
fn has_completed_cycle(
  current_index: Int,
  original_start_index: Int,
  wand_length: Int,
  wrapped_flag: Bool,
) -> Bool {
  let wrapped_index = current_index % wand_length
  wrapped_flag && wrapped_index >= original_start_index
}

/// Check if there's sufficient mana for a cost
/// Returns Error if insufficient, Ok(new_total) if sufficient
fn check_mana_sufficient(
  wand: Wand,
  current_mana_used: Float,
  additional_cost: Float,
) -> Result(Float, #(Float, Float)) {
  let new_total = current_mana_used +. additional_cost
  case wand.current_mana >=. new_total {
    True -> Ok(new_total)
    False -> Error(#(new_total, wand.current_mana))
  }
}

/// Advance state to the next slot
/// Updates current_index, adds wrapped_index to casting_indices, and tracks wrapping
fn advance_to_next_slot(
  state: CastState,
  wrapped_index: Int,
  wrapped_flag: Bool,
) -> CastState {
  CastState(
    ..state,
    current_index: state.current_index + 1,
    casting_indices: [wrapped_index, ..state.casting_indices],
    wrapped_during_cast: wrapped_flag,
  )
}

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

  let wand_length = iv.size(wand.slots)
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
  let next_state = advance_to_next_slot(state, wrapped_index, wrapped_flag)
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
    advance_to_next_slot(state, wrapped_index, wrapped_flag)
    |> fn(s) { CastState(..s, accumulated_modifiers: new_modifiers) }
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

  case check_mana_sufficient(wand, state.total_mana_used, multicast.mana_cost) {
    Ok(new_mana_used) -> {
      let next_state =
        advance_to_next_slot(state, wrapped_index, wrapped_flag)
        |> fn(s) {
          CastState(
            ..s,
            remaining_draw: new_draw,
            total_mana_used: new_mana_used,
          )
        }
      process_with_draw(wand, next_state, context)
    }
    Error(#(required, available)) -> #(
      NotEnoughMana(required: required, available: available),
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
  let is_wrapping = is_index_wrapped(state.current_index, wand_length)
  let wrapped_flag = state.wrapped_during_cast || is_wrapping

  // Check if we've completed a full cycle using helper
  let completed_cycle =
    has_completed_cycle(
      state.current_index,
      state.original_start_index,
      wand_length,
      wrapped_flag,
    )

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
    Ok(option.None) ->
      process_empty_slot(wand, state, wrapped_index, wrapped_flag, context)
    Ok(option.Some(current_spell)) ->
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
  let wand_length = iv.size(wand.slots)

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
  slots: iv.Array(option.Option(spell.Spell)),
  start_index: Int,
  end_index: Int,
  wand_length: Int,
) -> iv.Array(spell.ModifierSpell) {
  collect_modifiers_loop(slots, start_index, end_index, wand_length, iv.new())
}

fn collect_modifiers_loop(
  slots: iv.Array(option.Option(spell.Spell)),
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
        Ok(option.Some(spell.ModifierSpell(_, modifier))) ->
          iv.append(acc, modifier)
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
  slots: iv.Array(option.Option(spell.Spell)),
  start_index: Int,
) -> option.Option(#(spell.Id, spell.DamageSpell, Int)) {
  let length = iv.size(slots)
  find_next_damage_spell_loop(slots, start_index, start_index, length, 0)
}

fn find_next_damage_spell_loop(
  slots: iv.Array(option.Option(spell.Spell)),
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
            Ok(option.Some(spell.DamageSpell(id, damage_spell))) ->
              option.Some(#(id, damage_spell, current_index))
            Ok(option.Some(_)) | Ok(option.None) | Error(_) ->
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

/// Build trigger payload from next damage spell
fn build_trigger_payload(
  slots: iv.Array(option.Option(spell.Spell)),
  current_index: Int,
) -> #(option.Option(spell.ModifiedSpell), option.Option(Int)) {
  case find_next_damage_spell(slots, current_index + 1) {
    option.Some(#(payload_id, payload_spell, payload_index)) -> {
      let wand_length = iv.size(slots)
      let payload_modifiers =
        collect_modifiers_between(
          slots,
          current_index + 1,
          payload_index,
          wand_length,
        )
      let payload_modified =
        spell.apply_modifiers(payload_id, payload_spell, payload_modifiers)
      #(option.Some(payload_modified), option.Some(payload_index))
    }
    option.None -> #(option.None, option.None)
  }
}

/// Determine if damage spell needs trigger payload
fn calculate_trigger_payload(
  damaging: spell.DamageSpell,
  accumulated_modifiers: iv.Array(spell.ModifierSpell),
  slots: iv.Array(option.Option(spell.Spell)),
  current_index: Int,
) -> #(option.Option(spell.ModifiedSpell), option.Option(Int)) {
  let needs_trigger =
    damaging.has_trigger || has_trigger_modifier(accumulated_modifiers)
  case needs_trigger {
    True -> build_trigger_payload(slots, current_index)
    False -> #(option.None, option.None)
  }
}

/// Update casting indices after consuming payload
fn update_indices_for_payload(
  state: CastState,
  wand_slots: iv.Array(option.Option(spell.Spell)),
  wrapped_index: Int,
  payload_index_opt: option.Option(Int),
) -> #(Int, List(Int)) {
  case payload_index_opt {
    option.Some(payload_index) -> {
      let wand_length = iv.size(wand_slots)
      let indices_to_add =
        collect_indices_between(
          state.current_index + 1,
          payload_index,
          wand_length,
        )
      let all_indices =
        list.append(indices_to_add, [wrapped_index, ..state.casting_indices])
      #(payload_index + 1, all_indices)
    }
    option.None -> #(state.current_index + 1, [
      wrapped_index,
      ..state.casting_indices
    ])
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
  case
    id,
    is_orbiting_at_limit(context.existing_projectiles, state.projectiles)
  {
    spell.OrbitingSpell, True -> {
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
      let new_cast_delay =
        duration.add(state.total_cast_delay_addition, modified.final_cast_delay)
      let new_recharge_time =
        duration.add(
          state.total_recharge_time_addition,
          modified.final_recharge_time,
        )

      case
        check_mana_sufficient(
          wand,
          state.total_mana_used,
          modified.total_mana_cost,
        )
      {
        Error(#(required, available)) -> #(
          NotEnoughMana(required: required, available: available),
          wand,
        )
        Ok(new_mana_used) -> {
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

          let #(trigger_payload, payload_info) =
            calculate_trigger_payload(
              damaging,
              state.accumulated_modifiers,
              wand.slots,
              state.current_index,
            )

          let projectile =
            spell.Projectile(
              id: state.projectile_id,
              spell: modified,
              position: projectile_position,
              direction: spread_direction,
              time_alive: duration.milliseconds(0),
              visuals: damaging.visuals,
              projectile_type: projectile_type,
              trigger_payload: trigger_payload,
            )

          let new_accumulated_modifiers = case
            state.remaining_draw - 1 >= state.spells_per_cast
          {
            True -> state.accumulated_modifiers
            False -> iv.new()
          }

          let #(next_index, updated_casting_indices) =
            update_indices_for_payload(
              state,
              wand.slots,
              wrapped_index,
              payload_info,
            )

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
  target_position: option.Option(vec3.Vec3(Float)),
  player_center: option.Option(vec3.Vec3(Float)),
  cast_position: vec3.Vec3(Float),
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
  player_center: option.Option(vec3.Vec3(Float)),
  cast_position: vec3.Vec3(Float),
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
  default_position: vec3.Vec3(Float),
) -> vec3.Vec3(Float) {
  case projectile_type {
    spell.Orbiting(center, angle, radius, _) ->
      vec3.Vec3(
        center.x +. radius *. maths.cos(angle),
        center.y,
        center.z +. radius *. maths.sin(angle),
      )
    _ -> default_position
  }
}

pub fn recharge_mana(wand: Wand, delta_time: duration.Duration) -> Wand {
  let new_mana =
    float.min(
      wand.max_mana,
      wand.current_mana
        +. wand.mana_recharge_rate
        *. duration.to_seconds(delta_time),
    )
  Wand(..wand, current_mana: new_mana)
}

pub fn spell_count(wand: Wand) -> Int {
  wand.slots
  |> iv.filter(fn(slot) {
    case slot {
      option.Some(_) -> True
      option.None -> False
    }
  })
  |> iv.size
}

pub fn is_slot_empty(wand: Wand, slot_index: Int) -> Bool {
  case get_spell(wand, slot_index) {
    Ok(option.None) -> True
    Ok(option.Some(_)) -> False
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
fn has_any_spell_from(
  slots: iv.Array(option.Option(spell.Spell)),
  start_index: Int,
) -> Bool {
  let length = iv.size(slots)
  check_slots_from(slots, start_index, length)
}

fn check_slots_from(
  slots: iv.Array(option.Option(spell.Spell)),
  current: Int,
  length: Int,
) -> Bool {
  case current >= length {
    True -> False
    False -> {
      case iv.get(slots, current) {
        Ok(option.Some(_)) -> True
        _ -> check_slots_from(slots, current + 1, length)
      }
    }
  }
}

/// Apply spread (inaccuracy) to a direction vector
/// Only spreads horizontally (around Y axis) to keep projectiles on the ground plane
fn apply_spread(
  direction: vec3.Vec3(Float),
  spread_degrees: Float,
) -> vec3.Vec3(Float) {
  // Flatten direction to horizontal plane (Y=0) so projectiles don't go into ground
  let flat_dir =
    vec3.Vec3(direction.x, 0.0, direction.z)
    |> vec3f.normalize()

  case spread_degrees {
    0.0 -> flat_dir
    _ -> {
      // Convert spread to radians and generate random angle
      let spread_radians = spread_degrees *. maths.pi() /. 180.0
      let random_factor = float.random() *. 2.0 -. 1.0
      let angle = random_factor *. spread_radians

      // Rotate around Y axis (horizontal spread only)
      let cos_angle = maths.cos(angle)
      let sin_angle = maths.sin(angle)

      vec3.Vec3(
        flat_dir.x *. cos_angle -. flat_dir.z *. sin_angle,
        0.0,
        flat_dir.x *. sin_angle +. flat_dir.z *. cos_angle,
      )
      |> vec3f.normalize()
    }
  }
}
