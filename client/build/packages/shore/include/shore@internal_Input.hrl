-record(input, {
    label :: binary(),
    value :: binary(),
    width :: shore@style:size(),
    event :: fun((binary()) -> any()),
    submit :: gleam@option:option(any()),
    hidden :: boolean()
}).
