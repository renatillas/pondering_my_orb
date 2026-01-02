import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam_community/colour
import pondering_my_orb/game_physics/layer
import pondering_my_orb/id
import tiramisu/effect
import tiramisu/geometry
import tiramisu/light
import tiramisu/material
import tiramisu/model
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3

import pondering_my_orb/map/generator

// =============================================================================
// TYPES
// =============================================================================

pub type LoadState {
  Loading(loaded: Int, total: Int)
  Loaded
  Failed(String)
}

pub type Model {
  Model(
    load_state: LoadState,
    arena: generator.Arena,
    models: Dict(String, model.FBXData),
  )
}

pub type Msg {
  ModelLoaded(String, model.FBXData)
  LoadFailed
}

// =============================================================================
// CONSTANTS
// =============================================================================

const model_scale = 0.1

/// All models to load with their paths
fn model_paths() -> List(#(String, String)) {
  [
    // Floor
    #("floor", "medieval/Models/floor.fbx"),
    #("wall", "medieval/Models/wall-fortified.fbx"),
  ]
}

fn total_models() -> Int {
  list.length(model_paths())
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  let map_model =
    Model(
      load_state: Loading(loaded: 0, total: total_models()),
      arena: generator.create_arena(),
      models: dict.new(),
    )

  // Load all FBX models
  let load_effects =
    model_paths()
    |> list.map(fn(entry) {
      let #(key, path) = entry
      model.load_fbx(path, ModelLoaded(key, _), LoadFailed)
    })
    |> effect.batch

  #(map_model, load_effects)
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(map_model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    ModelLoaded(key, data) -> {
      let new_models = dict.insert(map_model.models, key, data)
      let new_loaded = dict.size(new_models)
      let new_state = case new_loaded >= total_models() {
        True -> Loaded
        False -> Loading(loaded: new_loaded, total: total_models())
      }
      #(
        Model(..map_model, models: new_models, load_state: new_state),
        effect.none(),
      )
    }
    LoadFailed -> {
      #(
        Model(..map_model, load_state: Failed("Failed to load models")),
        effect.none(),
      )
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(map_model: Model) -> List(scene.Node) {
  case map_model.load_state {
    Loading(loaded, total) -> [loading_indicator(loaded, total)]
    Failed(_error) -> [error_indicator()]
    Loaded -> render_arena(map_model)
  }
}

// =============================================================================
// LOADING INDICATORS
// =============================================================================

fn loading_indicator(loaded: Int, total: Int) -> scene.Node {
  let assert Ok(geo) = geometry.box(vec3.Vec3(1.0, 1.0, 1.0))
  let assert Ok(mat) =
    material.new()
    |> material.with_color(0x4ecdc4)
    |> material.build()

  let progress = int.to_float(loaded) /. int.to_float(total)

  scene.mesh(
    id: "loading-cube",
    geometry: geo,
    material: mat,
    transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0))
      |> transform.with_scale(vec3.Vec3(
        1.0 +. progress,
        1.0 +. progress,
        1.0 +. progress,
      )),
    physics: option.None,
  )
}

fn error_indicator() -> scene.Node {
  let assert Ok(geo) = geometry.box(vec3.Vec3(2.0, 2.0, 2.0))
  let assert Ok(mat) =
    material.new()
    |> material.with_color(0xff0000)
    |> material.build()

  scene.mesh(
    id: "error-cube",
    geometry: geo,
    material: mat,
    transform: transform.identity,
    physics: option.None,
  )
}

// =============================================================================
// ARENA RENDERING
// =============================================================================

fn render_arena(map_model: Model) -> List(scene.Node) {
  // Render all elements
  let element_nodes =
    map_model.arena.elements
    |> list.index_map(fn(element, index) {
      case element {
        generator.Floor(..) ->
          render_element("floor", id.Floor, map_model, element, index)
        generator.Wall(..) ->
          render_element("wall", id.Wall, map_model, element, index)
      }
    })
    |> list.filter_map(fn(x) { x })

  // Add lights
  let light_nodes = create_lights()

  list.flatten([light_nodes, element_nodes])
}

fn render_element(
  key: String,
  id_constructor,
  map_model: Model,
  element: generator.StructureElement,
  index: Int,
) -> Result(scene.Node, Nil) {
  case dict.get(map_model.models, key) {
    Error(Nil) -> Error(Nil)
    Ok(fbx) -> {
      // Create physics body for walls
      let physics_body = case id_constructor(index) {
        id.Wall(..) -> option.Some(create_wall_physics())
        _ -> option.None
      }

      Ok(scene.object_3d(
        id: id.to_string(id_constructor(index)),
        object: model.get_fbx_scene(fbx),
        transform: transform.at(position: element.position)
          |> transform.with_scale(vec3.Vec3(
            model_scale,
            model_scale,
            model_scale,
          ))
          |> transform.with_euler_rotation(vec3.Vec3(0.0, element.rotation, 0.0)),
        animation: option.None,
        physics: physics_body,
        material: option.None,
        transparent: False,
      ))
    }
  }
}

/// Create a physics body for wall elements
/// Layer 2 = Ground/Walls, collides with Player (0) and Enemies (1)
/// Zero friction to allow smooth sliding along walls
fn create_wall_physics() -> physics.RigidBody {
  physics.new_rigid_body(physics.Fixed)
  |> physics.with_collider(physics.Box(
    offset: transform.identity,
    size: vec3.Vec3(10.0, 10.0, 10.0),
  ))
  |> physics.with_collision_groups(membership: [layer.map], can_collide_with: [
    layer.player,
    layer.enemy,
  ])
  |> physics.with_friction(0.0)
  |> physics.build()
}

// =============================================================================
// ELEMENT TYPE MAPPING
// =============================================================================

// =============================================================================
// LIGHTING
// =============================================================================

fn create_lights() -> List(scene.Node) {
  // Ambient light - subtle base illumination
  let assert Ok(ambient_light) = light.ambient(color: 0xffffff, intensity: 0.2)
  let ambient =
    scene.light(
      id: "ambient",
      light: ambient_light,
      transform: transform.identity,
    )

  // Directional light - sun
  let assert Ok(dir_light) =
    light.directional(color: colour.white |> colour.to_rgb_hex, intensity: 1.5)
    |> result.map(light.with_shadows(_, True))
    |> result.try(light.with_shadow_resolution(_, 4096))
  let directional =
    scene.light(
      id: "sun",
      light: dir_light,
      transform: transform.at(position: vec3.Vec3(-30.0, 60.0, -30.0)),
    )

  // Hemisphere light for outdoor ambient
  let assert Ok(hemi_light) =
    light.hemisphere(
      intensity: 0.3,
      sky_color: 0x87ceeb,
      ground_color: 0x8b7355,
    )
  let hemisphere =
    scene.light(
      id: "hemisphere",
      light: hemi_light,
      transform: transform.identity,
    )

  [ambient, directional, hemisphere]
}
