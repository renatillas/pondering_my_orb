-module(shore).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).
-define(FILEPATH, "src/shore.gleam").
-export([spec_with_subject/6, spec/6, start/1, keybinds/5, default_keybinds/0, send/1, exit/0, on_timer/1, on_update/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/shore.gleam", 77).
?DOC(
    " A variant of `spec` which provides a subject of the shore actor to the\n"
    " `init` function. Messages can be send to your application through this\n"
    " subject via `actor.send`\n"
).
-spec spec_with_subject(
    fun((gleam@erlang@process:subject(HCO)) -> {HCQ, list(fun(() -> HCO))}),
    fun((HCQ) -> shore@internal:node_(HCO)),
    fun((HCQ, HCO) -> {HCQ, list(fun(() -> HCO))}),
    gleam@erlang@process:subject(nil),
    shore@internal:keybinds(),
    shore@internal:redraw()
) -> shore@internal:spec(HCQ, HCO).
spec_with_subject(Init, View, Update, Exit, Keybinds, Redraw) ->
    {spec, Init, View, Update, Exit, Keybinds, Redraw}.

-file("src/shore.gleam", 55).
?DOC(
    " A shore application is made up of these base parts. Following The Elm\n"
    " Architecture, you must define an init, view and update function which shore\n"
    " will handle calling.\n"
    "\n"
    " Additionally, a simple subject to pass the exit call to is required.\n"
    " keybinding for the framework level events such as exiting and ui focusing.\n"
    " And finally redraw for defining when the applicaiton should be redrawn, either on update messages or on a timer.\n"
    "\n"
    " `init` and `update` functions second argument `List(fn() -> Msg)` is an\n"
    " \"effects handler\". You can pass effectful/blocking code here such as\n"
    " requests to databases, file system io, network requests and they will be\n"
    " automatically passed to a separate, unlinked, erlang process which will call\n"
    " update for you on their return. See the `reader` example for practical usage\n"
    " examples.\n"
    "\n"
    " ## Example\n"
    " ```\n"
    " import gleam/erlang/process\n"
    " import shore\n"
    "\n"
    " pub fn main() {\n"
    "   let exit = process.new_subject()\n"
    "   let assert Ok(_actor) =\n"
    "     shore.spec(\n"
    "       init:,\n"
    "       update:,\n"
    "       view:,\n"
    "       exit:,\n"
    "       keybinds: shore.default_keybinds(),\n"
    "       redraw: shore.on_timer(16),\n"
    "     )\n"
    "     |> shore.start\n"
    "   exit |> process.receive_forever\n"
    " }\n"
    "\n"
    " ```\n"
).
-spec spec(
    fun(() -> {HCG, list(fun(() -> HCH))}),
    fun((HCG) -> shore@internal:node_(HCH)),
    fun((HCG, HCH) -> {HCG, list(fun(() -> HCH))}),
    gleam@erlang@process:subject(nil),
    shore@internal:keybinds(),
    shore@internal:redraw()
) -> shore@internal:spec(HCG, HCH).
spec(Init, View, Update, Exit, Keybinds, Redraw) ->
    spec_with_subject(
        fun(_) -> Init() end,
        View,
        Update,
        Exit,
        Keybinds,
        Redraw
    ).

-file("src/shore.gleam", 89).
?DOC(" Starts the application actor and returns its subject\n").
-spec start(shore@internal:spec(any(), HCY)) -> {ok,
        gleam@erlang@process:subject(shore@internal:event(HCY))} |
    {error, gleam@otp@actor:start_error()}.
start(Spec) ->
    shore@internal:start(Spec).

-file("src/shore.gleam", 98).
?DOC(
    " Set keybinds for various shore level functions, such as moving between\n"
    " focusable elements such as input boxes and buttons, as well as exiting and\n"
    " triggering button events.\n"
).
-spec keybinds(
    shore@key:key(),
    shore@key:key(),
    shore@key:key(),
    shore@key:key(),
    shore@key:key()
) -> shore@internal:keybinds().
keybinds(Exit, Submit, Focus_clear, Focus_next, Focus_prev) ->
    {keybinds, Exit, Submit, Focus_clear, Focus_next, Focus_prev}.

-file("src/shore.gleam", 115).
?DOC(
    " A typical set of keybindings\n"
    "\n"
    " - exit: `ctrl+x`\n"
    " - submit: `enter`\n"
    " - focus_clear: `escape`\n"
    " - focus_next: `tab`\n"
    " - focus_prev: `shift+tab`\n"
).
-spec default_keybinds() -> shore@internal:keybinds().
default_keybinds() ->
    {keybinds, {ctrl, <<"X"/utf8>>}, enter, esc, tab, back_tab}.

-file("src/shore.gleam", 133).
?DOC(
    " Allows sending a message to your TUI from another actor. This can be used,\n"
    " for example, to push an event to your TUI, rather than have it poll.\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " actor.send(shore, shore.send(MyMsg))\n"
    " ```\n"
).
-spec send(HDF) -> shore@internal:event(HDF).
send(Msg) ->
    shore@internal:send(Msg).

-file("src/shore.gleam", 145).
?DOC(
    " Manually trigger the exit for your TUI. Normally this would be handled\n"
    " through the exit keybind.\n"
    "\n"
    " ## Example\n"
    " ```gleam\n"
    " actor.send(shore, shore.exit())\n"
    " ```\n"
).
-spec exit() -> shore@internal:event(any()).
exit() ->
    shore@internal:exit().

-file("src/shore.gleam", 150).
?DOC(" Redraw every x milliseconds\n").
-spec on_timer(integer()) -> shore@internal:redraw().
on_timer(Ms) ->
    {on_timer, Ms}.

-file("src/shore.gleam", 155).
?DOC(" Redraw in response to events. Suitable for infrequently changing state.\n").
-spec on_update() -> shore@internal:redraw().
on_update() ->
    on_update.
