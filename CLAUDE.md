# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Gleam project targeting JavaScript that implements a spell-casting system inspired by Noita. The core architecture revolves around three main modules:

1. **Spell System** (`spell.gleam`) - Defines spell types and projectile mechanics
2. **Wand System** (`wand.gleam`) - Manages spell slots, casting logic, and mana
3. **Spell Bag** (`spell_bag.gleam`) - Inventory management for spells

## Common Commands

### Development
```bash
gleam run          # Run the project
gleam test         # Run all tests
gleam format       # Format code
```

### Build & Documentation
```bash
gleam build        # Build the project
gleam docs build   # Generate documentation
```

### Development Tools
The project uses Lustre for UI and includes dev tools via `lustre_dev_tools`. The frontend can be served with:
```bash
gleam run -m lustre/dev start
```

## Architecture

### Spell System Design
The spell system follows a **modifier-based composition pattern**:

- **DamageSpell**: Base spells that create projectiles (Spark, Fireball, Lightning)
- **ModifierSpell**: Enhancement spells that modify the next damage spell (Heavy Shot, Homing, Triple Spell)
- **ModifiedSpell**: Result of applying modifiers to a damage spell with final calculated stats
- **Projectile**: Instance of a cast spell in the game world

Key design principle: Modifiers multiply base spell properties (damage, speed, size, lifetime) and stack additively on mana cost.

### Wand Casting Logic
Wands process spells **left-to-right** with the following algorithm:
1. Collect consecutive modifier spells into an accumulator
2. When a damage spell is found, apply all accumulated modifiers
3. Check mana availability and create projectile
4. Return next casting index for sequential casting

This creates a Noita-like wand system where spell order matters significantly.

### Spell Bag System
Uses the `tote/bag` library for multiset operations:
- Tracks spell counts (allows duplicates)
- Supports transfer operations between bag and wand slots
- Distinguishes between total spell count and unique spell types

## Testing Practices

- Use `gleeunit` as the test framework
- **IMPORTANT**: `gleeunit/should` is deprecated - use pattern matching assertions instead:
  ```gleam
  // Good
  let assert Ok(result) = function_call()
  assert result == expected_value

  // Bad - deprecated
  function_call() |> should.equal(expected_value)
  ```
- Test files should end with `_test.gleam`
- Run tests with `gleam test`

## Dependencies

Key external dependencies:
- `lustre` - Frontend framework (v5.3.5)
- `iv` - Immutable vectors/arrays
- `tote` - Multiset/bag data structure
- `sortable` - Local dependency for UI sorting (path: ../sortable)
- `tiramisu` - Testing utilities
- `vec` - Vector math (3D vectors for projectile physics)

## Frontend Configuration

The project includes Lustre HTML configuration with:
- Three.js (v0.180.0) for 3D rendering
- Rapier3D physics engine (v0.11.2)
- Custom CSS to remove body margins and hide overflow

These are configured via importmap in `gleam.toml`.
