-module(shared@game_messages).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/shared/game_messages.gleam").
-export([encode_client_message/1, decode_client_message/1, encode_server_message/1, decode_server_message/1]).
-export_type([client_message/0, server_message/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type client_message() :: {join_room, binary(), binary()} |
    leave_room |
    {player_update, vec@vec3:vec3(float()), float()} |
    {spell_cast, integer(), vec@vec3:vec3(float())} |
    {ping, integer()}.

-type server_message() :: {room_joined,
        shared@id:room_id(),
        shared@id:player_id(),
        list(shared@player_state:player_state())} |
    {player_joined, shared@player_state:player_state()} |
    {player_left, shared@id:player_id()} |
    {player_states, list(shared@player_state:player_state())} |
    {spell_cast_broadcast,
        shared@id:player_id(),
        integer(),
        vec@vec3:vec3(float())} |
    {enemy_spawned, integer(), vec@vec3:vec3(float()), float()} |
    {enemy_died, integer(), shared@id:player_id()} |
    {pong, integer(), integer()} |
    {error, binary()}.

-file("src/shared/game_messages.gleam", 30).
?DOC(" Encode a ClientMessage to JSON string for transmission.\n").
-spec encode_client_message(client_message()) -> binary().
encode_client_message(Msg) ->
    _pipe = case Msg of
        {join_room, Room_id, Player_name} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"join_room"/utf8>>)},
                    {<<"room_id"/utf8>>, gleam@json:string(Room_id)},
                    {<<"player_name"/utf8>>, gleam@json:string(Player_name)}]
            );

        leave_room ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"leave_room"/utf8>>)}]
            );

        {player_update, Position, Rotation} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"player_update"/utf8>>)},
                    {<<"position"/utf8>>,
                        shared@player_state:encode_vec3(Position)},
                    {<<"rotation"/utf8>>, gleam@json:float(Rotation)}]
            );

        {spell_cast, Wand_index, Direction} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"spell_cast"/utf8>>)},
                    {<<"wand_index"/utf8>>, gleam@json:int(Wand_index)},
                    {<<"direction"/utf8>>,
                        shared@player_state:encode_vec3(Direction)}]
            );

        {ping, Timestamp} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"ping"/utf8>>)},
                    {<<"timestamp"/utf8>>, gleam@json:int(Timestamp)}]
            )
    end,
    gleam@json:to_string(_pipe).

-file("src/shared/game_messages.gleam", 61).
?DOC(" Decode a ClientMessage from JSON string.\n").
-spec decode_client_message(binary()) -> {ok, client_message()} |
    {error, binary()}.
decode_client_message(Data) ->
    Decoder = begin
        gleam@dynamic@decode:field(
            <<"type"/utf8>>,
            {decoder, fun gleam@dynamic@decode:decode_string/1},
            fun(Msg_type) -> case Msg_type of
                    <<"join_room"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"room_id"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_string/1},
                            fun(Room_id) ->
                                gleam@dynamic@decode:field(
                                    <<"player_name"/utf8>>,
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_string/1},
                                    fun(Player_name) ->
                                        gleam@dynamic@decode:success(
                                            {join_room, Room_id, Player_name}
                                        )
                                    end
                                )
                            end
                        );

                    <<"leave_room"/utf8>> ->
                        gleam@dynamic@decode:success(leave_room);

                    <<"player_update"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"position"/utf8>>,
                            shared@player_state:vec3_decoder(),
                            fun(Position) ->
                                gleam@dynamic@decode:field(
                                    <<"rotation"/utf8>>,
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_float/1},
                                    fun(Rotation) ->
                                        gleam@dynamic@decode:success(
                                            {player_update, Position, Rotation}
                                        )
                                    end
                                )
                            end
                        );

                    <<"spell_cast"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"wand_index"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_int/1},
                            fun(Wand_index) ->
                                gleam@dynamic@decode:field(
                                    <<"direction"/utf8>>,
                                    shared@player_state:vec3_decoder(),
                                    fun(Direction) ->
                                        gleam@dynamic@decode:success(
                                            {spell_cast, Wand_index, Direction}
                                        )
                                    end
                                )
                            end
                        );

                    <<"ping"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"timestamp"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_int/1},
                            fun(Timestamp) ->
                                gleam@dynamic@decode:success({ping, Timestamp})
                            end
                        );

                    _ ->
                        gleam@dynamic@decode:failure(
                            leave_room,
                            <<"ClientMessage"/utf8>>
                        )
                end end
        )
    end,
    _pipe = gleam@json:parse(Data, Decoder),
    gleam@result:map_error(
        _pipe,
        fun(_) -> <<"Failed to parse client message"/utf8>> end
    ).

-file("src/shared/game_messages.gleam", 123).
?DOC(" Encode a ServerMessage to JSON string for transmission.\n").
-spec encode_server_message(server_message()) -> binary().
encode_server_message(Msg) ->
    _pipe = case Msg of
        {room_joined, Room_id, Player_id, Players} ->
            {room_id, Rid} = Room_id,
            {player_id, Pid} = Player_id,
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"room_joined"/utf8>>)},
                    {<<"room_id"/utf8>>, gleam@json:string(Rid)},
                    {<<"player_id"/utf8>>, gleam@json:string(Pid)},
                    {<<"players"/utf8>>,
                        gleam@json:array(
                            Players,
                            fun shared@player_state:encode/1
                        )}]
            );

        {player_joined, Player} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"player_joined"/utf8>>)},
                    {<<"player"/utf8>>, shared@player_state:encode(Player)}]
            );

        {player_left, Player_id@1} ->
            {player_id, Pid@1} = Player_id@1,
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"player_left"/utf8>>)},
                    {<<"player_id"/utf8>>, gleam@json:string(Pid@1)}]
            );

        {player_states, States} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"player_states"/utf8>>)},
                    {<<"states"/utf8>>,
                        gleam@json:array(
                            States,
                            fun shared@player_state:encode/1
                        )}]
            );

        {spell_cast_broadcast, Caster_id, Wand_index, Direction} ->
            {player_id, Cid} = Caster_id,
            gleam@json:object(
                [{<<"type"/utf8>>,
                        gleam@json:string(<<"spell_cast_broadcast"/utf8>>)},
                    {<<"caster_id"/utf8>>, gleam@json:string(Cid)},
                    {<<"wand_index"/utf8>>, gleam@json:int(Wand_index)},
                    {<<"direction"/utf8>>,
                        shared@player_state:encode_vec3(Direction)}]
            );

        {enemy_spawned, Enemy_id, Position, Health} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"enemy_spawned"/utf8>>)},
                    {<<"enemy_id"/utf8>>, gleam@json:int(Enemy_id)},
                    {<<"position"/utf8>>,
                        shared@player_state:encode_vec3(Position)},
                    {<<"health"/utf8>>, gleam@json:float(Health)}]
            );

        {enemy_died, Enemy_id@1, Killer_id} ->
            {player_id, Kid} = Killer_id,
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"enemy_died"/utf8>>)},
                    {<<"enemy_id"/utf8>>, gleam@json:int(Enemy_id@1)},
                    {<<"killer_id"/utf8>>, gleam@json:string(Kid)}]
            );

        {pong, Client_timestamp, Server_timestamp} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"pong"/utf8>>)},
                    {<<"client_timestamp"/utf8>>,
                        gleam@json:int(Client_timestamp)},
                    {<<"server_timestamp"/utf8>>,
                        gleam@json:int(Server_timestamp)}]
            );

        {error, Message} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"error"/utf8>>)},
                    {<<"message"/utf8>>, gleam@json:string(Message)}]
            )
    end,
    gleam@json:to_string(_pipe).

-file("src/shared/game_messages.gleam", 192).
?DOC(" Decode a ServerMessage from JSON string.\n").
-spec decode_server_message(binary()) -> {ok, server_message()} |
    {error, binary()}.
decode_server_message(Data) ->
    Decoder = begin
        gleam@dynamic@decode:field(
            <<"type"/utf8>>,
            {decoder, fun gleam@dynamic@decode:decode_string/1},
            fun(Msg_type) -> case Msg_type of
                    <<"room_joined"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"room_id"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_string/1},
                            fun(Room_id) ->
                                gleam@dynamic@decode:field(
                                    <<"player_id"/utf8>>,
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_string/1},
                                    fun(Player_id) ->
                                        gleam@dynamic@decode:field(
                                            <<"players"/utf8>>,
                                            gleam@dynamic@decode:list(
                                                shared@player_state:decoder()
                                            ),
                                            fun(Players) ->
                                                gleam@dynamic@decode:success(
                                                    {room_joined,
                                                        {room_id, Room_id},
                                                        {player_id, Player_id},
                                                        Players}
                                                )
                                            end
                                        )
                                    end
                                )
                            end
                        );

                    <<"player_joined"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"player"/utf8>>,
                            shared@player_state:decoder(),
                            fun(Player) ->
                                gleam@dynamic@decode:success(
                                    {player_joined, Player}
                                )
                            end
                        );

                    <<"player_left"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"player_id"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_string/1},
                            fun(Player_id@1) ->
                                gleam@dynamic@decode:success(
                                    {player_left, {player_id, Player_id@1}}
                                )
                            end
                        );

                    <<"player_states"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"states"/utf8>>,
                            gleam@dynamic@decode:list(
                                shared@player_state:decoder()
                            ),
                            fun(States) ->
                                gleam@dynamic@decode:success(
                                    {player_states, States}
                                )
                            end
                        );

                    <<"spell_cast_broadcast"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"caster_id"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_string/1},
                            fun(Caster_id) ->
                                gleam@dynamic@decode:field(
                                    <<"wand_index"/utf8>>,
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_int/1},
                                    fun(Wand_index) ->
                                        gleam@dynamic@decode:field(
                                            <<"direction"/utf8>>,
                                            shared@player_state:vec3_decoder(),
                                            fun(Direction) ->
                                                gleam@dynamic@decode:success(
                                                    {spell_cast_broadcast,
                                                        {player_id, Caster_id},
                                                        Wand_index,
                                                        Direction}
                                                )
                                            end
                                        )
                                    end
                                )
                            end
                        );

                    <<"enemy_spawned"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"enemy_id"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_int/1},
                            fun(Enemy_id) ->
                                gleam@dynamic@decode:field(
                                    <<"position"/utf8>>,
                                    shared@player_state:vec3_decoder(),
                                    fun(Position) ->
                                        gleam@dynamic@decode:field(
                                            <<"health"/utf8>>,
                                            {decoder,
                                                fun gleam@dynamic@decode:decode_float/1},
                                            fun(Health) ->
                                                gleam@dynamic@decode:success(
                                                    {enemy_spawned,
                                                        Enemy_id,
                                                        Position,
                                                        Health}
                                                )
                                            end
                                        )
                                    end
                                )
                            end
                        );

                    <<"enemy_died"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"enemy_id"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_int/1},
                            fun(Enemy_id@1) ->
                                gleam@dynamic@decode:field(
                                    <<"killer_id"/utf8>>,
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_string/1},
                                    fun(Killer_id) ->
                                        gleam@dynamic@decode:success(
                                            {enemy_died,
                                                Enemy_id@1,
                                                {player_id, Killer_id}}
                                        )
                                    end
                                )
                            end
                        );

                    <<"pong"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"client_timestamp"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_int/1},
                            fun(Client_timestamp) ->
                                gleam@dynamic@decode:field(
                                    <<"server_timestamp"/utf8>>,
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_int/1},
                                    fun(Server_timestamp) ->
                                        gleam@dynamic@decode:success(
                                            {pong,
                                                Client_timestamp,
                                                Server_timestamp}
                                        )
                                    end
                                )
                            end
                        );

                    <<"error"/utf8>> ->
                        gleam@dynamic@decode:field(
                            <<"message"/utf8>>,
                            {decoder, fun gleam@dynamic@decode:decode_string/1},
                            fun(Message) ->
                                gleam@dynamic@decode:success({error, Message})
                            end
                        );

                    _ ->
                        gleam@dynamic@decode:failure(
                            {error, <<"unknown"/utf8>>},
                            <<"ServerMessage"/utf8>>
                        )
                end end
        )
    end,
    _pipe = gleam@json:parse(Data, Decoder),
    gleam@result:map_error(
        _pipe,
        fun(_) -> <<"Failed to parse server message"/utf8>> end
    ).
