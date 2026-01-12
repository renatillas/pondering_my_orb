import * as $function from "../../../gleam_stdlib/gleam/function.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $effect from "../../../lustre/lustre/effect.mjs";
import { CustomType as $CustomType } from "../../gleam.mjs";
import * as $toast from "../../grille_pain/toast.mjs";
import * as $level from "../../grille_pain/toast/level.mjs";

export class Options extends $CustomType {
  constructor(timeout, level, sticky, msg) {
    super();
    this.timeout = timeout;
    this.level = level;
    this.sticky = sticky;
    this.msg = msg;
  }
}
export const Options$Options = (timeout, level, sticky, msg) =>
  new Options(timeout, level, sticky, msg);
export const Options$isOptions = (value) => value instanceof Options;
export const Options$Options$timeout = (value) => value.timeout;
export const Options$Options$0 = (value) => value.timeout;
export const Options$Options$level = (value) => value.level;
export const Options$Options$1 = (value) => value.level;
export const Options$Options$sticky = (value) => value.sticky;
export const Options$Options$2 = (value) => value.sticky;
export const Options$Options$msg = (value) => value.msg;
export const Options$Options$3 = (value) => value.msg;

/**
 * Default, empty options. Use it to start Builder.
 */
export function options() {
  return new Options(
    new $option.None(),
    new $option.None(),
    false,
    new $option.None(),
  );
}

/**
 * Timeout to override defaults. Accepts a timeout in milliseconds.
 */
export function timeout(options, timeout) {
  return new Options(
    new $option.Some(timeout),
    options.level,
    options.sticky,
    options.msg,
  );
}

/**
 * Activate stickiness for toast. A sticky toast will never go away while it's
 * not hidden manually.
 */
export function sticky(options) {
  return new Options(options.timeout, options.level, true, options.msg);
}

/**
 * Level of your toast.
 */
export function level(options, level) {
  return new Options(
    options.timeout,
    new $option.Some(level),
    options.sticky,
    options.msg,
  );
}

export function notify(options, msg) {
  return new Options(
    options.timeout,
    options.level,
    options.sticky,
    new $option.Some(msg),
  );
}

function maybe(value, map) {
  if (value instanceof $option.Some) {
    let value$1 = value[0];
    return (_capture) => { return map(_capture, value$1); };
  } else {
    return $function.identity;
  }
}

function dispatch(content, msg, toaster) {
  return $effect.from(
    (dispatch) => {
      let id = toaster(content);
      if (msg instanceof $option.Some) {
        let msg$1 = msg[0];
        return dispatch(msg$1(id));
      } else {
        return undefined;
      }
    },
  );
}

export function toast(content) {
  return dispatch(content, new $option.None(), $toast.toast);
}

function to_options(options) {
  let _pipe = $toast.options();
  let _block;
  let $ = options.sticky;
  if ($) {
    _block = $toast.sticky;
  } else {
    _block = $function.identity;
  }
  let _pipe$1 = _block(_pipe);
  let _pipe$2 = maybe(options.timeout, $toast.timeout)(_pipe$1);
  return maybe(options.level, $toast.level)(_pipe$2);
}

export function info(content) {
  return dispatch(content, new $option.None(), $toast.info);
}

export function success(content) {
  return dispatch(content, new $option.None(), $toast.success);
}

export function error(content) {
  return dispatch(content, new $option.None(), $toast.error);
}

export function warning(content) {
  return dispatch(content, new $option.None(), $toast.warning);
}

export function custom(options, content) {
  return $effect.from(
    (dispatch) => {
      let options_ = to_options(options);
      let id = $toast.custom(options_, content);
      let $ = options.msg;
      if ($ instanceof $option.Some) {
        let msg = $[0];
        return dispatch(msg(id));
      } else {
        return undefined;
      }
    },
  );
}

/**
 * Hide toast. Sticky toast can only be hidden using `hide`.
 */
export function hide(id) {
  return $effect.from((_) => { return $toast.hide(id); });
}
