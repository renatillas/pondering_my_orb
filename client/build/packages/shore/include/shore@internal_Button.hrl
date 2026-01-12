-record(button, {
    id :: binary(),
    text :: binary(),
    key :: shore@key:key(),
    event :: any(),
    fg :: gleam@option:option(shore@style:color()),
    bg :: gleam@option:option(shore@style:color()),
    focus_fg :: gleam@option:option(shore@style:color()),
    focus_bg :: gleam@option:option(shore@style:color())
}).
