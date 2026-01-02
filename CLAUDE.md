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
game_msg.ToGame
├── PlayerMsg(player.Msg)
│   ├── Tick
│   └── MagicMsg(magic.Msg)
│       ├── Tick
│       ├── UpdatePlayerState(pos, zoom)
│       ├── PlaceSpellInSlot(spell_id, slot)
│       ├── SelectSlot(Int)
│       └── ReorderWandSlots(from, to)
├── MapMsg(map.Msg)
└── PhysicsMsg(PhysicsMsg)
    ├── PreStep
    ├── Step
    └── PostStep
```

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

When subsystems need data from siblings/parents, use state-update messages:

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
