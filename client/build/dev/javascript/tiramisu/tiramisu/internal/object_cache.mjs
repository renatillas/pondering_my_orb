import * as $dict from "../../../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $set from "../../../gleam_stdlib/gleam/set.mjs";
import * as $savoiardi from "../../../savoiardi/savoiardi.mjs";
import { Ok, Error, CustomType as $CustomType, isEqual } from "../../gleam.mjs";
import * as $camera from "../../tiramisu/camera.mjs";

export class SingleAction extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const AnimationActions$SingleAction = ($0) => new SingleAction($0);
export const AnimationActions$isSingleAction = (value) =>
  value instanceof SingleAction;
export const AnimationActions$SingleAction$0 = (value) => value[0];

export class BlendedActions extends $CustomType {
  constructor(from, to) {
    super();
    this.from = from;
    this.to = to;
  }
}
export const AnimationActions$BlendedActions = (from, to) =>
  new BlendedActions(from, to);
export const AnimationActions$isBlendedActions = (value) =>
  value instanceof BlendedActions;
export const AnimationActions$BlendedActions$from = (value) => value.from;
export const AnimationActions$BlendedActions$0 = (value) => value.from;
export const AnimationActions$BlendedActions$to = (value) => value.to;
export const AnimationActions$BlendedActions$1 = (value) => value.to;

export class SingleState extends $CustomType {
  constructor(clip_name) {
    super();
    this.clip_name = clip_name;
  }
}
export const AnimationState$SingleState = (clip_name) =>
  new SingleState(clip_name);
export const AnimationState$isSingleState = (value) =>
  value instanceof SingleState;
export const AnimationState$SingleState$clip_name = (value) => value.clip_name;
export const AnimationState$SingleState$0 = (value) => value.clip_name;

export class BlendedState extends $CustomType {
  constructor(from_clip_name, to_clip_name) {
    super();
    this.from_clip_name = from_clip_name;
    this.to_clip_name = to_clip_name;
  }
}
export const AnimationState$BlendedState = (from_clip_name, to_clip_name) =>
  new BlendedState(from_clip_name, to_clip_name);
export const AnimationState$isBlendedState = (value) =>
  value instanceof BlendedState;
export const AnimationState$BlendedState$from_clip_name = (value) =>
  value.from_clip_name;
export const AnimationState$BlendedState$0 = (value) => value.from_clip_name;
export const AnimationState$BlendedState$to_clip_name = (value) =>
  value.to_clip_name;
export const AnimationState$BlendedState$1 = (value) => value.to_clip_name;

export class CacheState extends $CustomType {
  constructor(objects, mixers, actions, animation_states, viewports, camera_postprocessing, cameras, active_camera) {
    super();
    this.objects = objects;
    this.mixers = mixers;
    this.actions = actions;
    this.animation_states = animation_states;
    this.viewports = viewports;
    this.camera_postprocessing = camera_postprocessing;
    this.cameras = cameras;
    this.active_camera = active_camera;
  }
}
export const CacheState$CacheState = (objects, mixers, actions, animation_states, viewports, camera_postprocessing, cameras, active_camera) =>
  new CacheState(objects,
  mixers,
  actions,
  animation_states,
  viewports,
  camera_postprocessing,
  cameras,
  active_camera);
export const CacheState$isCacheState = (value) => value instanceof CacheState;
export const CacheState$CacheState$objects = (value) => value.objects;
export const CacheState$CacheState$0 = (value) => value.objects;
export const CacheState$CacheState$mixers = (value) => value.mixers;
export const CacheState$CacheState$1 = (value) => value.mixers;
export const CacheState$CacheState$actions = (value) => value.actions;
export const CacheState$CacheState$2 = (value) => value.actions;
export const CacheState$CacheState$animation_states = (value) =>
  value.animation_states;
export const CacheState$CacheState$3 = (value) => value.animation_states;
export const CacheState$CacheState$viewports = (value) => value.viewports;
export const CacheState$CacheState$4 = (value) => value.viewports;
export const CacheState$CacheState$camera_postprocessing = (value) =>
  value.camera_postprocessing;
export const CacheState$CacheState$5 = (value) => value.camera_postprocessing;
export const CacheState$CacheState$cameras = (value) => value.cameras;
export const CacheState$CacheState$6 = (value) => value.cameras;
export const CacheState$CacheState$active_camera = (value) =>
  value.active_camera;
export const CacheState$CacheState$7 = (value) => value.active_camera;

/**
 * Create an empty cache state
 */
export function init() {
  return new CacheState(
    $dict.new$(),
    $dict.new$(),
    $dict.new$(),
    $dict.new$(),
    $dict.new$(),
    $dict.new$(),
    $set.new$(),
    new $option.None(),
  );
}

/**
 * Add a Three.js object to the cache
 */
export function add_object(cache, id, object) {
  return new CacheState(
    $dict.insert(cache.objects, id, object),
    cache.mixers,
    cache.actions,
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get a Three.js object from the cache
 */
export function get_object(cache, id) {
  return $dict.get(cache.objects, id);
}

/**
 * Remove a Three.js object from the cache
 */
export function remove_object(cache, id) {
  return new CacheState(
    $dict.delete$(cache.objects, id),
    cache.mixers,
    cache.actions,
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get all cached objects as a list of (ID, Object) tuples
 */
export function get_all_objects(cache) {
  return $dict.to_list(cache.objects);
}

/**
 * Add an animation mixer to the cache
 */
export function add_mixer(cache, id, mixer) {
  return new CacheState(
    cache.objects,
    $dict.insert(cache.mixers, id, mixer),
    cache.actions,
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get an animation mixer from the cache
 */
export function get_mixer(cache, id) {
  let _pipe = $dict.get(cache.mixers, id);
  return $option.from_result(_pipe);
}

/**
 * Remove an animation mixer from the cache
 */
export function remove_mixer(cache, id) {
  return new CacheState(
    cache.objects,
    $dict.delete$(cache.mixers, id),
    cache.actions,
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get all mixers as a list
 */
export function get_all_mixers(cache) {
  return $dict.to_list(cache.mixers);
}

/**
 * Set the current animation actions for a node
 */
export function set_actions(cache, id, actions) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    $dict.insert(cache.actions, id, actions),
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get the current animation actions for a node
 */
export function get_actions(cache, id) {
  let _pipe = $dict.get(cache.actions, id);
  return $option.from_result(_pipe);
}

/**
 * Remove animation actions for a node
 */
export function remove_actions(cache, id) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    $dict.delete$(cache.actions, id),
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Set the animation state for a node (for diffing clip names)
 */
export function set_animation_state(cache, id, state) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    $dict.insert(cache.animation_states, id, state),
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get the animation state for a node
 */
export function get_animation_state(cache, id) {
  let _pipe = $dict.get(cache.animation_states, id);
  return $option.from_result(_pipe);
}

/**
 * Remove animation state for a node
 */
export function remove_animation_state(cache, id) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    $dict.delete$(cache.animation_states, id),
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Set viewport configuration for a camera
 */
export function set_viewport(cache, id, viewport) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    cache.animation_states,
    $dict.insert(cache.viewports, id, viewport),
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get viewport configuration for a camera
 */
export function get_viewport(cache, id) {
  let _pipe = $dict.get(cache.viewports, id);
  return $option.from_result(_pipe);
}

/**
 * Remove viewport configuration for a camera
 */
export function remove_viewport(cache, id) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    cache.animation_states,
    $dict.delete$(cache.viewports, id),
    cache.camera_postprocessing,
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get all cameras with viewports
 */
export function get_cameras_with_viewports(cache) {
  let _pipe = $dict.to_list(cache.viewports);
  return $list.filter_map(
    _pipe,
    (entry) => {
      let id;
      let viewport;
      id = entry[0];
      viewport = entry[1];
      let $ = $dict.get(cache.objects, id);
      if ($ instanceof Ok) {
        let camera_obj = $[0];
        return new Ok([camera_obj, viewport]);
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Set postprocessing configuration for a camera
 */
export function set_camera_postprocessing(cache, id, pp) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    cache.animation_states,
    cache.viewports,
    $dict.insert(cache.camera_postprocessing, id, pp),
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Get postprocessing configuration for a camera
 */
export function get_camera_postprocessing(cache, id) {
  return $dict.get(cache.camera_postprocessing, id);
}

/**
 * Remove postprocessing configuration for a camera
 */
export function remove_camera_postprocessing(cache, id) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    cache.animation_states,
    cache.viewports,
    $dict.delete$(cache.camera_postprocessing, id),
    cache.cameras,
    cache.active_camera,
  );
}

/**
 * Add a camera ID to the cameras set
 */
export function add_camera(cache, id) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    $set.insert(cache.cameras, id),
    cache.active_camera,
  );
}

/**
 * Remove a camera ID from the cameras set
 */
export function remove_camera(cache, id) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    $set.delete$(cache.cameras, id),
    cache.active_camera,
  );
}

/**
 * Set the active camera ID
 */
export function set_active_camera(cache, id) {
  return new CacheState(
    cache.objects,
    cache.mixers,
    cache.actions,
    cache.animation_states,
    cache.viewports,
    cache.camera_postprocessing,
    cache.cameras,
    new $option.Some(id),
  );
}

/**
 * Get the active camera ID
 */
export function get_active_camera(cache) {
  return cache.active_camera;
}

/**
 * Get all cameras with their postprocessing configurations
 * Returns list of tuples: (camera_id_string, camera_object, Option(viewport), Option(postprocessing), is_active)
 */
export function get_all_cameras_with_info(cache) {
  let _pipe = $set.to_list(cache.cameras);
  return $list.filter_map(
    _pipe,
    (camera_id) => {
      let $ = $dict.get(cache.objects, camera_id);
      if ($ instanceof Ok) {
        let camera_obj = $[0];
        let _block;
        let _pipe$1 = $dict.get(cache.viewports, camera_id);
        _block = $option.from_result(_pipe$1);
        let viewport_opt = _block;
        let _block$1;
        let _pipe$2 = $dict.get(cache.camera_postprocessing, camera_id);
        _block$1 = $option.from_result(_pipe$2);
        let pp_opt = _block$1;
        let is_active = isEqual(
          cache.active_camera,
          new $option.Some(camera_id)
        );
        return new Ok([camera_id, camera_obj, viewport_opt, pp_opt, is_active]);
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Remove all cached data for a given ID (object, mixer, actions, animation_state, viewport, particles, camera, postprocessing)
 * This is used when a node is removed from the scene
 */
export function remove_all(cache, id) {
  let _pipe = cache;
  let _pipe$1 = remove_object(_pipe, id);
  let _pipe$2 = remove_mixer(_pipe$1, id);
  let _pipe$3 = remove_actions(_pipe$2, id);
  let _pipe$4 = remove_animation_state(_pipe$3, id);
  let _pipe$5 = remove_viewport(_pipe$4, id);
  let _pipe$6 = remove_camera(_pipe$5, id);
  return remove_camera_postprocessing(_pipe$6, id);
}
