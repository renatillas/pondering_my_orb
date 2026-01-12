import * as $array from "../../../gleam_javascript/gleam/javascript/array.mjs";
import * as $promise from "../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $float from "../../../gleam_stdlib/gleam/float.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $duration from "../../../gleam_time/gleam/time/duration.mjs";
import * as $clipboard from "../../../plinth/plinth/browser/clipboard.mjs";
import * as $element from "../../../plinth/plinth/browser/element.mjs";
import { toList } from "../../gleam.mjs";
import {
  requestPointerLock as request_pointer_lock_ffi,
  exitPointerLock as exit_pointer_lock_ffi,
  isPointerLocked as is_pointer_locked_ffi,
  vibrate as do_vibrate,
  gamepadVibrate as do_gamepad_vibrate,
} from "./browser.ffi.mjs";

/**
 * Write text to clipboard
 */
export function clipboard_write(text) {
  return $clipboard.write_text(text);
}

/**
 * Read text from clipboard
 */
export function clipboard_read() {
  return $clipboard.read_text();
}

/**
 * Request pointer lock for an element
 * Hides the cursor and provides unlimited mouse movement
 */
export function request_pointer_lock(elem) {
  return request_pointer_lock_ffi(elem);
}

/**
 * Exit pointer lock mode
 */
export function exit_pointer_lock() {
  return exit_pointer_lock_ffi();
}

/**
 * Check if pointer is currently locked
 */
export function is_pointer_locked() {
  return is_pointer_locked_ffi();
}

/**
 * Stop any ongoing vibration
 */
export function cancel_vibrate() {
  return do_vibrate($array.from_list(toList([])));
}

/**
 * Trigger haptic feedback on mobile devices
 * Pattern is a list of vibration durations in milliseconds
 * Example: [duration.milliseconds(200), duration.milliseconds(100), duration.milliseconds(200)] vibrates 200ms, pauses 100ms, vibrates 200ms
 */
export function mobile_vibrate(pattern) {
  let _pipe = pattern;
  let _pipe$1 = $list.map(
    _pipe,
    (duration) => {
      let _pipe$1 = duration;
      let _pipe$2 = $duration.to_seconds(_pipe$1);
      let _pipe$3 = $float.multiply(_pipe$2, 1000.0);
      return $float.round(_pipe$3);
    },
  );
  let _pipe$2 = $array.from_list(_pipe$1);
  return do_vibrate(_pipe$2);
}

/**
 * Trigger haptic feedback on a gamepad
 * - gamepad: Gamepad index (0-3)
 * - intensity: Vibration intensity (0.0 to 1.0)
 * - duration: Duration of the vibration
 */
export function gamepad_vibrate(gamepad, intensity, duration) {
  let _pipe = duration;
  let _pipe$1 = $duration.to_seconds(_pipe);
  let _pipe$2 = $float.multiply(_pipe$1, 1000.0);
  return ((_capture) => {
    return do_gamepad_vibrate(gamepad, intensity, _capture);
  })(_pipe$2);
}
