-module(shared@player_state).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/shared/player_state.gleam").
-export([encode/1, vec3_decoder/0, decoder/0, encode_vec3/1]).
-export_type([player_state/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type player_state() :: {player_state,
        shared@id:player_id(),
        vec@vec3:vec3(float()),
        float(),
        float(),
        float(),
        integer()}.

-file("src/shared/player_state.gleam", 22).
?DOC(" Encode a PlayerState to JSON for network transmission.\n").
-spec encode(player_state()) -> gleam@json:json().
encode(State) ->
    {player_id, Player_id} = erlang:element(2, State),
    gleam@json:object(
        [{<<"id"/utf8>>, gleam@json:string(Player_id)},
            {<<"position"/utf8>>,
                gleam@json:object(
                    [{<<"x"/utf8>>,
                            gleam@json:float(
                                erlang:element(2, erlang:element(3, State))
                            )},
                        {<<"y"/utf8>>,
                            gleam@json:float(
                                erlang:element(3, erlang:element(3, State))
                            )},
                        {<<"z"/utf8>>,
                            gleam@json:float(
                                erlang:element(4, erlang:element(3, State))
                            )}]
                )},
            {<<"rotation"/utf8>>, gleam@json:float(erlang:element(4, State))},
            {<<"health"/utf8>>, gleam@json:float(erlang:element(5, State))},
            {<<"max_health"/utf8>>, gleam@json:float(erlang:element(6, State))},
            {<<"active_wand_index"/utf8>>,
                gleam@json:int(erlang:element(7, State))}]
    ).

-file("src/shared/player_state.gleam", 60).
?DOC(" Decoder for Vec3(Float).\n").
-spec vec3_decoder() -> gleam@dynamic@decode:decoder(vec@vec3:vec3(float())).
vec3_decoder() ->
    gleam@dynamic@decode:field(
        <<"x"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_float/1},
        fun(X) ->
            gleam@dynamic@decode:field(
                <<"y"/utf8>>,
                {decoder, fun gleam@dynamic@decode:decode_float/1},
                fun(Y) ->
                    gleam@dynamic@decode:field(
                        <<"z"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_float/1},
                        fun(Z) ->
                            gleam@dynamic@decode:success({vec3, X, Y, Z})
                        end
                    )
                end
            )
        end
    ).

-file("src/shared/player_state.gleam", 42).
?DOC(" Decoder for PlayerState from JSON.\n").
-spec decoder() -> gleam@dynamic@decode:decoder(player_state()).
decoder() ->
    gleam@dynamic@decode:field(
        <<"id"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Id) ->
            gleam@dynamic@decode:field(
                <<"position"/utf8>>,
                vec3_decoder(),
                fun(Position) ->
                    gleam@dynamic@decode:field(
                        <<"rotation"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_float/1},
                        fun(Rotation) ->
                            gleam@dynamic@decode:field(
                                <<"health"/utf8>>,
                                {decoder,
                                    fun gleam@dynamic@decode:decode_float/1},
                                fun(Health) ->
                                    gleam@dynamic@decode:field(
                                        <<"max_health"/utf8>>,
                                        {decoder,
                                            fun gleam@dynamic@decode:decode_float/1},
                                        fun(Max_health) ->
                                            gleam@dynamic@decode:field(
                                                <<"active_wand_index"/utf8>>,
                                                {decoder,
                                                    fun gleam@dynamic@decode:decode_int/1},
                                                fun(Active_wand_index) ->
                                                    gleam@dynamic@decode:success(
                                                        {player_state,
                                                            {player_id, Id},
                                                            Position,
                                                            Rotation,
                                                            Health,
                                                            Max_health,
                                                            Active_wand_index}
                                                    )
                                                end
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/shared/player_state.gleam", 68).
?DOC(" Encode a Vec3 to JSON.\n").
-spec encode_vec3(vec@vec3:vec3(float())) -> gleam@json:json().
encode_vec3(V) ->
    gleam@json:object(
        [{<<"x"/utf8>>, gleam@json:float(erlang:element(2, V))},
            {<<"y"/utf8>>, gleam@json:float(erlang:element(3, V))},
            {<<"z"/utf8>>, gleam@json:float(erlang:element(4, V))}]
    ).
