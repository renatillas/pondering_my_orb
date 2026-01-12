import * as $colour from "../../gleam_community_colour/gleam_community/colour.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import { Ok, Empty as $Empty, CustomType as $CustomType, makeError } from "../gleam.mjs";
import * as $paint from "../paint.mjs";
import { translate_xy } from "../paint.mjs";
import * as $encode from "../paint/encode.mjs";
import * as $event from "../paint/event.mjs";
import * as $impl_canvas from "../paint/internal/impl_canvas.mjs";
import * as $types from "../paint/internal/types.mjs";
import {
  Arc,
  Blank,
  Combine,
  Fill,
  FontProperties,
  Image,
  NoStroke,
  Polygon,
  Radians,
  Rotate,
  Scale,
  SolidStroke,
  Stroke,
  Text,
  Translate,
} from "../paint/internal/types.mjs";

const FILEPATH = "src/paint/canvas.gleam";

export class Config extends $CustomType {
  constructor(width, height) {
    super();
    this.width = width;
    this.height = height;
  }
}
export const Config$Config = (width, height) => new Config(width, height);
export const Config$isConfig = (value) => value instanceof Config;
export const Config$Config$width = (value) => value.width;
export const Config$Config$0 = (value) => value.width;
export const Config$Config$height = (value) => value.height;
export const Config$Config$1 = (value) => value.height;

class DrawingState extends $CustomType {
  constructor(fill, stroke) {
    super();
    this.fill = fill;
    this.stroke = stroke;
  }
}

const default_drawing_state = /* @__PURE__ */ new DrawingState(false, true);

/**
 * Create a reference to an image using a CSS query selector. For example:
 * ```
 * fn kitten() {
 *  canvas.image_from_query("#kitten")
 * }
 * // In the HTML file:
 * // <img
 * //  style="display: none"
 * //  src="https://upload.wikimedia.org/wikipedia/commons/4/4d/Cat_November_2010-1a.jpg"
 * //  id="kitten"
 * // />
 * ```
 *
 * > [!WARNING]
 * > **Important**: Make sure the image has loaded before trying to draw a pictures referencing it.
 * > You can do this using `canvas.wait_until_loaded` function.
 */
export function image_from_query(selector) {
  let id = "image-selector-" + selector;
  let $ = $impl_canvas.get_global(id);
  if ($ instanceof Ok) {
    undefined
  } else {
    let image = $impl_canvas.image_from_query(selector);
    $impl_canvas.set_global(image, id)
  }
  return new Image(id);
}

/**
 * Create a reference to an image using a source path.
 * ```
 * fn my_logo_image() {
 *   canvas.image_from_src("./priv/static/logo.svg")
 * }
 * ```
 *
 * > [!WARNING]
 * > **Important**: Make sure the image has loaded before trying to draw a pictures referencing it.
 * > You can do this using `canvas.wait_until_loaded` function.
 */
export function image_from_src(src) {
  let id = "image-src-" + src;
  let $ = $impl_canvas.get_global(id);
  if ($ instanceof Ok) {
    undefined
  } else {
    let image = $impl_canvas.image_from_src(src);
    $impl_canvas.set_global(image, id)
  }
  return new Image(id);
}

/**
 * Wait until a list of images have all been loaded, for example:
 * ```
 * fn lucy() {
 *  canvas.image_from_query("#lucy")
 * }
 *
 * fn cat() {
 *   canvas.image_from_src("./path/to/kitten.png")
 * }
 *
 * pub fn main() {
 *  use <- canvas.wait_until_loaded([lucy(), kitten()])
 *  // It is now safe to draw Pictures containing the images lucy and kitten :)
 * }
 * ```
 */
export function wait_until_loaded(images, on_loaded) {
  if (images instanceof $Empty) {
    return on_loaded();
  } else {
    let image = images.head;
    let rest = images.tail;
    let id;
    id = image.id;
    let $ = $impl_canvas.get_global(id);
    let js_image;
    if ($ instanceof Ok) {
      js_image = $[0];
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "paint/canvas",
        101,
        "wait_until_loaded",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $,
          start: 3025,
          end: 3077,
          pattern_start: 3036,
          pattern_end: 3048
        }
      )
    }
    return $impl_canvas.on_image_load(
      js_image,
      () => { return wait_until_loaded(rest, on_loaded); },
    );
  }
}

function display_on_rendering_context(loop$picture, loop$ctx, loop$state) {
  while (true) {
    let picture = loop$picture;
    let ctx = loop$ctx;
    let state = loop$state;
    if (picture instanceof Blank) {
      return undefined;
    } else if (picture instanceof Polygon) {
      let points = picture[0];
      let closed = picture.closed;
      return $impl_canvas.polygon(ctx, points, closed, state.fill, state.stroke);
    } else if (picture instanceof Arc) {
      let radius = picture.radius;
      let start = picture.start;
      let end = picture.end;
      let start_radians;
      start_radians = start[0];
      let end_radians;
      end_radians = end[0];
      return $impl_canvas.arc(
        ctx,
        radius,
        start_radians,
        end_radians,
        state.fill,
        state.stroke,
      );
    } else if (picture instanceof Text) {
      let text = picture.text;
      let properties = picture.style;
      let size_px;
      let font_family;
      size_px = properties.size_px;
      font_family = properties.font_family;
      $impl_canvas.save(ctx);
      $impl_canvas.text(
        ctx,
        text,
        ($int.to_string(size_px) + "px ") + font_family,
      );
      return $impl_canvas.restore(ctx);
    } else if (picture instanceof $types.ImageRef) {
      let width_px = picture.width_px;
      let height_px = picture.height_px;
      let id = picture[0].id;
      let $ = $impl_canvas.get_global(id);
      let image;
      if ($ instanceof Ok) {
        image = $[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "paint/canvas",
          231,
          "display_on_rendering_context",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $,
            start: 6608,
            end: 6657,
            pattern_start: 6619,
            pattern_end: 6628
          }
        )
      }
      return $impl_canvas.draw_image(ctx, image, width_px, height_px);
    } else if (picture instanceof Fill) {
      let p = picture[0];
      let colour = picture[1];
      $impl_canvas.save(ctx);
      $impl_canvas.set_fill_colour(ctx, $colour.to_css_rgba_string(colour));
      display_on_rendering_context(p, ctx, new DrawingState(true, state.stroke));
      return $impl_canvas.restore(ctx);
    } else if (picture instanceof Stroke) {
      let p = picture[0];
      let stroke = picture[1];
      if (stroke instanceof NoStroke) {
        loop$picture = p;
        loop$ctx = ctx;
        loop$state = new DrawingState(state.fill, false);
      } else {
        let color = stroke[0];
        let width = stroke[1];
        $impl_canvas.save(ctx);
        $impl_canvas.set_stroke_color(ctx, $colour.to_css_rgba_string(color));
        $impl_canvas.set_line_width(ctx, width);
        display_on_rendering_context(p, ctx, new DrawingState(state.fill, true));
        return $impl_canvas.restore(ctx);
      }
    } else if (picture instanceof $types.ImageScalingBehaviour) {
      let p = picture[0];
      let behaviour = picture[1];
      $impl_canvas.save(ctx);
      $impl_canvas.set_image_smoothing_enabled(
        ctx,
        (() => {
          if (behaviour instanceof $types.ScalingSmooth) {
            return true;
          } else {
            return false;
          }
        })(),
      );
      display_on_rendering_context(p, ctx, state);
      return $impl_canvas.restore(ctx);
    } else if (picture instanceof Translate) {
      let p = picture[0];
      let vec = picture[1];
      let x;
      let y;
      x = vec[0];
      y = vec[1];
      $impl_canvas.save(ctx);
      $impl_canvas.translate(ctx, x, y);
      display_on_rendering_context(p, ctx, state);
      return $impl_canvas.restore(ctx);
    } else if (picture instanceof Scale) {
      let p = picture[0];
      let vec = picture[1];
      let x;
      let y;
      x = vec[0];
      y = vec[1];
      $impl_canvas.save(ctx);
      $impl_canvas.scale(ctx, x, y);
      display_on_rendering_context(p, ctx, state);
      return $impl_canvas.restore(ctx);
    } else if (picture instanceof Rotate) {
      let p = picture[0];
      let angle = picture[1];
      let rad;
      rad = angle[0];
      $impl_canvas.save(ctx);
      $impl_canvas.rotate(ctx, rad);
      display_on_rendering_context(p, ctx, state);
      return $impl_canvas.restore(ctx);
    } else {
      let pictures = picture[0];
      if (pictures instanceof $Empty) {
        return undefined;
      } else {
        let p = pictures.head;
        let ps = pictures.tail;
        display_on_rendering_context(p, ctx, state);
        loop$picture = new Combine(ps);
        loop$ctx = ctx;
        loop$state = state;
      }
    }
  }
}

function parse_key_code(key_code) {
  if (key_code === 32) {
    return new Some(new $event.KeySpace());
  } else if (key_code === 37) {
    return new Some(new $event.KeyLeftArrow());
  } else if (key_code === 38) {
    return new Some(new $event.KeyUpArrow());
  } else if (key_code === 39) {
    return new Some(new $event.KeyRightArrow());
  } else if (key_code === 40) {
    return new Some(new $event.KeyDownArrow());
  } else if (key_code === 87) {
    return new Some(new $event.KeyW());
  } else if (key_code === 65) {
    return new Some(new $event.KeyA());
  } else if (key_code === 83) {
    return new Some(new $event.KeyS());
  } else if (key_code === 68) {
    return new Some(new $event.KeyD());
  } else if (key_code === 90) {
    return new Some(new $event.KeyZ());
  } else if (key_code === 88) {
    return new Some(new $event.KeyX());
  } else if (key_code === 67) {
    return new Some(new $event.KeyC());
  } else if (key_code === 18) {
    return new Some(new $event.KeyEnter());
  } else if (key_code === 27) {
    return new Some(new $event.KeyEscape());
  } else if (key_code === 8) {
    return new Some(new $event.KeyBackspace());
  } else {
    return new None();
  }
}

/**
 * Utility to set the origin in the center of the canvas
 */
export function center(picture) {
  return (config) => {
    let width;
    let height;
    width = config.width;
    height = config.height;
    let _pipe = picture;
    return translate_xy(_pipe, width * 0.5, height * 0.5);
  };
}

/**
 * Display a picture on a HTML canvas element
 * (specified by some [CSS Selector](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_selectors)).
 * ```
 * canvas.display(fn (_: canvas.Config) { circle(50.0) }, "#mycanvas")
 * ```
 */
export function display(init, selector) {
  let ctx = $impl_canvas.get_rendering_context(selector);
  $impl_canvas.reset(ctx);
  let picture = init(
    new Config($impl_canvas.get_width(ctx), $impl_canvas.get_height(ctx)),
  );
  return display_on_rendering_context(picture, ctx, default_drawing_state);
}

function get_tick_func(ctx, view, update, selector) {
  return (time) => {
    let $ = $impl_canvas.get_global(selector);
    let current_state;
    if ($ instanceof Ok) {
      current_state = $[0];
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "paint/canvas",
        399,
        "get_tick_func",
        "Pattern match failed, no pattern matched the value.",
        {
          value: $,
          start: 11581,
          end: 11644,
          pattern_start: 11592,
          pattern_end: 11609
        }
      )
    }
    let new_state = update(current_state, new $event.Tick(time));
    $impl_canvas.set_global(new_state, selector);
    let picture = view(new_state);
    $impl_canvas.reset(ctx);
    display_on_rendering_context(picture, ctx, default_drawing_state);
    return $impl_canvas.setup_request_animation_frame(
      get_tick_func(ctx, view, update, selector),
    );
  };
}

/**
 * Animations, interactive applications and tiny games can be built using the
 * `interact` function. It roughly follows the [Elm architecture](https://guide.elm-lang.org/architecture/).
 * Here is a short example:
 * ```
 * type State =
 *   Int
 *
 * fn init(_: canvas.Config) -> State {
 *   0
 * }
 *
 * fn update(state: State, event: event.Event) -> State {
 *   case event {
 *     event.Tick(_) -> state + 1
 *     _ -> state
 *   }
 * }
 *
 * fn view(state: State) -> Picture {
 *   paint.circle(int.to_float(state))
 * }
 *
 * fn main() {
 *   interact(init, update, view, "#mycanvas")
 * }
 * ```
 */
export function interact(init, update, view, selector) {
  let ctx = $impl_canvas.get_rendering_context(selector);
  let initial_state = init(
    new Config($impl_canvas.get_width(ctx), $impl_canvas.get_height(ctx)),
  );
  $impl_canvas.set_global(initial_state, selector);
  let create_key_handler = (event_name, constructor) => {
    return $impl_canvas.setup_input_handler(
      event_name,
      (event) => {
        let key = parse_key_code($impl_canvas.get_key_code(event));
        if (key instanceof Some) {
          let key$1 = key[0];
          let $ = $impl_canvas.get_global(selector);
          let old_state;
          if ($ instanceof Ok) {
            old_state = $[0];
          } else {
            throw makeError(
              "let_assert",
              FILEPATH,
              "paint/canvas",
              292,
              "interact",
              "Pattern match failed, no pattern matched the value.",
              {
                value: $,
                start: 8332,
                end: 8391,
                pattern_start: 8343,
                pattern_end: 8356
              }
            )
          }
          let new_state = update(old_state, constructor(key$1));
          return $impl_canvas.set_global(new_state, selector);
        } else {
          return undefined;
        }
      },
    );
  };
  create_key_handler(
    "keydown",
    (var0) => { return new $event.KeyboardPressed(var0); },
  );
  create_key_handler(
    "keyup",
    (var0) => { return new $event.KeyboardRelased(var0); },
  );
  $impl_canvas.setup_input_handler(
    "mousemove",
    (event) => {
      let $ = $impl_canvas.mouse_pos(ctx, event);
      let x;
      let y;
      x = $[0];
      y = $[1];
      let $1 = $impl_canvas.get_global(selector);
      let old_state;
      if ($1 instanceof Ok) {
        old_state = $1[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "paint/canvas",
          309,
          "interact",
          "Pattern match failed, no pattern matched the value.",
          {
            value: $1,
            start: 8863,
            end: 8922,
            pattern_start: 8874,
            pattern_end: 8887
          }
        )
      }
      let new_state = update(old_state, new $event.MouseMoved(x, y));
      $impl_canvas.set_global(new_state, selector);
      return undefined;
    },
  );
  let create_mouse_button_handler = (event_name, constructor, check_pressed) => {
    return $impl_canvas.setup_input_handler(
      event_name,
      (event) => {
        let previous_event_id = "PAINT_PREVIOUS_MOUSE_INPUT_FOR_" + selector;
        let previous_event = $impl_canvas.get_global(previous_event_id);
        $impl_canvas.set_global(event, previous_event_id);
        let check_button = (i) => {
          return $impl_canvas.check_mouse_button(
            event,
            previous_event,
            i,
            check_pressed,
          );
        };
        let trigger_update = (button) => {
          let $ = $impl_canvas.get_global(selector);
          let old_state;
          if ($ instanceof Ok) {
            old_state = $[0];
          } else {
            throw makeError(
              "let_assert",
              FILEPATH,
              "paint/canvas",
              338,
              "interact",
              "Pattern match failed, no pattern matched the value.",
              {
                value: $,
                start: 9856,
                end: 9915,
                pattern_start: 9867,
                pattern_end: 9880
              }
            )
          }
          let new_state = update(old_state, constructor(button));
          return $impl_canvas.set_global(new_state, selector);
        };
        let $ = check_button(0);
        if ($) {
          trigger_update(new $event.MouseButtonLeft())
        } else {
          undefined
        }
        let $1 = check_button(1);
        if ($1) {
          trigger_update(new $event.MouseButtonRight())
        } else {
          undefined
        }
        let $2 = check_button(2);
        if ($2) {
          trigger_update(new $event.MouseButtonMiddle())
        } else {
          undefined
        }
        return undefined;
      },
    );
  };
  create_mouse_button_handler(
    "mousedown",
    (var0) => { return new $event.MousePressed(var0); },
    true,
  );
  create_mouse_button_handler(
    "mouseup",
    (var0) => { return new $event.MouseReleased(var0); },
    false,
  );
  return $impl_canvas.setup_request_animation_frame(
    get_tick_func(ctx, view, update, selector),
  );
}

/**
 * If you are using [Lustre](https://github.com/lustre-labs/lustre) or some other framework to build
 * your web application you may prefer to use the [web components](https://developer.mozilla.org/en-US/docs/Web/API/Web_components) API
 * and the `define_web_component` function.
 * ```
 * // Call this function once to register a custom HTML element <paint-canvas>
 * canvas.define_web_component()
 * // You can then display your picture by setting the "picture"
 * // property or attribute on the element.
 *
 * // In Lustre it would look something like this:
 * fn canvas(picture: paint.Picture, attributes: List(attribute.Attribute(a))) {
 *  element.element(
 *    "paint-canvas",
 *    [attribute.attribute("picture", encode.to_string(picture)), ..attributes],
 *    [],
 *  )
 *}
 * ```
 * A more detailed example for using this API can be found in the `demos/with_lustre` directory.
 */
export function define_web_component() {
  $impl_canvas.define_web_component();
  return $impl_canvas.set_global(
    (encoded_picture, ctx) => {
      let $ = $encode.from_string(encoded_picture);
      let picture;
      if ($ instanceof Ok) {
        picture = $[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "paint/canvas",
          447,
          "define_web_component",
          "Invalid picture provided to web component",
          {
            value: $,
            start: 13602,
            end: 13662,
            pattern_start: 13613,
            pattern_end: 13624
          }
        )
      }
      return display_on_rendering_context(picture, ctx, default_drawing_state);
    },
    "display_on_rendering_context_with_default_drawing_state",
  );
}
