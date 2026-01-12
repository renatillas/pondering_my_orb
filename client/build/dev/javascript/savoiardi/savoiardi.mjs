import * as $array from "../gleam_javascript/gleam/javascript/array.mjs";
import * as $promise from "../gleam_javascript/gleam/javascript/promise.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $quaternion from "../quaterni/quaternion.mjs";
import * as $vec2 from "../vec/vec/vec2.mjs";
import * as $vec3 from "../vec/vec/vec3.mjs";
import { CustomType as $CustomType } from "./gleam.mjs";
import {
  getFrontSide as get_front_side_constant,
  getBackSide as get_back_side_constant,
  getDoubleSide as get_double_side_constant,
  createScene as create_scene,
  setSceneBackgroundColor as set_scene_background_color,
  setSceneBackgroundTexture as set_scene_background_texture,
  setSceneBackgroundCubeTexture as set_scene_background_cube_texture,
  addToScene as add_to_scene,
  removeFromScene as remove_from_scene,
  getCanvasDimensions as get_canvas_dimensions,
  createRenderer as create_renderer,
  getRendererDomElement as get_renderer_dom_element,
  setRendererSize as set_renderer_size,
  setRendererPixelRatio as set_renderer_pixel_ratio,
  render,
  clearRenderer as clear_renderer,
  setViewport as set_viewport,
  setScissor as set_scissor,
  setScissorTest as set_scissor_test,
  getRenderStats as get_render_stats,
  createPerspectiveCamera as create_perspective_camera,
  createOrthographicCamera as create_orthographic_camera,
  setCameraAspect as set_camera_aspect,
  cloneObject3D as clone_object,
  createGroup as create_group,
  createMesh as create_mesh,
  addChild as add_child,
  applyTransform as apply_transform,
  updateMatrixWorld as update_matrix_world,
  updateMatrixWorldForce as update_matrix_world_force,
  disposeObject3D as dispose_object,
  extractMeshMaterialPairs as extract_mesh_material_pairs,
  createLOD as create_lod,
  addLODLevel as add_lod_level,
  removeLODLevel as remove_lod_level,
  createInstancedMesh as create_instanced_mesh,
  updateInstanceMatrix as update_instance_matrix,
  createBoxGeometry as create_box_geometry,
  createSphereGeometry as create_sphere_geometry,
  createConeGeometry as create_cone_geometry,
  createPlaneGeometry as create_plane_geometry,
  createCircleGeometry as create_circle_geometry,
  createCylinderGeometry as create_cylinder_geometry,
  createTorusGeometry as create_torus_geometry,
  createTetrahedronGeometry as create_tetrahedron_geometry,
  createIcosahedronGeometry as create_icosahedron_geometry,
  createTextGeometry as create_text_geometry,
  createBasicMaterial as create_basic_material_ffi,
  createStandardMaterial as create_standard_material,
  createPhongMaterial as create_phong_material,
  createLambertMaterial as create_lambert_material,
  createToonMaterial as create_toon_material,
  createLineMaterial as create_line_material,
  createSpriteMaterial as create_sprite_material,
  createPointsMaterial as create_points_material_internal,
  createAmbientLight as create_ambient_light,
  createDirectionalLight as create_directional_light_ffi,
  createPointLight as create_point_light_ffi,
  createSpotLight as create_spot_light_ffi,
  createHemisphereLight as create_hemisphere_light,
  createSprite as create_sprite,
  createPoints as create_points,
  createLineSegments as create_line_segments,
  removeChild as remove_child,
  setPosition as set_object_position,
  setRotation as set_object_rotation,
  setScale as set_object_scale,
  getWorldPosition as get_world_position,
  getWorldQuaternion as get_world_quaternion,
  copyPosition as copy_position,
  copyRotation as copy_rotation,
  copyScale as copy_scale,
  createAnimationMixer as create_animation_mixer,
  clipAction as clip_action,
  updateMixer as update_mixer,
  playAction as play_action,
  stopAction as stop_action,
  setActionLoop as set_action_loop_internal,
  setActionTimeScale as set_action_time_scale,
  setActionWeight as set_action_weight,
  getClipName as get_clip_name,
  getClipDuration as get_clip_duration,
  cloneTexture as clone_texture,
  setTextureOffset as set_texture_offset,
  setTextureRepeat as set_texture_repeat,
  setTextureWrapMode as set_texture_wrap_mode_internal,
  setTextureFilterMode as set_texture_filter_mode_internal,
  getRepeatWrapping as get_repeat_wrapping_constant,
  getClampToEdgeWrapping as get_clamp_to_edge_wrapping_constant,
  getMirroredRepeatWrapping as get_mirrored_repeat_wrapping_constant,
  getNearestFilter as get_nearest_filter_constant,
  getLinearFilter as get_linear_filter_constant,
  createAudioListener as create_audio_listener,
  createAudio as create_audio,
  createPositionalAudio as create_positional_audio,
  setAudioBuffer as set_audio_buffer,
  playAudio as play_audio,
  pauseAudio as pause_audio,
  stopAudio as stop_audio,
  setAudioVolume as set_audio_volume,
  setAudioLoop as set_audio_loop,
  setAudioPlaybackRate as set_audio_playback_rate,
  isAudioPlaying as is_audio_playing,
  setRefDistance as set_ref_distance,
  setRolloffFactor as set_rolloff_factor,
  setMaxDistance as set_max_distance,
  hasAudioBuffer as has_audio_buffer,
  getAudioLoop as get_audio_loop,
  getAudioContextState as get_audio_context_state,
  resumeAudioContext as resume_audio_context,
  createAxesHelper as create_axes_helper,
  createGridHelper as create_grid_helper,
  createBoxHelper as create_box_helper,
  createBufferGeometry as create_buffer_geometry,
  createBufferAttribute as create_buffer_attribute,
  setGeometryAttribute as set_geometry_attribute,
  markAttributeNeedsUpdate as mark_attribute_needs_update,
  setDrawRange as set_draw_range,
  createColor as create_color,
  lerpColor as lerp_color,
  getLoopOnce as get_loop_once_constant,
  getLoopRepeat as get_loop_repeat_constant,
  getLoopPingPong as get_loop_ping_pong_constant,
  getAdditiveBlending as get_additive_blending_constant,
  getNormalBlending as get_normal_blending_constant,
  getColorR as get_color_r,
  getColorG as get_color_g,
  getColorB as get_color_b,
  createFloat32Array as create_float32_array,
  setBufferAttribute as set_buffer_attribute,
  getGeometry as get_geometry,
  getAttribute as get_attribute,
  setBufferXYZ as set_buffer_xyz,
  setBufferX as set_buffer_x,
  setAttributeNeedsUpdate as set_attribute_needs_update,
  applyTransformWithQuaternion as apply_transform_with_quaternion,
  applyCameraLookAt as set_camera_look_at,
  objectLookAt as object_look_at,
  setShadowProperties as set_shadow_properties,
  clearLODLevels as clear_lod_levels,
  updateInstancedMeshTransforms as update_instanced_mesh_transforms,
  updateGroupInstancedMeshes as update_group_instanced_meshes,
  updateCameraProjectionMatrix as update_camera_projection_matrix,
  setPerspectiveCameraParams as set_perspective_camera_params,
  setOrthographicCameraParams as set_orthographic_camera_params,
  getObjectGeometry as get_object_geometry,
  getObjectMaterial as get_object_material,
  setObjectGeometry as set_object_geometry,
  setObjectMaterial as set_object_material,
  getObjectPosition as get_object_position,
  getObjectRotation as get_object_rotation,
  getObjectScale as get_object_scale,
  getObjectQuaternion as get_object_quaternion,
  setObjectQuaternion as set_object_quaternion,
  enableTransparency as enable_transparency,
  enableShadows as enable_shadows,
  applyMaterialToObject as apply_material_to_object,
  applyTextureToObject as apply_texture_to_object_internal,
  disposeTexture as dispose_texture,
  disposeGeometry as dispose_geometry,
  disposeMaterial as dispose_material,
  createCSS2DRenderer as create_css2d_renderer,
  setCSS2DRendererSize as set_css2d_renderer_size,
  getCSS2DRendererDomElement as get_css2d_renderer_dom_element,
  renderCSS2D as render_css2d,
  createCSS3DRenderer as create_css3d_renderer,
  setCSS3DRendererSize as set_css3d_renderer_size,
  getCSS3DRendererDomElement as get_css3d_renderer_dom_element,
  renderCSS3D as render_css3d,
  createCSS2DObject as create_css2d_object,
  updateCSS2DObjectHTML as update_css2d_object_html,
  createCSS3DObject as create_css3d_object,
  updateCSS3DObjectHTML as update_css3d_object_html,
  getRendererInfo as get_renderer_info,
  isContextValid as is_context_valid,
  loadTexture as load_texture,
  loadAudio as load_audio,
  loadSTL as load_stl,
  centerGeometry as center_geometry,
  centerObject3D as center_object,
  loadGLTF as load_gltf,
  loadOBJ as load_obj,
  loadFBX as load_fbx,
  loadFont as load_font,
  loadEquirectangularTexture as load_equirectangular_texture,
  loadCubeTexture as load_cube_texture,
  setAudioBuffer as set_positional_audio_buffer,
  setAudioVolume as set_positional_audio_volume,
  setAudioLoop as set_positional_audio_loop,
  setAudioPlaybackRate as set_positional_audio_playback_rate,
  playAudio as play_positional_audio,
  pauseAudio as pause_positional_audio,
  stopAudio as stop_positional_audio,
  isAudioPlaying as is_positional_audio_playing,
  hasAudioBuffer as has_positional_audio_buffer,
  getAudioLoop as get_positional_audio_loop,
} from "./savoiardi.ffi.mjs";

export {
  add_child,
  add_lod_level,
  add_to_scene,
  apply_material_to_object,
  apply_transform,
  apply_transform_with_quaternion,
  center_geometry,
  center_object,
  clear_lod_levels,
  clear_renderer,
  clip_action,
  clone_object,
  clone_texture,
  copy_position,
  copy_rotation,
  copy_scale,
  create_ambient_light,
  create_animation_mixer,
  create_audio,
  create_audio_listener,
  create_axes_helper,
  create_box_geometry,
  create_box_helper,
  create_buffer_attribute,
  create_buffer_geometry,
  create_circle_geometry,
  create_color,
  create_cone_geometry,
  create_css2d_object,
  create_css2d_renderer,
  create_css3d_object,
  create_css3d_renderer,
  create_cylinder_geometry,
  create_float32_array,
  create_grid_helper,
  create_group,
  create_hemisphere_light,
  create_icosahedron_geometry,
  create_instanced_mesh,
  create_lambert_material,
  create_line_material,
  create_line_segments,
  create_lod,
  create_mesh,
  create_orthographic_camera,
  create_perspective_camera,
  create_phong_material,
  create_plane_geometry,
  create_points,
  create_positional_audio,
  create_renderer,
  create_scene,
  create_sphere_geometry,
  create_sprite,
  create_sprite_material,
  create_standard_material,
  create_tetrahedron_geometry,
  create_text_geometry,
  create_toon_material,
  create_torus_geometry,
  dispose_geometry,
  dispose_material,
  dispose_object,
  dispose_texture,
  enable_shadows,
  enable_transparency,
  extract_mesh_material_pairs,
  get_attribute,
  get_audio_context_state,
  get_audio_loop,
  get_canvas_dimensions,
  get_clip_duration,
  get_clip_name,
  get_color_b,
  get_color_g,
  get_color_r,
  get_css2d_renderer_dom_element,
  get_css3d_renderer_dom_element,
  get_geometry,
  get_object_geometry,
  get_object_material,
  get_object_position,
  get_object_quaternion,
  get_object_rotation,
  get_object_scale,
  get_positional_audio_loop,
  get_render_stats,
  get_renderer_dom_element,
  get_renderer_info,
  get_world_position,
  get_world_quaternion,
  has_audio_buffer,
  has_positional_audio_buffer,
  is_audio_playing,
  is_context_valid,
  is_positional_audio_playing,
  lerp_color,
  load_audio,
  load_cube_texture,
  load_equirectangular_texture,
  load_fbx,
  load_font,
  load_gltf,
  load_obj,
  load_stl,
  load_texture,
  mark_attribute_needs_update,
  object_look_at,
  pause_audio,
  pause_positional_audio,
  play_action,
  play_audio,
  play_positional_audio,
  remove_child,
  remove_from_scene,
  remove_lod_level,
  render,
  render_css2d,
  render_css3d,
  resume_audio_context,
  set_action_time_scale,
  set_action_weight,
  set_attribute_needs_update,
  set_audio_buffer,
  set_audio_loop,
  set_audio_playback_rate,
  set_audio_volume,
  set_buffer_attribute,
  set_buffer_x,
  set_buffer_xyz,
  set_camera_aspect,
  set_camera_look_at,
  set_css2d_renderer_size,
  set_css3d_renderer_size,
  set_draw_range,
  set_geometry_attribute,
  set_max_distance,
  set_object_geometry,
  set_object_material,
  set_object_position,
  set_object_quaternion,
  set_object_rotation,
  set_object_scale,
  set_orthographic_camera_params,
  set_perspective_camera_params,
  set_positional_audio_buffer,
  set_positional_audio_loop,
  set_positional_audio_playback_rate,
  set_positional_audio_volume,
  set_ref_distance,
  set_renderer_pixel_ratio,
  set_renderer_size,
  set_rolloff_factor,
  set_scene_background_color,
  set_scene_background_cube_texture,
  set_scene_background_texture,
  set_scissor,
  set_scissor_test,
  set_shadow_properties,
  set_texture_offset,
  set_texture_repeat,
  set_viewport,
  stop_action,
  stop_audio,
  stop_positional_audio,
  update_camera_projection_matrix,
  update_css2d_object_html,
  update_css3d_object_html,
  update_group_instanced_meshes,
  update_instance_matrix,
  update_instanced_mesh_transforms,
  update_matrix_world,
  update_matrix_world_force,
  update_mixer,
};

export class ShadowConfig extends $CustomType {
  constructor(resolution, bias, normal_bias) {
    super();
    this.resolution = resolution;
    this.bias = bias;
    this.normal_bias = normal_bias;
  }
}
export const ShadowConfig$ShadowConfig = (resolution, bias, normal_bias) =>
  new ShadowConfig(resolution, bias, normal_bias);
export const ShadowConfig$isShadowConfig = (value) =>
  value instanceof ShadowConfig;
export const ShadowConfig$ShadowConfig$resolution = (value) => value.resolution;
export const ShadowConfig$ShadowConfig$0 = (value) => value.resolution;
export const ShadowConfig$ShadowConfig$bias = (value) => value.bias;
export const ShadowConfig$ShadowConfig$1 = (value) => value.bias;
export const ShadowConfig$ShadowConfig$normal_bias = (value) =>
  value.normal_bias;
export const ShadowConfig$ShadowConfig$2 = (value) => value.normal_bias;

export class DirectionalShadowConfig extends $CustomType {
  constructor(resolution, bias, normal_bias, camera_left, camera_right, camera_top, camera_bottom, camera_near, camera_far) {
    super();
    this.resolution = resolution;
    this.bias = bias;
    this.normal_bias = normal_bias;
    this.camera_left = camera_left;
    this.camera_right = camera_right;
    this.camera_top = camera_top;
    this.camera_bottom = camera_bottom;
    this.camera_near = camera_near;
    this.camera_far = camera_far;
  }
}
export const DirectionalShadowConfig$DirectionalShadowConfig = (resolution, bias, normal_bias, camera_left, camera_right, camera_top, camera_bottom, camera_near, camera_far) =>
  new DirectionalShadowConfig(resolution,
  bias,
  normal_bias,
  camera_left,
  camera_right,
  camera_top,
  camera_bottom,
  camera_near,
  camera_far);
export const DirectionalShadowConfig$isDirectionalShadowConfig = (value) =>
  value instanceof DirectionalShadowConfig;
export const DirectionalShadowConfig$DirectionalShadowConfig$resolution = (value) =>
  value.resolution;
export const DirectionalShadowConfig$DirectionalShadowConfig$0 = (value) =>
  value.resolution;
export const DirectionalShadowConfig$DirectionalShadowConfig$bias = (value) =>
  value.bias;
export const DirectionalShadowConfig$DirectionalShadowConfig$1 = (value) =>
  value.bias;
export const DirectionalShadowConfig$DirectionalShadowConfig$normal_bias = (value) =>
  value.normal_bias;
export const DirectionalShadowConfig$DirectionalShadowConfig$2 = (value) =>
  value.normal_bias;
export const DirectionalShadowConfig$DirectionalShadowConfig$camera_left = (value) =>
  value.camera_left;
export const DirectionalShadowConfig$DirectionalShadowConfig$3 = (value) =>
  value.camera_left;
export const DirectionalShadowConfig$DirectionalShadowConfig$camera_right = (value) =>
  value.camera_right;
export const DirectionalShadowConfig$DirectionalShadowConfig$4 = (value) =>
  value.camera_right;
export const DirectionalShadowConfig$DirectionalShadowConfig$camera_top = (value) =>
  value.camera_top;
export const DirectionalShadowConfig$DirectionalShadowConfig$5 = (value) =>
  value.camera_top;
export const DirectionalShadowConfig$DirectionalShadowConfig$camera_bottom = (value) =>
  value.camera_bottom;
export const DirectionalShadowConfig$DirectionalShadowConfig$6 = (value) =>
  value.camera_bottom;
export const DirectionalShadowConfig$DirectionalShadowConfig$camera_near = (value) =>
  value.camera_near;
export const DirectionalShadowConfig$DirectionalShadowConfig$7 = (value) =>
  value.camera_near;
export const DirectionalShadowConfig$DirectionalShadowConfig$camera_far = (value) =>
  value.camera_far;
export const DirectionalShadowConfig$DirectionalShadowConfig$8 = (value) =>
  value.camera_far;

export class FrontSide extends $CustomType {}
export const MaterialSide$FrontSide = () => new FrontSide();
export const MaterialSide$isFrontSide = (value) => value instanceof FrontSide;

export class BackSide extends $CustomType {}
export const MaterialSide$BackSide = () => new BackSide();
export const MaterialSide$isBackSide = (value) => value instanceof BackSide;

export class DoubleSide extends $CustomType {}
export const MaterialSide$DoubleSide = () => new DoubleSide();
export const MaterialSide$isDoubleSide = (value) => value instanceof DoubleSide;

export class NearestFilter extends $CustomType {}
export const FilterMode$NearestFilter = () => new NearestFilter();
export const FilterMode$isNearestFilter = (value) =>
  value instanceof NearestFilter;

export class LinearFilter extends $CustomType {}
export const FilterMode$LinearFilter = () => new LinearFilter();
export const FilterMode$isLinearFilter = (value) =>
  value instanceof LinearFilter;

export class RepeatWrapping extends $CustomType {}
export const WrapMode$RepeatWrapping = () => new RepeatWrapping();
export const WrapMode$isRepeatWrapping = (value) =>
  value instanceof RepeatWrapping;

export class ClampToEdgeWrapping extends $CustomType {}
export const WrapMode$ClampToEdgeWrapping = () => new ClampToEdgeWrapping();
export const WrapMode$isClampToEdgeWrapping = (value) =>
  value instanceof ClampToEdgeWrapping;

export class MirroredRepeatWrapping extends $CustomType {}
export const WrapMode$MirroredRepeatWrapping = () =>
  new MirroredRepeatWrapping();
export const WrapMode$isMirroredRepeatWrapping = (value) =>
  value instanceof MirroredRepeatWrapping;

export class AdditiveBlending extends $CustomType {}
export const BlendingMode$AdditiveBlending = () => new AdditiveBlending();
export const BlendingMode$isAdditiveBlending = (value) =>
  value instanceof AdditiveBlending;

export class NormalBlending extends $CustomType {}
export const BlendingMode$NormalBlending = () => new NormalBlending();
export const BlendingMode$isNormalBlending = (value) =>
  value instanceof NormalBlending;

export class LoopOnce extends $CustomType {}
export const LoopMode$LoopOnce = () => new LoopOnce();
export const LoopMode$isLoopOnce = (value) => value instanceof LoopOnce;

export class LoopRepeat extends $CustomType {}
export const LoopMode$LoopRepeat = () => new LoopRepeat();
export const LoopMode$isLoopRepeat = (value) => value instanceof LoopRepeat;

export class LoopPingPong extends $CustomType {}
export const LoopMode$LoopPingPong = () => new LoopPingPong();
export const LoopMode$isLoopPingPong = (value) => value instanceof LoopPingPong;

export class RendererOptions extends $CustomType {
  constructor(antialias, alpha, dimensions) {
    super();
    this.antialias = antialias;
    this.alpha = alpha;
    this.dimensions = dimensions;
  }
}
export const RendererOptions$RendererOptions = (antialias, alpha, dimensions) =>
  new RendererOptions(antialias, alpha, dimensions);
export const RendererOptions$isRendererOptions = (value) =>
  value instanceof RendererOptions;
export const RendererOptions$RendererOptions$antialias = (value) =>
  value.antialias;
export const RendererOptions$RendererOptions$0 = (value) => value.antialias;
export const RendererOptions$RendererOptions$alpha = (value) => value.alpha;
export const RendererOptions$RendererOptions$1 = (value) => value.alpha;
export const RendererOptions$RendererOptions$dimensions = (value) =>
  value.dimensions;
export const RendererOptions$RendererOptions$2 = (value) => value.dimensions;

/**
 * Convert a MaterialSide to its Three.js constant value (internal use only).
 * 
 * @ignore
 */
function material_side_to_int(side) {
  if (side instanceof FrontSide) {
    return get_front_side_constant();
  } else if (side instanceof BackSide) {
    return get_back_side_constant();
  } else {
    return get_double_side_constant();
  }
}

/**
 * Returns default renderer options: fullscreen, antialiased, opaque background.
 *
 * Equivalent to `RendererOptions(antialias: True, alpha: False, dimensions: option.None)`.
 *
 * See [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer)
 * for all available options in Three.js.
 */
export function default_renderer_options() {
  return new RendererOptions(true, false, new $option.None());
}

/**
 * Creates a [MeshBasicMaterial](https://threejs.org/docs/#api/en/materials/MeshBasicMaterial).
 *
 * A simple material that is not affected by lights. Displays a flat color
 * or texture. Useful for unlit objects, wireframes, and debugging.
 *
 * ## Parameters
 *
 * - `color` - Base color as hex (e.g., `0xff0000` for red)
 * - `transparent` - Enable transparency (required for opacity < 1.0)
 * - `opacity` - Opacity from 0.0 (invisible) to 1.0 (opaque)
 * - `map` - Optional color texture
 * - `side` - Which sides of faces to render (FrontSide, BackSide, or DoubleSide)
 * - `alpha_test` - Pixels with alpha below this value won't be rendered (0.0-1.0)
 * - `depth_write` - Whether to write to depth buffer (set False for transparent objects)
 *
 * ## Example
 *
 * ```gleam
 * // Solid red material
 * let red = create_basic_material(
 *   0xff0000, False, 1.0, option.None,
 *   FrontSide, 0.0, True,
 * )
 *
 * // Transparent sprite with alpha cutoff
 * let sprite = create_basic_material(
 *   0xffffff, True, 1.0, option.Some(texture),
 *   DoubleSide, 0.1, False,
 * )
 * ```
 */
export function create_basic_material(
  color,
  transparent,
  opacity,
  map,
  side,
  alpha_test,
  depth_write
) {
  return create_basic_material_ffi(
    color,
    transparent,
    opacity,
    map,
    material_side_to_int(side),
    alpha_test,
    depth_write,
  );
}

/**
 * Creates a [DirectionalLight](https://threejs.org/docs/#api/en/lights/DirectionalLight).
 *
 * A light that shines in a specific direction, as if from infinitely far away
 * (like the sun). All rays are parallel. Can cast shadows.
 *
 * ## Parameters
 *
 * - `color` - Light color as hex
 * - `intensity` - Light strength
 * - `cast_shadow` - Enable shadow casting
 * - `shadow_resolution` - Shadow map size (e.g., 1024, 2048). Higher = sharper shadows
 * - `shadow_bias` - Bias to prevent shadow acne. Typical: -0.0001 to -0.001
 *
 * ## Example
 *
 * ```gleam
 * let shadow_config = DirectionalShadowConfig(
 *   resolution: 2048,
 *   bias: -0.0001,
 *   normal_bias: 0.5,
 *   camera_left: -200.0, camera_right: 200.0,
 *   camera_top: 200.0, camera_bottom: -200.0,
 *   camera_near: 0.5, camera_far: 500.0,
 * )
 * let sun = create_directional_light(0xffffff, 1.0, True, shadow_config)
 * ```
 */
export function create_directional_light(
  color,
  intensity,
  cast_shadow,
  shadow_config
) {
  return create_directional_light_ffi(
    color,
    intensity,
    cast_shadow,
    shadow_config.resolution,
    shadow_config.bias,
    shadow_config.normal_bias,
    shadow_config.camera_left,
    shadow_config.camera_right,
    shadow_config.camera_top,
    shadow_config.camera_bottom,
    shadow_config.camera_near,
    shadow_config.camera_far,
  );
}

/**
 * Creates a [PointLight](https://threejs.org/docs/#api/en/lights/PointLight).
 *
 * A light that emits in all directions from a single point (like a light bulb).
 * Intensity falls off with distance. Can cast shadows (expensive).
 *
 * ## Parameters
 *
 * - `color` - Light color as hex
 * - `intensity` - Light strength
 * - `distance` - Maximum range (0 = no limit, light decays naturally)
 * - `cast_shadow` - Enable shadow casting (uses cube shadow map, expensive)
 * - `shadow_config` - Shadow configuration (resolution, bias, normal_bias)
 */
export function create_point_light(
  color,
  intensity,
  distance,
  cast_shadow,
  shadow_config
) {
  return create_point_light_ffi(
    color,
    intensity,
    distance,
    cast_shadow,
    shadow_config.resolution,
    shadow_config.bias,
    shadow_config.normal_bias,
  );
}

/**
 * Creates a [SpotLight](https://threejs.org/docs/#api/en/lights/SpotLight).
 *
 * A light that emits in a cone from a single point (like a flashlight or stage light).
 * Can cast shadows with a single shadow map.
 *
 * ## Parameters
 *
 * - `color` - Light color as hex
 * - `intensity` - Light strength
 * - `distance` - Maximum range (0 = no limit)
 * - `angle` - Maximum cone angle in radians (max: π/2)
 * - `penumbra` - Soft edge percentage (0 = hard edge, 1 = fully soft)
 * - `cast_shadow` - Enable shadow casting
 * - `shadow_config` - Shadow configuration (resolution, bias, normal_bias)
 */
export function create_spot_light(
  color,
  intensity,
  distance,
  angle,
  penumbra,
  cast_shadow,
  shadow_config
) {
  return create_spot_light_ffi(
    color,
    intensity,
    distance,
    angle,
    penumbra,
    cast_shadow,
    shadow_config.resolution,
    shadow_config.bias,
    shadow_config.normal_bias,
  );
}

function wrap_mode_to_int(mode) {
  if (mode instanceof RepeatWrapping) {
    return get_repeat_wrapping_constant();
  } else if (mode instanceof ClampToEdgeWrapping) {
    return get_clamp_to_edge_wrapping_constant();
  } else {
    return get_mirrored_repeat_wrapping_constant();
  }
}

/**
 * Sets the texture wrapping mode.
 *
 * Wraps [Texture.wrapS](https://threejs.org/docs/#api/en/textures/Texture.wrapS) and
 * [Texture.wrapT](https://threejs.org/docs/#api/en/textures/Texture.wrapT).
 *
 * ## Example
 *
 * ```gleam
 * set_texture_wrap_mode(texture, RepeatWrapping, RepeatWrapping)
 * ```
 */
export function set_texture_wrap_mode(texture, wrap_s, wrap_t) {
  return set_texture_wrap_mode_internal(
    texture,
    wrap_mode_to_int(wrap_s),
    wrap_mode_to_int(wrap_t),
  );
}

function filter_mode_to_int(mode) {
  if (mode instanceof NearestFilter) {
    return get_nearest_filter_constant();
  } else {
    return get_linear_filter_constant();
  }
}

/**
 * Sets the texture filtering mode.
 *
 * Wraps [Texture.minFilter](https://threejs.org/docs/#api/en/textures/Texture.minFilter) and
 * [Texture.magFilter](https://threejs.org/docs/#api/en/textures/Texture.magFilter).
 *
 * ## Example
 *
 * ```gleam
 * // For pixel art
 * set_texture_filter_mode(texture, NearestFilter, NearestFilter)
 *
 * // For smooth textures
 * set_texture_filter_mode(texture, LinearFilter, LinearFilter)
 * ```
 */
export function set_texture_filter_mode(texture, min_filter, mag_filter) {
  return set_texture_filter_mode_internal(
    texture,
    filter_mode_to_int(min_filter),
    filter_mode_to_int(mag_filter),
  );
}

function loop_mode_to_int(mode) {
  if (mode instanceof LoopOnce) {
    return get_loop_once_constant();
  } else if (mode instanceof LoopRepeat) {
    return get_loop_repeat_constant();
  } else {
    return get_loop_ping_pong_constant();
  }
}

/**
 * Sets the loop mode of an animation action.
 *
 * Wraps [AnimationAction.loop](https://threejs.org/docs/#api/en/animation/AnimationAction.loop).
 *
 * ## Example
 *
 * ```gleam
 * set_action_loop(action, LoopRepeat)  // Loop continuously
 * set_action_loop(action, LoopOnce)    // Play once and stop
 * ```
 */
export function set_action_loop(action, loop_mode) {
  return set_action_loop_internal(action, loop_mode_to_int(loop_mode));
}

function blending_mode_to_int(mode) {
  if (mode instanceof AdditiveBlending) {
    return get_additive_blending_constant();
  } else {
    return get_normal_blending_constant();
  }
}

/**
 * Creates a [PointsMaterial](https://threejs.org/docs/#api/en/materials/PointsMaterial).
 *
 * Material for Points (particle) objects. Each vertex is rendered as a point/sprite.
 *
 * ## Parameters
 *
 * - `size` - Point size in world units (or pixels if size_attenuation is False)
 * - `vertex_colors` - Use per-vertex colors from geometry
 * - `transparent` - Enable transparency
 * - `opacity` - Opacity value
 * - `depth_write` - Write to depth buffer (False for additive particles)
 * - `blending` - Blending mode (AdditiveBlending for glow, NormalBlending for standard)
 * - `size_attenuation` - If True, points get smaller with distance
 *
 * ## Example
 *
 * ```gleam
 * // Additive particle material for glow effects
 * let particles = create_points_material(
 *   0.1, False, True, 0.8,
 *   False, AdditiveBlending, True
 * )
 * ```
 */
export function create_points_material(
  size,
  vertex_colors,
  transparent,
  opacity,
  depth_write,
  blending,
  size_attenuation
) {
  return create_points_material_internal(
    size,
    vertex_colors,
    transparent,
    opacity,
    depth_write,
    blending_mode_to_int(blending),
    size_attenuation,
  );
}

/**
 * Applies a texture to all materials in an object hierarchy.
 *
 * Traverses the object and sets the texture as the `map` property on all materials.
 *
 * ## Parameters
 *
 * - `object` - The object hierarchy
 * - `texture` - The texture to apply
 * - `filter_mode` - NearestFilter for pixel art, LinearFilter for smooth textures
 *
 * ## Example
 *
 * ```gleam
 * // Apply pixel-art texture
 * apply_texture_to_object(floor_model, dungeon_texture, NearestFilter)
 * ```
 */
export function apply_texture_to_object(object, texture, filter_mode) {
  return apply_texture_to_object_internal(
    object,
    texture,
    filter_mode_to_int(filter_mode),
  );
}
