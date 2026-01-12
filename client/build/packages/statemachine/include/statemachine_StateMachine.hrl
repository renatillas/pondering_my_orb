-record(state_machine, {
    states :: gleam@set:set(any()),
    transitions :: gleam@set:set(statemachine:transition(any(), any())),
    current :: statemachine:machine_state(any()),
    default_blend :: gleam@time@duration:duration(),
    default_easing :: gleam@option:option(fun((float()) -> float()))
}).
