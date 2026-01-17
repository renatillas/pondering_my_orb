# Shared Package - AGENTS.md

AI agent documentation for the **shared** package: types, network protocol, and data structures shared between client and server.

---

## Package Overview

The `shared` package defines the contract between client and server:

- **Entity Types** - Player, Enemy, Projectile state representations
- **Network Protocol** - ClientMessage/ServerMessage with JSON codecs
- **ID System** - Typed identifiers for all entities
- **Game State** - Top-level state snapshot (ephemeral, no cached collections)

**Build Targets:** JavaScript (client) + Erlang (server)

**Key Principle:** This package contains NO business logic, only data definitions and encoding/decoding.

---

## Package Structure

```
shared/
├── src/shared/
│   ├── id.gleam              # Entity ID types (PlayerId, EnemyId, etc.)
│   ├── player.gleam          # Player state with velocity
│   ├── enemy.gleam           # Enemy state (type, health, position)
│   ├── projectile.gleam      # Projectile state (damage, velocity)
│   ├── game_state.gleam      # Game state snapshot
│   └── game_message.gleam    # Network protocol
├── test/
│   ├── id_test.gleam
│   ├── message_test.gleam
│   └── encoding_test.gleam
└── gleam.toml
```

---

## Core Modules

### 1. ID System (`shared/src/shared/id.gleam`)

**Purpose:** Type-safe entity identifiers.

```gleam
pub opaque type PlayerId {
  PlayerId(Int)
}

pub opaque type EnemyId {
  EnemyId(Int)
}

pub opaque type ProjectileId {
  ProjectileId(Int)
}

pub opaque type RoomId {
  RoomId(String)
}
```

**Key Functions:**
```gleam
pub fn new_player() -> PlayerId
pub fn new_enemy() -> EnemyId
pub fn new_projectile() -> ProjectileId
pub fn new_room() -> RoomId

pub fn to_string(id: PlayerId) -> String
pub fn from_string(str: String) -> Result(PlayerId, Nil)
```

**Why Opaque Types?**
- Prevents mixing different ID types (can't use EnemyId where PlayerId expected)
- Compiler enforces type safety
- Internal representation can change without breaking code

**Encoding/Decoding:**
```gleam
pub fn encode_player_id(id: PlayerId) -> json.Json {
  json.int(id.value)  // Access via field, not constructor
}

pub fn decode_player_id(json: Dynamic) -> Result(PlayerId, List(DecodeError)) {
  use int_value <- result.map(dynamic.int(json))
  PlayerId(int_value)
}
```

---

### 2. Player Type (`shared/src/shared/player.gleam`)

**State Representation:**
```gleam
pub type Player {
  Player(
    id: id.PlayerId,
    name: String,
    position: Vec3(Float),
    velocity: Vec3(Float),  // Server-calculated from WASD input
    active_wand_index: Int,
  )
}
```

**IMPORTANT: Velocity-Based Movement**

The `Player` type uses **velocity** instead of `MovementState`. This is because:
- Server calculates velocity from WASD input (server-authoritative)
- Client cannot lie about speed (prevents cheating)
- Physics simulation uses `position += velocity * delta_time`

**Evolution:**
- ❌ **Old:** `movement_state: MovementState` (click-to-move with target position)
- ✅ **New:** `velocity: Vec3(Float)` (WASD input → server calculates velocity)

**JSON Encoding:**
```gleam
pub fn encode(player: Player) -> json.Json {
  json.object([
    #("id", id.encode_player_id(player.id)),
    #("name", json.string(player.name)),
    #("position", encode_vec3(player.position)),
    #("velocity", encode_vec3(player.velocity)),
    #("active_wand_index", json.int(player.active_wand_index)),
  ])
}
```

---

### 3. Enemy Type (`shared/src/shared/enemy.gleam`)

**State Representation:**
```gleam
pub type Enemy {
  Enemy(
    id: id.EnemyId,
    enemy_type: EnemyType,
    position: Vec3(Float),
    health: Float,
    max_health: Float,
  )
}

pub type EnemyType {
  Zombie
  // Future: Skeleton, Mage, Boss, etc.
}
```

**Design Notes:**
- `health` and `max_health` separate (for health bar rendering)
- `enemy_type` determines AI behavior and stats (speed, damage)
- Position is ground-locked to y=0.9 (enforced by server, not in type)

**Enemy Type Stats:**
```gleam
pub fn max_health(enemy_type: EnemyType) -> Float {
  case enemy_type {
    Zombie -> 100.0
  }
}

pub fn speed(enemy_type: EnemyType) -> Float {
  case enemy_type {
    Zombie -> 2.0
  }
}
```

**JSON Encoding:**
```gleam
pub fn encode(enemy: Enemy) -> json.Json {
  json.object([
    #("id", id.encode_enemy_id(enemy.id)),
    #("enemy_type", encode_enemy_type(enemy.enemy_type)),
    #("position", encode_vec3(enemy.position)),
    #("health", json.float(enemy.health)),
    #("max_health", json.float(enemy.max_health)),
  ])
}
```

---

### 4. Projectile Type (`shared/src/shared/projectile.gleam`)

**State Representation:**
```gleam
pub type Projectile {
  Projectile(
    id: id.ProjectileId,
    position: Vec3(Float),
    velocity: Vec3(Float),
    damage: Float,
    owner_id: id.PlayerId,  // Who cast this projectile
  )
}
```

**Design Notes:**
- `owner_id` prevents friendly fire (future feature)
- Server tracks `lifetime_remaining` (not in shared type, only in ProjectileActor)
- Velocity determines direction and speed of projectile

**JSON Encoding:**
```gleam
pub fn encode(projectile: Projectile) -> json.Json {
  json.object([
    #("id", id.encode_projectile_id(projectile.id)),
    #("position", encode_vec3(projectile.position)),
    #("velocity", encode_vec3(projectile.velocity)),
    #("damage", json.float(projectile.damage)),
    #("owner_id", id.encode_player_id(projectile.owner_id)),
  ])
}
```

---

### 5. Game State (`shared/src/shared/game_state.gleam`)

**CRITICAL: No Cached Collections**

```gleam
pub type GameState {
  GameState(
    room_id: id.RoomId,
    tick_number: Int,
    next_projectile_id: Int,
    next_enemy_id: Int,
  )
}
```

**What's NOT in GameState:**
- ❌ `players: Dict(PlayerId, Player)` - Actors are source of truth
- ❌ `projectiles: Dict(ProjectileId, Projectile)` - Actors are source of truth
- ❌ `enemies: Dict(EnemyId, Enemy)` - Actors are source of truth

**Rationale:**
- **Single Source of Truth:** Actors own their state
- **Ephemeral Snapshots:** Room collects actor states during tick, broadcasts, then discards
- **No Stale Data:** Impossible to have out-of-sync cached state

**What IS in GameState:**
- `tick_number` - Current game tick (for client interpolation)
- `next_projectile_id` / `next_enemy_id` - ID generators
- `room_id` - Room identifier

---

### 6. Network Protocol (`shared/src/shared/game_message.gleam`)

**Client → Server Messages:**
```gleam
pub type ClientMessage {
  PlayerAction(PlayerAction)
  RequestJoin(player_name: String)
}

pub type PlayerAction {
  Move(w: Bool, a: Bool, s: Bool, d: Bool)  // WASD input
  SwitchWand(index: Int)
  CastSpell
}
```

**Server → Client Messages:**
```gleam
pub type ServerMessage {
  GameStateUpdate(GameStateUpdate)
  JoinAccepted(player_id: id.PlayerId)
  JoinRejected(reason: String)
}

pub type GameStateUpdate {
  GameStateUpdate(
    tick: Int,
    players: Dict(id.PlayerId, player.Player),
    projectiles: Dict(id.ProjectileId, projectile.Projectile),
    enemies: Dict(id.EnemyId, enemy.Enemy),
  )
}
```

**Key Design Decisions:**

1. **WASD as Booleans:**
   - Client sends key state changes (not every frame)
   - Server calculates velocity from WASD (server-authoritative)
   - Prevents speed hacks

2. **GameStateUpdate Contains Full Snapshot:**
   - Not deltas (simpler, more robust)
   - Clients receive complete world state every 50ms
   - Trade-off: Higher bandwidth, but eliminates desyncs

3. **Tick Number Included:**
   - Enables client-side interpolation (future)
   - Clients can detect missed/late updates

---

## JSON Encoding/Decoding Patterns

### Encoding Pattern

```gleam
pub fn encode_client_message(msg: ClientMessage) -> String {
  let json = case msg {
    PlayerAction(action) -> 
      json.object([
        #("type", json.string("player_action")),
        #("action", encode_player_action(action)),
      ])
    
    RequestJoin(name) ->
      json.object([
        #("type", json.string("request_join")),
        #("player_name", json.string(name)),
      ])
  }
  
  json.to_string(json)
}
```

**Key Principles:**
- Always include `"type"` field for message discrimination
- Use nested objects for complex data
- Convert to string at the end (not per-field)

### Decoding Pattern

```gleam
pub fn decode_server_message(data: String) -> Result(ServerMessage, DecodeError) {
  use json <- result.try(json.parse(data))
  use msg_type <- result.try(
    dynamic.field("type", dynamic.string)(json)
  )
  
  case msg_type {
    "game_state_update" -> decode_game_state_update(json)
    "join_accepted" -> decode_join_accepted(json)
    "join_rejected" -> decode_join_rejected(json)
    _ -> Error(UnknownMessageType(msg_type))
  }
}
```

**Key Principles:**
- Parse JSON once at top level
- Match on `"type"` field to discriminate
- Use `result.try` (or `use` syntax) to chain decoders
- Return descriptive errors

### Vec3 Encoding

```gleam
fn encode_vec3(v: Vec3(Float)) -> json.Json {
  json.object([
    #("x", json.float(v.x)),
    #("y", json.float(v.y)),
    #("z", json.float(v.z)),
  ])
}

fn decode_vec3(json: Dynamic) -> Result(Vec3(Float), List(DecodeError)) {
  use x <- result.try(dynamic.field("x", dynamic.float)(json))
  use y <- result.try(dynamic.field("y", dynamic.float)(json))
  use z <- result.try(dynamic.field("z", dynamic.float)(json))
  Ok(vec3.new(x, y, z))
}
```

### Dict Encoding

```gleam
fn encode_player_dict(players: Dict(id.PlayerId, player.Player)) -> json.Json {
  players
  |> dict.to_list()
  |> list.map(fn(entry) {
    let #(id, player) = entry
    #(id.to_string(id), player.encode(player))
  })
  |> json.object()
}

fn decode_player_dict(json: Dynamic) -> Result(Dict(id.PlayerId, player.Player), DecodeError) {
  use pairs <- result.try(dynamic.dict(dynamic.string, decode_player)(json))
  
  pairs
  |> dict.to_list()
  |> list.try_map(fn(entry) {
    let #(id_str, player) = entry
    use id <- result.map(id.from_string(id_str))
    #(id, player)
  })
  |> result.map(dict.from_list)
}
```

---

## Testing Guidelines

### Test Structure

```gleam
// shared/test/message_test.gleam
import gleeunit
import shared/game_message

pub fn encode_decode_player_action_test() {
  let original = game_message.PlayerAction(game_message.Move(
    w: True,
    a: False,
    s: False,
    d: True,
  ))
  
  let encoded = game_message.encode_client_message(original)
  let assert Ok(decoded) = game_message.decode_client_message(encoded)
  
  assert decoded == original
}
```

**Testing Checklist:**
- ✅ Encode then decode returns original value
- ✅ All message variants tested
- ✅ Invalid JSON returns Error
- ✅ Missing fields return Error
- ✅ Wrong types return Error

### Common Test Patterns

**Round-trip test:**
```gleam
pub fn round_trip_test() {
  let value = create_test_value()
  let encoded = encode(value)
  let assert Ok(decoded) = decode(encoded)
  assert decoded == value
}
```

**Error handling test:**
```gleam
pub fn decode_invalid_json_test() {
  let result = decode("{invalid json}")
  assert result == Error(_)  // Pattern match on Error
}
```

**Exhaustive variant test:**
```gleam
pub fn all_enemy_types_test() {
  // Test each variant
  assert encode_decode_round_trip(enemy.Zombie) == Ok(enemy.Zombie)
  // Add tests when new variants added
}
```

---

## Adding New Entity Types

### Checklist

1. **Create type in `shared/src/shared/your_type.gleam`:**
   ```gleam
   pub type YourType {
     YourType(
       id: id.YourTypeId,
       // ... fields
     )
   }
   ```

2. **Add ID type to `shared/src/shared/id.gleam`:**
   ```gleam
   pub opaque type YourTypeId {
     YourTypeId(Int)
   }
   
   pub fn new_your_type() -> YourTypeId {
     YourTypeId(generate_unique_int())
   }
   ```

3. **Add encoding/decoding:**
   ```gleam
   pub fn encode(your_type: YourType) -> json.Json {
     // ...
   }
   
   pub fn decode(json: Dynamic) -> Result(YourType, DecodeError) {
     // ...
   }
   ```

4. **Update `GameStateUpdate` if needed:**
   ```gleam
   pub type GameStateUpdate {
     GameStateUpdate(
       // ... existing fields
       your_types: Dict(id.YourTypeId, your_type.YourType),
     )
   }
   ```

5. **Add tests:**
   ```gleam
   pub fn encode_decode_your_type_test() {
     // Round-trip test
   }
   ```

6. **Update both client and server** to handle new type

---

## DOs and DON'Ts

### DO: Store Business Logic in Shared

```gleam
// GOOD: Game logic belongs in shared
pub fn player_take_damage(player: Player, damage: Float) -> Player {
  Player(..player, health: player.health -. damage)
}
```

**Why?** Shared is for data and behavior.

### ❌ DON'T: Add Cached Collections to GameState

```gleam
// BAD: Creates dual source of truth
pub type GameState {
  GameState(
    players: Dict(PlayerId, Player),  // Don't do this!
    // ...
  )
}
```

**Why?** Actors own state. GameState should only contain metadata.

### ❌ DON'T: Use Dynamic Types

```gleam
// BAD: Loses type safety
pub type Player {
  Player(
    id: Dynamic,  // Should be PlayerId
    data: Dynamic,  // Should be specific fields
  )
}
```

**Why?** Gleam's type system prevents bugs. Use it!

### ✅ DO: Keep Types Simple and Serializable

```gleam
// GOOD: Simple, serializable types
pub type Player {
  Player(
    id: id.PlayerId,
    position: Vec3(Float),
    velocity: Vec3(Float),
  )
}
```

### ✅ DO: Use Opaque Types for IDs

```gleam
// GOOD: Type-safe IDs
pub opaque type PlayerId {
  PlayerId(Int)
}
```
