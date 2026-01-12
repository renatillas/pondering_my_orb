import * as $process from "../../gleam_erlang/gleam/erlang/process.mjs";
import * as $actor from "../../gleam_otp/gleam/otp/actor.mjs";
import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $io from "../../gleam_stdlib/gleam/io.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $string from "../../gleam_stdlib/gleam/string.mjs";
import {
  Ok,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  divideFloat,
  divideInt,
  isEqual,
} from "../gleam.mjs";
import * as $key from "../shore/key.mjs";
import * as $style from "../shore/style.mjs";

export class Spec extends $CustomType {
  constructor(init, view, update, exit, keybinds, redraw) {
    super();
    this.init = init;
    this.view = view;
    this.update = update;
    this.exit = exit;
    this.keybinds = keybinds;
    this.redraw = redraw;
  }
}
export const Spec$Spec = (init, view, update, exit, keybinds, redraw) =>
  new Spec(init, view, update, exit, keybinds, redraw);
export const Spec$isSpec = (value) => value instanceof Spec;
export const Spec$Spec$init = (value) => value.init;
export const Spec$Spec$0 = (value) => value.init;
export const Spec$Spec$view = (value) => value.view;
export const Spec$Spec$1 = (value) => value.view;
export const Spec$Spec$update = (value) => value.update;
export const Spec$Spec$2 = (value) => value.update;
export const Spec$Spec$exit = (value) => value.exit;
export const Spec$Spec$3 = (value) => value.exit;
export const Spec$Spec$keybinds = (value) => value.keybinds;
export const Spec$Spec$4 = (value) => value.keybinds;
export const Spec$Spec$redraw = (value) => value.redraw;
export const Spec$Spec$5 = (value) => value.redraw;

class State extends $CustomType {
  constructor(spec, model, width, height, tasks, focused, renderer, last_frame) {
    super();
    this.spec = spec;
    this.model = model;
    this.width = width;
    this.height = height;
    this.tasks = tasks;
    this.focused = focused;
    this.renderer = renderer;
    this.last_frame = last_frame;
  }
}

export class Keybinds extends $CustomType {
  constructor(exit, submit, focus_clear, focus_next, focus_prev) {
    super();
    this.exit = exit;
    this.submit = submit;
    this.focus_clear = focus_clear;
    this.focus_next = focus_next;
    this.focus_prev = focus_prev;
  }
}
export const Keybinds$Keybinds = (exit, submit, focus_clear, focus_next, focus_prev) =>
  new Keybinds(exit, submit, focus_clear, focus_next, focus_prev);
export const Keybinds$isKeybinds = (value) => value instanceof Keybinds;
export const Keybinds$Keybinds$exit = (value) => value.exit;
export const Keybinds$Keybinds$0 = (value) => value.exit;
export const Keybinds$Keybinds$submit = (value) => value.submit;
export const Keybinds$Keybinds$1 = (value) => value.submit;
export const Keybinds$Keybinds$focus_clear = (value) => value.focus_clear;
export const Keybinds$Keybinds$2 = (value) => value.focus_clear;
export const Keybinds$Keybinds$focus_next = (value) => value.focus_next;
export const Keybinds$Keybinds$3 = (value) => value.focus_next;
export const Keybinds$Keybinds$focus_prev = (value) => value.focus_prev;
export const Keybinds$Keybinds$4 = (value) => value.focus_prev;

class FocusedInput extends $CustomType {
  constructor(label, value, event, submit, cursor, offset, width) {
    super();
    this.label = label;
    this.value = value;
    this.event = event;
    this.submit = submit;
    this.cursor = cursor;
    this.offset = offset;
    this.width = width;
  }
}

class FocusedButton extends $CustomType {
  constructor(label, event) {
    super();
    this.label = label;
    this.event = event;
  }
}

class KeyPress extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Cmd extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Redraw extends $CustomType {}

class Resize extends $CustomType {
  constructor(width, height) {
    super();
    this.width = width;
    this.height = height;
  }
}

class Exit extends $CustomType {}

export class OnUpdate extends $CustomType {}
export const Redraw$OnUpdate = () => new OnUpdate();
export const Redraw$isOnUpdate = (value) => value instanceof OnUpdate;

/**
 * every x milliseconds, trigger a redraw
 * 17 for 60fps
 * 33 for 30fps
 */
export class OnTimer extends $CustomType {
  constructor(ms) {
    super();
    this.ms = ms;
  }
}
export const Redraw$OnTimer = (ms) => new OnTimer(ms);
export const Redraw$isOnTimer = (value) => value instanceof OnTimer;
export const Redraw$OnTimer$ms = (value) => value.ms;
export const Redraw$OnTimer$0 = (value) => value.ms;

class FocusClear extends $CustomType {}

class FocusNext extends $CustomType {}

class FocusPrev extends $CustomType {}

class Element extends $CustomType {
  constructor(content, width, height) {
    super();
    this.content = content;
    this.width = width;
    this.height = height;
  }
}

class Pos extends $CustomType {
  constructor(x, y, width, height, align) {
    super();
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.align = align;
  }
}

/**
 * A field for text input
 */
export class Input extends $CustomType {
  constructor(label, value, width, event, submit, hidden) {
    super();
    this.label = label;
    this.value = value;
    this.width = width;
    this.event = event;
    this.submit = submit;
    this.hidden = hidden;
  }
}
export const Node$Input = (label, value, width, event, submit, hidden) =>
  new Input(label, value, width, event, submit, hidden);
export const Node$isInput = (value) => value instanceof Input;
export const Node$Input$label = (value) => value.label;
export const Node$Input$0 = (value) => value.label;
export const Node$Input$value = (value) => value.value;
export const Node$Input$1 = (value) => value.value;
export const Node$Input$width = (value) => value.width;
export const Node$Input$2 = (value) => value.width;
export const Node$Input$event = (value) => value.event;
export const Node$Input$3 = (value) => value.event;
export const Node$Input$submit = (value) => value.submit;
export const Node$Input$4 = (value) => value.submit;
export const Node$Input$hidden = (value) => value.hidden;
export const Node$Input$5 = (value) => value.hidden;

export class HR extends $CustomType {}
export const Node$HR = () => new HR();
export const Node$isHR = (value) => value instanceof HR;

/**
 * A colored horizontal line
 */
export class HR2 extends $CustomType {
  constructor(color) {
    super();
    this.color = color;
  }
}
export const Node$HR2 = (color) => new HR2(color);
export const Node$isHR2 = (value) => value instanceof HR2;
export const Node$HR2$color = (value) => value.color;
export const Node$HR2$0 = (value) => value.color;

/**
 * A row with a background color
 */
export class Bar extends $CustomType {
  constructor(color) {
    super();
    this.color = color;
  }
}
export const Node$Bar = (color) => new Bar(color);
export const Node$isBar = (value) => value instanceof Bar;
export const Node$Bar$color = (value) => value.color;
export const Node$Bar$0 = (value) => value.color;

/**
 * A row with a background color, containing items
 */
export class Bar2 extends $CustomType {
  constructor(color, node) {
    super();
    this.color = color;
    this.node = node;
  }
}
export const Node$Bar2 = (color, node) => new Bar2(color, node);
export const Node$isBar2 = (value) => value instanceof Bar2;
export const Node$Bar2$color = (value) => value.color;
export const Node$Bar2$0 = (value) => value.color;
export const Node$Bar2$node = (value) => value.node;
export const Node$Bar2$1 = (value) => value.node;

export class BR extends $CustomType {}
export const Node$BR = () => new BR();
export const Node$isBR = (value) => value instanceof BR;

/**
 * A multi-line text string
 */
export class TextMulti extends $CustomType {
  constructor(text, wrap, fg, bg) {
    super();
    this.text = text;
    this.wrap = wrap;
    this.fg = fg;
    this.bg = bg;
  }
}
export const Node$TextMulti = (text, wrap, fg, bg) =>
  new TextMulti(text, wrap, fg, bg);
export const Node$isTextMulti = (value) => value instanceof TextMulti;
export const Node$TextMulti$text = (value) => value.text;
export const Node$TextMulti$0 = (value) => value.text;
export const Node$TextMulti$wrap = (value) => value.wrap;
export const Node$TextMulti$1 = (value) => value.wrap;
export const Node$TextMulti$fg = (value) => value.fg;
export const Node$TextMulti$2 = (value) => value.fg;
export const Node$TextMulti$bg = (value) => value.bg;
export const Node$TextMulti$3 = (value) => value.bg;

/**
 * A button assigned to a key press to execute an event
 */
export class Button extends $CustomType {
  constructor(id, text, key, event, fg, bg, focus_fg, focus_bg) {
    super();
    this.id = id;
    this.text = text;
    this.key = key;
    this.event = event;
    this.fg = fg;
    this.bg = bg;
    this.focus_fg = focus_fg;
    this.focus_bg = focus_bg;
  }
}
export const Node$Button = (id, text, key, event, fg, bg, focus_fg, focus_bg) =>
  new Button(id, text, key, event, fg, bg, focus_fg, focus_bg);
export const Node$isButton = (value) => value instanceof Button;
export const Node$Button$id = (value) => value.id;
export const Node$Button$0 = (value) => value.id;
export const Node$Button$text = (value) => value.text;
export const Node$Button$1 = (value) => value.text;
export const Node$Button$key = (value) => value.key;
export const Node$Button$2 = (value) => value.key;
export const Node$Button$event = (value) => value.event;
export const Node$Button$3 = (value) => value.event;
export const Node$Button$fg = (value) => value.fg;
export const Node$Button$4 = (value) => value.fg;
export const Node$Button$bg = (value) => value.bg;
export const Node$Button$5 = (value) => value.bg;
export const Node$Button$focus_fg = (value) => value.focus_fg;
export const Node$Button$6 = (value) => value.focus_fg;
export const Node$Button$focus_bg = (value) => value.focus_bg;
export const Node$Button$7 = (value) => value.focus_bg;

/**
 * A non-visible button assigned to a key press to execute an event
 */
export class KeyBind extends $CustomType {
  constructor(key, event) {
    super();
    this.key = key;
    this.event = event;
  }
}
export const Node$KeyBind = (key, event) => new KeyBind(key, event);
export const Node$isKeyBind = (value) => value instanceof KeyBind;
export const Node$KeyBind$key = (value) => value.key;
export const Node$KeyBind$0 = (value) => value.key;
export const Node$KeyBind$event = (value) => value.event;
export const Node$KeyBind$1 = (value) => value.event;

/**
 * Sets alignment of all child nodes
 */
export class Aligned extends $CustomType {
  constructor(align, node) {
    super();
    this.align = align;
    this.node = node;
  }
}
export const Node$Aligned = (align, node) => new Aligned(align, node);
export const Node$isAligned = (value) => value instanceof Aligned;
export const Node$Aligned$align = (value) => value.align;
export const Node$Aligned$0 = (value) => value.align;
export const Node$Aligned$node = (value) => value.node;
export const Node$Aligned$1 = (value) => value.node;

/**
 * A container element for holding other nodes over multiple lines
 */
export class Col extends $CustomType {
  constructor(children) {
    super();
    this.children = children;
  }
}
export const Node$Col = (children) => new Col(children);
export const Node$isCol = (value) => value instanceof Col;
export const Node$Col$children = (value) => value.children;
export const Node$Col$0 = (value) => value.children;

/**
 * A container element for holding other nodes in a single line
 */
export class Row extends $CustomType {
  constructor(children) {
    super();
    this.children = children;
  }
}
export const Node$Row = (children) => new Row(children);
export const Node$isRow = (value) => value instanceof Row;
export const Node$Row$children = (value) => value.children;
export const Node$Row$0 = (value) => value.children;

/**
 * A box container element for holding other nodes
 */
export class Box extends $CustomType {
  constructor(children, title, fg) {
    super();
    this.children = children;
    this.title = title;
    this.fg = fg;
  }
}
export const Node$Box = (children, title, fg) => new Box(children, title, fg);
export const Node$isBox = (value) => value instanceof Box;
export const Node$Box$children = (value) => value.children;
export const Node$Box$0 = (value) => value.children;
export const Node$Box$title = (value) => value.title;
export const Node$Box$1 = (value) => value.title;
export const Node$Box$fg = (value) => value.fg;
export const Node$Box$2 = (value) => value.fg;

/**
 * A table layout
 */
export class Table extends $CustomType {
  constructor(width, table) {
    super();
    this.width = width;
    this.table = table;
  }
}
export const Node$Table = (width, table) => new Table(width, table);
export const Node$isTable = (value) => value instanceof Table;
export const Node$Table$width = (value) => value.width;
export const Node$Table$0 = (value) => value.width;
export const Node$Table$table = (value) => value.table;
export const Node$Table$1 = (value) => value.table;

/**
 * A Key-Value style table layout
 */
export class TableKV extends $CustomType {
  constructor(width, table) {
    super();
    this.width = width;
    this.table = table;
  }
}
export const Node$TableKV = (width, table) => new TableKV(width, table);
export const Node$isTableKV = (value) => value instanceof TableKV;
export const Node$TableKV$width = (value) => value.width;
export const Node$TableKV$0 = (value) => value.width;
export const Node$TableKV$table = (value) => value.table;
export const Node$TableKV$1 = (value) => value.table;

/**
 * An extremely simple plot
 */
export class Graph extends $CustomType {
  constructor(width, height, points) {
    super();
    this.width = width;
    this.height = height;
    this.points = points;
  }
}
export const Node$Graph = (width, height, points) =>
  new Graph(width, height, points);
export const Node$isGraph = (value) => value instanceof Graph;
export const Node$Graph$width = (value) => value.width;
export const Node$Graph$0 = (value) => value.width;
export const Node$Graph$height = (value) => value.height;
export const Node$Graph$1 = (value) => value.height;
export const Node$Graph$points = (value) => value.points;
export const Node$Graph$2 = (value) => value.points;

export class Debug extends $CustomType {}
export const Node$Debug = () => new Debug();
export const Node$isDebug = (value) => value instanceof Debug;

/**
 * A progress bar, will automatically calculate fill percent based off max and current values
 */
export class Progress extends $CustomType {
  constructor(width, max, value, color) {
    super();
    this.width = width;
    this.max = max;
    this.value = value;
    this.color = color;
  }
}
export const Node$Progress = (width, max, value, color) =>
  new Progress(width, max, value, color);
export const Node$isProgress = (value) => value instanceof Progress;
export const Node$Progress$width = (value) => value.width;
export const Node$Progress$0 = (value) => value.width;
export const Node$Progress$max = (value) => value.max;
export const Node$Progress$1 = (value) => value.max;
export const Node$Progress$value = (value) => value.value;
export const Node$Progress$2 = (value) => value.value;
export const Node$Progress$color = (value) => value.color;
export const Node$Progress$3 = (value) => value.color;

/**
 * Wraps a `Layout`
 */
export class Layouts extends $CustomType {
  constructor(layout) {
    super();
    this.layout = layout;
  }
}
export const Node$Layouts = (layout) => new Layouts(layout);
export const Node$isLayouts = (value) => value instanceof Layouts;
export const Node$Layouts$layout = (value) => value.layout;
export const Node$Layouts$0 = (value) => value.layout;

/**
 * A base64 image using kitty graphics protocol
 */
export class Graphic extends $CustomType {
  constructor(payload) {
    super();
    this.payload = payload;
  }
}
export const Node$Graphic = (payload) => new Graphic(payload);
export const Node$isGraphic = (value) => value instanceof Graphic;
export const Node$Graphic$payload = (value) => value.payload;
export const Node$Graphic$0 = (value) => value.payload;

class SepRow extends $CustomType {}

class SepCol extends $CustomType {}

export class Wrap extends $CustomType {}
export const TextWrap$Wrap = () => new Wrap();
export const TextWrap$isWrap = (value) => value instanceof Wrap;

export class NoWrap extends $CustomType {}
export const TextWrap$NoWrap = () => new NoWrap();
export const TextWrap$isNoWrap = (value) => value instanceof NoWrap;

class Iput extends $CustomType {
  constructor(width, height, title, text, pressed, cursor, offset, hidden) {
    super();
    this.width = width;
    this.height = height;
    this.title = title;
    this.text = text;
    this.pressed = pressed;
    this.cursor = cursor;
    this.offset = offset;
    this.hidden = hidden;
  }
}

class Btn extends $CustomType {
  constructor(width, height, text, pressed, align, fg, bg, focus_fg, focus_bg) {
    super();
    this.width = width;
    this.height = height;
    this.text = text;
    this.pressed = pressed;
    this.align = align;
    this.fg = fg;
    this.bg = bg;
    this.focus_fg = focus_fg;
    this.focus_bg = focus_bg;
  }
}

/**
 * A grid-based layout defining rows and columns which contain cells and the gaps between them.
 *
 * This should be remeniscent of CSS Grid. You define a list of rows and
 * columns by size, then use Cells to fill the rows/columns to create descrete
 * areas of ui elements.
 *
 * Consider using some of the default provided layouts, such as
 * `layout_center` and `layout_split` or view the examples/layouts for more
 * complex custom layouts.
 *
 * Note: Layouts can be nested as long as it is the only child of a cell.
 */
export class Grid extends $CustomType {
  constructor(gap, rows, columns, cells) {
    super();
    this.gap = gap;
    this.rows = rows;
    this.columns = columns;
    this.cells = cells;
  }
}
export const Layout$Grid = (gap, rows, columns, cells) =>
  new Grid(gap, rows, columns, cells);
export const Layout$isGrid = (value) => value instanceof Grid;
export const Layout$Grid$gap = (value) => value.gap;
export const Layout$Grid$0 = (value) => value.gap;
export const Layout$Grid$rows = (value) => value.rows;
export const Layout$Grid$1 = (value) => value.rows;
export const Layout$Grid$columns = (value) => value.columns;
export const Layout$Grid$2 = (value) => value.columns;
export const Layout$Grid$cells = (value) => value.cells;
export const Layout$Grid$3 = (value) => value.cells;

export class Cell extends $CustomType {
  constructor(content, row, col) {
    super();
    this.content = content;
    this.row = row;
    this.col = col;
  }
}
export const Cell$Cell = (content, row, col) => new Cell(content, row, col);
export const Cell$isCell = (value) => value instanceof Cell;
export const Cell$Cell$content = (value) => value.content;
export const Cell$Cell$0 = (value) => value.content;
export const Cell$Cell$row = (value) => value.row;
export const Cell$Cell$1 = (value) => value.row;
export const Cell$Cell$col = (value) => value.col;
export const Cell$Cell$2 = (value) => value.col;

class Clear extends $CustomType {}

class Top extends $CustomType {}

class HideCursor extends $CustomType {}

class ShowCursor extends $CustomType {}

class SetPos extends $CustomType {
  constructor(x, y) {
    super();
    this.x = x;
    this.y = y;
  }
}

class SavePos extends $CustomType {}

class LoadPos extends $CustomType {}

class MoveUp extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class MoveDown extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class MoveLeft extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class MoveRight extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StartLine extends $CustomType {}

class Column extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Fg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Bg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class SGR extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Reset extends $CustomType {}

class GetPos extends $CustomType {}

class AltBuffer extends $CustomType {}

class MainBuffer extends $CustomType {}

class BSU extends $CustomType {}

class ESU extends $CustomType {}

class Graphics extends $CustomType {
  constructor(format, compress, payload) {
    super();
    this.format = format;
    this.compress = compress;
    this.payload = payload;
  }
}

class TransmitAndDisplay extends $CustomType {}

class RGB extends $CustomType {}

class RGBA extends $CustomType {}

class PNG extends $CustomType {}

class Bold extends $CustomType {}

class Faint extends $CustomType {}

class Italic extends $CustomType {}

class Underline extends $CustomType {}

class Noshell extends $CustomType {}

class Raw extends $CustomType {}

const esc = "\u{001b}";

function default_renderer_loop(state, msg) {
  let _pipe = msg;
  $io.print(_pipe)
  return $actor.continue$(state);
}

/**
 * Allows sending a message to your TUI from another actor. This can be used,
 * for example, to push an event to your TUI, rather than have it poll.
 */
export function send(msg) {
  return new Cmd(msg);
}

/**
 * Manually trigger the exit for your TUI. Normally this would be handled
 * through the exit keybind.
 */
export function exit() {
  return new Exit();
}

export function key_press(key) {
  return new KeyPress(key);
}

export function resize(width, height) {
  return new Resize(width, height);
}

function focus_next(loop$focusable, loop$focused, loop$next) {
  while (true) {
    let focusable = loop$focusable;
    let focused = loop$focused;
    let next = loop$next;
    if (focusable instanceof $Empty) {
      return new None();
    } else {
      let x = focusable.head;
      let xs = focusable.tail;
      if (next) {
        return new Some(x);
      } else {
        loop$focusable = xs;
        loop$focused = focused;
        loop$next = x.label === focused.label;
      }
    }
  }
}

function focus_current(loop$focusable, loop$focused) {
  while (true) {
    let focusable = loop$focusable;
    let focused = loop$focused;
    if (focusable instanceof $Empty) {
      return new None();
    } else {
      let x = focusable.head;
      let xs = focusable.tail;
      let $ = x.label === focused.label;
      if ($) {
        let _block;
        if (x instanceof FocusedInput && focused instanceof FocusedInput) {
          let new$ = x;
          let old = focused;
          let $1 = old.cursor > $string.length(new$.value);
          if ($1) {
            _block = new FocusedInput(
              new$.label,
              new$.value,
              new$.event,
              new$.submit,
              $string.length(new$.value),
              0,
              new$.width,
            );
          } else {
            _block = new FocusedInput(
              new$.label,
              new$.value,
              new$.event,
              new$.submit,
              old.cursor,
              old.offset,
              new$.width,
            );
          }
        } else {
          _block = x;
        }
        let _pipe = _block;
        return new Some(_pipe);
      } else {
        loop$focusable = xs;
        loop$focused = focused;
      }
    }
  }
}

function input_offset(cursor, offset, width) {
  let x = cursor;
  if (x < offset) {
    return cursor;
  } else {
    let x = cursor;
    if (x >= (offset + (width - 3))) {
      return (cursor - width) + 3;
    } else {
      return offset;
    }
  }
}

function string_insert(str, cursor, char) {
  let x = cursor;
  if (x <= 0) {
    return char + str;
  } else {
    let _pipe = str;
    let _pipe$1 = $string.to_graphemes(_pipe);
    let _pipe$2 = $list.index_map(
      _pipe$1,
      (i, idx) => {
        let $ = idx === (cursor - 1);
        if ($) {
          return i + char;
        } else {
          return i;
        }
      },
    );
    return $string.join(_pipe$2, "");
  }
}

function string_backspace(str, cursor, offset) {
  let _pipe = str;
  let _pipe$1 = $string.to_graphemes(_pipe);
  let _pipe$2 = $list.index_fold(
    _pipe$1,
    toList([]),
    (acc, i, idx) => {
      let $ = idx === (cursor + offset);
      if ($) {
        return acc;
      } else {
        return listPrepend(i, acc);
      }
    },
  );
  let _pipe$3 = $list.reverse(_pipe$2);
  return $string.join(_pipe$3, "");
}

function input_handler(focused, key) {
  if (focused instanceof FocusedInput) {
    let focused$1 = focused;
    if (key instanceof $key.Backspace) {
      let cursor = $int.max(0, focused$1.cursor - 1);
      let offset = $int.max(0, focused$1.offset - 1);
      return new FocusedInput(
        focused$1.label,
        (() => {
          let _pipe = focused$1.value;
          return string_backspace(_pipe, focused$1.cursor, -1);
        })(),
        focused$1.event,
        focused$1.submit,
        cursor,
        offset,
        focused$1.width,
      );
    } else if (key instanceof $key.Left) {
      let cursor = $int.max(0, focused$1.cursor - 1);
      let offset = input_offset(cursor, focused$1.offset, focused$1.width);
      return new FocusedInput(
        focused$1.label,
        focused$1.value,
        focused$1.event,
        focused$1.submit,
        cursor,
        offset,
        focused$1.width,
      );
    } else if (key instanceof $key.Right) {
      let cursor = $int.min(
        $string.length(focused$1.value),
        focused$1.cursor + 1,
      );
      let offset = input_offset(cursor, focused$1.offset, focused$1.width);
      return new FocusedInput(
        focused$1.label,
        focused$1.value,
        focused$1.event,
        focused$1.submit,
        cursor,
        offset,
        focused$1.width,
      );
    } else if (key instanceof $key.Home) {
      return new FocusedInput(
        focused$1.label,
        focused$1.value,
        focused$1.event,
        focused$1.submit,
        0,
        focused$1.offset,
        focused$1.width,
      );
    } else if (key instanceof $key.End) {
      return new FocusedInput(
        focused$1.label,
        focused$1.value,
        focused$1.event,
        focused$1.submit,
        $string.length(focused$1.value),
        focused$1.offset,
        focused$1.width,
      );
    } else if (key instanceof $key.Delete) {
      let _block;
      let $ = focused$1.cursor === $string.length(focused$1.value);
      if ($) {
        _block = focused$1.offset;
      } else {
        _block = $int.max(0, focused$1.offset - 1);
      }
      let offset = _block;
      return new FocusedInput(
        focused$1.label,
        (() => {
          let _pipe = focused$1.value;
          return string_backspace(_pipe, focused$1.cursor, 0);
        })(),
        focused$1.event,
        focused$1.submit,
        focused$1.cursor,
        offset,
        focused$1.width,
      );
    } else if (key instanceof $key.Char) {
      let char = key[0];
      let cursor = focused$1.cursor + $string.length(char);
      let offset = input_offset(cursor, focused$1.offset, focused$1.width);
      return new FocusedInput(
        focused$1.label,
        string_insert(focused$1.value, focused$1.cursor, char),
        focused$1.event,
        focused$1.submit,
        cursor,
        offset,
        focused$1.width,
      );
    } else {
      return focused$1;
    }
  } else {
    return focused;
  }
}

function control_event(input, keybinds) {
  let x = input;
  if (isEqual(x, keybinds.focus_clear)) {
    let _pipe = new FocusClear();
    return new Some(_pipe);
  } else {
    let x = input;
    if (isEqual(x, keybinds.focus_next)) {
      let _pipe = new FocusNext();
      return new Some(_pipe);
    } else {
      let x = input;
      if (isEqual(x, keybinds.focus_prev)) {
        let _pipe = new FocusPrev();
        return new Some(_pipe);
      } else {
        return new None();
      }
    }
  }
}

function element_join_loop(loop$elements, loop$separator, loop$accumulator) {
  while (true) {
    let elements = loop$elements;
    let separator = loop$separator;
    let accumulator = loop$accumulator;
    if (elements instanceof $Empty) {
      return accumulator;
    } else {
      let element = elements.head;
      let elements$1 = elements.tail;
      loop$elements = elements$1;
      loop$separator = separator;
      loop$accumulator = new Element(
        (accumulator.content + separator) + element.content,
        accumulator.width + element.width,
        accumulator.height + element.height,
      );
    }
  }
}

function element_join(elements, separator) {
  if (elements instanceof $Empty) {
    return new Element("", 0, 0);
  } else {
    let first = elements.head;
    let rest = elements.tail;
    return element_join_loop(rest, separator, first);
  }
}

function element_prefix(element, prefix) {
  return new Element(prefix + element.content, element.width, element.height);
}

function calc_size(size, width) {
  if (size instanceof $style.Px) {
    let px = size[0];
    return px;
  } else if (size instanceof $style.Pct) {
    let pct = size[0];
    return globalThis.Math.trunc((width * pct) / 100);
  } else {
    return width;
  }
}

function calc_size_input(size, width, label) {
  return calc_size(size, width - $string.length(label));
}

function right_is_left(align) {
  if (align instanceof $style.Right) {
    return new $style.Left();
  } else {
    return align;
  }
}

function middle(width) {
  let fill = " ";
  let _pipe = toList(["│", $string.repeat(fill, width), "│"]);
  return $string.join(_pipe, "");
}

function text_wrap_loop(
  loop$text,
  loop$width,
  loop$count,
  loop$word,
  loop$line,
  loop$acc
) {
  while (true) {
    let text = loop$text;
    let width = loop$width;
    let count = loop$count;
    let word = loop$word;
    let line = loop$line;
    let acc = loop$acc;
    let append = (word, line, acc) => {
      let _block;
      let _pipe = $list.append(word, line);
      let _pipe$1 = $list.reverse(_pipe);
      _block = $string.join(_pipe$1, "");
      let line$1 = _block;
      return listPrepend(line$1, acc);
    };
    if (text instanceof $Empty) {
      let _pipe = append(word, line, acc);
      return $list.reverse(_pipe);
    } else {
      let $ = text.head;
      if ($ === "\n") {
        let xs = text.tail;
        loop$text = xs;
        loop$width = width;
        loop$count = 0;
        loop$word = toList([]);
        loop$line = toList([]);
        loop$acc = append(word, line, acc);
      } else if ($ === " ") {
        let xs = text.tail;
        loop$text = xs;
        loop$width = width;
        loop$count = count + 1;
        loop$word = toList([]);
        loop$line = $list.append(listPrepend(" ", word), line);
        loop$acc = acc;
      } else {
        let x = $;
        let xs = text.tail;
        let $1 = count >= width;
        if ($1) {
          loop$text = $list.append($list.reverse(listPrepend(x, word)), xs);
          loop$width = width;
          loop$count = 0;
          loop$word = toList([]);
          loop$line = toList([]);
          loop$acc = append(toList([]), line, acc);
        } else {
          loop$text = xs;
          loop$width = width;
          loop$count = count + 1;
          loop$word = listPrepend(x, word);
          loop$line = line;
          loop$acc = acc;
        }
      }
    }
  }
}

function text_wrap(text, wrap, width) {
  if (wrap instanceof Wrap) {
    return text_wrap_loop(
      $string.to_graphemes(text),
      width,
      0,
      toList([]),
      toList([]),
      toList([]),
    );
  } else {
    let _pipe = text;
    return $string.split(_pipe, "\n");
  }
}

function calc_cell_size(gap, from, to, of) {
  return $list.index_fold(
    of,
    [1, 0],
    (acc, item, idx) => {
      let x = idx;
      if ((x >= from) && (x <= to)) {
        return [acc[0], acc[1] + item];
      } else {
        let x = idx;
        if (x === (from - 1)) {
          return [(acc[0] + gap) + item, acc[1] - gap];
        } else {
          let x = idx;
          if (x < from) {
            return [acc[0] + item, acc[1]];
          } else {
            return acc;
          }
        }
      }
    },
  );
}

function do_calc_sizes(sizes, remainder_split, round_up, acc) {
  if (sizes instanceof $Empty) {
    return $list.reverse(acc);
  } else {
    let x = sizes.head;
    let xs = sizes.tail;
    if (x instanceof Some) {
      let px = x[0];
      let _pipe = listPrepend(px, acc);
      return ((_capture) => {
        return do_calc_sizes(xs, remainder_split, round_up, _capture);
      })(_pipe);
    } else {
      let _pipe = listPrepend(remainder_split + round_up, acc);
      return ((_capture) => {
        return do_calc_sizes(xs, remainder_split, 0, _capture);
      })(_pipe);
    }
  }
}

function calc_sizes(max, sizes) {
  let first = $list.map(
    sizes,
    (size) => {
      if (size instanceof $style.Px) {
        let px = size[0];
        return new Some(px);
      } else if (size instanceof $style.Pct) {
        let pct = size[0];
        return new Some(globalThis.Math.trunc((max * pct) / 100));
      } else {
        return new None();
      }
    },
  );
  let total_known_size = $list.fold(
    first,
    0,
    (acc, i) => {
      if (i instanceof Some) {
        let px = i[0];
        return acc + px;
      } else {
        return acc;
      }
    },
  );
  let _block;
  let _pipe = first;
  let _pipe$1 = $list.filter(_pipe, $option.is_none);
  _block = $list.length(_pipe$1);
  let total_unknown_count = _block;
  let remainder = max - total_known_size;
  let remainder_split = divideInt(remainder, total_unknown_count);
  let round_up = remainder - remainder_split * total_unknown_count;
  return do_calc_sizes(first, remainder_split, round_up, toList([]));
}

function layout(layout, pos) {
  let _block;
  let _pipe = layout.columns;
  _block = ((_capture) => { return calc_sizes(pos.width, _capture); })(_pipe);
  let col_sizes = _block;
  let _block$1;
  let _pipe$1 = layout.rows;
  _block$1 = ((_capture) => { return calc_sizes(pos.height, _capture); })(
    _pipe$1,
  );
  let row_sizes = _block$1;
  let _pipe$2 = layout.cells;
  return $list.map(
    _pipe$2,
    (cell) => {
      let $ = calc_cell_size(layout.gap, cell.col[0], cell.col[1], col_sizes);
      let x;
      let w;
      x = $[0];
      w = $[1];
      let $1 = calc_cell_size(layout.gap, cell.row[0], cell.row[1], row_sizes);
      let y;
      let h;
      y = $1[0];
      h = $1[1];
      return [
        cell.content,
        new Pos(pos.x + x, pos.y + y, w, h, new $style.Left()),
      ];
    },
  );
}

function do_list_focusable(loop$pos, loop$children, loop$acc) {
  while (true) {
    let pos = loop$pos;
    let children = loop$children;
    let acc = loop$acc;
    if (children instanceof $Empty) {
      return acc;
    } else {
      let x = children.head;
      let xs = children.tail;
      if (x instanceof Input) {
        let label = x.label;
        let value = x.value;
        let width = x.width;
        let event = x.event;
        let submit = x.submit;
        let cursor = $string.length(value);
        let width$1 = calc_size_input(width, pos.width, label);
        let focused = new FocusedInput(
          label,
          value,
          event,
          submit,
          cursor,
          0,
          width$1,
        );
        let offset = input_offset(cursor, focused.offset, focused.width);
        loop$pos = pos;
        loop$children = xs;
        loop$acc = listPrepend(
          new FocusedInput(
            focused.label,
            focused.value,
            focused.event,
            focused.submit,
            focused.cursor,
            offset,
            focused.width,
          ),
          acc,
        );
      } else if (x instanceof HR) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof HR2) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Bar) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Bar2) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof BR) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof TextMulti) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Button) {
        let id = x.id;
        let event = x.event;
        loop$pos = pos;
        loop$children = xs;
        loop$acc = listPrepend(new FocusedButton(id, event), acc);
      } else if (x instanceof KeyBind) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Aligned) {
        let node = x.node;
        loop$pos = pos;
        loop$children = xs;
        loop$acc = do_list_focusable(pos, toList([node]), acc);
      } else if (x instanceof Col) {
        let children$1 = x.children;
        loop$pos = pos;
        loop$children = xs;
        loop$acc = do_list_focusable(pos, children$1, acc);
      } else if (x instanceof Row) {
        let children$1 = x.children;
        loop$pos = pos;
        loop$children = xs;
        loop$acc = do_list_focusable(pos, children$1, acc);
      } else if (x instanceof Box) {
        let children$1 = x.children;
        let pos$1 = new Pos(
          pos.x,
          pos.y,
          pos.width - 4,
          pos.height - 2,
          pos.align,
        );
        loop$pos = pos$1;
        loop$children = xs;
        loop$acc = do_list_focusable(pos$1, children$1, acc);
      } else if (x instanceof Table) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof TableKV) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Graph) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Debug) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Progress) {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      } else if (x instanceof Layouts) {
        let l = x.layout;
        let _pipe = layout(l, pos);
        let _pipe$1 = $list.map(
          _pipe,
          (i) => { return do_list_focusable(i[1], toList([i[0]]), acc); },
        );
        let _pipe$2 = $list.reverse(_pipe$1);
        return $list.flatten(_pipe$2);
      } else {
        loop$pos = pos;
        loop$children = xs;
        loop$acc = acc;
      }
    }
  }
}

function list_focusable(children, state) {
  let pos = new Pos(0, 0, state.width, state.height, new $style.Left());
  return do_list_focusable(pos, children, toList([]));
}

function ignore_zero(code, i) {
  if (i === 0) {
    return "";
  } else {
    return code;
  }
}

function kitty_action(a) {
  return "a=" + (() => {
    return "T";
  })();
}

function kitty_format(f) {
  return "f=" + (() => {
    if (f instanceof RGB) {
      return "24";
    } else if (f instanceof RGBA) {
      return "32";
    } else {
      return "100";
    }
  })();
}

function kitty_payload(loop$base64, loop$acc) {
  while (true) {
    let base64 = loop$base64;
    let acc = loop$acc;
    let size = 4096;
    let $ = $string.length(base64);
    let len = $;
    if (len > size) {
      let chunk = $string.slice(base64, 0, size);
      let base64$1 = $string.slice(base64, size, len);
      loop$base64 = base64$1;
      loop$acc = listPrepend(chunk, acc);
    } else {
      return $list.reverse(listPrepend(base64, acc));
    }
  }
}

function graphic_to_string(graphic) {
  if (graphic instanceof Bold) {
    return "1";
  } else if (graphic instanceof Faint) {
    return "2";
  } else if (graphic instanceof Italic) {
    return "3";
  } else {
    return "4";
  }
}

function col(color) {
  if (color instanceof $style.Black) {
    return "0";
  } else if (color instanceof $style.Red) {
    return "1";
  } else if (color instanceof $style.Green) {
    return "2";
  } else if (color instanceof $style.Yellow) {
    return "3";
  } else if (color instanceof $style.Blue) {
    return "4";
  } else if (color instanceof $style.Magenta) {
    return "5";
  } else if (color instanceof $style.Cyan) {
    return "6";
  } else {
    return "7";
  }
}

function kitty_code(loop$format, loop$compress, loop$payload, loop$acc) {
  while (true) {
    let format = loop$format;
    let compress = loop$compress;
    let payload = loop$payload;
    let acc = loop$acc;
    let wrap = (m, payload) => {
      return (((((((((esc + "_G") + kitty_action(new TransmitAndDisplay())) + ",") + kitty_format(
        format,
      )) + ",") + m) + ";") + payload) + esc) + "\\";
    };
    if (payload instanceof $Empty) {
      return acc;
    } else {
      let $ = payload.tail;
      if ($ instanceof $Empty) {
        let x = payload.head;
        loop$format = format;
        loop$compress = compress;
        loop$payload = toList([]);
        loop$acc = acc + wrap("m=0", x);
      } else {
        let x = payload.head;
        let xs = $;
        loop$format = format;
        loop$compress = compress;
        loop$payload = xs;
        loop$acc = acc + wrap("m=1", x);
      }
    }
  }
}

function c(loop$code) {
  while (true) {
    let code = loop$code;
    if (code instanceof Clear) {
      return ((esc + "[2J") + esc) + "[H";
    } else if (code instanceof Top) {
      return esc + "[H";
    } else if (code instanceof HideCursor) {
      return esc + "[?25l";
    } else if (code instanceof ShowCursor) {
      return esc + "[?25h";
    } else if (code instanceof SetPos) {
      let x = code.x;
      let y = code.y;
      return ((((esc + "[") + $int.to_string(x)) + ";") + $int.to_string(y)) + "H";
    } else if (code instanceof SavePos) {
      return esc + "[s";
    } else if (code instanceof LoadPos) {
      return esc + "[u";
    } else if (code instanceof MoveUp) {
      let i = code[0];
      let _pipe = (((esc + "[") + $int.to_string(i)) + "A");
      return ignore_zero(_pipe, i);
    } else if (code instanceof MoveDown) {
      let i = code[0];
      let _pipe = (((esc + "[") + $int.to_string(i)) + "B");
      return ignore_zero(_pipe, i);
    } else if (code instanceof MoveLeft) {
      let i = code[0];
      let _pipe = (((esc + "[") + $int.to_string(i)) + "D");
      return ignore_zero(_pipe, i);
    } else if (code instanceof MoveRight) {
      let i = code[0];
      let _pipe = (((esc + "[") + $int.to_string(i)) + "C");
      return ignore_zero(_pipe, i);
    } else if (code instanceof StartLine) {
      let _pipe = new Column(1);
      loop$code = _pipe;
    } else if (code instanceof Column) {
      let i = code[0];
      return ((esc + "[") + $int.to_string(i)) + "G";
    } else if (code instanceof Fg) {
      let color = code[0];
      return ((esc + "[3") + col(color)) + "m";
    } else if (code instanceof Bg) {
      let color = code[0];
      return ((esc + "[4") + col(color)) + "m";
    } else if (code instanceof SGR) {
      let graphic = code[0];
      return ((esc + "[") + graphic_to_string(graphic)) + "m";
    } else if (code instanceof Reset) {
      return esc + "[0m";
    } else if (code instanceof GetPos) {
      return esc + "[6n";
    } else if (code instanceof AltBuffer) {
      return esc + "[?1049h";
    } else if (code instanceof MainBuffer) {
      return esc + "[?1049l";
    } else if (code instanceof BSU) {
      return esc + "[?2026h";
    } else if (code instanceof ESU) {
      return esc + "[?2026l";
    } else {
      let format = code.format;
      let compress = code.compress;
      let payload = code.payload;
      let _pipe = payload;
      let _pipe$1 = kitty_payload(_pipe, toList([]));
      return ((_capture) => {
        return kitty_code(format, compress, _capture, "");
      })(_pipe$1);
    }
  }
}

function sep(separator) {
  if (separator instanceof SepRow) {
    return c(new MoveRight(1));
  } else {
    return (c(new LoadPos()) + c(new MoveDown(1))) + c(new SavePos());
  }
}

function calc_align_len(text, align, width, len) {
  let center = (globalThis.Math.trunc(width / 2)) - (globalThis.Math.trunc(
    len / 2
  ));
  if (align instanceof $style.Left) {
    return text;
  } else if (align instanceof $style.Center) {
    return ((c(new SavePos()) + c(new MoveRight(center))) + text) + c(
      new LoadPos(),
    );
  } else {
    return ((c(new SavePos()) + c(new MoveRight(width - len))) + text) + c(
      new LoadPos(),
    );
  }
}

function calc_align(text, align, width) {
  let _block;
  let _pipe = text;
  _block = $string.length(_pipe);
  let len = _block;
  return calc_align_len(text, align, width, len);
}

function do_middle(loop$width, loop$height, loop$acc) {
  while (true) {
    let width = loop$width;
    let height = loop$height;
    let acc = loop$acc;
    if (height === 0) {
      let _pipe = acc;
      return $string.join(
        _pipe,
        c(new MoveLeft(width + 2)) + c(new MoveDown(1)),
      );
    } else {
      let h = height;
      loop$width = width;
      loop$height = h - 1;
      loop$acc = listPrepend(middle(width), acc);
    }
  }
}

function style_text(text, fg, bg) {
  return (((c(new Reset()) + (() => {
    let _pipe = $option.map(fg, (o) => { return c(new Fg(o)); });
    return $option.unwrap(_pipe, "");
  })()) + (() => {
    let _pipe = $option.map(bg, (o) => { return c(new Bg(o)); });
    return $option.unwrap(_pipe, "");
  })()) + text) + c(new Reset());
}

function draw_text_multi(text, wrap, fg, bg, pos) {
  let width = pos.width - 2;
  let height = pos.height;
  let text$1 = ((c(new SavePos()) + (() => {
    let _pipe = text;
    let _pipe$1 = text_wrap(_pipe, wrap, width - 1);
    let _pipe$2 = $list.take(_pipe$1, height);
    let _pipe$3 = $list.map(
      _pipe$2,
      (_capture) => { return $string.slice(_capture, 0, width); },
    );
    let _pipe$4 = $list.map(
      _pipe$3,
      (_capture) => { return calc_align(_capture, pos.align, pos.width); },
    );
    return $string.join(
      _pipe$4,
      (c(new LoadPos()) + c(new MoveDown(1))) + c(new SavePos()),
    );
  })()) + c(new LoadPos())) + c(new MoveDown(1));
  let _pipe = text$1;
  let _pipe$1 = style_text(_pipe, fg, bg);
  return new Element(_pipe$1, width, height);
}

function map_cursor(str, cursor, width) {
  let _block;
  let _pipe = cursor;
  _block = $int.min(_pipe, width - 2);
  let pos = _block;
  let _pipe$1 = str;
  let _pipe$2 = $string.to_graphemes(_pipe$1);
  let _pipe$3 = $list.index_map(
    _pipe$2,
    (i, idx) => {
      let $ = idx === pos;
      if ($) {
        return ((c(new Bg(new $style.White())) + c(new Fg(new $style.Black()))) + i) + c(
          new Reset(),
        );
      } else {
        return i;
      }
    },
  );
  return $string.join(_pipe$3, "");
}

function draw_input(input) {
  let _block;
  let $ = input.pressed;
  if ($) {
    let _pipe = new $style.Green();
    let _pipe$1 = new Fg(_pipe);
    _block = c(_pipe$1);
  } else {
    let _pipe = new $style.Blue();
    let _pipe$1 = new Fg(_pipe);
    _block = c(_pipe$1);
  }
  let color = _block;
  let in_width = input.width - 2;
  let _block$1;
  let $1 = input.hidden;
  if ($1) {
    let _pipe = $string.length(input.text);
    _block$1 = ((_capture) => { return $string.repeat("•", _capture); })(_pipe);
  } else {
    _block$1 = input.text;
  }
  let text = _block$1;
  let text$1 = text + " ";
  let _block$2;
  let _pipe = text$1;
  let _pipe$1 = $string.slice(_pipe, input.offset, in_width);
  _block$2 = ((x) => {
    let $2 = input.pressed;
    if ($2) {
      return map_cursor(x, input.cursor - input.offset, input.width);
    } else {
      return x;
    }
  })(_pipe$1);
  let text_trim = _block$2;
  let _pipe$2 = toList([
    c(new Reset()),
    color,
    input.title,
    " ",
    c(new Reset()),
    text_trim,
  ]);
  let _pipe$3 = $string.join(_pipe$2, "");
  return new Element(_pipe$3, input.width, input.height);
}

function draw_btn(btn) {
  let button = (("  " + btn.text) + "  ");
  let width = $string.length(button);
  let _block;
  let _pipe = button;
  _block = calc_align(_pipe, btn.align, btn.width);
  let button$1 = _block;
  let _block$1;
  let $ = btn.pressed;
  if ($) {
    _block$1 = btn.focus_bg;
  } else {
    _block$1 = btn.bg;
  }
  let bg = _block$1;
  let _block$2;
  let $1 = btn.pressed;
  if ($1) {
    _block$2 = btn.focus_fg;
  } else {
    _block$2 = btn.fg;
  }
  let fg = _block$2;
  let _pipe$1 = button$1;
  let _pipe$2 = style_text(_pipe$1, fg, bg);
  return new Element(_pipe$2, width, 1);
}

function draw_box(width, height, title, fg) {
  let _block;
  let _block$1;
  if (title instanceof Some) {
    let title$1 = title[0];
    _block$1 = toList([
      "╭",
      "─",
      " ",
      title$1,
      " ",
      $string.repeat("─", (width - 3) - $string.length(title$1)),
      "╮",
    ]);
  } else {
    _block$1 = toList(["╭", $string.repeat("─", width), "╮"]);
  }
  let _pipe = _block$1;
  _block = $string.join(_pipe, "");
  let top = _block;
  let _block$2;
  let _pipe$1 = toList(["╰", $string.repeat("─", width), "╯"]);
  _block$2 = $string.join(_pipe$1, "");
  let bottom = _block$2;
  let start$1 = c(new MoveLeft(width + 2)) + c(new MoveDown(1));
  let _pipe$2 = toList([
    c(new SavePos()),
    top,
    start$1,
    do_middle(width, height, toList([])),
    start$1,
    bottom,
    c(new LoadPos()),
    c(new MoveRight(2)),
    c(new SavePos()),
  ]);
  let _pipe$3 = $string.join(_pipe$2, "");
  let _pipe$4 = style_text(_pipe$3, fg, new None());
  return new Element(_pipe$4, width, height);
}

function draw_progress(width, max, value, color, pos) {
  let progress = divideInt(value * 100, max);
  let _block;
  let _pipe = (globalThis.Math.trunc((progress * width) / 100));
  _block = $int.clamp(_pipe, 0, width);
  let complete = _block;
  let rest = width - complete;
  let len = complete + rest;
  let _pipe$1 = toList([
    c(new Reset()),
    c(new Fg(color)),
    $string.repeat("█", complete),
    c(new Reset()),
    $string.repeat("░", rest),
  ]);
  let _pipe$2 = $string.join(_pipe$1, "");
  let _pipe$3 = calc_align_len(_pipe$2, pos.align, pos.width, len);
  return new Element(_pipe$3, width, 1);
}

function draw_table(width, values, pos) {
  let width$1 = $int.min(width, pos.width);
  let _block;
  let _pipe = values;
  _block = $list.length(_pipe);
  let row_count = _block;
  let height = $int.min(row_count, pos.height);
  let values$1 = $list.take(values, height);
  let _block$1;
  let _pipe$1 = values$1;
  let _pipe$2 = $list.first(_pipe$1);
  let _pipe$3 = $result.map(_pipe$2, $list.length);
  _block$1 = $result.unwrap(_pipe$3, 1);
  let col_count = _block$1;
  let col_width = divideInt(width$1, col_count);
  let col_left_over = width$1 - col_width * col_count;
  let start$1 = c(new MoveLeft(width$1)) + c(new MoveDown(1));
  let row = (row, idx) => {
    let _pipe$4 = $list.map(
      row,
      (col) => {
        let $ = $string.length(col);
        let x = $;
        if (x >= col_width) {
          return $string.slice(col, 0, col_width - 3) + ".. ";
        } else {
          let x = $;
          return col + c(new MoveRight(col_width - x));
        }
      },
    );
    let _pipe$5 = $string.join(_pipe$4, "");
    return ((row) => {
      if (idx === 0) {
        return ((((c(new SGR(new Bold())) + c(new Fg(new $style.Blue()))) + row) + c(
          new Reset(),
        )) + c(new MoveRight(col_left_over))) + start$1;
      } else {
        return (row + c(new MoveRight(col_left_over))) + start$1;
      }
    })(_pipe$5);
  };
  let _block$2;
  let _pipe$4 = values$1;
  let _pipe$5 = $list.index_map(_pipe$4, row);
  _block$2 = $string.join(_pipe$5, "");
  let rows = _block$2;
  let _block$3;
  let _pipe$6 = toList([c(new MoveUp(1)), c(new SavePos())]);
  _block$3 = $string.join(_pipe$6, "");
  let join_offset = _block$3;
  let _pipe$7 = toList([c(new Reset()), rows, join_offset]);
  let _pipe$8 = $string.join(_pipe$7, "");
  return new Element(_pipe$8, width$1, height);
}

function draw_table_kv(width, values, pos) {
  let width$1 = $int.min(width, pos.width);
  let _block;
  let _pipe = values;
  _block = $list.length(_pipe);
  let row_count = _block;
  let height = $int.min(row_count, pos.height);
  let values$1 = $list.take(values, height);
  let _block$1;
  let _pipe$1 = values$1;
  let _pipe$2 = $list.first(_pipe$1);
  let _pipe$3 = $result.map(_pipe$2, $list.length);
  _block$1 = $result.unwrap(_pipe$3, 1);
  let col_count = _block$1;
  let col_width = divideInt(width$1, col_count);
  let col_left_over = width$1 - col_width * col_count;
  let start$1 = c(new MoveLeft(width$1)) + c(new MoveDown(1));
  let row = (row) => {
    let _pipe$4 = $list.index_map(
      row,
      (col, idx) => {
        let _block$2;
        let $ = $string.length(col);
        let x = $;
        if (x >= col_width) {
          _block$2 = $string.slice(col, 0, col_width - 3) + ".. ";
        } else {
          let x = $;
          _block$2 = col + c(new MoveRight(col_width - x));
        }
        let trim = _block$2;
        if (idx === 0) {
          return ((c(new SGR(new Bold())) + c(new Fg(new $style.Blue()))) + trim) + c(
            new Reset(),
          );
        } else {
          return trim;
        }
      },
    );
    let _pipe$5 = $string.join(_pipe$4, "");
    return ((row) => {
      return (row + c(new MoveRight(col_left_over))) + start$1;
    })(_pipe$5);
  };
  let _block$2;
  let _pipe$4 = values$1;
  let _pipe$5 = $list.map(_pipe$4, row);
  _block$2 = $string.join(_pipe$5, "");
  let rows = _block$2;
  let _block$3;
  let _pipe$6 = toList([c(new MoveUp(1)), c(new SavePos())]);
  _block$3 = $string.join(_pipe$6, "");
  let join_offset = _block$3;
  let _pipe$7 = toList([c(new Reset()), rows, join_offset]);
  let _pipe$8 = $string.join(_pipe$7, "");
  return new Element(_pipe$8, width$1, height);
}

function draw_graph(width, height, values) {
  let values$1 = $list.take(values, width);
  let lhs = $string.repeat(
    ("│" + c(new MoveLeft(1))) + c(new MoveDown(1)),
    height,
  );
  let btm = $string.repeat("─", width - 1);
  let content = $result.map(
    $list.max(values$1, $float.compare),
    (max) => {
      let _block;
      let _pipe = values$1;
      let _pipe$1 = $list.map(
        _pipe,
        (value) => {
          let height$1 = height - 1;
          let pct = (divideFloat(value, max)) * 100.0;
          let offset = (($int.to_float(height$1) * pct)) / 100.0;
          let down = $int.to_float(height$1) - offset;
          let _block$1;
          let _pipe$1 = down;
          _block$1 = $float.round(_pipe$1);
          let d = _block$1;
          return (c(new MoveDown(d)) + "•") + c(new MoveUp(d));
        },
      );
      _block = $string.join(_pipe$1, "");
      let plot = _block;
      let _block$1;
      let _pipe$2 = toList([
        c(new Reset()),
        c(new SavePos()),
        lhs,
        c(new MoveUp(1)),
        "╰",
        btm,
        c(new LoadPos()),
        c(new SavePos()),
        c(new MoveRight(1)),
        plot,
        c(new LoadPos()),
        c(new MoveDown(height - 1)),
        c(new SavePos()),
        c(new Reset()),
      ]);
      _block$1 = $string.join(_pipe$2, "");
      let content = _block$1;
      return new Element(content, width, height);
    },
  );
  if (content instanceof Ok) {
    let content$1 = content[0];
    return content$1;
  } else {
    return new Element("error finding max", 5, 1);
  }
}

function draw_graphic(payload) {
  return new Element(c(new Graphics(new PNG(), false, payload)), 10, 10);
}

function render_node(loop$state, loop$node, loop$last_input, loop$pos) {
  while (true) {
    let state = loop$state;
    let node = loop$node;
    let last_input = loop$last_input;
    let pos = loop$pos;
    if (node instanceof Input) {
      let label = node.label;
      let value = node.value;
      let width = node.width;
      let hidden = node.hidden;
      let width$1 = calc_size_input(width, pos.width, label);
      let _block;
      let $1 = state.focused;
      if ($1 instanceof Some) {
        let $2 = $1[0];
        if ($2 instanceof FocusedInput) {
          let focused = $2;
          if (focused.label === label) {
            _block = [true, focused.cursor];
          } else {
            _block = [false, $string.length(value)];
          }
        } else {
          _block = [false, $string.length(value)];
        }
      } else {
        _block = [false, $string.length(value)];
      }
      let $ = _block;
      let is_focused;
      let cursor;
      is_focused = $[0];
      cursor = $[1];
      let _block$1;
      let $2 = state.focused;
      if ($2 instanceof Some) {
        let $3 = $2[0];
        if ($3 instanceof FocusedInput) {
          let focused = $3;
          if (focused.label === label) {
            _block$1 = focused.offset;
          } else {
            _block$1 = input_offset($string.length(value), 0, width$1);
          }
        } else {
          _block$1 = input_offset($string.length(value), 0, width$1);
        }
      } else {
        _block$1 = input_offset($string.length(value), 0, width$1);
      }
      let offset = _block$1;
      let _pipe = draw_input(
        new Iput(width$1, 1, label, value, is_focused, cursor, offset, hidden),
      );
      return new Some(_pipe);
    } else if (node instanceof HR) {
      let _pipe = (c(new Reset()) + $string.repeat("─", pos.width));
      let _pipe$1 = new Element(_pipe, pos.width, 1);
      return new Some(_pipe$1);
    } else if (node instanceof HR2) {
      let color = node.color;
      let _pipe = (((c(new Reset()) + c(new Fg(color))) + $string.repeat(
        "─",
        pos.width,
      )) + c(new Reset()));
      let _pipe$1 = new Element(_pipe, pos.width, 1);
      return new Some(_pipe$1);
    } else if (node instanceof Bar) {
      let color = node.color;
      let _pipe = toList([
        c(new SavePos()),
        c(new Reset()),
        c(new Bg(color)),
        $string.repeat(" ", pos.width),
        c(new Reset()),
        c(new LoadPos()),
      ]);
      let _pipe$1 = $string.join(_pipe, "");
      let _pipe$2 = new Element(_pipe$1, pos.width, 1);
      return new Some(_pipe$2);
    } else if (node instanceof Bar2) {
      let color = node.color;
      let node$1 = node.node;
      let _block;
      let _pipe = toList([
        c(new SavePos()),
        c(new Reset()),
        c(new Bg(color)),
        $string.repeat(" ", pos.width),
        c(new Reset()),
        c(new LoadPos()),
      ]);
      _block = $string.join(_pipe, "");
      let bar = _block;
      let _pipe$1 = render_node(state, node$1, last_input, pos);
      return $option.map(
        _pipe$1,
        (_capture) => { return element_prefix(_capture, bar); },
      );
    } else if (node instanceof BR) {
      let _pipe = "\n";
      let _pipe$1 = new Element(_pipe, pos.width, 1);
      return new Some(_pipe$1);
    } else if (node instanceof TextMulti) {
      let text = node.text;
      let wrap = node.wrap;
      let fg = node.fg;
      let bg = node.bg;
      let _pipe = draw_text_multi(text, wrap, fg, bg, pos);
      return new Some(_pipe);
    } else if (node instanceof Button) {
      let id = node.id;
      let text = node.text;
      let key = node.key;
      let fg = node.fg;
      let bg = node.bg;
      let focus_fg = node.focus_fg;
      let focus_bg = node.focus_bg;
      let _block;
      let $ = state.focused;
      if ($ instanceof Some) {
        let $1 = $[0];
        if ($1 instanceof FocusedButton) {
          let focused = $1;
          if (focused.label === id) {
            _block = true;
          } else {
            _block = false;
          }
        } else {
          _block = false;
        }
      } else {
        _block = false;
      }
      let is_focused = _block;
      let _pipe = draw_btn(
        new Btn(
          pos.width,
          1,
          text,
          (isEqual(last_input, key)) || is_focused,
          pos.align,
          fg,
          bg,
          focus_fg,
          focus_bg,
        ),
      );
      return new Some(_pipe);
    } else if (node instanceof KeyBind) {
      return new None();
    } else if (node instanceof Aligned) {
      let align = node.align;
      let node$1 = node.node;
      loop$state = state;
      loop$node = node$1;
      loop$last_input = last_input;
      loop$pos = new Pos(pos.x, pos.y, pos.width, pos.height, align);
    } else if (node instanceof Col) {
      let children = node.children;
      let _pipe = $list.map(
        children,
        (_capture) => { return render_node(state, _capture, last_input, pos); },
      );
      let _pipe$1 = $option.values(_pipe);
      let _pipe$2 = element_join(_pipe$1, sep(new SepCol()));
      let _pipe$3 = element_prefix(_pipe$2, c(new SavePos()));
      return new Some(_pipe$3);
    } else if (node instanceof Row) {
      let children = node.children;
      let _block;
      let _pipe = children;
      _block = $list.length(_pipe);
      let len = _block;
      let width = divideInt(pos.width, len);
      let _pipe$1 = $list.index_map(
        children,
        (child, idx) => {
          let x = idx * width;
          let new_pos = new Pos(
            x,
            pos.y,
            width,
            pos.height,
            right_is_left(pos.align),
          );
          let _pipe$1 = render_node(state, child, last_input, new_pos);
          return $option.map(
            _pipe$1,
            (r) => {
              let _block$1;
              let $ = pos.align;
              if ($ instanceof $style.Left) {
                _block$1 = "";
              } else if ($ instanceof $style.Center) {
                _block$1 = c(new MoveRight(x));
              } else {
                _block$1 = "";
              }
              let move = _block$1;
              return element_prefix(r, move);
            },
          );
        },
      );
      let _pipe$2 = $option.values(_pipe$1);
      let _pipe$3 = element_join(_pipe$2, sep(new SepRow()));
      let _pipe$4 = ((ele) => {
        let _block$1;
        let $ = pos.align;
        if ($ instanceof $style.Left) {
          _block$1 = "";
        } else if ($ instanceof $style.Center) {
          _block$1 = "";
        } else {
          _block$1 = c(new MoveRight((pos.width - ele.width) - (len - 1)));
        }
        let _pipe$4 = _block$1;
        return ((_capture) => { return element_prefix(ele, _capture); })(
          _pipe$4,
        );
      })(_pipe$3);
      return new Some(_pipe$4);
    } else if (node instanceof Box) {
      let children = node.children;
      let title = node.title;
      let fg = node.fg;
      let pos$1 = new Pos(
        pos.x,
        pos.y,
        pos.width - 3,
        pos.height - 2,
        pos.align,
      );
      let pos_child = new Pos(
        pos$1.x,
        pos$1.y,
        pos$1.width - 2,
        pos$1.height,
        pos$1.align,
      );
      let _pipe = listPrepend(
        draw_box($int.max(pos$1.width, 1), $int.max(pos$1.height, 1), title, fg),
        (() => {
          let _pipe = $list.map(
            children,
            (_capture) => {
              return render_node(state, _capture, last_input, pos_child);
            },
          );
          return $option.values(_pipe);
        })(),
      );
      let _pipe$1 = element_join(_pipe, sep(new SepCol()));
      return new Some(_pipe$1);
    } else if (node instanceof Table) {
      let width = node.width;
      let table = node.table;
      let width$1 = calc_size(width, pos.width);
      let _pipe = draw_table($int.min(width$1, pos.width), table, pos);
      return new Some(_pipe);
    } else if (node instanceof TableKV) {
      let width = node.width;
      let table = node.table;
      let width$1 = calc_size(width, pos.width);
      let _pipe = draw_table_kv($int.min(width$1, pos.width), table, pos);
      return new Some(_pipe);
    } else if (node instanceof Graph) {
      let width = node.width;
      let height = node.height;
      let points = node.points;
      let _pipe = draw_graph(
        calc_size(width, pos.width),
        calc_size(height, pos.height),
        points,
      );
      return new Some(_pipe);
    } else if (node instanceof Debug) {
      let content = $string.inspect(pos);
      let width = $string.length(content);
      let _pipe = new Element(content, width, 1);
      return new Some(_pipe);
    } else if (node instanceof Progress) {
      let width = node.width;
      let max = node.max;
      let value = node.value;
      let color = node.color;
      let width$1 = calc_size(width, pos.width);
      let _pipe = draw_progress(width$1, max, value, color, pos);
      return new Some(_pipe);
    } else if (node instanceof Layouts) {
      let l = node.layout;
      let _pipe = layout(l, pos);
      let _pipe$1 = $list.map(
        _pipe,
        (i) => {
          let cursor = c(new SetPos(i[1].y, i[1].x));
          let _pipe$1 = render_node(state, i[0], last_input, i[1]);
          return $option.map(
            _pipe$1,
            (r) => { return element_prefix(r, cursor); },
          );
        },
      );
      let _pipe$2 = $option.values(_pipe$1);
      let _pipe$3 = element_join(_pipe$2, "");
      return new Some(_pipe$3);
    } else {
      let payload = node.payload;
      let _pipe = draw_graphic(payload);
      return new Some(_pipe);
    }
  }
}

export function init_terminal() {
  return c(new HideCursor()) + c(new AltBuffer());
}

export function restore_terminal() {
  return c(new ShowCursor()) + c(new MainBuffer());
}

function do_detect_event(loop$state, loop$children, loop$input) {
  while (true) {
    let state = loop$state;
    let children = loop$children;
    let input = loop$input;
    if (children instanceof $Empty) {
      return new None();
    } else {
      let x = children.head;
      let xs = children.tail;
      let $ = detect_event(state, x, input);
      if ($ instanceof Some) {
        return $;
      } else {
        loop$state = state;
        loop$children = xs;
        loop$input = input;
      }
    }
  }
}

function detect_event(loop$state, loop$node, loop$input) {
  while (true) {
    let state = loop$state;
    let node = loop$node;
    let input = loop$input;
    if (node instanceof Input) {
      return new None();
    } else if (node instanceof HR) {
      return new None();
    } else if (node instanceof HR2) {
      return new None();
    } else if (node instanceof Bar) {
      return new None();
    } else if (node instanceof Bar2) {
      let node$1 = node.node;
      loop$state = state;
      loop$node = node$1;
      loop$input = input;
    } else if (node instanceof BR) {
      return new None();
    } else if (node instanceof TextMulti) {
      return new None();
    } else if (node instanceof Button) {
      let key = node.key;
      if (isEqual(input, key)) {
        let event = node.event;
        return new Some(event);
      } else {
        return new None();
      }
    } else if (node instanceof KeyBind) {
      let key = node.key;
      if (isEqual(input, key)) {
        let event = node.event;
        return new Some(event);
      } else {
        return new None();
      }
    } else if (node instanceof Aligned) {
      let node$1 = node.node;
      loop$state = state;
      loop$node = node$1;
      loop$input = input;
    } else if (node instanceof Col) {
      let children = node.children;
      return do_detect_event(state, children, input);
    } else if (node instanceof Row) {
      let children = node.children;
      return do_detect_event(state, children, input);
    } else if (node instanceof Box) {
      let children = node.children;
      return do_detect_event(state, children, input);
    } else if (node instanceof Table) {
      return new None();
    } else if (node instanceof TableKV) {
      return new None();
    } else if (node instanceof Graph) {
      return new None();
    } else if (node instanceof Debug) {
      return new None();
    } else if (node instanceof Progress) {
      return new None();
    } else if (node instanceof Layouts) {
      let layout$1 = node.layout;
      let _pipe = layout$1.cells;
      let _pipe$1 = $list.map(
        _pipe,
        (cell) => { return detect_event(state, cell.content, input); },
      );
      let _pipe$2 = $option.values(_pipe$1);
      let _pipe$3 = $list.first(_pipe$2);
      return $option.from_result(_pipe$3);
    } else {
      return new None();
    }
  }
}
