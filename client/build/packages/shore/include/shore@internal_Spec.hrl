-record(spec, {
    init :: fun((gleam@erlang@process:subject(any())) -> {any(),
        list(fun(() -> any()))}),
    view :: fun((any()) -> shore@internal:node_(any())),
    update :: fun((any(), any()) -> {any(), list(fun(() -> any()))}),
    exit :: gleam@erlang@process:subject(nil),
    keybinds :: shore@internal:keybinds(),
    redraw :: shore@internal:redraw()
}).
