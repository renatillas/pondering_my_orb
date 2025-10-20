import gleam/float
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option
import tiramisu
import tiramisu/asset
import tiramisu/background
import tiramisu/camera
import tiramisu/debug
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/light
import tiramisu/material
import tiramisu/object3d
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3

pub type Id {
  Camera
  Boxes
  Ambient
  Directional
  FloorTiles
  Cube1
  Cube2
}

pub type Model {
  Model(
    assets: asset.AssetCache,
    ground: List(scene.Node(Id)),
    boxes: List(scene.Node(Id)),
  )
}

pub type Msg {
  Tick
  AssetsLoaded(assets: asset.BatchLoadResult)
}

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x1a1a2e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(_ctx: tiramisu.Context(Id)) -> #(Model, Effect(Msg), option.Option(_)) {
  let assets = [
    asset.FBXAsset("PSX_Dungeon/Models/Box.fbx", option.None),
    asset.FBXAsset(
      "PSX_Dungeon/Models/Floor_Tiles.fbx",
      option.Some("PSX_Dungeon/Textures/"),
    ),
    asset.TextureAsset("PSX_Dungeon/Textures/TEX_Ground_04.png"),
    asset.TextureAsset("PSX_Dungeon/Textures/TEX_Crate_01.png"),
  ]
  // Initialize physics world with gravity
  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: vec3.Vec3(0.0, -9.81, 0.0)))

  let effects =
    effect.batch([
      effect.from_promise(promise.map(
        asset.load_batch_simple(assets),
        AssetsLoaded,
      )),
      effect.tick(Tick),
      effect.from(fn(_) { debug.show_collider_wireframes(physics_world, True) }),
    ])

  #(
    Model(assets: asset.new_cache(), ground: [], boxes: []),
    effects,
    option.Some(physics_world),
  )
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), option.Option(_)) {
  echo debug.get_performance_stats()
  let assert option.Some(physics_world) = ctx.physics_world
  case msg {
    Tick -> {
      let new_physics_world = physics.step(physics_world)
      #(model, effect.tick(Tick), option.Some(new_physics_world))
    }
    AssetsLoaded(assets:) -> {
      update_model_with_assets(assets, ctx.physics_world)
    }
  }
}

fn update_model_with_assets(
  assets: asset.BatchLoadResult,
  physics_world: option.Option(physics.PhysicsWorld(Id)),
) -> #(Model, Effect(Msg), option.Option(physics.PhysicsWorld(Id))) {
  let assert Ok(floor_fbx) =
    asset.get_fbx(assets.cache, "PSX_Dungeon/Models/Floor_Tiles.fbx")
  let assert Ok(floor_texture) =
    asset.get_texture(assets.cache, "PSX_Dungeon/Textures/TEX_Ground_04.png")
  let assert Ok(box_fbx) =
    asset.get_fbx(assets.cache, "PSX_Dungeon/Models/Box.fbx")
  let assert Ok(box_texture) =
    asset.get_texture(assets.cache, "PSX_Dungeon/Textures/TEX_Crate_01.png")

  let boxes = render_boxes(box_fbx)
  let ground = render_ground(floor_fbx.scene)

  let effects =
    effect.batch([
      effect.from(fn(_) {
        asset.apply_texture_to_object(
          floor_fbx.scene,
          floor_texture,
          asset.NearestFilter,
        )
      }),
      effect.from(fn(_) {
        asset.apply_texture_to_object(
          box_fbx.scene,
          box_texture,
          asset.NearestFilter,
        )
      }),
    ])

  #(Model(assets: assets.cache, ground:, boxes:), effects, physics_world)
}

fn render_boxes(box_fbx: asset.FBXData) -> List(scene.Node(Id)) {
  let instances =
    list.map(list.range(0, 19), fn(_) {
      transform.identity
      |> transform.with_position(vec3.Vec3(
        float.random() *. 20.0 -. 10.0,
        0.5,
        float.random() *. 20.0 -. 10.0,
      ))
      |> transform.scale_by(vec3.Vec3(0.12, 0.12, 0.12))
    })
  let boxes = [
    scene.InstancedModel(
      id: Boxes,
      object: box_fbx.scene,
      instances: instances,
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
    ),
  ]
  boxes
}

fn view(model: Model, ctx: tiramisu.Context(Id)) -> List(scene.Node(Id)) {
  let assert option.Some(physics_world) = ctx.physics_world
  let assert Ok(cam) =
    camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  let assert Ok(cube_geom) = geometry.box(width: 1.0, height: 1.0, depth: 1.0)
  let assert Ok(cube1_mat) =
    material.new() |> material.with_color(0xff4444) |> material.build
  let assert Ok(cube2_mat) =
    material.new() |> material.with_color(0x44ff44) |> material.build

  list.flatten([
    model.ground,
    model.boxes,
    [
      scene.Camera(
        id: Camera,
        camera: cam,
        transform: transform.at(position: vec3.Vec3(0.0, 10.0, 15.0)),
        look_at: option.Some(vec3.Vec3(0.0, 0.0, 0.0)),
        active: True,
        viewport: option.None,
      ),
      scene.Light(
        id: Ambient,
        light: {
          let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
          light
        },
        transform: transform.identity,
      ),
      scene.Light(
        id: Directional,
        light: {
          let assert Ok(light) =
            light.directional(color: 0xffffff, intensity: 2.0)
          light
        },
        transform: transform.at(position: vec3.Vec3(5.0, 10.0, 7.5)),
      ),
      // Falling cube 1 (dynamic physics body)
      scene.Mesh(
        id: Cube1,
        geometry: cube_geom,
        material: cube1_mat,
        transform: case physics.get_transform(physics_world, Cube1) {
          Ok(t) -> t
          Error(Nil) -> transform.at(position: vec3.Vec3(-2.0, 5.0, 0.0))
        },
        physics: option.Some(
          physics.new_rigid_body(physics.Dynamic)
          |> physics.with_collider(physics.Box(
            transform.identity,
            1.0,
            1.0,
            1.0,
          ))
          |> physics.with_mass(1.0)
          |> physics.with_restitution(0.5)
          |> physics.with_friction(0.5)
          |> physics.build(),
        ),
      ),
      // Falling cube 2 (dynamic physics body)
      scene.Mesh(
        id: Cube2,
        geometry: cube_geom,
        material: cube2_mat,
        transform: case physics.get_transform(physics_world, Cube2) {
          Ok(t) -> t
          Error(Nil) -> transform.at(position: vec3.Vec3(2.0, 7.0, 0.0))
        },
        physics: option.Some(
          physics.new_rigid_body(physics.Dynamic)
          |> physics.with_collider(physics.Box(
            transform.identity,
            1.0,
            1.0,
            1.0,
          ))
          |> physics.with_mass(1.0)
          |> physics.with_restitution(0.6)
          |> physics.with_friction(0.3)
          |> physics.build(),
        ),
      ),
    ],
  ])
}

fn render_ground(floor_tile: object3d.Object3D) -> List(scene.Node(Id)) {
  // Generate transforms for a 100x100 grid
  let instances =
    list.flatten(
      list.map(list.range(0, 36), fn(x) {
        list.map(list.range(0, 36), fn(z) {
          transform.identity
          |> transform.with_position(vec3.Vec3(
            int.to_float(x) -. 18.0,
            0.0,
            int.to_float(z) -. 18.0,
          ))
          |> transform.with_scale(vec3.Vec3(0.05, 0.05, 0.05))
        })
      }),
    )

  [
    scene.InstancedModel(
      id: FloorTiles,
      object: floor_tile,
      instances: instances,
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
    ),
  ]
}
