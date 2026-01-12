import * as $global from "../../../plinth/plinth/javascript/global.mjs";

/**
 * Delay execution by a specified duration
 */
export function delay(milliseconds, callback) {
  $global.set_timeout(milliseconds, callback);
  return undefined;
}

/**
 * Create a recurring interval (returns interval ID)
 */
export function interval(milliseconds, callback) {
  return $global.set_interval(milliseconds, callback);
}

/**
 * Cancel a recurring interval by its ID
 */
export function cancel_interval(id) {
  return $global.clear_interval(id);
}

/**
 * Set a timeout and return its ID for cancellation
 */
export function set_timeout(milliseconds, callback) {
  return $global.set_timeout(milliseconds, callback);
}

/**
 * Cancel a timeout by its ID
 */
export function cancel_timeout(id) {
  return $global.clear_timeout(id);
}
