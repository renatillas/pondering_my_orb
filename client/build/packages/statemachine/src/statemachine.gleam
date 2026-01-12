//// # StateMachine
////
//// A generic, type-safe state machine library for Gleam with easing function support
//// and weighted transitions.
////
//// ## Features
////
//// - **Fully Generic**: Works with any state type (enums, strings, custom types)
//// - **Easing Support**: Compatible with easings_gleam for smooth transitions
//// - **Weighted Transitions**: Prioritize transitions when multiple conditions are true
//// - **Automatic Blending**: Smooth interpolation between states
//// - **Context-Aware Conditions**: Pass game/app context to transition condition functions
//// - **Type-Safe**: Leverage Gleam's type system for correctness
//// - **Duration-Based**: Uses gleam_time's Duration type for precise timing
////
//// ## Quick Example
////
//// ```gleam
//// import statemachine
//// import gleam/option.{None}
//// import gleam/time/duration
////
//// // Define your state type
//// type PlayerState {
////   Idle
////   Walking
////   Running
//// }
////
//// // Define your context
//// type GameContext {
////   GameContext(velocity: Float)
//// }
////
//// // Create state machine
//// let machine =
////   statemachine.new(initial_state: Idle)
////   |> statemachine.with_state(state: Idle)
////   |> statemachine.with_state(state: Walking)
////   |> statemachine.with_state(state: Running)
////   |> statemachine.with_transition(
////     from: Idle,
////     to: Walking,
////     condition: statemachine.Custom(fn(ctx) { ctx.velocity >. 0.1 }),
////     blend_duration: duration.milliseconds(200),
////     easing: None,
////     weight: 0,
////   )
////
//// // Update in game loop
//// fn update(model: Model, delta_time: duration.Duration) {
////   let ctx = GameContext(velocity: model.velocity)
////   let #(new_machine, transitioned) = statemachine.update(machine, ctx, delta_time)
////   
////   case statemachine.state_data(new_machine) {
////     statemachine.Single(state) -> // Use single state
////     statemachine.BlendingData(from, to, factor) -> // Interpolate
////   }
//// }
//// ```
////
//// ## Transition Conditions
////
//// ### Always
//// Transition immediately when conditions are evaluated:
////
//// ```gleam
//// statemachine.with_transition(
////   from: Idle,
////   to: Jump,
////   condition: statemachine.Always,
////   blend_duration: duration.milliseconds(100),
////   easing: None,
////   weight: 0,
//// )
//// ```
////
//// ### AfterDuration
//// Transition after spending time in the current state:
////
//// ```gleam
//// statemachine.with_transition(
////   from: Idle,
////   to: Sleeping,
////   condition: statemachine.AfterDuration(duration.seconds(5)),
////   blend_duration: duration.seconds(1),
////   easing: Some(easings.ease_in_out_sine),
////   weight: 0,
//// )
//// ```
////
//// ### Custom
//// Transition based on custom context:
////
//// ```gleam
//// statemachine.Custom(fn(ctx) { ctx.velocity >. 5.0 })
//// ```
////
//// ## Transition Weights
////
//// When multiple transitions from the same state have their conditions met,
//// the transition with the highest weight is chosen:
////
//// ```gleam
//// statemachine.new(initial_state: Idle)
//// |> statemachine.with_transition(
////   from: Idle,
////   to: Walking,
////   condition: statemachine.Always,
////   blend_duration: duration.milliseconds(200),
////   easing: None,
////   weight: 5,
//// )
//// |> statemachine.with_transition(
////   from: Idle,
////   to: Running,
////   condition: statemachine.Always,
////   blend_duration: duration.milliseconds(200),
////   easing: None,
////   weight: 10,  // This one will be chosen!
//// )
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/set
import gleam/time/duration

/// Condition for transitioning between states.
///
/// The generic parameter `ctx` allows you to pass custom context to condition functions.
///
/// ## Examples
///
/// ```gleam
/// // Always transition
/// statemachine.Always
///
/// // After 5 seconds in current state
/// statemachine.AfterDuration(duration.seconds(5))
///
/// // Based on velocity
/// statemachine.Custom(fn(ctx: GameContext) { ctx.velocity >. 5.0 })
/// ```
pub type Condition(ctx) {
  /// Always transition (immediate)
  Always
  /// Transition after elapsed time in current state
  AfterDuration(duration.Duration)
  /// Custom condition function that receives context
  Custom(fn(ctx) -> Bool)
}

/// Transition between two states with optional easing and priority weight.
///
/// ## Fields
///
/// - `from`: Source state
/// - `to`: Target state
/// - `condition`: When to trigger the transition
/// - `blend_duration`: Time to blend between states
/// - `easing`: Optional easing function for non-linear blending
/// - `weight`: Priority when multiple transitions are valid (higher = higher priority)
pub type Transition(state, ctx) {
  Transition(
    from: state,
    to: state,
    condition: Condition(ctx),
    blend_duration: duration.Duration,
    easing: Option(fn(Float) -> Float),
    weight: Int,
  )
}

/// The current state of a running state machine.
///
/// Either playing a single state or blending between two states.
pub type MachineState(state) {
  /// Playing a single state
  Playing(state: state, elapsed: duration.Duration)
  /// Blending between two states with easing
  Blending(
    from: state,
    to: state,
    blend_progress: duration.Duration,
    blend_duration: duration.Duration,
    easing: Option(fn(Float) -> Float),
  )
}

/// A state machine.
///
/// Generic over:
/// - `state`: The type used for state identifiers (e.g., enum, string, custom types)
/// - `ctx`: The type passed to condition functions (e.g., game context)
///
/// ## Example
///
/// ```gleam
/// type State {
///   Idle
///   Walking
/// }
///
/// type Context {
///   Context(velocity: Float)
/// }
///
/// let machine: StateMachine(State, Context) = statemachine.new(initial_state: Idle)
/// ```
pub opaque type StateMachine(state, ctx) {
  StateMachine(
    states: set.Set(state),
    transitions: set.Set(Transition(state, ctx)),
    current: MachineState(state),
    default_blend: duration.Duration,
    default_easing: Option(fn(Float) -> Float),
  )
}

/// Create a new state machine with an initial state.
///
/// The initial state is automatically registered in the state machine.
///
/// **Default blend duration**: 1 second (can be changed with `with_default_blend`).
/// **Default easing**: None (linear) (can be changed with `with_default_easing`).
///
/// ## Example
///
/// ```gleam
/// type State {
///   Idle
///   Walking
/// }
///
/// let machine = statemachine.new(initial_state: Idle)
/// ```
pub fn new(initial_state initial_state: state) -> StateMachine(state, ctx) {
  StateMachine(
    states: set.new() |> set.insert(initial_state),
    transitions: set.new(),
    current: Playing(initial_state, duration.seconds(0)),
    default_blend: duration.seconds(1),
    default_easing: option.None,
  )
}

/// Register a state in the state machine.
///
/// States must be registered before they can be used in transitions.
/// Registering the same state multiple times is safe (uses a Set internally).
///
/// ## Example
///
/// ```gleam
/// let machine =
///   statemachine.new(initial_state: Idle)
///   |> statemachine.with_state(state: Walking)
///   |> statemachine.with_state(state: Running)
/// ```
pub fn with_state(
  machine: StateMachine(state, ctx),
  state state: state,
) -> StateMachine(state, ctx) {
  StateMachine(..machine, states: set.insert(machine.states, state))
}

/// Add a transition between two states.
///
/// Transitions define when and how to switch between states.
///
/// ## Parameters
///
/// - `from`: Source state (must be registered)
/// - `to`: Target state (must be registered)
/// - `condition`: When to trigger (Always, AfterDuration, or Custom)
/// - `blend_duration`: Time to blend between states
/// - `easing`: Optional easing function (compatible with easings_gleam)
/// - `weight`: Priority when multiple transitions are valid (higher = higher priority)
///
/// ## Example
///
/// ```gleam
/// import easings
/// import gleam/option.{None, Some}
/// import gleam/time/duration
///
/// statemachine.with_transition(
///   machine,
///   from: Idle,
///   to: Walking,
///   condition: statemachine.Custom(fn(ctx) { ctx.velocity >. 0.1 }),
///   blend_duration: duration.milliseconds(200),
///   easing: Some(easings.ease_out_quad),
///   weight: 5,
/// )
/// ```
pub fn with_transition(
  machine: StateMachine(state, ctx),
  from from: state,
  to to: state,
  condition condition: Condition(ctx),
  blend_duration blend_duration: duration.Duration,
  easing easing: Option(fn(Float) -> Float),
  weight weight: Int,
) -> StateMachine(state, ctx) {
  let transition =
    Transition(from:, to:, condition:, blend_duration:, easing:, weight:)
  StateMachine(
    ..machine,
    transitions: set.insert(machine.transitions, transition),
  )
}

/// Set the default blend duration for manual transitions.
///
/// This duration is used when calling `transition_to` without specifying
/// a blend duration. Does not affect transitions added with `with_transition`.
///
/// ## Example
///
/// ```gleam
/// import gleam/time/duration
///
/// let machine =
///   statemachine.new(initial_state: Idle)
///   |> statemachine.with_default_blend(duration: duration.milliseconds(500))
/// ```
pub fn with_default_blend(
  machine: StateMachine(state, ctx),
  duration default_blend: duration.Duration,
) -> StateMachine(state, ctx) {
  StateMachine(..machine, default_blend:)
}

/// Set the default easing function for manual transitions.
///
/// This easing is used when calling `transition_to` without specifying
/// an easing function. Does not affect transitions added with `with_transition`.
///
/// ## Example
///
/// ```gleam
/// import easings
/// import gleam/option.{Some}
///
/// let machine =
///   statemachine.new(initial_state: Idle)
///   |> statemachine.with_default_easing(easing: Some(easings.ease_in_out_quad))
/// ```
pub fn with_default_easing(
  machine: StateMachine(state, ctx),
  easing default_easing: Option(fn(Float) -> Float),
) -> StateMachine(state, ctx) {
  StateMachine(..machine, default_easing:)
}

/// Update the state machine (call every frame).
///
/// Evaluates transition conditions and advances blend progress. Returns the
/// updated machine and a boolean indicating if a transition occurred this frame.
///
/// ## Parameters
///
/// - `machine`: The state machine to update
/// - `context`: Your custom context passed to Custom condition functions
/// - `delta_time`: Time elapsed since last update
///
/// ## Returns
///
/// A tuple of `(updated_machine, transitioned)` where `transitioned` is `True`
/// if a state change occurred this frame.
///
/// ## Example
///
/// ```gleam
/// import gleam/time/duration
///
/// fn game_loop(model: Model, delta: duration.Duration) {
///   let ctx = GameContext(velocity: model.velocity)
///   let #(new_machine, transitioned) =
///     statemachine.update(model.machine, ctx, delta)
///   
///   case transitioned {
///     True -> io.println("State changed!")
///     False -> Nil
///   }
///   
///   Model(..model, machine: new_machine)
/// }
/// ```
pub fn update(
  machine: StateMachine(state, ctx),
  context: ctx,
  delta_time: duration.Duration,
) -> #(StateMachine(state, ctx), Bool) {
  case machine.current {
    Playing(state_id, elapsed) -> {
      let new_elapsed = duration.add(elapsed, delta_time)

      case find_valid_transition(machine, state_id, new_elapsed, context) {
        Ok(transition) -> {
          let new_current =
            Blending(
              from: state_id,
              to: transition.to,
              blend_progress: duration.seconds(0),
              blend_duration: transition.blend_duration,
              easing: transition.easing,
            )
          #(StateMachine(..machine, current: new_current), True)
        }
        Error(_) -> {
          // No transition, continue playing
          #(
            StateMachine(..machine, current: Playing(state_id, new_elapsed)),
            False,
          )
        }
      }
    }

    Blending(from, to, progress, duration, easing) -> {
      let new_progress = duration.add(progress, delta_time)

      case duration.compare(new_progress, duration) == order.Gt {
        True -> {
          // Blend complete, switch to new state
          #(
            StateMachine(..machine, current: Playing(to, duration.seconds(0))),
            True,
          )
        }
        False -> {
          // Continue blending
          #(
            StateMachine(
              ..machine,
              current: Blending(from, to, new_progress, duration, easing),
            ),
            False,
          )
        }
      }
    }
  }
}

/// Get the current state or blended state data.
///
/// Returns either a single state when not blending, or blended state data
/// with an eased factor (0.0 to 1.0) during transitions.
///
/// ## Returns
///
/// - `Single(state)`: Currently in a single state
/// - `BlendingData(from, to, factor)`: Blending between states with eased factor
///
/// ## Example
///
/// ```gleam
/// case statemachine.state_data(machine) {
///   statemachine.Single(state) -> {
///     // Use the current state directly
///     io.println("Current state: " <> string.inspect(state))
///   }
///   statemachine.BlendingData(from: from, to: to, factor: factor) -> {
///     // Interpolate between from and to using the eased factor
///     let interpolated = lerp(from_value, to_value, factor)
///   }
/// }
/// ```
pub type StateData(data) {
  /// Single state data
  Single(data)
  /// Blending between two states with blend factor (0.0 to 1.0)
  BlendingData(from: data, to: data, factor: Float)
}

/// Get the current state data from the state machine.
///
/// See `StateData` type documentation for usage examples.
pub fn state_data(machine: StateMachine(state, ctx)) -> StateData(state) {
  case machine.current {
    Playing(state_id, _) -> Single(state_id)

    Blending(from, to, progress, duration, easing) -> {
      // Calculate linear progress (0.0 to 1.0)
      let linear_progress = duration_ratio(progress, duration)
      // Apply easing function if provided
      let blend_factor = case easing {
        option.Some(ease_fn) -> ease_fn(linear_progress)
        option.None -> linear_progress
      }

      BlendingData(from:, to:, factor: blend_factor)
    }
  }
}

/// Manually force a transition to a specific state.
///
/// Bypasses all transition conditions and forces an immediate state change.
/// Useful for external events like damage, death, or cutscenes.
///
/// ## Parameters
///
/// - `machine`: The state machine
/// - `target`: The state to transition to
/// - `blend_duration`: Optional blend time. If None, uses default blend duration
/// - `easing`: Optional easing function. If None, uses default easing
///
/// ## Example
///
/// ```gleam
/// import easings
/// import gleam/option.{None, Some}
/// import gleam/time/duration
///
/// // Force transition with custom blend and easing
/// let machine =
///   statemachine.transition_to(
///     machine,
///     HitReaction,
///     blend_duration: Some(duration.milliseconds(100)),
///     easing: Some(easings.ease_out_back),
///   )
///
/// // Force transition with defaults
/// let machine =
///   statemachine.transition_to(
///     machine,
///     Dead,
///     blend_duration: None,
///     easing: None,
///   )
/// ```
pub fn transition_to(
  machine: StateMachine(state, ctx),
  target: state,
  blend_duration blend_duration: Option(duration.Duration),
  easing easing: Option(fn(Float) -> Float),
) -> StateMachine(state, ctx) {
  let blend = option.unwrap(blend_duration, machine.default_blend)
  let ease = case easing {
    option.Some(_) -> easing
    option.None -> machine.default_easing
  }

  case machine.current {
    Playing(from, _) -> {
      StateMachine(
        ..machine,
        current: Blending(from, target, duration.seconds(0), blend, ease),
      )
    }
    Blending(_, current_to, _, _, _) -> {
      // Already blending, start blend from current target
      StateMachine(
        ..machine,
        current: Blending(current_to, target, duration.seconds(0), blend, ease),
      )
    }
  }
}

/// Check if currently blending between states.
///
/// Returns `True` during transitions, `False` when playing a single state.
///
/// ## Example
///
/// ```gleam
/// case statemachine.is_blending(machine) {
///   True -> io.println("Transitioning...")
///   False -> io.println("Stable state")
/// }
/// ```
pub fn is_blending(machine: StateMachine(state, ctx)) -> Bool {
  case machine.current {
    Playing(..) -> False
    Blending(..) -> True
  }
}

/// Get blend progress as a normalized value (0.0 to 1.0).
///
/// Returns `None` if not currently blending, `Some(progress)` during transitions.
/// The progress returned is the **linear** progress, not the eased value.
///
/// ## Example
///
/// ```gleam
/// case statemachine.blend_progress(machine) {
///   Ok(progress) -> {
///     io.println("Blend: " <> float.to_string(progress *. 100.0) <> "%")
///   }
///   Error(Nil) -> Nil
/// }
/// ```
pub fn blend_progress(machine: StateMachine(state, ctx)) -> Result(Float, Nil) {
  case machine.current {
    Playing(..) -> Error(Nil)
    Blending(_, _, progress, duration, _) -> {
      Ok(duration_ratio(progress, duration))
    }
  }
}

/// Get all registered state IDs.
///
/// Returns a Set of all states registered in the state machine.
///
/// ## Example
///
/// ```gleam
/// import gleam/set
///
/// let ids = statemachine.state_ids(machine)
/// set.to_list(ids)
/// |> list.each(fn(state) {
///   io.println("State: " <> string.inspect(state))
/// })
/// ```
pub fn states(machine: StateMachine(state, ctx)) -> set.Set(state) {
  machine.states
}

/// Get the number of states in the state machine.
pub fn state_count(machine: StateMachine(state, ctx)) -> Int {
  set.size(machine.states)
}

/// Get the number of transitions in the state machine.
pub fn transition_count(machine: StateMachine(state, ctx)) -> Int {
  set.size(machine.transitions)
}

// --- Internal Functions ---

/// Find a valid transition from the current state
fn find_valid_transition(
  machine: StateMachine(state, ctx),
  from_state: state,
  elapsed: duration.Duration,
  context: ctx,
) -> Result(Transition(state, ctx), Nil) {
  machine.transitions
  |> set.filter(fn(transition) {
    transition.from == from_state
    && check_condition(transition.condition, elapsed, context)
  })
  |> set.to_list
  |> list.sort(by: fn(a: Transition(state, ctx), b: Transition(state, ctx)) {
    int.compare(b.weight, a.weight)
  })
  |> list.first
}

/// Check if a condition is met
fn check_condition(
  condition: Condition(ctx),
  elapsed: duration.Duration,
  context: ctx,
) -> Bool {
  case condition {
    Always -> True
    AfterDuration(duration) -> duration.compare(elapsed, duration) == order.Gt
    Custom(check) -> check(context)
  }
}

fn duration_ratio(a: duration.Duration, b: duration.Duration) -> Float {
  let #(a_sec, a_nano) = duration.to_seconds_and_nanoseconds(a)
  let #(b_sec, b_nano) = duration.to_seconds_and_nanoseconds(b)

  // Convert both to total nanoseconds for accurate division
  let a_total_nano = int.to_float(a_sec * 1_000_000_000 + a_nano)
  let b_total_nano = int.to_float(b_sec * 1_000_000_000 + b_nano)

  case b_total_nano == 0.0 {
    True -> 0.0
    False -> a_total_nano /. b_total_nano
  }
}
