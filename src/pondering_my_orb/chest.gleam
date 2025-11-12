import gleam/list
import gleam/option
import pondering_my_orb/id.{type Id}
import pondering_my_orb/perk.{type Perk}
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}

/// Represents a chest in the world that contains a perk
pub type Chest {
  Chest(id: Id, position: Vec3(Float), is_opened: Bool, perk: Perk)
}

/// Create a new chest at a position with a random perk
pub fn new(id: Id, position: Vec3(Float)) -> Chest {
  Chest(id:, position:, is_opened: False, perk: perk.random())
}

/// Create chests at fixed positions on the map
pub fn create_map_chests(start_id: Int) -> List(Chest) {
  // Define fixed chest positions around the map
  let positions = [
    Vec3(15.0, 0.5, 15.0),
    Vec3(-15.0, 0.5, 15.0),
    Vec3(15.0, 0.5, -15.0),
    Vec3(-15.0, 0.5, -15.0),
    Vec3(20.0, 0.5, 0.0),
    Vec3(-20.0, 0.5, 0.0),
    Vec3(0.0, 0.5, 20.0),
    Vec3(0.0, 0.5, -20.0),
  ]

  list.index_map(positions, fn(pos, idx) { new(id.chest(start_id + idx), pos) })
}

/// Mark a chest as opened
pub fn open(chest: Chest) -> Chest {
  Chest(..chest, is_opened: True)
}

/// Render a chest in the scene
pub fn render(chest: Chest) -> scene.Node(Id) {
  // Chest color: golden yellow when closed, dark gray when opened
  let color = case chest.is_opened {
    False -> 0xffd700
    // Gold
    True -> 0x4a4a4a
    // Dark gray
  }

  // Make chest a rectangular box (not a perfect cube)
  let assert Ok(box) = geometry.box(width: 1.0, height: 0.8, depth: 0.7)

  let assert Ok(material) =
    material.new() |> material.with_color(color) |> material.build()

  scene.mesh(
    id: chest.id,
    geometry: box,
    material:,
    transform: transform.at(position: chest.position),
    physics: option.None,
  )
}

/// Check if player is close enough to open a chest
pub fn can_open(
  chest: Chest,
  player_position: Vec3(Float),
  open_range: Float,
) -> Bool {
  case chest.is_opened {
    True -> False
    False -> {
      let dx = chest.position.x -. player_position.x
      let dy = chest.position.y -. player_position.y
      let dz = chest.position.z -. player_position.z
      let distance_squared = dx *. dx +. dy *. dy +. dz *. dz
      distance_squared <. open_range *. open_range
    }
  }
}
