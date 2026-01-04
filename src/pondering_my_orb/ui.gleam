import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleam/time/duration
import iv
import lustre
import lustre/attribute.{class, style}
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import tiramisu/ui

import pondering_my_orb/health
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/wand

// =============================================================================
// TYPES
// =============================================================================

/// Internal message type for UI
pub type Msg {
  FromBridge(BridgeMsg)
  HoverWand(Option(Int))
  /// Hover spell by wand index and slot index
  HoverSpell(Option(#(Int, Int)))
}

/// Wand info for inventory display
pub type WandInfo {
  WandInfo(wand: Option(wand.Wand), cast_index: Int)
}

/// Messages that flow between Tiramisu (game) and Lustre (UI)
pub type BridgeMsg {
  // Game -> UI
  HealthUpdated(health.Health)
  WandStateUpdated(WandInfo)
  ActiveWandChanged(index: Int, total_wands: Int)
  EditModeToggled(is_open: Bool, wands: List(WandInfo))
}

/// Lustre model - stores UI state and the bridge
pub type Model {
  Model(
    bridge: ui.Bridge(BridgeMsg),
    health: health.Health,
    active_wand: Option(wand.Wand),
    cast_index: Int,
    active_wand_index: Int,
    total_wands: Int,
    // Edit mode / inventory
    edit_mode: Bool,
    all_wands: List(WandInfo),
    hovered_wand: Option(Int),
    /// Hovered spell as (wand_index, slot_index)
    hovered_spell: Option(#(Int, Int)),
  )
}

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
  let model =
    Model(
      bridge: bridge,
      health: health.new(100.0),
      active_wand: option.None,
      cast_index: 0,
      active_wand_index: 0,
      total_wands: 4,
      edit_mode: False,
      all_wands: [],
      hovered_wand: option.None,
      hovered_spell: option.None,
    )
  #(model, ui.register_lustre(bridge, FromBridge))
}

// =============================================================================
// UPDATE
// =============================================================================

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    FromBridge(HealthUpdated(new_health)) -> #(
      Model(..model, health: new_health),
      effect.none(),
    )

    FromBridge(WandStateUpdated(WandInfo(wand:, cast_index:))) -> #(
      Model(..model, active_wand: wand, cast_index:),
      effect.none(),
    )

    FromBridge(ActiveWandChanged(index, total)) -> #(
      Model(..model, active_wand_index: index, total_wands: total),
      effect.none(),
    )

    FromBridge(EditModeToggled(is_open, wands)) -> #(
      Model(
        ..model,
        edit_mode: is_open,
        all_wands: wands,
        hovered_wand: option.None,
        hovered_spell: option.None,
      ),
      effect.none(),
    )

    HoverWand(wand_index) -> {
      // When leaving a wand, also clear the hovered spell
      let new_hovered_spell = case wand_index {
        option.None -> option.None
        option.Some(_) -> model.hovered_spell
      }
      #(
        Model(..model, hovered_wand: wand_index, hovered_spell: new_hovered_spell),
        effect.none(),
      )
    }

    HoverSpell(spell_opt) -> #(
      Model(..model, hovered_spell: spell_opt),
      effect.none(),
    )
  }
}

// =============================================================================
// VIEW
// =============================================================================

fn view(model: Model) -> Element(Msg) {
  html.div([class("pointer-events-none")], [
    // HUD (always visible)
    html.div([class("fixed top-4 left-4 flex flex-col gap-3")], [
      view_health(model.health),
      view_wand(model.active_wand, model.cast_index, model.active_wand_index),
    ]),
    // Inventory overlay (when edit mode is active)
    case model.edit_mode {
      True ->
        view_inventory(
          model.all_wands,
          model.active_wand_index,
          model.hovered_wand,
          model.hovered_spell,
        )
      False -> html.text("")
    },
  ])
}

fn view_inventory(
  wands: List(WandInfo),
  active_index: Int,
  hovered_wand: Option(Int),
  hovered_spell_indices: Option(#(Int, Int)),
) -> Element(Msg) {
  // Get the hovered wand info for tooltip
  let hovered_wand_info = case hovered_wand {
    option.Some(idx) ->
      wands
      |> list.drop(idx)
      |> list.first
      |> result.unwrap(WandInfo(option.None, 0))
    option.None -> WandInfo(option.None, 0)
  }

  // Look up the hovered spell from indices
  let hovered_spell = case hovered_spell_indices {
    option.Some(#(wand_idx, slot_idx)) -> {
      wands
      |> list.drop(wand_idx)
      |> list.first
      |> result.map(fn(wand_info) {
        case wand_info.wand {
          option.Some(w) ->
            iv.get(w.slots, slot_idx) |> result.unwrap(option.None)
          option.None -> option.None
        }
      })
      |> result.unwrap(option.None)
    }
    option.None -> option.None
  }

  html.div(
    [
      class(
        "fixed inset-0 z-50 bg-black/70 flex items-center justify-center pointer-events-auto",
      ),
    ],
    [
      // Use relative container for absolute tooltip positioning
      html.div([class("relative")], [
        // Wands panel
        html.div([class("bg-gray-900/95 rounded-lg p-6 max-w-2xl")], [
          // Header
          html.div([class("text-white text-xl font-bold mb-4 text-center")], [
            html.text("Inventory"),
          ]),
          html.div([class("text-gray-400 text-sm mb-6 text-center")], [
            html.text("Press I to close"),
          ]),
          // Wands grid
          html.div(
            [class("flex flex-col gap-4")],
            wands
              |> list.index_map(fn(wand_info, idx) {
                view_inventory_wand(wand_info, idx, idx == active_index)
              }),
          ),
        ]),
        // Tooltip panels - absolute positioned to not affect layout
        html.div(
          [class("absolute left-full top-0 ml-4 flex flex-col gap-4 w-64")],
          [
            // Wand tooltip
            html.div([class("bg-gray-900/95 rounded-lg p-4")], [
              case hovered_wand {
                option.Some(_) -> view_wand_tooltip_content(hovered_wand_info)
                option.None ->
                  html.div([class("text-gray-500 text-sm italic text-center")], [
                    html.text("Hover over a wand to see details"),
                  ])
              },
            ]),
            // Spell tooltip
            html.div([class("bg-gray-900/95 rounded-lg p-4")], [
              case hovered_spell {
                option.Some(s) -> view_spell_tooltip_content(s)
                option.None ->
                  html.div([class("text-gray-500 text-sm italic text-center")], [
                    html.text("Hover over a spell to see details"),
                  ])
              },
            ]),
          ],
        ),
      ]),
    ],
  )
}

fn view_inventory_wand(
  wand_info: WandInfo,
  index: Int,
  is_active: Bool,
) -> Element(Msg) {
  let border_class = case is_active {
    True -> "border-yellow-400 border-2"
    False -> "border-gray-700 border"
  }

  let label_class = case is_active {
    True -> "text-yellow-400"
    False -> "text-gray-400"
  }

  html.div(
    [
      class(
        "flex items-start gap-4 "
        <> border_class
        <> " rounded-lg p-3 bg-gray-800/50 cursor-pointer hover:bg-gray-700/50 transition-colors",
      ),
      event.on_mouse_enter(HoverWand(option.Some(index))),
      event.on_mouse_leave(HoverWand(option.None)),
    ],
    [
      // Wand slot number
      html.div([class("text-2xl font-bold " <> label_class <> " w-8")], [
        html.text(int.to_string(index + 1)),
      ]),
      // Wand details
      case wand_info.wand {
        option.None ->
          html.div([class("text-gray-500 italic")], [html.text("Empty slot")])

        option.Some(w) -> {
          let mana_pct = w.current_mana /. w.max_mana *. 100.0
          let current_mana = float.round(w.current_mana)
          let max_mana = float.round(w.max_mana)

          html.div([class("flex flex-col gap-2 flex-1")], [
            // Wand name
            html.div([class("text-white font-semibold")], [html.text(w.name)]),
            // Mana bar
            html.div([class("flex items-center gap-2")], [
              html.div([class("text-blue-300 text-xs font-mono w-20")], [
                html.text(
                  int.to_string(current_mana) <> "/" <> int.to_string(max_mana),
                ),
              ]),
              html.div(
                [class("flex-1 h-2 bg-gray-700 rounded overflow-hidden")],
                [
                  html.div(
                    [
                      class("h-full bg-blue-500"),
                      style("width", float.to_string(mana_pct) <> "%"),
                    ],
                    [],
                  ),
                ],
              ),
            ]),
            // Spell slots (with hover for tooltips)
            view_inventory_spell_slots(w.slots, wand_info.cast_index, index),
          ])
        }
      },
    ],
  )
}

fn view_wand_tooltip_content(wand_info: WandInfo) -> Element(Msg) {
  case wand_info.wand {
    option.None ->
      html.div([class("text-gray-500 text-sm italic text-center")], [
        html.text("Empty wand slot"),
      ])

    option.Some(w) -> {
        let cast_delay_ms = float.round(duration.to_seconds(w.cast_delay) *. 1000.0)
        let recharge_ms = float.round(duration.to_seconds(w.recharge_time) *. 1000.0)

        html.div([class("flex flex-col gap-3")], [
          // Wand name
          html.div([class("text-white font-bold text-lg border-b border-gray-700 pb-2")], [
            html.text(w.name),
          ]),
          // Stats
          html.div([class("flex flex-col gap-2 text-sm")], [
            // Mana
            view_tooltip_stat(
              "Mana",
              int.to_string(float.round(w.max_mana)),
              "text-blue-400",
            ),
            // Mana recharge
            view_tooltip_stat(
              "Mana Recharge",
              float.to_string(w.mana_recharge_rate) <> "/s",
              "text-blue-300",
            ),
            // Cast delay
            view_tooltip_stat(
              "Cast Delay",
              int.to_string(cast_delay_ms) <> "ms",
              "text-yellow-400",
            ),
            // Recharge time
            view_tooltip_stat(
              "Recharge Time",
              int.to_string(recharge_ms) <> "ms",
              "text-orange-400",
            ),
            // Spells per cast
            view_tooltip_stat(
              "Spells/Cast",
              int.to_string(w.spells_per_cast),
              "text-purple-400",
            ),
            // Spread
            view_tooltip_stat(
              "Spread",
              float.to_string(w.spread) <> "°",
              "text-gray-400",
            ),
          ]),
          // Slot count
          html.div([class("text-gray-500 text-xs mt-2 pt-2 border-t border-gray-700")], [
            html.text(int.to_string(iv.size(w.slots)) <> " spell slots"),
          ]),
        ])
      }
  }
}

fn view_tooltip_stat(label: String, value: String, color: String) -> Element(Msg) {
  html.div([class("flex justify-between")], [
    html.span([class("text-gray-400")], [html.text(label)]),
    html.span([class(color <> " font-mono")], [html.text(value)]),
  ])
}

fn view_inventory_spell_slots(
  slots: iv.Array(Option(spell.Spell)),
  cast_index: Int,
  wand_index: Int,
) -> Element(Msg) {
  html.div(
    [class("flex gap-1 mt-1")],
    slots
      |> iv.index_map(fn(slot, i) {
        view_inventory_spell_slot(slot, i, i == cast_index, wand_index)
      })
      |> iv.to_list,
  )
}

fn view_inventory_spell_slot(
  slot: Option(spell.Spell),
  slot_index: Int,
  is_active: Bool,
  wand_index: Int,
) -> Element(Msg) {
  let border_class = case is_active {
    True -> "border-yellow-400 border-2 shadow-lg shadow-yellow-400/50"
    False -> "border-gray-600 border"
  }

  let bg_class = case slot {
    option.Some(_) -> "bg-gray-800/90"
    option.None -> "bg-gray-900/60"
  }

  // Only send hover event if there's a spell in this slot
  let hover_msg = case slot {
    option.Some(_) -> HoverSpell(option.Some(#(wand_index, slot_index)))
    option.None -> HoverSpell(option.None)
  }

  html.div(
    [
      class(
        "w-10 h-10 "
        <> border_class
        <> " "
        <> bg_class
        <> " rounded flex items-center justify-center relative cursor-pointer hover:bg-gray-700/90 transition-colors",
      ),
      // Only mouseenter - mouseleave is handled at wand level to prevent flicker
      event.on_mouse_enter(hover_msg),
    ],
    [
      case slot {
        option.None ->
          html.span([class("text-gray-600 text-xs")], [
            html.text(int.to_string(slot_index + 1)),
          ])

        option.Some(s) -> {
          let name = spell.name(s)
          let short_name = get_short_name(name)
          let color_class = get_spell_color_class(s)

          html.div([class("flex flex-col items-center")], [
            html.span([class("text-xs font-bold " <> color_class)], [
              html.text(short_name),
            ]),
          ])
        }
      },
    ],
  )
}

fn view_spell_tooltip_content(s: spell.Spell) -> Element(Msg) {
  case s {
    spell.DamageSpell(_, kind) -> view_damage_spell_tooltip(kind)
    spell.ModifierSpell(_, kind) -> view_modifier_spell_tooltip(kind)
    spell.MulticastSpell(_, kind) -> view_multicast_spell_tooltip(kind)
  }
}

fn view_damage_spell_tooltip(s: spell.DamageSpell) -> Element(Msg) {
  let cast_delay_ms =
    float.round(duration.to_seconds(s.cast_delay_addition) *. 1000.0)
  let lifetime_ms =
    float.round(duration.to_seconds(s.projectile_lifetime) *. 1000.0)

  html.div([class("flex flex-col gap-3")], [
    // Spell name
    html.div(
      [class("text-yellow-300 font-bold text-lg border-b border-gray-700 pb-2")],
      [html.text(s.name)],
    ),
    html.div([class("text-gray-500 text-xs -mt-2 mb-1")], [
      html.text("Projectile Spell"),
    ]),
    // Stats
    html.div([class("flex flex-col gap-2 text-sm")], [
      view_tooltip_stat(
        "Mana Cost",
        int.to_string(float.round(s.mana_cost)),
        "text-blue-400",
      ),
      view_tooltip_stat(
        "Damage",
        int.to_string(float.round(s.damage)),
        "text-red-400",
      ),
      view_tooltip_stat(
        "Speed",
        int.to_string(float.round(s.projectile_speed)),
        "text-cyan-400",
      ),
      view_tooltip_stat("Lifetime", int.to_string(lifetime_ms) <> "ms", "text-gray-400"),
      view_tooltip_stat(
        "Cast Delay",
        int.to_string(cast_delay_ms) <> "ms",
        "text-yellow-400",
      ),
      view_tooltip_stat(
        "Crit Chance",
        float.to_string(s.critical_chance *. 100.0) <> "%",
        "text-orange-400",
      ),
      view_tooltip_stat("Spread", float.to_string(s.spread) <> "°", "text-gray-400"),
    ]),
    // Special properties
    case s.has_trigger {
      True ->
        html.div([class("text-purple-400 text-xs mt-2 pt-2 border-t border-gray-700")], [
          html.text("Has Trigger"),
        ])
      False -> html.text("")
    },
  ])
}

fn view_modifier_spell_tooltip(s: spell.ModifierSpell) -> Element(Msg) {
  let cast_delay_ms =
    float.round(duration.to_seconds(s.cast_delay_addition) *. 1000.0)
  let recharge_ms =
    float.round(duration.to_seconds(s.recharge_addition) *. 1000.0)

  html.div([class("flex flex-col gap-3")], [
    // Spell name
    html.div(
      [class("text-green-400 font-bold text-lg border-b border-gray-700 pb-2")],
      [html.text(s.name)],
    ),
    html.div([class("text-gray-500 text-xs -mt-2 mb-1")], [
      html.text("Modifier Spell"),
    ]),
    // Stats
    html.div([class("flex flex-col gap-2 text-sm")], [
      view_tooltip_stat(
        "Mana Cost",
        int.to_string(float.round(s.mana_cost)),
        "text-blue-400",
      ),
      // Show non-default modifiers
      case s.damage_addition != 0.0 {
        True ->
          view_tooltip_stat(
            "Damage +",
            format_modifier(s.damage_addition),
            "text-red-400",
          )
        False -> html.text("")
      },
      case s.damage_multiplier != 1.0 {
        True ->
          view_tooltip_stat(
            "Damage ×",
            float.to_string(s.damage_multiplier),
            "text-red-400",
          )
        False -> html.text("")
      },
      case s.projectile_speed_addition != 0.0 {
        True ->
          view_tooltip_stat(
            "Speed +",
            format_modifier(s.projectile_speed_addition),
            "text-cyan-400",
          )
        False -> html.text("")
      },
      case s.projectile_speed_multiplier != 1.0 {
        True ->
          view_tooltip_stat(
            "Speed ×",
            float.to_string(s.projectile_speed_multiplier),
            "text-cyan-400",
          )
        False -> html.text("")
      },
      case cast_delay_ms != 0 {
        True ->
          view_tooltip_stat(
            "Cast Delay",
            format_modifier_int(cast_delay_ms) <> "ms",
            "text-yellow-400",
          )
        False -> html.text("")
      },
      case recharge_ms != 0 {
        True ->
          view_tooltip_stat(
            "Recharge",
            format_modifier_int(recharge_ms) <> "ms",
            "text-orange-400",
          )
        False -> html.text("")
      },
    ]),
    case s.adds_trigger {
      True ->
        html.div([class("text-purple-400 text-xs mt-2 pt-2 border-t border-gray-700")], [
          html.text("Adds Trigger to next spell"),
        ])
      False -> html.text("")
    },
  ])
}

fn view_multicast_spell_tooltip(s: spell.MulticastSpell) -> Element(Msg) {
  let spell_count_text = case s.spell_count {
    spell.Fixed(n) -> int.to_string(n) <> " spells"
    spell.AllRemaining -> "All remaining"
  }

  html.div([class("flex flex-col gap-3")], [
    // Spell name
    html.div(
      [class("text-blue-400 font-bold text-lg border-b border-gray-700 pb-2")],
      [html.text(s.name)],
    ),
    html.div([class("text-gray-500 text-xs -mt-2 mb-1")], [
      html.text("Multicast Spell"),
    ]),
    // Stats
    html.div([class("flex flex-col gap-2 text-sm")], [
      view_tooltip_stat(
        "Mana Cost",
        int.to_string(float.round(s.mana_cost)),
        "text-blue-400",
      ),
      view_tooltip_stat("Casts", spell_count_text, "text-purple-400"),
      case s.draw_add > 0 {
        True ->
          view_tooltip_stat("Extra Draw", "+" <> int.to_string(s.draw_add), "text-green-400")
        False -> html.text("")
      },
    ]),
  ])
}

fn format_modifier(value: Float) -> String {
  case value >=. 0.0 {
    True -> "+" <> int.to_string(float.round(value))
    False -> int.to_string(float.round(value))
  }
}

fn format_modifier_int(value: Int) -> String {
  case value >= 0 {
    True -> "+" <> int.to_string(value)
    False -> int.to_string(value)
  }
}

fn view_health(h: health.Health) -> Element(Msg) {
  let pct = health.percentage(h) *. 100.0
  let current = float.round(health.current(h))
  let max = float.round(health.max(h))

  html.div([class("flex flex-col gap-1")], [
    html.div([class("text-white text-sm font-mono drop-shadow-md")], [
      html.text("HP: " <> int.to_string(current) <> "/" <> int.to_string(max)),
    ]),
    html.div([class("w-40 h-3 bg-gray-800/80 rounded overflow-hidden")], [
      html.div(
        [
          class("h-full bg-red-500 transition-all duration-100"),
          style("width", float.to_string(pct) <> "%"),
        ],
        [],
      ),
    ]),
  ])
}

fn view_wand(
  wand_opt: Option(wand.Wand),
  cast_index: Int,
  wand_index: Int,
) -> Element(Msg) {
  case wand_opt {
    option.None ->
      html.div([class("text-gray-400 text-sm")], [html.text("No wand equipped")])

    option.Some(w) -> {
      let mana_pct = w.current_mana /. w.max_mana *. 100.0
      let current_mana = float.round(w.current_mana)
      let max_mana = float.round(w.max_mana)

      html.div([class("flex flex-col gap-1")], [
        // Wand name + index
        html.div([class("text-white text-sm drop-shadow-md")], [
          html.text("[" <> int.to_string(wand_index + 1) <> "] " <> w.name),
        ]),
        // Mana text and bar
        html.div([class("text-blue-300 text-xs font-mono drop-shadow-md")], [
          html.text(
            "Mana: "
            <> int.to_string(current_mana)
            <> "/"
            <> int.to_string(max_mana),
          ),
        ]),
        html.div([class("w-40 h-3 bg-gray-800/80 rounded overflow-hidden")], [
          html.div(
            [
              class("h-full bg-blue-500 transition-all duration-100"),
              style("width", float.to_string(mana_pct) <> "%"),
            ],
            [],
          ),
        ]),
        // Spell slots
        view_spell_slots(w.slots, cast_index),
      ])
    }
  }
}

fn view_spell_slots(
  slots: iv.Array(Option(spell.Spell)),
  cast_index: Int,
) -> Element(Msg) {
  html.div(
    [class("flex gap-1 mt-1")],
    slots
      |> iv.index_map(fn(slot, i) { view_spell_slot(slot, i, i == cast_index) })
      |> iv.to_list,
  )
}

fn view_spell_slot(
  slot: Option(spell.Spell),
  index: Int,
  is_active: Bool,
) -> Element(Msg) {
  let border_class = case is_active {
    True -> "border-yellow-400 border-2 shadow-lg shadow-yellow-400/50"
    False -> "border-gray-600 border"
  }

  let bg_class = case slot {
    option.Some(_) -> "bg-gray-800/90"
    option.None -> "bg-gray-900/60"
  }

  html.div(
    [
      class(
        "w-10 h-10 "
        <> border_class
        <> " "
        <> bg_class
        <> " rounded flex items-center justify-center relative",
      ),
    ],
    [
      case slot {
        option.None ->
          html.span([class("text-gray-600 text-xs")], [
            html.text(int.to_string(index + 1)),
          ])

        option.Some(s) -> {
          let name = spell.name(s)
          let short_name = get_short_name(name)
          let color_class = get_spell_color_class(s)

          html.div([class("flex flex-col items-center")], [
            html.span([class("text-xs font-bold " <> color_class)], [
              html.text(short_name),
            ]),
          ])
        }
      },
    ],
  )
}

// =============================================================================
// HELPERS
// =============================================================================

/// Get a short display name for a spell (first 3 chars or abbreviation)
fn get_short_name(name: String) -> String {
  case name {
    "Spark" -> "SPK"
    "Firebolt" -> "FIR"
    "Lightning Bolt" -> "LTN"
    "Double Spell" -> "x2"
    "Add Mana" -> "+M"
    "Add Damage" -> "+D"
    "Rapid Fire" -> "RPD"
    "Piercing" -> "PRC"
    "Orbiting Spell" -> "ORB"
    "Spark with Trigger" -> "S+T"
    "Add Trigger" -> "+T"
    _ -> string.slice(name, at_index: 0, length: 3)
  }
}

/// Get Tailwind color class based on spell type
fn get_spell_color_class(s: spell.Spell) -> String {
  case s {
    spell.DamageSpell(id: spell.Spark, ..) -> "text-yellow-300"
    spell.DamageSpell(id: spell.Fireball, ..) -> "text-orange-400"
    spell.DamageSpell(id: spell.LightningBolt, ..) -> "text-cyan-300"
    spell.DamageSpell(id: spell.SparkWithTrigger, ..) -> "text-amber-400"
    spell.DamageSpell(id: spell.OrbitingSpell, ..) -> "text-purple-400"
    spell.DamageSpell(..) -> "text-white"
    spell.ModifierSpell(..) -> "text-green-400"
    spell.MulticastSpell(..) -> "text-blue-400"
  }
}
