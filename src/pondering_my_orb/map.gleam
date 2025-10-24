import gleam/option
import pondering_my_orb/id
import tiramisu/asset
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform

pub type Box

pub type Ground

pub opaque type Obstacle(kind) {
  Box(model: asset.Object3D, instances: List(transform.Transform))
  Ground(model: asset.Object3D, instances: List(transform.Transform))
}

pub fn box(
  model: asset.Object3D,
  instances: List(transform.Transform),
) -> Obstacle(Box) {
  Box(model:, instances:)
}

pub fn ground(model: asset.Object3D, instances: List(transform.Transform)) {
  Ground(model:, instances:)
}

pub fn view_box(box: Obstacle(Box), id: id.Id) -> scene.Node(id.Id) {
  scene.instanced_model(
    id:,
    object: box.model,
    instances: box.instances,
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.identity,
        width: 1.0,
        height: 1.0,
        depth: 1.0,
      ))
      |> physics.with_friction(0.0)
      |> physics.build(),
    ),
  )
}

pub fn view_ground(ground: Obstacle(Ground), id: id) -> scene.Node(id) {
  scene.instanced_model(
    id: id,
    object: ground.model,
    instances: ground.instances,
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.identity,
        width: 1.0,
        height: 0.25,
        depth: 1.0,
      ))
      |> physics.build(),
    ),
  )
}
