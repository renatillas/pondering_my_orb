-module(iv@internal@builder).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/iv/internal/builder.gleam").
-export([new/0, reverse/0, push/2, build/1]).
-export_type([builder/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-opaque builder(HLZ) :: {builder,
        list(iv@internal@vector:vector(iv@internal@node:node_(HLZ))),
        iv@internal@vector:vector(HLZ),
        fun((list(iv@internal@vector:vector(iv@internal@node:node_(HLZ))), iv@internal@node:node_(HLZ), integer()) -> list(iv@internal@vector:vector(iv@internal@node:node_(HLZ)))),
        fun((iv@internal@vector:vector(HLZ), HLZ) -> iv@internal@vector:vector(HLZ))}.

-file("src/iv/internal/builder.gleam", 36).
?DOC(false).
-spec append_node(
    list(iv@internal@vector:vector(iv@internal@node:node_(HNU))),
    iv@internal@node:node_(HNU),
    integer()
) -> list(iv@internal@vector:vector(iv@internal@node:node_(HNU))).
append_node(Nodes, Node, Shift) ->
    case Nodes of
        [] ->
            [iv_ffi:singleton(Node)];

        [Nodes@1 | Rest] ->
            case erlang:tuple_size(Nodes@1) < 16 of
                true ->
                    [erlang:append_element(Nodes@1, Node) | Rest];

                false ->
                    Shift@1 = Shift + 4,
                    New_node = iv@internal@node:balanced(Shift@1, Nodes@1),
                    [iv_ffi:singleton(Node) |
                        append_node(Rest, New_node, Shift@1)]
            end
    end.

-file("src/iv/internal/builder.gleam", 18).
?DOC(false).
-spec new() -> builder(any()).
new() ->
    {builder,
        [],
        iv_ffi:empty(),
        fun append_node/3,
        fun erlang:append_element/2}.

-file("src/iv/internal/builder.gleam", 52).
?DOC(false).
-spec prepend_node(
    list(iv@internal@vector:vector(iv@internal@node:node_(HOK))),
    iv@internal@node:node_(HOK),
    integer()
) -> list(iv@internal@vector:vector(iv@internal@node:node_(HOK))).
prepend_node(Nodes, Node, Shift) ->
    case Nodes of
        [] ->
            [iv_ffi:singleton(Node)];

        [Nodes@1 | Rest] ->
            case erlang:tuple_size(Nodes@1) < 16 of
                true ->
                    [iv_ffi:prepend(Nodes@1, Node) | Rest];

                false ->
                    Shift@1 = Shift + 4,
                    New_node = iv@internal@node:balanced(Shift@1, Nodes@1),
                    [iv_ffi:singleton(Node) |
                        prepend_node(Rest, New_node, Shift@1)]
            end
    end.

-file("src/iv/internal/builder.gleam", 27).
?DOC(false).
-spec reverse() -> builder(any()).
reverse() ->
    {builder, [], iv_ffi:empty(), fun prepend_node/3, fun iv_ffi:prepend/2}.

-file("src/iv/internal/builder.gleam", 68).
?DOC(false).
-spec push(builder(HMN), HMN) -> builder(HMN).
push(Builder, Item) ->
    {builder, Nodes, Items, Push_node, Push_item} = Builder,
    case erlang:tuple_size(Items) =:= 16 of
        true ->
            Leaf = {leaf, Items},
            {builder,
                Push_node(Nodes, Leaf, 0),
                iv_ffi:singleton(Item),
                Push_node,
                Push_item};

        false ->
            {builder, Nodes, Push_item(Items, Item), Push_node, Push_item}
    end.

-file("src/iv/internal/builder.gleam", 96).
?DOC(false).
-spec compress_nodes(
    list(iv@internal@vector:vector(iv@internal@node:node_(HPJ))),
    fun((list(iv@internal@vector:vector(iv@internal@node:node_(HPJ))), iv@internal@node:node_(HPJ), integer()) -> list(iv@internal@vector:vector(iv@internal@node:node_(HPJ)))),
    integer()
) -> {ok, {integer(), iv@internal@vector:vector(iv@internal@node:node_(HPJ))}} |
    {error, nil}.
compress_nodes(Nodes, Push_node, Shift) ->
    case Nodes of
        [] ->
            {error, nil};

        [Root] ->
            {ok, {Shift, Root}};

        [Nodes@1 | Rest] ->
            Shift@1 = Shift + 4,
            Compressed = Push_node(
                Rest,
                iv@internal@node:branch(Shift@1, Nodes@1),
                Shift@1
            ),
            compress_nodes(Compressed, Push_node, Shift@1)
    end.

-file("src/iv/internal/builder.gleam", 85).
?DOC(false).
-spec build(builder(HMP)) -> {ok,
        {integer(), iv@internal@vector:vector(iv@internal@node:node_(HMP))}} |
    {error, nil}.
build(Builder) ->
    {builder, Nodes, Items, Push_node, _} = Builder,
    Items_len = erlang:tuple_size(Items),
    Nodes@1 = case Items_len > 0 of
        true ->
            Push_node(Nodes, {leaf, Items}, 0);

        false ->
            Nodes
    end,
    compress_nodes(Nodes@1, Push_node, 0).
