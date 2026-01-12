import * as $process from "../gleam_erlang/gleam/erlang/process.mjs";
import * as $actor from "../gleam_otp/gleam/otp/actor.mjs";
import * as $internal from "./shore/internal.mjs";
import * as $key from "./shore/key.mjs";

/**
 * A variant of `spec` which provides a subject of the shore actor to the
 * `init` function. Messages can be send to your application through this
 * subject via `actor.send`
 */
export function spec_with_subject(init, view, update, exit, keybinds, redraw) {
  return new $internal.Spec(init, view, update, exit, keybinds, redraw);
}

/**
 * A shore application is made up of these base parts. Following The Elm
 * Architecture, you must define an init, view and update function which shore
 * will handle calling.
 *
 * Additionally, a simple subject to pass the exit call to is required.
 * keybinding for the framework level events such as exiting and ui focusing.
 * And finally redraw for defining when the applicaiton should be redrawn, either on update messages or on a timer.
 *
 * `init` and `update` functions second argument `List(fn() -> Msg)` is an
 * "effects handler". You can pass effectful/blocking code here such as
 * requests to databases, file system io, network requests and they will be
 * automatically passed to a separate, unlinked, erlang process which will call
 * update for you on their return. See the `reader` example for practical usage
 * examples.
 *
 * ## Example
 * ```
 * import gleam/erlang/process
 * import shore
 *
 * pub fn main() {
 *   let exit = process.new_subject()
 *   let assert Ok(_actor) =
 *     shore.spec(
 *       init:,
 *       update:,
 *       view:,
 *       exit:,
 *       keybinds: shore.default_keybinds(),
 *       redraw: shore.on_timer(16),
 *     )
 *     |> shore.start
 *   exit |> process.receive_forever
 * }
 *
 * ```
 */
export function spec(init, view, update, exit, keybinds, redraw) {
  return spec_with_subject(
    (_) => { return init(); },
    view,
    update,
    exit,
    keybinds,
    redraw,
  );
}

/**
 * Set keybinds for various shore level functions, such as moving between
 * focusable elements such as input boxes and buttons, as well as exiting and
 * triggering button events.
 */
export function keybinds(exit, submit, focus_clear, focus_next, focus_prev) {
  return new $internal.Keybinds(
    exit,
    submit,
    focus_clear,
    focus_next,
    focus_prev,
  );
}

/**
 * A typical set of keybindings
 *
 * - exit: `ctrl+x`
 * - submit: `enter`
 * - focus_clear: `escape`
 * - focus_next: `tab`
 * - focus_prev: `shift+tab`
 */
export function default_keybinds() {
  return new $internal.Keybinds(
    new $key.Ctrl("X"),
    new $key.Enter(),
    new $key.Esc(),
    new $key.Tab(),
    new $key.BackTab(),
  );
}

/**
 * Allows sending a message to your TUI from another actor. This can be used,
 * for example, to push an event to your TUI, rather than have it poll.
 *
 * ## Example
 * ```gleam
 * actor.send(shore, shore.send(MyMsg))
 * ```
 */
export function send(msg) {
  return $internal.send(msg);
}

/**
 * Manually trigger the exit for your TUI. Normally this would be handled
 * through the exit keybind.
 *
 * ## Example
 * ```gleam
 * actor.send(shore, shore.exit())
 * ```
 */
export function exit() {
  return $internal.exit();
}

/**
 * Redraw every x milliseconds
 */
export function on_timer(ms) {
  return new $internal.OnTimer(ms);
}

/**
 * Redraw in response to events. Suitable for infrequently changing state.
 */
export function on_update() {
  return new $internal.OnUpdate();
}
