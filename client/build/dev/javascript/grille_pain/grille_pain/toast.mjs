import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import * as $lustre from "../../lustre/lustre.mjs";
import { CustomType as $CustomType } from "../gleam.mjs";
import * as $msg from "../grille_pain/internals/data/msg.mjs";
import * as $toast from "../grille_pain/internals/data/toast.mjs";
import * as $effect_manager from "../grille_pain/internals/effect_manager.mjs";
import * as $function from "../grille_pain/internals/function.mjs";
import * as $level from "../grille_pain/toast/level.mjs";

class Options extends $CustomType {
  constructor(timeout, level, sticky) {
    super();
    this.timeout = timeout;
    this.level = level;
    this.sticky = sticky;
  }
}

/**
 * Default, empty options. Use it to start Builder.
 */
export function options() {
  return new Options(new None(), new None(), false);
}

/**
 * Timeout to override defaults. Accepts a timeout in milliseconds.
 */
export function timeout(options, timeout) {
  return new Options(new Some(timeout), options.level, options.sticky);
}

/**
 * Activate stickiness for toasts. A sticky toast will never go away while it's
 * not hidden manually.
 */
export function sticky(options) {
  return new Options(options.timeout, options.level, true);
}

/**
 * Level of your toast.
 */
export function level(options, level) {
  return new Options(options.timeout, new Some(level), options.sticky);
}

/**
 * Hide toast. Sticky toast can only be hidden using `hide`.
 */
export function hide(id) {
  return $effect_manager.call(
    (runtime) => {
      let _pipe = new $msg.UserHidToast(id);
      let _pipe$1 = $lustre.dispatch(_pipe);
      return ((_capture) => { return $lustre.send(runtime, _capture); })(
        _pipe$1,
      );
    },
  );
}

export function toast(content) {
  let _pipe = options();
  let _pipe$1 = level(_pipe, new $level.Standard());
  return dispatch_toast(_pipe$1, content);
}

function dispatch_toast(options, message) {
  return $function.tap(
    $toast.uuid(),
    (uuid) => {
      return $effect_manager.call(
        (runtime) => {
          let timeout$1;
          let level$1;
          let sticky$1;
          timeout$1 = options.timeout;
          level$1 = options.level;
          sticky$1 = options.sticky;
          let level$2 = $option.unwrap(level$1, new $level.Standard());
          let _pipe = new $msg.UserAddedToast(
            uuid,
            message,
            level$2,
            timeout$1,
            sticky$1,
          );
          let _pipe$1 = $lustre.dispatch(_pipe);
          return ((_capture) => { return $lustre.send(runtime, _capture); })(
            _pipe$1,
          );
        },
      );
    },
  );
}

export function info(content) {
  let _pipe = options();
  let _pipe$1 = level(_pipe, new $level.Info());
  return dispatch_toast(_pipe$1, content);
}

export function success(content) {
  let _pipe = options();
  let _pipe$1 = level(_pipe, new $level.Success());
  return dispatch_toast(_pipe$1, content);
}

export function error(content) {
  let _pipe = options();
  let _pipe$1 = level(_pipe, new $level.Error());
  return dispatch_toast(_pipe$1, content);
}

export function warning(content) {
  let _pipe = options();
  let _pipe$1 = level(_pipe, new $level.Warning());
  return dispatch_toast(_pipe$1, content);
}

export function custom(options, content) {
  return dispatch_toast(options, content);
}
