# Client Package - AGENTS.md

AI agent documentation for the **client** package: Tiramisu 3D engine, TEA architecture, rendering, and input handling.

---

## Package Overview

The client is a **3D multiplayer game client** built with Gleam targeting JavaScript:

- **Tiramisu Engine:** 3D rendering (Three.js) + physics (Rapier3D)
- **The Elm Architecture (TEA):** Model-Update-View pattern
- **Lustre:** UI framework for HUD/menus
- **WebSockets:** Real-time connection to server
- **Client-Side Rendering:** Display server-authoritative state

**Build Target:** JavaScript (browser)

**Key Principle:** Client is a view of server state. Server is authoritative.

---

## Package Structure

**Target Architecture (Proper Separation of Concerns):**

```
client/
├── src/
│   ├── client.gleam          # Main entry point (TEA root)
│   └── client/
│       ├── player.gleam      # Player rendering + input
│       ├── enemy.gleam       # Enemy rendering
│       ├── projectile.gleam  # Projectile rendering
│       ├── network.gleam     # WebSocket client
│       ├── map.gleam         # Level/terrain rendering
│       └── assets.gleam      # Asset loading
├── test/
├── assets/
└── gleam.toml
```

**Current State (Technical Debt):**
- ⚠️ `player.gleam` currently handles ALL entities (player, enemies, projectiles)
- ⚠️ No separate `enemy.gleam` or `projectile.gleam` modules yet
- 🎯 **Refactoring Goal:** Extract enemy and projectile modules

---

## Tiramisu Framework

### The Elm Architecture (TEA)

Every module follows the TEA pattern:

```gleam
pub type Model {
  Model(/* module state */)
}

pub type Msg {
  // Module messages
}

pub fn init() -> #(Model, effect.Effect(Msg)) {
  let model = // initial state
  let effect = effect.dispatch(Tick)  // Start tick cycle
  #(model, effect)
}

pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  effect_mapper: fn(Msg) -> parent_msg,
  // ... taggers for cross-module communication
) -> #(Model, effect.Effect(parent_msg)) {
  case msg {
    Tick -> {
      let new_model = process_tick(model, ctx)
      #(new_model, effect.dispatch(effect_mapper(Tick)))
    }
    // ... other messages
  }
}

pub fn view(model: Model, ctx: tiramisu.Context) -> List(scene.Node) {
  // Return 3D scene nodes
}
```

**Context (`tiramisu.Context`):**
```gleam
pub type Context {
  Context(
    delta_time: duration.Duration,  // Frame duration
    input: input.Input,              // Keyboard/mouse state
    canvas_size: Vec2(Float),        // Viewport dimensions
  )
}
```

---

## Message Tree Architecture

Messages form a tree where **parents wrap child messages**:

```
Msg (client.gleam - root)
├── PlayerMsg(player.Msg)
│   ├── Tick
│   ├── UpdateFromServer(player.Player)
│   └── MagicMsg(magic.Msg)  // Future: spell UI
│       ├── Tick
│       ├── PlaceSpellInSlot(spell_id, slot)
│       └── SelectSlot(Int)
├── EnemyMsg(enemy.Msg)
│   ├── Tick
│   └── UpdateFromServer(Dict(enemy.Id, enemy.Enemy))
├── ProjectileMsg(projectile.Msg)
│   ├── Tick
│   └── UpdateFromServer(Dict(projectile.Id, projectile.Projectile))
├── NetworkMsg(network.Msg)
│   ├── Connected
│   ├── Disconnected
│   ├── ReceivedMessage(game_message.ServerMessage)
│   └── SendMessage(game_message.ClientMessage)
└── MapMsg(map.Msg)
    └── Tick
```

**Root Module Example:**
```gleam
// client/src/client.gleam

pub type Model {
  Model(
    player: player.Model,
    enemy: enemy.Model,
    projectile: projectile.Model,
    network: network.Model,
    map: map.Model,
  )
}

pub type Msg {
  PlayerMsg(player.Msg)
  EnemyMsg(enemy.Msg)
  ProjectileMsg(projectile.Msg)
  NetworkMsg(network.Msg)
  MapMsg(map.Msg)
}

pub fn update(model: Model, msg: Msg, ctx: Context) -> #(Model, effect.Effect(Msg)) {
  case msg {
    PlayerMsg(player_msg) -> {
      let #(new_player, player_effect, physics_world) =
        player.update(
          model.player,
          player_msg,
          ctx,
          send_to_server: fn(msg) { NetworkMsg(network.SendMessage(msg)) },
          effect_mapper: PlayerMsg,
        )
      #(Model(..model, player: new_player), player_effect, physics_world)
    }
    
    NetworkMsg(network_msg) -> {
      let #(new_network, network_effect) =
        network.update(model.network, network_msg, ctx, NetworkMsg)
      
      // Route server messages to appropriate modules
      case network_msg {
        network.ReceivedMessage(game_message.GameStateUpdate(update)) -> {
          // Dispatch to player, enemy, projectile modules
          let effects = [
            effect.dispatch(PlayerMsg(player.UpdateFromServer(update.players))),
            effect.dispatch(EnemyMsg(enemy.UpdateFromServer(update.enemies))),
            effect.dispatch(ProjectileMsg(projectile.UpdateFromServer(update.projectiles))),
          ]
          #(
            Model(..model, network: new_network),
            effect.batch([network_effect, ..effects]),
          )
        }
        
        _ -> #(Model(..model, network: new_network), network_effect)
      }
    }
    
    // ... other messages
  }
}
```

---

## Cross-Module Communication: Message Taggers

**Problem:** Child modules cannot import siblings (creates import cycles).

**Solution:** Parent passes **taggers** - functions that wrap child data into parent messages.

### How Taggers Work

```gleam
// PARENT: client.gleam
PlayerMsg(player_msg) -> {
  let #(new_player, player_effect, physics_world) =
    player.update(
      model.player,
      player_msg,
      ctx,
      // Tagger: wrap network.Msg into Msg
      send_to_server: fn(client_msg) {
        NetworkMsg(network.SendMessage(client_msg))
      },
      // Tagger: wrap player.Msg into Msg
      effect_mapper: PlayerMsg,
    )
  
  #(Model(..model, player: new_player), player_effect, physics_world)
}
```

```gleam
// CHILD: player.gleam
pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  send_to_server: fn(game_message.ClientMessage) -> parent_msg,
  effect_mapper: fn(Msg) -> parent_msg,
) -> #(Model, effect.Effect(parent_msg), option.Option(physics.PhysicsWorld)) {
  case msg {
    Tick -> {
      // Detect input changes
      let current_input = read_wasd_input(ctx.input)
      
      case current_input != model.last_input {
        True -> {
          let #(w, a, s, d) = current_input
          
          // Use tagger to send to server (via network module)
          let send_effect = effect.dispatch(
            send_to_server(game_message.PlayerAction(player_action.Move(w, a, s, d)))
          )
          
          // Use effect_mapper to schedule next tick
          #(
            Model(..model, last_input: current_input),
            effect.batch([
              effect.dispatch(effect_mapper(Tick)),
              send_effect,
            ]),
            option.None,
          )
        }
        
        False -> {
          // Use effect_mapper to schedule next tick
          #(model, effect.dispatch(effect_mapper(Tick)), option.None)
        }
      }
    }
    
    UpdateFromServer(player_data) -> {
      // Update position from server
      let new_model = Model(..model, position: player_data.position)
      #(new_model, effect.none(), option.None)
    }
  }
}
```

### Tagger Principles

1. **Parent is the router** - Only parent knows about all siblings
2. **Taggers are functions** - `fn(child_data) -> ParentMsg`
3. **effect_mapper for self** - Every module needs to wrap its own messages
4. **No sibling imports** - Children only know tagger signatures
5. **Effects bubble up** - Child returns `effect.Effect(parent_msg)`

### Common Tagger Patterns

**Sending to sibling via parent:**
```gleam
// In enemy.gleam
pub fn update(
  model: Model,
  msg: Msg,
  ctx: Context,
  notify_player_hit: fn(damage: Float) -> parent_msg,  // Tagger to player
  effect_mapper: fn(Msg) -> parent_msg,
) -> #(Model, effect.Effect(parent_msg)) {
  case msg {
    DealDamageToPlayer(damage) -> {
      // Use tagger to notify player module
      let damage_effect = effect.dispatch(notify_player_hit(damage))
      #(model, damage_effect)
    }
  }
}
```

---

## Module Responsibilities

### Player Module (`client/player.gleam`)

**Responsibilities:**
- Read WASD input (send only on change)
- Receive local player position updates from server
- Render local player model
- Update camera to follow player
- Client-side interpolation for smooth movement

**Model:**
```gleam
pub type Model {
  Model(
    player: player.Player,           // Local player state
    render_position: Vec3(Float),    // Interpolated for smoothness
    last_input: #(Bool, Bool, Bool, Bool),  // WASD state
    zoom: Float,
    player_geometry: geometry.Geometry,
    player_material: material.Material,
  )
}
```

**Messages:**
```gleam
pub type Msg {
  Tick
  UpdateFromServer(player.Player)
}
```

**View:**
```gleam
pub fn view(model: Model, ctx: Context) -> List(scene.Node) {
  [
    // Camera
    scene.camera(
      id: "player_camera",
      camera: camera.orthographic(...),
      transform: transform.look_at(
        from: camera_pos,
        to: model.render_position,
        up: option.Some(Vec3(0.0, 1.0, 0.0)),
      ),
      active: True,
      // ...
    ),
    
    // Player mesh
    scene.mesh(
      id: "player",
      geometry: model.player_geometry,
      material: model.player_material,
      transform: transform.at(position: model.render_position),
      physics: option.None,
    ),
  ]
}
```

---

### Enemy Module (`client/enemy.gleam`)

**Responsibilities:**
- Receive enemy states from server
- Render enemy models at server positions
- Display health bars (future)

**Model:**
```gleam
pub type Model {
  Model(
    enemies: dict.Dict(enemy.Id, enemy.Enemy),
    enemy_geometry: geometry.Geometry,
    enemy_material: material.Material,
  )
}
```

**Messages:**
```gleam
pub type Msg {
  Tick
  UpdateFromServer(dict.Dict(enemy.Id, enemy.Enemy))
}
```

**Update:**
```gleam
pub fn update(
  model: Model,
  msg: Msg,
  ctx: Context,
  effect_mapper: fn(Msg) -> parent_msg,
) -> #(Model, effect.Effect(parent_msg)) {
  case msg {
    Tick -> {
      // Client doesn't simulate enemies, just renders
      #(model, effect.dispatch(effect_mapper(Tick)))
    }
    
    UpdateFromServer(enemies) -> {
      // Replace all enemies with server state
      #(Model(..model, enemies: enemies), effect.none())
    }
  }
}
```

**View:**
```gleam
pub fn view(model: Model, ctx: Context) -> List(scene.Node) {
  model.enemies
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(enemy_id, enemy_data) = entry
    
    scene.mesh(
      id: "enemy_" <> enemy_id.to_string(),
      geometry: model.enemy_geometry,
      material: model.enemy_material,
      transform: transform.at(position: enemy_data.position),
      physics: option.None,
    )
  })
}
```

---

### Projectile Module (`client/projectile.gleam`)

**Responsibilities:**
- Receive projectile states from server
- Client-side interpolation for smooth projectile motion
- Render projectile models

**Model:**
```gleam
pub type ClientProjectile {
  ClientProjectile(
    projectile: projectile.Projectile,
    render_position: Vec3(Float),  // Interpolated
  )
}

pub type Model {
  Model(
    projectiles: dict.Dict(projectile.Id, ClientProjectile),
    projectile_geometry: geometry.Geometry,
    projectile_material: material.Material,
  )
}
```

**Messages:**
```gleam
pub type Msg {
  Tick
  UpdateFromServer(dict.Dict(projectile.Id, projectile.Projectile))
}
```

**Update with Interpolation:**
```gleam
const projectile_lerp_factor = 0.35  // More aggressive than player

pub fn update(
  model: Model,
  msg: Msg,
  ctx: Context,
  effect_mapper: fn(Msg) -> parent_msg,
) -> #(Model, effect.Effect(parent_msg)) {
  case msg {
    Tick -> {
      // Interpolate projectile positions
      let new_projectiles = dict.map_values(model.projectiles, fn(_, client_proj) {
        let new_render_pos = vec3.lerp(
          client_proj.render_position,
          client_proj.projectile.position,
          projectile_lerp_factor,
        )
        ClientProjectile(..client_proj, render_position: new_render_pos)
      })
      
      #(
        Model(..model, projectiles: new_projectiles),
        effect.dispatch(effect_mapper(Tick)),
      )
    }
    
    UpdateFromServer(server_projectiles) -> {
      // Merge server updates with existing interpolated positions
      let updated_projectiles = dict.map_values(server_projectiles, fn(id, proj) {
        case dict.get(model.projectiles, id) {
          Ok(existing) -> 
            // Keep existing render position for interpolation
            ClientProjectile(projectile: proj, render_position: existing.render_position)
          Error(_) -> 
            // New projectile, start at server position
            ClientProjectile(projectile: proj, render_position: proj.position)
        }
      })
      
      #(Model(..model, projectiles: updated_projectiles), effect.none())
    }
  }
}
```

**View:**
```gleam
pub fn view(model: Model, ctx: Context) -> List(scene.Node) {
  model.projectiles
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(proj_id, client_proj) = entry
    
    scene.mesh(
      id: "projectile_" <> proj_id.to_string(),
      geometry: model.projectile_geometry,
      material: model.projectile_material,
      transform: transform.at(position: client_proj.render_position),
      physics: option.None,
    )
  })
}
```

---

### Network Module (`client/network.gleam`)

**Responsibilities:**
- Establish WebSocket connection to server
- Encode/decode JSON messages
- Dispatch server messages to parent (which routes to other modules)

**Model:**
```gleam
pub type ConnectionState {
  Disconnected
  Connecting
  Connected(room_id: String)
}

pub type Model {
  Model(
    connection_state: ConnectionState,
    server_url: String,
  )
}
```

**Messages:**
```gleam
pub type Msg {
  Connect(server_url: String, player_name: String)
  Disconnect
  SocketOpened
  SocketClosed
  ReceivedMessage(String)  // Raw JSON string
  SendMessage(game_message.ClientMessage)
}
```

**Update:**
```gleam
pub fn update(
  model: Model,
  msg: Msg,
  effect_mapper: fn(Msg) -> parent_msg,
  on_server_message: fn(game_message.ServerMessage) -> parent_msg,
  _ctx: tiramisu.Context,
) -> #(Model, effect.Effect(parent_msg)) {
  case msg {
    ReceivedMessage(data) -> {
      // Decode JSON and dispatch to parent
      case game_message.decode_server_message(data) {
        Ok(server_msg) -> {
          #(model, effect.dispatch(on_server_message(server_msg)))
        }
        Error(err) -> {
          io.println("Failed to decode: " <> string.inspect(err))
          #(model, effect.none())
        }
      }
    }
    
    SendMessage(client_msg) -> {
      // Encode and send via WebSocket FFI
      let encoded = game_message.encode_client_message(client_msg)
      let send_effect = websocket_send(encoded)
      #(model, send_effect)
    }
    
    // ... other messages
  }
}
```

---

## Input Handling

**Reading Input:**
```gleam
import tiramisu/input

// Keyboard
let w_pressed = input.is_key_pressed(ctx.input, input.KeyW)
let e_just_pressed = input.is_key_just_pressed(ctx.input, input.KeyE)

// Mouse
let mouse_pos = input.mouse_position(ctx.input)  // Vec2(Float)
let left_click = input.is_left_button_pressed(ctx.input)
let wheel_delta = input.mouse_wheel_delta(ctx.input)  // Float
```

**Input Change Detection Pattern:**
```gleam
fn read_wasd_input(input: input.Input) -> #(Bool, Bool, Bool, Bool) {
  let w = input.is_key_pressed(input, input.KeyW)
  let a = input.is_key_pressed(input, input.KeyA)
  let s = input.is_key_pressed(input, input.KeyS)
  let d = input.is_key_pressed(input, input.KeyD)
  #(w, a, s, d)
}

// In update(Tick):
let current_input = read_wasd_input(ctx.input)
case current_input == model.last_input {
  True -> effect.none()  // Don't send duplicate
  False -> {
    let #(w, a, s, d) = current_input
    effect.dispatch(send_to_server(PlayerAction(Move(w, a, s, d))))
  }
}
```

---

## Scene Nodes & Rendering

**Basic Scene Nodes:**
```gleam
import tiramisu/scene
import tiramisu/transform
import tiramisu/geometry
import tiramisu/material
import tiramisu/camera

// Mesh
scene.mesh(
  id: "player",
  geometry: geometry,
  material: material,
  transform: transform.at(position: Vec3(x, y, z)),
  physics: option.None,
)

// Camera
scene.camera(
  id: "main_camera",
  camera: camera.orthographic(
    left: -zoom,
    right: zoom,
    top: zoom,
    bottom: -zoom,
    near: 0.1,
    far: 200.0,
  ),
  transform: transform.look_at(
    from: cam_transform,
    to: target_transform,
    up: option.Some(Vec3(0.0, 1.0, 0.0)),
  ),
  active: True,
  viewport: option.None,
  postprocessing: option.None,
)

// Empty node (grouping)
scene.empty(
  id: "root",
  transform: transform.identity,
  children: [child1, child2],
)
```

---

## Refactoring Checklist

**To achieve proper architecture, extract from current `player.gleam`:**

### 1. Create `enemy.gleam`
- [ ] Move `enemies: Dict(enemy.Id, enemy.Enemy)` from player Model
- [ ] Move `enemy_geometry` and `enemy_material` from player Model
- [ ] Create `enemy.Msg` with `Tick` and `UpdateFromServer`
- [ ] Extract enemy rendering logic from `player.view()`
- [ ] Update `client.gleam` to add `EnemyMsg` variant
- [ ] Add tagger in `client.update()` for routing server updates

### 2. Create `projectile.gleam`
- [ ] Move `projectiles: Dict(projectile.Id, ClientProjectile)` from player Model
- [ ] Move `projectile_geometry` and `projectile_material` from player Model
- [ ] Create `projectile.Msg` with `Tick` and `UpdateFromServer`
- [ ] Extract projectile interpolation logic
- [ ] Extract projectile rendering logic from `player.view()`
- [ ] Update `client.gleam` to add `ProjectileMsg` variant

### 3. Clean up `player.gleam`
- [ ] Remove enemy-related code
- [ ] Remove projectile-related code
- [ ] Keep only local player state and rendering
- [ ] Keep camera logic (follows player)
- [ ] Keep input detection

### 4. Update `client.gleam`
- [ ] Add `enemy: enemy.Model` to Model
- [ ] Add `projectile: projectile.Model` to Model
- [ ] Add `EnemyMsg` and `ProjectileMsg` to Msg
- [ ] Route server `GameStateUpdate` to all three modules
- [ ] Combine views from all modules in main `view()`

---

## Common Patterns

### 1. Server State Synchronization

```gleam
UpdateFromServer(enemies) -> {
  // Replace client state with server state
  #(Model(..model, enemies: enemies), effect.none())
}
```

**Client NEVER modifies game state, only renders server data.**

### 2. Client-Side Interpolation

```gleam
// In Tick:
let new_render_pos = vec3.lerp(
  model.render_position,    // Current (old)
  model.player.position,    // Target (from server)
  0.2,                      // Interpolation factor
)
```

### 3. Input Change Detection

```gleam
let current_input = #(w, a, s, d)
case current_input != model.last_input {
  True -> send_to_server(Move(w, a, s, d))
  False -> effect.none()
}
```

---

## Architecture Decisions

### 1. Separate Modules for Each Entity Type

**Decision:** player.gleam, enemy.gleam, projectile.gleam as separate modules.

**Rationale:**
- **Separation of concerns** - Each module owns its domain
- **Better testability** - Test each entity type independently
- **Cleaner code** - Smaller, focused modules
- **Parallel development** - Team members can work on different entity types

**Trade-off:** More files, requires taggers for communication (worth it).

### 2. Client-Side Interpolation

**Decision:** Interpolate positions between server updates.

**Rationale:**
- Smooth 20 Hz server updates to 60 FPS rendering
- Better player experience
- No gameplay impact (visual only)

**Trade-off:** Slight visual lag, but worth it for smoothness.

### 3. Input Change Detection

**Decision:** Only send WASD when keys change.

**Rationale:**
- 85-95% bandwidth reduction
- Server continues last input until change
- No gameplay impact

### 4. Client-Side Prediction (v0.8.0)

**Decision:** Predict player movement locally before server confirms.

**Rationale:**
- **Instant visual feedback** - Player movement feels responsive (0ms vs 50ms lag)
- **Server remains authoritative** - Server can correct bad predictions
- **Better player experience** - No perceived input lag

**How It Works:**

1. **Extrapolation Approach:** Client extrapolates from last known server state
2. **Track Time:** Accumulate time since last server update (`time_since_server_update`)
3. **Calculate Current Velocity:** Use CURRENT input (w,a,s,d) to calculate velocity (mirrors server logic)
4. **Predict:** `predicted_position = server_position + current_velocity * time_elapsed`
5. **Server Update:** Reset timer to 0, start extrapolating from new server state
6. **If Mismatch:** Snap to server position if error > 0.1 units

**Why Current Input Instead of Server Velocity:**
- Server velocity reflects OLD input from 50ms ago (network + processing delay)
- Client knows CURRENT input state (what player is pressing RIGHT NOW)
- Using current input = predicting what server WILL calculate, not what it DID calculate
- Result: Near-zero prediction errors for local player

**Why Extrapolation Instead of Frame-by-Frame:**
- Client renders at 60 FPS, server updates at 20 Hz
- Extrapolating from server position avoids accumulating rounding errors
- Each server update resets the accumulator, preventing drift

**Implementation:**
```gleam
pub type Model {
  Model(
    player: player.Player,                    // Server-authoritative state
    predicted_position: Vec3(Float),          // Extrapolated position
    render_position: Vec3(Float),             // Smoothed for rendering
    time_since_server_update: Float,          // Time accumulator
    input_history: List(InputRecord),         // For reconciliation
    // ...
  )
}

// Every frame (60 FPS):
// 1. Accumulate time since last server update
let new_time_since_update = model.time_since_server_update +. dt

// 2. Calculate velocity from CURRENT input (what player is pressing NOW)
let current_velocity = calculate_velocity_from_input(w, a, s, d, speed)

// 3. Extrapolate from server position using current velocity
let new_predicted_position =
  vec3f.add(
    model.player.position,               // Last known server position
    vec3f.scale(current_velocity, by: new_time_since_update)
  )

// 4. Render using predicted position
shared_vec3.lerp(model.render_position, new_predicted_position, lerp_factor)

// When server update arrives (every 50ms):
// 1. Reset time accumulator
time_since_server_update = 0.0

// 2. Check prediction accuracy
case position_error >. 0.1 {
  True -> snap_to_server_position()   // Prediction wrong (rare)
  False -> keep_predicted_position()  // Prediction accurate (common)
}
```

**Trade-off:**
- Occasional snappy corrections when prediction wrong (rare in single-player, more common with lag)
- Worth it for instant responsive feel

**Related Files:**
- `client/src/client/player.gleam:29-47` - Model with time_since_server_update
- `client/src/client/player.gleam:459-492` - calculate_velocity_from_input (mirrors server)
- `client/src/client/player.gleam:168-183` - Extrapolation using current input
- `client/src/client/player.gleam:340-380` - Server reconciliation with timer reset

---

## Version History

- **v0.1.0** - Monolithic player.gleam (current - tech debt)
- **v0.2.0** - Refactored modular architecture (target)

**Current Version: v0.1.0 (needs refactoring to v0.2.0)**
