import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $tiramisu from "../../tiramisu/tiramisu.mjs";
import * as $effect from "../../tiramisu/tiramisu/effect.mjs";
import * as $geometry from "../../tiramisu/tiramisu/geometry.mjs";
import * as $input from "../../tiramisu/tiramisu/input.mjs";
import * as $material from "../../tiramisu/tiramisu/material.mjs";
import * as $scene from "../../tiramisu/tiramisu/scene.mjs";
import * as $transform from "../../tiramisu/tiramisu/transform.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { Vec3 } from "../../vec/vec/vec3.mjs";
import * as $vec3f from "../../vec/vec/vec3f.mjs";
import * as $id from "../client/id.mjs";
import * as $spell from "../client/magic_system/spell.mjs";
import * as $wand from "../client/magic_system/wand.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  makeError,
  isEqual,
} from "../gleam.mjs";

const FILEPATH = "src/client/altar.gleam";

export class Altar extends $CustomType {
  constructor(id, position, wand) {
    super();
    this.id = id;
    this.position = position;
    this.wand = wand;
  }
}
export const Altar$Altar = (id, position, wand) =>
  new Altar(id, position, wand);
export const Altar$isAltar = (value) => value instanceof Altar;
export const Altar$Altar$id = (value) => value.id;
export const Altar$Altar$0 = (value) => value.id;
export const Altar$Altar$position = (value) => value.position;
export const Altar$Altar$1 = (value) => value.position;
export const Altar$Altar$wand = (value) => value.wand;
export const Altar$Altar$2 = (value) => value.wand;

export class Model extends $CustomType {
  constructor(altars, next_altar_id) {
    super();
    this.altars = altars;
    this.next_altar_id = next_altar_id;
  }
}
export const Model$Model = (altars, next_altar_id) =>
  new Model(altars, next_altar_id);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$altars = (value) => value.altars;
export const Model$Model$0 = (value) => value.altars;
export const Model$Model$next_altar_id = (value) => value.next_altar_id;
export const Model$Model$1 = (value) => value.next_altar_id;

export class Tick extends $CustomType {}
export const Msg$Tick = () => new Tick();
export const Msg$isTick = (value) => value instanceof Tick;

export class EnemyDied extends $CustomType {
  constructor(position) {
    super();
    this.position = position;
  }
}
export const Msg$EnemyDied = (position) => new EnemyDied(position);
export const Msg$isEnemyDied = (value) => value instanceof EnemyDied;
export const Msg$EnemyDied$position = (value) => value.position;
export const Msg$EnemyDied$0 = (value) => value.position;

export class RemoveAltar extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$RemoveAltar = ($0) => new RemoveAltar($0);
export const Msg$isRemoveAltar = (value) => value instanceof RemoveAltar;
export const Msg$RemoveAltar$0 = (value) => value[0];

/**
 * Distance player must be within to pick up a wand from altar
 * 
 * @ignore
 */
const pickup_range = 3.0;

/**
 * Height offset for altar spawn (so it sits on ground)
 * 
 * @ignore
 */
const altar_y_offset = 0.5;

export function init() {
  let model = new Model(toList([]), 0);
  return [model, $effect.dispatch(new Tick())];
}

function add_random_spells(loop$w, loop$remaining, loop$slot_index) {
  while (true) {
    let w = loop$w;
    let remaining = loop$remaining;
    let slot_index = loop$slot_index;
    let $ = remaining <= 0;
    if ($) {
      return w;
    } else {
      let spell = $spell.random_spell();
      let $1 = $wand.set_spell(w, slot_index, spell);
      if ($1 instanceof Ok) {
        let new_wand = $1[0];
        loop$w = new_wand;
        loop$remaining = remaining - 1;
        loop$slot_index = slot_index + 1;
      } else {
        return w;
      }
    }
  }
}

/**
 * Populate a wand with random spells
 * 
 * @ignore
 */
function populate_wand_with_spells(w) {
  let spell_count = 1 + $int.random(3);
  return add_random_spells(w, spell_count, 0);
}

/**
 * Calculate horizontal distance (ignoring Y)
 * 
 * @ignore
 */
function distance_xz(a, b) {
  let diff = new Vec3(a.x - b.x, 0.0, a.z - b.z);
  return $vec3f.length(diff);
}

function view_altar(altar) {
  let $ = $geometry.box(new Vec3(1.5, 0.8, 1.5));
  let pedestal_geo;
  if ($ instanceof Ok) {
    pedestal_geo = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/altar",
      204,
      "view_altar",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 5919,
        end: 5982,
        pattern_start: 5930,
        pattern_end: 5946
      }
    )
  }
  let _block;
  let _pipe = $material.new$();
  let _pipe$1 = $material.with_color(_pipe, 0x8B4513);
  _block = $material.build(_pipe$1);
  let $1 = _block;
  let pedestal_mat;
  if ($1 instanceof Ok) {
    pedestal_mat = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/altar",
      207,
      "view_altar",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 6026,
        end: 6135,
        pattern_start: 6037,
        pattern_end: 6053
      }
    )
  }
  let $2 = $geometry.box(new Vec3(0.6, 0.6, 0.6));
  let orb_geo;
  if ($2 instanceof Ok) {
    orb_geo = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/altar",
      213,
      "view_altar",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 6227,
        end: 6285,
        pattern_start: 6238,
        pattern_end: 6249
      }
    )
  }
  let _block$1;
  let _pipe$2 = $material.new$();
  let _pipe$3 = $material.with_color(_pipe$2, 0xFFD700);
  let _pipe$4 = $material.with_emissive(_pipe$3, 0xFFD700);
  let _pipe$5 = $material.with_emissive_intensity(_pipe$4, 1.5);
  _block$1 = $material.build(_pipe$5);
  let $3 = _block$1;
  let orb_mat;
  if ($3 instanceof Ok) {
    orb_mat = $3[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/altar",
      216,
      "view_altar",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $3,
        start: 6306,
        end: 6495,
        pattern_start: 6317,
        pattern_end: 6328
      }
    )
  }
  let body_id = $id.to_string(altar.id);
  let altar_transform = $transform.at(altar.position);
  let orb_node = $scene.mesh(
    body_id + "_orb",
    orb_geo,
    orb_mat,
    $transform.at(new Vec3(0.0, 0.8, 0.0)),
    new $option.None(),
  );
  let _pipe$6 = $scene.mesh(
    body_id,
    pedestal_geo,
    pedestal_mat,
    altar_transform,
    new $option.None(),
  );
  return $scene.with_children(_pipe$6, toList([orb_node]));
}

export function view(model, _) {
  return $list.map(model.altars, (altar) => { return view_altar(altar); });
}

/**
 * Find the nearest altar within pickup range
 * Returns the altar if found
 */
export function get_nearest_altar(model, player_pos) {
  let altars_with_distance = $list.filter_map(
    model.altars,
    (altar) => {
      let distance = distance_xz(player_pos, altar.position);
      let $ = distance <= pickup_range;
      if ($) {
        return new Ok([altar, distance]);
      } else {
        return new Error(undefined);
      }
    },
  );
  if (altars_with_distance instanceof $Empty) {
    return new $option.None();
  } else {
    let first = altars_with_distance.head;
    let rest = altars_with_distance.tail;
    let $ = $list.fold(
      rest,
      first,
      (closest, current) => {
        let closest_dist;
        closest_dist = closest[1];
        let current_dist;
        current_dist = current[1];
        let $1 = current_dist < closest_dist;
        if ($1) {
          return current;
        } else {
          return closest;
        }
      },
    );
    let nearest;
    nearest = $[0];
    return new $option.Some(nearest);
  }
}

/**
 * Create a new altar with a random wand and random spells
 * 
 * @ignore
 */
function create_altar(altar_num, position) {
  let altar_id = new $id.Altar(altar_num);
  let random_wand = $wand.new_random("Found Wand #" + $int.to_string(altar_num));
  let wand_with_spells = populate_wand_with_spells(random_wand);
  return new Altar(
    altar_id,
    new Vec3(position.x, altar_y_offset, position.z),
    wand_with_spells,
  );
}

/**
 * Update altars. Accepts taggers for cross-module dispatch.
 */
export function update(model, msg, ctx, player_pos, pick_up_wand, effect_mapper) {
  if (msg instanceof Tick) {
    let _block;
    let $ = $input.is_key_just_pressed(ctx.input, new $input.KeyE());
    if ($) {
      let $1 = get_nearest_altar(model, player_pos);
      if ($1 instanceof $option.Some) {
        let nearby = $1[0];
        _block = $effect.batch(
          toList([
            $effect.dispatch(pick_up_wand(nearby.wand)),
            $effect.dispatch(effect_mapper(new RemoveAltar(nearby.id))),
          ]),
        );
      } else {
        _block = $effect.none();
      }
    } else {
      _block = $effect.none();
    }
    let pickup_effect = _block;
    return [
      model,
      $effect.batch(
        toList([$effect.dispatch(effect_mapper(new Tick())), pickup_effect]),
      ),
    ];
  } else if (msg instanceof EnemyDied) {
    let position = msg.position;
    let altar = create_altar(model.next_altar_id, position);
    return [
      new Model(listPrepend(altar, model.altars), model.next_altar_id + 1),
      $effect.none(),
    ];
  } else {
    let altar_id = msg[0];
    let updated_altars = $list.filter(
      model.altars,
      (altar) => { return !isEqual(altar.id, altar_id); },
    );
    return [new Model(updated_altars, model.next_altar_id), $effect.none()];
  }
}
