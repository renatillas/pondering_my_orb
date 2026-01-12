-module(shore@key).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).
-define(FILEPATH, "src/shore/key.gleam").
-export([from_string/1]).
-export_type([key/0]).

-type key() :: backspace |
    enter |
    left |
    right |
    up |
    down |
    home |
    'end' |
    page_up |
    page_down |
    tab |
    back_tab |
    delete |
    insert |
    {f, integer()} |
    {char, binary()} |
    null |
    esc |
    {ctrl, binary()}.

-file("src/shore/key.gleam", 36).
-spec from_string(binary()) -> key().
from_string(Key) ->
    case Key of
        <<"\x{0007F}"/utf8>> ->
            backspace;

        <<"\r"/utf8>> ->
            enter;

        <<"\x{001B}[D"/utf8>> ->
            left;

        <<"\x{001B}[C"/utf8>> ->
            right;

        <<"\x{001B}[A"/utf8>> ->
            up;

        <<"\x{001B}[B"/utf8>> ->
            down;

        <<"\x{001B}[H"/utf8>> ->
            home;

        <<"\x{001B}[F"/utf8>> ->
            'end';

        <<"\x{001B}[5~"/utf8>> ->
            page_up;

        <<"\x{001B}[6~"/utf8>> ->
            page_down;

        <<"\t"/utf8>> ->
            tab;

        <<"\x{001B}[Z"/utf8>> ->
            back_tab;

        <<"\x{001B}[3~"/utf8>> ->
            delete;

        <<"\x{001B}[2~"/utf8>> ->
            insert;

        <<"\x{001B}"/utf8>> ->
            esc;

        <<""/utf8>> ->
            null;

        <<"\x{001B}OP"/utf8>> ->
            {f, 1};

        <<"\x{001B}OQ"/utf8>> ->
            {f, 2};

        <<"\x{001B}OR"/utf8>> ->
            {f, 3};

        <<"\x{001B}OS"/utf8>> ->
            {f, 4};

        <<"\x{001B}[15~"/utf8>> ->
            {f, 5};

        <<"\x{001B}[17~"/utf8>> ->
            {f, 6};

        <<"\x{001B}[18~"/utf8>> ->
            {f, 7};

        <<"\x{001B}[19~"/utf8>> ->
            {f, 8};

        <<"\x{001B}[20~"/utf8>> ->
            {f, 9};

        <<"\x{001B}[21~"/utf8>> ->
            {f, 10};

        <<"\x{001B}[23~"/utf8>> ->
            {f, 11};

        <<"\x{001B}[24~"/utf8>> ->
            {f, 12};

        <<"\x{0001}"/utf8>> ->
            {ctrl, <<"A"/utf8>>};

        <<"\x{0002}"/utf8>> ->
            {ctrl, <<"B"/utf8>>};

        <<"\x{0003}"/utf8>> ->
            {ctrl, <<"C"/utf8>>};

        <<"\x{0004}"/utf8>> ->
            {ctrl, <<"D"/utf8>>};

        <<"\x{0005}"/utf8>> ->
            {ctrl, <<"E"/utf8>>};

        <<"\x{0006}"/utf8>> ->
            {ctrl, <<"F"/utf8>>};

        <<"\x{0007}"/utf8>> ->
            {ctrl, <<"G"/utf8>>};

        <<"\x{0008}"/utf8>> ->
            {ctrl, <<"H"/utf8>>};

        <<"\x{000B}"/utf8>> ->
            {ctrl, <<"K"/utf8>>};

        <<"\x{000C}"/utf8>> ->
            {ctrl, <<"L"/utf8>>};

        <<"\x{000E}"/utf8>> ->
            {ctrl, <<"N"/utf8>>};

        <<"\x{000F}"/utf8>> ->
            {ctrl, <<"O"/utf8>>};

        <<"\x{0010}"/utf8>> ->
            {ctrl, <<"P"/utf8>>};

        <<"\x{0011}"/utf8>> ->
            {ctrl, <<"Q"/utf8>>};

        <<"\x{0012}"/utf8>> ->
            {ctrl, <<"R"/utf8>>};

        <<"\x{0013}"/utf8>> ->
            {ctrl, <<"S"/utf8>>};

        <<"\x{0014}"/utf8>> ->
            {ctrl, <<"T"/utf8>>};

        <<"\x{0015}"/utf8>> ->
            {ctrl, <<"U"/utf8>>};

        <<"\x{0016}"/utf8>> ->
            {ctrl, <<"V"/utf8>>};

        <<"\x{0017}"/utf8>> ->
            {ctrl, <<"W"/utf8>>};

        <<"\x{0018}"/utf8>> ->
            {ctrl, <<"X"/utf8>>};

        <<"\x{0019}"/utf8>> ->
            {ctrl, <<"Y"/utf8>>};

        <<"\x{001A}"/utf8>> ->
            {ctrl, <<"Z"/utf8>>};

        X ->
            {char, X}
    end.
