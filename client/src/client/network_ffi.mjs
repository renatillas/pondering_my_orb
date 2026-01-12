// Network FFI for WebSocket communication with tiramisu effect system

import {
  SocketOpened,
  SocketClosed,
  ReceivedMessage,
} from "./network.mjs";

let socket = null;
let pendingJoin = { roomId: "", playerName: "" };

export function connect(url, roomId, playerName, dispatch) {
  // Store pending join info
  pendingJoin = { roomId, playerName };

  // Close existing connection if any
  if (socket) {
    socket.close();
  }

  try {
    socket = new WebSocket(url);

    socket.onopen = () => {
      console.log("[Network] Connected to", url);
      dispatch(new SocketOpened());

      // Send join room message
      const joinMsg = {
        type: "join_room",
        room_id: pendingJoin.roomId,
        player_name: pendingJoin.playerName,
      };
      socket.send(JSON.stringify(joinMsg));
    };

    socket.onmessage = (event) => {
      // Dispatch message immediately - Hibernation WebSocket API delivers messages in real-time
      dispatch(new ReceivedMessage(event.data));
    };

    socket.onclose = () => {
      console.log("[Network] Disconnected");
      dispatch(new SocketClosed());
      socket = null;
    };

    socket.onerror = (error) => {
      console.error("[Network] Error:", error);
    };
  } catch (e) {
    console.error("[Network] Failed to connect:", e);
  }
}

export function disconnect() {
  if (socket) {
    socket.close();
    socket = null;
  }
}

export function send(message) {
  if (socket && socket.readyState === WebSocket.OPEN) {
    socket.send(message);
  }
}

export function getTimestamp() {
  return Date.now();
}
