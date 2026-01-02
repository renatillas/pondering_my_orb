import ensaimada
import gleam/float
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/time/duration
import iv
import pondering_my_orb/game_physics/layer
import tiramisu
import tiramisu/effect
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec2.{type Vec2, Vec2}
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

import pondering_my_orb/id
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/spell_bag
import pondering_my_orb/magic_system/wand

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
    projectiles: List(spell.Projectile),
    next_projectile_id: Int,
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
  RemoveProjectile(Int)
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
  // Create default spell visuals
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
  let assert Ok(starter_wand) =
    wand.set_spell(starter_wand, 0, spell.spark(default_visuals))

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
    WandState(
      cast_cooldown: duration.milliseconds(0),
      wand_cast_index: 0,
    )
  let wand_states = iv.repeat(initial_wand_state, 4)

  // Start with an empty spell bag
  let initial_spell_bag = spell_bag.new()

  let model =
    Model(
      wands: wands,
      active_wand_index: 0,
      wand_states: wand_states,
      projectiles: [],
      next_projectile_id: 0,
      spell_bag: initial_spell_bag,
      selected_spell_slot: option.None,
      player_pos: Vec3(0.0, 1.0, 0.0),
      zoom: 30.0,
    )

  #(model, effect.tick(Tick))
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
      #(new_model, effect.tick(Tick))
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

    RemoveProjectile(projectile_id) -> {
      let new_projectiles =
        list.filter(model.projectiles, fn(p) { p.id != projectile_id })
      #(Model(..model, projectiles: new_projectiles), effect.none())
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
              case
                iv.set(active_wand.slots, at: slot_index, to: option.None)
              {
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

  // Handle spell casting (left click)
  let model = update_casting(model, ctx)

  // Update projectiles
  let model = update_projectiles(model, dt)

  // Recharge mana for all wands
  let new_wands = recharge_all_wands(model.wands, dt)

  // Reduce cooldown for all wand states
  let new_wand_states = reduce_all_cooldowns(model.wand_states, dt)

  Model(..model, wands: new_wands, wand_states: new_wand_states)
}

fn update_casting(model: Model, ctx: tiramisu.Context) -> Model {
  let active_state = get_active_wand_state(model)
  let can_cast =
    input.is_left_button_pressed(ctx.input)
    && duration.to_seconds(active_state.cast_cooldown) <=. 0.0

  case can_cast {
    True -> try_cast_spell(model, ctx)
    False -> model
  }
}

fn try_cast_spell(model: Model, ctx: tiramisu.Context) -> Model {
  case get_active_wand(model) {
    option.None -> model
    option.Some(active_wand) -> {
      let active_state = get_active_wand_state(model)

      let mouse_pos = input.mouse_position(ctx.input)
      let target_pos =
        screen_to_world_ground(
          mouse_pos,
          ctx.canvas_size,
          model.player_pos.x,
          model.player_pos.z,
          model.zoom,
        )

      let direction =
        vec3f.subtract(target_pos, model.player_pos) |> vec3f.normalize()

      let #(result, new_wand) =
        wand.cast(
          active_wand,
          active_state.wand_cast_index,
          model.player_pos,
          direction,
          model.next_projectile_id,
          option.None,
          option.Some(model.player_pos),
          model.projectiles,
        )

      case result {
        wand.CastSuccess(
          projectiles: new_projectiles,
          next_cast_index: next_index,
          total_cast_delay_addition: delay,
          total_recharge_time_addition: recharge_addition,
          did_wrap: wrapped,
          ..,
        ) -> {
          let total_projectiles =
            list.append(new_projectiles, model.projectiles)
          let new_id = model.next_projectile_id + list.length(new_projectiles)

          let total_delay = duration.add(active_wand.cast_delay, delay)

          let final_cooldown = case wrapped {
            True -> {
              let recharge =
                duration.add(active_wand.recharge_time, recharge_addition)
              duration.add(total_delay, recharge)
            }
            False -> total_delay
          }

          // Update wand in wands array
          let assert Ok(new_wands) =
            iv.set(
              model.wands,
              at: model.active_wand_index,
              to: option.Some(new_wand),
            )

          // Update wand state
          let new_state =
            WandState(cast_cooldown: final_cooldown, wand_cast_index: next_index)
          let assert Ok(new_wand_states) =
            iv.set(model.wand_states, at: model.active_wand_index, to: new_state)

          Model(
            ..model,
            wands: new_wands,
            wand_states: new_wand_states,
            projectiles: total_projectiles,
            next_projectile_id: new_id,
          )
        }
        wand.NotEnoughMana(..) | wand.NoSpellToCast | wand.WandEmpty -> {
          // Update wand mana even on failure
          let assert Ok(new_wands) =
            iv.set(
              model.wands,
              at: model.active_wand_index,
              to: option.Some(new_wand),
            )
          Model(..model, wands: new_wands)
        }
      }
    }
  }
}

fn update_projectiles(model: Model, delta_time: duration.Duration) -> Model {
  // Physics drives movement, we only update time_alive and filter expired projectiles
  let updated_projectiles =
    model.projectiles
    |> list.map(fn(proj) {
      let new_time_alive = duration.add(proj.time_alive, delta_time)
      spell.Projectile(..proj, time_alive: new_time_alive)
    })
    |> list.filter(fn(proj) {
      duration.compare(proj.time_alive, proj.spell.final_lifetime) != order.Gt
    })

  Model(..model, projectiles: updated_projectiles)
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
fn get_active_wand(model: Model) -> Option(wand.Wand) {
  case iv.get(model.wands, model.active_wand_index) {
    Ok(wand_opt) -> wand_opt
    Error(_) -> option.None
  }
}

/// Get the state for the active wand
fn get_active_wand_state(model: Model) -> WandState {
  case iv.get(model.wand_states, model.active_wand_index) {
    Ok(state) -> state
    Error(_) ->
      WandState(
        cast_cooldown: duration.milliseconds(0),
        wand_cast_index: 0,
      )
  }
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
    WandState(
      ..state,
      cast_cooldown: reduce_cooldown(state.cast_cooldown, dt),
    )
  })
}

/// Convert screen coordinates to world ground plane coordinates
fn screen_to_world_ground(
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

  let diagonal = 0.7071

  let world_x = { ortho_x +. ortho_y } *. diagonal +. player_x
  let world_z = { ortho_y -. ortho_x } *. diagonal +. player_z

  Vec3(world_x, 0.0, world_z)
}

// =============================================================================
// VIEW
// =============================================================================

/// Returns projectile scene nodes
pub fn view(
  model: Model,
  physics_world: physics.PhysicsWorld,
) -> List(scene.Node) {
  list.map(model.projectiles, fn(p) { view_projectile(p, physics_world) })
}

fn view_projectile(
  projectile: spell.Projectile,
  physics_world: physics.PhysicsWorld,
) -> scene.Node {
  let size = projectile.spell.final_size
  let assert Ok(proj_geo) = geometry.box(Vec3(size, size, size))

  let color = get_spell_color(projectile.spell.base)

  let assert Ok(proj_mat) =
    material.new()
    |> material.with_color(color)
    |> material.with_emissive(color)
    |> material.with_emissive_intensity(0.8)
    |> material.build()

  // Physics body for collision detection
  // Layer 3 = Projectiles, collides with layer 1 = Enemies
  // Sensor mode: detects collisions but doesn't bounce/deflect
  let physics_body =
    physics.new_rigid_body(physics.Dynamic)
    |> physics.with_collider(physics.Sphere(
      offset: transform.identity,
      radius: size /. 2.0,
    ))
    |> physics.with_collision_groups(
      membership: [layer.projectile],
      can_collide_with: [layer.enemy],
    )
    |> physics.with_collision_events()
    |> physics.with_sensor()
    |> physics.with_body_ccd_enabled()
    |> physics.with_lock_translation_y()
    |> physics.build()

  let body_id = id.to_string(id.Projectile(projectile.id))

  // Get transform from physics if body exists, otherwise use model position
  let proj_transform = case physics.get_transform(physics_world, body_id) {
    Ok(t) -> t
    Error(_) -> transform.at(position: projectile.position)
  }

  scene.mesh(
    id: body_id,
    geometry: proj_geo,
    material: proj_mat,
    transform: proj_transform,
    physics: option.Some(physics_body),
  )
}

fn get_spell_color(spell_type: spell.Spell) -> Int {
  case spell_type {
    spell.DamageSpell(id: spell.Spark, ..) -> 0xFFFF00
    spell.DamageSpell(id: spell.Fireball, ..) -> 0xFF4400
    spell.DamageSpell(id: spell.LightningBolt, ..) -> 0x00FFFF
    spell.DamageSpell(id: spell.SparkWithTrigger, ..) -> 0xFFAA00
    spell.DamageSpell(id: spell.OrbitingSpell, ..) -> 0xFF00FF
    spell.DamageSpell(..) -> 0xFFFFFF
    spell.ModifierSpell(..) -> 0x00FF00
    spell.MulticastSpell(..) -> 0x0000FF
  }
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
      #(
        [],
        option.None,
        0.0,
        0.0,
        model.spell_bag,
      )
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
pub fn get_projectiles(model: Model) -> List(spell.Projectile) {
  model.projectiles
}
