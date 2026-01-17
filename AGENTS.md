# AGENTS.md

High-level documentation for AI agents working on this codebase.

---

## 📦 Package-Specific Documentation

**For detailed technical documentation, see:**

- **[shared/AGENTS.md](./shared/AGENTS.md)** - Types, network protocol, JSON codecs, entity definitions
- **[server/AGENTS.md](./server/AGENTS.md)** - Actor architecture, OTP patterns, tick coordination, game simulation
- **[client/AGENTS.md](./client/AGENTS.md)** - Tiramisu engine, TEA patterns, rendering, input handling

---

## Project Overview

A **multiplayer action game** with Noita-inspired spell-casting mechanics, built entirely in Gleam:

- **Client**: Gleam → JavaScript (Tiramisu 3D engine + Lustre UI)
- **Server**: Gleam → Erlang/OTP (Actor-based, server-authoritative)
- **Shared**: Types, codecs, and protocols
- **Network**: WebSockets (ewe) with JSON messages

---

## Quick Start

### Development Commands

```bash
# Client (game)
just dev                  # Run with hot reload
just test-client          # Run tests

# Server (multiplayer backend)
just server-dev           # Run server (port 8080)
just test-server          # Run tests

# All packages
just build                # Build everything
just test                 # Run all tests
just format               # Format code
```

### Manual Commands

```bash
cd client && gleam run -m lustre/dev start
cd server && gleam run
cd shared && gleam build
```

---

## Monorepo Structure

```
pondering_my_orb/
├── client/              # 3D game client (JavaScript)
│   ├── src/client.gleam
│   ├── src/client/      # player, enemy, projectile, network, map
│   ├── test/
│   └── AGENTS.md        📘 Client documentation (target architecture)
├── server/              # Game server (Erlang/OTP)
│   ├── src/server.gleam
│   ├── src/server/      # room, player, enemy, projectile, wand, tick
│   ├── test/
│   └── AGENTS.md        📘 Server documentation
├── shared/              # Shared types (multi-target)
│   ├── src/shared/      # id, player, enemy, projectile, game_message
│   ├── test/
│   └── AGENTS.md        📘 Shared documentation
└── AGENTS.md            📘 This file (overview)
```

**Note:** Client currently has tech debt - `player.gleam` handles all entities. See client/AGENTS.md for refactoring plan.

---

## Architecture at a Glance

### Server (Erlang/OTP)

**Pattern:** Actor-based with factory supervisors

```
Supervision Tree:
├── player_factory       # Spawns player actors
├── projectile_factory   # Spawns projectile actors
├── enemy_factory        # Spawns enemy actors
├── wand_factory         # Spawns wand actors
├── room                 # Tick coordinator (20 Hz)
└── ewe_server           # WebSocket server (port 8080)
```

**Key Principles:**
- **Actors as source of truth** - No cached state in room
- **Ephemeral collections** - Snapshots discarded after broadcast
- **Fixed timestep** - 50ms per tick (deterministic physics)
- **Server-authoritative** - Client sends input, server calculates movement

**See:** [server/AGENTS.md](./server/AGENTS.md)

---

### Client (Tiramisu/JavaScript)

**Pattern:** The Elm Architecture (TEA)

```gleam
pub fn init() -> #(Model, effect.Effect(Msg))
pub fn update(model, msg, ctx) -> #(Model, effect.Effect(Msg))
pub fn view(model, ctx) -> List(scene.Node)
```

**Target Modular Structure:**
- **player.gleam** - Player rendering, input, camera
- **enemy.gleam** - Enemy rendering
- **projectile.gleam** - Projectile rendering with interpolation
- **network.gleam** - WebSocket connection, message codec
- **map.gleam** - Level/terrain rendering

**Current State (Tech Debt):**
- ⚠️ `player.gleam` currently handles ALL entities (needs refactoring)

**Key Principles:**
- **Taggers for cross-module communication** - Parent passes functions to children
- **Client-side interpolation** - Smooth 20 Hz server updates to 60 FPS
- **Input change detection** - Only send WASD when keys change
- **Server state as source of truth** - Client only renders, never simulates

**See:** [client/AGENTS.md](./client/AGENTS.md) for refactoring plan

---

### Shared (Types & Protocol)

**Network Protocol:**

```gleam
// Client → Server
pub type ClientMessage {
  PlayerAction(PlayerAction)
  RequestJoin(player_name: String)
}

pub type PlayerAction {
  Move(w: Bool, a: Bool, s: Bool, d: Bool)  // WASD
  SwitchWand(Int)
  CastSpell
}

// Server → Client
pub type ServerMessage {
  GameStateUpdate(GameStateUpdate)
  JoinAccepted(player_id: PlayerId)
  JoinRejected(reason: String)
}
```

**Entity Types:** Player, Enemy, Projectile, ID system

**See:** [shared/AGENTS.md](./shared/AGENTS.md)

---

## Key Design Decisions

### 1. Server-Authoritative Movement

**Decision:** Client sends WASD input, server calculates velocity and position.

**Why?**
- Prevents speed hacks
- Consistent physics across all clients
- Server controls game rules

**Trade-off:** 50ms input latency (mitigated by future client-side prediction)

---

### 2. Actors as Source of Truth

**Decision:** Room doesn't cache actor state. Actors send snapshots each tick.

**Why?**
- Single source of truth
- No synchronization bugs
- Ephemeral collections prevent stale data

**Trade-off:** Slight memory overhead (allocate/discard dicts every 50ms)

---

### 3. Fixed Timestep Physics

**Decision:** `delta_time()` always returns 0.05 (50ms).

**Why?**
- Deterministic simulation
- No accumulation errors
- Easier debugging

**Trade-off:** If tick loop falls behind, game slows down instead of skipping frames

---

### 4. Input Change Detection

**Decision:** Client only sends WASD when keys change.

**Why?**
- 85-95% bandwidth reduction
- No gameplay impact
- Server continues last input until change

**Trade-off:** Must track `last_input` state on client

---

## Testing

### Test Conventions

- Test files end with `_test.gleam`
- Test functions end with `_test` suffix
- Use `assert <pattern> = <expression>` for pattern matching
- Use `assert <bool expression>` for boolean checks
- **Do NOT use gleeunit/should** (deprecated)

### Running Tests

```bash
# All packages
just test

# Individual packages
cd client && gleam test
cd server && gleam test
cd shared && gleam test
```

---

## Critical Code Patterns

### 1. Tick Timing (Server)

**ALWAYS capture timestamp ONCE per tick:**

```gleam
fn handle_tick(state: State) -> actor.Next(State, Msg) {
  let now = timestamp.system_time()  // Capture ONCE
  let tick_scheduler = tick.advance_with_time(state.tick_scheduler, now)
  
  // Schedule both at 50ms using same timestamp
  process.send_after(state.self, 50, FinalizeTick(tick_number))
  process.send_after(state.self, 50, Tick)
  
  // ...
}
```

**NEVER schedule next tick in finalize_tick** (causes 10 Hz instead of 20 Hz)

---

### 2. Factory Spawning (Server)

**ALWAYS use factory supervisors (from gleam/otp):**

```gleam
// GOOD:
let spawn_args = projectile_actor.SpawnArguments(
  id: id,
  projectile: projectile_data,
  room: state.self,
  to_room: to_room,
)

case factory_supervisor.start_child(state.projectile_factory, spawn_args) {
  Ok(started) -> dict.insert(state.projectile_actors, id, started.data)
  Error(_) -> state.projectile_actors  // Factory handles restart
}
```

---

### 3. Input Change Detection (Client)

**Only send when input changes:**

```gleam
let current_input = #(w, a, s, d)
case current_input == model.last_input {
  True -> effect.none()  // Don't send duplicate
  False -> effect.dispatch(send_to_server(PlayerAction(Move(w, a, s, d))))
}
```

---

### 4. Message Taggers (Client)

**Parent passes taggers to children:**

```gleam
// Parent (client.gleam)
PlayerMsg(player_msg) -> {
  let #(new_player, player_effect) =
    player.update(
      model.player,
      player_msg,
      ctx,
      send_to_server: fn(msg) { NetworkingMsg(networking.SendMessage(msg)) },
      effect_mapper: PlayerMsg,
    )
  #(Model(..model, player: new_player), player_effect)
}
```

---

## Known Issues & Future Work

### High Priority

1. **Collision detection** - Projectiles pass through enemies
2. **Damage system** - Enemies don't take damage or die
3. **Client-side prediction** - Player movement feels laggy (50ms delay)

### Medium Priority

4. **Entity interpolation** - Smooth 20 Hz server updates to 60 FPS rendering
5. **Wand system integration** - Wire up `CastSpell` message
6. **Enemy spawning** - Wave-based spawner with difficulty scaling

### Low Priority

7. **Visual polish** - Particle effects, health bars, damage numbers
8. **Sound system** - Spell casting, hits, background music
9. **Performance optimization** - Profile tick loop, object pooling

---

## Tips for AI Agents

### When Adding New Features

1. **Check shared types first** - Does the message/type already exist?
2. **Use factory supervisors** - Spawn all dynamic actors via factories
3. **Maintain tick precision** - Capture timestamp ONCE, use for all scheduling
4. **Test both targets** - Run tests in both client and server
5. **Update package AGENTS.md** - Document architectural decisions

### When Debugging

1. **Add logging** - Use `io.println` or `io.debug` liberally
2. **Check tick timing** - Add logs to measure time between ticks
3. **Verify actor count** - Log `dict.size(state.player_actors)` etc.
4. **Inspect messages** - Log incoming/outgoing WebSocket messages

### When Refactoring

1. **One module at a time** - Don't change client + server + shared simultaneously
2. **Keep tests green** - Run tests after each change
3. **Update AGENTS.md files** - Keep documentation in sync
4. **Commit frequently** - Small commits = easier rollback

---

## Code Quality Standards

- **Prefer pattern matching over if/else**
- **Use `case` exhaustively** (compiler checks all branches)
- **Avoid `dynamic` type** unless truly necessary (ask first)
- **Name functions clearly** (`handle_tick` not `ht`)
- **Document complex logic** with comments
- **Keep functions under 50 lines** (extract helpers)

---

## Version History

- **v0.1.0** - Initial architecture
- **v0.2.0** - Factory supervisors for all actors
- **v0.3.0** - WASD movement (server-authoritative)
- **v0.4.0** - Fixed 20 Hz tick rate
- **v0.5.0** - Unified ephemeral collection pattern
- **v0.6.0** - Enemy AI with ground-locked movement
- **v0.7.0** - Input change detection (bandwidth optimization)

**Current Version: v0.7.0**

---

## Glossary

- **Actor** - OTP process with mailbox, handles messages sequentially
- **Subject** - Typed reference to an actor (like a typed PID)
- **Supervisor** - Actor that monitors children and restarts on crash
- **Factory** - Supervisor that dynamically spawns children on-demand
- **Tick** - Single iteration of game loop (50ms = 20 Hz)
- **Tagger** - Function that wraps child messages into parent messages
- **Effect** - Description of side effect to perform (à la Elm)
- **Ephemeral** - Short-lived, discarded after use (tick collections)
- **Server-Authoritative** - Server controls game state, clients are views
- **TEA** - The Elm Architecture (Model-Update-View)

---

**For detailed documentation, see the package-specific AGENTS.md files:**
- [shared/AGENTS.md](./shared/AGENTS.md)
- [server/AGENTS.md](./server/AGENTS.md)
- [client/AGENTS.md](./client/AGENTS.md)
