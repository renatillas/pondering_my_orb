import gleam/list
import gleam/option
import tiramisu
import tiramisu/effect
import tiramisu/physics
import vec/vec3.{type Vec3}
import vec/vec3f

import client/player
import shared/id
import shared/projectile

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

/// Enemy state updated synchronously during physics tick
pub type Msg {
  Tick
}

pub type CollisionResult {
  ProjectileHitEnemy(projectile_id: Int, enemy_id: Int, damage: Float)
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
  player_model player_model: player.Model,
  enemy_took_projectile_damage enemy_took_projectile_damage,
  remove_projectile remove_projectile,
  effect_mapper effect_mapper,
) -> #(Model, effect.Effect(game_msg)) {
  let assert option.Some(physics_world) = ctx.physics_world
  let projectiles = player.get_projectiles(player_model)

  case msg {
    Tick -> {
      // PRE-STEP: Set projectile velocities
      // Note: Enemies no longer have physics bodies (server-authoritative rendering only)
      let world_with_updates =
        physics_world
        |> set_projectile_velocities(projectiles)

      // STEP: Run physics simulation
      let stepped_world = physics.step(world_with_updates, ctx.delta_time)

      // POST-STEP: Process results
      let collision_results =
        stepped_world
        |> physics.get_collision_events
        |> process_collisions(projectiles)

      let model =
        Model(
          collision_results: collision_results,
          enemy_positions: [],
          // No longer tracking enemy physics positions
          stepped_world: option.Some(stepped_world),
        )

      // Build collision effects only (no enemy position updates needed)
      let effects =
        effect.batch([
          build_collision_effects(
            collision_results,
            enemy_took_projectile_damage,
            remove_projectile,
          ),
          effect.dispatch(effect_mapper(Tick)),
        ])

      #(model, effects)
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
  projectiles: List(projectile.Projectile),
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
  projectiles: List(projectile.Projectile),
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
  projectiles: List(projectile.Projectile),
  projectile_id: Int,
) -> Result(Float, Nil) {
  list.find_map(projectiles, fn(p) {
    case p.id == projectile_id {
      True -> Ok(p.damage)
      False -> Error(Nil)
    }
  })
}

// =============================================================================
// PHYSICS HELPERS
// =============================================================================

fn set_projectile_velocities(
  world: physics.PhysicsWorld,
  projectiles: List(projectile.Projectile),
) -> physics.PhysicsWorld {
  list.fold(projectiles, world, fn(w, proj) {
    let velocity = vec3f.scale(proj.direction, by: proj.speed)
    physics.set_velocity(w, id.to_string(id.Projectile(proj.id)), velocity)
  })
}
