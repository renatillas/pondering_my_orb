-record(blending, {
    from :: any(),
    to :: any(),
    blend_progress :: gleam@time@duration:duration(),
    blend_duration :: gleam@time@duration:duration(),
    easing :: gleam@option:option(fun((float()) -> float()))
}).
