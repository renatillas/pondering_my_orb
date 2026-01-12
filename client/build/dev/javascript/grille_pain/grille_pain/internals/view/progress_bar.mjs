import * as $int from "../../../../gleam_stdlib/gleam/int.mjs";
import * as $attribute from "../../../../lustre/lustre/attribute.mjs";
import * as $html from "../../../../lustre/lustre/element/html.mjs";
import { toList } from "../../../gleam.mjs";
import { var$ } from "../../../grille_pain/internals/css.mjs";
import * as $toast from "../../../grille_pain/internals/data/toast.mjs";
import * as $theme from "../../../grille_pain/internals/view/theme.mjs";
import * as $level from "../../../grille_pain/toast/level.mjs";

function background_color(level) {
  if (level instanceof $level.Standard) {
    let $ = $theme.is_dark();
    if ($) {
      return $theme.dark_transparent;
    } else {
      return $theme.light_transparent;
    }
  } else if (level instanceof $level.Info) {
    return $theme.color_transparent;
  } else if (level instanceof $level.Warning) {
    return $theme.color_transparent;
  } else if (level instanceof $level.Error) {
    return $theme.color_transparent;
  } else {
    return $theme.color_transparent;
  }
}

function pb_background_color(level) {
  let back_color = background_color(level);
  let level$1 = $level.to_string(level);
  let variable = ("grille_pain-" + level$1) + "-progress-bar";
  return var$(variable, back_color);
}

export function view(toast) {
  let animation_duration = $int.to_string(toast.animation_duration);
  let play_state = $toast.running_to_string(toast.running);
  return $html.div(
    toList([
      $attribute.class$("progress-bar"),
      $attribute.style("animation-duration", animation_duration + "ms"),
      $attribute.style("background", pb_background_color(toast.level)),
      $attribute.style("animation-play-state", play_state),
    ]),
    toList([]),
  );
}
