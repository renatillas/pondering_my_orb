// FFI helpers for the server

export function getCurrentTimestamp() {
  return Date.now();
}

export function intToString(n) {
  return n.toString();
}

// Forward a request to a Durable Object stub
export function forwardToStub(stub, request) {
  return stub.fetch(request);
}

// GameRoom Durable Object class
// This is the actual Durable Object that Cloudflare Workers will use
export class GameRoom {
  constructor(state, env) {
    this.state = state;
    this.env = env;
    this.sessions = new Map(); // WebSocket -> player_id
    this.gameState = {
      players: new Map(),
      nextPlayerId: 1,
    };
  }

  // Handle incoming fetch requests (including WebSocket upgrades)
  async fetch(request) {
    const url = new URL(request.url);

    // Handle WebSocket upgrade
    if (request.headers.get("Upgrade") === "websocket") {
      return this.handleWebSocketUpgrade(request);
    }

    // Handle HTTP requests
    return new Response("Expected WebSocket", { status: 400 });
  }

  // Handle WebSocket upgrade requests
  handleWebSocketUpgrade(request) {
    const pair = new WebSocketPair();
    const [client, server] = Object.values(pair);

    // Accept the WebSocket connection
    server.accept();

    // Generate a new player ID
    const playerId = `player_${this.gameState.nextPlayerId++}`;
    this.sessions.set(server, playerId);

    // Set up event handlers
    server.addEventListener("message", (event) => {
      this.handleMessage(server, playerId, event.data);
    });

    server.addEventListener("close", () => {
      this.handleClose(server, playerId);
    });

    server.addEventListener("error", (error) => {
      console.error("WebSocket error:", error);
      this.handleClose(server, playerId);
    });

    return new Response(null, {
      status: 101,
      webSocket: client,
    });
  }

  // Handle incoming WebSocket messages
  handleMessage(ws, playerId, data) {
    try {
      const msg = JSON.parse(data);

      switch (msg.type) {
        case "join_room":
          this.handleJoin(ws, playerId, msg.room_id, msg.player_name);
          break;

        case "leave_room":
          this.handleLeave(ws, playerId);
          break;

        case "player_update":
          this.handlePlayerUpdate(ws, playerId, msg.position, msg.rotation);
          break;

        case "spell_cast":
          this.handleSpellCast(ws, playerId, msg.wand_index, msg.direction);
          break;

        case "ping":
          this.handlePing(ws, playerId, msg.timestamp);
          break;

        default:
          this.sendToPlayer(ws, {
            type: "error",
            message: `Unknown message type: ${msg.type}`,
          });
      }
    } catch (error) {
      console.error("Error handling message:", error);
      this.sendToPlayer(ws, {
        type: "error",
        message: "Failed to process message",
      });
    }
  }

  // Handle player joining
  handleJoin(ws, playerId, roomId, playerName) {
    // Create new player state
    const newPlayer = {
      id: playerId,
      position: { x: 0, y: 0, z: 0 },
      rotation: 0,
      health: 100,
      max_health: 100,
      active_wand_index: 0,
    };

    // Get existing players
    const existingPlayers = Array.from(this.gameState.players.values());

    // Add new player
    this.gameState.players.set(playerId, { state: newPlayer, ws });

    // Send room_joined to new player
    this.sendToPlayer(ws, {
      type: "room_joined",
      room_id: roomId,
      player_id: playerId,
      players: existingPlayers.map((p) => p.state),
    });

    // Broadcast player_joined to existing players
    this.broadcast(
      {
        type: "player_joined",
        player: newPlayer,
      },
      playerId
    );
  }

  // Handle player leaving
  handleLeave(ws, playerId) {
    this.gameState.players.delete(playerId);
    this.sessions.delete(ws);

    // Broadcast to remaining players
    this.broadcast({
      type: "player_left",
      player_id: playerId,
    });

    ws.close();
  }

  // Handle WebSocket close
  handleClose(ws, playerId) {
    this.gameState.players.delete(playerId);
    this.sessions.delete(ws);

    // Broadcast to remaining players
    this.broadcast({
      type: "player_left",
      player_id: playerId,
    });
  }

  // Handle player position update
  handlePlayerUpdate(ws, playerId, position, rotation) {
    const player = this.gameState.players.get(playerId);
    if (player) {
      player.state.position = position;
      player.state.rotation = rotation;
    }
  }

  // Handle spell cast
  handleSpellCast(ws, playerId, wandIndex, direction) {
    // Broadcast to all players
    this.broadcast({
      type: "spell_cast_broadcast",
      caster_id: playerId,
      wand_index: wandIndex,
      direction,
    });
  }

  // Handle ping
  handlePing(ws, playerId, clientTimestamp) {
    this.sendToPlayer(ws, {
      type: "pong",
      client_timestamp: clientTimestamp,
      server_timestamp: Date.now(),
    });
  }

  // Send message to a specific player
  sendToPlayer(ws, message) {
    try {
      ws.send(JSON.stringify(message));
    } catch (error) {
      console.error("Error sending to player:", error);
    }
  }

  // Broadcast message to all players (optionally excluding one)
  broadcast(message, excludePlayerId = null) {
    const msgStr = JSON.stringify(message);
    for (const [playerId, player] of this.gameState.players) {
      if (playerId !== excludePlayerId) {
        try {
          player.ws.send(msgStr);
        } catch (error) {
          console.error(`Error broadcasting to ${playerId}:`, error);
        }
      }
    }
  }

  // Periodic state broadcast (can be called by an alarm)
  async alarm() {
    // Broadcast all player states
    const states = Array.from(this.gameState.players.values()).map(
      (p) => p.state
    );

    this.broadcast({
      type: "player_states",
      states,
    });

    // Schedule next alarm (e.g., every 50ms for 20Hz updates)
    await this.state.storage.setAlarm(Date.now() + 50);
  }
}

// Export helper for creating GameRoom from Gleam
export function createGameRoom(state) {
  return new GameRoom(state, {});
}

export function handleFetch(gameRoom, request) {
  return gameRoom.fetch(request);
}
