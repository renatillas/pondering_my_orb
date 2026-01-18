////
//// Wand UI component for the game UI.
////
//// Displays the active wand's spell slots with spell icons, mana costs,
//// and empty slots. Positioned at the bottom-center of the screen.
//// Styled with Tailwind CSS.
////

import client/bridge
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute.{alt, class, src, style}
import lustre/element.{type Element, text}
import lustre/element/html

// =============================================================================
// VIEW
// =============================================================================

/// Render the wand UI showing all spell slots for the active wand
///
/// ## Example
///
/// ```gleam
/// wand_ui.view(WandInfo(...))
/// ```
pub fn view(wand: bridge.WandInfo) -> Element(msg) {
  html.div(
    [
      class(
        "bg-gray-900 bg-opacity-90 backdrop-blur-sm rounded-lg p-3 border-2 border-gray-700 shadow-2xl",
      ),
    ],
    [
      // Wand stats row
      view_wand_stats(wand),
      // Spell slots row
      html.div(
        [class("flex gap-2 mt-2")],
        list.map(wand.spells, spell_slot_view),
      ),
    ],
  )
}

// =============================================================================
// SUBVIEWS
// =============================================================================

/// Display wand cooldown as a progress bar
fn view_wand_stats(wand: bridge.WandInfo) -> Element(msg) {
  let progress_width = float.to_string(wand.cooldown_progress) <> "%"

  // Choose color based on progress: red (cooling) -> yellow (almost ready) -> green (ready)
  let bar_color = case wand.cooldown_progress {
    p if p >=. 100.0 -> "bg-green-500"
    // Ready to fire
    p if p >=. 75.0 -> "bg-yellow-500"
    // Almost ready
    _ -> "bg-red-500"
    // Cooling down
  }

  html.div([class("w-full")], [
    // Progress bar container
    html.div(
      [
        class(
          "relative h-3 bg-gray-800 rounded-full overflow-hidden border border-gray-700",
        ),
      ],
      [
        // Progress fill (animates smoothly)
        html.div(
          [
            class("h-full " <> bar_color),
            style("width", progress_width),
          ],
          [],
        ),
        // Optional: Label showing percentage
        html.div(
          [
            class(
              "absolute inset-0 flex items-center justify-center text-xs font-bold text-white drop-shadow-md",
            ),
          ],
          [
            case wand.cooldown_progress {
              100.0 -> text("READY")
              p -> text(int.to_string(float.round(p)) <> "%")
            },
          ],
        ),
      ],
    ),
  ])
}

/// Render a single spell slot (filled or empty)
fn spell_slot_view(spell_opt: option.Option(bridge.SpellInfo)) -> Element(msg) {
  case spell_opt {
    option.Some(spell) -> filled_spell_slot(spell)
    option.None -> empty_spell_slot()
  }
}

/// Render a filled spell slot with icon and mana cost
fn filled_spell_slot(spell: bridge.SpellInfo) -> Element(msg) {
  html.div(
    [
      class(
        "relative w-16 h-16 bg-gray-800 rounded border-2 border-gray-600 hover:border-yellow-500 transition-colors cursor-pointer",
      ),
    ],
    [
      // Spell icon
      html.img([
        src(spell.icon_path),
        alt(spell.name),
        class("w-full h-full object-contain p-1"),
      ]),
      // Mana cost badge
      html.div(
        [
          class(
            "absolute -bottom-1 -right-1 bg-blue-600 text-white text-xs font-bold rounded-full w-6 h-6 flex items-center justify-center border-2 border-gray-900",
          ),
        ],
        [text(int.to_string(float.round(spell.mana_cost)))],
      ),
    ],
  )
}

/// Render an empty spell slot
fn empty_spell_slot() -> Element(msg) {
  html.div(
    [
      class(
        "w-16 h-16 bg-gray-800 bg-opacity-50 rounded border-2 border-gray-700 border-dashed",
      ),
    ],
    [],
  )
}
