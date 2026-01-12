import * as $decode from "../../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import { toList } from "../gleam.mjs";

export function float_or_int() {
  return $decode.one_of(
    $decode.float,
    toList([$decode.map($decode.int, $int.to_float)]),
  );
}
