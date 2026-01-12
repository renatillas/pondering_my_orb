import * as $bool from "../gleam_stdlib/gleam/bool.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $pair from "../gleam_stdlib/gleam/pair.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import * as $lustre from "../lustre/lustre.mjs";
import * as $effect from "../lustre/lustre/effect.mjs";
import { Ok, toList, Empty as $Empty } from "./gleam.mjs";
import * as $error from "./grille_pain/error.mjs";
import * as $model from "./grille_pain/internals/data/model.mjs";
import { Model } from "./grille_pain/internals/data/model.mjs";
import * as $msg from "./grille_pain/internals/data/msg.mjs";
import * as $toast from "./grille_pain/internals/data/toast.mjs";
import * as $effect_manager from "./grille_pain/internals/effect_manager.mjs";
import * as $global from "./grille_pain/internals/global.mjs";
import * as $schedule from "./grille_pain/internals/lustre/schedule.mjs";
import { schedule } from "./grille_pain/internals/lustre/schedule.mjs";
import * as $setup from "./grille_pain/internals/setup.mjs";
import * as $view from "./grille_pain/internals/view.mjs";
import * as $options from "./grille_pain/options.mjs";

function schedule_hide(sticky, timeout, id, iteration) {
  return $bool.lazy_guard(
    sticky,
    $effect.none,
    () => { return schedule(timeout, new $msg.ToastTimedOut(id, iteration)); },
  );
}

function show(model, id, timeout, sticky) {
  let time = $option.unwrap(timeout, model.timeout);
  let new_model = $model.show(model, id);
  let eff = schedule_hide(sticky, time, id, 0);
  return [new_model, eff];
}

function update_display(model) {
  let $ = model.next_frame;
  if ($ instanceof $option.Some) {
    return $effect.none();
  } else {
    return $effect.from(
      (dispatch) => {
        return dispatch(
          new $msg.LustreRequestedAnimationFrame(
            $global.request_animation_frame(
              () => { return dispatch(new $msg.BrowserUpdatedToasts()); },
            ),
          ),
        );
      },
    );
  }
}

function update_toasts(model) {
  let $ = model.next_frame;
  if ($ instanceof $option.Some) {
    return $effect.none();
  } else {
    return $effect.from(
      (dispatch) => {
        return dispatch(
          new $msg.LustreRequestedAnimationFrame(
            $global.request_animation_frame(
              () => { return dispatch(new $msg.LustreComputedToasts()); },
            ),
          ),
        );
      },
    );
  }
}

function update(model, msg) {
  if (msg instanceof $msg.BrowserUpdatedToasts) {
    let model$1 = new Model(
      model.toasts,
      model.id,
      model.timeout,
      model.root,
      new $option.None(),
      model.to_show,
    );
    let model$2 = $model.update_bottom_positions(model$1);
    return [model$2, update_toasts(model$2)];
  } else if (msg instanceof $msg.LustreComputedToasts) {
    let model$1 = new Model(
      model.toasts,
      model.id,
      model.timeout,
      model.root,
      new $option.None(),
      model.to_show,
    );
    let $ = model$1.to_show;
    if ($ instanceof $Empty) {
      return [model$1, $effect.none()];
    } else {
      let showable = $;
      let model$2 = new Model(
        model$1.toasts,
        model$1.id,
        model$1.timeout,
        model$1.root,
        model$1.next_frame,
        toList([]),
      );
      let _pipe = [model$2, update_display(model$2)];
      return ((_capture) => {
        return $list.fold(
          showable,
          _capture,
          (model, showable) => {
            let toast_id;
            let timeout;
            let sticky;
            toast_id = showable.toast_id;
            timeout = showable.timeout;
            sticky = showable.sticky;
            let model$1;
            let effs;
            model$1 = model[0];
            effs = model[1];
            let $1 = show(model$1, toast_id, timeout, sticky);
            let model$2;
            let eff;
            model$2 = $1[0];
            eff = $1[1];
            return [model$2, $effect.batch(toList([effs, eff]))];
          },
        );
      })(_pipe);
    }
  } else if (msg instanceof $msg.LustreRequestedAnimationFrame) {
    let frame = msg[0];
    let next_frame = new $option.Some(frame);
    let model$1 = new Model(
      model.toasts,
      model.id,
      model.timeout,
      model.root,
      next_frame,
      model.to_show,
    );
    return [model$1, $effect.none()];
  } else if (msg instanceof $msg.ToastHidDisplay) {
    let id = msg.id;
    let model$1 = $model.remove(model, id);
    let update$1 = update_display(model$1);
    return [model$1, update$1];
  } else if (msg instanceof $msg.ToastTimedOut) {
    let id = msg.id;
    let iteration = msg.iteration;
    let $ = $list.find(
      model.toasts,
      (_capture) => { return $toast.by_iteration(_capture, id, iteration); },
    );
    if ($ instanceof Ok) {
      let toast = $[0];
      let model$1 = $model.hide(model, toast.id);
      let to_remove = schedule(1000, new $msg.ToastHidDisplay(id));
      let update$1 = update_display(model$1);
      return [model$1, $effect.batch(toList([to_remove, update$1]))];
    } else {
      return [model, $effect.none()];
    }
  } else if (msg instanceof $msg.UserAddedToast) {
    let uuid = msg.uuid;
    let message = msg.message;
    let level = msg.level;
    let timeout = msg.timeout;
    let sticky = msg.sticky;
    let _pipe = $model.add(model, uuid, message, level, sticky, timeout);
    return $pair.new$(_pipe, update_display(model));
  } else if (msg instanceof $msg.UserEnteredToast) {
    let id = msg.id;
    let model$1 = $model.stop(model, id);
    return [model$1, $effect.none()];
  } else if (msg instanceof $msg.UserHidToast) {
    let uuid = msg.uuid;
    let $ = $list.find(
      model.toasts,
      (_capture) => { return $toast.by_uuid(_capture, uuid); },
    );
    if ($ instanceof Ok) {
      let toast = $[0];
      return [
        model,
        $effect.from(
          (dispatch) => {
            return dispatch(new $msg.ToastTimedOut(toast.id, toast.iteration));
          },
        ),
      ];
    } else {
      return [model, $effect.none()];
    }
  } else {
    let id = msg.id;
    let $ = $list.find(
      model.toasts,
      (_capture) => { return $toast.by_id(_capture, id); },
    );
    if ($ instanceof Ok) {
      let sticky = $[0].sticky;
      let remaining = $[0].remaining;
      let iteration = $[0].iteration;
      let new_model = $model.resume(model, id);
      return [new_model, schedule_hide(sticky, remaining, id, iteration)];
    } else {
      return [model, $effect.none()];
    }
  }
}

/**
 * Setup a new `grille_pain` instance. You should not instanciate two instances
 * on the page, as `grille_pain` expect to run as a singleton.
 * Use `grille_pain/options` to provide and customise options.
 */
export function setup(opts) {
  return $result.try$(
    $setup.mount(),
    (_use0) => {
      let lustre_root;
      let shadow;
      lustre_root = _use0[0];
      shadow = _use0[1];
      return $result.map(
        (() => {
          let _pipe = (_) => {
            return [$model.new$(shadow, opts.timeout), $effect.none()];
          };
          let _pipe$1 = $lustre.application(_pipe, update, $view.view);
          let _pipe$2 = $lustre.start(_pipe$1, lustre_root, undefined);
          return $error.lustre(_pipe$2);
        })(),
        (dispatcher) => { return $effect_manager.register(dispatcher); },
      );
    },
  );
}

/**
 * Setup a new `grille_pain` instance. You should not instanciate two instances
 * on the page, as `grille_pain` expect to run as a singleton.
 * Setup with default settings, meaning 5s of timeout.
 */
export function simple() {
  let _pipe = $options.default$();
  return setup(_pipe);
}
