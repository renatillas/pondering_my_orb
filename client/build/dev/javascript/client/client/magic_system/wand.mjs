import * as $maths from "../../../gleam_community_maths/gleam_community/maths.mjs";
import * as $float from "../../../gleam_stdlib/gleam/float.mjs";
import * as $int from "../../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../../gleam_stdlib/gleam/result.mjs";
import * as $duration from "../../../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../../../iv/iv.mjs";
import * as $vec3 from "../../../vec/vec/vec3.mjs";
import * as $vec3f from "../../../vec/vec/vec3f.mjs";
import * as $spell from "../../client/magic_system/spell.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  remainderInt,
} from "../../gleam.mjs";

export class Wand extends $CustomType {
  constructor(name, slots, max_mana, current_mana, mana_recharge_rate, cast_delay, recharge_time, spells_per_cast, spread) {
    super();
    this.name = name;
    this.slots = slots;
    this.max_mana = max_mana;
    this.current_mana = current_mana;
    this.mana_recharge_rate = mana_recharge_rate;
    this.cast_delay = cast_delay;
    this.recharge_time = recharge_time;
    this.spells_per_cast = spells_per_cast;
    this.spread = spread;
  }
}
export const Wand$Wand = (name, slots, max_mana, current_mana, mana_recharge_rate, cast_delay, recharge_time, spells_per_cast, spread) =>
  new Wand(name,
  slots,
  max_mana,
  current_mana,
  mana_recharge_rate,
  cast_delay,
  recharge_time,
  spells_per_cast,
  spread);
export const Wand$isWand = (value) => value instanceof Wand;
export const Wand$Wand$name = (value) => value.name;
export const Wand$Wand$0 = (value) => value.name;
export const Wand$Wand$slots = (value) => value.slots;
export const Wand$Wand$1 = (value) => value.slots;
export const Wand$Wand$max_mana = (value) => value.max_mana;
export const Wand$Wand$2 = (value) => value.max_mana;
export const Wand$Wand$current_mana = (value) => value.current_mana;
export const Wand$Wand$3 = (value) => value.current_mana;
export const Wand$Wand$mana_recharge_rate = (value) => value.mana_recharge_rate;
export const Wand$Wand$4 = (value) => value.mana_recharge_rate;
export const Wand$Wand$cast_delay = (value) => value.cast_delay;
export const Wand$Wand$5 = (value) => value.cast_delay;
export const Wand$Wand$recharge_time = (value) => value.recharge_time;
export const Wand$Wand$6 = (value) => value.recharge_time;
export const Wand$Wand$spells_per_cast = (value) => value.spells_per_cast;
export const Wand$Wand$7 = (value) => value.spells_per_cast;
export const Wand$Wand$spread = (value) => value.spread;
export const Wand$Wand$8 = (value) => value.spread;

/**
 * Successfully cast spells (can be multiple due to draw system)
 */
export class CastSuccess extends $CustomType {
  constructor(projectiles, remaining_mana, next_cast_index, casting_indices, did_wrap, total_cast_delay_addition, total_recharge_time_addition) {
    super();
    this.projectiles = projectiles;
    this.remaining_mana = remaining_mana;
    this.next_cast_index = next_cast_index;
    this.casting_indices = casting_indices;
    this.did_wrap = did_wrap;
    this.total_cast_delay_addition = total_cast_delay_addition;
    this.total_recharge_time_addition = total_recharge_time_addition;
  }
}
export const CastResult$CastSuccess = (projectiles, remaining_mana, next_cast_index, casting_indices, did_wrap, total_cast_delay_addition, total_recharge_time_addition) =>
  new CastSuccess(projectiles,
  remaining_mana,
  next_cast_index,
  casting_indices,
  did_wrap,
  total_cast_delay_addition,
  total_recharge_time_addition);
export const CastResult$isCastSuccess = (value) => value instanceof CastSuccess;
export const CastResult$CastSuccess$projectiles = (value) => value.projectiles;
export const CastResult$CastSuccess$0 = (value) => value.projectiles;
export const CastResult$CastSuccess$remaining_mana = (value) =>
  value.remaining_mana;
export const CastResult$CastSuccess$1 = (value) => value.remaining_mana;
export const CastResult$CastSuccess$next_cast_index = (value) =>
  value.next_cast_index;
export const CastResult$CastSuccess$2 = (value) => value.next_cast_index;
export const CastResult$CastSuccess$casting_indices = (value) =>
  value.casting_indices;
export const CastResult$CastSuccess$3 = (value) => value.casting_indices;
export const CastResult$CastSuccess$did_wrap = (value) => value.did_wrap;
export const CastResult$CastSuccess$4 = (value) => value.did_wrap;
export const CastResult$CastSuccess$total_cast_delay_addition = (value) =>
  value.total_cast_delay_addition;
export const CastResult$CastSuccess$5 = (value) =>
  value.total_cast_delay_addition;
export const CastResult$CastSuccess$total_recharge_time_addition = (value) =>
  value.total_recharge_time_addition;
export const CastResult$CastSuccess$6 = (value) =>
  value.total_recharge_time_addition;

/**
 * Not enough mana to cast
 */
export class NotEnoughMana extends $CustomType {
  constructor(required, available) {
    super();
    this.required = required;
    this.available = available;
  }
}
export const CastResult$NotEnoughMana = (required, available) =>
  new NotEnoughMana(required, available);
export const CastResult$isNotEnoughMana = (value) =>
  value instanceof NotEnoughMana;
export const CastResult$NotEnoughMana$required = (value) => value.required;
export const CastResult$NotEnoughMana$0 = (value) => value.required;
export const CastResult$NotEnoughMana$available = (value) => value.available;
export const CastResult$NotEnoughMana$1 = (value) => value.available;

export class NoSpellToCast extends $CustomType {}
export const CastResult$NoSpellToCast = () => new NoSpellToCast();
export const CastResult$isNoSpellToCast = (value) =>
  value instanceof NoSpellToCast;

export class WandEmpty extends $CustomType {}
export const CastResult$WandEmpty = () => new WandEmpty();
export const CastResult$isWandEmpty = (value) => value instanceof WandEmpty;

class CastContext extends $CustomType {
  constructor(position, direction, target_position, player_center, existing_projectiles, projectile_starting_index) {
    super();
    this.position = position;
    this.direction = direction;
    this.target_position = target_position;
    this.player_center = player_center;
    this.existing_projectiles = existing_projectiles;
    this.projectile_starting_index = projectile_starting_index;
  }
}

class CastState extends $CustomType {
  constructor(current_index, remaining_draw, accumulated_modifiers, projectiles, casting_indices, total_mana_used, total_cast_delay_addition, total_recharge_time_addition, projectile_id, wrapped_during_cast, original_start_index, spells_per_cast) {
    super();
    this.current_index = current_index;
    this.remaining_draw = remaining_draw;
    this.accumulated_modifiers = accumulated_modifiers;
    this.projectiles = projectiles;
    this.casting_indices = casting_indices;
    this.total_mana_used = total_mana_used;
    this.total_cast_delay_addition = total_cast_delay_addition;
    this.total_recharge_time_addition = total_recharge_time_addition;
    this.projectile_id = projectile_id;
    this.wrapped_during_cast = wrapped_during_cast;
    this.original_start_index = original_start_index;
    this.spells_per_cast = spells_per_cast;
  }
}

/**
 * Create a new wand
 */
export function new$(
  name,
  slot_count,
  max_mana,
  mana_recharge_rate,
  cast_delay,
  recharge_time,
  spells_per_cast,
  spread
) {
  return new Wand(
    name,
    $iv.repeat(new $option.None(), slot_count),
    max_mana,
    max_mana,
    mana_recharge_rate,
    cast_delay,
    recharge_time,
    spells_per_cast,
    spread,
  );
}

/**
 * Create a new wand with random stats (Noita-inspired ranges)
 */
export function new_random(name) {
  let slot_count = 2 + $int.random(5);
  let spells_per_cast = 1 + $int.random(3);
  let cast_delay = $duration.milliseconds(50 + $int.random(201));
  let recharge_time = $duration.milliseconds(20 + $int.random(451));
  let max_mana = 80.0 + ($float.random() * 50.0);
  let mana_recharge_rate = 5.0 + ($float.random() * 35.0);
  let spread = $float.random() * 10.0;
  return new$(
    name,
    slot_count,
    max_mana,
    mana_recharge_rate,
    cast_delay,
    recharge_time,
    spells_per_cast,
    spread,
  );
}

export function set_spell(wand, slot_index, spell) {
  let $ = $iv.get(wand.slots, slot_index);
  if ($ instanceof Ok) {
    let $1 = $[0];
    if ($1 instanceof $option.Some) {
      return new Error(undefined);
    } else {
      return $result.map(
        $iv.set(wand.slots, slot_index, new $option.Some(spell)),
        (slots) => {
          return new Wand(
            wand.name,
            slots,
            wand.max_mana,
            wand.current_mana,
            wand.mana_recharge_rate,
            wand.cast_delay,
            wand.recharge_time,
            wand.spells_per_cast,
            wand.spread,
          );
        },
      );
    }
  } else {
    return new Error(undefined);
  }
}

export function remove_spell(wand, slot_index) {
  return $result.map(
    $iv.delete$(wand.slots, slot_index),
    (slots) => {
      return new Wand(
        wand.name,
        slots,
        wand.max_mana,
        wand.current_mana,
        wand.mana_recharge_rate,
        wand.cast_delay,
        wand.recharge_time,
        wand.spells_per_cast,
        wand.spread,
      );
    },
  );
}

export function get_spell(wand, slot_index) {
  let _pipe = wand.slots;
  return $iv.get(_pipe, slot_index);
}

/**
 * Check if an index has wrapped around the wand
 * 
 * @ignore
 */
function is_index_wrapped(index, wand_length) {
  return index >= wand_length;
}

/**
 * Check if we've completed a full cycle through the wand
 * Returns true if we've wrapped and reached or passed the original start index
 * 
 * @ignore
 */
function has_completed_cycle(
  current_index,
  original_start_index,
  wand_length,
  wrapped_flag
) {
  let wrapped_index = remainderInt(current_index, wand_length);
  return wrapped_flag && (wrapped_index >= original_start_index);
}

/**
 * Check if there's sufficient mana for a cost
 * Returns Error if insufficient, Ok(new_total) if sufficient
 * 
 * @ignore
 */
function check_mana_sufficient(wand, current_mana_used, additional_cost) {
  let new_total = current_mana_used + additional_cost;
  let $ = wand.current_mana >= new_total;
  if ($) {
    return new Ok(new_total);
  } else {
    return new Error([new_total, wand.current_mana]);
  }
}

/**
 * Advance state to the next slot
 * Updates current_index, adds wrapped_index to casting_indices, and tracks wrapping
 * 
 * @ignore
 */
function advance_to_next_slot(state, wrapped_index, wrapped_flag) {
  return new CastState(
    state.current_index + 1,
    state.remaining_draw,
    state.accumulated_modifiers,
    state.projectiles,
    listPrepend(wrapped_index, state.casting_indices),
    state.total_mana_used,
    state.total_cast_delay_addition,
    state.total_recharge_time_addition,
    state.projectile_id,
    wrapped_flag,
    state.original_start_index,
    state.spells_per_cast,
  );
}

/**
 * Check if any modifier in the array has adds_trigger set to True
 * 
 * @ignore
 */
function has_trigger_modifier(modifiers) {
  return $iv.fold(
    modifiers,
    false,
    (acc, mod) => { return acc || mod.adds_trigger; },
  );
}

function collect_indices_loop(
  loop$current,
  loop$end,
  loop$wand_length,
  loop$acc
) {
  while (true) {
    let current = loop$current;
    let end = loop$end;
    let wand_length = loop$wand_length;
    let acc = loop$acc;
    let $ = current > end;
    if ($) {
      return $list.reverse(acc);
    } else {
      let wrapped_index = remainderInt(current, wand_length);
      loop$current = current + 1;
      loop$end = end;
      loop$wand_length = wand_length;
      loop$acc = listPrepend(wrapped_index, acc);
    }
  }
}

/**
 * Collect all indices between start and end (inclusive)
 * Handles wrapping around wand length
 * 
 * @ignore
 */
function collect_indices_between(start_index, end_index, wand_length) {
  return collect_indices_loop(start_index, end_index, wand_length, toList([]));
}

function collect_modifiers_loop(
  loop$slots,
  loop$current,
  loop$end,
  loop$wand_length,
  loop$acc
) {
  while (true) {
    let slots = loop$slots;
    let current = loop$current;
    let end = loop$end;
    let wand_length = loop$wand_length;
    let acc = loop$acc;
    let $ = current >= end;
    if ($) {
      return acc;
    } else {
      let wrapped_index = remainderInt(current, wand_length);
      let _block;
      let $1 = $iv.get(slots, wrapped_index);
      if ($1 instanceof Ok) {
        let $2 = $1[0];
        if ($2 instanceof $option.Some) {
          let $3 = $2[0];
          if ($3 instanceof $spell.ModifierSpell) {
            let kind = $3.kind;
            _block = $iv.append(acc, kind);
          } else {
            _block = acc;
          }
        } else {
          _block = acc;
        }
      } else {
        _block = acc;
      }
      let new_acc = _block;
      loop$slots = slots;
      loop$current = current + 1;
      loop$end = end;
      loop$wand_length = wand_length;
      loop$acc = new_acc;
    }
  }
}

/**
 * Collect modifiers between start and end index (exclusive of end)
 * Used to apply modifiers to trigger payloads
 * 
 * @ignore
 */
function collect_modifiers_between(slots, start_index, end_index, wand_length) {
  return collect_modifiers_loop(
    slots,
    start_index,
    end_index,
    wand_length,
    $iv.new$(),
  );
}

function find_next_damage_spell_loop(
  loop$slots,
  loop$current_index,
  loop$original_start,
  loop$length,
  loop$iterations
) {
  while (true) {
    let slots = loop$slots;
    let current_index = loop$current_index;
    let original_start = loop$original_start;
    let length = loop$length;
    let iterations = loop$iterations;
    let $ = iterations >= length;
    if ($) {
      return new Error(undefined);
    } else {
      let wrapped_index = remainderInt(current_index, length);
      let is_wrapped = current_index >= length;
      let would_go_backwards = is_wrapped && (wrapped_index <= original_start);
      if (would_go_backwards) {
        return new Error(undefined);
      } else {
        let $1 = $iv.get(slots, wrapped_index);
        if ($1 instanceof Ok) {
          let $2 = $1[0];
          if ($2 instanceof $option.Some) {
            let $3 = $2[0];
            if ($3 instanceof $spell.DamageSpell) {
              let id = $3.id;
              let ui_sprite = $3.ui_sprite;
              let kind = $3.kind;
              return new Ok([id, ui_sprite, kind, current_index]);
            } else {
              loop$slots = slots;
              loop$current_index = current_index + 1;
              loop$original_start = original_start;
              loop$length = length;
              loop$iterations = iterations + 1;
            }
          } else {
            loop$slots = slots;
            loop$current_index = current_index + 1;
            loop$original_start = original_start;
            loop$length = length;
            loop$iterations = iterations + 1;
          }
        } else {
          loop$slots = slots;
          loop$current_index = current_index + 1;
          loop$original_start = original_start;
          loop$length = length;
          loop$iterations = iterations + 1;
        }
      }
    }
  }
}

/**
 * Find the next damage spell in the wand starting from the given index
 * Returns Option(#(spell.Id, spell.DamageSpell, Int)) with the spell and the index where it was found
 * Only searches forward from start_index, does not wrap back to find spells before it
 * 
 * @ignore
 */
function find_next_damage_spell(slots, start_index) {
  let length = $iv.size(slots);
  return find_next_damage_spell_loop(slots, start_index, start_index, length, 0);
}

/**
 * Build trigger payload from next damage spell
 * 
 * @ignore
 */
function build_trigger_payload(slots, current_index) {
  let $ = find_next_damage_spell(slots, current_index + 1);
  if ($ instanceof Ok) {
    let payload_id = $[0][0];
    let ui_sprite = $[0][1];
    let payload_spell = $[0][2];
    let payload_index = $[0][3];
    let wand_length = $iv.size(slots);
    let payload_modifiers = collect_modifiers_between(
      slots,
      current_index + 1,
      payload_index,
      wand_length,
    );
    let payload_modified = $spell.apply_modifiers(
      payload_id,
      ui_sprite,
      payload_spell,
      payload_modifiers,
    );
    return [new $option.Some(payload_modified), new $option.Some(payload_index)];
  } else {
    return [new $option.None(), new $option.None()];
  }
}

/**
 * Determine if damage spell needs trigger payload
 * 
 * @ignore
 */
function calculate_trigger_payload(
  damaging,
  accumulated_modifiers,
  slots,
  current_index
) {
  let needs_trigger = damaging.has_trigger || has_trigger_modifier(
    accumulated_modifiers,
  );
  if (needs_trigger) {
    return build_trigger_payload(slots, current_index);
  } else {
    return [new $option.None(), new $option.None()];
  }
}

/**
 * Update casting indices after consuming payload
 * 
 * @ignore
 */
function update_indices_for_payload(
  state,
  wand_slots,
  wrapped_index,
  payload_index_opt
) {
  if (payload_index_opt instanceof $option.Some) {
    let payload_index = payload_index_opt[0];
    let wand_length = $iv.size(wand_slots);
    let indices_to_add = collect_indices_between(
      state.current_index + 1,
      payload_index,
      wand_length,
    );
    let all_indices = $list.append(
      indices_to_add,
      listPrepend(wrapped_index, state.casting_indices),
    );
    return [payload_index + 1, all_indices];
  } else {
    return [
      state.current_index + 1,
      listPrepend(wrapped_index, state.casting_indices),
    ];
  }
}

export function recharge_mana(wand, delta_time) {
  let new_mana = $float.min(
    wand.max_mana,
    wand.current_mana + (wand.mana_recharge_rate * $duration.to_seconds(
      delta_time,
    )),
  );
  return new Wand(
    wand.name,
    wand.slots,
    wand.max_mana,
    new_mana,
    wand.mana_recharge_rate,
    wand.cast_delay,
    wand.recharge_time,
    wand.spells_per_cast,
    wand.spread,
  );
}

export function spell_count(wand) {
  let _pipe = wand.slots;
  let _pipe$1 = $iv.filter(
    _pipe,
    (slot) => {
      if (slot instanceof $option.Some) {
        return true;
      } else {
        return false;
      }
    },
  );
  return $iv.size(_pipe$1);
}

export function is_slot_empty(wand, slot_index) {
  let $ = get_spell(wand, slot_index);
  if ($ instanceof Ok) {
    let $1 = $[0];
    if ($1 instanceof $option.Some) {
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}

function reorder_array(items, from_index, to_index) {
  let $ = $iv.get(items, from_index);
  let $1 = $iv.delete$(items, from_index);
  if ($ instanceof Ok && $1 instanceof Ok) {
    let removed_item = $[0];
    let list_without_item = $1[0];
    return $iv.insert(list_without_item, to_index, removed_item);
  } else {
    return new Ok(items);
  }
}

export function reorder_slots(wand, from_index, to_index) {
  return $result.map(
    reorder_array(wand.slots, from_index, to_index),
    (new_slots) => {
      return new Wand(
        wand.name,
        new_slots,
        wand.max_mana,
        wand.current_mana,
        wand.mana_recharge_rate,
        wand.cast_delay,
        wand.recharge_time,
        wand.spells_per_cast,
        wand.spread,
      );
    },
  );
}

function check_slots_from(loop$slots, loop$current, loop$length) {
  while (true) {
    let slots = loop$slots;
    let current = loop$current;
    let length = loop$length;
    let $ = current >= length;
    if ($) {
      return false;
    } else {
      let $1 = $iv.get(slots, current);
      if ($1 instanceof Ok) {
        let $2 = $1[0];
        if ($2 instanceof $option.Some) {
          return true;
        } else {
          loop$slots = slots;
          loop$current = current + 1;
          loop$length = length;
        }
      } else {
        loop$slots = slots;
        loop$current = current + 1;
        loop$length = length;
      }
    }
  }
}

/**
 * Check if there are any spells from start_index to end of slots
 * 
 * @ignore
 */
function has_any_spell_from(slots, start_index) {
  let length = $iv.size(slots);
  return check_slots_from(slots, start_index, length);
}

/**
 * Create a success result from the current cast state
 * 
 * @ignore
 */
function create_success_result(wand, state, wrapped_flag) {
  let new_mana = wand.current_mana - state.total_mana_used;
  let updated_wand = new Wand(
    wand.name,
    wand.slots,
    wand.max_mana,
    new_mana,
    wand.mana_recharge_rate,
    wand.cast_delay,
    wand.recharge_time,
    wand.spells_per_cast,
    wand.spread,
  );
  let wand_length = $iv.size(wand.slots);
  let next_index = remainderInt(state.current_index, wand_length);
  let has_spells_ahead = has_any_spell_from(wand.slots, next_index);
  let did_wrap = wrapped_flag || !has_spells_ahead;
  return [
    new CastSuccess(
      state.projectiles,
      new_mana,
      next_index,
      state.casting_indices,
      did_wrap,
      state.total_cast_delay_addition,
      state.total_recharge_time_addition,
    ),
    updated_wand,
  ];
}

/**
 * Apply spread (inaccuracy) to a direction vector
 * Only spreads horizontally (around Y axis) to keep projectiles on the ground plane
 * 
 * @ignore
 */
function apply_spread(direction, spread_degrees) {
  let _block;
  let _pipe = new $vec3.Vec3(direction.x, 0.0, direction.z);
  _block = $vec3f.normalize(_pipe);
  let flat_dir = _block;
  if (spread_degrees === 0.0) {
    return flat_dir;
  } else {
    let spread_radians = ((spread_degrees * $maths.pi())) / 180.0;
    let random_factor = ($float.random() * 2.0) - 1.0;
    let angle = random_factor * spread_radians;
    let cos_angle = $maths.cos(angle);
    let sin_angle = $maths.sin(angle);
    let _pipe$1 = new $vec3.Vec3(
      (flat_dir.x * cos_angle) - (flat_dir.z * sin_angle),
      0.0,
      (flat_dir.x * sin_angle) + (flat_dir.z * cos_angle),
    );
    return $vec3f.normalize(_pipe$1);
  }
}

/**
 * Process an empty slot (continue without consuming draw)
 * 
 * @ignore
 */
function process_empty_slot(wand, state, wrapped_index, wrapped_flag, context) {
  let next_state = advance_to_next_slot(state, wrapped_index, wrapped_flag);
  return process_with_draw(wand, next_state, context);
}

/**
 * Process spells with the draw system
 * Continues processing spells until draw is exhausted, with wrapping support
 * 
 * @ignore
 */
function process_with_draw(wand, state, context) {
  let wand_length = $iv.size(wand.slots);
  if (wand_length === 0) {
    return [new WandEmpty(), wand];
  } else {
    let $ = state.remaining_draw <= 0;
    if ($) {
      let $1 = state.projectiles;
      if ($1 instanceof $Empty) {
        return [new NoSpellToCast(), wand];
      } else {
        return create_success_result(wand, state, state.wrapped_during_cast);
      }
    } else {
      return process_next_spell(wand, state, context, wand_length);
    }
  }
}

/**
 * Process the next spell in the wand
 * 
 * @ignore
 */
function process_next_spell(wand, state, context, wand_length) {
  let wrapped_index = remainderInt(state.current_index, wand_length);
  let is_wrapping = is_index_wrapped(state.current_index, wand_length);
  let wrapped_flag = state.wrapped_during_cast || is_wrapping;
  let completed_cycle = has_completed_cycle(
    state.current_index,
    state.original_start_index,
    wand_length,
    wrapped_flag,
  );
  if (completed_cycle) {
    let $ = state.projectiles;
    if ($ instanceof $Empty) {
      return [new NoSpellToCast(), wand];
    } else {
      return create_success_result(wand, state, wrapped_flag);
    }
  } else {
    return process_spell_at_index(
      wand,
      state,
      wrapped_index,
      wrapped_flag,
      context,
    );
  }
}

/**
 * Process the spell at the current index
 * 
 * @ignore
 */
function process_spell_at_index(
  wand,
  state,
  wrapped_index,
  wrapped_flag,
  context
) {
  let $ = $iv.get(wand.slots, wrapped_index);
  if ($ instanceof Ok) {
    let $1 = $[0];
    if ($1 instanceof $option.Some) {
      let current_spell = $1[0];
      if (current_spell instanceof $spell.DamageSpell) {
        let id = current_spell.id;
        let ui_sprite = current_spell.ui_sprite;
        let kind = current_spell.kind;
        return process_damage_spell(
          wand,
          id,
          ui_sprite,
          kind,
          wrapped_index,
          wrapped_flag,
          state,
          context,
        );
      } else if (current_spell instanceof $spell.ModifierSpell) {
        let kind = current_spell.kind;
        return process_modifier_spell(
          wand,
          state,
          kind,
          wrapped_index,
          wrapped_flag,
          context,
        );
      } else {
        let kind = current_spell.kind;
        return process_multicast_spell(
          wand,
          state,
          kind,
          wrapped_index,
          wrapped_flag,
          context,
        );
      }
    } else {
      return process_empty_slot(
        wand,
        state,
        wrapped_index,
        wrapped_flag,
        context,
      );
    }
  } else {
    return [new WandEmpty(), wand];
  }
}

/**
 * Cast spells from the wand starting at a given index using the draw system
 * Processes spells until draw is exhausted, collecting all projectiles
 */
export function cast(
  wand,
  start_index,
  position,
  direction,
  projectile_starting_index,
  target_position,
  player_center,
  existing_projectiles
) {
  let $ = start_index >= $iv.size(wand.slots);
  if ($) {
    return [new WandEmpty(), wand];
  } else {
    let context = new CastContext(
      position,
      direction,
      target_position,
      player_center,
      existing_projectiles,
      projectile_starting_index,
    );
    let initial_state = new CastState(
      start_index,
      wand.spells_per_cast,
      $iv.new$(),
      toList([]),
      toList([]),
      0.0,
      $duration.milliseconds(0),
      $duration.milliseconds(0),
      projectile_starting_index,
      false,
      start_index,
      wand.spells_per_cast,
    );
    return process_with_draw(wand, initial_state, context);
  }
}

/**
 * Process a modifier spell (accumulate without consuming draw)
 * 
 * @ignore
 */
function process_modifier_spell(
  wand,
  state,
  modifier,
  wrapped_index,
  wrapped_flag,
  context
) {
  let new_modifiers = $iv.prepend(state.accumulated_modifiers, modifier);
  let _block;
  let _pipe = advance_to_next_slot(state, wrapped_index, wrapped_flag);
  _block = ((s) => {
    return new CastState(
      s.current_index,
      s.remaining_draw,
      new_modifiers,
      s.projectiles,
      s.casting_indices,
      s.total_mana_used,
      s.total_cast_delay_addition,
      s.total_recharge_time_addition,
      s.projectile_id,
      s.wrapped_during_cast,
      s.original_start_index,
      s.spells_per_cast,
    );
  })(_pipe);
  let next_state = _block;
  return process_with_draw(wand, next_state, context);
}

/**
 * Process a multicast spell
 * 
 * @ignore
 */
function process_multicast_spell(
  wand,
  state,
  multicast,
  wrapped_index,
  wrapped_flag,
  context
) {
  let new_draw = (state.remaining_draw - 1) + multicast.draw_add;
  let $ = check_mana_sufficient(
    wand,
    state.total_mana_used,
    multicast.mana_cost,
  );
  if ($ instanceof Ok) {
    let new_mana_used = $[0];
    let _block;
    let _pipe = advance_to_next_slot(state, wrapped_index, wrapped_flag);
    _block = ((s) => {
      return new CastState(
        s.current_index,
        new_draw,
        s.accumulated_modifiers,
        s.projectiles,
        s.casting_indices,
        new_mana_used,
        s.total_cast_delay_addition,
        s.total_recharge_time_addition,
        s.projectile_id,
        s.wrapped_during_cast,
        s.original_start_index,
        s.spells_per_cast,
      );
    })(_pipe);
    let next_state = _block;
    return process_with_draw(wand, next_state, context);
  } else {
    let required = $[0][0];
    let available = $[0][1];
    return [new NotEnoughMana(required, available), wand];
  }
}

/**
 * Process a damage spell (handles both orbiting and standard projectiles)
 * 
 * @ignore
 */
function process_damage_spell(
  wand,
  id,
  ui_sprite,
  spell,
  wrapped_index,
  wrapped_flag,
  state,
  context
) {
  let modified = $spell.apply_modifiers(
    id,
    ui_sprite,
    spell,
    state.accumulated_modifiers,
  );
  let new_cast_delay = $duration.add(
    state.total_cast_delay_addition,
    modified.final_cast_delay,
  );
  let new_recharge_time = $duration.add(
    state.total_recharge_time_addition,
    modified.final_recharge_time,
  );
  let $ = check_mana_sufficient(
    wand,
    state.total_mana_used,
    modified.total_mana_cost,
  );
  if ($ instanceof Ok) {
    let new_mana_used = $[0];
    let spread_direction = apply_spread(
      context.direction,
      wand.spread + modified.final_spread,
    );
    let projectile_position = context.position;
    let $1 = calculate_trigger_payload(
      spell,
      state.accumulated_modifiers,
      wand.slots,
      state.current_index,
    );
    let trigger_payload;
    let payload_info;
    trigger_payload = $1[0];
    payload_info = $1[1];
    let projectile = new $spell.Projectile(
      state.projectile_id,
      modified,
      projectile_position,
      spread_direction,
      $duration.milliseconds(0),
      spell.visuals,
      trigger_payload,
    );
    let _block;
    let $2 = (state.remaining_draw - 1) >= state.spells_per_cast;
    if ($2) {
      _block = state.accumulated_modifiers;
    } else {
      _block = $iv.new$();
    }
    let new_accumulated_modifiers = _block;
    let $3 = update_indices_for_payload(
      state,
      wand.slots,
      wrapped_index,
      payload_info,
    );
    let next_index;
    let updated_casting_indices;
    next_index = $3[0];
    updated_casting_indices = $3[1];
    let next_state = new CastState(
      next_index,
      state.remaining_draw - 1,
      new_accumulated_modifiers,
      listPrepend(projectile, state.projectiles),
      updated_casting_indices,
      new_mana_used,
      new_cast_delay,
      new_recharge_time,
      state.projectile_id + 1,
      wrapped_flag,
      state.original_start_index,
      state.spells_per_cast,
    );
    return process_with_draw(wand, next_state, context);
  } else {
    let required = $[0][0];
    let available = $[0][1];
    return [new NotEnoughMana(required, available), wand];
  }
}
