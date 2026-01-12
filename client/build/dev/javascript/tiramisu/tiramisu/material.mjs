import * as $bool from "../../gleam_stdlib/gleam/bool.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import { Ok, Error, CustomType as $CustomType } from "../gleam.mjs";

/**
 * Unlit material (no lighting calculations). Fast and useful for flat-shaded objects.
 * 
 * @ignore
 */
class BasicMaterial extends $CustomType {
  constructor(color, map, transparent, opacity, side, alpha_test, depth_write) {
    super();
    this.color = color;
    this.map = map;
    this.transparent = transparent;
    this.opacity = opacity;
    this.side = side;
    this.alpha_test = alpha_test;
    this.depth_write = depth_write;
  }
}

/**
 * Physically-based material with metalness/roughness workflow. Most realistic.
 * 
 * @ignore
 */
class StandardMaterial extends $CustomType {
  constructor(color, map, normal_map, ambient_oclusion_map, displacement_map, displacement_scale, displacement_bias, roughness_map, metalness_map, metalness, roughness, transparent, opacity, emissive, emissive_intensity) {
    super();
    this.color = color;
    this.map = map;
    this.normal_map = normal_map;
    this.ambient_oclusion_map = ambient_oclusion_map;
    this.displacement_map = displacement_map;
    this.displacement_scale = displacement_scale;
    this.displacement_bias = displacement_bias;
    this.roughness_map = roughness_map;
    this.metalness_map = metalness_map;
    this.metalness = metalness;
    this.roughness = roughness;
    this.transparent = transparent;
    this.opacity = opacity;
    this.emissive = emissive;
    this.emissive_intensity = emissive_intensity;
  }
}

/**
 * Shiny material with specular highlights (like plastic or ceramic).
 * 
 * @ignore
 */
class PhongMaterial extends $CustomType {
  constructor(color, map, normal_map, ambient_oclusion_map, shininess, transparent, opacity, alpha_test) {
    super();
    this.color = color;
    this.map = map;
    this.normal_map = normal_map;
    this.ambient_oclusion_map = ambient_oclusion_map;
    this.shininess = shininess;
    this.transparent = transparent;
    this.opacity = opacity;
    this.alpha_test = alpha_test;
  }
}

/**
 * Matte material (like cloth or wood). Non-shiny diffuse lighting.
 * 
 * @ignore
 */
class LambertMaterial extends $CustomType {
  constructor(color, map, normal_map, ambient_oclusion_map, transparent, opacity, alpha_test) {
    super();
    this.color = color;
    this.map = map;
    this.normal_map = normal_map;
    this.ambient_oclusion_map = ambient_oclusion_map;
    this.transparent = transparent;
    this.opacity = opacity;
    this.alpha_test = alpha_test;
  }
}

/**
 * Cartoon-style material with banded shading.
 * 
 * @ignore
 */
class ToonMaterial extends $CustomType {
  constructor(color, map, normal_map, ambient_oclusion_map, transparent, opacity, alpha_test) {
    super();
    this.color = color;
    this.map = map;
    this.normal_map = normal_map;
    this.ambient_oclusion_map = ambient_oclusion_map;
    this.transparent = transparent;
    this.opacity = opacity;
    this.alpha_test = alpha_test;
  }
}

/**
 * Material for rendering lines.
 * 
 * @ignore
 */
class LineMaterial extends $CustomType {
  constructor(color, linewidth) {
    super();
    this.color = color;
    this.linewidth = linewidth;
  }
}

/**
 * Material for 2D sprites that always face the camera.
 * 
 * @ignore
 */
class SpriteMaterial extends $CustomType {
  constructor(color, map, transparent, opacity) {
    super();
    this.color = color;
    this.map = map;
    this.transparent = transparent;
    this.opacity = opacity;
  }
}

export class FrontSide extends $CustomType {}
export const MaterialSide$FrontSide = () => new FrontSide();
export const MaterialSide$isFrontSide = (value) => value instanceof FrontSide;

export class BackSide extends $CustomType {}
export const MaterialSide$BackSide = () => new BackSide();
export const MaterialSide$isBackSide = (value) => value instanceof BackSide;

export class DoubleSide extends $CustomType {}
export const MaterialSide$DoubleSide = () => new DoubleSide();
export const MaterialSide$isDoubleSide = (value) => value instanceof DoubleSide;

export class OutOfBoundsColor extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$OutOfBoundsColor = ($0) => new OutOfBoundsColor($0);
export const MaterialError$isOutOfBoundsColor = (value) =>
  value instanceof OutOfBoundsColor;
export const MaterialError$OutOfBoundsColor$0 = (value) => value[0];

export class OutOfBoundsOpacity extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$OutOfBoundsOpacity = ($0) =>
  new OutOfBoundsOpacity($0);
export const MaterialError$isOutOfBoundsOpacity = (value) =>
  value instanceof OutOfBoundsOpacity;
export const MaterialError$OutOfBoundsOpacity$0 = (value) => value[0];

export class OutOfBoundsRoughness extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$OutOfBoundsRoughness = ($0) =>
  new OutOfBoundsRoughness($0);
export const MaterialError$isOutOfBoundsRoughness = (value) =>
  value instanceof OutOfBoundsRoughness;
export const MaterialError$OutOfBoundsRoughness$0 = (value) => value[0];

export class OutOfBoundsMetalness extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$OutOfBoundsMetalness = ($0) =>
  new OutOfBoundsMetalness($0);
export const MaterialError$isOutOfBoundsMetalness = (value) =>
  value instanceof OutOfBoundsMetalness;
export const MaterialError$OutOfBoundsMetalness$0 = (value) => value[0];

export class NonPositiveLinewidth extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$NonPositiveLinewidth = ($0) =>
  new NonPositiveLinewidth($0);
export const MaterialError$isNonPositiveLinewidth = (value) =>
  value instanceof NonPositiveLinewidth;
export const MaterialError$NonPositiveLinewidth$0 = (value) => value[0];

export class NonPositiveShininess extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$NonPositiveShininess = ($0) =>
  new NonPositiveShininess($0);
export const MaterialError$isNonPositiveShininess = (value) =>
  value instanceof NonPositiveShininess;
export const MaterialError$NonPositiveShininess$0 = (value) => value[0];

export class OutOfBoundsEmissive extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$OutOfBoundsEmissive = ($0) =>
  new OutOfBoundsEmissive($0);
export const MaterialError$isOutOfBoundsEmissive = (value) =>
  value instanceof OutOfBoundsEmissive;
export const MaterialError$OutOfBoundsEmissive$0 = (value) => value[0];

export class OutOfBoundsEmissiveIntensity extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MaterialError$OutOfBoundsEmissiveIntensity = ($0) =>
  new OutOfBoundsEmissiveIntensity($0);
export const MaterialError$isOutOfBoundsEmissiveIntensity = (value) =>
  value instanceof OutOfBoundsEmissiveIntensity;
export const MaterialError$OutOfBoundsEmissiveIntensity$0 = (value) => value[0];

class StandardMaterialBuilder extends $CustomType {
  constructor(color, metalness, roughness, transparent, opacity, map, normal_map, ambient_oclusion_map, displacement_map, displacement_scale, displacement_bias, roughness_map, metalness_map, emissive, emissive_intensity) {
    super();
    this.color = color;
    this.metalness = metalness;
    this.roughness = roughness;
    this.transparent = transparent;
    this.opacity = opacity;
    this.map = map;
    this.normal_map = normal_map;
    this.ambient_oclusion_map = ambient_oclusion_map;
    this.displacement_map = displacement_map;
    this.displacement_scale = displacement_scale;
    this.displacement_bias = displacement_bias;
    this.roughness_map = roughness_map;
    this.metalness_map = metalness_map;
    this.emissive = emissive;
    this.emissive_intensity = emissive_intensity;
  }
}

/**
 * Convert tiramisu MaterialSide to Three.js side constant via savoiardi
 * 
 * @ignore
 */
function material_side_to_int(side) {
  if (side instanceof FrontSide) {
    return new $savoiardi.FrontSide();
  } else if (side instanceof BackSide) {
    return new $savoiardi.BackSide();
  } else {
    return new $savoiardi.DoubleSide();
  }
}

/**
 * Create a validated basic (unlit) material.
 *
 * Basic materials don't react to lights, making them very fast to render.
 * Opacity must be between 0.0 (fully transparent) and 1.0 (fully opaque).
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(red) = material.basic(color: 0xff0000, transparent: False, opacity: 1.0, map: option.None)
 * let assert Ok(glass) = material.basic(color: 0x88ccff, transparent: True, opacity: 0.5, map: option.None)
 * ```
 */
export function basic(
  color,
  transparent,
  opacity,
  map,
  side,
  alpha_test,
  depth_write
) {
  return $bool.guard(
    (color < 0x0) || (color > 0xffffff),
    new Error(new OutOfBoundsColor(color)),
    () => {
      return $bool.guard(
        (opacity < 0.0) || (opacity > 1.0),
        new Error(new OutOfBoundsOpacity(opacity)),
        () => {
          return new Ok(
            new BasicMaterial(
              color,
              map,
              transparent,
              opacity,
              side,
              alpha_test,
              depth_write,
            ),
          );
        },
      );
    },
  );
}

/**
 * Create a validated physically-based (PBR) standard material.
 *
 * Standard materials use metalness/roughness workflow for realistic rendering.
 * - Metalness: 0.0 = dielectric (plastic, wood), 1.0 = metal
 * - Roughness: 0.0 = mirror-smooth, 1.0 = completely rough
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(gold) = scene.standard_material(color: 0xffd700, metalness: 1.0, roughness: 0.3, transparent: False, opacity: 1.0, map: option.None, normal_map: option.None, ao_map: option.None, roughness_map: option.None, metalness_map: option.None)
 * let assert Ok(plastic) = scene.standard_material(color: 0xff0000, metalness: 0.0, roughness: 0.5, transparent: False, opacity: 1.0, map: option.None, normal_map: option.None, ao_map: option.None, roughness_map: option.None, metalness_map: option.None)
 * ```
 */
export function standard(
  color,
  metalness,
  roughness,
  transparent,
  opacity,
  map,
  normal_map,
  ambient_oclusion_map,
  displacement_map,
  displacement_scale,
  displacement_bias,
  roughness_map,
  metalness_map,
  emissive,
  emissive_intensity
) {
  return $bool.guard(
    (color < 0x0) || (color > 0xffffff),
    new Error(new OutOfBoundsColor(color)),
    () => {
      return $bool.guard(
        (metalness < 0.0) || (metalness > 1.0),
        new Error(new OutOfBoundsMetalness(metalness)),
        () => {
          return $bool.guard(
            (roughness < 0.0) || (roughness > 1.0),
            new Error(new OutOfBoundsRoughness(roughness)),
            () => {
              return $bool.guard(
                (opacity < 0.0) || (opacity > 1.0),
                new Error(new OutOfBoundsOpacity(opacity)),
                () => {
                  return $bool.guard(
                    (emissive < 0x0) || (emissive > 0xffffff),
                    new Error(new OutOfBoundsEmissive(emissive)),
                    () => {
                      return $bool.guard(
                        emissive_intensity < 0.0,
                        new Error(
                          new OutOfBoundsEmissiveIntensity(emissive_intensity),
                        ),
                        () => {
                          return new Ok(
                            new StandardMaterial(
                              color,
                              map,
                              normal_map,
                              ambient_oclusion_map,
                              displacement_map,
                              displacement_scale,
                              displacement_bias,
                              roughness_map,
                              metalness_map,
                              metalness,
                              roughness,
                              transparent,
                              opacity,
                              emissive,
                              emissive_intensity,
                            ),
                          );
                        },
                      );
                    },
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
 * Create a validated line material for rendering lines.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(line_mat) = scene.line_material(color: 0xff0000, linewidth: 2.0)
 * ```
 */
export function line(color, linewidth) {
  return $bool.guard(
    (color < 0x0) || (color > 0xffffff),
    new Error(new OutOfBoundsColor(color)),
    () => {
      return $bool.guard(
        linewidth <= 0.0,
        new Error(new NonPositiveLinewidth(linewidth)),
        () => { return new Ok(new LineMaterial(color, linewidth)); },
      );
    },
  );
}

/**
 * Create a validated sprite material for 2D billboards.
 *
 * Sprites always face the camera and are useful for particles, UI elements, etc.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(sprite_mat) = material.sprite(color: 0xffffff, transparent: True, opacity: 0.8, map: option.None)
 * ```
 */
export function sprite(color, transparent, opacity, map) {
  return $bool.guard(
    (color < 0x0) || (color > 0xffffff),
    new Error(new OutOfBoundsColor(color)),
    () => {
      return $bool.guard(
        (opacity < 0.0) || (opacity > 1.0),
        new Error(new OutOfBoundsOpacity(opacity)),
        () => {
          return new Ok(new SpriteMaterial(color, map, transparent, opacity));
        },
      );
    },
  );
}

/**
 * Create a Lambert material for matte, non-shiny surfaces.
 *
 * Lambert materials use diffuse-only lighting with no specular highlights, making them
 * ideal for cloth, wood, concrete, or other matte surfaces. Cheaper than Phong or Standard.
 *
 * **Color**: Base color without lighting (0x000000 to 0xFFFFFF).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/material
 * import gleam/option
 *
 * // Matte red cloth
 * let assert Ok(cloth) = material.lambert(
 *   color: 0xcc0000,
 *   map: option.None,
 *   normal_map: option.None,
 *   ambient_oclusion_map: option.None,
 * )
 *
 * // Wood with texture
 * let assert Ok(color_tex) = asset.get_texture(cache, "wood.jpg")
 * let assert Ok(wood) = material.lambert(
 *   color: 0xffffff,  // White base color (texture provides color)
 *   map: option.Some(color_tex),
 *   normal_map: option.None,
 *   ambient_oclusion_map: option.None,
 * )
 * ```
 */
export function lambert(
  color,
  map,
  normal_map,
  ambient_oclusion_map,
  transparent,
  opacity,
  alpha_test
) {
  return $bool.guard(
    (color < 0x0) || (color > 0xffffff),
    new Error(new OutOfBoundsColor(color)),
    () => {
      return $bool.guard(
        (opacity < 0.0) || (opacity > 1.0),
        new Error(new OutOfBoundsOpacity(opacity)),
        () => {
          return $bool.guard(
            (alpha_test < 0.0) || (alpha_test > 1.0),
            new Error(new OutOfBoundsOpacity(alpha_test)),
            () => {
              return new Ok(
                new LambertMaterial(
                  color,
                  map,
                  normal_map,
                  ambient_oclusion_map,
                  transparent,
                  opacity,
                  alpha_test,
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
 * Create a Phong material for shiny surfaces with specular highlights.
 *
 * Phong materials add specular highlights to simulate shiny surfaces like plastic,
 * ceramic, or polished surfaces. More expensive than Lambert but cheaper than Standard.
 *
 * **Color**: Base diffuse color (0x000000 to 0xFFFFFF).
 * **Shininess**: Specular highlight size. Higher = smaller, sharper highlight (typical: 30-100).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/material
 * import gleam/option
 *
 * // Shiny red plastic
 * let assert Ok(plastic) = material.phong(
 *   color: 0xff0000,
 *   shininess: 80.0,
 *   map: option.None,
 *   normal_map: option.None,
 *   ambient_oclusion_map: option.None,
 * )
 *
 * // Ceramic with low shininess (larger highlight)
 * let assert Ok(ceramic) = material.phong(
 *   color: 0xf5f5dc,
 *   shininess: 30.0,
 *   map: option.None,
 *   normal_map: option.None,
 *   ambient_oclusion_map: option.None,
 * )
 * ```
 */
export function phong(
  color,
  shininess,
  map,
  normal_map,
  ambient_oclusion_map,
  transparent,
  opacity,
  alpha_test
) {
  return $bool.guard(
    (color < 0x0) || (color > 0xffffff),
    new Error(new OutOfBoundsColor(color)),
    () => {
      return $bool.guard(
        shininess < 0.0,
        new Error(new NonPositiveShininess(shininess)),
        () => {
          return $bool.guard(
            (opacity < 0.0) || (opacity > 1.0),
            new Error(new OutOfBoundsOpacity(opacity)),
            () => {
              return $bool.guard(
                (alpha_test < 0.0) || (alpha_test > 1.0),
                new Error(new OutOfBoundsOpacity(alpha_test)),
                () => {
                  return new Ok(
                    new PhongMaterial(
                      color,
                      map,
                      normal_map,
                      ambient_oclusion_map,
                      shininess,
                      transparent,
                      opacity,
                      alpha_test,
                    ),
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
 * Create a Toon material for cartoon-style cel-shaded rendering.
 *
 * Toon materials create a cartoon/anime aesthetic by using banded shading instead of
 * smooth gradients. Colors are quantized into distinct bands, creating a hand-drawn look.
 *
 * **Color**: Base color (0x000000 to 0xFFFFFF).
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/material
 * import gleam/option
 *
 * // Cartoon character
 * let assert Ok(toon_mat) = material.toon(
 *   color: 0xff6b35,
 *   map: option.None,
 *   normal_map: option.None,
 *   ambient_oclusion_map: option.None,
 * )
 *
 * // Cel-shaded with texture
 * let assert Ok(color_tex) = asset.get_texture(cache, "character.png")
 * let assert Ok(toon_textured) = material.toon(
 *   color: 0xffffff,  // White base (texture provides color)
 *   map: option.Some(color_tex),
 *   normal_map: option.None,
 *   ambient_oclusion_map: option.None,
 * )
 * ```
 */
export function toon(
  color,
  map,
  normal_map,
  ambient_oclusion_map,
  transparent,
  opacity,
  alpha_test
) {
  return $bool.guard(
    (color < 0x0) || (color > 0xffffff),
    new Error(new OutOfBoundsColor(color)),
    () => {
      return $bool.guard(
        (opacity < 0.0) || (opacity > 1.0),
        new Error(new OutOfBoundsOpacity(opacity)),
        () => {
          return $bool.guard(
            (alpha_test < 0.0) || (alpha_test > 1.0),
            new Error(new OutOfBoundsOpacity(alpha_test)),
            () => {
              return new Ok(
                new ToonMaterial(
                  color,
                  map,
                  normal_map,
                  ambient_oclusion_map,
                  transparent,
                  opacity,
                  alpha_test,
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
 * Create a new StandardMaterial builder with sensible defaults.
 *
 * **Default values:**
 * - Color: 0x808080 (medium gray)
 * - Metalness: 0.5 (semi-metallic)
 * - Roughness: 0.5 (semi-rough)
 * - Transparent: False
 * - Opacity: 1.0 (fully opaque)
 * - All texture maps: None
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/material
 *
 * // Start building a material
 * let assert Ok(metal) = material.new()
 *   |> material.with_color(0xcccccc)
 *   |> material.with_metalness(1.0)
 *   |> material.with_roughness(0.3)
 *   |> material.build()
 * ```
 */
export function new$() {
  return new StandardMaterialBuilder(
    0x808080,
    0.5,
    0.5,
    false,
    1.0,
    new $option.None(),
    new $option.None(),
    new $option.None(),
    new $option.None(),
    1.0,
    0.0,
    new $option.None(),
    new $option.None(),
    0x0,
    0.0,
  );
}

/**
 * Set the base color.
 *
 * **Color**: Hex color from 0x000000 (black) to 0xFFFFFF (white).
 *
 * ## Example
 *
 * ```gleam
 * material.new()
 *   |> material.with_color(0xff0000)  // Red
 * ```
 */
export function with_color(builder, color) {
  return new StandardMaterialBuilder(
    color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the metalness value.
 *
 * **Metalness**: 0.0 = non-metal (plastic, wood, fabric), 1.0 = pure metal (gold, steel).
 *
 * ## Example
 *
 * ```gleam
 * // Metallic surface
 * material.new()
 *   |> material.with_metalness(1.0)
 *
 * // Non-metallic surface
 * material.new()
 *   |> material.with_metalness(0.0)
 * ```
 */
export function with_metalness(builder, metalness) {
  return new StandardMaterialBuilder(
    builder.color,
    metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the roughness value.
 *
 * **Roughness**: 0.0 = mirror-smooth (polished), 1.0 = completely rough (matte).
 *
 * ## Example
 *
 * ```gleam
 * // Polished chrome
 * material.new()
 *   |> material.with_roughness(0.1)
 *
 * // Rough concrete
 * material.new()
 *   |> material.with_roughness(0.9)
 * ```
 */
export function with_roughness(builder, roughness) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the color/albedo texture map.
 *
 * The texture modulates the base color. Common practice is to set base color to white (0xFFFFFF)
 * when using a color map.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(texture) = asset.get_texture(cache, "brick_color.jpg")
 *
 * material.new()
 *   |> material.with_color(0xffffff)  // White base
 *   |> material.with_color_map(texture)
 * ```
 */
export function with_color_map(builder, map) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    new $option.Some(map),
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the normal map for surface detail.
 *
 * Normal maps add surface details like bumps and grooves without adding geometry.
 * They affect how light interacts with the surface.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(normal) = asset.get_texture(cache, "brick_normal.jpg")
 *
 * material.new()
 *   |> material.with_normal_map(normal)
 * ```
 */
export function with_normal_map(builder, normal_map) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    new $option.Some(normal_map),
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the ambient occlusion map for contact shadows.
 *
 * AO maps darken areas where ambient light would be occluded, adding depth and realism
 * to crevices and corners.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(ao) = asset.get_texture(cache, "brick_ao.jpg")
 *
 * material.new()
 *   |> material.with_ambient_oclusion_map(ao)
 * ```
 */
export function with_ambient_oclusion_map(builder, ambient_oclusion_map) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    new $option.Some(ambient_oclusion_map),
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the displacement map for vertex deformation.
 *
 * The displacement map affects the position of the mesh's vertices.
 * Unlike other maps which only affect the light and shade of the material
 * the displaced vertices can cast shadows, block other objects, and
 * otherwise act as real geometry. The displacement texture is an image
 * where the value of each pixel (white being the highest) is mapped against,
 * and repositions, the vertices of the mesh.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(dm) = asset.get_texture(cache, "water.jpg")
 *
 * material.new()
 *   |> material.with_displacement_map(dm)
 * ```
 */
export function with_displacement_map(builder, displacement_map) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    new $option.Some(displacement_map),
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the displacement scale for vertex deformation.
 *
 * If a displacement map texture is set, this affects how much the
 * texture affects the deformation of vertices. Greater values cause
 * greater deformation, lesser values create less deformation. Negative
 * values invert the effect.
 *
 * The default value is `1.0`.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(dm) = asset.get_texture(cache, "water.jpg")
 *
 * material.new()
 *   |> material.with_displacement_map(dm)
 *   |> material.with_displacement_scale(2.5)
 * ```
 */
export function with_displacement_scale(builder, displacement_scale) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the displacement bias for vertex deformation.
 *
 * If a displacement map texture is set, this adjusts the
 * base offset of the deformation. Since the displacement map texture
 * is from 0.0 to 1.0 (black to white), negative displacement can
 * be achieved by using a negative value for the bias.
 *
 * The default value is `0.0`.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(dm) = asset.get_texture(cache, "water.jpg")
 *
 * material.new()
 *   |> material.with_displacement_map(dm)
 *   |> material.with_displacement_bias(0.5)
 * ```
 */
export function with_displacement_bias(builder, displacement_bias) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the roughness map for per-pixel roughness variation.
 *
 * Allows different parts of the surface to have different roughness values,
 * like scratches on polished metal or worn areas on wood.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(roughness) = asset.get_texture(cache, "metal_roughness.jpg")
 *
 * material.new()
 *   |> material.with_roughness_map(roughness)
 * ```
 */
export function with_roughness_map(builder, roughness_map) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    new $option.Some(roughness_map),
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the metalness map for per-pixel metalness variation.
 *
 * Useful for surfaces that are partially metallic, like painted metal with scratches
 * revealing bare metal underneath.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(metalness) = asset.get_texture(cache, "metal_metalness.jpg")
 *
 * material.new()
 *   |> material.with_metalness_map(metalness)
 * ```
 */
export function with_metalness_map(builder, metalness_map) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    new $option.Some(metalness_map),
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Enable or disable transparency.
 *
 * When True, the material's opacity value will be used for alpha blending.
 * Set to True when creating glass, water, or semi-transparent effects.
 *
 * ## Example
 *
 * ```gleam
 * // Glass material
 * material.new()
 *   |> material.with_transparent(True)
 *   |> material.with_opacity(0.3)
 * ```
 */
export function with_transparent(builder, transparent) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the opacity value.
 *
 * **Opacity**: 0.0 = fully transparent, 1.0 = fully opaque.
 * Only takes effect when `with_transparent(True)` is set.
 *
 * ## Example
 *
 * ```gleam
 * // Semi-transparent glass
 * material.new()
 *   |> material.with_color(0x88ccff)
 *   |> material.with_transparent(True)
 *   |> material.with_opacity(0.3)
 * ```
 */
export function with_opacity(builder, opacity) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the emissive color (glow).
 *
 * **Emissive**: Hex color from 0x000000 (no glow) to 0xFFFFFF (white glow).
 * Objects with emissive colors appear to emit light and are perfect for bloom effects.
 *
 * ## Example
 *
 * ```gleam
 * // Glowing red cube
 * material.new()
 *   |> material.with_color(0xff0000)
 *   |> material.with_emissive(0xff0000)
 *   |> material.with_emissive_intensity(0.5)
 * ```
 */
export function with_emissive(builder, emissive) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    emissive,
    builder.emissive_intensity,
  );
}

/**
 * Set the emissive intensity.
 *
 * **Emissive Intensity**: Multiplier for the emissive color brightness.
 * 0.0 = no emission, higher values = brighter glow. Especially visible with bloom.
 *
 * ## Example
 *
 * ```gleam
 * // Bright glowing sphere
 * material.new()
 *   |> material.with_color(0x00ff00)
 *   |> material.with_emissive(0x00ff00)
 *   |> material.with_emissive_intensity(1.0)
 * ```
 */
export function with_emissive_intensity(builder, intensity) {
  return new StandardMaterialBuilder(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    intensity,
  );
}

/**
 * Build the final StandardMaterial from the builder.
 *
 * Validates all parameters and returns a Result. Will fail if any values
 * are out of valid ranges.
 *
 * ## Example
 *
 * ```gleam
 * let result = material.new()
 *   |> material.with_color(0xff0000)
 *   |> material.with_metalness(0.8)
 *   |> material.with_roughness(0.3)
 *   |> material.build()
 *
 * case result {
 *   Ok(material) -> // Use the material
 *   Error(material.OutOfBoundsColor(_)) -> // Handle error
 * }
 * ```
 */
export function build(builder) {
  return standard(
    builder.color,
    builder.metalness,
    builder.roughness,
    builder.transparent,
    builder.opacity,
    builder.map,
    builder.normal_map,
    builder.ambient_oclusion_map,
    builder.displacement_map,
    builder.displacement_scale,
    builder.displacement_bias,
    builder.roughness_map,
    builder.metalness_map,
    builder.emissive,
    builder.emissive_intensity,
  );
}

export function create_material(material) {
  if (material instanceof BasicMaterial) {
    let color = material.color;
    let map = material.map;
    let transparent = material.transparent;
    let opacity = material.opacity;
    let side = material.side;
    let alpha_test = material.alpha_test;
    let depth_write = material.depth_write;
    return $savoiardi.create_basic_material(
      color,
      transparent,
      opacity,
      map,
      material_side_to_int(side),
      alpha_test,
      depth_write,
    );
  } else if (material instanceof StandardMaterial) {
    let color = material.color;
    let map = material.map;
    let normal_map = material.normal_map;
    let ambient_oclusion_map = material.ambient_oclusion_map;
    let displacement_map = material.displacement_map;
    let displacement_scale = material.displacement_scale;
    let displacement_bias = material.displacement_bias;
    let roughness_map = material.roughness_map;
    let metalness_map = material.metalness_map;
    let metalness = material.metalness;
    let roughness = material.roughness;
    let transparent = material.transparent;
    let opacity = material.opacity;
    let emissive = material.emissive;
    let emissive_intensity = material.emissive_intensity;
    return $savoiardi.create_standard_material(
      color,
      metalness,
      roughness,
      transparent,
      opacity,
      map,
      normal_map,
      ambient_oclusion_map,
      displacement_map,
      displacement_scale,
      displacement_bias,
      roughness_map,
      metalness_map,
      emissive,
      emissive_intensity,
    );
  } else if (material instanceof PhongMaterial) {
    let color = material.color;
    let map = material.map;
    let normal_map = material.normal_map;
    let ambient_oclusion_map = material.ambient_oclusion_map;
    let shininess = material.shininess;
    let transparent = material.transparent;
    let opacity = material.opacity;
    let alpha_test = material.alpha_test;
    return $savoiardi.create_phong_material(
      color,
      shininess,
      map,
      normal_map,
      ambient_oclusion_map,
      transparent,
      opacity,
      alpha_test,
    );
  } else if (material instanceof LambertMaterial) {
    let color = material.color;
    let map = material.map;
    let normal_map = material.normal_map;
    let ambient_oclusion_map = material.ambient_oclusion_map;
    let transparent = material.transparent;
    let opacity = material.opacity;
    let alpha_test = material.alpha_test;
    return $savoiardi.create_lambert_material(
      color,
      map,
      normal_map,
      ambient_oclusion_map,
      transparent,
      opacity,
      alpha_test,
    );
  } else if (material instanceof ToonMaterial) {
    let color = material.color;
    let map = material.map;
    let normal_map = material.normal_map;
    let ambient_oclusion_map = material.ambient_oclusion_map;
    let transparent = material.transparent;
    let opacity = material.opacity;
    let alpha_test = material.alpha_test;
    return $savoiardi.create_toon_material(
      color,
      map,
      normal_map,
      ambient_oclusion_map,
      transparent,
      opacity,
      alpha_test,
    );
  } else if (material instanceof LineMaterial) {
    let color = material.color;
    let linewidth = material.linewidth;
    return $savoiardi.create_line_material(color, linewidth);
  } else {
    let color = material.color;
    let map = material.map;
    let transparent = material.transparent;
    let opacity = material.opacity;
    return $savoiardi.create_sprite_material(color, transparent, opacity, map);
  }
}
