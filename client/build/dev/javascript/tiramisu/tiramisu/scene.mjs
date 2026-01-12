import * as $array from "../../gleam_javascript/gleam/javascript/array.mjs";
import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import { identity as coerce } from "../../gleam_stdlib/gleam/function.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $order from "../../gleam_stdlib/gleam/order.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $paint from "../../paint/paint.mjs";
import * as $paint_encode from "../../paint/paint/encode.mjs";
import * as $window from "../../plinth/plinth/browser/window.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import * as $vec2 from "../../vec/vec/vec2.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import * as $vec3f from "../../vec/vec/vec3f.mjs";
import {
  Ok,
  Error,
  toList,
  prepend as listPrepend,
  CustomType as $CustomType,
  divideFloat,
  isEqual,
} from "../gleam.mjs";
import {
  appendElementToContainer as append_element_to_container,
  createCanvasTextureFromPicture as create_canvas_texture_from_picture,
  createCanvasPlane as create_canvas_plane,
  updateCanvasTexture as update_canvas_texture,
  updateCanvasSize as update_canvas_size,
  getCanvasCachedPicture as get_canvas_cached_picture,
  setCanvasCachedPicture as set_canvas_cached_picture,
  createDebugBox as create_debug_box,
  createDebugSphere as create_debug_sphere,
  createDebugLine as create_debug_line,
  createDebugAxes as create_debug_axes,
  createDebugGrid as create_debug_grid,
  createDebugPoint as create_debug_point,
} from "../tiramisu.ffi.mjs";
import * as $audio from "../tiramisu/audio.mjs";
import * as $camera from "../tiramisu/camera.mjs";
import * as $geometry from "../tiramisu/geometry.mjs";
import * as $audio_manager from "../tiramisu/internal/audio_manager.mjs";
import * as $object_cache from "../tiramisu/internal/object_cache.mjs";
import * as $light from "../tiramisu/light.mjs";
import * as $material from "../tiramisu/material.mjs";
import * as $model from "../tiramisu/model.mjs";
import * as $physics from "../tiramisu/physics.mjs";
import * as $spritesheet from "../tiramisu/spritesheet.mjs";
import * as $texture from "../tiramisu/texture.mjs";
import * as $transform from "../tiramisu/transform.mjs";
import {
  createHeadlessScene as create_headless_scene_ffi,
  createHeadlessRenderer as create_headless_renderer_ffi,
  createMockAudioListener as create_mock_audio_listener_ffi,
} from "./simulate.ffi.mjs";

export class LODLevel extends $CustomType {
  constructor(distance, node) {
    super();
    this.distance = distance;
    this.node = node;
  }
}
export const LODLevel$LODLevel = (distance, node) =>
  new LODLevel(distance, node);
export const LODLevel$isLODLevel = (value) => value instanceof LODLevel;
export const LODLevel$LODLevel$distance = (value) => value.distance;
export const LODLevel$LODLevel$0 = (value) => value.distance;
export const LODLevel$LODLevel$node = (value) => value.node;
export const LODLevel$LODLevel$1 = (value) => value.node;

/**
 * Empty node for organization, pivot points, and grouping without visual representation.
 * Replaces the old Group type with clearer intent.
 * 
 * @ignore
 */
class Empty extends $CustomType {
  constructor(id, children, transform) {
    super();
    this.id = id;
    this.children = children;
    this.transform = transform;
  }
}

class Mesh extends $CustomType {
  constructor(id, children, transform, geometry, material, physics) {
    super();
    this.id = id;
    this.children = children;
    this.transform = transform;
    this.geometry = geometry;
    this.material = material;
    this.physics = physics;
  }
}

class InstancedMesh extends $CustomType {
  constructor(id, children, geometry, material, instances) {
    super();
    this.id = id;
    this.children = children;
    this.geometry = geometry;
    this.material = material;
    this.instances = instances;
  }
}

class Light extends $CustomType {
  constructor(id, children, transform, light) {
    super();
    this.id = id;
    this.children = children;
    this.transform = transform;
    this.light = light;
  }
}

class Camera extends $CustomType {
  constructor(id, children, camera, transform, active, viewport, postprocessing) {
    super();
    this.id = id;
    this.children = children;
    this.camera = camera;
    this.transform = transform;
    this.active = active;
    this.viewport = viewport;
    this.postprocessing = postprocessing;
  }
}

class LOD extends $CustomType {
  constructor(id, children, levels, transform) {
    super();
    this.id = id;
    this.children = children;
    this.levels = levels;
    this.transform = transform;
  }
}

class Model3D extends $CustomType {
  constructor(id, children, object, transform, animation, physics, material, transparent) {
    super();
    this.id = id;
    this.children = children;
    this.object = object;
    this.transform = transform;
    this.animation = animation;
    this.physics = physics;
    this.material = material;
    this.transparent = transparent;
  }
}

class InstancedModel extends $CustomType {
  constructor(id, children, object, instances, physics, material, transparent) {
    super();
    this.id = id;
    this.children = children;
    this.object = object;
    this.instances = instances;
    this.physics = physics;
    this.material = material;
    this.transparent = transparent;
  }
}

class Audio extends $CustomType {
  constructor(id, children, audio) {
    super();
    this.id = id;
    this.children = children;
    this.audio = audio;
  }
}

class CSS2D extends $CustomType {
  constructor(id, children, html, transform) {
    super();
    this.id = id;
    this.children = children;
    this.html = html;
    this.transform = transform;
  }
}

class CSS3D extends $CustomType {
  constructor(id, children, html, transform) {
    super();
    this.id = id;
    this.children = children;
    this.html = html;
    this.transform = transform;
  }
}

class Canvas extends $CustomType {
  constructor(id, children, encoded_picture, texture_width, texture_height, width, height, transform) {
    super();
    this.id = id;
    this.children = children;
    this.encoded_picture = encoded_picture;
    this.texture_width = texture_width;
    this.texture_height = texture_height;
    this.width = width;
    this.height = height;
    this.transform = transform;
  }
}

class AnimatedSprite extends $CustomType {
  constructor(id, children, sprite, width, height, transform, physics) {
    super();
    this.id = id;
    this.children = children;
    this.sprite = sprite;
    this.width = width;
    this.height = height;
    this.transform = transform;
    this.physics = physics;
  }
}

class DebugBox extends $CustomType {
  constructor(id, children, min, max, color) {
    super();
    this.id = id;
    this.children = children;
    this.min = min;
    this.max = max;
    this.color = color;
  }
}

class DebugSphere extends $CustomType {
  constructor(id, children, center, radius, color) {
    super();
    this.id = id;
    this.children = children;
    this.center = center;
    this.radius = radius;
    this.color = color;
  }
}

class DebugLine extends $CustomType {
  constructor(id, children, from, to, color) {
    super();
    this.id = id;
    this.children = children;
    this.from = from;
    this.to = to;
    this.color = color;
  }
}

class DebugAxes extends $CustomType {
  constructor(id, children, origin, size) {
    super();
    this.id = id;
    this.children = children;
    this.origin = origin;
    this.size = size;
  }
}

class DebugGrid extends $CustomType {
  constructor(id, children, size, divisions, color) {
    super();
    this.id = id;
    this.children = children;
    this.size = size;
    this.divisions = divisions;
    this.color = color;
  }
}

class DebugPoint extends $CustomType {
  constructor(id, children, position, size, color) {
    super();
    this.id = id;
    this.children = children;
    this.position = position;
    this.size = size;
    this.color = color;
  }
}

export class AddNode extends $CustomType {
  constructor(id, node, parent_id) {
    super();
    this.id = id;
    this.node = node;
    this.parent_id = parent_id;
  }
}
export const Patch$AddNode = (id, node, parent_id) =>
  new AddNode(id, node, parent_id);
export const Patch$isAddNode = (value) => value instanceof AddNode;
export const Patch$AddNode$id = (value) => value.id;
export const Patch$AddNode$0 = (value) => value.id;
export const Patch$AddNode$node = (value) => value.node;
export const Patch$AddNode$1 = (value) => value.node;
export const Patch$AddNode$parent_id = (value) => value.parent_id;
export const Patch$AddNode$2 = (value) => value.parent_id;

export class RemoveNode extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Patch$RemoveNode = (id) => new RemoveNode(id);
export const Patch$isRemoveNode = (value) => value instanceof RemoveNode;
export const Patch$RemoveNode$id = (value) => value.id;
export const Patch$RemoveNode$0 = (value) => value.id;

export class UpdateTransform extends $CustomType {
  constructor(id, transform) {
    super();
    this.id = id;
    this.transform = transform;
  }
}
export const Patch$UpdateTransform = (id, transform) =>
  new UpdateTransform(id, transform);
export const Patch$isUpdateTransform = (value) =>
  value instanceof UpdateTransform;
export const Patch$UpdateTransform$id = (value) => value.id;
export const Patch$UpdateTransform$0 = (value) => value.id;
export const Patch$UpdateTransform$transform = (value) => value.transform;
export const Patch$UpdateTransform$1 = (value) => value.transform;

export class UpdateMaterial extends $CustomType {
  constructor(id, material) {
    super();
    this.id = id;
    this.material = material;
  }
}
export const Patch$UpdateMaterial = (id, material) =>
  new UpdateMaterial(id, material);
export const Patch$isUpdateMaterial = (value) =>
  value instanceof UpdateMaterial;
export const Patch$UpdateMaterial$id = (value) => value.id;
export const Patch$UpdateMaterial$0 = (value) => value.id;
export const Patch$UpdateMaterial$material = (value) => value.material;
export const Patch$UpdateMaterial$1 = (value) => value.material;

export class UpdateGeometry extends $CustomType {
  constructor(id, geometry) {
    super();
    this.id = id;
    this.geometry = geometry;
  }
}
export const Patch$UpdateGeometry = (id, geometry) =>
  new UpdateGeometry(id, geometry);
export const Patch$isUpdateGeometry = (value) =>
  value instanceof UpdateGeometry;
export const Patch$UpdateGeometry$id = (value) => value.id;
export const Patch$UpdateGeometry$0 = (value) => value.id;
export const Patch$UpdateGeometry$geometry = (value) => value.geometry;
export const Patch$UpdateGeometry$1 = (value) => value.geometry;

export class UpdateLight extends $CustomType {
  constructor(id, light) {
    super();
    this.id = id;
    this.light = light;
  }
}
export const Patch$UpdateLight = (id, light) => new UpdateLight(id, light);
export const Patch$isUpdateLight = (value) => value instanceof UpdateLight;
export const Patch$UpdateLight$id = (value) => value.id;
export const Patch$UpdateLight$0 = (value) => value.id;
export const Patch$UpdateLight$light = (value) => value.light;
export const Patch$UpdateLight$1 = (value) => value.light;

export class UpdateAnimation extends $CustomType {
  constructor(id, animation) {
    super();
    this.id = id;
    this.animation = animation;
  }
}
export const Patch$UpdateAnimation = (id, animation) =>
  new UpdateAnimation(id, animation);
export const Patch$isUpdateAnimation = (value) =>
  value instanceof UpdateAnimation;
export const Patch$UpdateAnimation$id = (value) => value.id;
export const Patch$UpdateAnimation$0 = (value) => value.id;
export const Patch$UpdateAnimation$animation = (value) => value.animation;
export const Patch$UpdateAnimation$1 = (value) => value.animation;

export class UpdatePhysics extends $CustomType {
  constructor(id, physics) {
    super();
    this.id = id;
    this.physics = physics;
  }
}
export const Patch$UpdatePhysics = (id, physics) =>
  new UpdatePhysics(id, physics);
export const Patch$isUpdatePhysics = (value) => value instanceof UpdatePhysics;
export const Patch$UpdatePhysics$id = (value) => value.id;
export const Patch$UpdatePhysics$0 = (value) => value.id;
export const Patch$UpdatePhysics$physics = (value) => value.physics;
export const Patch$UpdatePhysics$1 = (value) => value.physics;

export class UpdateAudio extends $CustomType {
  constructor(id, audio) {
    super();
    this.id = id;
    this.audio = audio;
  }
}
export const Patch$UpdateAudio = (id, audio) => new UpdateAudio(id, audio);
export const Patch$isUpdateAudio = (value) => value instanceof UpdateAudio;
export const Patch$UpdateAudio$id = (value) => value.id;
export const Patch$UpdateAudio$0 = (value) => value.id;
export const Patch$UpdateAudio$audio = (value) => value.audio;
export const Patch$UpdateAudio$1 = (value) => value.audio;

export class UpdateInstances extends $CustomType {
  constructor(id, instances) {
    super();
    this.id = id;
    this.instances = instances;
  }
}
export const Patch$UpdateInstances = (id, instances) =>
  new UpdateInstances(id, instances);
export const Patch$isUpdateInstances = (value) =>
  value instanceof UpdateInstances;
export const Patch$UpdateInstances$id = (value) => value.id;
export const Patch$UpdateInstances$0 = (value) => value.id;
export const Patch$UpdateInstances$instances = (value) => value.instances;
export const Patch$UpdateInstances$1 = (value) => value.instances;

export class UpdateLODLevels extends $CustomType {
  constructor(id, levels) {
    super();
    this.id = id;
    this.levels = levels;
  }
}
export const Patch$UpdateLODLevels = (id, levels) =>
  new UpdateLODLevels(id, levels);
export const Patch$isUpdateLODLevels = (value) =>
  value instanceof UpdateLODLevels;
export const Patch$UpdateLODLevels$id = (value) => value.id;
export const Patch$UpdateLODLevels$0 = (value) => value.id;
export const Patch$UpdateLODLevels$levels = (value) => value.levels;
export const Patch$UpdateLODLevels$1 = (value) => value.levels;

export class UpdateCamera extends $CustomType {
  constructor(id, camera_type) {
    super();
    this.id = id;
    this.camera_type = camera_type;
  }
}
export const Patch$UpdateCamera = (id, camera_type) =>
  new UpdateCamera(id, camera_type);
export const Patch$isUpdateCamera = (value) => value instanceof UpdateCamera;
export const Patch$UpdateCamera$id = (value) => value.id;
export const Patch$UpdateCamera$0 = (value) => value.id;
export const Patch$UpdateCamera$camera_type = (value) => value.camera_type;
export const Patch$UpdateCamera$1 = (value) => value.camera_type;

export class SetActiveCamera extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Patch$SetActiveCamera = (id) => new SetActiveCamera(id);
export const Patch$isSetActiveCamera = (value) =>
  value instanceof SetActiveCamera;
export const Patch$SetActiveCamera$id = (value) => value.id;
export const Patch$SetActiveCamera$0 = (value) => value.id;

export class UpdateCameraPostprocessing extends $CustomType {
  constructor(id, postprocessing) {
    super();
    this.id = id;
    this.postprocessing = postprocessing;
  }
}
export const Patch$UpdateCameraPostprocessing = (id, postprocessing) =>
  new UpdateCameraPostprocessing(id, postprocessing);
export const Patch$isUpdateCameraPostprocessing = (value) =>
  value instanceof UpdateCameraPostprocessing;
export const Patch$UpdateCameraPostprocessing$id = (value) => value.id;
export const Patch$UpdateCameraPostprocessing$0 = (value) => value.id;
export const Patch$UpdateCameraPostprocessing$postprocessing = (value) =>
  value.postprocessing;
export const Patch$UpdateCameraPostprocessing$1 = (value) =>
  value.postprocessing;

export class UpdateCSS2DLabel extends $CustomType {
  constructor(id, html, transform) {
    super();
    this.id = id;
    this.html = html;
    this.transform = transform;
  }
}
export const Patch$UpdateCSS2DLabel = (id, html, transform) =>
  new UpdateCSS2DLabel(id, html, transform);
export const Patch$isUpdateCSS2DLabel = (value) =>
  value instanceof UpdateCSS2DLabel;
export const Patch$UpdateCSS2DLabel$id = (value) => value.id;
export const Patch$UpdateCSS2DLabel$0 = (value) => value.id;
export const Patch$UpdateCSS2DLabel$html = (value) => value.html;
export const Patch$UpdateCSS2DLabel$1 = (value) => value.html;
export const Patch$UpdateCSS2DLabel$transform = (value) => value.transform;
export const Patch$UpdateCSS2DLabel$2 = (value) => value.transform;

export class UpdateCSS3DLabel extends $CustomType {
  constructor(id, html, transform) {
    super();
    this.id = id;
    this.html = html;
    this.transform = transform;
  }
}
export const Patch$UpdateCSS3DLabel = (id, html, transform) =>
  new UpdateCSS3DLabel(id, html, transform);
export const Patch$isUpdateCSS3DLabel = (value) =>
  value instanceof UpdateCSS3DLabel;
export const Patch$UpdateCSS3DLabel$id = (value) => value.id;
export const Patch$UpdateCSS3DLabel$0 = (value) => value.id;
export const Patch$UpdateCSS3DLabel$html = (value) => value.html;
export const Patch$UpdateCSS3DLabel$1 = (value) => value.html;
export const Patch$UpdateCSS3DLabel$transform = (value) => value.transform;
export const Patch$UpdateCSS3DLabel$2 = (value) => value.transform;

export class UpdateCanvas extends $CustomType {
  constructor(id, encoded_picture, texture_width, texture_height, width, height, transform) {
    super();
    this.id = id;
    this.encoded_picture = encoded_picture;
    this.texture_width = texture_width;
    this.texture_height = texture_height;
    this.width = width;
    this.height = height;
    this.transform = transform;
  }
}
export const Patch$UpdateCanvas = (id, encoded_picture, texture_width, texture_height, width, height, transform) =>
  new UpdateCanvas(id,
  encoded_picture,
  texture_width,
  texture_height,
  width,
  height,
  transform);
export const Patch$isUpdateCanvas = (value) => value instanceof UpdateCanvas;
export const Patch$UpdateCanvas$id = (value) => value.id;
export const Patch$UpdateCanvas$0 = (value) => value.id;
export const Patch$UpdateCanvas$encoded_picture = (value) =>
  value.encoded_picture;
export const Patch$UpdateCanvas$1 = (value) => value.encoded_picture;
export const Patch$UpdateCanvas$texture_width = (value) => value.texture_width;
export const Patch$UpdateCanvas$2 = (value) => value.texture_width;
export const Patch$UpdateCanvas$texture_height = (value) =>
  value.texture_height;
export const Patch$UpdateCanvas$3 = (value) => value.texture_height;
export const Patch$UpdateCanvas$width = (value) => value.width;
export const Patch$UpdateCanvas$4 = (value) => value.width;
export const Patch$UpdateCanvas$height = (value) => value.height;
export const Patch$UpdateCanvas$5 = (value) => value.height;
export const Patch$UpdateCanvas$transform = (value) => value.transform;
export const Patch$UpdateCanvas$6 = (value) => value.transform;

export class UpdateAnimatedSprite extends $CustomType {
  constructor(id, sprite, width, height, transform) {
    super();
    this.id = id;
    this.sprite = sprite;
    this.width = width;
    this.height = height;
    this.transform = transform;
  }
}
export const Patch$UpdateAnimatedSprite = (id, sprite, width, height, transform) =>
  new UpdateAnimatedSprite(id, sprite, width, height, transform);
export const Patch$isUpdateAnimatedSprite = (value) =>
  value instanceof UpdateAnimatedSprite;
export const Patch$UpdateAnimatedSprite$id = (value) => value.id;
export const Patch$UpdateAnimatedSprite$0 = (value) => value.id;
export const Patch$UpdateAnimatedSprite$sprite = (value) => value.sprite;
export const Patch$UpdateAnimatedSprite$1 = (value) => value.sprite;
export const Patch$UpdateAnimatedSprite$width = (value) => value.width;
export const Patch$UpdateAnimatedSprite$2 = (value) => value.width;
export const Patch$UpdateAnimatedSprite$height = (value) => value.height;
export const Patch$UpdateAnimatedSprite$3 = (value) => value.height;
export const Patch$UpdateAnimatedSprite$transform = (value) => value.transform;
export const Patch$UpdateAnimatedSprite$4 = (value) => value.transform;

export const Patch$id = (value) => value.id;

class NodeWithParent extends $CustomType {
  constructor(node, parent_id, depth) {
    super();
    this.node = node;
    this.parent_id = parent_id;
    this.depth = depth;
  }
}

export class RendererState extends $CustomType {
  constructor(renderer, scene, cache, physics_world, audio_manager, audio_listener, cached_scene_dict, css2d_renderer, css3d_renderer) {
    super();
    this.renderer = renderer;
    this.scene = scene;
    this.cache = cache;
    this.physics_world = physics_world;
    this.audio_manager = audio_manager;
    this.audio_listener = audio_listener;
    this.cached_scene_dict = cached_scene_dict;
    this.css2d_renderer = css2d_renderer;
    this.css3d_renderer = css3d_renderer;
  }
}
export const RendererState$RendererState = (renderer, scene, cache, physics_world, audio_manager, audio_listener, cached_scene_dict, css2d_renderer, css3d_renderer) =>
  new RendererState(renderer,
  scene,
  cache,
  physics_world,
  audio_manager,
  audio_listener,
  cached_scene_dict,
  css2d_renderer,
  css3d_renderer);
export const RendererState$isRendererState = (value) =>
  value instanceof RendererState;
export const RendererState$RendererState$renderer = (value) => value.renderer;
export const RendererState$RendererState$0 = (value) => value.renderer;
export const RendererState$RendererState$scene = (value) => value.scene;
export const RendererState$RendererState$1 = (value) => value.scene;
export const RendererState$RendererState$cache = (value) => value.cache;
export const RendererState$RendererState$2 = (value) => value.cache;
export const RendererState$RendererState$physics_world = (value) =>
  value.physics_world;
export const RendererState$RendererState$3 = (value) => value.physics_world;
export const RendererState$RendererState$audio_manager = (value) =>
  value.audio_manager;
export const RendererState$RendererState$4 = (value) => value.audio_manager;
export const RendererState$RendererState$audio_listener = (value) =>
  value.audio_listener;
export const RendererState$RendererState$5 = (value) => value.audio_listener;
export const RendererState$RendererState$cached_scene_dict = (value) =>
  value.cached_scene_dict;
export const RendererState$RendererState$6 = (value) => value.cached_scene_dict;
export const RendererState$RendererState$css2d_renderer = (value) =>
  value.css2d_renderer;
export const RendererState$RendererState$7 = (value) => value.css2d_renderer;
export const RendererState$RendererState$css3d_renderer = (value) =>
  value.css3d_renderer;
export const RendererState$RendererState$8 = (value) => value.css3d_renderer;

/**
 * Create an LOD level with a distance threshold and scene node.
 *
 * Levels should be ordered from closest (distance: 0.0) to farthest.
 *
 * ## Example
 *
 * ```gleam
 * let high_detail = scene.lod_level(distance: 0.0, node: detailed_mesh)
 * let low_detail = scene.lod_level(distance: 100.0, node: simple_mesh)
 * ```
 */
export function lod_level(distance, node) {
  return new LODLevel(distance, node);
}

/**
 * Create a mesh scene node.
 *
 * Meshes are the basic building blocks for 3D objects. They combine geometry (shape),
 * material (appearance), and transform (position/rotation/scale).
 *
 * **Physics**: Optional rigid body for physics simulation.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/geometry
 * import tiramisu/material
 * import tiramisu/transform
 * import gleam/option
 * import vec/vec3
 *
 * // Create a red cube
 * let assert Ok(cube_geo) = geometry.box(width: 1.0, height: 1.0, depth: 1.0)
 * let assert Ok(red_mat) = material.new()
 *   |> material.with_color(0xff0000)
 *   |> material.build()
 *
 * scene.mesh(
 *   id: "player",
 *   geometry: cube_geo,
 *   material: red_mat,
 *   transform: transform.at(position: vec3.Vec3(0.0, 1.0, 0.0)),
 *   physics: option.None,
 *   children: [],
 * )
 * ```
 */
export function mesh(id, geometry, material, transform, physics) {
  return new Mesh(id, toList([]), transform, geometry, material, physics);
}

/**
 * Create an instanced mesh for rendering many identical objects efficiently.
 *
 * Instead of creating N separate meshes (N draw calls), instanced meshes render all
 * instances in a single draw call. Perfect for forests, crowds, particles, or any
 * scene with many repeated objects.
 *
 * **Performance**: Use this when you have 10+ identical objects for significant speedup.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/geometry
 * import tiramisu/material
 * import tiramisu/transform
 * import vec/vec3
 * import gleam/list
 *
 * // Create 100 trees efficiently
 * let assert Ok(tree_geo) = geometry.cylinder(radius: 0.2, height: 3.0)
 * let assert Ok(tree_mat) = material.lambert(
 *   color: 0x8b4513,
 *   map: option.None,
 *   normal_map: option.None,
 *   ambient_oclusion_map: option.None,
 * )
 *
 * let tree_positions = list.range(0, 99)
 *   |> list.map(fn(i) {
 *     let x = int.to_float(i % 10) *. 5.0
 *     let z = int.to_float(i / 10) *. 5.0
 *     transform.at(position: vec3.Vec3(x, 0.0, z))
 *   })
 *
 * scene.InstancedMesh(
 *   id: "forest",
 *   geometry: tree_geo,
 *   material: tree_mat,
 *   instances: tree_positions,  // All rendered in 1 draw call!
 * )
 * ```
 */
export function instanced_mesh(id, geometry, material, instances) {
  return new InstancedMesh(id, toList([]), geometry, material, instances);
}

/**
 * Create an empty node for organization, pivot points, or grouping.
 *
 * Empty nodes don't render anything but are useful for organizing your scene hierarchy,
 * creating pivot points for rotation/animation, or grouping related objects.
 *
 * This replaces the old `group` function with clearer intent.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/transform
 *
 * // Group car parts together
 * scene.empty(
 *   id: "car",
 *   transform: car_transform,
 *   children: [
 *     scene.mesh(id: "body", ..., children: []),
 *     scene.mesh(id: "wheel-fl", ..., children: []),
 *     scene.mesh(id: "wheel-fr", ..., children: []),
 *   ],
 * )
 * ```
 */
export function empty(id, transform, children) {
  return new Empty(id, children, transform);
}

/**
 * Create a light scene node.
 *
 * Lights illuminate the scene. See the `light` module for different light types
 * (ambient, directional, point, spot, hemisphere).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/light
 * import tiramisu/transform
 * import vec/vec3
 *
 * // Directional sun light
 * let assert Ok(sun) = light.directional(intensity: 1.2, color: 0xffffff)
 *   |> light.with_shadows(True)
 *
 * scene.light(
 *   id: "sun",
 *   light: sun,
 *   transform: transform.identity
 *     |> transform.with_euler_rotation(vec3.Vec3(-0.8, 0.3, 0.0)),
 * )
 * ```
 */
export function light(id, light, transform) {
  return new Light(id, toList([]), transform, light);
}

/**
 * Create a camera scene node.
 *
 * Cameras define the viewpoint for rendering. At least one active camera is required.
 * Multiple cameras can be used for split-screen, minimaps, or picture-in-picture.
 *
 * **Active**: Only active cameras render. Set to `True` for at least one camera.
 * **Look At**: Optional target point the camera faces (camera auto-rotates to face it).
 * **Viewport**: Optional screen region for this camera (for split-screen).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/camera
 * import tiramisu/transform
 * import vec/vec3
 * import gleam/option
 *
 * // Main perspective camera
 * let assert Ok(cam) = camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)
 *
 * scene.camera(
 *   id: "main-camera",
 *   camera: cam,
 *   transform: transform.at(position: vec3.Vec3(0.0, 5.0, 10.0)),
 *   active: True,
 *   viewport: option.None,  // Fullscreen
 * )
 *
 * // Minimap camera (top-down view in corner)
 * let assert Ok(minimap_cam) = camera.orthographic(
 *   left: -20.0, right: 20.0, top: 20.0, bottom: -20.0, near: 0.1, far: 100.0
 * )
 *
 * scene.camera(
 *   id: "minimap",
 *   camera: minimap_cam,
 *   transform: transform.at(position: vec3.Vec3(0.0, 50.0, 0.0))
 *     |> transform.with_euler_rotation(vec3.Vec3(-1.57, 0.0, 0.0)),
 *   active: True,
 *   viewport: option.Some(camera.ViewPort(position: vec2.Vec2(10, 10), size: vec2.Vec2(200, 200))),
 * )
 * ```
 */
export function camera(id, camera, transform, active, viewport, postprocessing) {
  return new Camera(
    id,
    toList([]),
    camera,
    transform,
    active,
    $option.map(
      viewport,
      (viewport) => {
        return [
          viewport.position.x,
          viewport.position.y,
          viewport.size.x,
          viewport.size.y,
        ];
      },
    ),
    postprocessing,
  );
}

/**
 * Create a Level of Detail (LOD) node.
 *
 * LOD nodes automatically switch between different detail levels based on camera distance,
 * improving performance by showing simpler models when far away.
 *
 * **Levels**: Ordered list from closest (distance: 0.0) to farthest. Use `lod_level()` to create.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/geometry
 * import tiramisu/material
 * import tiramisu/transform
 * import gleam/option
 *
 * // High detail mesh (shown up close)
 * let assert Ok(high_geo) = geometry.sphere(radius: 1.0, width_segments: 32, height_segments: 32)
 * let assert Ok(mat) = material.new() |> material.with_color(0x00ff00) |> material.build()
 * let high_detail = scene.mesh(
 *   id: "tree-high",
 *   geometry: high_geo,
 *   material: mat,
 *   transform: transform.identity,
 *   physics: option.None,
 * )
 *
 * // Low detail mesh (shown far away)
 * let assert Ok(low_geo) = geometry.sphere(radius: 1.0, width_segments: 8, height_segments: 8)
 * let low_detail = scene.mesh(
 *   id: "tree-low",
 *   geometry: low_geo,
 *   material: mat,
 *   transform: transform.identity,
 *   physics: option.None,
 * )
 *
 * scene.lod(
 *   id: "optimized-tree",
 *   levels: [
 *     scene.lod_level(distance: 0.0, node: high_detail),   // 0-50 units away
 *     scene.lod_level(distance: 50.0, node: low_detail),   // 50+ units away
 *   ],
 *   transform: transform.identity,
 * )
 * ```
 */
export function lod(id, levels, transform) {
  return new LOD(id, toList([]), levels, transform);
}

/**
 * Create a 3D model node from a loaded asset (GLTF, FBX, OBJ).
 *
 * Use this for models loaded via the `model` module. Supports animations and physics.
 *
 * **Animation**: Optional animation playback (single or blended). See `animation` module.
 * **Physics**: Optional rigid body for physics simulation.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/model
 * import tiramisu/transform
 * import vec/vec3
 * import gleam/option
 * import gleam/list
 *
 * // After loading a GLTF model
 * let scene_object = model.get_scene(gltf_data)
 * let clips = model.get_animations(gltf_data)
 *
 * // Find walk animation
 * let walk_clip = list.find(clips, fn(clip) {
 *   model.clip_name(clip) == "Walk"
 * })
 *
 * let walk_anim = model.new_animation(walk_clip)
 *   |> model.set_speed(1.2)
 *   |> model.set_loop(model.LoopRepeat)
 *
 * scene.object_3d(
 *   id: "player",
 *   object: scene_object,
 *   transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0)),
 *   animation: option.Some(model.SingleAnimation(walk_anim)),
 *   physics: option.None,
 *   material: option.None,
 * )
 * ```
 */
export function object_3d(
  id,
  object,
  transform,
  animation,
  physics,
  material,
  transparent
) {
  return new Model3D(
    id,
    toList([]),
    object,
    transform,
    animation,
    physics,
    material,
    transparent,
  );
}

/**
 * Create instanced 3D models for rendering many copies of a loaded asset.
 *
 * Like `InstancedMesh`, but for loaded models (GLTF/FBX/OBJ). Renders all instances
 * in one draw call for maximum performance.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/model
 * import tiramisu/transform
 * import vec/vec3
 * import gleam/option
 * import gleam/list
 *
 * // After loading a GLTF model
 * let rock_scene = model.get_scene(rock_gltf)
 *
 * // Place 50 rocks around the scene
 * let rock_positions = list.range(0, 49)
 *   |> list.map(fn(i) {
 *     let angle = int.to_float(i) *. 0.125
 *     let radius = 20.0
 *     let x = radius *. float.cos(angle)
 *     let z = radius *. float.sin(angle)
 *     transform.at(position: vec3.Vec3(x, 0.0, z))
 *   })
 *
 * scene.instanced_model(
 *   id: "rock-field",
 *   object: rock_scene,
 *   instances: rock_positions,
 *   physics: option.None,
 *   material: option.None,
 * )
 * ```
 */
export function instanced_model(
  id,
  object,
  instances,
  physics,
  material,
  transparent
) {
  return new InstancedModel(
    id,
    toList([]),
    object,
    instances,
    physics,
    material,
    transparent,
  );
}

/**
 * Create an audio scene node.
 *
 * Audio nodes play sounds in the scene. See the `audio` module for creating audio sources.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/audio
 * import gleam/option
 *
 * // Background music
 * let background_music = audio.new_audio("background")
 *   |> audio.with_source(audio.Stream("music/theme.mp3"))
 *   |> audio.with_loop(True)
 *   |> audio.with_volume(0.5)
 *   |> audio.with_autoplay(True)
 *
 * scene.audio(id: "bgm", audio: background_music, children: [])
 *
 * // Sound effect (from pre-loaded buffer)
 * let assert Ok(jump_buffer) = asset.get_audio(cache, "sounds/jump.mp3")
 * let jump_sound = audio.new_audio("jump")
 *   |> audio.with_source(audio.Buffer(jump_buffer))
 *   |> audio.with_volume(0.8)
 *
 * scene.audio(id: "jump-sfx", audio: jump_sound, children: [])
 * ```
 */
export function audio(id, audio) {
  return new Audio(id, toList([]), audio);
}

/**
 * Create a CSS2D label that follows a 3D position in screen space.
 *
 * CSS2D labels are HTML elements that follow 3D objects but always face the camera.
 * Perfect for health bars, nameplates, tooltips, or interactive UI elements.
 *
 * **HTML**: Raw HTML string. Use Lustre's `element.to_string()` for type-safe HTML.
 * **Position**: Offset from parent object (or world position if top-level node).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import vec/vec3
 * import lustre/element/html
 * import lustre/element
 * import lustre/attribute
 *
 * // Option 1: Using Lustre (recommended)
 * let hp_element = html.div([attribute.class("bg-red-500 text-white px-4 py-2")], [
 *   html.text("HP: 100")
 * ])
 * scene.css2d(
 *   id: "player-hp",
 *   html: element.to_string(hp_element),
 *   position: vec3.Vec3(0.0, 2.0, 0.0),
 * )
 *
 * // Option 2: Raw HTML string
 * scene.css2d(
 *   id: "player-name",
 *   html: "<div class='text-white font-bold'>Player</div>",
 *   transform: vec3.Vec3(0.0, 2.5, 0.0),
 * )
 * ```
 */
export function css2d(id, html, transform) {
  return new CSS2D(id, toList([]), html, transform);
}

/**
 * Create a CSS3D label that respects 3D depth and occlusion.
 *
 * CSS3D labels are HTML elements that live "in" 3D space with full transformations.
 * Unlike CSS2D labels (always on top), CSS3D labels hide behind objects and can
 * rotate in 3D. Great for immersive UI elements.
 *
 * **HTML**: Raw HTML string. Use Lustre's `element.to_string()` for type-safe HTML.
 * **Position**: Offset from parent object (or world position if top-level node).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import vec/vec3
 *
 * // Label that hides behind objects
 * scene.css3d(
 *   id: "3d-sign",
 *   html: "<div class='text-white text-2xl'>→ Exit</div>",
 *   transform: vec3.Vec3(0.0, 2.0, 0.0),
 * )
 * ```
 */
export function css3d(id, html, transform) {
  return new CSS3D(id, toList([]), html, transform);
}

/**
 * Create a canvas node with a paint.Picture drawing rendered to a texture.
 *
 * Canvas nodes are Three.js planes with paint.Picture drawings rendered to canvas textures.
 * Unlike CSS2D/CSS3D, they are true 3D meshes that respect depth testing (hide behind objects).
 *
 * Uses the `paint` library for canvas drawing operations.
 *
 * **Picture**: A paint.Picture created using paint's drawing API
 * **Texture Size**: Canvas texture resolution in pixels as Vec2(width, height) (higher = sharper but more memory)
 * **Size**: World space size of the canvas plane as Vec2(width, height)
 * **Transform**: Position, rotation, scale
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/scene
 * import tiramisu/transform
 * import vec/vec2
 * import vec/vec3
 * import paint as p
 *
 * // Create health bar using paint
 * let health_bar = p.combine([
 *   // Background
 *   p.rectangle(256.0, 64.0)
 *     |> p.fill(p.colour_rgb(0, 0, 0)),
 *   // Health bar
 *   p.rectangle(192.0, 20.0)
 *     |> p.translate_xy(10.0, 22.0)
 *     |> p.fill(p.colour_rgb(255, 0, 0)),
 *   // Text
 *   p.text("HP: 75/100", 14.0)
 *     |> p.translate_xy(10.0, 50.0)
 *     |> p.fill(p.colour_rgb(255, 255, 255)),
 * ])
 *
 * scene.canvas(
 *   id: "health",
 *   picture: health_bar,
 *   texture_size: vec2.Vec2(256, 64),
 *   size: vec2.Vec2(2.0, 0.5),
 *   transform: transform.at(position: vec3.Vec3(0.0, 2.0, 0.0)),
 * )
 * ```
 */
export function canvas(id, picture, texture_size, size, transform) {
  let encoded_picture = $paint_encode.to_string(picture);
  return new Canvas(
    id,
    toList([]),
    encoded_picture,
    texture_size.x,
    texture_size.y,
    size.x,
    size.y,
    transform,
  );
}

/**
 * Create an animated sprite node with spritesheet animation.
 *
 * Animated sprites display a textured plane that cycles through frames
 * from a spritesheet. The animation is managed by an AnimationMachine
 * which handles frame advancement and animation state transitions.
 *
 * ## Example
 *
 * ```gleam
 * import gleam/option
 * import gleam/result
 * import gleam/time/duration
 * import tiramisu/scene
 * import tiramisu/spritesheet
 * import vec/vec2
 *
 * // In your init()
 * let assert Ok(machine) =
 *   spritesheet.new(texture: player_texture, columns: 8, rows: 4)
 *   |> result.map(spritesheet.with_animation(
 *     _,
 *     name: "idle",
 *     frames: [0, 1, 2, 3],
 *     frame_duration: duration.milliseconds(100),
 *     loop: spritesheet.Repeat,
 *   ))
 *   |> result.map(spritesheet.with_pixel_art(_, True))
 *
 * let model = Model(machine: machine, ..)
 *
 * // In your update()
 * fn update(model, msg, ctx) {
 *   case msg {
 *     Tick -> {
 *       let #(new_machine, _) =
 *         spritesheet.update(model.machine, model.context, ctx.delta_time)
 *       Model(..model, machine: new_machine)
 *     }
 *   }
 * }
 *
 * // In your view()
 * fn view(model, _ctx) {
 *   [
 *     scene.animated_sprite(
 *       id: "player",
 *       sprite: spritesheet.to_sprite(model.machine),
 *       size: vec2.Vec2(2.0, 2.0),
 *       transform: transform.identity,
 *       physics: option.None,
 *     ),
 *   ]
 * }
 * ```
 */
export function animated_sprite(id, sprite, size, transform, physics) {
  return new AnimatedSprite(
    id,
    toList([]),
    sprite,
    size.x,
    size.y,
    transform,
    physics,
  );
}

/**
 * Create a debug wireframe box visualization.
 *
 * Useful for visualizing collision bounds, trigger zones, or spatial regions.
 *
 * **Min/Max**: Define the axis-aligned bounding box corners in world space.
 * **Color**: Hex color for the wireframe lines.
 *
 * ## Example
 *
 * ```gleam
 * // Visualize a collision box
 * scene.debug_box(
 *   id: "trigger_zone",
 *   min: vec3.Vec3(-5.0, 0.0, -5.0),
 *   max: vec3.Vec3(5.0, 3.0, 5.0),
 *   color: 0x00ff00,  // Green wireframe
 * )
 * ```
 */
export function debug_box(id, min, max, color) {
  return new DebugBox(id, toList([]), min, max, color);
}

/**
 * Create a debug wireframe sphere visualization.
 *
 * Useful for visualizing sphere colliders, range indicators, or explosion radii.
 *
 * **Center**: Center position in world space.
 * **Radius**: Sphere radius (should match your collider if visualizing physics).
 * **Color**: Hex color for the wireframe lines.
 *
 * ## Example
 *
 * ```gleam
 * // Visualize attack range
 * scene.debug_sphere(
 *   id: "attack_range",
 *   center: player_position,
 *   radius: 5.0,  // 5 unit attack radius
 *   color: 0xff0000,  // Red wireframe
 *   children: [],
 * )
 * ```
 */
export function debug_sphere(id, center, radius, color) {
  return new DebugSphere(id, toList([]), center, radius, color);
}

/**
 * Create a debug line segment visualization.
 *
 * Useful for visualizing raycasts, trajectories, connections, or directions.
 *
 * **From/To**: Start and end points in world space.
 * **Color**: Hex color for the line.
 *
 * ## Example
 *
 * ```gleam
 * // Visualize raycast from player to target
 * scene.debug_line(
 *   id: "raycast",
 *   from: player_position,
 *   to: target_position,
 *   color: 0xffff00,  // Yellow line
 *   children: [],
 * )
 * ```
 */
export function debug_line(id, from, to, color) {
  return new DebugLine(id, toList([]), from, to, color);
}

/**
 * Create a debug coordinate axes visualization.
 *
 * Displays X (red), Y (green), and Z (blue) axes from the origin point.
 * Useful for visualizing object orientation, camera position, or world origin.
 *
 * **Origin**: Center point in world space.
 * **Size**: Length of each axis line in units.
 *
 * ## Example
 *
 * ```gleam
 * // Show world origin
 * scene.debug_axes(
 *   id: "world_axes",
 *   origin: vec3.Vec3(0.0, 0.0, 0.0),
 *   size: 5.0,  // 5 unit length axes
 * )
 *
 * // Show object local axes
 * scene.debug_axes(
 *   id: "player_axes",
 *   origin: player_position,
 *   size: 2.0,
 * )
 * ```
 */
export function debug_axes(id, origin, size) {
  return new DebugAxes(id, toList([]), origin, size);
}

/**
 * Create a debug ground grid visualization.
 *
 * Displays a grid on the XZ plane (horizontal ground plane) centered at origin.
 * Useful for spatial reference, scale indication, or level design.
 *
 * **Size**: Total width/depth of the grid in units.
 * **Divisions**: Number of grid cells (higher = finer grid).
 * **Color**: Hex color for the grid lines.
 *
 * ## Example
 *
 * ```gleam
 * // Create a 20x20 unit grid with 10 divisions
 * scene.debug_grid(
 *   id: "ground_grid",
 *   size: 20.0,  // 20 units wide
 *   divisions: 10,  // 10x10 cells (2 units per cell)
 *   color: 0x444444,  // Dark gray
 * )
 * ```
 */
export function debug_grid(id, size, divisions, color) {
  return new DebugGrid(id, toList([]), size, divisions, color);
}

/**
 * Create a debug point visualization.
 *
 * Displays a small sphere at the specified position.
 * Useful for marking locations, waypoints, spawn points, or intersection points.
 *
 * **Position**: Point location in world space.
 * **Size**: Radius of the debug sphere in units (typically small like 0.1-0.5).
 * **Color**: Hex color for the sphere.
 *
 * ## Example
 *
 * ```gleam
 * // Mark spawn points
 * scene.debug_point(
 *   id: "spawn_1",
 *   position: vec3.Vec3(10.0, 0.0, 5.0),
 *   size: 0.3,  // Small sphere
 *   color: 0x00ff00,  // Green
 * )
 *
 * // Mark raycast hit point
 * scene.debug_point(
 *   id: "hit_point",
 *   position: raycast_result.point,
 *   size: 0.2,
 *   color: 0xff0000,  // Red
 * )
 * ```
 */
export function debug_point(id, position, size, color) {
  return new DebugPoint(id, toList([]), position, size, color);
}

export function with_children(node, children) {
  if (node instanceof Empty) {
    return new Empty(node.id, children, node.transform);
  } else if (node instanceof Mesh) {
    return new Mesh(
      node.id,
      children,
      node.transform,
      node.geometry,
      node.material,
      node.physics,
    );
  } else if (node instanceof InstancedMesh) {
    return new InstancedMesh(
      node.id,
      children,
      node.geometry,
      node.material,
      node.instances,
    );
  } else if (node instanceof Light) {
    return new Light(node.id, children, node.transform, node.light);
  } else if (node instanceof Camera) {
    return new Camera(
      node.id,
      children,
      node.camera,
      node.transform,
      node.active,
      node.viewport,
      node.postprocessing,
    );
  } else if (node instanceof LOD) {
    return new LOD(node.id, children, node.levels, node.transform);
  } else if (node instanceof Model3D) {
    return new Model3D(
      node.id,
      children,
      node.object,
      node.transform,
      node.animation,
      node.physics,
      node.material,
      node.transparent,
    );
  } else if (node instanceof InstancedModel) {
    return new InstancedModel(
      node.id,
      children,
      node.object,
      node.instances,
      node.physics,
      node.material,
      node.transparent,
    );
  } else if (node instanceof Audio) {
    return new Audio(node.id, children, node.audio);
  } else if (node instanceof CSS2D) {
    return new CSS2D(node.id, children, node.html, node.transform);
  } else if (node instanceof CSS3D) {
    return new CSS3D(node.id, children, node.html, node.transform);
  } else if (node instanceof Canvas) {
    return new Canvas(
      node.id,
      children,
      node.encoded_picture,
      node.texture_width,
      node.texture_height,
      node.width,
      node.height,
      node.transform,
    );
  } else if (node instanceof AnimatedSprite) {
    return new AnimatedSprite(
      node.id,
      children,
      node.sprite,
      node.width,
      node.height,
      node.transform,
      node.physics,
    );
  } else if (node instanceof DebugBox) {
    return new DebugBox(node.id, children, node.min, node.max, node.color);
  } else if (node instanceof DebugSphere) {
    return new DebugSphere(
      node.id,
      children,
      node.center,
      node.radius,
      node.color,
    );
  } else if (node instanceof DebugLine) {
    return new DebugLine(node.id, children, node.from, node.to, node.color);
  } else if (node instanceof DebugAxes) {
    return new DebugAxes(node.id, children, node.origin, node.size);
  } else if (node instanceof DebugGrid) {
    return new DebugGrid(
      node.id,
      children,
      node.size,
      node.divisions,
      node.color,
    );
  } else {
    return new DebugPoint(
      node.id,
      children,
      node.position,
      node.size,
      node.color,
    );
  }
}

function flatten_scene_helper(nodes, parent_id, current_depth, acc) {
  return $list.fold(
    nodes,
    acc,
    (acc, node) => {
      let node_id = node.id;
      let acc$1 = $dict.insert(
        acc,
        node_id,
        new NodeWithParent(node, parent_id, current_depth),
      );
      let children = node.children;
      return flatten_scene_helper(
        children,
        new $option.Some(node_id),
        current_depth + 1,
        acc$1,
      );
    },
  );
}

function flatten_scene(nodes) {
  return flatten_scene_helper(nodes, new $option.None(), 0, $dict.new$());
}

/**
 * Efficiently concatenate multiple lists using fold + prepend
 * O(n) optimized: use list.append which preserves order
 * 
 * @ignore
 */
function concat_patches(lists) {
  return $list.fold(
    lists,
    toList([]),
    (acc, patches) => { return $list.append(acc, patches); },
  );
}

/**
 * Batch patches by type for optimal rendering order
 * Optimized: Single-pass partitioning + manual concatenation (no list.flatten)
 * 
 * @ignore
 */
function batch_patches(removals, parent_change_removals, updates, additions) {
  let $ = $list.fold(
    updates,
    [toList([]), toList([]), toList([]), toList([])],
    (acc, patch) => {
      let transforms;
      let materials;
      let geometries;
      let misc;
      transforms = acc[0];
      materials = acc[1];
      geometries = acc[2];
      misc = acc[3];
      if (patch instanceof UpdateTransform) {
        return [listPrepend(patch, transforms), materials, geometries, misc];
      } else if (patch instanceof UpdateMaterial) {
        return [transforms, listPrepend(patch, materials), geometries, misc];
      } else if (patch instanceof UpdateGeometry) {
        return [transforms, materials, listPrepend(patch, geometries), misc];
      } else {
        return [transforms, materials, geometries, listPrepend(patch, misc)];
      }
    },
  );
  let transform_updates;
  let material_updates;
  let geometry_updates;
  let misc_updates;
  transform_updates = $[0];
  material_updates = $[1];
  geometry_updates = $[2];
  misc_updates = $[3];
  return concat_patches(
    toList([
      removals,
      parent_change_removals,
      $list.reverse(transform_updates),
      $list.reverse(material_updates),
      $list.reverse(geometry_updates),
      $list.reverse(misc_updates),
      additions,
    ]),
  );
}

/**
 * Sort AddNode patches so that parents are added before their children
 * Optimized: pre-compute depths as tuples to avoid dict lookups in comparator
 * 
 * @ignore
 */
function sort_patches_by_hierarchy(patches, node_dict) {
  let patches_with_depth = $list.map(
    patches,
    (patch) => {
      if (patch instanceof AddNode) {
        let id = patch.id;
        let _block;
        let $ = $dict.get(node_dict, id);
        if ($ instanceof Ok) {
          let node_depth = $[0].depth;
          _block = node_depth;
        } else {
          _block = 0;
        }
        let depth = _block;
        return [depth, patch];
      } else {
        return [0, patch];
      }
    },
  );
  let _pipe = $list.sort(
    patches_with_depth,
    (a, b) => {
      let depth_a;
      depth_a = a[0];
      let depth_b;
      depth_b = b[0];
      let $ = depth_a < depth_b;
      if ($) {
        return new $order.Lt();
      } else {
        let $1 = depth_a > depth_b;
        if ($1) {
          return new $order.Gt();
        } else {
          return new $order.Eq();
        }
      }
    },
  );
  return $list.map(
    _pipe,
    (tuple) => {
      let patch;
      patch = tuple[1];
      return patch;
    },
  );
}

/**
 * Compare Mesh fields using accumulator pattern (no empty list allocations)
 * 
 * @ignore
 */
function compare_mesh_fields(
  id,
  prev_geom,
  prev_mat,
  prev_trans,
  prev_phys,
  curr_geom,
  curr_mat,
  curr_trans,
  curr_phys
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(prev_trans, curr_trans);
  if ($) {
    _block = listPrepend(new UpdateTransform(id, curr_trans), patches);
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let _block$1;
  let $1 = !isEqual(prev_mat, curr_mat);
  if ($1) {
    _block$1 = listPrepend(
      new UpdateMaterial(id, new $option.Some(curr_mat)),
      patches$1,
    );
  } else {
    _block$1 = patches$1;
  }
  let patches$2 = _block$1;
  let _block$2;
  let $2 = !isEqual(prev_geom, curr_geom);
  if ($2) {
    _block$2 = listPrepend(new UpdateGeometry(id, curr_geom), patches$2);
  } else {
    _block$2 = patches$2;
  }
  let patches$3 = _block$2;
  let _block$3;
  let $3 = !isEqual(prev_phys, curr_phys);
  if ($3) {
    _block$3 = listPrepend(new UpdatePhysics(id, curr_phys), patches$3);
  } else {
    _block$3 = patches$3;
  }
  let patches$4 = _block$3;
  return patches$4;
}

/**
 * Compare InstancedMesh fields using accumulator pattern
 * 
 * @ignore
 */
function compare_instanced_mesh_fields(
  id,
  prev_geom,
  prev_mat,
  prev_instances,
  curr_geom,
  curr_mat,
  curr_instances
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(prev_mat, curr_mat);
  if ($) {
    _block = listPrepend(
      new UpdateMaterial(id, new $option.Some(curr_mat)),
      patches,
    );
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let _block$1;
  let $1 = !isEqual(prev_geom, curr_geom);
  if ($1) {
    _block$1 = listPrepend(new UpdateGeometry(id, curr_geom), patches$1);
  } else {
    _block$1 = patches$1;
  }
  let patches$2 = _block$1;
  let _block$2;
  let $2 = !isEqual(prev_instances, curr_instances);
  if ($2) {
    _block$2 = listPrepend(new UpdateInstances(id, curr_instances), patches$2);
  } else {
    _block$2 = patches$2;
  }
  let patches$3 = _block$2;
  return patches$3;
}

/**
 * Compare Light fields using accumulator pattern
 * 
 * @ignore
 */
function compare_light_fields(
  id,
  prev_light,
  prev_trans,
  curr_light,
  curr_trans
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(prev_trans, curr_trans);
  if ($) {
    _block = listPrepend(new UpdateTransform(id, curr_trans), patches);
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let _block$1;
  let $1 = !isEqual(prev_light, curr_light);
  if ($1) {
    _block$1 = listPrepend(new UpdateLight(id, curr_light), patches$1);
  } else {
    _block$1 = patches$1;
  }
  let patches$2 = _block$1;
  return patches$2;
}

/**
 * Compare LOD fields using accumulator pattern
 * 
 * @ignore
 */
function compare_lod_fields(
  id,
  prev_levels,
  prev_trans,
  curr_levels,
  curr_trans
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(prev_trans, curr_trans);
  if ($) {
    _block = listPrepend(new UpdateTransform(id, curr_trans), patches);
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let _block$1;
  let $1 = !isEqual(prev_levels, curr_levels);
  if ($1) {
    _block$1 = listPrepend(new UpdateLODLevels(id, curr_levels), patches$1);
  } else {
    _block$1 = patches$1;
  }
  let patches$2 = _block$1;
  return patches$2;
}

/**
 * Compare Camera fields using accumulator pattern
 * 
 * @ignore
 */
function compare_camera_fields(
  id,
  prev_cam,
  prev_trans,
  prev_active,
  prev_viewport,
  prev_pp,
  curr_cam,
  curr_trans,
  curr_active,
  curr_viewport,
  curr_pp
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(prev_trans, curr_trans);
  if ($) {
    _block = listPrepend(new UpdateTransform(id, curr_trans), patches);
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let _block$1;
  let $1 = (!isEqual(prev_cam, curr_cam)) || (!isEqual(
    prev_viewport,
    curr_viewport
  ));
  if ($1) {
    _block$1 = listPrepend(new UpdateCamera(id, curr_cam), patches$1);
  } else {
    _block$1 = patches$1;
  }
  let patches$2 = _block$1;
  let _block$2;
  let $2 = !isEqual(prev_pp, curr_pp);
  if ($2) {
    _block$2 = listPrepend(
      new UpdateCameraPostprocessing(id, curr_pp),
      patches$2,
    );
  } else {
    _block$2 = patches$2;
  }
  let patches$3 = _block$2;
  let _block$3;
  if (!prev_active && curr_active) {
    _block$3 = listPrepend(new SetActiveCamera(id), patches$3);
  } else {
    _block$3 = patches$3;
  }
  let patches$4 = _block$3;
  return patches$4;
}

/**
 * Compare Model3D fields using accumulator pattern
 * 
 * @ignore
 */
function compare_model3d_fields(
  id,
  prev_trans,
  prev_anim,
  prev_phys,
  prev_mat,
  curr_trans,
  curr_anim,
  curr_phys,
  curr_mat
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(prev_trans, curr_trans);
  if ($) {
    _block = listPrepend(new UpdateTransform(id, curr_trans), patches);
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let _block$1;
  let $1 = !isEqual(prev_anim, curr_anim);
  if ($1) {
    _block$1 = listPrepend(new UpdateAnimation(id, curr_anim), patches$1);
  } else {
    _block$1 = patches$1;
  }
  let patches$2 = _block$1;
  let _block$2;
  let $2 = !isEqual(prev_phys, curr_phys);
  if ($2) {
    _block$2 = listPrepend(new UpdatePhysics(id, curr_phys), patches$2);
  } else {
    _block$2 = patches$2;
  }
  let patches$3 = _block$2;
  let _block$3;
  let $3 = !isEqual(prev_mat, curr_mat);
  if ($3) {
    _block$3 = listPrepend(new UpdateMaterial(id, curr_mat), patches$3);
  } else {
    _block$3 = patches$3;
  }
  let patches$4 = _block$3;
  return patches$4;
}

/**
 * Compare InstancedModel fields using accumulator pattern
 * 
 * @ignore
 */
function compare_instanced_model_fields(
  id,
  previous_instances,
  previous_physics,
  previous_material,
  current_instances,
  current_physics,
  current_material
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(previous_instances, current_instances);
  if ($) {
    _block = listPrepend(new UpdateInstances(id, current_instances), patches);
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let _block$1;
  let $1 = !isEqual(previous_physics, current_physics);
  if ($1) {
    _block$1 = listPrepend(new UpdatePhysics(id, current_physics), patches$1);
  } else {
    _block$1 = patches$1;
  }
  let patches$2 = _block$1;
  let _block$2;
  let $2 = !isEqual(previous_material, current_material);
  if ($2) {
    _block$2 = listPrepend(new UpdateMaterial(id, current_material), patches$2);
  } else {
    _block$2 = patches$2;
  }
  let patches$3 = _block$2;
  return patches$3;
}

/**
 * Compare AnimatedSprite fields using accumulator pattern
 * 
 * @ignore
 */
function compare_animated_sprite_fields(
  id,
  previous_sprite,
  previous_width,
  previous_height,
  previous_transform,
  previous_physics,
  current_sprite,
  current_width,
  current_height,
  current_transform,
  current_physics
) {
  let patches = toList([]);
  let _block;
  let $ = !isEqual(previous_physics, current_physics);
  if ($) {
    _block = listPrepend(new UpdatePhysics(id, current_physics), patches);
  } else {
    _block = patches;
  }
  let patches$1 = _block;
  let $1 = (((!isEqual(previous_sprite, current_sprite)) || (previous_width !== current_width)) || (previous_height !== current_height)) || (!isEqual(
    previous_transform,
    current_transform
  ));
  if ($1) {
    return listPrepend(
      new UpdateAnimatedSprite(
        id,
        current_sprite,
        current_width,
        current_height,
        current_transform,
      ),
      patches$1,
    );
  } else {
    return patches$1;
  }
}

/**
 * Detailed comparison of node properties (called only when nodes differ)
 * Uses accumulator pattern to avoid empty list allocations
 * 
 * @ignore
 */
function compare_nodes_detailed(id, prev, curr) {
  if (prev instanceof Empty) {
    if (curr instanceof Empty) {
      let prev_transform = prev.transform;
      let curr_transform = curr.transform;
      let $ = !isEqual(prev_transform, curr_transform);
      if ($) {
        return toList([new UpdateTransform(id, curr_transform)]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof Mesh) {
    if (curr instanceof Mesh) {
      let previous_transform = prev.transform;
      let previous_geometry = prev.geometry;
      let previous_material = prev.material;
      let previous_physics = prev.physics;
      let current_transform = curr.transform;
      let current_geometry = curr.geometry;
      let current_material = curr.material;
      let current_physics = curr.physics;
      return compare_mesh_fields(
        id,
        previous_geometry,
        previous_material,
        previous_transform,
        previous_physics,
        current_geometry,
        current_material,
        current_transform,
        current_physics,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof InstancedMesh) {
    if (curr instanceof InstancedMesh) {
      let previous_geometry = prev.geometry;
      let previous_material = prev.material;
      let previous_instances = prev.instances;
      let current_geometry = curr.geometry;
      let current_material = curr.material;
      let current_instances = curr.instances;
      return compare_instanced_mesh_fields(
        id,
        previous_geometry,
        previous_material,
        previous_instances,
        current_geometry,
        current_material,
        current_instances,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof Light) {
    if (curr instanceof Light) {
      let previous_transform = prev.transform;
      let previous_light = prev.light;
      let current_transform = curr.transform;
      let current_light = curr.light;
      return compare_light_fields(
        id,
        previous_light,
        previous_transform,
        current_light,
        current_transform,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof Camera) {
    if (curr instanceof Camera) {
      let previous_camera = prev.camera;
      let previous_transform = prev.transform;
      let previous_active = prev.active;
      let previous_viewport = prev.viewport;
      let previous_postprocessing = prev.postprocessing;
      let current_camera = curr.camera;
      let current_transform = curr.transform;
      let current_active = curr.active;
      let current_viewport = curr.viewport;
      let current_postprocessing = curr.postprocessing;
      return compare_camera_fields(
        id,
        previous_camera,
        previous_transform,
        previous_active,
        previous_viewport,
        previous_postprocessing,
        current_camera,
        current_transform,
        current_active,
        current_viewport,
        current_postprocessing,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof LOD) {
    if (curr instanceof LOD) {
      let previous_levels = prev.levels;
      let previous_transform = prev.transform;
      let current_levels = curr.levels;
      let current_transform = curr.transform;
      return compare_lod_fields(
        id,
        previous_levels,
        previous_transform,
        current_levels,
        current_transform,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof Model3D) {
    if (curr instanceof Model3D) {
      let previous_transform = prev.transform;
      let previous_animation = prev.animation;
      let previous_physics = prev.physics;
      let previous_material = prev.material;
      let current_transform = curr.transform;
      let current_animation = curr.animation;
      let current_physics = curr.physics;
      let current_material = curr.material;
      return compare_model3d_fields(
        id,
        previous_transform,
        previous_animation,
        previous_physics,
        previous_material,
        current_transform,
        current_animation,
        current_physics,
        current_material,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof InstancedModel) {
    if (curr instanceof InstancedModel) {
      let previous_instances = prev.instances;
      let previous_physics = prev.physics;
      let previous_material = prev.material;
      let current_instances = curr.instances;
      let current_physics = curr.physics;
      let current_material = curr.material;
      return compare_instanced_model_fields(
        id,
        previous_instances,
        previous_physics,
        previous_material,
        current_instances,
        current_physics,
        current_material,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof Audio) {
    if (curr instanceof Audio) {
      let prev_audio = prev.audio;
      let curr_audio = curr.audio;
      let $ = !isEqual(prev_audio, curr_audio);
      if ($) {
        return toList([new UpdateAudio(id, curr_audio)]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof CSS2D) {
    if (curr instanceof CSS2D) {
      let previous_html = prev.html;
      let prev_transform = prev.transform;
      let curr_html = curr.html;
      let curr_transform = curr.transform;
      let $ = (previous_html !== curr_html) || (!isEqual(
        prev_transform,
        curr_transform
      ));
      if ($) {
        return toList([new UpdateCSS2DLabel(id, curr_html, curr_transform)]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof CSS3D) {
    if (curr instanceof CSS3D) {
      let prev_html = prev.html;
      let prev_transform = prev.transform;
      let curr_html = curr.html;
      let curr_transform = curr.transform;
      let $ = (prev_html !== curr_html) || (!isEqual(
        prev_transform,
        curr_transform
      ));
      if ($) {
        return toList([new UpdateCSS3DLabel(id, curr_html, curr_transform)]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof Canvas) {
    if (curr instanceof Canvas) {
      let prev_encoded_picture = prev.encoded_picture;
      let prev_tw = prev.texture_width;
      let prev_th = prev.texture_height;
      let prev_w = prev.width;
      let prev_h = prev.height;
      let prev_transform = prev.transform;
      let curr_encoded_picture = curr.encoded_picture;
      let curr_tw = curr.texture_width;
      let curr_th = curr.texture_height;
      let curr_w = curr.width;
      let curr_h = curr.height;
      let curr_transform = curr.transform;
      let $ = (((((prev_encoded_picture !== curr_encoded_picture) || (prev_tw !== curr_tw)) || (prev_th !== curr_th)) || (prev_w !== curr_w)) || (prev_h !== curr_h)) || (!isEqual(
        prev_transform,
        curr_transform
      ));
      if ($) {
        return toList([
          new UpdateCanvas(
            id,
            curr_encoded_picture,
            curr_tw,
            curr_th,
            curr_w,
            curr_h,
            curr_transform,
          ),
        ]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof AnimatedSprite) {
    if (curr instanceof AnimatedSprite) {
      let previous_sprite = prev.sprite;
      let previous_width = prev.width;
      let previous_height = prev.height;
      let previous_transform = prev.transform;
      let previous_physics = prev.physics;
      let current_sprite = curr.sprite;
      let current_width = curr.width;
      let current_height = curr.height;
      let current_transform = curr.transform;
      let current_physics = curr.physics;
      return compare_animated_sprite_fields(
        id,
        previous_sprite,
        previous_width,
        previous_height,
        previous_transform,
        previous_physics,
        current_sprite,
        current_width,
        current_height,
        current_transform,
        current_physics,
      );
    } else {
      return toList([]);
    }
  } else if (prev instanceof DebugBox) {
    if (curr instanceof DebugBox) {
      let prev_min = prev.min;
      let prev_max = prev.max;
      let prev_color = prev.color;
      let curr_children = curr.children;
      let curr_min = curr.min;
      let curr_max = curr.max;
      let curr_color = curr.color;
      let $ = ((!isEqual(prev_min, curr_min)) || (!isEqual(prev_max, curr_max))) || (prev_color !== curr_color);
      if ($) {
        return toList([
          new RemoveNode(id),
          new AddNode(
            id,
            new DebugBox(id, curr_children, curr_min, curr_max, curr_color),
            new $option.None(),
          ),
        ]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof DebugSphere) {
    if (curr instanceof DebugSphere) {
      let prev_center = prev.center;
      let prev_radius = prev.radius;
      let prev_color = prev.color;
      let curr_children = curr.children;
      let curr_center = curr.center;
      let curr_radius = curr.radius;
      let curr_color = curr.color;
      let $ = ((!isEqual(prev_center, curr_center)) || (prev_radius !== curr_radius)) || (prev_color !== curr_color);
      if ($) {
        return toList([
          new RemoveNode(id),
          new AddNode(
            id,
            new DebugSphere(
              id,
              curr_children,
              curr_center,
              curr_radius,
              curr_color,
            ),
            new $option.None(),
          ),
        ]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof DebugLine) {
    if (curr instanceof DebugLine) {
      let prev_from = prev.from;
      let prev_to = prev.to;
      let prev_color = prev.color;
      let curr_children = curr.children;
      let curr_from = curr.from;
      let curr_to = curr.to;
      let curr_color = curr.color;
      let $ = ((!isEqual(prev_from, curr_from)) || (!isEqual(prev_to, curr_to))) || (prev_color !== curr_color);
      if ($) {
        return toList([
          new RemoveNode(id),
          new AddNode(
            id,
            new DebugLine(id, curr_children, curr_from, curr_to, curr_color),
            new $option.None(),
          ),
        ]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof DebugAxes) {
    if (curr instanceof DebugAxes) {
      let prev_origin = prev.origin;
      let prev_size = prev.size;
      let curr_children = curr.children;
      let curr_origin = curr.origin;
      let curr_size = curr.size;
      let $ = (!isEqual(prev_origin, curr_origin)) || (prev_size !== curr_size);
      if ($) {
        return toList([
          new RemoveNode(id),
          new AddNode(
            id,
            new DebugAxes(id, curr_children, curr_origin, curr_size),
            new $option.None(),
          ),
        ]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (prev instanceof DebugGrid) {
    if (curr instanceof DebugGrid) {
      let prev_size = prev.size;
      let prev_divisions = prev.divisions;
      let prev_color = prev.color;
      let curr_children = curr.children;
      let curr_size = curr.size;
      let curr_divisions = curr.divisions;
      let curr_color = curr.color;
      let $ = ((prev_size !== curr_size) || (prev_divisions !== curr_divisions)) || (prev_color !== curr_color);
      if ($) {
        return toList([
          new RemoveNode(id),
          new AddNode(
            id,
            new DebugGrid(
              id,
              curr_children,
              curr_size,
              curr_divisions,
              curr_color,
            ),
            new $option.None(),
          ),
        ]);
      } else {
        return toList([]);
      }
    } else {
      return toList([]);
    }
  } else if (curr instanceof DebugPoint) {
    let prev_position = prev.position;
    let prev_size = prev.size;
    let prev_color = prev.color;
    let curr_children = curr.children;
    let curr_position = curr.position;
    let curr_size = curr.size;
    let curr_color = curr.color;
    let $ = ((!isEqual(prev_position, curr_position)) || (prev_size !== curr_size)) || (prev_color !== curr_color);
    if ($) {
      return toList([
        new RemoveNode(id),
        new AddNode(
          id,
          new DebugPoint(
            id,
            curr_children,
            curr_position,
            curr_size,
            curr_color,
          ),
          new $option.None(),
        ),
      ]);
    } else {
      return toList([]);
    }
  } else {
    return toList([]);
  }
}

function compare_nodes(id, prev, curr) {
  let $ = isEqual(prev, curr);
  if ($) {
    return toList([]);
  } else {
    return compare_nodes_detailed(id, prev, curr);
  }
}

export function diff(previous, current, cached_prev_dict) {
  let $ = isEqual(previous, current);
  if ($) {
    let empty_dict = $dict.new$();
    return [
      toList([]),
      (() => {
        let _pipe = cached_prev_dict;
        return $option.unwrap(_pipe, empty_dict);
      })(),
    ];
  } else {
    let _block;
    if (previous instanceof $option.Some) {
      let node = previous[0];
      _block = toList([node]);
    } else {
      _block = toList([]);
    }
    let prev_list = _block;
    let _block$1;
    if (current instanceof $option.Some) {
      let node = current[0];
      _block$1 = toList([node]);
    } else {
      _block$1 = toList([]);
    }
    let curr_list = _block$1;
    let _block$2;
    if (cached_prev_dict instanceof $option.Some) {
      let cached = cached_prev_dict[0];
      _block$2 = cached;
    } else {
      _block$2 = flatten_scene(prev_list);
    }
    let prev_dict = _block$2;
    let curr_dict = flatten_scene(curr_list);
    let prev_size = $dict.size(prev_dict);
    let curr_size = $dict.size(curr_dict);
    let $1 = (prev_size === 0) && (curr_size === 0);
    if ($1) {
      return [toList([]), curr_dict];
    } else {
      let prev_ids = $dict.keys(prev_dict);
      let curr_ids = $dict.keys(curr_dict);
      let _block$3;
      let _pipe = $list.filter(
        prev_ids,
        (id) => { return !$dict.has_key(curr_dict, id); },
      );
      _block$3 = $list.map(_pipe, (id) => { return new RemoveNode(id); });
      let removals = _block$3;
      let _block$4;
      let _pipe$1 = $list.filter(
        curr_ids,
        (id) => { return $dict.has_key(prev_dict, id); },
      );
      _block$4 = $list.partition(
        _pipe$1,
        (id) => {
          let $3 = $dict.get(prev_dict, id);
          let $4 = $dict.get(curr_dict, id);
          if ($3 instanceof Ok && $4 instanceof Ok) {
            let prev_parent = $3[0].parent_id;
            let curr_parent = $4[0].parent_id;
            return !isEqual(prev_parent, curr_parent);
          } else {
            return false;
          }
        },
      );
      let $2 = _block$4;
      let parent_changed_ids;
      let same_parent_ids;
      parent_changed_ids = $2[0];
      same_parent_ids = $2[1];
      let parent_change_removals = $list.map(
        parent_changed_ids,
        (id) => { return new RemoveNode(id); },
      );
      let parent_change_additions = $list.filter_map(
        parent_changed_ids,
        (id) => {
          let $3 = $dict.get(curr_dict, id);
          if ($3 instanceof Ok) {
            let node = $3[0].node;
            let parent_id = $3[0].parent_id;
            return new Ok(new AddNode(id, node, parent_id));
          } else {
            return new Error(undefined);
          }
        },
      );
      let _block$5;
      let _pipe$2 = $list.filter(
        curr_ids,
        (id) => { return !$dict.has_key(prev_dict, id); },
      );
      let _pipe$3 = $list.filter_map(
        _pipe$2,
        (id) => {
          let $3 = $dict.get(curr_dict, id);
          if ($3 instanceof Ok) {
            let node = $3[0].node;
            let parent_id = $3[0].parent_id;
            return new Ok(new AddNode(id, node, parent_id));
          } else {
            return new Error(undefined);
          }
        },
      );
      let _pipe$4 = $list.append(_pipe$3, parent_change_additions);
      _block$5 = sort_patches_by_hierarchy(_pipe$4, curr_dict);
      let additions = _block$5;
      let updates = $list.flat_map(
        same_parent_ids,
        (id) => {
          let $3 = $dict.get(prev_dict, id);
          let $4 = $dict.get(curr_dict, id);
          if ($3 instanceof Ok && $4 instanceof Ok) {
            let prev_node = $3[0].node;
            let curr_node = $4[0].node;
            return compare_nodes(id, prev_node, curr_node);
          } else {
            return toList([]);
          }
        },
      );
      let patches = batch_patches(
        removals,
        parent_change_removals,
        updates,
        additions,
      );
      return [patches, curr_dict];
    }
  }
}

export function new_render_state(options) {
  let renderer = $savoiardi.create_renderer(options);
  let scene = $savoiardi.create_scene();
  let audio_listener = $savoiardi.create_audio_listener();
  return new RendererState(
    renderer,
    scene,
    $object_cache.init(),
    new $option.None(),
    $audio_manager.init(),
    audio_listener,
    new $option.None(),
    new $option.None(),
    new $option.None(),
  );
}

/**
 * Create a headless render state for testing (no WebGL required)
 *
 * This creates a real Three.js Scene (which works in Node.js) but uses
 * a mock Renderer that doesn't require WebGL. Use this in tests to
 * simulate game state without needing a browser environment.
 * 
 * @ignore
 */
export function new_headless_render_state(width, height) {
  let scene = create_headless_scene_ffi();
  let renderer = create_headless_renderer_ffi(width, height);
  let audio_listener = create_mock_audio_listener_ffi();
  return new RendererState(
    renderer,
    scene,
    $object_cache.init(),
    new $option.None(),
    $audio_manager.init(),
    audio_listener,
    new $option.None(),
    new $option.None(),
    new $option.None(),
  );
}

export function get_renderer(state) {
  return state.renderer;
}

export function get_scene(state) {
  return state.scene;
}

export function set_physics_world(state, world) {
  return new RendererState(
    state.renderer,
    state.scene,
    state.cache,
    world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

export function get_physics_world(state) {
  return state.physics_world;
}

export function get_cached_scene_dict(state) {
  return state.cached_scene_dict;
}

export function set_cached_scene_dict(state, cache) {
  return new RendererState(
    state.renderer,
    state.scene,
    state.cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    cache,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

export function resume_audio_context(state) {
  let new_audio_manager = $audio_manager.resume_audio_context(
    state.audio_manager,
    state.audio_listener,
  );
  return new RendererState(
    state.renderer,
    state.scene,
    state.cache,
    state.physics_world,
    new_audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

/**
 * Initialize CSS2D renderer and append to container
 * Must be called after the main canvas is appended to the container
 * 
 * @ignore
 */
export function init_css2d_renderer(state, container) {
  let css2d_renderer = $savoiardi.create_css2d_renderer();
  let $ = $savoiardi.get_canvas_dimensions(state.renderer);
  let width;
  let height;
  width = $.x;
  height = $.y;
  $savoiardi.set_css2d_renderer_size(
    css2d_renderer,
    $float.round(width),
    $float.round(height),
  );
  let css2d_element = $savoiardi.get_css2d_renderer_dom_element(css2d_renderer);
  append_element_to_container(container, css2d_element);
  return new RendererState(
    state.renderer,
    state.scene,
    state.cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    new $option.Some(css2d_renderer),
    state.css3d_renderer,
  );
}

/**
 * Render CSS2D labels (call after main render)
 * 
 * @ignore
 */
export function render_css2d(state, camera) {
  let $ = state.css2d_renderer;
  if ($ instanceof $option.Some) {
    let css2d_renderer = $[0];
    return $savoiardi.render_css2d(css2d_renderer, state.scene, camera);
  } else {
    return undefined;
  }
}

/**
 * Update CSS2D renderer size (call on window resize)
 * 
 * @ignore
 */
export function update_css2d_renderer_size(state) {
  let $ = state.css2d_renderer;
  if ($ instanceof $option.Some) {
    let css2d_renderer = $[0];
    let $1 = $savoiardi.get_canvas_dimensions(state.renderer);
    let width;
    let height;
    width = $1.x;
    height = $1.y;
    return $savoiardi.set_css2d_renderer_size(
      css2d_renderer,
      $float.round(width),
      $float.round(height),
    );
  } else {
    return undefined;
  }
}

/**
 * Initialize CSS3D renderer and append to container
 * Must be called after the main canvas is appended to the container
 * 
 * @ignore
 */
export function init_css3d_renderer(state, container) {
  let css3d_renderer = $savoiardi.create_css3d_renderer();
  let $ = $savoiardi.get_canvas_dimensions(state.renderer);
  let width;
  let height;
  width = $.x;
  height = $.y;
  $savoiardi.set_css3d_renderer_size(
    css3d_renderer,
    $float.round(width),
    $float.round(height),
  );
  let css3d_element = $savoiardi.get_css3d_renderer_dom_element(css3d_renderer);
  append_element_to_container(container, css3d_element);
  return new RendererState(
    state.renderer,
    state.scene,
    state.cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    new $option.Some(css3d_renderer),
  );
}

/**
 * Render CSS3D labels (call after main render)
 * 
 * @ignore
 */
export function render_css3d(state, camera) {
  let $ = state.css3d_renderer;
  if ($ instanceof $option.Some) {
    let css3d_renderer = $[0];
    return $savoiardi.render_css3d(css3d_renderer, state.scene, camera);
  } else {
    return undefined;
  }
}

/**
 * Update CSS3D renderer size (call on window resize)
 * 
 * @ignore
 */
export function update_css3d_renderer_size(state) {
  let $ = state.css3d_renderer;
  if ($ instanceof $option.Some) {
    let css3d_renderer = $[0];
    let $1 = $savoiardi.get_canvas_dimensions(state.renderer);
    let width;
    let height;
    width = $1.x;
    height = $1.y;
    return $savoiardi.set_css3d_renderer_size(
      css3d_renderer,
      $float.round(width),
      $float.round(height),
    );
  } else {
    return undefined;
  }
}

function add_to_scene_or_parent(state, object, parent_id) {
  if (parent_id instanceof $option.Some) {
    let pid = parent_id[0];
    let $ = $object_cache.get_object(state.cache, pid);
    if ($ instanceof Ok) {
      let parent_obj = $[0];
      return $savoiardi.add_child(parent_obj, object);
    } else {
      return $savoiardi.add_to_scene(state.scene, object);
    }
  } else {
    return $savoiardi.add_to_scene(state.scene, object);
  }
}

function handle_add_mesh(
  state,
  id,
  geometry,
  material,
  transform,
  physics,
  parent_id
) {
  let geometry_three = $geometry.create_geometry(geometry);
  let material_three = $material.create_material(material);
  let mesh$1 = $savoiardi.create_mesh(geometry_three, material_three);
  $savoiardi.apply_transform_with_quaternion(
    mesh$1,
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  $savoiardi.set_shadow_properties(mesh$1, true, true);
  add_to_scene_or_parent(state, mesh$1, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, mesh$1);
  let new_state = new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
  let $ = new_state.physics_world;
  if (physics instanceof $option.Some && $ instanceof $option.Some) {
    let physics_config = physics[0];
    let world = $[0];
    let world_position = $savoiardi.get_world_position(mesh$1);
    let world_rotation = $savoiardi.get_world_quaternion(mesh$1);
    let _block;
    let _pipe = $transform.at(world_position);
    _block = $transform.with_quaternion_rotation(_pipe, world_rotation);
    let world_transform = _block;
    let new_world = $physics.create_body(
      world,
      id,
      physics_config,
      world_transform,
    );
    return new RendererState(
      new_state.renderer,
      new_state.scene,
      new_state.cache,
      new $option.Some(new_world),
      new_state.audio_manager,
      new_state.audio_listener,
      new_state.cached_scene_dict,
      new_state.css2d_renderer,
      new_state.css3d_renderer,
    );
  } else {
    return new_state;
  }
}

function generate_instance_id(base_id, index) {
  return ((base_id + "[") + $int.to_string(index)) + "]";
}

function handle_add_group(state, id, transform, parent_id) {
  let group = $savoiardi.create_group();
  $savoiardi.apply_transform_with_quaternion(
    group,
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  add_to_scene_or_parent(state, group, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, group);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function create_lod_level_object(node) {
  if (node instanceof Empty) {
    let transform = node.transform;
    let group = $savoiardi.create_group();
    $savoiardi.apply_transform_with_quaternion(
      group,
      $transform.position(transform),
      $transform.rotation_quaternion(transform),
      $transform.scale(transform),
    );
    return group;
  } else if (node instanceof Mesh) {
    let transform = node.transform;
    let geometry = node.geometry;
    let material = node.material;
    let geometry_three = $geometry.create_geometry(geometry);
    let material_three = $material.create_material(material);
    let mesh$1 = $savoiardi.create_mesh(geometry_three, material_three);
    $savoiardi.apply_transform_with_quaternion(
      mesh$1,
      $transform.position(transform),
      $transform.rotation_quaternion(transform),
      $transform.scale(transform),
    );
    return mesh$1;
  } else if (node instanceof Model3D) {
    let object = node.object;
    let transform = node.transform;
    let material = node.material;
    let transparent = node.transparent;
    let cloned = $savoiardi.clone_object(object);
    $savoiardi.apply_transform_with_quaternion(
      cloned,
      $transform.position(transform),
      $transform.rotation_quaternion(transform),
      $transform.scale(transform),
    );
    if (material instanceof $option.Some) {
      let material$1 = material[0];
      $savoiardi.apply_material_to_object(
        cloned,
        $material.create_material(material$1),
      )
    } else {
      undefined
    }
    if (transparent) {
      $savoiardi.enable_transparency(cloned)
    } else {
      undefined
    }
    return cloned;
  } else {
    return $savoiardi.create_group();
  }
}

function handle_add_audio(state, id, audio, parent_id) {
  let _block;
  if (audio instanceof $audio.GlobalAudio) {
    let buffer = audio.buffer;
    let config = audio.config;
    _block = [buffer, config];
  } else {
    let buffer = audio.buffer;
    let config = audio.config;
    _block = [buffer, config];
  }
  let $ = _block;
  let buffer;
  let config;
  buffer = $[0];
  config = $[1];
  let $1 = $audio_manager.create_audio_source(
    state.audio_manager,
    id,
    buffer,
    config,
    audio,
    state.audio_listener,
  );
  let new_audio_manager;
  new_audio_manager = $1[0];
  let placeholder = $savoiardi.create_group();
  add_to_scene_or_parent(state, placeholder, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, placeholder);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    new_audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function calculate_aspect_ratio(viewport, renderer) {
  if (viewport instanceof $option.Some) {
    let width = viewport[0][2];
    let height = viewport[0][3];
    return divideFloat($int.to_float(width), $int.to_float(height));
  } else {
    let $ = $savoiardi.get_canvas_dimensions(renderer);
    let canvas_width;
    let canvas_height;
    canvas_width = $.x;
    canvas_height = $.y;
    let $1 = (canvas_width > 0.0) && (canvas_height > 0.0);
    if ($1) {
      return divideFloat(canvas_width, canvas_height);
    } else {
      let window_width = $window.outer_width($window.self());
      let window_height = $window.outer_height($window.self());
      return divideFloat(
        $int.to_float(window_width),
        $int.to_float(window_height)
      );
    }
  }
}

function handle_remove_node(state, id) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let obj = $[0];
    $savoiardi.remove_from_scene(state.scene, obj);
    $savoiardi.dispose_object(obj);
    let new_audio_manager = $audio_manager.unregister_audio_source(
      state.audio_manager,
      id,
    );
    let new_cache = $object_cache.remove_all(state.cache, id);
    let new_state = new RendererState(
      state.renderer,
      state.scene,
      new_cache,
      state.physics_world,
      new_audio_manager,
      state.audio_listener,
      state.cached_scene_dict,
      state.css2d_renderer,
      state.css3d_renderer,
    );
    let $1 = new_state.physics_world;
    if ($1 instanceof $option.Some) {
      let world = $1[0];
      let new_world = $physics.remove_body(world, id);
      return new RendererState(
        new_state.renderer,
        new_state.scene,
        new_state.cache,
        new $option.Some(new_world),
        new_state.audio_manager,
        new_state.audio_listener,
        new_state.cached_scene_dict,
        new_state.css2d_renderer,
        new_state.css3d_renderer,
      );
    } else {
      return new_state;
    }
  } else {
    return state;
  }
}

function handle_update_transform(state, id, transform) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    $savoiardi.apply_transform_with_quaternion(
      object,
      $transform.position(transform),
      $transform.rotation_quaternion(transform),
      $transform.scale(transform),
    );
    $savoiardi.update_matrix_world_force(object, true);
    let _block;
    let $1 = state.physics_world;
    if ($1 instanceof $option.Some) {
      let world = $1[0];
      let new_world = $physics.update_body_transform(world, id, transform);
      _block = new RendererState(
        state.renderer,
        state.scene,
        state.cache,
        new $option.Some(new_world),
        state.audio_manager,
        state.audio_listener,
        state.cached_scene_dict,
        state.css2d_renderer,
        state.css3d_renderer,
      );
    } else {
      _block = state;
    }
    let new_state = _block;
    return new_state;
  } else {
    return state;
  }
}

function handle_update_material(state, id, material) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    if (material instanceof $option.Some) {
      let mat = material[0];
      let old_material = $savoiardi.get_object_material(object);
      $savoiardi.dispose_material(old_material);
      let new_material = $material.create_material(mat);
      $savoiardi.set_object_material(object, new_material)
    } else {
      undefined
    }
    return state;
  } else {
    return state;
  }
}

function handle_update_geometry(state, id, geometry) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    let old_geometry = $savoiardi.get_object_geometry(object);
    $savoiardi.dispose_geometry(old_geometry);
    let new_geometry = $geometry.create_geometry(geometry);
    $savoiardi.set_object_geometry(object, new_geometry);
    return state;
  } else {
    return state;
  }
}

function object_to_transform(object) {
  let position = $savoiardi.get_object_position(object);
  let quaternion = $savoiardi.get_object_quaternion(object);
  let scale = $savoiardi.get_object_scale(object);
  let _pipe = $transform.identity;
  let _pipe$1 = $transform.with_position(_pipe, position);
  let _pipe$2 = $transform.with_quaternion_rotation(_pipe$1, quaternion);
  return $transform.with_scale(_pipe$2, scale);
}

function handle_update_physics(state, id, new_physics) {
  let $ = state.physics_world;
  if ($ instanceof $option.Some) {
    let world = $[0];
    let body_exists = $physics.has_body(world, id);
    if (body_exists) {
      if (new_physics instanceof $option.Some) {
        let $1 = $object_cache.get_object(state.cache, id);
        if ($1 instanceof Ok) {
          let object = $1[0];
          let object_transform = object_to_transform(object);
          let new_world = $physics.update_body_transform(
            world,
            id,
            object_transform,
          );
          return new RendererState(
            state.renderer,
            state.scene,
            state.cache,
            new $option.Some(new_world),
            state.audio_manager,
            state.audio_listener,
            state.cached_scene_dict,
            state.css2d_renderer,
            state.css3d_renderer,
          );
        } else {
          return state;
        }
      } else {
        let new_world = $physics.remove_body(world, id);
        return new RendererState(
          state.renderer,
          state.scene,
          state.cache,
          new $option.Some(new_world),
          state.audio_manager,
          state.audio_listener,
          state.cached_scene_dict,
          state.css2d_renderer,
          state.css3d_renderer,
        );
      }
    } else if (new_physics instanceof $option.Some) {
      let physics_config = new_physics[0];
      let $1 = $object_cache.get_object(state.cache, id);
      if ($1 instanceof Ok) {
        let object = $1[0];
        let object_transform = object_to_transform(object);
        let new_world = $physics.create_body(
          world,
          id,
          physics_config,
          object_transform,
        );
        return new RendererState(
          state.renderer,
          state.scene,
          state.cache,
          new $option.Some(new_world),
          state.audio_manager,
          state.audio_listener,
          state.cached_scene_dict,
          state.css2d_renderer,
          state.css3d_renderer,
        );
      } else {
        return state;
      }
    } else {
      return state;
    }
  } else {
    return state;
  }
}

function handle_update_audio(state, id, audio) {
  let _block;
  if (audio instanceof $audio.GlobalAudio) {
    let buffer = audio.buffer;
    let config = audio.config;
    _block = [buffer, config];
  } else {
    let buffer = audio.buffer;
    let config = audio.config;
    _block = [buffer, config];
  }
  let $ = _block;
  let buffer;
  let config;
  buffer = $[0];
  config = $[1];
  let new_audio_manager = $audio_manager.update_audio_config(
    state.audio_manager,
    id,
    buffer,
    config,
    state.audio_listener,
  );
  return new RendererState(
    state.renderer,
    state.scene,
    state.cache,
    state.physics_world,
    new_audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_set_active_camera(state, id) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let new_cache = $object_cache.set_active_camera(state.cache, id);
    return new RendererState(
      state.renderer,
      state.scene,
      new_cache,
      state.physics_world,
      state.audio_manager,
      state.audio_listener,
      state.cached_scene_dict,
      state.css2d_renderer,
      state.css3d_renderer,
    );
  } else {
    return state;
  }
}

function handle_update_camera_postprocessing(state, id, pp) {
  let _block;
  if (pp instanceof $option.Some) {
    let pp_config = pp[0];
    _block = $object_cache.set_camera_postprocessing(state.cache, id, pp_config);
  } else {
    _block = $object_cache.remove_camera_postprocessing(state.cache, id);
  }
  let new_cache = _block;
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function create_animation_action_ffi(mixer, clip) {
  return $savoiardi.clip_action(mixer, clip);
}

function set_animation_time_scale_ffi(action, time_scale) {
  return $savoiardi.set_action_time_scale(action, time_scale);
}

function set_animation_weight_ffi(action, weight) {
  return $savoiardi.set_action_weight(action, weight);
}

function play_animation_action_ffi(action) {
  return $savoiardi.play_action(action);
}

function create_animation_action(mixer, animation) {
  let three_animation_action = create_animation_action_ffi(
    mixer,
    animation.clip,
  );
  let _block;
  let $ = animation.loop;
  if ($ instanceof $model.LoopOnce) {
    _block = new $savoiardi.LoopOnce();
  } else {
    _block = new $savoiardi.LoopRepeat();
  }
  let loop_mode = _block;
  $savoiardi.set_action_loop(three_animation_action, loop_mode);
  set_animation_time_scale_ffi(three_animation_action, animation.speed);
  set_animation_weight_ffi(three_animation_action, animation.weight);
  play_animation_action_ffi(three_animation_action);
  return three_animation_action;
}

function stop_animation_action_ffi(action) {
  return $savoiardi.stop_action(action);
}

function stop_actions(actions) {
  if (actions instanceof $object_cache.SingleAction) {
    let action = actions[0];
    return stop_animation_action_ffi(action);
  } else {
    let from_action = actions.from;
    let to_action = actions.to;
    stop_animation_action_ffi(from_action);
    return stop_animation_action_ffi(to_action);
  }
}

function setup_animation(cache, id, mixer, playback) {
  let current_state = $object_cache.get_animation_state(cache, id);
  if (playback instanceof $model.SingleAnimation) {
    let anim = playback[0];
    let new_clip_name = $model.clip_name(anim.clip);
    let new_state = new $object_cache.SingleState(new_clip_name);
    let $ = $object_cache.get_actions(cache, id);
    if (current_state instanceof $option.Some && $ instanceof $option.Some) {
      let $1 = current_state[0];
      if ($1 instanceof $object_cache.SingleState) {
        let $2 = $[0];
        if ($2 instanceof $object_cache.SingleAction) {
          let current_clip_name = $1.clip_name;
          if (current_clip_name === new_clip_name) {
            let existing_action = $2[0];
            set_animation_weight_ffi(existing_action, anim.weight);
            set_animation_time_scale_ffi(existing_action, anim.speed);
            return $object_cache.set_animation_state(cache, id, new_state);
          } else {
            let $3 = $object_cache.get_actions(cache, id);
            if ($3 instanceof $option.Some) {
              let actions = $3[0];
              stop_actions(actions)
            } else {
              undefined
            }
            let action = create_animation_action(mixer, anim);
            let actions = new $object_cache.SingleAction(action);
            let _pipe = cache;
            let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
            return $object_cache.set_animation_state(_pipe$1, id, new_state);
          }
        } else {
          let $3 = $object_cache.get_actions(cache, id);
          if ($3 instanceof $option.Some) {
            let actions = $3[0];
            stop_actions(actions)
          } else {
            undefined
          }
          let action = create_animation_action(mixer, anim);
          let actions = new $object_cache.SingleAction(action);
          let _pipe = cache;
          let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
          return $object_cache.set_animation_state(_pipe$1, id, new_state);
        }
      } else {
        let $2 = $object_cache.get_actions(cache, id);
        if ($2 instanceof $option.Some) {
          let actions = $2[0];
          stop_actions(actions)
        } else {
          undefined
        }
        let action = create_animation_action(mixer, anim);
        let actions = new $object_cache.SingleAction(action);
        let _pipe = cache;
        let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
        return $object_cache.set_animation_state(_pipe$1, id, new_state);
      }
    } else {
      let $1 = $object_cache.get_actions(cache, id);
      if ($1 instanceof $option.Some) {
        let actions = $1[0];
        stop_actions(actions)
      } else {
        undefined
      }
      let action = create_animation_action(mixer, anim);
      let actions = new $object_cache.SingleAction(action);
      let _pipe = cache;
      let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
      return $object_cache.set_animation_state(_pipe$1, id, new_state);
    }
  } else {
    let from_anim = playback.from;
    let to_anim = playback.to;
    let blend_factor = playback.blend_factor;
    let from_clip_name = $model.clip_name(from_anim.clip);
    let to_clip_name = $model.clip_name(to_anim.clip);
    let new_state = new $object_cache.BlendedState(from_clip_name, to_clip_name);
    let $ = $object_cache.get_actions(cache, id);
    if (current_state instanceof $option.Some && $ instanceof $option.Some) {
      let $1 = current_state[0];
      if ($1 instanceof $object_cache.BlendedState) {
        let $2 = $[0];
        if ($2 instanceof $object_cache.BlendedActions) {
          let current_from = $1.from_clip_name;
          let current_to = $1.to_clip_name;
          if ((current_from === from_clip_name) && (current_to === to_clip_name)) {
            let existing_from_action = $2.from;
            let existing_to_action = $2.to;
            set_animation_weight_ffi(
              existing_from_action,
              (1.0 - blend_factor) * from_anim.weight,
            );
            set_animation_weight_ffi(
              existing_to_action,
              blend_factor * to_anim.weight,
            );
            return $object_cache.set_animation_state(cache, id, new_state);
          } else {
            let $3 = $object_cache.get_actions(cache, id);
            if ($3 instanceof $option.Some) {
              let actions = $3[0];
              stop_actions(actions)
            } else {
              undefined
            }
            let from_action = create_animation_action(mixer, from_anim);
            let to_action = create_animation_action(mixer, to_anim);
            set_animation_weight_ffi(
              from_action,
              (1.0 - blend_factor) * from_anim.weight,
            );
            set_animation_weight_ffi(to_action, blend_factor * to_anim.weight);
            let actions = new $object_cache.BlendedActions(
              from_action,
              to_action,
            );
            let _pipe = cache;
            let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
            return $object_cache.set_animation_state(_pipe$1, id, new_state);
          }
        } else {
          let $3 = $object_cache.get_actions(cache, id);
          if ($3 instanceof $option.Some) {
            let actions = $3[0];
            stop_actions(actions)
          } else {
            undefined
          }
          let from_action = create_animation_action(mixer, from_anim);
          let to_action = create_animation_action(mixer, to_anim);
          set_animation_weight_ffi(
            from_action,
            (1.0 - blend_factor) * from_anim.weight,
          );
          set_animation_weight_ffi(to_action, blend_factor * to_anim.weight);
          let actions = new $object_cache.BlendedActions(from_action, to_action);
          let _pipe = cache;
          let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
          return $object_cache.set_animation_state(_pipe$1, id, new_state);
        }
      } else {
        let $2 = $object_cache.get_actions(cache, id);
        if ($2 instanceof $option.Some) {
          let actions = $2[0];
          stop_actions(actions)
        } else {
          undefined
        }
        let from_action = create_animation_action(mixer, from_anim);
        let to_action = create_animation_action(mixer, to_anim);
        set_animation_weight_ffi(
          from_action,
          (1.0 - blend_factor) * from_anim.weight,
        );
        set_animation_weight_ffi(to_action, blend_factor * to_anim.weight);
        let actions = new $object_cache.BlendedActions(from_action, to_action);
        let _pipe = cache;
        let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
        return $object_cache.set_animation_state(_pipe$1, id, new_state);
      }
    } else {
      let $1 = $object_cache.get_actions(cache, id);
      if ($1 instanceof $option.Some) {
        let actions = $1[0];
        stop_actions(actions)
      } else {
        undefined
      }
      let from_action = create_animation_action(mixer, from_anim);
      let to_action = create_animation_action(mixer, to_anim);
      set_animation_weight_ffi(
        from_action,
        (1.0 - blend_factor) * from_anim.weight,
      );
      set_animation_weight_ffi(to_action, blend_factor * to_anim.weight);
      let actions = new $object_cache.BlendedActions(from_action, to_action);
      let _pipe = cache;
      let _pipe$1 = $object_cache.set_actions(_pipe, id, actions);
      return $object_cache.set_animation_state(_pipe$1, id, new_state);
    }
  }
}

function handle_add_model3d(
  state,
  id,
  object,
  transform,
  animation,
  physics,
  material,
  transparent,
  parent_id
) {
  let _block;
  if (animation instanceof $option.Some) {
    _block = object;
  } else {
    _block = $savoiardi.clone_object(object);
  }
  let model_object = _block;
  $savoiardi.apply_transform_with_quaternion(
    model_object,
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  if (material instanceof $option.Some) {
    let mat = material[0];
    $savoiardi.apply_material_to_object(
      model_object,
      $material.create_material(mat),
    )
  } else {
    undefined
  }
  if (transparent) {
    $savoiardi.enable_transparency(model_object)
  } else {
    undefined
  }
  $savoiardi.enable_shadows(model_object, true, true);
  let mixer = $savoiardi.create_animation_mixer(model_object);
  let cache_with_mixer = $object_cache.add_mixer(state.cache, id, mixer);
  let _block$1;
  if (animation instanceof $option.Some) {
    let anim_playback = animation[0];
    _block$1 = setup_animation(cache_with_mixer, id, mixer, anim_playback);
  } else {
    _block$1 = cache_with_mixer;
  }
  let cache_with_animation = _block$1;
  add_to_scene_or_parent(state, model_object, parent_id);
  let new_cache = $object_cache.add_object(
    cache_with_animation,
    id,
    model_object,
  );
  let new_state = new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
  let $ = new_state.physics_world;
  if (physics instanceof $option.Some && $ instanceof $option.Some) {
    let physics_config = physics[0];
    let world = $[0];
    let new_world = $physics.create_body(world, id, physics_config, transform);
    return new RendererState(
      new_state.renderer,
      new_state.scene,
      new_state.cache,
      new $option.Some(new_world),
      new_state.audio_manager,
      new_state.audio_listener,
      new_state.cached_scene_dict,
      new_state.css2d_renderer,
      new_state.css3d_renderer,
    );
  } else {
    return new_state;
  }
}

function handle_update_animation(state, id, animation) {
  let $ = $object_cache.get_mixer(state.cache, id);
  if ($ instanceof $option.Some) {
    let mixer = $[0];
    if (animation instanceof $option.Some) {
      let anim_playback = animation[0];
      let new_cache = setup_animation(state.cache, id, mixer, anim_playback);
      return new RendererState(
        state.renderer,
        state.scene,
        new_cache,
        state.physics_world,
        state.audio_manager,
        state.audio_listener,
        state.cached_scene_dict,
        state.css2d_renderer,
        state.css3d_renderer,
      );
    } else {
      let $1 = $object_cache.get_actions(state.cache, id);
      if ($1 instanceof $option.Some) {
        let actions = $1[0];
        stop_actions(actions);
        let new_cache = $object_cache.remove_actions(state.cache, id);
        return new RendererState(
          state.renderer,
          state.scene,
          new_cache,
          state.physics_world,
          state.audio_manager,
          state.audio_listener,
          state.cached_scene_dict,
          state.css2d_renderer,
          state.css3d_renderer,
        );
      } else {
        return state;
      }
    }
  } else {
    return state;
  }
}

export function update_mixers(state, delta_time) {
  let delta_time_seconds = $duration.to_seconds(delta_time);
  let mixers = $object_cache.get_all_mixers(state.cache);
  return $list.each(
    mixers,
    (entry) => {
      let mixer;
      mixer = entry[1];
      return $savoiardi.update_mixer(mixer, delta_time_seconds);
    },
  );
}

export function sync_physics_transforms(state) {
  let $ = state.physics_world;
  if ($ instanceof $option.Some) {
    let world = $[0];
    return $physics.for_each_body_raw(
      world,
      (id, position, quaternion, body_type) => {
        if (body_type instanceof $physics.Dynamic) {
          let $1 = $object_cache.get_object(state.cache, id);
          if ($1 instanceof Ok) {
            let obj = $1[0];
            $savoiardi.apply_transform_with_quaternion(
              obj,
              position,
              quaternion,
              $vec3f.one,
            );
            return $savoiardi.update_matrix_world_force(obj, true);
          } else {
            return undefined;
          }
        } else if (body_type instanceof $physics.Kinematic) {
          return undefined;
        } else {
          return undefined;
        }
      },
    );
  } else {
    return undefined;
  }
}

export function clear_cache(state) {
  let objects = $object_cache.get_all_objects(state.cache);
  $list.each(
    objects,
    (entry) => {
      let obj;
      obj = entry[1];
      return $savoiardi.dispose_object(obj);
    },
  );
  return new RendererState(
    state.renderer,
    state.scene,
    $object_cache.init(),
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

export function get_cameras_with_viewports(state) {
  let _pipe = $object_cache.get_cameras_with_viewports(state.cache);
  return $list.map(
    _pipe,
    (entry) => {
      let camera_obj;
      let viewport;
      camera_obj = entry[0];
      viewport = entry[1];
      return [camera_obj, viewport];
    },
  );
}

/**
 * Get all cameras with their viewport and postprocessing configurations
 * Returns: List of (camera_id_string, camera_object, Option(viewport), Option(postprocessing), is_active)
 * 
 * @ignore
 */
export function get_all_cameras_with_info(state) {
  let _pipe = $object_cache.get_all_cameras_with_info(state.cache);
  return $list.map(
    _pipe,
    (entry) => {
      let id_string;
      let camera_obj;
      let viewport_opt;
      let pp_opt;
      let is_active;
      id_string = entry[0];
      camera_obj = entry[1];
      viewport_opt = entry[2];
      pp_opt = entry[3];
      is_active = entry[4];
      return [id_string, camera_obj, viewport_opt, pp_opt, is_active];
    },
  );
}

function handle_add_light(state, id, light_config, transform, parent_id) {
  let light$1 = $light.create_light(light_config);
  $savoiardi.apply_transform_with_quaternion(
    (() => {
      let _pipe = light$1;
      return coerce(_pipe);
    })(),
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  add_to_scene_or_parent(
    state,
    (() => {
      let _pipe = light$1;
      return coerce(_pipe);
    })(),
    parent_id,
  );
  let new_cache = $object_cache.add_object(
    state.cache,
    id,
    (() => {
      let _pipe = light$1;
      return coerce(_pipe);
    })(),
  );
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_lod(state, id, transform, levels, parent_id) {
  let lod$1 = $savoiardi.create_lod();
  $savoiardi.apply_transform_with_quaternion(
    (() => {
      let _pipe = lod$1;
      return coerce(_pipe);
    })(),
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  $list.each(
    levels,
    (level) => {
      let level_obj = create_lod_level_object(level.node);
      return $savoiardi.add_lod_level(lod$1, level_obj, level.distance);
    },
  );
  add_to_scene_or_parent(
    state,
    (() => {
      let _pipe = lod$1;
      return coerce(_pipe);
    })(),
    parent_id,
  );
  let new_cache = $object_cache.add_object(
    state.cache,
    id,
    (() => {
      let _pipe = lod$1;
      return coerce(_pipe);
    })(),
  );
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_camera(
  state,
  id,
  camera_type,
  transform,
  active,
  viewport,
  postprocessing,
  parent_id
) {
  let aspect = calculate_aspect_ratio(viewport, state.renderer);
  let projection = $camera.get_projection(camera_type);
  let _block;
  if (projection instanceof $camera.Perspective) {
    let fov = projection.fov;
    let near = projection.near;
    let far = projection.far;
    _block = $savoiardi.create_perspective_camera(fov, aspect, near, far);
  } else {
    let left = projection.left;
    let right = projection.right;
    let top = projection.top;
    let bottom = projection.bottom;
    let near = projection.near;
    let far = projection.far;
    _block = $savoiardi.create_orthographic_camera(
      left,
      right,
      top,
      bottom,
      near,
      far,
    );
  }
  let camera$1 = _block;
  $savoiardi.add_child(
    (() => {
      let _pipe = camera$1;
      return coerce(_pipe);
    })(),
    (() => {
      let _pipe = state.audio_listener;
      return coerce(_pipe);
    })(),
  );
  $savoiardi.apply_transform_with_quaternion(
    (() => {
      let _pipe = camera$1;
      return coerce(_pipe);
    })(),
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  $savoiardi.update_camera_projection_matrix(camera$1);
  if (parent_id instanceof $option.Some) {
    let parent_id$1 = parent_id[0];
    let $ = $object_cache.get_object(state.cache, parent_id$1);
    if ($ instanceof Ok) {
      let parent_obj = $[0];
      $savoiardi.add_child(
        parent_obj,
        (() => {
          let _pipe = camera$1;
          return coerce(_pipe);
        })(),
      )
    } else {
      $savoiardi.add_to_scene(
        state.scene,
        (() => {
          let _pipe = camera$1;
          return coerce(_pipe);
        })(),
      )
    }
  } else {
    $savoiardi.add_to_scene(
      state.scene,
      (() => {
        let _pipe = camera$1;
        return coerce(_pipe);
      })(),
    )
  }
  let _block$1;
  if (viewport instanceof $option.Some) {
    let x = viewport[0][0];
    let y = viewport[0][1];
    let width = viewport[0][2];
    let height = viewport[0][3];
    let vp = new $camera.ViewPort(
      new $vec2.Vec2(x, y),
      new $vec2.Vec2(width, height),
    );
    _block$1 = $object_cache.set_viewport(state.cache, id, vp);
  } else {
    _block$1 = state.cache;
  }
  let cache_with_viewport = _block$1;
  let _block$2;
  if (postprocessing instanceof $option.Some) {
    let pp = postprocessing[0];
    _block$2 = $object_cache.set_camera_postprocessing(
      cache_with_viewport,
      id,
      pp,
    );
  } else {
    _block$2 = cache_with_viewport;
  }
  let cache_with_postprocessing = _block$2;
  let cache_with_camera = $object_cache.add_camera(
    cache_with_postprocessing,
    id,
  );
  let _block$3;
  if (active) {
    _block$3 = $object_cache.set_active_camera(cache_with_camera, id);
  } else {
    _block$3 = cache_with_camera;
  }
  let cache_with_active = _block$3;
  let new_cache = $object_cache.add_object(
    cache_with_active,
    id,
    (() => {
      let _pipe = camera$1;
      return coerce(_pipe);
    })(),
  );
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_update_light(state, id, light) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let old_object = $[0];
    let position = $savoiardi.get_object_position(old_object);
    let rotation = $savoiardi.get_object_rotation(old_object);
    let scale = $savoiardi.get_object_scale(old_object);
    let new_light = $light.create_light(light);
    let new_light_obj = coerce(new_light);
    $savoiardi.set_object_position(new_light_obj, position);
    $savoiardi.set_object_rotation(new_light_obj, rotation);
    $savoiardi.set_object_scale(new_light_obj, scale);
    $savoiardi.remove_from_scene(state.scene, old_object);
    $savoiardi.add_to_scene(
      state.scene,
      (() => {
        let _pipe = new_light;
        return coerce(_pipe);
      })(),
    );
    let new_cache = $object_cache.add_object(
      state.cache,
      id,
      (() => {
        let _pipe = new_light;
        return coerce(_pipe);
      })(),
    );
    return new RendererState(
      state.renderer,
      state.scene,
      new_cache,
      state.physics_world,
      state.audio_manager,
      state.audio_listener,
      state.cached_scene_dict,
      state.css2d_renderer,
      state.css3d_renderer,
    );
  } else {
    return state;
  }
}

function handle_update_lod_levels(state, id, levels) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    $savoiardi.clear_lod_levels(
      (() => {
        let _pipe = object;
        return coerce(_pipe);
      })(),
    );
    $list.each(
      levels,
      (level) => {
        let level_obj = create_lod_level_object(level.node);
        return $savoiardi.add_lod_level(
          (() => {
            let _pipe = object;
            return coerce(_pipe);
          })(),
          level_obj,
          level.distance,
        );
      },
    );
    return state;
  } else {
    return state;
  }
}

function handle_update_camera(state, id, camera_type) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    let projection = $camera.get_projection(camera_type);
    if (projection instanceof $camera.Perspective) {
      let fov = projection.fov;
      let near = projection.near;
      let far = projection.far;
      let viewport = $object_cache.get_viewport(state.cache, id);
      let _block;
      if (viewport instanceof $option.Some) {
        let position = viewport[0].position;
        let size = viewport[0].size;
        _block = new $option.Some([position.x, position.y, size.x, size.y]);
      } else {
        _block = viewport;
      }
      let viewport_tuple = _block;
      let calculated_aspect = calculate_aspect_ratio(
        viewport_tuple,
        state.renderer,
      );
      $savoiardi.set_perspective_camera_params(
        (() => {
          let _pipe = object;
          return coerce(_pipe);
        })(),
        fov,
        calculated_aspect,
        near,
        far,
      )
    } else {
      let left = projection.left;
      let right = projection.right;
      let top = projection.top;
      let bottom = projection.bottom;
      let near = projection.near;
      let far = projection.far;
      $savoiardi.set_orthographic_camera_params(
        (() => {
          let _pipe = object;
          return coerce(_pipe);
        })(),
        left,
        right,
        top,
        bottom,
        near,
        far,
      )
    }
    $savoiardi.update_camera_projection_matrix(
      (() => {
        let _pipe = object;
        return coerce(_pipe);
      })(),
    );
    return state;
  } else {
    return state;
  }
}

function handle_add_css2d(state, id, html, transform, parent_id) {
  let css2d_object = $savoiardi.create_css2d_object(html);
  $savoiardi.apply_transform_with_quaternion(
    (() => {
      let _pipe = css2d_object;
      return coerce(_pipe);
    })(),
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  add_to_scene_or_parent(
    state,
    (() => {
      let _pipe = css2d_object;
      return coerce(_pipe);
    })(),
    parent_id,
  );
  let new_cache = $object_cache.add_object(
    state.cache,
    id,
    (() => {
      let _pipe = css2d_object;
      return coerce(_pipe);
    })(),
  );
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_update_css2d(state, id, html, transform) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    $savoiardi.update_css2d_object_html(
      (() => {
        let _pipe = object;
        return coerce(_pipe);
      })(),
      html,
    );
    $savoiardi.apply_transform_with_quaternion(
      object,
      $transform.position(transform),
      $transform.rotation_quaternion(transform),
      $transform.scale(transform),
    );
    return state;
  } else {
    return state;
  }
}

function handle_add_css3d(state, id, html, transform, parent_id) {
  let css3d_object = $savoiardi.create_css3d_object(html);
  $savoiardi.apply_transform_with_quaternion(
    (() => {
      let _pipe = css3d_object;
      return coerce(_pipe);
    })(),
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  add_to_scene_or_parent(
    state,
    (() => {
      let _pipe = css3d_object;
      return coerce(_pipe);
    })(),
    parent_id,
  );
  let new_cache = $object_cache.add_object(
    state.cache,
    id,
    (() => {
      let _pipe = css3d_object;
      return coerce(_pipe);
    })(),
  );
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_update_css3d(state, id, html, transform) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    $savoiardi.update_css3d_object_html(
      (() => {
        let _pipe = object;
        return coerce(_pipe);
      })(),
      html,
    );
    $savoiardi.apply_transform_with_quaternion(
      object,
      $transform.position(transform),
      $transform.rotation_quaternion(transform),
      $transform.scale(transform),
    );
    return state;
  } else {
    return state;
  }
}

function handle_add_animated_sprite(
  state,
  id,
  sprite,
  width,
  height,
  trans,
  physics,
  parent_id
) {
  let base_texture = $spritesheet.sprite_texture(sprite);
  let sprite_texture = $texture.clone(base_texture);
  let $ = $spritesheet.sprite_frame_repeat(sprite);
  let repeat_x;
  let repeat_y;
  repeat_x = $[0];
  repeat_y = $[1];
  let _pipe = sprite_texture;
  let _pipe$1 = $texture.set_repeat(_pipe, new $vec2.Vec2(repeat_x, repeat_y));
  $texture.set_wrap_mode(
    _pipe$1,
    new $texture.RepeatWrapping(),
    new $texture.RepeatWrapping(),
  )
  let $1 = $spritesheet.sprite_pixel_art(sprite);
  if ($1) {
    let _pipe$2 = sprite_texture;
    $texture.set_filter_mode(
      _pipe$2,
      new $texture.NearestFilter(),
      new $texture.NearestFilter(),
    )
  } else {
    sprite_texture
  }
  let $2 = $spritesheet.sprite_frame_offset(sprite);
  let offset_x;
  let offset_y;
  offset_x = $2[0];
  offset_y = $2[1];
  let _pipe$2 = sprite_texture;
  $texture.set_offset(_pipe$2, new $vec2.Vec2(offset_x, offset_y))
  let sprite_mesh = create_canvas_plane(sprite_texture, width, height);
  $savoiardi.apply_transform_with_quaternion(
    sprite_mesh,
    $transform.position(trans),
    $transform.rotation_quaternion(trans),
    $transform.scale(trans),
  );
  add_to_scene_or_parent(state, sprite_mesh, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, sprite_mesh);
  let new_state = new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
  let $3 = new_state.physics_world;
  if (physics instanceof $option.Some && $3 instanceof $option.Some) {
    let physics_config = physics[0];
    let world = $3[0];
    let new_world = $physics.create_body(world, id, physics_config, trans);
    return new RendererState(
      new_state.renderer,
      new_state.scene,
      new_state.cache,
      new $option.Some(new_world),
      new_state.audio_manager,
      new_state.audio_listener,
      new_state.cached_scene_dict,
      new_state.css2d_renderer,
      new_state.css3d_renderer,
    );
  } else {
    return new_state;
  }
}

function handle_update_animated_sprite(state, id, sprite, width, height, trans) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let obj = $[0];
    let base_texture = $spritesheet.sprite_texture(sprite);
    let sprite_texture = $texture.clone(base_texture);
    let $1 = $spritesheet.sprite_frame_repeat(sprite);
    let repeat_x;
    let repeat_y;
    repeat_x = $1[0];
    repeat_y = $1[1];
    let _pipe = sprite_texture;
    let _pipe$1 = $texture.set_repeat(_pipe, new $vec2.Vec2(repeat_x, repeat_y));
    $texture.set_wrap_mode(
      _pipe$1,
      new $texture.RepeatWrapping(),
      new $texture.RepeatWrapping(),
    )
    let $2 = $spritesheet.sprite_pixel_art(sprite);
    if ($2) {
      let _pipe$2 = sprite_texture;
      $texture.set_filter_mode(
        _pipe$2,
        new $texture.NearestFilter(),
        new $texture.NearestFilter(),
      )
    } else {
      sprite_texture
    }
    let $3 = $spritesheet.sprite_frame_offset(sprite);
    let offset_x;
    let offset_y;
    offset_x = $3[0];
    offset_y = $3[1];
    let _pipe$2 = sprite_texture;
    $texture.set_offset(_pipe$2, new $vec2.Vec2(offset_x, offset_y))
    update_canvas_texture(obj, sprite_texture);
    update_canvas_size(obj, width, height);
    $savoiardi.apply_transform_with_quaternion(
      obj,
      $transform.position(trans),
      $transform.rotation_quaternion(trans),
      $transform.scale(trans),
    );
    return state;
  } else {
    return state;
  }
}

function handle_add_canvas(
  state,
  id,
  encoded_picture,
  texture_width,
  texture_height,
  width,
  height,
  transform,
  parent_id
) {
  let texture = create_canvas_texture_from_picture(
    encoded_picture,
    texture_width,
    texture_height,
  );
  let canvas_mesh = create_canvas_plane(texture, width, height);
  $savoiardi.apply_transform_with_quaternion(
    canvas_mesh,
    $transform.position(transform),
    $transform.rotation_quaternion(transform),
    $transform.scale(transform),
  );
  set_canvas_cached_picture(canvas_mesh, encoded_picture);
  add_to_scene_or_parent(state, canvas_mesh, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, canvas_mesh);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_update_canvas(
  state,
  id,
  encoded_picture,
  texture_width,
  texture_height,
  width,
  height,
  transform
) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    let cached_picture = get_canvas_cached_picture(object);
    let picture_changed = cached_picture !== encoded_picture;
    if (picture_changed) {
      let texture = create_canvas_texture_from_picture(
        encoded_picture,
        texture_width,
        texture_height,
      );
      update_canvas_texture(object, texture);
      set_canvas_cached_picture(object, encoded_picture)
    } else {
      undefined
    }
    update_canvas_size(object, width, height);
    $savoiardi.apply_transform_with_quaternion(
      object,
      $transform.position(transform),
      $transform.rotation_quaternion(transform),
      $transform.scale(transform),
    );
    return state;
  } else {
    return state;
  }
}

function handle_add_debug_box(state, id, min, max, color, parent_id) {
  let debug = create_debug_box(min, max, color);
  add_to_scene_or_parent(state, debug, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, debug);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_debug_sphere(state, id, center, radius, color, parent_id) {
  let debug = create_debug_sphere(center, radius, color);
  add_to_scene_or_parent(state, debug, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, debug);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_debug_line(state, id, from, to, color, parent_id) {
  let debug = create_debug_line(from, to, color);
  add_to_scene_or_parent(state, debug, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, debug);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_debug_axes(state, id, origin, size, parent_id) {
  let debug = create_debug_axes(origin, size);
  add_to_scene_or_parent(state, debug, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, debug);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_debug_grid(state, id, size, divisions, color, parent_id) {
  let debug = create_debug_grid(size, divisions, color);
  add_to_scene_or_parent(state, debug, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, debug);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_debug_point(state, id, position, size, color, parent_id) {
  let debug = create_debug_point(position, size, color);
  add_to_scene_or_parent(state, debug, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, debug);
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

/**
 * Convert a list of Transforms to the tuple format expected by savoiardi
 * 
 * @ignore
 */
function transforms_to_tuples(transforms) {
  return $list.map(
    transforms,
    (t) => {
      return [
        $transform.position(t),
        $transform.rotation(t),
        $transform.scale(t),
      ];
    },
  );
}

function handle_add_instanced_mesh(
  state,
  id,
  geometry,
  material,
  instances,
  parent_id
) {
  let geometry_three = $geometry.create_geometry(geometry);
  let material_three = $material.create_material(material);
  let count = $list.length(instances);
  let mesh$1 = $savoiardi.create_instanced_mesh(
    geometry_three,
    material_three,
    count,
  );
  $savoiardi.update_instanced_mesh_transforms(
    mesh$1,
    transforms_to_tuples(instances),
  );
  add_to_scene_or_parent(
    state,
    (() => {
      let _pipe = mesh$1;
      return coerce(_pipe);
    })(),
    parent_id,
  );
  let new_cache = $object_cache.add_object(
    state.cache,
    id,
    (() => {
      let _pipe = mesh$1;
      return coerce(_pipe);
    })(),
  );
  return new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
}

function handle_add_instanced_model(
  state,
  id,
  object,
  instances,
  physics,
  material,
  transparent,
  parent_id
) {
  let $ = $savoiardi.extract_mesh_material_pairs(object);
  let geometries;
  let materials;
  geometries = $[0];
  materials = $[1];
  let _block;
  if (material instanceof $option.Some) {
    let mat = material[0];
    let three_mat = $material.create_material(mat);
    _block = $list.repeat(three_mat, $array.size(geometries));
  } else {
    _block = $array.to_list(materials);
  }
  let materials$1 = _block;
  let group = $savoiardi.create_group();
  let count = $list.length(instances);
  let _pipe = $list.zip($array.to_list(geometries), materials$1);
  $list.each(
    _pipe,
    (pair) => {
      let geometry;
      let material$1;
      geometry = pair[0];
      material$1 = pair[1];
      let instanced_mesh$1 = $savoiardi.create_instanced_mesh(
        geometry,
        material$1,
        count,
      );
      $savoiardi.update_instanced_mesh_transforms(
        instanced_mesh$1,
        transforms_to_tuples(instances),
      );
      return $savoiardi.add_child(group, coerce(instanced_mesh$1));
    },
  )
  if (transparent) {
    $savoiardi.enable_transparency(group)
  } else {
    undefined
  }
  $savoiardi.enable_shadows(group, true, true);
  add_to_scene_or_parent(state, group, parent_id);
  let new_cache = $object_cache.add_object(state.cache, id, group);
  let new_state = new RendererState(
    state.renderer,
    state.scene,
    new_cache,
    state.physics_world,
    state.audio_manager,
    state.audio_listener,
    state.cached_scene_dict,
    state.css2d_renderer,
    state.css3d_renderer,
  );
  let $1 = new_state.physics_world;
  if (physics instanceof $option.Some && $1 instanceof $option.Some) {
    let physics_config = physics[0];
    let world = $1[0];
    let new_world = $list.index_fold(
      instances,
      world,
      (world_acc, instance_transform, idx) => {
        let instance_id = generate_instance_id(id, idx);
        return $physics.create_body(
          world_acc,
          instance_id,
          physics_config,
          instance_transform,
        );
      },
    );
    return new RendererState(
      new_state.renderer,
      new_state.scene,
      new_state.cache,
      new $option.Some(new_world),
      new_state.audio_manager,
      new_state.audio_listener,
      new_state.cached_scene_dict,
      new_state.css2d_renderer,
      new_state.css3d_renderer,
    );
  } else {
    return new_state;
  }
}

function handle_add_node(state, id, node, parent_id) {
  if (node instanceof Empty) {
    let transform = node.transform;
    return handle_add_group(state, id, transform, parent_id);
  } else if (node instanceof Mesh) {
    let transform = node.transform;
    let geometry = node.geometry;
    let material = node.material;
    let physics = node.physics;
    return handle_add_mesh(
      state,
      id,
      geometry,
      material,
      transform,
      physics,
      parent_id,
    );
  } else if (node instanceof InstancedMesh) {
    let geometry = node.geometry;
    let material = node.material;
    let instances = node.instances;
    return handle_add_instanced_mesh(
      state,
      id,
      geometry,
      material,
      instances,
      parent_id,
    );
  } else if (node instanceof Light) {
    let transform = node.transform;
    let light$1 = node.light;
    return handle_add_light(state, id, light$1, transform, parent_id);
  } else if (node instanceof Camera) {
    let camera$1 = node.camera;
    let transform = node.transform;
    let active = node.active;
    let viewport = node.viewport;
    let postprocessing = node.postprocessing;
    return handle_add_camera(
      state,
      id,
      camera$1,
      transform,
      active,
      viewport,
      postprocessing,
      parent_id,
    );
  } else if (node instanceof LOD) {
    let levels = node.levels;
    let transform = node.transform;
    return handle_add_lod(state, id, transform, levels, parent_id);
  } else if (node instanceof Model3D) {
    let object = node.object;
    let transform = node.transform;
    let animation = node.animation;
    let physics = node.physics;
    let material = node.material;
    let transparent = node.transparent;
    return handle_add_model3d(
      state,
      id,
      object,
      transform,
      animation,
      physics,
      material,
      transparent,
      parent_id,
    );
  } else if (node instanceof InstancedModel) {
    let object = node.object;
    let instances = node.instances;
    let physics = node.physics;
    let material = node.material;
    let transparent = node.transparent;
    return handle_add_instanced_model(
      state,
      id,
      object,
      instances,
      physics,
      material,
      transparent,
      parent_id,
    );
  } else if (node instanceof Audio) {
    let audio$1 = node.audio;
    return handle_add_audio(state, id, audio$1, parent_id);
  } else if (node instanceof CSS2D) {
    let html = node.html;
    let trans = node.transform;
    return handle_add_css2d(state, id, html, trans, parent_id);
  } else if (node instanceof CSS3D) {
    let html = node.html;
    let trans = node.transform;
    return handle_add_css3d(state, id, html, trans, parent_id);
  } else if (node instanceof Canvas) {
    let encoded_picture = node.encoded_picture;
    let tw = node.texture_width;
    let th = node.texture_height;
    let w = node.width;
    let h = node.height;
    let trans = node.transform;
    return handle_add_canvas(
      state,
      id,
      encoded_picture,
      tw,
      th,
      w,
      h,
      trans,
      parent_id,
    );
  } else if (node instanceof AnimatedSprite) {
    let spr = node.sprite;
    let w = node.width;
    let h = node.height;
    let trans = node.transform;
    let physics = node.physics;
    return handle_add_animated_sprite(
      state,
      id,
      spr,
      w,
      h,
      trans,
      physics,
      parent_id,
    );
  } else if (node instanceof DebugBox) {
    let min = node.min;
    let max = node.max;
    let color = node.color;
    return handle_add_debug_box(state, id, min, max, color, parent_id);
  } else if (node instanceof DebugSphere) {
    let center = node.center;
    let radius = node.radius;
    let color = node.color;
    return handle_add_debug_sphere(state, id, center, radius, color, parent_id);
  } else if (node instanceof DebugLine) {
    let from = node.from;
    let to = node.to;
    let color = node.color;
    return handle_add_debug_line(state, id, from, to, color, parent_id);
  } else if (node instanceof DebugAxes) {
    let origin = node.origin;
    let size = node.size;
    return handle_add_debug_axes(state, id, origin, size, parent_id);
  } else if (node instanceof DebugGrid) {
    let size = node.size;
    let divisions = node.divisions;
    let color = node.color;
    return handle_add_debug_grid(state, id, size, divisions, color, parent_id);
  } else {
    let position = node.position;
    let size = node.size;
    let color = node.color;
    return handle_add_debug_point(state, id, position, size, color, parent_id);
  }
}

function handle_update_instances(state, id, instances) {
  let $ = $object_cache.get_object(state.cache, id);
  if ($ instanceof Ok) {
    let object = $[0];
    $savoiardi.update_instanced_mesh_transforms(
      coerce(object),
      transforms_to_tuples(instances),
    );
    return state;
  } else {
    return state;
  }
}

export function apply_patch(state, patch) {
  if (patch instanceof AddNode) {
    let id_val = patch.id;
    let node = patch.node;
    let parent_id = patch.parent_id;
    return handle_add_node(state, id_val, node, parent_id);
  } else if (patch instanceof RemoveNode) {
    let id_val = patch.id;
    return handle_remove_node(state, id_val);
  } else if (patch instanceof UpdateTransform) {
    let id_val = patch.id;
    let transform = patch.transform;
    return handle_update_transform(state, id_val, transform);
  } else if (patch instanceof UpdateMaterial) {
    let id_val = patch.id;
    let material = patch.material;
    return handle_update_material(state, id_val, material);
  } else if (patch instanceof UpdateGeometry) {
    let id_val = patch.id;
    let geometry = patch.geometry;
    return handle_update_geometry(state, id_val, geometry);
  } else if (patch instanceof UpdateLight) {
    let id_val = patch.id;
    let light$1 = patch.light;
    return handle_update_light(state, id_val, light$1);
  } else if (patch instanceof UpdateAnimation) {
    let id_val = patch.id;
    let animation = patch.animation;
    return handle_update_animation(state, id_val, animation);
  } else if (patch instanceof UpdatePhysics) {
    let id_val = patch.id;
    let physics = patch.physics;
    return handle_update_physics(state, id_val, physics);
  } else if (patch instanceof UpdateAudio) {
    let id_val = patch.id;
    let audio$1 = patch.audio;
    return handle_update_audio(state, id_val, audio$1);
  } else if (patch instanceof UpdateInstances) {
    let id_val = patch.id;
    let instances = patch.instances;
    return handle_update_instances(state, id_val, instances);
  } else if (patch instanceof UpdateLODLevels) {
    let id_val = patch.id;
    let levels = patch.levels;
    return handle_update_lod_levels(state, id_val, levels);
  } else if (patch instanceof UpdateCamera) {
    let id_val = patch.id;
    let camera_type = patch.camera_type;
    return handle_update_camera(state, id_val, camera_type);
  } else if (patch instanceof SetActiveCamera) {
    let id_val = patch.id;
    return handle_set_active_camera(state, id_val);
  } else if (patch instanceof UpdateCameraPostprocessing) {
    let id_val = patch.id;
    let pp = patch.postprocessing;
    return handle_update_camera_postprocessing(state, id_val, pp);
  } else if (patch instanceof UpdateCSS2DLabel) {
    let id_val = patch.id;
    let html = patch.html;
    let trans = patch.transform;
    return handle_update_css2d(state, id_val, html, trans);
  } else if (patch instanceof UpdateCSS3DLabel) {
    let id_val = patch.id;
    let html = patch.html;
    let trans = patch.transform;
    return handle_update_css3d(state, id_val, html, trans);
  } else if (patch instanceof UpdateCanvas) {
    let id_val = patch.id;
    let encoded_picture = patch.encoded_picture;
    let tw = patch.texture_width;
    let th = patch.texture_height;
    let w = patch.width;
    let h = patch.height;
    let trans = patch.transform;
    return handle_update_canvas(
      state,
      id_val,
      encoded_picture,
      tw,
      th,
      w,
      h,
      trans,
    );
  } else {
    let id_val = patch.id;
    let spr = patch.sprite;
    let w = patch.width;
    let h = patch.height;
    let trans = patch.transform;
    return handle_update_animated_sprite(state, id_val, spr, w, h, trans);
  }
}

export function apply_patches(state, patches) {
  return $list.fold(
    patches,
    state,
    (st, patch) => { return apply_patch(st, patch); },
  );
}
