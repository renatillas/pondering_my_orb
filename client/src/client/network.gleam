/// Network module for WebSocket communication with multiplayer server.
/// Uses Tiramisu effect system with JavaScript FFI for WebSocket operations.
import gleam/io
import tiramisu
import tiramisu/effect.{type Effect}

import shared/game_messages

// =============================================================================
// MODEL
// =============================================================================

/// Connection state for the multiplayer session.
pub type ConnectionState {
  Disconnected
  Connecting
  Connected(room_id: String)
}

/// Network model containing connection state.
pub type Model {
  Model(connection_state: ConnectionState, server_url: String)
}

// =============================================================================
// MESSAGES
// =============================================================================

/// Messages for network operations.
pub type Msg {
  /// Connect to a game server
  Connect(server_url: String, room_id: String, player_name: String)
  /// Disconnect from the server
  Disconnect
  /// WebSocket opened successfully
  SocketOpened
  /// WebSocket closed
  SocketClosed
  /// Received a server message (raw string)
  ReceivedMessage(String)
  /// Send a client message to the server
  SendMessage(game_messages.ClientMessage)
}

// =============================================================================
// INIT
// =============================================================================

/// Initialize the network module in a disconnected state.
pub fn init() -> #(Model, Effect(Msg)) {
  let model = Model(connection_state: Disconnected, server_url: "")
  #(model, effect.none())
}

// =============================================================================
// UPDATE
// =============================================================================

/// Update the network module.
/// Uses taggers to dispatch server messages to other modules.
pub fn update(
  model: Model,
  msg: Msg,
  effect_mapper: fn(Msg) -> game_msg,
  on_server_message: fn(game_messages.ServerMessage) -> game_msg,
  _ctx: tiramisu.Context,
) -> #(Model, Effect(game_msg)) {
  case msg {
    Connect(server_url, room_id, player_name) ->
      handle_connect(model, server_url, room_id, player_name, effect_mapper)

    Disconnect -> handle_disconnect(model, effect_mapper)

    SocketOpened -> {
      io.println("✅ WebSocket connection opened")
      #(model, effect.none())
    }

    SocketClosed -> {
      io.println("🔌 WebSocket connection closed")
      let new_model = Model(..model, connection_state: Disconnected)
      #(new_model, effect.none())
    }

    ReceivedMessage(data) ->
      handle_received_message(model, data, on_server_message)

    SendMessage(client_msg) -> send_client_message(model, client_msg)
  }
}

// =============================================================================
// HANDLERS
// =============================================================================

/// Handle connect request.
fn handle_connect(
  _model: Model,
  server_url: String,
  room_id: String,
  player_name: String,
  effect_mapper: fn(Msg) -> game_msg,
) -> #(Model, Effect(game_msg)) {
  // Build the WebSocket URL
  let ws_url = server_url <> "/ws/" <> room_id

  let new_model = Model(server_url: server_url, connection_state: Connecting)

  // Create effect to connect WebSocket
  let connect_effect =
    effect.from(fn(dispatch) {
      do_connect(ws_url, room_id, player_name, fn(msg) {
        dispatch(effect_mapper(msg))
      })
    })

  #(new_model, connect_effect)
}

/// Handle disconnect request.
fn handle_disconnect(
  model: Model,
  effect_mapper: fn(Msg) -> game_msg,
) -> #(Model, Effect(game_msg)) {
  let new_model = Model(..model, connection_state: Disconnected)

  let disconnect_effect =
    effect.from(fn(dispatch) {
      do_disconnect()
      dispatch(effect_mapper(SocketClosed))
    })

  #(new_model, disconnect_effect)
}

/// Handle received WebSocket message.
fn handle_received_message(
  model: Model,
  data: String,
  on_server_message: fn(game_messages.ServerMessage) -> game_msg,
) -> #(Model, Effect(game_msg)) {
  case game_messages.decode_server_message(data) {
    Ok(server_msg) -> {
      // Route server message to parent module via tagger
      #(model, effect.dispatch(on_server_message(server_msg)))
    }
    Error(err) -> {
      io.println("Failed to decode server message: " <> err)
      #(model, effect.none())
    }
  }
}

/// Send a client message to the server.
fn send_client_message(
  model: Model,
  message: game_messages.ClientMessage,
) -> #(Model, Effect(game_msg)) {
  let json = game_messages.encode_client_message(message)
  let send_effect = effect.from(fn(_dispatch) { do_send(json) })
  #(model, send_effect)
}

// =============================================================================
// HELPERS
// =============================================================================

/// Check if connected to server
pub fn is_connected(model: Model) -> Bool {
  case model.connection_state {
    Connected(_) -> True
    _ -> False
  }
}

// =============================================================================
// FFI
// =============================================================================

/// Connect to WebSocket server
@external(javascript, "./network_ffi.mjs", "connect")
fn do_connect(
  url: String,
  room_id: String,
  player_name: String,
  dispatch: fn(Msg) -> Nil,
) -> Nil

/// Disconnect from server
@external(javascript, "./network_ffi.mjs", "disconnect")
fn do_disconnect() -> Nil

/// Send message to server
@external(javascript, "./network_ffi.mjs", "send")
fn do_send(message: String) -> Nil
