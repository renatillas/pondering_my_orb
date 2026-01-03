# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Gleam game targeting JavaScript that implements a Noita-inspired spell-casting system. Built with:
- **Tiramisu** - 3D game engine (Three.js + Rapier3D)
- **Lustre** - UI framework for HUD/menus
- **Ensaimada** - Drag-and-drop library for spell management

## Development Commands

```bash
gleam run -m lustre/dev start  # Run the game
gleam test                      # Run all tests
gleam format src test           # Format code
```

## Testing

- Test files in `test/` ending with `_test.gleam`
- All test functions must end with `_test` suffix
- Use `assert <pattern> = <expression>` for pattern-matching assertions
- Use `assert <bool expression>` for boolean assertions
- Use `echo <expression>` for debug output (not `io.debug`)
- **Do not use gleeunit/should** - it's deprecated

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
src/pondering_my_orb/
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

### Async vs Sync Updates

**Prefer async dispatch** for cross-module state updates. The one-frame delay is usually acceptable and keeps modules decoupled:

```gleam
// Physics dispatches position updates asynchronously
let effects = effect.batch([
  effect.dispatch(update_altar_player_pos(player_position)),
  effect.dispatch(update_enemy_positions(enemy_positions, player_position)),
  effect.tick(effect_mapper(Tick)),
])
```

**When sync is required** (same-frame data needed):
- Use `update_for_physics` pattern: module returns data needed for physics calculations
- The caller uses the data immediately, then dispatches async updates for other state

```gleam
// Sync: Get velocities for physics step (needed this frame)
let #(updated_enemy, enemy_velocities) =
  enemy.update_for_physics(enemy_model, player_position)

// Physics step uses velocities immediately
let world_with_velocities = set_enemy_velocities(physics_world, enemy_velocities)
let stepped_world = physics.step(world_with_velocities, ctx.delta_time)

// Async: Dispatch position updates (can be next frame)
effect.dispatch(update_enemy_positions(enemy_positions, player_position))
```

### Physics Coordination Pattern

The physics module coordinates the physics simulation and returns updated state for multiple modules:

```gleam
pub type TickResult {
  TickResult(
    physics: Model,
    enemy: enemy.Model,      // Updated enemy positions
    altar: altar.Model,      // Updated player position for proximity
    stepped_world: option.Option(physics.PhysicsWorld),
  )
}

pub fn update(
  msg msg: Msg,
  ctx ctx: tiramisu.Context,
  player_model player_model: player.Model,
  enemy_model enemy_model: enemy.Model,
  altar_model altar_model: altar.Model,
  // Taggers for collision effects
  enemy_took_projectile_damage enemy_took_projectile_damage,
  remove_projectile remove_projectile,
  effect_mapper effect_mapper,
) -> #(TickResult, effect.Effect(game_msg)) {
  // PRE-STEP: Set velocities from game state
  // STEP: Run physics simulation
  // POST-STEP: Read back positions, process collisions
}
```

The physics module:
1. **Reads** velocities/directions from player (projectiles) and enemy (movement)
2. **Steps** the physics world simulation
3. **Returns** updated positions and collision results
4. **Dispatches** collision effects via taggers

This keeps the physics module focused on simulation while modules own their behavior.

### Input Handling Ownership

Each module handles its own input for the behaviors it owns:

| Input | Module | Behavior |
|-------|--------|----------|
| WASD/Arrows | `player` | Movement |
| Mouse wheel | `player` | Zoom (normal) / Wand switch (shift+scroll) |
| 1-4 keys | `player` | Direct wand selection |
| I key | `player` | Toggle edit mode |
| E key | `altar` | Pick up wand from nearby altar |
| Left click | `player/magic` | Cast spells |

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

### UI Bridge (Tiramisu ↔ Lustre)

```gleam
// In main module
let bridge = ui.new_bridge()
game_ui.start(bridge)
tiramisu.run(bridge: option.Some(bridge), ...)

// Send to Lustre UI
ui.to_lustre(bridge, game_msg.WandUpdated(...))

// Send to Tiramisu game
ui.to_tiramisu(bridge, game_msg.PlayerMsg(player.MagicMsg(magic.SelectSlot(0))))
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
1. `gleam deps download`
2. `gleam test`
3. `gleam format --check src test`
