import ensaimada
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/time/duration
import iv
import tiramisu
import tiramisu/effect
import tiramisu/geometry
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec2.{type Vec2}
import vec/vec3.{type Vec3, Vec3}

import client/magic_system/spell
import client/magic_system/spell_bag
import client/magic_system/wand
import shared/id
import shared/projectile

// =============================================================================
// TYPES
// =============================================================================

/// Per-wand state tracking cooldowns and cast index
pub type WandState {
  WandState(cast_cooldown: duration.Duration, wand_cast_index: Int)
}

pub type Model {
  Model(
    // 4 wand slots (like Noita)
    wands: iv.Array(Option(wand.Wand)),
    active_wand_index: Int,
    wand_states: iv.Array(WandState),
    // Server-authoritative projectiles (from network)
    projectiles: List(projectile.Projectile),
    spell_bag: spell_bag.SpellBag,
    selected_spell_slot: Option(Int),
    // Player state needed for casting
    player_pos: Vec3(Float),
    zoom: Float,
  )
}

pub type Msg {
  Tick
  UpdatePlayerState(player_pos: Vec3(Float), zoom: Float)
  PlaceSpellInSlot(spell_id: spell.Id, slot_index: Int)
  SelectSlot(Int)
  ReorderWandSlots(from_index: Int, to_index: Int)
  // Server-authoritative projectile messages (from network)
  SetProjectiles(List(projectile.Projectile))
  AddProjectiles(List(projectile.Projectile))
  RemoveProjectiles(List(Int))
  // Wand switching
  SwitchWand(wand_index: Int)
  SwitchWandRelative(delta: Int)
  // Pick up wand from altar
  PickUpWand(wand.Wand)
  // Remove spell from wand slot (move to spell bag)
  RemoveSpellFromSlot(slot_index: Int)
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  // Create starter wand with 4 slots and a spark in slot 0
  let starter_wand =
    wand.new(
      name: "Starter Wand",
      slot_count: 4,
      max_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: duration.milliseconds(150),
      recharge_time: duration.milliseconds(330),
      spells_per_cast: 1,
      spread: 0.0,
    )
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 0, spell.spark())

  // 4 wand slots - only first slot has the starter wand
  let wands =
    iv.from_list([
      option.Some(starter_wand),
      option.None,
      option.None,
      option.None,
    ])

  // Per-wand state (cooldown and cast index for each slot)
  let initial_wand_state =
    WandState(cast_cooldown: duration.milliseconds(0), wand_cast_index: 0)
  let wand_states = iv.repeat(initial_wand_state, 4)

  // Start with an empty spell bag
  let initial_spell_bag = spell_bag.new()

  let model =
    Model(
      wands: wands,
      active_wand_index: 0,
      wand_states: wand_states,
      projectiles: [],
      spell_bag: initial_spell_bag,
      selected_spell_slot: option.None,
      player_pos: Vec3(0.0, 1.0, 0.0),
      zoom: 30.0,
    )

  #(model, effect.dispatch(Tick))
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg)) {
  case msg {
    Tick -> {
      let new_model = tick(model, ctx)
      #(new_model, effect.dispatch(Tick))
    }

    UpdatePlayerState(player_pos, zoom) -> {
      #(Model(..model, player_pos: player_pos, zoom: zoom), effect.none())
    }

    PlaceSpellInSlot(spell_id, slot_index) -> {
      // Find the spell in the spell bag by id
      let maybe_spell =
        spell_bag.list_spells(model.spell_bag)
        |> list.find(fn(s) { s.id == spell_id })

      case maybe_spell, get_active_wand(model) {
        Ok(spell_to_place), option.Some(active_wand) -> {
          // Get existing spell in wand slot (if any)
          let existing_spell = case wand.get_spell(active_wand, slot_index) {
            Ok(option.Some(spell)) -> option.Some(spell)
            _ -> option.None
          }

          // Remove the spell from bag
          let updated_bag =
            spell_bag.remove_spell(model.spell_bag, spell_to_place)

          // Add the spell to wand slot
          case
            iv.set(
              active_wand.slots,
              at: slot_index,
              to: option.Some(spell_to_place),
            )
          {
            Ok(new_slots) -> {
              let new_wand = wand.Wand(..active_wand, slots: new_slots)

              // If there was an existing spell in the slot, add it back to bag
              let final_bag = case existing_spell {
                option.Some(old_spell) ->
                  spell_bag.add_spell(updated_bag, old_spell)
                option.None -> updated_bag
              }

              // Update the wand in the wands array
              case
                iv.set(
                  model.wands,
                  at: model.active_wand_index,
                  to: option.Some(new_wand),
                )
              {
                Ok(new_wands) -> {
                  let new_model =
                    Model(..model, wands: new_wands, spell_bag: final_bag)
                  #(new_model, effect.none())
                }
                Error(_) -> #(model, effect.none())
              }
            }
            Error(_) -> #(model, effect.none())
          }
        }
        _, _ -> #(model, effect.none())
      }
    }

    SelectSlot(slot_index) -> {
      let new_model =
        Model(..model, selected_spell_slot: option.Some(slot_index))
      #(new_model, effect.none())
    }

    ReorderWandSlots(from_index, to_index) -> {
      case get_active_wand(model) {
        option.Some(active_wand) -> {
          let slots_list = iv.to_list(active_wand.slots)
          let reordered = ensaimada.reorder(slots_list, from_index, to_index)
          let new_slots = iv.from_list(reordered)
          let new_wand = wand.Wand(..active_wand, slots: new_slots)
          case
            iv.set(
              model.wands,
              at: model.active_wand_index,
              to: option.Some(new_wand),
            )
          {
            Ok(new_wands) -> {
              let new_model = Model(..model, wands: new_wands)
              #(new_model, effect.none())
            }
            Error(_) -> #(model, effect.none())
          }
        }
        option.None -> #(model, effect.none())
      }
    }

    // Server-authoritative projectile messages
    SetProjectiles(projectiles) -> {
      // Debug logging
      let _ =
        io.println(
          "[Magic] SetProjectiles: " <> int.to_string(list.length(projectiles)),
        )
      #(Model(..model, projectiles: projectiles), effect.none())
    }

    AddProjectiles(new_projectiles) -> {
      // Debug logging
      let _ =
        io.println(
          "[Magic] AddProjectiles: "
          <> int.to_string(list.length(new_projectiles))
          <> " (total: "
          <> int.to_string(
            list.length(model.projectiles) + list.length(new_projectiles),
          )
          <> ")",
        )
      let updated_projectiles = list.append(model.projectiles, new_projectiles)
      #(Model(..model, projectiles: updated_projectiles), effect.none())
    }

    RemoveProjectiles(projectile_ids) -> {
      // Debug logging
      let _ =
        io.println(
          "[Magic] RemoveProjectiles: "
          <> int.to_string(list.length(projectile_ids)),
        )
      let updated_projectiles =
        list.filter(model.projectiles, fn(p) {
          !list.contains(projectile_ids, p.id)
        })
      #(Model(..model, projectiles: updated_projectiles), effect.none())
    }

    SwitchWand(wand_index) -> {
      case wand_index >= 0 && wand_index <= 3 {
        True -> #(Model(..model, active_wand_index: wand_index), effect.none())
        False -> #(model, effect.none())
      }
    }

    SwitchWandRelative(delta) -> {
      // Wrap around: 0->3->0 or 3->0->3
      let new_index = { model.active_wand_index + delta + 4 } % 4
      #(Model(..model, active_wand_index: new_index), effect.none())
    }

    PickUpWand(new_wand) -> {
      // Find first empty slot, or replace current wand if all slots full
      let slot_to_use =
        find_empty_wand_slot(model.wands)
        |> option.unwrap(model.active_wand_index)

      case iv.set(model.wands, at: slot_to_use, to: option.Some(new_wand)) {
        Ok(new_wands) -> #(
          Model(..model, wands: new_wands, active_wand_index: slot_to_use),
          effect.none(),
        )
        Error(_) -> #(model, effect.none())
      }
    }

    RemoveSpellFromSlot(slot_index) -> {
      case get_active_wand(model) {
        option.Some(active_wand) -> {
          case wand.get_spell(active_wand, slot_index) {
            Ok(option.Some(spell_to_remove)) -> {
              // Remove spell from wand slot (set to None)
              case iv.set(active_wand.slots, at: slot_index, to: option.None) {
                Ok(new_slots) -> {
                  let new_wand = wand.Wand(..active_wand, slots: new_slots)

                  // Add spell back to spell bag
                  let updated_bag =
                    spell_bag.add_spell(model.spell_bag, spell_to_remove)

                  // Update wand in wands array
                  case
                    iv.set(
                      model.wands,
                      at: model.active_wand_index,
                      to: option.Some(new_wand),
                    )
                  {
                    Ok(new_wands) -> #(
                      Model(..model, wands: new_wands, spell_bag: updated_bag),
                      effect.none(),
                    )
                    Error(_) -> #(model, effect.none())
                  }
                }
                Error(_) -> #(model, effect.none())
              }
            }
            _ -> #(model, effect.none())
          }
        }
        option.None -> #(model, effect.none())
      }
    }
  }
}

// =============================================================================
// TICK
// =============================================================================

/// Called every frame to update magic state
fn tick(model: Model, ctx: tiramisu.Context) -> Model {
  let dt = ctx.delta_time

  // Recharge mana for all wands
  let new_wands = recharge_all_wands(model.wands, dt)

  let new_wand_states = reduce_all_cooldowns(model.wand_states, dt)

  Model(..model, wands: new_wands, wand_states: new_wand_states)
}

fn reduce_cooldown(
  cooldown: duration.Duration,
  delta_time: duration.Duration,
) -> duration.Duration {
  let cooldown_secs = duration.to_seconds(cooldown)
  let delta_secs = duration.to_seconds(delta_time)
  let remaining_secs = cooldown_secs -. delta_secs

  case remaining_secs >. 0.0 {
    True -> {
      let remaining_ms = float.round(remaining_secs *. 1000.0)
      duration.milliseconds(remaining_ms)
    }
    False -> duration.milliseconds(0)
  }
}

// =============================================================================
// WAND HELPERS
// =============================================================================

/// Get the currently active wand (if any)
pub fn get_active_wand(model: Model) -> Option(wand.Wand) {
  case iv.get(model.wands, model.active_wand_index) {
    Ok(wand_opt) -> wand_opt
    Error(_) -> option.None
  }
}

/// Get the wand cast index for the active wand (for UI display)
/// Returns the index of the next spell that will actually be cast,
/// not just the raw cast index (which might point to an empty slot)
pub fn get_wand_cast_index(model: Model) -> Int {
  case
    iv.get(model.wand_states, model.active_wand_index),
    get_active_wand(model)
  {
    Ok(state), option.Some(active_wand) ->
      find_next_spell_index(active_wand.slots, state.wand_cast_index)
    _, _ -> 0
  }
}

/// Find the index of the next non-empty spell slot starting from start_index
/// Wraps around if needed
fn find_next_spell_index(
  slots: iv.Array(option.Option(spell.Spell)),
  start_index: Int,
) -> Int {
  let slot_count = iv.size(slots)
  find_next_spell_loop(slots, start_index, slot_count, 0)
}

fn find_next_spell_loop(
  slots: iv.Array(option.Option(spell.Spell)),
  current_index: Int,
  slot_count: Int,
  iterations: Int,
) -> Int {
  // Prevent infinite loop - if we've checked all slots, return 0
  case iterations >= slot_count {
    True -> 0
    False -> {
      let wrapped_index = current_index % slot_count
      case iv.get(slots, wrapped_index) {
        Ok(option.Some(_)) -> wrapped_index
        _ ->
          find_next_spell_loop(
            slots,
            current_index + 1,
            slot_count,
            iterations + 1,
          )
      }
    }
  }
}

/// Get the state for the active wand
pub fn get_active_wand_state(model: Model) -> WandState {
  case iv.get(model.wand_states, model.active_wand_index) {
    Ok(state) -> state
    Error(_) ->
      WandState(cast_cooldown: duration.milliseconds(0), wand_cast_index: 0)
  }
}

/// Check if wand can cast (cooldown is zero)
pub fn can_cast(model: Model) -> Bool {
  let state = get_active_wand_state(model)
  duration.to_seconds(state.cast_cooldown) <=. 0.0
}

/// Find the first empty wand slot (returns index)
fn find_empty_wand_slot(wands: iv.Array(Option(wand.Wand))) -> Option(Int) {
  find_empty_slot_loop(wands, 0)
}

fn find_empty_slot_loop(
  wands: iv.Array(Option(wand.Wand)),
  index: Int,
) -> Option(Int) {
  case iv.get(wands, index) {
    Ok(option.None) -> option.Some(index)
    Ok(option.Some(_)) -> find_empty_slot_loop(wands, index + 1)
    Error(_) -> option.None
  }
}

/// Recharge mana for all wands
fn recharge_all_wands(
  wands: iv.Array(Option(wand.Wand)),
  dt: duration.Duration,
) -> iv.Array(Option(wand.Wand)) {
  iv.index_map(wands, fn(wand_opt, _index) {
    case wand_opt {
      option.Some(w) -> option.Some(wand.recharge_mana(w, dt))
      option.None -> option.None
    }
  })
}

/// Reduce cooldowns for all wand states
fn reduce_all_cooldowns(
  wand_states: iv.Array(WandState),
  dt: duration.Duration,
) -> iv.Array(WandState) {
  iv.index_map(wand_states, fn(state, _index) {
    WandState(..state, cast_cooldown: reduce_cooldown(state.cast_cooldown, dt))
  })
}

/// Convert screen coordinates to world coordinates at player's Y level
/// Uses proper isometric unprojection based on camera at (d,d,d) looking at origin
pub fn screen_to_world_ground(
  screen_pos: Vec2(Float),
  canvas_size: Vec2(Float),
  player_x: Float,
  player_z: Float,
  zoom: Float,
) -> Vec3(Float) {
  let norm_x = screen_pos.x /. canvas_size.x -. 0.5
  let norm_y = screen_pos.y /. canvas_size.y -. 0.5

  let aspect = canvas_size.x /. canvas_size.y
  let ortho_x = norm_x *. zoom *. 2.0 *. aspect
  let ortho_y = norm_y *. zoom *. 2.0

  // Camera basis vectors for isometric view from (d,d,d):
  // right = (0.7071, 0, -0.7071)
  // up = (-0.408, 0.816, -0.408)
  // To project screen coords to player's Y level, we need these coefficients:
  let right_coef = 0.7071
  let up_coef = 1.2247
  // = sqrt(1.5), accounts for camera elevation angle

  let world_x = player_x +. ortho_x *. right_coef +. ortho_y *. up_coef
  let world_z = player_z -. ortho_x *. right_coef +. ortho_y *. up_coef

  Vec3(world_x, 0.0, world_z)
}

// =============================================================================
// VIEW
// =============================================================================

/// Returns projectile scene nodes
pub fn view(model: Model) -> List(scene.Node) {
  list.map(model.projectiles, view_projectile)
}

fn view_projectile(proj: projectile.Projectile) -> scene.Node {
  // Use a plane geometry for billboard sprite
  let assert Ok(proj_geo) = geometry.box(size: vec3.Vec3(1.0, 1.0, 1.0))

  // Simple colored material for now (can be enhanced with textures later)
  let color = 0xFFFF00
  // Yellow projectiles
  let assert Ok(proj_mat) =
    material.new()
    |> material.with_color(color)
    |> material.with_emissive(color)
    |> material.with_emissive_intensity(0.8)
    |> material.with_transparent(True)
    |> material.with_opacity(1.0)
    |> material.build()

  let body_id = id.to_string(id.Projectile(proj.id))

  // Render WITHOUT physics body for now (server handles collision)
  scene.mesh(
    id: body_id,
    geometry: proj_geo,
    material: proj_mat,
    transform: transform.at(proj.position),
    physics: option.None,
  )
}

// =============================================================================
// STATE HELPERS
// =============================================================================

/// Get wand state for UI synchronization (for active wand)
pub fn get_wand_ui_state(
  model: Model,
) -> #(
  List(option.Option(spell.Spell)),
  option.Option(Int),
  Float,
  Float,
  spell_bag.SpellBag,
) {
  case get_active_wand(model) {
    option.Some(active_wand) -> {
      let slot_count = iv.size(active_wand.slots)
      let slots =
        list.range(0, slot_count - 1)
        |> list.map(fn(i) {
          case wand.get_spell(active_wand, i) {
            Ok(spell_opt) -> spell_opt
            Error(_) -> option.None
          }
        })

      #(
        slots,
        model.selected_spell_slot,
        active_wand.current_mana,
        active_wand.max_mana,
        model.spell_bag,
      )
    }
    option.None -> {
      #([], option.None, 0.0, 0.0, model.spell_bag)
    }
  }
}

/// Get wand inventory state for UI
pub fn get_wand_inventory(model: Model) -> List(Option(wand.Wand)) {
  iv.to_list(model.wands)
}

/// Get the active wand index
pub fn get_active_wand_index(model: Model) -> Int {
  model.active_wand_index
}

/// Get current projectiles for collision detection
pub fn get_projectiles(model: Model) -> List(projectile.Projectile) {
  model.projectiles
}

/// Get all wands with their cast indices for inventory display
pub fn get_all_wands_with_cast_indices(
  model: Model,
) -> List(#(Option(wand.Wand), Int)) {
  iv.to_list(model.wands)
  |> list.index_map(fn(wand_opt, index) {
    let cast_index = case iv.get(model.wand_states, index), wand_opt {
      Ok(state), option.Some(w) ->
        find_next_spell_index(w.slots, state.wand_cast_index)
      _, _ -> 0
    }
    #(wand_opt, cast_index)
  })
}
