-record(text_multi, {
    text :: binary(),
    wrap :: shore@internal:text_wrap(),
    fg :: gleam@option:option(shore@style:color()),
    bg :: gleam@option:option(shore@style:color())
}).
