import gleam/list
import gleam/option
import tiramisu
import tiramisu/effect
import tiramisu/physics
import tiramisu/transform
import vec/vec3.{type Vec3}
import vec/vec3f

import pondering_my_orb/enemy
import pondering_my_orb/id
import pondering_my_orb/magic_system/spell

// =============================================================================
// CONSTANTS
// ============================================================================

pub const map_layer = 0

pub const player_layer = 1

pub const enemies_layer = 2

pub const projectiles_layer = 3

// =============================================================================
// TYPES
// =============================================================================

/// Model contains results from physics tick for other modules to consume
pub type Model {
  Model(
    collision_results: List(CollisionResult),
    enemy_positions: List(#(id.Id, Vec3(Float))),
    stepped_world: option.Option(physics.PhysicsWorld),
  )
}

pub type Msg {
  Tick(
    enemy_model: enemy.Model,
    player_position: Vec3(Float),
    projectiles: List(spell.Projectile),
  )
}

/// Result of processing a collision event
pub type CollisionResult {
  ProjectileHitEnemy(projectile_id: Int, enemy_id: Int, damage: Float)
  EnemyHitPlayer(enemy_id: Int)
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

pub fn update(
  _model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg)) {
  case msg {
    Tick(enemy_model, player_position, projectiles) -> {
      // Get physics world from context (has bodies from renderer)
      let assert option.Some(physics_world) = ctx.physics_world

      // === PRE-STEP: Set velocities ===

      // Update enemy velocities based on player position
      let #(updated_enemy_model, enemy_velocities) =
        enemy.update_for_physics(enemy_model, player_position)

      // Set velocities for ALL projectiles every frame
      let world_after_projectiles =
        set_all_projectile_velocities(physics_world, projectiles)

      // Set velocities for enemies
      let world_with_velocities =
        set_enemy_velocities(world_after_projectiles, enemy_velocities)

      // === STEP: Run physics simulation ===
      let stepped_world = physics.step(world_with_velocities, ctx.delta_time)

      // === POST-STEP: Handle results ===

      // Handle collision events
      let collision_events = physics.get_collision_events(stepped_world)
      let collision_results =
        handle_collision_events(collision_events, projectiles)

      // Read enemy positions from physics
      let enemy_ids = enemy.get_enemy_ids(updated_enemy_model)
      let enemy_positions = get_enemy_positions(stepped_world, enemy_ids)

      let new_model =
        Model(
          collision_results: collision_results,
          enemy_positions: enemy_positions,
          stepped_world: option.Some(stepped_world),
        )

      // Don't self-schedule - main module schedules with fresh player data
      #(new_model, effect.none())
    }
  }
}

// =============================================================================
// COLLISION EVENT HANDLING
// =============================================================================

fn handle_collision_events(
  events: List(physics.CollisionEvent),
  projectiles: List(spell.Projectile),
) -> List(CollisionResult) {
  list.filter_map(events, fn(event) {
    case event {
      physics.CollisionStarted(body_a, body_b) ->
        handle_collision_started(body_a, body_b, projectiles)
      physics.CollisionEnded(_, _) -> Error(Nil)
    }
  })
}

fn handle_collision_started(
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
    id.Enemy(enemy_id), id.Player | id.Player, id.Enemy(enemy_id) ->
      Ok(EnemyHitPlayer(enemy_id))
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
// VELOCITY HELPERS
// =============================================================================

fn set_all_projectile_velocities(
  world: physics.PhysicsWorld,
  projectiles: List(spell.Projectile),
) -> physics.PhysicsWorld {
  list.fold(projectiles, world, fn(current_world, proj) {
    let velocity = vec3f.scale(proj.direction, by: proj.spell.final_speed)
    let body_id = id.to_string(id.Projectile(proj.id))
    physics.set_velocity(current_world, body_id, velocity)
  })
}

fn set_enemy_velocities(
  world: physics.PhysicsWorld,
  enemies: List(#(Int, Vec3(Float))),
) -> physics.PhysicsWorld {
  list.fold(enemies, world, fn(current_world, enemy_data) {
    let #(enemy_num, velocity) = enemy_data
    let body_id = id.to_string(id.Enemy(enemy_num))
    physics.set_velocity(current_world, body_id, velocity)
  })
}

fn get_enemy_positions(
  world: physics.PhysicsWorld,
  enemy_ids: List(Int),
) -> List(#(id.Id, Vec3(Float))) {
  list.filter_map(enemy_ids, fn(enemy_num) {
    let body_id = id.to_string(id.Enemy(enemy_num))
    case physics.get_transform(world, body_id) {
      Ok(trans) -> Ok(#(id.Enemy(enemy_num), transform.position(trans)))
      Error(_) -> Error(Nil)
    }
  })
}
