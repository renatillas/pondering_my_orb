import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $order from "../gleam_stdlib/gleam/order.mjs";
import * as $set from "../gleam_stdlib/gleam/set.mjs";
import * as $duration from "../gleam_time/gleam/time/duration.mjs";
import { Ok, Error, CustomType as $CustomType, divideFloat, isEqual } from "./gleam.mjs";

export class Always extends $CustomType {}
export const Condition$Always = () => new Always();
export const Condition$isAlways = (value) => value instanceof Always;

/**
 * Transition after elapsed time in current state
 */
export class AfterDuration extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Condition$AfterDuration = ($0) => new AfterDuration($0);
export const Condition$isAfterDuration = (value) =>
  value instanceof AfterDuration;
export const Condition$AfterDuration$0 = (value) => value[0];

/**
 * Custom condition function that receives context
 */
export class Custom extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Condition$Custom = ($0) => new Custom($0);
export const Condition$isCustom = (value) => value instanceof Custom;
export const Condition$Custom$0 = (value) => value[0];

export class Transition extends $CustomType {
  constructor(from, to, condition, blend_duration, easing, weight) {
    super();
    this.from = from;
    this.to = to;
    this.condition = condition;
    this.blend_duration = blend_duration;
    this.easing = easing;
    this.weight = weight;
  }
}
export const Transition$Transition = (from, to, condition, blend_duration, easing, weight) =>
  new Transition(from, to, condition, blend_duration, easing, weight);
export const Transition$isTransition = (value) => value instanceof Transition;
export const Transition$Transition$from = (value) => value.from;
export const Transition$Transition$0 = (value) => value.from;
export const Transition$Transition$to = (value) => value.to;
export const Transition$Transition$1 = (value) => value.to;
export const Transition$Transition$condition = (value) => value.condition;
export const Transition$Transition$2 = (value) => value.condition;
export const Transition$Transition$blend_duration = (value) =>
  value.blend_duration;
export const Transition$Transition$3 = (value) => value.blend_duration;
export const Transition$Transition$easing = (value) => value.easing;
export const Transition$Transition$4 = (value) => value.easing;
export const Transition$Transition$weight = (value) => value.weight;
export const Transition$Transition$5 = (value) => value.weight;

/**
 * Playing a single state
 */
export class Playing extends $CustomType {
  constructor(state, elapsed) {
    super();
    this.state = state;
    this.elapsed = elapsed;
  }
}
export const MachineState$Playing = (state, elapsed) =>
  new Playing(state, elapsed);
export const MachineState$isPlaying = (value) => value instanceof Playing;
export const MachineState$Playing$state = (value) => value.state;
export const MachineState$Playing$0 = (value) => value.state;
export const MachineState$Playing$elapsed = (value) => value.elapsed;
export const MachineState$Playing$1 = (value) => value.elapsed;

/**
 * Blending between two states with easing
 */
export class Blending extends $CustomType {
  constructor(from, to, blend_progress, blend_duration, easing) {
    super();
    this.from = from;
    this.to = to;
    this.blend_progress = blend_progress;
    this.blend_duration = blend_duration;
    this.easing = easing;
  }
}
export const MachineState$Blending = (from, to, blend_progress, blend_duration, easing) =>
  new Blending(from, to, blend_progress, blend_duration, easing);
export const MachineState$isBlending = (value) => value instanceof Blending;
export const MachineState$Blending$from = (value) => value.from;
export const MachineState$Blending$0 = (value) => value.from;
export const MachineState$Blending$to = (value) => value.to;
export const MachineState$Blending$1 = (value) => value.to;
export const MachineState$Blending$blend_progress = (value) =>
  value.blend_progress;
export const MachineState$Blending$2 = (value) => value.blend_progress;
export const MachineState$Blending$blend_duration = (value) =>
  value.blend_duration;
export const MachineState$Blending$3 = (value) => value.blend_duration;
export const MachineState$Blending$easing = (value) => value.easing;
export const MachineState$Blending$4 = (value) => value.easing;

class StateMachine extends $CustomType {
  constructor(states, transitions, current, default_blend, default_easing) {
    super();
    this.states = states;
    this.transitions = transitions;
    this.current = current;
    this.default_blend = default_blend;
    this.default_easing = default_easing;
  }
}

/**
 * Single state data
 */
export class Single extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const StateData$Single = ($0) => new Single($0);
export const StateData$isSingle = (value) => value instanceof Single;
export const StateData$Single$0 = (value) => value[0];

/**
 * Blending between two states with blend factor (0.0 to 1.0)
 */
export class BlendingData extends $CustomType {
  constructor(from, to, factor) {
    super();
    this.from = from;
    this.to = to;
    this.factor = factor;
  }
}
export const StateData$BlendingData = (from, to, factor) =>
  new BlendingData(from, to, factor);
export const StateData$isBlendingData = (value) =>
  value instanceof BlendingData;
export const StateData$BlendingData$from = (value) => value.from;
export const StateData$BlendingData$0 = (value) => value.from;
export const StateData$BlendingData$to = (value) => value.to;
export const StateData$BlendingData$1 = (value) => value.to;
export const StateData$BlendingData$factor = (value) => value.factor;
export const StateData$BlendingData$2 = (value) => value.factor;

/**
 * Create a new state machine with an initial state.
 *
 * The initial state is automatically registered in the state machine.
 *
 * **Default blend duration**: 1 second (can be changed with `with_default_blend`).
 * **Default easing**: None (linear) (can be changed with `with_default_easing`).
 *
 * ## Example
 *
 * ```gleam
 * type State {
 *   Idle
 *   Walking
 * }
 *
 * let machine = statemachine.new(initial_state: Idle)
 * ```
 */
export function new$(initial_state) {
  return new StateMachine(
    (() => {
      let _pipe = $set.new$();
      return $set.insert(_pipe, initial_state);
    })(),
    $set.new$(),
    new Playing(initial_state, $duration.seconds(0)),
    $duration.seconds(1),
    new $option.None(),
  );
}

/**
 * Register a state in the state machine.
 *
 * States must be registered before they can be used in transitions.
 * Registering the same state multiple times is safe (uses a Set internally).
 *
 * ## Example
 *
 * ```gleam
 * let machine =
 *   statemachine.new(initial_state: Idle)
 *   |> statemachine.with_state(state: Walking)
 *   |> statemachine.with_state(state: Running)
 * ```
 */
export function with_state(machine, state) {
  return new StateMachine(
    $set.insert(machine.states, state),
    machine.transitions,
    machine.current,
    machine.default_blend,
    machine.default_easing,
  );
}

/**
 * Add a transition between two states.
 *
 * Transitions define when and how to switch between states.
 *
 * ## Parameters
 *
 * - `from`: Source state (must be registered)
 * - `to`: Target state (must be registered)
 * - `condition`: When to trigger (Always, AfterDuration, or Custom)
 * - `blend_duration`: Time to blend between states
 * - `easing`: Optional easing function (compatible with easings_gleam)
 * - `weight`: Priority when multiple transitions are valid (higher = higher priority)
 *
 * ## Example
 *
 * ```gleam
 * import easings
 * import gleam/option.{None, Some}
 * import gleam/time/duration
 *
 * statemachine.with_transition(
 *   machine,
 *   from: Idle,
 *   to: Walking,
 *   condition: statemachine.Custom(fn(ctx) { ctx.velocity >. 0.1 }),
 *   blend_duration: duration.milliseconds(200),
 *   easing: Some(easings.ease_out_quad),
 *   weight: 5,
 * )
 * ```
 */
export function with_transition(
  machine,
  from,
  to,
  condition,
  blend_duration,
  easing,
  weight
) {
  let transition = new Transition(
    from,
    to,
    condition,
    blend_duration,
    easing,
    weight,
  );
  return new StateMachine(
    machine.states,
    $set.insert(machine.transitions, transition),
    machine.current,
    machine.default_blend,
    machine.default_easing,
  );
}

/**
 * Set the default blend duration for manual transitions.
 *
 * This duration is used when calling `transition_to` without specifying
 * a blend duration. Does not affect transitions added with `with_transition`.
 *
 * ## Example
 *
 * ```gleam
 * import gleam/time/duration
 *
 * let machine =
 *   statemachine.new(initial_state: Idle)
 *   |> statemachine.with_default_blend(duration: duration.milliseconds(500))
 * ```
 */
export function with_default_blend(machine, default_blend) {
  return new StateMachine(
    machine.states,
    machine.transitions,
    machine.current,
    default_blend,
    machine.default_easing,
  );
}

/**
 * Set the default easing function for manual transitions.
 *
 * This easing is used when calling `transition_to` without specifying
 * an easing function. Does not affect transitions added with `with_transition`.
 *
 * ## Example
 *
 * ```gleam
 * import easings
 * import gleam/option.{Some}
 *
 * let machine =
 *   statemachine.new(initial_state: Idle)
 *   |> statemachine.with_default_easing(easing: Some(easings.ease_in_out_quad))
 * ```
 */
export function with_default_easing(machine, default_easing) {
  return new StateMachine(
    machine.states,
    machine.transitions,
    machine.current,
    machine.default_blend,
    default_easing,
  );
}

/**
 * Manually force a transition to a specific state.
 *
 * Bypasses all transition conditions and forces an immediate state change.
 * Useful for external events like damage, death, or cutscenes.
 *
 * ## Parameters
 *
 * - `machine`: The state machine
 * - `target`: The state to transition to
 * - `blend_duration`: Optional blend time. If None, uses default blend duration
 * - `easing`: Optional easing function. If None, uses default easing
 *
 * ## Example
 *
 * ```gleam
 * import easings
 * import gleam/option.{None, Some}
 * import gleam/time/duration
 *
 * // Force transition with custom blend and easing
 * let machine =
 *   statemachine.transition_to(
 *     machine,
 *     HitReaction,
 *     blend_duration: Some(duration.milliseconds(100)),
 *     easing: Some(easings.ease_out_back),
 *   )
 *
 * // Force transition with defaults
 * let machine =
 *   statemachine.transition_to(
 *     machine,
 *     Dead,
 *     blend_duration: None,
 *     easing: None,
 *   )
 * ```
 */
export function transition_to(machine, target, blend_duration, easing) {
  let blend = $option.unwrap(blend_duration, machine.default_blend);
  let _block;
  if (easing instanceof $option.Some) {
    _block = easing;
  } else {
    _block = machine.default_easing;
  }
  let ease = _block;
  let $ = machine.current;
  if ($ instanceof Playing) {
    let from = $.state;
    return new StateMachine(
      machine.states,
      machine.transitions,
      new Blending(from, target, $duration.seconds(0), blend, ease),
      machine.default_blend,
      machine.default_easing,
    );
  } else {
    let current_to = $.to;
    return new StateMachine(
      machine.states,
      machine.transitions,
      new Blending(current_to, target, $duration.seconds(0), blend, ease),
      machine.default_blend,
      machine.default_easing,
    );
  }
}

/**
 * Check if currently blending between states.
 *
 * Returns `True` during transitions, `False` when playing a single state.
 *
 * ## Example
 *
 * ```gleam
 * case statemachine.is_blending(machine) {
 *   True -> io.println("Transitioning...")
 *   False -> io.println("Stable state")
 * }
 * ```
 */
export function is_blending(machine) {
  let $ = machine.current;
  if ($ instanceof Playing) {
    return false;
  } else {
    return true;
  }
}

/**
 * Get all registered state IDs.
 *
 * Returns a Set of all states registered in the state machine.
 *
 * ## Example
 *
 * ```gleam
 * import gleam/set
 *
 * let ids = statemachine.state_ids(machine)
 * set.to_list(ids)
 * |> list.each(fn(state) {
 *   io.println("State: " <> string.inspect(state))
 * })
 * ```
 */
export function states(machine) {
  return machine.states;
}

/**
 * Get the number of states in the state machine.
 */
export function state_count(machine) {
  return $set.size(machine.states);
}

/**
 * Get the number of transitions in the state machine.
 */
export function transition_count(machine) {
  return $set.size(machine.transitions);
}

/**
 * Check if a condition is met
 * 
 * @ignore
 */
function check_condition(condition, elapsed, context) {
  if (condition instanceof Always) {
    return true;
  } else if (condition instanceof AfterDuration) {
    let duration = condition[0];
    return $duration.compare(elapsed, duration) instanceof $order.Gt;
  } else {
    let check = condition[0];
    return check(context);
  }
}

/**
 * Find a valid transition from the current state
 * 
 * @ignore
 */
function find_valid_transition(machine, from_state, elapsed, context) {
  let _pipe = machine.transitions;
  let _pipe$1 = $set.filter(
    _pipe,
    (transition) => {
      return (isEqual(transition.from, from_state)) && check_condition(
        transition.condition,
        elapsed,
        context,
      );
    },
  );
  let _pipe$2 = $set.to_list(_pipe$1);
  let _pipe$3 = $list.sort(
    _pipe$2,
    (a, b) => { return $int.compare(b.weight, a.weight); },
  );
  return $list.first(_pipe$3);
}

/**
 * Update the state machine (call every frame).
 *
 * Evaluates transition conditions and advances blend progress. Returns the
 * updated machine and a boolean indicating if a transition occurred this frame.
 *
 * ## Parameters
 *
 * - `machine`: The state machine to update
 * - `context`: Your custom context passed to Custom condition functions
 * - `delta_time`: Time elapsed since last update
 *
 * ## Returns
 *
 * A tuple of `(updated_machine, transitioned)` where `transitioned` is `True`
 * if a state change occurred this frame.
 *
 * ## Example
 *
 * ```gleam
 * import gleam/time/duration
 *
 * fn game_loop(model: Model, delta: duration.Duration) {
 *   let ctx = GameContext(velocity: model.velocity)
 *   let #(new_machine, transitioned) =
 *     statemachine.update(model.machine, ctx, delta)
 *   
 *   case transitioned {
 *     True -> io.println("State changed!")
 *     False -> Nil
 *   }
 *   
 *   Model(..model, machine: new_machine)
 * }
 * ```
 */
export function update(machine, context, delta_time) {
  let $ = machine.current;
  if ($ instanceof Playing) {
    let state_id = $.state;
    let elapsed = $.elapsed;
    let new_elapsed = $duration.add(elapsed, delta_time);
    let $1 = find_valid_transition(machine, state_id, new_elapsed, context);
    if ($1 instanceof Ok) {
      let transition = $1[0];
      let new_current = new Blending(
        state_id,
        transition.to,
        $duration.seconds(0),
        transition.blend_duration,
        transition.easing,
      );
      return [
        new StateMachine(
          machine.states,
          machine.transitions,
          new_current,
          machine.default_blend,
          machine.default_easing,
        ),
        true,
      ];
    } else {
      return [
        new StateMachine(
          machine.states,
          machine.transitions,
          new Playing(state_id, new_elapsed),
          machine.default_blend,
          machine.default_easing,
        ),
        false,
      ];
    }
  } else {
    let from = $.from;
    let to = $.to;
    let progress = $.blend_progress;
    let duration = $.blend_duration;
    let easing = $.easing;
    let new_progress = $duration.add(progress, delta_time);
    let $1 = $duration.compare(new_progress, duration) instanceof $order.Gt;
    if ($1) {
      return [
        new StateMachine(
          machine.states,
          machine.transitions,
          new Playing(to, $duration.seconds(0)),
          machine.default_blend,
          machine.default_easing,
        ),
        true,
      ];
    } else {
      return [
        new StateMachine(
          machine.states,
          machine.transitions,
          new Blending(from, to, new_progress, duration, easing),
          machine.default_blend,
          machine.default_easing,
        ),
        false,
      ];
    }
  }
}

function duration_ratio(a, b) {
  let $ = $duration.to_seconds_and_nanoseconds(a);
  let a_sec;
  let a_nano;
  a_sec = $[0];
  a_nano = $[1];
  let $1 = $duration.to_seconds_and_nanoseconds(b);
  let b_sec;
  let b_nano;
  b_sec = $1[0];
  b_nano = $1[1];
  let a_total_nano = $int.to_float(a_sec * 1_000_000_000 + a_nano);
  let b_total_nano = $int.to_float(b_sec * 1_000_000_000 + b_nano);
  let $2 = b_total_nano === 0.0;
  if ($2) {
    return 0.0;
  } else {
    return divideFloat(a_total_nano, b_total_nano);
  }
}

/**
 * Get the current state data from the state machine.
 *
 * See `StateData` type documentation for usage examples.
 */
export function state_data(machine) {
  let $ = machine.current;
  if ($ instanceof Playing) {
    let state_id = $.state;
    return new Single(state_id);
  } else {
    let from = $.from;
    let to = $.to;
    let progress = $.blend_progress;
    let duration = $.blend_duration;
    let easing = $.easing;
    let linear_progress = duration_ratio(progress, duration);
    let _block;
    if (easing instanceof $option.Some) {
      let ease_fn = easing[0];
      _block = ease_fn(linear_progress);
    } else {
      _block = linear_progress;
    }
    let blend_factor = _block;
    return new BlendingData(from, to, blend_factor);
  }
}

/**
 * Get blend progress as a normalized value (0.0 to 1.0).
 *
 * Returns `None` if not currently blending, `Some(progress)` during transitions.
 * The progress returned is the **linear** progress, not the eased value.
 *
 * ## Example
 *
 * ```gleam
 * case statemachine.blend_progress(machine) {
 *   Ok(progress) -> {
 *     io.println("Blend: " <> float.to_string(progress *. 100.0) <> "%")
 *   }
 *   Error(Nil) -> Nil
 * }
 * ```
 */
export function blend_progress(machine) {
  let $ = machine.current;
  if ($ instanceof Playing) {
    return new Error(undefined);
  } else {
    let progress = $.blend_progress;
    let duration = $.blend_duration;
    return new Ok(duration_ratio(progress, duration));
  }
}
