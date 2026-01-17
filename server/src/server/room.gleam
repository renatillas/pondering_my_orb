/// Game room actor - manages game state and player connections using OTP/ewe with PlayerActors
import ewe
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/otp/actor
import gleam/otp/factory_supervisor
import gleam/time/timestamp
import logging.{Info}
import vec/vec3.{Vec3}

import server/enemy_actor
import server/player as player_actor
import server/projectile_actor
import server/tick

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
    // Tick collection state (ephemeral - only during tick processing)
    tick_state: TickState,
    tick_scheduler: tick.TickScheduler,
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
) -> Result(actor.Started(process.Subject(Msg)), actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    // Get references to all factory supervisors
    let player_factory = factory_supervisor.get_by_name(player_factory_name)
    let projectile_factory =
      factory_supervisor.get_by_name(projectile_factory_name)
    let enemy_factory = factory_supervisor.get_by_name(enemy_factory_name)

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
        tick_state: Idle,
        tick_scheduler: tick.new(timestamp.system_time()),
        player_factory: player_factory,
        projectile_factory: projectile_factory,
        enemy_factory: enemy_factory,
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
      expected_player_count:,
      player_responses:,
      projectile_responses:,
      enemy_responses:,
      tick_number:,
    ) -> {
      logging.log(
        logging.Debug,
        "Finalizing tick "
          <> int.to_string(tick_number)
          <> " with "
          <> int.to_string(dict.size(player_responses))
          <> "/"
          <> int.to_string(expected_player_count)
          <> " player responses, "
          <> int.to_string(dict.size(projectile_responses))
          <> " projectiles, "
          <> int.to_string(dict.size(enemy_responses))
          <> " enemies",
      )

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
  logging.log(
    logging.Debug,
    "Tick "
      <> int.to_string(tick_number)
      <> ": Broadcasting "
      <> int.to_string(dict.size(player_responses))
      <> " players, "
      <> int.to_string(dict.size(projectile_responses))
      <> " projectiles, "
      <> int.to_string(dict.size(enemy_responses))
      <> " enemies to "
      <> int.to_string(dict.size(state.connections))
      <> " clients",
  )

  // Broadcast GameStateUpdate to all players (using collected snapshots)
  broadcast_tick_updates(
    state.connections,
    tick_number,
    player_responses,
    projectile_responses,
    enemy_responses,
  )

  // Reset collection state (all ephemeral data is discarded)
  let new_state = State(..state, tick_state: Idle)

  // Check if all clients disconnected
  case dict.is_empty(new_state.player_actors) {
    True -> {
      logging.log(logging.Info, "All clients disconnected, pausing tick loop")
      // Don't schedule next tick - actors remain alive but tick loop stops
      actor.continue(new_state)
    }
    False -> {
      // Schedule next tick
      process.send_after(
        new_state.self,
        tick.next(state.tick_scheduler, timestamp.system_time()),
        Tick,
      )

      actor.continue(new_state)
    }
  }
}

fn handle_tick(state: State) -> actor.Next(State, Msg) {
  // Check if already collecting (shouldn't happen, but guard against it)
  case state.tick_state {
    Collecting(..) -> {
      logging.log(
        logging.Warning,
        "Tick received while already collecting - ignoring",
      )
      actor.continue(state)
    }

    Idle -> {
      // Advance the tick counter
      let new_scheduler = tick.advance(state.tick_scheduler)
      let current_tick = tick.current(new_scheduler)

      // Get delta time for physics
      let delta_time = tick.delta_time(state.tick_scheduler)

      // Count players to expect responses from
      let expected_player_count = dict.size(state.player_actors)

      // Start collection phase (empty collections for all actor types)
      let new_tick_state =
        Collecting(
          expected_player_count: expected_player_count,
          player_responses: dict.new(),
          projectile_responses: dict.new(),
          enemy_responses: dict.new(),
          tick_number: current_tick,
        )

      // Update state with new scheduler and collection phase
      let state =
        State(
          ..state,
          tick_scheduler: new_scheduler,
          tick_state: new_tick_state,
        )

      let Collecting(
        expected_player_count:,
        tick_number:,
        player_responses: _,
        projectile_responses: _,
        enemy_responses: _,
      ) = new_tick_state
      logging.log(
        logging.Debug,
        "Tick "
          <> int.to_string(tick_number)
          <> ": Started collection. Expecting "
          <> int.to_string(expected_player_count)
          <> " player responses",
      )

      // Send Tick to all player actors (they will respond with StateChanged)
      let _nil =
        dict.each(state.player_actors, fn(_player_id, player_actor) {
          process.send(player_actor, player_actor.Tick(delta_time))
        })

      // Send Tick to all projectile actors (they will respond with StateChanged or Expired)
      let _nil =
        dict.each(state.projectile_actors, fn(_proj_id, projectile_actor) {
          process.send(projectile_actor, projectile_actor.Tick(delta_time))
        })

      // Send Tick to all enemy actors with nearby player positions for AI
      // Note: Using current game_state.players which may be from previous tick
      // This is acceptable for AI - enemies don't need frame-perfect player positions
      let player_positions =
        dict.map_values(state.player_actors, fn(_id, _actor) {
          // We don't have player positions here yet (collecting during this tick)
          // For now, send empty dict - TODO: use previous tick's positions
          vec3.Vec3(0.0, 0.0, 0.0)
        })

      let _nil =
        dict.each(state.enemy_actors, fn(_enemy_id, enemy_actor) {
          process.send(
            enemy_actor,
            enemy_actor.Tick(delta_time, player_positions),
          )
        })

      // Schedule timeout - finalize after 50ms even if not all players responded
      process.send_after(
        state.self,
        tick.next(state.tick_scheduler, timestamp.system_time()),
        FinalizeTick,
      )

      actor.continue(state)
    }
  }
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
          let responses_count = dict.size(new_player_responses)

          logging.log(
            logging.Debug,
            "Tick "
              <> int.to_string(tick_number)
              <> ": Received player state ("
              <> int.to_string(responses_count)
              <> "/"
              <> int.to_string(expected_player_count)
              <> ")",
          )

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
        Idle -> {
          logging.log(
            logging.Debug,
            "Received StateChanged outside tick collection - will pick up next tick",
          )
          actor.continue(state)
        }
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
      logging.log(logging.Debug, "Projectile expired and removed")
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

    game_message.PlayerUpdate(position) ->
      handle_player_update(state, conn, position)

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

    game_message.MoveToPosition(target) -> {
      process.send(player_actor, player_actor.MoveToPosition(target))
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
  // Start tick loop if this is the first player
  let is_first_player = dict.size(state.player_actors) == 0
  case is_first_player {
    True -> {
      start_tick_loop(state)
      // Spawn some test enemies
      process.send(state.self, SpawnEnemy(position: Vec3(5.0, 0.9, 5.0)))
      process.send(state.self, SpawnEnemy(position: Vec3(-5.0, 0.9, 5.0)))
      process.send(state.self, SpawnEnemy(position: Vec3(0.0, 0.9, 10.0)))
    }
    False -> Nil
  }

  let new_player_id = player.Id(state.next_player_id)
  let initial_position = Vec3(0.0, 0.9, 0.0)

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

fn handle_player_update(
  state: State,
  connection: ewe.WebsocketConnection,
  position: vec3.Vec3(Float),
) -> #(State, List(#(ewe.WebsocketConnection, game_message.ServerMessage))) {
  // Route to PlayerActor
  case dict.get(state.connection_to_player, connection) {
    Ok(player_id) -> {
      case dict.get(state.player_actors, player_id) {
        Ok(player_actor) -> {
          process.send(player_actor, player_actor.MoveToPosition(position))
          #(state, [])
        }
        Error(_) -> #(state, [])
      }
    }
    Error(_) -> #(state, [])
  }
}

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
// HELPER FUNCTIONS
// =============================================================================

fn player_id_to_string(id: player.Id) -> String {
  let player.Id(n) = id
  int.to_string(n)
}
