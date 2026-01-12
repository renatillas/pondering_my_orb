-module(iv@internal@vector).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/iv/internal/vector.gleam").
-export([new/0, singleton/1, pair/2, append/2, prepend/2, drop_first/1, drop_last/1, concat_all/1, set/3, length/1, get/2, split/2, map/2, map_add/2, fold/3, concat/2, fold_skip_last/3, fold_skip_first/3, fold_right/3, index_fold_right/3, index_fold/3, index_map/2, try_fold/3, try_map/2, find_map/2, find_index/2, find_last_index/2]).
-export_type([vector/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-type vector(FMY) :: any() | {gleam_phantom, FMY}.

-file("src/iv/internal/vector.gleam", 11).
?DOC(false).
-spec new() -> vector(any()).
new() ->
    iv_ffi:empty().

-file("src/iv/internal/vector.gleam", 15).
?DOC(false).
-spec singleton(FNB) -> vector(FNB).
singleton(Item) ->
    iv_ffi:singleton(Item).

-file("src/iv/internal/vector.gleam", 19).
?DOC(false).
-spec pair(FND, FND) -> vector(FND).
pair(First, Second) ->
    iv_ffi:pair(First, Second).

-file("src/iv/internal/vector.gleam", 23).
?DOC(false).
-spec append(vector(FNF), FNF) -> vector(FNF).
append(Xs, X) ->
    erlang:append_element(Xs, X).

-file("src/iv/internal/vector.gleam", 27).
?DOC(false).
-spec prepend(vector(FNI), FNI) -> vector(FNI).
prepend(Xs, X) ->
    iv_ffi:prepend(Xs, X).

-file("src/iv/internal/vector.gleam", 31).
?DOC(false).
-spec drop_first(vector(FNL)) -> vector(FNL).
drop_first(Xs) ->
    iv_ffi:drop_first(Xs).

-file("src/iv/internal/vector.gleam", 35).
?DOC(false).
-spec drop_last(vector(FNO)) -> vector(FNO).
drop_last(Xs) ->
    iv_ffi:drop_last(Xs).

-file("src/iv/internal/vector.gleam", 45).
?DOC(false).
-spec concat_all(list(vector(FNV))) -> vector(FNV).
concat_all(Vectors) ->
    iv_ffi:concat_all(Vectors).

-file("src/iv/internal/vector.gleam", 49).
?DOC(false).
-spec set(integer(), vector(FNZ), FNZ) -> vector(FNZ).
set(Idx, Xs, X) ->
    erlang:setelement(Idx, Xs, X).

-file("src/iv/internal/vector.gleam", 53).
?DOC(false).
-spec length(vector(any())) -> integer().
length(Xs) ->
    erlang:tuple_size(Xs).

-file("src/iv/internal/vector.gleam", 57).
?DOC(false).
-spec get(integer(), vector(FOE)) -> FOE.
get(Index_plus_one, Xs) ->
    erlang:element(Index_plus_one, Xs).

-file("src/iv/internal/vector.gleam", 61).
?DOC(false).
-spec split(integer(), vector(FOG)) -> {vector(FOG), vector(FOG)}.
split(At, Xs) ->
    iv_ffi:split1(At, Xs).

-file("src/iv/internal/vector.gleam", 65).
?DOC(false).
-spec map(vector(FOK), fun((FOK) -> FOM)) -> vector(FOM).
map(Xs, Fun) ->
    iv_ffi:map(Xs, Fun).

-file("src/iv/internal/vector.gleam", 68).
?DOC(false).
-spec map_add(vector(integer()), integer()) -> vector(integer()).
map_add(Xs, Delta) ->
    iv_ffi:map_add(Xs, Delta).

-file("src/iv/internal/vector.gleam", 102).
?DOC(false).
-spec fold_loop(vector(FSR), FSQ, integer(), integer(), fun((FSQ, FSR) -> FSQ)) -> FSQ.
fold_loop(Xs, State, Idx, Len, Fun) ->
    case Idx =< Len of
        true ->
            fold_loop(
                Xs,
                Fun(State, erlang:element(Idx, Xs)),
                Idx + 1,
                Len,
                Fun
            );

        false ->
            State
    end.

-file("src/iv/internal/vector.gleam", 73).
?DOC(false).
-spec fold(vector(FOQ), FOS, fun((FOS, FOQ) -> FOS)) -> FOS.
fold(Xs, State, Fun) ->
    iv_ffi:fold(Xs, State, Fun).

-file("src/iv/internal/vector.gleam", 39).
?DOC(false).
-spec concat(vector(FNR), vector(FNR)) -> vector(FNR).
concat(A, B) ->
    iv_ffi:fold(B, A, fun erlang:append_element/2).

-file("src/iv/internal/vector.gleam", 83).
?DOC(false).
-spec fold_skip_last(vector(FOT), FOV, fun((FOV, FOT) -> FOV)) -> FOV.
fold_skip_last(Xs, State, Fun) ->
    iv_ffi:fold_skip_last(Xs, State, Fun).

-file("src/iv/internal/vector.gleam", 93).
?DOC(false).
-spec fold_skip_first(vector(FOW), FOY, fun((FOY, FOW) -> FOY)) -> FOY.
fold_skip_first(Xs, State, Fun) ->
    iv_ffi:fold_skip_first(Xs, State, Fun).

-file("src/iv/internal/vector.gleam", 134).
?DOC(false).
-spec fold_right_loop(vector(FTI), FTH, integer(), fun((FTH, FTI) -> FTH)) -> FTH.
fold_right_loop(Xs, State, Idx, Fun) ->
    case Idx > 0 of
        true ->
            fold_right_loop(
                Xs,
                Fun(State, erlang:element(Idx, Xs)),
                Idx - 1,
                Fun
            );

        false ->
            State
    end.

-file("src/iv/internal/vector.gleam", 125).
?DOC(false).
-spec fold_right(vector(FPS), FPU, fun((FPU, FPS) -> FPU)) -> FPU.
fold_right(Xs, State, Fun) ->
    Len = erlang:tuple_size(Xs),
    fold_right_loop(Xs, State, Len, Fun).

-file("src/iv/internal/vector.gleam", 150).
?DOC(false).
-spec index_fold_right_loop(
    vector(FTR),
    FTQ,
    integer(),
    fun((FTQ, FTR, integer()) -> FTQ)
) -> FTQ.
index_fold_right_loop(Xs, State, Idx, Fun) ->
    case Idx > 0 of
        true ->
            index_fold_right_loop(
                Xs,
                Fun(State, erlang:element(Idx, Xs), Idx),
                Idx - 1,
                Fun
            );

        false ->
            State
    end.

-file("src/iv/internal/vector.gleam", 141).
?DOC(false).
-spec index_fold_right(vector(FQA), FQC, fun((FQC, FQA, integer()) -> FQC)) -> FQC.
index_fold_right(Xs, State, Fun) ->
    Len = erlang:tuple_size(Xs),
    index_fold_right_loop(Xs, State, Len, Fun).

-file("src/iv/internal/vector.gleam", 167).
?DOC(false).
-spec index_fold_loop(
    vector(FUA),
    FTZ,
    integer(),
    integer(),
    fun((FTZ, FUA, integer()) -> FTZ)
) -> FTZ.
index_fold_loop(Xs, State, Idx, Len, Fun) ->
    case Idx =< Len of
        true ->
            index_fold_loop(
                Xs,
                Fun(State, erlang:element(Idx, Xs), Idx),
                Idx + 1,
                Len,
                Fun
            );

        false ->
            State
    end.

-file("src/iv/internal/vector.gleam", 158).
?DOC(false).
-spec index_fold(vector(FQI), FQK, fun((FQK, FQI, integer()) -> FQK)) -> FQK.
index_fold(Xs, State, Fun) ->
    Len = erlang:tuple_size(Xs),
    index_fold_loop(Xs, State, 1, Len, Fun).

-file("src/iv/internal/vector.gleam", 120).
?DOC(false).
-spec index_map(vector(FPO), fun((FPO, integer()) -> FPQ)) -> vector(FPQ).
index_map(Xs, Fun) ->
    index_fold(
        Xs,
        iv_ffi:empty(),
        fun(Result, Item, Index) ->
            erlang:append_element(Result, Fun(Item, Index))
        end
    ).

-file("src/iv/internal/vector.gleam", 184).
?DOC(false).
-spec try_fold_loop(
    vector(FUQ),
    FUU,
    integer(),
    integer(),
    fun((FUU, FUQ) -> {ok, FUU} | {error, FUY})
) -> {ok, FUU} | {error, FUY}.
try_fold_loop(Xs, State, Idx, Len, Fun) ->
    case Idx =< Len of
        true ->
            case Fun(State, erlang:element(Idx, Xs)) of
                {ok, State@1} ->
                    try_fold_loop(Xs, State@1, Idx + 1, Len, Fun);

                {error, Error} ->
                    {error, Error}
            end;

        false ->
            {ok, State}
    end.

-file("src/iv/internal/vector.gleam", 175).
?DOC(false).
-spec try_fold(vector(FQR), FQT, fun((FQT, FQR) -> {ok, FQT} | {error, FQU})) -> {ok,
        FQT} |
    {error, FQU}.
try_fold(Xs, State, Fun) ->
    Len = erlang:tuple_size(Xs),
    try_fold_loop(Xs, State, 1, Len, Fun).

-file("src/iv/internal/vector.gleam", 109).
?DOC(false).
-spec try_map(vector(FPF), fun((FPF) -> {ok, FPH} | {error, FPI})) -> {ok,
        vector(FPH)} |
    {error, FPI}.
try_map(Xs, Fun) ->
    try_fold(Xs, iv_ffi:empty(), fun(Result, Item) -> case Fun(Item) of
                {ok, Mapped} ->
                    {ok, erlang:append_element(Result, Mapped)};

                {error, Error} ->
                    {error, Error}
            end end).

-file("src/iv/internal/vector.gleam", 200).
?DOC(false).
-spec find_map_loop(
    vector(FVU),
    integer(),
    integer(),
    fun((FVU) -> {ok, FWC} | {error, nil})
) -> {ok, FWC} | {error, nil}.
find_map_loop(Xs, Idx, Len, Fun) ->
    case Idx =< Len of
        true ->
            Item = erlang:element(Idx, Xs),
            case Fun(Item) of
                {ok, _} = Result ->
                    Result;

                {error, _} ->
                    find_map_loop(Xs, Idx + 1, Len, Fun)
            end;

        false ->
            {error, nil}
    end.

-file("src/iv/internal/vector.gleam", 195).
?DOC(false).
-spec find_map(vector(FWD), fun((FWD) -> {ok, FWF} | {error, nil})) -> {ok, FWF} |
    {error, nil}.
find_map(Xs, Fun) ->
    Len = erlang:tuple_size(Xs),
    find_map_loop(Xs, 1, Len, Fun).

-file("src/iv/internal/vector.gleam", 221).
?DOC(false).
-spec find_index_loop(
    vector(FWL),
    integer(),
    integer(),
    fun((FWL, integer()) -> {ok, FWQ} | {error, nil})
) -> {ok, FWQ} | {error, nil}.
find_index_loop(Xs, Idx, Len, Fun) ->
    case Idx =< Len of
        true ->
            case Fun(erlang:element(Idx, Xs), Idx) of
                {ok, _} = Result ->
                    Result;

                {error, nil} ->
                    find_index_loop(Xs, Idx + 1, Len, Fun)
            end;

        false ->
            {error, nil}
    end.

-file("src/iv/internal/vector.gleam", 213).
?DOC(false).
-spec find_index(vector(FRN), fun((FRN, integer()) -> {ok, FRP} | {error, nil})) -> {ok,
        FRP} |
    {error, nil}.
find_index(Xs, Fun) ->
    Len = erlang:tuple_size(Xs),
    find_index_loop(Xs, 1, Len, Fun).

-file("src/iv/internal/vector.gleam", 240).
?DOC(false).
-spec find_last_index_loop(
    vector(FWZ),
    integer(),
    fun((FWZ, integer()) -> {ok, FXE} | {error, nil})
) -> {ok, FXE} | {error, nil}.
find_last_index_loop(Xs, Idx, Fun) ->
    case Idx > 0 of
        true ->
            case Fun(erlang:element(Idx, Xs), Idx) of
                {ok, _} = Result ->
                    Result;

                {error, nil} ->
                    find_last_index_loop(Xs, Idx - 1, Fun)
            end;

        false ->
            {error, nil}
    end.

-file("src/iv/internal/vector.gleam", 232).
?DOC(false).
-spec find_last_index(
    vector(FRZ),
    fun((FRZ, integer()) -> {ok, FSB} | {error, nil})
) -> {ok, FSB} | {error, nil}.
find_last_index(Xs, Fun) ->
    Len = erlang:tuple_size(Xs),
    find_last_index_loop(Xs, Len, Fun).
