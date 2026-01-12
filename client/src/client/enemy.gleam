import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/time/duration
import lustre/attribute.{attribute, class}
import lustre/element
import lustre/element/html
import shared/enemy
import tiramisu
import tiramisu/effect
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

import shared/health
import shared/id

// =============================================================================
// TYPES
// =============================================================================

pub type LocalEnemy {
  LocalEnemy(enemy: enemy.Enemy, position: Vec3(Float))
}

pub type Model {
  Model(
    enemies: List(LocalEnemy),
    player_pos: Vec3(Float),
    /// Shared rendering resources (created once in init)
    enemy_geometry: geometry.Geometry,
  )
}

pub type Msg {
  Tick
  PlayerPositionUpdated(player_pos: Vec3(Float))
  /// Server: Full game state received (on join or reconciliation)
  FullGameStateReceived(enemies: List(enemy.Enemy))
  /// Server: New enemy spawned
  ServerEnemySpawned(id: id.Id, position: Vec3(Float))
  /// Server: Enemy positions updated
  ServerEnemiesUpdated(updates: List(enemy.Delta))
  /// Server: Enemy died
  ServerEnemyDied(id: Int)
  /// Local: Enemy was hit by a projectile (for local feedback)
  ProjectileHasHitEnemy(enemy_id: id.Id, damage: Float)
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  // Create shared rendering resources once
  let assert Ok(enemy_geo) = geometry.box(Vec3(1.5, 2.0, 1.5))

  let model =
    Model(
      enemies: [],
      player_pos: Vec3(0.0, 0.0, 0.0),
      enemy_geometry: enemy_geo,
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
  effect_mapper effect_mapper: fn(Msg) -> game_msg,
) -> #(Model, effect.Effect(game_msg)) {
  case msg {
    Tick -> {
      #(
        tick(model, ctx),
        effect.batch([
          effect.dispatch(effect_mapper(Tick)),
        ]),
      )
    }

    PlayerPositionUpdated(player_pos) -> {
      #(Model(..model, player_pos: player_pos), effect.none())
    }

    FullGameStateReceived(enemy_states) -> {
      let enemies =
        list.map(enemy_states, fn(enemy_state) {
          LocalEnemy(enemy: enemy_state, position: enemy_state.position)
        })
      #(Model(..model, enemies: enemies), effect.none())
    }

    ServerEnemySpawned(server_id, position) -> {
      // Create new enemy from server data - no local velocity calculation
      let new_enemy = LocalEnemy(enemy: enemy.new(server_id), position:)
      #(Model(..model, enemies: [new_enemy, ..model.enemies]), effect.none())
    }

    ServerEnemiesUpdated(updates) -> {
      // Update target positions from server updates
      // Actual position will be interpolated in Tick
      let updated_enemies =
        list.map(model.enemies, fn(local_enemy) {
          case list.find(updates, fn(u) { u.id == local_enemy.enemy.id }) {
            Ok(update) ->
              LocalEnemy(
                ..local_enemy,
                enemy: enemy.Enemy(
                  ..local_enemy.enemy,
                  position: update.position,
                ),
              )
            Error(_) -> local_enemy
          }
        })
      #(Model(..model, enemies: updated_enemies), effect.none())
    }

    ServerEnemyDied(server_id) -> {
      // Remove enemy and spawn altar at death position
      let #(remaining, death_effects) =
        list.fold(model.enemies, #([], []), fn(acc, local_enemy) {
          let #(enemies_acc, effects_acc) = acc
          case local_enemy.enemy.id |> id.to_serial == server_id {
            True -> {
              // Enemy died - spawn altar at death position
              #(enemies_acc, effects_acc)
            }
            False -> #([local_enemy, ..enemies_acc], effects_acc)
          }
        })
      #(Model(..model, enemies: remaining), effect.batch(death_effects))
    }

    ProjectileHasHitEnemy(enemy_id, damage) -> {
      // Local damage feedback - for now just reduce health locally
      // Server will send authoritative health updates later
      let #(updated_enemies, death_effects) =
        list.fold(model.enemies, #([], []), fn(acc, local_enemy) {
          let #(enemies_acc, effects_acc) = acc
          case local_enemy.enemy.id == enemy_id {
            True -> {
              let new_health = health.damage(local_enemy.enemy.health, damage)
              case health.is_dead(new_health) {
                True -> {
                  #(enemies_acc, effects_acc)
                }
                False -> {
                  #(
                    [
                      LocalEnemy(
                        ..local_enemy,
                        enemy: enemy.Enemy(
                          ..local_enemy.enemy,
                          health: new_health,
                        ),
                      ),
                      ..enemies_acc
                    ],
                    effects_acc,
                  )
                }
              }
            }
            False -> #([local_enemy, ..enemies_acc], effects_acc)
          }
        })
      #(Model(..model, enemies: updated_enemies), effect.batch(death_effects))
    }
  }
}

// =============================================================================
// TICK
// =============================================================================

fn tick(model: Model, ctx: tiramisu.Context) -> Model {
  let dt = ctx.delta_time

  // Interpolate enemy positions toward server targets
  let interpolated_enemies = interpolate_enemy_positions(model.enemies, dt)
  Model(..model, enemies: interpolated_enemies)
}

/// Smoothly interpolate enemy positions toward their target positions
fn interpolate_enemy_positions(
  enemies: List(LocalEnemy),
  _dt: duration.Duration,
) -> List(LocalEnemy) {
  let alpha = 0.25

  list.map(enemies, fn(local_enemy) {
    // Calculate distance to target
    let delta = vec3f.subtract(local_enemy.enemy.position, local_enemy.position)
    let distance = vec3f.length(delta)

    // If very close, snap to target to avoid floating point drift
    case distance <. 0.01 {
      True -> LocalEnemy(..local_enemy, position: local_enemy.enemy.position)
      False -> {
        // Lerp toward target
        let movement = vec3f.scale(delta, by: alpha)
        let new_position = vec3f.add(local_enemy.position, movement)
        LocalEnemy(..local_enemy, position: new_position)
      }
    }
  })
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> List(scene.Node) {
  let assert option.Some(physics_world) = ctx.physics_world
  list.map(model.enemies, fn(enemy) {
    view_enemy(enemy, physics_world, model.enemy_geometry)
  })
}

fn view_enemy(
  enemy: LocalEnemy,
  _physics_world: physics.PhysicsWorld,
  enemy_geo: geometry.Geometry,
) -> scene.Node {
  // Color based on health percentage
  let health_pct = health.percentage(enemy.enemy.health)
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

  let body_id = id.to_string(enemy.enemy.id)

  // Use interpolated render position directly (no physics simulation for enemies)
  // Server is authoritative for all movement and logic
  let enemy_transform = transform.at(position: enemy.position)

  // Create health bar CSS2D label
  let health_bar_label =
    scene.css2d(
      id: id.to_string(id.EnemyHealth(enemy.enemy.id)),
      html: element.to_string(view_enemy_health_bar(enemy.enemy.health)),
      transform: transform.at(position: Vec3(0.0, 1.5, 0.0)),
    )

  // Enemy mesh WITHOUT physics - just a visual representation
  // Server handles all collision detection and logic
  scene.mesh(
    id: body_id,
    geometry: enemy_geo,
    material: enemy_mat,
    transform: enemy_transform,
    physics: option.None,
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
