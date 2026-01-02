import ensaimada
import gleam/float
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/time/duration
import iv
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
import pondering_my_orb/magic_system/wand

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    wand: wand.Wand,
    projectiles: List(spell.Projectile),
    next_projectile_id: Int,
    cast_cooldown: duration.Duration,
    wand_cast_index: Int,
    available_spells: List(spell.Spell),
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
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  // Create a wand with 4 slots
  let initial_wand =
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

  // Available spells the player can add to their wand
  let available_spells = [
    spell.spark(default_visuals),
    spell.fireball(spell.SpellVisuals(..default_visuals, base_tint: 0xFF4400)),
    spell.add_damage(),
    spell.rapid_fire(),
  ]

  let model =
    Model(
      wand: initial_wand,
      projectiles: [],
      next_projectile_id: 0,
      cast_cooldown: duration.milliseconds(0),
      wand_cast_index: 0,
      available_spells: available_spells,
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
      let maybe_new_spell =
        list.find(model.available_spells, fn(s) { s.id == spell_id })

      case maybe_new_spell {
        Ok(spell_to_place) -> {
          let existing_spell = case wand.get_spell(model.wand, slot_index) {
            Ok(option.Some(spell)) -> option.Some(spell)
            _ -> option.None
          }

          case
            iv.set(
              model.wand.slots,
              at: slot_index,
              to: option.Some(spell_to_place),
            )
          {
            Ok(new_slots) -> {
              let new_wand = wand.Wand(..model.wand, slots: new_slots)

              let updated_available =
                model.available_spells
                |> list.filter(fn(s) { s.id != spell_id })

              let final_available = case existing_spell {
                option.Some(old_spell) -> [old_spell, ..updated_available]
                option.None -> updated_available
              }

              let new_model =
                Model(
                  ..model,
                  wand: new_wand,
                  available_spells: final_available,
                )

              #(new_model, effect.none())
            }
            Error(_) -> #(model, effect.none())
          }
        }
        Error(_) -> #(model, effect.none())
      }
    }

    SelectSlot(slot_index) -> {
      let new_model =
        Model(..model, selected_spell_slot: option.Some(slot_index))
      #(new_model, effect.none())
    }

    ReorderWandSlots(from_index, to_index) -> {
      let slots_list = iv.to_list(model.wand.slots)
      let reordered = ensaimada.reorder(slots_list, from_index, to_index)
      let new_slots = iv.from_list(reordered)
      let new_wand = wand.Wand(..model.wand, slots: new_slots)
      let new_model = Model(..model, wand: new_wand)
      #(new_model, effect.none())
    }

    RemoveProjectile(projectile_id) -> {
      let new_projectiles =
        list.filter(model.projectiles, fn(p) { p.id != projectile_id })
      #(Model(..model, projectiles: new_projectiles), effect.none())
    }
  }
}

// =============================================================================
// TICK
// =============================================================================

/// Called every frame to update magic state
fn tick(model: Model, ctx: tiramisu.Context) -> Model {
  let dt = ctx.delta_time

  // Handle spell slot selection (1-4 keys)
  let model = update_spell_selection(model, ctx)

  // Handle spell casting (left click)
  let model = update_casting(model, ctx)

  // Update projectiles
  let model = update_projectiles(model, dt)

  // Recharge wand mana
  let new_wand = wand.recharge_mana(model.wand, dt)

  // Reduce cast cooldown
  let new_cooldown = reduce_cooldown(model.cast_cooldown, dt)

  Model(..model, wand: new_wand, cast_cooldown: new_cooldown)
}

fn update_spell_selection(model: Model, ctx: tiramisu.Context) -> Model {
  let key1 = input.is_key_just_pressed(ctx.input, input.Digit1)
  let key2 = input.is_key_just_pressed(ctx.input, input.Digit2)
  let key3 = input.is_key_just_pressed(ctx.input, input.Digit3)
  let key4 = input.is_key_just_pressed(ctx.input, input.Digit4)

  let selected = case key1, key2, key3, key4 {
    True, _, _, _ -> option.Some(0)
    _, True, _, _ -> option.Some(1)
    _, _, True, _ -> option.Some(2)
    _, _, _, True -> option.Some(3)
    _, _, _, _ -> model.selected_spell_slot
  }

  let key_e = input.is_key_just_pressed(ctx.input, input.KeyE)
  let model = case selected, key_e {
    option.Some(slot_index), True -> add_next_spell_to_slot(model, slot_index)
    _, _ -> model
  }

  Model(..model, selected_spell_slot: selected)
}

fn add_next_spell_to_slot(model: Model, slot_index: Int) -> Model {
  case model.available_spells {
    [first_spell, ..] -> {
      case wand.set_spell(model.wand, slot_index, first_spell) {
        Ok(new_wand) -> Model(..model, wand: new_wand)
        Error(_) -> model
      }
    }
    [] -> model
  }
}

fn update_casting(model: Model, ctx: tiramisu.Context) -> Model {
  let can_cast =
    input.is_left_button_pressed(ctx.input)
    && duration.to_seconds(model.cast_cooldown) <=. 0.0

  case can_cast {
    True -> try_cast_spell(model, ctx)
    False -> model
  }
}

fn try_cast_spell(model: Model, ctx: tiramisu.Context) -> Model {
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
      model.wand,
      model.wand_cast_index,
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
      let total_projectiles = list.append(new_projectiles, model.projectiles)
      let new_id = model.next_projectile_id + list.length(new_projectiles)

      let total_delay = duration.add(model.wand.cast_delay, delay)

      let final_cooldown = case wrapped {
        True -> {
          let recharge =
            duration.add(model.wand.recharge_time, recharge_addition)
          duration.add(total_delay, recharge)
        }
        False -> total_delay
      }

      Model(
        ..model,
        wand: new_wand,
        projectiles: total_projectiles,
        next_projectile_id: new_id,
        cast_cooldown: final_cooldown,
        wand_cast_index: next_index,
      )
    }
    wand.NotEnoughMana(..) | wand.NoSpellToCast | wand.WandEmpty -> {
      Model(..model, wand: new_wand)
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
    |> physics.with_collision_groups(membership: [3], can_collide_with: [1])
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

/// Get wand state for UI synchronization
pub fn get_wand_ui_state(
  model: Model,
) -> #(
  List(option.Option(spell.Spell)),
  option.Option(Int),
  Float,
  Float,
  List(spell.Spell),
) {
  let slots =
    list.range(0, 3)
    |> list.map(fn(i) {
      case wand.get_spell(model.wand, i) {
        Ok(spell_opt) -> spell_opt
        Error(_) -> option.None
      }
    })

  #(
    slots,
    model.selected_spell_slot,
    model.wand.current_mana,
    model.wand.max_mana,
    model.available_spells,
  )
}

/// Get current projectiles for collision detection
pub fn get_projectiles(model: Model) -> List(spell.Projectile) {
  model.projectiles
}
