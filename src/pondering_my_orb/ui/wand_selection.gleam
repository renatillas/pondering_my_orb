import gleam/float
import gleam/int
import gleam/list
import gleam/option
import iv
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import pondering_my_orb/spell
import pondering_my_orb/wand

pub type Msg {
  AcceptWand
  RejectWand
}

pub fn view(
  current_wand_slots: iv.Array(option.Option(spell.Spell)),
  current_max_mana: Float,
  current_mana_recharge_rate: Float,
  current_cast_delay: Float,
  current_recharge_time: Float,
  current_capacity: Int,
  current_spread: Float,
  new_wand: wand.Wand,
) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center z-50 bg-black bg-opacity-75 p-4 pointer-events-auto",
      ),
    ],
    [
      html.div(
        [
          attribute.class(
            "bg-gradient-to-br from-purple-900 to-blue-900 rounded-lg shadow-2xl max-w-5xl w-full p-8 border-4 border-yellow-400",
          ),
        ],
        [
          // Title
          html.h2(
            [
              attribute.class(
                "text-4xl font-bold text-center mb-6 text-yellow-300",
              ),
              attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.7)"),
            ],
            [html.text("🪄 New Wand Found!")],
          ),
          // Comparison container
          html.div([attribute.class("grid grid-cols-2 gap-8 mb-8")], [
            // Current wand
            view_wand_display(
              "Your Current Wand",
              current_wand_slots,
              current_max_mana,
              current_mana_recharge_rate,
              current_cast_delay,
              current_recharge_time,
              current_capacity,
              current_spread,
            ),
            // New wand
            view_wand_display(
              "New Wand",
              new_wand.slots,
              new_wand.max_mana,
              new_wand.mana_recharge_rate,
              new_wand.cast_delay,
              new_wand.recharge_time,
              iv.length(new_wand.slots),
              new_wand.spread,
            ),
          ]),
          // Buttons
          html.div([attribute.class("flex gap-4 justify-center")], [
            html.button(
              [
                attribute.class(
                  "px-8 py-3 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg text-xl transition-colors cursor-pointer",
                ),
                attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
                event.on_click(RejectWand),
              ],
              [html.text("Keep Current")],
            ),
            html.button(
              [
                attribute.class(
                  "px-8 py-3 bg-green-600 hover:bg-green-700 text-white font-bold rounded-lg text-xl transition-colors cursor-pointer",
                ),
                attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
                event.on_click(AcceptWand),
              ],
              [html.text("Take New Wand")],
            ),
          ]),
        ],
      ),
    ],
  )
}

fn view_wand_display(
  title: String,
  slots: iv.Array(option.Option(spell.Spell)),
  max_mana: Float,
  mana_recharge_rate: Float,
  cast_delay: Float,
  recharge_time: Float,
  capacity: Int,
  spread: Float,
) -> element.Element(msg) {
  html.div(
    [
      attribute.class(
        "bg-gray-800 bg-opacity-50 rounded-lg p-6 border-2 border-gray-600",
      ),
    ],
    [
      html.h3(
        [
          attribute.class("text-2xl font-bold mb-4 text-center text-blue-200"),
          attribute.style("text-shadow", "1px 1px 2px rgba(0,0,0,0.7)"),
        ],
        [html.text(title)],
      ),
      // Wand stats
      html.div([attribute.class("mb-4 space-y-2")], [
        view_wand_stat_compact("Max Mana", max_mana, ""),
        view_wand_stat_compact("Mana Regen", mana_recharge_rate, "/s"),
        view_wand_stat_compact("Cast Delay", cast_delay, "s"),
        view_wand_stat_compact("Recharge", recharge_time, "s"),
        view_wand_stat_compact("Capacity", int.to_float(capacity), ""),
        view_wand_stat_compact("Spread", spread, "°"),
      ]),
      // Spell slots
      html.div([attribute.class("space-y-2")], [
        html.div(
          [
            attribute.class(
              "text-sm font-semibold text-gray-300 mb-2 text-center",
            ),
          ],
          [html.text("Spells:")],
        ),
        html.div(
          [attribute.class("grid grid-cols-3 gap-2")],
          iv.to_list(slots)
            |> list.map(view_spell_slot),
        ),
      ]),
    ],
  )
}

fn view_wand_stat_compact(
  label: String,
  value: Float,
  unit: String,
) -> element.Element(msg) {
  html.div([attribute.class("flex justify-between")], [
    html.span([attribute.class("text-gray-300")], [html.text(label <> ":")]),
    html.span([attribute.class("font-bold")], [
      html.text(float.to_string(float.to_precision(value, 2)) <> " " <> unit),
    ]),
  ])
}

fn view_spell_slot(spell_opt: option.Option(spell.Spell)) -> element.Element(msg) {
  case spell_opt {
    option.Some(spell_value) -> {
      let #(sprite_path, name) = case spell_value {
        spell.DamageSpell(_, dmg_spell) -> #(
          dmg_spell.ui_sprite,
          dmg_spell.name,
        )
        spell.ModifierSpell(_, mod_spell) -> #(
          mod_spell.ui_sprite,
          mod_spell.name,
        )
        spell.MulticastSpell(_, multicast_spell) -> #(
          multicast_spell.ui_sprite,
          multicast_spell.name,
        )
      }

      html.div(
        [
          attribute.class(
            "bg-gray-700 rounded p-2 flex flex-col items-center justify-center hover:bg-gray-600 transition-colors",
          ),
          attribute.attribute("title", name),
        ],
        [
          html.img([
            attribute.src(sprite_path),
            attribute.class("w-12 h-12 pixelated"),
            attribute.alt(name),
          ]),
          html.div([attribute.class("text-xs text-center mt-1 text-gray-200")], [
            html.text(name),
          ]),
        ],
      )
    }
    option.None ->
      html.div(
        [
          attribute.class(
            "bg-gray-800 rounded p-2 h-20 flex items-center justify-center border-2 border-dashed border-gray-600",
          ),
        ],
        [
          html.span([attribute.class("text-gray-500 text-xs")], [
            html.text("Empty"),
          ]),
        ],
      )
  }
}
