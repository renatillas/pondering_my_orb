import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import * as $internal from "../shore/internal.mjs";
import * as $key from "../shore/key.mjs";
import * as $style from "../shore/style.mjs";

/**
 * Sets alignment of all child nodes
 */
export function align(alignment, node) {
  return new $internal.Aligned(alignment, node);
}

/**
 * A row with a background color
 */
export function bar(color) {
  return new $internal.Bar(color);
}

/**
 * A row with a background color, containing items
 */
export function bar2(color, node) {
  return new $internal.Bar2(color, node);
}

/**
 * A box container element for holding other nodes
 */
export function box(children, title) {
  return new $internal.Box(children, title, new None());
}

/**
 * A box container element for holding other nodes.
 *
 * Can be provided with a custom colour for the outline and title.
 */
export function box_styled(children, title, fg) {
  return new $internal.Box(children, title, fg);
}

/**
 * An empty line
 */
export function br() {
  return new $internal.BR();
}

/**
 * A button assigned to a key press to execute an event
 */
export function button(text, key, event) {
  return new $internal.Button(
    text,
    text,
    key,
    event,
    new Some(new $style.Black()),
    new Some(new $style.Blue()),
    new Some(new $style.Black()),
    new Some(new $style.Green()),
  );
}

/**
 * A button assigned to a key press to execute an event.
 * Can be provided with custom colours both for when focused/pressed or not.
 *
 * Default colors for buttons are:
 * ```gleam
 *  fg: Some(style.Black),
 *  bg: Some(style.Blue),
 *  focus_fg: Some(style.Black),
 *  focus_bg: Some(style.Green),
 * ```
 */
export function button_styled(text, key, event, fg, bg, focus_fg, focus_bg) {
  return new $internal.Button(
    text,
    text,
    key,
    event,
    fg,
    bg,
    focus_fg,
    focus_bg,
  );
}

/**
 * A button assigned to a key press to execute an event
 *
 * Takes an `id` value which uniquely identifies it, allowing two buttons to
 * share the same display text but operate independently, contrary to a
 * button, where the text is the id and so all button text must be unique.
 */
export function button_id(id, text, key, event) {
  return new $internal.Button(
    id,
    text,
    key,
    event,
    new Some(new $style.Black()),
    new Some(new $style.Blue()),
    new Some(new $style.Black()),
    new Some(new $style.Green()),
  );
}

/**
 * A button assigned to a key press to execute an event.
 *
 * Takes an `id` value which uniquely identifies it, allowing two buttons to
 * share the same display text but operate independently, contrary to a
 * button, where the text is the id and so all button text must be unique.
 *
 * Can be provided with custom colours both for when focused/pressed or not.
 *
 * Default colors for buttons are:
 * ```gleam
 *  fg: Some(style.Black),
 *  bg: Some(style.Blue),
 *  focus_fg: Some(style.Black),
 *  focus_bg: Some(style.Green),
 * ```
 */
export function button_id_styled(
  id,
  text,
  key,
  event,
  fg,
  bg,
  focus_fg,
  focus_bg
) {
  return new $internal.Button(id, text, key, event, fg, bg, focus_fg, focus_bg);
}

/**
 * A container element for holding other nodes over multiple lines
 */
export function col(children) {
  return new $internal.Col(children);
}

/**
 * Prints some positional information for developer debugging
 */
export function debug() {
  return new $internal.Debug();
}

/**
 * An extremely simple plot
 */
export function graph(width, height, points) {
  return new $internal.Graph(width, height, points);
}

/**
 * A horizontal line
 */
export function hr() {
  return new $internal.HR();
}

/**
 * A colored horizontal line
 */
export function hr_styled(color) {
  return new $internal.HR2(color);
}

/**
 * A field for text input
 */
export function input(label, value, width, event) {
  return new $internal.Input(label, value, width, event, new None(), false);
}

/**
 * A field for text input with the content display hidden, useful for password fields
 */
export function input_hidden(label, value, width, event) {
  return new $internal.Input(label, value, width, event, new None(), true);
}

/**
 * A field for text input. Allows setting a `submit` event which can be
 * triggered by the submit keybind while the field is currently focused.
 *
 * Useful for scenarios where a separate submit button would be inconvenient,
 * such as a chat box or 2fa prompt.
 */
export function input_submit(label, value, width, event, submit, hidden) {
  return new $internal.Input(
    label,
    value,
    width,
    event,
    new Some(submit),
    hidden,
  );
}

/**
 * A non-visible button assigned to a key press to execute an event
 */
export function keybind(key, event) {
  return new $internal.KeyBind(key, event);
}

/**
 * A progress bar, will automatically calculate fill percent based off max and current values
 */
export function progress(width, max, value, color) {
  return new $internal.Progress(width, max, value, color);
}

/**
 * A container element for holding other nodes in a single line
 */
export function row(children) {
  return new $internal.Row(children);
}

/**
 * A table layout
 */
export function table(width, table) {
  return new $internal.Table(width, table);
}

/**
 * A Key-Value style table layout
 */
export function table_kv(width, table) {
  return new $internal.TableKV(width, table);
}

/**
 * A text string
 */
export function text(text) {
  return new $internal.TextMulti(
    text,
    new $internal.NoWrap(),
    new None(),
    new None(),
  );
}

/**
 * A text string with automatic line wrapping
 */
export function text_wrapped(text) {
  return new $internal.TextMulti(
    text,
    new $internal.Wrap(),
    new None(),
    new None(),
  );
}

/**
 * A text string with colored foreground and/or background
 */
export function text_styled(text, fg, bg) {
  return new $internal.TextMulti(text, new $internal.NoWrap(), fg, bg);
}

/**
 * A text string with automatic line wrapping and colored foreground and/or background
 */
export function text_wrapped_styled(text, fg, bg) {
  return new $internal.TextMulti(text, new $internal.Wrap(), fg, bg);
}

/**
 * UNSTABLE: A base64 encoded png image drawn using the Kitty Graphics Protocol
 *
 * This is currently a unstable implementation/exploration of using the kitty graphics protocol, some general notes are:
 * - visually large pngs and file sizes over 500kb~ have performance issues
 * - performance is typically even worse in render on_timer mode as it will redraw the images every frame
 * - size of image is not detected for purposes of layout, as such, it should probably be in its own grid cell
 * - only pngs stored as a base64 string are supported
 * - only some terminals support this protocol
 * - this function is likely to change significantly as the implementation of image support is refined
 * - expect bugs
 */
export function image_unstable(base64) {
  return new $internal.Graphic(base64);
}
