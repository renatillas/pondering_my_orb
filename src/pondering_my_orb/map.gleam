import gleam/option
import pondering_my_orb/id.{type Id}
import tiramisu/asset
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform.{type Transform}
import vec/vec3

pub type Box

pub type Ground

pub opaque type Obstacle(kind) {
  Box(model: asset.Object3D, instances: List(Transform))
  Ground(model: asset.Object3D, instances: List(Transform))
}

pub fn box(model: asset.Object3D, instances: List(Transform)) -> Obstacle(Box) {
  Box(model:, instances:)
}

pub fn ground(
  model: asset.Object3D,
  instances: List(Transform),
) -> Obstacle(Ground) {
  Ground(model:, instances:)
}

pub fn view_box(box: Obstacle(Box), id: Id) -> scene.Node(Id) {
  scene.instanced_model(
    id:,
    object: box.model,
    instances: box.instances,
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.identity,
        width: 8.0,
        height: 8.0,
        depth: 8.0,
      ))
      |> physics.with_friction(0.0)
      |> physics.build(),
    ),
  )
}

pub fn view_ground(_ground: Obstacle(Ground), id: id) -> scene.Node(id) {
  let assert Ok(geometry) = geometry.plane(100.0, 100.0)
  let assert Ok(material) =
    material.new() |> material.with_color(0xaaaaaa) |> material.build()
  scene.mesh(
    id: id,
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.at(vec3.Vec3(0.0, 0.0, -0.25))
          |> transform.with_euler_rotation(vec3.Vec3(1.57, 0.0, 0.0)),
        width: 100.0,
        height: 0.5,
        depth: 100.0,
      ))
      |> physics.build(),
    ),
    geometry:,
    material:,
    transform: transform.identity
      |> transform.with_euler_rotation(vec3.Vec3(-1.56, 0.0, 0.0)),
  )
}
