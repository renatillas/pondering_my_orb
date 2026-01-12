-module(iv_ffi).
-export([prepend/2, empty/0, singleton/1, pair/2, split1/2, map/2, map_add/2, fold/3, fold_skip_first/3, fold_skip_last/3, concat_all/1,drop_first/1, drop_last/1, concat/2]).
-export([sum_node_children_counts_skip_first/1, sum_node_children_counts_skip_last/1]).
-export([compute_sizes/1]).

-compile([inline, inline_size/128, inline_list_funcs]).

empty() -> {}.
singleton(X) -> {X}.
pair(A, B) -> {A, B}.

% Optimized split using pattern matching on lists
% Convert to list once, then pattern match with |Rest syntax
% Since branch_factor is 16 on Erlang, we only need patterns up to 15 elements
split1(1, Xs) when is_tuple(Xs) -> {{}, Xs};
split1(Idx, Xs) when is_integer(Idx), is_tuple(Xs), Idx > tuple_size(Xs) -> {Xs, {}};
split1(Idx, Xs) when is_integer(Idx), is_tuple(Xs) ->
    split_list(Idx, tuple_to_list(Xs)).

% Pattern match on list position - much cleaner than tuple patterns
split_list(17, [A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P|Rest]) -> {{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P}, list_to_tuple(Rest)};
split_list(16, [A,B,C,D,E,F,G,H,I,J,K,L,M,N,O|Rest]) -> {{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O}, list_to_tuple(Rest)};
split_list(15, [A,B,C,D,E,F,G,H,I,J,K,L,M,N|Rest]) -> {{A,B,C,D,E,F,G,H,I,J,K,L,M,N}, list_to_tuple(Rest)};
split_list(14, [A,B,C,D,E,F,G,H,I,J,K,L,M|Rest]) -> {{A,B,C,D,E,F,G,H,I,J,K,L,M}, list_to_tuple(Rest)};
split_list(13, [A,B,C,D,E,F,G,H,I,J,K,L|Rest]) -> {{A,B,C,D,E,F,G,H,I,J,K,L}, list_to_tuple(Rest)};
split_list(12, [A,B,C,D,E,F,G,H,I,J,K|Rest]) -> {{A,B,C,D,E,F,G,H,I,J,K}, list_to_tuple(Rest)};
split_list(11, [A,B,C,D,E,F,G,H,I,J|Rest]) -> {{A,B,C,D,E,F,G,H,I,J}, list_to_tuple(Rest)};
split_list(10, [A,B,C,D,E,F,G,H,I|Rest]) -> {{A,B,C,D,E,F,G,H,I}, list_to_tuple(Rest)};
split_list(9, [A,B,C,D,E,F,G,H|Rest]) -> {{A,B,C,D,E,F,G,H}, list_to_tuple(Rest)};
split_list(8, [A,B,C,D,E,F,G|Rest]) -> {{A,B,C,D,E,F,G}, list_to_tuple(Rest)};
split_list(7, [A,B,C,D,E,F|Rest]) -> {{A,B,C,D,E,F}, list_to_tuple(Rest)};
split_list(6, [A,B,C,D,E|Rest]) -> {{A,B,C,D,E}, list_to_tuple(Rest)};
split_list(5, [A,B,C,D|Rest]) -> {{A,B,C,D}, list_to_tuple(Rest)};
split_list(4, [A,B,C|Rest]) -> {{A,B,C}, list_to_tuple(Rest)};
split_list(3, [A,B|Rest]) -> {{A,B}, list_to_tuple(Rest)};
split_list(2, [A|Rest]) -> {{A}, list_to_tuple(Rest)}.

prepend(Xs, X) when is_tuple(Xs) -> erlang:insert_element(1, Xs, X).

drop_first({}) -> {};
drop_first({_}) -> {};
drop_first(Xs) when is_tuple(Xs) -> erlang:delete_element(1, Xs).

drop_last({}) -> {};
drop_last({_}) -> {};
drop_last(Xs) when is_tuple(Xs) -> erlang:delete_element(tuple_size(Xs), Xs).

concat({}, X) -> X;
concat(X, {}) -> X;
concat(A, B) -> list_to_tuple(tuple_to_list(A) ++ tuple_to_list(B)).

concat_all([]) -> {};
concat_all([Single]) -> Single;
concat_all([_|_]=Tuples) -> reverse_and_flatten(Tuples, []).

reverse_and_flatten([], Acc) -> list_to_tuple(Acc);
reverse_and_flatten([{} | Rest], Acc) -> reverse_and_flatten(Rest, Acc);
reverse_and_flatten([Tuple | Rest], Acc) when is_tuple(Tuple) ->
    reverse_and_flatten(Rest, tuple_to_list(Tuple) ++ Acc).

%% this looks highly questionable, but means fold is 5 times (!!) as quick.
map({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9), F(X10), F(X11), F(X12), F(X13), F(X14), F(X15), F(X16)};
map({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9), F(X10), F(X11), F(X12), F(X13), F(X14), F(X15)};
map({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9), F(X10), F(X11), F(X12), F(X13), F(X14)};
map({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9), F(X10), F(X11), F(X12), F(X13)};
map({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9), F(X10), F(X11), F(X12)};
map({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9), F(X10), F(X11)};
map({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9), F(X10)};
map({X1, X2, X3, X4, X5, X6, X7, X8, X9}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8), F(X9)};
map({X1, X2, X3, X4, X5, X6, X7, X8}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7), F(X8)};
map({X1, X2, X3, X4, X5, X6, X7}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6), F(X7)};
map({X1, X2, X3, X4, X5, X6}, F) when is_function(F, 1) -> {F(X1), F(X2), F(X3), F(X4), F(X5), F(X6)};
map({X1, X2, X3, X4, X5}, F)when is_function(F, 1)  -> {F(X1), F(X2), F(X3), F(X4), F(X5)};
map({X1, X2, X3, X4}, F)when is_function(F, 1)  -> {F(X1), F(X2), F(X3), F(X4)};
map({X1, X2, X3}, F)when is_function(F, 1)  -> {F(X1), F(X2), F(X3)};
map({X1, X2}, F) when is_function(F, 1) -> {F(X1), F(X2)};
map({X1}, F) when is_function(F, 1) -> {F(X1)};
map(T, _F) -> T.

% Specialized map for adding a constant - avoids closure overhead
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta, X10+Delta, X11+Delta, X12+Delta, X13+Delta, X14+Delta, X15+Delta, X16+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta, X10+Delta, X11+Delta, X12+Delta, X13+Delta, X14+Delta, X15+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta, X10+Delta, X11+Delta, X12+Delta, X13+Delta, X14+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta, X10+Delta, X11+Delta, X12+Delta, X13+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta, X10+Delta, X11+Delta, X12+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta, X10+Delta, X11+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta, X10+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8, X9}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta, X9+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7, X8}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta, X8+Delta};
map_add({X1, X2, X3, X4, X5, X6, X7}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta, X7+Delta};
map_add({X1, X2, X3, X4, X5, X6}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta, X6+Delta};
map_add({X1, X2, X3, X4, X5}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta, X5+Delta};
map_add({X1, X2, X3, X4}, Delta) -> {X1+Delta, X2+Delta, X3+Delta, X4+Delta};
map_add({X1, X2, X3}, Delta) -> {X1+Delta, X2+Delta, X3+Delta};
map_add({X1, X2}, Delta) -> {X1+Delta, X2+Delta};
map_add({X1}, Delta) -> {X1+Delta};
map_add(T, _Delta) -> T.

fold({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14), X15), X16);
fold({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14), X15);
fold({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14);
fold({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13);
fold({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12);
fold({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11);
fold({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10);
fold({X1, X2, X3, X4, X5, X6, X7, X8, X9}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9);
fold({X1, X2, X3, X4, X5, X6, X7, X8}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8);
fold({X1, X2, X3, X4, X5, X6, X7}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7);
fold({X1, X2, X3, X4, X5, X6}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6);
fold({X1, X2, X3, X4, X5}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5);
fold({X1, X2, X3, X4}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(State, X1), X2), X3), X4);
fold({X1, X2, X3}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(State, X1), X2), X3);
fold({X1, X2}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(State, X1), X2);
fold({X1}, State, Fun) when is_function(Fun, 2) -> Fun(State, X1);
fold({}, State, _Fun) -> State.

fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14), X15), X16);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14), X15);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9), X10), X11);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9), X10);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8), X9);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7), X8);
fold_skip_first({_X1, X2, X3, X4, X5, X6, X7}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6), X7);
fold_skip_first({_X1, X2, X3, X4, X5, X6}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(Fun(State, X2), X3), X4), X5), X6);
fold_skip_first({_X1, X2, X3, X4, X5}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(Fun(State, X2), X3), X4), X5);
fold_skip_first({_X1, X2, X3, X4}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(Fun(State, X2), X3), X4);
fold_skip_first({_X1, X2, X3}, State, Fun) when is_function(Fun, 2) -> Fun(Fun(State, X2), X3);
fold_skip_first({_X1, X2}, State, Fun) when is_function(Fun, 2) -> Fun(State, X2);
fold_skip_first({_X1}, State, _Fun) -> State;
fold_skip_first({}, State, _Fun) -> State.

fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, _X16}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14), X15);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, _X15}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13), X14);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, _X14}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12), X13);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, _X13}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11), X12);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, _X12}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10), X11);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, _X11}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9), X10);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, _X10}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8), X9);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, _X9}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7), X8);
fold_skip_last({X1, X2, X3, X4, X5, X6, X7, _X8}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6), X7);
fold_skip_last({X1, X2, X3, X4, X5, X6, _X7}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5), X6);
fold_skip_last({X1, X2, X3, X4, X5, _X6}, State, Fun) -> Fun(Fun(Fun(Fun(Fun(State, X1), X2), X3), X4), X5);
fold_skip_last({X1, X2, X3, X4, _X5}, State, Fun) -> Fun(Fun(Fun(Fun(State, X1), X2), X3), X4);
fold_skip_last({X1, X2, X3, _X4}, State, Fun) -> Fun(Fun(Fun(State, X1), X2), X3);
fold_skip_last({X1, X2, _X3}, State, Fun) -> Fun(Fun(State, X1), X2);
fold_skip_last({X1, _X2}, State, Fun) -> Fun(State, X1);
fold_skip_last({_X1}, State, _Fun) -> State;
fold_skip_last({}, State, _Fun) -> State.

compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), S10 = S9 + node_size(X10), S11 = S10 + node_size(X11), S12 = S11 + node_size(X12), S13 = S12 + node_size(X13), S14 = S13 + node_size(X14), S15 = S14 + node_size(X15), S16 = S15 + node_size(X16), {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), S10 = S9 + node_size(X10), S11 = S10 + node_size(X11), S12 = S11 + node_size(X12), S13 = S12 + node_size(X13), S14 = S13 + node_size(X14), S15 = S14 + node_size(X15), {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), S10 = S9 + node_size(X10), S11 = S10 + node_size(X11), S12 = S11 + node_size(X12), S13 = S12 + node_size(X13), S14 = S13 + node_size(X14), {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), S10 = S9 + node_size(X10), S11 = S10 + node_size(X11), S12 = S11 + node_size(X12), S13 = S12 + node_size(X13), {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), S10 = S9 + node_size(X10), S11 = S10 + node_size(X11), S12 = S11 + node_size(X12), {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), S10 = S9 + node_size(X10), S11 = S10 + node_size(X11), {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), S10 = S9 + node_size(X10), {S1, S2, S3, S4, S5, S6, S7, S8, S9, S10};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8, X9}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), S9 = S8 + node_size(X9), {S1, S2, S3, S4, S5, S6, S7, S8, S9};
compute_sizes({X1, X2, X3, X4, X5, X6, X7, X8}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), S8 = S7 + node_size(X8), {S1, S2, S3, S4, S5, S6, S7, S8};
compute_sizes({X1, X2, X3, X4, X5, X6, X7}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), S7 = S6 + node_size(X7), {S1, S2, S3, S4, S5, S6, S7};
compute_sizes({X1, X2, X3, X4, X5, X6}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), S6 = S5 + node_size(X6), {S1, S2, S3, S4, S5, S6};
compute_sizes({X1, X2, X3, X4, X5}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), S5 = S4 + node_size(X5), {S1, S2, S3, S4, S5};
compute_sizes({X1, X2, X3, X4}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), S4 = S3 + node_size(X4), {S1, S2, S3, S4};
compute_sizes({X1, X2, X3}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), S3 = S2 + node_size(X3), {S1, S2, S3};
compute_sizes({X1, X2}) -> S1 = node_size(X1), S2 = S1 + node_size(X2), {S1, S2};
compute_sizes({X1}) -> S1 = node_size(X1), {S1}.

node_size({leaf, Items}) -> tuple_size(Items);
node_size({balanced, Size, _}) -> Size;
node_size({unbalanced, Sizes, _}) -> erlang:element(tuple_size(Sizes), Sizes).

% Helper to get children count from a node
node_length({leaf, C}) -> tuple_size(C);
node_length({balanced, _, C}) -> tuple_size(C);
node_length({unbalanced, _, C}) -> tuple_size(C).

sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12) + node_length(X13) + node_length(X14) + node_length(X15) + node_length(X16);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12) + node_length(X13) + node_length(X14) + node_length(X15);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12) + node_length(X13) + node_length(X14);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12) + node_length(X13);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9, X10}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8, X9}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7, X8}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6, X7}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5, X6}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6);
sum_node_children_counts_skip_first({_X1, X2, X3, X4, X5}) -> node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5);
sum_node_children_counts_skip_first({_X1, X2, X3, X4}) -> node_length(X2) + node_length(X3) + node_length(X4);
sum_node_children_counts_skip_first({_X1, X2, X3}) -> node_length(X2) + node_length(X3);
sum_node_children_counts_skip_first({_X1, X2}) -> node_length(X2);
sum_node_children_counts_skip_first({_X1}) -> 0;
sum_node_children_counts_skip_first({}) -> 0.

sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, _X16}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12) + node_length(X13) + node_length(X14) + node_length(X15);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, _X15}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12) + node_length(X13) + node_length(X14);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, _X14}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12) + node_length(X13);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, _X13}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11) + node_length(X12);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, _X12}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10) + node_length(X11);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, _X11}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9) + node_length(X10);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, X9, _X10}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8) + node_length(X9);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, X8, _X9}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7) + node_length(X8);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, X7, _X8}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6) + node_length(X7);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, X6, _X7}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5) + node_length(X6);
sum_node_children_counts_skip_last({X1, X2, X3, X4, X5, _X6}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4) + node_length(X5);
sum_node_children_counts_skip_last({X1, X2, X3, X4, _X5}) -> node_length(X1) + node_length(X2) + node_length(X3) + node_length(X4);
sum_node_children_counts_skip_last({X1, X2, X3, _X4}) -> node_length(X1) + node_length(X2) + node_length(X3);
sum_node_children_counts_skip_last({X1, X2, _X3}) -> node_length(X1) + node_length(X2);
sum_node_children_counts_skip_last({X1, _X2}) -> node_length(X1);
sum_node_children_counts_skip_last({_X1}) -> 0;
sum_node_children_counts_skip_last({}) -> 0.
