# Server Package - AGENTS.md

AI agent documentation for the **server** package: Erlang/OTP actor architecture, game simulation, and multiplayer coordination.

---

## Package Overview

The server is a **real-time multiplayer game server** built with Gleam targeting Erlang/OTP:

- **Actor-Based:** OTP processes for players, enemies, projectiles, wands
- **Factory Supervisors:** Dynamic actor spawning with fault tolerance
- **Server-Authoritative:** All game logic runs on server (20 Hz tick rate)
- **WebSocket Server:** ewe library for real-time client communication
- **Fixed Timestep:** Deterministic 50ms physics simulation

**Build Target:** Erlang/OTP

**Key Principle:** Actors are the single source of truth. No cached state.

---

## Package Structure

```
server/
├── src/
│   ├── server.gleam          # Main entry, supervision tree
│   └── server/
│       ├── room.gleam        # Game room actor (tick coordinator)
│       ├── player.gleam      # Player actor (movement, wands)
│       ├── enemy.gleam       # Enemy actor (AI, combat)
│       ├── projectile.gleam  # Projectile actor (physics)
│       ├── wand.gleam        # Wand actor (spell casting)
│       └── tick.gleam        # Precision tick scheduler
├── test/
│   ├── room_test.gleam
│   ├── player_test.gleam
│   └── tick_test.gleam
└── gleam.toml
```

---

## Supervision Tree

```
static_supervisor (OneForOne strategy)
├── player_factory        # Spawns PlayerActor instances
├── projectile_factory    # Spawns ProjectileActor instances
├── enemy_factory         # Spawns EnemyActor instances
├── wand_factory          # Spawns WandActor instances
├── room                  # Single room coordinator (tick loop)
└── ewe_server            # WebSocket server (port 8080)
```

**Supervision Strategy:** `OneForOne`
- If a child crashes, only that child is restarted
- Siblings continue running unaffected
- Room restart = full game reset (all actors stop)

**Code Location:** `server/src/server.gleam`

---

## Core Architecture Patterns

### 1. Factory Supervisor Pattern (gleam/otp/factory_supervisor)

**Purpose:** Dynamically spawn actors under supervision without crashing parent.

**We use `gleam/otp/factory_supervisor`** from the gleam_otp library, not a custom implementation.

**Setup in server.gleam:**
```gleam
import gleam/otp/factory_supervisor
import gleam/otp/static_supervisor
import gleam/otp/supervision

pub fn main() {
  // Create factory supervisors for all actor types
  let player_factory_name = process.new_name("player_factory")
  let player_factory =
    factory_supervisor.worker_child(player.start)
    |> factory_supervisor.named(player_factory_name)
    |> factory_supervisor.supervised()

  let enemy_factory_name = process.new_name("enemy_factory")
  let enemy_factory =
    factory_supervisor.worker_child(enemy.start)
    |> factory_supervisor.named(enemy_factory_name)
    |> factory_supervisor.supervised()

  // ... projectile_factory, wand_factory ...

  // Pass factory names to room
  let room =
    supervision.worker(fn() {
      room.start(
        game_room_name,
        player_factory_name,
        projectile_factory_name,
        enemy_factory_name,
        wand_factory_name,
      )
    })

  // Add all to supervision tree
  let assert Ok(_sup_tree) =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(player_factory)
    |> static_supervisor.add(projectile_factory)
    |> static_supervisor.add(enemy_factory)
    |> static_supervisor.add(wand_factory)
    |> static_supervisor.add(room)
    |> static_supervisor.start()

  process.sleep_forever()
}
```

**Room State (Typed Factories):**
```gleam
pub type State {
  State(
    // ... other fields ...
    
    player_factory: factory_supervisor.Supervisor(
      player_actor.SpawnArguments(Msg),
      process.Subject(player_actor.Msg),
    ),
    enemy_factory: factory_supervisor.Supervisor(
      enemy_actor.SpawnArguments(Msg),
      process.Subject(enemy_actor.Msg),
    ),
    // ... etc
  )
}
```

**Spawning Actors:**
```gleam
// In room.gleam when spawning enemy:
let enemy_spawn_args =
  enemy_actor.SpawnArguments(
    id: new_enemy_id,
    enemy: new_enemy,
    room: state.self,
    to_room: to_room,
  )

case factory_supervisor.start_child(state.enemy_factory, enemy_spawn_args) {
  Ok(started) -> {
    // started.data contains the Subject(enemy_actor.Msg)
    let new_enemy_actors =
      dict.insert(state.enemy_actors, new_enemy_id, started.data)
    
    actor.continue(
      State(..state, enemy_actors: new_enemy_actors),
    )
  }
  
  Error(_) -> {
    logging.log(logging.Error, "Failed to spawn enemy actor")
    actor.continue(state)
  }
}
```

**Key Points:**
- ✅ Use `gleam/otp/factory_supervisor` from gleam_otp (not custom code)
- ✅ Factories created with `worker_child()`, `named()`, `supervised()`
- ✅ Pass factory *names* (not subjects) to room
- ✅ `start_child()` returns `Result(Started, Error)` where `Started.data` is the actor Subject
- ✅ Fault tolerance: crashes don't bring down parent
- ✅ Scales to thousands of entities

---

### 2. Room Actor: Tick Coordinator

**Role:** Orchestrate 20 Hz game loop without maintaining cached state.

**State:**
```gleam
pub type State {
  State(
    // Connection management
    connection_to_player: Dict(ewe.WebsocketConnection, player.Id),
    connections: Dict(ewe.WebsocketConnection, ConnectionInfo),
    
    // ID generators
    next_player_id: Int,
    next_projectile_id: Int,
    next_enemy_id: Int,
    
    // Actor references (NOT state, just Subjects)
    player_actors: Dict(player.Id, process.Subject(player_actor.Msg)),
    projectile_actors: Dict(projectile.Id, process.Subject(projectile_actor.Msg)),
    enemy_actors: Dict(enemy.Id, process.Subject(enemy_actor.Msg)),
    
    // Cached player positions from previous tick (for enemy AI)
    last_player_positions: Dict(player.Id, Vec3(Float)),
    
    // Tick coordination (ephemeral - only during tick processing)
    tick_state: TickState,
    tick_scheduler: tick.TickScheduler,
    last_tick_timestamp: timestamp.Timestamp,
    
    // Factory supervisors (gleam/otp/factory_supervisor)
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
    wand_factory: factory_supervisor.Supervisor(
      wand_actor.SpawnArguments(player_actor.Msg),
      process.Subject(wand_actor.Msg),
    ),
    
    self: process.Subject(Msg),
  )
}
```

**Tick State Machine:**
```gleam
pub type TickState {
  Idle  // Waiting for next tick
  
  Collecting(
    expected_player_count: Int,
    player_responses: Dict(id.PlayerId, player.Player),
    projectile_responses: Dict(id.ProjectileId, projectile.Projectile),
    enemy_responses: Dict(id.EnemyId, enemy.Enemy),
    tick_number: Int,
  )
}
```

**Messages:**
```gleam
pub type Msg {
  // Tick cycle
  Tick
  FinalizeTick(tick_number: Int)
  
  // Actor state updates
  PlayerStateChanged(id.PlayerId, player.Player)
  ProjectileStateChanged(id.ProjectileId, projectile.Projectile)
  EnemyStateChanged(id.EnemyId, enemy.Enemy)
  
  // Actor lifecycle
  RemoveProjectile(id.ProjectileId)
  RemoveEnemy(id.EnemyId)
  
  // Client connections
  ClientConnected(ewe.WebsocketConnection)
  ClientDisconnected(ewe.WebsocketConnection)
  ClientMessage(ewe.WebsocketConnection, String)
}
```

---

### 3. Tick Cycle Flow

**CRITICAL: 20 Hz (50ms) Tick Rate**

```gleam
// 1. Tick Start (handle_tick)
fn handle_tick(state: State) -> actor.Next(State, Msg) {
  // CRITICAL: Capture timestamp ONCE to prevent drift
  let now = timestamp.system_time()
  let tick_scheduler = tick.advance_with_time(state.tick_scheduler, now)
  let tick_number = tick.current_tick(tick_scheduler)
  
  // Send Tick message to all actors
  let _ = dict.each(state.player_actors, fn(_, subject) {
    actor.send(subject, player.Tick)
  })
  let _ = dict.each(state.enemy_actors, fn(_, subject) {
    actor.send(subject, enemy_actor.Tick(state.last_player_positions))
  })
  let _ = dict.each(state.projectile_actors, fn(_, subject) {
    actor.send(subject, projectile_actor.Tick)
  })
  
  // Schedule BOTH messages at 50ms (using same timestamp)
  process.send_after(state.self, 50, FinalizeTick(tick_number))
  process.send_after(state.self, 50, Tick)
  
  // Transition to Collecting state
  actor.continue(State(
    ..state,
    tick_state: Collecting(
      expected_player_count: dict.size(state.player_actors),
      player_responses: dict.new(),
      projectile_responses: dict.new(),
      enemy_responses: dict.new(),
      tick_number: tick_number,
    ),
    tick_scheduler: tick_scheduler,
  ))
}

// 2. Actor Responses (handle_player_state_changed, etc.)
fn handle_player_state_changed(
  state: State,
  player_id: id.PlayerId,
  player: player.Player,
) -> actor.Next(State, Msg) {
  case state.tick_state {
    Collecting(expected, players, projectiles, enemies, tick_num) -> {
      let new_players = dict.insert(players, player_id, player)
      
      actor.continue(State(
        ..state,
        tick_state: Collecting(
          expected,
          new_players,
          projectiles,
          enemies,
          tick_num,
        ),
      ))
    }
    
    Idle -> actor.continue(state)  // Ignore late responses
  }
}

// 3. Finalize Tick (finalize_tick)
fn finalize_tick(state: State, tick_number: Int) -> actor.Next(State, Msg) {
  case state.tick_state {
    Collecting(_, players, projectiles, enemies, _) -> {
      // Broadcast game state to all clients
      let update = game_message.GameStateUpdate(
        tick: tick_number,
        players: players,
        projectiles: projectiles,
        enemies: enemies,
      )
      let message = game_message.encode_server_message(
        game_message.GameStateUpdate(update)
      )
      
      dict.each(state.connections, fn(_, conn) {
        ewe.send(conn, ewe.Text(message))
      })
      
      // Cache player positions for enemy AI (acceptable 50ms lag)
      let new_player_positions = dict.map_values(players, fn(_, player) {
        player.position
      })
      
      // Reset to Idle, discard ephemeral collections
      // DO NOT schedule next Tick (already scheduled in handle_tick)
      actor.continue(State(
        ..state,
        tick_state: Idle,
        last_player_positions: new_player_positions,
      ))
    }
    
    Idle -> actor.continue(state)  // Duplicate finalize, ignore
  }
}
```

**Critical Timing Pattern:**

❌ **WRONG (causes 10 Hz):**
```gleam
fn handle_tick(state) {
  // Send tick...
  process.send_after(self, 50, FinalizeTick)
  // Next tick scheduled in finalize_tick (50ms later)
}

fn finalize_tick(state) {
  // Broadcast...
  process.send_after(self, 50, Tick)  // 100ms total cycle!
}
```

✅ **CORRECT (achieves 20 Hz):**
```gleam
fn handle_tick(state) {
  let now = timestamp.system_time()  // Capture ONCE
  // Send tick...
  process.send_after(self, 50, FinalizeTick(tick_num))
  process.send_after(self, 50, Tick)  // Both scheduled at 50ms
}

fn finalize_tick(state) {
  // Broadcast...
  // Do NOT schedule Tick here
}
```

---

## Entity Actors

### PlayerActor (`server/src/server/player.gleam`)

**Responsibilities:**
- Process WASD input from client
- Calculate velocity (server-authoritative)
- Update position using velocity
- Manage wand inventory
- Handle wand switching and spell casting

**State:**
```gleam
pub type State {
  State(
    id: id.PlayerId,
    name: String,
    position: Vec3(Float),
    velocity: Vec3(Float),  // Calculated from WASD
    active_wand_index: Int,
    wands: List(Subject(wand_actor.Msg)),
    wand_factory: Subject(factory_supervisor.Msg(wand_actor.State)),
    room: Subject(room.Msg),
  )
}
```

**Messages:**
```gleam
pub type Msg {
  Tick
  Move(w: Bool, a: Bool, s: Bool, d: Bool)
  SwitchWand(Int)
  CastSpell
}
```

**Movement Logic:**
```gleam
fn handle_move(state: State, w: Bool, a: Bool, s: Bool, d: Bool) -> State {
  let speed = 5.0
  let camera_angle = 0.7071067811865476  // cos(45°) for isometric view
  
  // Convert booleans to floats
  let forward = case w { True -> 1.0, False -> 0.0 }
  let back = case s { True -> 1.0, False -> 0.0 }
  let left = case a { True -> 1.0, False -> 0.0 }
  let right = case d { True -> 1.0, False -> 0.0 }
  
  let net_forward = forward -. back
  let net_right = right -. left
  
  // Camera-relative transformation (45° isometric)
  let direction_x = camera_angle *. (net_right -. net_forward)
  let direction_z = -.camera_angle *. (net_forward +. net_right)
  
  // Normalize diagonal movement (prevent faster diagonal)
  let length = float.square_root(direction_x *. direction_x +. direction_z *. direction_z)
  let #(norm_x, norm_z) = case length >. 0.0 {
    True -> #(direction_x /. length, direction_z /. length)
    False -> #(0.0, 0.0)
  }
  
  let velocity = vec3.new(norm_x *. speed, 0.0, norm_z *. speed)
  State(..state, velocity: velocity)
}

fn update_movement(state: State, delta_time: Float) -> State {
  let new_position = vec3.add(
    state.position,
    vec3.scale(state.velocity, delta_time),
  )
  State(..state, position: new_position)
}
```

**Actor Lifecycle:**
```gleam
pub fn start(
  id: id.PlayerId,
  name: String,
  position: Vec3(Float),
  wand_factory: Subject(factory_supervisor.Msg(wand_actor.State)),
  room: Subject(room.Msg),
) -> Result(Subject(Msg), actor.StartError) {
  actor.start(State(
    id: id,
    name: name,
    position: position,
    velocity: vec3.zero(),
    active_wand_index: 0,
    wands: [],
    wand_factory: wand_factory,
    room: room,
  ), handle_message)
}

fn handle_message(msg: Msg, state: State) -> actor.Next(Msg, State) {
  case msg {
    Tick -> {
      let delta = 0.05  // Fixed 50ms
      let new_state = update_movement(state, delta)
      
      // Send state back to room
      let player_data = player.Player(
        id: new_state.id,
        name: new_state.name,
        position: new_state.position,
        velocity: new_state.velocity,
        active_wand_index: new_state.active_wand_index,
      )
      actor.send(new_state.room, room.PlayerStateChanged(new_state.id, player_data))
      
      actor.continue(new_state)
    }
    
    Move(w, a, s, d) -> {
      let new_state = handle_move(state, w, a, s, d)
      actor.continue(new_state)
    }
    
    // ... other messages
  }
}
```

---

### EnemyActor (`server/src/server/enemy_actor.gleam`)

**Responsibilities:**
- Chase nearest player (simple AI)
- Stay ground-locked (y = 0.9)
- Take damage and die
- Report state to room each tick

**State:**
```gleam
pub type State {
  State(
    id: id.EnemyId,
    enemy_type: enemy.EnemyType,
    position: Vec3(Float),
    health: Float,
    room: Subject(room.Msg),
  )
}
```

**Messages:**
```gleam
pub type Msg {
  Tick(player_positions: Dict(id.PlayerId, Vec3(Float)))
  TakeDamage(Float)
}
```

**AI Logic:**
```gleam
fn update_ai(
  state: State,
  player_positions: Dict(id.PlayerId, Vec3(Float)),
) -> State {
  case find_nearest_player(state.position, player_positions) {
    Some(target_pos) -> {
      let direction = vec3.subtract(target_pos, state.position)
      let horizontal_direction = vec3.new(direction.x, 0.0, direction.z)  // Ignore Y
      let normalized = vec3.normalize(horizontal_direction)
      
      let speed = enemy.speed(state.enemy_type)  // 2.0 for Zombie
      let delta = 0.05  // Fixed 50ms
      let movement = vec3.scale(normalized, speed *. delta)
      
      let new_pos = vec3.add(state.position, movement)
      
      // CRITICAL: Lock Y coordinate to ground level
      let locked_pos = vec3.new(new_pos.x, 0.9, new_pos.z)
      
      State(..state, position: locked_pos)
    }
    
    None -> state  // No players, stay still
  }
}

fn find_nearest_player(
  position: Vec3(Float),
  player_positions: Dict(id.PlayerId, Vec3(Float)),
) -> Option(Vec3(Float)) {
  player_positions
  |> dict.values()
  |> list.fold(None, fn(nearest, player_pos) {
    let distance = vec3.distance(position, player_pos)
    case nearest {
      None -> Some(player_pos)
      Some(#(_, min_dist)) if distance < min_dist -> Some(player_pos)
      _ -> nearest
    }
  })
}
```

**Damage Handling:**
```gleam
fn handle_take_damage(state: State, damage: Float) -> State {
  let new_health = state.health -. damage
  
  case new_health <=. 0.0 {
    True -> {
      // Notify room of death
      actor.send(state.room, room.RemoveEnemy(state.id))
      // Actor will be stopped by room
      state
    }
    
    False -> State(..state, health: new_health)
  }
}
```

---

### ProjectileActor (`server/src/server/projectile_actor.gleam`)

**Responsibilities:**
- Move in straight line (velocity-based)
- Track lifetime (remove when expired)
- Report position to room each tick

**State:**
```gleam
pub type State {
  State(
    id: id.ProjectileId,
    position: Vec3(Float),
    velocity: Vec3(Float),
    damage: Float,
    lifetime_remaining: Float,  // Milliseconds
    owner_id: id.PlayerId,
    room: Subject(room.Msg),
  )
}
```

**Physics:**
```gleam
fn update_physics(state: State) -> State {
  let delta = 0.05  // Fixed 50ms
  
  // Update position
  let new_position = vec3.add(
    state.position,
    vec3.scale(state.velocity, delta),
  )
  
  // Decrease lifetime
  let new_lifetime = state.lifetime_remaining -. 50.0
  
  case new_lifetime <=. 0.0 {
    True -> {
      // Lifetime expired, request removal
      actor.send(state.room, room.RemoveProjectile(state.id))
      state  // Will be stopped by room
    }
    
    False -> State(
      ..state,
      position: new_position,
      lifetime_remaining: new_lifetime,
    )
  }
}
```

---

### WandActor (`server/src/server/wand_actor.gleam`)

**Responsibilities:**
- Store spell sequence
- Handle casting (cooldown, mana)
- Spawn projectiles when cast

**State:**
```gleam
pub type State {
  State(
    id: id.WandId,
    slots: List(Option(spell.Spell)),
    cast_delay: duration.Duration,
    recharge_time: duration.Duration,
    cooldown_remaining: duration.Duration,
    room: Subject(room.Msg),
    owner_id: id.PlayerId,
  )
}
```

**Casting:**
```gleam
fn handle_cast(state: State) -> #(State, List(projectile.Projectile)) {
  case duration.is_zero(state.cooldown_remaining) {
    True -> {
      // Process spell sequence
      let #(projectiles, total_delay) = process_spell_sequence(state.slots)
      
      let new_cooldown = duration.add(state.cast_delay, total_delay)
      let new_state = State(..state, cooldown_remaining: new_cooldown)
      
      #(new_state, projectiles)
    }
    
    False -> {
      // Still on cooldown
      #(state, [])
    }
  }
}
```

---

## Tick Scheduler (`server/src/server/tick.gleam`)

**Purpose:** Maintain precise 20 Hz timing without drift.

**State:**
```gleam
pub type Scheduler {
  Scheduler(
    tick_number: Int,
    last_tick_time: timestamp.SystemTime,
  )
}
```

**Key Functions:**
```gleam
pub fn new() -> Scheduler {
  Scheduler(
    tick_number: 0,
    last_tick_time: timestamp.system_time(),
  )
}

// CRITICAL: Accept timestamp to prevent drift
pub fn advance_with_time(
  scheduler: Scheduler,
  now: timestamp.SystemTime,
) -> Scheduler {
  Scheduler(
    tick_number: scheduler.tick_number + 1,
    last_tick_time: now,  // Use provided timestamp, not system_time()
  )
}

// Always return 50ms for deterministic physics
pub fn delta_time(_scheduler: Scheduler) -> Float {
  0.05  // Fixed timestep
}

pub fn current_tick(scheduler: Scheduler) -> Int {
  scheduler.tick_number
}
```

**Why Fixed Timestep?**
- Deterministic simulation (same inputs → same outputs)
- No accumulation errors
- Easier debugging (frame-perfect replay)
- Consistent physics across variable server load

---

## WebSocket Integration

**ewe Server Setup:**
```gleam
// server/src/server.gleam

fn start_ewe_server(room: Subject(room.Msg)) {
  ewe.new(fn(request) {
    ewe.upgrade_websocket(
      request,
      on_init: fn(conn, _selector) {
        actor.send(room, room.ClientConnected(conn))
        #(Nil, None)
      },
      handler: fn(conn, _state, message) {
        case message {
          ewe.Text(data) -> {
            actor.send(room, room.ClientMessage(conn, data))
          }
          ewe.Binary(data) -> {
            let str = bit_array.to_string(data) |> result.unwrap("")
            actor.send(room, room.ClientMessage(conn, str))
          }
          _ -> Nil
        }
        ewe.websocket_continue(Nil)
      },
      on_close: fn(conn, _state) {
        actor.send(room, room.ClientDisconnected(conn))
      },
    )
  })
  |> ewe.listening(8080)
  |> ewe.start()
}
```

**Message Handling:**
```gleam
fn handle_client_message(
  state: State,
  conn: ewe.WebsocketConnection,
  data: String,
) -> actor.Next(State, Msg) {
  case game_message.decode_client_message(data) {
    Ok(game_message.PlayerAction(action)) -> {
      // Find player ID for this connection
      case find_player_by_connection(state.connections, conn) {
        Some(player_id) -> {
          // Forward action to player actor
          case dict.get(state.player_actors, player_id) {
            Ok(player_subject) -> {
              send_action_to_player(player_subject, action)
              actor.continue(state)
            }
            Error(_) -> actor.continue(state)
          }
        }
        None -> actor.continue(state)
      }
    }
    
    Ok(game_message.RequestJoin(name)) -> {
      // Spawn new player actor
      handle_join_request(state, conn, name)
    }
    
    Error(_) -> {
      io.println("Failed to decode client message")
      actor.continue(state)
    }
  }
}
```

---

## Critical Patterns & Best Practices

### 1. Always Use Factory Supervisors

❌ **WRONG:**
```gleam
case projectile_actor.start(id, position, velocity, damage, room) {
  Ok(subject) -> dict.insert(actors, id, subject)
  Error(_) -> actors  // Crash if error!
}
```

✅ **CORRECT:**
```gleam
// Create spawn arguments
let spawn_args = projectile_actor.SpawnArguments(
  id: projectile_id,
  projectile: projectile_data,
  room: state.self,
  to_room: to_room,
)

// Use factory_supervisor from gleam_otp
case factory_supervisor.start_child(state.projectile_factory, spawn_args) {
  Ok(started) -> dict.insert(actors, id, started.data)  // .data contains Subject
  Error(_) -> actors  // Factory handles restart
}
```

### 2. Capture Timestamp Once Per Tick

❌ **WRONG:**
```gleam
fn handle_tick(state) {
  let tick_scheduler = tick.advance(state.tick_scheduler)  // Uses system_time() internally
  // ...
  process.send_after(self, 50, FinalizeTick)
  process.send_after(self, 50, Tick)  // Different timestamp = drift
}
```

✅ **CORRECT:**
```gleam
fn handle_tick(state) {
  let now = timestamp.system_time()  // Capture ONCE
  let tick_scheduler = tick.advance_with_time(state.tick_scheduler, now)
  // ...
  process.send_after(self, 50, FinalizeTick)
  process.send_after(self, 50, Tick)  // Both use same timestamp
}
```

### 3. Don't Cache Actor State in Room

❌ **WRONG:**
```gleam
pub type State {
  State(
    player_actors: Dict(PlayerId, Subject(player.Msg)),
    cached_players: Dict(PlayerId, player.Player),  // Dual source of truth!
  )
}
```

✅ **CORRECT:**
```gleam
pub type State {
  State(
    player_actors: Dict(PlayerId, Subject(player.Msg)),  // Only references
    tick_state: TickState,  // Ephemeral collections during tick
  )
}
```

### 4. Fixed Timestep for Physics

```gleam
// ALWAYS use fixed delta time
let delta = 0.05  // 50ms

// Update position
let new_position = vec3.add(position, vec3.scale(velocity, delta))
```

### 5. Ground-Lock Enemies

```gleam
// After AI movement, lock Y coordinate
let new_pos = vec3.add(state.position, movement)
let locked_pos = vec3.new(new_pos.x, 0.9, new_pos.z)  // Force y=0.9
```

---

## Testing Guidelines

### Actor Testing

```gleam
import gleeunit
import server/player

pub fn player_movement_test() {
  let assert Ok(player_subject) = player.start(
    id: id.new_player(),
    name: "Alice",
    position: vec3.zero(),
    wand_factory: test_factory,
    room: test_room,
  )
  
  // Send move command
  actor.send(player_subject, player.Move(
    w: True,
    a: False,
    s: False,
    d: False,
  ))
  
  // Send tick
  actor.send(player_subject, player.Tick)
  
  // Check state changed message was sent to room
  // (Would need test helper to capture messages)
}
```

### Tick Timing Test

```gleam
pub fn tick_precision_test() {
  let scheduler = tick.new()
  let now = timestamp.system_time()
  
  let scheduler2 = tick.advance_with_time(scheduler, now)
  
  assert tick.current_tick(scheduler2) == 1
  assert tick.delta_time(scheduler2) == 0.05
}
```

---

## Common Pitfalls

### ❌ Scheduling Next Tick in finalize_tick

**Problem:** Creates 100ms cycle (10 Hz instead of 20 Hz)

```gleam
fn finalize_tick(state) {
  broadcast_game_state(state)
  process.send_after(state.self, 50, Tick)  // WRONG!
  // Total: Tick → 50ms → Finalize → 50ms → Tick = 100ms
}
```

**Solution:** Schedule both in handle_tick

```gleam
fn handle_tick(state) {
  // ...
  process.send_after(state.self, 50, FinalizeTick)
  process.send_after(state.self, 50, Tick)
  // Total: Tick → 50ms → Tick = 50ms ✅
}
```

### ❌ Using Variable Timestep

**Problem:** Non-deterministic physics, accumulation errors

```gleam
fn update_physics(state, actual_delta: Float) {
  // Different delta each frame = inconsistent simulation
}
```

**Solution:** Always use fixed 50ms

```gleam
fn update_physics(state) {
  let delta = 0.05  // Fixed
  // Deterministic simulation
}
```

### ❌ Forgetting to Lock Enemy Y Coordinate

**Problem:** Enemies float or sink over time

```gleam
fn update_ai(state, target) {
  let new_pos = vec3.add(state.position, movement)
  State(..state, position: new_pos)  // Y can drift!
}
```

**Solution:** Always lock Y after movement

```gleam
fn update_ai(state, target) {
  let new_pos = vec3.add(state.position, movement)
  let locked = vec3.new(new_pos.x, 0.9, new_pos.z)
  State(..state, position: locked)  // Y locked ✅
}
```

---

## Future Work

### High Priority

1. **Collision Detection**
   - Check projectile vs enemy in finalize_tick
   - Send TakeDamage to EnemyActor
   - Remove projectile on hit

2. **Damage System**
   - Implement TakeDamage in EnemyActor
   - Enemy death spawns loot/particles
   - Broadcast death event to clients

3. **Enemy Spawning**
   - Wave-based spawner
   - Difficulty scaling
   - Spawn zones

### Medium Priority

4. **Player Health**
   - Add health to PlayerActor
   - Enemy collision damage
   - Death/respawn system

5. **Projectile Collision with Terrain**
   - Raycasting for walls
   - Despawn on collision

6. **Performance Optimization**
   - Profile tick loop (<10ms target)
   - Spatial partitioning for collision
   - Object pooling for projectiles

---

## Architecture Decisions

### 1. Actors as Source of Truth

**Decision:** No cached dicts in Room. Actors send snapshots each tick.

**Rationale:**
- Single source of truth
- No synchronization bugs
- Ephemeral collections prevent stale data

### 2. Factory Supervisors for All Actors

**Decision:** Even long-lived actors (players) use factories.

**Rationale:**
- Consistent fault tolerance
- Scales to thousands of entities
- Flat supervision tree

### 3. Fixed Timestep Physics

**Decision:** Always 0.05 (50ms) delta time.

**Rationale:**
- Deterministic simulation
- No accumulation errors
- Easier debugging

### 4. Server-Authoritative Movement

**Decision:** Client sends WASD, server calculates velocity.

**Rationale:**
- Prevents speed hacks
- Consistent physics
- Server controls rules

---

## Version History

- **v0.1.0** - Basic actor architecture
- **v0.2.0** - Factory supervisors
- **v0.3.0** - WASD movement
- **v0.4.0** - Fixed 20 Hz tick rate
- **v0.5.0** - Ephemeral collections
- **v0.6.0** - Enemy AI with ground-lock

**Current Version: v0.6.0**
