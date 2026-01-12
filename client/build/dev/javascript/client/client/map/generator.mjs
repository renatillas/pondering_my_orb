import * as $int from "../../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $vec2 from "../../../vec/vec/vec2.mjs";
import { Vec2 } from "../../../vec/vec/vec2.mjs";
import * as $vec3 from "../../../vec/vec/vec3.mjs";
import { Vec3 } from "../../../vec/vec/vec3.mjs";
import * as $id from "../../client/id.mjs";
import { toList, CustomType as $CustomType } from "../../gleam.mjs";

export class Floor extends $CustomType {
  constructor(position, rotation) {
    super();
    this.position = position;
    this.rotation = rotation;
  }
}
export const StructureElement$Floor = (position, rotation) =>
  new Floor(position, rotation);
export const StructureElement$isFloor = (value) => value instanceof Floor;
export const StructureElement$Floor$position = (value) => value.position;
export const StructureElement$Floor$0 = (value) => value.position;
export const StructureElement$Floor$rotation = (value) => value.rotation;
export const StructureElement$Floor$1 = (value) => value.rotation;

export class Wall extends $CustomType {
  constructor(position, rotation) {
    super();
    this.position = position;
    this.rotation = rotation;
  }
}
export const StructureElement$Wall = (position, rotation) =>
  new Wall(position, rotation);
export const StructureElement$isWall = (value) => value instanceof Wall;
export const StructureElement$Wall$position = (value) => value.position;
export const StructureElement$Wall$0 = (value) => value.position;
export const StructureElement$Wall$rotation = (value) => value.rotation;
export const StructureElement$Wall$1 = (value) => value.rotation;

export const StructureElement$position = (value) => value.position;
export const StructureElement$rotation = (value) => value.rotation;

export class Arena extends $CustomType {
  constructor(elements) {
    super();
    this.elements = elements;
  }
}
export const Arena$Arena = (elements) => new Arena(elements);
export const Arena$isArena = (value) => value instanceof Arena;
export const Arena$Arena$elements = (value) => value.elements;
export const Arena$Arena$0 = (value) => value.elements;

const pi = 3.1416;

const half_pi = 1.5708;

const tile_size = 10.0;

/**
 * Get direction vector from rotation angle
 * Returns (dx, dz) unit vector for placing consecutive elements
 * 
 * @ignore
 */
function direction_from_rotation(rotation) {
  let r = rotation;
  if ((r > 3.0) && (r < 3.5)) {
    return new Vec2(1.0, 0.0);
  } else {
    let r = rotation;
    if ((r > -0.5) && (r < 0.5)) {
      return new Vec2(1.0, 0.0);
    } else {
      let r = rotation;
      if ((r > 1.0) && (r < 2.0)) {
        return new Vec2(0.0, 1.0);
      } else {
        let r = rotation;
        if ((r < -1.0) && (r > -2.0)) {
          return new Vec2(0.0, 1.0);
        } else {
          return new Vec2(1.0, 0.0);
        }
      }
    }
  }
}

/**
 * Get the rendering layer for proper depth ordering
 */
export function get_render_layer(element) {
  if (element instanceof $id.Wall) {
    return 2;
  } else if (element instanceof $id.Floor) {
    return 0;
  } else {
    return -1;
  }
}

/**
 * Generate a grid of floor tiles
 * size: number of tiles in x and z directions
 * position: center position of the floor grid
 */
export function floor(size, position) {
  let half_width = ($int.to_float(size.x) * tile_size) / 2.0;
  let half_depth = ($int.to_float(size.y) * tile_size) / 2.0;
  let _pipe = $list.range(0, size.y - 1);
  return $list.flat_map(
    _pipe,
    (z) => {
      let _pipe$1 = $list.range(0, size.x - 1);
      return $list.map(
        _pipe$1,
        (x) => {
          let tile_x = ((position.x - half_width) + ($int.to_float(x) * tile_size)) + (tile_size / 2.0);
          let tile_z = ((position.z - half_depth) + ($int.to_float(z) * tile_size)) + (tile_size / 2.0);
          return new Floor(new Vec3(tile_x, position.y, tile_z), 0.0);
        },
      );
    },
  );
}

/**
 * Generate a line of wall segments
 * length: number of wall segments
 * position: starting position (first segment)
 * rotation: wall rotation (determines direction of wall line)
 */
export function wall(length, position, rotation) {
  let $ = direction_from_rotation(rotation);
  let dx;
  let dz;
  dx = $.x;
  dz = $.y;
  let _pipe = $list.range(0, length - 1);
  return $list.map(
    _pipe,
    (i) => {
      let offset = $int.to_float(i) * tile_size;
      return new Wall(
        new Vec3(
          position.x + (dx * offset),
          position.y,
          position.z + (dz * offset),
        ),
        rotation,
      );
    },
  );
}

/**
 * Create a fortified arena
 */
export function create_arena() {
  let elements = $list.flatten(
    toList([
      floor(new Vec2(16, 16), new Vec3(0.0, 0.0, 0.0)),
      wall(16, new Vec3(-75.0, 0.0, -85.0), pi),
      wall(16, new Vec3(-75.0, 0.0, 85.0), 0.0),
      wall(16, new Vec3(-85.0, 0.0, -75.0), 0.0 - half_pi),
      wall(16, new Vec3(85.0, 0.0, -75.0), half_pi),
    ]),
  );
  return new Arena(elements);
}
