import * as $bool from "../../../gleam_stdlib/gleam/bool.mjs";
import * as $int from "../../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $attribute from "../../../lustre/lustre/attribute.mjs";
import * as $element from "../../../lustre/lustre/element.mjs";
import * as $html from "../../../lustre/lustre/element/html.mjs";
import * as $keyed from "../../../lustre/lustre/element/keyed.mjs";
import * as $event from "../../../lustre/lustre/event.mjs";
import { toList, prepend as listPrepend } from "../../gleam.mjs";
import { var$ } from "../../grille_pain/internals/css.mjs";
import * as $model from "../../grille_pain/internals/data/model.mjs";
import * as $msg from "../../grille_pain/internals/data/msg.mjs";
import * as $toast from "../../grille_pain/internals/data/toast.mjs";
import * as $progress_bar from "../../grille_pain/internals/view/progress_bar.mjs";
import * as $theme from "../../grille_pain/internals/view/theme.mjs";
import * as $level from "../../grille_pain/toast/level.mjs";

function select_on_click_action(toast) {
  return $bool.lazy_guard(
    toast.sticky,
    $attribute.none,
    () => {
      return $event.on_click(new $msg.ToastTimedOut(toast.id, toast.iteration));
    },
  );
}

function toast_progress_bar(toast) {
  return $bool.lazy_guard(
    toast.sticky,
    $element.none,
    () => { return $progress_bar.view(toast); },
  );
}

function toast_wrapper_class(toast) {
  let $ = toast.displayed;
  if ($ instanceof $toast.WillShow) {
    return "toast-wrapper-right";
  } else if ($ instanceof $toast.Show) {
    return "toast-wrapper-all";
  } else {
    return "toast-wrapper-all";
  }
}

function toast_wrapper_right(toast) {
  let $ = toast.displayed;
  if ($ instanceof $toast.WillShow) {
    let width = var$("grille_pain-width", "320px");
    return ("calc(-1 * " + width) + " - 100px)";
  } else if ($ instanceof $toast.Show) {
    return "0px";
  } else {
    let width = var$("grille_pain-width", "320px");
    return ("calc(-1 * " + width) + " - 100px)";
  }
}

function toast_wrapper(toast, attributes, children) {
  return $html.div(
    listPrepend(
      $attribute.class$("toast-wrapper"),
      listPrepend(
        $attribute.class$(toast_wrapper_class(toast)),
        listPrepend(
          $attribute.style("right", toast_wrapper_right(toast)),
          listPrepend(
            $attribute.style("top", $int.to_string(toast.bottom) + "px"),
            attributes,
          ),
        ),
      ),
    ),
    children,
  );
}

function wrapper_dom_classes(toast) {
  let _block;
  let $ = toast.displayed;
  if ($ instanceof $toast.WillShow) {
    _block = "will-show";
  } else if ($ instanceof $toast.Show) {
    _block = "show";
  } else {
    _block = "will-hide";
  }
  let displayed = _block;
  return $attribute.classes(
    toList([
      ["grille_pain-toast", true],
      ["grille_pain-toast-" + $int.to_string(toast.id), true],
      ["grille_pain-toast-" + displayed, true],
    ]),
  );
}

function toast_colors(level) {
  let $ = $theme.color(level);
  let background;
  let text_color;
  background = $[0];
  text_color = $[1];
  let level$1 = $level.to_string(level);
  let background_ = ("grille_pain-" + level$1) + "-background";
  let text = ("grille_pain-" + level$1) + "-text-color";
  let bg = $attribute.style("background", var$(background_, background));
  let color = $attribute.style("color", var$(text, text_color));
  return toList([bg, color]);
}

function toast_container(toast, children) {
  let mouse_enter = $event.on_mouse_enter(new $msg.UserEnteredToast(toast.id));
  let mouse_leave = $event.on_mouse_leave(new $msg.UserLeavedToast(toast.id));
  let colors = toast_colors(toast.level);
  let toast$1 = $attribute.class$("toast");
  return $html.div(
    listPrepend(
      mouse_enter,
      listPrepend(mouse_leave, listPrepend(toast$1, colors)),
    ),
    children,
  );
}

export function toast_content(attributes, children) {
  return $html.div(
    listPrepend($attribute.class$("toast-content"), attributes),
    children,
  );
}

function view_toast(toast) {
  let on_hide = select_on_click_action(toast);
  let data_id = $attribute.attribute("data-id", $int.to_string(toast.id));
  return toast_wrapper(
    toast,
    toList([wrapper_dom_classes(toast), data_id]),
    toList([
      toast_container(
        toast,
        toList([
          toast_content(toList([on_hide]), toList([$html.text(toast.message)])),
          toast_progress_bar(toast),
        ]),
      ),
    ]),
  );
}

export function view(model) {
  let toasts = model.toasts;
  return $keyed.div(
    toList([$attribute.class$("grille-pain")]),
    $list.map(
      toasts,
      (toast) => {
        let id = $int.to_string(toast.id);
        return [id, view_toast(toast)];
      },
    ),
  );
}
