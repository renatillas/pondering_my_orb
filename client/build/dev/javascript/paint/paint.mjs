import * as $colour from "../gleam_community_colour/gleam_community/colour.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import { toList, makeError } from "./gleam.mjs";
import { pi } from "./numbers_ffi.mjs";
import * as $internal_implementation from "./paint/internal/types.mjs";

const FILEPATH = "src/paint.gleam";

/**
 * Create an angle expressed in radians
 */
export function angle_rad(radians) {
  return new $internal_implementation.Radians(radians);
}

/**
 * A utility around [colour.from_rgb_hex_string](https://hexdocs.pm/gleam_community_colour/gleam_community/colour.html#from_rgb_hex_string)
 * (from `gleam_community/colour`) that **panics** on an invalid hex code.
 */
export function colour_hex(string) {
  return $result.lazy_unwrap(
    $colour.from_rgb_hex_string(string),
    () => {
      throw makeError(
        "panic",
        FILEPATH,
        "paint",
        47,
        "colour_hex",
        "Failed to parse hex code",
        {}
      )
    },
  );
}

/**
 * A utility around [colour.from_rgb255](https://hexdocs.pm/gleam_community_colour/gleam_community/colour.html#from_rgb255)
 * (from `gleam_community/colour`) that **panics** if the values are outside of the allowed range.
 */
export function colour_rgb(red, green, blue) {
  return $result.lazy_unwrap(
    $colour.from_rgb255(red, green, blue),
    () => {
      throw makeError(
        "panic",
        FILEPATH,
        "paint",
        55,
        "colour_rgb",
        "The value was not inside of the valid range [0-255]",
        {}
      )
    },
  );
}

/**
 * A blank picture
 */
export function blank() {
  return new $internal_implementation.Blank();
}

/**
 * An arc with some radius going from some
 * starting angle to some other angle in clock-wise direction
 */
export function arc(radius, start, end) {
  return new $internal_implementation.Arc(radius, start, end);
}

/**
 * A polygon consisting of a list of 2d points
 */
export function polygon(points) {
  return new $internal_implementation.Polygon(points, true);
}

/**
 * Lines (same as a polygon but not a closed shape)
 */
export function lines(points) {
  return new $internal_implementation.Polygon(points, false);
}

/**
 * A rectangle with some given width and height
 */
export function rectangle(width, height) {
  return polygon(
    toList([[0.0, 0.0], [width, 0.0], [width, height], [0.0, height]]),
  );
}

/**
 * A square
 */
export function square(length) {
  return rectangle(length, length);
}

/**
 * Draw an image such as a PNG, JPEG or an SVG. See the `canvas` back-end for more details on how to load images.
 */
export function image(image, width_px, height_px) {
  return new $internal_implementation.ImageRef(image, width_px, height_px);
}

/**
 * Set image scaling to be smooth (this is the default behaviour)
 */
export function image_scaling_smooth(picture) {
  return new $internal_implementation.ImageScalingBehaviour(
    picture,
    new $internal_implementation.ScalingSmooth(),
  );
}

/**
 * Disable smooth image scaling, suitable for pixel art.
 */
export function image_scaling_pixelated(picture) {
  return new $internal_implementation.ImageScalingBehaviour(
    picture,
    new $internal_implementation.ScalingPixelated(),
  );
}

/**
 * Text with some given font size
 */
export function text(text, font_size) {
  return new $internal_implementation.Text(
    text,
    new $internal_implementation.FontProperties(font_size, "sans-serif"),
  );
}

/**
 * Translate a picture in horizontal and vertical direction
 */
export function translate_xy(picture, x, y) {
  return new $internal_implementation.Translate(picture, [x, y]);
}

/**
 * Translate a picture in the horizontal direction
 */
export function translate_x(picture, x) {
  return translate_xy(picture, x, 0.0);
}

/**
 * Translate a picture in the vertical direction
 */
export function translate_y(picture, y) {
  return translate_xy(picture, 0.0, y);
}

/**
 * Scale the picture in the horizontal direction
 */
export function scale_x(picture, factor) {
  return new $internal_implementation.Scale(picture, [factor, 1.0]);
}

/**
 * Scale the picture in the vertical direction
 */
export function scale_y(picture, factor) {
  return new $internal_implementation.Scale(picture, [1.0, factor]);
}

/**
 * Scale the picture uniformly in horizontal and vertical direction
 */
export function scale_uniform(picture, factor) {
  return new $internal_implementation.Scale(picture, [factor, factor]);
}

/**
 * Rotate the picture in a clock-wise direction
 */
export function rotate(picture, angle) {
  return new $internal_implementation.Rotate(picture, angle);
}

/**
 * Fill a picture with some given colour, see `Colour`.
 */
export function fill(picture, colour) {
  return new $internal_implementation.Fill(picture, colour);
}

/**
 * Set a solid stroke with some given colour and width
 */
export function stroke(picture, colour, width) {
  return new $internal_implementation.Stroke(
    picture,
    new $internal_implementation.SolidStroke(colour, width),
  );
}

/**
 * Remove the stroke of the given picture
 */
export function stroke_none(picture) {
  return new $internal_implementation.Stroke(
    picture,
    new $internal_implementation.NoStroke(),
  );
}

/**
 * Combine multiple pictures into one
 */
export function combine(pictures) {
  return new $internal_implementation.Combine(pictures);
}

/**
 * Concatenate two pictures
 */
export function concat(picture, another_picture) {
  return combine(toList([picture, another_picture]));
}

/**
 * Create an angle expressed in degrees
 */
export function angle_deg(degrees) {
  return new $internal_implementation.Radians(((degrees * pi())) / 180.0);
}

/**
 * A circle with some given radius
 */
export function circle(radius) {
  return new $internal_implementation.Arc(
    radius,
    new $internal_implementation.Radians(0.0),
    new $internal_implementation.Radians(2.0 * pi()),
  );
}
