/// Room Registry Actor - Manages multiple game rooms
/// 
/// This actor is responsible for:
/// - Creating and managing multiple room actors
/// - Routing client connections to appropriate rooms
/// - Providing room list to clients
/// - Cleaning up empty rooms
import ewe
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/list
import gleam/otp/actor
import gleam/otp/factory_supervisor
import gleam/set.{type Set}
import gleam/string
import gleam/time/timestamp
import logging
import server/enemy as enemy_actor
import server/player as player_actor
import server/projectile as projectile_actor
import server/room
import shared/game_message
import shared/room_info

// =============================================================================
// TYPES
// =============================================================================

/// Room registry state
pub type State {
  State(
    /// Map of room_id -> room state
    rooms: Dict(String, RoomState),
    /// Map of connection -> room_id (for routing)
    connection_to_room: Dict(ewe.WebsocketConnection, String),
    /// Map of connection -> reply subject (for sending messages)
    connection_to_reply: Dict(
      ewe.WebsocketConnection,
      Subject(room.OutgoingMsg),
    ),
    /// Factory names for creating rooms
    player_factory: process.Name(
      factory_supervisor.Message(
        player_actor.SpawnArguments(room.Msg),
        Subject(player_actor.Msg),
      ),
    ),
    projectile_factory: process.Name(
      factory_supervisor.Message(
        projectile_actor.SpawnArguments(room.Msg),
        Subject(projectile_actor.Msg),
      ),
    ),
    enemy_factory: process.Name(
      factory_supervisor.Message(
        enemy_actor.SpawnArguments(room.Msg),
        Subject(enemy_actor.Msg),
      ),
    ),
    /// Counter for generating unique room IDs
    next_room_id: Int,
  )
}

/// Information about a managed room
pub type RoomState {
  RoomState(
    info: room_info.RoomInfo,
    actor: Subject(room.Msg),
    connections: Set(ewe.WebsocketConnection),
  )
}

/// Messages handled by the room registry
pub type Msg {
  /// New client connected (from WebSocket handler)
  ClientConnected(
    conn: ewe.WebsocketConnection,
    reply: Subject(room.OutgoingMsg),
  )
  /// Client disconnected
  ClientDisconnected(conn: ewe.WebsocketConnection)
  /// Client sent a message
  ClientMessage(conn: ewe.WebsocketConnection, data: BitArray)

  /// Room updates (from room actors)
  RoomPlayerCountChanged(room_id: String, count: Int)
  RoomStatusChanged(room_id: String, status: room_info.RoomStatus)
  RoomEmpty(room_id: String)
}

// =============================================================================
// START
// =============================================================================

/// Start the room registry actor
pub fn start(
  name: process.Name(Msg),
  player_factory: process.Name(
    factory_supervisor.Message(
      player_actor.SpawnArguments(room.Msg),
      Subject(player_actor.Msg),
    ),
  ),
  projectile_factory: process.Name(
    factory_supervisor.Message(
      projectile_actor.SpawnArguments(room.Msg),
      Subject(projectile_actor.Msg),
    ),
  ),
  enemy_factory: process.Name(
    factory_supervisor.Message(
      enemy_actor.SpawnArguments(room.Msg),
      Subject(enemy_actor.Msg),
    ),
  ),
) -> Result(actor.Started(Subject(Msg)), actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    logging.log(logging.Info, "Room registry started")

    let initial_state =
      State(
        rooms: dict.new(),
        connection_to_room: dict.new(),
        connection_to_reply: dict.new(),
        player_factory: player_factory,
        projectile_factory: projectile_factory,
        enemy_factory: enemy_factory,
        next_room_id: 1,
      )

    actor.initialised(initial_state)
    |> actor.returning(self)
    |> Ok
  })
  |> actor.on_message(handle_message)
  |> actor.named(name)
  |> actor.start
}

// =============================================================================
// MESSAGE HANDLER
// =============================================================================

fn handle_message(state: State, msg: Msg) -> actor.Next(State, Msg) {
  case msg {
    ClientConnected(conn, reply) -> handle_client_connected(conn, reply, state)
    ClientDisconnected(conn) -> handle_client_disconnected(conn, state)
    ClientMessage(conn, data) -> handle_client_message(conn, data, state)
    RoomPlayerCountChanged(room_id, count) ->
      handle_room_player_count_changed(room_id, count, state)
    RoomStatusChanged(room_id, status) ->
      handle_room_status_changed(room_id, status, state)
    RoomEmpty(room_id) -> handle_room_empty(room_id, state)
  }
}

// =============================================================================
// HANDLERS
// =============================================================================

fn handle_client_connected(
  conn: ewe.WebsocketConnection,
  reply: Subject(room.OutgoingMsg),
  state: State,
) -> actor.Next(State, Msg) {
  logging.log(logging.Info, "Client connected to registry")

  // Store the reply subject for this connection
  let updated_state =
    State(
      ..state,
      connection_to_reply: dict.insert(state.connection_to_reply, conn, reply),
    )

  actor.continue(updated_state)
}

fn handle_client_disconnected(
  conn: ewe.WebsocketConnection,
  state: State,
) -> actor.Next(State, Msg) {
  logging.log(logging.Info, "Client disconnected from registry")

  // Find which room this connection belongs to and forward disconnect
  case dict.get(state.connection_to_room, conn) {
    Ok(room_id) -> {
      case dict.get(state.rooms, room_id) {
        Ok(room_state) -> {
          // Forward disconnect to room
          actor.send(room_state.actor, room.ClientDisconnected(conn))

          // Remove connection from room state
          let updated_connections = set.delete(room_state.connections, conn)
          let updated_room_state =
            RoomState(..room_state, connections: updated_connections)
          let updated_rooms =
            dict.insert(state.rooms, room_id, updated_room_state)
          let updated_conn_map = dict.delete(state.connection_to_room, conn)
          let updated_reply_map = dict.delete(state.connection_to_reply, conn)

          actor.continue(
            State(
              ..state,
              rooms: updated_rooms,
              connection_to_room: updated_conn_map,
              connection_to_reply: updated_reply_map,
            ),
          )
        }
        Error(_) -> {
          // Still clean up the reply mapping
          let updated_reply_map = dict.delete(state.connection_to_reply, conn)
          actor.continue(State(..state, connection_to_reply: updated_reply_map))
        }
      }
    }
    Error(_) -> {
      // Still clean up the reply mapping
      let updated_reply_map = dict.delete(state.connection_to_reply, conn)
      actor.continue(State(..state, connection_to_reply: updated_reply_map))
    }
  }
}

fn handle_client_message(
  conn: ewe.WebsocketConnection,
  data: BitArray,
  state: State,
) -> actor.Next(State, Msg) {
  // Try to decode as client message
  case bit_array.to_string(data) {
    Ok(text) -> {
      case game_message.decode_client_message(text) {
        Ok(client_msg) -> {
          case client_msg {
            game_message.ListRooms -> handle_list_rooms(conn, state)
            game_message.CreateRoom(room_name, max_players) ->
              handle_create_room(conn, room_name, max_players, state)
            game_message.JoinRoom(room_id, player_name) ->
              handle_join_room(conn, room_id, player_name, state)
            _ -> {
              // Forward all other messages to the room this connection belongs to
              case dict.get(state.connection_to_room, conn) {
                Ok(room_id) -> {
                  case dict.get(state.rooms, room_id) {
                    Ok(room_state) -> {
                      actor.send(
                        room_state.actor,
                        room.ClientMessage(conn, data),
                      )
                      actor.continue(state)
                    }
                    Error(_) -> {
                      send_error(conn, "Not in a room", state)
                      actor.continue(state)
                    }
                  }
                }
                Error(_) -> {
                  send_error(conn, "Not in a room", state)
                  actor.continue(state)
                }
              }
            }
          }
        }
        Error(_) -> {
          logging.log(logging.Error, "Failed to decode client message")
          actor.continue(state)
        }
      }
    }
    Error(_) -> {
      logging.log(logging.Error, "Failed to convert message to string")
      actor.continue(state)
    }
  }
}

fn handle_list_rooms(
  conn: ewe.WebsocketConnection,
  state: State,
) -> actor.Next(State, Msg) {
  logging.log(logging.Info, "Client requested room list")

  // Convert room states to room info list
  let room_list =
    state.rooms
    |> dict.values()
    |> list.map(fn(room_state) { room_state.info })

  // Send room list to client
  let response = game_message.RoomList(room_list)
  let json = game_message.encode_server_message(response)
  send_text(conn, json, state)

  actor.continue(state)
}

fn handle_create_room(
  conn: ewe.WebsocketConnection,
  room_name: String,
  max_players: Int,
  state: State,
) -> actor.Next(State, Msg) {
  logging.log(logging.Info, "Client requested to create room: " <> room_name)

  // Validate room name
  case validate_room_name(room_name) {
    Error(error_msg) -> {
      send_error(conn, error_msg, state)
      actor.continue(state)
    }
    Ok(_) -> {
      // Generate unique room ID
      let room_id = "room_" <> int.to_string(state.next_room_id)

      // Create room info
      let room_info =
        room_info.RoomInfo(
          id: room_id,
          name: room_name,
          player_count: 0,
          max_players: max_players,
          status: room_info.Waiting,
          created_at: timestamp.system_time(),
        )

      // Start room actor
      case start_room_actor(room_id, state) {
        Ok(room_actor) -> {
          // Create room state
          let room_state =
            RoomState(
              info: room_info,
              actor: room_actor,
              connections: set.new(),
            )

          // Add to rooms dict
          let updated_rooms = dict.insert(state.rooms, room_id, room_state)
          let updated_state =
            State(
              ..state,
              rooms: updated_rooms,
              next_room_id: state.next_room_id + 1,
            )

          // Send confirmation to client
          let response = game_message.RoomCreated(room_id, room_info)
          let json = game_message.encode_server_message(response)
          send_text(conn, json, state)

          logging.log(logging.Info, "Room created: " <> room_id)
          actor.continue(updated_state)
        }
        Error(_) -> {
          send_error(conn, "Failed to create room", state)
          actor.continue(state)
        }
      }
    }
  }
}

fn handle_join_room(
  conn: ewe.WebsocketConnection,
  room_id: String,
  player_name: String,
  state: State,
) -> actor.Next(State, Msg) {
  logging.log(
    logging.Info,
    "Client " <> player_name <> " requested to join room: " <> room_id,
  )

  // Check if room exists
  case dict.get(state.rooms, room_id) {
    Error(_) -> {
      let response = game_message.RoomNotFound(room_id)
      let json = game_message.encode_server_message(response)
      send_text(conn, json, state)
      actor.continue(state)
    }
    Ok(room_state) -> {
      // Check if room is full
      case room_state.info.player_count >= room_state.info.max_players {
        True -> {
          let response = game_message.RoomFull(room_id)
          let json = game_message.encode_server_message(response)
          send_text(conn, json, state)
          actor.continue(state)
        }
        False -> {
          // Get the reply subject for this connection (from WebSocket handler)
          let assert Ok(reply) = dict.get(state.connection_to_reply, conn)

          // Forward join request to room actor with the actual reply subject
          actor.send(room_state.actor, room.ClientConnected(conn, reply))

          // Send the actual JoinRoom message
          let join_msg = game_message.JoinRoom(room_id, player_name)
          let join_json = game_message.encode_client_message(join_msg)
          let join_data = <<join_json:utf8>>
          actor.send(room_state.actor, room.ClientMessage(conn, join_data))

          // Add connection to room state
          let updated_connections = set.insert(room_state.connections, conn)
          let updated_room_state =
            RoomState(..room_state, connections: updated_connections)
          let updated_rooms =
            dict.insert(state.rooms, room_id, updated_room_state)

          // Track which room this connection is in
          let updated_conn_map =
            dict.insert(state.connection_to_room, conn, room_id)

          actor.continue(
            State(
              ..state,
              rooms: updated_rooms,
              connection_to_room: updated_conn_map,
            ),
          )
        }
      }
    }
  }
}

fn handle_room_player_count_changed(
  room_id: String,
  count: Int,
  state: State,
) -> actor.Next(State, Msg) {
  logging.log(
    logging.Info,
    "Room " <> room_id <> " player count changed to " <> int.to_string(count),
  )

  case dict.get(state.rooms, room_id) {
    Ok(room_state) -> {
      let updated_info =
        room_info.RoomInfo(..room_state.info, player_count: count)
      let updated_room_state = RoomState(..room_state, info: updated_info)
      let updated_rooms = dict.insert(state.rooms, room_id, updated_room_state)

      actor.continue(State(..state, rooms: updated_rooms))
    }
    Error(_) -> actor.continue(state)
  }
}

fn handle_room_status_changed(
  room_id: String,
  status: room_info.RoomStatus,
  state: State,
) -> actor.Next(State, Msg) {
  case dict.get(state.rooms, room_id) {
    Ok(room_state) -> {
      let updated_info = room_info.RoomInfo(..room_state.info, status: status)
      let updated_room_state = RoomState(..room_state, info: updated_info)
      let updated_rooms = dict.insert(state.rooms, room_id, updated_room_state)

      actor.continue(State(..state, rooms: updated_rooms))
    }
    Error(_) -> actor.continue(state)
  }
}

fn handle_room_empty(room_id: String, state: State) -> actor.Next(State, Msg) {
  logging.log(logging.Info, "Room " <> room_id <> " is empty, removing")

  // Remove room from registry
  let updated_rooms = dict.delete(state.rooms, room_id)

  // Remove any connections that were in this room
  let updated_conn_map =
    dict.filter(state.connection_to_room, fn(_conn, rid) { rid != room_id })

  actor.continue(
    State(..state, rooms: updated_rooms, connection_to_room: updated_conn_map),
  )
}

// =============================================================================
// HELPERS
// =============================================================================

fn start_room_actor(
  room_id: String,
  state: State,
) -> Result(Subject(room.Msg), Nil) {
  let room_name = process.new_name(room_id)
  case
    room.start(
      room_name,
      state.player_factory,
      state.projectile_factory,
      state.enemy_factory,
    )
  {
    Ok(started) -> Ok(started.data)
    Error(_) -> Error(Nil)
  }
}

fn validate_room_name(name: String) -> Result(Nil, String) {
  let len = string.length(name)
  case len {
    0 -> Error("Room name cannot be empty")
    l if l > 50 -> Error("Room name must be less than 50 characters")
    _ -> Ok(Nil)
  }
}

fn send_text(conn: ewe.WebsocketConnection, text: String, state: State) -> Nil {
  case dict.get(state.connection_to_reply, conn) {
    Ok(reply) -> {
      // Send via reply subject - this is the correct way with ewe!
      actor.send(reply, room.SendFrame(<<text:utf8>>))
      Nil
    }
    Error(_) -> {
      logging.log(logging.Error, "No reply subject for connection")
      Nil
    }
  }
}

fn send_error(
  conn: ewe.WebsocketConnection,
  message: String,
  state: State,
) -> Nil {
  let error_msg = game_message.Error(message)
  let json = game_message.encode_server_message(error_msg)
  send_text(conn, json, state)
}
