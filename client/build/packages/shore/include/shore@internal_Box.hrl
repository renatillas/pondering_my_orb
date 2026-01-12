-record(box, {
    children :: list(shore@internal:node_(any())),
    title :: gleam@option:option(binary()),
    fg :: gleam@option:option(shore@style:color())
}).
