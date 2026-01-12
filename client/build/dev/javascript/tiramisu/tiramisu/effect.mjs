import * as $promise from "../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $document from "../../plinth/plinth/browser/document.mjs";
import * as $element from "../../plinth/plinth/browser/element.mjs";
import * as $window from "../../plinth/plinth/browser/window.mjs";
import { Ok, CustomType as $CustomType } from "../gleam.mjs";
import * as $browser from "../tiramisu/internal/browser.mjs";
import * as $timer from "../tiramisu/internal/timer.mjs";

class Effect extends $CustomType {
  constructor(perform) {
    super();
    this.perform = perform;
  }
}

/**
 * Create an effect that performs no side effects.
 *
 * Use when you want to update state without triggering any effects.
 *
 * ## Example
 *
 * ```gleam
 * fn update(model, msg, ctx) {
 *   case msg {
 *     Idle -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function none() {
  return new Effect((_) => { return undefined; });
}

/**
 * Create a custom effect from a function.
 *
 * The function receives a `dispatch` callback to send messages back to your `update` function.
 *
 * ## Example
 *
 * ```gleam
 * effect.from(fn(dispatch) {
 *   log("Player score: " <> int.to_string(score))
 *   dispatch(ScoreLogged)
 * })
 * ```
 */
export function from(effect) {
  return new Effect(effect);
}

/**
 * Dispatch a message to be processed by the update function.
 *
 * This is the core effect for game loops. Calling `effect.dispatch(Tick)` schedules
 * a `Tick` message to be processed, which triggers another update cycle.
 */
export function dispatch(msg) {
  return new Effect(
    (dispatch) => {
      dispatch(msg);
      return undefined;
    },
  );
}

/**
 * Batch multiple effects to run them together.
 *
 * All effects execute in order during the same frame.
 *
 * ## Example
 *
 * ```gleam
 * effect.batch([
 *   effect.dispatch(NextFrame),
 *   play_sound_effect("jump.wav"),
 *   update_scoreboard(score),
 * ])
 * ```
 */
export function batch(effects) {
  return new Effect(
    (dispatch) => {
      let _pipe = effects;
      return $list.each(_pipe, (effect) => { return effect.perform(dispatch); });
    },
  );
}

/**
 * Map effect messages to a different type.
 *
 * Useful when composing effects from subcomponents.
 *
 * ## Example
 *
 * ```gleam
 * let player_effect = player.update(player_model, player_msg)
 * effect.map(player_effect, PlayerMsg)
 * ```
 */
export function map(effect, f) {
  return new Effect(
    (dispatch) => {
      return effect.perform((msg) => { return dispatch(f(msg)); });
    },
  );
}

/**
 * Create an effect from a JavaScript Promise.
 *
 * When the promise resolves, it dispatches the resulting message.
 *
 * ## Example
 *
 * ```gleam
 * let fetch_promise = fetch_data()
 * effect.from_promise(promise.map(fetch_promise, DataLoaded))
 * ```
 */
export function from_promise(p) {
  return new Effect(
    (dispatch) => {
      $promise.tap(p, dispatch);
      return undefined;
    },
  );
}

export function run(effect, dispatch) {
  return effect.perform(dispatch);
}

/**
 * Delay dispatching a message by a specified duration.
 *
 * Waits for a specific number of milliseconds using `setTimeout`.
 *
 * ## Example
 *
 * ```gleam
 * type Msg {
 *   PlayerHit
 *   ShowDamageEffect
 *   HideDamageEffect
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     PlayerHit -> #(
 *       Model(..model, health: model.health - 10),
 *       effect.batch([
 *         effect.from(fn(_) { show_damage_animation() }),
 *         effect.delay(500, HideDamageEffect),  // Hide after 500ms
 *       ]),
 *     )
 *     HideDamageEffect -> #(model, effect.none())
 *     _ -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function delay(duration, msg) {
  return new Effect(
    (dispatch) => {
      let _pipe = duration;
      let _pipe$1 = $duration.to_seconds(_pipe);
      let _pipe$2 = $float.multiply(_pipe$1, 1000.0);
      let _pipe$3 = $float.round(_pipe$2);
      return $timer.delay(_pipe$3, () => { return dispatch(msg); });
    },
  );
}

/**
 * Create a recurring interval that dispatches a message periodically.
 *
 * Immediately dispatches `on_created` with the interval ID, which you should
 * store in your model. Use this ID with `cancel_interval` to stop it later.
 *
 * **No global state** - the interval ID is managed by JavaScript's `setInterval`
 * and you store it in your model.
 *
 * ## Example
 *
 * ```gleam
 * type Model {
 *   Model(spawn_interval: option.Option(timer.TimerId))
 * }
 *
 * type Msg {
 *   StartSpawning
 *   IntervalCreated(timer.TimerId)
 *   SpawnEnemy
 *   StopSpawning
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     StartSpawning -> #(
 *       model,
 *       effect.interval(
 *         ms: 2000,
 *         msg: SpawnEnemy,
 *         on_created: IntervalCreated,
 *       ),
 *     )
 *     IntervalCreated(id) -> #(
 *       Model(..model, spawn_interval: option.Some(id)),
 *       effect.none(),
 *     )
 *     SpawnEnemy -> #(spawn_enemy(model), effect.none())
 *     StopSpawning ->
 *       case model.spawn_interval {
 *         option.Some(id) -> #(
 *           Model(..model, spawn_interval: option.None),
 *           effect.cancel_interval(id),
 *         )
 *         option.None -> #(model, effect.none())
 *       }
 *   }
 * }
 * ```
 */
export function interval(duration, msg, on_created) {
  return new Effect(
    (dispatch) => {
      let _pipe = duration;
      let _pipe$1 = $duration.to_seconds(_pipe);
      let _pipe$2 = $float.multiply(_pipe$1, 1000.0);
      let _pipe$3 = $float.round(_pipe$2);
      let _pipe$4 = $timer.interval(_pipe$3, () => { return dispatch(msg); });
      let _pipe$5 = on_created(_pipe$4);
      return dispatch(_pipe$5);
    },
  );
}

/**
 * Cancel a recurring interval by its ID.
 *
 * Pass the interval ID that was dispatched via `on_created` when you created the interval.
 *
 * ## Example
 *
 * ```gleam
 * case model.spawn_interval {
 *   option.Some(id) -> effect.cancel_interval(id)
 *   option.None -> effect.none()
 * }
 * ```
 */
export function cancel_interval(id) {
  return new Effect((_) => { return $timer.cancel_interval(id); });
}

/**
 * Request fullscreen mode for the game canvas.
 *
 * This must be called in response to a user interaction (click, key press, etc.)
 * due to browser security restrictions.
 *
 * ## Example
 *
 * ```gleam
 * type Msg {
 *   FullscreenButtonClicked
 *   FullscreenEntered
 *   FullscreenFailed
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     FullscreenButtonClicked -> #(
 *       model,
 *       effect.request_fullscreen(
 *         on_success: FullscreenEntered,
 *         on_error: FullscreenEnteredFailed,
 *       ),
 *     )
 *     _ -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function request_fullscreen(on_success, on_error) {
  return new Effect(
    (dispatch) => {
      let $ = $document.query_selector("canvas");
      if ($ instanceof Ok) {
        let canvas = $[0];
        let _pipe = $element.request_fullscreen(canvas);
        $promise.map(
          _pipe,
          (result) => {
            if (result instanceof Ok) {
              return dispatch(on_success);
            } else {
              return dispatch(on_error);
            }
          },
        )
        return undefined;
      } else {
        return dispatch(on_error);
      }
    },
  );
}

/**
 * Exit fullscreen mode.
 *
 * ## Example
 *
 * ```gleam
 * effect.exit_fullscreen(
 *   on_success: FullScreenExited,
 *   on_error: FullScreenExitedFailed
 * )
 * ```
 */
export function exit_fullscreen(on_success, on_error) {
  return new Effect(
    (dispatch) => {
      let _pipe = $window.self();
      let _pipe$1 = $window.document(_pipe);
      let _pipe$2 = $document.exit_fullscreen(_pipe$1);
      $promise.map(
        _pipe$2,
        (result) => {
          if (result instanceof Ok) {
            return dispatch(on_success);
          } else {
            return dispatch(on_error);
          }
        },
      )
      return undefined;
    },
  );
}

/**
 * Request pointer lock for the game canvas.
 *
 * This hides the cursor and provides unlimited mouse movement,
 * commonly used in first-person games. Must be called in response
 * to user interaction.
 *
 * ## Example
 *
 * ```gleam
 * type Msg {
 *   StartFPSMode
 *   PointerLocked
 *   PointerLockFailed
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     StartFPSMode -> #(
 *       model,
 *       effect.request_pointer_lock(
 *         on_success: PointerLocked,
 *         on_error: PointerLockFailed,
 *       ),
 *     )
 *     _ -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function request_pointer_lock(on_success, on_error) {
  return new Effect(
    (dispatch) => {
      let $ = $document.query_selector("canvas");
      if ($ instanceof Ok) {
        let canvas = $[0];
        let _pipe = $browser.request_pointer_lock(canvas);
        $promise.map(
          _pipe,
          (result) => {
            if (result instanceof Ok) {
              return dispatch(on_success);
            } else {
              return dispatch(on_error);
            }
          },
        )
        return undefined;
      } else {
        return dispatch(on_error);
      }
    },
  );
}

/**
 * Exit pointer lock mode.
 *
 * ## Example
 *
 * ```gleam
 * effect.exit_pointer_lock()
 * ```
 */
export function exit_pointer_lock() {
  return new Effect((_) => { return $browser.exit_pointer_lock(); });
}

/**
 * Trigger haptic feedback on mobile devices.
 *
 * The pattern is a list of vibration durations in milliseconds.
 * For example, `[200, 100, 200]` vibrates for 200ms, pauses 100ms, then vibrates 200ms.
 *
 * ## Example
 *
 * ```gleam
 * type Msg {
 *   PlayerHit
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     PlayerHit -> #(
 *       Model(..model, health: model.health - 10),
 *       effect.vibrate([100, 50, 100]),  // Quick buzz pattern
 *     )
 *     _ -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function mobile_vibrate(pattern) {
  return new Effect((_) => { return $browser.mobile_vibrate(pattern); });
}

/**
 * Trigger haptic feedback on a gamepad.
 *
 * Intensity ranges from 0.0 (no vibration) to 1.0 (maximum vibration).
 * Duration is in milliseconds.
 *
 * ## Example
 *
 * ```gleam
 * type Msg {
 *   ExplosionNearPlayer
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     ExplosionNearPlayer -> #(
 *       model,
 *       effect.gamepad_vibrate(
 *         gamepad: 0,
 *         intensity: 0.7,
 *         duration: duration.milliseconds(500),
 *       ),
 *     )
 *     _ -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function gamepad_vibrate(gamepad, intensity, duration) {
  return new Effect(
    (_) => { return $browser.gamepad_vibrate(gamepad, intensity, duration); },
  );
}

/**
 * Write text to the system clipboard.
 *
 * Must be called in response to user interaction due to browser security.
 *
 * ## Example
 *
 * ```gleam
 * type Msg {
 *   CopyScoreClicked
 *   CopiedToClipboard
 *   CopyFailed
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     CopyScoreClicked -> #(
 *       model,
 *       effect.clipboard_write(
 *         text: "High Score: " <> int.to_string(model.high_score),
 *         on_success: CopiedToClipboard,
 *         on_error: CopyFailed,
 *       ),
 *     )
 *     _ -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function clipboard_write(text, on_success, on_error) {
  return new Effect(
    (dispatch) => {
      let _pipe = $browser.clipboard_write(text);
      $promise.map(
        _pipe,
        (result) => {
          if (result instanceof Ok) {
            return dispatch(on_success);
          } else {
            return dispatch(on_error);
          }
        },
      )
      return undefined;
    },
  );
}

/**
 * Read text from the system clipboard.
 *
 * Must be called in response to user interaction due to browser security.
 *
 * ## Example
 *
 * ```gleam
 * type Msg {
 *   PasteClicked
 *   ClipboardData(String)
 *   PasteFailed
 * }
 *
 * fn update(model, msg, ctx) {
 *   case msg {
 *     PasteClicked -> #(
 *       model,
 *       effect.clipboard_read(
 *         on_success: ClipboardData,
 *         on_error: PasteFailed,
 *       ),
 *     )
 *     ClipboardData(text) -> {
 *       // Process clipboard text
 *       #(model, effect.none())
 *     }
 *     _ -> #(model, effect.none())
 *   }
 * }
 * ```
 */
export function clipboard_read(on_success, on_error) {
  return new Effect(
    (dispatch) => {
      let _pipe = $browser.clipboard_read();
      $promise.map(
        _pipe,
        (result) => {
          if (result instanceof Ok) {
            let text = result[0];
            return dispatch(on_success(text));
          } else {
            return dispatch(on_error);
          }
        },
      )
      return undefined;
    },
  );
}
