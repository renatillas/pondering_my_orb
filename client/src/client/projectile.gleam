/// Projectile module - handles projectile rendering with client-side interpolation
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
import vec/vec2.{Vec2}
import vec/vec3.{type Vec3}

import shared/projectile
import shared/vec3 as shared_vec3

// =============================================================================
// TYPES
// =============================================================================

/// Client-side wrapper for projectiles with interpolated render position
pub type ClientProjectile {
  ClientProjectile(
    projectile: projectile.Projectile,
    render_position: Vec3(Float),
  )
}

pub type Model {
  Model(
    projectiles: dict.Dict(projectile.Id, ClientProjectile),
    projectile_geometry: geometry.Geometry,
    projectile_material: material.Material,
  )
}

pub type Msg {
  Tick
  UpdateFromServer(dict.Dict(projectile.Id, projectile.Projectile))
}

// =============================================================================
// CONSTANTS
// =============================================================================

// Projectiles move faster, so they need more aggressive interpolation
const projectile_lerp_factor = 0.35

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  // Create projectile rendering resources
  let assert Ok(projectile_geo) = geometry.sphere(0.3, Vec2(8, 6))
  let assert Ok(projectile_mat) =
    material.new()
    |> material.with_color(0xFF4400)
    |> material.with_emissive(0xFF4400)
    |> material.with_emissive_intensity(1.0)
    |> material.build()

  let model =
    Model(
      projectiles: dict.new(),
      projectile_geometry: projectile_geo,
      projectile_material: projectile_mat,
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
      // Interpolate projectile positions for smooth rendering
      let new_projectiles =
        dict.map_values(model.projectiles, fn(_, client_proj) {
          let new_render_pos =
            shared_vec3.lerp(
              client_proj.render_position,
              client_proj.projectile.position,
              projectile_lerp_factor,
            )
          ClientProjectile(..client_proj, render_position: new_render_pos)
        })

      #(
        Model(..model, projectiles: new_projectiles),
        effect.dispatch(effect_mapper(Tick)),
      )
    }

    UpdateFromServer(server_projectiles) -> {
      // Merge server updates with existing interpolated positions
      let updated_projectiles =
        dict.map_values(server_projectiles, fn(id, proj) {
          case dict.get(model.projectiles, id) {
            Ok(existing) ->
              // Keep existing render position for smooth interpolation
              ClientProjectile(
                projectile: proj,
                render_position: existing.render_position,
              )
            Error(_) ->
              // New projectile, start at server position
              ClientProjectile(projectile: proj, render_position: proj.position)
          }
        })

      #(Model(..model, projectiles: updated_projectiles), effect.none())
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, _ctx: tiramisu.Context) -> List(scene.Node) {
  dict.to_list(model.projectiles)
  |> list.map(fn(entry) {
    let #(proj_id, client_proj) = entry
    let projectile.Id(pid) = proj_id
    scene.mesh(
      id: "projectile_" <> int.to_string(pid),
      geometry: model.projectile_geometry,
      material: model.projectile_material,
      transform: transform.at(position: client_proj.render_position),
      physics: option.None,
    )
  })
}
