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
import tiramisu/ui as tiramisu_ui

pub type Model {
  Model(
    player_health: Int,
    player_max_health: Int,
    player_mana: Float,
    player_max_mana: Float,
    wand_slots: iv.Array(option.Option(spell.Spell)),
  )
}

pub type Msg {
  GameStateUpdated(GameState)
}

pub type GameState {
  GameState(
    player_health: Int,
    player_max_health: Int,
    player_mana: Float,
    player_max_mana: Float,
    wand_slots: iv.Array(option.Option(spell.Spell)),
  )
}

pub fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(
      player_health: 100,
      player_max_health: 100,
      player_mana: 100.0,
      player_max_mana: 100.0,
      wand_slots: iv.new(),
    ),
    tiramisu_ui.register_lustre(),
  )
}

pub fn update(_model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    GameStateUpdated(state) -> #(
      Model(
        player_health: state.player_health,
        player_max_health: state.player_max_health,
        player_mana: state.player_mana,
        player_max_mana: state.player_max_mana,
        wand_slots: state.wand_slots,
      ),
      effect.none(),
    )
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
      // Top left corner - Player stats
      html.div(
        [
          attribute.class(
            "absolute top-4 left-4 p-4 bg-gradient-to-br from-purple-900/90 to-indigo-900/90 border-4 border-amber-400 rounded-lg shadow-2xl",
          ),
          attribute.style("image-rendering", "pixelated"),
          attribute.style("backdrop-filter", "blur(4px)"),
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
                int.to_string(model.player_health)
                <> " / "
                <> int.to_string(model.player_max_health),
              ),
            ]),
            render_pixel_bar(
              current: int.to_float(model.player_health),
              max: int.to_float(model.player_max_health),
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
            render_wand_slots(model.wand_slots),
          ]),
        ],
      ),
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

fn health_color_class(current: Int, max: Int) -> String {
  let percentage = current * 100 / max
  case percentage {
    p if p >= 75 -> "bg-green-500"
    p if p >= 50 -> "bg-lime-500"
    p if p >= 25 -> "bg-orange-500"
    _ -> "bg-red-500"
  }
}

fn render_wand_slots(
  slots: iv.Array(option.Option(spell.Spell)),
) -> element.Element(Msg) {
  let slot_elements =
    slots
    |> iv.to_list()
    |> list.map(render_spell_slot)

  html.div([attribute.class("flex gap-2")], slot_elements)
}

fn render_spell_slot(slot: option.Option(spell.Spell)) -> element.Element(Msg) {
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
        <> " shadow-lg relative transition-all hover:scale-110",
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
