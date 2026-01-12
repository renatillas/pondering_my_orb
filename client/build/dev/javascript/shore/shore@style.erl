-module(shore@style).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).
-define(FILEPATH, "src/shore/style.gleam").
-export_type([align/0, size/0, color/0]).

-type align() :: left | center | right.

-type size() :: {px, integer()} | {pct, integer()} | fill.

-type color() :: black | red | green | yellow | blue | magenta | cyan | white.


