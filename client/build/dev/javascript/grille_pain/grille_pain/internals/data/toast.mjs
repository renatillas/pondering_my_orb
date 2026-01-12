import { CustomType as $CustomType } from "../../../gleam.mjs";
import * as $global from "../../../grille_pain/internals/global.mjs";
import * as $shadow from "../../../grille_pain/internals/shadow.mjs";
import * as $level from "../../../grille_pain/toast/level.mjs";
import {
  computeToastSize as compute_size,
  computeBottomPosition as compute_bottom_position,
  uuid,
} from "./toast.ffi.mjs";

export { compute_bottom_position, compute_size, uuid };

export class WillShow extends $CustomType {}
export const DisplayState$WillShow = () => new WillShow();
export const DisplayState$isWillShow = (value) => value instanceof WillShow;

export class Show extends $CustomType {}
export const DisplayState$Show = () => new Show();
export const DisplayState$isShow = (value) => value instanceof Show;

export class WillHide extends $CustomType {}
export const DisplayState$WillHide = () => new WillHide();
export const DisplayState$isWillHide = (value) => value instanceof WillHide;

export class Toast extends $CustomType {
  constructor(external_id, id, sticky, message, displayed, running, remaining, last_schedule, iteration, bottom, level, animation_duration) {
    super();
    this.external_id = external_id;
    this.id = id;
    this.sticky = sticky;
    this.message = message;
    this.displayed = displayed;
    this.running = running;
    this.remaining = remaining;
    this.last_schedule = last_schedule;
    this.iteration = iteration;
    this.bottom = bottom;
    this.level = level;
    this.animation_duration = animation_duration;
  }
}
export const Toast$Toast = (external_id, id, sticky, message, displayed, running, remaining, last_schedule, iteration, bottom, level, animation_duration) =>
  new Toast(external_id,
  id,
  sticky,
  message,
  displayed,
  running,
  remaining,
  last_schedule,
  iteration,
  bottom,
  level,
  animation_duration);
export const Toast$isToast = (value) => value instanceof Toast;
export const Toast$Toast$external_id = (value) => value.external_id;
export const Toast$Toast$0 = (value) => value.external_id;
export const Toast$Toast$id = (value) => value.id;
export const Toast$Toast$1 = (value) => value.id;
export const Toast$Toast$sticky = (value) => value.sticky;
export const Toast$Toast$2 = (value) => value.sticky;
export const Toast$Toast$message = (value) => value.message;
export const Toast$Toast$3 = (value) => value.message;
export const Toast$Toast$displayed = (value) => value.displayed;
export const Toast$Toast$4 = (value) => value.displayed;
export const Toast$Toast$running = (value) => value.running;
export const Toast$Toast$5 = (value) => value.running;
export const Toast$Toast$remaining = (value) => value.remaining;
export const Toast$Toast$6 = (value) => value.remaining;
export const Toast$Toast$last_schedule = (value) => value.last_schedule;
export const Toast$Toast$7 = (value) => value.last_schedule;
export const Toast$Toast$iteration = (value) => value.iteration;
export const Toast$Toast$8 = (value) => value.iteration;
export const Toast$Toast$bottom = (value) => value.bottom;
export const Toast$Toast$9 = (value) => value.bottom;
export const Toast$Toast$level = (value) => value.level;
export const Toast$Toast$10 = (value) => value.level;
export const Toast$Toast$animation_duration = (value) =>
  value.animation_duration;
export const Toast$Toast$11 = (value) => value.animation_duration;

export function running_to_string(running) {
  if (running) {
    return "running";
  } else {
    return "paused";
  }
}

export function by_uuid(toast, uuid) {
  return toast.external_id === uuid;
}

export function by_id(toast, id) {
  return toast.id === id;
}

export function by_iteration(toast, id, iteration) {
  return (toast.id === id) && (toast.iteration === iteration);
}

export function new$(external_id, id, message, level, remaining, sticky, root) {
  return new Toast(
    external_id,
    id,
    sticky,
    message,
    new WillShow(),
    false,
    remaining,
    $global.now(),
    0,
    compute_bottom_position(root, id),
    level,
    remaining,
  );
}
