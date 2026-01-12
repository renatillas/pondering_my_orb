//// <script>
//// const docs = [
////   {
////     header: "Scene",
////     functions: [
////       "create_scene",
////       "set_scene_background_color",
////       "set_scene_background_texture",
////       "set_scene_background_cube_texture",
////       "add_to_scene",
////       "remove_from_scene"
////     ]
////   },
////   {
////     header: "Renderer",
////     functions: [
////       "default_renderer_options",
////       "create_renderer",
////       "get_renderer_dom_element",
////       "set_renderer_size",
////       "set_renderer_pixel_ratio",
////       "render",
////       "clear_renderer",
////       "set_viewport",
////       "set_scissor",
////       "set_scissor_test",
////       "get_render_stats",
////       "get_canvas_dimensions",
////       "get_renderer_info",
////       "is_context_valid"
////     ]
////   },
////   {
////     header: "Camera",
////     functions: [
////       "create_perspective_camera",
////       "create_orthographic_camera",
////       "set_camera_aspect",
////       "set_camera_look_at",
////       "update_camera_projection_matrix",
////       "set_perspective_camera_params",
////       "set_orthographic_camera_params",
////     ]
////   },
////   {
////     header: "Object3D",
////     functions: [
////       "create_group",
////       "create_mesh",
////       "clone_object",
////       "add_child",
////       "remove_child",
////       "apply_transform",
////       "apply_transform_with_quaternion",
////       "update_matrix_world",
////       "update_matrix_world_force",
////       "dispose_object",
////       "set_object_position",
////       "set_object_rotation",
////       "set_object_scale",
////       "set_object_quaternion",
////       "get_object_position",
////       "get_object_rotation",
////       "get_object_scale",
////       "get_object_quaternion",
////       "get_world_position",
////       "get_world_quaternion",
////       "copy_position",
////       "copy_rotation",
////       "copy_scale",
////       "set_shadow_properties",
////       "get_object_geometry",
////       "get_object_material",
////       "set_object_geometry",
////       "set_object_material",
////       "enable_transparency",
////       "apply_material_to_object",
////       "apply_texture_to_object",
////       "extract_mesh_material_pairs",
////       "center_object",
////       "enable_shadows",
////       "object_look_at",
////     ]
////   },
////   {
////     header: "Geometries",
////     functions: [
////       "create_box_geometry",
////       "create_sphere_geometry",
////       "create_cone_geometry",
////       "create_plane_geometry",
////       "create_circle_geometry",
////       "create_cylinder_geometry",
////       "create_torus_geometry",
////       "create_tetrahedron_geometry",
////       "create_icosahedron_geometry",
////       "create_text_geometry",
////       "create_buffer_geometry",
////       "create_buffer_attribute",
////       "set_geometry_attribute",
////       "mark_attribute_needs_update",
////       "dispose_geometry"
////     ]
////   },
////   {
////     header: "Materials",
////     functions: [
////       "create_basic_material",
////       "create_standard_material",
////       "create_phong_material",
////       "create_lambert_material",
////       "create_toon_material",
////       "create_line_material",
////       "create_sprite_material",
////       "create_points_material",
////       "dispose_material"
////     ]
////   },
////   {
////     header: "Lights",
////     functions: [
////       "create_ambient_light",
////       "create_directional_light",
////       "create_point_light",
////       "create_spot_light",
////       "create_hemisphere_light"
////     ]
////   },
////   {
////     header: "Textures",
////     functions: [
////       "load_texture",
////       "load_equirectangular_texture",
////       "load_cube_texture",
////       "clone_texture",
////       "set_texture_offset",
////       "set_texture_repeat",
////       "set_texture_wrap_mode",
////       "set_texture_filter_mode",
////       "dispose_texture"
////     ]
////   },
////   {
////     header: "Animation",
////     functions: [
////       "create_animation_mixer",
////       "clip_action",
////       "update_mixer",
////       "play_action",
////       "stop_action",
////       "set_action_loop",
////       "set_action_time_scale",
////       "set_action_weight",
////       "get_clip_name",
////       "get_clip_duration",
////     ]
////   },
////   {
////     header: "Audio",
////     functions: [
////       "create_audio_listener",
////       "create_audio",
////       "create_positional_audio",
////       "load_audio",
////       "set_audio_buffer",
////       "play_audio",
////       "pause_audio",
////       "stop_audio",
////       "set_audio_volume",
////       "set_audio_loop",
////       "set_audio_playback_rate",
////       "is_audio_playing",
////       "has_audio_buffer",
////       "get_audio_loop",
////       "get_audio_context_state",
////       "resume_audio_context"
////     ]
////   },
////   {
////     header: "Positional Audio",
////     functions: [
////       "set_positional_audio_buffer",
////       "set_positional_audio_volume",
////       "set_positional_audio_loop",
////       "set_positional_audio_playback_rate",
////       "play_positional_audio",
////       "pause_positional_audio",
////       "stop_positional_audio",
////       "is_positional_audio_playing",
////       "has_positional_audio_buffer",
////       "get_positional_audio_loop",
////       "set_ref_distance",
////       "set_rolloff_factor",
////       "set_max_distance"
////     ]
////   },
////   {
////     header: "Asset Loading",
////     functions: [
////       "load_stl",
////       "load_gltf",
////       "load_obj",
////       "load_fbx",
////       "load_font",
////     ]
////   },
////   {
////     header: "LOD & Instancing",
////     functions: [
////       "create_lod",
////       "add_lod_level",
////       "remove_lod_level",
////       "clear_lod_levels",
////       "create_instanced_mesh",
////       "update_instance_matrix",
////       "update_instanced_mesh_transforms",
////       "update_group_instanced_meshes"
////     ]
////   },
////   {
////     header: "Sprites & Particles",
////     functions: [
////       "create_sprite",
////       "create_points",
////       "create_line_segments",
////       "create_float32_array",
////       "set_buffer_attribute",
////       "get_geometry",
////       "get_attribute",
////       "set_buffer_xyz",
////       "set_buffer_x",
////       "set_attribute_needs_update",
////       "set_draw_range",
////       "center_geometry"
////     ]
////   },
////   {
////     header: "Math Utilities",
////     functions: [
////       "create_color",
////       "lerp_color",
////       "get_color_r",
////       "get_color_g",
////       "get_color_b"
////     ]
////   },
////   {
////     header: "CSS Renderers",
////     functions: [
////       "create_css2d_renderer",
////       "set_css2d_renderer_size",
////       "get_css2d_renderer_dom_element",
////       "render_css2d",
////       "create_css2d_object",
////       "update_css2d_object_html",
////       "create_css3d_object",
////       "update_css3d_object_html"
////     ]
////   },
////   {
////     header: "Debug Helpers",
////     functions: [
////       "create_axes_helper",
////       "create_grid_helper",
////       "create_box_helper"
////     ]
////   },
//// ]
////
//// const callback = () => {
////   const list = document.querySelector(".sidebar > ul:last-of-type")
////   const sortedLists = document.createDocumentFragment()
////   const sortedMembers = document.createDocumentFragment()
////
////   for (const section of docs) {
////     sortedLists.append((() => {
////       const node = document.createElement("h3")
////       node.append(section.header)
////       return node
////     })())
////     sortedMembers.append((() => {
////       const node = document.createElement("h2")
////       node.append(section.header)
////       return node
////     })())
////
////     const sortedList = document.createElement("ul")
////     sortedLists.append(sortedList)
////
////
////     for (const funcName of section.functions) {
////       const href = `#${funcName}`
////       const member = document.querySelector(
////         `.member:has(h2 > a[href="${href}"])`
////       )
////       const sidebar = list.querySelector(`li:has(a[href="${href}"])`)
////       sortedList.append(sidebar)
////       sortedMembers.append(member)
////     }
////   }
////
////   document.querySelector(".sidebar").insertBefore(sortedLists, list)
////   document
////     .querySelector(".module-members:has(#module-values)")
////     .insertBefore(
////       sortedMembers,
////       document.querySelector("#module-values").nextSibling
////     )
//// }
////
//// document.readyState !== "loading"
////   ? callback()
////   : document.addEventListener(
////     "DOMContentLoaded",
////     callback,
////     { once: true }
////   )
//// </script>

import gleam/javascript/array
import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option}
import quaternion.{type Quaternion}
import vec/vec2
import vec/vec3.{type Vec3}

// ============================================================================
// CORE TYPES
// ============================================================================

/// Opaque type wrapping Three.js [Object3D](https://threejs.org/docs/#api/en/core/Object3D).
///
/// Object3D is the base class for most objects in Three.js. It provides properties
/// and methods for manipulating objects in 3D space including position, rotation,
/// scale, and parent/child relationships.
///
/// Common subclasses include Mesh, Group, Camera, Light, and more.
pub type Object3D

/// Opaque type wrapping Three.js [Scene](https://threejs.org/docs/#api/en/scenes/Scene).
///
/// Scenes allow you to set up what is to be rendered and where. This is where you
/// place objects, lights and cameras. The scene forms the root of the scene graph.
pub type Scene

/// Opaque type wrapping Three.js [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer).
///
/// The WebGL renderer displays your scenes using WebGL. It handles all the low-level
/// graphics operations and provides hardware-accelerated rendering.
pub type Renderer

/// Opaque type wrapping Three.js [Camera](https://threejs.org/docs/#api/en/cameras/Camera).
///
/// Abstract base class for cameras. This class should not be instantiated directly.
/// Use `create_perspective_camera` or `create_orthographic_camera` instead.
pub type Camera

/// Opaque type wrapping Three.js [BufferGeometry](https://threejs.org/docs/#api/en/core/BufferGeometry).
///
/// A representation of mesh, line, or point geometry using typed arrays.
/// BufferGeometry is more efficient than the deprecated Geometry class as it stores
/// all data in buffers that can be sent directly to the GPU.
pub type Geometry

/// Opaque type wrapping Three.js [Material](https://threejs.org/docs/#api/en/materials/Material).
///
/// Abstract base class for materials. Materials describe the appearance of objects
/// and how they interact with light. Use specific material constructors like
/// `create_basic_material` or `create_standard_material`.
pub type Material

/// Opaque type wrapping Three.js [Texture](https://threejs.org/docs/#api/en/textures/Texture).
///
/// Creates a texture to apply to a surface or as a reflection/refraction map.
/// Textures are loaded asynchronously via `load_texture`.
pub type Texture

/// Opaque type wrapping Three.js [CubeTexture](https://threejs.org/docs/#api/en/textures/CubeTexture).
///
/// Creates a cube texture made up of six images for skyboxes and environment maps.
/// Load with `load_cube_texture` providing 6 image URLs in order: +X, -X, +Y, -Y, +Z, -Z.
pub type CubeTexture

/// Opaque type wrapping Three.js [Light](https://threejs.org/docs/#api/en/lights/Light).
///
/// Abstract base class for lights. Use specific light constructors like
/// `create_ambient_light`, `create_directional_light`, `create_point_light`, etc.
pub type Light

/// Shadow configuration for point and spot lights.
///
/// Contains basic shadow map settings that apply to all shadow-casting lights.
pub type ShadowConfig {
  ShadowConfig(resolution: Int, bias: Float, normal_bias: Float)
}

/// Shadow configuration for directional lights.
///
/// Extends basic shadow config with orthographic camera bounds for the shadow camera.
/// The bounds define the area that can cast/receive shadows.
pub type DirectionalShadowConfig {
  DirectionalShadowConfig(
    resolution: Int,
    bias: Float,
    normal_bias: Float,
    camera_left: Float,
    camera_right: Float,
    camera_top: Float,
    camera_bottom: Float,
    camera_near: Float,
    camera_far: Float,
  )
}

/// Opaque type wrapping Three.js [AnimationClip](https://threejs.org/docs/#api/en/animation/AnimationClip).
///
/// An AnimationClip is a reusable set of keyframe tracks which represent an animation.
/// Clips are typically loaded from GLTF/FBX models and played via AnimationAction.
pub type AnimationClip

/// Opaque type wrapping Three.js [AnimationMixer](https://threejs.org/docs/#api/en/animation/AnimationMixer).
///
/// The AnimationMixer is a player for animations on a particular object in the scene.
/// When multiple objects are animated independently, one mixer per object is required.
/// Call `update_mixer` with delta time each frame to advance animations.
pub type AnimationMixer

/// Opaque type wrapping Three.js [AnimationAction](https://threejs.org/docs/#api/en/animation/AnimationAction).
///
/// AnimationActions schedule the performance of animations stored in AnimationClips.
/// Actions can be played, paused, stopped, looped, crossfaded, and blended.
pub type AnimationAction

/// Opaque type wrapping Three.js [Audio](https://threejs.org/docs/#api/en/audio/Audio).
///
/// Creates a non-positional (global) audio object. This audio is not affected by
/// the listener's position - it plays at constant volume regardless of distance.
/// Use for background music, UI sounds, etc.
pub type Audio

/// Opaque type wrapping Three.js [AudioListener](https://threejs.org/docs/#api/en/audio/AudioListener).
///
/// Represents a virtual listener for all positional and non-positional audio.
/// Typically attached to the camera. A single AudioListener is required for
/// the Web Audio API to process audio in the scene.
pub type AudioListener

/// Opaque type wrapping Three.js [PositionalAudio](https://threejs.org/docs/#api/en/audio/PositionalAudio).
///
/// Creates a positional audio object that uses the Web Audio API's PannerNode.
/// Audio volume and panning are affected by the listener's position and orientation
/// relative to the audio source. Use for 3D sound effects attached to objects.
pub type PositionalAudio

/// Opaque type wrapping Three.js [LOD](https://threejs.org/docs/#api/en/objects/LOD).
///
/// Level of Detail - shows meshes with varying levels of detail based on distance
/// from the camera. Useful for optimizing rendering of complex objects by showing
/// simpler meshes when far away.
pub type LOD

/// Opaque type wrapping Three.js [InstancedMesh](https://threejs.org/docs/#api/en/objects/InstancedMesh).
///
/// A special version of Mesh with instanced rendering support. Use InstancedMesh
/// to render a large number of objects with the same geometry and material but
/// different world transformations efficiently in a single draw call.
pub type InstancedMesh

/// Opaque type wrapping Three.js [Sprite](https://threejs.org/docs/#api/en/objects/Sprite).
///
/// A sprite is a plane that always faces towards the camera. Commonly used for
/// billboards, particles, and UI elements in 3D space.
pub type Sprite

/// Opaque type wrapping Three.js [Points](https://threejs.org/docs/#api/en/objects/Points).
///
/// A class for displaying particles. Points are rendered as a cloud of points
/// using WebGL's POINTS primitive. Used for particle systems, point clouds, etc.
pub type Points

/// Opaque type for the HTML [Canvas](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/canvas) element.
///
/// The canvas element used by the WebGL renderer for drawing.
pub type Canvas

/// Opaque type for loaded GLTF data from [GLTFLoader](https://threejs.org/docs/#examples/en/loaders/GLTFLoader).
///
/// Contains the loaded scene, animations, cameras, and other assets from a GLTF/GLB file.
/// GLTF is the recommended format for 3D models in Three.js.
pub type GLTFData

/// Opaque type for loaded FBX data from [FBXLoader](https://threejs.org/docs/#examples/en/loaders/FBXLoader).
///
/// Contains the loaded scene and animations from an FBX file. FBX is commonly
/// exported from tools like Blender, Maya, and 3ds Max.
pub type FBXData

/// Opaque type wrapping [CSS2DRenderer](https://threejs.org/docs/#examples/en/renderers/CSS2DRenderer).
///
/// Renders DOM elements as 2D sprites that are positioned in 3D space but always
/// face the camera. Useful for labels, health bars, and UI elements.
pub type CSS2DRenderer

/// Opaque type wrapping [CSS2DObject](https://threejs.org/docs/#examples/en/renderers/CSS2DRenderer).
///
/// A DOM element that can be positioned in 3D space and rendered by CSS2DRenderer.
/// The element always faces the camera (billboard behavior).
pub type CSS2DObject

/// Opaque type wrapping [CSS3DObject](https://threejs.org/docs/#examples/en/renderers/CSS3DRenderer).
///
/// A DOM element that exists in full 3D space. Unlike CSS2DObject, CSS3DObject
/// can be rotated and transformed in 3D.
pub type CSS3DObject

/// Opaque type wrapping [CSS3DRenderer](https://threejs.org/docs/#examples/en/renderers/CSS3DRenderer).
///
/// Renders DOM elements as full 3D objects that can be rotated and transformed.
/// Unlike CSS2DRenderer, CSS3D elements exist in true 3D space with depth.
pub type CSS3DRenderer

/// Opaque type for fonts loaded via [FontLoader](https://threejs.org/docs/#examples/en/loaders/FontLoader).
///
/// Fonts are required for creating 3D text geometry with `create_text_geometry`.
/// Fonts must be in Three.js JSON font format (converted from TTF/OTF).
pub type Font

/// Opaque type wrapping the Web Audio API [AudioBuffer](https://developer.mozilla.org/en-US/docs/Web/API/AudioBuffer).
///
/// Represents audio data loaded into memory. Load audio files with `load_audio`
/// and assign to Audio or PositionalAudio objects with `set_audio_buffer`.
pub type AudioBuffer

/// Opaque type wrapping Three.js [BufferAttribute](https://threejs.org/docs/#api/en/core/BufferAttribute).
///
/// Stores data for an attribute (such as vertex positions, normals, colors, UVs)
/// in a typed array buffer. Used for custom geometry and particle systems.
pub type BufferAttribute

/// Opaque type wrapping Three.js [Color](https://threejs.org/docs/#api/en/math/Color).
///
/// Represents a color. Can be created from hex values with `create_color`.
/// Supports color operations like `lerp_color` for smooth transitions.
pub type Color

/// Opaque type wrapping JavaScript [Float32Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Float32Array).
///
/// A typed array of 32-bit floating point numbers. Used for buffer geometry
/// attributes like positions, normals, colors, and UVs.
pub type Float32Array

/// Opaque type for an HTML [DOM Element](https://developer.mozilla.org/en-US/docs/Web/API/Element).
///
/// Represents a generic DOM element returned by CSS renderers.
pub type DomElement

/// Opaque type for WebGL renderer information from [WebGLRenderer.info](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.info).
///
/// Contains memory and render statistics useful for debugging and profiling.
pub type RendererInfo

// ============================================================================
// ENUM TYPES
// ============================================================================

/// Which sides of faces to render.
///
/// See: [Material Constants](https://threejs.org/docs/#api/en/constants/Materials)
pub type MaterialSide {
  /// Render front faces only (default).
  FrontSide
  /// Render back faces only.
  BackSide
  /// Render both front and back faces.
  DoubleSide
}

@external(javascript, "./savoiardi.ffi.mjs", "getFrontSide")
fn get_front_side_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getBackSide")
fn get_back_side_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getDoubleSide")
fn get_double_side_constant() -> Int

/// Convert a MaterialSide to its Three.js constant value (internal use only).
fn material_side_to_int(side: MaterialSide) -> Int {
  case side {
    FrontSide -> get_front_side_constant()
    BackSide -> get_back_side_constant()
    DoubleSide -> get_double_side_constant()
  }
}

/// Texture filtering mode.
///
/// Controls how textures are sampled when scaled up or down.
///
/// See: [Texture Constants](https://threejs.org/docs/#api/en/constants/Textures)
pub type FilterMode {
  /// No interpolation, uses nearest pixel. Best for pixel art.
  NearestFilter
  /// Bilinear interpolation for smooth texture sampling. Default.
  LinearFilter
}

/// Texture wrapping mode.
///
/// Controls how textures behave when UV coordinates exceed the 0-1 range.
///
/// See: [Texture Constants](https://threejs.org/docs/#api/en/constants/Textures)
pub type WrapMode {
  /// Texture repeats infinitely. Requires power-of-two dimensions.
  RepeatWrapping
  /// Edge pixels stretch infinitely. Works with any dimensions.
  ClampToEdgeWrapping
  /// Texture repeats with alternating mirrored copies.
  MirroredRepeatWrapping
}

/// Material blending mode.
///
/// Controls how materials blend with the background.
///
/// See: [Material Constants](https://threejs.org/docs/#api/en/constants/Materials)
pub type BlendingMode {
  /// Adds source and destination colors. Creates glow effects.
  AdditiveBlending
  /// Standard alpha blending. Source replaces destination based on alpha.
  NormalBlending
}

/// Animation loop mode.
///
/// Controls how animations repeat.
///
/// See: [Animation Constants](https://threejs.org/docs/#api/en/constants/Animation)
pub type LoopMode {
  /// Play once and stop.
  LoopOnce
  /// Loop continuously from start.
  LoopRepeat
  /// Play forward, then backward, then forward, etc.
  LoopPingPong
}

// ============================================================================
// CONFIGURATION TYPES
// ============================================================================

/// Options for creating a [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer).
///
/// ## Fields
///
/// - `antialias` - Whether to perform antialiasing. Smooths jagged edges but has
///   a performance cost. Default: `True`
/// - `alpha` - Whether the canvas contains an alpha (transparency) buffer.
///   Set to `True` if you need the canvas background to be transparent. Default: `False`
/// - `dimensions` - Fixed canvas size, or `None` for fullscreen mode
///
/// ## Example
///
/// ```gleam
/// // Fixed size renderer
/// let options = RendererOptions(
///   antialias: True,
///   alpha: False,
///   dimensions: option.Some(Dimensions(800.0, 600.0)),
/// )
/// let renderer = create_renderer(options)
/// ```
pub type RendererOptions {
  RendererOptions(
    /// Enable antialiasing (smooths jagged edges, costs performance)
    antialias: Bool,
    /// Enable alpha channel (transparent canvas background)
    alpha: Bool,
    /// Canvas dimensions (None for fullscreen mode)
    dimensions: Option(vec2.Vec2(Float)),
  )
}

/// Returns default renderer options: fullscreen, antialiased, opaque background.
///
/// Equivalent to `RendererOptions(antialias: True, alpha: False, dimensions: option.None)`.
///
/// See [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer)
/// for all available options in Three.js.
pub fn default_renderer_options() -> RendererOptions {
  RendererOptions(antialias: True, alpha: False, dimensions: option.None)
}

// ============================================================================
// SCENE
// ============================================================================

/// Creates a new Three.js [Scene](https://threejs.org/docs/#api/en/scenes/Scene).
///
/// The scene is the container for all objects, lights, and cameras. It forms
/// the root of the scene graph that gets rendered.
///
/// ## Example
///
/// ```gleam
/// let scene = create_scene()
///   |> set_scene_background_color(0x000000)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createScene")
pub fn create_scene() -> Scene

/// Sets the scene background to a solid color.
///
/// Wraps [Scene.background](https://threejs.org/docs/#api/en/scenes/Scene.background)
/// with a Three.js Color.
///
/// ## Parameters
///
/// - `scene` - The scene to modify
/// - `color` - Hex color value (e.g., `0x1a1a2e` for dark blue)
///
/// ## Example
///
/// ```gleam
/// let scene = create_scene()
///   |> set_scene_background_color(0x87ceeb)  // Sky blue
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "setSceneBackgroundColor")
pub fn set_scene_background_color(scene: Scene, color: Int) -> Scene

/// Sets the scene background to a texture (e.g., an image).
///
/// Wraps [Scene.background](https://threejs.org/docs/#api/en/scenes/Scene.background).
/// The texture will be stretched to fill the entire background.
///
/// ## Parameters
///
/// - `scene` - The scene to modify
/// - `texture` - A texture loaded via `load_texture` or `load_equirectangular_texture`
///
/// ## Example
///
/// ```gleam
/// load_texture("/images/background.jpg")
/// |> promise.map(fn(result) {
///   case result {
///     Ok(texture) -> set_scene_background_texture(scene, texture)
///     Error(Nil) -> scene
///   }
/// })
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "setSceneBackgroundTexture")
pub fn set_scene_background_texture(scene: Scene, texture: Texture) -> Scene

/// Sets the scene background to a cube texture (skybox).
///
/// Wraps [Scene.background](https://threejs.org/docs/#api/en/scenes/Scene.background)
/// with a CubeTexture. Creates an immersive 360° environment.
///
/// ## Parameters
///
/// - `scene` - The scene to modify
/// - `cube_texture` - A cube texture loaded via `load_cube_texture`
///
/// ## Example
///
/// ```gleam
/// let urls = [
///   "/skybox/px.jpg", "/skybox/nx.jpg",  // +X, -X
///   "/skybox/py.jpg", "/skybox/ny.jpg",  // +Y, -Y
///   "/skybox/pz.jpg", "/skybox/nz.jpg",  // +Z, -Z
/// ]
/// load_cube_texture(urls)
/// |> promise.map(fn(result) {
///   case result {
///     Ok(cube) -> set_scene_background_cube_texture(scene, cube)
///     Error(Nil) -> scene
///   }
/// })
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "setSceneBackgroundCubeTexture")
pub fn set_scene_background_cube_texture(
  scene: Scene,
  cube_texture: CubeTexture,
) -> Scene

/// Adds an object to the scene.
///
/// Wraps [Object3D.add](https://threejs.org/docs/#api/en/core/Object3D.add).
/// The object becomes a child of the scene and will be rendered.
///
/// ## Parameters
///
/// - `scene` - The scene to add to
/// - `object` - Any Object3D (mesh, light, group, camera, etc.)
///
/// ## Example
///
/// ```gleam
/// let cube = create_mesh(geometry, material)
/// add_to_scene(scene: scene, object: cube)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "addToScene")
pub fn add_to_scene(scene scene: Scene, object object: Object3D) -> Nil

/// Removes an object from the scene.
///
/// Wraps [Object3D.remove](https://threejs.org/docs/#api/en/core/Object3D.remove).
/// The object is detached from the scene graph and will no longer be rendered.
///
/// **Note:** This does not dispose of the object's geometry or materials.
/// Call `dispose_object` if you want to free GPU memory.
///
/// ## Parameters
///
/// - `scene` - The scene to remove from
/// - `object` - The object to remove
@external(javascript, "./savoiardi.ffi.mjs", "removeFromScene")
pub fn remove_from_scene(scene scene: Scene, object object: Object3D) -> Nil

// ============================================================================
// RENDERER
// ============================================================================

/// Gets the current canvas dimensions from the renderer.
///
/// Returns a tuple of `#(width, height)` in pixels.
///
/// See [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer).
@external(javascript, "./savoiardi.ffi.mjs", "getCanvasDimensions")
pub fn get_canvas_dimensions(renderer: Renderer) -> vec2.Vec2(Float)

/// Creates a new [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer).
///
/// The WebGL renderer uses WebGL to render your scene. It automatically creates
/// a canvas element and appends it to the document body (in fullscreen mode).
///
/// ## Parameters
///
/// - `options` - Renderer configuration (see `RendererOptions`)
///
/// ## Example
///
/// ```gleam
/// // Fullscreen with antialiasing
/// let renderer = create_renderer(default_renderer_options())
///
/// // Fixed size, transparent background
/// let renderer = create_renderer(RendererOptions(
///   antialias: True,
///   alpha: True,
///   dimensions: option.Some(Dimensions(1280.0, 720.0)),
/// ))
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createRenderer")
pub fn create_renderer(options: RendererOptions) -> Renderer

/// Gets the canvas DOM element from the renderer.
///
/// Wraps [WebGLRenderer.domElement](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.domElement).
/// Useful for adding event listeners or appending to a specific container.
///
/// ## Example
///
/// ```gleam
/// let canvas = get_renderer_dom_element(renderer)
/// // Now you can use the canvas for input handling
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "getRendererDomElement")
pub fn get_renderer_dom_element(renderer: Renderer) -> Canvas

/// Sets the renderer output canvas size.
///
/// Wraps [WebGLRenderer.setSize](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.setSize).
/// Call this when the window resizes to update the rendering resolution.
///
/// ## Parameters
///
/// - `renderer` - The renderer to resize
/// - `width` - New width in pixels
/// - `height` - New height in pixels
///
/// ## Example
///
/// ```gleam
/// // Handle window resize
/// set_renderer_size(renderer, window_width, window_height)
/// set_camera_aspect(camera, int.to_float(window_width) /. int.to_float(window_height))
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "setRendererSize")
pub fn set_renderer_size(renderer: Renderer, width: Int, height: Int) -> Nil

/// Sets the device pixel ratio for the renderer.
///
/// Wraps [WebGLRenderer.setPixelRatio](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.setPixelRatio).
/// Higher values render at higher resolution for sharper images on HiDPI displays,
/// but cost more performance.
///
/// ## Parameters
///
/// - `renderer` - The renderer to configure
/// - `ratio` - Pixel ratio (typically `window.devicePixelRatio`, usually 1.0-3.0)
///
/// ## Example
///
/// ```gleam
/// // Match device pixel ratio for sharp rendering
/// set_renderer_pixel_ratio(renderer, 2.0)  // Retina display
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "setRendererPixelRatio")
pub fn set_renderer_pixel_ratio(renderer: Renderer, ratio: Float) -> Nil

/// Renders the scene using the given camera.
///
/// Wraps [WebGLRenderer.render](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.render).
/// This is the main render call - invoke it each frame in your render loop.
///
/// ## Parameters
///
/// - `renderer` - The WebGL renderer
/// - `scene` - The scene containing objects to render
/// - `camera` - The camera defining the view
///
/// ## Example
///
/// ```gleam
/// // Basic render loop
/// fn render_loop() {
///   render(renderer, scene, camera)
///   request_animation_frame(render_loop)
/// }
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "render")
pub fn render(renderer: Renderer, scene: Scene, camera: Camera) -> Nil

/// Clears the renderer's color, depth, and stencil buffers.
///
/// Wraps [WebGLRenderer.clear](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.clear).
/// Useful when manually compositing multiple render passes.
@external(javascript, "./savoiardi.ffi.mjs", "clearRenderer")
pub fn clear_renderer(renderer: Renderer) -> Nil

/// Sets the viewport for rendering.
///
/// Wraps [WebGLRenderer.setViewport](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.setViewport).
/// Defines the rectangular region of the canvas to render to. Useful for
/// split-screen, picture-in-picture, or multiple views.
///
/// ## Parameters
///
/// - `renderer` - The renderer
/// - `x` - Left edge in pixels
/// - `y` - Bottom edge in pixels (WebGL uses bottom-left origin)
/// - `width` - Viewport width in pixels
/// - `height` - Viewport height in pixels
///
/// ## Example
///
/// ```gleam
/// // Render to left half of screen
/// set_viewport(renderer, 0, 0, width / 2, height)
/// render(renderer, scene, left_camera)
///
/// // Render to right half
/// set_viewport(renderer, width / 2, 0, width / 2, height)
/// render(renderer, scene, right_camera)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "setViewport")
pub fn set_viewport(
  renderer: Renderer,
  x: Int,
  y: Int,
  width: Int,
  height: Int,
) -> Nil

/// Sets the scissor region for rendering.
///
/// Wraps [WebGLRenderer.setScissor](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.setScissor).
/// When scissor test is enabled, only pixels within this region are affected.
/// Use with `set_scissor_test(renderer, True)`.
///
/// ## Parameters
///
/// - `renderer` - The renderer
/// - `x` - Left edge in pixels
/// - `y` - Bottom edge in pixels
/// - `width` - Scissor region width
/// - `height` - Scissor region height
@external(javascript, "./savoiardi.ffi.mjs", "setScissor")
pub fn set_scissor(
  renderer: Renderer,
  x: Int,
  y: Int,
  width: Int,
  height: Int,
) -> Nil

/// Enables or disables the scissor test.
///
/// Wraps [WebGLRenderer.setScissorTest](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.setScissorTest).
/// When enabled, only the scissor region defined by `set_scissor` is rendered.
///
/// ## Parameters
///
/// - `renderer` - The renderer
/// - `enabled` - `True` to enable scissor test, `False` to disable
@external(javascript, "./savoiardi.ffi.mjs", "setScissorTest")
pub fn set_scissor_test(renderer: Renderer, enabled: Bool) -> Nil

/// Gets render statistics from the last frame.
///
/// Accesses [WebGLRenderer.info](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.info).
/// Useful for performance monitoring and debugging.
///
/// ## Returns
///
/// A tuple of `#(draw_calls, triangles)`:
/// - `draw_calls` - Number of WebGL draw calls
/// - `triangles` - Number of triangles rendered
///
/// ## Example
///
/// ```gleam
/// let #(calls, tris) = get_render_stats(renderer)
/// io.println("Draw calls: " <> int.to_string(calls))
/// io.println("Triangles: " <> int.to_string(tris))
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "getRenderStats")
pub fn get_render_stats(renderer: Renderer) -> #(Int, Int)

// ============================================================================
// CAMERA
// ============================================================================

/// Creates a [PerspectiveCamera](https://threejs.org/docs/#api/en/cameras/PerspectiveCamera).
///
/// The most common projection mode for 3D rendering. Mimics how the human eye sees,
/// with objects getting smaller as they move further away (perspective foreshortening).
///
/// ## Parameters
///
/// - `fov` - Field of view in degrees (vertical). Typical values: 45-75. Higher = wider view
/// - `aspect` - Aspect ratio (width / height). Should match canvas aspect ratio
/// - `near` - Near clipping plane. Objects closer than this won't render. Typical: 0.1
/// - `far` - Far clipping plane. Objects further than this won't render. Typical: 1000-10000
///
/// ## Important Notes
///
/// - Keep `near` as large as possible to avoid z-fighting (depth buffer precision issues)
/// - The ratio `far/near` should be as small as possible for best depth precision
/// - After changing `fov` or `aspect`, call `update_camera_projection_matrix`
///
/// ## Example
///
/// ```gleam
/// // Standard 16:9 camera
/// let camera = create_perspective_camera(75.0, 16.0 /. 9.0, 0.1, 1000.0)
/// set_object_position(camera, vec3.new(0.0, 5.0, 10.0))
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createPerspectiveCamera")
pub fn create_perspective_camera(
  fov: Float,
  aspect: Float,
  near: Float,
  far: Float,
) -> Camera

/// Creates an [OrthographicCamera](https://threejs.org/docs/#api/en/cameras/OrthographicCamera).
///
/// In orthographic projection, object size stays constant regardless of distance.
/// Useful for 2D games, isometric views, UI elements, and CAD-style applications.
///
/// ## Parameters
///
/// - `left` - Left plane of the camera frustum
/// - `right` - Right plane of the camera frustum
/// - `top` - Top plane of the camera frustum
/// - `bottom` - Bottom plane of the camera frustum
/// - `near` - Near clipping plane
/// - `far` - Far clipping plane
///
/// ## Example
///
/// ```gleam
/// // Orthographic camera for 2D game (origin at center)
/// let half_width = 10.0
/// let half_height = 10.0 /. aspect
/// let camera = create_orthographic_camera(
///   -half_width, half_width,
///   half_height, -half_height,
///   0.1, 1000.0
/// )
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createOrthographicCamera")
pub fn create_orthographic_camera(
  left: Float,
  right: Float,
  top: Float,
  bottom: Float,
  near: Float,
  far: Float,
) -> Camera

/// Sets the aspect ratio of a perspective camera.
///
/// Wraps [PerspectiveCamera.aspect](https://threejs.org/docs/#api/en/cameras/PerspectiveCamera.aspect).
/// Call this when the canvas/window is resized, followed by `update_camera_projection_matrix`.
///
/// ## Parameters
///
/// - `camera` - The perspective camera to update
/// - `aspect` - New aspect ratio (width / height)
///
/// ## Example
///
/// ```gleam
/// // On window resize
/// let aspect = int.to_float(width) /. int.to_float(height)
/// set_camera_aspect(camera, aspect)
/// update_camera_projection_matrix(camera)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "setCameraAspect")
pub fn set_camera_aspect(camera: Camera, aspect: Float) -> Nil

// ============================================================================
// OBJECT3D
// ============================================================================

/// Clones an [Object3D](https://threejs.org/docs/#api/en/core/Object3D.clone) and its descendants.
///
/// Creates a deep copy of the object including all children. Geometry and materials
/// are shared by reference (not cloned) for efficiency.
///
/// ## Returns
///
/// A new Object3D that is a copy of the original.
@external(javascript, "./savoiardi.ffi.mjs", "cloneObject3D")
pub fn clone_object(object: Object3D) -> Object3D

/// Creates an empty [Group](https://threejs.org/docs/#api/en/objects/Group) (Object3D container).
///
/// Groups are useful for organizing objects hierarchically. Transforming a group
/// affects all its children. Groups have no visual representation themselves.
///
/// ## Example
///
/// ```gleam
/// let car = create_group()
/// add_child(parent: car, child: body_mesh)
/// add_child(parent: car, child: wheel1)
/// add_child(parent: car, child: wheel2)
/// // Now moving the car moves all parts together
/// set_object_position(car, vec3.new(10.0, 0.0, 0.0))
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createGroup")
pub fn create_group() -> Object3D

/// Creates a [Mesh](https://threejs.org/docs/#api/en/objects/Mesh) from geometry and material.
///
/// A mesh is a 3D object composed of triangular polygons. It combines geometry
/// (shape) with material (appearance) to create a renderable object.
///
/// ## Parameters
///
/// - `geometry` - The shape of the mesh (vertices, faces, UVs, normals)
/// - `material` - The surface appearance (color, texture, shading)
///
/// ## Example
///
/// ```gleam
/// let geometry = create_box_geometry(1.0, 1.0, 1.0)
/// let material = create_standard_material(0xff0000, 0.5, 0.5, ...)
/// let cube = create_mesh(geometry, material)
/// add_to_scene(scene: scene, object: cube)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createMesh")
pub fn create_mesh(geometry: Geometry, material: Material) -> Object3D

/// Adds a child to an [Object3D](https://threejs.org/docs/#api/en/core/Object3D.add).
///
/// The child's transform becomes relative to the parent. Moving the parent
/// moves all children with it.
///
/// ## Parameters
///
/// - `parent` - The parent object
/// - `child` - The object to add as a child
@external(javascript, "./savoiardi.ffi.mjs", "addChild")
pub fn add_child(parent parent: Object3D, child child: Object3D) -> Nil

/// Applies position, rotation, and scale to an object in one call.
///
/// More efficient than setting each property individually. Sets
/// [Object3D.position](https://threejs.org/docs/#api/en/core/Object3D.position),
/// [Object3D.rotation](https://threejs.org/docs/#api/en/core/Object3D.rotation), and
/// [Object3D.scale](https://threejs.org/docs/#api/en/core/Object3D.scale).
///
/// ## Parameters
///
/// - `object` - The object to transform
/// - `position` - Position in world units
/// - `rotation` - Euler rotation in radians (x, y, z)
/// - `scale` - Scale factors (1.0 = original size)
@external(javascript, "./savoiardi.ffi.mjs", "applyTransform")
pub fn apply_transform(
  object object: Object3D,
  position position: vec3.Vec3(Float),
  rotation rotation: vec3.Vec3(Float),
  scale scale: vec3.Vec3(Float),
) -> Nil

/// Updates the object's world matrix.
///
/// Wraps [Object3D.updateMatrixWorld](https://threejs.org/docs/#api/en/core/Object3D.updateMatrixWorld).
/// Computes the world matrix from local position/rotation/scale and parent transforms.
/// Usually called automatically during rendering, but needed for manual matrix access.
@external(javascript, "./savoiardi.ffi.mjs", "updateMatrixWorld")
pub fn update_matrix_world(object: Object3D) -> Nil

/// Updates the object's world matrix with optional force flag.
///
/// Wraps [Object3D.updateMatrixWorld](https://threejs.org/docs/#api/en/core/Object3D.updateMatrixWorld).
///
/// ## Parameters
///
/// - `object` - The object to update
/// - `force` - If `True`, forces update of all descendants even if not dirty
@external(javascript, "./savoiardi.ffi.mjs", "updateMatrixWorldForce")
pub fn update_matrix_world_force(object: Object3D, force: Bool) -> Nil

/// Disposes of an Object3D and its resources.
///
/// Frees GPU memory by disposing geometry and materials. Call this when
/// removing objects permanently to prevent memory leaks.
///
/// **Important:** After disposal, the object should not be used.
///
/// See [How to dispose of objects](https://threejs.org/docs/#manual/en/introduction/How-to-dispose-of-objects).
@external(javascript, "./savoiardi.ffi.mjs", "disposeObject3D")
pub fn dispose_object(object: Object3D) -> Nil

/// Extracts all geometries and materials from an Object3D hierarchy.
///
/// Traverses the object and its children, collecting all unique geometries
/// and materials found on meshes.
///
/// ## Returns
///
/// A tuple of `#(geometries, materials)` as JavaScript arrays.
@external(javascript, "./savoiardi.ffi.mjs", "extractMeshMaterialPairs")
pub fn extract_mesh_material_pairs(
  object: Object3D,
) -> #(array.Array(Geometry), array.Array(Material))

// ============================================================================
// LOD (Level of Detail)
// ============================================================================

/// Creates a [LOD](https://threejs.org/docs/#api/en/objects/LOD) (Level of Detail) object.
///
/// LOD shows different meshes based on distance from the camera. Use simpler
/// meshes for distant objects to improve performance.
///
/// ## Example
///
/// ```gleam
/// let lod = create_lod()
/// add_lod_level(lod: lod, object: high_detail_mesh, distance: 0.0)
/// add_lod_level(lod: lod, object: medium_detail_mesh, distance: 50.0)
/// add_lod_level(lod: lod, object: low_detail_mesh, distance: 100.0)
/// add_to_scene(scene: scene, object: lod)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createLOD")
pub fn create_lod() -> LOD

/// Adds a level to a [LOD](https://threejs.org/docs/#api/en/objects/LOD.addLevel) object.
///
/// Objects are shown when the camera is at or beyond the specified distance
/// (until the next level's distance is reached).
///
/// ## Parameters
///
/// - `lod` - The LOD object
/// - `object` - The mesh to show at this level
/// - `distance` - Distance threshold for this level (0.0 = closest/most detailed)
@external(javascript, "./savoiardi.ffi.mjs", "addLODLevel")
pub fn add_lod_level(
  lod lod: LOD,
  object object: Object3D,
  distance distance: Float,
) -> Nil

/// Removes a level from a LOD object by distance.
///
/// ## Parameters
///
/// - `lod` - The LOD object
/// - `distance` - The distance of the level to remove
@external(javascript, "./savoiardi.ffi.mjs", "removeLODLevel")
pub fn remove_lod_level(lod: LOD, distance: Float) -> Nil

// ============================================================================
// INSTANCED MESH
// ============================================================================

/// Creates an [InstancedMesh](https://threejs.org/docs/#api/en/objects/InstancedMesh).
///
/// Renders many copies of the same geometry/material with different transforms
/// in a single draw call. Extremely efficient for rendering large numbers of
/// similar objects (trees, particles, crowd, etc.).
///
/// ## Parameters
///
/// - `geometry` - Shared geometry for all instances
/// - `material` - Shared material for all instances
/// - `count` - Maximum number of instances
///
/// ## Example
///
/// ```gleam
/// // Render 1000 trees efficiently
/// let tree_geometry = create_cone_geometry(1.0, 3.0, 8)
/// let tree_material = create_basic_material(0x228b22, False, 1.0, option.None)
/// let trees = create_instanced_mesh(tree_geometry, tree_material, 1000)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createInstancedMesh")
pub fn create_instanced_mesh(
  geometry: Geometry,
  material: Material,
  count: Int,
) -> InstancedMesh

/// Marks the instance matrix buffer for GPU upload.
///
/// Wraps [InstancedMesh.instanceMatrix.needsUpdate](https://threejs.org/docs/#api/en/objects/InstancedMesh).
/// Call this after modifying instance matrices with `set_instance_matrix`.
@external(javascript, "./savoiardi.ffi.mjs", "updateInstanceMatrix")
pub fn update_instance_matrix(mesh: InstancedMesh) -> Nil

// ============================================================================
// GEOMETRIES
// ============================================================================

/// Creates a [BoxGeometry](https://threejs.org/docs/#api/en/geometries/BoxGeometry) (rectangular cuboid).
///
/// The geometry is centered at the origin. The box has 6 faces with correct
/// normals and UVs for texturing.
///
/// ## Parameters
///
/// - `width` - Width (X axis)
/// - `height` - Height (Y axis)
/// - `depth` - Depth (Z axis)
///
/// ## Example
///
/// ```gleam
/// let cube = create_box_geometry(1.0, 1.0, 1.0)
/// let mesh = create_mesh(cube, material)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createBoxGeometry")
pub fn create_box_geometry(
  width: Float,
  height: Float,
  depth: Float,
) -> Geometry

/// Creates a [SphereGeometry](https://threejs.org/docs/#api/en/geometries/SphereGeometry).
///
/// The sphere is centered at the origin. Higher segment counts produce smoother spheres
/// but use more triangles.
///
/// ## Parameters
///
/// - `radius` - Sphere radius
/// - `width_segments` - Horizontal segments (longitude). Minimum 3, typical 32
/// - `height_segments` - Vertical segments (latitude). Minimum 2, typical 16
///
/// ## Example
///
/// ```gleam
/// // Smooth sphere
/// let sphere = create_sphere_geometry(1.0, 32, 16)
///
/// // Low-poly sphere
/// let low_poly = create_sphere_geometry(1.0, 8, 6)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createSphereGeometry")
pub fn create_sphere_geometry(
  radius: Float,
  width_segments: Int,
  height_segments: Int,
) -> Geometry

/// Creates a [ConeGeometry](https://threejs.org/docs/#api/en/geometries/ConeGeometry).
///
/// The cone points up along the Y axis with its base centered at the origin.
///
/// ## Parameters
///
/// - `radius` - Base radius
/// - `height` - Cone height
/// - `segments` - Number of radial segments. Higher = smoother circular base
@external(javascript, "./savoiardi.ffi.mjs", "createConeGeometry")
pub fn create_cone_geometry(
  radius: Float,
  height: Float,
  segments: Int,
) -> Geometry

/// Creates a [PlaneGeometry](https://threejs.org/docs/#api/en/geometries/PlaneGeometry).
///
/// A flat rectangular surface in the XY plane, facing the +Z direction.
/// Commonly used for floors, walls, billboards, and UI elements.
///
/// ## Parameters
///
/// - `width` - Width (X axis)
/// - `height` - Height (Y axis)
/// - `width_segments` - Subdivisions along width (1 = single quad)
/// - `height_segments` - Subdivisions along height (1 = single quad)
///
/// ## Example
///
/// ```gleam
/// // Simple floor (rotate to lie flat)
/// let floor = create_plane_geometry(100.0, 100.0, 1, 1)
/// set_object_rotation(floor_mesh, vec3.new(-3.14159 /. 2.0, 0.0, 0.0))
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createPlaneGeometry")
pub fn create_plane_geometry(
  width: Float,
  height: Float,
  width_segments: Int,
  height_segments: Int,
) -> Geometry

/// Creates a [CircleGeometry](https://threejs.org/docs/#api/en/geometries/CircleGeometry).
///
/// A flat circular disc in the XY plane, facing the +Z direction.
///
/// ## Parameters
///
/// - `radius` - Circle radius
/// - `segments` - Number of segments. Higher = smoother circle (minimum 3)
@external(javascript, "./savoiardi.ffi.mjs", "createCircleGeometry")
pub fn create_circle_geometry(radius: Float, segments: Int) -> Geometry

/// Creates a [CylinderGeometry](https://threejs.org/docs/#api/en/geometries/CylinderGeometry).
///
/// A cylinder along the Y axis, centered at the origin. Can also create cones
/// by setting one radius to 0.
///
/// ## Parameters
///
/// - `radius_top` - Top cap radius (0 for a cone)
/// - `radius_bottom` - Bottom cap radius
/// - `height` - Cylinder height
/// - `radial_segments` - Number of faces around the circumference
///
/// ## Example
///
/// ```gleam
/// // Regular cylinder
/// let cylinder = create_cylinder_geometry(1.0, 1.0, 2.0, 32)
///
/// // Tapered cylinder (cone-like)
/// let tapered = create_cylinder_geometry(0.5, 1.0, 2.0, 32)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createCylinderGeometry")
pub fn create_cylinder_geometry(
  radius_top: Float,
  radius_bottom: Float,
  height: Float,
  radial_segments: Int,
) -> Geometry

/// Creates a [TorusGeometry](https://threejs.org/docs/#api/en/geometries/TorusGeometry) (donut shape).
///
/// A torus centered at the origin, lying in the XY plane.
///
/// ## Parameters
///
/// - `radius` - Distance from center to the middle of the tube
/// - `tube` - Radius of the tube (thickness)
/// - `radial_segments` - Segments around the tube cross-section
/// - `tubular_segments` - Segments around the torus circumference
@external(javascript, "./savoiardi.ffi.mjs", "createTorusGeometry")
pub fn create_torus_geometry(
  radius: Float,
  tube: Float,
  radial_segments: Int,
  tubular_segments: Int,
) -> Geometry

/// Creates a [TetrahedronGeometry](https://threejs.org/docs/#api/en/geometries/TetrahedronGeometry) (4-faced polyhedron).
///
/// A tetrahedron (triangular pyramid) centered at the origin.
///
/// ## Parameters
///
/// - `radius` - Radius of the circumscribed sphere
/// - `detail` - Subdivision level (0 = base shape, higher = more triangles)
@external(javascript, "./savoiardi.ffi.mjs", "createTetrahedronGeometry")
pub fn create_tetrahedron_geometry(radius: Float, detail: Int) -> Geometry

/// Creates an [IcosahedronGeometry](https://threejs.org/docs/#api/en/geometries/IcosahedronGeometry) (20-faced polyhedron).
///
/// An icosahedron centered at the origin. With detail > 0, becomes a good
/// approximation of a sphere with evenly distributed vertices.
///
/// ## Parameters
///
/// - `radius` - Radius of the circumscribed sphere
/// - `detail` - Subdivision level (0 = 20 faces, 1 = 80 faces, etc.)
@external(javascript, "./savoiardi.ffi.mjs", "createIcosahedronGeometry")
pub fn create_icosahedron_geometry(radius: Float, detail: Int) -> Geometry

/// Creates a [TextGeometry](https://threejs.org/docs/#examples/en/geometries/TextGeometry) for 3D text.
///
/// Generates extruded 3D text from a string. Requires a font loaded via `load_font`.
///
/// ## Parameters
///
/// - `text` - The text string to render
/// - `font` - A Font loaded via `load_font`
/// - `size` - Font size
/// - `depth` - Extrusion depth (thickness)
/// - `curve_segments` - Curve smoothness for rounded letters
/// - `bevel_enabled` - Whether to add beveled edges
/// - `bevel_thickness` - Bevel depth
/// - `bevel_size` - Bevel extent from text outline
/// - `bevel_offset` - Bevel start offset
/// - `bevel_segments` - Bevel smoothness
///
/// ## Example
///
/// ```gleam
/// load_font("/fonts/helvetiker.json")
/// |> promise.map(fn(result) {
///   case result {
///     Ok(font) -> {
///       let text_geo = create_text_geometry(
///         "Hello", font, 1.0, 0.2, 12,
///         True, 0.03, 0.02, 0.0, 3
///       )
///       create_mesh(text_geo, material)
///     }
///     Error(Nil) -> panic
///   }
/// })
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createTextGeometry")
pub fn create_text_geometry(
  text: String,
  font: Font,
  size: Float,
  depth: Float,
  curve_segments: Int,
  bevel_enabled: Bool,
  bevel_thickness: Float,
  bevel_size: Float,
  bevel_offset: Float,
  bevel_segments: Int,
) -> Geometry

// ============================================================================
// MATERIALS
// ============================================================================

/// Creates a [MeshBasicMaterial](https://threejs.org/docs/#api/en/materials/MeshBasicMaterial).
///
/// A simple material that is not affected by lights. Displays a flat color
/// or texture. Useful for unlit objects, wireframes, and debugging.
///
/// ## Parameters
///
/// - `color` - Base color as hex (e.g., `0xff0000` for red)
/// - `transparent` - Enable transparency (required for opacity < 1.0)
/// - `opacity` - Opacity from 0.0 (invisible) to 1.0 (opaque)
/// - `map` - Optional color texture
/// - `side` - Which sides of faces to render (FrontSide, BackSide, or DoubleSide)
/// - `alpha_test` - Pixels with alpha below this value won't be rendered (0.0-1.0)
/// - `depth_write` - Whether to write to depth buffer (set False for transparent objects)
///
/// ## Example
///
/// ```gleam
/// // Solid red material
/// let red = create_basic_material(
///   0xff0000, False, 1.0, option.None,
///   FrontSide, 0.0, True,
/// )
///
/// // Transparent sprite with alpha cutoff
/// let sprite = create_basic_material(
///   0xffffff, True, 1.0, option.Some(texture),
///   DoubleSide, 0.1, False,
/// )
/// ```
pub fn create_basic_material(
  color: Int,
  transparent: Bool,
  opacity: Float,
  map: Option(Texture),
  side: MaterialSide,
  alpha_test: Float,
  depth_write: Bool,
) -> Material {
  create_basic_material_ffi(
    color,
    transparent,
    opacity,
    map,
    material_side_to_int(side),
    alpha_test,
    depth_write,
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "createBasicMaterial")
fn create_basic_material_ffi(
  color: Int,
  transparent: Bool,
  opacity: Float,
  map: Option(Texture),
  side: Int,
  alpha_test: Float,
  depth_write: Bool,
) -> Material

/// Creates a [MeshStandardMaterial](https://threejs.org/docs/#api/en/materials/MeshStandardMaterial).
///
/// A physically-based rendering (PBR) material using the metallic-roughness workflow.
/// This is the recommended material for realistic rendering with proper lighting.
///
/// ## Parameters
///
/// - `color` - Base color (albedo) as hex
/// - `metalness` - How metallic the surface is (0.0 = dielectric, 1.0 = metal)
/// - `roughness` - How rough the surface is (0.0 = mirror, 1.0 = diffuse)
/// - `transparent` - Enable transparency
/// - `opacity` - Opacity value
/// - `map` - Color/albedo texture
/// - `normal_map` - Normal map for surface detail
/// - `ao_map` - Ambient occlusion map
/// - `displacement_map` - Displacement map for vertex displacement
/// - `displacement_scale` - Displacement strength
/// - `displacement_bias` - Displacement offset
/// - `roughness_map` - Per-pixel roughness
/// - `metalness_map` - Per-pixel metalness
/// - `emissive` - Emissive (glow) color
/// - `emissive_intensity` - Emissive strength
///
/// ## Example
///
/// ```gleam
/// // Shiny metal
/// let metal = create_standard_material(
///   0xcccccc, 1.0, 0.2,  // Silver, full metal, slightly rough
///   False, 1.0,          // Opaque
///   option.None, option.None, option.None,  // No textures
///   option.None, 0.0, 0.0,  // No displacement
///   option.None, option.None,  // No maps
///   0x000000, 0.0         // No emission
/// )
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createStandardMaterial")
pub fn create_standard_material(
  color: Int,
  metalness: Float,
  roughness: Float,
  transparent: Bool,
  opacity: Float,
  map: Option(Texture),
  normal_map: Option(Texture),
  ao_map: Option(Texture),
  displacement_map: Option(Texture),
  displacement_scale: Float,
  displacement_bias: Float,
  roughness_map: Option(Texture),
  metalness_map: Option(Texture),
  emissive: Int,
  emissive_intensity: Float,
) -> Material

/// Creates a [MeshPhongMaterial](https://threejs.org/docs/#api/en/materials/MeshPhongMaterial).
///
/// A material for shiny surfaces with specular highlights. Less realistic than
/// StandardMaterial but faster to render. Good for stylized graphics.
///
/// ## Parameters
///
/// - `color` - Base color as hex
/// - `shininess` - Specular highlight size (higher = smaller, sharper highlights)
/// - `map` - Color texture
/// - `normal_map` - Normal map
/// - `ao_map` - Ambient occlusion map
/// - `transparent` - Enable transparency
/// - `opacity` - Opacity value
/// - `alpha_test` - Alpha cutoff threshold (pixels below this are discarded)
@external(javascript, "./savoiardi.ffi.mjs", "createPhongMaterial")
pub fn create_phong_material(
  color: Int,
  shininess: Float,
  map: Option(Texture),
  normal_map: Option(Texture),
  ao_map: Option(Texture),
  transparent: Bool,
  opacity: Float,
  alpha_test: Float,
) -> Material

/// Creates a [MeshLambertMaterial](https://threejs.org/docs/#api/en/materials/MeshLambertMaterial).
///
/// A material for non-shiny surfaces (matte). Cheaper than Phong/Standard.
/// Uses Lambertian reflectance (diffuse only, no specular).
///
/// ## Parameters
///
/// - `color` - Base color as hex
/// - `map` - Color texture
/// - `normal_map` - Normal map
/// - `ao_map` - Ambient occlusion map
/// - `transparent` - Enable transparency
/// - `opacity` - Opacity value
/// - `alpha_test` - Alpha cutoff threshold
@external(javascript, "./savoiardi.ffi.mjs", "createLambertMaterial")
pub fn create_lambert_material(
  color: Int,
  map: Option(Texture),
  normal_map: Option(Texture),
  ao_map: Option(Texture),
  transparent: Bool,
  opacity: Float,
  alpha_test: Float,
) -> Material

/// Creates a [MeshToonMaterial](https://threejs.org/docs/#api/en/materials/MeshToonMaterial).
///
/// A cel-shaded (cartoon) material with hard lighting transitions.
/// Great for stylized, anime-like graphics.
///
/// ## Parameters
///
/// - `color` - Base color as hex
/// - `map` - Color texture
/// - `normal_map` - Normal map
/// - `ao_map` - Ambient occlusion map
/// - `transparent` - Enable transparency
/// - `opacity` - Opacity value
/// - `alpha_test` - Alpha cutoff threshold
@external(javascript, "./savoiardi.ffi.mjs", "createToonMaterial")
pub fn create_toon_material(
  color: Int,
  map: Option(Texture),
  normal_map: Option(Texture),
  ao_map: Option(Texture),
  transparent: Bool,
  opacity: Float,
  alpha_test: Float,
) -> Material

/// Creates a [LineBasicMaterial](https://threejs.org/docs/#api/en/materials/LineBasicMaterial).
///
/// Material for Line and LineSegments objects.
///
/// ## Parameters
///
/// - `color` - Line color as hex
/// - `linewidth` - Line width in pixels (note: line width > 1 not supported on all platforms)
@external(javascript, "./savoiardi.ffi.mjs", "createLineMaterial")
pub fn create_line_material(color: Int, linewidth: Float) -> Material

/// Creates a [SpriteMaterial](https://threejs.org/docs/#api/en/materials/SpriteMaterial).
///
/// Material for Sprite objects (always camera-facing planes).
///
/// ## Parameters
///
/// - `color` - Tint color as hex
/// - `transparent` - Enable transparency
/// - `opacity` - Opacity value
/// - `map` - Sprite texture
@external(javascript, "./savoiardi.ffi.mjs", "createSpriteMaterial")
pub fn create_sprite_material(
  color: Int,
  transparent: Bool,
  opacity: Float,
  map: Option(Texture),
) -> Material

/// Creates a [PointsMaterial](https://threejs.org/docs/#api/en/materials/PointsMaterial).
///
/// Material for Points (particle) objects. Each vertex is rendered as a point/sprite.
///
/// ## Parameters
///
/// - `size` - Point size in world units (or pixels if size_attenuation is False)
/// - `vertex_colors` - Use per-vertex colors from geometry
/// - `transparent` - Enable transparency
/// - `opacity` - Opacity value
/// - `depth_write` - Write to depth buffer (False for additive particles)
/// - `blending` - Blending mode (AdditiveBlending for glow, NormalBlending for standard)
/// - `size_attenuation` - If True, points get smaller with distance
///
/// ## Example
///
/// ```gleam
/// // Additive particle material for glow effects
/// let particles = create_points_material(
///   0.1, False, True, 0.8,
///   False, AdditiveBlending, True
/// )
/// ```
pub fn create_points_material(
  size: Float,
  vertex_colors: Bool,
  transparent: Bool,
  opacity: Float,
  depth_write: Bool,
  blending: BlendingMode,
  size_attenuation: Bool,
) -> Material {
  create_points_material_internal(
    size,
    vertex_colors,
    transparent,
    opacity,
    depth_write,
    blending_mode_to_int(blending),
    size_attenuation,
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "createPointsMaterial")
fn create_points_material_internal(
  size: Float,
  vertex_colors: Bool,
  transparent: Bool,
  opacity: Float,
  depth_write: Bool,
  blending: Int,
  size_attenuation: Bool,
) -> Material

// ============================================================================
// LIGHTS
// ============================================================================

/// Creates an [AmbientLight](https://threejs.org/docs/#api/en/lights/AmbientLight).
///
/// Illuminates all objects equally from all directions. Provides baseline
/// illumination so shadows aren't completely black. Does not cast shadows.
///
/// ## Parameters
///
/// - `color` - Light color as hex
/// - `intensity` - Light strength (typically 0.1-1.0)
///
/// ## Example
///
/// ```gleam
/// // Soft ambient light
/// let ambient = create_ambient_light(0x404040, 0.5)
/// add_to_scene(scene: scene, object: ambient)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createAmbientLight")
pub fn create_ambient_light(color: Int, intensity: Float) -> Light

/// Creates a [DirectionalLight](https://threejs.org/docs/#api/en/lights/DirectionalLight).
///
/// A light that shines in a specific direction, as if from infinitely far away
/// (like the sun). All rays are parallel. Can cast shadows.
///
/// ## Parameters
///
/// - `color` - Light color as hex
/// - `intensity` - Light strength
/// - `cast_shadow` - Enable shadow casting
/// - `shadow_resolution` - Shadow map size (e.g., 1024, 2048). Higher = sharper shadows
/// - `shadow_bias` - Bias to prevent shadow acne. Typical: -0.0001 to -0.001
///
/// ## Example
///
/// ```gleam
/// let shadow_config = DirectionalShadowConfig(
///   resolution: 2048,
///   bias: -0.0001,
///   normal_bias: 0.5,
///   camera_left: -200.0, camera_right: 200.0,
///   camera_top: 200.0, camera_bottom: -200.0,
///   camera_near: 0.5, camera_far: 500.0,
/// )
/// let sun = create_directional_light(0xffffff, 1.0, True, shadow_config)
/// ```
pub fn create_directional_light(
  color: Int,
  intensity: Float,
  cast_shadow: Bool,
  shadow_config: DirectionalShadowConfig,
) -> Light {
  create_directional_light_ffi(
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
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "createDirectionalLight")
fn create_directional_light_ffi(
  color: Int,
  intensity: Float,
  cast_shadow: Bool,
  shadow_resolution: Int,
  shadow_bias: Float,
  shadow_normal_bias: Float,
  shadow_camera_left: Float,
  shadow_camera_right: Float,
  shadow_camera_top: Float,
  shadow_camera_bottom: Float,
  shadow_camera_near: Float,
  shadow_camera_far: Float,
) -> Light

/// Creates a [PointLight](https://threejs.org/docs/#api/en/lights/PointLight).
///
/// A light that emits in all directions from a single point (like a light bulb).
/// Intensity falls off with distance. Can cast shadows (expensive).
///
/// ## Parameters
///
/// - `color` - Light color as hex
/// - `intensity` - Light strength
/// - `distance` - Maximum range (0 = no limit, light decays naturally)
/// - `cast_shadow` - Enable shadow casting (uses cube shadow map, expensive)
/// - `shadow_config` - Shadow configuration (resolution, bias, normal_bias)
pub fn create_point_light(
  color: Int,
  intensity: Float,
  distance: Float,
  cast_shadow: Bool,
  shadow_config: ShadowConfig,
) -> Light {
  create_point_light_ffi(
    color,
    intensity,
    distance,
    cast_shadow,
    shadow_config.resolution,
    shadow_config.bias,
    shadow_config.normal_bias,
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "createPointLight")
fn create_point_light_ffi(
  color: Int,
  intensity: Float,
  distance: Float,
  cast_shadow: Bool,
  shadow_resolution: Int,
  shadow_bias: Float,
  shadow_normal_bias: Float,
) -> Light

/// Creates a [SpotLight](https://threejs.org/docs/#api/en/lights/SpotLight).
///
/// A light that emits in a cone from a single point (like a flashlight or stage light).
/// Can cast shadows with a single shadow map.
///
/// ## Parameters
///
/// - `color` - Light color as hex
/// - `intensity` - Light strength
/// - `distance` - Maximum range (0 = no limit)
/// - `angle` - Maximum cone angle in radians (max: π/2)
/// - `penumbra` - Soft edge percentage (0 = hard edge, 1 = fully soft)
/// - `cast_shadow` - Enable shadow casting
/// - `shadow_config` - Shadow configuration (resolution, bias, normal_bias)
pub fn create_spot_light(
  color: Int,
  intensity: Float,
  distance: Float,
  angle: Float,
  penumbra: Float,
  cast_shadow: Bool,
  shadow_config: ShadowConfig,
) -> Light {
  create_spot_light_ffi(
    color,
    intensity,
    distance,
    angle,
    penumbra,
    cast_shadow,
    shadow_config.resolution,
    shadow_config.bias,
    shadow_config.normal_bias,
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "createSpotLight")
fn create_spot_light_ffi(
  color: Int,
  intensity: Float,
  distance: Float,
  angle: Float,
  penumbra: Float,
  cast_shadow: Bool,
  shadow_resolution: Int,
  shadow_bias: Float,
  shadow_normal_bias: Float,
) -> Light

/// Creates a [HemisphereLight](https://threejs.org/docs/#api/en/lights/HemisphereLight).
///
/// A light positioned above the scene that fades from sky color (above) to ground
/// color (below). Provides natural-looking ambient lighting for outdoor scenes.
/// Does not cast shadows.
///
/// ## Parameters
///
/// - `sky_color` - Color from above as hex
/// - `ground_color` - Color from below as hex
/// - `intensity` - Light strength
///
/// ## Example
///
/// ```gleam
/// // Blue sky, brown ground
/// let hemi = create_hemisphere_light(0x87ceeb, 0x8b4513, 0.6)
/// add_to_scene(scene: scene, object: hemi)
/// ```
@external(javascript, "./savoiardi.ffi.mjs", "createHemisphereLight")
pub fn create_hemisphere_light(
  sky_color: Int,
  ground_color: Int,
  intensity: Float,
) -> Light

// ============================================================================
// OBJECTS
// ============================================================================

/// Creates a [Sprite](https://threejs.org/docs/#api/en/objects/Sprite).
///
/// A sprite is a plane that always faces the camera (billboard). Commonly used
/// for particles, labels, lens flares, and UI elements in 3D space.
///
/// ## Parameters
///
/// - `material` - A SpriteMaterial (created with `create_sprite_material`)
@external(javascript, "./savoiardi.ffi.mjs", "createSprite")
pub fn create_sprite(material: Material) -> Sprite

/// Creates a [Points](https://threejs.org/docs/#api/en/objects/Points) object (particle system).
///
/// Renders each vertex in the geometry as a point/sprite. Efficient for large
/// particle systems with thousands of particles.
///
/// ## Parameters
///
/// - `geometry` - Geometry containing vertex positions (and optionally colors)
/// - `material` - A PointsMaterial (created with `create_points_material`)
@external(javascript, "./savoiardi.ffi.mjs", "createPoints")
pub fn create_points(geometry: Geometry, material: Material) -> Points

/// Creates [LineSegments](https://threejs.org/docs/#api/en/objects/LineSegments).
///
/// Draws a series of line segments. Every pair of consecutive vertices forms
/// a separate line segment (unlike Line which connects all vertices).
///
/// ## Parameters
///
/// - `geometry` - Geometry with vertex positions
/// - `material` - A LineBasicMaterial (created with `create_line_material`)
@external(javascript, "./savoiardi.ffi.mjs", "createLineSegments")
pub fn create_line_segments(geometry: Geometry, material: Material) -> Object3D

// ============================================================================
// SCENE GRAPH MANIPULATION
// ============================================================================

/// Removes a child from its parent.
///
/// Wraps [Object3D.remove](https://threejs.org/docs/#api/en/core/Object3D.remove).
@external(javascript, "./savoiardi.ffi.mjs", "removeChild")
pub fn remove_child(parent: Object3D, child: Object3D) -> Nil

/// Sets the object's local position.
///
/// Wraps [Object3D.position](https://threejs.org/docs/#api/en/core/Object3D.position).
///
/// ## Parameters
///
/// - `object` - The object to position
/// - `position` - Position as Vec3 (x, y, z)
@external(javascript, "./savoiardi.ffi.mjs", "setPosition")
pub fn set_object_position(object: Object3D, position: Vec3(Float)) -> Nil

/// Sets the object's local rotation using Euler angles.
///
/// Wraps [Object3D.rotation](https://threejs.org/docs/#api/en/core/Object3D.rotation).
/// Rotation order is XYZ by default.
///
/// ## Parameters
///
/// - `object` - The object to rotate
/// - `rotation` - Rotation in radians as Vec3 (x, y, z)
@external(javascript, "./savoiardi.ffi.mjs", "setRotation")
pub fn set_object_rotation(object: Object3D, rotation: Vec3(Float)) -> Nil

/// Sets the object's local scale.
///
/// Wraps [Object3D.scale](https://threejs.org/docs/#api/en/core/Object3D.scale).
///
/// ## Parameters
///
/// - `object` - The object to scale
/// - `scale` - Scale factors as Vec3 (1.0 = original size)
@external(javascript, "./savoiardi.ffi.mjs", "setScale")
pub fn set_object_scale(object: Object3D, scale: Vec3(Float)) -> Nil

/// Gets the object's world position.
///
/// Wraps [Object3D.getWorldPosition](https://threejs.org/docs/#api/en/core/Object3D.getWorldPosition).
/// Returns the position in world space, accounting for all parent transforms.
@external(javascript, "./savoiardi.ffi.mjs", "getWorldPosition")
pub fn get_world_position(object: Object3D) -> Vec3(Float)

/// Gets the object's world quaternion.
///
/// Wraps [Object3D.getWorldQuaternion](https://threejs.org/docs/#api/en/core/Object3D.getWorldQuaternion).
/// Returns the rotation as a quaternion in world space.
@external(javascript, "./savoiardi.ffi.mjs", "getWorldQuaternion")
pub fn get_world_quaternion(object: Object3D) -> Quaternion

/// Copies position from another object.
///
/// Sets this object's position to match the source object's position.
@external(javascript, "./savoiardi.ffi.mjs", "copyPosition")
pub fn copy_position(object: Object3D, source: Object3D) -> Nil

/// Copies rotation from another object.
///
/// Sets this object's rotation to match the source object's rotation.
@external(javascript, "./savoiardi.ffi.mjs", "copyRotation")
pub fn copy_rotation(object: Object3D, source: Object3D) -> Nil

/// Copies scale from another object.
///
/// Sets this object's scale to match the source object's scale.
@external(javascript, "./savoiardi.ffi.mjs", "copyScale")
pub fn copy_scale(object: Object3D, source: Object3D) -> Nil

// ============================================================================
// ANIMATION
// ============================================================================

/// Creates an [AnimationMixer](https://threejs.org/docs/#api/en/animation/AnimationMixer).
///
/// The mixer is a player for animations on a particular object. Each animated
/// object needs its own mixer. Call `update_mixer` each frame with delta time.
///
/// ## Parameters
///
/// - `root` - The root object to animate (usually a loaded model)
@external(javascript, "./savoiardi.ffi.mjs", "createAnimationMixer")
pub fn create_animation_mixer(root: Object3D) -> AnimationMixer

/// Gets an [AnimationAction](https://threejs.org/docs/#api/en/animation/AnimationAction) for a clip.
///
/// Wraps [AnimationMixer.clipAction](https://threejs.org/docs/#api/en/animation/AnimationMixer.clipAction).
/// Returns an action that can be played, paused, or configured.
///
/// ## Parameters
///
/// - `mixer` - The animation mixer
/// - `clip` - The animation clip (from loaded GLTF/FBX)
@external(javascript, "./savoiardi.ffi.mjs", "clipAction")
pub fn clip_action(
  mixer: AnimationMixer,
  clip: AnimationClip,
) -> AnimationAction

/// Updates the animation mixer.
///
/// Wraps [AnimationMixer.update](https://threejs.org/docs/#api/en/animation/AnimationMixer.update).
/// Call this every frame with the time delta in seconds.
///
/// ## Parameters
///
/// - `mixer` - The animation mixer
/// - `delta_time` - Time since last update in seconds
@external(javascript, "./savoiardi.ffi.mjs", "updateMixer")
pub fn update_mixer(mixer: AnimationMixer, delta_time: Float) -> Nil

/// Plays an animation action.
///
/// Wraps [AnimationAction.play](https://threejs.org/docs/#api/en/animation/AnimationAction.play).
@external(javascript, "./savoiardi.ffi.mjs", "playAction")
pub fn play_action(action: AnimationAction) -> Nil

/// Stops an animation action.
///
/// Wraps [AnimationAction.stop](https://threejs.org/docs/#api/en/animation/AnimationAction.stop).
/// Resets the action to the beginning.
@external(javascript, "./savoiardi.ffi.mjs", "stopAction")
pub fn stop_action(action: AnimationAction) -> Nil

/// Sets the loop mode of an animation action.
///
/// Wraps [AnimationAction.loop](https://threejs.org/docs/#api/en/animation/AnimationAction.loop).
///
/// ## Example
///
/// ```gleam
/// set_action_loop(action, LoopRepeat)  // Loop continuously
/// set_action_loop(action, LoopOnce)    // Play once and stop
/// ```
pub fn set_action_loop(action: AnimationAction, loop_mode: LoopMode) -> Nil {
  set_action_loop_internal(action, loop_mode_to_int(loop_mode))
}

@external(javascript, "./savoiardi.ffi.mjs", "setActionLoop")
fn set_action_loop_internal(action: AnimationAction, loop_mode: Int) -> Nil

/// Sets the time scale (playback speed) of an animation action.
///
/// Wraps [AnimationAction.timeScale](https://threejs.org/docs/#api/en/animation/AnimationAction.timeScale).
/// 1.0 = normal speed, 2.0 = double speed, 0.5 = half speed, negative = reverse.
@external(javascript, "./savoiardi.ffi.mjs", "setActionTimeScale")
pub fn set_action_time_scale(action: AnimationAction, time_scale: Float) -> Nil

/// Sets the weight of an animation action.
///
/// Wraps [AnimationAction.weight](https://threejs.org/docs/#api/en/animation/AnimationAction.weight).
/// Used for blending multiple animations. 0.0 = no influence, 1.0 = full influence.
@external(javascript, "./savoiardi.ffi.mjs", "setActionWeight")
pub fn set_action_weight(action: AnimationAction, weight: Float) -> Nil

/// Gets the name of an animation clip.
///
/// Accesses [AnimationClip.name](https://threejs.org/docs/#api/en/animation/AnimationClip.name).
@external(javascript, "./savoiardi.ffi.mjs", "getClipName")
pub fn get_clip_name(clip: AnimationClip) -> String

/// Gets the duration of an animation clip in seconds.
///
/// Accesses [AnimationClip.duration](https://threejs.org/docs/#api/en/animation/AnimationClip.duration).
@external(javascript, "./savoiardi.ffi.mjs", "getClipDuration")
pub fn get_clip_duration(clip: AnimationClip) -> Float

// ============================================================================
// TEXTURES
// ============================================================================

/// Clones a texture for independent manipulation.
///
/// Wraps [Texture.clone](https://threejs.org/docs/#api/en/textures/Texture.clone).
/// The clone shares the underlying image but has independent UV properties.
@external(javascript, "./savoiardi.ffi.mjs", "cloneTexture")
pub fn clone_texture(texture: Texture) -> Texture

/// Sets the UV offset of a texture.
///
/// Wraps [Texture.offset](https://threejs.org/docs/#api/en/textures/Texture.offset).
/// Useful for sprite sheet animation or tiling effects.
///
/// ## Parameters
///
/// - `texture` - The texture to modify
/// - `x` - Horizontal offset (0.0-1.0)
/// - `y` - Vertical offset (0.0-1.0)
@external(javascript, "./savoiardi.ffi.mjs", "setTextureOffset")
pub fn set_texture_offset(texture: Texture, x: Float, y: Float) -> Nil

/// Sets the UV repeat (tiling) of a texture.
///
/// Wraps [Texture.repeat](https://threejs.org/docs/#api/en/textures/Texture.repeat).
///
/// ## Parameters
///
/// - `texture` - The texture to modify
/// - `x` - Horizontal repeat count
/// - `y` - Vertical repeat count
@external(javascript, "./savoiardi.ffi.mjs", "setTextureRepeat")
pub fn set_texture_repeat(texture: Texture, x: Float, y: Float) -> Nil

/// Sets the texture wrapping mode.
///
/// Wraps [Texture.wrapS](https://threejs.org/docs/#api/en/textures/Texture.wrapS) and
/// [Texture.wrapT](https://threejs.org/docs/#api/en/textures/Texture.wrapT).
///
/// ## Example
///
/// ```gleam
/// set_texture_wrap_mode(texture, RepeatWrapping, RepeatWrapping)
/// ```
pub fn set_texture_wrap_mode(
  texture: Texture,
  wrap_s: WrapMode,
  wrap_t: WrapMode,
) -> Nil {
  set_texture_wrap_mode_internal(
    texture,
    wrap_mode_to_int(wrap_s),
    wrap_mode_to_int(wrap_t),
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "setTextureWrapMode")
fn set_texture_wrap_mode_internal(
  texture: Texture,
  wrap_s: Int,
  wrap_t: Int,
) -> Nil

/// Sets the texture filtering mode.
///
/// Wraps [Texture.minFilter](https://threejs.org/docs/#api/en/textures/Texture.minFilter) and
/// [Texture.magFilter](https://threejs.org/docs/#api/en/textures/Texture.magFilter).
///
/// ## Example
///
/// ```gleam
/// // For pixel art
/// set_texture_filter_mode(texture, NearestFilter, NearestFilter)
///
/// // For smooth textures
/// set_texture_filter_mode(texture, LinearFilter, LinearFilter)
/// ```
pub fn set_texture_filter_mode(
  texture: Texture,
  min_filter: FilterMode,
  mag_filter: FilterMode,
) -> Nil {
  set_texture_filter_mode_internal(
    texture,
    filter_mode_to_int(min_filter),
    filter_mode_to_int(mag_filter),
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "setTextureFilterMode")
fn set_texture_filter_mode_internal(
  texture: Texture,
  min_filter: Int,
  mag_filter: Int,
) -> Nil

// Internal helpers for converting enum types to Three.js constants

@external(javascript, "./savoiardi.ffi.mjs", "getRepeatWrapping")
fn get_repeat_wrapping_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getClampToEdgeWrapping")
fn get_clamp_to_edge_wrapping_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getMirroredRepeatWrapping")
fn get_mirrored_repeat_wrapping_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getNearestFilter")
fn get_nearest_filter_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getLinearFilter")
fn get_linear_filter_constant() -> Int

fn wrap_mode_to_int(mode: WrapMode) -> Int {
  case mode {
    RepeatWrapping -> get_repeat_wrapping_constant()
    ClampToEdgeWrapping -> get_clamp_to_edge_wrapping_constant()
    MirroredRepeatWrapping -> get_mirrored_repeat_wrapping_constant()
  }
}

fn filter_mode_to_int(mode: FilterMode) -> Int {
  case mode {
    NearestFilter -> get_nearest_filter_constant()
    LinearFilter -> get_linear_filter_constant()
  }
}

// ============================================================================
// AUDIO
// ============================================================================

/// Creates an [AudioListener](https://threejs.org/docs/#api/en/audio/AudioListener).
///
/// Represents the virtual "ears" for the scene. Usually attached to the camera.
/// Required for any audio playback in the scene.
@external(javascript, "./savoiardi.ffi.mjs", "createAudioListener")
pub fn create_audio_listener() -> AudioListener

/// Creates a global [Audio](https://threejs.org/docs/#api/en/audio/Audio) object.
///
/// Non-positional audio that plays at constant volume regardless of camera position.
/// Use for background music, UI sounds, ambient audio.
///
/// ## Parameters
///
/// - `listener` - The AudioListener for the scene
@external(javascript, "./savoiardi.ffi.mjs", "createAudio")
pub fn create_audio(listener: AudioListener) -> Audio

/// Creates a [PositionalAudio](https://threejs.org/docs/#api/en/audio/PositionalAudio) object.
///
/// 3D audio that changes volume and panning based on distance and direction
/// from the listener. Use for sound effects attached to objects.
///
/// ## Parameters
///
/// - `listener` - The AudioListener for the scene
@external(javascript, "./savoiardi.ffi.mjs", "createPositionalAudio")
pub fn create_positional_audio(listener: AudioListener) -> PositionalAudio

/// Sets the audio buffer for an Audio object.
///
/// Wraps [Audio.setBuffer](https://threejs.org/docs/#api/en/audio/Audio.setBuffer).
/// Load audio with `load_audio` first.
@external(javascript, "./savoiardi.ffi.mjs", "setAudioBuffer")
pub fn set_audio_buffer(audio: Audio, buffer: AudioBuffer) -> Nil

/// Starts playing audio.
///
/// Wraps [Audio.play](https://threejs.org/docs/#api/en/audio/Audio.play).
/// **Note:** Browser autoplay policies may require user interaction first.
@external(javascript, "./savoiardi.ffi.mjs", "playAudio")
pub fn play_audio(audio: Audio) -> Nil

/// Pauses audio playback.
///
/// Wraps [Audio.pause](https://threejs.org/docs/#api/en/audio/Audio.pause).
/// Playback resumes from the current position when played again.
@external(javascript, "./savoiardi.ffi.mjs", "pauseAudio")
pub fn pause_audio(audio: Audio) -> Nil

/// Stops audio playback.
///
/// Wraps [Audio.stop](https://threejs.org/docs/#api/en/audio/Audio.stop).
/// Resets playback position to the beginning.
@external(javascript, "./savoiardi.ffi.mjs", "stopAudio")
pub fn stop_audio(audio: Audio) -> Nil

/// Sets the audio volume.
///
/// Wraps [Audio.setVolume](https://threejs.org/docs/#api/en/audio/Audio.setVolume).
///
/// ## Parameters
///
/// - `audio` - The audio object
/// - `volume` - Volume from 0.0 (silent) to 1.0 (full volume)
@external(javascript, "./savoiardi.ffi.mjs", "setAudioVolume")
pub fn set_audio_volume(audio: Audio, volume: Float) -> Nil

/// Sets whether audio should loop.
///
/// Wraps [Audio.setLoop](https://threejs.org/docs/#api/en/audio/Audio.setLoop).
@external(javascript, "./savoiardi.ffi.mjs", "setAudioLoop")
pub fn set_audio_loop(audio: Audio, loop: Bool) -> Nil

/// Sets the audio playback rate.
///
/// Wraps [Audio.setPlaybackRate](https://threejs.org/docs/#api/en/audio/Audio.setPlaybackRate).
/// 1.0 = normal speed, 2.0 = double speed, 0.5 = half speed.
@external(javascript, "./savoiardi.ffi.mjs", "setAudioPlaybackRate")
pub fn set_audio_playback_rate(audio: Audio, rate: Float) -> Nil

/// Checks if audio is currently playing.
///
/// Accesses [Audio.isPlaying](https://threejs.org/docs/#api/en/audio/Audio.isPlaying).
@external(javascript, "./savoiardi.ffi.mjs", "isAudioPlaying")
pub fn is_audio_playing(audio: Audio) -> Bool

/// Sets the reference distance for positional audio attenuation.
///
/// Wraps [PositionalAudio.setRefDistance](https://threejs.org/docs/#api/en/audio/PositionalAudio.setRefDistance).
/// The distance at which the volume reduction starts. Audio at this distance
/// plays at full volume; beyond this, volume decreases based on rolloff.
///
/// ## Parameters
///
/// - `audio` - The positional audio object
/// - `distance` - Reference distance in world units (default: 1)
@external(javascript, "./savoiardi.ffi.mjs", "setRefDistance")
pub fn set_ref_distance(audio: PositionalAudio, distance: Float) -> Nil

/// Sets the rolloff factor for positional audio attenuation.
///
/// Wraps [PositionalAudio.setRolloffFactor](https://threejs.org/docs/#api/en/audio/PositionalAudio.setRolloffFactor).
/// Controls how quickly volume decreases with distance. Higher values = faster falloff.
///
/// ## Parameters
///
/// - `audio` - The positional audio object
/// - `factor` - Rolloff factor (default: 1, range: 0-∞)
@external(javascript, "./savoiardi.ffi.mjs", "setRolloffFactor")
pub fn set_rolloff_factor(audio: PositionalAudio, factor: Float) -> Nil

/// Sets the maximum distance for positional audio.
///
/// Wraps [PositionalAudio.setMaxDistance](https://threejs.org/docs/#api/en/audio/PositionalAudio.setMaxDistance).
/// Beyond this distance, volume won't decrease further.
///
/// ## Parameters
///
/// - `audio` - The positional audio object
/// - `distance` - Maximum distance in world units (default: 10000)
@external(javascript, "./savoiardi.ffi.mjs", "setMaxDistance")
pub fn set_max_distance(audio: PositionalAudio, distance: Float) -> Nil

/// Checks if an audio object has a buffer loaded.
///
/// Returns `True` if `set_audio_buffer` has been called with a valid buffer.
@external(javascript, "./savoiardi.ffi.mjs", "hasAudioBuffer")
pub fn has_audio_buffer(audio: Audio) -> Bool

/// Gets the loop state of an audio object.
///
/// Accesses [Audio.loop](https://threejs.org/docs/#api/en/audio/Audio.loop).
@external(javascript, "./savoiardi.ffi.mjs", "getAudioLoop")
pub fn get_audio_loop(audio: Audio) -> Bool

/// Gets the current state of the Web Audio [AudioContext](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext/state).
///
/// ## Returns
///
/// One of: "suspended", "running", or "closed".
/// Browsers often start in "suspended" state until user interaction.
@external(javascript, "./savoiardi.ffi.mjs", "getAudioContextState")
pub fn get_audio_context_state() -> String

/// Resumes the Web Audio [AudioContext](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext/resume).
///
/// Call this after user interaction (e.g., button click) to enable audio
/// playback in browsers with autoplay restrictions.
@external(javascript, "./savoiardi.ffi.mjs", "resumeAudioContext")
pub fn resume_audio_context() -> Nil

// ============================================================================
// DEBUG HELPERS
// ============================================================================

/// Creates an [AxesHelper](https://threejs.org/docs/#api/en/helpers/AxesHelper).
///
/// Displays the 3 axes in a simple way: X (red), Y (green), Z (blue).
/// Useful for understanding object orientation and debugging transforms.
///
/// ## Parameters
///
/// - `size` - Length of each axis line
@external(javascript, "./savoiardi.ffi.mjs", "createAxesHelper")
pub fn create_axes_helper(size: Float) -> Object3D

/// Creates a [GridHelper](https://threejs.org/docs/#api/en/helpers/GridHelper).
///
/// A 2D grid in the XZ plane. Useful for visualizing the ground plane and
/// understanding scale in the scene.
///
/// ## Parameters
///
/// - `size` - Total size of the grid (extends size/2 in each direction)
/// - `divisions` - Number of divisions (grid cells)
/// - `color` - Grid line color as hex
@external(javascript, "./savoiardi.ffi.mjs", "createGridHelper")
pub fn create_grid_helper(size: Float, divisions: Int, color: Int) -> Object3D

/// Creates a [BoxHelper](https://threejs.org/docs/#api/en/helpers/BoxHelper).
///
/// A wireframe box that shows the bounding box of an object.
/// Useful for visualizing object bounds and debugging collisions.
///
/// ## Parameters
///
/// - `object` - The object to create a bounding box helper for
/// - `color` - Wireframe color as hex
@external(javascript, "./savoiardi.ffi.mjs", "createBoxHelper")
pub fn create_box_helper(object: Object3D, color: Int) -> Object3D

// ============================================================================
// BUFFER GEOMETRY MANIPULATION
// ============================================================================

/// Creates an empty [BufferGeometry](https://threejs.org/docs/#api/en/core/BufferGeometry).
///
/// BufferGeometry is the most efficient geometry type, storing data in typed arrays.
/// Add attributes (position, normal, color, uv) using `set_geometry_attribute`.
@external(javascript, "./savoiardi.ffi.mjs", "createBufferGeometry")
pub fn create_buffer_geometry() -> Geometry

/// Creates a [BufferAttribute](https://threejs.org/docs/#api/en/core/BufferAttribute) from a Float32Array.
///
/// BufferAttributes store data for geometry attributes like positions, normals, and colors.
///
/// ## Parameters
///
/// - `array` - The Float32Array containing the data
/// - `item_size` - Number of values per vertex (3 for xyz, 4 for rgba, 2 for uv)
@external(javascript, "./savoiardi.ffi.mjs", "createBufferAttribute")
pub fn create_buffer_attribute(
  array: Float32Array,
  item_size: Int,
) -> BufferAttribute

/// Sets an attribute on a [BufferGeometry](https://threejs.org/docs/#api/en/core/BufferGeometry.setAttribute).
///
/// ## Parameters
///
/// - `geometry` - The geometry to modify
/// - `name` - Attribute name ("position", "normal", "color", "uv", etc.)
/// - `attribute` - The BufferAttribute to set
@external(javascript, "./savoiardi.ffi.mjs", "setGeometryAttribute")
pub fn set_geometry_attribute(
  geometry: Geometry,
  name: String,
  attribute: BufferAttribute,
) -> Nil

/// Marks a buffer attribute for GPU upload.
///
/// Sets [BufferAttribute.needsUpdate](https://threejs.org/docs/#api/en/core/BufferAttribute.needsUpdate)
/// to `true`. Call this after modifying attribute data.
@external(javascript, "./savoiardi.ffi.mjs", "markAttributeNeedsUpdate")
pub fn mark_attribute_needs_update(attribute: BufferAttribute) -> Nil

/// Sets the draw range for a geometry.
///
/// Wraps [BufferGeometry.setDrawRange](https://threejs.org/docs/#api/en/core/BufferGeometry.setDrawRange).
/// Limits which vertices are rendered, useful for partial geometry rendering.
///
/// ## Parameters
///
/// - `geometry` - The geometry to modify
/// - `start` - First vertex index to render
/// - `count` - Number of vertices to render
@external(javascript, "./savoiardi.ffi.mjs", "setDrawRange")
pub fn set_draw_range(geometry: Geometry, start: Int, count: Int) -> Nil

// ============================================================================
// MATH UTILITIES
// ============================================================================

/// Creates a [Color](https://threejs.org/docs/#api/en/math/Color) from a hex value.
///
/// ## Parameters
///
/// - `hex` - Color as hex integer (e.g., `0xff0000` for red)
@external(javascript, "./savoiardi.ffi.mjs", "createColor")
pub fn create_color(hex: Int) -> Color

/// Linearly interpolates between two colors.
///
/// Wraps [Color.lerp](https://threejs.org/docs/#api/en/math/Color.lerp).
/// Creates a new color that is a blend of the two input colors.
///
/// ## Parameters
///
/// - `color1` - Starting color (t=0)
/// - `color2` - Ending color (t=1)
/// - `t` - Interpolation factor (0.0 to 1.0)
@external(javascript, "./savoiardi.ffi.mjs", "lerpColor")
pub fn lerp_color(color1: Color, color2: Color, t: Float) -> Color

// ============================================================================
// INTERNAL CONSTANTS
// ============================================================================

// Internal helpers for converting enum types to Three.js constants

@external(javascript, "./savoiardi.ffi.mjs", "getLoopOnce")
fn get_loop_once_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getLoopRepeat")
fn get_loop_repeat_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getLoopPingPong")
fn get_loop_ping_pong_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getAdditiveBlending")
fn get_additive_blending_constant() -> Int

@external(javascript, "./savoiardi.ffi.mjs", "getNormalBlending")
fn get_normal_blending_constant() -> Int

fn loop_mode_to_int(mode: LoopMode) -> Int {
  case mode {
    LoopOnce -> get_loop_once_constant()
    LoopRepeat -> get_loop_repeat_constant()
    LoopPingPong -> get_loop_ping_pong_constant()
  }
}

fn blending_mode_to_int(mode: BlendingMode) -> Int {
  case mode {
    AdditiveBlending -> get_additive_blending_constant()
    NormalBlending -> get_normal_blending_constant()
  }
}

// ============================================================================
// PARTICLE SYSTEMS HELPERS
// ============================================================================

/// Gets the red component of a color (0.0 to 1.0).
///
/// Accesses [Color.r](https://threejs.org/docs/#api/en/math/Color.r).
@external(javascript, "./savoiardi.ffi.mjs", "getColorR")
pub fn get_color_r(color: Color) -> Float

/// Gets the green component of a color (0.0 to 1.0).
///
/// Accesses [Color.g](https://threejs.org/docs/#api/en/math/Color.g).
@external(javascript, "./savoiardi.ffi.mjs", "getColorG")
pub fn get_color_g(color: Color) -> Float

/// Gets the blue component of a color (0.0 to 1.0).
///
/// Accesses [Color.b](https://threejs.org/docs/#api/en/math/Color.b).
@external(javascript, "./savoiardi.ffi.mjs", "getColorB")
pub fn get_color_b(color: Color) -> Float

/// Creates a [Float32Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Float32Array) of the specified size.
///
/// Used for storing vertex data for buffer geometry attributes.
///
/// ## Parameters
///
/// - `size` - Number of float elements in the array
@external(javascript, "./savoiardi.ffi.mjs", "createFloat32Array")
pub fn create_float32_array(size: Int) -> Float32Array

/// Sets a buffer attribute directly on geometry.
///
/// Convenience function that creates a BufferAttribute and sets it in one call.
///
/// ## Parameters
///
/// - `geometry` - The geometry to modify
/// - `name` - Attribute name ("position", "color", etc.)
/// - `array` - The Float32Array containing the data
/// - `item_size` - Values per vertex (3 for xyz, 4 for rgba)
@external(javascript, "./savoiardi.ffi.mjs", "setBufferAttribute")
pub fn set_buffer_attribute(
  geometry: Geometry,
  name: String,
  array: Float32Array,
  item_size: Int,
) -> Nil

/// Gets the geometry from a Points object.
///
/// Accesses [Points.geometry](https://threejs.org/docs/#api/en/objects/Points.geometry).
@external(javascript, "./savoiardi.ffi.mjs", "getGeometry")
pub fn get_geometry(points: Points) -> Geometry

/// Gets an attribute from geometry by name.
///
/// Wraps [BufferGeometry.getAttribute](https://threejs.org/docs/#api/en/core/BufferGeometry.getAttribute).
///
/// ## Parameters
///
/// - `geometry` - The geometry to query
/// - `name` - Attribute name ("position", "color", "normal", "uv", etc.)
@external(javascript, "./savoiardi.ffi.mjs", "getAttribute")
pub fn get_attribute(geometry: Geometry, name: String) -> BufferAttribute

/// Sets XYZ values in a buffer attribute at a specific index.
///
/// Wraps [BufferAttribute.setXYZ](https://threejs.org/docs/#api/en/core/BufferAttribute.setXYZ).
///
/// ## Parameters
///
/// - `attribute` - The buffer attribute to modify
/// - `index` - Vertex index
/// - `value` - XYZ values as Vec3
@external(javascript, "./savoiardi.ffi.mjs", "setBufferXYZ")
pub fn set_buffer_xyz(
  attribute: BufferAttribute,
  index: Int,
  value: Vec3(Float),
) -> Nil

/// Sets a single value (X component) in a buffer attribute at an index.
///
/// Wraps [BufferAttribute.setX](https://threejs.org/docs/#api/en/core/BufferAttribute.setX).
@external(javascript, "./savoiardi.ffi.mjs", "setBufferX")
pub fn set_buffer_x(attribute: BufferAttribute, index: Int, value: Float) -> Nil

/// Sets the needsUpdate flag on a buffer attribute.
///
/// When `True`, the attribute data will be uploaded to the GPU on the next render.
@external(javascript, "./savoiardi.ffi.mjs", "setAttributeNeedsUpdate")
pub fn set_attribute_needs_update(
  attribute: BufferAttribute,
  needs_update: Bool,
) -> Nil

// ============================================================================
// TRANSFORM UTILITIES
// ============================================================================

/// Applies position, rotation (as quaternion), and scale to an object.
///
/// Like `apply_transform` but uses a Quaternion for rotation instead of Euler angles.
/// Quaternions avoid gimbal lock and interpolate smoothly.
///
/// ## Parameters
///
/// - `object` - The object to transform
/// - `position` - Position in world units
/// - `quaternion` - Rotation as Quaternion
/// - `scale` - Scale factors
@external(javascript, "./savoiardi.ffi.mjs", "applyTransformWithQuaternion")
pub fn apply_transform_with_quaternion(
  object object: Object3D,
  position position: Vec3(Float),
  quaternion quaternion: Quaternion,
  scale scale: Vec3(Float),
) -> Nil

/// Makes a camera look at a target position.
///
/// Wraps [Object3D.lookAt](https://threejs.org/docs/#api/en/core/Object3D.lookAt).
/// Rotates the camera so its -Z axis points at the target.
///
/// ## Parameters
///
/// - `camera` - The camera to rotate
/// - `target` - The world position to look at
@external(javascript, "./savoiardi.ffi.mjs", "applyCameraLookAt")
pub fn set_camera_look_at(
  camera camera: Camera,
  target target: Vec3(Float),
) -> Nil

/// Makes any Object3D look at a target position.
///
/// Wraps [Object3D.lookAt](https://threejs.org/docs/#api/en/core/Object3D.lookAt).
/// Rotates the object so its local -Z axis points at the target.
///
/// ## Parameters
///
/// - `object` - The object to rotate
/// - `target` - The world position to look at
@external(javascript, "./savoiardi.ffi.mjs", "objectLookAt")
pub fn object_look_at(
  object object: Object3D,
  target target: Vec3(Float),
) -> Nil

/// Sets shadow casting and receiving properties on an object.
///
/// For shadows to work, you need:
/// 1. A light with `cast_shadow: True`
/// 2. Objects with `cast_shadow: True`
/// 3. Objects with `receive_shadow: True`
/// 4. `renderer.shadowMap.enabled = true` (automatic in create_renderer)
///
/// ## Parameters
///
/// - `object` - The object to configure
/// - `cast_shadow` - Whether this object casts shadows
/// - `receive_shadow` - Whether this object receives shadows from other objects
@external(javascript, "./savoiardi.ffi.mjs", "setShadowProperties")
pub fn set_shadow_properties(
  object object: Object3D,
  cast_shadow cast_shadow: Bool,
  receive_shadow receive_shadow: Bool,
) -> Nil

// ============================================================================
// OBJECT3D UTILITIES
// ============================================================================

/// Removes all levels from a LOD object.
@external(javascript, "./savoiardi.ffi.mjs", "clearLODLevels")
pub fn clear_lod_levels(lod: LOD) -> Nil

/// Updates all instance transforms in an instanced mesh.
///
/// Efficient batch update for all instances. Each instance is specified as
/// a tuple of `#(position, rotation, scale)` where rotation is Euler angles.
///
/// ## Parameters
///
/// - `mesh` - The instanced mesh
/// - `instances` - List of transform tuples
@external(javascript, "./savoiardi.ffi.mjs", "updateInstancedMeshTransforms")
pub fn update_instanced_mesh_transforms(
  mesh: InstancedMesh,
  instances: List(#(Vec3(Float), Vec3(Float), Vec3(Float))),
) -> Nil

/// Updates all instanced meshes within a group with the same transforms.
///
/// Applies the same instance transforms to all InstancedMesh children in a group.
///
/// ## Parameters
///
/// - `group` - The group containing instanced meshes
/// - `instances` - List of transform tuples (position, rotation, scale)
@external(javascript, "./savoiardi.ffi.mjs", "updateGroupInstancedMeshes")
pub fn update_group_instanced_meshes(
  group: Object3D,
  instances: List(#(Vec3(Float), Vec3(Float), Vec3(Float))),
) -> Nil

/// Updates the camera's projection matrix.
///
/// See [PerspectiveCamera](https://threejs.org/docs/#api/en/cameras/PerspectiveCamera) or
/// [OrthographicCamera](https://threejs.org/docs/#api/en/cameras/OrthographicCamera).
/// Call this after changing camera parameters (fov, aspect, near, far, etc.).
@external(javascript, "./savoiardi.ffi.mjs", "updateCameraProjectionMatrix")
pub fn update_camera_projection_matrix(camera: Camera) -> Nil

/// Sets all parameters of a perspective camera.
///
/// Updates fov, aspect, near, and far planes. Call `update_camera_projection_matrix`
/// afterward to apply the changes.
@external(javascript, "./savoiardi.ffi.mjs", "setPerspectiveCameraParams")
pub fn set_perspective_camera_params(
  camera: Camera,
  fov: Float,
  aspect: Float,
  near: Float,
  far: Float,
) -> Nil

/// Sets all parameters of an orthographic camera.
///
/// Updates left, right, top, bottom, near, and far planes. Call
/// `update_camera_projection_matrix` afterward to apply the changes.
@external(javascript, "./savoiardi.ffi.mjs", "setOrthographicCameraParams")
pub fn set_orthographic_camera_params(
  camera: Camera,
  left: Float,
  right: Float,
  top: Float,
  bottom: Float,
  near: Float,
  far: Float,
) -> Nil

/// Gets the geometry from a mesh.
///
/// Accesses [Mesh.geometry](https://threejs.org/docs/#api/en/objects/Mesh.geometry).
@external(javascript, "./savoiardi.ffi.mjs", "getObjectGeometry")
pub fn get_object_geometry(object: Object3D) -> Geometry

/// Gets the material from a mesh.
///
/// Accesses [Mesh.material](https://threejs.org/docs/#api/en/objects/Mesh.material).
@external(javascript, "./savoiardi.ffi.mjs", "getObjectMaterial")
pub fn get_object_material(object: Object3D) -> Material

/// Sets the geometry of a mesh.
///
/// Replaces the mesh's geometry. The old geometry is not automatically disposed.
@external(javascript, "./savoiardi.ffi.mjs", "setObjectGeometry")
pub fn set_object_geometry(object: Object3D, geometry: Geometry) -> Nil

/// Sets the material of a mesh.
///
/// Replaces the mesh's material. The old material is not automatically disposed.
@external(javascript, "./savoiardi.ffi.mjs", "setObjectMaterial")
pub fn set_object_material(object: Object3D, material: Material) -> Nil

/// Gets the object's local position.
///
/// Accesses [Object3D.position](https://threejs.org/docs/#api/en/core/Object3D.position).
@external(javascript, "./savoiardi.ffi.mjs", "getObjectPosition")
pub fn get_object_position(object: Object3D) -> Vec3(Float)

/// Gets the object's local rotation as Euler angles.
///
/// Accesses [Object3D.rotation](https://threejs.org/docs/#api/en/core/Object3D.rotation).
@external(javascript, "./savoiardi.ffi.mjs", "getObjectRotation")
pub fn get_object_rotation(object: Object3D) -> Vec3(Float)

/// Gets the object's local scale.
///
/// Accesses [Object3D.scale](https://threejs.org/docs/#api/en/core/Object3D.scale).
@external(javascript, "./savoiardi.ffi.mjs", "getObjectScale")
pub fn get_object_scale(object: Object3D) -> Vec3(Float)

/// Gets the object's local rotation as a quaternion.
///
/// Accesses [Object3D.quaternion](https://threejs.org/docs/#api/en/core/Object3D.quaternion).
@external(javascript, "./savoiardi.ffi.mjs", "getObjectQuaternion")
pub fn get_object_quaternion(object: Object3D) -> Quaternion

/// Sets the object's rotation using a quaternion.
///
/// Sets [Object3D.quaternion](https://threejs.org/docs/#api/en/core/Object3D.quaternion).
/// Quaternions avoid gimbal lock and interpolate smoothly.
@external(javascript, "./savoiardi.ffi.mjs", "setObjectQuaternion")
pub fn set_object_quaternion(object: Object3D, quaternion: Quaternion) -> Nil

/// Enables transparency on all materials in an object hierarchy.
///
/// Traverses the object and all children, setting `transparent: true` on all materials.
@external(javascript, "./savoiardi.ffi.mjs", "enableTransparency")
pub fn enable_transparency(object: Object3D) -> Nil

/// Enables shadow casting and receiving on all meshes in an object hierarchy.
///
/// Traverses the object and all children, setting `castShadow` and `receiveShadow`.
@external(javascript, "./savoiardi.ffi.mjs", "enableShadows")
pub fn enable_shadows(
  object: Object3D,
  cast_shadow: Bool,
  receive_shadow: Bool,
) -> Nil

/// Applies a material to all meshes in an object hierarchy.
///
/// Traverses the object and all children, replacing their materials.
@external(javascript, "./savoiardi.ffi.mjs", "applyMaterialToObject")
pub fn apply_material_to_object(object: Object3D, material: Material) -> Nil

/// Applies a texture to all materials in an object hierarchy.
///
/// Traverses the object and sets the texture as the `map` property on all materials.
///
/// ## Parameters
///
/// - `object` - The object hierarchy
/// - `texture` - The texture to apply
/// - `filter_mode` - NearestFilter for pixel art, LinearFilter for smooth textures
///
/// ## Example
///
/// ```gleam
/// // Apply pixel-art texture
/// apply_texture_to_object(floor_model, dungeon_texture, NearestFilter)
/// ```
pub fn apply_texture_to_object(
  object: Object3D,
  texture: Texture,
  filter_mode: FilterMode,
) -> Nil {
  apply_texture_to_object_internal(
    object,
    texture,
    filter_mode_to_int(filter_mode),
  )
}

@external(javascript, "./savoiardi.ffi.mjs", "applyTextureToObject")
fn apply_texture_to_object_internal(
  object: Object3D,
  texture: Texture,
  filter_mode: Int,
) -> Nil

// ============================================================================
// RESOURCE DISPOSAL
// ============================================================================

/// Disposes of a texture and frees GPU memory.
///
/// Wraps [Texture.dispose](https://threejs.org/docs/#api/en/textures/Texture.dispose).
/// Call when a texture is no longer needed to prevent memory leaks.
@external(javascript, "./savoiardi.ffi.mjs", "disposeTexture")
pub fn dispose_texture(texture: Texture) -> Nil

/// Disposes of a geometry and frees GPU memory.
///
/// Wraps [BufferGeometry.dispose](https://threejs.org/docs/#api/en/core/BufferGeometry.dispose).
/// Call when geometry is no longer needed.
@external(javascript, "./savoiardi.ffi.mjs", "disposeGeometry")
pub fn dispose_geometry(geometry: Geometry) -> Nil

/// Disposes of a material and frees GPU memory.
///
/// Wraps [Material.dispose](https://threejs.org/docs/#api/en/materials/Material.dispose).
/// Note: This does not dispose textures used by the material.
@external(javascript, "./savoiardi.ffi.mjs", "disposeMaterial")
pub fn dispose_material(material: Material) -> Nil

// ============================================================================
// CSS2D RENDERER
// ============================================================================

/// Creates a [CSS2DRenderer](https://threejs.org/docs/#examples/en/renderers/CSS2DRenderer).
///
/// CSS2D renders DOM elements in 3D space, always facing the camera.
/// Use for labels, health bars, tooltips, and UI elements attached to 3D objects.
@external(javascript, "./savoiardi.ffi.mjs", "createCSS2DRenderer")
pub fn create_css2d_renderer() -> CSS2DRenderer

/// Sets the size of a CSS2DRenderer.
///
/// Should match the WebGL renderer size.
@external(javascript, "./savoiardi.ffi.mjs", "setCSS2DRendererSize")
pub fn set_css2d_renderer_size(
  renderer: CSS2DRenderer,
  width: Int,
  height: Int,
) -> Nil

/// Gets the DOM element of a CSS2DRenderer.
///
/// The DOM element should be positioned over the WebGL canvas.
@external(javascript, "./savoiardi.ffi.mjs", "getCSS2DRendererDomElement")
pub fn get_css2d_renderer_dom_element(renderer: CSS2DRenderer) -> DomElement

/// Renders CSS2D objects in the scene.
///
/// Call this after `render()` in your render loop.
@external(javascript, "./savoiardi.ffi.mjs", "renderCSS2D")
pub fn render_css2d(
  renderer: CSS2DRenderer,
  scene: Scene,
  camera: Camera,
) -> Nil

// ============================================================================
// CSS3D RENDERER
// ============================================================================

/// Creates a [CSS3DRenderer](https://threejs.org/docs/#examples/en/renderers/CSS3DRenderer).
///
/// CSS3D renders DOM elements as full 3D objects that can be rotated and transformed.
/// Unlike CSS2D, CSS3D elements exist in true 3D space with depth and occlusion.
@external(javascript, "./savoiardi.ffi.mjs", "createCSS3DRenderer")
pub fn create_css3d_renderer() -> CSS3DRenderer

/// Sets the size of a CSS3DRenderer.
///
/// Should match the WebGL renderer size.
@external(javascript, "./savoiardi.ffi.mjs", "setCSS3DRendererSize")
pub fn set_css3d_renderer_size(
  renderer: CSS3DRenderer,
  width: Int,
  height: Int,
) -> Nil

/// Gets the DOM element of a CSS3DRenderer.
///
/// The DOM element should be positioned over the WebGL canvas.
@external(javascript, "./savoiardi.ffi.mjs", "getCSS3DRendererDomElement")
pub fn get_css3d_renderer_dom_element(renderer: CSS3DRenderer) -> DomElement

/// Renders CSS3D objects in the scene.
///
/// Call this after `render()` in your render loop.
@external(javascript, "./savoiardi.ffi.mjs", "renderCSS3D")
pub fn render_css3d(
  renderer: CSS3DRenderer,
  scene: Scene,
  camera: Camera,
) -> Nil

/// Creates a [CSS2DObject](https://threejs.org/docs/#examples/en/renderers/CSS2DRenderer) from HTML.
///
/// The HTML string is parsed and wrapped in a CSS2DObject that can be
/// positioned in 3D space.
///
/// ## Parameters
///
/// - `html` - HTML string for the label content
@external(javascript, "./savoiardi.ffi.mjs", "createCSS2DObject")
pub fn create_css2d_object(html: String) -> CSS2DObject

/// Updates the HTML content of a CSS2DObject.
///
/// ## Parameters
///
/// - `object` - The CSS2DObject to update
/// - `html` - New HTML content
@external(javascript, "./savoiardi.ffi.mjs", "updateCSS2DObjectHTML")
pub fn update_css2d_object_html(object: CSS2DObject, html: String) -> Nil

/// Creates a [CSS3DObject](https://threejs.org/docs/#examples/en/renderers/CSS3DRenderer) from HTML.
///
/// Unlike CSS2DObject, CSS3DObject exists in full 3D space and can be
/// rotated and scaled like any other 3D object.
@external(javascript, "./savoiardi.ffi.mjs", "createCSS3DObject")
pub fn create_css3d_object(html: String) -> CSS3DObject

/// Updates the HTML content of a CSS3DObject.
@external(javascript, "./savoiardi.ffi.mjs", "updateCSS3DObjectHTML")
pub fn update_css3d_object_html(object: CSS3DObject, html: String) -> Nil

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/// Gets diagnostic information about the WebGL renderer.
///
/// Returns information about the WebGL context including:
/// - Memory usage (geometries, textures)
/// - Render statistics (draw calls, triangles, points, lines)
/// - WebGL capabilities and limits
///
/// Useful for debugging performance issues and monitoring resource usage.
///
/// See: [WebGLRenderer.info](https://threejs.org/docs/#api/en/renderers/WebGLRenderer.info)
///
/// ## Example
///
/// ```gleam
/// let info = get_renderer_info(renderer)
/// // Access render statistics for profiling
/// ```
///
/// ## Notes
///
/// - The returned object structure depends on Three.js version
/// - Memory stats include counts of geometries and textures in GPU memory
/// - Render stats are reset each frame by default
/// - Call `info.reset()` in JavaScript to manually reset stats
///
@external(javascript, "./savoiardi.ffi.mjs", "getRendererInfo")
pub fn get_renderer_info(renderer: Renderer) -> RendererInfo

/// Checks if the WebGL context is still valid and usable.
///
/// The WebGL context can be lost due to:
/// - GPU driver crashes or resets
/// - Too many active WebGL contexts
/// - System resource pressure
/// - Device sleep/wake cycles
///
/// See: [WebGLRenderer](https://threejs.org/docs/#api/en/renderers/WebGLRenderer)
///
/// ## Example
///
/// ```gleam
/// case is_context_valid(renderer) {
///   True -> render(renderer, scene, camera)
///   False -> {
///     // Handle context loss - may need to recreate renderer
///     io.println("WebGL context lost!")
///   }
/// }
/// ```
///
/// ## Notes
///
/// - Returns `False` if context was lost and not yet restored
/// - Listen for `webglcontextlost` and `webglcontextrestored` events
/// - When context is lost, all textures and buffers are invalidated
/// - May need to recreate resources after context restoration
///
@external(javascript, "./savoiardi.ffi.mjs", "isContextValid")
pub fn is_context_valid(renderer: Renderer) -> Bool

// ============================================================================
// ASSET LOADING
// ============================================================================

/// Loads a texture image from a URL asynchronously.
///
/// Supports common image formats: PNG, JPG, GIF, BMP, WebP.
/// The texture is automatically uploaded to GPU memory when used.
///
/// See: [TextureLoader](https://threejs.org/docs/#api/en/loaders/TextureLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the image file
///
/// ## Example
///
/// ```gleam
/// use texture <- promise.await(load_texture("/textures/brick.jpg"))
/// case texture {
///   Ok(tex) -> {
///     let material = create_basic_material(0xffffff, False, 1.0, option.Some(tex))
///     // Use material...
///   }
///   Error(Nil) -> io.println("Failed to load texture")
/// }
/// ```
///
/// ## Notes
///
/// - Loading is asynchronous - texture may not be immediately available
/// - Large textures impact memory; consider power-of-two dimensions
/// - Set texture filtering and wrapping after loading if needed
/// - CORS restrictions apply for cross-origin URLs
/// - Consider using compressed textures (KTX2) for better performance
///
@external(javascript, "./savoiardi.ffi.mjs", "loadTexture")
pub fn load_texture(url: String) -> Promise(Result(Texture, Nil))

/// Loads an audio file from a URL into an AudioBuffer.
///
/// The AudioBuffer can be used with both global Audio and PositionalAudio.
/// Supports common formats: MP3, OGG, WAV, AAC (browser-dependent).
///
/// See: [AudioLoader](https://threejs.org/docs/#api/en/loaders/AudioLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the audio file
///
/// ## Example
///
/// ```gleam
/// use buffer <- promise.await(load_audio("/sounds/explosion.mp3"))
/// case buffer {
///   Ok(audio_buffer) -> {
///     set_audio_buffer(sound, audio_buffer)
///     play_audio(sound)
///   }
///   Error(Nil) -> io.println("Failed to load audio")
/// }
/// ```
///
/// ## Notes
///
/// - Audio must be triggered by user interaction (browser autoplay policy)
/// - Decoded audio is stored in memory - large files consume RAM
/// - MP3 has best browser support; OGG better for looping
/// - WAV files are larger but have no decoding overhead
/// - Consider using compressed formats for music, WAV for short effects
///
@external(javascript, "./savoiardi.ffi.mjs", "loadAudio")
pub fn load_audio(url: String) -> Promise(Result(AudioBuffer, Nil))

/// Loads an STL (stereolithography) model from a URL.
///
/// STL is common for 3D printing and CAD applications. Returns only
/// geometry data - you'll need to create a material and mesh.
///
/// See: [STLLoader](https://threejs.org/docs/#examples/en/loaders/STLLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the .stl file
///
/// ## Example
///
/// ```gleam
/// use geometry <- promise.await(load_stl("/models/part.stl"))
/// case geometry {
///   Ok(geo) -> {
///     let material = create_standard_material(0x888888, 0.5, 0.5, option.None)
///     let mesh = create_mesh(geo, material)
///     add_to_scene(scene, mesh)
///   }
///   Error(Nil) -> io.println("Failed to load STL")
/// }
/// ```
///
/// ## Notes
///
/// - STL contains only geometry, no materials or colors
/// - Both ASCII and binary STL formats are supported
/// - Binary STL is more compact and loads faster
/// - STL has no hierarchy - always returns a single geometry
/// - Consider computing vertex normals after loading for smooth shading
///
@external(javascript, "./savoiardi.ffi.mjs", "loadSTL")
pub fn load_stl(url: String) -> Promise(Result(Geometry, Nil))

/// Centers a geometry around its bounding box center.
///
/// This is useful for STL or OBJ models that need to rotate around their
/// geometric center rather than their original origin point.
///
/// Many CAD-exported models have their origin at an arbitrary location.
/// Call this function after loading to ensure the model rotates around
/// its visual center.
///
/// ## Example
///
/// ```gleam
/// use result <- promise.await(load_stl("/models/part.stl"))
/// case result {
///   Ok(geometry) -> {
///     // Center the geometry so it rotates around its middle
///     let centered = center_geometry(geometry)
///     let material = create_standard_material(0x888888, 0.5, 0.5, option.None)
///     let mesh = create_mesh(centered, material)
///   }
///   Error(Nil) -> io.println("Failed to load")
/// }
/// ```
///
/// ## Notes
///
/// - This mutates the geometry in place and returns it for convenience
/// - The geometry's vertices are translated so the bounding box center is at origin
/// - Useful for any geometry, not just STL files
///
@external(javascript, "./savoiardi.ffi.mjs", "centerGeometry")
pub fn center_geometry(geometry: Geometry) -> Geometry

/// Centers an Object3D around its bounding box center.
///
/// This computes the bounding box of all children and offsets them so the
/// object's local origin is at the geometric center. Useful for FBX/GLTF
/// models that have their origin at a corner instead of the center.
///
/// ## Example
///
/// ```gleam
/// use result <- promise.await(load_fbx("/models/floor.fbx"))
/// case result {
///   Ok(fbx) -> {
///     // Center the model so it's at origin
///     let centered = center_object(fbx)
///   }
///   Error(Nil) -> io.println("Failed to load")
/// }
/// ```
///
/// ## Notes
///
/// - This mutates the object in place and returns it for convenience
/// - The children's positions are adjusted so the bounding box center is at origin
///
@external(javascript, "./savoiardi.ffi.mjs", "centerObject3D")
pub fn center_object(object: Object3D) -> Object3D

/// Loads a GLTF or GLB model from a URL.
///
/// GLTF is the recommended format for web 3D - it's efficient, well-supported,
/// and includes materials, animations, and scene hierarchy.
///
/// See: [GLTFLoader](https://threejs.org/docs/#examples/en/loaders/GLTFLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the .gltf or .glb file
///
/// ## Example
///
/// ```gleam
/// use gltf <- promise.await(load_gltf("/models/character.glb"))
/// case gltf {
///   Ok(data) -> {
///     let model = get_gltf_scene(data)
///     add_to_scene(scene, model)
///
///     // If model has animations
///     let clips = get_gltf_animations(data)
///     let mixer = create_animation_mixer(model)
///     // Play animations...
///   }
///   Error(Nil) -> io.println("Failed to load GLTF")
/// }
/// ```
///
/// ## Notes
///
/// - GLB is binary GLTF - single file, faster to load
/// - GLTF may reference external textures and .bin files
/// - Materials are automatically converted to Three.js materials
/// - Animations are stored in `animations` array of GLTFData
/// - Use Draco compression for smaller file sizes (requires DRACOLoader)
/// - Consider KTX2 textures for GPU-compressed textures
///
@external(javascript, "./savoiardi.ffi.mjs", "loadGLTF")
pub fn load_gltf(url: String) -> Promise(Result(GLTFData, Nil))

/// Loads an OBJ model from a URL.
///
/// OBJ is a simple, widely-supported 3D format. It contains only
/// geometry and basic material references (via .mtl files).
///
/// See: [OBJLoader](https://threejs.org/docs/#examples/en/loaders/OBJLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the .obj file
///
/// ## Example
///
/// ```gleam
/// use model <- promise.await(load_obj("/models/furniture.obj"))
/// case model {
///   Ok(obj) -> {
///     add_to_scene(scene, obj)
///   }
///   Error(Nil) -> io.println("Failed to load OBJ")
/// }
/// ```
///
/// ## Notes
///
/// - OBJ files are text-based and can be large
/// - Materials require separate MTLLoader (not included here)
/// - No animation support in OBJ format
/// - Returns an Object3D that may contain multiple meshes
/// - Consider GLTF for better features and smaller files
///
@external(javascript, "./savoiardi.ffi.mjs", "loadOBJ")
pub fn load_obj(url: String) -> Promise(Result(Object3D, Nil))

/// Loads an FBX model from a URL.
///
/// FBX is common in game development and supports complex animations,
/// blend shapes, and skeletal rigs from tools like Maya and Blender.
///
/// See: [FBXLoader](https://threejs.org/docs/#examples/en/loaders/FBXLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the .fbx file
///
/// ## Example
///
/// ```gleam
/// use fbx <- promise.await(load_fbx("/models/animated_character.fbx"))
/// case fbx {
///   Ok(data) -> {
///     let model = get_fbx_scene(data)
///     add_to_scene(scene, model)
///
///     // Setup animation
///     let mixer = create_animation_mixer(model)
///     let clips = get_fbx_animations(data)
///     // Play animations...
///   }
///   Error(Nil) -> io.println("Failed to load FBX")
/// }
/// ```
///
/// ## Notes
///
/// - FBX files can be very large (binary format recommended)
/// - Supports skeletal animation, blend shapes, and morph targets
/// - Materials may need adjustment for web rendering
/// - Embedded textures are automatically extracted
/// - Consider converting to GLTF for better web performance
///
@external(javascript, "./savoiardi.ffi.mjs", "loadFBX")
pub fn load_fbx(url: String) -> Promise(Result(FBXData, Nil))

/// Loads a font file for use with TextGeometry.
///
/// Fonts must be in Three.js JSON format (converted from TTF/OTF).
/// Use tools like Facetype.js to convert standard fonts.
///
/// See: [FontLoader](https://threejs.org/docs/#examples/en/loaders/FontLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the JSON font file
///
/// ## Example
///
/// ```gleam
/// use font <- promise.await(load_font("/fonts/helvetiker_regular.typeface.json"))
/// case font {
///   Ok(f) -> {
///     let text_geo = create_text_geometry("Hello!", f, 1.0, 0.2, 12, 1)
///     let material = create_basic_material(0xffffff, False, 1.0, option.None)
///     let text_mesh = create_mesh(text_geo, material)
///     add_to_scene(scene, text_mesh)
///   }
///   Error(Nil) -> io.println("Failed to load font")
/// }
/// ```
///
/// ## Notes
///
/// - Three.js includes helvetiker font in examples
/// - Convert fonts at: https://gero3.github.io/facetype.js/
/// - Only outline fonts work (no bitmap/raster fonts)
/// - Text geometry can have many triangles - use sparingly
/// - Consider CSS2DRenderer for 2D text overlays instead
///
@external(javascript, "./savoiardi.ffi.mjs", "loadFont")
pub fn load_font(url: String) -> Promise(Result(Font, Nil))

/// Loads an equirectangular (360°) texture for environment maps or skyboxes.
///
/// Equirectangular images are panoramic photos mapped to a sphere.
/// Commonly used for environment backgrounds and reflections.
///
/// See: [TextureLoader](https://threejs.org/docs/#api/en/loaders/TextureLoader)
///
/// ## Parameters
///
/// - `url`: Path or URL to the equirectangular image (PNG, JPG, WebP)
///
/// ## Example
///
/// ```gleam
/// use env_texture <- promise.await(load_equirectangular_texture("/env/studio.jpg"))
/// case env_texture {
///   Ok(tex) -> {
///     // Use as scene background
///     set_scene_background_texture(scene, tex)
///   }
///   Error(Nil) -> io.println("Failed to load environment")
/// }
/// ```
///
/// ## Notes
///
/// - Supports standard image formats (PNG, JPG, WebP)
/// - Large panoramas impact memory and load time
/// - Consider pre-processed cubemaps for better performance
///
@external(javascript, "./savoiardi.ffi.mjs", "loadEquirectangularTexture")
pub fn load_equirectangular_texture(
  url: String,
) -> Promise(Result(Texture, Nil))

/// Loads a cube texture (skybox) from 6 image URLs.
///
/// Cube textures use 6 images representing the faces of a cube:
/// positive X, negative X, positive Y, negative Y, positive Z, negative Z.
///
/// See: [CubeTextureLoader](https://threejs.org/docs/#api/en/loaders/CubeTextureLoader)
///
/// ## Parameters
///
/// - `urls`: List of 6 URLs in order: [+X, -X, +Y, -Y, +Z, -Z]
///
/// ## Example
///
/// ```gleam
/// let skybox_urls = [
///   "/skybox/px.jpg",  // positive X (right)
///   "/skybox/nx.jpg",  // negative X (left)
///   "/skybox/py.jpg",  // positive Y (top)
///   "/skybox/ny.jpg",  // negative Y (bottom)
///   "/skybox/pz.jpg",  // positive Z (front)
///   "/skybox/nz.jpg",  // negative Z (back)
/// ]
///
/// use cube_tex <- promise.await(load_cube_texture(skybox_urls))
/// case cube_tex {
///   Ok(tex) -> set_scene_background_cube_texture(scene, tex)
///   Error(Nil) -> io.println("Failed to load skybox")
/// }
/// ```
///
/// ## Notes
///
/// - All 6 images must be the same size and square
/// - Power-of-two dimensions recommended (512, 1024, 2048)
/// - More efficient than equirectangular for real-time skyboxes
/// - Can also be used for reflection/environment mapping
/// - Consider compressed textures for large skyboxes
///
@external(javascript, "./savoiardi.ffi.mjs", "loadCubeTexture")
pub fn load_cube_texture(
  urls: List(String),
) -> Promise(Result(CubeTexture, Nil))

// ============================================================================
// POSITIONAL AUDIO OPERATIONS
// ============================================================================

/// Sets the audio buffer for a positional audio source.
///
/// The buffer contains the decoded audio data to play. Must be set
/// before playing the audio.
///
/// See: [PositionalAudio.setBuffer](https://threejs.org/docs/#api/en/audio/PositionalAudio.setBuffer)
///
/// ## Parameters
///
/// - `audio`: The positional audio source
/// - `buffer`: Decoded audio buffer from `load_audio`
///
/// ## Example
///
/// ```gleam
/// use buffer <- promise.await(load_audio("/sounds/engine.mp3"))
/// case buffer {
///   Ok(audio_buffer) -> {
///     set_positional_audio_buffer(car_sound, audio_buffer)
///     set_positional_audio_loop(car_sound, True)
///     play_positional_audio(car_sound)
///   }
///   Error(Nil) -> Nil
/// }
/// ```
///
/// ## Notes
///
/// - Buffer must be set before calling play
/// - Same buffer can be shared between multiple audio sources
/// - Buffer stays in memory until explicitly released
///
@external(javascript, "./savoiardi.ffi.mjs", "setAudioBuffer")
pub fn set_positional_audio_buffer(
  audio: PositionalAudio,
  buffer: AudioBuffer,
) -> Nil

/// Sets the volume for a positional audio source.
///
/// Volume is a multiplier for the audio output. This is the base volume
/// before distance attenuation is applied.
///
/// See: [PositionalAudio.setVolume](https://threejs.org/docs/#api/en/audio/PositionalAudio.setVolume)
///
/// ## Parameters
///
/// - `audio`: The positional audio source
/// - `volume`: Volume level (0.0 = silent, 1.0 = full volume)
///
/// ## Example
///
/// ```gleam
/// // Set ambient sound to half volume
/// set_positional_audio_volume(forest_ambience, 0.5)
///
/// // Mute temporarily
/// set_positional_audio_volume(music, 0.0)
/// ```
///
/// ## Notes
///
/// - Values above 1.0 amplify the sound (may cause clipping)
/// - Actual heard volume also depends on listener distance
/// - Use fade functions for smooth volume transitions
///
@external(javascript, "./savoiardi.ffi.mjs", "setAudioVolume")
pub fn set_positional_audio_volume(audio: PositionalAudio, volume: Float) -> Nil

/// Enables or disables looping for a positional audio source.
///
/// When enabled, the audio will restart from the beginning when it
/// reaches the end.
///
/// See: [PositionalAudio.setLoop](https://threejs.org/docs/#api/en/audio/PositionalAudio.setLoop)
///
/// ## Parameters
///
/// - `audio`: The positional audio source
/// - `loop`: `True` to enable looping, `False` for one-shot playback
///
/// ## Example
///
/// ```gleam
/// // Background music should loop
/// set_positional_audio_loop(music, True)
///
/// // Sound effects play once
/// set_positional_audio_loop(explosion_sound, False)
/// ```
///
/// ## Notes
///
/// - Can be changed while audio is playing
/// - OGG format handles looping better than MP3 (no gaps)
/// - For seamless loops, ensure audio file is properly trimmed
///
@external(javascript, "./savoiardi.ffi.mjs", "setAudioLoop")
pub fn set_positional_audio_loop(audio: PositionalAudio, loop: Bool) -> Nil

/// Sets the playback rate for a positional audio source.
///
/// Changes both the speed and pitch of the audio playback.
///
/// See: [PositionalAudio.setPlaybackRate](https://threejs.org/docs/#api/en/audio/PositionalAudio.setPlaybackRate)
///
/// ## Parameters
///
/// - `audio`: The positional audio source
/// - `rate`: Playback speed (1.0 = normal, 2.0 = double speed, 0.5 = half speed)
///
/// ## Example
///
/// ```gleam
/// // Simulate engine revving up
/// set_positional_audio_playback_rate(engine_sound, 1.5)
///
/// // Slow motion effect
/// set_positional_audio_playback_rate(sound, 0.5)
/// ```
///
/// ## Notes
///
/// - Changes pitch proportionally (higher rate = higher pitch)
/// - Values below 0.5 or above 4.0 may sound unnatural
/// - Good for simulating Doppler effect or engine RPM
/// - Can be changed while audio is playing for dynamic effects
///
@external(javascript, "./savoiardi.ffi.mjs", "setAudioPlaybackRate")
pub fn set_positional_audio_playback_rate(
  audio: PositionalAudio,
  rate: Float,
) -> Nil

/// Starts playback of a positional audio source.
///
/// If the audio was paused, resumes from the paused position.
/// If stopped, starts from the beginning.
///
/// See: [PositionalAudio.play](https://threejs.org/docs/#api/en/audio/PositionalAudio.play)
///
/// ## Parameters
///
/// - `audio`: The positional audio source to play
///
/// ## Example
///
/// ```gleam
/// // Start playing after buffer is loaded
/// case has_positional_audio_buffer(sound) {
///   True -> play_positional_audio(sound)
///   False -> io.println("Buffer not loaded yet")
/// }
/// ```
///
/// ## Notes
///
/// - Requires user interaction first (browser autoplay policy)
/// - Buffer must be set before calling play
/// - Calling play on already playing audio restarts it
/// - Use `is_positional_audio_playing` to check state first
///
@external(javascript, "./savoiardi.ffi.mjs", "playAudio")
pub fn play_positional_audio(audio: PositionalAudio) -> Nil

/// Pauses playback of a positional audio source.
///
/// The playback position is preserved and can be resumed with play.
///
/// See: [PositionalAudio.pause](https://threejs.org/docs/#api/en/audio/PositionalAudio.pause)
///
/// ## Parameters
///
/// - `audio`: The positional audio source to pause
///
/// ## Example
///
/// ```gleam
/// // Pause when game is paused
/// pause_positional_audio(background_music)
///
/// // Resume when game continues
/// play_positional_audio(background_music)
/// ```
///
/// ## Notes
///
/// - Preserves playback position
/// - Has no effect if audio is not playing
/// - Better than stop for temporary pauses
///
@external(javascript, "./savoiardi.ffi.mjs", "pauseAudio")
pub fn pause_positional_audio(audio: PositionalAudio) -> Nil

/// Stops playback of a positional audio source.
///
/// Resets the playback position to the beginning.
///
/// See: [PositionalAudio.stop](https://threejs.org/docs/#api/en/audio/PositionalAudio.stop)
///
/// ## Parameters
///
/// - `audio`: The positional audio source to stop
///
/// ## Example
///
/// ```gleam
/// // Stop sound effect
/// stop_positional_audio(explosion_sound)
///
/// // Play again from start
/// play_positional_audio(explosion_sound)
/// ```
///
/// ## Notes
///
/// - Resets position to beginning (unlike pause)
/// - Has no effect if audio is not playing
/// - Use for one-shot sounds or complete restarts
///
@external(javascript, "./savoiardi.ffi.mjs", "stopAudio")
pub fn stop_positional_audio(audio: PositionalAudio) -> Nil

/// Checks if a positional audio source is currently playing.
///
/// See: [PositionalAudio.isPlaying](https://threejs.org/docs/#api/en/audio/PositionalAudio.isPlaying)
///
/// ## Parameters
///
/// - `audio`: The positional audio source to check
///
/// ## Returns
///
/// `True` if the audio is currently playing, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// case is_positional_audio_playing(music) {
///   True -> pause_positional_audio(music)
///   False -> play_positional_audio(music)
/// }
/// ```
///
@external(javascript, "./savoiardi.ffi.mjs", "isAudioPlaying")
pub fn is_positional_audio_playing(audio: PositionalAudio) -> Bool

/// Checks if a positional audio source has a buffer loaded.
///
/// Useful to verify audio is ready before attempting playback.
///
/// See: [PositionalAudio.buffer](https://threejs.org/docs/#api/en/audio/PositionalAudio)
///
/// ## Parameters
///
/// - `audio`: The positional audio source to check
///
/// ## Returns
///
/// `True` if a buffer has been set, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// // Only play if buffer is ready
/// case has_positional_audio_buffer(sound) {
///   True -> play_positional_audio(sound)
///   False -> {
///     // Buffer still loading, queue for later
///     io.println("Audio not ready")
///   }
/// }
/// ```
///
@external(javascript, "./savoiardi.ffi.mjs", "hasAudioBuffer")
pub fn has_positional_audio_buffer(audio: PositionalAudio) -> Bool

/// Gets the loop state of a positional audio source.
///
/// See: [PositionalAudio.loop](https://threejs.org/docs/#api/en/audio/PositionalAudio)
///
/// ## Parameters
///
/// - `audio`: The positional audio source to check
///
/// ## Returns
///
/// `True` if looping is enabled, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// // Toggle loop state
/// let current_loop = get_positional_audio_loop(music)
/// set_positional_audio_loop(music, !current_loop)
/// ```
///
@external(javascript, "./savoiardi.ffi.mjs", "getAudioLoop")
pub fn get_positional_audio_loop(audio: PositionalAudio) -> Bool
