import ensaimada
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{attribute, class}
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import tiramisu/ui

import pondering_my_orb/bridge_msg.{type BridgeMsg, type WandDisplayInfo}
import pondering_my_orb/health
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/spell_bag

// =============================================================================
// TYPES
// =============================================================================

/// Internal message type for UI
pub type Msg {
  /// Message from the game via bridge
  FromBridge(BridgeMsg)
  /// User clicked on a wand slot
  SlotClicked(Int)
  /// Drag and drop messages
  DndMsg(ensaimada.Msg(Nil))
}

/// Lustre model - stores UI state and the bridge
pub type Model {
  Model(
    bridge: ui.Bridge(BridgeMsg),
    wand_slots: List(Option(spell.Spell)),
    selected_slot: Option(Int),
    mana: Float,
    max_mana: Float,
    spell_bag: spell_bag.SpellBag,
    drag_state: ensaimada.DragState,
    health: health.Health,
    // Wand inventory
    wand_names: List(Option(String)),
    active_wand_index: Int,
    // Altar pickup prompt with full wand info
    altar_nearby: Option(WandDisplayInfo),
    // Edit mode (Tab to toggle)
    edit_mode_active: Bool,
  )
}

// =============================================================================
// CONSTANTS
// =============================================================================

const spell_library_id = "spell-library"

const wand_slots_id = "wand-slots"

// =============================================================================
// START
// =============================================================================

pub fn start(bridge: ui.Bridge(BridgeMsg)) -> Result(Nil, lustre.Error) {
  lustre.application(init, update, view)
  |> lustre.start("#ui", bridge)
  |> result.map(fn(_) { Nil })
}

// =============================================================================
// INIT
// =============================================================================

fn init(bridge: ui.Bridge(BridgeMsg)) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(
      bridge: bridge,
      wand_slots: [option.None, option.None, option.None, option.None],
      selected_slot: option.None,
      mana: 100.0,
      max_mana: 100.0,
      spell_bag: spell_bag.new(),
      drag_state: ensaimada.NoDrag,
      health: health.new(100.0),
      wand_names: [option.None, option.None, option.None, option.None],
      active_wand_index: 0,
      altar_nearby: option.None,
      edit_mode_active: False,
    ),
    ui.register_lustre(bridge, FromBridge),
  )
}

// =============================================================================
// UPDATE
// =============================================================================

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    // Handle messages from game via bridge
    FromBridge(bridge_msg) -> handle_bridge_msg(model, bridge_msg)

    // User clicked on a wand slot
    SlotClicked(slot) -> #(
      Model(..model, selected_slot: option.Some(slot)),
      ui.send(model.bridge, bridge_msg.SelectSlot(slot)),
    )

    // Drag and drop messages
    DndMsg(dnd_msg) -> handle_dnd_msg(model, dnd_msg)
  }
}

/// Handle messages coming from the game via bridge
fn handle_bridge_msg(model: Model, msg: BridgeMsg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    bridge_msg.PlayerStateUpdated(
      slots,
      selected,
      mana,
      max_mana,
      bag,
      player_health,
      wand_names,
      active_wand_idx,
      altar_nearby_wand,
    ) -> #(
      Model(
        ..model,
        wand_slots: slots,
        selected_slot: selected,
        mana: mana,
        max_mana: max_mana,
        spell_bag: bag,
        health: player_health,
        wand_names: wand_names,
        active_wand_index: active_wand_idx,
        altar_nearby: altar_nearby_wand,
      ),
      effect.none(),
    )

    bridge_msg.ToggleEditMode -> #(
      Model(..model, edit_mode_active: !model.edit_mode_active),
      effect.none(),
    )

    // UI → Game messages: ignore on UI side
    bridge_msg.SelectSlot(_)
    | bridge_msg.PlaceSpellInSlot(_, _)
    | bridge_msg.RemoveSpellFromSlot(_)
    | bridge_msg.ReorderWandSlots(_, _) -> #(model, effect.none())
  }
}

/// Handle drag and drop messages
fn handle_dnd_msg(
  model: Model,
  dnd_msg: ensaimada.Msg(Nil),
) -> #(Model, effect.Effect(Msg)) {
  // Create config for the wand slots (accepts from spell-library)
  let wand_config =
    ensaimada.Config(
      on_reorder: fn(_, _) { Nil },
      container_id: wand_slots_id,
      container_class: "",
      item_class: "",
      dragging_class: "opacity-50",
      drag_over_class: "ring-2 ring-cyan-400",
      ghost_class: "",
      accept_from: [spell_library_id],
    )

  // Create config for the spell library (accepts from wand-slots)
  let library_config =
    ensaimada.Config(
      on_reorder: fn(_, _) { Nil },
      container_id: spell_library_id,
      container_class: "",
      item_class: "",
      dragging_class: "opacity-50",
      drag_over_class: "ring-2 ring-purple-400",
      ghost_class: "",
      accept_from: [wand_slots_id],
    )

  // Try wand config first
  let #(new_drag_state, maybe_action) =
    ensaimada.update(dnd_msg, model.drag_state, wand_config)

  // If no action from wand config, try library config
  let #(final_drag_state, final_action) = case maybe_action {
    option.Some(_) -> #(new_drag_state, maybe_action)
    option.None -> ensaimada.update(dnd_msg, model.drag_state, library_config)
  }

  case final_action {
    option.Some(ensaimada.CrossContainer(
      from_container,
      from_index,
      to_container,
      _to_index,
    )) -> {
      // Spell Library → Wand: Place spell in slot
      case
        from_container == spell_library_id && to_container == wand_slots_id
      {
        True -> {
          let available_spells = spell_bag.list_spells(model.spell_bag)
          case list.drop(available_spells, from_index) {
            [spell, ..] -> {
              let spell_id = spell.id
              // Find first empty slot in wand
              let target_slot =
                find_first_empty_slot(model.wand_slots)
                |> option.unwrap(0)
              #(
                Model(..model, drag_state: final_drag_state),
                ui.send(
                  model.bridge,
                  bridge_msg.PlaceSpellInSlot(spell_id, target_slot),
                ),
              )
            }
            [] -> #(
              Model(..model, drag_state: final_drag_state),
              effect.none(),
            )
          }
        }
        False -> {
          // Wand → Spell Library: Remove spell from slot
          case
            from_container == wand_slots_id
            && to_container == spell_library_id
          {
            True -> #(
              Model(..model, drag_state: final_drag_state),
              ui.send(
                model.bridge,
                bridge_msg.RemoveSpellFromSlot(from_index),
              ),
            )
            False -> #(
              Model(..model, drag_state: final_drag_state),
              effect.none(),
            )
          }
        }
      }
    }

    option.Some(ensaimada.SameContainer(from_index, to_index)) -> {
      // Send reorder to game
      #(
        Model(..model, drag_state: final_drag_state),
        ui.send(
          model.bridge,
          bridge_msg.ReorderWandSlots(from: from_index, to: to_index),
        ),
      )
    }

    option.None -> #(
      Model(..model, drag_state: final_drag_state),
      effect.none(),
    )
  }
}

/// Find first empty slot index in wand slots
fn find_first_empty_slot(slots: List(Option(spell.Spell))) -> Option(Int) {
  find_empty_slot_loop(slots, 0)
}

fn find_empty_slot_loop(
  slots: List(Option(spell.Spell)),
  index: Int,
) -> Option(Int) {
  case slots {
    [] -> option.None
    [option.None, ..] -> option.Some(index)
    [option.Some(_), ..rest] -> find_empty_slot_loop(rest, index + 1)
  }
}

// =============================================================================
// VIEW
// =============================================================================

fn view(model: Model) -> Element(Msg) {
  html.div([class("pointer-events-none")], [
    // Top-left: Health bar
    view_health_bar(model.health),
    // Top-right: Wand inventory
    view_wand_inventory(model),
    // Center: Altar pickup prompt (if near altar)
    view_altar_prompt(model),
    // Conditional: Edit mode overlay OR just mana bar
    case model.edit_mode_active {
      True -> view_edit_mode_overlay(model)
      False -> view_mana_bar_standalone(model.mana, model.max_mana)
    },
  ])
}

/// Standalone mana bar shown in bottom-right when not in edit mode
fn view_mana_bar_standalone(mana: Float, max_mana: Float) -> Element(Msg) {
  html.div([class("fixed bottom-4 right-4 pointer-events-auto")], [
    html.div([class("bg-black/70 rounded-lg p-3")], [
      view_mana_bar(mana, max_mana),
    ]),
  ])
}

/// Edit mode overlay - shows spell bag and wand slots for editing
fn view_edit_mode_overlay(model: Model) -> Element(Msg) {
  html.div(
    [
      class(
        "fixed inset-0 bg-black/50 flex items-center justify-center pointer-events-auto",
      ),
    ],
    [
      html.div([class("bg-gray-900/95 rounded-lg p-6 flex gap-8")], [
        // Left: Spell Bag
        html.div([class("flex flex-col")], [
          html.div([class("text-white font-mono text-sm mb-2")], [
            element.text("Spell Bag"),
          ]),
          view_spell_library(model),
        ]),
        // Right: Active Wand Slots
        html.div([class("flex flex-col")], [
          html.div([class("text-white font-mono text-sm mb-2")], [
            element.text("Wand: " <> get_active_wand_name(model)),
          ]),
          view_wand_slots_for_edit(model),
          html.div([class("mt-4")], [
            view_mana_bar(model.mana, model.max_mana),
          ]),
        ]),
      ]),
      // I to close hint
      html.div(
        [
          class(
            "fixed bottom-8 left-1/2 -translate-x-1/2 text-white/70 font-mono text-sm",
          ),
        ],
        [element.text("Press I to close")],
      ),
    ],
  )
}

/// Get the name of the active wand
fn get_active_wand_name(model: Model) -> String {
  case list.drop(model.wand_names, model.active_wand_index) {
    [option.Some(name), ..] -> name
    _ -> "No Wand"
  }
}

/// Wand slots view for edit mode overlay
fn view_wand_slots_for_edit(model: Model) -> Element(Msg) {
  let wand_config =
    ensaimada.Config(
      on_reorder: fn(_, _) { Nil },
      container_id: wand_slots_id,
      container_class: "flex flex-col gap-2 min-w-48",
      item_class: "",
      dragging_class: "opacity-50",
      drag_over_class: "ring-2 ring-cyan-400",
      ghost_class: "",
      accept_from: [spell_library_id],
    )

  let items =
    model.wand_slots
    |> list.index_map(fn(spell_opt, i) {
      ensaimada.item("slot-" <> int.to_string(i), #(
        i,
        spell_opt,
        model.selected_slot == option.Some(i),
      ))
    })

  ensaimada.container(
    wand_config,
    model.drag_state,
    items,
    render_wand_slot_edit,
  )
  |> element.map(DndMsg)
}

/// Render a wand slot for edit mode (horizontal layout)
fn render_wand_slot_edit(
  item: ensaimada.Item(#(Int, Option(spell.Spell), Bool)),
  _index: Int,
  _drag_state: ensaimada.DragState,
) -> Element(Nil) {
  let #(slot_index, spell_opt, selected) = ensaimada.item_data(item)

  let border_color = case selected {
    True -> "border-cyan-400"
    False -> "border-gray-600"
  }

  let #(spell_name, spell_color) = case spell_opt {
    option.Some(spell) -> #(spell.name(spell), get_spell_color_class(spell))
    option.None -> #("Empty", "bg-gray-800")
  }

  html.div(
    [
      class(
        "flex items-center gap-3 px-3 py-2 border-2 rounded cursor-grab bg-black/50 hover:bg-black/30 "
        <> border_color,
      ),
    ],
    [
      html.div([class("text-yellow-400 font-bold text-lg w-6")], [
        element.text(int.to_string(slot_index + 1)),
      ]),
      html.div(
        [
          class(
            "flex-1 px-2 py-1 rounded text-white text-sm font-mono "
            <> spell_color,
          ),
        ],
        [element.text(spell_name)],
      ),
    ],
  )
}

fn view_spell_library(model: Model) -> Element(Msg) {
  let library_config =
    ensaimada.Config(
      on_reorder: fn(_, _) { Nil },
      container_id: spell_library_id,
      container_class: "flex flex-col gap-1 bg-black/70 rounded-lg p-2 max-h-64 overflow-y-auto min-w-40 min-h-16",
      item_class: "",
      dragging_class: "opacity-50",
      drag_over_class: "ring-2 ring-purple-400",
      ghost_class: "",
      accept_from: [wand_slots_id],
    )

  // Convert spell_bag to list for display, using Option(Spell) to allow placeholder
  let available_spells = spell_bag.list_spells(model.spell_bag)

  // If empty, add a placeholder item so ensaimada has something to drop onto
  let items = case list.is_empty(available_spells) {
    True -> [ensaimada.item("placeholder-drop-zone", option.None)]
    False ->
      available_spells
      |> list.index_map(fn(spell_item, i) {
        ensaimada.item(
          spell_id_to_string(spell_item.id) <> "-" <> int.to_string(i),
          option.Some(spell_item),
        )
      })
  }

  html.div([class("w-32")], [
    html.div([class("text-white text-xs mb-1 font-mono")], [
      element.text("Spells"),
    ]),
    ensaimada.container(
      library_config,
      model.drag_state,
      items,
      render_library_spell,
    )
      |> element.map(DndMsg),
  ])
}

fn render_library_spell(
  item: ensaimada.Item(Option(spell.Spell)),
  _index: Int,
  _drag_state: ensaimada.DragState,
) -> Element(Nil) {
  case ensaimada.item_data(item) {
    option.Some(spell_item) -> {
      let name = spell.name(spell_item)
      let color = get_spell_color_class(spell_item)

      html.div(
        [
          class(
            "px-2 py-1 text-xs font-mono text-white rounded cursor-grab "
            <> color,
          ),
        ],
        [element.text(name)],
      )
    }
    // Placeholder for empty spell bag - acts as drop zone
    option.None ->
      html.div(
        [
          class(
            "px-2 py-4 text-xs font-mono text-gray-500 rounded border-2 border-dashed border-gray-600 text-center italic",
          ),
        ],
        [element.text("Drop spells here")],
      )
  }
}

fn view_health_bar(player_health: health.Health) -> Element(Msg) {
  let percentage = health.percentage(player_health) *. 100.0
  let percentage_str = float.to_string(percentage)

  // Color changes based on health percentage
  let bar_color = case health.percentage(player_health) {
    p if p >. 0.6 -> "bg-green-500"
    p if p >. 0.3 -> "bg-yellow-500"
    _ -> "bg-red-500"
  }

  html.div([class("fixed top-4 left-4 pointer-events-auto")], [
    html.div([class("bg-black/70 rounded-lg p-3")], [
      html.div([class("text-xs mb-1 text-white font-mono")], [
        element.text("Health"),
      ]),
      html.div([class("w-32 h-4 bg-gray-700 rounded overflow-hidden")], [
        html.div(
          [
            class("h-full  " <> bar_color),
            attribute("style", "width: " <> percentage_str <> "%"),
          ],
          [],
        ),
      ]),
      html.div([class("text-xs mt-1 text-center text-white font-mono")], [
        element.text(
          int.to_string(float.round(health.current(player_health)))
          <> "/"
          <> int.to_string(float.round(health.max(player_health))),
        ),
      ]),
    ]),
  ])
}

fn view_mana_bar(mana: Float, max_mana: Float) -> Element(Msg) {
  let percentage = mana /. max_mana *. 100.0
  let percentage_str = float.to_string(percentage)

  html.div([class("flex flex-col justify-center")], [
    html.div([class("text-xs mb-1 text-white font-mono")], [
      element.text("Mana"),
    ]),
    html.div([class("w-24 h-3 bg-gray-700 rounded overflow-hidden")], [
      html.div(
        [
          class("h-full bg-blue-500"),
          attribute("style", "width: " <> percentage_str <> "%"),
        ],
        [],
      ),
    ]),
    html.div([class("text-[10px] mt-0.5 text-center text-white font-mono")], [
      element.text(
        int.to_string(float.round(mana))
        <> "/"
        <> int.to_string(float.round(max_mana)),
      ),
    ]),
  ])
}

// =============================================================================
// HELPERS
// =============================================================================

fn get_spell_color_class(spell: spell.Spell) -> String {
  case spell {
    spell.DamageSpell(..) -> "bg-red-700"
    spell.ModifierSpell(..) -> "bg-green-700"
    spell.MulticastSpell(..) -> "bg-blue-700"
  }
}

fn spell_id_to_string(id: spell.Id) -> String {
  case id {
    spell.Fireball -> "fireball"
    spell.LightningBolt -> "lightning-bolt"
    spell.Spark -> "spark"
    spell.SparkWithTrigger -> "spark-with-trigger"
    spell.Piercing -> "piercing"
    spell.DoubleSpell -> "double-spell"
    spell.AddMana -> "add-mana"
    spell.AddDamage -> "add-damage"
    spell.OrbitingSpell -> "orbiting-spell"
    spell.RapidFire -> "rapid-fire"
    spell.AddTrigger -> "add-trigger"
  }
}

/// Display the 4-wand inventory in top-right corner
fn view_wand_inventory(model: Model) -> Element(Msg) {
  let wand_slots =
    list.index_map(model.wand_names, fn(wand_opt, i) {
      view_wand_slot_inventory(wand_opt, i, model.active_wand_index)
    })

  html.div([class("fixed top-4 right-4 pointer-events-auto")], [
    html.div([class("bg-black/70 rounded-lg p-3")], [
      html.div([class("text-xs mb-2 text-white font-mono")], [
        element.text("Wands"),
      ]),
      html.div([class("flex gap-2")], wand_slots),
    ]),
  ])
}

fn view_wand_slot_inventory(
  wand_name_opt: Option(String),
  index: Int,
  active_index: Int,
) -> Element(Msg) {
  let is_active = index == active_index
  let border_class = case is_active {
    True -> "border-yellow-400 bg-yellow-900/30"
    False -> "border-gray-600 bg-black/50"
  }

  // Truncate name if too long (max 8 chars)
  let display_name = case wand_name_opt {
    option.Some(name) -> {
      case string.length(name) > 8 {
        True -> string.slice(name, 0, 7) <> ".."
        False -> name
      }
    }
    option.None -> "Empty"
  }

  html.div(
    [
      class(
        "w-16 h-16 border-2 rounded flex flex-col items-center justify-center text-xs font-mono text-white cursor-pointer hover:bg-black/30 "
        <> border_class,
      ),
    ],
    [
      // Keyboard shortcut
      html.div([class("text-lg font-bold text-yellow-400")], [
        element.text(int.to_string(index + 1)),
      ]),
      // Wand name (truncated)
      html.div([class("text-[8px] mt-1 text-center truncate w-14")], [
        element.text(display_name),
      ]),
    ],
  )
}

/// Display altar pickup prompt when near an altar
fn view_altar_prompt(model: Model) -> Element(Msg) {
  case model.altar_nearby {
    option.Some(wand_info) ->
      html.div([class("fixed bottom-32 left-1/2 -translate-x-1/2")], [
        html.div(
          [
            class(
              "bg-black/90 border-2 border-yellow-400 rounded-lg px-4 py-3 text-white font-mono min-w-64",
            ),
          ],
          [
            // Header with pickup prompt
            html.div([class("text-center mb-2 pb-2 border-b border-gray-600")], [
              html.span([class("text-yellow-400 font-bold")], [
                element.text("E"),
              ]),
              element.text(" - Pick up: "),
              html.span([class("text-cyan-400 font-bold")], [
                element.text(wand_info.name),
              ]),
            ]),
            // Stats grid
            html.div([class("grid grid-cols-2 gap-x-4 gap-y-1 text-xs")], [
              view_stat_row("Slots", int.to_string(wand_info.slot_count)),
              view_stat_row(
                "Spells/Cast",
                int.to_string(wand_info.spells_per_cast),
              ),
              view_stat_row(
                "Cast Delay",
                int.to_string(wand_info.cast_delay_ms) <> "ms",
              ),
              view_stat_row(
                "Recharge",
                int.to_string(wand_info.recharge_time_ms) <> "ms",
              ),
              view_stat_row(
                "Mana",
                int.to_string(float.round(wand_info.max_mana)),
              ),
              view_stat_row(
                "Mana/sec",
                float.to_precision(wand_info.mana_recharge_rate, 1)
                  |> float.to_string,
              ),
              view_stat_row(
                "Spread",
                float.to_precision(wand_info.spread, 1) |> float.to_string
                  <> "°",
              ),
            ]),
            // Spells section
            case wand_info.spell_names {
              [] -> html.div([], [])
              spells ->
                html.div([class("mt-2 pt-2 border-t border-gray-600")], [
                  html.div([class("text-xs text-gray-400 mb-1")], [
                    element.text("Spells:"),
                  ]),
                  html.div(
                    [class("flex flex-wrap gap-1")],
                    list.map(spells, fn(spell_name) {
                      html.span(
                        [class("px-1.5 py-0.5 bg-purple-800 rounded text-xs")],
                        [
                          element.text(spell_name),
                        ],
                      )
                    }),
                  ),
                ])
            },
          ],
        ),
      ])
    option.None -> html.div([], [])
  }
}

/// Helper to render a stat row
fn view_stat_row(label: String, value: String) -> Element(Msg) {
  html.div([class("contents")], [
    html.span([class("text-gray-400")], [element.text(label <> ":")]),
    html.span([class("text-white")], [element.text(value)]),
  ])
}
