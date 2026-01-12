import * as $list from "../../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../../gleam_stdlib/gleam/option.mjs";
import { toList, prepend as listPrepend, CustomType as $CustomType } from "../../../gleam.mjs";
import * as $toast from "../../../grille_pain/internals/data/toast.mjs";
import { Toast } from "../../../grille_pain/internals/data/toast.mjs";
import * as $global from "../../../grille_pain/internals/global.mjs";
import * as $shadow from "../../../grille_pain/internals/shadow.mjs";
import * as $level from "../../../grille_pain/toast/level.mjs";

export class Model extends $CustomType {
  constructor(toasts, id, timeout, root, next_frame, to_show) {
    super();
    this.toasts = toasts;
    this.id = id;
    this.timeout = timeout;
    this.root = root;
    this.next_frame = next_frame;
    this.to_show = to_show;
  }
}
export const Model$Model = (toasts, id, timeout, root, next_frame, to_show) =>
  new Model(toasts, id, timeout, root, next_frame, to_show);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$toasts = (value) => value.toasts;
export const Model$Model$0 = (value) => value.toasts;
export const Model$Model$id = (value) => value.id;
export const Model$Model$1 = (value) => value.id;
export const Model$Model$timeout = (value) => value.timeout;
export const Model$Model$2 = (value) => value.timeout;
export const Model$Model$root = (value) => value.root;
export const Model$Model$3 = (value) => value.root;
export const Model$Model$next_frame = (value) => value.next_frame;
export const Model$Model$4 = (value) => value.next_frame;
export const Model$Model$to_show = (value) => value.to_show;
export const Model$Model$5 = (value) => value.to_show;

export class ToShow extends $CustomType {
  constructor(toast_id, timeout, sticky) {
    super();
    this.toast_id = toast_id;
    this.timeout = timeout;
    this.sticky = sticky;
  }
}
export const ToShow$ToShow = (toast_id, timeout, sticky) =>
  new ToShow(toast_id, timeout, sticky);
export const ToShow$isToShow = (value) => value instanceof ToShow;
export const ToShow$ToShow$toast_id = (value) => value.toast_id;
export const ToShow$ToShow$0 = (value) => value.toast_id;
export const ToShow$ToShow$timeout = (value) => value.timeout;
export const ToShow$ToShow$1 = (value) => value.timeout;
export const ToShow$ToShow$sticky = (value) => value.sticky;
export const ToShow$ToShow$2 = (value) => value.sticky;

export function new$(root, timeout) {
  let toasts = toList([]);
  let id = 0;
  return new Model(toasts, id, timeout, root, new $option.None(), toList([]));
}

export function add(model, external_id, message, level, sticky, timeout) {
  let animation_duration = $option.unwrap(timeout, model.timeout);
  let new_toast = $toast.new$(
    external_id,
    model.id,
    message,
    level,
    animation_duration,
    sticky,
    model.root,
  );
  let new_toasts = listPrepend(new_toast, model.toasts);
  let new_id = model.id + 1;
  let to_show = listPrepend(
    new ToShow(new_toast.id, timeout, sticky),
    model.to_show,
  );
  return new Model(
    new_toasts,
    new_id,
    model.timeout,
    model.root,
    model.next_frame,
    to_show,
  );
}

function update_toast(model, id, updater) {
  let toasts = $list.map(
    model.toasts,
    (toast) => {
      let $ = id === toast.id;
      if ($) {
        return updater(toast);
      } else {
        return toast;
      }
    },
  );
  return new Model(
    toasts,
    model.id,
    model.timeout,
    model.root,
    model.next_frame,
    model.to_show,
  );
}

export function show(model, id) {
  return update_toast(
    model,
    id,
    (toast) => {
      let now = $global.now();
      return new Toast(
        toast.external_id,
        toast.id,
        toast.sticky,
        toast.message,
        new $toast.Show(),
        true,
        toast.remaining,
        now,
        toast.iteration,
        toast.bottom,
        toast.level,
        toast.animation_duration,
      );
    },
  );
}

export function hide(model, id) {
  return update_toast(
    model,
    id,
    (toast) => {
      return new Toast(
        toast.external_id,
        toast.id,
        toast.sticky,
        toast.message,
        new $toast.WillHide(),
        toast.running,
        toast.remaining,
        toast.last_schedule,
        toast.iteration,
        toast.bottom,
        toast.level,
        toast.animation_duration,
      );
    },
  );
}

export function stop(model, id) {
  return update_toast(
    model,
    id,
    (toast) => {
      let now = $global.now();
      let duration = now - toast.last_schedule;
      let remaining = toast.remaining - duration;
      let iteration = toast.iteration + 1;
      return new Toast(
        toast.external_id,
        toast.id,
        toast.sticky,
        toast.message,
        toast.displayed,
        false,
        remaining,
        toast.last_schedule,
        iteration,
        toast.bottom,
        toast.level,
        toast.animation_duration,
      );
    },
  );
}

export function resume(model, id) {
  return update_toast(
    model,
    id,
    (toast) => {
      let now = $global.now();
      return new Toast(
        toast.external_id,
        toast.id,
        toast.sticky,
        toast.message,
        toast.displayed,
        true,
        toast.remaining,
        now,
        toast.iteration,
        toast.bottom,
        toast.level,
        toast.animation_duration,
      );
    },
  );
}

export function remove(model, id) {
  let new_toasts = $list.filter(
    model.toasts,
    (toast) => { return toast.id !== id; },
  );
  return new Model(
    new_toasts,
    model.id,
    model.timeout,
    model.root,
    model.next_frame,
    model.to_show,
  );
}

export function update_bottom_positions(model) {
  return new Model(
    $list.map(
      model.toasts,
      (toast) => {
        let $ = toast.displayed;
        if ($ instanceof $toast.WillShow) {
          return new $toast.Toast(
            toast.external_id,
            toast.id,
            toast.sticky,
            toast.message,
            toast.displayed,
            toast.running,
            toast.remaining,
            toast.last_schedule,
            toast.iteration,
            $toast.compute_bottom_position(model.root, toast.id),
            toast.level,
            toast.animation_duration,
          );
        } else if ($ instanceof $toast.Show) {
          return new $toast.Toast(
            toast.external_id,
            toast.id,
            toast.sticky,
            toast.message,
            toast.displayed,
            toast.running,
            toast.remaining,
            toast.last_schedule,
            toast.iteration,
            $toast.compute_bottom_position(model.root, toast.id),
            toast.level,
            toast.animation_duration,
          );
        } else {
          return toast;
        }
      },
    ),
    model.id,
    model.timeout,
    model.root,
    model.next_frame,
    model.to_show,
  );
}
