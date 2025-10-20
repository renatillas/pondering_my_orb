# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Gleam project targeting JavaScript that implements a spell-casting system inspired by games like Noita. The system includes:
- **Spells**: Damage spells and modifier spells that affect damage, speed, size, and lifetime of projectiles
- **Wands**: Containers for spells with mana management and spell slot systems
- **Spell Bags**: Collections for managing multiple spell instances using a bag/multiset data structure

The project uses Lustre for UI and integrates with Three.js and Rapier3D physics engine.

## Development Commands

### Core Commands
- `gleam run` - Run the project
- `gleam test` - Run all tests
- `gleam format --check src test` - Check code formatting (used in CI)
- `gleam format src test` - Format code

### Testing
- Test files should be placed in `test/` directory and end with `_test.gleam`
- All test functions must end with `_test` suffix
- Use `assert <pattern> = <expression>` for pattern-matching assertions
- Use `assert <bool expression>` for boolean assertions
- **Do not use gleeunit/should** - it's deprecated

### Dependencies
The project uses:
- `iv` - Immutable vectors/arrays for spell slot management
- `tote/bag` - Multiset/bag data structure for spell collections
- `lustre` - Frontend framework
- `tiramisu` - Vector math library (likely for 3D calculations)
- Three.js and Rapier3D (via CDN) - 3D rendering and physics

## Architecture

### Spell System (src/pondering_my_orb/spell.gleam)
- **DamageSpell**: Base projectile with damage, speed, lifetime, size, and mana cost
- **ModifierSpell**: Applies multipliers and additions to damage spell properties
- **ModifiedSpell**: Result of applying modifiers to a damage spell
- **Projectile**: Runtime representation of a cast spell with position, direction, and time alive
- `apply_modifiers/2` applies an array of modifiers to a damage spell, processing additions first, then multipliers

### Wand System (src/pondering_my_orb/wand.gleam)
- Wands have spell slots (stored as `iv.Array(Option(Spell))`)
- Casting processes spells left-to-right, accumulating modifiers until a damage spell is found
- Mana system tracks current/max mana with recharge rate
- Cast delay and recharge time properties for balancing
- `cast/5` returns `CastResult` (success with projectile, mana error, no spell, or empty wand)
- Slots can be reordered using `reorder_slots/3`

### Spell Bag System (src/pondering_my_orb/spell_bag.gleam)
- Opaque type wrapping `tote/bag` for spell inventory management
- Tracks multiple copies of the same spell
- Supports transferring spells to wand slots via `transfer_to_wand/4`
- Provides both unique spell lists and spell stacks (with counts)

## Code Patterns

### Opaque Types
The codebase uses opaque types (SpellBag, Wand) to encapsulate internal structure and provide clean APIs.

### Result Types
Functions that can fail return `Result(_, Nil)` for simple errors or custom error types like `TransferError` for more context.

### Immutable Data Structures
All data structures are immutable. Updates return new instances (e.g., `Wand(..wand, current_mana: new_mana)`).

## CI/CD
GitHub Actions runs on push to main/master and PRs:
1. Downloads dependencies (`gleam deps download`)
2. Runs tests (`gleam test`)
3. Checks formatting (`gleam format --check src test`)
