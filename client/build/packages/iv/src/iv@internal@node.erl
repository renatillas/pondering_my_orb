-module(iv@internal@node).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/iv/internal/node.gleam").
-export([size/1, find_map/2, map/2, try_map/2, fold/3, fold_right/3, try_fold/3, balanced/2, unbalanced/3, branch/2, get/3, find_index/4, find_last_index/4, update/4, split/3, index_map/4, index_fold/5, index_fold_right/5, direct_concat/4, concat/4]).
-export_type([node_/1, concat_result/1, rebalance_state/2, rebalance_params/1, direct_concat_result/1, split_result/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-type node_(FXJ) :: {balanced, integer(), iv@internal@vector:vector(node_(FXJ))} |
    {unbalanced,
        iv@internal@vector:vector(integer()),
        iv@internal@vector:vector(node_(FXJ))} |
    {leaf, iv@internal@vector:vector(FXJ)}.

-type concat_result(FXK) :: {one_node, node_(FXK)} |
    {two_nodes, node_(FXK), node_(FXK)}.

-type rebalance_state(FXL, FXM) :: {rebalance_state,
        integer(),
        iv@internal@vector:vector(node_(FXL)),
        list(iv@internal@vector:vector(FXM)),
        integer()}.

-type rebalance_params(FXN) :: {from_left,
        iv@internal@vector:vector(node_(FXN)),
        concat_result(FXN)} |
    {from_right, concat_result(FXN), iv@internal@vector:vector(node_(FXN))} |
    {rebalance_merge,
        iv@internal@vector:vector(node_(FXN)),
        concat_result(FXN),
        iv@internal@vector:vector(node_(FXN))}.

-type direct_concat_result(FXO) :: {concatenated, node_(FXO)} |
    {no_free_slot, node_(FXO), node_(FXO)}.

-type split_result(FXP) :: {split, node_(FXP), integer(), node_(FXP), integer()} |
    empty_prefix.

-file("src/iv/internal/node.gleam", 92).
?DOC(false).
-spec size(node_(any())) -> integer().
size(Node) ->
    case Node of
        {balanced, Size, _} ->
            Size;

        {leaf, Children} ->
            erlang:tuple_size(Children);

        {unbalanced, Sizes, _} ->
            erlang:element(erlang:tuple_size(Sizes), Sizes)
    end.

-file("src/iv/internal/node.gleam", 101).
?DOC(false).
-spec length(node_(any())) -> integer().
length(Node) ->
    case Node of
        {balanced, _, Children} ->
            erlang:tuple_size(Children);

        {unbalanced, _, Children} ->
            erlang:tuple_size(Children);

        {leaf, Children@1} ->
            erlang:tuple_size(Children@1)
    end.

-file("src/iv/internal/node.gleam", 135).
?DOC(false).
-spec find_size(iv@internal@vector:vector(integer()), integer(), integer()) -> integer().
find_size(Sizes, Size_idx_plus_one, Index) ->
    case erlang:element(Size_idx_plus_one, Sizes) > Index of
        true ->
            Size_idx_plus_one - 1;

        false ->
            find_size(Sizes, Size_idx_plus_one + 1, Index)
    end.

-file("src/iv/internal/node.gleam", 150).
?DOC(false).
-spec find_map(node_(GIF), fun((GIF) -> {ok, GIH} | {error, nil})) -> {ok, GIH} |
    {error, nil}.
find_map(Node, Fun) ->
    case Node of
        {leaf, Children} ->
            iv@internal@vector:find_map(Children, Fun);

        {balanced, _, Children@1} ->
            iv@internal@vector:find_map(
                Children@1,
                fun(_capture) -> find_map(_capture, Fun) end
            );

        {unbalanced, _, Children@1} ->
            iv@internal@vector:find_map(
                Children@1,
                fun(_capture) -> find_map(_capture, Fun) end
            )
    end.

-file("src/iv/internal/node.gleam", 446).
?DOC(false).
-spec concat_result_to_vector(concat_result(GAO)) -> iv@internal@vector:vector(node_(GAO)).
concat_result_to_vector(Result) ->
    case Result of
        {one_node, Node} ->
            iv_ffi:singleton(Node);

        {two_nodes, Full, Partial} ->
            iv_ffi:pair(Full, Partial)
    end.

-file("src/iv/internal/node.gleam", 461).
?DOC(false).
-spec concat_result_node_count(concat_result(any())) -> integer().
concat_result_node_count(Result) ->
    case Result of
        {one_node, _} ->
            1;

        {two_nodes, _, _} ->
            2
    end.

-file("src/iv/internal/node.gleam", 567).
?DOC(false).
-spec sum_children_counts(integer(), node_(any())) -> integer().
sum_children_counts(Count, Node) ->
    case Node of
        {balanced, _, Children} ->
            Count + erlang:tuple_size(Children);

        {leaf, Children@1} ->
            Count + erlang:tuple_size(Children@1);

        {unbalanced, _, Children@2} ->
            Count + erlang:tuple_size(Children@2)
    end.

-file("src/iv/internal/node.gleam", 453).
?DOC(false).
-spec concat_result_children_count(concat_result(any())) -> integer().
concat_result_children_count(Result) ->
    case Result of
        {one_node, Node} ->
            sum_children_counts(0, Node);

        {two_nodes, Full, Partial} ->
            sum_children_counts(sum_children_counts(0, Full), Partial)
    end.

-file("src/iv/internal/node.gleam", 585).
?DOC(false).
-spec extract_children(node_(GJN)) -> iv@internal@vector:vector(node_(GJN)).
extract_children(Node) ->
    case Node of
        {balanced, _, Children} ->
            Children;

        {unbalanced, _, Children} ->
            Children;

        {leaf, _} ->
            erlang:error(#{gleam_error => panic,
                    message => <<"`panic` expression evaluated."/utf8>>,
                    file => <<?FILEPATH/utf8>>,
                    module => <<"iv/internal/node"/utf8>>,
                    function => <<"extract_children"/utf8>>,
                    line => 595})
    end.

-file("src/iv/internal/node.gleam", 599).
?DOC(false).
-spec extract_items(node_(GJP)) -> iv@internal@vector:vector(GJP).
extract_items(Node) ->
    Children@1 = case Node of
        {leaf, Children} -> Children;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"iv/internal/node"/utf8>>,
                        function => <<"extract_items"/utf8>>,
                        line => 600,
                        value => _assert_fail,
                        start => 19565,
                        'end' => 19597,
                        pattern_start => 19576,
                        pattern_end => 19590})
    end,
    Children@1.

-file("src/iv/internal/node.gleam", 686).
?DOC(false).
-spec rebalance_skip_subtree(
    rebalance_state(GCD, GCE),
    iv@internal@vector:vector(GCE)
) -> rebalance_state(GCD, GCE).
rebalance_skip_subtree(State, Children) ->
    {rebalance_state,
        erlang:element(2, State) - 1,
        erlang:element(3, State),
        [Children | erlang:element(4, State)],
        erlang:tuple_size(Children) + erlang:element(5, State)}.

-file("src/iv/internal/node.gleam", 698).
?DOC(false).
-spec rebalance_push_subtree(
    rebalance_state(GCJ, any()),
    node_(GCJ),
    list(iv@internal@vector:vector(GKF)),
    integer()
) -> rebalance_state(GCJ, GKF).
rebalance_push_subtree(State, Subtree, Overflow, Overflow_length) ->
    {rebalance_state,
        erlang:element(2, State),
        erlang:append_element(erlang:element(3, State), Subtree),
        Overflow,
        Overflow_length}.

-file("src/iv/internal/node.gleam", 1108).
?DOC(false).
-spec map(node_(GEF), fun((GEF) -> GEH)) -> node_(GEH).
map(Node, Fun) ->
    case Node of
        {balanced, Size, Children} ->
            {balanced,
                Size,
                iv_ffi:map(Children, fun(_capture) -> map(_capture, Fun) end)};

        {unbalanced, Sizes, Children@1} ->
            {unbalanced,
                Sizes,
                iv_ffi:map(
                    Children@1,
                    fun(_capture@1) -> map(_capture@1, Fun) end
                )};

        {leaf, Children@2} ->
            {leaf, iv_ffi:map(Children@2, Fun)}
    end.

-file("src/iv/internal/node.gleam", 1157).
?DOC(false).
-spec try_map(node_(GMH), fun((GMH) -> {ok, GMK} | {error, GMR})) -> {ok,
        node_(GMK)} |
    {error, GMR}.
try_map(Node, Fun) ->
    case Node of
        {balanced, Size, Children} ->
            case iv@internal@vector:try_map(
                Children,
                fun(_capture) -> try_map(_capture, Fun) end
            ) of
                {ok, Children@1} ->
                    {ok, {balanced, Size, Children@1}};

                {error, Error} ->
                    {error, Error}
            end;

        {unbalanced, Sizes, Children@2} ->
            case iv@internal@vector:try_map(
                Children@2,
                fun(_capture@1) -> try_map(_capture@1, Fun) end
            ) of
                {ok, Children@3} ->
                    {ok, {unbalanced, Sizes, Children@3}};

                {error, Error@1} ->
                    {error, Error@1}
            end;

        {leaf, Children@4} ->
            case iv@internal@vector:try_map(Children@4, Fun) of
                {ok, Children@5} ->
                    {ok, {leaf, Children@5}};

                {error, Error@2} ->
                    {error, Error@2}
            end
    end.

-file("src/iv/internal/node.gleam", 1179).
?DOC(false).
-spec fold(node_(GER), GET, fun((GET, GER) -> GET)) -> GET.
fold(Node, State, Fun) ->
    case Node of
        {balanced, _, Children} ->
            iv_ffi:fold(
                Children,
                State,
                fun(State@1, Node@1) -> fold(Node@1, State@1, Fun) end
            );

        {unbalanced, _, Children} ->
            iv_ffi:fold(
                Children,
                State,
                fun(State@1, Node@1) -> fold(Node@1, State@1, Fun) end
            );

        {leaf, Children@1} ->
            iv_ffi:fold(Children@1, State, Fun)
    end.

-file("src/iv/internal/node.gleam", 1221).
?DOC(false).
-spec fold_right(node_(GEX), GFB, fun((GFB, GEX) -> GFB)) -> GFB.
fold_right(Node, State, Fun) ->
    case Node of
        {balanced, _, Children} ->
            iv@internal@vector:fold_right(
                Children,
                State,
                fun(State@1, Node@1) -> fold_right(Node@1, State@1, Fun) end
            );

        {unbalanced, _, Children} ->
            iv@internal@vector:fold_right(
                Children,
                State,
                fun(State@1, Node@1) -> fold_right(Node@1, State@1, Fun) end
            );

        {leaf, Children@1} ->
            iv@internal@vector:fold_right(Children@1, State, Fun)
    end.

-file("src/iv/internal/node.gleam", 1275).
?DOC(false).
-spec do_try_fold(
    node_(GFN),
    GFP,
    fun(({ok, GFP} | {error, GFQ}, GFN) -> {ok, GFP} | {error, GFQ})
) -> {ok, GFP} | {error, GFQ}.
do_try_fold(Node, State, Fun) ->
    case Node of
        {balanced, _, Children} ->
            iv@internal@vector:try_fold(
                Children,
                State,
                fun(State@1, Child) -> do_try_fold(Child, State@1, Fun) end
            );

        {unbalanced, _, Children} ->
            iv@internal@vector:try_fold(
                Children,
                State,
                fun(State@1, Child) -> do_try_fold(Child, State@1, Fun) end
            );

        {leaf, Children@1} ->
            iv_ffi:fold(Children@1, {ok, State}, Fun)
    end.

-file("src/iv/internal/node.gleam", 1263).
?DOC(false).
-spec try_fold(node_(GFF), GFH, fun((GFH, GFF) -> {ok, GFH} | {error, GFI})) -> {ok,
        GFH} |
    {error, GFI}.
try_fold(Node, State, Fun) ->
    do_try_fold(Node, State, fun(State@1, Item) -> case State@1 of
                {ok, State@2} ->
                    Fun(State@2, Item);

                {error, _} = Result ->
                    Result
            end end).

-file("src/iv/internal/node.gleam", 39).
?DOC(false).
-spec balanced(integer(), iv@internal@vector:vector(node_(FXQ))) -> node_(FXQ).
balanced(Shift, Nodes) ->
    Len = erlang:tuple_size(Nodes),
    Last_child = erlang:element(Len, Nodes),
    Max_size = erlang:'bsl'(1, Shift),
    Size = (Max_size * (Len - 1)) + size(Last_child),
    {balanced, Size, Nodes}.

-file("src/iv/internal/node.gleam", 48).
?DOC(false).
-spec unbalanced(
    integer(),
    iv@internal@vector:vector(node_(FXU)),
    iv@internal@vector:vector(integer())
) -> node_(FXU).
unbalanced(Shift, Children, Sizes) ->
    case erlang:tuple_size(Children) of
        1 ->
            balanced(Shift, Children);

        _ ->
            {unbalanced, Sizes, Children}
    end.

-file("src/iv/internal/node.gleam", 59).
?DOC(false).
-spec branch(integer(), iv@internal@vector:vector(node_(FXZ))) -> node_(FXZ).
branch(Shift, Nodes) ->
    Len = erlang:tuple_size(Nodes),
    Max_size = erlang:'bsl'(1, Shift),
    Sizes = iv_ffi:compute_sizes(Nodes),
    Prefix_size = case Len of
        1 ->
            0;

        _ ->
            erlang:element(Len - 1, Sizes)
    end,
    Is_balanced = Prefix_size =:= (Max_size * (Len - 1)),
    case Is_balanced of
        true ->
            Size = erlang:element(Len, Sizes),
            {balanced, Size, Nodes};

        false ->
            {unbalanced, Sizes, Nodes}
    end.

-file("src/iv/internal/node.gleam", 111).
?DOC(false).
-spec get(node_(FYL), integer(), integer()) -> FYL.
get(Node, Shift, Index) ->
    case Node of
        {balanced, _, Children} ->
            Node_index = erlang:'bsr'(Index, Shift),
            Index@1 = Index - erlang:'bsl'(Node_index, Shift),
            Child = erlang:element(Node_index + 1, Children),
            get(Child, Shift - 4, Index@1);

        {unbalanced, Sizes, Children@1} ->
            Start_search_index = erlang:'bsr'(Index, Shift),
            Node_index@1 = find_size(Sizes, Start_search_index + 1, Index),
            Index@2 = case Node_index@1 of
                0 ->
                    Index;

                _ ->
                    Index - erlang:element(Node_index@1, Sizes)
            end,
            Child@1 = erlang:element(Node_index@1 + 1, Children@1),
            get(Child@1, Shift - 4, Index@2);

        {leaf, Children@2} ->
            erlang:element(Index + 1, Children@2)
    end.

-file("src/iv/internal/node.gleam", 158).
?DOC(false).
-spec find_index(integer(), integer(), node_(GQC), fun((GQC) -> boolean())) -> {ok,
        integer()} |
    {error, nil}.
find_index(Shift, Offset, Node, Fun) ->
    Child_shift = Shift - 4,
    case Node of
        {leaf, Children} ->
            iv@internal@vector:find_index(
                Children,
                fun(Item, Index) -> case Fun(Item) of
                        true ->
                            {ok, (Offset + Index) - 1};

                        false ->
                            {error, nil}
                    end end
            );

        {balanced, _, Children@1} ->
            Child_size = erlang:'bsl'(1, Shift),
            iv@internal@vector:find_index(
                Children@1,
                fun(Child, Index@1) ->
                    Offset@1 = Offset + ((Index@1 - 1) * Child_size),
                    find_index(Child_shift, Offset@1, Child, Fun)
                end
            );

        {unbalanced, Sizes, Children@2} ->
            iv@internal@vector:find_index(
                Children@2,
                fun(Child@1, Index@2) ->
                    Child_offset = case Index@2 of
                        1 ->
                            0;

                        _ ->
                            erlang:element(Index@2 - 1, Sizes)
                    end,
                    find_index(Child_shift, Offset + Child_offset, Child@1, Fun)
                end
            )
    end.

-file("src/iv/internal/node.gleam", 187).
?DOC(false).
-spec find_last_index(integer(), integer(), node_(GRA), fun((GRA) -> boolean())) -> {ok,
        integer()} |
    {error, nil}.
find_last_index(Shift, Offset, Node, Fun) ->
    Child_shift = Shift - 4,
    case Node of
        {leaf, Children} ->
            iv@internal@vector:find_last_index(
                Children,
                fun(Item, Index) -> case Fun(Item) of
                        true ->
                            {ok, (Offset + Index) - 1};

                        false ->
                            {error, nil}
                    end end
            );

        {balanced, _, Children@1} ->
            Child_size = erlang:'bsl'(1, Shift),
            iv@internal@vector:find_last_index(
                Children@1,
                fun(Child, Index@1) ->
                    Offset@1 = Offset + ((Index@1 - 1) * Child_size),
                    find_last_index(Child_shift, Offset@1, Child, Fun)
                end
            );

        {unbalanced, Sizes, Children@2} ->
            iv@internal@vector:find_last_index(
                Children@2,
                fun(Child@1, Index@2) ->
                    Child_offset = case Index@2 of
                        1 ->
                            0;

                        _ ->
                            erlang:element(Index@2 - 1, Sizes)
                    end,
                    find_last_index(
                        Child_shift,
                        Offset + Child_offset,
                        Child@1,
                        Fun
                    )
                end
            )
    end.

-file("src/iv/internal/node.gleam", 218).
?DOC(false).
-spec update(integer(), node_(GRZ), integer(), fun((GRZ) -> GRZ)) -> node_(GRZ).
update(Shift, Node, Index, Fun) ->
    case Node of
        {balanced, Size, Children} ->
            Node_index = erlang:'bsr'(Index, Shift),
            Index@1 = Index - erlang:'bsl'(Node_index, Shift),
            New_children = begin
                _pipe = erlang:element(Node_index + 1, Children),
                _pipe@1 = update(Shift - 4, _pipe, Index@1, Fun),
                erlang:setelement(Node_index + 1, Children, _pipe@1)
            end,
            {balanced, Size, New_children};

        {unbalanced, Sizes, Children@1} ->
            Start_search_index = erlang:'bsr'(Index, Shift),
            Node_index@1 = find_size(Sizes, Start_search_index + 1, Index),
            Index@2 = case Node_index@1 of
                0 ->
                    Index;

                _ ->
                    Index - erlang:element(Node_index@1, Sizes)
            end,
            New_children@1 = begin
                _pipe@2 = erlang:element(Node_index@1 + 1, Children@1),
                _pipe@3 = update(Shift - 4, _pipe@2, Index@2, Fun),
                erlang:setelement(Node_index@1 + 1, Children@1, _pipe@3)
            end,
            {unbalanced, Sizes, New_children@1};

        {leaf, Children@2} ->
            New_children@2 = erlang:setelement(
                Index + 1,
                Children@2,
                Fun(erlang:element(Index + 1, Children@2))
            ),
            {leaf, New_children@2}
    end.

-file("src/iv/internal/node.gleam", 956).
?DOC(false).
-spec split(integer(), node_(GEC), integer()) -> split_result(GEC).
split(Shift, Node, Index) ->
    Child_shift = Shift - 4,
    case Node of
        {balanced, _, Children} ->
            Node_index = erlang:'bsr'(Index, Shift),
            Index@1 = Index - erlang:'bsl'(Node_index, Shift),
            Child = erlang:element(Node_index + 1, Children),
            case split(Child_shift, Child, Index@1) of
                empty_prefix when Node_index =:= 0 ->
                    empty_prefix;

                empty_prefix ->
                    {Before_children, After_children} = iv_ffi:split1(
                        Node_index + 1,
                        Children
                    ),
                    Prefix = balanced(Shift, Before_children),
                    After_children_len = erlang:tuple_size(After_children),
                    Suffix = case After_children_len of
                        1 ->
                            erlang:element(1, After_children);

                        _ ->
                            balanced(Shift, After_children)
                    end,
                    Suffix_shift = case After_children_len of
                        1 ->
                            Child_shift;

                        _ ->
                            Shift
                    end,
                    {split, Prefix, Shift, Suffix, Suffix_shift};

                {split, Prefix@1, Prefix_shift, Suffix@1, Suffix_shift@1} ->
                    {Before_children@1, After_children@1} = iv_ffi:split1(
                        Node_index + 1,
                        Children
                    ),
                    Before_children_len = erlang:tuple_size(Before_children@1),
                    Prefix@2 = case Before_children_len of
                        0 ->
                            Prefix@1;

                        _ ->
                            balanced(
                                Shift,
                                erlang:append_element(
                                    Before_children@1,
                                    Prefix@1
                                )
                            )
                    end,
                    Prefix_shift@1 = case Before_children_len of
                        0 ->
                            Prefix_shift;

                        _ ->
                            Shift
                    end,
                    After_children_len@1 = erlang:tuple_size(After_children@1),
                    Suffix@2 = case After_children_len@1 of
                        1 ->
                            Suffix@1;

                        _ ->
                            branch(
                                Shift,
                                erlang:setelement(1, After_children@1, Suffix@1)
                            )
                    end,
                    Suffix_shift@2 = case After_children_len@1 of
                        1 ->
                            Suffix_shift@1;

                        _ ->
                            Shift
                    end,
                    {split, Prefix@2, Prefix_shift@1, Suffix@2, Suffix_shift@2}
            end;

        {unbalanced, Sizes, Children@1} ->
            Start_search_index = erlang:'bsr'(Index, Shift),
            Node_index@1 = find_size(Sizes, Start_search_index + 1, Index),
            Index@2 = case Node_index@1 of
                0 ->
                    Index;

                _ ->
                    Index - erlang:element(Node_index@1, Sizes)
            end,
            Child@1 = erlang:element(Node_index@1 + 1, Children@1),
            case split(Child_shift, Child@1, Index@2) of
                empty_prefix when Node_index@1 =:= 0 ->
                    empty_prefix;

                empty_prefix ->
                    {Before_children@2, After_children@2} = iv_ffi:split1(
                        Node_index@1 + 1,
                        Children@1
                    ),
                    {Before_sizes, After_sizes} = iv_ffi:split1(
                        Node_index@1 + 1,
                        Sizes
                    ),
                    Before_size = erlang:element(Node_index@1, Before_sizes),
                    After_sizes@1 = iv_ffi:map_add(After_sizes, - Before_size),
                    Prefix@3 = unbalanced(
                        Shift,
                        Before_children@2,
                        Before_sizes
                    ),
                    After_children_len@2 = erlang:tuple_size(After_children@2),
                    Suffix@3 = case After_children_len@2 of
                        1 ->
                            erlang:element(1, After_children@2);

                        _ ->
                            unbalanced(Shift, After_children@2, After_sizes@1)
                    end,
                    Suffix_shift@3 = case After_children_len@2 of
                        1 ->
                            Child_shift;

                        _ ->
                            Shift
                    end,
                    {split, Prefix@3, Shift, Suffix@3, Suffix_shift@3};

                {split, Prefix@4, Prefix_shift@2, Suffix@4, Suffix_shift@4} ->
                    {Before_children@3, After_children@3} = iv_ffi:split1(
                        Node_index@1 + 1,
                        Children@1
                    ),
                    {Before_sizes@1, After_sizes@2} = iv_ffi:split1(
                        Node_index@1 + 1,
                        Sizes
                    ),
                    Before_children_len@1 = erlang:tuple_size(Before_children@3),
                    Prefix@5 = case Before_children_len@1 of
                        0 ->
                            Prefix@4;

                        _ ->
                            Children@2 = erlang:append_element(
                                Before_children@3,
                                Prefix@4
                            ),
                            Before_size@1 = case Node_index@1 of
                                0 ->
                                    0;

                                _ ->
                                    erlang:element(Node_index@1, Before_sizes@1)
                            end,
                            Sizes@1 = erlang:append_element(
                                Before_sizes@1,
                                Before_size@1 + size(Prefix@4)
                            ),
                            unbalanced(Shift, Children@2, Sizes@1)
                    end,
                    Prefix_shift@3 = case Before_children_len@1 of
                        0 ->
                            Prefix_shift@2;

                        _ ->
                            Shift
                    end,
                    After_children_len@3 = erlang:tuple_size(After_children@3),
                    Suffix@5 = case After_children_len@3 of
                        1 ->
                            Suffix@4;

                        _ ->
                            Children@3 = erlang:setelement(
                                1,
                                After_children@3,
                                Suffix@4
                            ),
                            After_delta = size(Suffix@4) - erlang:element(
                                1,
                                After_sizes@2
                            ),
                            Sizes@2 = iv_ffi:map_add(After_sizes@2, After_delta),
                            unbalanced(Shift, Children@3, Sizes@2)
                    end,
                    Suffix_shift@5 = case After_children_len@3 of
                        1 ->
                            Suffix_shift@4;

                        _ ->
                            Shift
                    end,
                    {split, Prefix@5, Prefix_shift@3, Suffix@5, Suffix_shift@5}
            end;

        {leaf, Children@4} ->
            case Index of
                0 ->
                    empty_prefix;

                _ ->
                    {Before, After} = iv_ffi:split1(Index + 1, Children@4),
                    Prefix@6 = {leaf, Before},
                    Suffix@6 = {leaf, After},
                    {split, Prefix@6, 0, Suffix@6, 0}
            end
    end.

-file("src/iv/internal/node.gleam", 1118).
?DOC(false).
-spec index_map(integer(), integer(), node_(GEJ), fun((GEJ, integer()) -> GEL)) -> node_(GEL).
index_map(Shift, Offset, Node, Fun) ->
    Child_shift = Shift - 4,
    case Node of
        {balanced, Size, Children} ->
            Child_size = erlang:'bsl'(1, Shift),
            Children@1 = iv@internal@vector:index_map(
                Children,
                fun(Child, Index) ->
                    Offset@1 = Offset + ((Index - 1) * Child_size),
                    index_map(Child_shift, Offset@1, Child, Fun)
                end
            ),
            {balanced, Size, Children@1};

        {unbalanced, Sizes, Children@2} ->
            Children@3 = iv@internal@vector:index_map(
                Children@2,
                fun(Child@1, Index@1) ->
                    Child_offset = case Index@1 of
                        1 ->
                            0;

                        _ ->
                            erlang:element(Index@1 - 1, Sizes)
                    end,
                    index_map(Child_shift, Offset + Child_offset, Child@1, Fun)
                end
            ),
            {unbalanced, Sizes, Children@3};

        {leaf, Children@4} ->
            Children@5 = iv@internal@vector:index_map(
                Children@4,
                fun(Item, Index@2) -> Fun(Item, (Index@2 + Offset) - 1) end
            ),
            {leaf, Children@5}
    end.

-file("src/iv/internal/node.gleam", 1189).
?DOC(false).
-spec index_fold(
    integer(),
    integer(),
    node_(GEU),
    GEW,
    fun((GEW, GEU, integer()) -> GEW)
) -> GEW.
index_fold(Shift, Offset, Node, State, Fun) ->
    Child_shift = Shift - 4,
    case Node of
        {balanced, _, Children} ->
            Child_size = erlang:'bsl'(1, Shift),
            iv@internal@vector:index_fold(
                Children,
                State,
                fun(State@1, Child, Index) ->
                    Offset@1 = Offset + ((Index - 1) * Child_size),
                    index_fold(Child_shift, Offset@1, Child, State@1, Fun)
                end
            );

        {unbalanced, Sizes, Children@1} ->
            iv@internal@vector:index_fold(
                Children@1,
                State,
                fun(State@2, Child@1, Index@1) ->
                    Child_offset = case Index@1 of
                        1 ->
                            0;

                        _ ->
                            erlang:element(Index@1 - 1, Sizes)
                    end,
                    index_fold(
                        Child_shift,
                        Offset + Child_offset,
                        Child@1,
                        State@2,
                        Fun
                    )
                end
            );

        {leaf, Children@2} ->
            iv@internal@vector:index_fold(
                Children@2,
                State,
                fun(State@3, Item, Index@2) ->
                    Fun(State@3, Item, (Offset + Index@2) - 1)
                end
            )
    end.

-file("src/iv/internal/node.gleam", 1231).
?DOC(false).
-spec index_fold_right(
    integer(),
    integer(),
    node_(GFC),
    GFE,
    fun((GFE, GFC, integer()) -> GFE)
) -> GFE.
index_fold_right(Shift, Offset, Node, State, Fun) ->
    Child_shift = Shift - 4,
    case Node of
        {balanced, _, Children} ->
            Child_size = erlang:'bsl'(1, Shift),
            iv@internal@vector:index_fold_right(
                Children,
                State,
                fun(State@1, Child, Index) ->
                    Offset@1 = Offset + ((Index - 1) * Child_size),
                    index_fold_right(Child_shift, Offset@1, Child, State@1, Fun)
                end
            );

        {unbalanced, Sizes, Children@1} ->
            iv@internal@vector:index_fold_right(
                Children@1,
                State,
                fun(State@2, Child@1, Index@1) ->
                    Child_offset = case Index@1 of
                        1 ->
                            0;

                        _ ->
                            erlang:element(Index@1 - 1, Sizes)
                    end,
                    index_fold_right(
                        Child_shift,
                        Offset + Child_offset,
                        Child@1,
                        State@2,
                        Fun
                    )
                end
            );

        {leaf, Children@2} ->
            iv@internal@vector:index_fold_right(
                Children@2,
                State,
                fun(State@3, Item, Index@2) ->
                    Fun(State@3, Item, (Offset + Index@2) - 1)
                end
            )
    end.

-file("src/iv/internal/node.gleam", 713).
?DOC(false).
-spec rebalance_finalise(
    rebalance_state(GCR, GCS),
    fun((iv@internal@vector:vector(GCS)) -> node_(GCR)),
    integer()
) -> concat_result(GCR).
rebalance_finalise(State, Construct, Shift) ->
    State@1 = case erlang:element(4, State) of
        [] ->
            State;

        Overflow ->
            Node = Construct(iv_ffi:concat_all(Overflow)),
            rebalance_push_subtree(State, Node, [], 0)
    end,
    Subtree_count = erlang:tuple_size(erlang:element(3, State@1)),
    case Subtree_count of
        N when N =< 16 ->
            {one_node, branch(Shift + 4, erlang:element(3, State@1))};

        _ ->
            {First_subtrees, Second_subtrees} = iv_ffi:split1(
                16 + 1,
                erlang:element(3, State@1)
            ),
            First_root = branch(Shift + 4, First_subtrees),
            Second_root = branch(Shift + 4, Second_subtrees),
            {two_nodes, First_root, Second_root}
    end.

-file("src/iv/internal/node.gleam", 642).
?DOC(false).
-spec rebalance_push(
    rebalance_state(GBS, GBT),
    node_(GBS),
    fun((node_(GBS)) -> iv@internal@vector:vector(GBT)),
    fun((iv@internal@vector:vector(GBT)) -> node_(GBS))
) -> rebalance_state(GBS, GBT).
rebalance_push(State, Subtree, Extract, Construct) ->
    Subtree_len = length(Subtree),
    Total_len = erlang:element(5, State) + Subtree_len,
    case Total_len =< 16 of
        true ->
            case (erlang:element(2, State) =< 0) orelse (Total_len >= (16 - (2
            div 2))) of
                true ->
                    Subtree@1 = case erlang:element(4, State) of
                        [] ->
                            Subtree;

                        Overflow ->
                            Construct(
                                iv_ffi:concat_all([Extract(Subtree) | Overflow])
                            )
                    end,
                    rebalance_push_subtree(State, Subtree@1, [], 0);

                false ->
                    rebalance_skip_subtree(State, Extract(Subtree))
            end;

        false ->
            To_move_len = 16 - erlang:element(5, State),
            {To_move, Overflow@1} = iv_ffi:split1(
                To_move_len + 1,
                Extract(Subtree)
            ),
            Overflow_len = erlang:tuple_size(Overflow@1),
            Subtree@2 = Construct(
                iv_ffi:concat_all([To_move | erlang:element(4, State)])
            ),
            rebalance_push_subtree(State, Subtree@2, [Overflow@1], Overflow_len)
    end.

-file("src/iv/internal/node.gleam", 604).
?DOC(false).
-spec do_rebalance(
    integer(),
    rebalance_params(HAD),
    fun((node_(HAD)) -> iv@internal@vector:vector(GZP)),
    fun((iv@internal@vector:vector(GZP)) -> node_(HAD)),
    integer()
) -> concat_result(HAD).
do_rebalance(Shift, Params, Extract, Construct, Balance) ->
    State = {rebalance_state, Balance, iv_ffi:empty(), [], 0},
    Push = fun(State@1, Node) ->
        rebalance_push(State@1, Node, Extract, Construct)
    end,
    State@6 = case Params of
        {from_left, Left, Merged} ->
            State@2 = iv_ffi:fold_skip_last(Left, State, Push),
            Merged_vec = concat_result_to_vector(Merged),
            iv_ffi:fold(Merged_vec, State@2, Push);

        {from_right, Merged@1, Right} ->
            Merged_vec@1 = concat_result_to_vector(Merged@1),
            State@3 = iv_ffi:fold(Merged_vec@1, State, Push),
            iv_ffi:fold_skip_first(Right, State@3, Push);

        {rebalance_merge, Left@1, Merged@2, Right@1} ->
            State@4 = iv_ffi:fold_skip_last(Left@1, State, Push),
            Merged_vec@2 = concat_result_to_vector(Merged@2),
            State@5 = iv_ffi:fold(Merged_vec@2, State@4, Push),
            iv_ffi:fold_skip_first(Right@1, State@5, Push)
    end,
    rebalance_finalise(State@6, Construct, Shift).

-file("src/iv/internal/node.gleam", 468).
?DOC(false).
-spec rebalance(integer(), rebalance_params(GAW)) -> concat_result(GAW).
rebalance(Shift, Params) ->
    S = case Params of
        {from_left, Left, Merged} ->
            iv_ffi:sum_node_children_counts_skip_last(Left) + concat_result_children_count(
                Merged
            );

        {from_right, Merged@1, Right} ->
            concat_result_children_count(Merged@1) + iv_ffi:sum_node_children_counts_skip_first(
                Right
            );

        {rebalance_merge, Left@1, Merged@2, Right@1} ->
            (iv_ffi:sum_node_children_counts_skip_last(Left@1) + concat_result_children_count(
                Merged@2
            ))
            + iv_ffi:sum_node_children_counts_skip_first(Right@1)
    end,
    N = case Params of
        {from_left, Left@2, Merged@3} ->
            (erlang:tuple_size(Left@2) + concat_result_node_count(Merged@3)) - 1;

        {from_right, Merged@4, Right@2} ->
            (concat_result_node_count(Merged@4) + erlang:tuple_size(Right@2)) - 1;

        {rebalance_merge, Left@3, Merged@5, Right@3} ->
            (((erlang:tuple_size(Left@3) - 1) + concat_result_node_count(
                Merged@5
            ))
            + erlang:tuple_size(Right@3))
            - 1
    end,
    N_opt = erlang:'bsr'((S + 16) - 1, 4),
    Balance = (N - N_opt) - 2,
    case (Balance =< 0) andalso (N =< 16) of
        true ->
            Combined = case Params of
                {from_left, Left@4, Merged@6} ->
                    Merged@7 = concat_result_to_vector(Merged@6),
                    case erlang:tuple_size(Left@4) of
                        1 ->
                            Merged@7;

                        _ ->
                            iv@internal@vector:concat(
                                iv_ffi:drop_last(Left@4),
                                Merged@7
                            )
                    end;

                {from_right, Merged@8, Right@4} ->
                    Merged@9 = concat_result_to_vector(Merged@8),
                    case erlang:tuple_size(Right@4) of
                        1 ->
                            Merged@9;

                        _ ->
                            iv@internal@vector:concat(
                                Merged@9,
                                iv_ffi:drop_first(Right@4)
                            )
                    end;

                {rebalance_merge, Left@5, Merged@10, Right@5} ->
                    Merged@11 = concat_result_to_vector(Merged@10),
                    Left_len = erlang:tuple_size(Left@5),
                    Right_len = erlang:tuple_size(Right@5),
                    case {Left_len, Right_len} of
                        {1, 1} ->
                            Merged@11;

                        {1, _} ->
                            iv@internal@vector:concat(
                                Merged@11,
                                iv_ffi:drop_first(Right@5)
                            );

                        {_, 1} ->
                            iv@internal@vector:concat(
                                iv_ffi:drop_last(Left@5),
                                Merged@11
                            );

                        {_, _} ->
                            Left_prefix = iv_ffi:drop_last(Left@5),
                            Right_suffix = iv_ffi:drop_first(Right@5),
                            iv_ffi:concat_all(
                                [Right_suffix, Merged@11, Left_prefix]
                            )
                    end
            end,
            {one_node, branch(Shift, Combined)};

        false ->
            Shift@1 = Shift - 4,
            Result = case Shift@1 > 0 of
                true ->
                    Construct = fun(Children) -> branch(Shift@1, Children) end,
                    do_rebalance(
                        Shift@1,
                        Params,
                        fun extract_children/1,
                        Construct,
                        Balance
                    );

                false ->
                    do_rebalance(
                        Shift@1,
                        Params,
                        fun extract_items/1,
                        fun(Field@0) -> {leaf, Field@0} end,
                        Balance
                    )
            end,
            Result
    end.

-file("src/iv/internal/node.gleam", 825).
?DOC(false).
-spec direct_append_balanced(
    integer(),
    node_(GDC),
    iv@internal@vector:vector(node_(GDC)),
    integer(),
    node_(GDC)
) -> direct_concat_result(GDC).
direct_append_balanced(Left_shift, Left, Left_children, Right_shift, Right) ->
    Left_len = erlang:tuple_size(Left_children),
    Left_last = erlang:element(Left_len, Left_children),
    case direct_concat(Left_shift - 4, Left_last, Right_shift, Right) of
        {concatenated, Updated} ->
            Children = erlang:setelement(Left_len, Left_children, Updated),
            {concatenated, balanced(Left_shift, Children)};

        {no_free_slot, _, Node} when Left_len < 16 ->
            Children@1 = erlang:append_element(Left_children, Node),
            case size(Left_last) =:= erlang:'bsl'(1, Left_shift) of
                true ->
                    {concatenated, balanced(Left_shift, Children@1)};

                false ->
                    {concatenated, branch(Left_shift, Children@1)}
            end;

        {no_free_slot, _, Node@1} ->
            {no_free_slot, Left, balanced(Left_shift, iv_ffi:singleton(Node@1))}
    end.

-file("src/iv/internal/node.gleam", 759).
?DOC(false).
-spec direct_concat(integer(), node_(GCY), integer(), node_(GCY)) -> direct_concat_result(GCY).
direct_concat(Left_shift, Left, Right_shift, Right) ->
    case {Left, Right} of
        {{balanced, _, Cl}, {leaf, _}} ->
            direct_append_balanced(Left_shift, Left, Cl, Right_shift, Right);

        {{unbalanced, Sizes, Cl@1}, {leaf, _}} ->
            direct_append_unbalanced(
                Left_shift,
                Left,
                Cl@1,
                Sizes,
                Right_shift,
                Right
            );

        {{leaf, _}, {balanced, _, Cr}} ->
            direct_prepend_balanced(Left_shift, Left, Right_shift, Right, Cr);

        {{leaf, _}, {unbalanced, Sr, Cr@1}} ->
            direct_prepend_unbalanced(
                Left_shift,
                Left,
                Right_shift,
                Right,
                Cr@1,
                Sr
            );

        {{leaf, Cl@2}, {leaf, Cr@2}} ->
            case (erlang:tuple_size(Cl@2) + erlang:tuple_size(Cr@2)) =< 16 of
                true ->
                    {concatenated,
                        {leaf, iv@internal@vector:concat(Cl@2, Cr@2)}};

                false ->
                    {no_free_slot, Left, Right}
            end;

        {{balanced, _, Cl@3}, _} when Left_shift > Right_shift ->
            direct_append_balanced(Left_shift, Left, Cl@3, Right_shift, Right);

        {{unbalanced, Sizes@1, Cl@4}, _} when Left_shift > Right_shift ->
            direct_append_unbalanced(
                Left_shift,
                Left,
                Cl@4,
                Sizes@1,
                Right_shift,
                Right
            );

        {_, {balanced, _, Cr@3}} when Right_shift > Left_shift ->
            direct_prepend_balanced(Left_shift, Left, Right_shift, Right, Cr@3);

        {_, {unbalanced, Sr@1, Cr@4}} when Right_shift > Left_shift ->
            direct_prepend_unbalanced(
                Left_shift,
                Left,
                Right_shift,
                Right,
                Cr@4,
                Sr@1
            );

        {{balanced, _, Cl@5}, {balanced, _, Cr@5}} ->
            case (erlang:tuple_size(Cl@5) + erlang:tuple_size(Cr@5)) =< 16 of
                true ->
                    Merged = iv@internal@vector:concat(Cl@5, Cr@5),
                    Left_last = erlang:element(erlang:tuple_size(Cl@5), Cl@5),
                    case size(Left_last) =:= erlang:'bsl'(1, Left_shift) of
                        true ->
                            {concatenated, balanced(Left_shift, Merged)};

                        false ->
                            {concatenated, branch(Left_shift, Merged)}
                    end;

                false ->
                    {no_free_slot, Left, Right}
            end;

        {{balanced, _, Cl@6}, {unbalanced, _, Cr@6}} ->
            case (erlang:tuple_size(Cl@6) + erlang:tuple_size(Cr@6)) =< 16 of
                true ->
                    {concatenated,
                        branch(
                            Left_shift,
                            iv@internal@vector:concat(Cl@6, Cr@6)
                        )};

                false ->
                    {no_free_slot, Left, Right}
            end;

        {{unbalanced, _, Cl@6}, {balanced, _, Cr@6}} ->
            case (erlang:tuple_size(Cl@6) + erlang:tuple_size(Cr@6)) =< 16 of
                true ->
                    {concatenated,
                        branch(
                            Left_shift,
                            iv@internal@vector:concat(Cl@6, Cr@6)
                        )};

                false ->
                    {no_free_slot, Left, Right}
            end;

        {{unbalanced, _, Cl@6}, {unbalanced, _, Cr@6}} ->
            case (erlang:tuple_size(Cl@6) + erlang:tuple_size(Cr@6)) =< 16 of
                true ->
                    {concatenated,
                        branch(
                            Left_shift,
                            iv@internal@vector:concat(Cl@6, Cr@6)
                        )};

                false ->
                    {no_free_slot, Left, Right}
            end
    end.

-file("src/iv/internal/node.gleam", 859).
?DOC(false).
-spec direct_append_unbalanced(
    integer(),
    node_(GDI),
    iv@internal@vector:vector(node_(GDI)),
    iv@internal@vector:vector(integer()),
    integer(),
    node_(GDI)
) -> direct_concat_result(GDI).
direct_append_unbalanced(
    Left_shift,
    Left,
    Left_children,
    Sizes,
    Right_shift,
    Right
) ->
    Left_len = erlang:tuple_size(Left_children),
    Left_last = erlang:element(Left_len, Left_children),
    case direct_concat(Left_shift - 4, Left_last, Right_shift, Right) of
        {concatenated, Updated} ->
            Children = erlang:setelement(Left_len, Left_children, Updated),
            Last_size = erlang:element(Left_len, Sizes) + size(Updated),
            Sizes@1 = erlang:setelement(Left_len, Sizes, Last_size),
            {concatenated, {unbalanced, Sizes@1, Children}};

        {no_free_slot, _, Node} when Left_len < 16 ->
            Children@1 = erlang:append_element(Left_children, Node),
            Sizes@2 = erlang:append_element(
                Sizes,
                erlang:element(Left_len, Sizes) + size(Node)
            ),
            {concatenated, {unbalanced, Sizes@2, Children@1}};

        {no_free_slot, _, Node@1} ->
            {no_free_slot, Left, balanced(Left_shift, iv_ffi:singleton(Node@1))}
    end.

-file("src/iv/internal/node.gleam", 888).
?DOC(false).
-spec direct_prepend_balanced(
    integer(),
    node_(GDP),
    integer(),
    node_(GDP),
    iv@internal@vector:vector(node_(GDP))
) -> direct_concat_result(GDP).
direct_prepend_balanced(Left_shift, Left, Right_shift, Right, Right_children) ->
    Right_len = erlang:tuple_size(Right_children),
    Right_first = erlang:element(1, Right_children),
    case direct_concat(Left_shift, Left, Right_shift - 4, Right_first) of
        {concatenated, Updated} ->
            Children = erlang:setelement(1, Right_children, Updated),
            {concatenated, branch(Right_shift, Children)};

        {no_free_slot, Node, _} when Right_len < 16 ->
            Children@1 = iv_ffi:prepend(Right_children, Node),
            {concatenated, branch(Right_shift, Children@1)};

        {no_free_slot, Node@1, _} ->
            {no_free_slot,
                balanced(Right_shift, iv_ffi:singleton(Node@1)),
                Right}
    end.

-file("src/iv/internal/node.gleam", 912).
?DOC(false).
-spec direct_prepend_unbalanced(
    integer(),
    node_(GDV),
    integer(),
    node_(GDV),
    iv@internal@vector:vector(node_(GDV)),
    iv@internal@vector:vector(integer())
) -> direct_concat_result(GDV).
direct_prepend_unbalanced(
    Left_shift,
    Left,
    Right_shift,
    Right,
    Right_children,
    Sizes
) ->
    Right_len = erlang:tuple_size(Right_children),
    Right_first = erlang:element(1, Right_children),
    case direct_concat(Left_shift, Left, Right_shift - 4, Right_first) of
        {concatenated, Updated} ->
            Children = erlang:setelement(1, Right_children, Updated),
            Size_delta = size(Updated) - size(Right_first),
            Sizes@1 = iv_ffi:map_add(Sizes, Size_delta),
            {concatenated, {unbalanced, Sizes@1, Children}};

        {no_free_slot, Node, _} when Right_len < 16 ->
            Children@1 = iv_ffi:prepend(Right_children, Node),
            Node_size = size(Node),
            Sizes@2 = begin
                _pipe = Sizes,
                _pipe@1 = iv_ffi:map_add(_pipe, Node_size),
                iv_ffi:prepend(_pipe@1, Node_size)
            end,
            {concatenated, {unbalanced, Sizes@2, Children@1}};

        {no_free_slot, Node@1, _} ->
            {no_free_slot,
                balanced(Right_shift, iv_ffi:singleton(Node@1)),
                Right}
    end.

-file("src/iv/internal/node.gleam", 318).
?DOC(false).
-spec concat_children(
    integer(),
    iv@internal@vector:vector(node_(FZI)),
    integer(),
    iv@internal@vector:vector(node_(FZI))
) -> concat_result(FZI).
concat_children(Left_shift, Left, Right_shift, Right) ->
    Left_down = Left_shift - 4,
    Left_len = erlang:tuple_size(Left),
    Left_init = erlang:element(Left_len, Left),
    Right_down = Right_shift - 4,
    Right_head = erlang:element(1, Right),
    Merged = concat(Left_init, Left_down, Right_head, Right_down),
    rebalance(Left_shift, {rebalance_merge, Left, Merged, Right}).

-file("src/iv/internal/node.gleam", 268).
?DOC(false).
-spec concat(node_(FZI), integer(), node_(FZI), integer()) -> concat_result(FZI).
concat(Left, Left_shift, Right, Right_shift) ->
    case {Left, Right} of
        {{balanced, Size, Cl}, _} when Left_shift > Right_shift ->
            concat_left_balanced(Left_shift, Cl, Size, Right_shift, Right);

        {{unbalanced, Sizes, Cl@1}, _} when Left_shift > Right_shift ->
            concat_left_unbalanced(Left_shift, Cl@1, Sizes, Right_shift, Right);

        {_, {balanced, _, Cr}} when Right_shift > Left_shift ->
            concat_right_balanced(Left_shift, Left, Right_shift, Cr);

        {_, {unbalanced, Sizes@1, Cr@1}} when Right_shift > Left_shift ->
            concat_right_unbalanced(
                Left_shift,
                Left,
                Right_shift,
                Cr@1,
                Sizes@1
            );

        {{balanced, Size@1, Cl@2}, {leaf, _}} ->
            concat_left_balanced(Left_shift, Cl@2, Size@1, Right_shift, Right);

        {{unbalanced, Sizes@2, Cl@3}, {leaf, _}} ->
            concat_left_unbalanced(
                Left_shift,
                Cl@3,
                Sizes@2,
                Right_shift,
                Right
            );

        {{leaf, _}, {balanced, _, Cr@2}} ->
            concat_right_balanced(Left_shift, Left, Right_shift, Cr@2);

        {{leaf, _}, {unbalanced, Sizes@3, Cr@3}} ->
            concat_right_unbalanced(
                Left_shift,
                Left,
                Right_shift,
                Cr@3,
                Sizes@3
            );

        {{balanced, _, Cl@4}, {balanced, _, Cr@4}} ->
            concat_children(Left_shift, Cl@4, Right_shift, Cr@4);

        {{balanced, _, Cl@4}, {unbalanced, _, Cr@4}} ->
            concat_children(Left_shift, Cl@4, Right_shift, Cr@4);

        {{unbalanced, _, Cl@4}, {balanced, _, Cr@4}} ->
            concat_children(Left_shift, Cl@4, Right_shift, Cr@4);

        {{unbalanced, _, Cl@4}, {unbalanced, _, Cr@4}} ->
            concat_children(Left_shift, Cl@4, Right_shift, Cr@4);

        {{leaf, Cl@5}, {leaf, Cr@5}} ->
            case (erlang:tuple_size(Cl@5) + erlang:tuple_size(Cr@5)) =< 16 of
                true ->
                    {one_node, {leaf, iv@internal@vector:concat(Cl@5, Cr@5)}};

                false ->
                    {two_nodes, Left, Right}
            end
    end.

-file("src/iv/internal/node.gleam", 330).
?DOC(false).
-spec concat_left_balanced(
    integer(),
    iv@internal@vector:vector(node_(FZI)),
    integer(),
    integer(),
    node_(FZI)
) -> concat_result(FZI).
concat_left_balanced(Left_shift, Left_children, Left_size, Right_shift, Right) ->
    Down_shift = Left_shift - 4,
    Left_len = erlang:tuple_size(Left_children),
    Left_last = erlang:element(Left_len, Left_children),
    Merged = concat(Left_last, Down_shift, Right, Right_shift),
    case Merged of
        {one_node, Node} ->
            Children = erlang:setelement(Left_len, Left_children, Node),
            New_size = (Left_size - size(Left_last)) + size(Node),
            {one_node, {balanced, New_size, Children}};

        _ ->
            rebalance(Left_shift, {from_left, Left_children, Merged})
    end.

-file("src/iv/internal/node.gleam", 355).
?DOC(false).
-spec concat_left_unbalanced(
    integer(),
    iv@internal@vector:vector(node_(FZI)),
    iv@internal@vector:vector(integer()),
    integer(),
    node_(FZI)
) -> concat_result(FZI).
concat_left_unbalanced(
    Left_shift,
    Left_children,
    Left_sizes,
    Right_shift,
    Right
) ->
    Down_shift = Left_shift - 4,
    Left_len = erlang:tuple_size(Left_children),
    Left_last = erlang:element(Left_len, Left_children),
    Prefix_size = case Left_len of
        1 ->
            0;

        _ ->
            erlang:element(Left_len - 1, Left_sizes)
    end,
    Merged = concat(Left_last, Down_shift, Right, Right_shift),
    case Merged of
        {one_node, Node} ->
            Children = erlang:setelement(Left_len, Left_children, Node),
            Sizes = erlang:setelement(
                Left_len,
                Left_sizes,
                Prefix_size + size(Node)
            ),
            {one_node, unbalanced(Left_shift, Children, Sizes)};

        _ ->
            rebalance(Left_shift, {from_left, Left_children, Merged})
    end.

-file("src/iv/internal/node.gleam", 383).
?DOC(false).
-spec concat_right_balanced(
    integer(),
    node_(FZI),
    integer(),
    iv@internal@vector:vector(node_(FZI))
) -> concat_result(FZI).
concat_right_balanced(Left_shift, Left, Right_shift, Right_children) ->
    Down_shift = Right_shift - 4,
    Right_head = erlang:element(1, Right_children),
    Merged = concat(Left, Left_shift, Right_head, Down_shift),
    case Merged of
        {one_node, Node} ->
            Children = erlang:setelement(1, Right_children, Node),
            {one_node, branch(Right_shift, Children)};

        _ ->
            rebalance(Right_shift, {from_right, Merged, Right_children})
    end.

-file("src/iv/internal/node.gleam", 399).
?DOC(false).
-spec concat_right_unbalanced(
    integer(),
    node_(FZI),
    integer(),
    iv@internal@vector:vector(node_(FZI)),
    iv@internal@vector:vector(integer())
) -> concat_result(FZI).
concat_right_unbalanced(
    Left_shift,
    Left,
    Right_shift,
    Right_children,
    Right_sizes
) ->
    Down_shift = Right_shift - 4,
    Right_head = erlang:element(1, Right_children),
    Merged = concat(Left, Left_shift, Right_head, Down_shift),
    case Merged of
        {one_node, Node} ->
            Children = erlang:setelement(1, Right_children, Node),
            Size_delta = size(Node) - size(Right_head),
            Sizes = iv_ffi:map_add(Right_sizes, Size_delta),
            {one_node, unbalanced(Right_shift, Children, Sizes)};

        _ ->
            rebalance(Right_shift, {from_right, Merged, Right_children})
    end.
