import * as $dict from "../../../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $set from "../../../gleam_stdlib/gleam/set.mjs";
import * as $vec2 from "../../../vec/vec/vec2.mjs";
import { Ok, toList, CustomType as $CustomType } from "../../gleam.mjs";
import * as $input from "../../tiramisu/input.mjs";
import {
  captureGamepadStates as capture_gamepad_states_ffi,
  checkGamepadsConnected as check_gamepads_connected_ffi,
} from "./input_manager.ffi.mjs";

class InputManager extends $CustomType {
  constructor(keyboard_pressed, keyboard_just_pressed, keyboard_just_released, mouse_x, mouse_y, mouse_last_x, mouse_last_y, mouse_delta_x, mouse_delta_y, mouse_wheel_delta, mouse_left_pressed, mouse_left_just_pressed, mouse_left_just_released, mouse_middle_pressed, mouse_middle_just_pressed, mouse_middle_just_released, mouse_right_pressed, mouse_right_just_pressed, mouse_right_just_released, touch_active, touch_just_started, touch_just_ended, gamepad_connected) {
    super();
    this.keyboard_pressed = keyboard_pressed;
    this.keyboard_just_pressed = keyboard_just_pressed;
    this.keyboard_just_released = keyboard_just_released;
    this.mouse_x = mouse_x;
    this.mouse_y = mouse_y;
    this.mouse_last_x = mouse_last_x;
    this.mouse_last_y = mouse_last_y;
    this.mouse_delta_x = mouse_delta_x;
    this.mouse_delta_y = mouse_delta_y;
    this.mouse_wheel_delta = mouse_wheel_delta;
    this.mouse_left_pressed = mouse_left_pressed;
    this.mouse_left_just_pressed = mouse_left_just_pressed;
    this.mouse_left_just_released = mouse_left_just_released;
    this.mouse_middle_pressed = mouse_middle_pressed;
    this.mouse_middle_just_pressed = mouse_middle_just_pressed;
    this.mouse_middle_just_released = mouse_middle_just_released;
    this.mouse_right_pressed = mouse_right_pressed;
    this.mouse_right_just_pressed = mouse_right_just_pressed;
    this.mouse_right_just_released = mouse_right_just_released;
    this.touch_active = touch_active;
    this.touch_just_started = touch_just_started;
    this.touch_just_ended = touch_just_ended;
    this.gamepad_connected = gamepad_connected;
  }
}

/**
 * Create a new input manager
 */
export function new$() {
  return new InputManager(
    $set.new$(),
    $set.new$(),
    $set.new$(),
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    $dict.new$(),
    $dict.new$(),
    $dict.new$(),
    false,
  );
}

/**
 * Clear per-frame input state
 * Should be called at the end of each frame
 */
export function clear_frame_state(manager) {
  return new InputManager(
    manager.keyboard_pressed,
    $set.new$(),
    $set.new$(),
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_x,
    manager.mouse_y,
    0.0,
    0.0,
    0.0,
    manager.mouse_left_pressed,
    false,
    false,
    manager.mouse_middle_pressed,
    false,
    false,
    manager.mouse_right_pressed,
    false,
    false,
    manager.touch_active,
    $dict.new$(),
    $dict.new$(),
    manager.gamepad_connected,
  );
}

/**
 * Handle keydown event
 */
export function on_keydown(manager, key_code) {
  let was_pressed = $set.contains(manager.keyboard_pressed, key_code);
  if (was_pressed) {
    return manager;
  } else {
    return new InputManager(
      $set.insert(manager.keyboard_pressed, key_code),
      $set.insert(manager.keyboard_just_pressed, key_code),
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      manager.mouse_left_pressed,
      manager.mouse_left_just_pressed,
      manager.mouse_left_just_released,
      manager.mouse_middle_pressed,
      manager.mouse_middle_just_pressed,
      manager.mouse_middle_just_released,
      manager.mouse_right_pressed,
      manager.mouse_right_just_pressed,
      manager.mouse_right_just_released,
      manager.touch_active,
      manager.touch_just_started,
      manager.touch_just_ended,
      manager.gamepad_connected,
    );
  }
}

/**
 * Handle keyup event
 */
export function on_keyup(manager, key_code) {
  return new InputManager(
    $set.delete$(manager.keyboard_pressed, key_code),
    manager.keyboard_just_pressed,
    $set.insert(manager.keyboard_just_released, key_code),
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    manager.touch_active,
    manager.touch_just_started,
    manager.touch_just_ended,
    manager.gamepad_connected,
  );
}

/**
 * Handle mousemove event
 */
export function on_mousemove(manager, x, y, delta_x, delta_y) {
  return new InputManager(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
    x,
    y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    delta_x,
    delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    manager.touch_active,
    manager.touch_just_started,
    manager.touch_just_ended,
    manager.gamepad_connected,
  );
}

/**
 * Handle mousedown event
 */
export function on_mousedown(manager, button) {
  if (button === 0) {
    return new InputManager(
      manager.keyboard_pressed,
      manager.keyboard_just_pressed,
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      true,
      (() => {
        let $ = manager.mouse_left_pressed;
        if ($) {
          return false;
        } else {
          return true;
        }
      })(),
      manager.mouse_left_just_released,
      manager.mouse_middle_pressed,
      manager.mouse_middle_just_pressed,
      manager.mouse_middle_just_released,
      manager.mouse_right_pressed,
      manager.mouse_right_just_pressed,
      manager.mouse_right_just_released,
      manager.touch_active,
      manager.touch_just_started,
      manager.touch_just_ended,
      manager.gamepad_connected,
    );
  } else if (button === 1) {
    return new InputManager(
      manager.keyboard_pressed,
      manager.keyboard_just_pressed,
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      manager.mouse_left_pressed,
      manager.mouse_left_just_pressed,
      manager.mouse_left_just_released,
      true,
      (() => {
        let $ = manager.mouse_middle_pressed;
        if ($) {
          return false;
        } else {
          return true;
        }
      })(),
      manager.mouse_middle_just_released,
      manager.mouse_right_pressed,
      manager.mouse_right_just_pressed,
      manager.mouse_right_just_released,
      manager.touch_active,
      manager.touch_just_started,
      manager.touch_just_ended,
      manager.gamepad_connected,
    );
  } else if (button === 2) {
    return new InputManager(
      manager.keyboard_pressed,
      manager.keyboard_just_pressed,
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      manager.mouse_left_pressed,
      manager.mouse_left_just_pressed,
      manager.mouse_left_just_released,
      manager.mouse_middle_pressed,
      manager.mouse_middle_just_pressed,
      manager.mouse_middle_just_released,
      true,
      (() => {
        let $ = manager.mouse_right_pressed;
        if ($) {
          return false;
        } else {
          return true;
        }
      })(),
      manager.mouse_right_just_released,
      manager.touch_active,
      manager.touch_just_started,
      manager.touch_just_ended,
      manager.gamepad_connected,
    );
  } else {
    return manager;
  }
}

/**
 * Handle mouseup event
 */
export function on_mouseup(manager, button) {
  if (button === 0) {
    return new InputManager(
      manager.keyboard_pressed,
      manager.keyboard_just_pressed,
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      false,
      manager.mouse_left_just_pressed,
      true,
      manager.mouse_middle_pressed,
      manager.mouse_middle_just_pressed,
      manager.mouse_middle_just_released,
      manager.mouse_right_pressed,
      manager.mouse_right_just_pressed,
      manager.mouse_right_just_released,
      manager.touch_active,
      manager.touch_just_started,
      manager.touch_just_ended,
      manager.gamepad_connected,
    );
  } else if (button === 1) {
    return new InputManager(
      manager.keyboard_pressed,
      manager.keyboard_just_pressed,
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      manager.mouse_left_pressed,
      manager.mouse_left_just_pressed,
      manager.mouse_left_just_released,
      false,
      manager.mouse_middle_just_pressed,
      true,
      manager.mouse_right_pressed,
      manager.mouse_right_just_pressed,
      manager.mouse_right_just_released,
      manager.touch_active,
      manager.touch_just_started,
      manager.touch_just_ended,
      manager.gamepad_connected,
    );
  } else if (button === 2) {
    return new InputManager(
      manager.keyboard_pressed,
      manager.keyboard_just_pressed,
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      manager.mouse_left_pressed,
      manager.mouse_left_just_pressed,
      manager.mouse_left_just_released,
      manager.mouse_middle_pressed,
      manager.mouse_middle_just_pressed,
      manager.mouse_middle_just_released,
      false,
      manager.mouse_right_just_pressed,
      true,
      manager.touch_active,
      manager.touch_just_started,
      manager.touch_just_ended,
      manager.gamepad_connected,
    );
  } else {
    return manager;
  }
}

/**
 * Handle wheel event
 */
export function on_wheel(manager, delta_y) {
  return new InputManager(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    delta_y,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    manager.touch_active,
    manager.touch_just_started,
    manager.touch_just_ended,
    manager.gamepad_connected,
  );
}

/**
 * Handle touchstart event
 */
export function on_touchstart(manager, touch_id, x, y) {
  return new InputManager(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    $dict.insert(manager.touch_active, touch_id, [x, y]),
    $dict.insert(manager.touch_just_started, touch_id, [x, y]),
    manager.touch_just_ended,
    manager.gamepad_connected,
  );
}

/**
 * Handle touchmove event
 */
export function on_touchmove(manager, touch_id, x, y) {
  return new InputManager(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    $dict.insert(manager.touch_active, touch_id, [x, y]),
    manager.touch_just_started,
    manager.touch_just_ended,
    manager.gamepad_connected,
  );
}

/**
 * Handle touchend event
 */
export function on_touchend(manager, touch_id) {
  let $ = $dict.get(manager.touch_active, touch_id);
  if ($ instanceof Ok) {
    let pos = $[0];
    return new InputManager(
      manager.keyboard_pressed,
      manager.keyboard_just_pressed,
      manager.keyboard_just_released,
      manager.mouse_x,
      manager.mouse_y,
      manager.mouse_last_x,
      manager.mouse_last_y,
      manager.mouse_delta_x,
      manager.mouse_delta_y,
      manager.mouse_wheel_delta,
      manager.mouse_left_pressed,
      manager.mouse_left_just_pressed,
      manager.mouse_left_just_released,
      manager.mouse_middle_pressed,
      manager.mouse_middle_just_pressed,
      manager.mouse_middle_just_released,
      manager.mouse_right_pressed,
      manager.mouse_right_just_pressed,
      manager.mouse_right_just_released,
      $dict.delete$(manager.touch_active, touch_id),
      manager.touch_just_started,
      $dict.insert(manager.touch_just_ended, touch_id, pos),
      manager.gamepad_connected,
    );
  } else {
    return manager;
  }
}

/**
 * Handle touchcancel event
 */
export function on_touchcancel(manager, touch_id) {
  return new InputManager(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    $dict.delete$(manager.touch_active, touch_id),
    manager.touch_just_started,
    $dict.delete$(manager.touch_just_ended, touch_id),
    manager.gamepad_connected,
  );
}

/**
 * Handle gamepad connected event
 */
export function on_gamepad_connected(manager) {
  return new InputManager(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    manager.touch_active,
    manager.touch_just_started,
    manager.touch_just_ended,
    true,
  );
}

/**
 * Capture current input state as immutable snapshot
 */
export function capture_state(manager) {
  let keyboard_state = $input.build_keyboard_state(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
  );
  let mouse_state = $input.build_mouse_state(
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
  );
  let _block;
  let _pipe = $dict.to_list(manager.touch_active);
  _block = $list.map(
    _pipe,
    (entry) => {
      let id;
      let x;
      let y;
      id = entry[0];
      x = entry[1][0];
      y = entry[1][1];
      return $input.build_touch(id, new $vec2.Vec2(x, y));
    },
  );
  let active_touches = _block;
  let _block$1;
  let _pipe$1 = $dict.to_list(manager.touch_just_started);
  _block$1 = $list.map(
    _pipe$1,
    (entry) => {
      let id;
      let x;
      let y;
      id = entry[0];
      x = entry[1][0];
      y = entry[1][1];
      return $input.build_touch(id, new $vec2.Vec2(x, y));
    },
  );
  let just_started_touches = _block$1;
  let _block$2;
  let _pipe$2 = $dict.to_list(manager.touch_just_ended);
  _block$2 = $list.map(
    _pipe$2,
    (entry) => {
      let id;
      let x;
      let y;
      id = entry[0];
      x = entry[1][0];
      y = entry[1][1];
      return $input.build_touch(id, new $vec2.Vec2(x, y));
    },
  );
  let just_ended_touches = _block$2;
  let touch_state = $input.build_touch_state(
    active_touches,
    just_started_touches,
    just_ended_touches,
  );
  let _block$3;
  let $ = manager.gamepad_connected;
  if ($) {
    _block$3 = capture_gamepad_states_ffi();
  } else {
    _block$3 = toList([
      $input.build_gamepad_state(false, toList([]), toList([])),
      $input.build_gamepad_state(false, toList([]), toList([])),
      $input.build_gamepad_state(false, toList([]), toList([])),
      $input.build_gamepad_state(false, toList([]), toList([])),
    ]);
  }
  let gamepad_states = _block$3;
  return $input.build_input_state(
    keyboard_state,
    mouse_state,
    gamepad_states,
    touch_state,
  );
}

/**
 * Handle gamepad disconnected event
 */
export function on_gamepad_disconnected(manager) {
  let still_connected = check_gamepads_connected_ffi();
  return new InputManager(
    manager.keyboard_pressed,
    manager.keyboard_just_pressed,
    manager.keyboard_just_released,
    manager.mouse_x,
    manager.mouse_y,
    manager.mouse_last_x,
    manager.mouse_last_y,
    manager.mouse_delta_x,
    manager.mouse_delta_y,
    manager.mouse_wheel_delta,
    manager.mouse_left_pressed,
    manager.mouse_left_just_pressed,
    manager.mouse_left_just_released,
    manager.mouse_middle_pressed,
    manager.mouse_middle_just_pressed,
    manager.mouse_middle_just_released,
    manager.mouse_right_pressed,
    manager.mouse_right_just_pressed,
    manager.mouse_right_just_released,
    manager.touch_active,
    manager.touch_just_started,
    manager.touch_just_ended,
    still_connected,
  );
}
