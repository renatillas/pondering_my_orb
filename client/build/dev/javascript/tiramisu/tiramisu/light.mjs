import * as $bool from "../../gleam_stdlib/gleam/bool.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import { Ok, Error, CustomType as $CustomType } from "../gleam.mjs";

/**
 * Global ambient light (affects all objects equally, no direction).
 * 
 * @ignore
 */
class Ambient extends $CustomType {
  constructor(intensity, color) {
    super();
    this.intensity = intensity;
    this.color = color;
  }
}

/**
 * Directional light like the sun (parallel rays, infinite distance).
 * 
 * @ignore
 */
class Directional extends $CustomType {
  constructor(intensity, color, cast_shadow, shadow_resolution, shadow_bias, shadow_normal_bias, shadow_camera_left, shadow_camera_right, shadow_camera_top, shadow_camera_bottom, shadow_camera_near, shadow_camera_far) {
    super();
    this.intensity = intensity;
    this.color = color;
    this.cast_shadow = cast_shadow;
    this.shadow_resolution = shadow_resolution;
    this.shadow_bias = shadow_bias;
    this.shadow_normal_bias = shadow_normal_bias;
    this.shadow_camera_left = shadow_camera_left;
    this.shadow_camera_right = shadow_camera_right;
    this.shadow_camera_top = shadow_camera_top;
    this.shadow_camera_bottom = shadow_camera_bottom;
    this.shadow_camera_near = shadow_camera_near;
    this.shadow_camera_far = shadow_camera_far;
  }
}

/**
 * Point light that radiates in all directions (like a light bulb).
 * 
 * @ignore
 */
class Point extends $CustomType {
  constructor(intensity, color, distance, cast_shadow, shadow_resolution, shadow_bias, shadow_normal_bias) {
    super();
    this.intensity = intensity;
    this.color = color;
    this.distance = distance;
    this.cast_shadow = cast_shadow;
    this.shadow_resolution = shadow_resolution;
    this.shadow_bias = shadow_bias;
    this.shadow_normal_bias = shadow_normal_bias;
  }
}

/**
 * Cone-shaped spotlight (like a flashlight or stage light).
 * 
 * @ignore
 */
class Spot extends $CustomType {
  constructor(intensity, color, distance, angle, penumbra, cast_shadow, shadow_resolution, shadow_bias, shadow_normal_bias) {
    super();
    this.intensity = intensity;
    this.color = color;
    this.distance = distance;
    this.angle = angle;
    this.penumbra = penumbra;
    this.cast_shadow = cast_shadow;
    this.shadow_resolution = shadow_resolution;
    this.shadow_bias = shadow_bias;
    this.shadow_normal_bias = shadow_normal_bias;
  }
}

/**
 * Hemisphere light with different colors for sky and ground (outdoor ambient).
 * 
 * @ignore
 */
class Hemisphere extends $CustomType {
  constructor(intensity, sky_color, ground_color) {
    super();
    this.intensity = intensity;
    this.sky_color = sky_color;
    this.ground_color = ground_color;
  }
}

/**
 * Intensity must be non-negative
 */
export class NegativeIntensity extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const LightError$NegativeIntensity = ($0) => new NegativeIntensity($0);
export const LightError$isNegativeIntensity = (value) =>
  value instanceof NegativeIntensity;
export const LightError$NegativeIntensity$0 = (value) => value[0];

/**
 * Color must be a valid hex color (0x000000 to 0xFFFFFF)
 */
export class OutOfBoundsColor extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const LightError$OutOfBoundsColor = ($0) => new OutOfBoundsColor($0);
export const LightError$isOutOfBoundsColor = (value) =>
  value instanceof OutOfBoundsColor;
export const LightError$OutOfBoundsColor$0 = (value) => value[0];

/**
 * Distance must be non-negative
 */
export class NegativeDistance extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const LightError$NegativeDistance = ($0) => new NegativeDistance($0);
export const LightError$isNegativeDistance = (value) =>
  value instanceof NegativeDistance;
export const LightError$NegativeDistance$0 = (value) => value[0];

/**
 * Shadow resolution must be positive and a power of 2
 */
export class InvalidShadowResolution extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const LightError$InvalidShadowResolution = ($0) =>
  new InvalidShadowResolution($0);
export const LightError$isInvalidShadowResolution = (value) =>
  value instanceof InvalidShadowResolution;
export const LightError$InvalidShadowResolution$0 = (value) => value[0];

/**
 * Shadow bias must be non-negative
 */
export class InvalidShadowBias extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const LightError$InvalidShadowBias = ($0) => new InvalidShadowBias($0);
export const LightError$isInvalidShadowBias = (value) =>
  value instanceof InvalidShadowBias;
export const LightError$InvalidShadowBias$0 = (value) => value[0];

/**
 * Create an ambient light for global base illumination.
 *
 * Ambient light has no direction and affects all objects equally. It's the cheapest
 * light type and should be used as a base level of illumination in every scene.
 *
 * **Intensity**: Typical values are 0.1-0.5 for subtle ambient, 0.5-1.0 for brighter scenes.
 * **Color**: Hex color (e.g., 0xffffff for white, 0x404040 for dim gray).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/light
 * import tiramisu/scene
 * import tiramisu/transform
 *
 * // Subtle gray ambient for indoor scene
 * let assert Ok(ambient) = light.ambient(intensity: 0.2, color: 0x404040)
 *
 * scene.Light(
 *   id: "ambient",
 *   light: ambient,
 *   transform: transform.identity,
 * )
 * ```
 */
export function ambient(intensity, color) {
  return $bool.guard(
    intensity < 0.0,
    new Error(new NegativeIntensity(intensity)),
    () => {
      return $bool.guard(
        (color < 0) && (color > 0xffffff),
        new Error(new OutOfBoundsColor(color)),
        () => { return new Ok(new Ambient(intensity, color)); },
      );
    },
  );
}

/**
 * Create a directional light with parallel rays like the sun.
 *
 * Directional lights simulate sunlight - all rays are parallel, coming from an infinite
 * distance. The light's position doesn't matter, only its rotation (direction).
 * Can cast high-quality shadows across the entire scene.
 *
 * **Intensity**: Typical values are 0.5-1.5. Higher for harsh sunlight, lower for overcast.
 * **Color**: Hex color (e.g., 0xffffff for noon sun, 0xffeedd for sunset).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/light
 * import tiramisu/scene
 * import tiramisu/transform
 * import vec/vec3
 *
 * // Sun at an angle with shadows
 * let assert Ok(sun) = light.directional(intensity: 1.2, color: 0xffffff)
 *   |> light.with_shadows(True)
 *   |> light.with_shadow_resolution(2048)
 *
 * scene.Light(
 *   id: "sun",
 *   light: sun,
 *   transform: transform.identity
 *     |> transform.with_euler_rotation(vec3.Vec3(-0.8, 0.5, 0.0)),  // Angled downward
 * )
 * ```
 */
export function directional(intensity, color) {
  return $bool.guard(
    intensity < 0.0,
    new Error(new NegativeIntensity(intensity)),
    () => {
      return $bool.guard(
        (color < 0) && (color > 0xffffff),
        new Error(new OutOfBoundsColor(color)),
        () => {
          return new Ok(
            new Directional(
              intensity,
              color,
              false,
              1024,
              0.0001,
              0.5,
              -200.0,
              200.0,
              200.0,
              -200.0,
              0.5,
              500.0,
            ),
          );
        },
      );
    },
  );
}

/**
 * Create a point light that radiates in all directions.
 *
 * Point lights simulate light bulbs, torches, or lamps. They emit light equally in all
 * directions from their position. Light intensity decreases with distance.
 *
 * **Intensity**: Typical values are 0.5-2.0 depending on desired brightness.
 * **Color**: Hex color (e.g., 0xfff5e1 for warm bulb, 0xffffff for cool white).
 * **Distance**: Maximum range where light intensity reaches zero. Use 0.0 for infinite range (not recommended for performance).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/light
 * import tiramisu/scene
 * import tiramisu/transform
 * import vec/vec3
 *
 * // Warm ceiling light
 * let assert Ok(bulb) = light.point(
 *   intensity: 1.0,
 *   color: 0xfff5e1,  // Warm yellow-white
 *   distance: 15.0,   // Light fades out at 15 units
 * ) |> light.with_shadows(True)
 *
 * scene.Light(
 *   id: "ceiling-light",
 *   light: bulb,
 *   transform: transform.at(position: vec3.Vec3(0.0, 5.0, 0.0)),
 * )
 * ```
 */
export function point(intensity, color, distance) {
  return $bool.guard(
    intensity < 0.0,
    new Error(new NegativeIntensity(intensity)),
    () => {
      return $bool.guard(
        (color < 0) && (color > 0xffffff),
        new Error(new OutOfBoundsColor(color)),
        () => {
          return $bool.guard(
            distance < 0.0,
            new Error(new NegativeDistance(distance)),
            () => {
              return new Ok(
                new Point(intensity, color, distance, false, 1024, 0.0001, 0.5),
              );
            },
          );
        },
      );
    },
  );
}

/**
 * Create a spotlight with a focused cone of light.
 *
 * Spotlights simulate flashlights, stage lights, or car headlights. They emit light in a
 * cone shape from their position, with the cone pointing in the light's forward direction.
 *
 * **Intensity**: Typical values are 0.5-2.0.
 * **Color**: Hex color (e.g., 0xffffff for white, 0xffff00 for yellow headlight).
 * **Distance**: Maximum range where light intensity reaches zero.
 * **Angle**: Cone angle in **radians** (e.g., Math.PI/4 for 45°, Math.PI/6 for 30°).
 * **Penumbra**: Edge softness from 0.0 (hard edge) to 1.0 (very soft edge). Typical: 0.1-0.3.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/light
 * import tiramisu/scene
 * import tiramisu/transform
 * import vec/vec3
 * import gleam_community/maths
 *
 * // Flashlight spotlight
 * let assert Ok(flashlight) = light.spot(
 *   intensity: 1.5,
 *   color: 0xffffff,
 *   distance: 20.0,
 *   angle: maths.pi /. 6.0,  // 30 degree cone (in radians)
 *   penumbra: 0.2,           // Soft edges
 * ) |> light.with_shadows(True)
 *
 * scene.Light(
 *   id: "flashlight",
 *   light: flashlight,
 *   transform: transform.at(position: vec3.Vec3(0.0, 2.0, 0.0))
 *     |> transform.with_euler_rotation(vec3.Vec3(-1.57, 0.0, 0.0)),  // Point downward
 * )
 * ```
 */
export function spot(intensity, color, distance, angle, penumbra) {
  return $bool.guard(
    intensity < 0.0,
    new Error(new NegativeIntensity(intensity)),
    () => {
      return $bool.guard(
        (color < 0) && (color > 0xffffff),
        new Error(new OutOfBoundsColor(color)),
        () => {
          return $bool.guard(
            distance < 0.0,
            new Error(new NegativeDistance(distance)),
            () => {
              return new Ok(
                new Spot(
                  intensity,
                  color,
                  distance,
                  angle,
                  penumbra,
                  false,
                  1024,
                  0.0001,
                  0.5,
                ),
              );
            },
          );
        },
      );
    },
  );
}

/**
 * Create a hemisphere light for outdoor ambient lighting.
 *
 * Hemisphere lights simulate outdoor ambient light by using different colors for the sky
 * (upper hemisphere) and ground (lower hemisphere). Objects facing upward receive the sky
 * color, and objects facing downward receive the ground color. Creates more realistic
 * outdoor ambient than a single flat ambient light.
 *
 * **Intensity**: Typical values are 0.2-0.5 for subtle ambient contribution.
 * **Sky Color**: Upper hemisphere color (e.g., 0x87ceeb for sky blue).
 * **Ground Color**: Lower hemisphere color (e.g., 0x8b7355 for brown earth).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/light
 * import tiramisu/scene
 * import tiramisu/transform
 *
 * // Outdoor ambient with blue sky and brown ground
 * let assert Ok(outdoor_ambient) = light.hemisphere(
 *   intensity: 0.4,
 *   sky_color: 0x87ceeb,    // Sky blue
 *   ground_color: 0x8b7355,  // Brown earth
 * )
 *
 * scene.Light(
 *   id: "outdoor-ambient",
 *   light: outdoor_ambient,
 *   transform: transform.identity,
 * )
 * ```
 */
export function hemisphere(intensity, sky_color, ground_color) {
  return $bool.guard(
    intensity < 0.0,
    new Error(new NegativeIntensity(intensity)),
    () => {
      return $bool.guard(
        (sky_color < 0) && (sky_color > 0xffffff),
        new Error(new OutOfBoundsColor(sky_color)),
        () => {
          return $bool.guard(
            (ground_color < 0) && (ground_color > 0xffffff),
            new Error(new OutOfBoundsColor(sky_color)),
            () => {
              return new Ok(new Hemisphere(intensity, sky_color, ground_color));
            },
          );
        },
      );
    },
  );
}

/**
 * Enable shadow casting for a light.
 *
 * Only directional, point, and spot lights can cast shadows.
 * Ambient and hemisphere lights are ignored.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(sun) = light.directional(intensity: 1.0, color: 0xffffff)
 *   |> light.with_shadows(True)
 * ```
 */
export function with_shadows(light, cast_shadow) {
  if (light instanceof Directional) {
    let intensity = light.intensity;
    let color = light.color;
    let shadow_resolution = light.shadow_resolution;
    let shadow_bias = light.shadow_bias;
    let shadow_normal_bias = light.shadow_normal_bias;
    let shadow_camera_left = light.shadow_camera_left;
    let shadow_camera_right = light.shadow_camera_right;
    let shadow_camera_top = light.shadow_camera_top;
    let shadow_camera_bottom = light.shadow_camera_bottom;
    let shadow_camera_near = light.shadow_camera_near;
    let shadow_camera_far = light.shadow_camera_far;
    return new Directional(
      intensity,
      color,
      cast_shadow,
      shadow_resolution,
      shadow_bias,
      shadow_normal_bias,
      shadow_camera_left,
      shadow_camera_right,
      shadow_camera_top,
      shadow_camera_bottom,
      shadow_camera_near,
      shadow_camera_far,
    );
  } else if (light instanceof Point) {
    let intensity = light.intensity;
    let color = light.color;
    let distance = light.distance;
    let shadow_resolution = light.shadow_resolution;
    let shadow_bias = light.shadow_bias;
    let shadow_normal_bias = light.shadow_normal_bias;
    return new Point(
      intensity,
      color,
      distance,
      cast_shadow,
      shadow_resolution,
      shadow_bias,
      shadow_normal_bias,
    );
  } else if (light instanceof Spot) {
    let intensity = light.intensity;
    let color = light.color;
    let distance = light.distance;
    let angle = light.angle;
    let penumbra = light.penumbra;
    let shadow_resolution = light.shadow_resolution;
    let shadow_bias = light.shadow_bias;
    let shadow_normal_bias = light.shadow_normal_bias;
    return new Spot(
      intensity,
      color,
      distance,
      angle,
      penumbra,
      cast_shadow,
      shadow_resolution,
      shadow_bias,
      shadow_normal_bias,
    );
  } else {
    return light;
  }
}

/**
 * Set shadow map resolution (in pixels).
 *
 * Higher values produce sharper shadows but use more memory.
 * Common values: 512, 1024 (default), 2048, 4096.
 * Must be a power of 2.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(sun) = light.directional(intensity: 1.0, color: 0xffffff)
 *   |> result.map(light.with_shadows(_, True))
 *   |> result.try(light.with_shadow_resolution(_, 2048))
 * ```
 */
export function with_shadow_resolution(light, resolution) {
  return $bool.guard(
    (resolution <= 0) || ((resolution % 2) !== 0),
    new Error(new InvalidShadowResolution(resolution)),
    () => {
      if (light instanceof Directional) {
        let intensity = light.intensity;
        let color = light.color;
        let cast_shadow = light.cast_shadow;
        let shadow_bias = light.shadow_bias;
        let shadow_normal_bias = light.shadow_normal_bias;
        let shadow_camera_left = light.shadow_camera_left;
        let shadow_camera_right = light.shadow_camera_right;
        let shadow_camera_top = light.shadow_camera_top;
        let shadow_camera_bottom = light.shadow_camera_bottom;
        let shadow_camera_near = light.shadow_camera_near;
        let shadow_camera_far = light.shadow_camera_far;
        return new Ok(
          new Directional(
            intensity,
            color,
            cast_shadow,
            resolution,
            shadow_bias,
            shadow_normal_bias,
            shadow_camera_left,
            shadow_camera_right,
            shadow_camera_top,
            shadow_camera_bottom,
            shadow_camera_near,
            shadow_camera_far,
          ),
        );
      } else if (light instanceof Point) {
        let intensity = light.intensity;
        let color = light.color;
        let distance = light.distance;
        let cast_shadow = light.cast_shadow;
        let shadow_bias = light.shadow_bias;
        let shadow_normal_bias = light.shadow_normal_bias;
        return new Ok(
          new Point(
            intensity,
            color,
            distance,
            cast_shadow,
            resolution,
            shadow_bias,
            shadow_normal_bias,
          ),
        );
      } else if (light instanceof Spot) {
        let intensity = light.intensity;
        let color = light.color;
        let distance = light.distance;
        let angle = light.angle;
        let penumbra = light.penumbra;
        let cast_shadow = light.cast_shadow;
        let shadow_bias = light.shadow_bias;
        let shadow_normal_bias = light.shadow_normal_bias;
        return new Ok(
          new Spot(
            intensity,
            color,
            distance,
            angle,
            penumbra,
            cast_shadow,
            resolution,
            shadow_bias,
            shadow_normal_bias,
          ),
        );
      } else {
        return new Ok(light);
      }
    },
  );
}

/**
 * Set shadow bias to reduce shadow acne artifacts.
 *
 * Typical values: 0.00001 to 0.001 (default: 0.0001).
 * Increase if you see shadow artifacts (shadow acne).
 * Decrease if shadows appear detached from objects.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(sun) = light.directional(intensity: 1.0, color: 0xffffff)
 *   |> light.with_shadows(True)
 *   |> light.with_shadow_bias(0.0005)
 * ```
 */
export function with_shadow_bias(light, bias) {
  return $bool.guard(
    bias < 0.0,
    new Error(new InvalidShadowBias(bias)),
    () => {
      if (light instanceof Directional) {
        let intensity = light.intensity;
        let color = light.color;
        let cast_shadow = light.cast_shadow;
        let shadow_resolution = light.shadow_resolution;
        let shadow_normal_bias = light.shadow_normal_bias;
        let shadow_camera_left = light.shadow_camera_left;
        let shadow_camera_right = light.shadow_camera_right;
        let shadow_camera_top = light.shadow_camera_top;
        let shadow_camera_bottom = light.shadow_camera_bottom;
        let shadow_camera_near = light.shadow_camera_near;
        let shadow_camera_far = light.shadow_camera_far;
        return new Ok(
          new Directional(
            intensity,
            color,
            cast_shadow,
            shadow_resolution,
            bias,
            shadow_normal_bias,
            shadow_camera_left,
            shadow_camera_right,
            shadow_camera_top,
            shadow_camera_bottom,
            shadow_camera_near,
            shadow_camera_far,
          ),
        );
      } else if (light instanceof Point) {
        let intensity = light.intensity;
        let color = light.color;
        let distance = light.distance;
        let cast_shadow = light.cast_shadow;
        let shadow_resolution = light.shadow_resolution;
        let shadow_normal_bias = light.shadow_normal_bias;
        return new Ok(
          new Point(
            intensity,
            color,
            distance,
            cast_shadow,
            shadow_resolution,
            bias,
            shadow_normal_bias,
          ),
        );
      } else if (light instanceof Spot) {
        let intensity = light.intensity;
        let color = light.color;
        let distance = light.distance;
        let angle = light.angle;
        let penumbra = light.penumbra;
        let cast_shadow = light.cast_shadow;
        let shadow_resolution = light.shadow_resolution;
        let shadow_normal_bias = light.shadow_normal_bias;
        return new Ok(
          new Spot(
            intensity,
            color,
            distance,
            angle,
            penumbra,
            cast_shadow,
            shadow_resolution,
            bias,
            shadow_normal_bias,
          ),
        );
      } else {
        return new Ok(light);
      }
    },
  );
}

export function create_light(light) {
  if (light instanceof Ambient) {
    let intensity = light.intensity;
    let color = light.color;
    return $savoiardi.create_ambient_light(color, intensity);
  } else if (light instanceof Directional) {
    let intensity = light.intensity;
    let color = light.color;
    let cast_shadow = light.cast_shadow;
    let shadow_resolution = light.shadow_resolution;
    let shadow_bias = light.shadow_bias;
    let shadow_normal_bias = light.shadow_normal_bias;
    let shadow_camera_left = light.shadow_camera_left;
    let shadow_camera_right = light.shadow_camera_right;
    let shadow_camera_top = light.shadow_camera_top;
    let shadow_camera_bottom = light.shadow_camera_bottom;
    let shadow_camera_near = light.shadow_camera_near;
    let shadow_camera_far = light.shadow_camera_far;
    return $savoiardi.create_directional_light(
      color,
      intensity,
      cast_shadow,
      new $savoiardi.DirectionalShadowConfig(
        shadow_resolution,
        shadow_bias,
        shadow_normal_bias,
        shadow_camera_left,
        shadow_camera_right,
        shadow_camera_top,
        shadow_camera_bottom,
        shadow_camera_near,
        shadow_camera_far,
      ),
    );
  } else if (light instanceof Point) {
    let intensity = light.intensity;
    let color = light.color;
    let distance = light.distance;
    let cast_shadow = light.cast_shadow;
    let shadow_resolution = light.shadow_resolution;
    let shadow_bias = light.shadow_bias;
    let shadow_normal_bias = light.shadow_normal_bias;
    return $savoiardi.create_point_light(
      color,
      intensity,
      distance,
      cast_shadow,
      new $savoiardi.ShadowConfig(
        shadow_resolution,
        shadow_bias,
        shadow_normal_bias,
      ),
    );
  } else if (light instanceof Spot) {
    let intensity = light.intensity;
    let color = light.color;
    let distance = light.distance;
    let angle = light.angle;
    let penumbra = light.penumbra;
    let cast_shadow = light.cast_shadow;
    let shadow_resolution = light.shadow_resolution;
    let shadow_bias = light.shadow_bias;
    let shadow_normal_bias = light.shadow_normal_bias;
    return $savoiardi.create_spot_light(
      color,
      intensity,
      distance,
      angle,
      penumbra,
      cast_shadow,
      new $savoiardi.ShadowConfig(
        shadow_resolution,
        shadow_bias,
        shadow_normal_bias,
      ),
    );
  } else {
    let intensity = light.intensity;
    let sky_color = light.sky_color;
    let ground_color = light.ground_color;
    return $savoiardi.create_hemisphere_light(
      sky_color,
      ground_color,
      intensity,
    );
  }
}
