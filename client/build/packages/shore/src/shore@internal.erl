-module(shore@internal).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).
-define(FILEPATH, "src/shore/internal.gleam").
-export([send/1, exit/0, key_press/1, resize/2, init_terminal/0, restore_terminal/0, start_custom_renderer/2, start/1]).
-export_type([spec/2, state/2, keybinds/0, focused/1, event/1, redraw/0, control/0, element/0, pos/0, node_/1, separator/0, text_wrap/0, iput/0, btn/0, layout/1, cell/1, term_code/0, kitty_action/0, kitty_format/0, graphic/0, shell_opt/0, do_not_leak/0, t_o_d_o/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-type spec(FBX, FBY) :: {spec,
        fun((gleam@erlang@process:subject(FBY)) -> {FBX, list(fun(() -> FBY))}),
        fun((FBX) -> node_(FBY)),
        fun((FBX, FBY) -> {FBX, list(fun(() -> FBY))}),
        gleam@erlang@process:subject(nil),
        keybinds(),
        redraw()}.

-type state(FBZ, FCA) :: {state,
        spec(FBZ, FCA),
        FBZ,
        integer(),
        integer(),
        gleam@erlang@process:subject(event(FCA)),
        gleam@option:option(focused(FCA)),
        gleam@erlang@process:subject(binary()),
        binary()}.

-type keybinds() :: {keybinds,
        shore@key:key(),
        shore@key:key(),
        shore@key:key(),
        shore@key:key(),
        shore@key:key()}.

-type focused(FCB) :: {focused_input,
        binary(),
        binary(),
        fun((binary()) -> FCB),
        gleam@option:option(FCB),
        integer(),
        integer(),
        integer()} |
    {focused_button, binary(), FCB}.

-opaque event(FCC) :: {key_press, shore@key:key()} |
    {cmd, FCC} |
    redraw |
    {resize, integer(), integer()} |
    exit.

-type redraw() :: on_update | {on_timer, integer()}.

-type control() :: focus_clear | focus_next | focus_prev.

-type element() :: {element, binary(), integer(), integer()}.

-type pos() :: {pos,
        integer(),
        integer(),
        integer(),
        integer(),
        shore@style:align()}.

-type node_(FCD) :: {input,
        binary(),
        binary(),
        shore@style:size(),
        fun((binary()) -> FCD),
        gleam@option:option(FCD),
        boolean()} |
    h_r |
    {h_r2, shore@style:color()} |
    {bar, shore@style:color()} |
    {bar2, shore@style:color(), node_(FCD)} |
    b_r |
    {text_multi,
        binary(),
        text_wrap(),
        gleam@option:option(shore@style:color()),
        gleam@option:option(shore@style:color())} |
    {button,
        binary(),
        binary(),
        shore@key:key(),
        FCD,
        gleam@option:option(shore@style:color()),
        gleam@option:option(shore@style:color()),
        gleam@option:option(shore@style:color()),
        gleam@option:option(shore@style:color())} |
    {key_bind, shore@key:key(), FCD} |
    {aligned, shore@style:align(), node_(FCD)} |
    {col, list(node_(FCD))} |
    {row, list(node_(FCD))} |
    {box,
        list(node_(FCD)),
        gleam@option:option(binary()),
        gleam@option:option(shore@style:color())} |
    {table, shore@style:size(), list(list(binary()))} |
    {table_k_v, shore@style:size(), list(list(binary()))} |
    {graph, shore@style:size(), shore@style:size(), list(float())} |
    debug |
    {progress, shore@style:size(), integer(), integer(), shore@style:color()} |
    {layouts, layout(FCD)} |
    {graphic, binary()}.

-type separator() :: sep_row | sep_col.

-type text_wrap() :: wrap | no_wrap.

-type iput() :: {iput,
        integer(),
        integer(),
        binary(),
        binary(),
        boolean(),
        integer(),
        integer(),
        boolean()}.

-type btn() :: {btn,
        integer(),
        integer(),
        binary(),
        boolean(),
        shore@style:align(),
        gleam@option:option(shore@style:color()),
        gleam@option:option(shore@style:color()),
        gleam@option:option(shore@style:color()),
        gleam@option:option(shore@style:color())}.

-type layout(FCE) :: {grid,
        integer(),
        list(shore@style:size()),
        list(shore@style:size()),
        list(cell(FCE))}.

-type cell(FCF) :: {cell,
        node_(FCF),
        {integer(), integer()},
        {integer(), integer()}}.

-type term_code() :: clear |
    top |
    hide_cursor |
    show_cursor |
    {set_pos, integer(), integer()} |
    save_pos |
    load_pos |
    {move_up, integer()} |
    {move_down, integer()} |
    {move_left, integer()} |
    {move_right, integer()} |
    start_line |
    {column, integer()} |
    {fg, shore@style:color()} |
    {bg, shore@style:color()} |
    {s_g_r, graphic()} |
    reset |
    get_pos |
    alt_buffer |
    main_buffer |
    b_s_u |
    e_s_u |
    {graphics, kitty_format(), boolean(), binary()}.

-type kitty_action() :: transmit_and_display.

-type kitty_format() :: r_g_b | r_g_b_a | p_n_g.

-type graphic() :: bold | faint | italic | underline.

-type shell_opt() :: noshell | raw.

-type do_not_leak() :: any().

-type t_o_d_o() :: any().

-file("src/shore/internal.gleam", 161).
?DOC(false).
-spec default_renderer_loop(nil, binary()) -> gleam@otp@actor:next(nil, binary()).
default_renderer_loop(State, Msg) ->
    _pipe = Msg,
    gleam_stdlib:print(_pipe),
    gleam@otp@actor:continue(State).

-file("src/shore/internal.gleam", 155).
?DOC(false).
-spec default_renderer() -> {ok,
        gleam@otp@actor:started(gleam@erlang@process:subject(binary()))} |
    {error, gleam@otp@actor:start_error()}.
default_renderer() ->
    _pipe = gleam@otp@actor:new(nil),
    _pipe@1 = gleam@otp@actor:on_message(_pipe, fun default_renderer_loop/2),
    gleam@otp@actor:start(_pipe@1).

-file("src/shore/internal.gleam", 188).
?DOC(false).
-spec read_input(gleam@erlang@process:subject(event(any()))) -> nil.
read_input(Shore) ->
    Key = begin
        _pipe = io:get_chars(<<""/utf8>>, 1024),
        shore@key:from_string(_pipe)
    end,
    _pipe@1 = Key,
    _pipe@2 = {key_press, _pipe@1},
    gleam@erlang@process:send(Shore, _pipe@2),
    read_input(Shore).

-file("src/shore/internal.gleam", 210).
?DOC(false).
-spec send(FED) -> event(FED).
send(Msg) ->
    {cmd, Msg}.

-file("src/shore/internal.gleam", 217).
?DOC(false).
-spec exit() -> event(any()).
exit() ->
    exit.

-file("src/shore/internal.gleam", 221).
?DOC(false).
-spec key_press(shore@key:key()) -> event(any()).
key_press(Key) ->
    {key_press, Key}.

-file("src/shore/internal.gleam", 225).
?DOC(false).
-spec resize(integer(), integer()) -> event(any()).
resize(Width, Height) ->
    {resize, Width, Height}.

-file("src/shore/internal.gleam", 426).
?DOC(false).
-spec do_redraw_on_timer(gleam@erlang@process:subject(event(any())), integer()) -> nil.
do_redraw_on_timer(Shore, X) ->
    gleam@erlang@process:send(Shore, redraw),
    gleam_erlang_ffi:sleep(X),
    do_redraw_on_timer(Shore, X).

-file("src/shore/internal.gleam", 416).
?DOC(false).
-spec redraw_on_timer(
    spec(any(), FFJ),
    gleam@erlang@process:subject(event(FFJ))
) -> nil.
redraw_on_timer(Spec, Shore) ->
    case erlang:element(7, Spec) of
        on_update ->
            nil;

        {on_timer, X} ->
            proc_lib:spawn_link(fun() -> do_redraw_on_timer(Shore, X) end),
            nil
    end.

-file("src/shore/internal.gleam", 447).
?DOC(false).
-spec task_handler(
    list(fun(() -> FGD)),
    gleam@erlang@process:subject(event(FGD))
) -> nil.
task_handler(Tasks, Queue) ->
    gleam@list:each(Tasks, fun(Task) -> _pipe@2 = fun() -> _pipe = Task(),
                _pipe@1 = {cmd, _pipe},
                gleam@erlang@process:send(Queue, _pipe@1) end,
            proc_lib:spawn(_pipe@2) end).

-file("src/shore/internal.gleam", 525).
?DOC(false).
-spec focus_next(list(focused(FGW)), focused(FGW), boolean()) -> gleam@option:option(focused(FGW)).
focus_next(Focusable, Focused, Next) ->
    case Focusable of
        [] ->
            none;

        [X | Xs] ->
            case Next of
                true ->
                    {some, X};

                false ->
                    focus_next(
                        Xs,
                        Focused,
                        erlang:element(2, X) =:= erlang:element(2, Focused)
                    )
            end
    end.

-file("src/shore/internal.gleam", 540).
?DOC(false).
-spec focus_current(list(focused(FHC)), focused(FHC)) -> gleam@option:option(focused(FHC)).
focus_current(Focusable, Focused) ->
    case Focusable of
        [] ->
            none;

        [X | Xs] ->
            case erlang:element(2, X) =:= erlang:element(2, Focused) of
                true ->
                    _pipe = case {X, Focused} of
                        {{focused_input, _, _, _, _, _, _, _} = New,
                            {focused_input, _, _, _, _, _, _, _} = Old} ->
                            case erlang:element(6, Old) > string:length(
                                erlang:element(3, New)
                            ) of
                                true ->
                                    _record = New,
                                    {focused_input,
                                        erlang:element(2, _record),
                                        erlang:element(3, _record),
                                        erlang:element(4, _record),
                                        erlang:element(5, _record),
                                        string:length(erlang:element(3, New)),
                                        0,
                                        erlang:element(8, _record)};

                                false ->
                                    _record@1 = New,
                                    {focused_input,
                                        erlang:element(2, _record@1),
                                        erlang:element(3, _record@1),
                                        erlang:element(4, _record@1),
                                        erlang:element(5, _record@1),
                                        erlang:element(6, Old),
                                        erlang:element(7, Old),
                                        erlang:element(8, _record@1)}
                            end;

                        {New@1, _} ->
                            New@1
                    end,
                    {some, _pipe};

                false ->
                    focus_current(Xs, Focused)
            end
    end.

-file("src/shore/internal.gleam", 630).
?DOC(false).
-spec input_offset(integer(), integer(), integer()) -> integer().
input_offset(Cursor, Offset, Width) ->
    case Cursor of
        X when X < Offset ->
            Cursor;

        X@1 when X@1 >= (Offset + (Width - 3)) ->
            (Cursor - Width) + 3;

        _ ->
            Offset
    end.

-file("src/shore/internal.gleam", 638).
?DOC(false).
-spec string_insert(binary(), integer(), binary()) -> binary().
string_insert(Str, Cursor, Char) ->
    case Cursor of
        X when X =< 0 ->
            <<Char/binary, Str/binary>>;

        _ ->
            _pipe = Str,
            _pipe@1 = gleam@string:to_graphemes(_pipe),
            _pipe@2 = gleam@list:index_map(
                _pipe@1,
                fun(I, Idx) -> case Idx =:= (Cursor - 1) of
                        true ->
                            <<I/binary, Char/binary>>;

                        false ->
                            I
                    end end
            ),
            gleam@string:join(_pipe@2, <<""/utf8>>)
    end.

-file("src/shore/internal.gleam", 655).
?DOC(false).
-spec string_backspace(binary(), integer(), integer()) -> binary().
string_backspace(Str, Cursor, Offset) ->
    _pipe = Str,
    _pipe@1 = gleam@string:to_graphemes(_pipe),
    _pipe@2 = gleam@list:index_fold(
        _pipe@1,
        [],
        fun(Acc, I, Idx) -> case Idx =:= (Cursor + Offset) of
                true ->
                    Acc;

                false ->
                    [I | Acc]
            end end
    ),
    _pipe@3 = lists:reverse(_pipe@2),
    gleam@string:join(_pipe@3, <<""/utf8>>).

-file("src/shore/internal.gleam", 574).
?DOC(false).
-spec input_handler(focused(FHI), shore@key:key()) -> focused(FHI).
input_handler(Focused, Key) ->
    case Focused of
        {focused_input, _, _, _, _, _, _, _} = Focused@1 ->
            case Key of
                backspace ->
                    Cursor = gleam@int:max(0, erlang:element(6, Focused@1) - 1),
                    Offset = gleam@int:max(0, erlang:element(7, Focused@1) - 1),
                    _record = Focused@1,
                    {focused_input,
                        erlang:element(2, _record),
                        begin
                            _pipe = erlang:element(3, Focused@1),
                            string_backspace(
                                _pipe,
                                erlang:element(6, Focused@1),
                                -1
                            )
                        end,
                        erlang:element(4, _record),
                        erlang:element(5, _record),
                        Cursor,
                        Offset,
                        erlang:element(8, _record)};

                home ->
                    _record@1 = Focused@1,
                    {focused_input,
                        erlang:element(2, _record@1),
                        erlang:element(3, _record@1),
                        erlang:element(4, _record@1),
                        erlang:element(5, _record@1),
                        0,
                        erlang:element(7, _record@1),
                        erlang:element(8, _record@1)};

                'end' ->
                    _record@2 = Focused@1,
                    {focused_input,
                        erlang:element(2, _record@2),
                        erlang:element(3, _record@2),
                        erlang:element(4, _record@2),
                        erlang:element(5, _record@2),
                        string:length(erlang:element(3, Focused@1)),
                        erlang:element(7, _record@2),
                        erlang:element(8, _record@2)};

                right ->
                    Cursor@1 = gleam@int:min(
                        string:length(erlang:element(3, Focused@1)),
                        erlang:element(6, Focused@1) + 1
                    ),
                    Offset@1 = input_offset(
                        Cursor@1,
                        erlang:element(7, Focused@1),
                        erlang:element(8, Focused@1)
                    ),
                    _record@3 = Focused@1,
                    {focused_input,
                        erlang:element(2, _record@3),
                        erlang:element(3, _record@3),
                        erlang:element(4, _record@3),
                        erlang:element(5, _record@3),
                        Cursor@1,
                        Offset@1,
                        erlang:element(8, _record@3)};

                left ->
                    Cursor@2 = gleam@int:max(
                        0,
                        erlang:element(6, Focused@1) - 1
                    ),
                    Offset@2 = input_offset(
                        Cursor@2,
                        erlang:element(7, Focused@1),
                        erlang:element(8, Focused@1)
                    ),
                    _record@4 = Focused@1,
                    {focused_input,
                        erlang:element(2, _record@4),
                        erlang:element(3, _record@4),
                        erlang:element(4, _record@4),
                        erlang:element(5, _record@4),
                        Cursor@2,
                        Offset@2,
                        erlang:element(8, _record@4)};

                delete ->
                    Offset@3 = case erlang:element(6, Focused@1) =:= string:length(
                        erlang:element(3, Focused@1)
                    ) of
                        true ->
                            erlang:element(7, Focused@1);

                        false ->
                            gleam@int:max(0, erlang:element(7, Focused@1) - 1)
                    end,
                    _record@5 = Focused@1,
                    {focused_input,
                        erlang:element(2, _record@5),
                        begin
                            _pipe@1 = erlang:element(3, Focused@1),
                            string_backspace(
                                _pipe@1,
                                erlang:element(6, Focused@1),
                                0
                            )
                        end,
                        erlang:element(4, _record@5),
                        erlang:element(5, _record@5),
                        erlang:element(6, _record@5),
                        Offset@3,
                        erlang:element(8, _record@5)};

                {char, Char} ->
                    Cursor@3 = erlang:element(6, Focused@1) + string:length(
                        Char
                    ),
                    Offset@4 = input_offset(
                        Cursor@3,
                        erlang:element(7, Focused@1),
                        erlang:element(8, Focused@1)
                    ),
                    _record@6 = Focused@1,
                    {focused_input,
                        erlang:element(2, _record@6),
                        string_insert(
                            erlang:element(3, Focused@1),
                            erlang:element(6, Focused@1),
                            Char
                        ),
                        erlang:element(4, _record@6),
                        erlang:element(5, _record@6),
                        Cursor@3,
                        Offset@4,
                        erlang:element(8, _record@6)};

                _ ->
                    Focused@1
            end;

        {focused_button, _, _} = Button ->
            Button
    end.

-file("src/shore/internal.gleam", 678).
?DOC(false).
-spec control_event(shore@key:key(), keybinds()) -> gleam@option:option(control()).
control_event(Input, Keybinds) ->
    case Input of
        X when X =:= erlang:element(4, Keybinds) ->
            _pipe = focus_clear,
            {some, _pipe};

        X@1 when X@1 =:= erlang:element(5, Keybinds) ->
            _pipe@1 = focus_next,
            {some, _pipe@1};

        X@2 when X@2 =:= erlang:element(6, Keybinds) ->
            _pipe@2 = focus_prev,
            {some, _pipe@2};

        _ ->
            none
    end.

-file("src/shore/internal.gleam", 702).
?DOC(false).
-spec element_join_loop(list(element()), binary(), element()) -> element().
element_join_loop(Elements, Separator, Accumulator) ->
    case Elements of
        [] ->
            Accumulator;

        [Element | Elements@1] ->
            element_join_loop(
                Elements@1,
                Separator,
                {element,
                    <<<<(erlang:element(2, Accumulator))/binary,
                            Separator/binary>>/binary,
                        (erlang:element(2, Element))/binary>>,
                    erlang:element(3, Accumulator) + erlang:element(3, Element),
                    erlang:element(4, Accumulator) + erlang:element(4, Element)}
            )
    end.

-file("src/shore/internal.gleam", 695).
?DOC(false).
-spec element_join(list(element()), binary()) -> element().
element_join(Elements, Separator) ->
    case Elements of
        [] ->
            {element, <<""/utf8>>, 0, 0};

        [First | Rest] ->
            element_join_loop(Rest, Separator, First)
    end.

-file("src/shore/internal.gleam", 722).
?DOC(false).
-spec element_append(element(), element()) -> element().
element_append(First, Second) ->
    {element,
        <<(erlang:element(2, First))/binary,
            (erlang:element(2, Second))/binary>>,
        erlang:element(3, First) + erlang:element(3, Second),
        erlang:element(4, First) + erlang:element(4, Second)}.

-file("src/shore/internal.gleam", 730).
?DOC(false).
-spec element_prefix(element(), binary()) -> element().
element_prefix(Element, Prefix) ->
    _record = Element,
    {element,
        <<Prefix/binary, (erlang:element(2, Element))/binary>>,
        erlang:element(3, _record),
        erlang:element(4, _record)}.

-file("src/shore/internal.gleam", 1016).
?DOC(false).
-spec calc_size(shore@style:size(), integer()) -> integer().
calc_size(Size, Width) ->
    case Size of
        {px, Px} ->
            Px;

        {pct, Pct} ->
            (Width * Pct) div 100;

        fill ->
            Width
    end.

-file("src/shore/internal.gleam", 1024).
?DOC(false).
-spec calc_size_input(shore@style:size(), integer(), binary()) -> integer().
calc_size_input(Size, Width, Label) ->
    calc_size(Size, Width - string:length(Label)).

-file("src/shore/internal.gleam", 1052).
?DOC(false).
-spec right_is_left(shore@style:align()) -> shore@style:align().
right_is_left(Align) ->
    case Align of
        right ->
            left;

        X ->
            X
    end.

-file("src/shore/internal.gleam", 1066).
?DOC(false).
-spec middle(integer()) -> binary().
middle(Width) ->
    Fill = <<" "/utf8>>,
    _pipe = [<<"│"/utf8>>, gleam@string:repeat(Fill, Width), <<"│"/utf8>>],
    gleam@string:join(_pipe, <<""/utf8>>).

-file("src/shore/internal.gleam", 1121).
?DOC(false).
-spec text_wrap_loop(
    list(binary()),
    integer(),
    integer(),
    list(binary()),
    list(binary()),
    list(binary())
) -> list(binary()).
text_wrap_loop(Text, Width, Count, Word, Line, Acc) ->
    Append = fun(Word@1, Line@1, Acc@1) ->
        Line@2 = begin
            _pipe = lists:append(Word@1, Line@1),
            _pipe@1 = lists:reverse(_pipe),
            gleam@string:join(_pipe@1, <<""/utf8>>)
        end,
        [Line@2 | Acc@1]
    end,
    case Text of
        [<<"\n"/utf8>> | Xs] ->
            text_wrap_loop(Xs, Width, 0, [], [], Append(Word, Line, Acc));

        [<<" "/utf8>> | Xs@1] ->
            text_wrap_loop(
                Xs@1,
                Width,
                Count + 1,
                [],
                lists:append([<<" "/utf8>> | Word], Line),
                Acc
            );

        [X | Xs@2] ->
            case Count >= Width of
                true ->
                    text_wrap_loop(
                        lists:append(lists:reverse([X | Word]), Xs@2),
                        Width,
                        0,
                        [],
                        [],
                        Append([], Line, Acc)
                    );

                false ->
                    text_wrap_loop(
                        Xs@2,
                        Width,
                        Count + 1,
                        [X | Word],
                        Line,
                        Acc
                    )
            end;

        [] ->
            _pipe@2 = Append(Word, Line, Acc),
            lists:reverse(_pipe@2)
    end.

-file("src/shore/internal.gleam", 1114).
?DOC(false).
-spec text_wrap(binary(), text_wrap(), integer()) -> list(binary()).
text_wrap(Text, Wrap, Width) ->
    case Wrap of
        wrap ->
            text_wrap_loop(
                gleam@string:to_graphemes(Text),
                Width,
                0,
                [],
                [],
                []
            );

        no_wrap ->
            _pipe = Text,
            gleam@string:split(_pipe, <<"\n"/utf8>>)
    end.

-file("src/shore/internal.gleam", 1474).
?DOC(false).
-spec calc_cell_size(integer(), integer(), integer(), list(integer())) -> {integer(),
    integer()}.
calc_cell_size(Gap, From, To, Of) ->
    gleam@list:index_fold(Of, {1, 0}, fun(Acc, Item, Idx) -> case Idx of
                X when (X >= From) andalso (X =< To) ->
                    {erlang:element(1, Acc), erlang:element(2, Acc) + Item};

                X@1 when X@1 =:= (From - 1) ->
                    {(erlang:element(1, Acc) + Gap) + Item,
                        erlang:element(2, Acc) - Gap};

                X@2 when X@2 < From ->
                    {erlang:element(1, Acc) + Item, erlang:element(2, Acc)};

                _ ->
                    Acc
            end end).

-file("src/shore/internal.gleam", 1508).
?DOC(false).
-spec do_calc_sizes(
    list(gleam@option:option(integer())),
    integer(),
    integer(),
    list(integer())
) -> list(integer()).
do_calc_sizes(Sizes, Remainder_split, Round_up, Acc) ->
    case Sizes of
        [] ->
            lists:reverse(Acc);

        [X | Xs] ->
            case X of
                {some, Px} ->
                    _pipe = [Px | Acc],
                    do_calc_sizes(Xs, Remainder_split, Round_up, _pipe);

                none ->
                    _pipe@1 = [Remainder_split + Round_up | Acc],
                    do_calc_sizes(Xs, Remainder_split, 0, _pipe@1)
            end
    end.

-file("src/shore/internal.gleam", 1485).
?DOC(false).
-spec calc_sizes(integer(), list(shore@style:size())) -> list(integer()).
calc_sizes(Max, Sizes) ->
    First = gleam@list:map(Sizes, fun(Size) -> case Size of
                {px, Px} ->
                    {some, Px};

                {pct, Pct} ->
                    {some, (Max * Pct) div 100};

                fill ->
                    none
            end end),
    Total_known_size = gleam@list:fold(First, 0, fun(Acc, I) -> case I of
                {some, Px@1} ->
                    Acc + Px@1;

                none ->
                    Acc
            end end),
    Total_unknown_count = begin
        _pipe = First,
        _pipe@1 = gleam@list:filter(_pipe, fun gleam@option:is_none/1),
        erlang:length(_pipe@1)
    end,
    Remainder = Max - Total_known_size,
    Remainder_split = case Total_unknown_count of
        0 -> 0;
        Gleam@denominator -> Remainder div Gleam@denominator
    end,
    Round_up = Remainder - (Remainder_split * Total_unknown_count),
    do_calc_sizes(First, Remainder_split, Round_up, []).

-file("src/shore/internal.gleam", 1460).
?DOC(false).
-spec layout(layout(FIT), pos()) -> list({node_(FIT), pos()}).
layout(Layout, Pos) ->
    Col_sizes = begin
        _pipe = erlang:element(4, Layout),
        calc_sizes(erlang:element(4, Pos), _pipe)
    end,
    Row_sizes = begin
        _pipe@1 = erlang:element(3, Layout),
        calc_sizes(erlang:element(5, Pos), _pipe@1)
    end,
    _pipe@2 = erlang:element(5, Layout),
    gleam@list:map(
        _pipe@2,
        fun(Cell) ->
            {X, W} = calc_cell_size(
                erlang:element(2, Layout),
                erlang:element(1, erlang:element(4, Cell)),
                erlang:element(2, erlang:element(4, Cell)),
                Col_sizes
            ),
            {Y, H} = calc_cell_size(
                erlang:element(2, Layout),
                erlang:element(1, erlang:element(3, Cell)),
                erlang:element(2, erlang:element(3, Cell)),
                Row_sizes
            ),
            {erlang:element(2, Cell),
                {pos,
                    erlang:element(2, Pos) + X,
                    erlang:element(3, Pos) + Y,
                    W,
                    H,
                    left}}
        end
    ).

-file("src/shore/internal.gleam", 466).
?DOC(false).
-spec do_list_focusable(pos(), list(node_(FGP)), list(focused(FGP))) -> list(focused(FGP)).
do_list_focusable(Pos, Children, Acc) ->
    case Children of
        [] ->
            Acc;

        [X | Xs] ->
            case X of
                {row, Children@1} ->
                    do_list_focusable(
                        Pos,
                        Xs,
                        do_list_focusable(Pos, Children@1, Acc)
                    );

                {col, Children@1} ->
                    do_list_focusable(
                        Pos,
                        Xs,
                        do_list_focusable(Pos, Children@1, Acc)
                    );

                {box, Children@2, _, _} ->
                    Pos@1 = begin
                        _record = Pos,
                        {pos,
                            erlang:element(2, _record),
                            erlang:element(3, _record),
                            erlang:element(4, Pos) - 4,
                            erlang:element(5, Pos) - 2,
                            erlang:element(6, _record)}
                    end,
                    do_list_focusable(
                        Pos@1,
                        Xs,
                        do_list_focusable(Pos@1, Children@2, Acc)
                    );

                {aligned, _, Node} ->
                    do_list_focusable(
                        Pos,
                        Xs,
                        do_list_focusable(Pos, [Node], Acc)
                    );

                {layouts, L} ->
                    _pipe = layout(L, Pos),
                    _pipe@1 = gleam@list:map(
                        _pipe,
                        fun(I) ->
                            do_list_focusable(
                                erlang:element(2, I),
                                [erlang:element(1, I)],
                                Acc
                            )
                        end
                    ),
                    _pipe@2 = lists:reverse(_pipe@1),
                    gleam@list:flatten(_pipe@2);

                {input, Label, Value, Width, Event, Submit, _} ->
                    Cursor = string:length(Value),
                    Width@1 = calc_size_input(
                        Width,
                        erlang:element(4, Pos),
                        Label
                    ),
                    Focused = {focused_input,
                        Label,
                        Value,
                        Event,
                        Submit,
                        Cursor,
                        0,
                        Width@1},
                    Offset = input_offset(
                        Cursor,
                        erlang:element(7, Focused),
                        erlang:element(8, Focused)
                    ),
                    do_list_focusable(
                        Pos,
                        Xs,
                        [begin
                                _record@1 = Focused,
                                {focused_input,
                                    erlang:element(2, _record@1),
                                    erlang:element(3, _record@1),
                                    erlang:element(4, _record@1),
                                    erlang:element(5, _record@1),
                                    erlang:element(6, _record@1),
                                    Offset,
                                    erlang:element(8, _record@1)}
                            end |
                            Acc]
                    );

                {button, Id, _, _, Event@1, _, _, _, _} ->
                    do_list_focusable(
                        Pos,
                        Xs,
                        [{focused_button, Id, Event@1} | Acc]
                    );

                b_r ->
                    do_list_focusable(Pos, Xs, Acc);

                {bar, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {bar2, _, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                debug ->
                    do_list_focusable(Pos, Xs, Acc);

                h_r ->
                    do_list_focusable(Pos, Xs, Acc);

                {h_r2, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {key_bind, _, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {progress, _, _, _, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {table, _, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {table_k_v, _, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {graph, _, _, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {graphic, _} ->
                    do_list_focusable(Pos, Xs, Acc);

                {text_multi, _, _, _, _} ->
                    do_list_focusable(Pos, Xs, Acc)
            end
    end.

-file("src/shore/internal.gleam", 458).
?DOC(false).
-spec list_focusable(list(node_(FGH)), state(any(), FGH)) -> list(focused(FGH)).
list_focusable(Children, State) ->
    Pos = {pos, 0, 0, erlang:element(4, State), erlang:element(5, State), left},
    do_list_focusable(Pos, Children, []).

-file("src/shore/internal.gleam", 1592).
?DOC(false).
-spec ignore_zero(binary(), integer()) -> binary().
ignore_zero(Code, I) ->
    case I of
        0 ->
            <<""/utf8>>;

        _ ->
            Code
    end.

-file("src/shore/internal.gleam", 1622).
?DOC(false).
-spec kitty_action(kitty_action()) -> binary().
kitty_action(A) ->
    <<"a="/utf8, (case A of
            transmit_and_display ->
                <<"T"/utf8>>
        end)/binary>>.

-file("src/shore/internal.gleam", 1635).
?DOC(false).
-spec kitty_format(kitty_format()) -> binary().
kitty_format(F) ->
    <<"f="/utf8, (case F of
            r_g_b ->
                <<"24"/utf8>>;

            r_g_b_a ->
                <<"32"/utf8>>;

            p_n_g ->
                <<"100"/utf8>>
        end)/binary>>.

-file("src/shore/internal.gleam", 1644).
?DOC(false).
-spec kitty_payload(binary(), list(binary())) -> list(binary()).
kitty_payload(Base64, Acc) ->
    Size = 4096,
    case string:length(Base64) of
        Len when Len > Size ->
            Chunk = gleam@string:slice(Base64, 0, Size),
            Base64@1 = gleam@string:slice(Base64, Size, Len),
            kitty_payload(Base64@1, [Chunk | Acc]);

        _ ->
            lists:reverse([Base64 | Acc])
    end.

-file("src/shore/internal.gleam", 1695).
?DOC(false).
-spec graphic_to_string(graphic()) -> binary().
graphic_to_string(Graphic) ->
    case Graphic of
        bold ->
            <<"1"/utf8>>;

        faint ->
            <<"2"/utf8>>;

        italic ->
            <<"3"/utf8>>;

        underline ->
            <<"4"/utf8>>
    end.

-file("src/shore/internal.gleam", 1708).
?DOC(false).
-spec col(shore@style:color()) -> binary().
col(Color) ->
    case Color of
        black ->
            <<"0"/utf8>>;

        red ->
            <<"1"/utf8>>;

        green ->
            <<"2"/utf8>>;

        yellow ->
            <<"3"/utf8>>;

        blue ->
            <<"4"/utf8>>;

        magenta ->
            <<"5"/utf8>>;

        cyan ->
            <<"6"/utf8>>;

        white ->
            <<"7"/utf8>>
    end.

-file("src/shore/internal.gleam", 1730).
?DOC(false).
-spec raw_erl() -> do_not_leak().
raw_erl() ->
    shell:start_interactive({noshell, raw}).

-file("src/shore/internal.gleam", 166).
?DOC(false).
-spec default_resize(
    gleam@erlang@process:subject(event(any())),
    {integer(), integer()}
) -> nil.
default_resize(Shore, Size) ->
    Width@1 = case io:columns() of
        {ok, Width} -> Width;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"shore/internal"/utf8>>,
                        function => <<"default_resize"/utf8>>,
                        line => 167,
                        value => _assert_fail,
                        start => 3785,
                        'end' => 3826,
                        pattern_start => 3796,
                        pattern_end => 3805})
    end,
    Height@1 = case io:rows() of
        {ok, Height} -> Height;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"shore/internal"/utf8>>,
                        function => <<"default_resize"/utf8>>,
                        line => 168,
                        value => _assert_fail@1,
                        start => 3829,
                        'end' => 3868,
                        pattern_start => 3840,
                        pattern_end => 3850})
    end,
    New_size = {Width@1, Height@1},
    Size@1 = case Size =:= New_size of
        true ->
            Size;

        false ->
            gleam@erlang@process:send(
                Shore,
                {resize,
                    erlang:element(1, New_size),
                    erlang:element(2, New_size)}
            ),
            New_size
    end,
    gleam_erlang_ffi:sleep(16),
    default_resize(Shore, Size@1).

-file("src/shore/internal.gleam", 134).
?DOC(false).
-spec configure_renderer(
    gleam@option:option(gleam@erlang@process:subject(binary())),
    gleam@erlang@process:subject(event(any())),
    {integer(), integer()}
) -> {ok, gleam@erlang@process:subject(binary())} | {error, binary()}.
configure_renderer(Renderer, Shore, Size) ->
    case Renderer of
        {some, Renderer@1} ->
            {ok, Renderer@1};

        none ->
            case default_renderer() of
                {ok, {started, _, Renderer@2}} ->
                    raw_erl(),
                    proc_lib:spawn_link(
                        fun() -> default_resize(Shore, Size) end
                    ),
                    proc_lib:spawn_link(fun() -> read_input(Shore) end),
                    {ok, Renderer@2};

                {error, Error} ->
                    {error, gleam@string:inspect(Error)}
            end
    end.

-file("src/shore/internal.gleam", 1656).
?DOC(false).
-spec kitty_code(kitty_format(), boolean(), list(binary()), binary()) -> binary().
kitty_code(Format, Compress, Payload, Acc) ->
    Wrap = fun(M, Payload@1) ->
        <<<<<<<<<<<<<<<<<<<<"\x{001b}"/utf8, "_G"/utf8>>/binary,
                                            (kitty_action(transmit_and_display))/binary>>/binary,
                                        ","/utf8>>/binary,
                                    (kitty_format(Format))/binary>>/binary,
                                ","/utf8>>/binary,
                            M/binary>>/binary,
                        ";"/utf8>>/binary,
                    Payload@1/binary>>/binary,
                "\x{001b}"/utf8>>/binary,
            "\\"/utf8>>
    end,
    case Payload of
        [] ->
            Acc;

        [X] ->
            kitty_code(
                Format,
                Compress,
                [],
                <<Acc/binary, (Wrap(<<"m=0"/utf8>>, X))/binary>>
            );

        [X@1 | Xs] ->
            kitty_code(
                Format,
                Compress,
                Xs,
                <<Acc/binary, (Wrap(<<"m=1"/utf8>>, X@1))/binary>>
            )
    end.

-file("src/shore/internal.gleam", 1561).
?DOC(false).
-spec c(term_code()) -> binary().
c(Code) ->
    case Code of
        clear ->
            <<<<<<"\x{001b}"/utf8, "[2J"/utf8>>/binary, "\x{001b}"/utf8>>/binary,
                "[H"/utf8>>;

        top ->
            <<"\x{001b}"/utf8, "[H"/utf8>>;

        hide_cursor ->
            <<"\x{001b}"/utf8, "[?25l"/utf8>>;

        show_cursor ->
            <<"\x{001b}"/utf8, "[?25h"/utf8>>;

        {set_pos, X, Y} ->
            <<<<<<<<<<"\x{001b}"/utf8, "["/utf8>>/binary,
                            (erlang:integer_to_binary(X))/binary>>/binary,
                        ";"/utf8>>/binary,
                    (erlang:integer_to_binary(Y))/binary>>/binary,
                "H"/utf8>>;

        save_pos ->
            <<"\x{001b}"/utf8, "[s"/utf8>>;

        load_pos ->
            <<"\x{001b}"/utf8, "[u"/utf8>>;

        {move_up, I} ->
            _pipe = (<<<<<<"\x{001b}"/utf8, "["/utf8>>/binary,
                    (erlang:integer_to_binary(I))/binary>>/binary,
                "A"/utf8>>),
            ignore_zero(_pipe, I);

        {move_down, I@1} ->
            _pipe@1 = (<<<<<<"\x{001b}"/utf8, "["/utf8>>/binary,
                    (erlang:integer_to_binary(I@1))/binary>>/binary,
                "B"/utf8>>),
            ignore_zero(_pipe@1, I@1);

        {move_left, I@2} ->
            _pipe@2 = (<<<<<<"\x{001b}"/utf8, "["/utf8>>/binary,
                    (erlang:integer_to_binary(I@2))/binary>>/binary,
                "D"/utf8>>),
            ignore_zero(_pipe@2, I@2);

        {move_right, I@3} ->
            _pipe@3 = (<<<<<<"\x{001b}"/utf8, "["/utf8>>/binary,
                    (erlang:integer_to_binary(I@3))/binary>>/binary,
                "C"/utf8>>),
            ignore_zero(_pipe@3, I@3);

        start_line ->
            _pipe@4 = {column, 1},
            c(_pipe@4);

        {column, I@4} ->
            <<<<<<"\x{001b}"/utf8, "["/utf8>>/binary,
                    (erlang:integer_to_binary(I@4))/binary>>/binary,
                "G"/utf8>>;

        {fg, Color} ->
            <<<<<<"\x{001b}"/utf8, "[3"/utf8>>/binary, (col(Color))/binary>>/binary,
                "m"/utf8>>;

        {bg, Color@1} ->
            <<<<<<"\x{001b}"/utf8, "[4"/utf8>>/binary, (col(Color@1))/binary>>/binary,
                "m"/utf8>>;

        {s_g_r, Graphic} ->
            <<<<<<"\x{001b}"/utf8, "["/utf8>>/binary,
                    (graphic_to_string(Graphic))/binary>>/binary,
                "m"/utf8>>;

        reset ->
            <<"\x{001b}"/utf8, "[0m"/utf8>>;

        get_pos ->
            <<"\x{001b}"/utf8, "[6n"/utf8>>;

        alt_buffer ->
            <<"\x{001b}"/utf8, "[?1049h"/utf8>>;

        main_buffer ->
            <<"\x{001b}"/utf8, "[?1049l"/utf8>>;

        b_s_u ->
            <<"\x{001b}"/utf8, "[?2026h"/utf8>>;

        e_s_u ->
            <<"\x{001b}"/utf8, "[?2026l"/utf8>>;

        {graphics, Format, Compress, Payload} ->
            _pipe@5 = Payload,
            _pipe@6 = kitty_payload(_pipe@5, []),
            kitty_code(Format, Compress, _pipe@6, <<""/utf8>>)
    end.

-file("src/shore/internal.gleam", 940).
?DOC(false).
-spec sep(separator()) -> binary().
sep(Separator) ->
    case Separator of
        sep_row ->
            c({move_right, 1});

        sep_col ->
            <<<<(c(load_pos))/binary, (c({move_down, 1}))/binary>>/binary,
                (c(save_pos))/binary>>
    end.

-file("src/shore/internal.gleam", 1038).
?DOC(false).
-spec calc_align_len(binary(), shore@style:align(), integer(), integer()) -> binary().
calc_align_len(Text, Align, Width, Len) ->
    Center = (Width div 2) - (Len div 2),
    case Align of
        left ->
            Text;

        center ->
            <<<<<<(c(save_pos))/binary, (c({move_right, Center}))/binary>>/binary,
                    Text/binary>>/binary,
                (c(load_pos))/binary>>;

        right ->
            <<<<<<(c(save_pos))/binary, (c({move_right, Width - Len}))/binary>>/binary,
                    Text/binary>>/binary,
                (c(load_pos))/binary>>
    end.

-file("src/shore/internal.gleam", 1033).
?DOC(false).
-spec calc_align(binary(), shore@style:align(), integer()) -> binary().
calc_align(Text, Align, Width) ->
    Len = begin
        _pipe = Text,
        string:length(_pipe)
    end,
    calc_align_len(Text, Align, Width, Len).

-file("src/shore/internal.gleam", 1059).
?DOC(false).
-spec do_middle(integer(), integer(), list(binary())) -> binary().
do_middle(Width, Height, Acc) ->
    case Height of
        0 ->
            _pipe = Acc,
            gleam@string:join(
                _pipe,
                <<(c({move_left, Width + 2}))/binary,
                    (c({move_down, 1}))/binary>>
            );

        H ->
            do_middle(Width, H - 1, [middle(Width) | Acc])
    end.

-file("src/shore/internal.gleam", 1071).
?DOC(false).
-spec style_text(
    binary(),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color())
) -> binary().
style_text(Text, Fg, Bg) ->
    <<<<<<<<(c(reset))/binary,
                    (begin
                        _pipe = gleam@option:map(Fg, fun(O) -> c({fg, O}) end),
                        gleam@option:unwrap(_pipe, <<""/utf8>>)
                    end)/binary>>/binary,
                (begin
                    _pipe@1 = gleam@option:map(Bg, fun(O@1) -> c({bg, O@1}) end),
                    gleam@option:unwrap(_pipe@1, <<""/utf8>>)
                end)/binary>>/binary,
            Text/binary>>/binary,
        (c(reset))/binary>>.

-file("src/shore/internal.gleam", 1088).
?DOC(false).
-spec draw_text_multi(
    binary(),
    text_wrap(),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color()),
    pos()
) -> element().
draw_text_multi(Text, Wrap, Fg, Bg, Pos) ->
    Width = erlang:element(4, Pos) - 2,
    Height = erlang:element(5, Pos),
    Text@1 = <<<<<<(c(save_pos))/binary,
                (begin
                    _pipe = Text,
                    _pipe@1 = text_wrap(_pipe, Wrap, Width - 1),
                    _pipe@2 = gleam@list:take(_pipe@1, Height),
                    _pipe@3 = gleam@list:map(
                        _pipe@2,
                        fun(_capture) ->
                            gleam@string:slice(_capture, 0, Width)
                        end
                    ),
                    _pipe@4 = gleam@list:map(
                        _pipe@3,
                        fun(_capture@1) ->
                            calc_align(
                                _capture@1,
                                erlang:element(6, Pos),
                                erlang:element(4, Pos)
                            )
                        end
                    ),
                    gleam@string:join(
                        _pipe@4,
                        <<<<(c(load_pos))/binary, (c({move_down, 1}))/binary>>/binary,
                            (c(save_pos))/binary>>
                    )
                end)/binary>>/binary,
            (c(load_pos))/binary>>/binary,
        (c({move_down, 1}))/binary>>,
    _pipe@5 = Text@1,
    _pipe@6 = style_text(_pipe@5, Fg, Bg),
    {element, _pipe@6, Width, Height}.

-file("src/shore/internal.gleam", 1202).
?DOC(false).
-spec map_cursor(binary(), integer(), integer()) -> binary().
map_cursor(Str, Cursor, Width) ->
    Pos = begin
        _pipe = Cursor,
        gleam@int:min(_pipe, Width - 2)
    end,
    _pipe@1 = Str,
    _pipe@2 = gleam@string:to_graphemes(_pipe@1),
    _pipe@3 = gleam@list:index_map(_pipe@2, fun(I, Idx) -> case Idx =:= Pos of
                true ->
                    <<<<<<(c({bg, white}))/binary, (c({fg, black}))/binary>>/binary,
                            I/binary>>/binary,
                        (c(reset))/binary>>;

                false ->
                    I
            end end),
    gleam@string:join(_pipe@3, <<""/utf8>>).

-file("src/shore/internal.gleam", 1175).
?DOC(false).
-spec draw_input(iput()) -> element().
draw_input(Input) ->
    Color = case erlang:element(6, Input) of
        true ->
            _pipe = green,
            _pipe@1 = {fg, _pipe},
            c(_pipe@1);

        false ->
            _pipe@2 = blue,
            _pipe@3 = {fg, _pipe@2},
            c(_pipe@3)
    end,
    In_width = erlang:element(2, Input) - 2,
    Text = case erlang:element(9, Input) of
        true ->
            _pipe@4 = string:length(erlang:element(5, Input)),
            gleam@string:repeat(<<"•"/utf8>>, _pipe@4);

        false ->
            erlang:element(5, Input)
    end,
    Text@1 = <<Text/binary, " "/utf8>>,
    Text_trim = begin
        _pipe@5 = Text@1,
        _pipe@6 = gleam@string:slice(
            _pipe@5,
            erlang:element(8, Input),
            In_width
        ),
        (fun(X) -> case erlang:element(6, Input) of
                true ->
                    map_cursor(
                        X,
                        erlang:element(7, Input) - erlang:element(8, Input),
                        erlang:element(2, Input)
                    );

                false ->
                    X
            end end)(_pipe@6)
    end,
    _pipe@7 = [c(reset),
        Color,
        erlang:element(4, Input),
        <<" "/utf8>>,
        c(reset),
        Text_trim],
    _pipe@8 = gleam@string:join(_pipe@7, <<""/utf8>>),
    {element, _pipe@8, erlang:element(2, Input), erlang:element(3, Input)}.

-file("src/shore/internal.gleam", 1229).
?DOC(false).
-spec draw_btn(btn()) -> element().
draw_btn(Btn) ->
    Button = (<<<<"  "/utf8, (erlang:element(4, Btn))/binary>>/binary,
        "  "/utf8>>),
    Width = string:length(Button),
    Button@1 = begin
        _pipe = Button,
        calc_align(_pipe, erlang:element(6, Btn), erlang:element(2, Btn))
    end,
    Bg = case erlang:element(5, Btn) of
        false ->
            erlang:element(8, Btn);

        true ->
            erlang:element(10, Btn)
    end,
    Fg = case erlang:element(5, Btn) of
        false ->
            erlang:element(7, Btn);

        true ->
            erlang:element(9, Btn)
    end,
    _pipe@1 = Button@1,
    _pipe@2 = style_text(_pipe@1, Fg, Bg),
    {element, _pipe@2, Width, 1}.

-file("src/shore/internal.gleam", 1248).
?DOC(false).
-spec draw_box(
    integer(),
    integer(),
    gleam@option:option(binary()),
    gleam@option:option(shore@style:color())
) -> element().
draw_box(Width, Height, Title, Fg) ->
    Top = begin
        _pipe = case Title of
            {some, Title@1} ->
                [<<"╭"/utf8>>,
                    <<"─"/utf8>>,
                    <<" "/utf8>>,
                    Title@1,
                    <<" "/utf8>>,
                    gleam@string:repeat(
                        <<"─"/utf8>>,
                        (Width - 3) - string:length(Title@1)
                    ),
                    <<"╮"/utf8>>];

            none ->
                [<<"╭"/utf8>>,
                    gleam@string:repeat(<<"─"/utf8>>, Width),
                    <<"╮"/utf8>>]
        end,
        gleam@string:join(_pipe, <<""/utf8>>)
    end,
    Bottom = begin
        _pipe@1 = [<<"╰"/utf8>>,
            gleam@string:repeat(<<"─"/utf8>>, Width),
            <<"╯"/utf8>>],
        gleam@string:join(_pipe@1, <<""/utf8>>)
    end,
    Start = <<(c({move_left, Width + 2}))/binary, (c({move_down, 1}))/binary>>,
    _pipe@2 = [c(save_pos),
        Top,
        Start,
        do_middle(Width, Height, []),
        Start,
        Bottom,
        c(load_pos),
        c({move_right, 2}),
        c(save_pos)],
    _pipe@3 = gleam@string:join(_pipe@2, <<""/utf8>>),
    _pipe@4 = style_text(_pipe@3, Fg, none),
    {element, _pipe@4, Width, Height}.

-file("src/shore/internal.gleam", 1286).
?DOC(false).
-spec draw_progress(integer(), integer(), integer(), shore@style:color(), pos()) -> element().
draw_progress(Width, Max, Value, Color, Pos) ->
    Progress = case Max of
        0 -> 0;
        Gleam@denominator -> Value * 100 div Gleam@denominator
    end,
    Complete = begin
        _pipe = ((Progress * Width) div 100),
        gleam@int:clamp(_pipe, 0, Width)
    end,
    Rest = Width - Complete,
    Len = Complete + Rest,
    _pipe@1 = [c(reset),
        c({fg, Color}),
        gleam@string:repeat(<<"█"/utf8>>, Complete),
        c(reset),
        gleam@string:repeat(<<"░"/utf8>>, Rest)],
    _pipe@2 = gleam@string:join(_pipe@1, <<""/utf8>>),
    _pipe@3 = calc_align_len(
        _pipe@2,
        erlang:element(6, Pos),
        erlang:element(4, Pos),
        Len
    ),
    {element, _pipe@3, Width, 1}.

-file("src/shore/internal.gleam", 1309).
?DOC(false).
-spec draw_table(integer(), list(list(binary())), pos()) -> element().
draw_table(Width, Values, Pos) ->
    Width@1 = gleam@int:min(Width, erlang:element(4, Pos)),
    Row_count = begin
        _pipe = Values,
        erlang:length(_pipe)
    end,
    Height = gleam@int:min(Row_count, erlang:element(5, Pos)),
    Values@1 = gleam@list:take(Values, Height),
    Col_count = begin
        _pipe@1 = Values@1,
        _pipe@2 = gleam@list:first(_pipe@1),
        _pipe@3 = gleam@result:map(_pipe@2, fun erlang:length/1),
        gleam@result:unwrap(_pipe@3, 1)
    end,
    Col_width = case Col_count of
        0 -> 0;
        Gleam@denominator -> Width@1 div Gleam@denominator
    end,
    Col_left_over = Width@1 - (Col_width * Col_count),
    Start = <<(c({move_left, Width@1}))/binary, (c({move_down, 1}))/binary>>,
    Row@2 = fun(Row, Idx) ->
        _pipe@4 = gleam@list:map(Row, fun(Col) -> case string:length(Col) of
                    X when X >= Col_width ->
                        <<(gleam@string:slice(Col, 0, Col_width - 3))/binary,
                            ".. "/utf8>>;

                    X@1 ->
                        <<Col/binary,
                            (c({move_right, Col_width - X@1}))/binary>>
                end end),
        _pipe@5 = gleam@string:join(_pipe@4, <<""/utf8>>),
        (fun(Row@1) -> case Idx of
                0 ->
                    <<<<<<<<<<(c({s_g_r, bold}))/binary,
                                        (c({fg, blue}))/binary>>/binary,
                                    Row@1/binary>>/binary,
                                (c(reset))/binary>>/binary,
                            (c({move_right, Col_left_over}))/binary>>/binary,
                        Start/binary>>;

                _ ->
                    <<<<Row@1/binary, (c({move_right, Col_left_over}))/binary>>/binary,
                        Start/binary>>
            end end)(_pipe@5)
    end,
    Rows = begin
        _pipe@6 = Values@1,
        _pipe@7 = gleam@list:index_map(_pipe@6, Row@2),
        gleam@string:join(_pipe@7, <<""/utf8>>)
    end,
    Join_offset = begin
        _pipe@8 = [c({move_up, 1}), c(save_pos)],
        gleam@string:join(_pipe@8, <<""/utf8>>)
    end,
    _pipe@9 = [c(reset), Rows, Join_offset],
    _pipe@10 = gleam@string:join(_pipe@9, <<""/utf8>>),
    {element, _pipe@10, Width@1, Height}.

-file("src/shore/internal.gleam", 1347).
?DOC(false).
-spec draw_table_kv(integer(), list(list(binary())), pos()) -> element().
draw_table_kv(Width, Values, Pos) ->
    Width@1 = gleam@int:min(Width, erlang:element(4, Pos)),
    Row_count = begin
        _pipe = Values,
        erlang:length(_pipe)
    end,
    Height = gleam@int:min(Row_count, erlang:element(5, Pos)),
    Values@1 = gleam@list:take(Values, Height),
    Col_count = begin
        _pipe@1 = Values@1,
        _pipe@2 = gleam@list:first(_pipe@1),
        _pipe@3 = gleam@result:map(_pipe@2, fun erlang:length/1),
        gleam@result:unwrap(_pipe@3, 1)
    end,
    Col_width = case Col_count of
        0 -> 0;
        Gleam@denominator -> (Width@1) div Gleam@denominator
    end,
    Col_left_over = Width@1 - (Col_width * Col_count),
    Start = <<(c({move_left, Width@1}))/binary, (c({move_down, 1}))/binary>>,
    Row@2 = fun(Row) ->
        _pipe@4 = gleam@list:index_map(
            Row,
            fun(Col, Idx) ->
                Trim = case string:length(Col) of
                    X when X >= Col_width ->
                        <<(gleam@string:slice(Col, 0, Col_width - 3))/binary,
                            ".. "/utf8>>;

                    X@1 ->
                        <<Col/binary,
                            (c({move_right, Col_width - X@1}))/binary>>
                end,
                case Idx of
                    0 ->
                        <<<<<<(c({s_g_r, bold}))/binary,
                                    (c({fg, blue}))/binary>>/binary,
                                Trim/binary>>/binary,
                            (c(reset))/binary>>;

                    _ ->
                        Trim
                end
            end
        ),
        _pipe@5 = gleam@string:join(_pipe@4, <<""/utf8>>),
        (fun(Row@1) ->
            <<<<Row@1/binary, (c({move_right, Col_left_over}))/binary>>/binary,
                Start/binary>>
        end)(_pipe@5)
    end,
    Rows = begin
        _pipe@6 = Values@1,
        _pipe@7 = gleam@list:map(_pipe@6, Row@2),
        gleam@string:join(_pipe@7, <<""/utf8>>)
    end,
    Join_offset = begin
        _pipe@8 = [c({move_up, 1}), c(save_pos)],
        gleam@string:join(_pipe@8, <<""/utf8>>)
    end,
    _pipe@9 = [c(reset), Rows, Join_offset],
    _pipe@10 = gleam@string:join(_pipe@9, <<""/utf8>>),
    {element, _pipe@10, Width@1, Height}.

-file("src/shore/internal.gleam", 1379).
?DOC(false).
-spec draw_graph(integer(), integer(), list(float())) -> element().
draw_graph(Width, Height, Values) ->
    Values@1 = gleam@list:take(Values, Width),
    Lhs = gleam@string:repeat(
        <<<<"│"/utf8, (c({move_left, 1}))/binary>>/binary,
            (c({move_down, 1}))/binary>>,
        Height
    ),
    Btm = gleam@string:repeat(<<"─"/utf8>>, Width - 1),
    Content@1 = begin
        gleam@result:map(
            gleam@list:max(Values@1, fun gleam@float:compare/2),
            fun(Max) ->
                Plot = begin
                    _pipe = Values@1,
                    _pipe@2 = gleam@list:map(
                        _pipe,
                        fun(Value) ->
                            Height@1 = Height - 1,
                            Pct = (case Max of
                                +0.0 -> +0.0;
                                -0.0 -> -0.0;
                                Gleam@denominator -> Value / Gleam@denominator
                            end) * 100.0,
                            Offset = (erlang:float(Height@1) * Pct) / 100.0,
                            Down = erlang:float(Height@1) - Offset,
                            D = begin
                                _pipe@1 = Down,
                                erlang:round(_pipe@1)
                            end,
                            <<<<(c({move_down, D}))/binary, "•"/utf8>>/binary,
                                (c({move_up, D}))/binary>>
                        end
                    ),
                    gleam@string:join(_pipe@2, <<""/utf8>>)
                end,
                Content = begin
                    _pipe@3 = [c(reset),
                        c(save_pos),
                        Lhs,
                        c({move_up, 1}),
                        <<"╰"/utf8>>,
                        Btm,
                        c(load_pos),
                        c(save_pos),
                        c({move_right, 1}),
                        Plot,
                        c(load_pos),
                        c({move_down, Height - 1}),
                        c(save_pos),
                        c(reset)],
                    gleam@string:join(_pipe@3, <<""/utf8>>)
                end,
                {element, Content, Width, Height}
            end
        )
    end,
    case Content@1 of
        {ok, Content@2} ->
            Content@2;

        {error, nil} ->
            {element, <<"error finding max"/utf8>>, 5, 1}
    end.

-file("src/shore/internal.gleam", 1424).
?DOC(false).
-spec draw_graphic(binary()) -> element().
draw_graphic(Payload) ->
    {element, c({graphics, p_n_g, false, Payload}), 10, 10}.

-file("src/shore/internal.gleam", 764).
?DOC(false).
-spec render_node(state(any(), FHW), node_(FHW), shore@key:key(), pos()) -> gleam@option:option(element()).
render_node(State, Node, Last_input, Pos) ->
    case Node of
        {layouts, L} ->
            _pipe = layout(L, Pos),
            _pipe@2 = gleam@list:map(
                _pipe,
                fun(I) ->
                    Cursor = c(
                        {set_pos,
                            erlang:element(3, (erlang:element(2, I))),
                            erlang:element(2, (erlang:element(2, I)))}
                    ),
                    _pipe@1 = render_node(
                        State,
                        erlang:element(1, I),
                        Last_input,
                        erlang:element(2, I)
                    ),
                    gleam@option:map(
                        _pipe@1,
                        fun(R) -> element_prefix(R, Cursor) end
                    )
                end
            ),
            _pipe@3 = gleam@option:values(_pipe@2),
            _pipe@4 = element_join(_pipe@3, <<""/utf8>>),
            {some, _pipe@4};

        debug ->
            Content = gleam@string:inspect(Pos),
            Width = string:length(Content),
            _pipe@5 = {element, Content, Width, 1},
            {some, _pipe@5};

        {aligned, Align, Node@1} ->
            render_node(
                State,
                Node@1,
                Last_input,
                begin
                    _record = Pos,
                    {pos,
                        erlang:element(2, _record),
                        erlang:element(3, _record),
                        erlang:element(4, _record),
                        erlang:element(5, _record),
                        Align}
                end
            );

        {row, Children} ->
            Len = begin
                _pipe@6 = Children,
                erlang:length(_pipe@6)
            end,
            Width@1 = case Len of
                0 -> 0;
                Gleam@denominator -> erlang:element(4, Pos) div Gleam@denominator
            end,
            _pipe@8 = gleam@list:index_map(
                Children,
                fun(Child, Idx) ->
                    X = Idx * Width@1,
                    New_pos = begin
                        _record@1 = Pos,
                        {pos,
                            X,
                            erlang:element(3, _record@1),
                            Width@1,
                            erlang:element(5, _record@1),
                            right_is_left(erlang:element(6, Pos))}
                    end,
                    _pipe@7 = render_node(State, Child, Last_input, New_pos),
                    gleam@option:map(
                        _pipe@7,
                        fun(R@1) ->
                            Move = case erlang:element(6, Pos) of
                                center ->
                                    c({move_right, X});

                                left ->
                                    <<""/utf8>>;

                                right ->
                                    <<""/utf8>>
                            end,
                            element_prefix(R@1, Move)
                        end
                    )
                end
            ),
            _pipe@9 = gleam@option:values(_pipe@8),
            _pipe@10 = element_join(_pipe@9, sep(sep_row)),
            _pipe@12 = (fun(Ele) -> _pipe@11 = case erlang:element(6, Pos) of
                    right ->
                        c(
                            {move_right,
                                (erlang:element(4, Pos) - erlang:element(3, Ele))
                                - (Len - 1)}
                        );

                    left ->
                        <<""/utf8>>;

                    center ->
                        <<""/utf8>>
                end,
                element_prefix(Ele, _pipe@11) end)(_pipe@10),
            {some, _pipe@12};

        {col, Children@1} ->
            _pipe@13 = gleam@list:map(
                Children@1,
                fun(_capture) ->
                    render_node(State, _capture, Last_input, Pos)
                end
            ),
            _pipe@14 = gleam@option:values(_pipe@13),
            _pipe@15 = element_join(_pipe@14, sep(sep_col)),
            _pipe@16 = element_prefix(_pipe@15, c(save_pos)),
            {some, _pipe@16};

        {box, Children@2, Title, Fg} ->
            Pos@1 = begin
                _record@2 = Pos,
                {pos,
                    erlang:element(2, _record@2),
                    erlang:element(3, _record@2),
                    erlang:element(4, Pos) - 3,
                    erlang:element(5, Pos) - 2,
                    erlang:element(6, _record@2)}
            end,
            Pos_child = begin
                _record@3 = Pos@1,
                {pos,
                    erlang:element(2, _record@3),
                    erlang:element(3, _record@3),
                    erlang:element(4, Pos@1) - 2,
                    erlang:element(5, _record@3),
                    erlang:element(6, _record@3)}
            end,
            _pipe@18 = [draw_box(
                    gleam@int:max(erlang:element(4, Pos@1), 1),
                    gleam@int:max(erlang:element(5, Pos@1), 1),
                    Title,
                    Fg
                ) |
                begin
                    _pipe@17 = gleam@list:map(
                        Children@2,
                        fun(_capture@1) ->
                            render_node(
                                State,
                                _capture@1,
                                Last_input,
                                Pos_child
                            )
                        end
                    ),
                    gleam@option:values(_pipe@17)
                end],
            _pipe@19 = element_join(_pipe@18, sep(sep_col)),
            {some, _pipe@19};

        {table, Width@2, Table} ->
            Width@3 = calc_size(Width@2, erlang:element(4, Pos)),
            _pipe@20 = draw_table(
                gleam@int:min(Width@3, erlang:element(4, Pos)),
                Table,
                Pos
            ),
            {some, _pipe@20};

        {table_k_v, Width@4, Table@1} ->
            Width@5 = calc_size(Width@4, erlang:element(4, Pos)),
            _pipe@21 = draw_table_kv(
                gleam@int:min(Width@5, erlang:element(4, Pos)),
                Table@1,
                Pos
            ),
            {some, _pipe@21};

        {graph, Width@6, Height, Points} ->
            _pipe@22 = draw_graph(
                calc_size(Width@6, erlang:element(4, Pos)),
                calc_size(Height, erlang:element(5, Pos)),
                Points
            ),
            {some, _pipe@22};

        {button, Id, Text, Key, _, Fg@1, Bg, Focus_fg, Focus_bg} ->
            Is_focused = case erlang:element(7, State) of
                {some, {focused_button, _, _} = Focused} when erlang:element(
                    2,
                    Focused
                ) =:= Id ->
                    true;

                _ ->
                    false
            end,
            _pipe@23 = draw_btn(
                {btn,
                    erlang:element(4, Pos),
                    1,
                    Text,
                    (Last_input =:= Key) orelse Is_focused,
                    erlang:element(6, Pos),
                    Fg@1,
                    Bg,
                    Focus_fg,
                    Focus_bg}
            ),
            {some, _pipe@23};

        {key_bind, _, _} ->
            none;

        {input, Label, Value, Width@7, _, _, Hidden} ->
            Width@8 = calc_size_input(Width@7, erlang:element(4, Pos), Label),
            {Is_focused@1, Cursor@1} = case erlang:element(7, State) of
                {some, {focused_input, _, _, _, _, _, _, _} = Focused@1} when erlang:element(
                    2,
                    Focused@1
                ) =:= Label ->
                    {true, erlang:element(6, Focused@1)};

                _ ->
                    {false, string:length(Value)}
            end,
            Offset = case erlang:element(7, State) of
                {some, {focused_input, _, _, _, _, _, _, _} = Focused@2} when erlang:element(
                    2,
                    Focused@2
                ) =:= Label ->
                    erlang:element(7, Focused@2);

                _ ->
                    input_offset(string:length(Value), 0, Width@8)
            end,
            _pipe@24 = draw_input(
                {iput,
                    Width@8,
                    1,
                    Label,
                    Value,
                    Is_focused@1,
                    Cursor@1,
                    Offset,
                    Hidden}
            ),
            {some, _pipe@24};

        {text_multi, Text@1, Wrap, Fg@2, Bg@1} ->
            _pipe@25 = draw_text_multi(Text@1, Wrap, Fg@2, Bg@1, Pos),
            {some, _pipe@25};

        h_r ->
            _pipe@26 = (<<(c(reset))/binary,
                (gleam@string:repeat(<<"─"/utf8>>, erlang:element(4, Pos)))/binary>>),
            _pipe@27 = {element, _pipe@26, erlang:element(4, Pos), 1},
            {some, _pipe@27};

        {h_r2, Color} ->
            _pipe@28 = (<<<<<<(c(reset))/binary, (c({fg, Color}))/binary>>/binary,
                    (gleam@string:repeat(<<"─"/utf8>>, erlang:element(4, Pos)))/binary>>/binary,
                (c(reset))/binary>>),
            _pipe@29 = {element, _pipe@28, erlang:element(4, Pos), 1},
            {some, _pipe@29};

        {bar, Color@1} ->
            _pipe@30 = [c(save_pos),
                c(reset),
                c({bg, Color@1}),
                gleam@string:repeat(<<" "/utf8>>, erlang:element(4, Pos)),
                c(reset),
                c(load_pos)],
            _pipe@31 = gleam@string:join(_pipe@30, <<""/utf8>>),
            _pipe@32 = {element, _pipe@31, erlang:element(4, Pos), 1},
            {some, _pipe@32};

        {bar2, Color@2, Node@2} ->
            Bar = begin
                _pipe@33 = [c(save_pos),
                    c(reset),
                    c({bg, Color@2}),
                    gleam@string:repeat(<<" "/utf8>>, erlang:element(4, Pos)),
                    c(reset),
                    c(load_pos)],
                gleam@string:join(_pipe@33, <<""/utf8>>)
            end,
            _pipe@34 = render_node(State, Node@2, Last_input, Pos),
            gleam@option:map(
                _pipe@34,
                fun(_capture@2) -> element_prefix(_capture@2, Bar) end
            );

        b_r ->
            _pipe@35 = <<"\n"/utf8>>,
            _pipe@36 = {element, _pipe@35, erlang:element(4, Pos), 1},
            {some, _pipe@36};

        {progress, Width@9, Max, Value@1, Color@3} ->
            Width@10 = calc_size(Width@9, erlang:element(4, Pos)),
            _pipe@37 = draw_progress(Width@10, Max, Value@1, Color@3, Pos),
            {some, _pipe@37};

        {graphic, Payload} ->
            _pipe@38 = draw_graphic(Payload),
            {some, _pipe@38}
    end.

-file("src/shore/internal.gleam", 742).
?DOC(false).
-spec render(state(FHO, FHP), node_(FHP), shore@key:key()) -> state(FHO, FHP).
render(State, Node, Last_input) ->
    Pos = {pos, 0, 0, erlang:element(4, State), erlang:element(5, State), left},
    Frame = <<(c(clear))/binary,
        (begin
            _pipe = Node,
            _pipe@1 = render_node(State, _pipe, Last_input, Pos),
            _pipe@2 = gleam@option:map(
                _pipe@1,
                fun(R) -> erlang:element(2, R) end
            ),
            gleam@option:unwrap(_pipe@2, <<""/utf8>>)
        end)/binary>>,
    Render = [c(b_s_u), Frame, c(e_s_u)],
    case Frame /= erlang:element(9, State) of
        true ->
            _pipe@3 = Render,
            gleam@list:each(
                _pipe@3,
                fun(_capture) ->
                    gleam@erlang@process:send(
                        erlang:element(8, State),
                        _capture
                    )
                end
            ),
            _record = State,
            {state,
                erlang:element(2, _record),
                erlang:element(3, _record),
                erlang:element(4, _record),
                erlang:element(5, _record),
                erlang:element(6, _record),
                erlang:element(7, _record),
                erlang:element(8, _record),
                Frame};

        false ->
            State
    end.

-file("src/shore/internal.gleam", 432).
?DOC(false).
-spec redraw(state(FFR, FFS), shore@key:key()) -> state(FFR, FFS).
redraw(State, Input) ->
    _pipe = erlang:element(3, State),
    _pipe@1 = (erlang:element(3, erlang:element(2, State)))(_pipe),
    render(State, _pipe@1, Input).

-file("src/shore/internal.gleam", 436).
?DOC(false).
-spec redraw_on_update(state(FFX, FFY), shore@key:key()) -> state(FFX, FFY).
redraw_on_update(State, Input) ->
    case erlang:element(7, erlang:element(2, State)) of
        on_update ->
            redraw(State, Input);

        {on_timer, _} ->
            State
    end.

-file("src/shore/internal.gleam", 1599).
?DOC(false).
-spec init_terminal() -> binary().
init_terminal() ->
    <<(c(hide_cursor))/binary, (c(alt_buffer))/binary>>.

-file("src/shore/internal.gleam", 1603).
?DOC(false).
-spec restore_terminal() -> binary().
restore_terminal() ->
    <<(c(show_cursor))/binary, (c(main_buffer))/binary>>.

-file("src/shore/internal.gleam", 386).
?DOC(false).
-spec do_detect_event(state(any(), FFC), list(node_(FFC)), shore@key:key()) -> gleam@option:option(FFC).
do_detect_event(State, Children, Input) ->
    case Children of
        [] ->
            none;

        [X | Xs] ->
            case detect_event(State, X, Input) of
                {some, Msg} ->
                    {some, Msg};

                none ->
                    do_detect_event(State, Xs, Input)
            end
    end.

-file("src/shore/internal.gleam", 352).
?DOC(false).
-spec detect_event(state(any(), FEW), node_(FEW), shore@key:key()) -> gleam@option:option(FEW).
detect_event(State, Node, Input) ->
    case Node of
        {button, _, _, Key, Event, _, _, _, _} when Input =:= Key ->
            {some, Event};

        {button, _, _, _, _, _, _, _, _} ->
            none;

        {key_bind, Key@1, Event@1} when Input =:= Key@1 ->
            {some, Event@1};

        {key_bind, _, _} ->
            none;

        {aligned, _, Node@1} ->
            detect_event(State, Node@1, Input);

        {bar2, _, Node@1} ->
            detect_event(State, Node@1, Input);

        {row, Children} ->
            do_detect_event(State, Children, Input);

        {col, Children} ->
            do_detect_event(State, Children, Input);

        {box, Children, _, _} ->
            do_detect_event(State, Children, Input);

        {layouts, Layout} ->
            _pipe = erlang:element(5, Layout),
            _pipe@1 = gleam@list:map(
                _pipe,
                fun(Cell) ->
                    detect_event(State, erlang:element(2, Cell), Input)
                end
            ),
            _pipe@2 = gleam@option:values(_pipe@1),
            _pipe@3 = gleam@list:first(_pipe@2),
            gleam@option:from_result(_pipe@3);

        {input, _, _, _, _, _, _} ->
            none;

        h_r ->
            none;

        {h_r2, _} ->
            none;

        {bar, _} ->
            none;

        b_r ->
            none;

        {progress, _, _, _, _} ->
            none;

        {table, _, _} ->
            none;

        {table_k_v, _, _} ->
            none;

        {graph, _, _, _} ->
            none;

        {text_multi, _, _, _, _} ->
            none;

        {graphic, _} ->
            none;

        debug ->
            none
    end.

-file("src/shore/internal.gleam", 229).
?DOC(false).
-spec shore_loop(state(FEL, FEM), event(FEM)) -> gleam@otp@actor:next(state(FEL, FEM), event(FEM)).
shore_loop(State, Event) ->
    Exit = erlang:element(2, erlang:element(6, erlang:element(2, State))),
    case Event of
        {cmd, Msg} ->
            {Model, Tasks} = (erlang:element(4, erlang:element(2, State)))(
                erlang:element(3, State),
                Msg
            ),
            _pipe = Tasks,
            task_handler(_pipe, erlang:element(6, State)),
            State@1 = begin
                _record = State,
                {state,
                    erlang:element(2, _record),
                    Model,
                    erlang:element(4, _record),
                    erlang:element(5, _record),
                    erlang:element(6, _record),
                    erlang:element(7, _record),
                    erlang:element(8, _record),
                    erlang:element(9, _record)}
            end,
            State@2 = redraw_on_update(State@1, null),
            gleam@otp@actor:continue(State@2);

        {key_press, Input} when Input =:= Exit ->
            shore_loop(State, exit);

        {key_press, Input@1} ->
            Ui = (erlang:element(3, erlang:element(2, State)))(
                erlang:element(3, State)
            ),
            State@3 = case erlang:element(7, State) of
                none ->
                    Model@2 = case detect_event(State, Ui, Input@1) of
                        {some, Msg@1} ->
                            {Model@1, Tasks@1} = (erlang:element(
                                4,
                                erlang:element(2, State)
                            ))(erlang:element(3, State), Msg@1),
                            _pipe@1 = Tasks@1,
                            task_handler(_pipe@1, erlang:element(6, State)),
                            Model@1;

                        none ->
                            erlang:element(3, State)
                    end,
                    _record@1 = State,
                    {state,
                        erlang:element(2, _record@1),
                        Model@2,
                        erlang:element(4, _record@1),
                        erlang:element(5, _record@1),
                        erlang:element(6, _record@1),
                        erlang:element(7, _record@1),
                        erlang:element(8, _record@1),
                        erlang:element(9, _record@1)};

                {some, Focused} ->
                    Reload = begin
                        _pipe@2 = list_focusable([Ui], State),
                        focus_current(_pipe@2, Focused)
                    end,
                    case Reload of
                        {some, Focused@1} ->
                            case input_handler(Focused@1, Input@1) of
                                {focused_input, _, _, _, _, _, _, _} = Focused@2 ->
                                    case {Input@1 =:= erlang:element(
                                            3,
                                            erlang:element(
                                                6,
                                                erlang:element(2, State)
                                            )
                                        ),
                                        erlang:element(5, Focused@2)} of
                                        {true, {some, Event@1}} ->
                                            {Model@3, Tasks@2} = (erlang:element(
                                                4,
                                                erlang:element(2, State)
                                            ))(
                                                erlang:element(3, State),
                                                Event@1
                                            ),
                                            Reload@1 = begin
                                                _pipe@3 = list_focusable(
                                                    [(erlang:element(
                                                            3,
                                                            erlang:element(
                                                                2,
                                                                State
                                                            )
                                                        ))(Model@3)],
                                                    State
                                                ),
                                                focus_current(
                                                    _pipe@3,
                                                    Focused@2
                                                )
                                            end,
                                            _pipe@4 = Tasks@2,
                                            task_handler(
                                                _pipe@4,
                                                erlang:element(6, State)
                                            ),
                                            _record@2 = State,
                                            {state,
                                                erlang:element(2, _record@2),
                                                Model@3,
                                                erlang:element(4, _record@2),
                                                erlang:element(5, _record@2),
                                                erlang:element(6, _record@2),
                                                Reload@1,
                                                erlang:element(8, _record@2),
                                                erlang:element(9, _record@2)};

                                        {_, _} ->
                                            {Model@4, Tasks@3} = (erlang:element(
                                                4,
                                                erlang:element(2, State)
                                            ))(
                                                erlang:element(3, State),
                                                (erlang:element(4, Focused@2))(
                                                    erlang:element(3, Focused@2)
                                                )
                                            ),
                                            _pipe@5 = Tasks@3,
                                            task_handler(
                                                _pipe@5,
                                                erlang:element(6, State)
                                            ),
                                            _record@3 = State,
                                            {state,
                                                erlang:element(2, _record@3),
                                                Model@4,
                                                erlang:element(4, _record@3),
                                                erlang:element(5, _record@3),
                                                erlang:element(6, _record@3),
                                                {some, Focused@2},
                                                erlang:element(8, _record@3),
                                                erlang:element(9, _record@3)}
                                    end;

                                {focused_button, _, _} = Focused@3 ->
                                    case Input@1 =:= erlang:element(
                                        3,
                                        erlang:element(
                                            6,
                                            erlang:element(2, State)
                                        )
                                    ) of
                                        true ->
                                            {Model@5, Tasks@4} = (erlang:element(
                                                4,
                                                erlang:element(2, State)
                                            ))(
                                                erlang:element(3, State),
                                                erlang:element(3, Focused@3)
                                            ),
                                            Reload@2 = begin
                                                _pipe@6 = list_focusable(
                                                    [(erlang:element(
                                                            3,
                                                            erlang:element(
                                                                2,
                                                                State
                                                            )
                                                        ))(Model@5)],
                                                    State
                                                ),
                                                focus_current(
                                                    _pipe@6,
                                                    Focused@3
                                                )
                                            end,
                                            _pipe@7 = Tasks@4,
                                            task_handler(
                                                _pipe@7,
                                                erlang:element(6, State)
                                            ),
                                            _record@4 = State,
                                            {state,
                                                erlang:element(2, _record@4),
                                                Model@5,
                                                erlang:element(4, _record@4),
                                                erlang:element(5, _record@4),
                                                erlang:element(6, _record@4),
                                                Reload@2,
                                                erlang:element(8, _record@4),
                                                erlang:element(9, _record@4)};

                                        false ->
                                            State
                                    end
                            end;

                        none ->
                            _record@5 = State,
                            {state,
                                erlang:element(2, _record@5),
                                erlang:element(3, _record@5),
                                erlang:element(4, _record@5),
                                erlang:element(5, _record@5),
                                erlang:element(6, _record@5),
                                none,
                                erlang:element(8, _record@5),
                                erlang:element(9, _record@5)}
                    end
            end,
            State@4 = case control_event(
                Input@1,
                erlang:element(6, erlang:element(2, State@3))
            ) of
                {some, focus_clear} ->
                    _record@6 = State@3,
                    {state,
                        erlang:element(2, _record@6),
                        erlang:element(3, _record@6),
                        erlang:element(4, _record@6),
                        erlang:element(5, _record@6),
                        erlang:element(6, _record@6),
                        none,
                        erlang:element(8, _record@6),
                        erlang:element(9, _record@6)};

                {some, focus_prev} ->
                    Focusable = list_focusable([Ui], State@3),
                    Focused@4 = case erlang:element(7, State@3) of
                        none ->
                            _pipe@8 = Focusable,
                            _pipe@9 = gleam@list:first(_pipe@8),
                            gleam@option:from_result(_pipe@9);

                        {some, X} ->
                            _pipe@10 = Focusable,
                            focus_next(_pipe@10, X, false)
                    end,
                    _record@7 = State@3,
                    {state,
                        erlang:element(2, _record@7),
                        erlang:element(3, _record@7),
                        erlang:element(4, _record@7),
                        erlang:element(5, _record@7),
                        erlang:element(6, _record@7),
                        Focused@4,
                        erlang:element(8, _record@7),
                        erlang:element(9, _record@7)};

                {some, focus_next} ->
                    Focusable@1 = begin
                        _pipe@11 = list_focusable([Ui], State@3),
                        lists:reverse(_pipe@11)
                    end,
                    Focused@5 = case erlang:element(7, State@3) of
                        none ->
                            _pipe@12 = Focusable@1,
                            _pipe@13 = gleam@list:first(_pipe@12),
                            gleam@option:from_result(_pipe@13);

                        {some, X@1} ->
                            _pipe@14 = Focusable@1,
                            focus_next(_pipe@14, X@1, false)
                    end,
                    _record@8 = State@3,
                    {state,
                        erlang:element(2, _record@8),
                        erlang:element(3, _record@8),
                        erlang:element(4, _record@8),
                        erlang:element(5, _record@8),
                        erlang:element(6, _record@8),
                        Focused@5,
                        erlang:element(8, _record@8),
                        erlang:element(9, _record@8)};

                none ->
                    State@3
            end,
            State@5 = redraw_on_update(State@4, Input@1),
            gleam@otp@actor:continue(State@5);

        redraw ->
            State@6 = redraw(State, null),
            gleam@otp@actor:continue(State@6);

        {resize, Width, Height} ->
            State@7 = begin
                _record@9 = State,
                {state,
                    erlang:element(2, _record@9),
                    erlang:element(3, _record@9),
                    Width,
                    Height,
                    erlang:element(6, _record@9),
                    erlang:element(7, _record@9),
                    erlang:element(8, _record@9),
                    erlang:element(9, _record@9)}
            end,
            gleam@otp@actor:continue(State@7);

        exit ->
            gleam@otp@actor:send(erlang:element(8, State), restore_terminal()),
            gleam_erlang_ffi:sleep(16),
            gleam@otp@actor:send(
                erlang:element(5, erlang:element(2, State)),
                nil
            ),
            gleam@otp@actor:stop()
    end.

-file("src/shore/internal.gleam", 88).
?DOC(false).
-spec shore_start(
    spec(any(), FCZ),
    gleam@option:option(gleam@erlang@process:subject(binary()))
) -> {ok, gleam@otp@actor:started(gleam@erlang@process:subject(event(FCZ)))} |
    {error, gleam@otp@actor:start_error()}.
shore_start(Spec, Renderer) ->
    _pipe@9 = gleam@otp@actor:new_with_initialiser(
        1000,
        fun(Tasks) ->
            Subj = gleam@erlang@process:new_subject(),
            {Model, Task_init} = (erlang:element(2, Spec))(Subj),
            Width@1 = case io:columns() of
                {ok, Width} -> Width;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                                file => <<?FILEPATH/utf8>>,
                                module => <<"shore/internal"/utf8>>,
                                function => <<"shore_start"/utf8>>,
                                line => 95,
                                value => _assert_fail,
                                start => 2000,
                                'end' => 2041,
                                pattern_start => 2011,
                                pattern_end => 2020})
            end,
            Height@1 = case io:rows() of
                {ok, Height} -> Height;
                _assert_fail@1 ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                                file => <<?FILEPATH/utf8>>,
                                module => <<"shore/internal"/utf8>>,
                                function => <<"shore_start"/utf8>>,
                                line => 96,
                                value => _assert_fail@1,
                                start => 2046,
                                'end' => 2085,
                                pattern_start => 2057,
                                pattern_end => 2067})
            end,
            gleam@result:'try'(
                configure_renderer(Renderer, Tasks, {Width@1, Height@1}),
                fun(Renderer@1) ->
                    State = {state,
                        Spec,
                        Model,
                        Width@1,
                        Height@1,
                        Tasks,
                        none,
                        Renderer@1,
                        <<""/utf8>>},
                    gleam@otp@actor:send(Renderer@1, init_terminal()),
                    State@1 = begin
                        _pipe = Model,
                        _pipe@1 = (erlang:element(3, Spec))(_pipe),
                        render(State, _pipe@1, null)
                    end,
                    _pipe@2 = Task_init,
                    task_handler(_pipe@2, Tasks),
                    Selector = begin
                        _pipe@3 = gleam_erlang_ffi:new_selector(),
                        _pipe@4 = gleam@erlang@process:select(_pipe@3, Tasks),
                        gleam@erlang@process:select_map(
                            _pipe@4,
                            Subj,
                            fun(Field@0) -> {cmd, Field@0} end
                        )
                    end,
                    _pipe@5 = State@1,
                    _pipe@6 = gleam@otp@actor:initialised(_pipe@5),
                    _pipe@7 = gleam@otp@actor:selecting(_pipe@6, Selector),
                    _pipe@8 = gleam@otp@actor:returning(_pipe@7, Tasks),
                    {ok, _pipe@8}
                end
            )
        end
    ),
    _pipe@10 = gleam@otp@actor:on_message(_pipe@9, fun shore_loop/2),
    gleam@otp@actor:start(_pipe@10).

-file("src/shore/internal.gleam", 79).
?DOC(false).
-spec start_custom_renderer(
    spec(any(), FCP),
    gleam@option:option(gleam@erlang@process:subject(binary()))
) -> {ok, gleam@erlang@process:subject(event(FCP))} |
    {error, gleam@otp@actor:start_error()}.
start_custom_renderer(Spec, Renderer) ->
    gleam@result:map(
        shore_start(Spec, Renderer),
        fun(_use0) ->
            {started, _, Shore} = _use0,
            redraw_on_timer(Spec, Shore),
            Shore
        end
    ).

-file("src/shore/internal.gleam", 68).
?DOC(false).
-spec start(spec(any(), FCH)) -> {ok, gleam@erlang@process:subject(event(FCH))} |
    {error, gleam@otp@actor:start_error()}.
start(Spec) ->
    start_custom_renderer(Spec, none).
