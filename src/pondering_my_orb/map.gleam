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

  // Group instances by model and texture
  // For now, assuming all instances share the same model and texture
  // If you need different textures per instance, you'll need to group them
  case instances {
    [] -> scene.empty(id: base_id, transform: transform.identity, children: [])
    [first, ..] -> {
      let #(model, texture, _) = first

      // Extract just the transforms
      let transforms =
        list.map(instances, fn(inst) {
          let #(_, _, t) = inst
          t
        })

      // Create Lambert material with texture for fully matte foliage
      let assert Ok(foliage_material) =
        material.lambert(
          color: 0xffffff,
          map: option.Some(texture),
          normal_map: option.None,
          ambient_oclusion_map: option.None,
          transparent: True,
          opacity: 1.0,
          alpha_test: 0.5,
        )

      scene.instanced_model(
        id: base_id,
        object: model,
        instances: transforms,
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
        material: option.Some(foliage_material),
      )
    }
  }
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
