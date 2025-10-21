import gleam/float
import gleam/int
import gleam/javascript/promise
import gleam/list
import gleam/option
import pondering_my_orb/map
import tiramisu
import tiramisu/asset
import tiramisu/background
import tiramisu/camera
import tiramisu/debug
import tiramisu/effect.{type Effect}
import tiramisu/light
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3

pub type Id {
  Camera
  Boxes
  Ambient
  Directional
  Ground
  Cube1
  Cube2
}

pub type Model {
  Model(
    ground: option.Option(map.Obstacle(map.Ground)),
    boxes: option.Option(map.Obstacle(map.Box)),
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
    Model(ground: option.None, boxes: option.None),
    effects,
    option.Some(physics_world),
  )
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), option.Option(_)) {
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

  let boxes =
    list.map(list.range(0, 19), fn(_) {
      transform.identity
      |> transform.with_position(vec3.Vec3(
        float.random() *. 20.0 -. 10.0,
        0.5,
        float.random() *. 20.0 -. 10.0,
      ))
      |> transform.scale_by(vec3.Vec3(0.12, 0.12, 0.12))
    })
    |> map.box(box_fbx.scene, _)
    |> option.Some

  let ground =
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
    |> map.ground(floor_fbx.scene, _)
    |> option.Some

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

  #(Model(ground:, boxes:), effects, physics_world)
}

fn view(model: Model, _ctx: tiramisu.Context(Id)) -> List(scene.Node(Id)) {
  let assert Ok(cam) =
    camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  let ground = case model.ground {
    option.Some(ground) -> map.render_ground(ground, Ground)
    option.None -> []
  }

  let boxes = case model.boxes {
    option.Some(boxes) -> map.render_box(boxes, Boxes)
    option.None -> []
  }

  list.flatten([
    ground,
    boxes,
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
    ],
  ])
}
