-module(shore@layout).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).
-define(FILEPATH, "src/shore/layout.gleam").
-export([cell/3, grid/4, center/3, split/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/shore/layout.gleam", 29).
?DOC(
    " A Cell is a container item within a Grid which contains a collection of ui items (or another Grid).\n"
    "\n"
    " A Cell can be a single \"square\" within a Grid, or it can span across multiple \"squares\" in a Grid.\n"
    "\n"
    " Using the row and col arguments to define the start and end rows and columns\n"
    " respectively that the content should span across (this is a 0-based index).\n"
    "\n"
    " For example, in a Grid made up of four equally sized \"squares\" defined as\n"
    " ```gleam\n"
    " rows: [style.Pct(50), style.Pct(50)],\n"
    " cols: [style.Pct(50), style.Pct(50)],\n"
    " ```\n"
    " (a.k.a. two rows and two columns at 50% each).\n"
    "\n"
    " Then to position a cell, consider the following examples:\n"
    "\n"
    " * `row: #(0,0), col: #(0,0)` would be the top left\n"
    " * `row: #(0,1), col: #(0,0)` would be the left half\n"
    " * `row: #(0,1), col: #(0,1)` would be the entire grid\n"
    " * `row: #(0,0), col: #(0,1)` would be the top half\n"
).
-spec cell(
    shore@internal:node_(HDV),
    {integer(), integer()},
    {integer(), integer()}
) -> shore@internal:cell(HDV).
cell(Content, Row, Col) ->
    {cell, Content, Row, Col}.

-file("src/shore/layout.gleam", 49).
?DOC(
    " A grid-based layout defining rows and columns which contain cells and the\n"
    " gaps between them.\n"
    "\n"
    " This should be remeniscent of CSS Grid. You define a list of rows and\n"
    " columns by size, then use Cells to fill the rows/columns to create descrete\n"
    " areas of ui elements.\n"
    "\n"
    " Consider using some of the default provided layouts, such as `center` and\n"
    " `split` or view the examples/layouts for more complex custom layouts.\n"
    "\n"
    " Note: Layouts can be nested as long as it is the only child of a cell.\n"
).
-spec grid(
    integer(),
    list(shore@style:size()),
    list(shore@style:size()),
    list(shore@internal:cell(HEA))
) -> shore@internal:node_(HEA).
grid(Gap, Rows, Cols, Cells) ->
    {layouts, {grid, Gap, Rows, Cols, Cells}}.

-file("src/shore/layout.gleam", 59).
?DOC(" A layout which centers vertically and horizontally\n").
-spec center(shore@internal:node_(HEE), shore@style:size(), shore@style:size()) -> shore@internal:node_(HEE).
center(Content, Width, Height) ->
    _pipe = {grid,
        0,
        [fill, Height, fill],
        [fill, Width, fill],
        [{cell, Content, {1, 1}, {1, 1}}]},
    {layouts, _pipe}.

-file("src/shore/layout.gleam", 74).
?DOC(" A layout which has a 50/50 split\n").
-spec split(shore@internal:node_(HEH), shore@internal:node_(HEH)) -> shore@internal:node_(HEH).
split(Left, Right) ->
    _pipe = {grid,
        0,
        [{pct, 100}],
        [{pct, 50}, fill],
        [{cell, Left, {0, 0}, {0, 0}}, {cell, Right, {0, 0}, {1, 1}}]},
    {layouts, _pipe}.
