import * as $level from "../../../grille_pain/toast/level.mjs";
import { isDark as is_dark } from "./theme.ffi.mjs";

export { is_dark };

export const info = "var(--info)";

export const success = "var(--success)";

export const warning = "var(--warning)";

export const error = "var(--error)";

export const color_transparent = "var(--color-transparent)";

export const light_transparent = "var(--light-transparent)";

export const dark_transparent = "var(--dark-transparent)";

export const dark = "var(--dark)";

export const light = "var(--light)";

function standard() {
  let $ = is_dark();
  if ($) {
    return [dark, light];
  } else {
    return [light, dark];
  }
}

export function color(level) {
  if (level instanceof $level.Standard) {
    return standard();
  } else if (level instanceof $level.Info) {
    return [info, light];
  } else if (level instanceof $level.Warning) {
    return [warning, light];
  } else if (level instanceof $level.Error) {
    return [error, light];
  } else {
    return [success, light];
  }
}
