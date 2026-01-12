import * as $element from "../../grille_pain/internals/element.mjs";
import {
  attachShadow as attach,
  appendChild as append_child,
  addStyles as add_styles,
} from "./element.ffi.mjs";

export { add_styles, append_child, attach };
