import gleam/float
import gleam/int
import gleam/list
import gleam/option
import iv
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import sortable
import tiramisu/ui as tiramisu_ui

pub type Model {
  Model(
    player_health: Float,
    player_max_health: Float,
    player_mana: Float,
    player_max_mana: Float,
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
    drag_state: sortable.DragState,
    inventory_open: Bool,
  )
}

pub type Msg {
  GameStateUpdated(GameState)
  WandSortableMsg(sortable.SortableMsg(Msg))
  BagSortableMsg(sortable.SortableMsg(Msg))
  ToggleInventory
  SyncInventoryToGame
  NoOp
}

pub type UiToGameMsg {
  UpdatePlayerInventory(
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
  )
}

pub type GameState {
  GameState(
    player_health: Float,
    player_max_health: Float,
    player_mana: Float,
    player_max_mana: Float,
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
    inventory_open: Bool,
  )
}

pub fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(
      player_health: 100.0,
      player_max_health: 100.0,
      player_mana: 100.0,
      player_max_mana: 100.0,
      wand_slots: iv.new(),
      spell_bag: spell_bag.new(),
      drag_state: sortable.NoDrag,
      inventory_open: False,
    ),
    tiramisu_ui.register_lustre(),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    GameStateUpdated(state) -> {
      // Detect inventory closing (transition from True to False) and sync changes
      let sync_effect = case model.inventory_open, state.inventory_open {
        True, False ->
          tiramisu_ui.dispatch_to_tiramisu(UpdatePlayerInventory(
            model.wand_slots,
            model.spell_bag,
          ))
        _, _ -> effect.none()
      }

      // Don't overwrite wand_slots and spell_bag when inventory is open
      // to preserve user's drag-and-drop changes
      let #(wand_slots, spell_bag) = case model.inventory_open {
        True -> #(model.wand_slots, model.spell_bag)
        False -> #(state.wand_slots, state.spell_bag)
      }

      #(
        Model(
          player_health: state.player_health,
          player_max_health: state.player_max_health,
          player_mana: state.player_mana,
          player_max_mana: state.player_max_mana,
          wand_slots: wand_slots,
          spell_bag: spell_bag,
          drag_state: model.drag_state,
          inventory_open: state.inventory_open,
        ),
        sync_effect,
      )
    }
    ToggleInventory -> {
      // When closing inventory, sync changes back to game
      let sync_effect = case model.inventory_open {
        True ->
          tiramisu_ui.dispatch_to_tiramisu(UpdatePlayerInventory(
            model.wand_slots,
            model.spell_bag,
          ))
        False -> effect.none()
      }

      #(Model(..model, inventory_open: !model.inventory_open), sync_effect)
    }
    SyncInventoryToGame -> #(model, effect.none())
    WandSortableMsg(sortable_msg) -> {
      let wand_config =
        sortable.SortableConfig(
          on_reorder: fn(_from, _to) { WandSortableMsg(sortable.UserMsg(NoOp)) },
          container_id: "wand-slots",
          container_class: "flex gap-2",
          item_class: "sortable-item",
          dragging_class: "opacity-50 scale-105",
          drag_over_class: "ring-2 ring-blue-400",
          ghost_class: "opacity-30",
          accept_from: ["spell-bag"],
        )

      let #(new_drag_state, maybe_action) =
        sortable.update_sortable(sortable_msg, model.drag_state, wand_config)

      case maybe_action {
        option.None -> #(
          Model(..model, drag_state: new_drag_state),
          effect.none(),
        )
        option.Some(sortable.SameContainer(from_index, to_index)) -> {
          // Reorder within wand
          let new_slots = reorder_array(model.wand_slots, from_index, to_index)
          #(
            Model(..model, wand_slots: new_slots, drag_state: new_drag_state),
            effect.none(),
          )
        }
        option.Some(sortable.CrossContainer(
          from_container,
          from_index,
          _to_container,
          to_index,
        )) -> {
          case from_container {
            "spell-bag" -> {
              // Transfer from bag to wand
              let spell_stacks = spell_bag.list_spell_stacks(model.spell_bag)
              case
                spell_stacks
                |> list.drop(from_index)
                |> list.first()
              {
                Ok(#(spell_to_add, _count)) -> {
                  // Check if target slot already has a spell and add it back to bag
                  let new_bag = case iv.get(model.wand_slots, to_index) {
                    Ok(option.Some(existing_spell)) -> {
                      // Add existing spell back to bag
                      spell_bag.add_spell(model.spell_bag, existing_spell)
                    }
                    _ -> model.spell_bag
                  }

                  // Remove spell from bag
                  let new_bag = spell_bag.remove_spell(new_bag, spell_to_add)

                  // Add to wand at the drop position
                  let new_slots = case
                    iv.set(
                      model.wand_slots,
                      to_index,
                      option.Some(spell_to_add),
                    )
                  {
                    Ok(slots) -> slots
                    Error(_) -> model.wand_slots
                  }

                  #(
                    Model(
                      ..model,
                      wand_slots: new_slots,
                      spell_bag: new_bag,
                      drag_state: new_drag_state,
                    ),
                    effect.none(),
                  )
                }
                Error(_) -> #(
                  Model(..model, drag_state: new_drag_state),
                  effect.none(),
                )
              }
            }
            _ -> #(Model(..model, drag_state: new_drag_state), effect.none())
          }
        }
      }
    }
    BagSortableMsg(sortable_msg) -> {
      let bag_config =
        sortable.SortableConfig(
          on_reorder: fn(_from, _to) { BagSortableMsg(sortable.UserMsg(NoOp)) },
          container_id: "spell-bag",
          container_class: "grid grid-cols-4 gap-2",
          item_class: "sortable-item",
          dragging_class: "opacity-50 scale-105",
          drag_over_class: "[&>div]:ring-2 [&>div]:ring-purple-400",
          ghost_class: "opacity-30",
          accept_from: ["wand-slots"],
        )

      let #(new_drag_state, maybe_action) =
        sortable.update_sortable(sortable_msg, model.drag_state, bag_config)

      case maybe_action {
        option.None -> #(
          Model(..model, drag_state: new_drag_state),
          effect.none(),
        )
        option.Some(sortable.CrossContainer(
          from_container,
          from_index,
          _to_container,
          _to_index,
        )) -> {
          case from_container {
            "wand-slots" -> {
              // Transfer from wand to bag
              case iv.get(model.wand_slots, from_index) {
                Ok(option.Some(spell)) -> {
                  // Remove from wand
                  let new_slots = case
                    iv.set(model.wand_slots, from_index, option.None)
                  {
                    Ok(slots) -> slots
                    Error(_) -> model.wand_slots
                  }

                  // Add to bag
                  let new_bag = spell_bag.add_spell(model.spell_bag, spell)

                  #(
                    Model(
                      ..model,
                      wand_slots: new_slots,
                      spell_bag: new_bag,
                      drag_state: new_drag_state,
                    ),
                    effect.none(),
                  )
                }
                _ -> #(
                  Model(..model, drag_state: new_drag_state),
                  effect.none(),
                )
              }
            }
            _ -> #(Model(..model, drag_state: new_drag_state), effect.none())
          }
        }
        _ -> #(Model(..model, drag_state: new_drag_state), effect.none())
      }
    }
    NoOp -> #(model, effect.none())
  }
}

fn reorder_array(
  items: iv.Array(a),
  from_index: Int,
  to_index: Int,
) -> iv.Array(a) {
  case iv.get(items, from_index), iv.delete(items, from_index) {
    Ok(removed_item), Ok(list_without_item) -> {
      case iv.insert(list_without_item, to_index, removed_item) {
        Ok(reordered) -> reordered
        Error(_) -> items
      }
    }
    _, _ -> items
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed top-0 left-0 w-full h-full pointer-events-none select-none font-mono",
      ),
    ],
    [
      // Top left corner - Player stats (always visible, never blurred)
      html.div(
        [
          attribute.class(
            "absolute top-4 left-4 p-4 bg-gradient-to-br from-purple-900/90 to-indigo-900/90 border-4 border-amber-400 rounded-lg shadow-2xl",
          ),
          attribute.style("image-rendering", "pixelated"),
          attribute.style("backdrop-filter", "blur(4px)"),
          attribute.style("z-index", "200"),
        ],
        [
          // Health section
          html.div([attribute.class("mb-4")], [
            html.div([attribute.class("flex items-center gap-2 mb-2")], [
              html.span([attribute.class("text-red-400 text-lg")], [
                html.text("❤"),
              ]),
              html.span([attribute.class("text-white font-bold")], [
                html.text("HEALTH"),
              ]),
            ]),
            html.div([attribute.class("text-gray-300 text-sm mb-1")], [
              html.text(
                float_to_string_rounded(model.player_health)
                <> " / "
                <> float_to_string_rounded(model.player_max_health),
              ),
            ]),
            render_pixel_bar(
              current: model.player_health,
              max: model.player_max_health,
              color_class: health_color_class(
                model.player_health,
                model.player_max_health,
              ),
              bg_class: "bg-red-950",
            ),
          ]),
          // Mana section
          html.div([attribute.class("mb-4")], [
            html.div([attribute.class("flex items-center gap-2 mb-2")], [
              html.span([attribute.class("text-blue-400 text-lg")], [
                html.text("✦"),
              ]),
              html.span([attribute.class("text-white font-bold")], [
                html.text("MANA"),
              ]),
            ]),
            html.div([attribute.class("text-gray-300 text-sm mb-1")], [
              html.text(
                float_to_string_rounded(model.player_mana)
                <> " / "
                <> float_to_string_rounded(model.player_max_mana),
              ),
            ]),
            render_pixel_bar(
              current: model.player_mana,
              max: model.player_max_mana,
              color_class: "bg-blue-500",
              bg_class: "bg-blue-950",
            ),
          ]),
          // Wand section
          html.div([], [
            html.div([attribute.class("flex items-center gap-2 mb-2")], [
              html.span([attribute.class("text-amber-400 text-lg")], [
                html.text("⚡"),
              ]),
              html.span([attribute.class("text-white font-bold")], [
                html.text("WAND"),
              ]),
            ]),
            render_wand_slots(model.wand_slots, model.drag_state),
          ]),
        ],
      ),
      // Inventory screen (spell bag) - only show when inventory is open
      case model.inventory_open {
        True ->
          html.div(
            [
              attribute.class(
                "absolute inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm pointer-events-auto",
              ),
              attribute.style("z-index", "100"),
            ],
            [
              html.div(
                [
                  attribute.class(
                    "p-8 bg-gradient-to-br from-purple-900/95 to-indigo-900/95 border-4 border-amber-400 rounded-lg shadow-2xl pointer-events-auto",
                  ),
                  attribute.style("image-rendering", "pixelated"),
                  attribute.style("max-width", "800px"),
                ],
                [
                  html.div(
                    [attribute.class("flex items-center justify-between mb-4")],
                    [
                      html.div([attribute.class("flex items-center gap-2")], [
                        html.span(
                          [attribute.class("text-purple-400 text-2xl")],
                          [
                            html.text("📦"),
                          ],
                        ),
                        html.span(
                          [
                            attribute.class(
                              "text-white font-bold text-2xl tracking-wider",
                            ),
                          ],
                          [html.text("SPELL BAG")],
                        ),
                      ]),
                      html.div([attribute.class("text-gray-300 text-sm")], [
                        html.text("Press I to close"),
                      ]),
                    ],
                  ),
                  render_spell_bag(model.spell_bag, model.drag_state),
                ],
              ),
            ],
          )
        False -> html.div([], [])
      },
    ],
  )
}

fn render_pixel_bar(
  current current: Float,
  max max: Float,
  color_class color_class: String,
  bg_class bg_class: String,
) -> element.Element(Msg) {
  let percentage = case max >. 0.0 {
    True -> { current /. max } *. 100.0
    False -> 0.0
  }

  html.div(
    [
      attribute.class(
        "w-48 h-6 "
        <> bg_class
        <> " border-2 border-amber-600 relative overflow-hidden",
      ),
      attribute.style("image-rendering", "pixelated"),
    ],
    [
      // Filled portion
      html.div(
        [
          attribute.class(color_class <> " h-full"),
          attribute.style("width", float.to_string(percentage) <> "%"),
        ],
        [],
      ),
      // Pixel effect overlay
      html.div(
        [
          attribute.class("absolute inset-0 opacity-30"),
          attribute.style(
            "background",
            "repeating-linear-gradient(0deg, transparent, transparent 1px, rgba(255,255,255,0.1) 1px, rgba(255,255,255,0.1) 2px)",
          ),
          attribute.style("background-size", "2px 2px"),
        ],
        [],
      ),
    ],
  )
}

fn health_color_class(current: Float, max: Float) -> String {
  let percentage = current /. max *. 100.0
  case percentage {
    p if p >=. 75.0 -> "bg-green-500"
    p if p >=. 50.0 -> "bg-lime-500"
    p if p >=. 25.0 -> "bg-orange-500"
    _ -> "bg-red-500"
  }
}

fn render_wand_slots(
  slots: iv.Array(option.Option(spell.Spell)),
  drag_state: sortable.DragState,
) -> element.Element(Msg) {
  let sortable_items =
    slots
    |> iv.to_list()
    |> list.index_map(fn(slot, index) {
      sortable.create_sortable_item("wand-" <> int.to_string(index), slot)
    })

  let config =
    sortable.SortableConfig(
      on_reorder: fn(_from, _to) { WandSortableMsg(sortable.UserMsg(NoOp)) },
      container_id: "wand-slots",
      container_class: "flex gap-2 pointer-events-auto",
      item_class: "sortable-item",
      dragging_class: "opacity-50 scale-105",
      drag_over_class: "ring-2 ring-blue-400",
      ghost_class: "opacity-30",
      accept_from: ["spell-bag"],
    )

  element.map(
    sortable.sortable_container(
      config,
      drag_state,
      sortable_items,
      render_wand_slot_item,
    ),
    WandSortableMsg,
  )
}

fn render_wand_slot_item(
  item: sortable.SortableItem(option.Option(spell.Spell)),
  _index: Int,
  _drag_state: sortable.DragState,
) -> element.Element(Msg) {
  let slot = sortable.item_data(item)
  let #(content, bg_class, border_class, text_class) = case slot {
    option.Some(spell.DamageSpell(damage_spell)) -> #(
      spell_icon(damage_spell),
      "bg-red-600",
      "border-red-400",
      "text-white",
    )
    option.Some(spell.ModifierSpell(_)) -> #(
      "✨",
      "bg-green-600",
      "border-green-400",
      "text-white",
    )
    option.None -> #("", "bg-gray-800", "border-gray-600", "text-gray-500")
  }

  html.div(
    [
      attribute.class(
        "w-12 h-12 "
        <> bg_class
        <> " border-2 "
        <> border_class
        <> " flex items-center justify-center text-xl font-bold "
        <> text_class
        <> " shadow-lg relative transition-all hover:scale-110 cursor-move pointer-events-auto",
      ),
      attribute.style("image-rendering", "pixelated"),
    ],
    [
      html.text(content),
      // Inner shadow effect
      html.div(
        [
          attribute.class("absolute inset-0 opacity-20 pointer-events-none"),
          attribute.style("box-shadow", "inset 0 2px 4px rgba(0,0,0,0.5)"),
        ],
        [],
      ),
    ],
  )
}

fn render_spell_bag(
  bag: spell_bag.SpellBag,
  drag_state: sortable.DragState,
) -> element.Element(Msg) {
  let spell_stacks = spell_bag.list_spell_stacks(bag)

  let sortable_items =
    spell_stacks
    |> list.index_map(fn(stack, index) {
      sortable.create_sortable_item("bag-" <> int.to_string(index), stack)
    })

  let config =
    sortable.SortableConfig(
      on_reorder: fn(_from, _to) { BagSortableMsg(sortable.UserMsg(NoOp)) },
      container_id: "spell-bag",
      container_class: "grid grid-cols-4 gap-2 pointer-events-auto",
      item_class: "sortable-item",
      dragging_class: "opacity-50 scale-105",
      drag_over_class: "[&>div]:ring-2 [&>div]:ring-purple-400",
      ghost_class: "opacity-30",
      accept_from: ["wand-slots"],
    )

  element.map(
    sortable.sortable_container(
      config,
      drag_state,
      sortable_items,
      render_bag_spell_item,
    ),
    BagSortableMsg,
  )
}

fn render_bag_spell_item(
  item: sortable.SortableItem(#(spell.Spell, Int)),
  _index: Int,
  _drag_state: sortable.DragState,
) -> element.Element(Msg) {
  let #(spell_item, count) = sortable.item_data(item)
  let #(content, bg_class, border_class, text_class) = case spell_item {
    spell.DamageSpell(damage_spell) -> #(
      spell_icon(damage_spell),
      "bg-red-600",
      "border-red-400",
      "text-white",
    )
    spell.ModifierSpell(_) -> #(
      "✨",
      "bg-green-600",
      "border-green-400",
      "text-white",
    )
  }

  html.div(
    [
      attribute.class(
        "w-12 h-12 "
        <> bg_class
        <> " border-2 "
        <> border_class
        <> " flex items-center justify-center text-xl font-bold "
        <> text_class
        <> " shadow-lg relative transition-all hover:scale-110 cursor-move pointer-events-auto",
      ),
      attribute.style("image-rendering", "pixelated"),
    ],
    [
      html.text(content),
      // Count badge
      case count > 1 {
        True ->
          html.div(
            [
              attribute.class(
                "absolute -top-1 -right-1 bg-amber-500 border border-amber-700 rounded-full w-5 h-5 flex items-center justify-center text-xs font-bold text-black",
              ),
            ],
            [html.text(int.to_string(count))],
          )
        False -> html.div([], [])
      },
      // Inner shadow effect
      html.div(
        [
          attribute.class("absolute inset-0 opacity-20 pointer-events-none"),
          attribute.style("box-shadow", "inset 0 2px 4px rgba(0,0,0,0.5)"),
        ],
        [],
      ),
    ],
  )
}

fn spell_icon(spell: spell.DamageSpell) -> String {
  case spell.damage {
    d if d >=. 100.0 -> "🔥"
    d if d >=. 50.0 -> "⚡"
    _ -> "✦"
  }
}

fn float_to_string_rounded(value: Float) -> String {
  value
  |> float.round()
  |> int.to_string()
}

pub fn start() {
  let assert Ok(_) =
    lustre.application(init, update, view)
    |> lustre.start("#ui", Nil)
  Nil
}
