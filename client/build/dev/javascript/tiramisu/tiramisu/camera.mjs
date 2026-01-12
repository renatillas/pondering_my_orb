import * as $bool from "../../gleam_stdlib/gleam/bool.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $vec2 from "../../vec/vec/vec2.mjs";
import { Ok, Error, toList, CustomType as $CustomType } from "../gleam.mjs";

class Camera extends $CustomType {
  constructor(projection) {
    super();
    this.projection = projection;
  }
}

export class Perspective extends $CustomType {
  constructor(fov, aspect, near, far) {
    super();
    this.fov = fov;
    this.aspect = aspect;
    this.near = near;
    this.far = far;
  }
}
export const CameraProjection$Perspective = (fov, aspect, near, far) =>
  new Perspective(fov, aspect, near, far);
export const CameraProjection$isPerspective = (value) =>
  value instanceof Perspective;
export const CameraProjection$Perspective$fov = (value) => value.fov;
export const CameraProjection$Perspective$0 = (value) => value.fov;
export const CameraProjection$Perspective$aspect = (value) => value.aspect;
export const CameraProjection$Perspective$1 = (value) => value.aspect;
export const CameraProjection$Perspective$near = (value) => value.near;
export const CameraProjection$Perspective$2 = (value) => value.near;
export const CameraProjection$Perspective$far = (value) => value.far;
export const CameraProjection$Perspective$3 = (value) => value.far;

export class Orthographic extends $CustomType {
  constructor(left, right, top, bottom, near, far) {
    super();
    this.left = left;
    this.right = right;
    this.top = top;
    this.bottom = bottom;
    this.near = near;
    this.far = far;
  }
}
export const CameraProjection$Orthographic = (left, right, top, bottom, near, far) =>
  new Orthographic(left, right, top, bottom, near, far);
export const CameraProjection$isOrthographic = (value) =>
  value instanceof Orthographic;
export const CameraProjection$Orthographic$left = (value) => value.left;
export const CameraProjection$Orthographic$0 = (value) => value.left;
export const CameraProjection$Orthographic$right = (value) => value.right;
export const CameraProjection$Orthographic$1 = (value) => value.right;
export const CameraProjection$Orthographic$top = (value) => value.top;
export const CameraProjection$Orthographic$2 = (value) => value.top;
export const CameraProjection$Orthographic$bottom = (value) => value.bottom;
export const CameraProjection$Orthographic$3 = (value) => value.bottom;
export const CameraProjection$Orthographic$near = (value) => value.near;
export const CameraProjection$Orthographic$4 = (value) => value.near;
export const CameraProjection$Orthographic$far = (value) => value.far;
export const CameraProjection$Orthographic$5 = (value) => value.far;

/**
 * Field of view must be between 0 and 180 degrees
 */
export class InvalidFieldOfView extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const CameraError$InvalidFieldOfView = ($0) =>
  new InvalidFieldOfView($0);
export const CameraError$isInvalidFieldOfView = (value) =>
  value instanceof InvalidFieldOfView;
export const CameraError$InvalidFieldOfView$0 = (value) => value[0];

/**
 * Aspect ratio must be positive
 */
export class InvalidAspectRatio extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const CameraError$InvalidAspectRatio = ($0) =>
  new InvalidAspectRatio($0);
export const CameraError$isInvalidAspectRatio = (value) =>
  value instanceof InvalidAspectRatio;
export const CameraError$InvalidAspectRatio$0 = (value) => value[0];

/**
 * Near plane must be positive
 */
export class InvalidNearPlane extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const CameraError$InvalidNearPlane = ($0) => new InvalidNearPlane($0);
export const CameraError$isInvalidNearPlane = (value) =>
  value instanceof InvalidNearPlane;
export const CameraError$InvalidNearPlane$0 = (value) => value[0];

/**
 * Far plane must be positive
 */
export class InvalidFarPlane extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const CameraError$InvalidFarPlane = ($0) => new InvalidFarPlane($0);
export const CameraError$isInvalidFarPlane = (value) =>
  value instanceof InvalidFarPlane;
export const CameraError$InvalidFarPlane$0 = (value) => value[0];

/**
 * Near plane must be less than far plane
 */
export class NearFarConflict extends $CustomType {
  constructor(near, far) {
    super();
    this.near = near;
    this.far = far;
  }
}
export const CameraError$NearFarConflict = (near, far) =>
  new NearFarConflict(near, far);
export const CameraError$isNearFarConflict = (value) =>
  value instanceof NearFarConflict;
export const CameraError$NearFarConflict$near = (value) => value.near;
export const CameraError$NearFarConflict$0 = (value) => value.near;
export const CameraError$NearFarConflict$far = (value) => value.far;
export const CameraError$NearFarConflict$1 = (value) => value.far;

export class ViewPort extends $CustomType {
  constructor(position, size) {
    super();
    this.position = position;
    this.size = size;
  }
}
export const ViewPort$ViewPort = (position, size) =>
  new ViewPort(position, size);
export const ViewPort$isViewPort = (value) => value instanceof ViewPort;
export const ViewPort$ViewPort$position = (value) => value.position;
export const ViewPort$ViewPort$0 = (value) => value.position;
export const ViewPort$ViewPort$size = (value) => value.size;
export const ViewPort$ViewPort$1 = (value) => value.size;

class PostProcessing extends $CustomType {
  constructor(passes) {
    super();
    this.passes = passes;
  }
}

export class RenderPass extends $CustomType {}
export const Pass$RenderPass = () => new RenderPass();
export const Pass$isRenderPass = (value) => value instanceof RenderPass;

/**
 * Clear pass - clears the render target with a color.
 *
 * Use this before RenderPass to make scene backgrounds work correctly.
 * The color parameter overrides the scene background if provided.
 *
 * - `None`: Uses the scene's background color
 * - `Some(color)`: Uses the specified hex color
 */
export class ClearPass extends $CustomType {
  constructor(color) {
    super();
    this.color = color;
  }
}
export const Pass$ClearPass = (color) => new ClearPass(color);
export const Pass$isClearPass = (value) => value instanceof ClearPass;
export const Pass$ClearPass$color = (value) => value.color;
export const Pass$ClearPass$0 = (value) => value.color;

export class OutputPass extends $CustomType {}
export const Pass$OutputPass = () => new OutputPass();
export const Pass$isOutputPass = (value) => value instanceof OutputPass;

/**
 * Pixelation effect with optional edge detection.
 *
 * Creates a retro pixel-art aesthetic by reducing the resolution of the image.
 * Edge detection can add outlines based on surface normals and depth.
 */
export class PixelatePass extends $CustomType {
  constructor(pixel_size, normal_edge_strength, depth_edge_strength) {
    super();
    this.pixel_size = pixel_size;
    this.normal_edge_strength = normal_edge_strength;
    this.depth_edge_strength = depth_edge_strength;
  }
}
export const Pass$PixelatePass = (pixel_size, normal_edge_strength, depth_edge_strength) =>
  new PixelatePass(pixel_size, normal_edge_strength, depth_edge_strength);
export const Pass$isPixelatePass = (value) => value instanceof PixelatePass;
export const Pass$PixelatePass$pixel_size = (value) => value.pixel_size;
export const Pass$PixelatePass$0 = (value) => value.pixel_size;
export const Pass$PixelatePass$normal_edge_strength = (value) =>
  value.normal_edge_strength;
export const Pass$PixelatePass$1 = (value) => value.normal_edge_strength;
export const Pass$PixelatePass$depth_edge_strength = (value) =>
  value.depth_edge_strength;
export const Pass$PixelatePass$2 = (value) => value.depth_edge_strength;

/**
 * Bloom effect (glow for bright areas).
 *
 * Makes bright areas of the scene glow and bleed into surrounding pixels.
 * Great for emissive materials, lights, and sci-fi aesthetics.
 */
export class BloomPass extends $CustomType {
  constructor(strength, threshold, radius) {
    super();
    this.strength = strength;
    this.threshold = threshold;
    this.radius = radius;
  }
}
export const Pass$BloomPass = (strength, threshold, radius) =>
  new BloomPass(strength, threshold, radius);
export const Pass$isBloomPass = (value) => value instanceof BloomPass;
export const Pass$BloomPass$strength = (value) => value.strength;
export const Pass$BloomPass$0 = (value) => value.strength;
export const Pass$BloomPass$threshold = (value) => value.threshold;
export const Pass$BloomPass$1 = (value) => value.threshold;
export const Pass$BloomPass$radius = (value) => value.radius;
export const Pass$BloomPass$2 = (value) => value.radius;

/**
 * Film grain effect.
 *
 * Adds analog film texture with grain noise and optional scanlines.
 * Can create a retro or cinematic look.
 */
export class FilmPass extends $CustomType {
  constructor(noise_intensity, scanline_intensity, scanline_count, grayscale) {
    super();
    this.noise_intensity = noise_intensity;
    this.scanline_intensity = scanline_intensity;
    this.scanline_count = scanline_count;
    this.grayscale = grayscale;
  }
}
export const Pass$FilmPass = (noise_intensity, scanline_intensity, scanline_count, grayscale) =>
  new FilmPass(noise_intensity, scanline_intensity, scanline_count, grayscale);
export const Pass$isFilmPass = (value) => value instanceof FilmPass;
export const Pass$FilmPass$noise_intensity = (value) => value.noise_intensity;
export const Pass$FilmPass$0 = (value) => value.noise_intensity;
export const Pass$FilmPass$scanline_intensity = (value) =>
  value.scanline_intensity;
export const Pass$FilmPass$1 = (value) => value.scanline_intensity;
export const Pass$FilmPass$scanline_count = (value) => value.scanline_count;
export const Pass$FilmPass$2 = (value) => value.scanline_count;
export const Pass$FilmPass$grayscale = (value) => value.grayscale;
export const Pass$FilmPass$3 = (value) => value.grayscale;

/**
 * Vignette effect (darkened edges).
 *
 * Darkens the edges of the screen, focusing attention on the center.
 */
export class VignettePass extends $CustomType {
  constructor(darkness, offset) {
    super();
    this.darkness = darkness;
    this.offset = offset;
  }
}
export const Pass$VignettePass = (darkness, offset) =>
  new VignettePass(darkness, offset);
export const Pass$isVignettePass = (value) => value instanceof VignettePass;
export const Pass$VignettePass$darkness = (value) => value.darkness;
export const Pass$VignettePass$0 = (value) => value.darkness;
export const Pass$VignettePass$offset = (value) => value.offset;
export const Pass$VignettePass$1 = (value) => value.offset;

export class FXAAPass extends $CustomType {}
export const Pass$FXAAPass = () => new FXAAPass();
export const Pass$isFXAAPass = (value) => value instanceof FXAAPass;

/**
 * Glitch effect.
 *
 * Creates digital corruption artifacts with RGB channel offsets.
 * Great for cyberpunk or error state aesthetics.
 */
export class GlitchPass extends $CustomType {
  constructor(dt_size) {
    super();
    this.dt_size = dt_size;
  }
}
export const Pass$GlitchPass = (dt_size) => new GlitchPass(dt_size);
export const Pass$isGlitchPass = (value) => value instanceof GlitchPass;
export const Pass$GlitchPass$dt_size = (value) => value.dt_size;
export const Pass$GlitchPass$0 = (value) => value.dt_size;

/**
 * Color correction.
 *
 * Adjust brightness, contrast, and saturation of the final image.
 */
export class ColorCorrectionPass extends $CustomType {
  constructor(brightness, contrast, saturation) {
    super();
    this.brightness = brightness;
    this.contrast = contrast;
    this.saturation = saturation;
  }
}
export const Pass$ColorCorrectionPass = (brightness, contrast, saturation) =>
  new ColorCorrectionPass(brightness, contrast, saturation);
export const Pass$isColorCorrectionPass = (value) =>
  value instanceof ColorCorrectionPass;
export const Pass$ColorCorrectionPass$brightness = (value) => value.brightness;
export const Pass$ColorCorrectionPass$0 = (value) => value.brightness;
export const Pass$ColorCorrectionPass$contrast = (value) => value.contrast;
export const Pass$ColorCorrectionPass$1 = (value) => value.contrast;
export const Pass$ColorCorrectionPass$saturation = (value) => value.saturation;
export const Pass$ColorCorrectionPass$2 = (value) => value.saturation;

/**
 * Custom shader pass.
 *
 * Apply a custom GLSL shader for advanced effects.
 */
export class CustomShaderPass extends $CustomType {
  constructor(vertex_shader, fragment_shader, uniforms) {
    super();
    this.vertex_shader = vertex_shader;
    this.fragment_shader = fragment_shader;
    this.uniforms = uniforms;
  }
}
export const Pass$CustomShaderPass = (vertex_shader, fragment_shader, uniforms) =>
  new CustomShaderPass(vertex_shader, fragment_shader, uniforms);
export const Pass$isCustomShaderPass = (value) =>
  value instanceof CustomShaderPass;
export const Pass$CustomShaderPass$vertex_shader = (value) =>
  value.vertex_shader;
export const Pass$CustomShaderPass$0 = (value) => value.vertex_shader;
export const Pass$CustomShaderPass$fragment_shader = (value) =>
  value.fragment_shader;
export const Pass$CustomShaderPass$1 = (value) => value.fragment_shader;
export const Pass$CustomShaderPass$uniforms = (value) => value.uniforms;
export const Pass$CustomShaderPass$2 = (value) => value.uniforms;

export class FloatUniform extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const UniformValue$FloatUniform = ($0) => new FloatUniform($0);
export const UniformValue$isFloatUniform = (value) =>
  value instanceof FloatUniform;
export const UniformValue$FloatUniform$0 = (value) => value[0];

export class IntUniform extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const UniformValue$IntUniform = ($0) => new IntUniform($0);
export const UniformValue$isIntUniform = (value) => value instanceof IntUniform;
export const UniformValue$IntUniform$0 = (value) => value[0];

export class Vec2Uniform extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const UniformValue$Vec2Uniform = ($0, $1) => new Vec2Uniform($0, $1);
export const UniformValue$isVec2Uniform = (value) =>
  value instanceof Vec2Uniform;
export const UniformValue$Vec2Uniform$0 = (value) => value[0];
export const UniformValue$Vec2Uniform$1 = (value) => value[1];

export class Vec3Uniform extends $CustomType {
  constructor($0, $1, $2) {
    super();
    this[0] = $0;
    this[1] = $1;
    this[2] = $2;
  }
}
export const UniformValue$Vec3Uniform = ($0, $1, $2) =>
  new Vec3Uniform($0, $1, $2);
export const UniformValue$isVec3Uniform = (value) =>
  value instanceof Vec3Uniform;
export const UniformValue$Vec3Uniform$0 = (value) => value[0];
export const UniformValue$Vec3Uniform$1 = (value) => value[1];
export const UniformValue$Vec3Uniform$2 = (value) => value[2];

export class ColorUniform extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const UniformValue$ColorUniform = ($0) => new ColorUniform($0);
export const UniformValue$isColorUniform = (value) =>
  value instanceof ColorUniform;
export const UniformValue$ColorUniform$0 = (value) => value[0];

/**
 * Creates a perspective camera for 3D games.
 *
 * Objects further away appear smaller, like in real life. The aspect ratio is
 * automatically calculated from the viewport dimensions at render time.
 */
export function perspective(fov, near, far) {
  return $bool.guard(
    (fov <= 0.0) || (fov >= 180.0),
    new Error(new InvalidFieldOfView(fov)),
    () => {
      return $bool.guard(
        near <= 0.0,
        new Error(new InvalidNearPlane(near)),
        () => {
          return $bool.guard(
            far <= 0.0,
            new Error(new InvalidFarPlane(far)),
            () => {
              return $bool.guard(
                near >= far,
                new Error(new NearFarConflict(near, far)),
                () => {
                  return new Ok(
                    new Camera(new Perspective(fov, 1.0, near, far)),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

/**
 * Create an orthographic camera (for 2D games or isometric views).
 *
 * No perspective distortion - objects are the same size regardless of distance.
 *
 * ## Example
 *
 * ```gleam
 * let cam = camera.orthographic(
 *   left: -400.0, right: 400.0,
 *   top: 300.0, bottom: -300.0,
 *   near: 0.1, far: 1000.0,
 * )
 * ```
 */
export function orthographic(left, right, top, bottom, near, far) {
  return new Camera(new Orthographic(left, right, top, bottom, near, far));
}

/**
 * Create a 2D camera centered at origin with world coordinates.
 *
 * Useful for 2D games where (0,0) is the center of the screen.
 *
 * ## Example
 *
 * ```gleam
 * let cam = camera.camera_2d(size: vec2.Vec2(800, 600))
 * scene.Camera(
 *   id: "main_camera",
 *   camera: cam,
 *   transform: transform.at(position: vec3.Vec3(0.0, 0.0, 5.0)),
 *   active: True,
 *   viewport: option.None,
 * )
 * // (0, 0) is screen center, positive Y is up
 * ```
 */
export function camera_2d(size) {
  let w = $int.to_float(size.x);
  let h = $int.to_float(size.y);
  let half_w = w / 2.0;
  let half_h = h / 2.0;
  return orthographic(0.0 - half_w, half_w, half_h, 0.0 - half_h, 0.1, 1000.0);
}

/**
 * Create a 2D camera with screen-space coordinates (top-left origin).
 *
 * Useful for UI or pixel-perfect 2D games where (0,0) is top-left corner.
 *
 * ## Example
 *
 * ```gleam
 * let cam = camera.camera_2d_screen_space(size: vec2.Vec2(800, 600))
 * scene.Camera(
 *   id: "ui_camera",
 *   camera: cam,
 *   transform: transform.at(position: vec3.Vec3(0.0, 0.0, 5.0)),
 *   active: True,
 *   viewport: option.None,
 * )
 * // (0, 0) is top-left, positive Y is down (like CSS)
 * ```
 */
export function camera_2d_screen_space(size) {
  let w = $int.to_float(size.x);
  let h = $int.to_float(size.y);
  return orthographic(0.0, w, 0.0, 0.0 - h, 0.1, 1000.0);
}

/**
 * Create a 2D camera with custom bounds.
 *
 * ## Example
 *
 * ```gleam
 * let cam = camera.camera_2d_with_bounds(
 *   left: -100.0, right: 100.0,
 *   top: 75.0, bottom: -75.0,
 * )
 * scene.Camera(
 *   id: "game_camera",
 *   camera: cam,
 *   transform: transform.at(position: vec3.Vec3(0.0, 0.0, 5.0)),
 *   active: True,
 *   viewport: option.None,
 * )
 * ```
 */
export function camera_2d_with_bounds(left, right, top, bottom) {
  return orthographic(left, right, top, bottom, 0.1, 1000.0);
}

/**
 * Internal function to get the camera projection
 *
 * Used by the internal renderer to create Three.js cameras
 * 
 * @ignore
 */
export function get_projection(camera) {
  return camera.projection;
}

/**
 * Create a new empty post-processing pipeline.
 *
 * Start with this and add passes using `postprocessing_add_pass`.
 *
 * ## Example
 *
 * ```gleam
 * let pp = camera.new_postprocessing()
 *   |> camera.add_pass(camera.clear_pass(option.None))
 *   |> camera.add_pass(camera.render_pass())
 *   |> camera.add_pass(camera.bloom(...))
 *   |> camera.add_pass(camera.fxaa())
 *   |> camera.add_pass(camera.output_pass())
 * ```
 */
export function new_postprocessing() {
  return new PostProcessing(toList([]));
}

/**
 * Add a pass to the pipeline.
 *
 * Passes are executed in the order they are added.
 *
 * ## Example
 *
 * ```gleam
 * camera.postprocessing_new()
 * |> camera.add_pass(camera.bloom(
 *   strength: 1.5,
 *   threshold: 0.85,
 *   radius: 0.4,
 * ))
 * |> camera.postprocessing_add_pass(camera.fxaa())
 * ```
 */
export function add_pass(pp, pass) {
  let passes;
  passes = pp.passes;
  return new PostProcessing($list.append(passes, toList([pass])));
}

/**
 * Get the list of passes (internal use).
 * 
 * @ignore
 */
export function get_passes(pp) {
  let passes;
  passes = pp.passes;
  return passes;
}

/**
 * Create a render pass.
 *
 * This pass renders your 3D scene to the render target. It should typically
 * be one of the first passes in your pipeline (after ClearPass if you need
 * background rendering).
 *
 * ## Example
 *
 * ```gleam
 * camera.postprocessing_new()
 * |> camera.postprocessing_add_pass(camera.render_pass())
 * |> camera.postprocessing_add_pass(camera.bloom(...))
 * ```
 */
export function render_pass() {
  return new RenderPass();
}

/**
 * Creates a clear pass for postprocessing.
 *
 * Clears the render target with a color. Use before RenderPass to make
 * scene backgrounds work correctly with postprocessing. Pass `None` to use
 * the scene's background color.
 *
 * ## Example
 *
 * ```gleam
 * // Use scene background
 * camera.clear_pass(option.None)
 *
 * // Use custom color
 * camera.clear_pass(option.Some(0x000000))  // Black
 * ```
 */
export function clear_pass(color) {
  return new ClearPass(color);
}

/**
 * Create an output pass.
 *
 * Applies final tone mapping and outputs to the screen. This should typically
 * be the last pass in your pipeline.
 *
 * ## Example
 *
 * ```gleam
 * camera.postprocessing_new()
 * |> camera.postprocessing_add_pass(camera.render_pass())
 * |> camera.postprocessing_add_pass(camera.bloom(...))
 * |> camera.postprocessing_add_pass(camera.output_pass())  // Last pass
 * ```
 */
export function output_pass() {
  return new OutputPass();
}

/**
 * Creates a bloom effect pass.
 *
 * Makes bright areas glow and bleed into surrounding pixels.
 *
 * ## Example
 *
 * ```gleam
 * // Subtle bloom for realistic glow
 * camera.bloom(strength: 0.8, threshold: 0.85, radius: 0.4)
 *
 * // Intense bloom for sci-fi effect
 * camera.bloom(strength: 2.0, threshold: 0.5, radius: 0.8)
 * ```
 */
export function bloom(strength, threshold, radius) {
  return new BloomPass(strength, threshold, radius);
}

/**
 * Creates a simple pixelation effect without edge detection.
 *
 * ## Example
 *
 * ```gleam
 * // Subtle pixelation
 * camera.pixelate(pixel_size: 2)
 *
 * // Strong retro effect
 * camera.pixelate(pixel_size: 8)
 * ```
 */
export function pixelate(pixel_size) {
  return new PixelatePass(pixel_size, 0.0, 0.0);
}

/**
 * Creates a pixelation effect with edge detection.
 *
 * Edge detection adds outlines based on surface normals and depth changes.
 *
 * ## Example
 *
 * ```gleam
 * camera.pixelate_with_edges(
 *   pixel_size: 4,
 *   normal_edge_strength: 1.0,
 *   depth_edge_strength: 0.5,
 * )
 * ```
 */
export function pixelate_with_edges(
  pixel_size,
  normal_edge_strength,
  depth_edge_strength
) {
  return new PixelatePass(pixel_size, normal_edge_strength, depth_edge_strength);
}

/**
 * Creates a film grain effect.
 *
 * Adds analog film texture with grain noise and optional scanlines.
 *
 * ## Example
 *
 * ```gleam
 * // Subtle film grain
 * camera.film_grain(
 *   noise_intensity: 0.2,
 *   scanline_intensity: 0.0,
 *   scanline_count: 0,
 *   grayscale: False,
 * )
 *
 * // Retro CRT monitor effect
 * camera.film_grain(
 *   noise_intensity: 0.4,
 *   scanline_intensity: 0.3,
 *   scanline_count: 512,
 *   grayscale: True,
 * )
 * ```
 */
export function film_grain(
  noise_intensity,
  scanline_intensity,
  scanline_count,
  grayscale
) {
  return new FilmPass(
    noise_intensity,
    scanline_intensity,
    scanline_count,
    grayscale,
  );
}

/**
 * Creates a vignette effect.
 *
 * Darkens the edges of the screen, focusing attention on the center.
 *
 * ## Example
 *
 * ```gleam
 * // Subtle vignette
 * camera.vignette(darkness: 0.5, offset: 1.0)
 *
 * // Dramatic vignette
 * camera.vignette(darkness: 1.5, offset: 0.8)
 * ```
 */
export function vignette(darkness, offset) {
  return new VignettePass(darkness, offset);
}

/**
 * Create an FXAA anti-aliasing pass.
 *
 * Fast approximate anti-aliasing that smooths jagged edges.
 * Usually added as the last pass in the pipeline.
 *
 * ## Example
 *
 * ```gleam
 * camera.postprocessing_new()
 * |> camera.postprocessing_add_pass(camera.bloom(...))
 * |> camera.postprocessing_add_pass(camera.fxaa())  // Last pass
 * ```
 */
export function fxaa() {
  return new FXAAPass();
}

/**
 * Creates a glitch effect pass.
 *
 * Creates digital corruption artifacts with RGB channel offsets.
 *
 * ## Example
 *
 * ```gleam
 * camera.glitch(dt_size: 64)
 * ```
 */
export function glitch(dt_size) {
  return new GlitchPass(dt_size);
}

/**
 * Creates a color correction pass.
 *
 * Adjusts brightness, contrast, and saturation of the final image.
 *
 * ## Example
 *
 * ```gleam
 * // Brighten and increase saturation
 * camera.color_correction(
 *   brightness: 0.2,
 *   contrast: 0.1,
 *   saturation: 0.3,
 * )
 *
 * // Desaturated look
 * camera.color_correction(
 *   brightness: 0.0,
 *   contrast: 0.2,
 *   saturation: -0.5,
 * )
 * ```
 */
export function color_correction(brightness, contrast, saturation) {
  return new ColorCorrectionPass(brightness, contrast, saturation);
}

/**
 * Creates a custom shader pass for advanced effects.
 *
 * Apply custom GLSL vertex and fragment shaders with uniforms.
 *
 * ## Example
 *
 * ```gleam
 * camera.custom_shader(
 *   vertex_shader: "
 *     varying vec2 vUv;
 *     void main() {
 *       vUv = uv;
 *       gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
 *     }
 *   ",
 *   fragment_shader: "
 *     uniform sampler2D tDiffuse;
 *     uniform float intensity;
 *     varying vec2 vUv;
 *     void main() {
 *       vec4 color = texture2D(tDiffuse, vUv);
 *       gl_FragColor = color * intensity;
 *     }
 *   ",
 *   uniforms: [
 *     #("intensity", camera.FloatUniform(1.5)),
 *   ],
 * )
 * ```
 */
export function custom_shader(vertex_shader, fragment_shader, uniforms) {
  return new CustomShaderPass(vertex_shader, fragment_shader, uniforms);
}
