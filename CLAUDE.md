# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Gleam game targeting JavaScript that implements a Noita-inspired spell-casting system with multiplayer support. Built with:
- **Tiramisu** - 3D game engine (Three.js + Rapier3D)
- **Lustre** - UI framework for HUD/menus
- **Ensaimada** - Drag-and-drop library for spell management
- **Erlang/OTP + ewe** - Actor-based multiplayer backend with WebSockets

## Monorepo Structure

```
pondering_my_orb/
├── client/                      # Game client (JavaScript target)
│   ├── src/client.gleam         # Main game entry point
│   ├── src/client/              # Game modules
│   ├── test/                    # Client tests
│   ├── assets/                  # Game assets
│   └── gleam.toml
├── server/                      # Erlang/OTP backend
│   ├── src/server.gleam         # Main entry point
│   ├── src/server/              # Server modules
│   │   ├── effect.gleam         # Effects system
│   │   └── game_room.gleam      # Game room actor
│   └── gleam.toml
├── shared/                      # Shared types (client + server)
│   ├── src/shared/              # Shared modules
│   │   ├── id.gleam             # Entity identifiers
│   │   ├── player_state.gleam   # Networked player state
│   │   └── game_messages.gleam  # Client<->Server messages
│   └── gleam.toml
└── package.json                 # Root workspace config
```

## Development Commands

Using `just` (justfile):
```bash
# Client (game)
just dev                        # Run game with hot reload
just build-client               # Build client
just test-client                # Run client tests

# Server (multiplayer backend)
just server-dev                 # Run server locally
just server-watch               # Run with auto-restart

# All packages
just build                      # Build all packages
just test                       # Run all tests
just format                     # Format all code
```

Or run directly in each package:
```bash
cd client && gleam run -m lustre/dev start
cd client && gleam test
cd server && gleam run
cd shared && gleam build
```

## Testing

- Test files in `client/test/` ending with `_test.gleam`
- All test functions must end with `_test` suffix
- Use `assert <pattern> = <expression>` for pattern-matching assertions
- Use `assert <bool expression>` for boolean assertions
- Use `echo <expression>` for debug output (not `io.debug`)
- **Do not use gleeunit/should** - it's deprecated

## Shared Package

The `shared/` package contains types used by both client and server:

- **shared/id** - PlayerId, RoomId, ProjectileId, EnemyId
- **shared/player_state** - Networked player state with JSON codecs
- **shared/game_messages** - ClientMessage and ServerMessage types

Both client and server import shared via path dependency:
```toml
shared = { path = "../shared" }
```

## Server Architecture

The server uses Erlang/OTP with ewe for real-time multiplayer:

- **Actor-based** - Game room managed by OTP actor (message handler pattern)
- **WebSockets** - Real-time player state synchronization via ewe
- **Game Simulation** - Server-authoritative game logic (20Hz tick rate)
- **Message Protocol** - JSON-encoded ClientMessage/ServerMessage types

Key files:
- `server/src/server.gleam` - Main entry point, ewe WebSocket server
- `server/src/server/game_room.gleam` - Game room actor with message handling
- `server/src/server/game_simulation.gleam` - Server-side game logic (movement, projectiles, collisions)
- `server/src/server/game_tick.gleam` - Fixed 20Hz tick scheduler

### Actor Pattern

The server follows the OTP actor pattern with gleam/otp/actor:

```gleam
pub type Msg {
  Tick
  ClientConnected(ewe.WebsocketConnection)
  ClientDisconnected(ewe.WebsocketConnection)
  ClientMessage(ewe.WebsocketConnection, BitArray)
}

pub fn start(room_id: room.Id) {
  actor.new_with_initialiser(1000, fn(self) {
    let state = State(
      room_id: room_id,
      players: dict.new(),
      game_state: game_state.new(),
      tick_scheduler: game_tick.new(),
      self: self,
    )
    
    actor.initialised(state)
    |> actor.returning(self)
    |> Ok
  })
  |> actor.on_message(handle_message)
  |> actor.start
}

fn handle_message(state: State, msg: Msg) -> actor.Next(State, Msg) {
  case msg {
    Tick -> {
      // Run game simulation
      let #(new_game_state, events) = 
        game_simulation.tick(state.game_state, state.player_inputs, delta_time)
      
      // Broadcast to all players
      broadcast_game_state_update(state.players, tick, new_game_state)
      
      // Schedule next tick
      process.send_after(state.self, 50, Tick)
      actor.continue(State(..state, game_state: new_game_state))
    }
    ClientMessage(conn, data) -> {
      // Handle player input, store in buffer for next tick
      // ...
    }
  }
}
```

### WebSocket Integration

The ewe server forwards messages to the actor:

```gleam
ewe.new(fn(request) {
  ewe.upgrade_websocket(
    request,
    on_init: fn(conn, _selector) {
      actor.send(room_actor, ClientConnected(conn))
      // ...
    },
    handler: fn(conn, user_state, message) {
      actor.send(room_actor, ClientMessage(conn, data))
      ewe.websocket_continue(user_state)
    },
    on_close: fn(conn, _user_state) {
      actor.send(room_actor, ClientDisconnected(conn))
    },
  )
})
|> ewe.listening(8080)
|> ewe.start()
```

### Game Simulation

Server-authoritative game loop at 20Hz:

1. Process player inputs (movement, wand switching, spell casting)
2. Simulate player movement toward targets
3. Simulate projectile movement and lifetime
4. Check collisions (projectile vs enemy, enemy vs player)
5. Broadcast game state and events to all clients

## Tiramisu Game Architecture

### Core Pattern: Independent Tick Cycles

Each subsystem manages its own tick cycle using `effect.tick(Tick)`. This creates independent update loops:

```gleam
pub fn init() -> #(Model, effect.Effect(Msg)) {
  #(model, effect.tick(Tick))
}

pub fn update(model, msg, ctx) -> #(Model, effect.Effect(Msg)) {
  case msg {
    Tick -> {
      let new_model = process_tick(model, ctx)
      #(new_model, effect.tick(Tick))  // Schedule next tick
    }
    // ...
  }
}
```

### Message Tree Architecture

Messages form a tree structure where parent modules wrap child messages:

```
Msg (main module)
├── PlayerMsg(player.Msg)
│   ├── Tick
│   ├── TakeDamage(Float)
│   └── MagicMsg(magic.Msg)
│       ├── Tick
│       ├── UpdatePlayerState(pos, zoom)
│       ├── PlaceSpellInSlot(spell_id, slot)
│       ├── SelectSlot(Int)
│       ├── RemoveProjectile(Int)
│       ├── PickUpWand(wand.Wand)
│       └── ReorderWandSlots(from, to)
├── EnemyMsg(enemy.Msg)
│   ├── Tick
│   └── TakeProjectileDamage(id.Id, Float)
├── AltarMsg(altar.Msg)
│   ├── Tick
│   ├── SpawnAltar(Vec3)
│   └── RemoveAltar(id.Id)
├── MapMsg(map.Msg)
└── PhysicsMsg(game_physics.Msg)
    └── Tick
```

**Cross-module message flow example** (enemy dies → altar spawns):
1. `PhysicsMsg(Tick)` detects projectile-enemy collision
2. Physics dispatches `EnemyMsg(TakeProjectileDamage(id, damage))`
3. Enemy update reduces health, detects death
4. Enemy dispatches `AltarMsg(SpawnAltar(position))` via tagger
5. Altar update creates new altar at position

### Submodule Pattern

Each game subsystem follows this structure:

```
client/src/client/
├── player.gleam           # Player module (movement, camera)
├── player/
│   └── magic.gleam        # Magic subsystem (wand, projectiles, casting)
├── map.gleam              # Map/level module
└── magic_system/
    ├── spell.gleam        # Spell definitions and modifiers
    └── wand.gleam         # Wand logic and casting
```

Each submodule exports:
- `Model` - State type
- `Msg` - Message type
- `init()` - Returns `#(Model, effect.Effect(Msg))`
- `update(model, msg, ctx)` - Returns `#(Model, effect.Effect(Msg))`
- `view(model)` - Returns `List(scene.Node)` or `scene.Node`

### Cross-Module Communication: Message Taggers

Child modules cannot import sibling modules (would create cycles). Instead, the **parent passes message taggers** - functions that wrap messages into the parent's message type. This allows children to dispatch effects to any sibling.

#### How Taggers Work

```gleam
// PARENT: Passes taggers when calling child update
EnemyMsg(enemy_msg) -> {
  let #(new_enemy, enemy_effect) =
    enemy.update(
      model.enemy,
      enemy_msg,
      ctx,
      // Taggers: functions that wrap sibling messages
      player_took_damage: fn(dmg) { PlayerMsg(player.TakeDamage(dmg)) },
      spawn_altar: fn(pos) { AltarMsg(altar.SpawnAltar(pos)) },
      // effect_mapper: wraps child's own messages
      effect_mapper: EnemyMsg,
    )
  #(Model(..model, enemy: new_enemy), enemy_effect, ctx.physics_world)
}
```

```gleam
// CHILD: Accepts taggers as parameters, uses them to dispatch
pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  player_took_damage player_took_damage,  // Tagger for sibling
  spawn_altar spawn_altar,                 // Tagger for sibling
  effect_mapper effect_mapper,             // Tagger for self
) -> #(Model, effect.Effect(game_msg)) {
  case msg {
    Tick -> {
      let #(new_model, damage) = tick(model, ctx)
      // Use tagger to dispatch to sibling
      let damage_effect = case damage >. 0.0 {
        True -> effect.dispatch(player_took_damage(damage))
        False -> effect.none()
      }
      // Use effect_mapper to wrap own messages
      #(new_model, effect.batch([
        effect.tick(effect_mapper(Tick)),
        damage_effect,
      ]))
    }

    TakeProjectileDamage(enemy_id, damage) -> {
      // When enemy dies, dispatch to altar module via tagger
      let spawn_effect = effect.dispatch(spawn_altar(enemy.position))
      // ...
    }
  }
}
```

#### Key Principles

1. **Parent is the router** - Only the parent knows about all siblings and their message types
2. **Taggers are functions** - `fn(args) -> ParentMsg` that wrap child-specific data into parent messages
3. **effect_mapper for self** - Every module needs a tagger to wrap its own `Tick` and other self-referential messages
4. **No sibling imports** - Children never import siblings; they only know about tagger function signatures
5. **Effects bubble up** - Child returns `effect.Effect(game_msg)` (parent's type), parent routes them

### Module Responsibility Separation

Each module should own its domain logic and dispatch cross-module effects via taggers:

| Module | Owns | Dispatches to |
|--------|------|---------------|
| `player` | Movement, wand switching, UI sync | magic (nested) |
| `enemy` | Spawning, movement, attacks | player (damage), altar (death spawn) |
| `altar` | Altar lifecycle, pickup detection | player (wand pickup) |
| `game_physics` | Physics simulation, collisions | enemy (damage), player (projectile removal) |

### Tiramisu Context

The `tiramisu.Context` provides:
- `ctx.delta_time` - Frame duration (`duration.Duration`)
- `ctx.input` - Input state (keys, mouse)
- `ctx.canvas_size` - Viewport dimensions (`Vec2(Float)`)

### Effects

```gleam
effect.tick(Tick)              // Schedule next frame tick
effect.dispatch(msg)           // Dispatch message immediately
effect.batch([...])            // Combine multiple effects
effect.map(eff, wrapper)       // Wrap effect messages
effect.none()                  // No effect
```

### Scene Nodes

```gleam
scene.mesh(id:, geometry:, material:, transform:, physics:)
scene.camera(id:, camera:, transform:, active:, viewport:, postprocessing:)
scene.empty(id:, transform:, children:)
node |> scene.with_children([...])
```

## Game-Specific Architecture

### Magic System

**Spell Types:**
- `DamageSpell` - Projectiles with damage, speed, lifetime, size
- `ModifierSpell` - Modifies spell properties (damage, speed, cast_delay)
- `MulticastSpell` - Casts multiple spells at once

**Modifier Application:**
1. Additive modifiers applied first (damage_addition, speed_addition)
2. Multiplicative modifiers applied second (damage_multiplier, speed_multiplier)

**Wand Casting:**
- Processes slots left-to-right
- Accumulates modifiers until a damage spell is found
- Returns `CastSuccess` with projectiles, delays, and next cast index
- Tracks `total_cast_delay_addition` and `total_recharge_time_addition`

### Cooldown Calculation

```gleam
let total_delay = duration.add(wand.cast_delay, spell_delay_addition)
let final_cooldown = case wrapped {
  True -> duration.add(total_delay, duration.add(wand.recharge_time, recharge_addition))
  False -> total_delay
}
```

## Code Patterns

### Immutable Updates
```gleam
Model(..model, field: new_value)
wand.Wand(..wand, slots: new_slots)
```

### Duration Arithmetic
```gleam
duration.add(base, addition)           // Supports negative values
duration.milliseconds(-170)            // Negative durations for speed boosts
duration.to_seconds(dur)               // Convert for calculations
```

### Input Handling
```gleam
input.is_key_pressed(ctx.input, input.KeyW)       // Held down
input.is_key_just_pressed(ctx.input, input.KeyE)  // Just pressed this frame
input.is_left_button_pressed(ctx.input)           // Mouse held
input.mouse_position(ctx.input)                   // Vec2(Float)
input.mouse_wheel_delta(ctx.input)                // Float
```

## CI/CD

GitHub Actions runs on push to main/master and PRs:
1. Build shared: `cd shared && gleam deps download && gleam build`
2. Test client: `cd client && gleam deps download && gleam test`
3. Format check: `gleam format --check src test`
4. Deploy client to Cloudflare Pages
5. Deploy server to Cloudflare Workers
