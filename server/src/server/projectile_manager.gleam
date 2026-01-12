/// Server-side projectile spawning, movement, and collision detection.
import gleam/dict
import gleam/option
import server/game_state
import shared/damage
import shared/enemy
import shared/health
import shared/id
import shared/projectile
import vec/vec3
import vec/vec3f

/// Result of updating projectile movement and collisions
pub type UpdateResult {
  UpdateResult(
    state: game_state.GameState,
    damage_events: List(damage.Damage),
    enemy_deaths: List(Int),
    projectile_removals: List(Int),
  )
}

/// Spawn a new projectile from a player's spell cast
pub fn spawn_projectile(
  state: game_state.GameState,
  owner_id: id.Id,
  position: vec3.Vec3(Float),
  direction: vec3.Vec3(Float),
  damage_amount: Float,
  speed: Float,
  size: Float,
  lifetime: Float,
) -> #(game_state.GameState, projectile.Projectile) {
  let new_projectile =
    projectile.Projectile(
      id: state.next_projectile_id,
      owner_id: owner_id,
      position: position,
      direction: direction,
      damage: damage_amount,
      speed: speed,
      size: size,
      lifetime: lifetime,
    )

  let new_state =
    game_state.GameState(
      ..state,
      projectiles: dict.insert(
        state.projectiles,
        new_projectile.id,
        new_projectile,
      ),
      next_projectile_id: state.next_projectile_id + 1,
    )

  #(new_state, new_projectile)
}

/// Update all projectiles: move them, check collisions, and remove expired ones
pub fn update_projectiles(
  state: game_state.GameState,
  dt: Float,
) -> UpdateResult {
  // Convert dt from seconds to milliseconds for lifetime tracking
  let dt_ms = dt *. 1000.0

  let #(
    new_projectiles,
    damage_events,
    enemy_deaths,
    projectile_removals,
    new_enemies,
  ) =
    dict.fold(
      state.projectiles,
      #(dict.new(), [], [], [], state.enemies),
      fn(acc, proj_id, proj) {
        let #(projs, damages, deaths, removals, enemies) = acc

        // Update lifetime
        let new_lifetime = proj.lifetime -. dt_ms

        // Check if projectile expired
        case new_lifetime <=. 0.0 {
          True -> {
            // Remove projectile
            #(projs, damages, deaths, [proj_id, ..removals], enemies)
          }
          False -> {
            // Move projectile
            let vec3.Vec3(px, py, pz) = proj.position
            let vec3.Vec3(dx, dy, dz) = proj.direction
            let new_pos =
              vec3.Vec3(
                px +. dx *. proj.speed *. dt,
                py +. dy *. proj.speed *. dt,
                pz +. dz *. proj.speed *. dt,
              )

            let moved_proj = projectile.Projectile(..proj, position: new_pos)

            // Check collision with enemies
            let #(hit_enemy_id, new_enemies_after_hit) =
              check_projectile_enemy_collision(
                moved_proj,
                enemies,
                state.config.arena_min,
                state.config.arena_max,
              )

            case hit_enemy_id {
              option.Some(enemy_id) -> {
                // Get enemy to create damage event
                case dict.get(enemies, enemy_id) {
                  Ok(enemy_hit) -> {
                    // Get updated enemy to check if it died
                    case dict.get(new_enemies_after_hit, enemy_id) {
                      Ok(_) -> {
                        // Enemy still alive - create damage event
                        let damage_event =
                          damage.Damage(
                            enemy_id: id.to_serial(enemy_id),
                            damage: proj.damage,
                            remaining_health: health.current(enemy_hit.health)
                              -. proj.damage,
                            source_player_id: option.Some(proj.owner_id),
                          )
                        #(
                          projs,
                          [damage_event, ..damages],
                          deaths,
                          [proj_id, ..removals],
                          new_enemies_after_hit,
                        )
                      }
                      Error(_) -> {
                        // Enemy died - add to death list
                        let damage_event =
                          damage.Damage(
                            enemy_id: id.to_serial(enemy_id),
                            damage: proj.damage,
                            remaining_health: 0.0,
                            source_player_id: option.Some(proj.owner_id),
                          )
                        #(
                          projs,
                          [damage_event, ..damages],
                          [id.to_serial(enemy_id), ..deaths],
                          [proj_id, ..removals],
                          new_enemies_after_hit,
                        )
                      }
                    }
                  }
                  Error(_) -> {
                    // Shouldn't happen, but remove projectile anyway
                    #(
                      projs,
                      damages,
                      deaths,
                      [proj_id, ..removals],
                      new_enemies_after_hit,
                    )
                  }
                }
              }
              option.None -> {
                // No collision - update projectile lifetime and keep it
                let updated_proj =
                  projectile.Projectile(..moved_proj, lifetime: new_lifetime)
                #(
                  dict.insert(projs, proj_id, updated_proj),
                  damages,
                  deaths,
                  removals,
                  enemies,
                )
              }
            }
          }
        }
      },
    )

  UpdateResult(
    state: game_state.GameState(
      ..state,
      projectiles: new_projectiles,
      enemies: new_enemies,
    ),
    damage_events: damage_events,
    enemy_deaths: enemy_deaths,
    projectile_removals: projectile_removals,
  )
}

/// Check if a projectile collides with any enemy
/// Returns the hit enemy ID and updated enemies dict (with damaged/removed enemy)
fn check_projectile_enemy_collision(
  proj: projectile.Projectile,
  enemies: dict.Dict(id.Id, enemy.Enemy),
  arena_min: Float,
  arena_max: Float,
) -> #(option.Option(id.Id), dict.Dict(id.Id, enemy.Enemy)) {
  // Check if projectile is out of bounds
  let vec3.Vec3(px, _, pz) = proj.position
  case
    px <. arena_min || px >. arena_max || pz <. arena_min || pz >. arena_max
  {
    True -> #(option.None, enemies)
    False -> {
      // Check collision with each enemy
      let result =
        dict.fold(
          enemies,
          #(option.None, enemies),
          fn(acc, enemy_id, enemy_item) {
            let #(found_hit, current_enemies) = acc

            // If we already found a hit, skip
            case found_hit {
              option.Some(_) -> acc
              option.None -> {
                // Calculate distance to enemy
                let dist = vec3f.distance(proj.position, enemy_item.position)

                // Collision threshold based on actual visual sizes:
                // - Projectile: 1.0 box = 0.5 radius
                // - Enemy: 1.5 box width = 0.75 radius
                // Total threshold = 0.5 + 0.75 = 1.25
                let projectile_radius = 0.5
                let enemy_radius = 0.75
                let collision_threshold = projectile_radius +. enemy_radius

                case dist <. collision_threshold {
                  False -> acc
                  True -> {
                    // Apply damage to enemy
                    let new_health =
                      health.damage(enemy_item.health, proj.damage)

                    case health.is_dead(new_health) {
                      False -> {
                        // Enemy still alive - update health
                        let updated_enemy =
                          enemy.Enemy(..enemy_item, health: new_health)
                        let updated_enemies =
                          dict.insert(current_enemies, enemy_id, updated_enemy)
                        #(option.Some(enemy_id), updated_enemies)
                      }
                      True -> {
                        // Enemy died - remove from dict
                        let updated_enemies =
                          dict.delete(current_enemies, enemy_id)
                        #(option.Some(enemy_id), updated_enemies)
                      }
                    }
                  }
                }
              }
            }
          },
        )

      result
    }
  }
}
