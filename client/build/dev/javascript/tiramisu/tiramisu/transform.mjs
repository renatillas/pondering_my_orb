import * as $maths from "../../gleam_community_maths/gleam_community/maths.mjs";
import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $quaternion from "../../quaterni/quaternion.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import * as $vec3f from "../../vec/vec/vec3f.mjs";
import { Ok, CustomType as $CustomType } from "../gleam.mjs";

class Transform extends $CustomType {
  constructor(position, rotation, scale) {
    super();
    this.position = position;
    this.rotation = rotation;
    this.scale = scale;
  }
}

export class Spherical extends $CustomType {}
export const BillboardMode$Spherical = () => new Spherical();
export const BillboardMode$isSpherical = (value) => value instanceof Spherical;

export class Cylindrical extends $CustomType {}
export const BillboardMode$Cylindrical = () => new Cylindrical();
export const BillboardMode$isCylindrical = (value) =>
  value instanceof Cylindrical;

export class SphericalNoRoll extends $CustomType {}
export const BillboardMode$SphericalNoRoll = () => new SphericalNoRoll();
export const BillboardMode$isSphericalNoRoll = (value) =>
  value instanceof SphericalNoRoll;

/**
 * Create an identity transform (position at origin, no rotation, scale 1).
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.identity
 * // position: (0, 0, 0), rotation: quaternion identity, scale: (1, 1, 1)
 * ```
 */
export const identity = /* @__PURE__ */ new Transform(
  /* @__PURE__ */ new $vec3.Vec3(0.0, 0.0, 0.0),
  $quaternion.identity,
  /* @__PURE__ */ new $vec3.Vec3(1.0, 1.0, 1.0),
);

/**
 * Create a transform at a specific position with default rotation and scale.
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.at(position: vec3.Vec3(5.0, 0.0, -3.0))
 * // Object positioned at (5, 0, -3)
 * ```
 */
export function at(position) {
  return new Transform(position, $quaternion.identity, $vec3f.one);
}

/**
 * Get the position of a transform.
 *
 * ## Example
 *
 * ```gleam
 * let pos = transform.position(my_transform)
 * // Returns vec3.Vec3(x, y, z)
 * ```
 */
export function position(transform) {
  return transform.position;
}

/**
 * Get the rotation of a transform as Euler angles (in radians).
 *
 * Returns rotation as Vec3(x_rotation, y_rotation, z_rotation) in radians.
 *
 * ## Example
 *
 * ```gleam
 * let euler = transform.rotation(my_transform)
 * // Returns vec3.Vec3(x_rotation, y_rotation, z_rotation)
 * ```
 */
export function rotation(transform) {
  return $quaternion.to_euler(transform.rotation);
}

/**
 * Get the rotation of a transform as a quaternion.
 *
 * ## Example
 *
 * ```gleam
 * let quat = transform.rotation_quaternion(my_transform)
 * // Returns quaternion.Quaternion(x, y, z, w)
 * ```
 */
export function rotation_quaternion(transform) {
  return transform.rotation;
}

/**
 * Get the scale of a transform.
 *
 * ## Example
 *
 * ```gleam
 * let scale = transform.scale(my_transform)
 * // Returns vec3.Vec3(x, y, z)
 * ```
 */
export function scale(transform) {
  return transform.scale;
}

/**
 * Update the position of a transform.
 *
 * ## Example
 *
 * ```gleam
 * let moved = transform.identity
 *   |> transform.with_position(vec3.Vec3(1.0, 2.0, 3.0))
 * ```
 */
export function with_position(transform, position) {
  return new Transform(position, transform.rotation, transform.scale);
}

/**
 * Update the rotation of a transform using Euler angles (in radians).
 *
 * Converts Euler angles to quaternion internally.
 *
 * ## Example
 *
 * ```gleam
 * let rotated = transform.identity
 *   |> transform.with_euler_rotation(vec3.Vec3(0.0, 1.57, 0.0))  // 90° turn around Y axis
 * ```
 */
export function with_euler_rotation(transform, euler) {
  let quat = $quaternion.from_euler(euler);
  return new Transform(transform.position, quat, transform.scale);
}

/**
 * Update the rotation of a transform using a quaternion directly.
 *
 * Use this when you already have a quaternion or want to avoid Euler angle conversion.
 *
 * ## Example
 *
 * ```gleam
 * let quat = transform.Quaternion(0.0, 0.707, 0.0, 0.707)
 * let rotated = transform.identity
 *   |> transform.with_quaternion_rotation(quat)
 * ```
 */
export function with_quaternion_rotation(transform, quaternion) {
  return new Transform(transform.position, quaternion, transform.scale);
}

/**
 * Update the scale of a transform.
 *
 * ## Example
 *
 * ```gleam
 * let scaled = transform.identity
 *   |> transform.with_scale(vec3.Vec3(2.0, 1.0, 2.0))  // Wide and deep, normal height
 * ```
 */
export function with_scale(transform, scale) {
  return new Transform(transform.position, transform.rotation, scale);
}

function lerp_vec(a, b, t) {
  return new $vec3.Vec3(
    a.x + ((b.x - a.x) * t),
    a.y + ((b.y - a.y) * t),
    a.z + ((b.z - a.z) * t),
  );
}

/**
 * Linearly interpolate between two transforms.
 *
 * Uses linear interpolation for position and scale, and spherical linear
 * interpolation (slerp) for rotation to ensure smooth rotation transitions.
 *
 * Parameter `t` should be between 0.0 and 1.0:
 * - `t = 0.0` returns `from`
 * - `t = 1.0` returns `to`
 * - `t = 0.5` returns halfway between
 *
 * ## Example
 *
 * ```gleam
 * let start = transform.at(vec3.Vec3(0.0, 0.0, 0.0))
 * let end = transform.at(vec3.Vec3(10.0, 0.0, 0.0))
 * let halfway = transform.lerp(start, to: end, with: 0.5)
 * // position: (5.0, 0.0, 0.0)
 * ```
 */
export function lerp(from, to, t) {
  return new Transform(
    lerp_vec(from.position, to.position, t),
    $quaternion.linear_interpolation(from.rotation, to.rotation, t),
    lerp_vec(from.scale, to.scale, t),
  );
}

/**
 * Compose two transforms (apply second transform after first).
 *
 * Useful for relative transformations. Combines positions, multiplies quaternions
 * for rotation, and multiplies scales. For proper hierarchical transforms,
 * use scene `Group` nodes instead.
 *
 * ## Example
 *
 * ```gleam
 * let base = transform.at(vec3.Vec3(5.0, 0.0, 0.0))
 * let offset = transform.at(vec3.Vec3(0.0, 2.0, 0.0))
 * let combined = transform.compose(base, offset)
 * // position: (5.0, 2.0, 0.0)
 * ```
 */
export function compose(first, second) {
  return new Transform(
    $vec3f.add(first.position, second.position),
    $quaternion.multiply(first.rotation, second.rotation),
    new $vec3.Vec3(
      first.scale.x * second.scale.x,
      first.scale.y * second.scale.y,
      first.scale.z * second.scale.z,
    ),
  );
}

/**
 * Create a transform that looks at a target position from a source position.
 *
 * Calculates the rotation needed to point from `from` towards `to`.
 *
 * ## Example
 *
 * ```gleam
 * let camera_pos = transform.at(vec3.Vec3(0.0, 5.0, 10.0))
 * let target_pos = transform.at(vec3.Vec3(0.0, 0.0, 0.0))
 * let look_transform = transform.look_at(from: camera_pos, to: target_pos, up: option.None)
 * // Camera now faces the origin
 * ```
 */
export function look_at(from, to, up) {
  let up$1 = $option.unwrap(up, new $vec3.Vec3(0.0, 1.0, 0.0));
  let direction = $vec3f.subtract(to.position, from.position);
  let quat = $quaternion.look_at(
    new $vec3.Vec3(0.0, 0.0, -1.0),
    direction,
    up$1,
  );
  return new Transform(from.position, quat, from.scale);
}

/**
 * Move a transform by adding to its current position (relative movement).
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.at(vec3.Vec3(5.0, 0.0, 0.0))
 *   |> transform.translate_by(vec3.Vec3(2.0, 1.0, 0.0))
 * // position: (7.0, 1.0, 0.0)
 * ```
 */
export function translate(transform, offset) {
  return new Transform(
    $vec3f.add(transform.position, offset),
    transform.rotation,
    transform.scale,
  );
}

/**
 * Rotate a transform by applying an additional rotation (relative rotation).
 *
 * Converts the Euler angle rotation to a quaternion and multiplies it with
 * the current rotation.
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.identity
 *   |> transform.rotate_by(vec3.Vec3(0.0, 1.57, 0.0))  // Turn 90° right
 *   |> transform.rotate_by(vec3.Vec3(0.0, 1.57, 0.0))  // Turn another 90° right
 * // Now facing backward
 * ```
 */
export function rotate_by(transform, euler) {
  let additional_rotation = $quaternion.from_euler(euler);
  return new Transform(
    transform.position,
    $quaternion.multiply(transform.rotation, additional_rotation),
    transform.scale,
  );
}

/**
 * Scale a transform by multiplying its current scale (relative scaling).
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.identity
 *   |> transform.scale_by(vec3.Vec3(2.0, 1.0, 2.0))
 *   |> transform.scale_by(vec3.Vec3(2.0, 1.0, 1.0))
 * // scale: (4.0, 1.0, 2.0)
 * ```
 */
export function scale_by(transform, scale_factor) {
  return new Transform(
    transform.position,
    transform.rotation,
    new $vec3.Vec3(
      transform.scale.x * scale_factor.x,
      transform.scale.y * scale_factor.y,
      transform.scale.z * scale_factor.z,
    ),
  );
}

/**
 * Set uniform scale on all axes (width = height = depth).
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.identity
 *   |> transform.scale_uniform(2.0)
 * // scale: (2.0, 2.0, 2.0) - twice as big in all dimensions
 * ```
 */
export function scale_uniform(transform, scale) {
  return new Transform(
    transform.position,
    transform.rotation,
    new $vec3.Vec3(scale, scale, scale),
  );
}

/**
 * Rotate around the Y axis (yaw/turn left-right).
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.identity
 *   |> transform.rotate_y(1.57)  // Turn 90° right
 * ```
 */
export function rotate_y(transform, angle) {
  return rotate_by(transform, new $vec3.Vec3(0.0, angle, 0.0));
}

/**
 * Rotate around the X axis (pitch/look up-down).
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.identity
 *   |> transform.rotate_x(0.5)  // Look up slightly
 * ```
 */
export function rotate_x(transform, angle) {
  return rotate_by(transform, new $vec3.Vec3(angle, 0.0, 0.0));
}

/**
 * Rotate around the Z axis (roll/tilt left-right).
 *
 * ## Example
 *
 * ```gleam
 * let t = transform.identity
 *   |> transform.rotate_z(0.3)  // Tilt right
 * ```
 */
export function rotate_z(transform, angle) {
  return rotate_by(transform, new $vec3.Vec3(0.0, 0.0, angle));
}

/**
 * Create a billboard transform that makes a sprite face a target.
 *
 * The `mode` parameter controls how the billboard rotates:
 * - `Spherical`: Full 3D rotation to always face the target
 * - `Cylindrical`: Only Y-axis rotation (stays upright)
 * - `SphericalNoRoll`: X and Y rotation but no Z roll
 *
 * ## Example
 *
 * ```gleam
 * let sprite_pos = vec3.Vec3(5.0, 0.0, 0.0)
 * let camera_pos = vec3.Vec3(0.0, 5.0, 10.0)
 * let t = transform.billboard(sprite_pos, camera_pos, Cylindrical)
 * // Sprite faces camera horizontally but stays upright
 * ```
 */
export function billboard(position, target, mode) {
  let dx = target.x - position.x;
  let dy = target.y - position.y;
  let dz = target.z - position.z;
  let _block;
  if (mode instanceof Spherical) {
    let direction = $vec3f.subtract(target, position);
    _block = $quaternion.from_to_rotation(
      new $vec3.Vec3(0.0, 0.0, 1.0),
      direction,
    );
  } else if (mode instanceof Cylindrical) {
    let angle_y = $maths.atan2(dx, dz) + $maths.pi();
    _block = $quaternion.from_axis_angle(new $vec3.Vec3(0.0, 1.0, 0.0), angle_y);
  } else {
    let angle_y = $maths.atan2(dx, dz) + $maths.pi();
    let _block$1;
    let $ = $float.square_root((dx * dx) + (dz * dz));
    if ($ instanceof Ok) {
      let d = $[0];
      _block$1 = d;
    } else {
      _block$1 = 0.0;
    }
    let horizontal_dist = _block$1;
    let angle_x = $maths.atan2(dy, horizontal_dist);
    let quat_y = $quaternion.from_axis_angle(
      new $vec3.Vec3(0.0, 1.0, 0.0),
      angle_y,
    );
    let quat_x = $quaternion.from_axis_angle(
      new $vec3.Vec3(1.0, 0.0, 0.0),
      angle_x,
    );
    _block = $quaternion.multiply(quat_y, quat_x);
  }
  let quat = _block;
  return new Transform(position, quat, $vec3f.one);
}
