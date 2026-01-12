-record(grid, {
    gap :: integer(),
    rows :: list(shore@style:size()),
    columns :: list(shore@style:size()),
    cells :: list(shore@internal:cell(any()))
}).
