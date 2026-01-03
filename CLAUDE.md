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

### Cross-Module Communication

There are two patterns for cross-module communication:

#### Pattern 1: State-Update Messages (Child reads from Parent)

When a child module needs data from a parent/sibling, the parent sends state-update messages:

```gleam
// Parent sends state to child
Tick -> {
  let new_model = tick(model, ctx)
  let update_child = effect.dispatch(
    ChildMsg(child.UpdateParentState(new_model.position, new_model.zoom))
  )
  #(new_model, effect.batch([effect.tick(Tick), update_child]))
}

// Child stores received state
UpdateParentState(pos, zoom) -> {
  #(Model(..model, parent_pos: pos, parent_zoom: zoom), effect.none())
}
```

#### Pattern 2: Message Taggers (Child dispatches to Sibling)

When a child module needs to dispatch effects to sibling modules (e.g., enemy death spawns altar), use **message taggers**. The parent passes message constructor functions to the child:

```gleam
// Parent passes taggers to child module
EnemyMsg(enemy_msg) -> {
  let #(new_enemy, enemy_effect) =
    enemy.update(
      model.enemy,
      enemy_msg,
      ctx,
      // Taggers for cross-module dispatch
      player_took_damage: fn(dmg) { PlayerMsg(player.TakeDamage(dmg)) },
      spawn_altar: fn(pos) { AltarMsg(altar.SpawnAltar(pos)) },
      effect_mapper: EnemyMsg,
    )
  #(Model(..model, enemy: new_enemy), enemy_effect, ctx.physics_world)
}

// Child module uses taggers to dispatch effects
pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
  player_took_damage player_took_damage,  // Tagger function
  spawn_altar spawn_altar,                 // Tagger function
  effect_mapper effect_mapper,             // Maps own Msg to parent Msg
) -> #(Model, effect.Effect(game_msg)) {
  case msg {
    Tick -> {
      let #(new_model, damage) = tick(model, ctx)
      // Dispatch to sibling using tagger
      let damage_effect = case damage >. 0.0 {
        True -> effect.dispatch(player_took_damage(damage))
        False -> effect.none()
      }
      #(new_model, effect.batch([
        effect.tick(effect_mapper(Tick)),
        damage_effect,
      ]))
    }
    // ...
  }
}
```

**Key principles:**
- **Taggers** are functions that wrap module-specific messages into parent messages
- **effect_mapper** wraps the module's own messages (e.g., `Tick` → `EnemyMsg(Tick)`)
- Child modules dispatch effects directly without import cycles
- Parent module stays clean - just routes messages, doesn't coordinate logic

### Module Responsibility Separation

Each module should own its domain logic and dispatch cross-module effects via taggers:

| Module | Owns | Dispatches to |
|--------|------|---------------|
| `player` | Movement, wand switching, UI sync | magic (nested) |
| `enemy` | Spawning, movement, attacks | player (damage), altar (death spawn) |
| `altar` | Altar lifecycle, pickup detection | player (wand pickup) |
| `game_physics` | Physics simulation, collisions | enemy (damage), player (projectile removal) |

### Synchronous Helpers vs Effect Dispatch

Sometimes you need to update sibling state synchronously (same frame) rather than via effect dispatch (next frame). Use helper functions:

```gleam
// Helper for synchronous updates (no effects needed)
pub fn set_player_pos(model: Model, player_pos: Vec3(Float)) -> Model {
  Model(..model, player_pos: player_pos)
}

// Called synchronously in physics tick
let final_altar = altar.set_player_pos(altar_model, player_position)
```

Use synchronous helpers when:
- Data is needed immediately in the same tick
- No side effects or UI updates required
- Avoiding one-frame delays matters

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
