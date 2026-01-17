// Network FFI for WebSocket communication with Tiramisu effect system

import {
  SocketOpened,
  SocketClosed,
  ReceivedMessage,
} from "./network.mjs";

let socket = null;

/**
 * Connect to WebSocket server
 * @param {string} url - WebSocket URL
 * @param {string} roomId - Room ID to join
 * @param {string} playerName - Player name
 * @param {function} dispatch - Callback to dispatch Gleam messages
 */
export function connect(url, playerName, dispatch) {
  // Close existing connection if any
  if (socket) {
    socket.close();
  }

  try {
    socket = new WebSocket(url);
    console.log(socket)

    socket.onopen = () => {
      console.log("[Network] Connected to", url);
      dispatch(new SocketOpened());

      // Send join room message
      const joinMsg = {
        type: "join_room",
        room_id: "1", // Default room for now
        player_name: playerName,
      };
      socket.send(JSON.stringify(joinMsg));
    };

    socket.onmessage = (event) => {
      // Dispatch message to Gleam - this calls ReceivedMessage(data)
      dispatch(new ReceivedMessage(event.data));
    };

    socket.onclose = () => {
      console.log("[Network] Disconnected");
      dispatch(new SocketClosed());
      socket = null;
    };

    socket.onerror = (error) => {
      console.error("[Network] WebSocket error:", error);
    };
  } catch (e) {
    console.error("[Network] Failed to connect:", e);
  }
}

/**
 * Disconnect from server
 */
export function disconnect() {
  if (socket) {
    socket.close();
    socket = null;
  }
}

/**
 * Send message to server
 * @param {string} message - JSON string message
 */
export function send(message) {
  if (socket && socket.readyState === WebSocket.OPEN) {
    socket.send(message);
  } else {
    console.warn("[Network] Cannot send - socket not open");
  }
}
