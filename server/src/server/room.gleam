/// Game room actor - manages game state and player connections using OTP/ewe with PlayerActors
import ewe
import expresso/body
import expresso/world
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/otp/actor
import gleam/otp/factory_supervisor
import gleam/result
import gleam/time/duration.{type Duration}
import gleam/time/timestamp
import gleam_community/maths
import logging.{Info}
import spatial/bvh
import spatial/collider
import vec/vec2
import vec/vec3.{Vec3}

import server/enemy as enemy_actor
import server/player as player_actor
import server/projectile as projectile_actor
import server/tick
import server/wand as wand_actor

import shared/enemy
import shared/game_message
import shared/player
import shared/projectile

// =============================================================================
// STATE
// =============================================================================

/// Tick collection state - tracks all actor responses during tick
pub type TickState {
  /// Not collecting - normal operation
  Idle
  /// Collecting all actor state responses for current tick
  Collecting(
    /// Number of players we're waiting for
    expected_player_count: Int,
    /// Player states received so far
    player_responses: Dict(player.Id, player.Player),
    /// Projectile states collected this tick (updated as they respond)
    projectile_responses: Dict(projectile.Id, projectile.Projectile),
    /// Enemy states collected this tick (updated as they respond)
    enemy_responses: Dict(enemy.Id, enemy.Enemy),
    /// Current tick number
    tick_number: Int,
  )
}

/// Enemy spawn configuration
pub type SpawnConfig {
  SpawnConfig(
    /// How many ticks between enemy waves (20 ticks = 1 second)
    spawn_interval_ticks: Int,
    /// Number of enemies to spawn per wave
    enemies_per_wave: Int,
    /// Distance from player to spawn enemies (meters)
    spawn_radius_min: Float,
    spawn_radius_max: Float,
    /// Total waves spawned (for difficulty scaling)
    waves_spawned: Int,
  )
}

/// Game room state
pub type State {
  State(
    // Lightweight connection-to-player-ID mapping (for routing messages)
    connection_to_player: dict.Dict(ewe.WebsocketConnection, player.Id),
    // Connection info (for sending messages)
    connections: dict.Dict(ewe.WebsocketConnection, ConnectionInfo),
    next_player_id: Int,
    next_projectile_id: Int,
    next_enemy_id: Int,
    // Player actors (replaces game_state.players)
    player_actors: Dict(player.Id, process.Subject(player_actor.Msg)),
    // Projectile actors (replaces game_state.projectiles)
    projectile_actors: Dict(
      projectile.Id,
      process.Subject(projectile_actor.Msg),
    ),
    // Enemy actors (replaces game_state.enemies)
    enemy_actors: Dict(enemy.Id, process.Subject(enemy_actor.Msg)),
    // Cached player positions from previous tick (for enemy AI)
    last_player_positions: Dict(player.Id, vec3.Vec3(Float)),
    // Cached enemy positions from previous tick (for enemy separation)
    last_enemy_positions: Dict(enemy.Id, vec3.Vec3(Float)),
    // Physics world for collision resolution (String IDs for bodies)
    physics_world: world.World(String),
    // Tick collection state (ephemeral - only during tick processing)
    tick_state: TickState,
    tick_scheduler: tick.TickScheduler,
    // Debug: Last tick timestamp for measuring actual tick intervals
    last_tick_timestamp: timestamp.Timestamp,
    // Enemy spawning state
    spawn_config: SpawnConfig,
    ticks_until_spawn: Int,
    // Factory supervisors for spawning actors
    player_factory: factory_supervisor.Supervisor(
      player_actor.SpawnArguments(Msg),
      process.Subject(player_actor.Msg),
    ),
    projectile_factory: factory_supervisor.Supervisor(
      projectile_actor.SpawnArguments(Msg),
      process.Subject(projectile_actor.Msg),
    ),
    enemy_factory: factory_supervisor.Supervisor(
      enemy_actor.SpawnArguments(Msg),
      process.Subject(enemy_actor.Msg),
    ),
    wand_factory: factory_supervisor.Supervisor(
      wand_actor.SpawnArguments(player_actor.Msg),
      process.Subject(wand_actor.Msg),
    ),
    self: process.Subject(Msg),
  )
}

/// Messages sent to WebSocket connection handler
pub type OutgoingMsg {
  SendFrame(BitArray)
  Disconnect
}

/// Connection info stored for each player
pub type ConnectionInfo {
  ConnectionInfo(
    conn: ewe.WebsocketConnection,
    outgoing: process.Subject(OutgoingMsg),
  )
}

/// Actor messages
pub type Msg {
  // Tick message for game loop
  Tick
  // Finalize tick after collecting player states (or timeout)
  FinalizeTick
  // Client connected
  ClientConnected(ewe.WebsocketConnection, process.Subject(OutgoingMsg))
  // Client disconnected
  ClientDisconnected(ewe.WebsocketConnection)
  // Message from client
  ClientMessage(ewe.WebsocketConnection, BitArray)
  // Messages FROM PlayerActors
  PlayerMessage(player_actor.ToRoomMsg)
  // Messages FROM ProjectileActors
  ProjectileMessage(projectile_actor.ToRoomMsg)
  // Messages FROM EnemyActors
  EnemyMessage(enemy_actor.ToRoomMsg)
  // Spawn enemy at position
  SpawnEnemy(position: vec3.Vec3(Float))
}

// =============================================================================
// ACTOR LIFECYCLE
// =============================================================================

/// Start a new game room actor
pub fn start(
  name: process.Name(Msg),
  player_factory_name: process.Name(
    factory_supervisor.Message(
      player_actor.SpawnArguments(Msg),
      process.Subject(player_actor.Msg),
    ),
  ),
  projectile_factory_name: process.Name(
    factory_supervisor.Message(
      projectile_actor.SpawnArguments(Msg),
      process.Subject(projectile_actor.Msg),
    ),
  ),
  enemy_factory_name: process.Name(
    factory_supervisor.Message(
      enemy_actor.SpawnArguments(Msg),
      process.Subject(enemy_actor.Msg),
    ),
  ),
  wand_factory_name: process.Name(
    factory_supervisor.Message(
      wand_actor.SpawnArguments(player_actor.Msg),
      process.Subject(wand_actor.Msg),
    ),
  ),
) -> Result(actor.Started(process.Subject(Msg)), actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    // Get references to all factory supervisors
    let player_factory = factory_supervisor.get_by_name(player_factory_name)
    let projectile_factory =
      factory_supervisor.get_by_name(projectile_factory_name)
    let enemy_factory = factory_supervisor.get_by_name(enemy_factory_name)
    let wand_factory = factory_supervisor.get_by_name(wand_factory_name)

    // Enemy spawn configuration
    // Disabled automatic spawning - we spawn 500 enemies on first join for benchmarking
    let spawn_config =
      SpawnConfig(
        spawn_interval_ticks: 999_999,
        // Effectively disabled
        enemies_per_wave: 3,
        spawn_radius_min: 10.0,
        spawn_radius_max: 15.0,
        waves_spawned: 0,
      )

    // Initialize physics world (2D, no gravity for top-down gameplay)
    let physics_world =
      world.new(gravity: vec2.Vec2(0.0, 0.0))
      |> world.with_iterations(2)
      // Reduced: substeps + relaxation handle stability
      |> world.with_restitution(0.0)
      |> world.with_substeps(3)
    // 3 substeps for 500+ enemies with chain collisions

    let state =
      State(
        connection_to_player: dict.new(),
        connections: dict.new(),
        next_player_id: 1,
        next_projectile_id: 1,
        next_enemy_id: 1,
        player_actors: dict.new(),
        projectile_actors: dict.new(),
        enemy_actors: dict.new(),
        last_player_positions: dict.new(),
        last_enemy_positions: dict.new(),
        physics_world: physics_world,
        tick_state: Idle,
        tick_scheduler: tick.new(timestamp.system_time()),
        last_tick_timestamp: timestamp.system_time(),
        spawn_config: spawn_config,
        ticks_until_spawn: spawn_config.spawn_interval_ticks,
        player_factory: player_factory,
        projectile_factory: projectile_factory,
        enemy_factory: enemy_factory,
        wand_factory: wand_factory,
        self: self,
      )

    actor.initialised(state)
    |> actor.returning(self)
    |> Ok
  })
  |> actor.on_message(handle_message)
  |> actor.named(name)
  |> actor.start
}

/// Handle incoming messages
fn handle_message(state: State, msg: Msg) -> actor.Next(State, Msg) {
  case msg {
    Tick -> handle_tick(state)
    FinalizeTick -> handle_finalize_tick(state)
    ClientConnected(conn, outgoing) ->
      handle_client_connected(state, conn, outgoing)
    ClientDisconnected(conn) -> handle_client_disconnected(state, conn)
    ClientMessage(conn, data) -> handle_client_message(state, conn, data)
    PlayerMessage(player_msg) -> handle_player_message(state, player_msg)
    ProjectileMessage(projectile_msg) ->
      handle_projectile_message(state, projectile_msg)
    EnemyMessage(enemy_msg) -> handle_enemy_message(state, enemy_msg)
    SpawnEnemy(position:) -> handle_spawn_enemy(state, position)
  }
}

/// Handle client connection
fn handle_client_connected(
  state: State,
  conn: ewe.WebsocketConnection,
  outgoing: process.Subject(OutgoingMsg),
) -> actor.Next(State, Msg) {
  let conn_info = ConnectionInfo(conn: conn, outgoing: outgoing)
  let new_connections = dict.insert(state.connections, conn, conn_info)
  actor.continue(State(..state, connections: new_connections))
}

// =============================================================================
// TICK HANDLING
// =============================================================================

/// Handle FinalizeTick - called after timeout or when all players responded
fn handle_finalize_tick(state: State) -> actor.Next(State, Msg) {
  case state.tick_state {
    Idle -> {
      // Already finalized (all players responded before timeout)
      actor.continue(state)
    }

    Collecting(
      expected_player_count: _,
      player_responses:,
      projectile_responses:,
      enemy_responses:,
      tick_number:,
    ) -> {
      finalize_tick(
        state,
        player_responses,
        projectile_responses,
        enemy_responses,
        tick_number,
      )
    }
  }
}

/// Finalize the tick - broadcast collected state
fn finalize_tick(
  state: State,
  player_responses: Dict(player.Id, player.Player),
  projectile_responses: Dict(projectile.Id, projectile.Projectile),
  enemy_responses: Dict(enemy.Id, enemy.Enemy),
  tick_number: Int,
) -> actor.Next(State, Msg) {
  // Apply physics to prevent enemy overlapping
  let delta_time = tick.delta_time(state.tick_scheduler)

  let #(updated_physics_world, physics_corrected_enemies) =
    apply_physics_to_enemies(
      state.physics_world,
      player_responses,
      enemy_responses,
      delta_time,
    )

  // Send physics-corrected positions back to enemy actors
  dict.each(physics_corrected_enemies, fn(enemy_id, enemy_data) {
    case dict.get(state.enemy_actors, enemy_id) {
      Ok(enemy_actor) ->
        process.send(
          enemy_actor,
          enemy_actor.UpdatePosition(enemy_data.position, enemy_data.velocity),
        )
      Error(_) -> Nil
    }
  })

  // Check collisions BEFORE broadcasting
  // This ensures damage is applied and actors receive messages before tick ends
  check_collisions(state, projectile_responses, physics_corrected_enemies)

  // Broadcast GameStateUpdate to all players (using physics-corrected enemy positions)
  broadcast_tick_updates(
    state.connections,
    tick_number,
    player_responses,
    projectile_responses,
    physics_corrected_enemies,
  )

  // Cache player positions for next tick's enemy AI
  let player_positions =
    dict.map_values(player_responses, fn(_id, player_state) {
      player_state.position
    })

  // Cache enemy positions for next tick's enemy separation (use physics-corrected positions)
  let enemy_positions =
    dict.map_values(physics_corrected_enemies, fn(_id, enemy_state) {
      enemy_state.position
    })

  // Keep tick scheduler as-is (last_tick_time was set when tick started)
  // DON'T call update_time() - that would set it to NOW and break 60Hz timing!

  // Enemy spawning logic
  let new_ticks_until_spawn = state.ticks_until_spawn - 1
  let state_after_spawn = case new_ticks_until_spawn <= 0 {
    True -> {
      // Time to spawn enemies!
      spawn_enemy_wave(state, player_positions)
    }
    False -> {
      // Just decrement counter
      State(..state, ticks_until_spawn: new_ticks_until_spawn)
    }
  }

  // Reset collection state (all ephemeral data is discarded)
  let new_state =
    State(
      ..state_after_spawn,
      tick_state: Idle,
      last_player_positions: player_positions,
      last_enemy_positions: enemy_positions,
      physics_world: updated_physics_world,
      // Keep original tick_scheduler - it has the correct tick start time!
    )

  // Schedule next tick to maintain fixed 60Hz rate
  // Calculate time remaining until next tick (16ms - elapsed time)
  let now = timestamp.system_time()
  let time_until_next_tick = tick.next(state.tick_scheduler, now)

  process.send_after(new_state.self, time_until_next_tick, Tick)

  actor.continue(new_state)
}

fn handle_tick(state: State) -> actor.Next(State, Msg) {
  // Stop ticking if all players disconnected
  case dict.is_empty(state.player_actors) {
    True -> {
      logging.log(logging.Info, "No players connected, stopping tick loop")
      actor.continue(state)
    }
    False -> {
      // Check if already collecting (shouldn't happen, but guard against it)
      case state.tick_state {
        Collecting(..) -> {
          logging.log(
            logging.Warning,
            "Tick received while already collecting - ignoring",
          )
          actor.continue(state)
        }

        Idle -> handle_tick_idle(state)
      }
    }
  }
}

fn handle_tick_idle(state: State) -> actor.Next(State, Msg) {
  // Capture current time ONCE for all tick calculations (prevents drift)
  let now = timestamp.system_time()

  // Advance the tick counter (use the captured 'now' timestamp)
  let tick_scheduler = tick.advance_with_time(state.tick_scheduler, now)
  let current_tick = tick.current(tick_scheduler)

  // Get delta time for physics
  let delta_time = tick.delta_time(state.tick_scheduler)

  // Count players to expect responses from
  let expected_player_count = dict.size(state.player_actors)

  // Start collection phase (empty collections for all actor types)
  let tick_state =
    Collecting(
      expected_player_count: expected_player_count,
      player_responses: dict.new(),
      projectile_responses: dict.new(),
      enemy_responses: dict.new(),
      tick_number: current_tick,
    )

  // Update state with new scheduler, collection phase, and timestamp
  let state =
    State(..state, tick_scheduler:, tick_state:, last_tick_timestamp: now)

  // Send Tick to all player actors (they will respond with StateChanged)
  dict.each(state.player_actors, fn(_player_id, player_actor) {
    process.send(player_actor, player_actor.Tick(delta_time))
  })

  // Send Tick to all projectile actors (they will respond with StateChanged or Expired)
  dict.each(state.projectile_actors, fn(_proj_id, projectile_actor) {
    process.send(projectile_actor, projectile_actor.Tick(delta_time))
  })

  // Send Tick to all enemy actors with player positions only
  // OPTIMIZATION: Don't send enemy positions - let physics handle separation!
  // This reduces message size from 12KB to ~100 bytes (just player positions)
  dict.each(state.enemy_actors, fn(_enemy_id, enemy_actor) {
    process.send(
      enemy_actor,
      enemy_actor.Tick(delta_time, state.last_player_positions),
    )
  })

  // Schedule finalize to run after a small delay (allows actors to respond)
  // Actors respond in <1ms, so 2ms timeout is safe
  process.send_after(state.self, 2, FinalizeTick)

  // DON'T schedule next tick here - it's scheduled at the end of finalize_tick
  // This ensures predictable 60Hz tick rate

  actor.continue(state)
}

/// Start the tick loop when the first player joins
fn start_tick_loop(state: State) {
  process.send_after(
    state.self,
    tick.next(state.tick_scheduler, timestamp.system_time()),
    Tick,
  )
  Nil
}

// =============================================================================
// PLAYER MESSAGE HANDLING
// =============================================================================

fn handle_player_message(
  state: State,
  player_msg: player_actor.ToRoomMsg,
) -> actor.Next(State, Msg) {
  case player_msg {
    player_actor.SpawnProjectile(proj, player_id) -> {
      // Assign unique ID to projectile
      let new_proj_id = projectile.Id(state.next_projectile_id)
      let proj_with_id = projectile.Projectile(..proj, id: new_proj_id)

      // Create tagger for projectile messages
      let to_room = fn(proj_msg: projectile_actor.ToRoomMsg) -> Msg {
        ProjectileMessage(proj_msg)
      }

      // Spawn ProjectileActor with unique ID via factory supervisor
      let proj_spawn_args =
        projectile_actor.SpawnArguments(
          projectile: proj_with_id,
          room: state.self,
          to_room: to_room,
        )

      case
        factory_supervisor.start_child(
          state.projectile_factory,
          proj_spawn_args,
        )
      {
        Ok(started) -> {
          let new_projectile_actors =
            dict.insert(state.projectile_actors, new_proj_id, started.data)

          logging.log(
            logging.Debug,
            "Projectile actor "
              <> int.to_string(state.next_projectile_id)
              <> " spawned from player "
              <> player_id_to_string(player_id),
          )

          actor.continue(
            State(
              ..state,
              projectile_actors: new_projectile_actors,
              next_projectile_id: state.next_projectile_id + 1,
            ),
          )
        }

        Error(_) -> {
          logging.log(logging.Error, "Failed to spawn projectile actor")
          actor.continue(state)
        }
      }
    }

    player_actor.StateChanged(player_id, player_state) -> {
      case state.tick_state {
        // Currently collecting player states for tick
        Collecting(
          expected_player_count:,
          player_responses:,
          projectile_responses:,
          enemy_responses:,
          tick_number:,
        ) -> {
          // Add this player's response
          let new_player_responses =
            dict.insert(player_responses, player_id, player_state.player)

          // Update collection state - ALWAYS wait for FinalizeTick timeout
          // to ensure projectiles and enemies have time to respond
          let new_tick_state =
            Collecting(
              expected_player_count:,
              player_responses: new_player_responses,
              projectile_responses:,
              enemy_responses:,
              tick_number:,
            )
          actor.continue(State(..state, tick_state: new_tick_state))
        }

        // Not collecting - this is a state change outside of tick (e.g., from CastSpell)
        // Just ignore it - next tick will collect the updated state
        Idle -> actor.continue(state)
      }
    }
  }
}

// =============================================================================
// PROJECTILE MESSAGE HANDLING
// =============================================================================

fn handle_projectile_message(
  state: State,
  projectile_msg: projectile_actor.ToRoomMsg,
) -> actor.Next(State, Msg) {
  case projectile_msg {
    projectile_actor.StateChanged(proj) -> {
      case state.tick_state {
        // Currently collecting - add to ephemeral collection
        Collecting(
          expected_player_count:,
          player_responses:,
          projectile_responses:,
          enemy_responses:,
          tick_number:,
        ) -> {
          let new_projectile_responses =
            dict.insert(projectile_responses, proj.id, proj)
          let new_tick_state =
            Collecting(
              expected_player_count:,
              player_responses:,
              projectile_responses: new_projectile_responses,
              enemy_responses:,
              tick_number:,
            )
          actor.continue(State(..state, tick_state: new_tick_state))
        }

        // Not collecting - ignore (will be picked up next tick)
        Idle -> {
          actor.continue(state)
        }
      }
    }

    projectile_actor.Expired(proj_id) -> {
      // Remove projectile actor (it's already stopped itself)
      let new_projectile_actors = dict.delete(state.projectile_actors, proj_id)
      actor.continue(State(..state, projectile_actors: new_projectile_actors))
    }
  }
}

// =============================================================================
// ENEMY MESSAGE HANDLING
// =============================================================================

fn handle_enemy_message(
  state: State,
  enemy_msg: enemy_actor.ToRoomMsg,
) -> actor.Next(State, Msg) {
  case enemy_msg {
    enemy_actor.StateChanged(enemy_state) -> {
      case state.tick_state {
        // Currently collecting - add to ephemeral collection
        Collecting(
          expected_player_count:,
          player_responses:,
          projectile_responses:,
          enemy_responses:,
          tick_number:,
        ) -> {
          let new_enemy_responses =
            dict.insert(enemy_responses, enemy_state.id, enemy_state)
          let new_tick_state =
            Collecting(
              expected_player_count:,
              player_responses:,
              projectile_responses:,
              enemy_responses: new_enemy_responses,
              tick_number:,
            )
          actor.continue(State(..state, tick_state: new_tick_state))
        }

        // Not collecting - ignore (will be picked up next tick)
        Idle -> {
          actor.continue(state)
        }
      }
    }

    enemy_actor.Died(enemy_id) -> {
      // Remove enemy actor (it's already stopped itself)
      let new_enemy_actors = dict.delete(state.enemy_actors, enemy_id)
      logging.log(logging.Info, "Enemy died and removed")
      actor.continue(State(..state, enemy_actors: new_enemy_actors))
    }
  }
}

fn handle_spawn_enemy(
  state: State,
  position: vec3.Vec3(Float),
) -> actor.Next(State, Msg) {
  // Create new enemy
  let new_enemy_id = enemy.Id(state.next_enemy_id)
  let new_enemy = enemy_actor.new_zombie(new_enemy_id, position)

  // Create tagger for enemy messages
  let to_room = fn(enemy_msg: enemy_actor.ToRoomMsg) -> Msg {
    EnemyMessage(enemy_msg)
  }

  // Spawn EnemyActor via factory supervisor
  let enemy_spawn_args =
    enemy_actor.SpawnArguments(
      enemy: new_enemy,
      room: state.self,
      to_room: to_room,
    )

  case factory_supervisor.start_child(state.enemy_factory, enemy_spawn_args) {
    Ok(started) -> {
      let new_enemy_actors =
        dict.insert(state.enemy_actors, new_enemy_id, started.data)

      logging.log(
        logging.Info,
        "Enemy " <> int.to_string(state.next_enemy_id) <> " spawned",
      )

      actor.continue(
        State(
          ..state,
          enemy_actors: new_enemy_actors,
          next_enemy_id: state.next_enemy_id + 1,
        ),
      )
    }

    Error(_) -> {
      logging.log(logging.Error, "Failed to spawn enemy actor")
      actor.continue(state)
    }
  }
}

// =============================================================================
// CONNECTION HANDLING
// =============================================================================

fn handle_client_disconnected(
  state: State,
  conn: ewe.WebsocketConnection,
) -> actor.Next(State, Msg) {
  // Find the player ID for this connection
  case dict.get(state.connection_to_player, conn) {
    Error(Nil) -> actor.continue(state)
    Ok(player_id) -> {
      logging.log(
        Info,
        "Player " <> player_id_to_string(player_id) <> " disconnected",
      )

      // Remove connection mappings
      let new_connection_to_player =
        dict.delete(state.connection_to_player, conn)
      let new_connections = dict.delete(state.connections, conn)

      // Remove player actor (will terminate automatically)
      let new_player_actors = dict.delete(state.player_actors, player_id)

      // Broadcast player_left to remaining players
      broadcast_to_all(
        new_connections,
        game_message.encode_server_message(game_message.PlayerLeft(player_id)),
      )

      actor.continue(
        State(
          ..state,
          connection_to_player: new_connection_to_player,
          connections: new_connections,
          player_actors: new_player_actors,
        ),
      )
    }
  }
}

// =============================================================================
// MESSAGE HANDLING
// =============================================================================

fn handle_client_message(
  state: State,
  conn: ewe.WebsocketConnection,
  data: BitArray,
) -> actor.Next(State, Msg) {
  // Decode the message
  let result = case bit_array.to_string(data) {
    Ok(text) -> game_message.decode_client_message(text)
    Error(_) -> Error("Invalid UTF-8 encoding")
  }

  case result {
    Error(err) -> {
      logging.log(
        logging.Error,
        "Failed to decode message from client: " <> err,
      )
      send_to_connection(
        state.connections,
        conn,
        game_message.encode_server_message(game_message.Error(err)),
      )
      actor.continue(state)
    }
    Ok(client_msg) -> {
      // Handle the message
      let #(updated_state, messages) =
        handle_message_internal(state, conn, client_msg)

      // Send all response messages
      list.each(messages, fn(msg_data) {
        let #(to_connection, message) = msg_data
        send_to_connection(
          updated_state.connections,
          to_connection,
          game_message.encode_server_message(message),
        )
      })

      actor.continue(updated_state)
    }
  }
}

/// Handle an incoming client message
fn handle_message_internal(
  state: State,
  conn: ewe.WebsocketConnection,
  msg: game_message.ClientMessage,
) -> #(State, List(#(ewe.WebsocketConnection, game_message.ServerMessage))) {
  case msg {
    game_message.JoinRoom(_, player_name) ->
      handle_join(state, conn, player_name)

    game_message.LeaveRoom -> handle_leave(state, conn)

    game_message.PlayerInput(_tick, action) -> {
      handle_player_input(state, conn, action)
    }

    game_message.Ping(timestamp) -> handle_ping(state, conn, timestamp)
  }
}

fn handle_player_input(
  state: State,
  conn: ewe.WebsocketConnection,
  action: game_message.PlayerAction,
) -> #(State, List(#(ewe.WebsocketConnection, game_message.ServerMessage))) {
  logging.log(logging.Debug, "Received PlayerInput from connection")

  case dict.get(state.connection_to_player, conn) {
    Ok(player_id) -> {
      // Route action to PlayerActor
      case dict.get(state.player_actors, player_id) {
        Ok(player_actor) -> {
          route_action_to_player(player_id, player_actor, action, state)
          #(state, [])
        }
        Error(_) -> {
          logging.log(logging.Warning, "Player actor not found for player ID")
          #(state, [])
        }
      }
    }
    Error(_) -> {
      logging.log(
        logging.Warning,
        "Received input from client that hasn't joined",
      )
      #(state, [])
    }
  }
}

/// Route player action to PlayerActor
fn route_action_to_player(
  _player_id: player.Id,
  player_actor: process.Subject(player_actor.Msg),
  action: game_message.PlayerAction,
  _state: State,
) -> Nil {
  case action {
    game_message.None -> Nil

    game_message.Move(w, a, s, d) -> {
      process.send(player_actor, player_actor.Move(w, a, s, d))
    }

    game_message.SwitchWand(slot) -> {
      process.send(player_actor, player_actor.SwitchWand(slot))
    }

    game_message.CastSpell(target) -> {
      // PlayerActor will calculate direction from its own position
      process.send(player_actor, player_actor.CastSpell(target))
    }
  }
}

// =============================================================================
// JOIN/LEAVE HANDLING
// =============================================================================

fn handle_join(
  state: State,
  conn: ewe.WebsocketConnection,
  player_name: String,
) -> #(State, List(#(ewe.WebsocketConnection, game_message.ServerMessage))) {
  let new_player_id = player.Id(state.next_player_id)
  let initial_position = Vec3(0.0, 0.9, 0.0)

  // Start tick loop if this is the first player
  let is_first_player = dict.size(state.player_actors) == 0
  case is_first_player {
    True -> {
      start_tick_loop(state)

      // Spawn 500 enemies immediately to benchmark physics performance
      logging.log(
        logging.Info,
        "🌊 First player joined! Spawning 1000 enemies to benchmark expresso optimization...",
      )

      // Create player positions dict with initial player position
      let player_positions =
        dict.new()
        |> dict.insert(new_player_id, initial_position)

      // Generate 1000 spawn positions around the player
      let spawn_positions =
        generate_spawn_positions(player_positions, state.spawn_config, 10)

      // Spawn all enemies immediately
      list.each(spawn_positions, fn(pos) {
        process.send(state.self, SpawnEnemy(position: pos))
      })
    }
    False -> Nil
  }

  // Create tagger function to wrap player messages
  let to_room = fn(player_msg: player_actor.ToRoomMsg) -> Msg {
    PlayerMessage(player_msg)
  }

  // Create spawn arguments for the player actor
  let spawn_args =
    player_actor.SpawnArguments(
      player_id: new_player_id,
      player_name: player_name,
      initial_position: initial_position,
      room: state.self,
      to_room: to_room,
      wand_factory: state.wand_factory,
    )

  // Spawn PlayerActor using factory supervisor
  case factory_supervisor.start_child(state.player_factory, spawn_args) {
    Error(_) -> {
      logging.log(logging.Error, "Failed to start player actor")
      #(state, [#(conn, game_message.Error("Failed to create player actor"))])
    }

    Ok(started) -> {
      let player_actor_subject = started.data

      // Add connection mapping
      let new_connection_to_player =
        dict.insert(state.connection_to_player, conn, new_player_id)

      // Add player actor
      let new_player_actors =
        dict.insert(state.player_actors, new_player_id, player_actor_subject)

      // NOTE: We don't update tick_state here even if Collecting
      // New player will be included in next tick cycle, not current one
      // This avoids race conditions with mid-collection joins

      // Increment next player ID
      let new_state =
        State(
          ..state,
          connection_to_player: new_connection_to_player,
          player_actors: new_player_actors,
          next_player_id: state.next_player_id + 1,
        )

      // Send room_joined to new player
      // Note: existing_players is empty - client will receive full state on next tick
      let join_msg = game_message.RoomJoined(new_player_id, [])

      // Create initial player representation for broadcasting
      let initial_player =
        player.new(new_player_id, player_name, initial_position)

      // Broadcast player_joined to existing players
      let messages =
        dict.keys(state.connection_to_player)
        |> list.map(fn(connection) {
          #(connection, game_message.PlayerJoined(initial_player))
        })
        |> list.prepend(#(conn, join_msg))

      #(new_state, messages)
    }
  }
}

fn handle_leave(
  state: State,
  connection: ewe.WebsocketConnection,
) -> #(State, List(#(ewe.WebsocketConnection, game_message.ServerMessage))) {
  // Get player ID for this connection
  let assert Ok(player_id) = dict.get(state.connection_to_player, connection)

  // Remove connection mappings
  let new_connection_to_player =
    dict.delete(state.connection_to_player, connection)
  let new_connections = dict.delete(state.connections, connection)

  // Remove player actor
  let new_player_actors = dict.delete(state.player_actors, player_id)

  // Request the connection to close
  case dict.get(state.connections, connection) {
    Ok(conn_info) -> {
      process.send(conn_info.outgoing, Disconnect)
    }
    Error(_) -> Nil
  }

  // Update tick state if we're currently collecting
  let new_tick_state = case state.tick_state {
    Idle -> Idle
    Collecting(
      expected_player_count:,
      player_responses:,
      projectile_responses:,
      enemy_responses:,
      tick_number:,
    ) -> {
      // Decrement expected count and remove player from responses if present
      let new_expected = expected_player_count - 1
      let new_player_responses = dict.delete(player_responses, player_id)

      logging.log(
        logging.Info,
        "Player left during tick collection. Adjusted expected count: "
          <> int.to_string(new_expected),
      )

      // If no players left, reset to Idle
      case new_expected {
        0 -> Idle
        _ ->
          Collecting(
            expected_player_count: new_expected,
            player_responses: new_player_responses,
            projectile_responses:,
            enemy_responses:,
            tick_number:,
          )
      }
    }
  }

  let new_state =
    State(
      ..state,
      connection_to_player: new_connection_to_player,
      connections: new_connections,
      player_actors: new_player_actors,
      tick_state: new_tick_state,
    )

  // Broadcast to remaining players
  let broadcast_msg = game_message.PlayerLeft(player_id)
  let messages =
    dict.keys(new_connection_to_player)
    |> list.map(fn(conn) { #(conn, broadcast_msg) })

  #(new_state, messages)
}

// =============================================================================
// PLAYER UPDATE HANDLING
// =============================================================================

fn handle_ping(
  state: State,
  connection: ewe.WebsocketConnection,
  client_timestamp: timestamp.Timestamp,
) -> #(State, List(#(ewe.WebsocketConnection, game_message.ServerMessage))) {
  let server_timestamp = timestamp.system_time()
  let pong_msg = game_message.Pong(client_timestamp, server_timestamp)
  #(state, [#(connection, pong_msg)])
}

// =============================================================================
// BROADCAST HELPERS
// =============================================================================

/// Send a message to a specific connection
fn send_to_connection(
  connections: Dict(ewe.WebsocketConnection, ConnectionInfo),
  conn: ewe.WebsocketConnection,
  message: String,
) -> Nil {
  case dict.get(connections, conn) {
    Ok(conn_info) ->
      process.send(
        conn_info.outgoing,
        SendFrame(bit_array.from_string(message)),
      )
    Error(_) -> Nil
  }
}

/// Broadcast GameStateUpdate to all players
fn broadcast_tick_updates(
  connections: Dict(ewe.WebsocketConnection, ConnectionInfo),
  tick: Int,
  players: Dict(player.Id, player.Player),
  projectiles: Dict(projectile.Id, projectile.Projectile),
  enemies: Dict(enemy.Id, enemy.Enemy),
) -> Nil {
  // Convert collections to lists for broadcasting
  let players_list = dict.values(players)
  let projectiles_list = dict.values(projectiles)
  let enemies_list = dict.values(enemies)

  let game_state_msg =
    game_message.GameStateUpdate(
      tick: tick,
      players: players_list,
      projectiles: projectiles_list,
      enemies: enemies_list,
    )
    |> game_message.encode_server_message

  // Send to all connections
  dict.each(connections, fn(_conn, conn_info) {
    process.send(
      conn_info.outgoing,
      SendFrame(bit_array.from_string(game_state_msg)),
    )
  })
}

/// Broadcast message to all players
fn broadcast_to_all(
  connections: Dict(ewe.WebsocketConnection, ConnectionInfo),
  message: String,
) -> Nil {
  dict.each(connections, fn(_, conn_info) {
    process.send(conn_info.outgoing, SendFrame(bit_array.from_string(message)))
  })
}

// =============================================================================
// PHYSICS SIMULATION
// =============================================================================

/// Apply physics to enemy positions to prevent overlapping
///
/// This function:
/// 1. Reuses the persistent physics world structure (spatial index will be rebuilt by world.step)
/// 2. Updates bodies dict directly with current positions (fast dict operations)
/// 3. Removes bodies that no longer exist
/// 4. Runs world.step() which rebuilds BVH (40x faster) and resolves collisions
/// 5. Returns updated world and enemy positions
fn apply_physics_to_enemies(
  physics_world: world.World(String),
  player_responses: Dict(player.Id, player.Player),
  enemy_responses: Dict(enemy.Id, enemy.Enemy),
  delta_time: Duration,
) -> #(world.World(String), Dict(enemy.Id, enemy.Enemy)) {
  // Convert delta_time to seconds for physics
  let dt_seconds = duration.to_seconds(delta_time)

  // Use minimal substeps for 500+ enemies to maintain 60Hz tick rate
  let enemy_count = dict.size(enemy_responses)
  let substeps = case enemy_count {
    n if n > 100 -> 1
    // 100+ enemies: 1 substep only (we don't need perfect collision chains at 60Hz)
    _ -> 2
    // <100 enemies: 2 substeps
  }

  // Get current bodies dict (we'll modify it directly - faster than incremental BVH updates)
  let current_bodies = world.bodies(physics_world)

  // Build new bodies dict by updating positions
  // (world.step will rebuild BVH from this - 40x faster than before)
  let mut_bodies = current_bodies

  // Add/update player bodies (kinematic - immovable obstacles)
  let mut_bodies =
    dict.fold(
      player_responses,
      mut_bodies,
      fn(bodies_acc, player_id, player_data) {
        let player.Id(id_num) = player_id
        let body_id = "player_" <> int.to_string(id_num)

        let player_body =
          body.new_circle(
            id: body_id,
            position: vec3_to_vec2(player_data.position),
            radius: 0.5,
          )
          |> body.kinematic()

        dict.insert(bodies_acc, body_id, player_body)
      },
    )

  // Add/update enemy bodies (dynamic - affected by physics)
  let mut_bodies =
    dict.fold(enemy_responses, mut_bodies, fn(bodies_acc, enemy_id, enemy_data) {
      let enemy.Id(id_num) = enemy_id
      let body_id = "enemy_" <> int.to_string(id_num)

      let enemy_body =
        body.new_circle(
          id: body_id,
          position: vec3_to_vec2(enemy_data.position),
          radius: 0.5,
        )
        // Set velocity from AI - expresso will integrate movement
        |> body.with_velocity(vec3_to_vec2(enemy_data.velocity))
        |> body.with_mass(1.0)
        |> body.with_friction(0.0)
      // No friction - AI controls movement

      dict.insert(bodies_acc, body_id, enemy_body)
    })

  // Build set of IDs that should exist
  let mut_should_exist =
    dict.fold(player_responses, dict.new(), fn(acc, player_id, _) {
      let player.Id(id_num) = player_id
      dict.insert(acc, "player_" <> int.to_string(id_num), True)
    })
  let should_exist =
    dict.fold(enemy_responses, mut_should_exist, fn(acc, enemy_id, _) {
      let enemy.Id(id_num) = enemy_id
      dict.insert(acc, "enemy_" <> int.to_string(id_num), True)
    })

  // Remove bodies that no longer exist (died or disconnected)
  let final_bodies =
    dict.filter(mut_bodies, fn(body_id, _body) {
      dict.has_key(should_exist, body_id)
    })

  // Create updated world with new bodies dict
  // We'll add bodies one by one, but world.step() will rebuild BVH anyway (40x faster)
  // Start with empty world to ensure clean state
  let mut_world =
    world.new(gravity: vec2.Vec2(0.0, 0.0))
    |> world.with_iterations(2)
    |> world.with_restitution(0.0)
    |> world.with_substeps(substeps)

  // Add all bodies to the fresh world
  let mut_world =
    dict.fold(final_bodies, mut_world, fn(world_acc, _id, body_data) {
      world.add_body(world_acc, body_data)
    })

  // Run physics step with proper delta_time
  // This integrates velocities (movement) AND resolves collisions
  let mut_world = world.step(mut_world, delta_time: dt_seconds)

  // Extract updated positions AND velocities from physics world
  // Physics has integrated movement and resolved collisions
  let updated_enemies =
    dict.map_values(enemy_responses, fn(enemy_id, enemy_data) {
      let enemy.Id(id_num) = enemy_id
      let body_id = "enemy_" <> int.to_string(id_num)

      case world.get_body(mut_world, body_id) {
        Ok(updated_body) -> {
          // Update both position (from physics integration + collision)
          // and velocity (for client interpolation)
          enemy.Enemy(
            ..enemy_data,
            position: vec2_to_vec3(updated_body.position),
            velocity: vec2_to_vec3_flat(updated_body.velocity),
          )
        }
        Error(_) -> {
          // Body not found (shouldn't happen), keep original
          enemy_data
        }
      }
    })

  #(mut_world, updated_enemies)
}

// =============================================================================
// COLLISION DETECTION
// =============================================================================

/// Check collisions between projectiles and enemies using spatial partitioning.
///
/// Uses BVH (Bounding Volume Hierarchy) to accelerate collision detection.
/// Complexity: O(n log m + n*k) where n=projectiles, m=enemies, k=avg nearby enemies
/// Previous brute force: O(n*m)
fn check_collisions(
  state: State,
  projectile_responses: Dict(projectile.Id, projectile.Projectile),
  enemy_responses: Dict(enemy.Id, enemy.Enemy),
) -> Nil {
  // Early exit if no projectiles or enemies
  case dict.is_empty(projectile_responses) || dict.is_empty(enemy_responses) {
    True -> Nil
    False -> {
      // Build BVH from enemy positions (O(m log m))
      let enemy_items =
        dict.to_list(enemy_responses)
        |> list.map(fn(pair) {
          let #(enemy_id, enemy_state) = pair
          #(enemy_state.position, #(enemy_id, enemy_state))
        })

      case bvh.from_items(enemy_items, max_leaf_size: 8) {
        Error(_) -> Nil
        Ok(enemy_bvh) -> {
          // For each projectile, query BVH for nearby enemies (O(n * (log m + k)))
          dict.each(projectile_responses, fn(proj_id, proj) {
            // Query sphere around projectile (includes both projectile and enemy radii)
            let query_radius = proj.spell.final_size +. 1.0

            let nearby_enemies =
              bvh.query_radius(enemy_bvh, proj.position, query_radius)

            // Check precise sphere-sphere collision for candidates
            list.each(nearby_enemies, fn(enemy_pair) {
              let #(enemy_pos, #(enemy_id, _enemy_data)) = enemy_pair

              // Create sphere colliders for precise intersection test
              let proj_collider =
                collider.sphere(
                  center: proj.position,
                  radius: proj.spell.final_size,
                )

              let enemy_collider =
                collider.sphere(center: enemy_pos, radius: 1.0)

              // Check if they intersect
              case collider.intersects(proj_collider, enemy_collider) {
                True -> {
                  logging.log(
                    logging.Info,
                    "💥 Projectile "
                      <> projectile_id_to_string(proj_id)
                      <> " hit Enemy "
                      <> enemy_id_to_string(enemy_id),
                  )

                  // Send TakeDamage to enemy actor
                  case dict.get(state.enemy_actors, enemy_id) {
                    Ok(enemy_actor) -> {
                      process.send(
                        enemy_actor,
                        enemy_actor.TakeDamage(proj.spell.final_damage),
                      )
                    }
                    Error(_) -> Nil
                  }

                  // Send Hit to projectile actor (will expire itself)
                  case dict.get(state.projectile_actors, proj_id) {
                    Ok(projectile_actor) -> {
                      process.send(
                        projectile_actor,
                        projectile_actor.Hit(enemy_id),
                      )
                    }
                    Error(_) -> Nil
                  }
                }
                False -> Nil
              }
            })
          })
        }
      }
    }
  }
}

// =============================================================================
// ENEMY SPAWNING
// =============================================================================

/// Generate random spawn positions around players
fn generate_spawn_positions(
  player_positions: Dict(player.Id, vec3.Vec3(Float)),
  config: SpawnConfig,
  count: Int,
) -> List(vec3.Vec3(Float)) {
  case dict.is_empty(player_positions) {
    True -> []
    False -> {
      // Get list of player positions
      let positions = dict.values(player_positions)

      // Get player count once
      let player_count = list.length(positions)

      // Generate spawn positions around random players
      list.range(0, count - 1)
      |> list.map(fn(i) {
        // Pick a player position (cycling through players)
        let player_index = i % player_count
        let player_pos =
          positions
          |> list.drop(player_index)
          |> list.first
          |> result.unwrap(Vec3(0.0, 0.9, 0.0))

        // Generate pseudo-random angle (0-360 degrees)
        // Use golden angle and wave count for good distribution
        let angle_degrees =
          int.to_float({ i * 137 + config.waves_spawned * 89 } % 360)
        let angle_radians = angle_degrees *. maths.pi() /. 180.0

        // Generate random radius between min and max
        let radius_range = config.spawn_radius_max -. config.spawn_radius_min
        let radius_offset =
          int.to_float({ i * 73 } % 100) /. 100.0 *. radius_range
        let radius = config.spawn_radius_min +. radius_offset

        // Calculate spawn position
        let x_offset = maths.cos(angle_radians) *. radius
        let z_offset = maths.sin(angle_radians) *. radius

        Vec3(
          player_pos.x +. x_offset,
          0.9,
          // Ground level
          player_pos.z +. z_offset,
        )
      })
    }
  }
}

/// Spawn a wave of enemies around players
fn spawn_enemy_wave(
  state: State,
  player_positions: Dict(player.Id, vec3.Vec3(Float)),
) -> State {
  // Calculate number of enemies to spawn (scale with difficulty)
  let wave_number = state.spawn_config.waves_spawned + 1
  let difficulty_multiplier = 1 + { wave_number / 10 }
  let enemy_count = state.spawn_config.enemies_per_wave * difficulty_multiplier

  logging.log(
    logging.Info,
    "🌊 Spawning wave "
      <> int.to_string(wave_number)
      <> " with "
      <> int.to_string(enemy_count)
      <> " enemies (difficulty x"
      <> int.to_string(difficulty_multiplier)
      <> ")",
  )

  // Generate spawn positions
  let spawn_positions =
    generate_spawn_positions(player_positions, state.spawn_config, enemy_count)

  // Spawn enemies at each position
  list.each(spawn_positions, fn(pos) {
    process.send(state.self, SpawnEnemy(position: pos))
  })

  // Update spawn config with incremented wave count
  let new_spawn_config =
    SpawnConfig(..state.spawn_config, waves_spawned: wave_number)

  State(
    ..state,
    spawn_config: new_spawn_config,
    ticks_until_spawn: state.spawn_config.spawn_interval_ticks,
  )
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Convert Vec3 position to Vec2 (XZ plane for top-down physics)
fn vec3_to_vec2(pos: vec3.Vec3(Float)) -> vec2.Vec2(Float) {
  vec2.Vec2(pos.x, pos.z)
}

/// Convert Vec2 position to Vec3 (add Y=0.9 for ground level)
fn vec2_to_vec3(pos: vec2.Vec2(Float)) -> vec3.Vec3(Float) {
  vec3.Vec3(pos.x, 0.9, pos.y)
}

/// Convert Vec2 velocity to Vec3 velocity (horizontal only, Y=0)
fn vec2_to_vec3_flat(vel: vec2.Vec2(Float)) -> vec3.Vec3(Float) {
  vec3.Vec3(vel.x, 0.0, vel.y)
}

fn projectile_id_to_string(id: projectile.Id) -> String {
  let projectile.Id(n) = id
  int.to_string(n)
}

fn enemy_id_to_string(id: enemy.Id) -> String {
  let enemy.Id(n) = id
  int.to_string(n)
}

fn player_id_to_string(id: player.Id) -> String {
  let player.Id(n) = id
  int.to_string(n)
}
