import gleam/option
import tiramisu/object3d
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform

pub type Box

pub type Ground

pub opaque type Obstacle(kind) {
  Box(model: object3d.Object3D, instances: List(transform.Transform))
  Ground(model: object3d.Object3D, instances: List(transform.Transform))
}

pub fn box(
  model: object3d.Object3D,
  instances: List(transform.Transform),
) -> Obstacle(Box) {
  Box(model:, instances:)
}

pub fn ground(model: object3d.Object3D, instances: List(transform.Transform)) {
  Ground(model:, instances:)
}

pub fn render_box(box: Obstacle(Box), id: id) -> scene.Node(id) {
  scene.InstancedModel(
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
      |> physics.build(),
    ),
  )
}

pub fn render_ground(ground: Obstacle(Ground), id: id) -> scene.Node(id) {
  scene.InstancedModel(
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
