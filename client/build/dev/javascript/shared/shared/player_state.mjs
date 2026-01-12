import * as $json from "../../gleam_json/gleam/json.mjs";
import * as $decode from "../../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { Vec3 } from "../../vec/vec/vec3.mjs";
import { toList, CustomType as $CustomType } from "../gleam.mjs";
import * as $id from "../shared/id.mjs";
import { PlayerId } from "../shared/id.mjs";

export class PlayerState extends $CustomType {
  constructor(id, position, rotation, health, max_health, active_wand_index) {
    super();
    this.id = id;
    this.position = position;
    this.rotation = rotation;
    this.health = health;
    this.max_health = max_health;
    this.active_wand_index = active_wand_index;
  }
}
export const PlayerState$PlayerState = (id, position, rotation, health, max_health, active_wand_index) =>
  new PlayerState(id, position, rotation, health, max_health, active_wand_index);
export const PlayerState$isPlayerState = (value) =>
  value instanceof PlayerState;
export const PlayerState$PlayerState$id = (value) => value.id;
export const PlayerState$PlayerState$0 = (value) => value.id;
export const PlayerState$PlayerState$position = (value) => value.position;
export const PlayerState$PlayerState$1 = (value) => value.position;
export const PlayerState$PlayerState$rotation = (value) => value.rotation;
export const PlayerState$PlayerState$2 = (value) => value.rotation;
export const PlayerState$PlayerState$health = (value) => value.health;
export const PlayerState$PlayerState$3 = (value) => value.health;
export const PlayerState$PlayerState$max_health = (value) => value.max_health;
export const PlayerState$PlayerState$4 = (value) => value.max_health;
export const PlayerState$PlayerState$active_wand_index = (value) =>
  value.active_wand_index;
export const PlayerState$PlayerState$5 = (value) => value.active_wand_index;

/**
 * Encode a PlayerState to JSON for network transmission.
 */
export function encode(state) {
  let $ = state.id;
  let player_id;
  player_id = $[0];
  return $json.object(
    toList([
      ["id", $json.string(player_id)],
      [
        "position",
        $json.object(
          toList([
            ["x", $json.float(state.position.x)],
            ["y", $json.float(state.position.y)],
            ["z", $json.float(state.position.z)],
          ]),
        ),
      ],
      ["rotation", $json.float(state.rotation)],
      ["health", $json.float(state.health)],
      ["max_health", $json.float(state.max_health)],
      ["active_wand_index", $json.int(state.active_wand_index)],
    ]),
  );
}

/**
 * Decoder for Vec3(Float).
 */
export function vec3_decoder() {
  return $decode.field(
    "x",
    $decode.float,
    (x) => {
      return $decode.field(
        "y",
        $decode.float,
        (y) => {
          return $decode.field(
            "z",
            $decode.float,
            (z) => { return $decode.success(new Vec3(x, y, z)); },
          );
        },
      );
    },
  );
}

/**
 * Decoder for PlayerState from JSON.
 */
export function decoder() {
  return $decode.field(
    "id",
    $decode.string,
    (id) => {
      return $decode.field(
        "position",
        vec3_decoder(),
        (position) => {
          return $decode.field(
            "rotation",
            $decode.float,
            (rotation) => {
              return $decode.field(
                "health",
                $decode.float,
                (health) => {
                  return $decode.field(
                    "max_health",
                    $decode.float,
                    (max_health) => {
                      return $decode.field(
                        "active_wand_index",
                        $decode.int,
                        (active_wand_index) => {
                          return $decode.success(
                            new PlayerState(
                              new PlayerId(id),
                              position,
                              rotation,
                              health,
                              max_health,
                              active_wand_index,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

/**
 * Encode a Vec3 to JSON.
 */
export function encode_vec3(v) {
  return $json.object(
    toList([
      ["x", $json.float(v.x)],
      ["y", $json.float(v.y)],
      ["z", $json.float(v.z)],
    ]),
  );
}
