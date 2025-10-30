import gleam/list
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
  Box(instances: List(#(asset.Object3D, asset.Texture, Transform)))
  Ground(model: asset.Object3D, instances: List(Transform))
}

pub fn box(
  instances: List(#(asset.Object3D, asset.Texture, Transform)),
) -> Obstacle(Box) {
  Box(instances:)
}

pub fn ground(
  model: asset.Object3D,
  instances: List(Transform),
) -> Obstacle(Ground) {
  Ground(model:, instances:)
}

pub fn view_foliage(obstacles: Obstacle(Box), base_id: Id) -> scene.Node(Id) {
  let assert Box(instances:) = obstacles

  let children =
    instances
    |> list.index_map(fn(instance, i) {
      let #(model, texture, instance_transform) = instance

      // Create material override with texture for this specific instance
      let foliage_material_override =
        material.MaterialOverride(
          map: option.Some(texture),
          transparent: option.Some(True),
          alpha_test: option.Some(0.5),
          side: option.Some(material.DoubleSide),
          roughness: option.Some(1.0),
          metalness: option.Some(0.0),
        )

      scene.model_3d(
        id: id.foliage(i),
        object: model,
        animation: option.None,
        physics: option.Some(
          physics.new_rigid_body(physics.Fixed)
          |> physics.with_collider(physics.Cylinder(
            offset: transform.identity,
            half_height: 0.3,
            radius: 0.2,
          ))
          |> physics.with_friction(0.0)
          |> physics.build(),
        ),
        material_override: option.Some(foliage_material_override),
        transform: instance_transform,
      )
    })

  scene.empty(id: base_id, transform: transform.identity, children:)
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
