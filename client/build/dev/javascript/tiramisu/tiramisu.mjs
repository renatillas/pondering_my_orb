import * as $float from "../gleam_stdlib/gleam/float.mjs";
import { identity as coerce } from "../gleam_stdlib/gleam/function.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import * as $duration from "../gleam_time/gleam/time/duration.mjs";
import * as $document from "../plinth/plinth/browser/document.mjs";
import * as $element from "../plinth/plinth/browser/element.mjs";
import * as $window from "../plinth/plinth/browser/window.mjs";
import * as $savoiardi from "../savoiardi/savoiardi.mjs";
import * as $vec2 from "../vec/vec/vec2.mjs";
import {
  createRuntime as create_runtime_ffi,
  getRuntimeDispatch as get_runtime_dispatch_ffi,
  processFrame as process_frame_ffi,
  updateRuntimeState as update_runtime_state_ffi,
  clearRuntimeInputFrameState as clear_runtime_input_frame_state_ffi,
  updateRuntimeInputManager as update_runtime_input_manager_ffi,
  getRuntimeInputManager as get_runtime_input_manager_ffi,
  renderCameras as render_cameras_ffi,
} from "./game_runtime.ffi.mjs";
import { Ok, Error, toList, Empty as $Empty, CustomType as $CustomType } from "./gleam.mjs";
import * as $camera from "./tiramisu/camera.mjs";
import * as $effect from "./tiramisu/effect.mjs";
import * as $input from "./tiramisu/input.mjs";
import * as $input_init from "./tiramisu/internal/input_init.mjs";
import * as $input_manager from "./tiramisu/internal/input_manager.mjs";
import * as $physics from "./tiramisu/physics.mjs";
import * as $scene from "./tiramisu/scene.mjs";
import * as $ui from "./tiramisu/ui.mjs";

export class FullScreen extends $CustomType {}
export const Dimensions$FullScreen = () => new FullScreen();
export const Dimensions$isFullScreen = (value) => value instanceof FullScreen;

export class Window extends $CustomType {
  constructor(dimensions) {
    super();
    this.dimensions = dimensions;
  }
}
export const Dimensions$Window = (dimensions) => new Window(dimensions);
export const Dimensions$isWindow = (value) => value instanceof Window;
export const Dimensions$Window$dimensions = (value) => value.dimensions;
export const Dimensions$Window$0 = (value) => value.dimensions;

export class Context extends $CustomType {
  constructor(delta_time, input, canvas_size, physics_world, scene, renderer) {
    super();
    this.delta_time = delta_time;
    this.input = input;
    this.canvas_size = canvas_size;
    this.physics_world = physics_world;
    this.scene = scene;
    this.renderer = renderer;
  }
}
export const Context$Context = (delta_time, input, canvas_size, physics_world, scene, renderer) =>
  new Context(delta_time, input, canvas_size, physics_world, scene, renderer);
export const Context$isContext = (value) => value instanceof Context;
export const Context$Context$delta_time = (value) => value.delta_time;
export const Context$Context$0 = (value) => value.delta_time;
export const Context$Context$input = (value) => value.input;
export const Context$Context$1 = (value) => value.input;
export const Context$Context$canvas_size = (value) => value.canvas_size;
export const Context$Context$2 = (value) => value.canvas_size;
export const Context$Context$physics_world = (value) => value.physics_world;
export const Context$Context$3 = (value) => value.physics_world;
export const Context$Context$scene = (value) => value.scene;
export const Context$Context$4 = (value) => value.scene;
export const Context$Context$renderer = (value) => value.renderer;
export const Context$Context$5 = (value) => value.renderer;

export class FrameData extends $CustomType {
  constructor(messages, state, prev_node, context, renderer_state, delta_time_ms, input_state, canvas_size) {
    super();
    this.messages = messages;
    this.state = state;
    this.prev_node = prev_node;
    this.context = context;
    this.renderer_state = renderer_state;
    this.delta_time_ms = delta_time_ms;
    this.input_state = input_state;
    this.canvas_size = canvas_size;
  }
}
export const FrameData$FrameData = (messages, state, prev_node, context, renderer_state, delta_time_ms, input_state, canvas_size) =>
  new FrameData(messages,
  state,
  prev_node,
  context,
  renderer_state,
  delta_time_ms,
  input_state,
  canvas_size);
export const FrameData$isFrameData = (value) => value instanceof FrameData;
export const FrameData$FrameData$messages = (value) => value.messages;
export const FrameData$FrameData$0 = (value) => value.messages;
export const FrameData$FrameData$state = (value) => value.state;
export const FrameData$FrameData$1 = (value) => value.state;
export const FrameData$FrameData$prev_node = (value) => value.prev_node;
export const FrameData$FrameData$2 = (value) => value.prev_node;
export const FrameData$FrameData$context = (value) => value.context;
export const FrameData$FrameData$3 = (value) => value.context;
export const FrameData$FrameData$renderer_state = (value) =>
  value.renderer_state;
export const FrameData$FrameData$4 = (value) => value.renderer_state;
export const FrameData$FrameData$delta_time_ms = (value) => value.delta_time_ms;
export const FrameData$FrameData$5 = (value) => value.delta_time_ms;
export const FrameData$FrameData$input_state = (value) => value.input_state;
export const FrameData$FrameData$6 = (value) => value.input_state;
export const FrameData$FrameData$canvas_size = (value) => value.canvas_size;
export const FrameData$FrameData$7 = (value) => value.canvas_size;

class App extends $CustomType {
  constructor(init, update, view) {
    super();
    this.init = init;
    this.update = update;
    this.view = view;
  }
}

/**
 * Creates a static scene application with no state or update logic.
 *
 * Useful for demos, visualizations, or learning the basics before moving to `application`.
 */
export function element(view) {
  return new App(
    (_) => { return [undefined, $effect.none(), new $option.None()]; },
    (_, _1, _2) => { return [undefined, $effect.none(), new $option.None()]; },
    (_, _1) => { return view; },
  );
}

/**
 * Creates a full MVU application with state, effects, and optional physics.
 *
 * The init function initializes state and returns an initial effect (typically `effect.dispatch(Tick)`
 * for a game loop). The update function handles messages and returns new state with effects.
 * The view function renders the current state as a scene graph.
 */
export function application(init, update, view) {
  return new App(init, update, view);
}

/**
 * Process all queued messages through the update function
 * 
 * @ignore
 */
function process_messages(
  loop$state,
  loop$messages,
  loop$context,
  loop$accumulated_effect,
  loop$update
) {
  while (true) {
    let state = loop$state;
    let messages = loop$messages;
    let context = loop$context;
    let accumulated_effect = loop$accumulated_effect;
    let update = loop$update;
    if (messages instanceof $Empty) {
      let _block;
      if (accumulated_effect instanceof $option.Some) {
        let eff = accumulated_effect[0];
        _block = eff;
      } else {
        _block = $effect.none();
      }
      let final_effect = _block;
      return [state, final_effect, context.physics_world];
    } else {
      let msg = messages.head;
      let rest = messages.tail;
      let $ = update(state, msg, context);
      let new_state;
      let new_effect;
      let new_physics_world;
      new_state = $[0];
      new_effect = $[1];
      new_physics_world = $[2];
      let _block;
      if (new_physics_world instanceof $option.Some) {
        let world = new_physics_world[0];
        _block = new Context(
          context.delta_time,
          context.input,
          context.canvas_size,
          new $option.Some(world),
          context.scene,
          context.renderer,
        );
      } else {
        _block = context;
      }
      let new_context = _block;
      let _block$1;
      if (accumulated_effect instanceof $option.Some) {
        let prev_effect = accumulated_effect[0];
        _block$1 = new $option.Some(
          $effect.batch(toList([prev_effect, new_effect])),
        );
      } else {
        _block$1 = new $option.Some(new_effect);
      }
      let combined = _block$1;
      loop$state = new_state;
      loop$messages = rest;
      loop$context = new_context;
      loop$accumulated_effect = combined;
      loop$update = update;
    }
  }
}

/**
 * Split cameras into main (fullscreen, active) and viewport cameras
 * Main cameras: no viewport AND is_active
 * Viewport cameras: have a viewport (regardless of active state)
 * 
 * @ignore
 */
function split_cameras(cameras) {
  let main = $list.filter_map(
    cameras,
    (entry) => {
      let id;
      let cam;
      let viewport_opt;
      let pp_opt;
      let is_active;
      id = entry[0];
      cam = entry[1];
      viewport_opt = entry[2];
      pp_opt = entry[3];
      is_active = entry[4];
      let $ = $option.is_none(viewport_opt) && is_active;
      if ($) {
        return new Ok([id, cam, viewport_opt, pp_opt]);
      } else {
        return new Error(undefined);
      }
    },
  );
  let viewport = $list.filter_map(
    cameras,
    (entry) => {
      let id;
      let cam;
      let viewport_opt;
      let pp_opt;
      id = entry[0];
      cam = entry[1];
      viewport_opt = entry[2];
      pp_opt = entry[3];
      let $ = $option.is_some(viewport_opt);
      if ($) {
        return new Ok([id, cam, viewport_opt, pp_opt]);
      } else {
        return new Error(undefined);
      }
    },
  );
  return [main, viewport];
}

/**
 * Apply initial scene using renderer.gleam's patch system
 * 
 * @ignore
 */
function apply_initial_scene_gleam(renderer_state, node) {
  let $ = $scene.diff(
    new $option.None(),
    new $option.Some(node),
    new $option.None(),
  );
  let patches;
  let new_dict;
  patches = $[0];
  new_dict = $[1];
  let renderer_state$1 = $scene.apply_patches(renderer_state, patches);
  return $scene.set_cached_scene_dict(
    renderer_state$1,
    new $option.Some(new_dict),
  );
}

/**
 * Render the scene to the canvas
 * 
 * @ignore
 */
function render_scene(renderer_state) {
  let cameras = $scene.get_all_cameras_with_info(renderer_state);
  let $ = split_cameras(cameras);
  let main_cameras;
  let viewport_cameras;
  main_cameras = $[0];
  viewport_cameras = $[1];
  return render_cameras_ffi(renderer_state, main_cameras, viewport_cameras);
}

/**
 * Schedule the next animation frame using the runtime
 * 
 * @ignore
 */
function schedule_frame_with_runtime(runtime, update, view) {
  $window.request_animation_frame(
    (timestamp) => {
      let frame_data = process_frame_ffi(
        runtime,
        update,
        view,
        timestamp,
        $input_manager.capture_state,
        $input_manager.clear_frame_state,
      );
      let _block;
      let _record = frame_data.context;
      _block = new Context(
        $duration.milliseconds($float.round(frame_data.delta_time_ms)),
        frame_data.input_state,
        frame_data.canvas_size,
        _record.physics_world,
        _record.scene,
        _record.renderer,
      );
      let updated_context = _block;
      let _block$1;
      let $ = $input.has_user_interaction(frame_data.input_state);
      if ($) {
        _block$1 = $scene.resume_audio_context(frame_data.renderer_state);
      } else {
        _block$1 = frame_data.renderer_state;
      }
      let renderer_state_with_audio = _block$1;
      let $1 = process_messages(
        frame_data.state,
        frame_data.messages,
        updated_context,
        new $option.None(),
        update,
      );
      let new_state;
      let combined_effect;
      let final_physics_world;
      new_state = $1[0];
      combined_effect = $1[1];
      final_physics_world = $1[2];
      let _block$2;
      if (final_physics_world instanceof $option.Some) {
        let world = final_physics_world[0];
        _block$2 = new Context(
          updated_context.delta_time,
          updated_context.input,
          updated_context.canvas_size,
          new $option.Some(world),
          updated_context.scene,
          updated_context.renderer,
        );
      } else {
        _block$2 = updated_context;
      }
      let new_context = _block$2;
      let new_node = view(new_state, new_context);
      let $2 = $scene.diff(
        new $option.Some(frame_data.prev_node),
        new $option.Some(new_node),
        renderer_state_with_audio.cached_scene_dict,
      );
      let patches;
      let new_dict;
      patches = $2[0];
      new_dict = $2[1];
      let _block$3;
      let _pipe = renderer_state_with_audio;
      let _pipe$1 = $scene.apply_patches(_pipe, patches);
      _block$3 = $scene.set_cached_scene_dict(
        _pipe$1,
        new $option.Some(new_dict),
      );
      let new_renderer_state = _block$3;
      $scene.update_mixers(new_renderer_state, new_context.delta_time);
      render_scene(new_renderer_state);
      let _block$4;
      let $3 = $scene.get_physics_world(new_renderer_state);
      if ($3 instanceof $option.Some) {
        let world = $3[0];
        _block$4 = new Context(
          new_context.delta_time,
          new_context.input,
          new_context.canvas_size,
          new $option.Some(world),
          new_context.scene,
          new_context.renderer,
        );
      } else {
        _block$4 = new_context;
      }
      let final_context = _block$4;
      update_runtime_state_ffi(
        runtime,
        new_state,
        new_node,
        final_context,
        new_renderer_state,
      );
      clear_runtime_input_frame_state_ffi(
        runtime,
        $input_manager.clear_frame_state,
      );
      let dispatch = get_runtime_dispatch_ffi(runtime);
      $effect.run(combined_effect, dispatch);
      return schedule_frame_with_runtime(runtime, update, view);
    },
  );
  return undefined;
}

/**
 * Start the game loop
 * 
 * @ignore
 */
function game_loop(
  bridge,
  bridge_wrapper,
  state,
  prev_node,
  pending_effect,
  context,
  renderer_state,
  input_manager,
  canvas,
  update,
  view
) {
  let runtime = create_runtime_ffi(
    bridge,
    bridge_wrapper,
    state,
    prev_node,
    context,
    renderer_state,
    input_manager,
  );
  let $ = $input_init.initialize(
    canvas,
    () => { return get_runtime_input_manager_ffi(runtime); },
    (updated_mgr) => {
      return update_runtime_input_manager_ffi(runtime, updated_mgr);
    },
  );
  
  let dispatch = get_runtime_dispatch_ffi(runtime);
  $effect.run(pending_effect, dispatch);
  return schedule_frame_with_runtime(runtime, update, view);
}

/**
 * Starts a game application, setting up the renderer and game loop.
 *
 * The selector is a CSS selector for the container element. Use `option.None` for the
 * bridge in standalone games, or `option.Some(#(bridge, wrapper))` for Lustre integration.
 */
export function start(app, selector, dimensions, bridge) {
  return $result.try$(
    $document.query_selector(selector),
    (container) => {
      let renderer_state = $scene.new_render_state(
        new $savoiardi.RendererOptions(
          true,
          false,
          (() => {
            if (dimensions instanceof FullScreen) {
              return new $option.None();
            } else {
              let dim = dimensions.dimensions;
              return new $option.Some(dim);
            }
          })(),
        ),
      );
      let renderer = $scene.get_renderer(renderer_state);
      let canvas = $savoiardi.get_renderer_dom_element(renderer);
      $element.append_child(
        container,
        (() => {
          let _pipe = canvas;
          return coerce(_pipe);
        })(),
      );
      let renderer_state$1 = $scene.init_css2d_renderer(
        renderer_state,
        container,
      );
      let renderer_state$2 = $scene.init_css3d_renderer(
        renderer_state$1,
        container,
      );
      let input_mgr = $input_manager.new$();
      let canvas_size = $savoiardi.get_canvas_dimensions(renderer);
      let scene = $scene.get_scene(renderer_state$2);
      let initial_context = new Context(
        $duration.nanoseconds(0),
        $input.new$(),
        canvas_size,
        new $option.None(),
        scene,
        renderer,
      );
      let $ = app.init(initial_context);
      let initial_state;
      let initial_effect;
      let physics_world;
      initial_state = $[0];
      initial_effect = $[1];
      physics_world = $[2];
      let context_with_physics = new Context(
        $duration.nanoseconds(0),
        $input.new$(),
        canvas_size,
        physics_world,
        scene,
        renderer,
      );
      let _block;
      if (physics_world instanceof $option.Some) {
        let world = physics_world[0];
        _block = $scene.set_physics_world(
          renderer_state$2,
          new $option.Some(world),
        );
      } else {
        _block = $scene.set_physics_world(renderer_state$2, new $option.None());
      }
      let renderer_state_with_physics = _block;
      let initial_root = app.view(initial_state, context_with_physics);
      let renderer_state_after_init = apply_initial_scene_gleam(
        renderer_state_with_physics,
        initial_root,
      );
      let _block$1;
      let $1 = $scene.get_physics_world(renderer_state_after_init);
      if ($1 instanceof $option.Some) {
        let updated_world = $1[0];
        _block$1 = new Context(
          context_with_physics.delta_time,
          context_with_physics.input,
          context_with_physics.canvas_size,
          new $option.Some(updated_world),
          context_with_physics.scene,
          context_with_physics.renderer,
        );
      } else {
        _block$1 = context_with_physics;
      }
      let updated_context = _block$1;
      let _block$2;
      if (bridge instanceof $option.Some) {
        let b = bridge[0][0];
        let wrapper = bridge[0][1];
        _block$2 = [
          new $option.Some($ui.get_internal(b)),
          new $option.Some(wrapper),
        ];
      } else {
        _block$2 = [new $option.None(), new $option.None()];
      }
      let $2 = _block$2;
      let bridge_internal;
      let bridge_wrapper;
      bridge_internal = $2[0];
      bridge_wrapper = $2[1];
      game_loop(
        bridge_internal,
        bridge_wrapper,
        initial_state,
        initial_root,
        initial_effect,
        updated_context,
        renderer_state_after_init,
        input_mgr,
        (() => {
          let _pipe = canvas;
          return coerce(_pipe);
        })(),
        app.update,
        app.view,
      );
      return new Ok(undefined);
    },
  );
}
