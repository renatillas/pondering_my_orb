/// A sortable library for Gleam/Lustre that provides drag and drop functionality
/// for reordering items in a list. Supports both mouse/desktop and touch/mobile interactions.
///
/// ## Features
/// 
/// - **Desktop Support**: Full HTML5 drag and drop API support
/// - **Mobile Support**: Touch events for drag and drop on mobile devices
/// - **Customizable**: Configurable CSS classes for styling
/// - **Framework Agnostic**: No built-in CSS framework dependencies
/// - **Type Safe**: Fully typed with Gleam's type system
///
/// ## Basic Usage
///
/// ```gleam
/// import ensaimada
/// 
/// let config = ensaimada.default_config(
///   fn(from, to) { MyReorderMsg(from, to) },
///   "my-sortable-container"
/// )
/// 
/// ensaimada.container(
///   config,
///   drag_state,
///   items,
///   render_item_fn
/// )
/// ```
import gleam/bool
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute.{attribute, class, id}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

/// Configuration for a sortable container.
///
/// - `on_reorder`: Callback function called when items are reordered with (from_index, to_index)
/// - `container_id`: HTML id attribute for the container element
/// - `container_class`: CSS classes to apply to the container (e.g., grid layout classes)
/// - `item_class`: CSS class for individual sortable items
/// - `dragging_class`: CSS class applied to the item being dragged
/// - `drag_over_class`: CSS class applied to the item being dragged over
/// - `ghost_class`: CSS class for the drag ghost/placeholder
/// - `accept_from`: List of container IDs that can drop items into this container (empty list = only same container)
pub type Config(msg) {
  Config(
    on_reorder: fn(Int, Int) -> msg,
    container_id: String,
    container_class: String,
    item_class: String,
    dragging_class: String,
    drag_over_class: String,
    ghost_class: String,
    accept_from: List(String),
  )
}

/// Represents the current drag state of the sortable container.
///
/// - `NoDrag`: No drag operation in progress
/// - `Dragging`: Desktop drag in progress with source container, index, and optional target
/// - `TouchDragging`: Mobile touch drag in progress with source container, index, and optional target
pub type DragState {
  NoDrag
  Dragging(
    source_container: String,
    source_index: Int,
    over_container: Option(String),
    over_index: Option(Int),
  )
  TouchDragging(
    source_container: String,
    source_index: Int,
    over_container: Option(String),
    over_index: Option(Int),
  )
}

/// Represents different types of reorder actions
pub type ReorderAction {
  /// Reordering within the same container
  SameContainer(from_index: Int, to_index: Int)
  /// Moving item from one container to another
  CrossContainer(
    from_container: String,
    from_index: Int,
    to_container: String,
    to_index: Int,
  )
}

/// A wrapper for items in a sortable list. The type is opaque to ensure
/// proper encapsulation of the item data and metadata.
/// 
/// Use `ensaimada.item()` to create instances and accessor functions
/// to retrieve data.
pub opaque type Item(a) {
  Item(id: String, data: a)
}

/// Creates a default sortable configuration with standard CSS classes.
/// 
/// ## Arguments
/// 
/// - `on_reorder`: Function called when items are reordered, receives (from_index, to_index)
/// - `container_id`: HTML id for the sortable container element
/// 
/// ## Returns
/// 
/// A `Config` with default CSS classes:
/// - Container: "sortable-container"
/// - Item: "sortable-item"  
/// - Dragging: "sortable-dragging"
/// - Drag over: "sortable-drag-over"
/// - Ghost: "sortable-ghost"
/// 
/// ## Example
/// 
/// ```gleam
/// let config = ensaimada.default_config(
///   fn(from, to) { ReorderImages(from, to) },
///   "image-grid"
/// )
/// ```
pub fn default_config(
  on_reorder: fn(Int, Int) -> msg,
  container_id: String,
) -> Config(msg) {
  Config(
    on_reorder: on_reorder,
    container_id: container_id,
    container_class: "sortable-container",
    item_class: "sortable-item",
    dragging_class: "sortable-dragging",
    drag_over_class: "sortable-drag-over",
    ghost_class: "sortable-ghost",
    accept_from: [],
  )
}

/// Creates a sortable container element that handles drag and drop interactions.
/// 
/// ## Arguments
/// 
/// - `config`: Configuration for the sortable container
/// - `drag_state`: Current drag state (should be managed in your application state)
/// - `items`: List of sortable items to render
/// - `render_item`: Function to render individual items, receives (item, index, drag_state)
/// 
/// ## Returns
/// 
/// A Lustre `Element` that handles drag and drop events and renders the sortable items.
/// The element emits `Config` events that should be handled in your update function.
/// 
/// ## Example
/// 
/// ```gleam
/// ensaimada.container(
///   config,
///   model.drag_state,
///   model.items |> list.index_map(fn(item, i) {
///     ensaimada.item("item-" <> int.to_string(i), item)
///   }),
///   fn(item, index, drag_state) { render_my_item(item, index, drag_state) }
/// )
/// ```
pub fn container(
  config: Config(msg),
  drag_state: DragState,
  items: List(Item(a)),
  render_item: fn(Item(a), Int, DragState) -> Element(msg),
) -> Element(Msg(msg)) {
  let container_classes = case drag_state {
    NoDrag -> config.container_class
    Dragging(_, _, _, _) -> config.container_class <> " sortable-active"
    TouchDragging(_, _, _, _) -> config.container_class <> " sortable-active"
  }

  html.div(
    [
      id(config.container_id),
      class(container_classes),
      attribute.style("user-select", "none"),
      attribute.style("-webkit-user-select", "none"),
      attribute.style("-moz-user-select", "none"),
      attribute.style("-ms-user-select", "none"),
    ],
    list.index_map(items, fn(item, index) {
      render_sortable_item(config, drag_state, item, index, render_item)
    }),
  )
}

fn render_sortable_item(
  config: Config(msg),
  drag_state: DragState,
  item: Item(a),
  index: Int,
  render_item: fn(Item(a), Int, DragState) -> Element(msg),
) -> Element(Msg(msg)) {
  let is_dragging = case drag_state {
    Dragging(source_container, source_index, _, _) ->
      source_container == config.container_id && source_index == index
    TouchDragging(source_container, source_index, _, _) ->
      source_container == config.container_id && source_index == index
    NoDrag -> False
  }

  let is_drag_over = case drag_state {
    Dragging(
      source_container,
      source_index,
      Some(over_container),
      Some(over_index),
    ) ->
      over_container == config.container_id
      && over_index == index
      && { source_container != config.container_id || source_index != index }
    TouchDragging(
      source_container,
      source_index,
      Some(over_container),
      Some(over_index),
    ) ->
      over_container == config.container_id
      && over_index == index
      && { source_container != config.container_id || source_index != index }
    _ -> False
  }

  let item_classes =
    config.item_class
    <> bool.lazy_guard(is_dragging, fn() { " " <> config.dragging_class }, fn() {
      ""
    })
    <> bool.lazy_guard(
      is_drag_over,
      fn() { " " <> config.drag_over_class },
      fn() { "" },
    )

  html.div(
    [
      class(item_classes),
      attribute("draggable", "true"),
      attribute("data-index", int.to_string(index)),
      attribute("data-item-id", item.id),
      attribute.style("cursor", case is_dragging {
        True -> "grabbing"
        False -> "grab"
      }),
      attribute.style("touch-action", "manipulation"),
      attribute.style("-webkit-user-select", "none"),
      attribute.style("user-select", "none"),
      attribute.style("opacity", case is_dragging {
        True -> "0.5"
        False -> "1"
      }),
      attribute.style("transform", case is_dragging {
        True -> "scale(1.05) rotate(3deg)"
        False -> "scale(1)"
      }),
      attribute.style("transition", "all 0.2s ease"),
      attribute.style("z-index", case is_dragging {
        True -> "1000"
        False -> "1"
      }),
      // HTML5 Drag and Drop events
      event.on("dragstart", drag_start_decoder(config.container_id, index)),
      event.on("dragover", drag_over_decoder()) |> event.prevent_default,
      event.on("dragenter", drag_enter_decoder(config.container_id, index))
        |> event.prevent_default,
      event.on("dragleave", drag_leave_decoder()) |> event.prevent_default,
      event.on("drop", drop_decoder(config.container_id, index))
        |> event.prevent_default,
      event.on("dragend", drag_end_decoder()) |> event.prevent_default,
      // Touch events for mobile support
      event.on("touchstart", touch_start_decoder(config.container_id, index)),
      event.on("touchmove", touch_move_decoder()) |> event.prevent_default,
      event.on("touchend", touch_end_decoder()),
      event.on("touchenter", touch_enter_decoder(config.container_id, index)),
    ],
    [element.map(render_item(item, index, drag_state), UserMsg)],
  )
}

/// Messages emitted by the sortable container during drag and drop interactions.
/// These should be handled in your application's update function.
pub type Msg(msg) {
  StartDrag(container_id: String, index: Int)
  DragOver(Int)
  DragEnter(container_id: String, index: Int)
  DragLeave
  Drop(container_id: String, index: Int)
  DragEnd
  TouchStart(container_id: String, index: Int)
  TouchMove
  TouchEnd
  TouchEnter(container_id: String, index: Int)
  UserMsg(msg)
}

/// Reorders a list by moving an item from one index to another.
/// 
/// ## Arguments
/// 
/// - `items`: The list to reorder
/// - `from_index`: The current index of the item to move
/// - `to_index`: The new index where the item should be placed
/// 
/// ## Returns
/// 
/// A new list with the item moved to the new position. If indices are invalid
/// or the same, returns the original list unchanged.
/// 
/// ## Example
/// 
/// ```gleam
/// let items = [1, 2, 3, 4, 5]
/// let reordered = ensaimada.reorder(items, 1, 3)
/// // Result: [1, 3, 4, 2, 5] (moved item at index 1 to index 3)
/// ```
pub fn reorder(items: List(a), from_index: Int, to_index: Int) -> List(a) {
  let item_count = list.length(items)
  use <- bool.guard(
    from_index == to_index
      || from_index < 0
      || to_index < 0
      || from_index >= item_count
      || to_index >= item_count,
    items,
  )
  case list.split(items, from_index) {
    #(before_from, after_from) -> {
      case after_from {
        [moving_item, ..rest_after_from] -> {
          let without_moving_item = list.append(before_from, rest_after_from)
          case list.split(without_moving_item, to_index) {
            #(before_to, after_to) ->
              list.append(before_to, [moving_item, ..after_to])
          }
        }
        [] -> items
      }
    }
  }
}

/// Creates a new sortable item with the given id and data.
/// 
/// ```gleam
/// let item = ensaimada.item("image-1", my_image_data)
/// ```
pub fn item(id: String, data: a) -> Item(a) {
  Item(id: id, data: data)
}

/// Extracts the data from a sortable item.
/// 
/// ## Arguments
/// 
/// - `item`: The sortable item to extract data from
/// 
/// ## Returns
/// 
/// The original data that was stored in the item.
/// 
/// ## Example
/// 
/// ```gleam
/// let data = ensaimada.item_data(item)
/// ```
pub fn item_data(item: Item(a)) -> a {
  item.data
}

/// Gets the unique identifier of a sortable item.
/// 
/// ## Arguments
/// 
/// - `item`: The sortable item to get the id from
/// 
/// ## Returns
/// 
/// The string id that was assigned to the item.
/// 
/// ## Example
/// 
/// ```gleam
/// let id = ensaimada.item_id(item)
/// ```
pub fn item_id(item: Item(a)) -> String {
  item.id
}

// Event decoders for HTML5 drag and drop
fn drag_start_decoder(
  container_id: String,
  index: Int,
) -> decode.Decoder(Msg(msg)) {
  decode.success(StartDrag(container_id, index))
}

fn drag_over_decoder() -> decode.Decoder(Msg(msg)) {
  decode.success(DragOver(-1))
}

fn drag_enter_decoder(
  container_id: String,
  index: Int,
) -> decode.Decoder(Msg(msg)) {
  decode.success(DragEnter(container_id, index))
}

fn drag_leave_decoder() -> decode.Decoder(Msg(msg)) {
  decode.success(DragLeave)
}

fn drop_decoder(container_id: String, index: Int) -> decode.Decoder(Msg(msg)) {
  decode.success(Drop(container_id, index))
}

fn drag_end_decoder() -> decode.Decoder(Msg(msg)) {
  decode.success(DragEnd)
}

// Touch event decoders for mobile support
fn touch_start_decoder(
  container_id: String,
  index: Int,
) -> decode.Decoder(Msg(msg)) {
  decode.success(TouchStart(container_id, index))
}

fn touch_move_decoder() -> decode.Decoder(Msg(msg)) {
  decode.success(TouchMove)
}

fn touch_end_decoder() -> decode.Decoder(Msg(msg)) {
  decode.success(TouchEnd)
}

fn touch_enter_decoder(
  container_id: String,
  index: Int,
) -> decode.Decoder(Msg(msg)) {
  decode.success(TouchEnter(container_id, index))
}

/// Updates the drag state based on sortable messages and returns reorder information.
///
/// This function should be called from your application's update function when
/// handling `SortableMsg` events. It manages the drag state and returns information
/// about when items should be reordered or moved between containers.
///
/// ## Arguments
///
/// - `sortable_msg`: The sortable message to process
/// - `drag_state`: The current drag state
/// - `config`: The sortable configuration (needed to check accept_from)
///
/// ## Returns
///
/// A tuple containing:
/// 1. The new `DragState` after processing the message
/// 2. `Option(ReorderAction)` - Information about reorder/transfer action, `None` otherwise
///
/// ## Example
///
/// ```gleam
/// // In your update function
/// MyMsg(sortable_msg) -> {
///   let #(new_drag_state, maybe_action) =
///     ensaimada.update(sortable_msg, model.drag_state, config)
///
///   case maybe_action {
///     Some(ensaimada.SameContainer(from, to)) -> {
///       let new_items = ensaimada.reorder(model.items, from, to)
///       #(Model(..model, items: new_items, drag_state: new_drag_state), effect.none())
///     }
///     Some(ensaimada.CrossContainer(from_cont, from_idx, to_cont, to_idx)) -> {
///       // Handle cross-container transfer
///       ...
///     }
///     None -> {
///       #(Model(..model, drag_state: new_drag_state), effect.none())
///     }
///   }
/// }
/// ```
pub fn update(
  sortable_msg: Msg(msg),
  drag_state: DragState,
  config: Config(msg),
) -> #(DragState, Option(ReorderAction)) {
  case sortable_msg {
    StartDrag(container_id, index) -> {
      #(Dragging(container_id, index, None, None), None)
    }
    DragEnter(container_id, index) ->
      case drag_state {
        Dragging(source_container, source_index, _, _) -> {
          // Check if this container accepts drops from source container
          let accepts =
            source_container == container_id
            || list.contains(config.accept_from, source_container)

          case accepts {
            True -> #(
              Dragging(
                source_container,
                source_index,
                Some(container_id),
                Some(index),
              ),
              None,
            )
            False -> #(drag_state, None)
          }
        }
        TouchDragging(source_container, source_index, _, _) -> {
          let accepts =
            source_container == container_id
            || list.contains(config.accept_from, source_container)

          case accepts {
            True -> #(
              TouchDragging(
                source_container,
                source_index,
                Some(container_id),
                Some(index),
              ),
              None,
            )
            False -> #(drag_state, None)
          }
        }
        NoDrag -> #(drag_state, None)
      }
    DragLeave -> #(drag_state, None)
    Drop(container_id, target_index) ->
      case drag_state {
        Dragging(source_container, source_index, _, _) -> {
          case source_container == container_id {
            True -> #(NoDrag, Some(SameContainer(source_index, target_index)))
            False -> {
              // Check if drop is allowed
              let accepts = list.contains(config.accept_from, source_container)
              case accepts {
                True -> #(
                  NoDrag,
                  Some(CrossContainer(
                    source_container,
                    source_index,
                    container_id,
                    target_index,
                  )),
                )
                False -> #(NoDrag, None)
              }
            }
          }
        }
        TouchDragging(source_container, source_index, _, _) -> {
          case source_container == container_id {
            True -> #(NoDrag, Some(SameContainer(source_index, target_index)))
            False -> {
              let accepts = list.contains(config.accept_from, source_container)
              case accepts {
                True -> #(
                  NoDrag,
                  Some(CrossContainer(
                    source_container,
                    source_index,
                    container_id,
                    target_index,
                  )),
                )
                False -> #(NoDrag, None)
              }
            }
          }
        }
        NoDrag -> #(drag_state, None)
      }
    DragEnd ->
      case drag_state {
        Dragging(
          source_container,
          source_index,
          Some(target_container),
          Some(target_index),
        ) -> {
          case source_container == target_container {
            True -> #(NoDrag, Some(SameContainer(source_index, target_index)))
            False -> {
              let accepts = list.contains(config.accept_from, source_container)
              case accepts {
                True -> #(
                  NoDrag,
                  Some(CrossContainer(
                    source_container,
                    source_index,
                    target_container,
                    target_index,
                  )),
                )
                False -> #(NoDrag, None)
              }
            }
          }
        }
        _ -> #(NoDrag, None)
      }
    DragOver(_) -> #(drag_state, None)
    TouchStart(container_id, index) -> #(
      TouchDragging(container_id, index, None, None),
      None,
    )
    TouchMove ->
      case drag_state {
        TouchDragging(source_container, source_index, over_container, _) -> {
          // Keep current state during move
          #(
            TouchDragging(source_container, source_index, over_container, None),
            None,
          )
        }
        _ -> #(drag_state, None)
      }
    TouchEnd ->
      case drag_state {
        TouchDragging(
          source_container,
          source_index,
          Some(target_container),
          Some(target_index),
        ) -> {
          case source_container == target_container {
            True -> #(NoDrag, Some(SameContainer(source_index, target_index)))
            False -> {
              let accepts = list.contains(config.accept_from, source_container)
              case accepts {
                True -> #(
                  NoDrag,
                  Some(CrossContainer(
                    source_container,
                    source_index,
                    target_container,
                    target_index,
                  )),
                )
                False -> #(NoDrag, None)
              }
            }
          }
        }
        TouchDragging(_, _, _, _) -> #(NoDrag, None)
        _ -> #(NoDrag, None)
      }
    TouchEnter(container_id, index) ->
      case drag_state {
        TouchDragging(source_container, source_index, _, _) -> {
          let accepts =
            source_container == container_id
            || list.contains(config.accept_from, source_container)

          case accepts {
            True -> #(
              TouchDragging(
                source_container,
                source_index,
                Some(container_id),
                Some(index),
              ),
              None,
            )
            False -> #(drag_state, None)
          }
        }
        _ -> #(drag_state, None)
      }
    UserMsg(_) -> #(drag_state, None)
  }
}
