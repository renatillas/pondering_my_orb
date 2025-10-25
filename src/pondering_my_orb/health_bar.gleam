import gleam/int
import paint as p

/// Creates a health bar picture for enemies
///
/// The health bar shows current health as a filled portion of the bar:
/// - Green when health is above 70%
/// - Yellow when health is between 30-70%
/// - Red when health is below 30%
pub fn create(current_health: Int, max_health: Int) -> p.Picture {
  let bar_width = 100.0
  let bar_height = 10.0
  let border_width = 2.0

  // Calculate health percentage and bar fill width
  let health_percent = int_to_float(current_health) /. int_to_float(max_health)
  let fill_width = bar_width *. health_percent

  // Determine bar color based on health percentage
  let fill_color = case health_percent {
    h if h >. 0.7 -> p.colour_rgb(76, 175, 80)  // Green
    h if h >. 0.3 -> p.colour_rgb(255, 193, 7)  // Yellow
    _ -> p.colour_rgb(244, 67, 54)  // Red
  }

  p.combine([
    // Background (dark gray)
    p.rectangle(bar_width +. border_width *. 2.0, bar_height +. border_width *. 2.0)
      |> p.translate_xy(0.0, 0.0)
      |> p.fill(p.colour_rgb(50, 50, 50)),
    // Border (white)
    p.rectangle(bar_width +. border_width, bar_height +. border_width)
      |> p.translate_xy(border_width /. 2.0, border_width /. 2.0)
      |> p.fill(p.colour_rgb(255, 255, 255)),
    // Black background for health bar
    p.rectangle(bar_width, bar_height)
      |> p.translate_xy(border_width, border_width)
      |> p.fill(p.colour_rgb(0, 0, 0)),
    // Health fill
    p.rectangle(fill_width, bar_height)
      |> p.translate_xy(border_width, border_width)
      |> p.fill(fill_color),
  ])
}

fn int_to_float(i: Int) -> Float {
  // Convert int to float using Gleam's built-in conversion
  int.to_float(i)
}
