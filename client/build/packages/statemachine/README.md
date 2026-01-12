# StateMachine

A generic, type-safe state machine library for Gleam with easing function support and transition weights.

## Features

- **🎯 Fully Generic**: Works with any state type (enums, strings, custom types)
- **🎨 Easing Support**: Compatible with [easings_gleam](https://hexdocs.pm/easings_gleam/) for smooth transitions
- **⚖️ Weighted Transitions**: Prioritize transitions when multiple conditions are true
- **🔄 Automatic Blending**: Smooth interpolation between states with configurable durations
- **⚡ Context-Aware Conditions**: Pass game/app context to transition condition functions  
- **🛡️ Type-Safe**: Leverage Gleam's type system for correctness
- **🔧 Immutable**: Pure functional updates, no hidden state
- **⏱️ Duration-Based**: Uses gleam_time's Duration type for precise timing

## Installation

```sh
gleam add statemachine
```

## Quick Start

```gleam
import statemachine
import gleam/option.{None}
import gleam/time/duration

// Define your state type
type PlayerState {
  Idle
  Walking
  Running
}

// Define your context
type GameContext {
  GameContext(velocity: Float)
}

// Create state machine
let machine =
  statemachine.new(initial_state: Idle)
  |> statemachine.with_state(state: Idle)
  |> statemachine.with_state(state: Walking)
  |> statemachine.with_state(state: Running)
  |> statemachine.with_transition(
    from: Idle,
    to: Walking,
    condition: statemachine.Custom(fn(ctx: GameContext) { ctx.velocity >. 0.1 }),
    blend_duration: duration.milliseconds(200),
    easing: None,
    weight: 0,
  )
  |> statemachine.with_transition(
    from: Walking,
    to: Running,
    condition: statemachine.Custom(fn(ctx: GameContext) { ctx.velocity >. 5.0 }),
    blend_duration: duration.milliseconds(300),
    easing: None,
    weight: 0,
  )

// Update in game loop
fn update(model: Model, delta_time: duration.Duration) {
  let ctx = GameContext(velocity: model.velocity)
  let #(new_machine, transitioned) = statemachine.update(machine, ctx, delta_time)
  
  case statemachine.state_data(new_machine) {
    statemachine.Single(state) -> // Use single state
    statemachine.BlendingData(from, to, factor) -> // Interpolate
  }
}
```

## Using with easings_gleam

The library works seamlessly with [easings_gleam](https://hexdocs.pm/easings_gleam/) for beautiful transitions:

```gleam
import statemachine
import easings_gleam/easings
import gleam/option.{Some}
import gleam/time/duration

statemachine.with_transition(
  from: Idle,
  to: Running,
  condition: statemachine.Always,
  blend_duration: duration.milliseconds(500),
  easing: Some(easings.cubic_in_out),
  weight: 0,
)
```

## Transition Conditions

Three types of conditions control when transitions occur:

### Always
Transition immediately:

```gleam
import gleam/time/duration

statemachine.with_transition(
  from: Idle,
  to: Jump,
  condition: statemachine.Always,
  blend_duration: duration.milliseconds(100),
  easing: None,
  weight: 0,
)
```

### AfterDuration
Transition after spending time in the current state:

```gleam
import gleam/time/duration
import easings
import gleam/option.{Some}

// Automatically transition after 5 seconds
statemachine.with_transition(
  from: Idle,
  to: Sleeping,
  condition: statemachine.AfterDuration(duration.seconds(5)),
  blend_duration: duration.seconds(1),
  easing: Some(easings.ease_in_out_sine),
  weight: 0,
)
```

### Custom
Transition based on custom game/app context:

```gleam
// Velocity-based
statemachine.Custom(fn(ctx) { ctx.velocity >. 5.0 })

// Input-based
statemachine.Custom(fn(ctx) { ctx.jump_pressed && ctx.is_grounded })

```

## Transition Weights

When multiple transitions from the same state have their conditions met, the transition with the **highest weight** is chosen:

```gleam
import statemachine
import gleam/time/duration

statemachine.new(initial_state: Idle)
|> statemachine.with_state(state: Idle)
|> statemachine.with_state(state: Walking)
|> statemachine.with_state(state: Running)
// Lower priority transition
|> statemachine.with_transition(
  from: Idle,
  to: Walking,
  condition: statemachine.Always,
  blend_duration: duration.milliseconds(200),
  easing: None,
  weight: 5,
)
// Higher priority transition - this one will be chosen!
|> statemachine.with_transition(
  from: Idle,
  to: Running,
  condition: statemachine.Always,
  blend_duration: duration.milliseconds(200),
  easing: None,
  weight: 10,
)
```

This is useful for creating layered logic where more specific conditions take precedence.

## Manual Transitions

Force transitions programmatically (useful for events like damage, death, cutscenes):

```gleam
import easings
import gleam/option.{None, Some}
import gleam/time/duration

// Force transition with custom blend and easing
let machine = statemachine.transition_to(
  machine,
  HitReaction,
  blend_duration: Some(duration.milliseconds(100)),
  easing: Some(easings.ease_out_back),
)

// Force transition with defaults
let machine = statemachine.transition_to(
  machine,
  Dead,
  blend_duration: None,
  easing: None,
)
```

## API Overview

### Building State Machines
- `new(initial_state:)` - Create a new state machine
- `with_state(machine, state:)` - Register a state
- `with_transition(...)` - Define conditional transitions with easing and weight
- `with_default_blend(machine, duration:)` - Set default blend duration
- `with_default_easing(machine, easing:)` - Set default easing function

### Runtime
- `update(machine, context, delta_time)` - Evaluate conditions and update
- `state_data(machine)` - Get current or blended state data (returns `StateData`)
- `transition_to(...)` - Manually force a transition

### Querying
- `is_blending(machine)` - Check if transitioning
- `blend_progress(machine)` - Get linear blend progress (0.0 to 1.0)
- `state_ids(machine)` - Get Set of all state IDs
- `state_count(machine)` - Count states
- `transition_count(machine)` - Count transitions

### Types
- `StateData(state)` - Result of `state_data()`: `Single(state)` or `BlendingData(from, to, factor)`
- `Condition(ctx)` - Transition conditions: `Always`, `AfterDuration(Duration)`, or `Custom(fn(ctx) -> Bool)`

## Philosophy

StateMachine is designed to be:

- **Generic**: Works with any state type, not just enums
- **Composable**: Build complex state graphs declaratively
- **Type-safe**: Leverage Gleam's type system
- **Functional**: Immutable updates, pure functions
- **Flexible**: Compatible with existing easing libraries
- **Precise**: Uses Duration for accurate timing

## Use Cases

- **Game Animations**: Character controllers, NPC behaviors
- **UI Transitions**: Menu states, loading screens, modal animations
- **Application States**: Workflow management, process orchestration
- **Audio**: Music/sound state management with crossfading

## License

MIT

## Contributing

Contributions welcome! This library was extracted from [Tiramisu](https://github.com/renatillas/tiramisu) to benefit the broader Gleam ecosystem.
