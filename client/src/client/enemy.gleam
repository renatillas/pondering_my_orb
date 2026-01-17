/// Enemy module - handles enemy rendering
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import tiramisu
import tiramisu/effect
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{Vec3}

import shared/enemy

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    enemies: dict.Dict(enemy.Id, enemy.Enemy),
    enemy_geometry: geometry.Geometry,
    enemy_material: material.Material,
  )
}

pub type Msg {
  Tick
  UpdateFromServer(dict.Dict(enemy.Id, enemy.Enemy))
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  // Create enemy rendering resources
  let assert Ok(enemy_geo) = geometry.box(Vec3(0.8, 1.8, 0.8))
  let assert Ok(enemy_mat) =
    material.new()
    |> material.with_color(0xFF0000)
    |> material.with_emissive(0xFF0000)
    |> material.with_emissive_intensity(0.8)
    |> material.build()

  let model =
    Model(
      enemies: dict.new(),
      enemy_geometry: enemy_geo,
      enemy_material: enemy_mat,
    )

  #(model, effect.dispatch(Tick))
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(
  model: Model,
  msg: Msg,
  _ctx: tiramisu.Context,
  effect_mapper: fn(Msg) -> game_msg,
) -> #(Model, effect.Effect(game_msg)) {
  case msg {
    Tick -> {
      #(model, effect.dispatch(effect_mapper(Tick)))
    }

    UpdateFromServer(enemies) -> {
      #(Model(..model, enemies: enemies), effect.none())
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, _ctx: tiramisu.Context) -> List(scene.Node) {
  dict.to_list(model.enemies)
  |> list.map(fn(entry) {
    let #(enemy_id, enemy_data) = entry
    let enemy.Id(eid) = enemy_id
    scene.mesh(
      id: "enemy_" <> int.to_string(eid),
      geometry: model.enemy_geometry,
      material: model.enemy_material,
      transform: transform.at(position: enemy_data.position),
      physics: option.None,
    )
  })
}
