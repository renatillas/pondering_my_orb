# Ensaimada

A drag-and-drop sortable list library for Gleam/Lustre with full support for both desktop and mobile devices.

## Features

- **Desktop Support**: HTML5 drag and drop API
- **Mobile Support**: Touch events for drag and drop on mobile devices
- **Customizable**: Configurable CSS classes for styling
- **Type Safe**: Fully typed with Gleam's type system
- **Framework Agnostic**: No built-in CSS framework dependencies
- **Cross-Container Support**: Move items between multiple sortable containers

## Installation

Add `ensaimada` to your Gleam project:

```sh
gleam add ensaimada
```

## Quick Start

```gleam
import gleam/list
import lustre
import lustre/element.{type Element}
import lustre/element/html
import ensaimada

pub type Model {
  Model(items: List(String), drag_state: ensaimada.DragState)
}

pub type Msg {
  SortableMsg(ensaimada.SortableMsg(Msg))
  Reorder(Int, Int)
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    SortableMsg(sortable_msg) -> {
      let config = sortable.default_config(Reorder, "my-list")
      let #(new_drag_state, maybe_action) =
        sortable.update_sortable(sortable_msg, model.drag_state, config)

      case maybe_action {
        option.Some(sortable.SameContainer(from, to)) -> {
          let new_items = sortable.reorder_list(model.items, from, to)
          Model(..model, items: new_items, drag_state: new_drag_state)
        }
        _ -> Model(..model, drag_state: new_drag_state)
      }
    }
    Reorder(_, _) -> model
  }
}

pub fn view(model: Model) -> Element(Msg) {
  let config = sortable.default_config(Reorder, "my-list")

  let sortable_items =
    list.index_map(model.items, fn(item, i) {
      sortable.create_sortable_item("item-" <> int.to_string(i), item)
    })

  sortable.sortable_container(
    config,
    model.drag_state,
    sortable_items,
    fn(item, _index, _drag_state) {
      html.div([], [html.text(sortable.item_data(item))])
    },
  )
  |> element.map(SortableMsg)
}
```

## Styling

The library uses CSS classes for styling. Here's an example CSS setup:

```css
.sortable-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
  padding: 1rem;
}

.sortable-item {
  padding: 1rem;
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  transition: all 0.2s ease;
}

.sortable-dragging {
  opacity: 0.5;
  transform: scale(1.05) rotate(3deg);
}

.sortable-drag-over {
  border-color: #3b82f6;
  background: #eff6ff;
}

.sortable-active {
  user-select: none;
}
```

## Cross-Container Drag and Drop

To enable dragging between multiple containers:

```gleam
let config1 = sortable.SortableConfig(
  ..sortable.default_config(Reorder, "container-1"),
  accept_from: ["container-2"]
)

let config2 = sortable.SortableConfig(
  ..sortable.default_config(Reorder, "container-2"),
  accept_from: ["container-1"]
)
```

Then handle `CrossContainer` actions in your update function:

```gleam
case maybe_action {
  Some(sortable.CrossContainer(from_cont, from_idx, to_cont, to_idx)) -> {
    // Remove from source container and add to target container
    ...
  }
  ...
}
```

## Testing

Run tests with:

```sh
gleam test
```

## License

This project is available under the MIT license. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
