import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $tiramisu from "../../tiramisu/tiramisu.mjs";
import * as $camera from "../../tiramisu/tiramisu/camera.mjs";
import * as $effect from "../../tiramisu/tiramisu/effect.mjs";
import * as $geometry from "../../tiramisu/tiramisu/geometry.mjs";
import * as $input from "../../tiramisu/tiramisu/input.mjs";
import * as $material from "../../tiramisu/tiramisu/material.mjs";
import * as $physics from "../../tiramisu/tiramisu/physics.mjs";
import * as $scene from "../../tiramisu/tiramisu/scene.mjs";
import * as $transform from "../../tiramisu/tiramisu/transform.mjs";
import * as $vec2 from "../../vec/vec/vec2.mjs";
import { Vec2 } from "../../vec/vec/vec2.mjs";
import * as $vec2f from "../../vec/vec/vec2f.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { Vec3 } from "../../vec/vec/vec3.mjs";
import * as $assets from "../client/assets.mjs";
import * as $layer from "../client/game_physics/layer.mjs";
import * as $health from "../client/health.mjs";
import * as $id from "../client/id.mjs";
import * as $spell from "../client/magic_system/spell.mjs";
import * as $spell_bag from "../client/magic_system/spell_bag.mjs";
import * as $wand from "../client/magic_system/wand.mjs";
import * as $magic from "../client/player/magic.mjs";
import {
  Ok,
  toList,
  prepend as listPrepend,
  CustomType as $CustomType,
  makeError,
  divideFloat,
} from "../gleam.mjs";

const FILEPATH = "src/client/player.gleam";

export class Model extends $CustomType {
  constructor(position, zoom, magic, health, player_geometry, player_material) {
    super();
    this.position = position;
    this.zoom = zoom;
    this.magic = magic;
    this.health = health;
    this.player_geometry = player_geometry;
    this.player_material = player_material;
  }
}
export const Model$Model = (position, zoom, magic, health, player_geometry, player_material) =>
  new Model(position, zoom, magic, health, player_geometry, player_material);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$position = (value) => value.position;
export const Model$Model$0 = (value) => value.position;
export const Model$Model$zoom = (value) => value.zoom;
export const Model$Model$1 = (value) => value.zoom;
export const Model$Model$magic = (value) => value.magic;
export const Model$Model$2 = (value) => value.magic;
export const Model$Model$health = (value) => value.health;
export const Model$Model$3 = (value) => value.health;
export const Model$Model$player_geometry = (value) => value.player_geometry;
export const Model$Model$4 = (value) => value.player_geometry;
export const Model$Model$player_material = (value) => value.player_material;
export const Model$Model$5 = (value) => value.player_material;

export class Tick extends $CustomType {}
export const Msg$Tick = () => new Tick();
export const Msg$isTick = (value) => value instanceof Tick;

export class MagicMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$MagicMsg = ($0) => new MagicMsg($0);
export const Msg$isMagicMsg = (value) => value instanceof MagicMsg;
export const Msg$MagicMsg$0 = (value) => value[0];

export class DamageReceived extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$DamageReceived = ($0) => new DamageReceived($0);
export const Msg$isDamageReceived = (value) => value instanceof DamageReceived;
export const Msg$DamageReceived$0 = (value) => value[0];

const move_speed = 30.0;

const zoom_speed = 50.0;

const min_zoom = 5.0;

const max_zoom = 100.0;

const initial_zoom = 30.0;

const camera_distance = 50.0;

const initial_health = 100.0;

const isometric_up = /* @__PURE__ */ new Vec2(-0.7071, -0.7071);

const isometric_right = /* @__PURE__ */ new Vec2(0.7071, -0.7071);

function get_screen_input(ctx) {
  let up = $input.is_key_pressed(ctx.input, new $input.KeyW()) || $input.is_key_pressed(
    ctx.input,
    new $input.ArrowUp(),
  );
  let down = $input.is_key_pressed(ctx.input, new $input.KeyS()) || $input.is_key_pressed(
    ctx.input,
    new $input.ArrowDown(),
  );
  let left = $input.is_key_pressed(ctx.input, new $input.KeyA()) || $input.is_key_pressed(
    ctx.input,
    new $input.ArrowLeft(),
  );
  let right = $input.is_key_pressed(ctx.input, new $input.KeyD()) || $input.is_key_pressed(
    ctx.input,
    new $input.ArrowRight(),
  );
  let _block;
  if (up) {
    if (!down) {
      _block = 1.0;
    } else {
      _block = 0.0;
    }
  } else if (down) {
    _block = -1.0;
  } else {
    _block = 0.0;
  }
  let screen_y = _block;
  let _block$1;
  if (left) {
    if (!right) {
      _block$1 = -1.0;
    } else {
      _block$1 = 0.0;
    }
  } else if (right) {
    _block$1 = 1.0;
  } else {
    _block$1 = 0.0;
  }
  let screen_x = _block$1;
  return new Vec2(screen_x, screen_y);
}

/**
 * Check for wand switch inputs and return appropriate effect
 * 
 * @ignore
 */
function get_wand_switch_effect(ctx, effect_mapper) {
  let _block;
  let $ = $input.is_key_just_pressed(ctx.input, new $input.Digit1());
  let $1 = $input.is_key_just_pressed(ctx.input, new $input.Digit2());
  let $2 = $input.is_key_just_pressed(ctx.input, new $input.Digit3());
  let $3 = $input.is_key_just_pressed(ctx.input, new $input.Digit4());
  if ($) {
    _block = $effect.dispatch(
      effect_mapper(new MagicMsg(new $magic.SwitchWand(0))),
    );
  } else if ($1) {
    _block = $effect.dispatch(
      effect_mapper(new MagicMsg(new $magic.SwitchWand(1))),
    );
  } else if ($2) {
    _block = $effect.dispatch(
      effect_mapper(new MagicMsg(new $magic.SwitchWand(2))),
    );
  } else if ($3) {
    _block = $effect.dispatch(
      effect_mapper(new MagicMsg(new $magic.SwitchWand(3))),
    );
  } else {
    _block = $effect.none();
  }
  let key_effect = _block;
  let shift_held = $input.is_key_pressed(ctx.input, new $input.ShiftLeft()) || $input.is_key_pressed(
    ctx.input,
    new $input.ShiftRight(),
  );
  let wheel_delta = $input.mouse_wheel_delta(ctx.input);
  let _block$1;
  if (shift_held) {
    let d = wheel_delta;
    if (d > 0.0) {
      _block$1 = $effect.dispatch(
        effect_mapper(new MagicMsg(new $magic.SwitchWandRelative(-1))),
      );
    } else {
      let d = wheel_delta;
      if (d < 0.0) {
        _block$1 = $effect.dispatch(
          effect_mapper(new MagicMsg(new $magic.SwitchWandRelative(1))),
        );
      } else {
        _block$1 = $effect.none();
      }
    }
  } else {
    _block$1 = $effect.none();
  }
  let scroll_effect = _block$1;
  return $effect.batch(toList([key_effect, scroll_effect]));
}

/**
 * Get wand state for UI synchronization (active wand)
 */
export function get_wand_ui_state(model) {
  return $magic.get_wand_ui_state(model.magic);
}

/**
 * Get wand inventory for UI
 */
export function get_wand_inventory(model) {
  return $magic.get_wand_inventory(model.magic);
}

/**
 * Get wand names for UI display
 */
export function get_wand_names(model) {
  let _pipe = $magic.get_wand_inventory(model.magic);
  return $list.map(
    _pipe,
    (wand_opt) => {
      if (wand_opt instanceof $option.Some) {
        let w = wand_opt[0];
        return new $option.Some(w.name);
      } else {
        return wand_opt;
      }
    },
  );
}

/**
 * Get active wand index
 */
export function get_active_wand_index(model) {
  return $magic.get_active_wand_index(model.magic);
}

/**
 * Get the currently active wand (if any)
 */
export function get_active_wand(model) {
  return $magic.get_active_wand(model.magic);
}

/**
 * Get the wand cast index for UI display
 */
export function get_wand_cast_index(model) {
  return $magic.get_wand_cast_index(model.magic);
}

/**
 * Get current projectiles for collision detection
 */
export function get_projectiles(model) {
  return $magic.get_projectiles(model.magic);
}

/**
 * Get all wands with their cast indices for inventory display
 */
export function get_all_wands_with_cast_indices(model) {
  return $magic.get_all_wands_with_cast_indices(model.magic);
}

function create_camera(model, ctx) {
  let ortho_size = model.zoom;
  let aspect = divideFloat(ctx.canvas_size.x, ctx.canvas_size.y);
  let cam = $camera.orthographic(
    0.0 - (ortho_size * aspect),
    ortho_size * aspect,
    ortho_size,
    0.0 - ortho_size,
    0.1,
    1000.0,
  );
  let camera_pos = $transform.at(
    new Vec3(camera_distance, camera_distance, camera_distance),
  );
  let target_pos = $transform.at(new Vec3(0.0, 0.0, 0.0));
  let camera_transform = $transform.look_at(
    camera_pos,
    target_pos,
    new $option.Some(new Vec3(0.0, 1.0, 0.0)),
  );
  return $scene.camera(
    "main-camera",
    cam,
    camera_transform,
    true,
    new $option.None(),
    new $option.None(),
  );
}

export function view(model, ctx, game_assets) {
  let $ = ctx.physics_world;
  let physics_world;
  if ($ instanceof $option.Some) {
    physics_world = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/player",
      327,
      "view",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 9422,
        end: 9479,
        pattern_start: 9433,
        pattern_end: 9459
      }
    )
  }
  let _block;
  let _pipe = $physics.new_rigid_body(new $physics.Kinematic());
  let _pipe$1 = $physics.with_collider(
    _pipe,
    new $physics.Capsule($transform.identity, 1.0, 0.5),
  );
  let _pipe$2 = $physics.with_collision_groups(
    _pipe$1,
    toList([$layer.player]),
    toList([$layer.enemy, $layer.map]),
  );
  let _pipe$3 = $physics.with_character_controller(
    _pipe$2,
    1.0,
    new Vec3(0.0, 1.0, 0.0),
    true,
  );
  let _pipe$4 = $physics.with_collision_events(_pipe$3);
  let _pipe$5 = $physics.with_friction(_pipe$4, 0.0);
  _block = $physics.build(_pipe$5);
  let physics_body = _block;
  let camera_node = create_camera(model, ctx);
  let _block$1;
  let _pipe$6 = $scene.mesh(
    $id.to_string(new $id.Player()),
    model.player_geometry,
    model.player_material,
    $transform.at(model.position),
    new $option.Some(physics_body),
  );
  _block$1 = $scene.with_children(_pipe$6, toList([camera_node]));
  let player_node = _block$1;
  let camera_world_pos = new Vec3(
    model.position.x + camera_distance,
    model.position.y + camera_distance,
    model.position.z + camera_distance,
  );
  let projectile_nodes = $magic.view(
    model.magic,
    physics_world,
    camera_world_pos,
    game_assets,
  );
  return listPrepend(player_node, projectile_nodes);
}

export function init() {
  let $ = $magic.init();
  let magic_model;
  let magic_effect;
  magic_model = $[0];
  magic_effect = $[1];
  let $1 = $geometry.box(new Vec3(1.0, 2.0, 1.0));
  let player_geo;
  if ($1 instanceof Ok) {
    player_geo = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/player",
      80,
      "init",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 1930,
        end: 1991,
        pattern_start: 1941,
        pattern_end: 1955
      }
    )
  }
  let _block;
  let _pipe = $material.new$();
  let _pipe$1 = $material.with_color(_pipe, 0x4ecdc4);
  _block = $material.build(_pipe$1);
  let $2 = _block;
  let player_mat;
  if ($2 instanceof Ok) {
    player_mat = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/player",
      81,
      "init",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 1994,
        end: 2101,
        pattern_start: 2005,
        pattern_end: 2019
      }
    )
  }
  return [
    new Model(
      new $vec3.Vec3(0.0, 1.0, 0.0),
      initial_zoom,
      magic_model,
      $health.new$(initial_health),
      player_geo,
      player_mat,
    ),
    $effect.batch(
      toList([
        $effect.dispatch(new Tick()),
        $effect.map(magic_effect, (var0) => { return new MagicMsg(var0); }),
      ]),
    ),
  ];
}

function screen_to_world_movement(screen_input) {
  let from_vertical = $vec2f.scale(isometric_up, screen_input.y);
  let from_horizontal = $vec2f.scale(isometric_right, screen_input.x);
  let combined = $vec2f.add(from_vertical, from_horizontal);
  let $ = $vec2f.length(combined) > 0.0;
  if ($) {
    return $vec2f.normalize(combined);
  } else {
    return $vec2f.zero;
  }
}

function update_movement(model, ctx) {
  let dt = $duration.to_seconds(ctx.delta_time);
  let screen_input = get_screen_input(ctx);
  let world_movement = screen_to_world_movement(screen_input);
  let shift_held = $input.is_key_pressed(ctx.input, new $input.ShiftLeft()) || $input.is_key_pressed(
    ctx.input,
    new $input.ShiftRight(),
  );
  let wheel_delta = $input.mouse_wheel_delta(ctx.input);
  let _block;
  if (shift_held) {
    _block = 0.0;
  } else {
    _block = (wheel_delta * zoom_speed) * dt;
  }
  let zoom_change = _block;
  let new_zoom = $float.clamp(model.zoom + zoom_change, min_zoom, max_zoom);
  let desired_x = (world_movement.x * move_speed) * dt;
  let desired_z = (world_movement.y * move_speed) * dt;
  let desired_translation = new Vec3(desired_x, 0.0, desired_z);
  let _block$1;
  let $ = ctx.physics_world;
  if ($ instanceof $option.Some) {
    let physics_world = $[0];
    let player_id = $id.to_string(new $id.Player());
    let $1 = $physics.compute_character_movement(
      physics_world,
      player_id,
      desired_translation,
    );
    if ($1 instanceof Ok) {
      let safe_movement = $1[0];
      _block$1 = new Vec3(
        model.position.x + safe_movement.x,
        model.position.y,
        model.position.z + safe_movement.z,
      );
    } else {
      _block$1 = new Vec3(
        model.position.x + desired_x,
        model.position.y,
        model.position.z + desired_z,
      );
    }
  } else {
    _block$1 = new Vec3(
      model.position.x + desired_x,
      model.position.y,
      model.position.z + desired_z,
    );
  }
  let new_position = _block$1;
  return new Model(
    new_position,
    new_zoom,
    model.magic,
    model.health,
    model.player_geometry,
    model.player_material,
  );
}

/**
 * Internal tick function - handles movement only
 * 
 * @ignore
 */
function tick(model, ctx) {
  return update_movement(model, ctx);
}

/**
 * Update player. Uses callbacks for cross-module communication.
 */
export function update(model, msg, ctx, effect_mapper) {
  if (msg instanceof Tick) {
    let new_model = tick(model, ctx);
    let update_magic_effect = $effect.dispatch(
      effect_mapper(
        new MagicMsg(
          new $magic.UpdatePlayerState(new_model.position, new_model.zoom),
        ),
      ),
    );
    let wand_switch_effect = get_wand_switch_effect(ctx, effect_mapper);
    return [
      new_model,
      $effect.batch(
        toList([
          $effect.dispatch(effect_mapper(new Tick())),
          update_magic_effect,
          wand_switch_effect,
        ]),
      ),
    ];
  } else if (msg instanceof MagicMsg) {
    let magic_msg = msg[0];
    let $ = $magic.update(model.magic, magic_msg, ctx);
    let new_magic;
    let magic_effect;
    new_magic = $[0];
    magic_effect = $[1];
    let new_model = new Model(
      model.position,
      model.zoom,
      new_magic,
      model.health,
      model.player_geometry,
      model.player_material,
    );
    return [
      new_model,
      $effect.batch(
        toList([
          $effect.map(
            magic_effect,
            (m) => { return effect_mapper(new MagicMsg(m)); },
          ),
        ]),
      ),
    ];
  } else {
    let amount = msg[0];
    let new_health = $health.damage(model.health, amount);
    let new_model = new Model(
      model.position,
      model.zoom,
      model.magic,
      new_health,
      model.player_geometry,
      model.player_material,
    );
    return [new_model, $effect.none()];
  }
}
