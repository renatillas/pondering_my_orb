import * as $json from "../../../gleam_json/gleam/json.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import { isEqual } from "../../gleam.mjs";

export function sparse(entries) {
  let _pipe = $list.filter(
    entries,
    (entry) => {
      let v;
      v = entry[1];
      return !isEqual(v, $json.null$());
    },
  );
  return $json.object(_pipe);
}
