import gleam/option
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

pub type Player {
  Player(
    max_health: Int,
    current_health: Int,
    speed: Float,
    player_position: vec3.Vec3(Float),
    player_rotation: vec3.Vec3(Float),
  )
}

pub fn new(
  health health: Int,
  speed speed: Float,
  player_position player_position: vec3.Vec3(Float),
  player_rotation player_rotation: vec3.Vec3(Float),
) {
  Player(
    max_health: health,
    current_health: health,
    speed:,
    player_position:,
    player_rotation:,
  )
}

pub fn render(id: id, player: Player) {
  let assert Ok(capsule) =
    geometry.cylinder(
      radius_top: 0.5,
      radius_bottom: 0.5,
      height: 2.0,
      radial_segments: 10,
    )
  let assert Ok(material) =
    material.new() |> material.with_color(0x00ff00) |> material.build()
  scene.Mesh(
    id:,
    geometry: capsule,
    material:,
    transform: transform.at(player.player_position)
      |> transform.with_rotation(player.player_rotation),
    physics: option.None,
  )
}

pub fn init() -> Player {
  new(
    health: 100,
    speed: 0.1,
    player_position: vec3.Vec3(0.0, 0.0, 0.0),
    player_rotation: vec3.Vec3(0.0, 0.0, 0.0),
  )
}

pub fn update(
  player: Player,
  position: vec3.Vec3(Float),
  rotation: vec3.Vec3(Float),
) -> Player {
  Player(..player, player_position: position, player_rotation: rotation)
}
