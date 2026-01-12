import * as $bool from "../gleam_stdlib/gleam/bool.mjs";
import * as $decode from "../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../gleam_stdlib/gleam/option.mjs";
import * as $attribute from "../lustre/lustre/attribute.mjs";
import { attribute, class$, id } from "../lustre/lustre/attribute.mjs";
import * as $element from "../lustre/lustre/element.mjs";
import * as $html from "../lustre/lustre/element/html.mjs";
import * as $event from "../lustre/lustre/event.mjs";
import {
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
} from "./gleam.mjs";

export class Config extends $CustomType {
  constructor(on_reorder, container_id, container_class, item_class, dragging_class, drag_over_class, ghost_class, accept_from) {
    super();
    this.on_reorder = on_reorder;
    this.container_id = container_id;
    this.container_class = container_class;
    this.item_class = item_class;
    this.dragging_class = dragging_class;
    this.drag_over_class = drag_over_class;
    this.ghost_class = ghost_class;
    this.accept_from = accept_from;
  }
}
export const Config$Config = (on_reorder, container_id, container_class, item_class, dragging_class, drag_over_class, ghost_class, accept_from) =>
  new Config(on_reorder,
  container_id,
  container_class,
  item_class,
  dragging_class,
  drag_over_class,
  ghost_class,
  accept_from);
export const Config$isConfig = (value) => value instanceof Config;
export const Config$Config$on_reorder = (value) => value.on_reorder;
export const Config$Config$0 = (value) => value.on_reorder;
export const Config$Config$container_id = (value) => value.container_id;
export const Config$Config$1 = (value) => value.container_id;
export const Config$Config$container_class = (value) => value.container_class;
export const Config$Config$2 = (value) => value.container_class;
export const Config$Config$item_class = (value) => value.item_class;
export const Config$Config$3 = (value) => value.item_class;
export const Config$Config$dragging_class = (value) => value.dragging_class;
export const Config$Config$4 = (value) => value.dragging_class;
export const Config$Config$drag_over_class = (value) => value.drag_over_class;
export const Config$Config$5 = (value) => value.drag_over_class;
export const Config$Config$ghost_class = (value) => value.ghost_class;
export const Config$Config$6 = (value) => value.ghost_class;
export const Config$Config$accept_from = (value) => value.accept_from;
export const Config$Config$7 = (value) => value.accept_from;

export class NoDrag extends $CustomType {}
export const DragState$NoDrag = () => new NoDrag();
export const DragState$isNoDrag = (value) => value instanceof NoDrag;

export class Dragging extends $CustomType {
  constructor(source_container, source_index, over_container, over_index) {
    super();
    this.source_container = source_container;
    this.source_index = source_index;
    this.over_container = over_container;
    this.over_index = over_index;
  }
}
export const DragState$Dragging = (source_container, source_index, over_container, over_index) =>
  new Dragging(source_container, source_index, over_container, over_index);
export const DragState$isDragging = (value) => value instanceof Dragging;
export const DragState$Dragging$source_container = (value) =>
  value.source_container;
export const DragState$Dragging$0 = (value) => value.source_container;
export const DragState$Dragging$source_index = (value) => value.source_index;
export const DragState$Dragging$1 = (value) => value.source_index;
export const DragState$Dragging$over_container = (value) =>
  value.over_container;
export const DragState$Dragging$2 = (value) => value.over_container;
export const DragState$Dragging$over_index = (value) => value.over_index;
export const DragState$Dragging$3 = (value) => value.over_index;

export class TouchDragging extends $CustomType {
  constructor(source_container, source_index, over_container, over_index) {
    super();
    this.source_container = source_container;
    this.source_index = source_index;
    this.over_container = over_container;
    this.over_index = over_index;
  }
}
export const DragState$TouchDragging = (source_container, source_index, over_container, over_index) =>
  new TouchDragging(source_container, source_index, over_container, over_index);
export const DragState$isTouchDragging = (value) =>
  value instanceof TouchDragging;
export const DragState$TouchDragging$source_container = (value) =>
  value.source_container;
export const DragState$TouchDragging$0 = (value) => value.source_container;
export const DragState$TouchDragging$source_index = (value) =>
  value.source_index;
export const DragState$TouchDragging$1 = (value) => value.source_index;
export const DragState$TouchDragging$over_container = (value) =>
  value.over_container;
export const DragState$TouchDragging$2 = (value) => value.over_container;
export const DragState$TouchDragging$over_index = (value) => value.over_index;
export const DragState$TouchDragging$3 = (value) => value.over_index;

/**
 * Reordering within the same container
 */
export class SameContainer extends $CustomType {
  constructor(from_index, to_index) {
    super();
    this.from_index = from_index;
    this.to_index = to_index;
  }
}
export const ReorderAction$SameContainer = (from_index, to_index) =>
  new SameContainer(from_index, to_index);
export const ReorderAction$isSameContainer = (value) =>
  value instanceof SameContainer;
export const ReorderAction$SameContainer$from_index = (value) =>
  value.from_index;
export const ReorderAction$SameContainer$0 = (value) => value.from_index;
export const ReorderAction$SameContainer$to_index = (value) => value.to_index;
export const ReorderAction$SameContainer$1 = (value) => value.to_index;

/**
 * Moving item from one container to another
 */
export class CrossContainer extends $CustomType {
  constructor(from_container, from_index, to_container, to_index) {
    super();
    this.from_container = from_container;
    this.from_index = from_index;
    this.to_container = to_container;
    this.to_index = to_index;
  }
}
export const ReorderAction$CrossContainer = (from_container, from_index, to_container, to_index) =>
  new CrossContainer(from_container, from_index, to_container, to_index);
export const ReorderAction$isCrossContainer = (value) =>
  value instanceof CrossContainer;
export const ReorderAction$CrossContainer$from_container = (value) =>
  value.from_container;
export const ReorderAction$CrossContainer$0 = (value) => value.from_container;
export const ReorderAction$CrossContainer$from_index = (value) =>
  value.from_index;
export const ReorderAction$CrossContainer$1 = (value) => value.from_index;
export const ReorderAction$CrossContainer$to_container = (value) =>
  value.to_container;
export const ReorderAction$CrossContainer$2 = (value) => value.to_container;
export const ReorderAction$CrossContainer$to_index = (value) => value.to_index;
export const ReorderAction$CrossContainer$3 = (value) => value.to_index;

class Item extends $CustomType {
  constructor(id, data) {
    super();
    this.id = id;
    this.data = data;
  }
}

export class StartDrag extends $CustomType {
  constructor(container_id, index) {
    super();
    this.container_id = container_id;
    this.index = index;
  }
}
export const Msg$StartDrag = (container_id, index) =>
  new StartDrag(container_id, index);
export const Msg$isStartDrag = (value) => value instanceof StartDrag;
export const Msg$StartDrag$container_id = (value) => value.container_id;
export const Msg$StartDrag$0 = (value) => value.container_id;
export const Msg$StartDrag$index = (value) => value.index;
export const Msg$StartDrag$1 = (value) => value.index;

export class DragOver extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$DragOver = ($0) => new DragOver($0);
export const Msg$isDragOver = (value) => value instanceof DragOver;
export const Msg$DragOver$0 = (value) => value[0];

export class DragEnter extends $CustomType {
  constructor(container_id, index) {
    super();
    this.container_id = container_id;
    this.index = index;
  }
}
export const Msg$DragEnter = (container_id, index) =>
  new DragEnter(container_id, index);
export const Msg$isDragEnter = (value) => value instanceof DragEnter;
export const Msg$DragEnter$container_id = (value) => value.container_id;
export const Msg$DragEnter$0 = (value) => value.container_id;
export const Msg$DragEnter$index = (value) => value.index;
export const Msg$DragEnter$1 = (value) => value.index;

export class DragLeave extends $CustomType {}
export const Msg$DragLeave = () => new DragLeave();
export const Msg$isDragLeave = (value) => value instanceof DragLeave;

export class Drop extends $CustomType {
  constructor(container_id, index) {
    super();
    this.container_id = container_id;
    this.index = index;
  }
}
export const Msg$Drop = (container_id, index) => new Drop(container_id, index);
export const Msg$isDrop = (value) => value instanceof Drop;
export const Msg$Drop$container_id = (value) => value.container_id;
export const Msg$Drop$0 = (value) => value.container_id;
export const Msg$Drop$index = (value) => value.index;
export const Msg$Drop$1 = (value) => value.index;

export class DragEnd extends $CustomType {}
export const Msg$DragEnd = () => new DragEnd();
export const Msg$isDragEnd = (value) => value instanceof DragEnd;

export class TouchStart extends $CustomType {
  constructor(container_id, index) {
    super();
    this.container_id = container_id;
    this.index = index;
  }
}
export const Msg$TouchStart = (container_id, index) =>
  new TouchStart(container_id, index);
export const Msg$isTouchStart = (value) => value instanceof TouchStart;
export const Msg$TouchStart$container_id = (value) => value.container_id;
export const Msg$TouchStart$0 = (value) => value.container_id;
export const Msg$TouchStart$index = (value) => value.index;
export const Msg$TouchStart$1 = (value) => value.index;

export class TouchMove extends $CustomType {}
export const Msg$TouchMove = () => new TouchMove();
export const Msg$isTouchMove = (value) => value instanceof TouchMove;

export class TouchEnd extends $CustomType {}
export const Msg$TouchEnd = () => new TouchEnd();
export const Msg$isTouchEnd = (value) => value instanceof TouchEnd;

export class TouchEnter extends $CustomType {
  constructor(container_id, index) {
    super();
    this.container_id = container_id;
    this.index = index;
  }
}
export const Msg$TouchEnter = (container_id, index) =>
  new TouchEnter(container_id, index);
export const Msg$isTouchEnter = (value) => value instanceof TouchEnter;
export const Msg$TouchEnter$container_id = (value) => value.container_id;
export const Msg$TouchEnter$0 = (value) => value.container_id;
export const Msg$TouchEnter$index = (value) => value.index;
export const Msg$TouchEnter$1 = (value) => value.index;

export class UserMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$UserMsg = ($0) => new UserMsg($0);
export const Msg$isUserMsg = (value) => value instanceof UserMsg;
export const Msg$UserMsg$0 = (value) => value[0];

/**
 * Creates a default sortable configuration with standard CSS classes.
 * 
 * ## Arguments
 * 
 * - `on_reorder`: Function called when items are reordered, receives (from_index, to_index)
 * - `container_id`: HTML id for the sortable container element
 * 
 * ## Returns
 * 
 * A `Config` with default CSS classes:
 * - Container: "sortable-container"
 * - Item: "sortable-item"  
 * - Dragging: "sortable-dragging"
 * - Drag over: "sortable-drag-over"
 * - Ghost: "sortable-ghost"
 * 
 * ## Example
 * 
 * ```gleam
 * let config = ensaimada.default_config(
 *   fn(from, to) { ReorderImages(from, to) },
 *   "image-grid"
 * )
 * ```
 */
export function default_config(on_reorder, container_id) {
  return new Config(
    on_reorder,
    container_id,
    "sortable-container",
    "sortable-item",
    "sortable-dragging",
    "sortable-drag-over",
    "sortable-ghost",
    toList([]),
  );
}

/**
 * Reorders a list by moving an item from one index to another.
 * 
 * ## Arguments
 * 
 * - `items`: The list to reorder
 * - `from_index`: The current index of the item to move
 * - `to_index`: The new index where the item should be placed
 * 
 * ## Returns
 * 
 * A new list with the item moved to the new position. If indices are invalid
 * or the same, returns the original list unchanged.
 * 
 * ## Example
 * 
 * ```gleam
 * let items = [1, 2, 3, 4, 5]
 * let reordered = ensaimada.reorder(items, 1, 3)
 * // Result: [1, 3, 4, 2, 5] (moved item at index 1 to index 3)
 * ```
 */
export function reorder(items, from_index, to_index) {
  let item_count = $list.length(items);
  return $bool.guard(
    ((((from_index === to_index) || (from_index < 0)) || (to_index < 0)) || (from_index >= item_count)) || (to_index >= item_count),
    items,
    () => {
      let $ = $list.split(items, from_index);
      let before_from = $[0];
      let after_from = $[1];
      if (after_from instanceof $Empty) {
        return items;
      } else {
        let moving_item = after_from.head;
        let rest_after_from = after_from.tail;
        let without_moving_item = $list.append(before_from, rest_after_from);
        let $1 = $list.split(without_moving_item, to_index);
        let before_to = $1[0];
        let after_to = $1[1];
        return $list.append(before_to, listPrepend(moving_item, after_to));
      }
    },
  );
}

/**
 * Creates a new sortable item with the given id and data.
 * 
 * ```gleam
 * let item = ensaimada.item("image-1", my_image_data)
 * ```
 */
export function item(id, data) {
  return new Item(id, data);
}

/**
 * Extracts the data from a sortable item.
 * 
 * ## Arguments
 * 
 * - `item`: The sortable item to extract data from
 * 
 * ## Returns
 * 
 * The original data that was stored in the item.
 * 
 * ## Example
 * 
 * ```gleam
 * let data = ensaimada.item_data(item)
 * ```
 */
export function item_data(item) {
  return item.data;
}

/**
 * Gets the unique identifier of a sortable item.
 * 
 * ## Arguments
 * 
 * - `item`: The sortable item to get the id from
 * 
 * ## Returns
 * 
 * The string id that was assigned to the item.
 * 
 * ## Example
 * 
 * ```gleam
 * let id = ensaimada.item_id(item)
 * ```
 */
export function item_id(item) {
  return item.id;
}

function drag_start_decoder(container_id, index) {
  return $decode.success(new StartDrag(container_id, index));
}

function drag_over_decoder() {
  return $decode.success(new DragOver(-1));
}

function drag_enter_decoder(container_id, index) {
  return $decode.success(new DragEnter(container_id, index));
}

function drag_leave_decoder() {
  return $decode.success(new DragLeave());
}

function drop_decoder(container_id, index) {
  return $decode.success(new Drop(container_id, index));
}

function drag_end_decoder() {
  return $decode.success(new DragEnd());
}

function touch_start_decoder(container_id, index) {
  return $decode.success(new TouchStart(container_id, index));
}

function touch_move_decoder() {
  return $decode.success(new TouchMove());
}

function touch_end_decoder() {
  return $decode.success(new TouchEnd());
}

function touch_enter_decoder(container_id, index) {
  return $decode.success(new TouchEnter(container_id, index));
}

function render_sortable_item(config, drag_state, item, index, render_item) {
  let _block;
  if (drag_state instanceof NoDrag) {
    _block = false;
  } else if (drag_state instanceof Dragging) {
    let source_container = drag_state.source_container;
    let source_index = drag_state.source_index;
    _block = (source_container === config.container_id) && (source_index === index);
  } else {
    let source_container = drag_state.source_container;
    let source_index = drag_state.source_index;
    _block = (source_container === config.container_id) && (source_index === index);
  }
  let is_dragging = _block;
  let _block$1;
  if (drag_state instanceof Dragging) {
    let $ = drag_state.over_container;
    if ($ instanceof Some) {
      let $1 = drag_state.over_index;
      if ($1 instanceof Some) {
        let source_container = drag_state.source_container;
        let source_index = drag_state.source_index;
        let over_container = $[0];
        let over_index = $1[0];
        _block$1 = ((over_container === config.container_id) && (over_index === index)) && ((source_container !== config.container_id) || (source_index !== index));
      } else {
        _block$1 = false;
      }
    } else {
      _block$1 = false;
    }
  } else if (drag_state instanceof TouchDragging) {
    let $ = drag_state.over_container;
    if ($ instanceof Some) {
      let $1 = drag_state.over_index;
      if ($1 instanceof Some) {
        let source_container = drag_state.source_container;
        let source_index = drag_state.source_index;
        let over_container = $[0];
        let over_index = $1[0];
        _block$1 = ((over_container === config.container_id) && (over_index === index)) && ((source_container !== config.container_id) || (source_index !== index));
      } else {
        _block$1 = false;
      }
    } else {
      _block$1 = false;
    }
  } else {
    _block$1 = false;
  }
  let is_drag_over = _block$1;
  let item_classes = (config.item_class + $bool.lazy_guard(
    is_dragging,
    () => { return " " + config.dragging_class; },
    () => { return ""; },
  )) + $bool.lazy_guard(
    is_drag_over,
    () => { return " " + config.drag_over_class; },
    () => { return ""; },
  );
  return $html.div(
    toList([
      class$(item_classes),
      attribute("draggable", "true"),
      attribute("data-index", $int.to_string(index)),
      attribute("data-item-id", item.id),
      $attribute.style(
        "cursor",
        (() => {
          if (is_dragging) {
            return "grabbing";
          } else {
            return "grab";
          }
        })(),
      ),
      $attribute.style("touch-action", "manipulation"),
      $attribute.style("-webkit-user-select", "none"),
      $attribute.style("user-select", "none"),
      $attribute.style(
        "opacity",
        (() => {
          if (is_dragging) {
            return "0.5";
          } else {
            return "1";
          }
        })(),
      ),
      $attribute.style(
        "transform",
        (() => {
          if (is_dragging) {
            return "scale(1.05) rotate(3deg)";
          } else {
            return "scale(1)";
          }
        })(),
      ),
      $attribute.style("transition", "all 0.2s ease"),
      $attribute.style(
        "z-index",
        (() => {
          if (is_dragging) {
            return "1000";
          } else {
            return "1";
          }
        })(),
      ),
      $event.on("dragstart", drag_start_decoder(config.container_id, index)),
      (() => {
        let _pipe = $event.on("dragover", drag_over_decoder());
        return $event.prevent_default(_pipe);
      })(),
      (() => {
        let _pipe = $event.on(
          "dragenter",
          drag_enter_decoder(config.container_id, index),
        );
        return $event.prevent_default(_pipe);
      })(),
      (() => {
        let _pipe = $event.on("dragleave", drag_leave_decoder());
        return $event.prevent_default(_pipe);
      })(),
      (() => {
        let _pipe = $event.on("drop", drop_decoder(config.container_id, index));
        return $event.prevent_default(_pipe);
      })(),
      (() => {
        let _pipe = $event.on("dragend", drag_end_decoder());
        return $event.prevent_default(_pipe);
      })(),
      $event.on("touchstart", touch_start_decoder(config.container_id, index)),
      (() => {
        let _pipe = $event.on("touchmove", touch_move_decoder());
        return $event.prevent_default(_pipe);
      })(),
      $event.on("touchend", touch_end_decoder()),
      $event.on("touchenter", touch_enter_decoder(config.container_id, index)),
    ]),
    toList([
      $element.map(
        render_item(item, index, drag_state),
        (var0) => { return new UserMsg(var0); },
      ),
    ]),
  );
}

/**
 * Creates a sortable container element that handles drag and drop interactions.
 * 
 * ## Arguments
 * 
 * - `config`: Configuration for the sortable container
 * - `drag_state`: Current drag state (should be managed in your application state)
 * - `items`: List of sortable items to render
 * - `render_item`: Function to render individual items, receives (item, index, drag_state)
 * 
 * ## Returns
 * 
 * A Lustre `Element` that handles drag and drop events and renders the sortable items.
 * The element emits `Config` events that should be handled in your update function.
 * 
 * ## Example
 * 
 * ```gleam
 * ensaimada.container(
 *   config,
 *   model.drag_state,
 *   model.items |> list.index_map(fn(item, i) {
 *     ensaimada.item("item-" <> int.to_string(i), item)
 *   }),
 *   fn(item, index, drag_state) { render_my_item(item, index, drag_state) }
 * )
 * ```
 */
export function container(config, drag_state, items, render_item) {
  let _block;
  if (drag_state instanceof NoDrag) {
    _block = config.container_class;
  } else if (drag_state instanceof Dragging) {
    _block = config.container_class + " sortable-active";
  } else {
    _block = config.container_class + " sortable-active";
  }
  let container_classes = _block;
  return $html.div(
    toList([
      id(config.container_id),
      class$(container_classes),
      $attribute.style("user-select", "none"),
      $attribute.style("-webkit-user-select", "none"),
      $attribute.style("-moz-user-select", "none"),
      $attribute.style("-ms-user-select", "none"),
    ]),
    $list.index_map(
      items,
      (item, index) => {
        return render_sortable_item(
          config,
          drag_state,
          item,
          index,
          render_item,
        );
      },
    ),
  );
}

/**
 * Updates the drag state based on sortable messages and returns reorder information.
 *
 * This function should be called from your application's update function when
 * handling `SortableMsg` events. It manages the drag state and returns information
 * about when items should be reordered or moved between containers.
 *
 * ## Arguments
 *
 * - `sortable_msg`: The sortable message to process
 * - `drag_state`: The current drag state
 * - `config`: The sortable configuration (needed to check accept_from)
 *
 * ## Returns
 *
 * A tuple containing:
 * 1. The new `DragState` after processing the message
 * 2. `Option(ReorderAction)` - Information about reorder/transfer action, `None` otherwise
 *
 * ## Example
 *
 * ```gleam
 * // In your update function
 * MyMsg(sortable_msg) -> {
 *   let #(new_drag_state, maybe_action) =
 *     ensaimada.update(sortable_msg, model.drag_state, config)
 *
 *   case maybe_action {
 *     Some(ensaimada.SameContainer(from, to)) -> {
 *       let new_items = ensaimada.reorder(model.items, from, to)
 *       #(Model(..model, items: new_items, drag_state: new_drag_state), effect.none())
 *     }
 *     Some(ensaimada.CrossContainer(from_cont, from_idx, to_cont, to_idx)) -> {
 *       // Handle cross-container transfer
 *       ...
 *     }
 *     None -> {
 *       #(Model(..model, drag_state: new_drag_state), effect.none())
 *     }
 *   }
 * }
 * ```
 */
export function update(sortable_msg, drag_state, config) {
  if (sortable_msg instanceof StartDrag) {
    let container_id = sortable_msg.container_id;
    let index = sortable_msg.index;
    return [
      new Dragging(container_id, index, new None(), new None()),
      new None(),
    ];
  } else if (sortable_msg instanceof DragOver) {
    return [drag_state, new None()];
  } else if (sortable_msg instanceof DragEnter) {
    let container_id = sortable_msg.container_id;
    let index = sortable_msg.index;
    if (drag_state instanceof NoDrag) {
      return [drag_state, new None()];
    } else if (drag_state instanceof Dragging) {
      let source_container = drag_state.source_container;
      let source_index = drag_state.source_index;
      let accepts = (source_container === container_id) || $list.contains(
        config.accept_from,
        source_container,
      );
      if (accepts) {
        return [
          new Dragging(
            source_container,
            source_index,
            new Some(container_id),
            new Some(index),
          ),
          new None(),
        ];
      } else {
        return [drag_state, new None()];
      }
    } else {
      let source_container = drag_state.source_container;
      let source_index = drag_state.source_index;
      let accepts = (source_container === container_id) || $list.contains(
        config.accept_from,
        source_container,
      );
      if (accepts) {
        return [
          new TouchDragging(
            source_container,
            source_index,
            new Some(container_id),
            new Some(index),
          ),
          new None(),
        ];
      } else {
        return [drag_state, new None()];
      }
    }
  } else if (sortable_msg instanceof DragLeave) {
    return [drag_state, new None()];
  } else if (sortable_msg instanceof Drop) {
    let container_id = sortable_msg.container_id;
    let target_index = sortable_msg.index;
    if (drag_state instanceof NoDrag) {
      return [drag_state, new None()];
    } else if (drag_state instanceof Dragging) {
      let source_container = drag_state.source_container;
      let source_index = drag_state.source_index;
      let $ = source_container === container_id;
      if ($) {
        return [
          new NoDrag(),
          new Some(new SameContainer(source_index, target_index)),
        ];
      } else {
        let accepts = $list.contains(config.accept_from, source_container);
        if (accepts) {
          return [
            new NoDrag(),
            new Some(
              new CrossContainer(
                source_container,
                source_index,
                container_id,
                target_index,
              ),
            ),
          ];
        } else {
          return [new NoDrag(), new None()];
        }
      }
    } else {
      let source_container = drag_state.source_container;
      let source_index = drag_state.source_index;
      let $ = source_container === container_id;
      if ($) {
        return [
          new NoDrag(),
          new Some(new SameContainer(source_index, target_index)),
        ];
      } else {
        let accepts = $list.contains(config.accept_from, source_container);
        if (accepts) {
          return [
            new NoDrag(),
            new Some(
              new CrossContainer(
                source_container,
                source_index,
                container_id,
                target_index,
              ),
            ),
          ];
        } else {
          return [new NoDrag(), new None()];
        }
      }
    }
  } else if (sortable_msg instanceof DragEnd) {
    if (drag_state instanceof Dragging) {
      let $ = drag_state.over_container;
      if ($ instanceof Some) {
        let $1 = drag_state.over_index;
        if ($1 instanceof Some) {
          let source_container = drag_state.source_container;
          let source_index = drag_state.source_index;
          let target_container = $[0];
          let target_index = $1[0];
          let $2 = source_container === target_container;
          if ($2) {
            return [
              new NoDrag(),
              new Some(new SameContainer(source_index, target_index)),
            ];
          } else {
            let accepts = $list.contains(config.accept_from, source_container);
            if (accepts) {
              return [
                new NoDrag(),
                new Some(
                  new CrossContainer(
                    source_container,
                    source_index,
                    target_container,
                    target_index,
                  ),
                ),
              ];
            } else {
              return [new NoDrag(), new None()];
            }
          }
        } else {
          return [new NoDrag(), new None()];
        }
      } else {
        return [new NoDrag(), new None()];
      }
    } else {
      return [new NoDrag(), new None()];
    }
  } else if (sortable_msg instanceof TouchStart) {
    let container_id = sortable_msg.container_id;
    let index = sortable_msg.index;
    return [
      new TouchDragging(container_id, index, new None(), new None()),
      new None(),
    ];
  } else if (sortable_msg instanceof TouchMove) {
    if (drag_state instanceof TouchDragging) {
      let source_container = drag_state.source_container;
      let source_index = drag_state.source_index;
      let over_container = drag_state.over_container;
      return [
        new TouchDragging(
          source_container,
          source_index,
          over_container,
          new None(),
        ),
        new None(),
      ];
    } else {
      return [drag_state, new None()];
    }
  } else if (sortable_msg instanceof TouchEnd) {
    if (drag_state instanceof TouchDragging) {
      let $ = drag_state.over_container;
      if ($ instanceof Some) {
        let $1 = drag_state.over_index;
        if ($1 instanceof Some) {
          let source_container = drag_state.source_container;
          let source_index = drag_state.source_index;
          let target_container = $[0];
          let target_index = $1[0];
          let $2 = source_container === target_container;
          if ($2) {
            return [
              new NoDrag(),
              new Some(new SameContainer(source_index, target_index)),
            ];
          } else {
            let accepts = $list.contains(config.accept_from, source_container);
            if (accepts) {
              return [
                new NoDrag(),
                new Some(
                  new CrossContainer(
                    source_container,
                    source_index,
                    target_container,
                    target_index,
                  ),
                ),
              ];
            } else {
              return [new NoDrag(), new None()];
            }
          }
        } else {
          return [new NoDrag(), new None()];
        }
      } else {
        return [new NoDrag(), new None()];
      }
    } else {
      return [new NoDrag(), new None()];
    }
  } else if (sortable_msg instanceof TouchEnter) {
    let container_id = sortable_msg.container_id;
    let index = sortable_msg.index;
    if (drag_state instanceof TouchDragging) {
      let source_container = drag_state.source_container;
      let source_index = drag_state.source_index;
      let accepts = (source_container === container_id) || $list.contains(
        config.accept_from,
        source_container,
      );
      if (accepts) {
        return [
          new TouchDragging(
            source_container,
            source_index,
            new Some(container_id),
            new Some(index),
          ),
          new None(),
        ];
      } else {
        return [drag_state, new None()];
      }
    } else {
      return [drag_state, new None()];
    }
  } else {
    return [drag_state, new None()];
  }
}
