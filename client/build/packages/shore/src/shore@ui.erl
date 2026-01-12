-module(shore@ui).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).
-define(FILEPATH, "src/shore/ui.gleam").
-export([align/2, bar/1, bar2/2, box/2, box_styled/3, br/0, button/3, button_styled/7, button_id/4, button_id_styled/8, col/1, debug/0, graph/3, hr/0, hr_styled/1, input/4, input_hidden/4, input_submit/6, keybind/2, progress/4, row/1, table/2, table_kv/2, text/1, text_wrapped/1, text_styled/3, text_wrapped_styled/3, image_unstable/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/shore/ui.gleam", 7).
?DOC(" Sets alignment of all child nodes\n").
-spec align(shore@style:align(), shore@internal:node_(HFE)) -> shore@internal:node_(HFE).
align(Alignment, Node) ->
    {aligned, Alignment, Node}.

-file("src/shore/ui.gleam", 12).
?DOC(" A row with a background color\n").
-spec bar(shore@style:color()) -> shore@internal:node_(any()).
bar(Color) ->
    {bar, Color}.

-file("src/shore/ui.gleam", 17).
?DOC(" A row with a background color, containing items\n").
-spec bar2(shore@style:color(), shore@internal:node_(HFJ)) -> shore@internal:node_(HFJ).
bar2(Color, Node) ->
    {bar2, Color, Node}.

-file("src/shore/ui.gleam", 22).
?DOC(" A box container element for holding other nodes\n").
-spec box(list(shore@internal:node_(HFM)), gleam@option:option(binary())) -> shore@internal:node_(HFM).
box(Children, Title) ->
    {box, Children, Title, none}.

-file("src/shore/ui.gleam", 29).
?DOC(
    " A box container element for holding other nodes.\n"
    "\n"
    " Can be provided with a custom colour for the outline and title.\n"
).
-spec box_styled(
    list(shore@internal:node_(HFR)),
    gleam@option:option(binary()),
    gleam@option:option(shore@style:color())
) -> shore@internal:node_(HFR).
box_styled(Children, Title, Fg) ->
    {box, Children, Title, Fg}.

-file("src/shore/ui.gleam", 38).
?DOC(" An empty line\n").
-spec br() -> shore@internal:node_(any()).
br() ->
    b_r.

-file("src/shore/ui.gleam", 43).
?DOC(" A button assigned to a key press to execute an event\n").
-spec button(binary(), shore@key:key(), HFZ) -> shore@internal:node_(HFZ).
button(Text, Key, Event) ->
    {button,
        Text,
        Text,
        Key,
        Event,
        {some, black},
        {some, blue},
        {some, black},
        {some, green}}.

-file("src/shore/ui.gleam", 67).
?DOC(
    " A button assigned to a key press to execute an event.\n"
    " Can be provided with custom colours both for when focused/pressed or not.\n"
    "\n"
    " Default colors for buttons are:\n"
    " ```gleam\n"
    "  fg: Some(style.Black),\n"
    "  bg: Some(style.Blue),\n"
    "  focus_fg: Some(style.Black),\n"
    "  focus_bg: Some(style.Green),\n"
    " ```\n"
).
-spec button_styled(
    binary(),
    shore@key:key(),
    HGB,
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color())
) -> shore@internal:node_(HGB).
button_styled(Text, Key, Event, Fg, Bg, Focus_fg, Focus_bg) ->
    {button, Text, Text, Key, Event, Fg, Bg, Focus_fg, Focus_bg}.

-file("src/shore/ui.gleam", 84).
?DOC(
    " A button assigned to a key press to execute an event\n"
    "\n"
    " Takes an `id` value which uniquely identifies it, allowing two buttons to\n"
    " share the same display text but operate independently, contrary to a\n"
    " button, where the text is the id and so all button text must be unique.\n"
).
-spec button_id(binary(), binary(), shore@key:key(), HGH) -> shore@internal:node_(HGH).
button_id(Id, Text, Key, Event) ->
    {button,
        Id,
        Text,
        Key,
        Event,
        {some, black},
        {some, blue},
        {some, black},
        {some, green}}.

-file("src/shore/ui.gleam", 113).
?DOC(
    " A button assigned to a key press to execute an event.\n"
    "\n"
    " Takes an `id` value which uniquely identifies it, allowing two buttons to\n"
    " share the same display text but operate independently, contrary to a\n"
    " button, where the text is the id and so all button text must be unique.\n"
    "\n"
    " Can be provided with custom colours both for when focused/pressed or not.\n"
    "\n"
    " Default colors for buttons are:\n"
    " ```gleam\n"
    "  fg: Some(style.Black),\n"
    "  bg: Some(style.Blue),\n"
    "  focus_fg: Some(style.Black),\n"
    "  focus_bg: Some(style.Green),\n"
    " ```\n"
).
-spec button_id_styled(
    binary(),
    binary(),
    shore@key:key(),
    HGJ,
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color())
) -> shore@internal:node_(HGJ).
button_id_styled(Id, Text, Key, Event, Fg, Bg, Focus_fg, Focus_bg) ->
    {button, Id, Text, Key, Event, Fg, Bg, Focus_fg, Focus_bg}.

-file("src/shore/ui.gleam", 127).
?DOC(" A container element for holding other nodes over multiple lines\n").
-spec col(list(shore@internal:node_(HGP))) -> shore@internal:node_(HGP).
col(Children) ->
    {col, Children}.

-file("src/shore/ui.gleam", 132).
?DOC(" Prints some positional information for developer debugging\n").
-spec debug() -> shore@internal:node_(any()).
debug() ->
    debug.

-file("src/shore/ui.gleam", 137).
?DOC(" An extremely simple plot\n").
-spec graph(shore@style:size(), shore@style:size(), list(float())) -> shore@internal:node_(any()).
graph(Width, Height, Points) ->
    {graph, Width, Height, Points}.

-file("src/shore/ui.gleam", 146).
?DOC(" A horizontal line\n").
-spec hr() -> shore@internal:node_(any()).
hr() ->
    h_r.

-file("src/shore/ui.gleam", 151).
?DOC(" A colored horizontal line\n").
-spec hr_styled(shore@style:color()) -> shore@internal:node_(any()).
hr_styled(Color) ->
    {h_r2, Color}.

-file("src/shore/ui.gleam", 156).
?DOC(" A field for text input\n").
-spec input(binary(), binary(), shore@style:size(), fun((binary()) -> HHC)) -> shore@internal:node_(HHC).
input(Label, Value, Width, Event) ->
    {input, Label, Value, Width, Event, none, false}.

-file("src/shore/ui.gleam", 166).
?DOC(" A field for text input with the content display hidden, useful for password fields\n").
-spec input_hidden(
    binary(),
    binary(),
    shore@style:size(),
    fun((binary()) -> HHE)
) -> shore@internal:node_(HHE).
input_hidden(Label, Value, Width, Event) ->
    {input, Label, Value, Width, Event, none, true}.

-file("src/shore/ui.gleam", 181).
?DOC(
    " A field for text input. Allows setting a `submit` event which can be\n"
    " triggered by the submit keybind while the field is currently focused.\n"
    "\n"
    " Useful for scenarios where a separate submit button would be inconvenient,\n"
    " such as a chat box or 2fa prompt.\n"
).
-spec input_submit(
    binary(),
    binary(),
    shore@style:size(),
    fun((binary()) -> HHG),
    HHG,
    boolean()
) -> shore@internal:node_(HHG).
input_submit(Label, Value, Width, Event, Submit, Hidden) ->
    {input, Label, Value, Width, Event, {some, Submit}, Hidden}.

-file("src/shore/ui.gleam", 193).
?DOC(" A non-visible button assigned to a key press to execute an event\n").
-spec keybind(shore@key:key(), HHI) -> shore@internal:node_(HHI).
keybind(Key, Event) ->
    {key_bind, Key, Event}.

-file("src/shore/ui.gleam", 198).
?DOC(" A progress bar, will automatically calculate fill percent based off max and current values\n").
-spec progress(shore@style:size(), integer(), integer(), shore@style:color()) -> shore@internal:node_(any()).
progress(Width, Max, Value, Color) ->
    {progress, Width, Max, Value, Color}.

-file("src/shore/ui.gleam", 208).
?DOC(" A container element for holding other nodes in a single line\n").
-spec row(list(shore@internal:node_(HHM))) -> shore@internal:node_(HHM).
row(Children) ->
    {row, Children}.

-file("src/shore/ui.gleam", 213).
?DOC(" A table layout\n").
-spec table(shore@style:size(), list(list(binary()))) -> shore@internal:node_(any()).
table(Width, Table) ->
    {table, Width, Table}.

-file("src/shore/ui.gleam", 218).
?DOC(" A Key-Value style table layout\n").
-spec table_kv(shore@style:size(), list(list(binary()))) -> shore@internal:node_(any()).
table_kv(Width, Table) ->
    {table_k_v, Width, Table}.

-file("src/shore/ui.gleam", 223).
?DOC(" A text string\n").
-spec text(binary()) -> shore@internal:node_(any()).
text(Text) ->
    {text_multi, Text, no_wrap, none, none}.

-file("src/shore/ui.gleam", 228).
?DOC(" A text string with automatic line wrapping\n").
-spec text_wrapped(binary()) -> shore@internal:node_(any()).
text_wrapped(Text) ->
    {text_multi, Text, wrap, none, none}.

-file("src/shore/ui.gleam", 233).
?DOC(" A text string with colored foreground and/or background\n").
-spec text_styled(
    binary(),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color())
) -> shore@internal:node_(any()).
text_styled(Text, Fg, Bg) ->
    {text_multi, Text, no_wrap, Fg, Bg}.

-file("src/shore/ui.gleam", 242).
?DOC(" A text string with automatic line wrapping and colored foreground and/or background\n").
-spec text_wrapped_styled(
    binary(),
    gleam@option:option(shore@style:color()),
    gleam@option:option(shore@style:color())
) -> shore@internal:node_(any()).
text_wrapped_styled(Text, Fg, Bg) ->
    {text_multi, Text, wrap, Fg, Bg}.

-file("src/shore/ui.gleam", 261).
?DOC(
    " UNSTABLE: A base64 encoded png image drawn using the Kitty Graphics Protocol\n"
    "\n"
    " This is currently a unstable implementation/exploration of using the kitty graphics protocol, some general notes are:\n"
    " - visually large pngs and file sizes over 500kb~ have performance issues\n"
    " - performance is typically even worse in render on_timer mode as it will redraw the images every frame\n"
    " - size of image is not detected for purposes of layout, as such, it should probably be in its own grid cell\n"
    " - only pngs stored as a base64 string are supported\n"
    " - only some terminals support this protocol\n"
    " - this function is likely to change significantly as the implementation of image support is refined\n"
    " - expect bugs\n"
).
-spec image_unstable(binary()) -> shore@internal:node_(any()).
image_unstable(Base64) ->
    {graphic, Base64}.
