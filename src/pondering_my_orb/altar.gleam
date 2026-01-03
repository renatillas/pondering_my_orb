import gleam/int
import gleam/list
import gleam/option.{type Option}
import tiramisu
import tiramisu/effect
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec2.{Vec2}
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

import pondering_my_orb/id
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/wand

// =============================================================================
// TYPES
// =============================================================================

pub type Altar {
  Altar(id: id.Id, position: Vec3(Float), wand: wand.Wand)
}

pub type Model {
  Model(altars: List(Altar), next_altar_id: Int, player_pos: Vec3(Float))
}

pub type Msg {
  Tick
  UpdatePlayerPos(Vec3(Float))
  SpawnAltar(position: Vec3(Float))
  RemoveAltar(id.Id)
}

// =============================================================================
// CONSTANTS
// =============================================================================

/// Distance player must be within to pick up a wand from altar
const pickup_range = 3.0

/// Height offset for altar spawn (so it sits on ground)
const altar_y_offset = 0.5

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  let model =
    Model(altars: [], next_altar_id: 0, player_pos: Vec3(0.0, 0.0, 0.0))

  #(model, effect.dispatch(Tick))
}

// =============================================================================
// UPDATE
// =============================================================================

/// Update altars. Accepts taggers for cross-module dispatch.
pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  pick_up_wand pick_up_wand,
  effect_mapper effect_mapper,
) -> #(Model, effect.Effect(game_msg)) {
  case msg {
    Tick -> {
      // Check for wand pickup (E key)
      let pickup_effect = case input.is_key_just_pressed(ctx.input, input.KeyE) {
        True ->
          case get_nearest_altar(model) {
            option.Some(nearby) ->
              effect.batch([
                effect.dispatch(pick_up_wand(nearby.wand)),
                effect.dispatch(effect_mapper(RemoveAltar(nearby.id))),
              ])
            option.None -> effect.none()
          }
        False -> effect.none()
      }

      #(model, effect.batch([effect.dispatch(effect_mapper(Tick)), pickup_effect]))
    }

    UpdatePlayerPos(player_pos) -> {
      #(Model(..model, player_pos: player_pos), effect.none())
    }

    SpawnAltar(position) -> {
      let altar = create_altar(model.next_altar_id, position)
      #(
        Model(
          ..model,
          altars: [altar, ..model.altars],
          next_altar_id: model.next_altar_id + 1,
        ),
        effect.none(),
      )
    }

    RemoveAltar(altar_id) -> {
      let updated_altars =
        list.filter(model.altars, fn(altar) { altar.id != altar_id })
      #(Model(..model, altars: updated_altars), effect.none())
    }
  }
}

// =============================================================================
// ALTAR CREATION
// =============================================================================

/// Create a new altar with a random wand and random spells
fn create_altar(altar_num: Int, position: Vec3(Float)) -> Altar {
  let altar_id = id.Altar(altar_num)

  // Create a random wand with Noita-inspired stats
  let random_wand =
    wand.new_random("Found Wand #" <> int.to_string(altar_num))

  // Populate some slots with random spells
  let wand_with_spells = populate_wand_with_spells(random_wand)

  Altar(
    id: altar_id,
    position: Vec3(position.x, altar_y_offset, position.z),
    wand: wand_with_spells,
  )
}

/// Populate a wand with random spells
fn populate_wand_with_spells(w: wand.Wand) -> wand.Wand {
  // Add 1-3 random spells to the wand
  let spell_count = 1 + int.random(3)
  add_random_spells(w, spell_count, 0)
}

fn add_random_spells(w: wand.Wand, remaining: Int, slot_index: Int) -> wand.Wand {
  case remaining <= 0 {
    True -> w
    False -> {
      let spell = random_spell()
      case wand.set_spell(w, slot_index, spell) {
        Ok(new_wand) -> add_random_spells(new_wand, remaining - 1, slot_index + 1)
        Error(_) -> w
      }
    }
  }
}

fn random_spell() -> spell.Spell {
  let default_visuals =
    spell.SpellVisuals(
      projectile: spell.StaticSprite(
        texture_path: "spark.png",
        size: Vec2(1.0, 1.0),
      ),
      hit_effect: spell.NoEffect,
      base_tint: 0xFFFFFF,
      emissive_intensity: 1.0,
    )

  // Pick a random spell type (0-4)
  case int.random(5) {
    0 -> spell.spark(default_visuals)
    1 -> spell.fireball(default_visuals)
    2 -> spell.lightning(default_visuals)
    3 -> spell.add_damage()
    _ -> spell.rapid_fire()
  }
}

// =============================================================================
// HELPERS
// =============================================================================

/// Find the nearest altar within pickup range
/// Returns the altar and its distance if found
pub fn get_nearest_altar(model: Model) -> Option(Altar) {
  let player_pos = model.player_pos

  // Find all altars within range with their distances
  let altars_with_distance =
    list.filter_map(model.altars, fn(altar) {
      let distance = distance_xz(player_pos, altar.position)
      case distance <=. pickup_range {
        True -> Ok(#(altar, distance))
        False -> Error(Nil)
      }
    })

  // Find the nearest one
  case altars_with_distance {
    [] -> option.None
    [first, ..rest] -> {
      let #(nearest, _) =
        list.fold(rest, first, fn(closest, current) {
          let #(_, closest_dist) = closest
          let #(_, current_dist) = current
          case current_dist <. closest_dist {
            True -> current
            False -> closest
          }
        })
      option.Some(nearest)
    }
  }
}

/// Calculate horizontal distance (ignoring Y)
fn distance_xz(a: Vec3(Float), b: Vec3(Float)) -> Float {
  let diff = Vec3(a.x -. b.x, 0.0, a.z -. b.z)
  vec3f.length(diff)
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, _ctx: tiramisu.Context) -> List(scene.Node) {
  list.map(model.altars, fn(altar) { view_altar(altar) })
}

fn view_altar(altar: Altar) -> scene.Node {
  // Pedestal geometry - brown stone platform
  let assert Ok(pedestal_geo) = geometry.box(Vec3(1.5, 0.8, 1.5))

  // Brown stone color for the pedestal
  let assert Ok(pedestal_mat) =
    material.new()
    |> material.with_color(0x8B4513)
    |> material.build()

  // Glowing orb on top to indicate wand presence (using a small box instead of sphere)
  let assert Ok(orb_geo) = geometry.box(Vec3(0.6, 0.6, 0.6))

  // Golden glow
  let assert Ok(orb_mat) =
    material.new()
    |> material.with_color(0xFFD700)
    |> material.with_emissive(0xFFD700)
    |> material.with_emissive_intensity(1.5)
    |> material.build()

  let body_id = id.to_string(altar.id)

  // No physics body - just visual. Pickup is handled by distance check.
  let altar_transform = transform.at(position: altar.position)

  // Orb floating above the pedestal
  let orb_node =
    scene.mesh(
      id: body_id <> "_orb",
      geometry: orb_geo,
      material: orb_mat,
      transform: transform.at(position: Vec3(0.0, 0.8, 0.0)),
      physics: option.None,
    )

  // Pedestal with orb as child (no physics - player can walk through)
  scene.mesh(
    id: body_id,
    geometry: pedestal_geo,
    material: pedestal_mat,
    transform: altar_transform,
    physics: option.None,
  )
  |> scene.with_children([orb_node])
}
