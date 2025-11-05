import gleam/float
import gleam/int
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import pondering_my_orb/spell
import pondering_my_orb/ui/model

pub type Msg {
  AddSpellToBag(spell.Id)
  UpdateWandStat(model.WandStatUpdate)
  NoOp
}

pub fn view(
  wand_max_mana: Float,
  wand_mana_recharge_rate: Float,
  wand_cast_delay: Float,
  wand_recharge_time: Float,
  wand_capacity: Int,
  wand_spread: Float,
) -> element.Element(Msg) {
  html.div([], [
    html.h3([attribute.class("text-xl font-bold text-amber-300 mb-4")], [
      html.text("Add Spells to Bag"),
    ]),
    html.div([attribute.class("space-y-2 mb-6")], [
      debug_spell_button("Spark", spell.Spark),
      debug_spell_button("Fireball", spell.Fireball),
      debug_spell_button("Lightning Bolt", spell.LightningBolt),
      debug_spell_button("Double Spell", spell.DoubleSpell),
      debug_spell_button("Add Mana", spell.AddMana),
      debug_spell_button("Add Damage", spell.AddDamage),
      debug_spell_button("Piercing", spell.Piercing),
      debug_spell_button("Rapid Fire", spell.RapidFire),
      debug_spell_button("Orbitin Shards", spell.OrbitingSpell),
      debug_spell_button("Trigger spark", spell.SparkWithTrigger),
      debug_spell_button("Add trigger", spell.AddTrigger),
    ]),
    // Middle column - Current Wand Stats (Read-only)
    html.div([attribute.class("mt-6")], [
      html.h3([attribute.class("text-xl font-bold text-amber-300 mb-4")], [
        html.text("Current Wand Stats"),
      ]),
      html.div([attribute.class("space-y-3 bg-purple-950/40 p-4 rounded-lg")], [
        view_wand_stat_compact("Cast Delay", wand_cast_delay, "s"),
        view_wand_stat_compact("Recharge Time", wand_recharge_time, "s"),
        view_wand_stat_compact("Max Mana", wand_max_mana, ""),
        view_wand_stat_compact("Mana Recharge", wand_mana_recharge_rate, "/s"),
        html.div([attribute.class("flex justify-between text-sm")], [
          html.span([attribute.class("text-blue-200")], [
            html.text("Capacity:"),
          ]),
          html.span([attribute.class("text-white font-bold")], [
            html.text(int.to_string(wand_capacity)),
          ]),
        ]),
        view_wand_stat_compact("Spread", wand_spread, "°"),
      ]),
    ]),
    // Right column - Wand Stat Sliders (Editable)
    html.div([attribute.class("mt-6")], [
      html.h3([attribute.class("text-xl font-bold text-amber-300 mb-4")], [
        html.text("Edit Wand Stats"),
      ]),
      html.div([attribute.class("space-y-4")], [
        wand_stat_slider("Max Mana", wand_max_mana, 0.0, 1000.0, fn(val) {
          UpdateWandStat(model.SetMaxMana(val))
        }),
        wand_stat_slider(
          "Mana Recharge Rate",
          wand_mana_recharge_rate,
          0.0,
          1000.0,
          fn(val) { UpdateWandStat(model.SetManaRechargeRate(val)) },
        ),
        wand_stat_slider("Cast Delay", wand_cast_delay, 0.0, 1.0, fn(val) {
          UpdateWandStat(model.SetCastDelay(val))
        }),
        wand_stat_slider("Recharge Time", wand_recharge_time, 0.0, 5.0, fn(val) {
          UpdateWandStat(model.SetRechargeTime(val))
        }),
        wand_stat_slider("Spread", wand_spread, 0.0, 50.0, fn(val) {
          UpdateWandStat(model.SetSpread(val))
        }),
        wand_capacity_slider(
          "Capacity (Spell Slots)",
          wand_capacity,
          1,
          10,
          fn(val) { UpdateWandStat(model.SetCapacity(val)) },
        ),
      ]),
    ]),
  ])
}

fn debug_spell_button(name: String, spell_id: spell.Id) -> element.Element(Msg) {
  html.button(
    [
      attribute.class(
        "w-full px-4 py-2 bg-purple-700 hover:bg-purple-600 text-white rounded-lg transition-colors cursor-pointer",
      ),
      event.on_click(AddSpellToBag(spell_id)),
    ],
    [html.text(name)],
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

fn float_to_string_rounded(value: Float) -> String {
  float.to_string(float.to_precision(value, 2))
}

fn wand_stat_slider(
  label: String,
  current_value: Float,
  min: Float,
  max: Float,
  on_change: fn(Float) -> Msg,
) -> element.Element(Msg) {
  html.div([], [
    html.label([attribute.class("block text-gray-300 text-sm mb-1")], [
      html.text(label <> ": " <> float_to_string_rounded(current_value)),
    ]),
    html.input([
      attribute.type_("range"),
      attribute.attribute("min", float.to_string(min)),
      attribute.attribute("max", float.to_string(max)),
      attribute.attribute("step", "0.01"),
      attribute.attribute("value", float.to_string(current_value)),
      attribute.class("w-full cursor-pointer"),
      event.on_input(fn(value) {
        case float.parse(value) {
          Ok(val) -> on_change(val)
          Error(_) -> NoOp
        }
      }),
    ]),
  ])
}

fn wand_capacity_slider(
  label: String,
  current_value: Int,
  min: Int,
  max: Int,
  on_change: fn(Int) -> Msg,
) -> element.Element(Msg) {
  html.div([], [
    html.label([attribute.class("block text-gray-300 text-sm mb-1")], [
      html.text(label <> ": " <> int.to_string(current_value)),
    ]),
    html.input([
      attribute.type_("range"),
      attribute.attribute("min", int.to_string(min)),
      attribute.attribute("max", int.to_string(max)),
      attribute.attribute("step", "1"),
      attribute.attribute("value", int.to_string(current_value)),
      attribute.class("w-full cursor-pointer"),
      event.on_input(fn(value) {
        case int.parse(value) {
          Ok(val) -> on_change(val)
          Error(_) -> NoOp
        }
      }),
    ]),
  ])
}
