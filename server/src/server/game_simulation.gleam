/// Server-side game simulation logic.
/// Processes player inputs and updates game state every tick (20 Hz).
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/time/duration
import shared/enemy
import shared/game_messages.{type PlayerAction}
import shared/game_state.{type GameState}
import shared/player
import shared/projectile
import shared/spell
import shared/wand
import vec/vec3f

// =============================================================================
// TYPES
// =============================================================================

/// Events that occur during simulation (for broadcasting to clients)
pub type GameEvent {
  ProjectileCreated(projectile: projectile.Projectile)
  ProjectileDestroyed(id: projectile.Id, reason: DestroyReason)
  EnemySpawned(enemy: enemy.Enemy)
  EnemyDied(id: enemy.Id)
  PlayerDamaged(player_id: player.Id, damage: Float, new_health: Float)
}

pub type DestroyReason {
  HitEnemy(enemy_id: enemy.Id)
  HitPlayer(player_id: player.Id)
  Expired
}

// =============================================================================
// MAIN SIMULATION
// =============================================================================

/// Main simulation tick function - processes all game logic for one frame
pub fn tick(
  game_state: GameState,
  player_inputs: Dict(player.Id, PlayerAction),
  delta_time: duration.Duration,
) -> #(GameState, List(GameEvent)) {
  // Start with empty event list
  let events = []

  // 1. Process player inputs (movement, wand switching, casting)
  let #(new_game_state, input_events) =
    process_player_inputs(
      game_state,
      player_inputs,
      game_state.next_projectile_id,
    )
  let events = list.append(events, input_events)

  // Add any created projectiles to the game state
  let new_game_state = apply_events_to_state(new_game_state, input_events)

  // 2. Simulate player movement (move toward target positions)
  let new_game_state = simulate_player_movement(new_game_state, delta_time)

  // 3. Simulate projectile movement
  let #(new_game_state, projectile_events) =
    simulate_projectiles(new_game_state, delta_time)
  let events = list.append(events, projectile_events)

  // 4. Simulate enemy movement (move toward target players)
  let new_game_state = simulate_enemy_movement(new_game_state, delta_time)

  // 5. Check collisions (projectile vs enemy, enemy vs player)
  let #(new_game_state, collision_events) = check_collisions(new_game_state)
  let events = list.append(events, collision_events)

  // 6. Enemy spawning (TODO: implement spawn logic)
  // let #(new_game_state, spawn_events) = spawn_enemies(new_game_state)
  // let events = list.append(events, spawn_events)

  #(new_game_state, events)
}

// =============================================================================
// PLAYER INPUT PROCESSING
// =============================================================================

/// Process all player inputs for this tick
fn process_player_inputs(
  game_state: GameState,
  player_inputs: Dict(player.Id, PlayerAction),
  next_projectile_id: Int,
) -> #(GameState, List(GameEvent)) {
  // Process each player's input
  let #(new_players, events, final_projectile_id) =
    dict.fold(
      player_inputs,
      #(game_state.players, [], next_projectile_id),
      fn(acc, player_id, action) {
        let #(players, events, proj_id_counter) = acc

        case dict.get(players, player_id) {
          Error(_) -> acc
          // Player not found, skip
          Ok(player_state) -> {
            process_player_action(
              players,
              events,
              player_id,
              player_state,
              action,
              proj_id_counter,
            )
          }
        }
      },
    )

  #(
    game_state.GameState(
      ..game_state,
      players: new_players,
      next_projectile_id: final_projectile_id,
    ),
    events,
  )
}

/// Process a single player's action
fn process_player_action(
  players: Dict(player.Id, player.Player),
  events: List(GameEvent),
  player_id: player.Id,
  player_state: player.Player,
  action: PlayerAction,
  next_projectile_id: Int,
) -> #(Dict(player.Id, player.Player), List(GameEvent), Int) {
  case action {
    game_messages.None -> #(players, events, next_projectile_id)

    game_messages.MoveToPosition(target) -> {
      // Set player to moving state with default speed
      let movement_speed = 10.0
      // units per second
      let new_movement_state = player.MovingToPosition(target, movement_speed)
      let updated_player =
        player.Player(..player_state, movement_state: new_movement_state)
      let new_players = dict.insert(players, player_id, updated_player)
      #(new_players, events, next_projectile_id)
    }

    game_messages.SwitchWand(slot) -> {
      // Validate slot is 0-3
      case slot >= 0 && slot <= 3 {
        True -> {
          let updated_player =
            player.Player(..player_state, active_wand_slot: slot)
          let new_players = dict.insert(players, player_id, updated_player)
          #(new_players, events, next_projectile_id)
        }
        False -> #(players, events, next_projectile_id)
        // Invalid slot, ignore
      }
    }

    game_messages.CastSpell(target) -> {
      // Get the active wand
      let wand_option = get_active_wand(player_state)

      case wand_option {
        None -> #(players, events, next_projectile_id)
        // No wand equipped
        Some(active_wand) -> {
          // Calculate direction from player to target
          let direction = vec3f.direction(player_state.position, to: target)

          // Cast from the wand using current projectile ID counter
          let #(cast_result, updated_wand) =
            wand.cast(
              active_wand,
              0,
              // Start from beginning of wand
              player_state.position,
              direction,
              next_projectile_id,
              // Use proper projectile ID counter
              Some(target),
              Some(player_state.position),
              [],
              // TODO: Pass existing projectiles for collision avoidance
            )

          case cast_result {
            wand.CastSuccess(projectiles, _remaining_mana, _next_cast_index, ..) -> {
              // Update player's wand
              let updated_player =
                update_player_wand(
                  player_state,
                  player_state.active_wand_slot,
                  updated_wand,
                )
              let new_players = dict.insert(players, player_id, updated_player)

              // Convert spell.Projectile to shared/projectile.Projectile and create events
              // Increment projectile ID for each projectile created
              let #(new_events, final_id) =
                list.fold(
                  projectiles,
                  #([], next_projectile_id),
                  fn(acc, spell_projectile) {
                    let #(event_list, current_id) = acc
                    let projectile =
                      spell_projectile_to_game_projectile(
                        spell_projectile,
                        player_id,
                      )
                    let event = ProjectileCreated(projectile)
                    #(list.append(event_list, [event]), current_id + 1)
                  },
                )

              #(new_players, list.append(events, new_events), final_id)
            }

            // Failed to cast - don't update anything
            _ -> #(players, events, next_projectile_id)
          }
        }
      }
    }
  }
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Apply events to the game state (add/remove entities based on events)
fn apply_events_to_state(
  game_state: GameState,
  events: List(GameEvent),
) -> GameState {
  list.fold(events, game_state, fn(state, event) {
    case event {
      ProjectileCreated(projectile) -> {
        let new_projectiles =
          dict.insert(state.projectiles, projectile.id, projectile)
        game_state.GameState(..state, projectiles: new_projectiles)
      }

      ProjectileDestroyed(id, _reason) -> {
        let new_projectiles = dict.delete(state.projectiles, id)
        game_state.GameState(..state, projectiles: new_projectiles)
      }

      EnemyDied(id) -> {
        let new_enemies = dict.delete(state.enemies, id)
        game_state.GameState(..state, enemies: new_enemies)
      }

      // These events don't modify game state
      EnemySpawned(_) | PlayerDamaged(..) -> state
    }
  })
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Get the active wand from a player's inventory
fn get_active_wand(player_state: player.Player) -> option.Option(wand.Wand) {
  case player_state.active_wand_slot {
    0 -> player_state.wands.slot_0
    1 -> player_state.wands.slot_1
    2 -> player_state.wands.slot_2
    3 -> player_state.wands.slot_3
    _ -> None
  }
}

/// Update a player's wand in the specified slot
fn update_player_wand(
  player_state: player.Player,
  slot: Int,
  new_wand: wand.Wand,
) -> player.Player {
  let new_wands = case slot {
    0 -> player.WandInventory(..player_state.wands, slot_0: Some(new_wand))
    1 -> player.WandInventory(..player_state.wands, slot_1: Some(new_wand))
    2 -> player.WandInventory(..player_state.wands, slot_2: Some(new_wand))
    3 -> player.WandInventory(..player_state.wands, slot_3: Some(new_wand))
    _ -> player_state.wands
    // Invalid slot
  }

  player.Player(..player_state, wands: new_wands)
}

/// Convert a spell.Projectile to a shared/projectile.Projectile
fn spell_projectile_to_game_projectile(
  spell_proj: spell.Projectile,
  owner_id: player.Id,
) -> projectile.Projectile {
  // Calculate velocity from direction and spell speed
  let speed = case spell_proj.spell.base {
    spell.DamageSpell(kind: damage_spell, ..) ->
      case damage_spell {
        spell.Damage(projectile_speed: speed, ..) -> speed
      }
    _ -> 100.0
    // Default speed (shouldn't happen - modifiers/multicasts don't create projectiles)
  }

  let velocity = vec3f.scale(spell_proj.direction, by: speed)

  projectile.Projectile(
    id: projectile.Id(spell_proj.id),
    owner_id: owner_id,
    spell: spell_proj.spell,
    position: spell_proj.position,
    velocity: velocity,
    time_alive: spell_proj.time_alive,
    visuals: spell_proj.visuals,
    trigger_payload: spell_proj.trigger_payload,
  )
}

// =============================================================================
// MOVEMENT SIMULATION
// =============================================================================

/// Simulate player movement based on movement_state
fn simulate_player_movement(
  game_state: GameState,
  delta_time: duration.Duration,
) -> GameState {
  let dt_seconds = duration.to_seconds(delta_time)

  let new_players =
    dict.map_values(game_state.players, fn(_player_id, player_state) {
      case player_state.movement_state {
        player.Idle -> player_state

        player.MovingToPosition(target, speed) -> {
          // Calculate distance to target
          let current_pos = player_state.position
          let distance = vec3f.distance(current_pos, with: target)

          // How far we can move this frame
          let max_movement = speed *. dt_seconds

          case distance <=. 0.1 || max_movement >=. distance {
            // Reached target - snap to position and stop
            True ->
              player.Player(
                ..player_state,
                position: target,
                movement_state: player.Idle,
              )

            // Still moving - move toward target
            False -> {
              let direction = vec3f.direction(current_pos, to: target)
              let movement_vec = vec3f.scale(direction, by: max_movement)
              let new_pos = vec3f.add(current_pos, movement_vec)

              player.Player(..player_state, position: new_pos)
            }
          }
        }
      }
    })

  game_state.GameState(..game_state, players: new_players)
}

/// Simulate enemy movement (move toward target player)
fn simulate_enemy_movement(
  game_state: GameState,
  _delta_time: duration.Duration,
) -> GameState {
  // TODO: For each enemy with a target_player:
  // - Find target player position
  // - Calculate direction vector
  // - Move enemy by speed * delta_time
  // - Update enemy velocity
  game_state
}

// =============================================================================
// PROJECTILE SIMULATION
// =============================================================================

/// Simulate projectile movement and lifetime
fn simulate_projectiles(
  game_state: GameState,
  delta_time: duration.Duration,
) -> #(GameState, List(GameEvent)) {
  let dt_seconds = duration.to_seconds(delta_time)

  // Process all projectiles, updating position and checking lifetime
  let #(updated_projectiles, destroyed_events) =
    dict.fold(
      game_state.projectiles,
      #(dict.new(), []),
      fn(acc, proj_id, projectile) {
        let #(projectiles_acc, events_acc) = acc

        // Get the lifetime from the spell
        let lifetime = case projectile.spell.base {
          spell.DamageSpell(kind: damage_spell, ..) ->
            case damage_spell {
              spell.Damage(projectile_lifetime: lifetime, ..) -> lifetime
            }
          _ -> duration.seconds(5)
          // Default 5 seconds
        }

        // Update time alive
        let new_time_alive = duration.add(projectile.time_alive, delta_time)

        // Check if expired
        case duration.compare(new_time_alive, lifetime) {
          order.Gt | order.Eq -> {
            // Projectile expired - remove it and create event
            let event = ProjectileDestroyed(proj_id, Expired)
            #(projectiles_acc, [event, ..events_acc])
          }

          order.Lt -> {
            // Still alive - move it
            let movement = vec3f.scale(projectile.velocity, by: dt_seconds)
            let new_position = vec3f.add(projectile.position, movement)

            let updated_projectile =
              projectile.Projectile(
                ..projectile,
                position: new_position,
                time_alive: new_time_alive,
              )

            let new_projectiles =
              dict.insert(projectiles_acc, proj_id, updated_projectile)
            #(new_projectiles, events_acc)
          }
        }
      },
    )

  #(
    game_state.GameState(..game_state, projectiles: updated_projectiles),
    destroyed_events,
  )
}

// =============================================================================
// COLLISION DETECTION
// =============================================================================

/// Check all collisions and apply damage
fn check_collisions(game_state: GameState) -> #(GameState, List(GameEvent)) {
  // TODO: Implement collision detection:
  // 1. Projectile vs Enemy collisions
  //    - Check distance between each projectile and enemy
  //    - Apply damage to enemy
  //    - Remove projectile
  //    - Create ProjectileDestroyed(HitEnemy) event
  //    - If enemy health <= 0, create EnemyDied event
  // 2. Enemy vs Player collisions
  //    - Check distance between each enemy and player
  //    - Apply contact damage to player
  //    - Create PlayerDamaged event
  #(game_state, [])
}
