import * as $bool from "../../gleam_stdlib/gleam/bool.mjs";
import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $order from "../../gleam_stdlib/gleam/order.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../../iv/iv.mjs";
import * as $statemachine from "../../statemachine/statemachine.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  makeError,
  remainderInt,
  divideFloat,
  divideInt,
} from "../gleam.mjs";
import * as $texture from "../tiramisu/texture.mjs";

const FILEPATH = "src/tiramisu/spritesheet.gleam";

class Sprite extends $CustomType {
  constructor(texture, frame_index, columns, rows, pixel_art) {
    super();
    this.texture = texture;
    this.frame_index = frame_index;
    this.columns = columns;
    this.rows = rows;
    this.pixel_art = pixel_art;
  }
}

export class Once extends $CustomType {}
export const LoopMode$Once = () => new Once();
export const LoopMode$isOnce = (value) => value instanceof Once;

export class Repeat extends $CustomType {}
export const LoopMode$Repeat = () => new Repeat();
export const LoopMode$isRepeat = (value) => value instanceof Repeat;

export class PingPong extends $CustomType {}
export const LoopMode$PingPong = () => new PingPong();
export const LoopMode$isPingPong = (value) => value instanceof PingPong;

export class InvalidColumns extends $CustomType {}
export const SpritesheetError$InvalidColumns = () => new InvalidColumns();
export const SpritesheetError$isInvalidColumns = (value) =>
  value instanceof InvalidColumns;

export class InvalidRows extends $CustomType {}
export const SpritesheetError$InvalidRows = () => new InvalidRows();
export const SpritesheetError$isInvalidRows = (value) =>
  value instanceof InvalidRows;

export class InvalidFrameCount extends $CustomType {}
export const SpritesheetError$InvalidFrameCount = () => new InvalidFrameCount();
export const SpritesheetError$isInvalidFrameCount = (value) =>
  value instanceof InvalidFrameCount;

export class FrameCountExceedsGrid extends $CustomType {}
export const SpritesheetError$FrameCountExceedsGrid = () =>
  new FrameCountExceedsGrid();
export const SpritesheetError$isFrameCountExceedsGrid = (value) =>
  value instanceof FrameCountExceedsGrid;

class Spritesheet extends $CustomType {
  constructor(texture, columns, rows, frame_count) {
    super();
    this.texture = texture;
    this.columns = columns;
    this.rows = rows;
    this.frame_count = frame_count;
  }
}

class Animation extends $CustomType {
  constructor(name, frames, frame_duration, loop) {
    super();
    this.name = name;
    this.frames = frames;
    this.frame_duration = frame_duration;
    this.loop = loop;
  }
}

class FrameState extends $CustomType {
  constructor(current_frame_index, elapsed_time, is_playing, ping_pong_forward) {
    super();
    this.current_frame_index = current_frame_index;
    this.elapsed_time = elapsed_time;
    this.is_playing = is_playing;
    this.ping_pong_forward = ping_pong_forward;
  }
}

class Builder extends $CustomType {
  constructor(spritesheet, animations, frame_states, initial_animation, transitions, default_blend, pixel_art) {
    super();
    this.spritesheet = spritesheet;
    this.animations = animations;
    this.frame_states = frame_states;
    this.initial_animation = initial_animation;
    this.transitions = transitions;
    this.default_blend = default_blend;
    this.pixel_art = pixel_art;
  }
}

class TransitionConfig extends $CustomType {
  constructor(from, to, condition, blend_duration, easing, weight) {
    super();
    this.from = from;
    this.to = to;
    this.condition = condition;
    this.blend_duration = blend_duration;
    this.easing = easing;
    this.weight = weight;
  }
}

class AnimationMachine extends $CustomType {
  constructor(spritesheet, state_machine, frame_states, animations, initial_animation, pixel_art) {
    super();
    this.spritesheet = spritesheet;
    this.state_machine = state_machine;
    this.frame_states = frame_states;
    this.animations = animations;
    this.initial_animation = initial_animation;
    this.pixel_art = pixel_art;
  }
}

/**
 * Playing a single animation
 */
export class SingleFrame extends $CustomType {
  constructor(frame_index) {
    super();
    this.frame_index = frame_index;
  }
}
export const FrameData$SingleFrame = (frame_index) =>
  new SingleFrame(frame_index);
export const FrameData$isSingleFrame = (value) => value instanceof SingleFrame;
export const FrameData$SingleFrame$frame_index = (value) => value.frame_index;
export const FrameData$SingleFrame$0 = (value) => value.frame_index;

/**
 * Blending between two animations with a factor (0.0 = from, 1.0 = to)
 */
export class BlendingFrames extends $CustomType {
  constructor(from_frame_index, to_frame_index, blend_factor) {
    super();
    this.from_frame_index = from_frame_index;
    this.to_frame_index = to_frame_index;
    this.blend_factor = blend_factor;
  }
}
export const FrameData$BlendingFrames = (from_frame_index, to_frame_index, blend_factor) =>
  new BlendingFrames(from_frame_index, to_frame_index, blend_factor);
export const FrameData$isBlendingFrames = (value) =>
  value instanceof BlendingFrames;
export const FrameData$BlendingFrames$from_frame_index = (value) =>
  value.from_frame_index;
export const FrameData$BlendingFrames$0 = (value) => value.from_frame_index;
export const FrameData$BlendingFrames$to_frame_index = (value) =>
  value.to_frame_index;
export const FrameData$BlendingFrames$1 = (value) => value.to_frame_index;
export const FrameData$BlendingFrames$blend_factor = (value) =>
  value.blend_factor;
export const FrameData$BlendingFrames$2 = (value) => value.blend_factor;

/**
 * Always transition immediately when evaluated.
 */
export function always() {
  return new $statemachine.Always();
}

/**
 * Transition after spending the specified duration in the current state.
 */
export function after_duration(time) {
  return new $statemachine.AfterDuration(time);
}

/**
 * Transition based on a custom condition function.
 */
export function custom(check) {
  return new $statemachine.Custom(check);
}

/**
 * Create a new animation machine builder with a specific frame count.
 *
 * Use this when your sprite atlas has empty cells at the end.
 */
export function new_with_count(texture, columns, rows, frame_count) {
  return $bool.guard(
    columns < 1,
    new Error(new InvalidColumns()),
    () => {
      return $bool.guard(
        rows < 1,
        new Error(new InvalidRows()),
        () => {
          return $bool.guard(
            frame_count < 1,
            new Error(new InvalidFrameCount()),
            () => {
              return $bool.guard(
                frame_count > columns * rows,
                new Error(new FrameCountExceedsGrid()),
                () => {
                  let sheet = new Spritesheet(
                    texture,
                    columns,
                    rows,
                    frame_count,
                  );
                  return new Ok(
                    new Builder(
                      sheet,
                      $dict.new$(),
                      $dict.new$(),
                      "",
                      toList([]),
                      new $option.None(),
                      false,
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
 * Create a new animation machine builder from a texture.
 *
 * This creates the spritesheet configuration. You must add at least one
 * animation with `with_animation` before calling `build()`.
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(machine) =
 *   spritesheet.new(texture: tex, columns: 8, rows: 4)
 *   |> result.map(spritesheet.with_animation(...))
 *   |> result.map(spritesheet.build)
 * ```
 */
export function new$(texture, columns, rows) {
  return new_with_count(texture, columns, rows, columns * rows);
}

function new_frame_state() {
  return new FrameState(0, $duration.nanoseconds(0), true, true);
}

/**
 * Add an animation to the builder.
 *
 * The first animation added becomes the initial/default animation.
 * Adding an animation transitions the builder from `NoAnimation` to `HasAnimation`.
 *
 * ## Example
 *
 * ```gleam
 * builder
 * |> spritesheet.with_animation(
 *   name: "idle",
 *   frames: [0, 1, 2, 3],
 *   frame_duration: duration.milliseconds(100),
 *   loop: spritesheet.Repeat,
 * )
 * |> spritesheet.with_animation(
 *   name: "walk",
 *   frames: [8, 9, 10, 11, 12, 13, 14, 15],
 *   frame_duration: duration.milliseconds(80),
 *   loop: spritesheet.Repeat,
 * )
 * ```
 */
export function with_animation(builder, name, frames, frame_duration, loop) {
  let anim = new Animation(name, $iv.from_list(frames), frame_duration, loop);
  let new_animations = $dict.insert(builder.animations, name, anim);
  let new_frame_states = $dict.insert(
    builder.frame_states,
    name,
    new_frame_state(),
  );
  let _block;
  let $ = builder.initial_animation;
  if ($ === "") {
    _block = name;
  } else {
    _block = $;
  }
  let initial = _block;
  return new Builder(
    builder.spritesheet,
    new_animations,
    new_frame_states,
    initial,
    builder.transitions,
    builder.default_blend,
    builder.pixel_art,
  );
}

/**
 * Enable pixel art rendering (nearest-neighbor filtering).
 *
 * When enabled, the texture will use nearest-neighbor filtering instead of
 * linear filtering, preserving crisp pixel edges.
 */
export function with_pixel_art(builder, enabled) {
  return new Builder(
    builder.spritesheet,
    builder.animations,
    builder.frame_states,
    builder.initial_animation,
    builder.transitions,
    builder.default_blend,
    enabled,
  );
}

/**
 * Add a transition between two animations by name.
 *
 * This can only be called on a builder that has at least one animation.
 *
 * ## Example
 *
 * ```gleam
 * builder
 * |> spritesheet.with_transition(
 *   from: "idle",
 *   to: "walk",
 *   condition: spritesheet.custom(fn(ctx) { ctx.is_moving }),
 *   blend_duration: duration.milliseconds(200),
 * )
 * ```
 */
export function with_transition(builder, from, to, condition, blend_duration) {
  let config = new TransitionConfig(
    from,
    to,
    condition,
    blend_duration,
    new $option.None(),
    0,
  );
  return new Builder(
    builder.spritesheet,
    builder.animations,
    builder.frame_states,
    builder.initial_animation,
    listPrepend(config, builder.transitions),
    builder.default_blend,
    builder.pixel_art,
  );
}

/**
 * Add a transition with advanced options.
 *
 * Like `with_transition` but allows specifying easing function and priority weight.
 */
export function with_transition_advanced(
  builder,
  from,
  to,
  condition,
  blend_duration,
  easing,
  weight
) {
  let config = new TransitionConfig(
    from,
    to,
    condition,
    blend_duration,
    easing,
    weight,
  );
  return new Builder(
    builder.spritesheet,
    builder.animations,
    builder.frame_states,
    builder.initial_animation,
    listPrepend(config, builder.transitions),
    builder.default_blend,
    builder.pixel_art,
  );
}

/**
 * Set the default blend duration for manual transitions.
 */
export function with_default_blend(builder, blend_duration) {
  return new Builder(
    builder.spritesheet,
    builder.animations,
    builder.frame_states,
    builder.initial_animation,
    builder.transitions,
    new $option.Some(blend_duration),
    builder.pixel_art,
  );
}

function list_reverse(loop$list, loop$acc) {
  while (true) {
    let list = loop$list;
    let acc = loop$acc;
    if (list instanceof $Empty) {
      return acc;
    } else {
      let first = list.head;
      let rest = list.tail;
      loop$list = rest;
      loop$acc = listPrepend(first, acc);
    }
  }
}

function list_fold(loop$list, loop$acc, loop$f) {
  while (true) {
    let list = loop$list;
    let acc = loop$acc;
    let f = loop$f;
    if (list instanceof $Empty) {
      return acc;
    } else {
      let first = list.head;
      let rest = list.tail;
      loop$list = rest;
      loop$acc = f(acc, first);
      loop$f = f;
    }
  }
}

/**
 * Build the animation machine from the builder.
 *
 * This can only be called on a builder that has at least one animation
 * (`Builder(HasAnimation, ctx)`).
 *
 * ## Example
 *
 * ```gleam
 * let assert Ok(machine) =
 *   spritesheet.new(texture: tex, columns: 8, rows: 4)
 *   |> result.map(spritesheet.with_animation(...))
 *   |> result.map(spritesheet.build)
 * ```
 */
export function build(builder) {
  let $ = $dict.get(builder.animations, builder.initial_animation);
  let initial_anim;
  if ($ instanceof Ok) {
    initial_anim = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "tiramisu/spritesheet",
      539,
      "build",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 15568,
        end: 15657,
        pattern_start: 15579,
        pattern_end: 15595
      }
    )
  }
  let state_machine = $dict.fold(
    builder.animations,
    $statemachine.new$(initial_anim),
    (sm, _, anim) => {
      let $1 = anim.name === initial_anim.name;
      if ($1) {
        return sm;
      } else {
        return $statemachine.with_state(sm, anim);
      }
    },
  );
  let _block;
  let _pipe = builder.transitions;
  let _pipe$1 = list_reverse(_pipe, toList([]));
  _block = list_fold(
    _pipe$1,
    state_machine,
    (sm, config) => {
      let $1 = $dict.get(builder.animations, config.from);
      let $2 = $dict.get(builder.animations, config.to);
      if ($1 instanceof Ok && $2 instanceof Ok) {
        let from_anim = $1[0];
        let to_anim = $2[0];
        return $statemachine.with_transition(
          sm,
          from_anim,
          to_anim,
          config.condition,
          config.blend_duration,
          config.easing,
          config.weight,
        );
      } else {
        return sm;
      }
    },
  );
  let state_machine$1 = _block;
  let _block$1;
  let $1 = builder.default_blend;
  if ($1 instanceof $option.Some) {
    let duration = $1[0];
    _block$1 = $statemachine.with_default_blend(state_machine$1, duration);
  } else {
    _block$1 = state_machine$1;
  }
  let state_machine$2 = _block$1;
  return new AnimationMachine(
    builder.spritesheet,
    state_machine$2,
    builder.frame_states,
    builder.animations,
    builder.initial_animation,
    builder.pixel_art,
  );
}

function advance_frame(loop$state, loop$animation, loop$remaining_time) {
  while (true) {
    let state = loop$state;
    let animation = loop$animation;
    let remaining_time = loop$remaining_time;
    let frame_count = $iv.size(animation.frames);
    let _block;
    let $ = animation.loop;
    if ($ instanceof Once) {
      let next_index = state.current_frame_index + 1;
      let $1 = next_index >= frame_count;
      if ($1) {
        _block = new FrameState(
          frame_count - 1,
          $duration.nanoseconds(0),
          false,
          state.ping_pong_forward,
        );
      } else {
        _block = new FrameState(
          next_index,
          remaining_time,
          state.is_playing,
          state.ping_pong_forward,
        );
      }
    } else if ($ instanceof Repeat) {
      let next_index = remainderInt(
        (state.current_frame_index + 1),
        frame_count
      );
      _block = new FrameState(
        next_index,
        remaining_time,
        state.is_playing,
        state.ping_pong_forward,
      );
    } else {
      let $1 = state.ping_pong_forward;
      if ($1) {
        let next_index = state.current_frame_index + 1;
        let $2 = next_index >= frame_count;
        if ($2) {
          _block = new FrameState(
            frame_count - 2,
            remaining_time,
            state.is_playing,
            false,
          );
        } else {
          _block = new FrameState(
            next_index,
            remaining_time,
            state.is_playing,
            state.ping_pong_forward,
          );
        }
      } else {
        let next_index = state.current_frame_index - 1;
        let $2 = next_index < 0;
        if ($2) {
          _block = new FrameState(1, remaining_time, state.is_playing, true);
        } else {
          _block = new FrameState(
            next_index,
            remaining_time,
            state.is_playing,
            state.ping_pong_forward,
          );
        }
      }
    }
    let new_state = _block;
    let $1 = new_state.is_playing;
    if ($1) {
      let $2 = $duration.compare(
        new_state.elapsed_time,
        animation.frame_duration,
      );
      if ($2 instanceof $order.Lt) {
        return new_state;
      } else if ($2 instanceof $order.Eq) {
        loop$state = new_state;
        loop$animation = animation;
        loop$remaining_time = $duration.nanoseconds(0);
      } else {
        let remaining = $duration.difference(
          animation.frame_duration,
          new_state.elapsed_time,
        );
        loop$state = new_state;
        loop$animation = animation;
        loop$remaining_time = remaining;
      }
    } else {
      return new_state;
    }
  }
}

function advance_animation(state, animation, delta_time) {
  let $ = state.is_playing;
  if ($) {
    let new_elapsed = $duration.add(state.elapsed_time, delta_time);
    let $1 = $duration.compare(new_elapsed, animation.frame_duration);
    if ($1 instanceof $order.Lt) {
      return new FrameState(
        state.current_frame_index,
        new_elapsed,
        state.is_playing,
        state.ping_pong_forward,
      );
    } else if ($1 instanceof $order.Eq) {
      let remaining = $duration.difference(
        animation.frame_duration,
        new_elapsed,
      );
      return advance_frame(state, animation, remaining);
    } else {
      let remaining = $duration.difference(
        animation.frame_duration,
        new_elapsed,
      );
      return advance_frame(state, animation, remaining);
    }
  } else {
    return state;
  }
}

function update_frame_state(frame_states, animation, delta_time) {
  let _block;
  let $ = $dict.get(frame_states, animation.name);
  if ($ instanceof Ok) {
    let s = $[0];
    _block = s;
  } else {
    _block = new_frame_state();
  }
  let state = _block;
  let new_state = advance_animation(state, animation, delta_time);
  return $dict.insert(frame_states, animation.name, new_state);
}

/**
 * Update the animation machine (call every frame).
 *
 * This advances frame counters for active animations and evaluates
 * transition conditions.
 *
 * Returns the updated machine and a boolean indicating if a transition
 * occurred this frame.
 *
 * ## Example
 *
 * ```gleam
 * fn update(model: Model, msg: Msg, ctx: Context) {
 *   case msg {
 *     Tick -> {
 *       let #(new_machine, _transitioned) =
 *         spritesheet.update(model.machine, model.game_state, ctx.delta_time)
 *       Model(..model, machine: new_machine)
 *     }
 *   }
 * }
 * ```
 */
export function update(machine, context, delta_time) {
  let $ = $statemachine.update(machine.state_machine, context, delta_time);
  let new_state_machine;
  let transitioned;
  new_state_machine = $[0];
  transitioned = $[1];
  let _block;
  let $1 = $statemachine.state_data(new_state_machine);
  if ($1 instanceof $statemachine.Single) {
    let animation = $1[0];
    _block = update_frame_state(machine.frame_states, animation, delta_time);
  } else {
    let from_anim = $1.from;
    let to_anim = $1.to;
    let _pipe = machine.frame_states;
    let _pipe$1 = update_frame_state(_pipe, from_anim, delta_time);
    _block = update_frame_state(_pipe$1, to_anim, delta_time);
  }
  let new_frame_states = _block;
  return [
    new AnimationMachine(
      machine.spritesheet,
      new_state_machine,
      new_frame_states,
      machine.animations,
      machine.initial_animation,
      machine.pixel_art,
    ),
    transitioned,
  ];
}

function get_frame_index(frame_states, animation) {
  let $ = $dict.get(frame_states, animation.name);
  if ($ instanceof Ok) {
    let state = $[0];
    let $1 = $iv.get(animation.frames, state.current_frame_index);
    if ($1 instanceof Ok) {
      let frame = $1[0];
      return frame;
    } else {
      return 0;
    }
  } else {
    let $1 = $iv.get(animation.frames, 0);
    if ($1 instanceof Ok) {
      let frame = $1[0];
      return frame;
    } else {
      return 0;
    }
  }
}

/**
 * Get the current frame data from the animation machine.
 *
 * Returns either a single frame or blending frame data.
 */
export function frame_data(machine) {
  let $ = $statemachine.state_data(machine.state_machine);
  if ($ instanceof $statemachine.Single) {
    let animation = $[0];
    let frame_idx = get_frame_index(machine.frame_states, animation);
    return new SingleFrame(frame_idx);
  } else {
    let from_anim = $.from;
    let to_anim = $.to;
    let factor = $.factor;
    let from_idx = get_frame_index(machine.frame_states, from_anim);
    let to_idx = get_frame_index(machine.frame_states, to_anim);
    return new BlendingFrames(from_idx, to_idx, factor);
  }
}

/**
 * Force a transition to a specific animation by name.
 *
 * Bypasses all transition conditions and forces an immediate state change.
 * Useful for external events like damage, death, or cutscenes.
 *
 * ## Example
 *
 * ```gleam
 * // Player got hit, immediately play hurt animation
 * let machine = spritesheet.transition_to(machine, "hurt")
 * ```
 */
export function transition_to(machine, animation_name) {
  let $ = $dict.get(machine.animations, animation_name);
  if ($ instanceof Ok) {
    let target = $[0];
    return new AnimationMachine(
      machine.spritesheet,
      $statemachine.transition_to(
        machine.state_machine,
        target,
        new $option.None(),
        new $option.None(),
      ),
      machine.frame_states,
      machine.animations,
      machine.initial_animation,
      machine.pixel_art,
    );
  } else {
    return machine;
  }
}

/**
 * Force a transition with custom blend duration.
 */
export function transition_to_with_blend(
  machine,
  animation_name,
  blend_duration
) {
  let $ = $dict.get(machine.animations, animation_name);
  if ($ instanceof Ok) {
    let target = $[0];
    return new AnimationMachine(
      machine.spritesheet,
      $statemachine.transition_to(
        machine.state_machine,
        target,
        new $option.Some(blend_duration),
        new $option.None(),
      ),
      machine.frame_states,
      machine.animations,
      machine.initial_animation,
      machine.pixel_art,
    );
  } else {
    return machine;
  }
}

/**
 * Check if currently blending between animations.
 */
export function is_blending(machine) {
  return $statemachine.is_blending(machine.state_machine);
}

/**
 * Get blend progress as a normalized value (0.0 to 1.0).
 *
 * Returns Error(Nil) if not currently blending.
 */
export function blend_progress(machine) {
  return $statemachine.blend_progress(machine.state_machine);
}

/**
 * Get the name of the current animation.
 */
export function current_animation_name(machine) {
  let $ = $statemachine.state_data(machine.state_machine);
  if ($ instanceof $statemachine.Single) {
    let animation = $[0];
    return animation.name;
  } else {
    let to_anim = $.to;
    return to_anim.name;
  }
}

/**
 * Check if pixel art mode is enabled.
 */
export function is_pixel_art(machine) {
  return machine.pixel_art;
}

/**
 * Convert an animation machine to a sprite for rendering.
 *
 * Call this in your view function to get the current sprite state
 * that can be passed to `scene.animated_sprite`.
 *
 * ## Example
 *
 * ```gleam
 * fn view(model: Model, _ctx: Context) -> scene.Node {
 *   scene.animated_sprite(
 *     id: "player",
 *     sprite: spritesheet.to_sprite(model.machine),
 *     size: vec2.Vec2(64.0, 64.0),
 *     transform: transform.identity,
 *     physics: option.None,
 *   )
 * }
 * ```
 */
export function to_sprite(machine) {
  let _block;
  let $ = frame_data(machine);
  if ($ instanceof SingleFrame) {
    let frame_index = $.frame_index;
    _block = frame_index;
  } else {
    let to_frame_index = $.to_frame_index;
    _block = to_frame_index;
  }
  let frame_idx = _block;
  return new Sprite(
    machine.spritesheet.texture,
    frame_idx,
    machine.spritesheet.columns,
    machine.spritesheet.rows,
    machine.pixel_art,
  );
}

/**
 * Get the texture from a sprite.
 * @internal
 */
export function sprite_texture(sprite) {
  return sprite.texture;
}

/**
 * Get the current frame index from a sprite.
 * @internal
 */
export function sprite_frame_index(sprite) {
  return sprite.frame_index;
}

/**
 * Check if pixel art mode is enabled for a sprite.
 * @internal
 */
export function sprite_pixel_art(sprite) {
  return sprite.pixel_art;
}

/**
 * Calculate UV offset for a sprite's current frame.
 * @internal
 */
export function sprite_frame_offset(sprite) {
  let row = divideInt(sprite.frame_index, sprite.columns);
  let col = remainderInt(sprite.frame_index, sprite.columns);
  let offset_x = divideFloat($int.to_float(col), $int.to_float(sprite.columns));
  let offset_y = divideFloat($int.to_float(row), $int.to_float(sprite.rows));
  return [offset_x, offset_y];
}

/**
 * Calculate UV repeat values for a sprite.
 * @internal
 */
export function sprite_frame_repeat(sprite) {
  let repeat_x = divideFloat(1.0, $int.to_float(sprite.columns));
  let repeat_y = divideFloat(1.0, $int.to_float(sprite.rows));
  return [repeat_x, repeat_y];
}
