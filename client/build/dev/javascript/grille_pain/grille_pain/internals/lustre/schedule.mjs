import * as $effect from "../../../../lustre/lustre/effect.mjs";
import * as $global from "../../../grille_pain/internals/global.mjs";

export function schedule(duration, msg) {
  return $effect.from(
    (dispatch) => {
      return $global.set_timeout(duration, () => { return dispatch(msg); });
    },
  );
}
