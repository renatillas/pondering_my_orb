-module(shared@id).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/shared/id.gleam").
-export([player_id_to_string/1, player_id_from_string/1, room_id_to_string/1, room_id_from_string/1]).
-export_type([player_id/0, room_id/0, projectile_id/0, enemy_id/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type player_id() :: {player_id, binary()}.

-type room_id() :: {room_id, binary()}.

-type projectile_id() :: {projectile_id, player_id(), integer()}.

-type enemy_id() :: {enemy_id, integer()}.

-file("src/shared/id.gleam", 26).
?DOC(" Convert a PlayerId to its string representation.\n").
-spec player_id_to_string(player_id()) -> binary().
player_id_to_string(Id) ->
    {player_id, S} = Id,
    S.

-file("src/shared/id.gleam", 32).
?DOC(" Create a PlayerId from a string.\n").
-spec player_id_from_string(binary()) -> player_id().
player_id_from_string(S) ->
    {player_id, S}.

-file("src/shared/id.gleam", 37).
?DOC(" Convert a RoomId to its string representation.\n").
-spec room_id_to_string(room_id()) -> binary().
room_id_to_string(Id) ->
    {room_id, S} = Id,
    S.

-file("src/shared/id.gleam", 43).
?DOC(" Create a RoomId from a string.\n").
-spec room_id_from_string(binary()) -> room_id().
room_id_from_string(S) ->
    {room_id, S}.
