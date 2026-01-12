//// Pure Gleam quaternion math library for 3D rotations.
////
//// Quaternions are a mathematical representation of rotations in 3D space that:
//// - Avoid gimbal lock
//// - Provide smooth interpolation (slerp)
//// - Are more compact than rotation matrices
//// - Compose efficiently
////
//// ## Quick Start
////
//// ```gleam
//// import q
//// import vec/vec3
////
//// // Create quaternion from axis-angle
//// let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)
////
//// // Or from Euler angles
//// let rotation = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))
////
//// // Rotate a vector
//// let rotated = q.rotate(rotation, vec3.Vec3(1.0, 0.0, 0.0))
////
//// // Interpolate between rotations
//// let halfway = q.slerp(from: rot1, to: rot2, t: 0.5)
//// ```

import gleam/float
import gleam/result
import gleam_community/maths
import vec/vec3.{type Vec3}
import vec/vec3f

/// Quaternion represents a rotation in 3D space.
///
/// Quaternions use four components (x, y, z, w) where:
/// - (x, y, z) represents the rotation axis scaled by sin(angle/2)
/// - w represents cos(angle/2)
pub type Quaternion {
  Quaternion(x: Float, y: Float, z: Float, w: Float)
}

// --- Constants ---

/// Identity quaternion (no rotation).
pub const identity = Quaternion(0.0, 0.0, 0.0, 1.0)

// --- Creation ---

/// Create a quaternion from axis-angle representation.
///
/// ## Parameters
/// - `axis`: The rotation axis
/// - `angle`: The rotation angle in radians
///
/// ## Example
/// ```gleam
/// // 90 degree rotation around Y axis
/// let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)
/// ```
pub fn from_axis_angle(axis: Vec3(Float), angle: Float) -> Quaternion {
  let axis = vec3f.normalize(axis)
  let half_angle = angle /. 2.0
  let s = maths.sin(half_angle)

  Quaternion(
    x: axis.x *. s,
    y: axis.y *. s,
    z: axis.z *. s,
    w: maths.cos(half_angle),
  )
}

/// Convert Euler angles (radians) to quaternion using XYZ rotation order.
///
/// ## Example
/// ```gleam
/// // Rotate 90 degrees around Y axis
/// let rotation = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))
/// ```
pub fn from_euler(euler: Vec3(Float)) -> Quaternion {
  let c1 = maths.cos(euler.x /. 2.0)
  let c2 = maths.cos(euler.y /. 2.0)
  let c3 = maths.cos(euler.z /. 2.0)
  let s1 = maths.sin(euler.x /. 2.0)
  let s2 = maths.sin(euler.y /. 2.0)
  let s3 = maths.sin(euler.z /. 2.0)

  // XYZ rotation order
  Quaternion(
    x: s1 *. c2 *. c3 +. c1 *. s2 *. s3,
    y: c1 *. s2 *. c3 -. s1 *. c2 *. s3,
    z: c1 *. c2 *. s3 +. s1 *. s2 *. c3,
    w: c1 *. c2 *. c3 -. s1 *. s2 *. s3,
  )
}

/// Convert quaternion to Euler angles (radians) using XYZ rotation order.
///
/// Returns Vec3(roll, pitch, yaw).
pub fn to_euler(quat: Quaternion) -> Vec3(Float) {
  // Roll (x-axis rotation)
  let sinr_cosp = 2.0 *. { quat.w *. quat.x +. quat.y *. quat.z }
  let cosr_cosp = 1.0 -. 2.0 *. { quat.x *. quat.x +. quat.y *. quat.y }
  let roll = maths.atan2(sinr_cosp, cosr_cosp)

  // Pitch (y-axis rotation)
  let sinp = 2.0 *. { quat.w *. quat.y -. quat.z *. quat.x }
  let pitch = case sinp >=. 1.0 {
    True -> maths.pi() /. 2.0
    False ->
      case sinp <=. -1.0 {
        True -> 0.0 -. maths.pi() /. 2.0
        False -> maths.asin(sinp) |> result.unwrap(0.0)
      }
  }

  // Yaw (z-axis rotation)
  let siny_cosp = 2.0 *. { quat.w *. quat.z +. quat.x *. quat.y }
  let cosy_cosp = 1.0 -. 2.0 *. { quat.y *. quat.y +. quat.z *. quat.z }
  let yaw = maths.atan2(siny_cosp, cosy_cosp)

  vec3.Vec3(roll, pitch, yaw)
}

/// Create a quaternion that rotates from one direction to another.
pub fn from_to_rotation(from: Vec3(Float), to: Vec3(Float)) -> Quaternion {
  let from = vec3f.normalize(from)
  let to = vec3f.normalize(to)
  let dot_val = vec3f.dot(from, to)

  // Vectors are nearly parallel
  case dot_val >. 0.999999 {
    True -> identity
    False ->
      case dot_val <. -0.999999 {
        // Vectors are nearly opposite - rotate 180 degrees around any perpendicular axis
        True -> {
          let axis = case float.absolute_value(from.x) <. 0.99 {
            True -> vec3f.normalize(vec3f.cross(vec3.Vec3(1.0, 0.0, 0.0), from))
            False ->
              vec3f.normalize(vec3f.cross(vec3.Vec3(0.0, 1.0, 0.0), from))
          }
          from_axis_angle(axis, maths.pi())
        }
        False -> {
          let axis = vec3f.cross(from, to)
          Quaternion(x: axis.x, y: axis.y, z: axis.z, w: 1.0 +. dot_val)
          |> normalize
        }
      }
  }
}

// --- Operations ---

/// Multiply two quaternions (q1 * q2).
///
/// Represents the combined rotation of applying q1 then q2.
///
/// ## Example
/// ```gleam
/// let rotate_y = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)
/// let rotate_x = q.from_axis_angle(vec3.Vec3(1.0, 0.0, 0.0), 0.5)
/// let combined = q.multiply(rotate_y, rotate_x)
/// ```
pub fn multiply(q1: Quaternion, q2: Quaternion) -> Quaternion {
  Quaternion(
    x: q1.w *. q2.x +. q1.x *. q2.w +. q1.y *. q2.z -. q1.z *. q2.y,
    y: q1.w *. q2.y -. q1.x *. q2.z +. q1.y *. q2.w +. q1.z *. q2.x,
    z: q1.w *. q2.z +. q1.x *. q2.y -. q1.y *. q2.x +. q1.z *. q2.w,
    w: q1.w *. q2.w -. q1.x *. q2.x -. q1.y *. q2.y -. q1.z *. q2.z,
  )
}

/// Normalize a quaternion to unit length.
///
/// All rotation quaternions should be normalized.
pub fn normalize(quat: Quaternion) -> Quaternion {
  let mag =
    float.square_root(
      quat.x
      *. quat.x
      +. quat.y
      *. quat.y
      +. quat.z
      *. quat.z
      +. quat.w
      *. quat.w,
    )

  case mag {
    Ok(m) if m >. 0.0001 -> {
      Quaternion(x: quat.x /. m, y: quat.y /. m, z: quat.z /. m, w: quat.w /. m)
    }
    _ -> identity
  }
}

/// Compute the conjugate of a quaternion.
///
/// The conjugate represents the inverse rotation.
pub fn conjugate(quat: Quaternion) -> Quaternion {
  Quaternion(x: 0.0 -. quat.x, y: 0.0 -. quat.y, z: 0.0 -. quat.z, w: quat.w)
}

/// Compute the inverse of a quaternion.
///
/// For unit quaternions (normalized), this is equivalent to the conjugate.
pub fn inverse(quat: Quaternion) -> Quaternion {
  let norm_sq =
    quat.x *. quat.x +. quat.y *. quat.y +. quat.z *. quat.z +. quat.w *. quat.w
  case norm_sq >. 0.0001 {
    True -> {
      let conj = conjugate(quat)
      Quaternion(
        x: conj.x /. norm_sq,
        y: conj.y /. norm_sq,
        z: conj.z /. norm_sq,
        w: conj.w /. norm_sq,
      )
    }
    False -> identity
  }
}

/// Compute the dot product of two quaternions.
pub fn dot(q1: Quaternion, q2: Quaternion) -> Float {
  q1.x *. q2.x +. q1.y *. q2.y +. q1.z *. q2.z +. q1.w *. q2.w
}

// --- Interpolation ---

/// Spherical linear interpolation (slerp) between two quaternions.
///
/// Provides smooth rotation interpolation without gimbal lock issues.
///
/// ## Parameters
/// - `from`: Starting quaternion
/// - `to`: Target quaternion
/// - `t`: Interpolation factor (0.0 = from, 1.0 = to)
///
/// ## Example
/// ```gleam
/// let start = q.from_euler(vec3.Vec3(0.0, 0.0, 0.0))
/// let end = q.from_euler(vec3.Vec3(0.0, 1.57, 0.0))
/// let halfway = q.slerp(from: start, to: end, t: 0.5)
/// ```
pub fn spherical_linear_interpolation(
  from from: Quaternion,
  to to: Quaternion,
  t t: Float,
) -> Quaternion {
  // Compute dot product
  let dot_prod = dot(from, to)

  // If dot product is negative, negate to to take shorter path
  let #(to, dot_prod) = case dot_prod <. 0.0 {
    True -> #(
      Quaternion(0.0 -. to.x, 0.0 -. to.y, 0.0 -. to.z, 0.0 -. to.w),
      0.0 -. dot_prod,
    )
    False -> #(to, dot_prod)
  }

  // If quaternions are very close, use linear interpolation
  case dot_prod >. 0.9995 {
    True -> {
      Quaternion(
        x: from.x +. { to.x -. from.x } *. t,
        y: from.y +. { to.y -. from.y } *. t,
        z: from.z +. { to.z -. from.z } *. t,
        w: from.w +. { to.w -. from.w } *. t,
      )
      |> normalize
    }
    False -> {
      // Clamp dot to avoid numerical issues with acos
      let dot_clamped = float.clamp(dot_prod, -1.0, 1.0)
      let theta_0 = maths.acos(dot_clamped) |> result.unwrap(0.0)
      let theta = theta_0 *. t
      let sin_theta = maths.sin(theta)
      let sin_theta_0 = maths.sin(theta_0)

      let s1 = maths.cos(theta) -. dot_clamped *. sin_theta /. sin_theta_0
      let s2 = sin_theta /. sin_theta_0

      Quaternion(
        x: from.x *. s1 +. to.x *. s2,
        y: from.y *. s1 +. to.y *. s2,
        z: from.z *. s1 +. to.z *. s2,
        w: from.w *. s1 +. to.w *. s2,
      )
    }
  }
}

/// Linear interpolation between two quaternions.
///
/// Faster than slerp but doesn't maintain constant angular velocity.
/// Result should be normalized.
pub fn linear_interpolation(
  from from: Quaternion,
  to to: Quaternion,
  t t: Float,
) -> Quaternion {
  Quaternion(
    x: from.x +. { to.x -. from.x } *. t,
    y: from.y +. { to.y -. from.y } *. t,
    z: from.z +. { to.z -. from.z } *. t,
    w: from.w +. { to.w -. from.w } *. t,
  )
  |> normalize
}

// --- Vector Rotation ---

/// Rotate a vector by a quaternion.
///
/// ## Example
/// ```gleam
/// let rotation = q.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)
/// let point = vec3.Vec3(1.0, 0.0, 0.0)
/// let rotated = q.rotate(rotation, point)  // ~Vec3(0.0, 0.0, -1.0)
/// ```
pub fn rotate(quat: Quaternion, v: Vec3(Float)) -> Vec3(Float) {
  // Optimized quaternion rotation: v' = q * v * q^-1
  let qx = quat.x
  let qy = quat.y
  let qz = quat.z
  let qw = quat.w

  // Calculate quat * vector
  let ix = qw *. v.x +. qy *. v.z -. qz *. v.y
  let iy = qw *. v.y +. qz *. v.x -. qx *. v.z
  let iz = qw *. v.z +. qx *. v.y -. qy *. v.x
  let iw = 0.0 -. qx *. v.x -. qy *. v.y -. qz *. v.z

  // Calculate result * inverse quat
  vec3.Vec3(
    ix
      *. qw
      +. iw
      *. { 0.0 -. qx }
      +. iy
      *. { 0.0 -. qz }
      -. iz
      *. { 0.0 -. qy },
    iy
      *. qw
      +. iw
      *. { 0.0 -. qy }
      +. iz
      *. { 0.0 -. qx }
      -. ix
      *. { 0.0 -. qz },
    iz
      *. qw
      +. iw
      *. { 0.0 -. qz }
      +. ix
      *. { 0.0 -. qy }
      -. iy
      *. { 0.0 -. qx },
  )
}

// --- Queries ---

/// Get the rotation angle in radians.
pub fn angle(quat: Quaternion) -> Float {
  2.0 *. { maths.acos(float.clamp(quat.w, -1.0, 1.0)) |> result.unwrap(0.0) }
}

/// Get the rotation axis.
///
/// Returns Error if the quaternion represents no rotation (identity).
pub fn axis(quat: Quaternion) -> Result(Vec3(Float), Nil) {
  let s_squared = 1.0 -. quat.w *. quat.w
  case s_squared <. 0.0001 {
    True -> Error(Nil)
    False -> {
      let s = case float.square_root(s_squared) {
        Ok(val) -> val
        Error(_) -> 0.0
      }
      Ok(vec3.Vec3(quat.x /. s, quat.y /. s, quat.z /. s))
    }
  }
}

/// Create a quaternion that looks from one direction toward a target direction.
///
/// Creates a rotation that orients the `forward` direction to point toward the `target` direction,
/// with the given `up` vector for orientation. Useful for cameras and billboards.
///
/// ## Parameters
/// - `forward`: The current forward direction (usually Vec3(0.0, 0.0, -1.0) for cameras)
/// - `target`: The direction to look toward  
/// - `up`: The up vector for orientation (usually Vec3(0.0, 1.0, 0.0))
///
/// ## Example
/// ```gleam
/// // Make camera look at target from position
/// let camera_pos = Vec3(10.0, 10.0, 10.0)
/// let target_pos = Vec3(0.0, 0.0, 0.0)
/// let direction = vec3f.normalize(vec3f.subtract(target_pos, camera_pos))
/// let quat = look_at(Vec3(0.0, 0.0, -1.0), direction, Vec3(0.0, 1.0, 0.0))
/// ```
pub fn look_at(
  forward forward: Vec3(Float),
  target target: Vec3(Float),
  up up: Vec3(Float),
) -> Quaternion {
  // Compute rotation that aligns `forward` with `target`, preserving `up`
  // Final = Q_target * inverse(Q_forward)
  let q_target = look_at_direction(target, up)
  let q_forward = look_at_direction(forward, up)
  multiply(q_target, inverse(q_forward))
}

/// Internal helper: compute quaternion for looking at a direction with given up vector.
/// Assumes the default forward is -Z.
fn look_at_direction(direction: Vec3(Float), up: Vec3(Float)) -> Quaternion {
  let dir_norm = vec3f.normalize(direction)
  let up_norm = vec3f.normalize(up)

  // Build orthonormal basis (right-handed coordinate system)
  let right = vec3f.normalize(vec3f.cross(dir_norm, up_norm))
  let new_up = vec3f.cross(right, dir_norm)

  // Build rotation matrix from basis vectors (column-major)
  // Column 0: right, Column 1: up, Column 2: -forward
  let m00 = right.x
  let m10 = right.y
  let m20 = right.z
  let m01 = new_up.x
  let m11 = new_up.y
  let m21 = new_up.z
  let m02 = 0.0 -. dir_norm.x
  let m12 = 0.0 -. dir_norm.y
  let m22 = 0.0 -. dir_norm.z

  matrix_to_quaternion(m00, m01, m02, m10, m11, m12, m20, m21, m22)
}

/// Convert a 3x3 rotation matrix to quaternion using Shepperd's method.
fn matrix_to_quaternion(
  m00: Float,
  m01: Float,
  m02: Float,
  m10: Float,
  m11: Float,
  m12: Float,
  m20: Float,
  m21: Float,
  m22: Float,
) -> Quaternion {
  let trace = m00 +. m11 +. m22

  case trace >. 0.0 {
    True -> {
      let s = float.square_root(trace +. 1.0) |> result.unwrap(1.0)
      let w = s /. 2.0
      let s = 0.5 /. s
      Quaternion(
        x: { m21 -. m12 } *. s,
        y: { m02 -. m20 } *. s,
        z: { m10 -. m01 } *. s,
        w: w,
      )
      |> normalize
    }
    False -> {
      case m00 >. m11 && m00 >. m22 {
        True -> {
          let s =
            float.square_root(1.0 +. m00 -. m11 -. m22)
            |> result.unwrap(1.0)
          let x = s /. 2.0
          let s = 0.5 /. s
          Quaternion(
            x: x,
            y: { m01 +. m10 } *. s,
            z: { m02 +. m20 } *. s,
            w: { m21 -. m12 } *. s,
          )
          |> normalize
        }
        False ->
          case m11 >. m22 {
            True -> {
              let s =
                float.square_root(1.0 +. m11 -. m00 -. m22)
                |> result.unwrap(1.0)
              let y = s /. 2.0
              let s = 0.5 /. s
              Quaternion(
                x: { m01 +. m10 } *. s,
                y: y,
                z: { m12 +. m21 } *. s,
                w: { m02 -. m20 } *. s,
              )
              |> normalize
            }
            False -> {
              let s =
                float.square_root(1.0 +. m22 -. m00 -. m11)
                |> result.unwrap(1.0)
              let z = s /. 2.0
              let s = 0.5 /. s
              Quaternion(
                x: { m02 +. m20 } *. s,
                y: { m12 +. m21 } *. s,
                z: z,
                w: { m10 -. m01 } *. s,
              )
              |> normalize
            }
          }
      }
    }
  }
}

/// Check if two quaternions are approximately equal within a tolerance.
///
/// Useful for floating-point comparisons where exact equality is problematic.
/// Note: Quaternions q and -q represent the same rotation, so this function
/// checks both orientations.
///
/// ## Parameters
/// - `q1`: First quaternion
/// - `q2`: Second quaternion
/// - `epsilon`: Tolerance for comparison (typically 0.0001 to 0.001)
///
/// ## Example
/// ```gleam
/// let q1 = from_euler(Vec3(0.0, 1.57, 0.0))
/// let q2 = from_euler(Vec3(0.0, 1.57001, 0.0))
/// loosely_equals(q1, q2, epsilon: 0.001)  // True
/// ```
pub fn loosely_equals(
  q1: Quaternion,
  q2: Quaternion,
  tolerating epsilon: Float,
) -> Bool {
  // Check if quaternions are the same
  let same_orientation =
    float.absolute_value(q1.x -. q2.x) <. epsilon
    && float.absolute_value(q1.y -. q2.y) <. epsilon
    && float.absolute_value(q1.z -. q2.z) <. epsilon
    && float.absolute_value(q1.w -. q2.w) <. epsilon

  // Check if quaternions are opposite (q and -q represent same rotation)
  let opposite_orientation =
    float.absolute_value(q1.x +. q2.x) <. epsilon
    && float.absolute_value(q1.y +. q2.y) <. epsilon
    && float.absolute_value(q1.z +. q2.z) <. epsilon
    && float.absolute_value(q1.w +. q2.w) <. epsilon

  same_orientation || opposite_orientation
}
