import * as $promise from "../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $bool from "../../gleam_stdlib/gleam/bool.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import * as $vec2 from "../../vec/vec/vec2.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { Ok, Error, CustomType as $CustomType } from "../gleam.mjs";
import * as $effect from "../tiramisu/effect.mjs";

class BoxGeometry extends $CustomType {
  constructor(width, height, depth) {
    super();
    this.width = width;
    this.height = height;
    this.depth = depth;
  }
}

class SphereGeometry extends $CustomType {
  constructor(radius, width_segments, height_segments) {
    super();
    this.radius = radius;
    this.width_segments = width_segments;
    this.height_segments = height_segments;
  }
}

class ConeGeometry extends $CustomType {
  constructor(radius, height, segments) {
    super();
    this.radius = radius;
    this.height = height;
    this.segments = segments;
  }
}

class PlaneGeometry extends $CustomType {
  constructor(width, height, width_segments, height_segments) {
    super();
    this.width = width;
    this.height = height;
    this.width_segments = width_segments;
    this.height_segments = height_segments;
  }
}

class CircleGeometry extends $CustomType {
  constructor(radius, segments) {
    super();
    this.radius = radius;
    this.segments = segments;
  }
}

class CylinderGeometry extends $CustomType {
  constructor(radius_top, radius_bottom, height, radial_segments) {
    super();
    this.radius_top = radius_top;
    this.radius_bottom = radius_bottom;
    this.height = height;
    this.radial_segments = radial_segments;
  }
}

class TorusGeometry extends $CustomType {
  constructor(radius, tube, radial_segments, tubular_segments) {
    super();
    this.radius = radius;
    this.tube = tube;
    this.radial_segments = radial_segments;
    this.tubular_segments = tubular_segments;
  }
}

class TetrahedronGeometry extends $CustomType {
  constructor(radius, detail) {
    super();
    this.radius = radius;
    this.detail = detail;
  }
}

class IcosahedronGeometry extends $CustomType {
  constructor(radius, detail) {
    super();
    this.radius = radius;
    this.detail = detail;
  }
}

class CustomGeometry extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class TextGeometry extends $CustomType {
  constructor(text, font, size, depth, curve_segments, bevel_enabled, bevel_thickness, bevel_size, bevel_offset, bevel_segments) {
    super();
    this.text = text;
    this.font = font;
    this.size = size;
    this.depth = depth;
    this.curve_segments = curve_segments;
    this.bevel_enabled = bevel_enabled;
    this.bevel_thickness = bevel_thickness;
    this.bevel_size = bevel_size;
    this.bevel_offset = bevel_offset;
    this.bevel_segments = bevel_segments;
  }
}

export class NonPositiveWidth extends $CustomType {
  constructor(width) {
    super();
    this.width = width;
  }
}
export const GeometryError$NonPositiveWidth = (width) =>
  new NonPositiveWidth(width);
export const GeometryError$isNonPositiveWidth = (value) =>
  value instanceof NonPositiveWidth;
export const GeometryError$NonPositiveWidth$width = (value) => value.width;
export const GeometryError$NonPositiveWidth$0 = (value) => value.width;

export class NonPositiveHeight extends $CustomType {
  constructor(height) {
    super();
    this.height = height;
  }
}
export const GeometryError$NonPositiveHeight = (height) =>
  new NonPositiveHeight(height);
export const GeometryError$isNonPositiveHeight = (value) =>
  value instanceof NonPositiveHeight;
export const GeometryError$NonPositiveHeight$height = (value) => value.height;
export const GeometryError$NonPositiveHeight$0 = (value) => value.height;

export class NonPositiveDepth extends $CustomType {
  constructor(depth) {
    super();
    this.depth = depth;
  }
}
export const GeometryError$NonPositiveDepth = (depth) =>
  new NonPositiveDepth(depth);
export const GeometryError$isNonPositiveDepth = (value) =>
  value instanceof NonPositiveDepth;
export const GeometryError$NonPositiveDepth$depth = (value) => value.depth;
export const GeometryError$NonPositiveDepth$0 = (value) => value.depth;

export class NonPositiveRadius extends $CustomType {
  constructor(radius) {
    super();
    this.radius = radius;
  }
}
export const GeometryError$NonPositiveRadius = (radius) =>
  new NonPositiveRadius(radius);
export const GeometryError$isNonPositiveRadius = (value) =>
  value instanceof NonPositiveRadius;
export const GeometryError$NonPositiveRadius$radius = (value) => value.radius;
export const GeometryError$NonPositiveRadius$0 = (value) => value.radius;

export class InvalidGeometryTube extends $CustomType {
  constructor(tube) {
    super();
    this.tube = tube;
  }
}
export const GeometryError$InvalidGeometryTube = (tube) =>
  new InvalidGeometryTube(tube);
export const GeometryError$isInvalidGeometryTube = (value) =>
  value instanceof InvalidGeometryTube;
export const GeometryError$InvalidGeometryTube$tube = (value) => value.tube;
export const GeometryError$InvalidGeometryTube$0 = (value) => value.tube;

export class LessThanThreeSegmentCountWidth extends $CustomType {
  constructor(count) {
    super();
    this.count = count;
  }
}
export const GeometryError$LessThanThreeSegmentCountWidth = (count) =>
  new LessThanThreeSegmentCountWidth(count);
export const GeometryError$isLessThanThreeSegmentCountWidth = (value) =>
  value instanceof LessThanThreeSegmentCountWidth;
export const GeometryError$LessThanThreeSegmentCountWidth$count = (value) =>
  value.count;
export const GeometryError$LessThanThreeSegmentCountWidth$0 = (value) =>
  value.count;

export class LessThanTwoSegmentCountHeight extends $CustomType {
  constructor(count) {
    super();
    this.count = count;
  }
}
export const GeometryError$LessThanTwoSegmentCountHeight = (count) =>
  new LessThanTwoSegmentCountHeight(count);
export const GeometryError$isLessThanTwoSegmentCountHeight = (value) =>
  value instanceof LessThanTwoSegmentCountHeight;
export const GeometryError$LessThanTwoSegmentCountHeight$count = (value) =>
  value.count;
export const GeometryError$LessThanTwoSegmentCountHeight$0 = (value) =>
  value.count;

export class NegativeSegmentCount extends $CustomType {
  constructor(count) {
    super();
    this.count = count;
  }
}
export const GeometryError$NegativeSegmentCount = (count) =>
  new NegativeSegmentCount(count);
export const GeometryError$isNegativeSegmentCount = (value) =>
  value instanceof NegativeSegmentCount;
export const GeometryError$NegativeSegmentCount$count = (value) => value.count;
export const GeometryError$NegativeSegmentCount$0 = (value) => value.count;

export class EmptyText extends $CustomType {}
export const GeometryError$EmptyText = () => new EmptyText();
export const GeometryError$isEmptyText = (value) => value instanceof EmptyText;

export class NonPositiveSize extends $CustomType {
  constructor(size) {
    super();
    this.size = size;
  }
}
export const GeometryError$NonPositiveSize = (size) =>
  new NonPositiveSize(size);
export const GeometryError$isNonPositiveSize = (value) =>
  value instanceof NonPositiveSize;
export const GeometryError$NonPositiveSize$size = (value) => value.size;
export const GeometryError$NonPositiveSize$0 = (value) => value.size;

export class NegativeBevelThickness extends $CustomType {
  constructor(thickness) {
    super();
    this.thickness = thickness;
  }
}
export const GeometryError$NegativeBevelThickness = (thickness) =>
  new NegativeBevelThickness(thickness);
export const GeometryError$isNegativeBevelThickness = (value) =>
  value instanceof NegativeBevelThickness;
export const GeometryError$NegativeBevelThickness$thickness = (value) =>
  value.thickness;
export const GeometryError$NegativeBevelThickness$0 = (value) =>
  value.thickness;

export class NegativeBevelSize extends $CustomType {
  constructor(size) {
    super();
    this.size = size;
  }
}
export const GeometryError$NegativeBevelSize = (size) =>
  new NegativeBevelSize(size);
export const GeometryError$isNegativeBevelSize = (value) =>
  value instanceof NegativeBevelSize;
export const GeometryError$NegativeBevelSize$size = (value) => value.size;
export const GeometryError$NegativeBevelSize$0 = (value) => value.size;

/**
 * Create a validated box geometry.
 *
 * All dimensions must be positive (> 0).
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(cube) = geometry.box(size: vec3.Vec3(1.0, 1.0, 1.0))
 * let assert Ok(wall) = geometry.box(size: vec3.Vec3(10.0, 3.0, 0.1))
 * ```
 */
export function box(size) {
  return $bool.guard(
    size.x <= 0.0,
    new Error(new NonPositiveWidth(size.x)),
    () => {
      return $bool.guard(
        size.y <= 0.0,
        new Error(new NonPositiveHeight(size.y)),
        () => {
          return $bool.guard(
            size.z <= 0.0,
            new Error(new NonPositiveDepth(size.z)),
            () => { return new Ok(new BoxGeometry(size.x, size.y, size.z)); },
          );
        },
      );
    },
  );
}

/**
 * Create a validated sphere geometry.
 *
 * Radius must be positive. Width segments >= 3, height segments >= 2.
 * More segments = smoother sphere but more triangles.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(ball) = geometry.sphere(radius: 1.0, segments: vec2.Vec2(32, 16))
 * let assert Ok(low_poly) = geometry.sphere(radius: 1.0, segments: vec2.Vec2(8, 6))
 * ```
 */
export function sphere(radius, segments) {
  return $bool.guard(
    radius <= 0.0,
    new Error(new NonPositiveRadius(radius)),
    () => {
      return $bool.guard(
        segments.x < 3,
        new Error(new LessThanThreeSegmentCountWidth(segments.x)),
        () => {
          return $bool.guard(
            segments.y < 2,
            new Error(new LessThanTwoSegmentCountHeight(segments.y)),
            () => {
              return new Ok(new SphereGeometry(radius, segments.x, segments.y));
            },
          );
        },
      );
    },
  );
}

export function cone(radius, height, segments) {
  return $bool.guard(
    radius <= 0.0,
    new Error(new NonPositiveRadius(radius)),
    () => {
      return $bool.guard(
        height <= 0.0,
        new Error(new NonPositiveHeight(height)),
        () => {
          return $bool.guard(
            segments < 3,
            new Error(new NegativeSegmentCount(segments)),
            () => { return new Ok(new ConeGeometry(radius, height, segments)); },
          );
        },
      );
    },
  );
}

export function sheet(size, segments) {
  return $bool.guard(
    size.x <= 0.0,
    new Error(new NonPositiveWidth(size.x)),
    () => {
      return $bool.guard(
        size.y <= 0.0,
        new Error(new NonPositiveHeight(size.y)),
        () => {
          return $bool.guard(
            segments.x < 1,
            new Error(new NegativeSegmentCount(segments.x)),
            () => {
              return $bool.guard(
                segments.y < 1,
                new Error(new NegativeSegmentCount(segments.y)),
                () => {
                  return new Ok(
                    new PlaneGeometry(size.x, size.y, segments.x, segments.y),
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

export function plane(size) {
  return sheet(size, new $vec2.Vec2(1, 1));
}

export function circle(radius, segments) {
  return $bool.guard(
    radius <= 0.0,
    new Error(new NonPositiveRadius(radius)),
    () => {
      return $bool.guard(
        segments < 3,
        new Error(new NegativeSegmentCount(segments)),
        () => { return new Ok(new CircleGeometry(radius, segments)); },
      );
    },
  );
}

export function custom_geometry(geometry) {
  return new CustomGeometry(geometry);
}

/**
 * Create a validated cylinder geometry.
 *
 * Both radii must be non-negative, height positive, radial segments >= 3.
 * Set one radius to 0 to create a cone shape.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(cylinder) = scene.cylinder(radius_top: 1.0, radius_bottom: 1.0, height: 2.0, radial_segments: 32)
 * let assert Ok(cone) = scene.cylinder(radius_top: 0.0, radius_bottom: 1.0, height: 2.0, radial_segments: 32)
 * ```
 */
export function cylinder(radius_top, radius_bottom, height, radial_segments) {
  return $bool.guard(
    radius_top < 0.0,
    new Error(new NonPositiveRadius(radius_top)),
    () => {
      return $bool.guard(
        radius_bottom < 0.0,
        new Error(new NonPositiveRadius(radius_bottom)),
        () => {
          return $bool.guard(
            height <= 0.0,
            new Error(new NonPositiveHeight(height)),
            () => {
              return $bool.guard(
                radial_segments < 3,
                new Error(new NegativeSegmentCount(radial_segments)),
                () => {
                  return new Ok(
                    new CylinderGeometry(
                      radius_top,
                      radius_bottom,
                      height,
                      radial_segments,
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
 * Create a validated torus (donut) geometry.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(donut) = scene.torus(radius: 2.0, tube: 0.5, radial_segments: 16, tubular_segments: 100)
 * ```
 */
export function torus(radius, tube, radial_segments, tubular_segments) {
  return $bool.guard(
    radius <= 0.0,
    new Error(new NonPositiveRadius(radius)),
    () => {
      return $bool.guard(
        tube <= 0.0,
        new Error(new InvalidGeometryTube(tube)),
        () => {
          return $bool.guard(
            radial_segments < 3,
            new Error(new NegativeSegmentCount(radial_segments)),
            () => {
              return $bool.guard(
                tubular_segments < 3,
                new Error(new NegativeSegmentCount(tubular_segments)),
                () => {
                  return new Ok(
                    new TorusGeometry(
                      radius,
                      tube,
                      radial_segments,
                      tubular_segments,
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
 * Create a validated tetrahedron (4-sided polyhedron) geometry.
 *
 * Detail level controls subdivision (0 = no subdivision, higher = more triangles).
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(shape) = scene.tetrahedron(radius: 1.0, detail: 0)
 * ```
 */
export function tetrahedron(radius, detail) {
  return $bool.guard(
    radius <= 0.0,
    new Error(new NonPositiveRadius(radius)),
    () => {
      return $bool.guard(
        detail < 0,
        new Error(new NegativeSegmentCount(detail)),
        () => { return new Ok(new TetrahedronGeometry(radius, detail)); },
      );
    },
  );
}

/**
 * Create a validated icosahedron (20-sided polyhedron) geometry.
 *
 * Detail level controls subdivision. Good for creating spheres with flat faces.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(shape) = scene.icosahedron(radius: 1.0, detail: 2)
 * ```
 */
export function icosahedron(radius, detail) {
  return $bool.guard(
    radius <= 0.0,
    new Error(new NonPositiveRadius(radius)),
    () => {
      return $bool.guard(
        detail < 0,
        new Error(new NegativeSegmentCount(detail)),
        () => { return new Ok(new IcosahedronGeometry(radius, detail)); },
      );
    },
  );
}

/**
 * Create validated 3D text geometry from a loaded font.
 *
 * Renders text as 3D geometry with optional beveling (rounded edges).
 * Requires a font loaded via `geometry.load_font()`.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/geometry
 *
 * // After loading font with geometry.load_font()...
 * let assert Ok(text) = geometry.text(
 *   text: "Hello!",
 *   font: my_font,
 *   size: 1.0,
 *   depth: 0.2,
 *   curve_segments: 12,
 *   bevel_enabled: True,
 *   bevel_thickness: 0.05,
 *   bevel_size: 0.02,
 *   bevel_offset: 0.0,
 *   bevel_segments: 5,
 * )
 * ```
 */
export function text(
  text,
  font,
  size,
  depth,
  curve_segments,
  bevel_enabled,
  bevel_thickness,
  bevel_size,
  bevel_offset,
  bevel_segments
) {
  return $bool.guard(
    text === "",
    new Error(new EmptyText()),
    () => {
      return $bool.guard(
        size <= 0.0,
        new Error(new NonPositiveSize(size)),
        () => {
          return $bool.guard(
            depth < 0.0,
            new Error(new NonPositiveDepth(depth)),
            () => {
              return $bool.guard(
                curve_segments < 1,
                new Error(new NegativeSegmentCount(curve_segments)),
                () => {
                  return $bool.guard(
                    bevel_thickness < 0.0,
                    new Error(new NegativeBevelThickness(bevel_thickness)),
                    () => {
                      return $bool.guard(
                        bevel_size < 0.0,
                        new Error(new NegativeBevelSize(bevel_size)),
                        () => {
                          return $bool.guard(
                            bevel_segments < 1,
                            new Error(new NegativeSegmentCount(bevel_segments)),
                            () => {
                              return new Ok(
                                new TextGeometry(
                                  text,
                                  font,
                                  size,
                                  depth,
                                  curve_segments,
                                  bevel_enabled,
                                  bevel_thickness,
                                  bevel_size,
                                  bevel_offset,
                                  bevel_segments,
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
    },
  );
}

export function create_geometry(geometry) {
  if (geometry instanceof BoxGeometry) {
    let width = geometry.width;
    let height = geometry.height;
    let depth = geometry.depth;
    return $savoiardi.create_box_geometry(width, height, depth);
  } else if (geometry instanceof SphereGeometry) {
    let radius = geometry.radius;
    let width_segments = geometry.width_segments;
    let height_segments = geometry.height_segments;
    return $savoiardi.create_sphere_geometry(
      radius,
      width_segments,
      height_segments,
    );
  } else if (geometry instanceof ConeGeometry) {
    let radius = geometry.radius;
    let height = geometry.height;
    let segments = geometry.segments;
    return $savoiardi.create_cone_geometry(radius, height, segments);
  } else if (geometry instanceof PlaneGeometry) {
    let width = geometry.width;
    let height = geometry.height;
    let width_segments = geometry.width_segments;
    let height_segments = geometry.height_segments;
    return $savoiardi.create_plane_geometry(
      width,
      height,
      width_segments,
      height_segments,
    );
  } else if (geometry instanceof CircleGeometry) {
    let radius = geometry.radius;
    let segments = geometry.segments;
    return $savoiardi.create_circle_geometry(radius, segments);
  } else if (geometry instanceof CylinderGeometry) {
    let radius_top = geometry.radius_top;
    let radius_bottom = geometry.radius_bottom;
    let height = geometry.height;
    let radial_segments = geometry.radial_segments;
    return $savoiardi.create_cylinder_geometry(
      radius_top,
      radius_bottom,
      height,
      radial_segments,
    );
  } else if (geometry instanceof TorusGeometry) {
    let radius = geometry.radius;
    let tube = geometry.tube;
    let radial_segments = geometry.radial_segments;
    let tubular_segments = geometry.tubular_segments;
    return $savoiardi.create_torus_geometry(
      radius,
      tube,
      radial_segments,
      tubular_segments,
    );
  } else if (geometry instanceof TetrahedronGeometry) {
    let radius = geometry.radius;
    let detail = geometry.detail;
    return $savoiardi.create_tetrahedron_geometry(radius, detail);
  } else if (geometry instanceof IcosahedronGeometry) {
    let radius = geometry.radius;
    let detail = geometry.detail;
    return $savoiardi.create_icosahedron_geometry(radius, detail);
  } else if (geometry instanceof CustomGeometry) {
    let buffer = geometry[0];
    return buffer;
  } else {
    let text$1 = geometry.text;
    let font = geometry.font;
    let size = geometry.size;
    let depth = geometry.depth;
    let curve_segments = geometry.curve_segments;
    let bevel_enabled = geometry.bevel_enabled;
    let bevel_thickness = geometry.bevel_thickness;
    let bevel_size = geometry.bevel_size;
    let bevel_offset = geometry.bevel_offset;
    let bevel_segments = geometry.bevel_segments;
    return $savoiardi.create_text_geometry(
      text$1,
      font,
      size,
      depth,
      curve_segments,
      bevel_enabled,
      bevel_thickness,
      bevel_size,
      bevel_offset,
      bevel_segments,
    );
  }
}

export function load_font(url, on_success, on_error) {
  let _block;
  let _pipe = $savoiardi.load_font(url);
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

export function load_stl(url, on_success, on_error) {
  let _block;
  let _pipe = $savoiardi.load_stl(url);
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
 * Centers a geometry around its bounding box center.
 *
 * This is useful for STL or OBJ models that need to rotate around their
 * geometric center rather than their original origin point.
 *
 * Many CAD-exported models have their origin at an arbitrary location.
 * Call this function after loading to ensure the model rotates around
 * its visual center.
 *
 * ## Example
 *
 * ```gleam
 * use result <- promise.await(geometry.load_stl("/models/part.stl"))
 * case result {
 *   Ok(geom) -> {
 *     // Center the geometry so it rotates around its middle
 *     let centered = geometry.center(geom)
 *     // Use centered geometry in your mesh...
 *   }
 *   Error(Nil) -> // handle error
 * }
 * ```
 */
export function center(geometry) {
  return $savoiardi.center_geometry(geometry);
}
