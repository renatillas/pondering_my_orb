// FFI helpers for the server

import * as game_room_do from "./server/game_room_do.mjs";

export function getCurrentTimestamp() {
  return Date.now();
}

export function consoleLog(message) {
  console.log(message);
}

// ============================================================================
// GameRoom Durable Object class using Gleam
// ============================================================================
// This is the actual Durable Object that Cloudflare Workers will use
export class GameRoom {
  constructor(state, env) {
    this.state = state;
    this.env = env;

    // Initialize Gleam game room state
    this.roomState = game_room_do.init_state();
  }

  // Handle incoming fetch requests (including WebSocket upgrades)
  async fetch(request) {
    return game_room_do.fetch(this.state, request);
  }

  // Durable Objects WebSocket Hibernation API handlers
  async webSocketMessage(ws, message) {
    console.log("[GameRoom] WebSocket message received");
    this.roomState = game_room_do.websocket_message(
      this.state,
      ws,
      message,
      this.roomState
    );
  }

  async webSocketClose(ws, code, reason, wasClean) {
    console.log("[GameRoom] WebSocket closed");
    this.roomState = game_room_do.websocket_close(
      this.state,
      ws,
      code,
      reason,
      wasClean,
      this.roomState
    );
  }

  async webSocketError(ws, error) {
    console.error("[GameRoom] WebSocket error:", error);
    this.roomState = game_room_do.websocket_error(
      this.state,
      ws,
      error,
      this.roomState
    );
  }
}
