import * as $unsafe from "../../grille_pain/internals/unsafe.mjs";
import {
  setTimeout as set_timeout,
  now,
  requestAnimationFrame as request_animation_frame,
} from "./global.ffi.mjs";

export { now, request_animation_frame, set_timeout };
