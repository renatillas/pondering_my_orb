import * as $array from "../../gleam_javascript/gleam/javascript/array.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $set from "../../gleam_stdlib/gleam/set.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $vec2 from "../../vec/vec/vec2.mjs";
import { Vec2 } from "../../vec/vec/vec2.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
} from "../gleam.mjs";
import * as $tiramisu from "../tiramisu.mjs";
import * as $effect from "../tiramisu/effect.mjs";
import * as $input from "../tiramisu/input.mjs";
import * as $physics from "../tiramisu/physics.mjs";
import * as $scene from "../tiramisu/scene.mjs";
import * as $transform from "../tiramisu/transform.mjs";
import { pushToMutableList as push_to_mutable_list } from "./simulate.ffi.mjs";

class Simulation extends $CustomType {
  constructor(model, update, view, physics_world, input_state, canvas_size, renderer_state, recorded_effects, pending_messages, frame_count, total_time) {
    super();
    this.model = model;
    this.update = update;
    this.view = view;
    this.physics_world = physics_world;
    this.input_state = input_state;
    this.canvas_size = canvas_size;
    this.renderer_state = renderer_state;
    this.recorded_effects = recorded_effects;
    this.pending_messages = pending_messages;
    this.frame_count = frame_count;
    this.total_time = total_time;
  }
}

/**
 * A message was dispatched via effect.dispatch
 */
export class RecordedDispatch extends $CustomType {
  constructor(msg) {
    super();
    this.msg = msg;
  }
}
export const RecordedEffect$RecordedDispatch = (msg) =>
  new RecordedDispatch(msg);
export const RecordedEffect$isRecordedDispatch = (value) =>
  value instanceof RecordedDispatch;
export const RecordedEffect$RecordedDispatch$msg = (value) => value.msg;
export const RecordedEffect$RecordedDispatch$0 = (value) => value.msg;

/**
 * A delayed message via effect.delay
 */
export class RecordedDelay extends $CustomType {
  constructor(delay, msg) {
    super();
    this.delay = delay;
    this.msg = msg;
  }
}
export const RecordedEffect$RecordedDelay = (delay, msg) =>
  new RecordedDelay(delay, msg);
export const RecordedEffect$isRecordedDelay = (value) =>
  value instanceof RecordedDelay;
export const RecordedEffect$RecordedDelay$delay = (value) => value.delay;
export const RecordedEffect$RecordedDelay$0 = (value) => value.delay;
export const RecordedEffect$RecordedDelay$msg = (value) => value.msg;
export const RecordedEffect$RecordedDelay$1 = (value) => value.msg;

/**
 * An interval was created via effect.interval
 */
export class RecordedInterval extends $CustomType {
  constructor(interval, msg) {
    super();
    this.interval = interval;
    this.msg = msg;
  }
}
export const RecordedEffect$RecordedInterval = (interval, msg) =>
  new RecordedInterval(interval, msg);
export const RecordedEffect$isRecordedInterval = (value) =>
  value instanceof RecordedInterval;
export const RecordedEffect$RecordedInterval$interval = (value) =>
  value.interval;
export const RecordedEffect$RecordedInterval$0 = (value) => value.interval;
export const RecordedEffect$RecordedInterval$msg = (value) => value.msg;
export const RecordedEffect$RecordedInterval$1 = (value) => value.msg;

/**
 * Queue a message to be processed on the next frame
 *
 * ## Example
 *
 * ```gleam
 * let sim = simulate.dispatch(sim, Jump)
 * let sim = simulate.frame(sim, delta: duration.milliseconds(16))
 * ```
 */
export function dispatch(sim, msg) {
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    sim.input_state,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    $list.append(sim.pending_messages, toList([msg])),
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Get the current model
 */
export function model(sim) {
  return sim.model;
}

/**
 * Get the current scene node (result of calling view)
 */
export function view(sim) {
  let context = new $tiramisu.Context(
    $duration.nanoseconds(0),
    sim.input_state,
    sim.canvas_size,
    sim.physics_world,
    $scene.get_scene(sim.renderer_state),
    $scene.get_renderer(sim.renderer_state),
  );
  return sim.view(sim.model, context);
}

/**
 * Get all recorded effects
 */
export function effects(sim) {
  return $list.reverse(sim.recorded_effects);
}

/**
 * Get the physics world (if physics is enabled)
 */
export function physics_world(sim) {
  return sim.physics_world;
}

/**
 * Get current frame count
 */
export function frame_count(sim) {
  return sim.frame_count;
}

/**
 * Get total simulation time
 */
export function total_time(sim) {
  return sim.total_time;
}

/**
 * Get the current input state
 */
export function input_state(sim) {
  return sim.input_state;
}

/**
 * Set full input state (for complex scenarios)
 */
export function with_input(sim, input_state) {
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    input_state,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Step physics explicitly
 *
 * Physics is NOT stepped automatically by `frame()`. Use this helper
 * to step physics in your tests, or call `physics.step` in your game's
 * update function.
 */
export function step_physics(sim, delta) {
  let $ = sim.physics_world;
  if ($ instanceof $option.Some) {
    let world = $[0];
    let new_world = $physics.step(world, delta);
    return new Simulation(
      sim.model,
      sim.update,
      sim.view,
      new $option.Some(new_world),
      sim.input_state,
      sim.canvas_size,
      $scene.set_physics_world(sim.renderer_state, new $option.Some(new_world)),
      sim.recorded_effects,
      sim.pending_messages,
      sim.frame_count,
      sim.total_time,
    );
  } else {
    return sim;
  }
}

/**
 * Get transform of a physics body
 */
export function get_body_transform(sim, id) {
  let $ = sim.physics_world;
  if ($ instanceof $option.Some) {
    let world = $[0];
    return $physics.get_transform(world, id);
  } else {
    return new Error(undefined);
  }
}

/**
 * Get collision events from last physics step
 */
export function get_collision_events(sim) {
  let $ = sim.physics_world;
  if ($ instanceof $option.Some) {
    let world = $[0];
    return $physics.get_collision_events(world);
  } else {
    return toList([]);
  }
}

/**
 * Clear all recorded effects
 */
export function clear_effects(sim) {
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    sim.input_state,
    sim.canvas_size,
    sim.renderer_state,
    toList([]),
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Check if a specific effect was recorded
 *
 * ## Example
 *
 * ```gleam
 * let has_jump_sound = simulate.has_effect(sim, fn(e) {
 *   case e {
 *     simulate.RecordedDispatch(PlaySound("jump")) -> True
 *     _ -> False
 *   }
 * })
 * ```
 */
export function has_effect(sim, predicate) {
  return $list.any(sim.recorded_effects, predicate);
}

/**
 * Get all dispatched messages from effects
 */
export function dispatched_messages(sim) {
  return $list.filter_map(
    sim.recorded_effects,
    (e) => {
      if (e instanceof RecordedDispatch) {
        let msg = e.msg;
        return new Ok(msg);
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Clear per-frame input state
 * 
 * @ignore
 */
function clear_frame_input_state(input_state) {
  let keyboard = $input.build_keyboard_state(
    $input.get_pressed_keys(input_state),
    $set.new$(),
    $set.new$(),
  );
  let left = $input.get_left_button_state(input_state);
  let middle = $input.get_middle_button_state(input_state);
  let right = $input.get_right_button_state(input_state);
  let new_mouse = $input.build_mouse_state(
    $input.get_mouse_x(input_state),
    $input.get_mouse_y(input_state),
    0.0,
    0.0,
    0.0,
    left.pressed,
    false,
    false,
    middle.pressed,
    false,
    false,
    right.pressed,
    false,
    false,
  );
  let touch = $input.build_touch_state(
    $input.get_active_touches(input_state),
    toList([]),
    toList([]),
  );
  return $input.build_input_state(
    keyboard,
    new_mouse,
    $input.get_gamepad_list(input_state),
    touch,
  );
}

/**
 * Clear per-frame input state (just_pressed, just_released, deltas)
 *
 * This is automatically called by `frame()`, but you can call it manually
 * if needed.
 */
export function clear_input(sim) {
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    clear_frame_input_state(sim.input_state),
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Rebuild input state with new keyboard
 * 
 * @ignore
 */
function rebuild_input_with_keyboard(input_state, keyboard) {
  return $input.build_input_state(
    keyboard,
    $input.get_mouse_state(input_state),
    $input.get_gamepad_list(input_state),
    $input.get_touch_state(input_state),
  );
}

/**
 * Rebuild input state with new mouse
 * 
 * @ignore
 */
function rebuild_input_with_mouse(input_state, mouse) {
  return $input.build_input_state(
    $input.get_keyboard_state(input_state),
    mouse,
    $input.get_gamepad_list(input_state),
    $input.get_touch_state(input_state),
  );
}

/**
 * Set mouse position
 *
 * ## Example
 *
 * ```gleam
 * let sim = simulate.with_mouse_position(sim, 400.0, 300.0)
 * ```
 */
export function with_mouse_position(sim, x, y) {
  let left = $input.get_left_button_state(sim.input_state);
  let middle = $input.get_middle_button_state(sim.input_state);
  let right = $input.get_right_button_state(sim.input_state);
  let new_mouse = $input.build_mouse_state(
    x,
    y,
    $input.get_mouse_delta_x(sim.input_state),
    $input.get_mouse_delta_y(sim.input_state),
    $input.get_mouse_wheel_delta(sim.input_state),
    left.pressed,
    left.just_pressed,
    left.just_released,
    middle.pressed,
    middle.just_pressed,
    middle.just_released,
    right.pressed,
    right.just_pressed,
    right.just_released,
  );
  let new_input = rebuild_input_with_mouse(sim.input_state, new_mouse);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Set mouse delta (movement since last frame)
 */
export function with_mouse_delta(sim, dx, dy) {
  let left = $input.get_left_button_state(sim.input_state);
  let middle = $input.get_middle_button_state(sim.input_state);
  let right = $input.get_right_button_state(sim.input_state);
  let new_mouse = $input.build_mouse_state(
    $input.get_mouse_x(sim.input_state),
    $input.get_mouse_y(sim.input_state),
    dx,
    dy,
    $input.get_mouse_wheel_delta(sim.input_state),
    left.pressed,
    left.just_pressed,
    left.just_released,
    middle.pressed,
    middle.just_pressed,
    middle.just_released,
    right.pressed,
    right.just_pressed,
    right.just_released,
  );
  let new_input = rebuild_input_with_mouse(sim.input_state, new_mouse);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Set left mouse button as pressed
 */
export function with_left_button_pressed(sim) {
  let left = $input.get_left_button_state(sim.input_state);
  let middle = $input.get_middle_button_state(sim.input_state);
  let right = $input.get_right_button_state(sim.input_state);
  let new_mouse = $input.build_mouse_state(
    $input.get_mouse_x(sim.input_state),
    $input.get_mouse_y(sim.input_state),
    $input.get_mouse_delta_x(sim.input_state),
    $input.get_mouse_delta_y(sim.input_state),
    $input.get_mouse_wheel_delta(sim.input_state),
    true,
    left.just_pressed,
    left.just_released,
    middle.pressed,
    middle.just_pressed,
    middle.just_released,
    right.pressed,
    right.just_pressed,
    right.just_released,
  );
  let new_input = rebuild_input_with_mouse(sim.input_state, new_mouse);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Set left mouse button as just pressed (for this frame only)
 */
export function with_left_button_just_pressed(sim) {
  let middle = $input.get_middle_button_state(sim.input_state);
  let right = $input.get_right_button_state(sim.input_state);
  let new_mouse = $input.build_mouse_state(
    $input.get_mouse_x(sim.input_state),
    $input.get_mouse_y(sim.input_state),
    $input.get_mouse_delta_x(sim.input_state),
    $input.get_mouse_delta_y(sim.input_state),
    $input.get_mouse_wheel_delta(sim.input_state),
    true,
    true,
    false,
    middle.pressed,
    middle.just_pressed,
    middle.just_released,
    right.pressed,
    right.just_pressed,
    right.just_released,
  );
  let new_input = rebuild_input_with_mouse(sim.input_state, new_mouse);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Set right mouse button as pressed
 */
export function with_right_button_pressed(sim) {
  let left = $input.get_left_button_state(sim.input_state);
  let middle = $input.get_middle_button_state(sim.input_state);
  let right = $input.get_right_button_state(sim.input_state);
  let new_mouse = $input.build_mouse_state(
    $input.get_mouse_x(sim.input_state),
    $input.get_mouse_y(sim.input_state),
    $input.get_mouse_delta_x(sim.input_state),
    $input.get_mouse_delta_y(sim.input_state),
    $input.get_mouse_wheel_delta(sim.input_state),
    left.pressed,
    left.just_pressed,
    left.just_released,
    middle.pressed,
    middle.just_pressed,
    middle.just_released,
    true,
    right.just_pressed,
    right.just_released,
  );
  let new_input = rebuild_input_with_mouse(sim.input_state, new_mouse);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

function key_to_code(key) {
  if (key instanceof $input.KeyA) {
    return "KeyA";
  } else if (key instanceof $input.KeyB) {
    return "KeyB";
  } else if (key instanceof $input.KeyC) {
    return "KeyC";
  } else if (key instanceof $input.KeyD) {
    return "KeyD";
  } else if (key instanceof $input.KeyE) {
    return "KeyE";
  } else if (key instanceof $input.KeyF) {
    return "KeyF";
  } else if (key instanceof $input.KeyG) {
    return "KeyG";
  } else if (key instanceof $input.KeyH) {
    return "KeyH";
  } else if (key instanceof $input.KeyI) {
    return "KeyI";
  } else if (key instanceof $input.KeyJ) {
    return "KeyJ";
  } else if (key instanceof $input.KeyK) {
    return "KeyK";
  } else if (key instanceof $input.KeyL) {
    return "KeyL";
  } else if (key instanceof $input.KeyM) {
    return "KeyM";
  } else if (key instanceof $input.KeyN) {
    return "KeyN";
  } else if (key instanceof $input.KeyO) {
    return "KeyO";
  } else if (key instanceof $input.KeyP) {
    return "KeyP";
  } else if (key instanceof $input.KeyQ) {
    return "KeyQ";
  } else if (key instanceof $input.KeyR) {
    return "KeyR";
  } else if (key instanceof $input.KeyS) {
    return "KeyS";
  } else if (key instanceof $input.KeyT) {
    return "KeyT";
  } else if (key instanceof $input.KeyU) {
    return "KeyU";
  } else if (key instanceof $input.KeyV) {
    return "KeyV";
  } else if (key instanceof $input.KeyW) {
    return "KeyW";
  } else if (key instanceof $input.KeyX) {
    return "KeyX";
  } else if (key instanceof $input.KeyY) {
    return "KeyY";
  } else if (key instanceof $input.KeyZ) {
    return "KeyZ";
  } else if (key instanceof $input.Digit0) {
    return "Digit0";
  } else if (key instanceof $input.Digit1) {
    return "Digit1";
  } else if (key instanceof $input.Digit2) {
    return "Digit2";
  } else if (key instanceof $input.Digit3) {
    return "Digit3";
  } else if (key instanceof $input.Digit4) {
    return "Digit4";
  } else if (key instanceof $input.Digit5) {
    return "Digit5";
  } else if (key instanceof $input.Digit6) {
    return "Digit6";
  } else if (key instanceof $input.Digit7) {
    return "Digit7";
  } else if (key instanceof $input.Digit8) {
    return "Digit8";
  } else if (key instanceof $input.Digit9) {
    return "Digit9";
  } else if (key instanceof $input.F1) {
    return "F1";
  } else if (key instanceof $input.F2) {
    return "F2";
  } else if (key instanceof $input.F3) {
    return "F3";
  } else if (key instanceof $input.F4) {
    return "F4";
  } else if (key instanceof $input.F5) {
    return "F5";
  } else if (key instanceof $input.F6) {
    return "F6";
  } else if (key instanceof $input.F7) {
    return "F7";
  } else if (key instanceof $input.F8) {
    return "F8";
  } else if (key instanceof $input.F9) {
    return "F9";
  } else if (key instanceof $input.F10) {
    return "F10";
  } else if (key instanceof $input.F11) {
    return "F11";
  } else if (key instanceof $input.F12) {
    return "F12";
  } else if (key instanceof $input.ArrowUp) {
    return "ArrowUp";
  } else if (key instanceof $input.ArrowDown) {
    return "ArrowDown";
  } else if (key instanceof $input.ArrowLeft) {
    return "ArrowLeft";
  } else if (key instanceof $input.ArrowRight) {
    return "ArrowRight";
  } else if (key instanceof $input.ShiftLeft) {
    return "ShiftLeft";
  } else if (key instanceof $input.ShiftRight) {
    return "ShiftRight";
  } else if (key instanceof $input.ControlLeft) {
    return "ControlLeft";
  } else if (key instanceof $input.ControlRight) {
    return "ControlRight";
  } else if (key instanceof $input.AltLeft) {
    return "AltLeft";
  } else if (key instanceof $input.AltRight) {
    return "AltRight";
  } else if (key instanceof $input.MetaLeft) {
    return "MetaLeft";
  } else if (key instanceof $input.MetaRight) {
    return "MetaRight";
  } else if (key instanceof $input.Space) {
    return "Space";
  } else if (key instanceof $input.Enter) {
    return "Enter";
  } else if (key instanceof $input.Escape) {
    return "Escape";
  } else if (key instanceof $input.Tab) {
    return "Tab";
  } else if (key instanceof $input.Backspace) {
    return "Backspace";
  } else if (key instanceof $input.Delete) {
    return "Delete";
  } else if (key instanceof $input.Insert) {
    return "Insert";
  } else if (key instanceof $input.Home) {
    return "Home";
  } else if (key instanceof $input.End) {
    return "End";
  } else if (key instanceof $input.PageUp) {
    return "PageUp";
  } else if (key instanceof $input.PageDown) {
    return "PageDown";
  } else if (key instanceof $input.CapsLock) {
    return "CapsLock";
  } else if (key instanceof $input.Minus) {
    return "Minus";
  } else if (key instanceof $input.Equal) {
    return "Equal";
  } else if (key instanceof $input.BracketLeft) {
    return "BracketLeft";
  } else if (key instanceof $input.BracketRight) {
    return "BracketRight";
  } else if (key instanceof $input.Backslash) {
    return "Backslash";
  } else if (key instanceof $input.Semicolon) {
    return "Semicolon";
  } else if (key instanceof $input.Quote) {
    return "Quote";
  } else if (key instanceof $input.Comma) {
    return "Comma";
  } else if (key instanceof $input.Period) {
    return "Period";
  } else if (key instanceof $input.Slash) {
    return "Slash";
  } else if (key instanceof $input.Backquote) {
    return "Backquote";
  } else if (key instanceof $input.Numpad0) {
    return "Numpad0";
  } else if (key instanceof $input.Numpad1) {
    return "Numpad1";
  } else if (key instanceof $input.Numpad2) {
    return "Numpad2";
  } else if (key instanceof $input.Numpad3) {
    return "Numpad3";
  } else if (key instanceof $input.Numpad4) {
    return "Numpad4";
  } else if (key instanceof $input.Numpad5) {
    return "Numpad5";
  } else if (key instanceof $input.Numpad6) {
    return "Numpad6";
  } else if (key instanceof $input.Numpad7) {
    return "Numpad7";
  } else if (key instanceof $input.Numpad8) {
    return "Numpad8";
  } else if (key instanceof $input.Numpad9) {
    return "Numpad9";
  } else if (key instanceof $input.NumpadAdd) {
    return "NumpadAdd";
  } else if (key instanceof $input.NumpadSubtract) {
    return "NumpadSubtract";
  } else if (key instanceof $input.NumpadMultiply) {
    return "NumpadMultiply";
  } else if (key instanceof $input.NumpadDivide) {
    return "NumpadDivide";
  } else if (key instanceof $input.NumpadDecimal) {
    return "NumpadDecimal";
  } else if (key instanceof $input.NumpadEnter) {
    return "NumpadEnter";
  } else if (key instanceof $input.NumLock) {
    return "NumLock";
  } else if (key instanceof $input.AudioVolumeUp) {
    return "AudioVolumeUp";
  } else if (key instanceof $input.AudioVolumeDown) {
    return "AudioVolumeDown";
  } else if (key instanceof $input.AudioVolumeMute) {
    return "AudioVolumeMute";
  } else if (key instanceof $input.MediaPlayPause) {
    return "MediaPlayPause";
  } else if (key instanceof $input.MediaStop) {
    return "MediaStop";
  } else if (key instanceof $input.MediaTrackNext) {
    return "MediaTrackNext";
  } else if (key instanceof $input.MediaTrackPrevious) {
    return "MediaTrackPrevious";
  } else if (key instanceof $input.PrintScreen) {
    return "PrintScreen";
  } else if (key instanceof $input.ScrollLock) {
    return "ScrollLock";
  } else if (key instanceof $input.Pause) {
    return "Pause";
  } else if (key instanceof $input.ContextMenu) {
    return "ContextMenu";
  } else {
    let code = key[0];
    return code;
  }
}

/**
 * Set a key as pressed (held down)
 *
 * ## Example
 *
 * ```gleam
 * let sim = simulate.with_key_pressed(sim, input.KeyW)
 * ```
 */
export function with_key_pressed(sim, key) {
  let key_code = key_to_code(key);
  let new_keyboard = $input.build_keyboard_state(
    $set.insert($input.get_pressed_keys(sim.input_state), key_code),
    $input.get_just_pressed_keys(sim.input_state),
    $input.get_just_released_keys(sim.input_state),
  );
  let new_input = rebuild_input_with_keyboard(sim.input_state, new_keyboard);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Set a key as just pressed (for this frame only)
 *
 * This sets the key as both pressed AND just_pressed.
 *
 * ## Example
 *
 * ```gleam
 * let sim = simulate.with_key_just_pressed(sim, input.Space)
 * let sim = simulate.frame(sim, delta: duration.milliseconds(16))
 * // After frame(), just_pressed is cleared but pressed remains
 * ```
 */
export function with_key_just_pressed(sim, key) {
  let key_code = key_to_code(key);
  let new_keyboard = $input.build_keyboard_state(
    $set.insert($input.get_pressed_keys(sim.input_state), key_code),
    $set.insert($input.get_just_pressed_keys(sim.input_state), key_code),
    $input.get_just_released_keys(sim.input_state),
  );
  let new_input = rebuild_input_with_keyboard(sim.input_state, new_keyboard);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Release a key
 *
 * This removes the key from pressed and sets it as just_released.
 */
export function with_key_released(sim, key) {
  let key_code = key_to_code(key);
  let new_keyboard = $input.build_keyboard_state(
    $set.delete$($input.get_pressed_keys(sim.input_state), key_code),
    $input.get_just_pressed_keys(sim.input_state),
    $set.insert($input.get_just_released_keys(sim.input_state), key_code),
  );
  let new_input = rebuild_input_with_keyboard(sim.input_state, new_keyboard);
  return new Simulation(
    sim.model,
    sim.update,
    sim.view,
    sim.physics_world,
    new_input,
    sim.canvas_size,
    sim.renderer_state,
    sim.recorded_effects,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Capture messages dispatched by an effect
 * 
 * @ignore
 */
function capture_dispatched_messages(eff) {
  let captured = $array.from_list(toList([]));
  $effect.run(eff, (msg) => { return push_to_mutable_list(captured, msg); });
  return $array.to_list(captured);
}

/**
 * Record an effect (run it with a recording dispatch)
 * 
 * @ignore
 */
function record_effect(eff, acc) {
  let messages = capture_dispatched_messages(eff);
  return $list.fold(
    messages,
    acc,
    (acc, msg) => { return listPrepend(new RecordedDispatch(msg), acc); },
  );
}

/**
 * Start a simulation with a specific canvas size
 *
 * ## Example
 *
 * ```gleam
 * let sim = simulate.start(
 *   init: game.init,
 *   update: game.update,
 *   view: game.view,
 *   canvas_size: vec2.Vec2(1920.0, 1080.0),
 * )
 * ```
 */
export function start(init, update, view, canvas_size) {
  let width;
  let height;
  width = canvas_size.x;
  height = canvas_size.y;
  let renderer_state = $scene.new_headless_render_state(width, height);
  let initial_context = new $tiramisu.Context(
    $duration.nanoseconds(0),
    $input.new$(),
    canvas_size,
    new $option.None(),
    $scene.get_scene(renderer_state),
    $scene.get_renderer(renderer_state),
  );
  let $ = init(initial_context);
  let initial_model;
  let initial_effect;
  let physics_world$1;
  initial_model = $[0];
  initial_effect = $[1];
  physics_world$1 = $[2];
  let recorded = record_effect(initial_effect, toList([]));
  let _block;
  if (physics_world$1 instanceof $option.Some) {
    let world = physics_world$1[0];
    _block = $scene.set_physics_world(renderer_state, new $option.Some(world));
  } else {
    _block = renderer_state;
  }
  let renderer_state$1 = _block;
  return new Simulation(
    initial_model,
    update,
    view,
    physics_world$1,
    $input.new$(),
    canvas_size,
    renderer_state$1,
    recorded,
    toList([]),
    0,
    $duration.nanoseconds(0),
  );
}

/**
 * Dispatch a message and immediately process it (within the same frame)
 *
 * ## Example
 *
 * ```gleam
 * let sim = simulate.dispatch_now(sim, StartGame)
 * let model = simulate.model(sim)
 * ```
 */
export function dispatch_now(sim, msg) {
  let context = new $tiramisu.Context(
    $duration.nanoseconds(0),
    sim.input_state,
    sim.canvas_size,
    sim.physics_world,
    $scene.get_scene(sim.renderer_state),
    $scene.get_renderer(sim.renderer_state),
  );
  let $ = sim.update(sim.model, msg, context);
  let new_model;
  let new_effect;
  let new_physics_world;
  new_model = $[0];
  new_effect = $[1];
  new_physics_world = $[2];
  let new_recorded = record_effect(new_effect, sim.recorded_effects);
  let _block;
  if (new_physics_world instanceof $option.Some) {
    _block = new_physics_world;
  } else {
    _block = sim.physics_world;
  }
  let final_physics = _block;
  return new Simulation(
    new_model,
    sim.update,
    sim.view,
    final_physics,
    sim.input_state,
    sim.canvas_size,
    $scene.set_physics_world(sim.renderer_state, final_physics),
    new_recorded,
    sim.pending_messages,
    sim.frame_count,
    sim.total_time,
  );
}

/**
 * Process messages and record effects
 * 
 * @ignore
 */
function process_messages(
  loop$model,
  loop$messages,
  loop$context,
  loop$recorded,
  loop$update
) {
  while (true) {
    let model = loop$model;
    let messages = loop$messages;
    let context = loop$context;
    let recorded = loop$recorded;
    let update = loop$update;
    if (messages instanceof $Empty) {
      return [model, recorded, context.physics_world];
    } else {
      let msg = messages.head;
      let rest = messages.tail;
      let $ = update(model, msg, context);
      let new_model;
      let new_effect;
      let new_physics_world;
      new_model = $[0];
      new_effect = $[1];
      new_physics_world = $[2];
      let new_recorded = record_effect(new_effect, recorded);
      let _block;
      if (new_physics_world instanceof $option.Some) {
        let world = new_physics_world[0];
        _block = new $tiramisu.Context(
          context.delta_time,
          context.input,
          context.canvas_size,
          new $option.Some(world),
          context.scene,
          context.renderer,
        );
      } else {
        _block = context;
      }
      let new_context = _block;
      loop$model = new_model;
      loop$messages = rest;
      loop$context = new_context;
      loop$recorded = new_recorded;
      loop$update = update;
    }
  }
}

/**
 * Advance simulation by one frame with specified delta time
 *
 * This processes all pending messages and updates the frame counter.
 * Physics stepping is NOT done automatically - if your game uses physics,
 * call `physics.step` in your update function.
 *
 * ## Example
 *
 * ```gleam
 * let sim = simulate.frame(sim, delta: duration.milliseconds(16))
 * ```
 */
export function frame(sim, delta) {
  let context = new $tiramisu.Context(
    delta,
    sim.input_state,
    sim.canvas_size,
    sim.physics_world,
    $scene.get_scene(sim.renderer_state),
    $scene.get_renderer(sim.renderer_state),
  );
  let $ = process_messages(
    sim.model,
    sim.pending_messages,
    context,
    sim.recorded_effects,
    sim.update,
  );
  let new_model;
  let new_effects;
  let final_physics_world;
  new_model = $[0];
  new_effects = $[1];
  final_physics_world = $[2];
  let _block;
  if (final_physics_world instanceof $option.Some) {
    _block = final_physics_world;
  } else {
    _block = sim.physics_world;
  }
  let final_physics = _block;
  let new_input = clear_frame_input_state(sim.input_state);
  return new Simulation(
    new_model,
    sim.update,
    sim.view,
    final_physics,
    new_input,
    sim.canvas_size,
    $scene.set_physics_world(sim.renderer_state, final_physics),
    new_effects,
    toList([]),
    sim.frame_count + 1,
    $duration.add(sim.total_time, delta),
  );
}

/**
 * Advance simulation by N frames with fixed delta time
 *
 * ## Example
 *
 * ```gleam
 * // Advance 60 frames at 16ms each (roughly 1 second)
 * let sim = simulate.frames(sim, count: 60, delta: duration.milliseconds(16))
 * ```
 */
export function frames(loop$sim, loop$count, loop$delta) {
  while (true) {
    let sim = loop$sim;
    let count = loop$count;
    let delta = loop$delta;
    let $ = count <= 0;
    if ($) {
      return sim;
    } else {
      loop$sim = frame(sim, delta);
      loop$count = count - 1;
      loop$delta = delta;
    }
  }
}
