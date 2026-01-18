////
//// Mana bar component for the game UI.
////
//// Displays player mana as a horizontal bar with current/max values.
//// Styled with Tailwind CSS and blue gradient colors.
////

import gleam/float
import gleam/int
import lustre/attribute.{class, style}
import lustre/element.{type Element, text}
import lustre/element/html

// =============================================================================
// VIEW
// =============================================================================

/// Render a mana bar showing current and maximum mana
///
/// ## Example
///
/// ```gleam
/// mana_bar.view(50.0, 100.0)
/// ```
pub fn view(current: Float, max: Float) -> Element(msg) {
  let percentage = calculate_percentage(current, max)
  let current_rounded = float.round(current)
  let max_rounded = float.round(max)

  html.div([class("w-64")], [
    // Label with current/max values
    html.div(
      [
        class(
          "text-white text-sm font-bold mb-1 flex justify-between drop-shadow-lg",
        ),
      ],
      [
        html.span([], [text("Mana")]),
        html.span([], [
          text(
            int.to_string(current_rounded)
            <> " / "
            <> int.to_string(max_rounded),
          ),
        ]),
      ],
    ),
    // Bar container
    html.div(
      [
        class(
          "w-full h-6 bg-gray-800 bg-opacity-80 rounded-lg overflow-hidden border-2 border-gray-600 shadow-lg",
        ),
      ],
      [
        // Bar fill with gradient (blue colors for mana)
        html.div(
          [
            class(
              "h-full bg-gradient-to-r from-blue-600 to-blue-500 transition-all duration-300 ease-out",
            ),
            style("width", float.to_string(percentage) <> "%"),
          ],
          [],
        ),
      ],
    ),
  ])
}

// =============================================================================
// HELPERS
// =============================================================================

/// Calculate percentage of current/max, clamped to 0-100
fn calculate_percentage(current: Float, max: Float) -> Float {
  case max {
    0.0 -> 0.0
    _ -> {
      let raw_percentage = current /. max *. 100.0
      float.max(0.0, float.min(100.0, raw_percentage))
    }
  }
}
