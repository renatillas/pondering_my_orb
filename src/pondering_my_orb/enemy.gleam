import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/time/duration
import gleam_community/maths
import lustre/attribute.{attribute, class}
import lustre/element
import lustre/element/html
import tiramisu
import tiramisu/effect
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

import pondering_my_orb/game_physics/layer
import pondering_my_orb/health
import pondering_my_orb/id

// =============================================================================
// TYPES
// =============================================================================

pub type Enemy {
  Enemy(
    id: id.Id,
    position: Vec3(Float),
    health: health.Health,
    damage: Float,
    speed: Float,
    attack_cooldown: duration.Duration,
    // Desired velocity toward player (set by update, applied by physics)
    desired_velocity: Vec3(Float),
  )
}

pub type Model {
  Model(
    enemies: List(Enemy),
    next_enemy_id: Int,
    spawn_timer: duration.Duration,
    spawn_interval: duration.Duration,
    player_pos: Vec3(Float),
  )
}

pub type Msg {
  Tick
  UpdatePlayerPos(player_pos: Vec3(Float))
  TakeProjectileDamage(enemy_id: id.Id, damage: Float)
  // Physics sends back updated positions after simulation
  UpdatePositionsFromPhysics(
    positions: List(#(id.Id, Vec3(Float))),
    player_pos: Vec3(Float),
  )
}

// =============================================================================
// CONSTANTS
// =============================================================================

const default_enemy_health = 10.0

const default_enemy_damage = 10.0

const default_enemy_speed = 8.0

const spawn_interval_ms = 2000

const attack_range = 2.0

const attack_cooldown_ms = 1000

const arena_min = -70.0

const arena_max = 70.0

const spawn_distance_min = 15.0

const spawn_distance_max = 30.0

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  let model =
    Model(
      enemies: [],
      next_enemy_id: 0,
      spawn_timer: duration.milliseconds(0),
      spawn_interval: duration.milliseconds(spawn_interval_ms),
      player_pos: Vec3(0.0, 0.0, 0.0),
    )

  #(model, effect.dispatch(Tick))
}

// =============================================================================
// UPDATE
// =============================================================================

/// Update enemies. Accepts taggers for cross-module dispatch.
pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  player_took_damage player_took_damage,
  spawn_altar spawn_altar,
  effect_mapper effect_mapper,
) -> #(Model, effect.Effect(game_msg)) {
  case msg {
    Tick -> {
      let #(new_model, damage) = tick(model, ctx)
      let damage_effect = case damage >. 0.0 {
        True -> effect.dispatch(player_took_damage(damage))
        False -> effect.none()
      }
      #(new_model, effect.batch([effect.dispatch(effect_mapper(Tick)), damage_effect]))
    }

    UpdatePlayerPos(player_pos) -> {
      let model_with_pos = Model(..model, player_pos: player_pos)
      let model_with_velocities = calculate_velocities(model_with_pos)
      #(model_with_velocities, effect.none())
    }

    TakeProjectileDamage(enemy_id, damage) -> {
      let #(updated_enemies, death_effects) =
        list.fold(model.enemies, #([], []), fn(acc, enemy) {
          let #(enemies_acc, effects_acc) = acc
          case enemy.id == enemy_id {
            True -> {
              let new_health = health.damage(enemy.health, damage)
              case health.is_dead(new_health) {
                True -> {
                  // Enemy died - spawn altar at death position
                  let spawn_effect = effect.dispatch(spawn_altar(enemy.position))
                  #(enemies_acc, [spawn_effect, ..effects_acc])
                }
                False -> {
                  #(
                    [Enemy(..enemy, health: new_health), ..enemies_acc],
                    effects_acc,
                  )
                }
              }
            }
            False -> #([enemy, ..enemies_acc], effects_acc)
          }
        })
      #(Model(..model, enemies: updated_enemies), effect.batch(death_effects))
    }

    UpdatePositionsFromPhysics(positions, player_pos) -> {
      let updated_enemies =
        list.map(model.enemies, fn(enemy) {
          case list.find(positions, fn(p) { p.0 == enemy.id }) {
            Ok(#(_, new_pos)) -> Enemy(..enemy, position: new_pos)
            Error(_) -> enemy
          }
        })
      #(
        Model(..model, enemies: updated_enemies, player_pos: player_pos),
        effect.none(),
      )
    }
  }
}

// =============================================================================
// TICK
// =============================================================================

fn tick(model: Model, ctx: tiramisu.Context) -> #(Model, Float) {
  let dt = ctx.delta_time

  // Update spawn timer and spawn enemies
  let model = update_spawning(model, dt)

  // Move enemies toward player
  let model = update_movement(model, dt)

  // Check for enemy attacks on player (returns damage dealt)
  update_attacks(model, dt)
}

fn update_spawning(model: Model, dt: duration.Duration) -> Model {
  let new_timer = duration.add(model.spawn_timer, dt)

  case duration.compare(new_timer, model.spawn_interval) {
    order.Gt | order.Eq -> {
      // Time to spawn
      let new_enemy = spawn_enemy(model)
      Model(
        ..model,
        enemies: [new_enemy, ..model.enemies],
        next_enemy_id: model.next_enemy_id + 1,
        spawn_timer: duration.milliseconds(0),
      )
    }
    order.Lt -> Model(..model, spawn_timer: new_timer)
  }
}

fn spawn_enemy(model: Model) -> Enemy {
  // Spawn at random position around player, within arena bounds
  let angle = float.random() *. 2.0 *. 3.14159
  let distance =
    spawn_distance_min
    +. float.random()
    *. { spawn_distance_max -. spawn_distance_min }

  let spawn_x = model.player_pos.x +. maths.cos(angle) *. distance
  let spawn_z = model.player_pos.z +. maths.sin(angle) *. distance

  // Clamp to arena bounds
  let spawn_x = float.clamp(spawn_x, min: arena_min, max: arena_max)
  let spawn_z = float.clamp(spawn_z, min: arena_min, max: arena_max)

  Enemy(
    id: id.Enemy(model.next_enemy_id),
    position: Vec3(spawn_x, 1.0, spawn_z),
    health: health.new(default_enemy_health),
    damage: default_enemy_damage,
    speed: default_enemy_speed,
    attack_cooldown: duration.milliseconds(0),
    desired_velocity: Vec3(0.0, 0.0, 0.0),
  )
}

fn update_movement(model: Model, _dt: duration.Duration) -> Model {
  calculate_velocities(model)
}

/// Calculate desired velocities for all enemies based on player position
fn calculate_velocities(model: Model) -> Model {
  let updated_enemies =
    list.map(model.enemies, fn(enemy) {
      // Direction to player
      let to_player = vec3f.subtract(model.player_pos, enemy.position)
      let distance = vec3f.length(to_player)

      case distance >. attack_range {
        True -> {
          // Calculate velocity toward player
          let direction = vec3f.normalize(to_player)
          let velocity = vec3f.scale(direction, by: enemy.speed)
          Enemy(..enemy, desired_velocity: velocity)
        }
        False -> {
          // Stop moving when in attack range
          Enemy(..enemy, desired_velocity: Vec3(0.0, 0.0, 0.0))
        }
      }
    })

  Model(..model, enemies: updated_enemies)
}

fn update_attacks(model: Model, dt: duration.Duration) -> #(Model, Float) {
  let #(updated_enemies, total_damage) =
    list.fold(model.enemies, #([], 0.0), fn(acc, enemy) {
      let #(enemies_acc, damage_acc) = acc

      // Reduce cooldown
      let cooldown_secs = duration.to_seconds(enemy.attack_cooldown)
      let dt_secs = duration.to_seconds(dt)
      let new_cooldown_secs = float.max(0.0, cooldown_secs -. dt_secs)
      let new_cooldown =
        duration.milliseconds(float.round(new_cooldown_secs *. 1000.0))

      // Check if in range and can attack
      let to_player = vec3f.subtract(model.player_pos, enemy.position)
      let distance = vec3f.length(to_player)

      case distance <=. attack_range && new_cooldown_secs <=. 0.0 {
        True -> {
          let attacking_enemy =
            Enemy(
              ..enemy,
              attack_cooldown: duration.milliseconds(attack_cooldown_ms),
            )
          #([attacking_enemy, ..enemies_acc], damage_acc +. enemy.damage)
        }
        False -> {
          let updated_enemy = Enemy(..enemy, attack_cooldown: new_cooldown)
          #([updated_enemy, ..enemies_acc], damage_acc)
        }
      }
    })

  #(Model(..model, enemies: updated_enemies), total_damage)
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> List(scene.Node) {
  let assert option.Some(physics_world) = ctx.physics_world
  list.map(model.enemies, fn(enemy) { view_enemy(enemy, physics_world) })
}

fn view_enemy(enemy: Enemy, physics_world: physics.PhysicsWorld) -> scene.Node {
  let assert Ok(enemy_geo) = geometry.box(Vec3(1.5, 2.0, 1.5))

  // Color based on health percentage
  let health_pct = health.percentage(enemy.health)
  let color = case health_pct {
    p if p >. 0.6 -> 0xFF0000
    p if p >. 0.3 -> 0xFF6600
    _ -> 0xFF3300
  }

  let assert Ok(enemy_mat) =
    material.new()
    |> material.with_color(color)
    |> material.with_emissive(color)
    |> material.with_emissive_intensity(0.3)
    |> material.build()

  let body_id = id.to_string(enemy.id)

  let physics_body =
    physics.new_rigid_body(physics.Dynamic)
    |> physics.with_collider(physics.Capsule(
      offset: transform.identity,
      half_height: 1.0,
      radius: 0.75,
    ))
    |> physics.with_mass(50.0)
    |> physics.with_collision_groups(
      membership: [layer.enemy],
      can_collide_with: [
        layer.player,
        layer.map,
        layer.projectile,
        layer.enemy,
      ],
    )
    |> physics.with_collision_events()
    |> physics.with_lock_translation_y()
    |> physics.with_lock_rotation_x()
    |> physics.with_lock_rotation_z()
    |> physics.build()

  // Get transform from physics if body exists, otherwise use model position
  let enemy_transform = case physics.get_transform(physics_world, body_id) {
    Ok(t) -> t
    Error(_) -> transform.at(position: enemy.position)
  }

  // Create health bar CSS2D label
  let health_bar_label =
    scene.css2d(
      id: id.to_string(id.EnemyHealth(enemy.id)),
      html: element.to_string(view_enemy_health_bar(enemy.health)),
      transform: transform.at(position: Vec3(0.0, 1.5, 0.0)),
    )

  // Enemy mesh with physics body and health bar as child
  scene.mesh(
    id: body_id,
    geometry: enemy_geo,
    material: enemy_mat,
    transform: enemy_transform,
    physics: option.Some(physics_body),
  )
  |> scene.with_children([health_bar_label])
}

fn view_enemy_health_bar(enemy_health: health.Health) -> element.Element(Nil) {
  let percentage = health.percentage(enemy_health) *. 100.0
  let percentage_str = float.to_string(percentage)
  let current_str = int.to_string(float.round(health.current(enemy_health)))
  let max_str = int.to_string(float.round(health.max(enemy_health)))

  // Bar color based on health (using hex for inline style)
  let bar_color = case health.percentage(enemy_health) {
    p if p >. 0.6 -> "#22c55e"
    p if p >. 0.3 -> "#eab308"
    _ -> "#ef4444"
  }

  let bar_style =
    "width: "
    <> percentage_str
    <> "%; background-color: "
    <> bar_color
    <> "; height: 100%;"

  html.div([class("flex flex-col items-center")], [
    // Health bar container
    html.div(
      [
        attribute(
          "style",
          "width: 48px; height: 6px; background-color: #1f2937; border-radius: 4px; overflow: hidden;",
        ),
      ],
      [html.div([attribute("style", bar_style)], [])],
    ),
    // Health text
    html.div(
      [
        attribute(
          "style",
          "font-size: 8px; color: white; font-family: monospace; margin-top: 2px;",
        ),
      ],
      [element.text(current_str <> "/" <> max_str)],
    ),
  ])
}

// =============================================================================
// PUBLIC HELPERS
// =============================================================================

/// Get enemies with their desired velocities for physics
pub fn get_enemies_for_physics(model: Model) -> List(#(id.Id, Vec3(Float))) {
  list.map(model.enemies, fn(e) { #(e.id, e.desired_velocity) })
}

/// Update player position and calculate velocities synchronously
/// Returns updated model and velocities for physics
pub fn update_for_physics(
  model: Model,
  player_pos: Vec3(Float),
) -> #(Model, List(#(id.Id, Vec3(Float)))) {
  let model_with_pos = Model(..model, player_pos: player_pos)
  let model_with_velocities = calculate_velocities(model_with_pos)
  let velocities = get_enemies_for_physics(model_with_velocities)
  #(model_with_velocities, velocities)
}

pub fn id(enemy: Enemy) -> id.Id {
  enemy.id
}
