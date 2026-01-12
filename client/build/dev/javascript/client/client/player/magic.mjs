import * as $ensaimada from "../../../ensaimada/ensaimada.mjs";
import * as $float from "../../../gleam_stdlib/gleam/float.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $order from "../../../gleam_stdlib/gleam/order.mjs";
import * as $duration from "../../../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../../../iv/iv.mjs";
import * as $tiramisu from "../../../tiramisu/tiramisu.mjs";
import * as $effect from "../../../tiramisu/tiramisu/effect.mjs";
import * as $geometry from "../../../tiramisu/tiramisu/geometry.mjs";
import * as $input from "../../../tiramisu/tiramisu/input.mjs";
import * as $material from "../../../tiramisu/tiramisu/material.mjs";
import * as $physics from "../../../tiramisu/tiramisu/physics.mjs";
import * as $scene from "../../../tiramisu/tiramisu/scene.mjs";
import * as $transform from "../../../tiramisu/tiramisu/transform.mjs";
import * as $vec2 from "../../../vec/vec/vec2.mjs";
import * as $vec3 from "../../../vec/vec/vec3.mjs";
import { Vec3 } from "../../../vec/vec/vec3.mjs";
import * as $vec3f from "../../../vec/vec/vec3f.mjs";
import * as $assets from "../../client/assets.mjs";
import * as $layer from "../../client/game_physics/layer.mjs";
import * as $id from "../../client/id.mjs";
import * as $spell from "../../client/magic_system/spell.mjs";
import * as $spell_bag from "../../client/magic_system/spell_bag.mjs";
import * as $wand from "../../client/magic_system/wand.mjs";
import {
  Ok,
  toList,
  CustomType as $CustomType,
  makeError,
  remainderInt,
  divideFloat,
  isEqual,
} from "../../gleam.mjs";

const FILEPATH = "src/client/player/magic.gleam";

export class WandState extends $CustomType {
  constructor(cast_cooldown, wand_cast_index) {
    super();
    this.cast_cooldown = cast_cooldown;
    this.wand_cast_index = wand_cast_index;
  }
}
export const WandState$WandState = (cast_cooldown, wand_cast_index) =>
  new WandState(cast_cooldown, wand_cast_index);
export const WandState$isWandState = (value) => value instanceof WandState;
export const WandState$WandState$cast_cooldown = (value) => value.cast_cooldown;
export const WandState$WandState$0 = (value) => value.cast_cooldown;
export const WandState$WandState$wand_cast_index = (value) =>
  value.wand_cast_index;
export const WandState$WandState$1 = (value) => value.wand_cast_index;

export class Model extends $CustomType {
  constructor(wands, active_wand_index, wand_states, projectiles, next_projectile_id, spell_bag, selected_spell_slot, player_pos, zoom) {
    super();
    this.wands = wands;
    this.active_wand_index = active_wand_index;
    this.wand_states = wand_states;
    this.projectiles = projectiles;
    this.next_projectile_id = next_projectile_id;
    this.spell_bag = spell_bag;
    this.selected_spell_slot = selected_spell_slot;
    this.player_pos = player_pos;
    this.zoom = zoom;
  }
}
export const Model$Model = (wands, active_wand_index, wand_states, projectiles, next_projectile_id, spell_bag, selected_spell_slot, player_pos, zoom) =>
  new Model(wands,
  active_wand_index,
  wand_states,
  projectiles,
  next_projectile_id,
  spell_bag,
  selected_spell_slot,
  player_pos,
  zoom);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$wands = (value) => value.wands;
export const Model$Model$0 = (value) => value.wands;
export const Model$Model$active_wand_index = (value) => value.active_wand_index;
export const Model$Model$1 = (value) => value.active_wand_index;
export const Model$Model$wand_states = (value) => value.wand_states;
export const Model$Model$2 = (value) => value.wand_states;
export const Model$Model$projectiles = (value) => value.projectiles;
export const Model$Model$3 = (value) => value.projectiles;
export const Model$Model$next_projectile_id = (value) =>
  value.next_projectile_id;
export const Model$Model$4 = (value) => value.next_projectile_id;
export const Model$Model$spell_bag = (value) => value.spell_bag;
export const Model$Model$5 = (value) => value.spell_bag;
export const Model$Model$selected_spell_slot = (value) =>
  value.selected_spell_slot;
export const Model$Model$6 = (value) => value.selected_spell_slot;
export const Model$Model$player_pos = (value) => value.player_pos;
export const Model$Model$7 = (value) => value.player_pos;
export const Model$Model$zoom = (value) => value.zoom;
export const Model$Model$8 = (value) => value.zoom;

export class Tick extends $CustomType {}
export const Msg$Tick = () => new Tick();
export const Msg$isTick = (value) => value instanceof Tick;

export class UpdatePlayerState extends $CustomType {
  constructor(player_pos, zoom) {
    super();
    this.player_pos = player_pos;
    this.zoom = zoom;
  }
}
export const Msg$UpdatePlayerState = (player_pos, zoom) =>
  new UpdatePlayerState(player_pos, zoom);
export const Msg$isUpdatePlayerState = (value) =>
  value instanceof UpdatePlayerState;
export const Msg$UpdatePlayerState$player_pos = (value) => value.player_pos;
export const Msg$UpdatePlayerState$0 = (value) => value.player_pos;
export const Msg$UpdatePlayerState$zoom = (value) => value.zoom;
export const Msg$UpdatePlayerState$1 = (value) => value.zoom;

export class PlaceSpellInSlot extends $CustomType {
  constructor(spell_id, slot_index) {
    super();
    this.spell_id = spell_id;
    this.slot_index = slot_index;
  }
}
export const Msg$PlaceSpellInSlot = (spell_id, slot_index) =>
  new PlaceSpellInSlot(spell_id, slot_index);
export const Msg$isPlaceSpellInSlot = (value) =>
  value instanceof PlaceSpellInSlot;
export const Msg$PlaceSpellInSlot$spell_id = (value) => value.spell_id;
export const Msg$PlaceSpellInSlot$0 = (value) => value.spell_id;
export const Msg$PlaceSpellInSlot$slot_index = (value) => value.slot_index;
export const Msg$PlaceSpellInSlot$1 = (value) => value.slot_index;

export class SelectSlot extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$SelectSlot = ($0) => new SelectSlot($0);
export const Msg$isSelectSlot = (value) => value instanceof SelectSlot;
export const Msg$SelectSlot$0 = (value) => value[0];

export class ReorderWandSlots extends $CustomType {
  constructor(from_index, to_index) {
    super();
    this.from_index = from_index;
    this.to_index = to_index;
  }
}
export const Msg$ReorderWandSlots = (from_index, to_index) =>
  new ReorderWandSlots(from_index, to_index);
export const Msg$isReorderWandSlots = (value) =>
  value instanceof ReorderWandSlots;
export const Msg$ReorderWandSlots$from_index = (value) => value.from_index;
export const Msg$ReorderWandSlots$0 = (value) => value.from_index;
export const Msg$ReorderWandSlots$to_index = (value) => value.to_index;
export const Msg$ReorderWandSlots$1 = (value) => value.to_index;

export class RemoveProjectile extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$RemoveProjectile = ($0) => new RemoveProjectile($0);
export const Msg$isRemoveProjectile = (value) =>
  value instanceof RemoveProjectile;
export const Msg$RemoveProjectile$0 = (value) => value[0];

export class SwitchWand extends $CustomType {
  constructor(wand_index) {
    super();
    this.wand_index = wand_index;
  }
}
export const Msg$SwitchWand = (wand_index) => new SwitchWand(wand_index);
export const Msg$isSwitchWand = (value) => value instanceof SwitchWand;
export const Msg$SwitchWand$wand_index = (value) => value.wand_index;
export const Msg$SwitchWand$0 = (value) => value.wand_index;

export class SwitchWandRelative extends $CustomType {
  constructor(delta) {
    super();
    this.delta = delta;
  }
}
export const Msg$SwitchWandRelative = (delta) => new SwitchWandRelative(delta);
export const Msg$isSwitchWandRelative = (value) =>
  value instanceof SwitchWandRelative;
export const Msg$SwitchWandRelative$delta = (value) => value.delta;
export const Msg$SwitchWandRelative$0 = (value) => value.delta;

export class PickUpWand extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$PickUpWand = ($0) => new PickUpWand($0);
export const Msg$isPickUpWand = (value) => value instanceof PickUpWand;
export const Msg$PickUpWand$0 = (value) => value[0];

export class RemoveSpellFromSlot extends $CustomType {
  constructor(slot_index) {
    super();
    this.slot_index = slot_index;
  }
}
export const Msg$RemoveSpellFromSlot = (slot_index) =>
  new RemoveSpellFromSlot(slot_index);
export const Msg$isRemoveSpellFromSlot = (value) =>
  value instanceof RemoveSpellFromSlot;
export const Msg$RemoveSpellFromSlot$slot_index = (value) => value.slot_index;
export const Msg$RemoveSpellFromSlot$0 = (value) => value.slot_index;

export function init() {
  let starter_wand = $wand.new$(
    "Starter Wand",
    4,
    100.0,
    30.0,
    $duration.milliseconds(150),
    $duration.milliseconds(330),
    1,
    0.0,
  );
  let $ = $wand.set_spell(starter_wand, 0, $spell.spark());
  let starter_wand$1;
  if ($ instanceof Ok) {
    starter_wand$1 = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/player/magic",
      85,
      "init",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 2324,
        end: 2400,
        pattern_start: 2335,
        pattern_end: 2351
      }
    )
  }
  let wands = $iv.from_list(
    toList([
      new $option.Some(starter_wand$1),
      new $option.None(),
      new $option.None(),
      new $option.None(),
    ]),
  );
  let initial_wand_state = new WandState($duration.milliseconds(0), 0);
  let wand_states = $iv.repeat(initial_wand_state, 4);
  let initial_spell_bag = $spell_bag.new$();
  let model = new Model(
    wands,
    0,
    wand_states,
    toList([]),
    0,
    initial_spell_bag,
    new $option.None(),
    new Vec3(0.0, 1.0, 0.0),
    30.0,
  );
  return [model, $effect.dispatch(new Tick())];
}

function update_projectiles(model, delta_time) {
  let _block;
  let _pipe = model.projectiles;
  let _pipe$1 = $list.map(
    _pipe,
    (proj) => {
      let new_time_alive = $duration.add(proj.time_alive, delta_time);
      return new $spell.Projectile(
        proj.id,
        proj.spell,
        proj.position,
        proj.direction,
        new_time_alive,
        proj.visuals,
        proj.trigger_payload,
      );
    },
  );
  _block = $list.filter(
    _pipe$1,
    (proj) => {
      return !($duration.compare(proj.time_alive, proj.spell.final_lifetime) instanceof $order.Gt);
    },
  );
  let updated_projectiles = _block;
  return new Model(
    model.wands,
    model.active_wand_index,
    model.wand_states,
    updated_projectiles,
    model.next_projectile_id,
    model.spell_bag,
    model.selected_spell_slot,
    model.player_pos,
    model.zoom,
  );
}

function reduce_cooldown(cooldown, delta_time) {
  let cooldown_secs = $duration.to_seconds(cooldown);
  let delta_secs = $duration.to_seconds(delta_time);
  let remaining_secs = cooldown_secs - delta_secs;
  let $ = remaining_secs > 0.0;
  if ($) {
    let remaining_ms = $float.round(remaining_secs * 1000.0);
    return $duration.milliseconds(remaining_ms);
  } else {
    return $duration.milliseconds(0);
  }
}

/**
 * Get the currently active wand (if any)
 */
export function get_active_wand(model) {
  let $ = $iv.get(model.wands, model.active_wand_index);
  if ($ instanceof Ok) {
    let wand_opt = $[0];
    return wand_opt;
  } else {
    return new $option.None();
  }
}

function find_next_spell_loop(
  loop$slots,
  loop$current_index,
  loop$slot_count,
  loop$iterations
) {
  while (true) {
    let slots = loop$slots;
    let current_index = loop$current_index;
    let slot_count = loop$slot_count;
    let iterations = loop$iterations;
    let $ = iterations >= slot_count;
    if ($) {
      return 0;
    } else {
      let wrapped_index = remainderInt(current_index, slot_count);
      let $1 = $iv.get(slots, wrapped_index);
      if ($1 instanceof Ok) {
        let $2 = $1[0];
        if ($2 instanceof $option.Some) {
          return wrapped_index;
        } else {
          loop$slots = slots;
          loop$current_index = current_index + 1;
          loop$slot_count = slot_count;
          loop$iterations = iterations + 1;
        }
      } else {
        loop$slots = slots;
        loop$current_index = current_index + 1;
        loop$slot_count = slot_count;
        loop$iterations = iterations + 1;
      }
    }
  }
}

/**
 * Find the index of the next non-empty spell slot starting from start_index
 * Wraps around if needed
 * 
 * @ignore
 */
function find_next_spell_index(slots, start_index) {
  let slot_count = $iv.size(slots);
  return find_next_spell_loop(slots, start_index, slot_count, 0);
}

/**
 * Get the wand cast index for the active wand (for UI display)
 * Returns the index of the next spell that will actually be cast,
 * not just the raw cast index (which might point to an empty slot)
 */
export function get_wand_cast_index(model) {
  let $ = $iv.get(model.wand_states, model.active_wand_index);
  let $1 = get_active_wand(model);
  if ($ instanceof Ok && $1 instanceof $option.Some) {
    let state = $[0];
    let active_wand = $1[0];
    return find_next_spell_index(active_wand.slots, state.wand_cast_index);
  } else {
    return 0;
  }
}

/**
 * Get the state for the active wand
 * 
 * @ignore
 */
function get_active_wand_state(model) {
  let $ = $iv.get(model.wand_states, model.active_wand_index);
  if ($ instanceof Ok) {
    let state = $[0];
    return state;
  } else {
    return new WandState($duration.milliseconds(0), 0);
  }
}

function find_empty_slot_loop(loop$wands, loop$index) {
  while (true) {
    let wands = loop$wands;
    let index = loop$index;
    let $ = $iv.get(wands, index);
    if ($ instanceof Ok) {
      let $1 = $[0];
      if ($1 instanceof $option.Some) {
        loop$wands = wands;
        loop$index = index + 1;
      } else {
        return new $option.Some(index);
      }
    } else {
      return new $option.None();
    }
  }
}

/**
 * Find the first empty wand slot (returns index)
 * 
 * @ignore
 */
function find_empty_wand_slot(wands) {
  return find_empty_slot_loop(wands, 0);
}

/**
 * Recharge mana for all wands
 * 
 * @ignore
 */
function recharge_all_wands(wands, dt) {
  return $iv.index_map(
    wands,
    (wand_opt, _) => {
      if (wand_opt instanceof $option.Some) {
        let w = wand_opt[0];
        return new $option.Some($wand.recharge_mana(w, dt));
      } else {
        return wand_opt;
      }
    },
  );
}

/**
 * Reduce cooldowns for all wand states
 * 
 * @ignore
 */
function reduce_all_cooldowns(wand_states, dt) {
  return $iv.index_map(
    wand_states,
    (state, _) => {
      return new WandState(
        reduce_cooldown(state.cast_cooldown, dt),
        state.wand_cast_index,
      );
    },
  );
}

/**
 * Convert screen coordinates to world coordinates at player's Y level
 * Uses proper isometric unprojection based on camera at (d,d,d) looking at origin
 * 
 * @ignore
 */
function screen_to_world_ground(
  screen_pos,
  canvas_size,
  player_x,
  player_z,
  zoom
) {
  let norm_x = (divideFloat(screen_pos.x, canvas_size.x)) - 0.5;
  let norm_y = (divideFloat(screen_pos.y, canvas_size.y)) - 0.5;
  let aspect = divideFloat(canvas_size.x, canvas_size.y);
  let ortho_x = ((norm_x * zoom) * 2.0) * aspect;
  let ortho_y = (norm_y * zoom) * 2.0;
  let right_coef = 0.7071;
  let up_coef = 1.2247;
  let world_x = (player_x + (ortho_x * right_coef)) + (ortho_y * up_coef);
  let world_z = (player_z - (ortho_x * right_coef)) + (ortho_y * up_coef);
  return new Vec3(world_x, 0.0, world_z);
}

function try_cast_spell(model, ctx) {
  let $ = get_active_wand(model);
  if ($ instanceof $option.Some) {
    let active_wand = $[0];
    let active_state = get_active_wand_state(model);
    let mouse_pos = $input.mouse_position(ctx.input);
    let target_ground = screen_to_world_ground(
      mouse_pos,
      ctx.canvas_size,
      model.player_pos.x,
      model.player_pos.z,
      model.zoom,
    );
    let target_pos = new Vec3(
      target_ground.x,
      model.player_pos.y,
      target_ground.z,
    );
    let _block;
    let _pipe = $vec3f.subtract(target_pos, model.player_pos);
    _block = $vec3f.normalize(_pipe);
    let direction = _block;
    let $1 = $wand.cast(
      active_wand,
      active_state.wand_cast_index,
      model.player_pos,
      direction,
      model.next_projectile_id,
      new $option.None(),
      new $option.Some(model.player_pos),
      model.projectiles,
    );
    let result;
    let new_wand;
    result = $1[0];
    new_wand = $1[1];
    if (result instanceof $wand.CastSuccess) {
      let new_projectiles = result.projectiles;
      let next_index = result.next_cast_index;
      let wrapped = result.did_wrap;
      let delay = result.total_cast_delay_addition;
      let recharge_addition = result.total_recharge_time_addition;
      let total_projectiles = $list.append(new_projectiles, model.projectiles);
      let new_id = model.next_projectile_id + $list.length(new_projectiles);
      let total_delay = $duration.add(active_wand.cast_delay, delay);
      let _block$1;
      if (wrapped) {
        let recharge = $duration.add(
          active_wand.recharge_time,
          recharge_addition,
        );
        _block$1 = $duration.add(total_delay, recharge);
      } else {
        _block$1 = total_delay;
      }
      let final_cooldown = _block$1;
      let $2 = $iv.set(
        model.wands,
        model.active_wand_index,
        new $option.Some(new_wand),
      );
      let new_wands;
      if ($2 instanceof Ok) {
        new_wands = $2[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "client/player/magic",
          399,
          "try_cast_spell",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $2,
            start: 12182,
            end: 12353,
            pattern_start: 12193,
            pattern_end: 12206
          }
        )
      }
      let new_state = new WandState(final_cooldown, next_index);
      let $3 = $iv.set(model.wand_states, model.active_wand_index, new_state);
      let new_wand_states;
      if ($3 instanceof Ok) {
        new_wand_states = $3[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "client/player/magic",
          412,
          "try_cast_spell",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $3,
            start: 12547,
            end: 12718,
            pattern_start: 12558,
            pattern_end: 12577
          }
        )
      }
      return new Model(
        new_wands,
        model.active_wand_index,
        new_wand_states,
        total_projectiles,
        new_id,
        model.spell_bag,
        model.selected_spell_slot,
        model.player_pos,
        model.zoom,
      );
    } else if (result instanceof $wand.NotEnoughMana) {
      let $2 = $iv.set(
        model.wands,
        model.active_wand_index,
        new $option.Some(new_wand),
      );
      let new_wands;
      if ($2 instanceof Ok) {
        new_wands = $2[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "client/player/magic",
          429,
          "try_cast_spell",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $2,
            start: 13066,
            end: 13237,
            pattern_start: 13077,
            pattern_end: 13090
          }
        )
      }
      return new Model(
        new_wands,
        model.active_wand_index,
        model.wand_states,
        model.projectiles,
        model.next_projectile_id,
        model.spell_bag,
        model.selected_spell_slot,
        model.player_pos,
        model.zoom,
      );
    } else if (result instanceof $wand.NoSpellToCast) {
      let $2 = $iv.set(
        model.wands,
        model.active_wand_index,
        new $option.Some(new_wand),
      );
      let new_wands;
      if ($2 instanceof Ok) {
        new_wands = $2[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "client/player/magic",
          429,
          "try_cast_spell",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $2,
            start: 13066,
            end: 13237,
            pattern_start: 13077,
            pattern_end: 13090
          }
        )
      }
      return new Model(
        new_wands,
        model.active_wand_index,
        model.wand_states,
        model.projectiles,
        model.next_projectile_id,
        model.spell_bag,
        model.selected_spell_slot,
        model.player_pos,
        model.zoom,
      );
    } else {
      let $2 = $iv.set(
        model.wands,
        model.active_wand_index,
        new $option.Some(new_wand),
      );
      let new_wands;
      if ($2 instanceof Ok) {
        new_wands = $2[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "client/player/magic",
          429,
          "try_cast_spell",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $2,
            start: 13066,
            end: 13237,
            pattern_start: 13077,
            pattern_end: 13090
          }
        )
      }
      return new Model(
        new_wands,
        model.active_wand_index,
        model.wand_states,
        model.projectiles,
        model.next_projectile_id,
        model.spell_bag,
        model.selected_spell_slot,
        model.player_pos,
        model.zoom,
      );
    }
  } else {
    return model;
  }
}

function update_casting(model, ctx) {
  let active_state = get_active_wand_state(model);
  let can_cast = $input.is_left_button_pressed(ctx.input) && ($duration.to_seconds(
    active_state.cast_cooldown,
  ) <= 0.0);
  if (can_cast) {
    return try_cast_spell(model, ctx);
  } else {
    return model;
  }
}

/**
 * Called every frame to update magic state
 * 
 * @ignore
 */
function tick(model, ctx) {
  let dt = ctx.delta_time;
  let model$1 = update_casting(model, ctx);
  let model$2 = update_projectiles(model$1, dt);
  let new_wands = recharge_all_wands(model$2.wands, dt);
  let new_wand_states = reduce_all_cooldowns(model$2.wand_states, dt);
  return new Model(
    new_wands,
    model$2.active_wand_index,
    new_wand_states,
    model$2.projectiles,
    model$2.next_projectile_id,
    model$2.spell_bag,
    model$2.selected_spell_slot,
    model$2.player_pos,
    model$2.zoom,
  );
}

export function update(model, msg, ctx) {
  if (msg instanceof Tick) {
    let new_model = tick(model, ctx);
    return [new_model, $effect.dispatch(new Tick())];
  } else if (msg instanceof UpdatePlayerState) {
    let player_pos = msg.player_pos;
    let zoom = msg.zoom;
    return [
      new Model(
        model.wands,
        model.active_wand_index,
        model.wand_states,
        model.projectiles,
        model.next_projectile_id,
        model.spell_bag,
        model.selected_spell_slot,
        player_pos,
        zoom,
      ),
      $effect.none(),
    ];
  } else if (msg instanceof PlaceSpellInSlot) {
    let spell_id = msg.spell_id;
    let slot_index = msg.slot_index;
    let _block;
    let _pipe = $spell_bag.list_spells(model.spell_bag);
    _block = $list.find(_pipe, (s) => { return isEqual(s.id, spell_id); });
    let maybe_spell = _block;
    let $ = get_active_wand(model);
    if (maybe_spell instanceof Ok && $ instanceof $option.Some) {
      let spell_to_place = maybe_spell[0];
      let active_wand = $[0];
      let _block$1;
      let $1 = $wand.get_spell(active_wand, slot_index);
      if ($1 instanceof Ok) {
        let $2 = $1[0];
        if ($2 instanceof $option.Some) {
          let spell = $2[0];
          _block$1 = new $option.Some(spell);
        } else {
          _block$1 = new $option.None();
        }
      } else {
        _block$1 = new $option.None();
      }
      let existing_spell = _block$1;
      let updated_bag = $spell_bag.remove_spell(model.spell_bag, spell_to_place);
      let $2 = $iv.set(
        active_wand.slots,
        slot_index,
        new $option.Some(spell_to_place),
      );
      if ($2 instanceof Ok) {
        let new_slots = $2[0];
        let new_wand = new $wand.Wand(
          active_wand.name,
          new_slots,
          active_wand.max_mana,
          active_wand.current_mana,
          active_wand.mana_recharge_rate,
          active_wand.cast_delay,
          active_wand.recharge_time,
          active_wand.spells_per_cast,
          active_wand.spread,
        );
        let _block$2;
        if (existing_spell instanceof $option.Some) {
          let old_spell = existing_spell[0];
          _block$2 = $spell_bag.add_spell(updated_bag, old_spell);
        } else {
          _block$2 = updated_bag;
        }
        let final_bag = _block$2;
        let $3 = $iv.set(
          model.wands,
          model.active_wand_index,
          new $option.Some(new_wand),
        );
        if ($3 instanceof Ok) {
          let new_wands = $3[0];
          let new_model = new Model(
            new_wands,
            model.active_wand_index,
            model.wand_states,
            model.projectiles,
            model.next_projectile_id,
            final_bag,
            model.selected_spell_slot,
            model.player_pos,
            model.zoom,
          );
          return [new_model, $effect.none()];
        } else {
          return [model, $effect.none()];
        }
      } else {
        return [model, $effect.none()];
      }
    } else {
      return [model, $effect.none()];
    }
  } else if (msg instanceof SelectSlot) {
    let slot_index = msg[0];
    let new_model = new Model(
      model.wands,
      model.active_wand_index,
      model.wand_states,
      model.projectiles,
      model.next_projectile_id,
      model.spell_bag,
      new $option.Some(slot_index),
      model.player_pos,
      model.zoom,
    );
    return [new_model, $effect.none()];
  } else if (msg instanceof ReorderWandSlots) {
    let from_index = msg.from_index;
    let to_index = msg.to_index;
    let $ = get_active_wand(model);
    if ($ instanceof $option.Some) {
      let active_wand = $[0];
      let slots_list = $iv.to_list(active_wand.slots);
      let reordered = $ensaimada.reorder(slots_list, from_index, to_index);
      let new_slots = $iv.from_list(reordered);
      let new_wand = new $wand.Wand(
        active_wand.name,
        new_slots,
        active_wand.max_mana,
        active_wand.current_mana,
        active_wand.mana_recharge_rate,
        active_wand.cast_delay,
        active_wand.recharge_time,
        active_wand.spells_per_cast,
        active_wand.spread,
      );
      let $1 = $iv.set(
        model.wands,
        model.active_wand_index,
        new $option.Some(new_wand),
      );
      if ($1 instanceof Ok) {
        let new_wands = $1[0];
        let new_model = new Model(
          new_wands,
          model.active_wand_index,
          model.wand_states,
          model.projectiles,
          model.next_projectile_id,
          model.spell_bag,
          model.selected_spell_slot,
          model.player_pos,
          model.zoom,
        );
        return [new_model, $effect.none()];
      } else {
        return [model, $effect.none()];
      }
    } else {
      return [model, $effect.none()];
    }
  } else if (msg instanceof RemoveProjectile) {
    let projectile_id = msg[0];
    let new_projectiles = $list.filter(
      model.projectiles,
      (p) => { return p.id !== projectile_id; },
    );
    return [
      new Model(
        model.wands,
        model.active_wand_index,
        model.wand_states,
        new_projectiles,
        model.next_projectile_id,
        model.spell_bag,
        model.selected_spell_slot,
        model.player_pos,
        model.zoom,
      ),
      $effect.none(),
    ];
  } else if (msg instanceof SwitchWand) {
    let wand_index = msg.wand_index;
    let $ = (wand_index >= 0) && (wand_index <= 3);
    if ($) {
      return [
        new Model(
          model.wands,
          wand_index,
          model.wand_states,
          model.projectiles,
          model.next_projectile_id,
          model.spell_bag,
          model.selected_spell_slot,
          model.player_pos,
          model.zoom,
        ),
        $effect.none(),
      ];
    } else {
      return [model, $effect.none()];
    }
  } else if (msg instanceof SwitchWandRelative) {
    let delta = msg.delta;
    let new_index = ((model.active_wand_index + delta) + 4) % 4;
    return [
      new Model(
        model.wands,
        new_index,
        model.wand_states,
        model.projectiles,
        model.next_projectile_id,
        model.spell_bag,
        model.selected_spell_slot,
        model.player_pos,
        model.zoom,
      ),
      $effect.none(),
    ];
  } else if (msg instanceof PickUpWand) {
    let new_wand = msg[0];
    let _block;
    let _pipe = find_empty_wand_slot(model.wands);
    _block = $option.unwrap(_pipe, model.active_wand_index);
    let slot_to_use = _block;
    let $ = $iv.set(model.wands, slot_to_use, new $option.Some(new_wand));
    if ($ instanceof Ok) {
      let new_wands = $[0];
      return [
        new Model(
          new_wands,
          slot_to_use,
          model.wand_states,
          model.projectiles,
          model.next_projectile_id,
          model.spell_bag,
          model.selected_spell_slot,
          model.player_pos,
          model.zoom,
        ),
        $effect.none(),
      ];
    } else {
      return [model, $effect.none()];
    }
  } else {
    let slot_index = msg.slot_index;
    let $ = get_active_wand(model);
    if ($ instanceof $option.Some) {
      let active_wand = $[0];
      let $1 = $wand.get_spell(active_wand, slot_index);
      if ($1 instanceof Ok) {
        let $2 = $1[0];
        if ($2 instanceof $option.Some) {
          let spell_to_remove = $2[0];
          let $3 = $iv.set(active_wand.slots, slot_index, new $option.None());
          if ($3 instanceof Ok) {
            let new_slots = $3[0];
            let new_wand = new $wand.Wand(
              active_wand.name,
              new_slots,
              active_wand.max_mana,
              active_wand.current_mana,
              active_wand.mana_recharge_rate,
              active_wand.cast_delay,
              active_wand.recharge_time,
              active_wand.spells_per_cast,
              active_wand.spread,
            );
            let updated_bag = $spell_bag.add_spell(
              model.spell_bag,
              spell_to_remove,
            );
            let $4 = $iv.set(
              model.wands,
              model.active_wand_index,
              new $option.Some(new_wand),
            );
            if ($4 instanceof Ok) {
              let new_wands = $4[0];
              return [
                new Model(
                  new_wands,
                  model.active_wand_index,
                  model.wand_states,
                  model.projectiles,
                  model.next_projectile_id,
                  updated_bag,
                  model.selected_spell_slot,
                  model.player_pos,
                  model.zoom,
                ),
                $effect.none(),
              ];
            } else {
              return [model, $effect.none()];
            }
          } else {
            return [model, $effect.none()];
          }
        } else {
          return [model, $effect.none()];
        }
      } else {
        return [model, $effect.none()];
      }
    } else {
      return [model, $effect.none()];
    }
  }
}

function get_spell_color(spell_type) {
  if (spell_type instanceof $spell.DamageSpell) {
    let $ = spell_type.id;
    if ($ instanceof $spell.Fireball) {
      return 0xFF4400;
    } else if ($ instanceof $spell.LightningBolt) {
      return 0xFFFF;
    } else if ($ instanceof $spell.Spark) {
      return 0xFFFF00;
    } else if ($ instanceof $spell.SparkWithTrigger) {
      return 0xFFAA00;
    } else if ($ instanceof $spell.OrbitingSpell) {
      return 0xFF00FF;
    } else {
      return 0xFFFFFF;
    }
  } else if (spell_type instanceof $spell.ModifierSpell) {
    return 0xFF00;
  } else {
    return 0xFF;
  }
}

function view_projectile(projectile, physics_world, camera_pos, game_assets) {
  let size = projectile.spell.final_size;
  let _block;
  let $1 = projectile.visuals.projectile;
  let path = $1.texture_path;
  let s = $1.size;
  _block = [s, path];
  let $ = _block;
  let sprite_size;
  let texture_path;
  sprite_size = $[0];
  texture_path = $[1];
  let $2 = $geometry.plane(
    new $vec2.Vec2(sprite_size.x * size, sprite_size.y * size),
  );
  let proj_geo;
  if ($2 instanceof Ok) {
    proj_geo = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/player/magic",
      643,
      "view_projectile",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 19376,
        end: 19502,
        pattern_start: 19387,
        pattern_end: 19399
      }
    )
  }
  let _block$1;
  let $3 = $assets.texture_id_for_path(texture_path);
  if ($3 instanceof $option.Some) {
    let id = $3[0];
    _block$1 = $assets.get_texture(game_assets, id);
  } else {
    _block$1 = $3;
  }
  let maybe_texture = _block$1;
  let _block$2;
  if (maybe_texture instanceof $option.Some) {
    let tex = maybe_texture[0];
    let $4 = $material.basic(
      0xFFFFFF,
      true,
      1.0,
      new $option.Some(tex),
      new $material.DoubleSide(),
      0.1,
      false,
    );
    let mat;
    if ($4 instanceof Ok) {
      mat = $4[0];
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "client/player/magic",
        658,
        "view_projectile",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $4,
          start: 19836,
          end: 20097,
          pattern_start: 19847,
          pattern_end: 19854
        }
      )
    }
    _block$2 = mat;
  } else {
    let color = get_spell_color(projectile.spell.base);
    let _block$3;
    let _pipe = $material.new$();
    let _pipe$1 = $material.with_color(_pipe, color);
    let _pipe$2 = $material.with_emissive(_pipe$1, color);
    let _pipe$3 = $material.with_emissive_intensity(_pipe$2, 0.8);
    _block$3 = $material.build(_pipe$3);
    let $4 = _block$3;
    let mat;
    if ($4 instanceof Ok) {
      mat = $4[0];
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "client/player/magic",
        673,
        "view_projectile",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $4,
          start: 20245,
          end: 20444,
          pattern_start: 20256,
          pattern_end: 20263
        }
      )
    }
    _block$2 = mat;
  }
  let proj_mat = _block$2;
  let _block$3;
  let _pipe = $physics.new_rigid_body(new $physics.Dynamic());
  let _pipe$1 = $physics.with_collider(
    _pipe,
    new $physics.Sphere($transform.identity, size / 2.0),
  );
  let _pipe$2 = $physics.with_collision_groups(
    _pipe$1,
    toList([$layer.projectile]),
    toList([$layer.enemy]),
  );
  let _pipe$3 = $physics.with_collision_events(_pipe$2);
  let _pipe$4 = $physics.with_sensor(_pipe$3);
  let _pipe$5 = $physics.with_body_ccd_enabled(_pipe$4);
  let _pipe$6 = $physics.with_lock_translation_y(_pipe$5);
  _block$3 = $physics.build(_pipe$6);
  let physics_body = _block$3;
  let body_id = $id.to_string(new $id.Projectile(projectile.id));
  let _block$4;
  let $4 = $physics.get_transform(physics_world, body_id);
  if ($4 instanceof Ok) {
    let t = $4[0];
    _block$4 = $transform.position(t);
  } else {
    _block$4 = projectile.position;
  }
  let proj_position = _block$4;
  let proj_transform = $transform.billboard(
    proj_position,
    camera_pos,
    new $transform.Cylindrical(),
  );
  return $scene.mesh(
    body_id,
    proj_geo,
    proj_mat,
    proj_transform,
    new $option.Some(physics_body),
  );
}

/**
 * Returns projectile scene nodes
 */
export function view(model, physics_world, camera_pos, game_assets) {
  return $list.map(
    model.projectiles,
    (p) => { return view_projectile(p, physics_world, camera_pos, game_assets); },
  );
}

/**
 * Get wand state for UI synchronization (for active wand)
 */
export function get_wand_ui_state(model) {
  let $ = get_active_wand(model);
  if ($ instanceof $option.Some) {
    let active_wand = $[0];
    let slot_count = $iv.size(active_wand.slots);
    let _block;
    let _pipe = $list.range(0, slot_count - 1);
    _block = $list.map(
      _pipe,
      (i) => {
        let $1 = $wand.get_spell(active_wand, i);
        if ($1 instanceof Ok) {
          let spell_opt = $1[0];
          return spell_opt;
        } else {
          return new $option.None();
        }
      },
    );
    let slots = _block;
    return [
      slots,
      model.selected_spell_slot,
      active_wand.current_mana,
      active_wand.max_mana,
      model.spell_bag,
    ];
  } else {
    return [toList([]), new $option.None(), 0.0, 0.0, model.spell_bag];
  }
}

/**
 * Get wand inventory state for UI
 */
export function get_wand_inventory(model) {
  return $iv.to_list(model.wands);
}

/**
 * Get the active wand index
 */
export function get_active_wand_index(model) {
  return model.active_wand_index;
}

/**
 * Get current projectiles for collision detection
 */
export function get_projectiles(model) {
  return model.projectiles;
}

/**
 * Get all wands with their cast indices for inventory display
 */
export function get_all_wands_with_cast_indices(model) {
  let _pipe = $iv.to_list(model.wands);
  return $list.index_map(
    _pipe,
    (wand_opt, index) => {
      let _block;
      let $ = $iv.get(model.wand_states, index);
      if ($ instanceof Ok && wand_opt instanceof $option.Some) {
        let state = $[0];
        let w = wand_opt[0];
        _block = find_next_spell_index(w.slots, state.wand_cast_index);
      } else {
        _block = 0;
      }
      let cast_index = _block;
      return [wand_opt, cast_index];
    },
  );
}
