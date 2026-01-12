-module(tote@bag).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([new/0, from_map/1, remove_all/2, copies/2, remove/3, insert/3, from_list/1, update/3, contains/2, is_empty/1, fold/3, size/1, intersect/2, merge/2, subtract/2, map/2, filter/2, to_list/1, to_set/1, to_map/1]).
-export_type([bag/1]).

-opaque bag(GJD) :: {bag, gleam@dict:dict(GJD, integer())}.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 91).
-spec new() -> bag(any()).
new() ->
    {bag, gleam@dict:new()}.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 122).
-spec from_map(gleam@dict:dict(GJJ, integer())) -> bag(GJJ).
from_map(Map) ->
    {bag, Map}.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 215).
-spec remove_all(bag(GJT), GJT) -> bag(GJT).
remove_all(Bag, Item) ->
    {bag, gleam@dict:delete(erlang:element(2, Bag), Item)}.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 270).
-spec copies(bag(GJZ), GJZ) -> integer().
copies(Bag, Item) ->
    case gleam@dict:get(erlang:element(2, Bag), Item) of
        {ok, Copies} ->
            Copies;

        {error, nil} ->
            0
    end.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 196).
-spec remove(bag(GJQ), integer(), GJQ) -> bag(GJQ).
remove(Bag, To_remove, Item) ->
    To_remove@1 = gleam@int:absolute_value(To_remove),
    Item_copies = copies(Bag, Item),
    case gleam@int:compare(To_remove@1, Item_copies) of
        lt ->
            {bag,
                gleam@dict:insert(
                    erlang:element(2, Bag),
                    Item,
                    Item_copies - To_remove@1
                )};

        gt ->
            remove_all(Bag, Item);

        eq ->
            remove_all(Bag, Item)
    end.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 149).
-spec insert(bag(GJN), integer(), GJN) -> bag(GJN).
insert(Bag, To_add, Item) ->
    case gleam@int:compare(To_add, 0) of
        lt ->
            remove(Bag, To_add, Item);

        eq ->
            Bag;

        gt ->
            {bag,
                gleam@dict:upsert(
                    erlang:element(2, Bag),
                    Item,
                    fun(N) -> case N of
                            {some, N@1} ->
                                N@1 + To_add;

                            none ->
                                To_add
                        end end
                )}
    end.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 105).
-spec from_list(list(GJG)) -> bag(GJG).
from_list(List) ->
    gleam@list:fold(List, new(), fun(Bag, Item) -> insert(Bag, 1, Item) end).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 247).
-spec update(bag(GJW), GJW, fun((integer()) -> integer())) -> bag(GJW).
update(Bag, Item, Fun) ->
    Count = copies(Bag, Item),
    New_count = Fun(Count),
    case gleam@int:compare(New_count, 0) of
        lt ->
            remove_all(Bag, Item);

        eq ->
            remove_all(Bag, Item);

        gt ->
            _pipe = remove_all(Bag, Item),
            insert(_pipe, New_count, Item)
    end.

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 293).
-spec contains(bag(GKB), GKB) -> boolean().
contains(Bag, Item) ->
    gleam@dict:has_key(erlang:element(2, Bag), Item).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 316).
-spec is_empty(bag(any())) -> boolean().
is_empty(Bag) ->
    erlang:element(2, Bag) =:= gleam@dict:new().

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 420).
-spec fold(bag(GKT), GKV, fun((GKV, GKT, integer()) -> GKV)) -> GKV.
fold(Bag, Initial, Fun) ->
    gleam@dict:fold(erlang:element(2, Bag), Initial, Fun).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 337).
-spec size(bag(any())) -> integer().
size(Bag) ->
    fold(Bag, 0, fun(Sum, _, Copies) -> Sum + Copies end).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 358).
-spec intersect(bag(GKH), bag(GKH)) -> bag(GKH).
intersect(One, Other) ->
    fold(
        One,
        new(),
        fun(Acc, Item, Copies_in_one) -> case copies(Other, Item) of
                0 ->
                    Acc;

                Copies_in_other ->
                    insert(
                        Acc,
                        gleam@int:min(Copies_in_one, Copies_in_other),
                        Item
                    )
            end end
    ).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 380).
-spec merge(bag(GKL), bag(GKL)) -> bag(GKL).
merge(One, Other) ->
    fold(
        One,
        Other,
        fun(Acc, Item, Copies_in_one) -> insert(Acc, Copies_in_one, Item) end
    ).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 398).
-spec subtract(bag(GKP), bag(GKP)) -> bag(GKP).
subtract(One, Other) ->
    fold(
        Other,
        One,
        fun(Acc, Item, Copies_in_other) ->
            remove(Acc, Copies_in_other, Item)
        end
    ).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 443).
-spec map(bag(GKW), fun((GKW, integer()) -> GKY)) -> bag(GKY).
map(Bag, Fun) ->
    fold(
        Bag,
        new(),
        fun(Acc, Item, Copies) -> insert(Acc, Copies, Fun(Item, Copies)) end
    ).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 460).
-spec filter(bag(GLA), fun((GLA, integer()) -> boolean())) -> bag(GLA).
filter(Bag, Predicate) ->
    fold(Bag, new(), fun(Acc, Item, Copies) -> case Predicate(Item, Copies) of
                true ->
                    insert(Acc, Copies, Item);

                false ->
                    Acc
            end end).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 481).
-spec to_list(bag(GLD)) -> list({GLD, integer()}).
to_list(Bag) ->
    maps:to_list(erlang:element(2, Bag)).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 496).
-spec to_set(bag(GLG)) -> gleam@set:set(GLG).
to_set(Bag) ->
    gleam@set:from_list(gleam@dict:keys(erlang:element(2, Bag))).

-file("/Users/giacomocavalieri/Desktop/progetti/tote/src/tote/bag.gleam", 503).
-spec to_map(bag(GLJ)) -> gleam@dict:dict(GLJ, integer()).
to_map(Bag) ->
    erlang:element(2, Bag).
