import gleam/int
import gleam/list
import pondering_my_orb/id
import vec/vec2.{type Vec2, Vec2}
import vec/vec3.{type Vec3, Vec3}

// =============================================================================
// ELEMENT TYPES
// =============================================================================

pub type StructureElement {
  Floor(position: Vec3(Float), rotation: Float)
  Wall(position: Vec3(Float), rotation: Float)
}

pub type Arena {
  Arena(elements: List(StructureElement))
}

// =============================================================================
// CONSTANTS
// =============================================================================

const pi = 3.1416

const half_pi = 1.5708

const tile_size = 10.0

// =============================================================================
// ARENA BUILDER
// =============================================================================

/// Create a fortified arena
pub fn create_arena() -> Arena {
  let elements =
    list.flatten([
      // 16x16 floor centered at origin
      floor(Vec2(16, 16), Vec3(0.0, 0.0, 0.0)),
      wall(16, Vec3(-75.0, 0.0, -85.0), pi),
      wall(16, Vec3(-75.0, 0.0, 85.0), 0.0),
      wall(16, Vec3(-85.0, 0.0, -75.0), 0.0 -. half_pi),
      wall(16, Vec3(85.0, 0.0, -75.0), half_pi),
    ])

  Arena(elements:)
}

// =============================================================================
// ELEMENT GENERATORS
// =============================================================================

/// Generate a grid of floor tiles
/// size: number of tiles in x and z directions
/// position: center position of the floor grid
pub fn floor(size: Vec2(Int), position: Vec3(Float)) -> List(StructureElement) {
  let half_width = { int.to_float(size.x) *. tile_size } /. 2.0
  let half_depth = { int.to_float(size.y) *. tile_size } /. 2.0

  list.range(0, size.y - 1)
  |> list.flat_map(fn(z) {
    list.range(0, size.x - 1)
    |> list.map(fn(x) {
      let tile_x =
        position.x
        -. half_width
        +. { int.to_float(x) *. tile_size }
        +. { tile_size /. 2.0 }
      let tile_z =
        position.z
        -. half_depth
        +. { int.to_float(z) *. tile_size }
        +. { tile_size /. 2.0 }

      Floor(position: Vec3(tile_x, position.y, tile_z), rotation: 0.0)
    })
  })
}

/// Generate a line of wall segments
/// length: number of wall segments
/// position: starting position (first segment)
/// rotation: wall rotation (determines direction of wall line)
pub fn wall(
  length: Int,
  position: Vec3(Float),
  rotation: Float,
) -> List(StructureElement) {
  let vec2.Vec2(dx, dz) = direction_from_rotation(rotation)

  list.range(0, length - 1)
  |> list.map(fn(i) {
    let offset = int.to_float(i) *. tile_size
    Wall(
      position: Vec3(
        position.x +. dx *. offset,
        position.y,
        position.z +. dz *. offset,
      ),
      rotation: rotation,
    )
  })
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/// Get direction vector from rotation angle
/// Returns (dx, dz) unit vector for placing consecutive elements
fn direction_from_rotation(rotation: Float) -> vec2.Vec2(Float) {
  case rotation {
    // Facing south (pi) -> elements extend east (+x)
    r if r >. 3.0 && r <. 3.5 -> Vec2(1.0, 0.0)
    // Facing north (0) -> elements extend east (+x)
    r if r >. -0.5 && r <. 0.5 -> Vec2(1.0, 0.0)
    // Facing east (half_pi) -> elements extend south (+z)
    r if r >. 1.0 && r <. 2.0 -> Vec2(0.0, 1.0)
    // Facing west (-half_pi) -> elements extend south (+z)
    r if r <. -1.0 && r >. -2.0 -> Vec2(0.0, 1.0)
    // Default: extend east
    _ -> Vec2(1.0, 0.0)
  }
}

/// Get the rendering layer for proper depth ordering
pub fn get_render_layer(element: id.Id) -> Int {
  case element {
    id.Floor(_) -> 0
    id.Wall(_) -> 2
    _ -> -1
  }
}
