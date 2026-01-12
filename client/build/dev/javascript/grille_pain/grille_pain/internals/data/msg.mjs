import * as $option from "../../../../gleam_stdlib/gleam/option.mjs";
import { CustomType as $CustomType } from "../../../gleam.mjs";
import * as $global from "../../../grille_pain/internals/global.mjs";
import * as $level from "../../../grille_pain/toast/level.mjs";

export class BrowserUpdatedToasts extends $CustomType {}
export const Msg$BrowserUpdatedToasts = () => new BrowserUpdatedToasts();
export const Msg$isBrowserUpdatedToasts = (value) =>
  value instanceof BrowserUpdatedToasts;

export class LustreComputedToasts extends $CustomType {}
export const Msg$LustreComputedToasts = () => new LustreComputedToasts();
export const Msg$isLustreComputedToasts = (value) =>
  value instanceof LustreComputedToasts;

export class LustreRequestedAnimationFrame extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$LustreRequestedAnimationFrame = ($0) =>
  new LustreRequestedAnimationFrame($0);
export const Msg$isLustreRequestedAnimationFrame = (value) =>
  value instanceof LustreRequestedAnimationFrame;
export const Msg$LustreRequestedAnimationFrame$0 = (value) => value[0];

export class ToastHidDisplay extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Msg$ToastHidDisplay = (id) => new ToastHidDisplay(id);
export const Msg$isToastHidDisplay = (value) =>
  value instanceof ToastHidDisplay;
export const Msg$ToastHidDisplay$id = (value) => value.id;
export const Msg$ToastHidDisplay$0 = (value) => value.id;

export class ToastTimedOut extends $CustomType {
  constructor(id, iteration) {
    super();
    this.id = id;
    this.iteration = iteration;
  }
}
export const Msg$ToastTimedOut = (id, iteration) =>
  new ToastTimedOut(id, iteration);
export const Msg$isToastTimedOut = (value) => value instanceof ToastTimedOut;
export const Msg$ToastTimedOut$id = (value) => value.id;
export const Msg$ToastTimedOut$0 = (value) => value.id;
export const Msg$ToastTimedOut$iteration = (value) => value.iteration;
export const Msg$ToastTimedOut$1 = (value) => value.iteration;

export class UserAddedToast extends $CustomType {
  constructor(uuid, message, level, timeout, sticky) {
    super();
    this.uuid = uuid;
    this.message = message;
    this.level = level;
    this.timeout = timeout;
    this.sticky = sticky;
  }
}
export const Msg$UserAddedToast = (uuid, message, level, timeout, sticky) =>
  new UserAddedToast(uuid, message, level, timeout, sticky);
export const Msg$isUserAddedToast = (value) => value instanceof UserAddedToast;
export const Msg$UserAddedToast$uuid = (value) => value.uuid;
export const Msg$UserAddedToast$0 = (value) => value.uuid;
export const Msg$UserAddedToast$message = (value) => value.message;
export const Msg$UserAddedToast$1 = (value) => value.message;
export const Msg$UserAddedToast$level = (value) => value.level;
export const Msg$UserAddedToast$2 = (value) => value.level;
export const Msg$UserAddedToast$timeout = (value) => value.timeout;
export const Msg$UserAddedToast$3 = (value) => value.timeout;
export const Msg$UserAddedToast$sticky = (value) => value.sticky;
export const Msg$UserAddedToast$4 = (value) => value.sticky;

export class UserEnteredToast extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Msg$UserEnteredToast = (id) => new UserEnteredToast(id);
export const Msg$isUserEnteredToast = (value) =>
  value instanceof UserEnteredToast;
export const Msg$UserEnteredToast$id = (value) => value.id;
export const Msg$UserEnteredToast$0 = (value) => value.id;

export class UserHidToast extends $CustomType {
  constructor(uuid) {
    super();
    this.uuid = uuid;
  }
}
export const Msg$UserHidToast = (uuid) => new UserHidToast(uuid);
export const Msg$isUserHidToast = (value) => value instanceof UserHidToast;
export const Msg$UserHidToast$uuid = (value) => value.uuid;
export const Msg$UserHidToast$0 = (value) => value.uuid;

export class UserLeavedToast extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Msg$UserLeavedToast = (id) => new UserLeavedToast(id);
export const Msg$isUserLeavedToast = (value) =>
  value instanceof UserLeavedToast;
export const Msg$UserLeavedToast$id = (value) => value.id;
export const Msg$UserLeavedToast$0 = (value) => value.id;
