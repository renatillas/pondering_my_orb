import gleam/option
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform

pub type Enemy {
  Enemy(
    max_health: Int,
    current_health: Int,
    damage: Int,
    speed: Float,
    transform: transform.Transform,
  )
}

pub fn new(
  health health: Int,
  damage damage: Int,
  speed speed: Float,
  transform transform: transform.Transform,
) {
  Enemy(max_health: health, current_health: health, damage:, speed:, transform:)
}

pub fn render(enemy: Enemy, id: id) {
  let assert Ok(capsule) =
    geometry.cylinder(
      radius_top: 0.5,
      radius_bottom: 0.5,
      height: 2.0,
      radial_segments: 10,
    )
  let assert Ok(material) =
    material.new() |> material.with_color(0xff0000) |> material.build()
  scene.Mesh(
    id,
    geometry: capsule,
    material:,
    transform: enemy.transform,
    physics: option.Some(
      physics.new_rigid_body(physics.Dynamic)
      |> physics.with_collider(physics.Capsule(
        offset: transform.identity,
        half_height: 1.0,
        radius: 0.5,
      ))
      |> physics.with_lock_rotation_x()
      |> physics.with_lock_rotation_z()
      |> physics.build(),
    ),
  )
}

pub fn basic(transform: transform.Transform) {
  new(health: 10, damage: 10, speed: 10.0, transform:)
}
