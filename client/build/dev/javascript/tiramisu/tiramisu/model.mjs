import * as $promise from "../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import { Ok, CustomType as $CustomType } from "../gleam.mjs";
import * as $effect from "../tiramisu/effect.mjs";
import * as $texture from "../tiramisu/texture.mjs";
import {
  getGLTFScene as get_scene,
  getGLTFAnimations as get_animations,
  getGLTFCameras as get_cameras,
  getFBXScene as get_fbx_scene,
  getFBXAnimations as get_fbx_animations,
} from "./model.ffi.mjs";

export {
  get_animations,
  get_cameras,
  get_fbx_animations,
  get_fbx_scene,
  get_scene,
};

export class LoopOnce extends $CustomType {}
export const LoopMode$LoopOnce = () => new LoopOnce();
export const LoopMode$isLoopOnce = (value) => value instanceof LoopOnce;

export class LoopRepeat extends $CustomType {}
export const LoopMode$LoopRepeat = () => new LoopRepeat();
export const LoopMode$isLoopRepeat = (value) => value instanceof LoopRepeat;

export class Animation extends $CustomType {
  constructor(clip, loop, speed, weight) {
    super();
    this.clip = clip;
    this.loop = loop;
    this.speed = speed;
    this.weight = weight;
  }
}
export const Animation$Animation = (clip, loop, speed, weight) =>
  new Animation(clip, loop, speed, weight);
export const Animation$isAnimation = (value) => value instanceof Animation;
export const Animation$Animation$clip = (value) => value.clip;
export const Animation$Animation$0 = (value) => value.clip;
export const Animation$Animation$loop = (value) => value.loop;
export const Animation$Animation$1 = (value) => value.loop;
export const Animation$Animation$speed = (value) => value.speed;
export const Animation$Animation$2 = (value) => value.speed;
export const Animation$Animation$weight = (value) => value.weight;
export const Animation$Animation$3 = (value) => value.weight;

/**
 * Play a single animation
 */
export class SingleAnimation extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const AnimationPlayback$SingleAnimation = ($0) =>
  new SingleAnimation($0);
export const AnimationPlayback$isSingleAnimation = (value) =>
  value instanceof SingleAnimation;
export const AnimationPlayback$SingleAnimation$0 = (value) => value[0];

/**
 * Blend between two animations with a blend factor (0.0 = fully 'from', 1.0 = fully 'to')
 */
export class BlendedAnimations extends $CustomType {
  constructor(from, to, blend_factor) {
    super();
    this.from = from;
    this.to = to;
    this.blend_factor = blend_factor;
  }
}
export const AnimationPlayback$BlendedAnimations = (from, to, blend_factor) =>
  new BlendedAnimations(from, to, blend_factor);
export const AnimationPlayback$isBlendedAnimations = (value) =>
  value instanceof BlendedAnimations;
export const AnimationPlayback$BlendedAnimations$from = (value) => value.from;
export const AnimationPlayback$BlendedAnimations$0 = (value) => value.from;
export const AnimationPlayback$BlendedAnimations$to = (value) => value.to;
export const AnimationPlayback$BlendedAnimations$1 = (value) => value.to;
export const AnimationPlayback$BlendedAnimations$blend_factor = (value) =>
  value.blend_factor;
export const AnimationPlayback$BlendedAnimations$2 = (value) =>
  value.blend_factor;

export function load_gltf(url, on_success, on_error) {
  let _block;
  let _pipe = $savoiardi.load_gltf(url);
  _block = $promise.map(
    _pipe,
    (result) => {
      if (result instanceof Ok) {
        let data = result[0];
        return on_success(data);
      } else {
        return on_error;
      }
    },
  );
  let promise = _block;
  return $effect.from_promise(promise);
}

export function load_obj(url, on_success, on_error) {
  let _block;
  let _pipe = $savoiardi.load_obj(url);
  _block = $promise.map(
    _pipe,
    (result) => {
      if (result instanceof Ok) {
        let data = result[0];
        return on_success(data);
      } else {
        return on_error;
      }
    },
  );
  let promise = _block;
  return $effect.from_promise(promise);
}

export function load_fbx(url, on_success, on_error) {
  let _block;
  let _pipe = $savoiardi.load_fbx(url);
  _block = $promise.map(
    _pipe,
    (result) => {
      if (result instanceof Ok) {
        let data = result[0];
        return on_success(data);
      } else {
        return on_error;
      }
    },
  );
  let promise = _block;
  return $effect.from_promise(promise);
}

/**
 * Center an Object3D so its geometric center is at the origin.
 *
 * Computes the bounding box of the entire object hierarchy and adjusts
 * all children's positions so the center of the bounding box is at (0, 0, 0).
 *
 * This is useful for loaded models (FBX, GLTF, OBJ) where the origin may not
 * be at the geometric center of the mesh.
 *
 * ## Example
 *
 * ```gleam
 * let fbx_data = model.get_fbx_scene(loaded_fbx)
 * let centered = model.center_object(fbx_data)
 * // Now the model's center is at (0, 0, 0)
 * ```
 *
 * ## Notes
 *
 * - This mutates the object in place and returns it for convenience
 * - The children's positions are adjusted, not the root object's position
 */
export function center_object(object) {
  return $savoiardi.center_object(object);
}

/**
 * Apply a texture to all meshes in an Object3D hierarchy.
 *
 * This is useful for loaded models that reference external textures,
 * or when you want to override the model's textures.
 *
 * ## Example
 *
 * ```gleam
 * let floor = model.get_fbx_scene(loaded_fbx)
 * model.apply_texture(floor, dungeon_texture, texture.NearestFilter)
 * ```
 */
export function apply_texture(object, tex, filter_mode) {
  let _block;
  if (filter_mode instanceof $texture.NearestFilter) {
    _block = new $savoiardi.NearestFilter();
  } else {
    _block = new $savoiardi.LinearFilter();
  }
  let savoiardi_filter = _block;
  return $savoiardi.apply_texture_to_object(object, tex, savoiardi_filter);
}

/**
 * Create an animation from a clip with default settings.
 *
 * Defaults: loop repeat, normal speed (1.0x), full weight (1.0).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/model
 *
 * // After loading a GLTF model
 * let clips = model.get_animations(gltf_data)
 * let walk_clip = list.find(clips, fn(clip) { model.clip_name(clip) == "Walk" })
 *
 * let walk_animation = model.new_animation(walk_clip)
 * ```
 */
export function new_animation(clip) {
  return new Animation(clip, new LoopRepeat(), 1.0, 1.0);
}

/**
 * Set the loop mode for an animation.
 *
 * ## Example
 *
 * ```gleam
 * let jump_animation = model.new_animation(jump_clip)
 *   |> model.set_loop(model.LoopOnce)  // Play once, don't loop
 * ```
 */
export function set_loop(anim, mode) {
  return new Animation(anim.clip, mode, anim.speed, anim.weight);
}

/**
 * Set the playback speed multiplier.
 *
 * The `speed` multiplier affects how fast the animation plays:
 * - `1.0` = normal speed
 * - `2.0` = double speed (twice as fast)
 * - `0.5` = half speed (slow motion)
 * - Negative values play the animation in reverse
 *
 * ## Example
 *
 * ```gleam
 * let run_animation = model.new_animation(run_clip)
 *   |> model.set_speed(1.5)  // 50% faster running
 * ```
 */
export function set_speed(anim, speed) {
  return new Animation(anim.clip, anim.loop, speed, anim.weight);
}

/**
 * Set the animation weight for blending.
 *
 * The `weight` value ranges from 0.0 to 1.0:
 * - `1.0` = full influence (default)
 * - `0.5` = half influence (useful for blending)
 * - `0.0` = no influence (animation has no effect)
 *
 * ## Example
 *
 * ```gleam
 * // Blend two animations manually
 * let walk = model.new_animation(walk_clip) |> model.set_weight(0.7)
 * let idle = model.new_animation(idle_clip) |> model.set_weight(0.3)
 *
 * // Or use BlendedAnimations with a blend factor
 * model.BlendedAnimations(from: walk, to: idle, blend_factor: 0.5)
 * ```
 */
export function set_weight(anim, weight) {
  return new Animation(anim.clip, anim.loop, anim.speed, weight);
}

/**
 * Get the name of an animation clip.
 *
 * Useful for finding specific animations by name when loading from GLTF files.
 *
 * ## Example
 *
 * ```gleam
 * import gleam/list
 * import tiramisu/model
 *
 * // After loading a GLTF model
 * let clips = model.get_animations(gltf_data)
 *
 * let walk_clip = list.find(clips, fn(clip) {
 *   model.clip_name(clip) == "Walk"
 * })
 * ```
 */
export function clip_name(clip) {
  return $savoiardi.get_clip_name(clip);
}

/**
 * Get the duration of an animation clip.
 *
 * The duration is in **seconds**.
 *
 * ## Example
 *
 * ```gleam
 * let anim = model.new_animation(walk_clip)
 * let duration = model.clip_duration(walk_clip)
 * // Use this to sync game events with animation timing
 * ```
 */
export function clip_duration(clip) {
  let _pipe = $savoiardi.get_clip_duration(clip);
  let _pipe$1 = $float.multiply(_pipe, 1000000000.0);
  let _pipe$2 = $float.round(_pipe$1);
  return $duration.nanoseconds(_pipe$2);
}
