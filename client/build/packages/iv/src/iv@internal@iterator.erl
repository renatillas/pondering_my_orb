-module(iv@internal@iterator).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/iv/internal/iterator.gleam").
-export([new/1]).
-export_type([iterator/1, path_advancement/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-type iterator(HPQ) :: {iterator,
        list({integer(), iv@internal@vector:vector(iv@internal@node:node_(HPQ))}),
        integer(),
        integer(),
        iv@internal@vector:vector(HPQ)}.

-type path_advancement(HPR) :: {advanced_path,
        integer(),
        iv@internal@vector:vector(iv@internal@node:node_(HPR)),
        list({integer(), iv@internal@vector:vector(iv@internal@node:node_(HPR))})} |
    reached_the_end.

-file("src/iv/internal/iterator.gleam", 35).
?DOC(false).
-spec do_init(
    iv@internal@node:node_(HPY),
    list({integer(), iv@internal@vector:vector(iv@internal@node:node_(HPY))})
) -> iterator(HPY).
do_init(Node, Path) ->
    case Node of
        {leaf, Children} ->
            {iterator, Path, 0, erlang:tuple_size(Children), Children};

        {balanced, _, Children@1} ->
            First = erlang:element(1, Children@1),
            do_init(First, [{1, Children@1} | Path]);

        {unbalanced, _, Children@1} ->
            First = erlang:element(1, Children@1),
            do_init(First, [{1, Children@1} | Path])
    end.

-file("src/iv/internal/iterator.gleam", 31).
?DOC(false).
-spec init(iv@internal@node:node_(HPV)) -> iterator(HPV).
init(Node) ->
    do_init(Node, []).

-file("src/iv/internal/iterator.gleam", 88).
?DOC(false).
-spec advance(
    integer(),
    iv@internal@vector:vector(iv@internal@node:node_(HQH)),
    list({integer(), iv@internal@vector:vector(iv@internal@node:node_(HQH))})
) -> path_advancement(HQH).
advance(Current, Nodes, Rest) ->
    Current@1 = Current + 1,
    case Current@1 =< erlang:tuple_size(Nodes) of
        true ->
            {advanced_path, Current@1, Nodes, Rest};

        false ->
            case Rest of
                [] ->
                    reached_the_end;

                [{Current@2, Nodes@1} | Rest@1] ->
                    case advance(Current@2, Nodes@1, Rest@1) of
                        {advanced_path, Current@3, Nodes@2, Rest@2} ->
                            case erlang:element(Current@3, Nodes@2) of
                                {balanced, _, Children} ->
                                    Rest@3 = [{Current@3, Nodes@2} | Rest@2],
                                    {advanced_path, 1, Children, Rest@3};

                                {unbalanced, _, Children} ->
                                    Rest@3 = [{Current@3, Nodes@2} | Rest@2],
                                    {advanced_path, 1, Children, Rest@3};

                                {leaf, _} ->
                                    reached_the_end
                            end;

                        reached_the_end = Result ->
                            Result
                    end
            end
    end.

-file("src/iv/internal/iterator.gleam", 52).
?DOC(false).
-spec next(iterator(HQC)) -> gleam@yielder:step(HQC, iterator(HQC)).
next(It) ->
    {iterator, Path, Current, Length, Items} = It,
    Current@1 = Current + 1,
    case Current@1 =< Length of
        true ->
            {next,
                erlang:element(Current@1, Items),
                {iterator,
                    erlang:element(2, It),
                    Current@1,
                    erlang:element(4, It),
                    erlang:element(5, It)}};

        false ->
            case Path of
                [] ->
                    done;

                [{Current@2, Nodes} | Rest] ->
                    case advance(Current@2, Nodes, Rest) of
                        {advanced_path, Current@3, Nodes@1, Rest@1} ->
                            case erlang:element(Current@3, Nodes@1) of
                                {leaf, Items@1} ->
                                    Item = erlang:element(1, Items@1),
                                    Path@1 = [{Current@3, Nodes@1} | Rest@1],
                                    Length@1 = erlang:tuple_size(Items@1),
                                    {next,
                                        Item,
                                        {iterator, Path@1, 1, Length@1, Items@1}};

                                _ ->
                                    done
                            end;

                        reached_the_end ->
                            done
                    end
            end
    end.

-file("src/iv/internal/iterator.gleam", 26).
?DOC(false).
-spec new(iv@internal@node:node_(HPS)) -> gleam@yielder:yielder(HPS).
new(Node) ->
    gleam@yielder:unfold(init(Node), fun next/1).
