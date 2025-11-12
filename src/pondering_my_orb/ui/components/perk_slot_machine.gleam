import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import pondering_my_orb/perk
import pondering_my_orb/ui/model

/// Render the perk slot machine overlay
pub fn view(
  state: model.SlotMachineState,
  on_continue: msg,
) -> element.Element(msg) {
  let is_stopped = case state.animation_phase {
    model.Stopped -> True
    _ -> False
  }

  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center bg-black/85 pointer-events-auto",
      ),
      attribute.style("z-index", "500"),
    ],
    [
      html.div(
        [
          attribute.class(
            "bg-gradient-to-br from-indigo-950 to-purple-950 rounded-3xl p-10 shadow-2xl border-4 border-amber-400",
          ),
          attribute.style("min-width", "600px"),
          attribute.style("max-width", "700px"),
        ],
        [
          // Title
          html.div(
            [
              attribute.class(
                "text-center mb-8 text-4xl font-bold text-amber-400",
              ),
              attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.8)"),
            ],
            [html.text("⭐ PERK OBTAINED! ⭐")],
          ),
          // Slot machine reels
          view_reels(state),
          // Selected perk description (only show when stopped)
          case is_stopped {
            True -> view_perk_description(state.selected_perk)
            False -> html.div([], [])
          },
          // Continue button (only show when stopped)
          case is_stopped {
            True ->
              html.div([attribute.class("flex justify-center mt-8")], [
                html.button(
                  [
                    event.on_click(on_continue),
                    attribute.class(
                      "px-12 py-4 text-2xl font-bold rounded-xl bg-gradient-to-r from-amber-500 to-yellow-400 text-gray-900 cursor-pointer shadow-lg hover:scale-105 transition-transform",
                    ),
                  ],
                  [html.text("CONTINUE")],
                ),
              ])
            False -> html.div([], [])
          },
        ],
      ),
    ],
  )
}

/// Render the three slot machine reels
fn view_reels(state: model.SlotMachineState) -> element.Element(msg) {
  let reel1_stopped = case state.animation_phase {
    model.StoppingLeft
    | model.StoppingMiddle
    | model.StoppingRight
    | model.Stopped -> True
    _ -> False
  }

  let reel2_stopped = case state.animation_phase {
    model.StoppingMiddle | model.StoppingRight | model.Stopped -> True
    _ -> False
  }

  let reel3_stopped = case state.animation_phase {
    model.StoppingRight | model.Stopped -> True
    _ -> False
  }

  html.div([attribute.class("flex justify-around gap-5 my-8")], [
    view_reel(
      case reel1_stopped {
        True -> state.selected_perk
        False -> state.reel1
      },
      reel1_stopped,
    ),
    view_reel(
      case reel2_stopped {
        True -> state.selected_perk
        False -> state.reel2
      },
      reel2_stopped,
    ),
    view_reel(
      case reel3_stopped {
        True -> state.selected_perk
        False -> state.reel3
      },
      reel3_stopped,
    ),
  ])
}

/// Render a single slot machine reel
fn view_reel(perk_value: perk.Perk, is_stopped: Bool) -> element.Element(msg) {
  let info = perk.get_info(perk_value)

  let border_classes = case is_stopped {
    True -> "border-4 border-amber-400 shadow-amber-500/50"
    False -> "border-4 border-gray-600"
  }

  let scale_class = case is_stopped {
    True -> "scale-110"
    False -> "scale-100"
  }

  html.div(
    [
      attribute.class(
        "flex-1 bg-gradient-to-b from-gray-800 to-gray-900 rounded-2xl p-8 text-center "
        <> border_classes
        <> " "
        <> scale_class
        <> " transition-all duration-300 shadow-xl",
      ),
    ],
    [
      // Perk emoji/icon
      html.div([attribute.class("text-6xl mb-4")], [
        html.text(get_perk_emoji(perk_value)),
      ]),
      // Perk name
      html.div([attribute.class("text-xl font-bold text-white")], [
        html.text(info.name),
      ]),
    ],
  )
}

/// Render the description of the selected perk (shown when stopped)
fn view_perk_description(perk_value: perk.Perk) -> element.Element(msg) {
  let info = perk.get_info(perk_value)

  html.div(
    [
      attribute.class(
        "text-center p-6 bg-amber-400/10 rounded-xl border-2 border-amber-400 mt-6",
      ),
    ],
    [
      html.div([attribute.class("text-3xl font-bold text-amber-400 mb-3")], [
        html.text(get_perk_emoji(perk_value) <> " " <> info.name),
      ]),
      html.div([attribute.class("text-lg text-gray-300")], [
        html.text(info.description),
      ]),
    ],
  )
}

/// Get emoji icon for each perk type
fn get_perk_emoji(perk_value: perk.Perk) -> String {
  case perk_value {
    perk.BigBonk(..) -> "🎯"
    perk.Trance(..) -> "🧃"
    perk.OneLife -> "⏰"
    perk.BerserkersRage(_) -> "😤"
    perk.Execute(..) -> "⚔️"
    perk.GlassCannon(..) -> "💎"
  }
}
