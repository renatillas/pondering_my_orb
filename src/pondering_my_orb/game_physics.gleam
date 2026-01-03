import gleam/list
import gleam/option
import tiramisu
import tiramisu/effect
import tiramisu/physics
import tiramisu/transform
import vec/vec3.{type Vec3}
import vec/vec3f

import pondering_my_orb/altar
import pondering_my_orb/enemy
import pondering_my_orb/id
import pondering_my_orb/magic_system/spell
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
  // Message taggers for cross-module dispatch
  enemy_took_projectile_damage enemy_took_projectile_damage,
  remove_projectile remove_projectile,
  update_altar_player_pos update_altar_player_pos,
  update_enemy_positions update_enemy_positions,
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

      // Build result (enemy and altar updated via async dispatch)
      let result =
        TickResult(
          physics: Model(
            collision_results: collision_results,
            enemy_positions: enemy_positions,
            stepped_world: option.Some(stepped_world),
          ),
          enemy: updated_enemy,
          altar: altar_model,
          stepped_world: option.Some(stepped_world),
        )

      // Build all effects (including async position updates)
      let effects =
        effect.batch([
          build_collision_effects(
            collision_results,
            enemy_took_projectile_damage,
            remove_projectile,
          ),
          effect.dispatch(update_altar_player_pos(player_position)),
          effect.dispatch(update_enemy_positions(enemy_positions, player_position)),
          effect.dispatch(effect_mapper(Tick)),
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
