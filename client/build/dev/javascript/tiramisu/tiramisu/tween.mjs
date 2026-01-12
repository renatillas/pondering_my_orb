import * as $order from "../../gleam_stdlib/gleam/order.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $quaternion from "../../quaterni/quaternion.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { CustomType as $CustomType, divideFloat } from "../gleam.mjs";
import * as $transform from "../tiramisu/transform.mjs";

export class Tween extends $CustomType {
  constructor(start_value, end_value, duration, elapsed, easing, lerp_fn) {
    super();
    this.start_value = start_value;
    this.end_value = end_value;
    this.duration = duration;
    this.elapsed = elapsed;
    this.easing = easing;
    this.lerp_fn = lerp_fn;
  }
}
export const Tween$Tween = (start_value, end_value, duration, elapsed, easing, lerp_fn) =>
  new Tween(start_value, end_value, duration, elapsed, easing, lerp_fn);
export const Tween$isTween = (value) => value instanceof Tween;
export const Tween$Tween$start_value = (value) => value.start_value;
export const Tween$Tween$0 = (value) => value.start_value;
export const Tween$Tween$end_value = (value) => value.end_value;
export const Tween$Tween$1 = (value) => value.end_value;
export const Tween$Tween$duration = (value) => value.duration;
export const Tween$Tween$2 = (value) => value.duration;
export const Tween$Tween$elapsed = (value) => value.elapsed;
export const Tween$Tween$3 = (value) => value.elapsed;
export const Tween$Tween$easing = (value) => value.easing;
export const Tween$Tween$4 = (value) => value.easing;
export const Tween$Tween$lerp_fn = (value) => value.lerp_fn;
export const Tween$Tween$5 = (value) => value.lerp_fn;

/**
 * Create a new tween with a custom interpolation function.
 *
 * For most use cases, prefer `tween_float()`, `tween_vec3()`, or `tween_transform()`.
 *
 * ## Example
 *
 * ```gleam
 * // Custom tween for a color value
 * type Color {
 *   Color(r: Float, g: Float, b: Float)
 * }
 *
 * let color_tween = tween.new(
 *   start: Color(1.0, 0.0, 0.0),  // Red
 *   end: Color(0.0, 0.0, 1.0),    // Blue
 *   duration: duration.seconds(1),
 *   easing: fn(t) { t *. t },     // Ease in quad
 *   lerp_fn: fn(a, b, t) {
 *     Color(
 *       r: a.r +. { b.r -. a.r } *. t,
 *       g: a.g +. { b.g -. a.g } *. t,
 *       b: a.b +. { b.b -. a.b } *. t,
 *     )
 *   },
 * )
 * ```
 */
export function new$(start, end, duration, easing, lerp_fn) {
  return new Tween(
    start,
    end,
    duration,
    $duration.nanoseconds(0),
    easing,
    lerp_fn,
  );
}

/**
 * Update a tween by advancing its elapsed time.
 *
 * The `delta` parameter is a Duration (typically from `ctx.delta_time`).
 *
 * ## Example
 *
 * ```gleam
 * fn update(model: Model, msg: Msg, ctx: Context) {
 *   // Advance the tween by the frame delta
 *   let updated_tween = tween.update(model.tween, ctx.delta_time)
 *   Model(..model, tween: updated_tween)
 * }
 * ```
 */
export function update(tween, delta) {
  let new_elapsed = $duration.add(tween.elapsed, delta);
  return new Tween(
    tween.start_value,
    tween.end_value,
    tween.duration,
    new_elapsed,
    tween.easing,
    tween.lerp_fn,
  );
}

/**
 * Get the current interpolated value of a tween.
 *
 * Applies the easing function and returns the value at the current elapsed time.
 * Once the tween completes, this returns the end value.
 *
 * ## Example
 *
 * ```gleam
 * let my_tween = tween.tween_float(0.0, 100.0, duration.seconds(1), fn(t) { t })
 *   |> tween.update(duration.milliseconds(500))  // Halfway through
 *
 * let value = tween.get_value(my_tween)  // => 50.0
 * ```
 */
export function get_value(tween) {
  let _block;
  let $ = $duration.compare(tween.elapsed, tween.duration);
  if ($ instanceof $order.Lt) {
    let elapsed_s = $duration.to_seconds(tween.elapsed);
    let total_s = $duration.to_seconds(tween.duration);
    _block = divideFloat(elapsed_s, total_s);
  } else if ($ instanceof $order.Eq) {
    _block = 1.0;
  } else {
    _block = 1.0;
  }
  let t = _block;
  let eased_t = tween.easing(t);
  return tween.lerp_fn(tween.start_value, tween.end_value, eased_t);
}

/**
 * Check if a tween has finished playing.
 *
 * ## Example
 *
 * ```gleam
 * fn update(model: Model, msg: Msg, ctx: Context) {
 *   let updated_tween = tween.update(model.tween, ctx.delta_time)
 *
 *   case tween.is_complete(updated_tween) {
 *     True -> {
 *       // Tween finished, trigger next animation or event
 *       #(Model(..model, tween: tween.reset(updated_tween)), effect.none())
 *     }
 *     False -> #(Model(..model, tween: updated_tween), effect.none())
 *   }
 * }
 * ```
 */
export function is_complete(tween) {
  let $ = $duration.compare(tween.elapsed, tween.duration);
  if ($ instanceof $order.Lt) {
    return false;
  } else if ($ instanceof $order.Eq) {
    return true;
  } else {
    return true;
  }
}

/**
 * Create a tween that interpolates a Float value.
 *
 * The `duration` is a Duration type.
 *
 * ## Example
 *
 * ```gleam
 * // Fade from 0.0 to 1.0 over 2 seconds
 * let fade_tween = tween.tween_float(
 *   start: 0.0,
 *   end: 1.0,
 *   duration: duration.seconds(2),
 *   easing: fn(t) { t *. t *. t },  // Ease in cubic
 * )
 * ```
 */
export function tween_float(start, end, duration, easing) {
  return new$(
    start,
    end,
    duration,
    easing,
    (a, b, t) => { return a + ((b - a) * t); },
  );
}

/**
 * Create a tween that interpolates a Vec3 value (useful for positions).
 *
 * The `duration` is a Duration type.
 *
 * ## Example
 *
 * ```gleam
 * import vec/vec3
 *
 * // Move from origin to (10, 5, 0) over 3 seconds
 * let position_tween = tween.tween_vec3(
 *   start: vec3.Vec3(0.0, 0.0, 0.0),
 *   end: vec3.Vec3(10.0, 5.0, 0.0),
 *   duration: duration.seconds(3),
 *   easing: fn(t) { 1.0 -. { 1.0 -. t } *. { 1.0 -. t } },  // Ease out quad
 * )
 * ```
 */
export function tween_vec3(start, end, duration, easing) {
  return new$(
    start,
    end,
    duration,
    easing,
    (a, b, t) => {
      return new $vec3.Vec3(
        a.x + ((b.x - a.x) * t),
        a.y + ((b.y - a.y) * t),
        a.z + ((b.z - a.z) * t),
      );
    },
  );
}

/**
 * Create a tween that interpolates between two quaternions using spherical linear interpolation (slerp).
 *
 * The `duration` is a Duration type.
 *
 * ## Example
 *
 * ```gleam
 * import quaternion
 * import vec/vec3
 *
 * let start_rotation = quaternion.from_euler(vec3.Vec3(0.0, 0.0, 0.0))
 * let end_rotation = quaternion.from_euler(vec3.Vec3(0.0, 3.14159, 0.0))
 *
 * let rotation_tween = tween.tween_quaternion(
 *   start: start_rotation,
 *   end: end_rotation,
 *   duration: duration.seconds(2),
 *   easing: fn(t) { t },  // Linear
 * )
 * ```
 */
export function tween_quaternion(start, end, duration, easing) {
  return new$(
    start,
    end,
    duration,
    easing,
    (a, b, t) => { return $quaternion.spherical_linear_interpolation(a, b, t); },
  );
}

/**
 * Create a tween that interpolates a Transform (position, rotation, and scale).
 *
 * The `duration` is a Duration type.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/transform
 * import vec/vec3
 *
 * let start_transform = transform.at(position: vec3.Vec3(0.0, 0.0, 0.0))
 *   |> transform.scale_uniform(1.0)
 *
 * let end_transform = transform.at(position: vec3.Vec3(5.0, 0.0, 0.0))
 *   |> transform.scale_uniform(2.0)
 *   |> transform.rotate_y(3.14159)
 *
 * let transform_tween = tween.tween_transform(
 *   start: start_transform,
 *   end: end_transform,
 *   duration: duration.seconds(1.5),
 *   easing: fn(t) { t *. t *. { 3.0 -. 2.0 *. t } },  // Smooth step
 * )
 * ```
 */
export function tween_transform(start, end, duration, easing) {
  return new$(start, end, duration, easing, $transform.lerp);
}

/**
 * Reset a tween back to the beginning (elapsed time = 0).
 *
 * ## Example
 *
 * ```gleam
 * // Play the tween again from the start
 * let reset_tween = tween.reset(completed_tween)
 * ```
 */
export function reset(tween) {
  return new Tween(
    tween.start_value,
    tween.end_value,
    tween.duration,
    $duration.nanoseconds(0),
    tween.easing,
    tween.lerp_fn,
  );
}

/**
 * Reverse a tween by swapping its start and end values.
 *
 * The elapsed time is preserved, so the tween continues from where it was
 * but in the opposite direction.
 *
 * ## Example
 *
 * ```gleam
 * // Create a bouncing animation
 * fn update(model: Model, msg: Msg, ctx: Context) {
 *   let updated_tween = tween.update(model.tween, ctx.delta_time)
 *
 *   case tween.is_complete(updated_tween) {
 *     True -> {
 *       // Bounce back by reversing the tween
 *       let reversed = tween.reverse(updated_tween)
 *         |> tween.reset()
 *       Model(..model, tween: reversed)
 *     }
 *     False -> Model(..model, tween: updated_tween)
 *   }
 * }
 * ```
 */
export function reverse(tween) {
  return new Tween(
    tween.end_value,
    tween.start_value,
    tween.duration,
    tween.elapsed,
    tween.easing,
    tween.lerp_fn,
  );
}
