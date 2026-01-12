-module(statemachine).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/statemachine.gleam").
-export([new/1, with_state/2, with_transition/7, with_default_blend/2, with_default_easing/2, transition_to/4, is_blending/1, states/1, state_count/1, transition_count/1, update/3, state_data/1, blend_progress/1]).
-export_type([condition/1, transition/2, machine_state/1, state_machine/2, state_data/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " # StateMachine\n"
    "\n"
    " A generic, type-safe state machine library for Gleam with easing function support\n"
    " and weighted transitions.\n"
    "\n"
    " ## Features\n"
    "\n"
    " - **Fully Generic**: Works with any state type (enums, strings, custom types)\n"
    " - **Easing Support**: Compatible with easings_gleam for smooth transitions\n"
    " - **Weighted Transitions**: Prioritize transitions when multiple conditions are true\n"
    " - **Automatic Blending**: Smooth interpolation between states\n"
    " - **Context-Aware Conditions**: Pass game/app context to transition condition functions\n"
    " - **Type-Safe**: Leverage Gleam's type system for correctness\n"
    " - **Duration-Based**: Uses gleam_time's Duration type for precise timing\n"
    "\n"
    " ## Quick Example\n"
    "\n"
    " ```gleam\n"
    " import statemachine\n"
    " import gleam/option.{None}\n"
    " import gleam/time/duration\n"
    "\n"
    " // Define your state type\n"
    " type PlayerState {\n"
    "   Idle\n"
    "   Walking\n"
    "   Running\n"
    " }\n"
    "\n"
    " // Define your context\n"
    " type GameContext {\n"
    "   GameContext(velocity: Float)\n"
    " }\n"
    "\n"
    " // Create state machine\n"
    " let machine =\n"
    "   statemachine.new(initial_state: Idle)\n"
    "   |> statemachine.with_state(state: Idle)\n"
    "   |> statemachine.with_state(state: Walking)\n"
    "   |> statemachine.with_state(state: Running)\n"
    "   |> statemachine.with_transition(\n"
    "     from: Idle,\n"
    "     to: Walking,\n"
    "     condition: statemachine.Custom(fn(ctx) { ctx.velocity >. 0.1 }),\n"
    "     blend_duration: duration.milliseconds(200),\n"
    "     easing: None,\n"
    "     weight: 0,\n"
    "   )\n"
    "\n"
    " // Update in game loop\n"
    " fn update(model: Model, delta_time: duration.Duration) {\n"
    "   let ctx = GameContext(velocity: model.velocity)\n"
    "   let #(new_machine, transitioned) = statemachine.update(machine, ctx, delta_time)\n"
    "   \n"
    "   case statemachine.state_data(new_machine) {\n"
    "     statemachine.Single(state) -> // Use single state\n"
    "     statemachine.BlendingData(from, to, factor) -> // Interpolate\n"
    "   }\n"
    " }\n"
    " ```\n"
    "\n"
    " ## Transition Conditions\n"
    "\n"
    " ### Always\n"
    " Transition immediately when conditions are evaluated:\n"
    "\n"
    " ```gleam\n"
    " statemachine.with_transition(\n"
    "   from: Idle,\n"
    "   to: Jump,\n"
    "   condition: statemachine.Always,\n"
    "   blend_duration: duration.milliseconds(100),\n"
    "   easing: None,\n"
    "   weight: 0,\n"
    " )\n"
    " ```\n"
    "\n"
    " ### AfterDuration\n"
    " Transition after spending time in the current state:\n"
    "\n"
    " ```gleam\n"
    " statemachine.with_transition(\n"
    "   from: Idle,\n"
    "   to: Sleeping,\n"
    "   condition: statemachine.AfterDuration(duration.seconds(5)),\n"
    "   blend_duration: duration.seconds(1),\n"
    "   easing: Some(easings.ease_in_out_sine),\n"
    "   weight: 0,\n"
    " )\n"
    " ```\n"
    "\n"
    " ### Custom\n"
    " Transition based on custom context:\n"
    "\n"
    " ```gleam\n"
    " statemachine.Custom(fn(ctx) { ctx.velocity >. 5.0 })\n"
    " ```\n"
    "\n"
    " ## Transition Weights\n"
    "\n"
    " When multiple transitions from the same state have their conditions met,\n"
    " the transition with the highest weight is chosen:\n"
    "\n"
    " ```gleam\n"
    " statemachine.new(initial_state: Idle)\n"
    " |> statemachine.with_transition(\n"
    "   from: Idle,\n"
    "   to: Walking,\n"
    "   condition: statemachine.Always,\n"
    "   blend_duration: duration.milliseconds(200),\n"
    "   easing: None,\n"
    "   weight: 5,\n"
    " )\n"
    " |> statemachine.with_transition(\n"
    "   from: Idle,\n"
    "   to: Running,\n"
    "   condition: statemachine.Always,\n"
    "   blend_duration: duration.milliseconds(200),\n"
    "   easing: None,\n"
    "   weight: 10,  // This one will be chosen!\n"
    " )\n"
    " ```\n"
).

-type condition(ECX) :: always |
    {after_duration, gleam@time@duration:duration()} |
    {custom, fun((ECX) -> boolean())}.

-type transition(ECY, ECZ) :: {transition,
        ECY,
        ECY,
        condition(ECZ),
        gleam@time@duration:duration(),
        gleam@option:option(fun((float()) -> float())),
        integer()}.

-type machine_state(EDA) :: {playing, EDA, gleam@time@duration:duration()} |
    {blending,
        EDA,
        EDA,
        gleam@time@duration:duration(),
        gleam@time@duration:duration(),
        gleam@option:option(fun((float()) -> float()))}.

-opaque state_machine(EDB, EDC) :: {state_machine,
        gleam@set:set(EDB),
        gleam@set:set(transition(EDB, EDC)),
        machine_state(EDB),
        gleam@time@duration:duration(),
        gleam@option:option(fun((float()) -> float()))}.

-type state_data(EDD) :: {single, EDD} | {blending_data, EDD, EDD, float()}.

-file("src/statemachine.gleam", 240).
?DOC(
    " Create a new state machine with an initial state.\n"
    "\n"
    " The initial state is automatically registered in the state machine.\n"
    "\n"
    " **Default blend duration**: 1 second (can be changed with `with_default_blend`).\n"
    " **Default easing**: None (linear) (can be changed with `with_default_easing`).\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " type State {\n"
    "   Idle\n"
    "   Walking\n"
    " }\n"
    "\n"
    " let machine = statemachine.new(initial_state: Idle)\n"
    " ```\n"
).
-spec new(EDE) -> state_machine(EDE, any()).
new(Initial_state) ->
    {state_machine,
        begin
            _pipe = gleam@set:new(),
            gleam@set:insert(_pipe, Initial_state)
        end,
        gleam@set:new(),
        {playing, Initial_state, gleam@time@duration:seconds(0)},
        gleam@time@duration:seconds(1),
        none}.

-file("src/statemachine.gleam", 263).
?DOC(
    " Register a state in the state machine.\n"
    "\n"
    " States must be registered before they can be used in transitions.\n"
    " Registering the same state multiple times is safe (uses a Set internally).\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " let machine =\n"
    "   statemachine.new(initial_state: Idle)\n"
    "   |> statemachine.with_state(state: Walking)\n"
    "   |> statemachine.with_state(state: Running)\n"
    " ```\n"
).
-spec with_state(state_machine(EDI, EDJ), EDI) -> state_machine(EDI, EDJ).
with_state(Machine, State) ->
    {state_machine,
        gleam@set:insert(erlang:element(2, Machine), State),
        erlang:element(3, Machine),
        erlang:element(4, Machine),
        erlang:element(5, Machine),
        erlang:element(6, Machine)}.

-file("src/statemachine.gleam", 300).
?DOC(
    " Add a transition between two states.\n"
    "\n"
    " Transitions define when and how to switch between states.\n"
    "\n"
    " ## Parameters\n"
    "\n"
    " - `from`: Source state (must be registered)\n"
    " - `to`: Target state (must be registered)\n"
    " - `condition`: When to trigger (Always, AfterDuration, or Custom)\n"
    " - `blend_duration`: Time to blend between states\n"
    " - `easing`: Optional easing function (compatible with easings_gleam)\n"
    " - `weight`: Priority when multiple transitions are valid (higher = higher priority)\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " import easings\n"
    " import gleam/option.{None, Some}\n"
    " import gleam/time/duration\n"
    "\n"
    " statemachine.with_transition(\n"
    "   machine,\n"
    "   from: Idle,\n"
    "   to: Walking,\n"
    "   condition: statemachine.Custom(fn(ctx) { ctx.velocity >. 0.1 }),\n"
    "   blend_duration: duration.milliseconds(200),\n"
    "   easing: Some(easings.ease_out_quad),\n"
    "   weight: 5,\n"
    " )\n"
    " ```\n"
).
-spec with_transition(
    state_machine(EDO, EDP),
    EDO,
    EDO,
    condition(EDP),
    gleam@time@duration:duration(),
    gleam@option:option(fun((float()) -> float())),
    integer()
) -> state_machine(EDO, EDP).
with_transition(Machine, From, To, Condition, Blend_duration, Easing, Weight) ->
    Transition = {transition,
        From,
        To,
        Condition,
        Blend_duration,
        Easing,
        Weight},
    {state_machine,
        erlang:element(2, Machine),
        gleam@set:insert(erlang:element(3, Machine), Transition),
        erlang:element(4, Machine),
        erlang:element(5, Machine),
        erlang:element(6, Machine)}.

-file("src/statemachine.gleam", 331).
?DOC(
    " Set the default blend duration for manual transitions.\n"
    "\n"
    " This duration is used when calling `transition_to` without specifying\n"
    " a blend duration. Does not affect transitions added with `with_transition`.\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " import gleam/time/duration\n"
    "\n"
    " let machine =\n"
    "   statemachine.new(initial_state: Idle)\n"
    "   |> statemachine.with_default_blend(duration: duration.milliseconds(500))\n"
    " ```\n"
).
-spec with_default_blend(
    state_machine(EDW, EDX),
    gleam@time@duration:duration()
) -> state_machine(EDW, EDX).
with_default_blend(Machine, Default_blend) ->
    {state_machine,
        erlang:element(2, Machine),
        erlang:element(3, Machine),
        erlang:element(4, Machine),
        Default_blend,
        erlang:element(6, Machine)}.

-file("src/statemachine.gleam", 353).
?DOC(
    " Set the default easing function for manual transitions.\n"
    "\n"
    " This easing is used when calling `transition_to` without specifying\n"
    " an easing function. Does not affect transitions added with `with_transition`.\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " import easings\n"
    " import gleam/option.{Some}\n"
    "\n"
    " let machine =\n"
    "   statemachine.new(initial_state: Idle)\n"
    "   |> statemachine.with_default_easing(easing: Some(easings.ease_in_out_quad))\n"
    " ```\n"
).
-spec with_default_easing(
    state_machine(EEC, EED),
    gleam@option:option(fun((float()) -> float()))
) -> state_machine(EEC, EED).
with_default_easing(Machine, Default_easing) ->
    {state_machine,
        erlang:element(2, Machine),
        erlang:element(3, Machine),
        erlang:element(4, Machine),
        erlang:element(5, Machine),
        Default_easing}.

-file("src/statemachine.gleam", 540).
?DOC(
    " Manually force a transition to a specific state.\n"
    "\n"
    " Bypasses all transition conditions and forces an immediate state change.\n"
    " Useful for external events like damage, death, or cutscenes.\n"
    "\n"
    " ## Parameters\n"
    "\n"
    " - `machine`: The state machine\n"
    " - `target`: The state to transition to\n"
    " - `blend_duration`: Optional blend time. If None, uses default blend duration\n"
    " - `easing`: Optional easing function. If None, uses default easing\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " import easings\n"
    " import gleam/option.{None, Some}\n"
    " import gleam/time/duration\n"
    "\n"
    " // Force transition with custom blend and easing\n"
    " let machine =\n"
    "   statemachine.transition_to(\n"
    "     machine,\n"
    "     HitReaction,\n"
    "     blend_duration: Some(duration.milliseconds(100)),\n"
    "     easing: Some(easings.ease_out_back),\n"
    "   )\n"
    "\n"
    " // Force transition with defaults\n"
    " let machine =\n"
    "   statemachine.transition_to(\n"
    "     machine,\n"
    "     Dead,\n"
    "     blend_duration: None,\n"
    "     easing: None,\n"
    "   )\n"
    " ```\n"
).
-spec transition_to(
    state_machine(EEU, EEV),
    EEU,
    gleam@option:option(gleam@time@duration:duration()),
    gleam@option:option(fun((float()) -> float()))
) -> state_machine(EEU, EEV).
transition_to(Machine, Target, Blend_duration, Easing) ->
    Blend = gleam@option:unwrap(Blend_duration, erlang:element(5, Machine)),
    Ease = case Easing of
        {some, _} ->
            Easing;

        none ->
            erlang:element(6, Machine)
    end,
    case erlang:element(4, Machine) of
        {playing, From, _} ->
            {state_machine,
                erlang:element(2, Machine),
                erlang:element(3, Machine),
                {blending,
                    From,
                    Target,
                    gleam@time@duration:seconds(0),
                    Blend,
                    Ease},
                erlang:element(5, Machine),
                erlang:element(6, Machine)};

        {blending, _, Current_to, _, _, _} ->
            {state_machine,
                erlang:element(2, Machine),
                erlang:element(3, Machine),
                {blending,
                    Current_to,
                    Target,
                    gleam@time@duration:seconds(0),
                    Blend,
                    Ease},
                erlang:element(5, Machine),
                erlang:element(6, Machine)}
    end.

-file("src/statemachine.gleam", 581).
?DOC(
    " Check if currently blending between states.\n"
    "\n"
    " Returns `True` during transitions, `False` when playing a single state.\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " case statemachine.is_blending(machine) {\n"
    "   True -> io.println(\"Transitioning...\")\n"
    "   False -> io.println(\"Stable state\")\n"
    " }\n"
    " ```\n"
).
-spec is_blending(state_machine(any(), any())) -> boolean().
is_blending(Machine) ->
    case erlang:element(4, Machine) of
        {playing, _, _} ->
            false;

        {blending, _, _, _, _, _} ->
            true
    end.

-file("src/statemachine.gleam", 627).
?DOC(
    " Get all registered state IDs.\n"
    "\n"
    " Returns a Set of all states registered in the state machine.\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " import gleam/set\n"
    "\n"
    " let ids = statemachine.state_ids(machine)\n"
    " set.to_list(ids)\n"
    " |> list.each(fn(state) {\n"
    "   io.println(\"State: \" <> string.inspect(state))\n"
    " })\n"
    " ```\n"
).
-spec states(state_machine(EFM, any())) -> gleam@set:set(EFM).
states(Machine) ->
    erlang:element(2, Machine).

-file("src/statemachine.gleam", 632).
?DOC(" Get the number of states in the state machine.\n").
-spec state_count(state_machine(any(), any())) -> integer().
state_count(Machine) ->
    gleam@set:size(erlang:element(2, Machine)).

-file("src/statemachine.gleam", 637).
?DOC(" Get the number of transitions in the state machine.\n").
-spec transition_count(state_machine(any(), any())) -> integer().
transition_count(Machine) ->
    gleam@set:size(erlang:element(3, Machine)).

-file("src/statemachine.gleam", 663).
?DOC(" Check if a condition is met\n").
-spec check_condition(condition(EGH), gleam@time@duration:duration(), EGH) -> boolean().
check_condition(Condition, Elapsed, Context) ->
    case Condition of
        always ->
            true;

        {after_duration, Duration} ->
            gleam@time@duration:compare(Elapsed, Duration) =:= gt;

        {custom, Check} ->
            Check(Context)
    end.

-file("src/statemachine.gleam", 644).
?DOC(" Find a valid transition from the current state\n").
-spec find_valid_transition(
    state_machine(EFZ, EGA),
    EFZ,
    gleam@time@duration:duration(),
    EGA
) -> {ok, transition(EFZ, EGA)} | {error, nil}.
find_valid_transition(Machine, From_state, Elapsed, Context) ->
    _pipe = erlang:element(3, Machine),
    _pipe@1 = gleam@set:filter(
        _pipe,
        fun(Transition) ->
            (erlang:element(2, Transition) =:= From_state) andalso check_condition(
                erlang:element(4, Transition),
                Elapsed,
                Context
            )
        end
    ),
    _pipe@2 = gleam@set:to_list(_pipe@1),
    _pipe@3 = gleam@list:sort(
        _pipe@2,
        fun(A, B) ->
            gleam@int:compare(erlang:element(7, B), erlang:element(7, A))
        end
    ),
    gleam@list:first(_pipe@3).

-file("src/statemachine.gleam", 394).
?DOC(
    " Update the state machine (call every frame).\n"
    "\n"
    " Evaluates transition conditions and advances blend progress. Returns the\n"
    " updated machine and a boolean indicating if a transition occurred this frame.\n"
    "\n"
    " ## Parameters\n"
    "\n"
    " - `machine`: The state machine to update\n"
    " - `context`: Your custom context passed to Custom condition functions\n"
    " - `delta_time`: Time elapsed since last update\n"
    "\n"
    " ## Returns\n"
    "\n"
    " A tuple of `(updated_machine, transitioned)` where `transitioned` is `True`\n"
    " if a state change occurred this frame.\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " import gleam/time/duration\n"
    "\n"
    " fn game_loop(model: Model, delta: duration.Duration) {\n"
    "   let ctx = GameContext(velocity: model.velocity)\n"
    "   let #(new_machine, transitioned) =\n"
    "     statemachine.update(model.machine, ctx, delta)\n"
    "   \n"
    "   case transitioned {\n"
    "     True -> io.println(\"State changed!\")\n"
    "     False -> Nil\n"
    "   }\n"
    "   \n"
    "   Model(..model, machine: new_machine)\n"
    " }\n"
    " ```\n"
).
-spec update(state_machine(EEJ, EEK), EEK, gleam@time@duration:duration()) -> {state_machine(EEJ, EEK),
    boolean()}.
update(Machine, Context, Delta_time) ->
    case erlang:element(4, Machine) of
        {playing, State_id, Elapsed} ->
            New_elapsed = gleam@time@duration:add(Elapsed, Delta_time),
            case find_valid_transition(Machine, State_id, New_elapsed, Context) of
                {ok, Transition} ->
                    New_current = {blending,
                        State_id,
                        erlang:element(3, Transition),
                        gleam@time@duration:seconds(0),
                        erlang:element(5, Transition),
                        erlang:element(6, Transition)},
                    {{state_machine,
                            erlang:element(2, Machine),
                            erlang:element(3, Machine),
                            New_current,
                            erlang:element(5, Machine),
                            erlang:element(6, Machine)},
                        true};

                {error, _} ->
                    {{state_machine,
                            erlang:element(2, Machine),
                            erlang:element(3, Machine),
                            {playing, State_id, New_elapsed},
                            erlang:element(5, Machine),
                            erlang:element(6, Machine)},
                        false}
            end;

        {blending, From, To, Progress, Duration, Easing} ->
            New_progress = gleam@time@duration:add(Progress, Delta_time),
            case gleam@time@duration:compare(New_progress, Duration) =:= gt of
                true ->
                    {{state_machine,
                            erlang:element(2, Machine),
                            erlang:element(3, Machine),
                            {playing, To, gleam@time@duration:seconds(0)},
                            erlang:element(5, Machine),
                            erlang:element(6, Machine)},
                        true};

                false ->
                    {{state_machine,
                            erlang:element(2, Machine),
                            erlang:element(3, Machine),
                            {blending, From, To, New_progress, Duration, Easing},
                            erlang:element(5, Machine),
                            erlang:element(6, Machine)},
                        false}
            end
    end.

-file("src/statemachine.gleam", 675).
-spec duration_ratio(
    gleam@time@duration:duration(),
    gleam@time@duration:duration()
) -> float().
duration_ratio(A, B) ->
    {A_sec, A_nano} = gleam@time@duration:to_seconds_and_nanoseconds(A),
    {B_sec, B_nano} = gleam@time@duration:to_seconds_and_nanoseconds(B),
    A_total_nano = erlang:float((A_sec * 1000000000) + A_nano),
    B_total_nano = erlang:float((B_sec * 1000000000) + B_nano),
    case B_total_nano =:= +0.0 of
        true ->
            +0.0;

        false ->
            case B_total_nano of
                +0.0 -> +0.0;
                -0.0 -> -0.0;
                Gleam@denominator -> A_total_nano / Gleam@denominator
            end
    end.

-file("src/statemachine.gleam", 485).
?DOC(
    " Get the current state data from the state machine.\n"
    "\n"
    " See `StateData` type documentation for usage examples.\n"
).
-spec state_data(state_machine(EEP, any())) -> state_data(EEP).
state_data(Machine) ->
    case erlang:element(4, Machine) of
        {playing, State_id, _} ->
            {single, State_id};

        {blending, From, To, Progress, Duration, Easing} ->
            Linear_progress = duration_ratio(Progress, Duration),
            Blend_factor = case Easing of
                {some, Ease_fn} ->
                    Ease_fn(Linear_progress);

                none ->
                    Linear_progress
            end,
            {blending_data, From, To, Blend_factor}
    end.

-file("src/statemachine.gleam", 603).
?DOC(
    " Get blend progress as a normalized value (0.0 to 1.0).\n"
    "\n"
    " Returns `None` if not currently blending, `Some(progress)` during transitions.\n"
    " The progress returned is the **linear** progress, not the eased value.\n"
    "\n"
    " ## Example\n"
    "\n"
    " ```gleam\n"
    " case statemachine.blend_progress(machine) {\n"
    "   Ok(progress) -> {\n"
    "     io.println(\"Blend: \" <> float.to_string(progress *. 100.0) <> \"%\")\n"
    "   }\n"
    "   Error(Nil) -> Nil\n"
    " }\n"
    " ```\n"
).
-spec blend_progress(state_machine(any(), any())) -> {ok, float()} |
    {error, nil}.
blend_progress(Machine) ->
    case erlang:element(4, Machine) of
        {playing, _, _} ->
            {error, nil};

        {blending, _, _, Progress, Duration, _} ->
            {ok, duration_ratio(Progress, Duration)}
    end.
