import * as $colour from "../../gleam_community_colour/gleam_community/colour.mjs";
import * as $json from "../../gleam_json/gleam/json.mjs";
import * as $decode from "../../gleam_stdlib/gleam/dynamic/decode.mjs";
import { toList } from "../gleam.mjs";
import * as $paint from "../paint.mjs";
import * as $types from "../paint/internal/types.mjs";
import { FontProperties, NoStroke, Radians, SolidStroke } from "../paint/internal/types.mjs";

function decode_angle() {
  return $decode.field(
    "radians",
    $decode.float,
    (radians) => { return $decode.success(new Radians(radians)); },
  );
}

function decode_font() {
  return $decode.field(
    "sizePx",
    $decode.int,
    (size_px) => {
      return $decode.field(
        "fontFamily",
        $decode.string,
        (font_family) => {
          return $decode.success(new FontProperties(size_px, font_family));
        },
      );
    },
  );
}

function decode_stroke() {
  return $decode.field(
    "type",
    $decode.string,
    (stroke_type) => {
      if (stroke_type === "noStroke") {
        return $decode.success(new NoStroke());
      } else if (stroke_type === "solidStroke") {
        return $decode.field(
          "colour",
          $colour.decoder(),
          (colour) => {
            return $decode.field(
              "thickness",
              $decode.float,
              (thickness) => {
                return $decode.success(new SolidStroke(colour, thickness));
              },
            );
          },
        );
      } else {
        return $decode.failure(new NoStroke(), "StrokeProperties");
      }
    },
  );
}

function decode_vec2() {
  return $decode.field(
    "x",
    $decode.float,
    (x) => {
      return $decode.field(
        "y",
        $decode.float,
        (y) => { return $decode.success([x, y]); },
      );
    },
  );
}

function decode_picture() {
  return $decode.recursive(
    () => {
      return $decode.field(
        "type",
        $decode.string,
        (ty) => {
          if (ty === "arc") {
            return $decode.field(
              "radius",
              $decode.float,
              (radius) => {
                return $decode.field(
                  "start",
                  decode_angle(),
                  (start) => {
                    return $decode.field(
                      "end",
                      decode_angle(),
                      (end) => {
                        return $decode.success(
                          new $types.Arc(radius, start, end),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (ty === "blank") {
            return $decode.success(new $types.Blank());
          } else if (ty === "combine") {
            return $decode.field(
              "pictures",
              $decode.list(decode_picture()),
              (pictures) => {
                return $decode.success(new $types.Combine(pictures));
              },
            );
          } else if (ty === "fill") {
            return $decode.field(
              "picture",
              decode_picture(),
              (picture) => {
                return $decode.field(
                  "colour",
                  $colour.decoder(),
                  (colour) => {
                    return $decode.success(new $types.Fill(picture, colour));
                  },
                );
              },
            );
          } else if (ty === "polygon") {
            return $decode.field(
              "points",
              $decode.list(decode_vec2()),
              (points) => {
                return $decode.field(
                  "closed",
                  $decode.bool,
                  (closed) => {
                    return $decode.success(new $types.Polygon(points, closed));
                  },
                );
              },
            );
          } else if (ty === "rotate") {
            return $decode.field(
              "angle",
              decode_angle(),
              (angle) => {
                return $decode.field(
                  "picture",
                  decode_picture(),
                  (picture) => {
                    return $decode.success(new $types.Rotate(picture, angle));
                  },
                );
              },
            );
          } else if (ty === "scale") {
            return $decode.field(
              "x",
              $decode.float,
              (x) => {
                return $decode.field(
                  "y",
                  $decode.float,
                  (y) => {
                    return $decode.field(
                      "picture",
                      decode_picture(),
                      (picture) => {
                        return $decode.success(
                          new $types.Scale(picture, [x, y]),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (ty === "stroke") {
            return $decode.field(
              "stroke",
              decode_stroke(),
              (stroke) => {
                return $decode.field(
                  "picture",
                  decode_picture(),
                  (picture) => {
                    return $decode.success(new $types.Stroke(picture, stroke));
                  },
                );
              },
            );
          } else if (ty === "text") {
            return $decode.field(
              "text",
              $decode.string,
              (text) => {
                return $decode.field(
                  "style",
                  decode_font(),
                  (style) => {
                    return $decode.success(new $types.Text(text, style));
                  },
                );
              },
            );
          } else if (ty === "translate") {
            return $decode.field(
              "x",
              $decode.float,
              (x) => {
                return $decode.field(
                  "y",
                  $decode.float,
                  (y) => {
                    return $decode.field(
                      "picture",
                      decode_picture(),
                      (picture) => {
                        return $decode.success(
                          new $types.Translate(picture, [x, y]),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (ty === "image") {
            return $decode.field(
              "id",
              $decode.string,
              (id) => {
                return $decode.field(
                  "width_px",
                  $decode.int,
                  (width_px) => {
                    return $decode.field(
                      "height_px",
                      $decode.int,
                      (height_px) => {
                        return $decode.success(
                          new $types.ImageRef(
                            new $types.Image(id),
                            width_px,
                            height_px,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (ty === "image_scaling_behaviour") {
            return $decode.field(
              "behaviour",
              $decode.string,
              (behaviour) => {
                return $decode.field(
                  "picture",
                  decode_picture(),
                  (picture) => {
                    if (behaviour === "smooth") {
                      return $decode.success(
                        new $types.ImageScalingBehaviour(
                          picture,
                          new $types.ScalingSmooth(),
                        ),
                      );
                    } else if (behaviour === "pixelated") {
                      return $decode.success(
                        new $types.ImageScalingBehaviour(
                          picture,
                          new $types.ScalingPixelated(),
                        ),
                      );
                    } else {
                      return $decode.failure(new $types.Blank(), "Picture");
                    }
                  },
                );
              },
            );
          } else {
            return $decode.failure(new $types.Blank(), "Picture");
          }
        },
      );
    },
  );
}

/**
 * Attempt to deserialize a `Picture`
 */
export function from_string(string) {
  let decoder = $decode.field(
    "picture",
    decode_picture(),
    (picture) => { return $decode.success(picture); },
  );
  return $json.parse(string, decoder);
}

function font_to_json(font) {
  let size_px;
  let font_family;
  size_px = font.size_px;
  font_family = font.font_family;
  return $json.object(
    toList([
      ["sizePx", $json.int(size_px)],
      ["fontFamily", $json.string(font_family)],
    ]),
  );
}

function stroke_to_json(stroke) {
  if (stroke instanceof NoStroke) {
    return $json.object(toList([["type", $json.string("noStroke")]]));
  } else {
    let colour = stroke[0];
    let thickness = stroke[1];
    return $json.object(
      toList([
        ["type", $json.string("solidStroke")],
        ["colour", $colour.encode(colour)],
        ["thickness", $json.float(thickness)],
      ]),
    );
  }
}

function angle_to_json(angle) {
  let rad;
  rad = angle[0];
  return $json.object(toList([["radians", $json.float(rad)]]));
}

function picture_to_json(picture) {
  if (picture instanceof $types.Blank) {
    return $json.object(toList([["type", $json.string("blank")]]));
  } else if (picture instanceof $types.Polygon) {
    let points = picture[0];
    let closed = picture.closed;
    return $json.object(
      toList([
        ["type", $json.string("polygon")],
        [
          "points",
          $json.array(
            points,
            (point) => {
              let x;
              let y;
              x = point[0];
              y = point[1];
              return $json.object(
                toList([["x", $json.float(x)], ["y", $json.float(y)]]),
              );
            },
          ),
        ],
        ["closed", $json.bool(closed)],
      ]),
    );
  } else if (picture instanceof $types.Arc) {
    let radius = picture.radius;
    let start = picture.start;
    let end = picture.end;
    return $json.object(
      toList([
        ["type", $json.string("arc")],
        ["radius", $json.float(radius)],
        ["start", angle_to_json(start)],
        ["end", angle_to_json(end)],
      ]),
    );
  } else if (picture instanceof $types.Text) {
    let text = picture.text;
    let style = picture.style;
    return $json.object(
      toList([
        ["type", $json.string("text")],
        ["text", $json.string(text)],
        ["style", font_to_json(style)],
      ]),
    );
  } else if (picture instanceof $types.ImageRef) {
    let width_px = picture.width_px;
    let height_px = picture.height_px;
    let id = picture[0].id;
    return $json.object(
      toList([
        ["type", $json.string("image")],
        ["id", $json.string(id)],
        ["width_px", $json.int(width_px)],
        ["height_px", $json.int(height_px)],
      ]),
    );
  } else if (picture instanceof $types.Fill) {
    let picture$1 = picture[0];
    let colour = picture[1];
    return $json.object(
      toList([
        ["type", $json.string("fill")],
        ["colour", $colour.encode(colour)],
        ["picture", picture_to_json(picture$1)],
      ]),
    );
  } else if (picture instanceof $types.Stroke) {
    let picture$1 = picture[0];
    let stroke = picture[1];
    return $json.object(
      toList([
        ["type", $json.string("stroke")],
        ["stroke", stroke_to_json(stroke)],
        ["picture", picture_to_json(picture$1)],
      ]),
    );
  } else if (picture instanceof $types.ImageScalingBehaviour) {
    let picture$1 = picture[0];
    let behaviour = picture[1];
    return $json.object(
      toList([
        ["type", $json.string("image_scaling_behaviour")],
        [
          "behaviour",
          $json.string(
            (() => {
              if (behaviour instanceof $types.ScalingSmooth) {
                return "smooth";
              } else {
                return "pixelated";
              }
            })(),
          ),
        ],
        ["picture", picture_to_json(picture$1)],
      ]),
    );
  } else if (picture instanceof $types.Translate) {
    let picture$1 = picture[0];
    let x = picture[1][0];
    let y = picture[1][1];
    return $json.object(
      toList([
        ["type", $json.string("translate")],
        ["x", $json.float(x)],
        ["y", $json.float(y)],
        ["picture", picture_to_json(picture$1)],
      ]),
    );
  } else if (picture instanceof $types.Scale) {
    let picture$1 = picture[0];
    let x = picture[1][0];
    let y = picture[1][1];
    return $json.object(
      toList([
        ["type", $json.string("scale")],
        ["x", $json.float(x)],
        ["y", $json.float(y)],
        ["picture", picture_to_json(picture$1)],
      ]),
    );
  } else if (picture instanceof $types.Rotate) {
    let picture$1 = picture[0];
    let angle = picture[1];
    return $json.object(
      toList([
        ["type", $json.string("rotate")],
        ["angle", angle_to_json(angle)],
        ["picture", picture_to_json(picture$1)],
      ]),
    );
  } else {
    let from = picture[0];
    return $json.object(
      toList([
        ["type", $json.string("combine")],
        ["pictures", $json.array(from, picture_to_json)],
      ]),
    );
  }
}

/**
 * Serialize a `Picture` to a string.
 *
 * Note, serializing an `Image` texture will only store an ID referencing the image. This means that if you deserialize a Picture containing
 * references to images, you are responsible for making sure all images are loaded before drawing the picture.
 * More advanced APIs to support use cases such as these are planned for a future release.
 *
 * Also, if you wish to store the serialized data, remember that the library currently makes no stability guarantee that
 * the data can be deserialized by *future* versions of the library.
 */
export function to_string(picture) {
  let version = "paint:unstable";
  let _pipe = $json.object(
    toList([
      ["version", $json.string(version)],
      ["picture", picture_to_json(picture)],
    ]),
  );
  return $json.to_string(_pipe);
}
