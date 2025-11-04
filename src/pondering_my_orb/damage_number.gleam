import gleam/float
import gleam/int
import pondering_my_orb/id.{type Id}
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}

const damage_number_lifetime = 1.5

const damage_number_rise_speed = 2.0

/// Floating damage number that appears when dealing damage
pub type DamageNumber {
  DamageNumber(
    id: Id,
    damage: Float,
    position: Vec3(Float),
    time_alive: Float,
    is_critical: Bool,
  )
}

/// Create a new damage number
pub fn new(id: Id, damage: Float, position: Vec3(Float), is_critical: Bool) {
  DamageNumber(id:, damage:, position:, time_alive: 0.0, is_critical:)
}

/// Update damage number position and lifetime
pub fn update(number: DamageNumber, delta_time: Float) -> DamageNumber {
  let new_time = number.time_alive +. delta_time /. 1000.0

  // Rise upward over time
  let new_position =
    Vec3(
      number.position.x,
      number.position.y +. damage_number_rise_speed *. delta_time /. 1000.0,
      number.position.z,
    )

  DamageNumber(..number, time_alive: new_time, position: new_position)
}

/// Check if damage number should be removed
pub fn is_expired(number: DamageNumber) -> Bool {
  number.time_alive >=. damage_number_lifetime
}

/// Render damage number as a CSS2D label
pub fn render(
  number: DamageNumber,
  _camera_position: Vec3(Float),
) -> scene.Node(Id) {
  // Calculate fade out based on lifetime
  let life_ratio = number.time_alive /. damage_number_lifetime
  let opacity = 1.0 -. life_ratio

  // Scale up slightly at the start for impact
  let scale = case life_ratio {
    r if r <. 0.2 -> 1.0 +. { 1.0 -. r /. 0.2 } *. 0.5
    // Grow at start
    _ -> 1.0
  }

  // Format damage as text
  let damage_text = case number.damage {
    d if d >=. 10.0 -> int.to_string(float.round(d))
    d -> {
      let rounded = float.round(d *. 10.0)
      float.to_string(int.to_float(rounded) /. 10.0)
    }
  }

  // Font size and color depend on if it's a critical hit
  let #(font_size, color) = case number.is_critical {
    True -> #("5.0em", "#FF6600")
    // Orange for Big Bonk crits, much bigger!
    False -> #("2.5em", "#FFFFFF")
    // White for normal
  }

  // Create HTML with inline styles for the damage number
  // Using "Bangers" font from Google Fonts for impact
  let html = "<div style=\"
      font-family: 'Bangers', cursive;
      font-size: " <> font_size <> ";
      color: " <> color <> ";
      text-shadow:
        2px 2px 0 #000,
        -2px -2px 0 #000,
        2px -2px 0 #000,
        -2px 2px 0 #000,
        0 0 10px rgba(0,0,0,0.5);
      opacity: " <> float.to_string(opacity) <> ";
      transform: scale(" <> float.to_string(scale) <> ");
      pointer-events: none;
      user-select: none;
      white-space: nowrap;
    \">" <> damage_text <> "</div>"

  scene.css2d_label(
    id: number.id,
    html:,
    transform: transform.at(position: number.position),
  )
}
