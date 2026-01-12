-record(transition, {
    from :: any(),
    to :: any(),
    condition :: statemachine:condition(any()),
    blend_duration :: gleam@time@duration:duration(),
    easing :: gleam@option:option(fun((float()) -> float())),
    weight :: integer()
}).
