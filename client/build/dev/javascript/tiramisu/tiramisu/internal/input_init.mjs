import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $element from "../../../plinth/plinth/browser/element.mjs";
import * as $event from "../../../plinth/plinth/browser/event.mjs";
import * as $window from "../../../plinth/plinth/browser/window.mjs";
import * as $input_manager from "../../tiramisu/internal/input_manager.mjs";
import {
  getMouseButton as get_mouse_button,
  getMousePosition as get_mouse_position,
  getWheelDelta as get_wheel_delta,
  getChangedTouches as get_changed_touches,
  getChangedTouchIds as get_changed_touch_ids,
} from "./input_init.ffi.mjs";

function attach_keydown(get_manager, set_manager) {
  let handler = (event) => {
    let current = get_manager();
    let _pipe = $event.code(event);
    let _pipe$1 = ((_capture) => {
      return $input_manager.on_keydown(current, _capture);
    })(_pipe);
    return set_manager(_pipe$1);
  };
  return $window.add_event_listener("keydown", handler);
}

function attach_keyup(get_manager, set_manager) {
  let handler = (event) => {
    let current = get_manager();
    let _pipe = $event.code(event);
    let _pipe$1 = ((_capture) => {
      return $input_manager.on_keyup(current, _capture);
    })(_pipe);
    return set_manager(_pipe$1);
  };
  return $window.add_event_listener("keyup", handler);
}

function attach_contextmenu(canvas, _, _1) {
  let handler = (event) => { return $event.prevent_default(event); };
  return $element.add_event_listener(canvas, "contextmenu", handler);
}

function attach_gamepadconnected(canvas, get_manager, set_manager) {
  let handler = (_) => {
    let current = get_manager();
    let updated = $input_manager.on_gamepad_connected(current);
    set_manager(updated);
    return undefined;
  };
  return $element.add_event_listener(canvas, "gamepadconnected", handler);
}

function attach_gamepaddisconnected(canvas, get_manager, set_manager) {
  let handler = (_) => {
    let current = get_manager();
    let updated = $input_manager.on_gamepad_disconnected(current);
    set_manager(updated);
    return undefined;
  };
  return $element.add_event_listener(canvas, "gamepaddisconnected", handler);
}

function attach_mousedown(canvas, get_manager, set_manager) {
  let handler = (event) => {
    let current = get_manager();
    let _pipe = get_mouse_button(event);
    let _pipe$1 = ((_capture) => {
      return $input_manager.on_mousedown(current, _capture);
    })(_pipe);
    return set_manager(_pipe$1);
  };
  return $element.add_event_listener(canvas, "mousedown", handler);
}

function attach_mouseup(canvas, get_manager, set_manager) {
  let handler = (event) => {
    let current = get_manager();
    let _pipe = get_mouse_button(event);
    let _pipe$1 = ((_capture) => {
      return $input_manager.on_mouseup(current, _capture);
    })(_pipe);
    return set_manager(_pipe$1);
  };
  return $element.add_event_listener(canvas, "mouseup", handler);
}

function attach_mousemove(canvas, get_manager, set_manager) {
  let handler = (evt) => {
    let $ = get_mouse_position(canvas, evt);
    let x;
    let y;
    let delta_x;
    let delta_y;
    x = $[0];
    y = $[1];
    delta_x = $[2];
    delta_y = $[3];
    let current = get_manager();
    let _pipe = $input_manager.on_mousemove(current, x, y, delta_x, delta_y);
    return set_manager(_pipe);
  };
  return $element.add_event_listener(canvas, "mousemove", handler);
}

function attach_wheel(canvas, get_manager, set_manager) {
  let handler = (event) => {
    let current = get_manager();
    let _pipe = get_wheel_delta(event);
    let _pipe$1 = ((_capture) => {
      return $input_manager.on_wheel(current, _capture);
    })(_pipe);
    return set_manager(_pipe$1);
  };
  return $element.add_event_listener(canvas, "wheel", handler);
}

function attach_touchstart(canvas, get_manager, set_manager) {
  let handler = (event) => {
    $event.prevent_default(event);
    let current = get_manager();
    let _pipe = get_changed_touches(canvas, event);
    let _pipe$1 = $list.fold(
      _pipe,
      current,
      (manager, touch) => {
        let id;
        let x;
        let y;
        id = touch[0];
        x = touch[1];
        y = touch[2];
        return $input_manager.on_touchstart(manager, id, x, y);
      },
    );
    return set_manager(_pipe$1);
  };
  return $element.add_event_listener(canvas, "touchstart", handler);
}

function attach_touchmove(canvas, get_manager, set_manager) {
  let handler = (event) => {
    $event.prevent_default(event);
    let current = get_manager();
    let _pipe = get_changed_touches(canvas, event);
    let _pipe$1 = $list.fold(
      _pipe,
      current,
      (manager, touch) => {
        let id;
        let x;
        let y;
        id = touch[0];
        x = touch[1];
        y = touch[2];
        return $input_manager.on_touchmove(manager, id, x, y);
      },
    );
    return set_manager(_pipe$1);
  };
  return $element.add_event_listener(canvas, "touchmove", handler);
}

function attach_touchend(canvas, get_manager, set_manager) {
  let handler = (event) => {
    $event.prevent_default(event);
    let current = get_manager();
    let _pipe = get_changed_touch_ids(event);
    let _pipe$1 = $list.fold(
      _pipe,
      current,
      (manager, id) => { return $input_manager.on_touchend(manager, id); },
    );
    return set_manager(_pipe$1);
  };
  return $element.add_event_listener(canvas, "touchend", handler);
}

function attach_touchcancel(canvas, get_manager, set_manager) {
  let handler = (evt) => {
    $event.prevent_default(evt);
    let current = get_manager();
    let _pipe = get_changed_touch_ids(evt);
    let _pipe$1 = $list.fold(
      _pipe,
      current,
      (manager, id) => { return $input_manager.on_touchcancel(manager, id); },
    );
    return set_manager(_pipe$1);
  };
  return $element.add_event_listener(canvas, "touchcancel", handler);
}

/**
 * Initialize input system - attach all event listeners to canvas
 * Returns a cleanup function to remove all listeners
 */
export function initialize(canvas, get_manager, set_manager) {
  attach_keydown(get_manager, set_manager);
  attach_keyup(get_manager, set_manager);
  attach_mousemove(canvas, get_manager, set_manager);
  attach_mousedown(canvas, get_manager, set_manager);
  attach_mouseup(canvas, get_manager, set_manager);
  attach_contextmenu(canvas, get_manager, set_manager);
  attach_wheel(canvas, get_manager, set_manager);
  attach_touchstart(canvas, get_manager, set_manager);
  attach_touchmove(canvas, get_manager, set_manager);
  attach_touchend(canvas, get_manager, set_manager);
  attach_touchcancel(canvas, get_manager, set_manager);
  attach_gamepadconnected(canvas, get_manager, set_manager);
  attach_gamepaddisconnected(canvas, get_manager, set_manager);
  return undefined;
}
