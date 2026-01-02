import ensaimada
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import lustre
import lustre/attribute.{attribute, class}
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import tiramisu/ui

import pondering_my_orb/game_msg
import pondering_my_orb/magic_system/spell
import pondering_my_orb/player
import pondering_my_orb/player/magic

// =============================================================================
// TYPES
// =============================================================================

/// Internal message type for UI - wraps game messages and ensaimada messages
type Msg {
  GameMsg(game_msg.ToUI)
  DndMsg(ensaimada.Msg(Nil))
}

/// Lustre model - stores UI state and the bridge
pub type UIModel {
  UIModel(
    bridge: ui.Bridge(game_msg.ToUI, game_msg.ToGame),
    wand_slots: List(Option(spell.Spell)),
    selected_slot: Option(Int),
    mana: Float,
    max_mana: Float,
    available_spells: List(spell.Spell),
    drag_state: ensaimada.DragState,
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

pub fn start(
  bridge: ui.Bridge(game_msg.ToUI, game_msg.ToGame),
) -> Result(Nil, lustre.Error) {
  lustre.application(init, update, view)
  |> lustre.start("#ui", bridge)
  |> result.map(fn(_) { Nil })
}

// =============================================================================
// INIT
// =============================================================================

fn init(
  bridge: ui.Bridge(game_msg.ToUI, game_msg.ToGame),
) -> #(UIModel, effect.Effect(Msg)) {
  #(
    UIModel(
      bridge: bridge,
      wand_slots: [option.None, option.None, option.None, option.None],
      selected_slot: option.None,
      mana: 100.0,
      max_mana: 100.0,
      available_spells: [],
      drag_state: ensaimada.NoDrag,
    ),
    ui.register_lustre(bridge) |> effect.map(GameMsg),
  )
}

// =============================================================================
// UPDATE
// =============================================================================

fn update(model: UIModel, msg: Msg) -> #(UIModel, effect.Effect(Msg)) {
  case msg {
    GameMsg(game_msg.SlotClicked(slot)) -> #(
      UIModel(..model, selected_slot: option.Some(slot)),
      ui.to_tiramisu(
        model.bridge,
        game_msg.PlayerMsg(player.MagicMsg(magic.SelectSlot(slot))),
      )
        |> effect.map(GameMsg),
    )

    GameMsg(game_msg.WandUpdated(slots, selected, mana, max_mana, available)) -> #(
      UIModel(
        ..model,
        wand_slots: slots,
        selected_slot: selected,
        mana: mana,
        max_mana: max_mana,
        available_spells: available,
      ),
      effect.none(),
    )

    DndMsg(dnd_msg) -> {
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

      let #(new_drag_state, maybe_action) =
        ensaimada.update(dnd_msg, model.drag_state, wand_config)

      case maybe_action {
        option.Some(ensaimada.CrossContainer(
          from_container,
          from_index,
          to_container,
          to_index,
        )) -> {
          // Get spell from library
          case
            from_container == spell_library_id && to_container == wand_slots_id
          {
            True -> {
              case list.drop(model.available_spells, from_index) {
                [spell, ..] -> {
                  let spell_id = get_spell_id(spell)
                  #(
                    UIModel(..model, drag_state: new_drag_state),
                    ui.to_tiramisu(
                      model.bridge,
                      game_msg.PlayerMsg(
                        player.MagicMsg(magic.PlaceSpellInSlot(
                          spell_id,
                          to_index,
                        )),
                      ),
                    )
                      |> effect.map(GameMsg),
                  )
                }
                [] -> #(
                  UIModel(..model, drag_state: new_drag_state),
                  effect.none(),
                )
              }
            }
            False -> #(
              UIModel(..model, drag_state: new_drag_state),
              effect.none(),
            )
          }
        }

        option.Some(ensaimada.SameContainer(from_index, to_index)) -> {
          // Send reorder to game
          #(
            UIModel(..model, drag_state: new_drag_state),
            ui.to_tiramisu(
              model.bridge,
              game_msg.PlayerMsg(
                player.MagicMsg(magic.ReorderWandSlots(from_index, to_index)),
              ),
            )
              |> effect.map(GameMsg),
          )
        }

        option.None -> #(
          UIModel(..model, drag_state: new_drag_state),
          effect.none(),
        )
      }
    }
  }
}

fn get_spell_id(spell: spell.Spell) -> spell.Id {
  case spell {
    spell.DamageSpell(id, _) -> id
    spell.ModifierSpell(id, _) -> id
    spell.MulticastSpell(id, _) -> id
  }
}

// =============================================================================
// VIEW
// =============================================================================

fn view(model: UIModel) -> Element(Msg) {
  html.div(
    [
      class(
        "fixed bottom-0 left-0 right-0 flex items-end gap-4 p-4 pointer-events-auto",
      ),
    ],
    [
      // Left: Spell library
      view_spell_library(model),
      // Right: Wand slots and mana bar
      html.div([class("flex-1 flex justify-center")], [
        view_wand_bar(model),
      ]),
    ],
  )
}

fn view_spell_library(model: UIModel) -> Element(Msg) {
  let library_config =
    ensaimada.Config(
      on_reorder: fn(_, _) { Nil },
      container_id: spell_library_id,
      container_class: "flex flex-col gap-1 bg-black/70 rounded-lg p-2 max-h-48 overflow-y-auto",
      item_class: "",
      dragging_class: "opacity-50",
      drag_over_class: "",
      ghost_class: "",
      accept_from: [],
    )

  let items =
    model.available_spells
    |> list.index_map(fn(spell, i) {
      ensaimada.item(
        spell_id_to_string(get_spell_id(spell)) <> "-" <> int.to_string(i),
        spell,
      )
    })

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
  item: ensaimada.Item(spell.Spell),
  _index: Int,
  _drag_state: ensaimada.DragState,
) -> Element(Nil) {
  let spell = ensaimada.item_data(item)
  let name = get_spell_name(spell)
  let color = get_spell_color_class(spell)

  html.div(
    [
      class(
        "px-2 py-1 text-xs font-mono text-white rounded cursor-grab " <> color,
      ),
    ],
    [element.text(name)],
  )
}

fn view_wand_bar(model: UIModel) -> Element(Msg) {
  let wand_config =
    ensaimada.Config(
      on_reorder: fn(_, _) { Nil },
      container_id: wand_slots_id,
      container_class: "flex gap-2.5 p-2.5 bg-black/70 rounded-lg font-mono text-white",
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

  html.div([class("flex items-center gap-4")], [
    ensaimada.container(wand_config, model.drag_state, items, render_wand_slot)
      |> element.map(DndMsg),
    view_mana_bar(model.mana, model.max_mana),
  ])
}

fn render_wand_slot(
  item: ensaimada.Item(#(Int, Option(spell.Spell), Bool)),
  _index: Int,
  _drag_state: ensaimada.DragState,
) -> Element(Nil) {
  let #(slot_index, spell_opt, selected) = ensaimada.item_data(item)

  let border_color = case selected {
    True -> "border-[#4ecdc4]"
    False -> "border-gray-600"
  }

  let spell_name = case spell_opt {
    option.Some(spell) -> get_spell_name(spell)
    option.None -> "Empty"
  }

  html.div(
    [
      class(
        "w-16 h-16 border-2 rounded flex flex-col items-center justify-center text-xs cursor-grab bg-black/50 hover:bg-black/30 "
        <> border_color,
      ),
    ],
    [
      html.div([class("text-sm font-bold")], [
        element.text(int.to_string(slot_index + 1)),
      ]),
      html.div([class("text-[8px] mt-1")], [element.text(spell_name)]),
    ],
  )
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
          class("h-full bg-blue-500 transition-all"),
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

fn get_spell_name(spell: spell.Spell) -> String {
  case spell {
    spell.DamageSpell(_, kind) -> kind.name
    spell.ModifierSpell(_, kind) -> kind.name
    spell.MulticastSpell(_, kind) -> kind.name
  }
}

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
