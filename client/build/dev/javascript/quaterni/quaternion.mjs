import * as $maths from "../gleam_community_maths/gleam_community/maths.mjs";
import * as $float from "../gleam_stdlib/gleam/float.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import * as $vec3 from "../vec/vec/vec3.mjs";
import * as $vec3f from "../vec/vec/vec3f.mjs";
import { Ok, Error, CustomType as $CustomType, divideFloat } from "./gleam.mjs";

export class Quaternion extends $CustomType {
  constructor(x, y, z, w) {
    super();
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
  }
}
export const Quaternion$Quaternion = (x, y, z, w) => new Quaternion(x, y, z, w);
export const Quaternion$isQuaternion = (value) => value instanceof Quaternion;
export const Quaternion$Quaternion$x = (value) => value.x;
export const Quaternion$Quaternion$0 = (value) => value.x;
export const Quaternion$Quaternion$y = (value) => value.y;
export const Quaternion$Quaternion$1 = (value) => value.y;
export const Quaternion$Quaternion$z = (value) => value.z;
export const Quaternion$Quaternion$2 = (value) => value.z;
export const Quaternion$Quaternion$w = (value) => value.w;
export const Quaternion$Quaternion$3 = (value) => value.w;

/**
 * Identity quaternion (no rotation).
 */
export const identity = /* @__PURE__ */ new Quaternion(0.0, 0.0, 0.0, 1.0);

/**
 * Create a quaternion from axis-angle representation.
 *
 * ## Parameters
 * - `axis`: The rotation axis
 * - `angle`: The rotation angle in radians
 *
 * ## Example
 * ```gleam
 * // 90 degree rotation around Y axis
 * let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)
 * ```
 */
export function from_axis_angle(axis, angle) {
  let axis$1 = $vec3f.normalize(axis);
  let half_angle = angle / 2.0;
  let s = $maths.sin(half_angle);
  return new Quaternion(
    axis$1.x * s,
    axis$1.y * s,
    axis$1.z * s,
    $maths.cos(half_angle),
  );
}

/**
 * Convert Euler angles (radians) to quaternion using XYZ rotation order.
 *
 * ## Example
 * ```gleam
 * // Rotate 90 degrees around Y axis
 * let rotation = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))
 * ```
 */
export function from_euler(euler) {
  let c1 = $maths.cos(euler.x / 2.0);
  let c2 = $maths.cos(euler.y / 2.0);
  let c3 = $maths.cos(euler.z / 2.0);
  let s1 = $maths.sin(euler.x / 2.0);
  let s2 = $maths.sin(euler.y / 2.0);
  let s3 = $maths.sin(euler.z / 2.0);
  return new Quaternion(
    ((s1 * c2) * c3) + ((c1 * s2) * s3),
    ((c1 * s2) * c3) - ((s1 * c2) * s3),
    ((c1 * c2) * s3) + ((s1 * s2) * c3),
    ((c1 * c2) * c3) - ((s1 * s2) * s3),
  );
}

/**
 * Convert quaternion to Euler angles (radians) using XYZ rotation order.
 *
 * Returns Vec3(roll, pitch, yaw).
 */
export function to_euler(quat) {
  let sinr_cosp = 2.0 * ((quat.w * quat.x) + (quat.y * quat.z));
  let cosr_cosp = 1.0 - (2.0 * ((quat.x * quat.x) + (quat.y * quat.y)));
  let roll = $maths.atan2(sinr_cosp, cosr_cosp);
  let sinp = 2.0 * ((quat.w * quat.y) - (quat.z * quat.x));
  let _block;
  let $ = sinp >= 1.0;
  if ($) {
    _block = $maths.pi() / 2.0;
  } else {
    let $1 = sinp <= -1.0;
    if ($1) {
      _block = 0.0 - ($maths.pi() / 2.0);
    } else {
      let _pipe = $maths.asin(sinp);
      _block = $result.unwrap(_pipe, 0.0);
    }
  }
  let pitch = _block;
  let siny_cosp = 2.0 * ((quat.w * quat.z) + (quat.x * quat.y));
  let cosy_cosp = 1.0 - (2.0 * ((quat.y * quat.y) + (quat.z * quat.z)));
  let yaw = $maths.atan2(siny_cosp, cosy_cosp);
  return new $vec3.Vec3(roll, pitch, yaw);
}

/**
 * Multiply two quaternions (q1 * q2).
 *
 * Represents the combined rotation of applying q1 then q2.
 *
 * ## Example
 * ```gleam
 * let rotate_y = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)
 * let rotate_x = q.from_axis_angle(vec3.Vec3(1.0, 0.0, 0.0), 0.5)
 * let combined = q.multiply(rotate_y, rotate_x)
 * ```
 */
export function multiply(q1, q2) {
  return new Quaternion(
    (((q1.w * q2.x) + (q1.x * q2.w)) + (q1.y * q2.z)) - (q1.z * q2.y),
    (((q1.w * q2.y) - (q1.x * q2.z)) + (q1.y * q2.w)) + (q1.z * q2.x),
    (((q1.w * q2.z) + (q1.x * q2.y)) - (q1.y * q2.x)) + (q1.z * q2.w),
    (((q1.w * q2.w) - (q1.x * q2.x)) - (q1.y * q2.y)) - (q1.z * q2.z),
  );
}

/**
 * Compute the conjugate of a quaternion.
 *
 * The conjugate represents the inverse rotation.
 */
export function conjugate(quat) {
  return new Quaternion(0.0 - quat.x, 0.0 - quat.y, 0.0 - quat.z, quat.w);
}

/**
 * Compute the dot product of two quaternions.
 */
export function dot(q1, q2) {
  return (((q1.x * q2.x) + (q1.y * q2.y)) + (q1.z * q2.z)) + (q1.w * q2.w);
}

/**
 * Rotate a vector by a quaternion.
 *
 * ## Example
 * ```gleam
 * let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)
 * let point = vec3.Vec3(1.0, 0.0, 0.0)
 * let rotated = q.rotate(rotation, point)  // ~Vec3(0.0, 0.0, -1.0)
 * ```
 */
export function rotate(quat, v) {
  let qx = quat.x;
  let qy = quat.y;
  let qz = quat.z;
  let qw = quat.w;
  let ix = ((qw * v.x) + (qy * v.z)) - (qz * v.y);
  let iy = ((qw * v.y) + (qz * v.x)) - (qx * v.z);
  let iz = ((qw * v.z) + (qx * v.y)) - (qy * v.x);
  let iw = ((0.0 - (qx * v.x)) - (qy * v.y)) - (qz * v.z);
  return new $vec3.Vec3(
    (((ix * qw) + (iw * (0.0 - qx))) + (iy * (0.0 - qz))) - (iz * (0.0 - qy)),
    (((iy * qw) + (iw * (0.0 - qy))) + (iz * (0.0 - qx))) - (ix * (0.0 - qz)),
    (((iz * qw) + (iw * (0.0 - qz))) + (ix * (0.0 - qy))) - (iy * (0.0 - qx)),
  );
}

/**
 * Get the rotation angle in radians.
 */
export function angle(quat) {
  return 2.0 * (() => {
    let _pipe = $maths.acos($float.clamp(quat.w, -1.0, 1.0));
    return $result.unwrap(_pipe, 0.0);
  })();
}

/**
 * Get the rotation axis.
 *
 * Returns Error if the quaternion represents no rotation (identity).
 */
export function axis(quat) {
  let s_squared = 1.0 - (quat.w * quat.w);
  let $ = s_squared < 0.0001;
  if ($) {
    return new Error(undefined);
  } else {
    let _block;
    let $1 = $float.square_root(s_squared);
    if ($1 instanceof Ok) {
      let val = $1[0];
      _block = val;
    } else {
      _block = 0.0;
    }
    let s = _block;
    return new Ok(
      new $vec3.Vec3(
        divideFloat(quat.x, s),
        divideFloat(quat.y, s),
        divideFloat(quat.z, s),
      ),
    );
  }
}

/**
 * Check if two quaternions are approximately equal within a tolerance.
 *
 * Useful for floating-point comparisons where exact equality is problematic.
 * Note: Quaternions q and -q represent the same rotation, so this function
 * checks both orientations.
 *
 * ## Parameters
 * - `q1`: First quaternion
 * - `q2`: Second quaternion
 * - `epsilon`: Tolerance for comparison (typically 0.0001 to 0.001)
 *
 * ## Example
 * ```gleam
 * let q1 = from_euler(Vec3(0.0, 1.57, 0.0))
 * let q2 = from_euler(Vec3(0.0, 1.57001, 0.0))
 * loosely_equals(q1, q2, epsilon: 0.001)  // True
 * ```
 */
export function loosely_equals(q1, q2, epsilon) {
  let same_orientation = ((($float.absolute_value(q1.x - q2.x) < epsilon) && ($float.absolute_value(
    q1.y - q2.y,
  ) < epsilon)) && ($float.absolute_value(q1.z - q2.z) < epsilon)) && ($float.absolute_value(
    q1.w - q2.w,
  ) < epsilon);
  let opposite_orientation = ((($float.absolute_value(q1.x + q2.x) < epsilon) && ($float.absolute_value(
    q1.y + q2.y,
  ) < epsilon)) && ($float.absolute_value(q1.z + q2.z) < epsilon)) && ($float.absolute_value(
    q1.w + q2.w,
  ) < epsilon);
  return same_orientation || opposite_orientation;
}

/**
 * Normalize a quaternion to unit length.
 *
 * All rotation quaternions should be normalized.
 */
export function normalize(quat) {
  let mag = $float.square_root(
    (((quat.x * quat.x) + (quat.y * quat.y)) + (quat.z * quat.z)) + (quat.w * quat.w),
  );
  if (mag instanceof Ok) {
    let m = mag[0];
    if (m > 0.0001) {
      return new Quaternion(
        divideFloat(quat.x, m),
        divideFloat(quat.y, m),
        divideFloat(quat.z, m),
        divideFloat(quat.w, m),
      );
    } else {
      return identity;
    }
  } else {
    return identity;
  }
}

/**
 * Create a quaternion that rotates from one direction to another.
 */
export function from_to_rotation(from, to) {
  let from$1 = $vec3f.normalize(from);
  let to$1 = $vec3f.normalize(to);
  let dot_val = $vec3f.dot(from$1, to$1);
  let $ = dot_val > 0.999999;
  if ($) {
    return identity;
  } else {
    let $1 = dot_val < -0.999999;
    if ($1) {
      let _block;
      let $2 = $float.absolute_value(from$1.x) < 0.99;
      if ($2) {
        _block = $vec3f.normalize(
          $vec3f.cross(new $vec3.Vec3(1.0, 0.0, 0.0), from$1),
        );
      } else {
        _block = $vec3f.normalize(
          $vec3f.cross(new $vec3.Vec3(0.0, 1.0, 0.0), from$1),
        );
      }
      let axis$1 = _block;
      return from_axis_angle(axis$1, $maths.pi());
    } else {
      let axis$1 = $vec3f.cross(from$1, to$1);
      let _pipe = new Quaternion(axis$1.x, axis$1.y, axis$1.z, 1.0 + dot_val);
      return normalize(_pipe);
    }
  }
}

/**
 * Compute the inverse of a quaternion.
 *
 * For unit quaternions (normalized), this is equivalent to the conjugate.
 */
export function inverse(quat) {
  let norm_sq = (((quat.x * quat.x) + (quat.y * quat.y)) + (quat.z * quat.z)) + (quat.w * quat.w);
  let $ = norm_sq > 0.0001;
  if ($) {
    let conj = conjugate(quat);
    return new Quaternion(
      divideFloat(conj.x, norm_sq),
      divideFloat(conj.y, norm_sq),
      divideFloat(conj.z, norm_sq),
      divideFloat(conj.w, norm_sq),
    );
  } else {
    return identity;
  }
}

/**
 * Spherical linear interpolation (slerp) between two quaternions.
 *
 * Provides smooth rotation interpolation without gimbal lock issues.
 *
 * ## Parameters
 * - `from`: Starting quaternion
 * - `to`: Target quaternion
 * - `t`: Interpolation factor (0.0 = from, 1.0 = to)
 *
 * ## Example
 * ```gleam
 * let start = q.from_euler(vec3.Vec3(0.0, 0.0, 0.0))
 * let end = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))
 * let halfway = q.slerp(from: start, to: end, t: 0.5)
 * ```
 */
export function spherical_linear_interpolation(from, to, t) {
  let dot_prod = dot(from, to);
  let _block;
  let $1 = dot_prod < 0.0;
  if ($1) {
    _block = [
      new Quaternion(0.0 - to.x, 0.0 - to.y, 0.0 - to.z, 0.0 - to.w),
      0.0 - dot_prod,
    ];
  } else {
    _block = [to, dot_prod];
  }
  let $ = _block;
  let to$1;
  let dot_prod$1;
  to$1 = $[0];
  dot_prod$1 = $[1];
  let $2 = dot_prod$1 > 0.9995;
  if ($2) {
    let _pipe = new Quaternion(
      from.x + ((to$1.x - from.x) * t),
      from.y + ((to$1.y - from.y) * t),
      from.z + ((to$1.z - from.z) * t),
      from.w + ((to$1.w - from.w) * t),
    );
    return normalize(_pipe);
  } else {
    let dot_clamped = $float.clamp(dot_prod$1, -1.0, 1.0);
    let _block$1;
    let _pipe = $maths.acos(dot_clamped);
    _block$1 = $result.unwrap(_pipe, 0.0);
    let theta_0 = _block$1;
    let theta = theta_0 * t;
    let sin_theta = $maths.sin(theta);
    let sin_theta_0 = $maths.sin(theta_0);
    let s1 = $maths.cos(theta) - (divideFloat(
      (dot_clamped * sin_theta),
      sin_theta_0
    ));
    let s2 = divideFloat(sin_theta, sin_theta_0);
    return new Quaternion(
      (from.x * s1) + (to$1.x * s2),
      (from.y * s1) + (to$1.y * s2),
      (from.z * s1) + (to$1.z * s2),
      (from.w * s1) + (to$1.w * s2),
    );
  }
}

/**
 * Linear interpolation between two quaternions.
 *
 * Faster than slerp but doesn't maintain constant angular velocity.
 * Result should be normalized.
 */
export function linear_interpolation(from, to, t) {
  let _pipe = new Quaternion(
    from.x + ((to.x - from.x) * t),
    from.y + ((to.y - from.y) * t),
    from.z + ((to.z - from.z) * t),
    from.w + ((to.w - from.w) * t),
  );
  return normalize(_pipe);
}

/**
 * Convert a 3x3 rotation matrix to quaternion using Shepperd's method.
 * 
 * @ignore
 */
function matrix_to_quaternion(m00, m01, m02, m10, m11, m12, m20, m21, m22) {
  let trace = (m00 + m11) + m22;
  let $ = trace > 0.0;
  if ($) {
    let _block;
    let _pipe = $float.square_root(trace + 1.0);
    _block = $result.unwrap(_pipe, 1.0);
    let s = _block;
    let w = s / 2.0;
    let s$1 = divideFloat(0.5, s);
    let _pipe$1 = new Quaternion(
      (m21 - m12) * s$1,
      (m02 - m20) * s$1,
      (m10 - m01) * s$1,
      w,
    );
    return normalize(_pipe$1);
  } else {
    let $1 = (m00 > m11) && (m00 > m22);
    if ($1) {
      let _block;
      let _pipe = $float.square_root(((1.0 + m00) - m11) - m22);
      _block = $result.unwrap(_pipe, 1.0);
      let s = _block;
      let x = s / 2.0;
      let s$1 = divideFloat(0.5, s);
      let _pipe$1 = new Quaternion(
        x,
        (m01 + m10) * s$1,
        (m02 + m20) * s$1,
        (m21 - m12) * s$1,
      );
      return normalize(_pipe$1);
    } else {
      let $2 = m11 > m22;
      if ($2) {
        let _block;
        let _pipe = $float.square_root(((1.0 + m11) - m00) - m22);
        _block = $result.unwrap(_pipe, 1.0);
        let s = _block;
        let y = s / 2.0;
        let s$1 = divideFloat(0.5, s);
        let _pipe$1 = new Quaternion(
          (m01 + m10) * s$1,
          y,
          (m12 + m21) * s$1,
          (m02 - m20) * s$1,
        );
        return normalize(_pipe$1);
      } else {
        let _block;
        let _pipe = $float.square_root(((1.0 + m22) - m00) - m11);
        _block = $result.unwrap(_pipe, 1.0);
        let s = _block;
        let z = s / 2.0;
        let s$1 = divideFloat(0.5, s);
        let _pipe$1 = new Quaternion(
          (m02 + m20) * s$1,
          (m12 + m21) * s$1,
          z,
          (m10 - m01) * s$1,
        );
        return normalize(_pipe$1);
      }
    }
  }
}

/**
 * Internal helper: compute quaternion for looking at a direction with given up vector.
 * Assumes the default forward is -Z.
 * 
 * @ignore
 */
function look_at_direction(direction, up) {
  let dir_norm = $vec3f.normalize(direction);
  let up_norm = $vec3f.normalize(up);
  let right = $vec3f.normalize($vec3f.cross(dir_norm, up_norm));
  let new_up = $vec3f.cross(right, dir_norm);
  let m00 = right.x;
  let m10 = right.y;
  let m20 = right.z;
  let m01 = new_up.x;
  let m11 = new_up.y;
  let m21 = new_up.z;
  let m02 = 0.0 - dir_norm.x;
  let m12 = 0.0 - dir_norm.y;
  let m22 = 0.0 - dir_norm.z;
  return matrix_to_quaternion(m00, m01, m02, m10, m11, m12, m20, m21, m22);
}

/**
 * Create a quaternion that looks from one direction toward a target direction.
 *
 * Creates a rotation that orients the `forward` direction to point toward the `target` direction,
 * with the given `up` vector for orientation. Useful for cameras and billboards.
 *
 * ## Parameters
 * - `forward`: The current forward direction (usually Vec3(0.0, 0.0, -1.0) for cameras)
 * - `target`: The direction to look toward  
 * - `up`: The up vector for orientation (usually Vec3(0.0, 1.0, 0.0))
 *
 * ## Example
 * ```gleam
 * // Make camera look at target from position
 * let camera_pos = Vec3(10.0, 10.0, 10.0)
 * let target_pos = Vec3(0.0, 0.0, 0.0)
 * let direction = vec3f.normalize(vec3f.subtract(target_pos, camera_pos))
 * let quat = look_at(Vec3(0.0, 0.0, -1.0), direction, Vec3(0.0, 1.0, 0.0))
 * ```
 */
export function look_at(forward, target, up) {
  let q_target = look_at_direction(target, up);
  let q_forward = look_at_direction(forward, up);
  return multiply(q_target, inverse(q_forward));
}
