import gleam/float
import gleam/list
import gleam/option
import gleam/time/duration
import iv
import tiramisu
import tiramisu/effect
import tiramisu/input
import tiramisu/physics
import tiramisu/transform
import tiramisu/ui
import vec/vec3.{type Vec3}
import vec/vec3f

import pondering_my_orb/altar
import pondering_my_orb/enemy
import pondering_my_orb/id
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/wand
import pondering_my_orb/player

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    collision_results: List(CollisionResult),
    enemy_positions: List(#(id.Id, Vec3(Float))),
    stepped_world: option.Option(physics.PhysicsWorld),
  )
}

pub type Msg {
  Tick
}

pub type CollisionResult {
  ProjectileHitEnemy(projectile_id: Int, enemy_id: Int, damage: Float)
}

pub type TickResult {
  TickResult(
    physics: Model,
    enemy: enemy.Model,
    altar: altar.Model,
    stepped_world: option.Option(physics.PhysicsWorld),
  )
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  let model =
    Model(
      collision_results: [],
      enemy_positions: [],
      stepped_world: option.None,
    )
  #(model, effect.none())
}

// =============================================================================
// UPDATE
// =============================================================================

/// Physics tick - coordinates physics simulation and cross-module effects.
///
/// Accepts tagger functions to dispatch effects to sibling modules without
/// creating import cycles. The parent module provides these taggers.
pub fn update(
  msg msg: Msg,
  ctx ctx: tiramisu.Context,
  // Module state
  player_model player_model: player.Model,
  enemy_model enemy_model: enemy.Model,
  altar_model altar_model: altar.Model,
  bridge bridge: ui.Bridge(ui_msg, game_msg),
  // Message taggers for cross-module dispatch
  spawn_altar spawn_altar,
  enemy_took_projectile_damage enemy_took_projectile_damage,
  remove_projectile remove_projectile,
  player_state_updated player_state_updated,
  pick_up_wand pick_up_wand,
  remove_altar remove_altar,
  constructor_wand_display_info constructor_wand_display_info,
  toggle_edit_mode toggle_edit_mode,
  effect_mapper effect_mapper,
) -> #(TickResult, effect.Effect(game_msg)) {
  let assert option.Some(physics_world) = ctx.physics_world
  let player_position = player_model.position
  let projectiles = player.get_projectiles(player_model)

  case msg {
    Tick -> {
      // PRE-STEP: Set velocities
      let #(updated_enemy, enemy_velocities) =
        enemy.update_for_physics(enemy_model, player_position)
      let world_with_velocities =
        physics_world
        |> set_projectile_velocities(projectiles)
        |> set_enemy_velocities(enemy_velocities)

      // STEP: Run physics simulation
      let stepped_world = physics.step(world_with_velocities, ctx.delta_time)

      // POST-STEP: Process results
      let collision_results =
        stepped_world
        |> physics.get_collision_events
        |> process_collisions(projectiles)

      let enemy_ids = list.map(updated_enemy.enemies, enemy.id)
      let enemy_positions = read_enemy_positions(stepped_world, enemy_ids)
      let enemy_with_positions =
        enemy.apply_physics_positions(
          updated_enemy,
          enemy_positions,
          player_position,
        )

      // Handle deaths and altar updates
      let #(final_enemy, death_effects) =
        build_death_effects(enemy_with_positions, spawn_altar)
      let #(final_altar, _) =
        altar.update(altar_model, altar.UpdatePlayerPos(player_position), ctx)

      // Build result
      let result =
        TickResult(
          physics: Model(
            collision_results: collision_results,
            enemy_positions: enemy_positions,
            stepped_world: option.Some(stepped_world),
          ),
          enemy: final_enemy,
          altar: final_altar,
          stepped_world: option.Some(stepped_world),
        )

      // Build all effects
      let effects =
        effect.batch([
          build_collision_effects(
            collision_results,
            enemy_took_projectile_damage,
            remove_projectile,
          ),
          build_ui_sync_effect(
            player_model,
            final_altar,
            bridge,
            player_state_updated,
            constructor_wand_display_info,
          ),
          death_effects,
          build_pickup_effect(ctx, final_altar, pick_up_wand, remove_altar),
          build_edit_mode_effect(ctx, bridge, toggle_edit_mode),
          effect.tick(effect_mapper(Tick)),
        ])

      #(result, effects)
    }
  }
}

// =============================================================================
// EFFECT BUILDERS
// =============================================================================

fn build_collision_effects(
  results: List(CollisionResult),
  enemy_took_damage,
  remove_projectile,
) -> effect.Effect(game_msg) {
  results
  |> list.map(fn(result) {
    let ProjectileHitEnemy(proj_id, enemy_id, damage) = result
    effect.batch([
      effect.dispatch(enemy_took_damage(id.Enemy(enemy_id), damage)),
      effect.dispatch(remove_projectile(proj_id)),
    ])
  })
  |> effect.batch
}

fn build_ui_sync_effect(
  player_model: player.Model,
  altar_model: altar.Model,
  bridge,
  player_state_updated,
  constructor_wand_display_info,
) -> effect.Effect(game_msg) {
  let #(slots, selected, mana, max_mana, spell_bag) =
    player.get_wand_ui_state(player_model)

  ui.to_lustre(
    bridge,
    player_state_updated(
      slots,
      selected,
      mana,
      max_mana,
      spell_bag,
      player_model.health,
      player.get_wand_names(player_model),
      player.get_active_wand_index(player_model),
      get_nearby_altar_info(altar_model, constructor_wand_display_info),
    ),
  )
}

fn build_death_effects(
  enemy_model: enemy.Model,
  spawn_altar,
) -> #(enemy.Model, effect.Effect(game_msg)) {
  let effects =
    enemy_model
    |> enemy.get_death_positions
    |> list.map(fn(pos) { effect.dispatch(spawn_altar(pos)) })
    |> effect.batch

  #(enemy.clear_death_positions(enemy_model), effects)
}

fn build_pickup_effect(
  ctx: tiramisu.Context,
  altar_model: altar.Model,
  pick_up_wand,
  remove_altar,
) -> effect.Effect(game_msg) {
  case input.is_key_just_pressed(ctx.input, input.KeyE) {
    True ->
      case altar.get_nearest_altar(altar_model) {
        option.Some(nearby) ->
          effect.batch([
            effect.dispatch(pick_up_wand(nearby.wand)),
            effect.dispatch(remove_altar(nearby.id)),
          ])
        option.None -> effect.none()
      }
    False -> effect.none()
  }
}

fn build_edit_mode_effect(
  ctx: tiramisu.Context,
  bridge: ui.Bridge(ui_msg, game_msg),
  toggle_edit_mode,
) -> effect.Effect(game_msg) {
  case input.is_key_just_pressed(ctx.input, input.KeyI) {
    True -> ui.to_lustre(bridge, toggle_edit_mode)
    False -> effect.none()
  }
}

fn get_nearby_altar_info(
  altar_model: altar.Model,
  constructor_wand_display_info,
) -> option.Option(game_msg) {
  case altar.get_nearest_altar(altar_model) {
    option.Some(nearby) -> {
      let w = nearby.wand
      option.Some(constructor_wand_display_info(
        w.name,
        iv.size(w.slots),
        w.spells_per_cast,
        float.round(duration.to_seconds(w.cast_delay) *. 1000.0),
        float.round(duration.to_seconds(w.recharge_time) *. 1000.0),
        w.max_mana,
        w.mana_recharge_rate,
        w.spread,
        wand.get_spell_names(w),
      ))
    }
    option.None -> option.None
  }
}

// =============================================================================
// COLLISION HANDLING
// =============================================================================

fn process_collisions(
  events: List(physics.CollisionEvent),
  projectiles: List(spell.Projectile),
) -> List(CollisionResult) {
  list.filter_map(events, fn(event) {
    case event {
      physics.CollisionStarted(body_a, body_b) ->
        match_projectile_enemy_collision(body_a, body_b, projectiles)
      physics.CollisionEnded(_, _) -> Error(Nil)
    }
  })
}

fn match_projectile_enemy_collision(
  body_a: String,
  body_b: String,
  projectiles: List(spell.Projectile),
) -> Result(CollisionResult, Nil) {
  case id.from_string(body_a), id.from_string(body_b) {
    id.Projectile(proj_id), id.Enemy(enemy_id)
    | id.Enemy(enemy_id), id.Projectile(proj_id)
    -> {
      case find_projectile_damage(projectiles, proj_id) {
        Ok(damage) -> Ok(ProjectileHitEnemy(proj_id, enemy_id, damage))
        Error(_) -> Error(Nil)
      }
    }
    _, _ -> Error(Nil)
  }
}

fn find_projectile_damage(
  projectiles: List(spell.Projectile),
  projectile_id: Int,
) -> Result(Float, Nil) {
  list.find_map(projectiles, fn(p) {
    case p.id == projectile_id {
      True -> Ok(p.spell.final_damage)
      False -> Error(Nil)
    }
  })
}

// =============================================================================
// PHYSICS HELPERS
// =============================================================================

fn set_projectile_velocities(
  world: physics.PhysicsWorld,
  projectiles: List(spell.Projectile),
) -> physics.PhysicsWorld {
  list.fold(projectiles, world, fn(w, proj) {
    let velocity = vec3f.scale(proj.direction, by: proj.spell.final_speed)
    physics.set_velocity(w, id.to_string(id.Projectile(proj.id)), velocity)
  })
}

fn set_enemy_velocities(
  world: physics.PhysicsWorld,
  velocities: List(#(id.Id, Vec3(Float))),
) -> physics.PhysicsWorld {
  list.fold(velocities, world, fn(w, data) {
    let #(enemy_id, velocity) = data
    physics.set_velocity(w, id.to_string(enemy_id), velocity)
  })
}

fn read_enemy_positions(
  world: physics.PhysicsWorld,
  enemy_ids: List(id.Id),
) -> List(#(id.Id, Vec3(Float))) {
  list.filter_map(enemy_ids, fn(enemy_id) {
    case physics.get_transform(world, id.to_string(enemy_id)) {
      Ok(trans) -> Ok(#(enemy_id, transform.position(trans)))
      Error(_) -> Error(Nil)
    }
  })
}
