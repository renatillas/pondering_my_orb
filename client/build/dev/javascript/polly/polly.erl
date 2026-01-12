-module(polly).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/polly.gleam").
-export([add_dir/2, add_file/2, max_depth/2, interval/2, filter/2, default_filter/2, new/0, ignore_initial_missing/1, add_callback/2, add_subject/2, stop/1, describe_errors/1, watch/1, supervised/1, factory/0]).
-export_type([event/0, options/0, watcher/0, vfs/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type event() :: {created, binary()} |
    {changed, binary()} |
    {deleted, binary()} |
    {error, binary(), simplifile:file_error()}.

-opaque options() :: {options,
        integer(),
        list(binary()),
        integer(),
        fun((simplifile:file_type(), binary()) -> boolean()),
        boolean(),
        list(fun((event()) -> nil))}.

-opaque watcher() :: {watcher, fun(() -> nil)}.

-type vfs() :: {file, binary(), integer()} |
    {folder, binary(), integer(), list(vfs())}.

-file("src/polly.gleam", 103).
?DOC(
    " Tell Polly which directory to watch. If it does not exist, `watch` will return an error.\n"
    "\n"
    " If the directory goes away after watching has started, Polly will continue to\n"
    " check on it to see if it came back.\n"
    "\n"
    " Paths are not expanded by default, so the paths reported by events and passed\n"
    " to the filter function will be prefixed with whatever you specified here.\n"
).
-spec add_dir(options(), binary()) -> options().
add_dir(Options, Path) ->
    {options,
        erlang:element(2, Options),
        [Path | erlang:element(3, Options)],
        erlang:element(4, Options),
        erlang:element(5, Options),
        erlang:element(6, Options),
        erlang:element(7, Options)}.

-file("src/polly.gleam", 111).
?DOC(
    " Tell Polly to watch a single file.\n"
    "\n"
    " Polly doesn't care if you tell her to watch a file or directory, but\n"
    " using this function makes your intent clearer!\n"
).
-spec add_file(options(), binary()) -> options().
add_file(Options, Path) ->
    add_dir(Options, Path).

-file("src/polly.gleam", 126).
?DOC(
    " Limit the maximum depth that Polly will walk each directory.\n"
    "\n"
    " A limit of `0` would mean that Polly _only_ watches the specified list of\n"
    " files or directories. A limit of `1` means that she will also look at the\n"
    " files inside the given directories, but not at any nested directories.\n"
    "\n"
    " There is no limit by default, but setting a limit might be good to\n"
    " better control resource usage of the watcher.\n"
    "\n"
    " Calling this function multiple times will cause polly to only remember the\n"
    " lowest limit provided.\n"
).
-spec max_depth(options(), integer()) -> options().
max_depth(Options, Max_depth) ->
    case (erlang:element(4, Options) < 0) orelse (Max_depth < erlang:element(
        4,
        Options
    )) of
        true ->
            {options,
                erlang:element(2, Options),
                erlang:element(3, Options),
                Max_depth,
                erlang:element(5, Options),
                erlang:element(6, Options),
                erlang:element(7, Options)};

        false ->
            Options
    end.

-file("src/polly.gleam", 140).
?DOC(
    " Set the interval in-between file-system polls, in milliseconds.\n"
    "\n"
    " This is the time that Polly rests between calls, so if scanning your directory\n"
    " tree takes 100ms, and you configured 1000ms here, the total time between calls\n"
    " will roughly be 1100ms.\n"
    "\n"
    " Doing it this way makes sure that Polly doesn't stumble over herself.\n"
).
-spec interval(options(), integer()) -> options().
interval(Options, Interval) ->
    case Interval > 0 of
        true ->
            {options,
                Interval,
                erlang:element(3, Options),
                erlang:element(4, Options),
                erlang:element(5, Options),
                erlang:element(6, Options),
                erlang:element(7, Options)};

        false ->
            Options
    end.

-file("src/polly.gleam", 159).
?DOC(
    " Filter files using the given predicate.\n"
    "\n"
    " Polly will ignore files and directories for which the predicate returns `False`\n"
    " completely, and any event happening for them or for a contained file of them\n"
    " will not get reported.\n"
    "\n"
    " Keep in mind that the filter is checked for every part of a path, not just\n"
    " leaf nodes! So for example, if you have a path `./src/app.gleam`, your filter\n"
    " function will first be called on `.`, then on `./src`, and then finally on\n"
    " `./src/app.gleam`.\n"
    "\n"
    " By default, all hidden files are ignored by using the `default_filter`.\n"
).
-spec filter(options(), fun((simplifile:file_type(), binary()) -> boolean())) -> options().
filter(Options, Filter) ->
    {options,
        erlang:element(2, Options),
        erlang:element(3, Options),
        erlang:element(4, Options),
        Filter,
        erlang:element(6, Options),
        erlang:element(7, Options)}.

-file("src/polly.gleam", 164).
?DOC(" The default filter function, ignoring hidden files starting with a colon `\".\"`\n").
-spec default_filter(simplifile:file_type(), binary()) -> boolean().
default_filter(_, Path) ->
    case filepath:base_name(Path) of
        <<"."/utf8>> ->
            true;

        <<".."/utf8>> ->
            true;

        Basename ->
            not gleam_stdlib:string_starts_with(Basename, <<"."/utf8>>)
    end.

-file("src/polly.gleam", 85).
?DOC(
    " Start creating a new configuration using the default options.\n"
    "\n"
    " By default, an interval of 1 second is set, and the `default_filter` is used.\n"
).
-spec new() -> options().
new() ->
    {options, 1000, [], -1, fun default_filter/2, false, []}.

-file("src/polly.gleam", 179).
?DOC(
    " Tell Polly that it is fine if a file or directory does not exist initially.\n"
    "\n"
    " By default, if a file or directory cannot be found when calling `watch`,\n"
    " Polly will immediately return to you with an `Enoent` error and refuse to run.\n"
    "\n"
    " When this option is active, Polly will instead note the missing directory,\n"
    " and continuously check if it appears, similarly to how she does after a\n"
    " file or directory goes away after she has first seen it.\n"
).
-spec ignore_initial_missing(options()) -> options().
ignore_initial_missing(Options) ->
    {options,
        erlang:element(2, Options),
        erlang:element(3, Options),
        erlang:element(4, Options),
        erlang:element(5, Options),
        true,
        erlang:element(7, Options)}.

-file("src/polly.gleam", 188).
?DOC(
    " Add a callback function that Polly will call whenever she spots an event.\n"
    "\n"
    " You can add multiple callbacks, and Polly will call them all in the order\n"
    " you added them. The callbacks are called synchronously while she's collecting\n"
    " change events, so it's a good idea to keep them light and fast!\n"
).
-spec add_callback(options(), fun((event()) -> nil)) -> options().
add_callback(Options, Callback) ->
    {options,
        erlang:element(2, Options),
        erlang:element(3, Options),
        erlang:element(4, Options),
        erlang:element(5, Options),
        erlang:element(6, Options),
        [Callback | erlang:element(7, Options)]}.

-file("src/polly.gleam", 201).
?DOC(
    " Add a subject that Polly will send events to.\n"
    "\n"
    " This is a convenience wrapper around `add_callback` for when you want to\n"
    " send events to a process subject. Polly will use `process.send` to deliver\n"
    " each event to your subject.\n"
).
-spec add_subject(options(), gleam@erlang@process:subject(event())) -> options().
add_subject(Options, Subject) ->
    add_callback(
        Options,
        fun(_capture) -> gleam@erlang@process:send(Subject, _capture) end
    ).

-file("src/polly.gleam", 307).
-spec broadcast(list(fun((event()) -> nil)), event()) -> nil.
broadcast(Callbacks, Event) ->
    gleam@list:each(Callbacks, fun(Callback) -> Callback(Event) end).

-file("src/polly.gleam", 316).
?DOC(
    " Stop this watcher.\n"
    "\n"
    " If Polly currently scans your directories, she might not hear you right away\n"
    " and may still report events for one run, after which she will stop.\n"
).
-spec stop(watcher()) -> nil.
stop(Watcher) ->
    (erlang:element(2, Watcher))().

-file("src/polly.gleam", 324).
?DOC(
    " Format a list of file errors into a human-readable string.\n"
    "\n"
    " This is handy when `watch` returns errors and you want to show them to\n"
    " your users. Each error is formatted as \"path: description\" on its own line.\n"
).
-spec describe_errors(list({binary(), simplifile:file_error()})) -> binary().
describe_errors(Errors) ->
    _pipe = Errors,
    _pipe@1 = gleam@list:map(
        _pipe,
        fun(Error) ->
            {Path, Error@1} = Error,
            <<<<Path/binary, ": "/utf8>>/binary,
                (simplifile:describe_error(Error@1))/binary>>
        end
    ),
    gleam@string:join(_pipe@1, <<"\n"/utf8>>).

-file("src/polly.gleam", 690).
-spec delete(binary(), vfs(), fun((event()) -> nil)) -> nil.
delete(Path, Vfs, Emit) ->
    Full_path = filepath:join(Path, erlang:element(2, Vfs)),
    case Vfs of
        {file, _, _} ->
            Emit({deleted, Full_path});

        {folder, _, _, Children} ->
            gleam@list:each(
                Children,
                fun(Child) -> delete(Full_path, Child, Emit) end
            ),
            Emit({deleted, Full_path})
    end.

-file("src/polly.gleam", 701).
-spec get_modkey(simplifile:file_info()) -> integer().
get_modkey(Stat) ->
    gleam@int:max(erlang:element(10, Stat), erlang:element(11, Stat)).

-file("src/polly.gleam", 705).
-spec readdir(binary()) -> {ok, list(binary())} |
    {error, simplifile:file_error()}.
readdir(Path) ->
    _pipe = simplifile_erl:read_directory(Path),
    gleam@result:map(
        _pipe,
        fun(_capture) ->
            gleam@list:sort(_capture, fun gleam@string:compare/2)
        end
    ).

-file("src/polly.gleam", 585).
-spec diff_children(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    list(vfs()),
    list(binary()),
    list(vfs()),
    fun((event()) -> nil)
) -> list(vfs()).
diff_children(
    Filter,
    Depth,
    Path,
    Old_children,
    New_entries,
    New_children,
    Emit
) ->
    case {Old_children, New_entries} of
        {[], []} ->
            lists:reverse(New_children);

        {[First_old | Rest_old], [First_new | Rest_new]} ->
            case gleam@string:compare(erlang:element(2, First_old), First_new) of
                eq ->
                    case diff(Filter, Depth, Path, First_old, Emit) of
                        {some, New_vfs} ->
                            diff_children(
                                Filter,
                                Depth,
                                Path,
                                Rest_old,
                                Rest_new,
                                [New_vfs | New_children],
                                Emit
                            );

                        none ->
                            diff_children(
                                Filter,
                                Depth,
                                Path,
                                Rest_old,
                                Rest_new,
                                New_children,
                                Emit
                            )
                    end;

                gt ->
                    New_children@1 = case create(
                        Filter,
                        Depth,
                        Path,
                        First_new,
                        Emit
                    ) of
                        {some, New_vfs@1} ->
                            [New_vfs@1 | New_children];

                        none ->
                            New_children
                    end,
                    diff_children(
                        Filter,
                        Depth,
                        Path,
                        Old_children,
                        Rest_new,
                        New_children@1,
                        Emit
                    );

                lt ->
                    delete(Path, First_old, Emit),
                    diff_children(
                        Filter,
                        Depth,
                        Path,
                        Rest_old,
                        New_entries,
                        New_children,
                        Emit
                    )
            end;

        {[], [First_new@1 | Rest_new@1]} ->
            New_children@2 = case create(Filter, Depth, Path, First_new@1, Emit) of
                {some, New_vfs@2} ->
                    [New_vfs@2 | New_children];

                none ->
                    New_children
            end,
            diff_children(
                Filter,
                Depth,
                Path,
                Old_children,
                Rest_new@1,
                New_children@2,
                Emit
            );

        {[First_old@1 | Rest_old@1], []} ->
            delete(Path, First_old@1, Emit),
            diff_children(
                Filter,
                Depth,
                Path,
                Rest_old@1,
                New_entries,
                New_children,
                Emit
            )
    end.

-file("src/polly.gleam", 497).
-spec diff(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    vfs(),
    fun((event()) -> nil)
) -> gleam@option:option(vfs()).
diff(Filter, Depth, Path, Vfs, Emit) ->
    Full_path = filepath:join(Path, erlang:element(2, Vfs)),
    case simplifile_erl:link_info(Full_path) of
        {ok, Stat} ->
            Type_ = simplifile:file_info_type(Stat),
            case Filter(Type_, Full_path) of
                true ->
                    case {Type_, Vfs} of
                        {file, {file, Name, Old_key}} ->
                            New_key = get_modkey(Stat),
                            case New_key =:= Old_key of
                                true ->
                                    {some, Vfs};

                                false ->
                                    Emit({changed, Full_path}),
                                    {some, {file, Name, New_key}}
                            end;

                        {directory, {folder, _, _, _}} when Depth =:= 0 ->
                            {some, Vfs};

                        {directory, {folder, Name@1, _, Old_children}} when Depth =/= 0 ->
                            case readdir(Full_path) of
                                {ok, New_entries} ->
                                    Children = diff_children(
                                        Filter,
                                        Depth - 1,
                                        Full_path,
                                        Old_children,
                                        New_entries,
                                        [],
                                        Emit
                                    ),
                                    {some,
                                        {folder,
                                            Name@1,
                                            get_modkey(Stat),
                                            Children}};

                                {error, enoent} ->
                                    delete(Path, Vfs, Emit),
                                    none;

                                {error, eacces} ->
                                    delete(Path, Vfs, Emit),
                                    none;

                                {error, Reason} ->
                                    Emit({error, Full_path, Reason}),
                                    {some, Vfs}
                            end;

                        {_, _} ->
                            delete(Path, Vfs, Emit),
                            create_stat(
                                Filter,
                                Depth,
                                erlang:element(2, Vfs),
                                Full_path,
                                Stat,
                                Emit
                            )
                    end;

                false ->
                    delete(Path, Vfs, Emit),
                    none
            end;

        {error, eacces} ->
            delete(Path, Vfs, Emit),
            none;

        {error, enoent} ->
            delete(Path, Vfs, Emit),
            none;

        {error, Reason@1} ->
            Emit({error, Path, Reason@1}),
            {some, Vfs}
    end.

-file("src/polly.gleam", 477).
-spec create_children(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    list(binary()),
    list(vfs()),
    fun((event()) -> nil)
) -> list(vfs()).
create_children(Filter, Depth, Path, Children, Oks, Emit) ->
    case Children of
        [] ->
            lists:reverse(Oks);

        [First | Rest] ->
            case create(Filter, Depth, Path, First, Emit) of
                {some, Vfs} ->
                    create_children(
                        Filter,
                        Depth,
                        Path,
                        Rest,
                        [Vfs | Oks],
                        Emit
                    );

                none ->
                    create_children(Filter, Depth, Path, Rest, Oks, Emit)
            end
    end.

-file("src/polly.gleam", 414).
-spec create(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    binary(),
    fun((event()) -> nil)
) -> gleam@option:option(vfs()).
create(Filter, Depth, Path, Name, Emit) ->
    Full_path = filepath:join(Path, Name),
    case simplifile_erl:link_info(Full_path) of
        {ok, Stat} ->
            create_stat(Filter, Depth, Name, Full_path, Stat, Emit);

        {error, enoent} ->
            none;

        {error, eacces} ->
            none;

        {error, Reason} ->
            Emit({error, Full_path, Reason}),
            none
    end.

-file("src/polly.gleam", 433).
-spec create_stat(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    binary(),
    simplifile:file_info(),
    fun((event()) -> nil)
) -> gleam@option:option(vfs()).
create_stat(Filter, Depth, Name, Full_path, Stat, Emit) ->
    Type_ = simplifile:file_info_type(Stat),
    gleam@bool:guard(not Filter(Type_, Full_path), none, fun() -> case Type_ of
                file ->
                    Emit({created, Full_path}),
                    {some, {file, Name, get_modkey(Stat)}};

                directory when Depth =:= 0 ->
                    Emit({created, Full_path}),
                    {some, {folder, Name, get_modkey(Stat), []}};

                directory when Depth =/= 0 ->
                    case readdir(Full_path) of
                        {ok, Entries} ->
                            Depth@1 = Depth - 1,
                            Emit({created, Full_path}),
                            Children = create_children(
                                Filter,
                                Depth@1,
                                Full_path,
                                Entries,
                                [],
                                Emit
                            ),
                            {some, {folder, Name, get_modkey(Stat), Children}};

                        {error, enoent} ->
                            none;

                        {error, eacces} ->
                            none;

                        {error, Reason} ->
                            Emit({error, Full_path, Reason}),
                            none
                    end;

                _ ->
                    none
            end end).

-file("src/polly.gleam", 282).
-spec step(
    options(),
    fun((event()) -> nil),
    list({binary(), gleam@option:option(vfs())})
) -> list({binary(), gleam@option:option(vfs())}).
step(Options, Emit, Roots) ->
    {options, _, _, Max_depth, Filter, _, _} = Options,
    gleam@list:fold(
        Roots,
        [],
        fun(Roots@1, _use1) ->
            {Path, Vfs} = _use1,
            case Vfs of
                {some, Vfs@1} ->
                    New_vfs = diff(Filter, Max_depth, Path, Vfs@1, Emit),
                    [{Path, New_vfs} | Roots@1];

                none ->
                    New_vfs@1 = create(
                        Filter,
                        Max_depth,
                        Path,
                        <<""/utf8>>,
                        Emit
                    ),
                    [{Path, New_vfs@1} | Roots@1]
            end
        end
    ).

-file("src/polly.gleam", 394).
-spec init_children(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    list(binary()),
    list(vfs()),
    list({binary(), simplifile:file_error()})
) -> {list(vfs()), list({binary(), simplifile:file_error()})}.
init_children(Filter, Depth, Path, Children, Oks, Errors) ->
    case Children of
        [] ->
            {lists:reverse(Oks), Errors};

        [First | Rest] ->
            case init(Filter, Depth, Path, First, Errors) of
                {{some, Vfs}, Errors@1} ->
                    init_children(
                        Filter,
                        Depth,
                        Path,
                        Rest,
                        [Vfs | Oks],
                        Errors@1
                    );

                {none, Errors@2} ->
                    init_children(Filter, Depth, Path, Rest, Oks, Errors@2)
            end
    end.

-file("src/polly.gleam", 340).
-spec init(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    binary(),
    list({binary(), simplifile:file_error()})
) -> {gleam@option:option(vfs()), list({binary(), simplifile:file_error()})}.
init(Filter, Depth, Path, Name, Errors) ->
    Full_path = filepath:join(Path, Name),
    case simplifile_erl:link_info(Full_path) of
        {ok, Stat} ->
            init_stat(Filter, Depth, Name, Full_path, Stat, Errors);

        {error, enoent} ->
            {none, Errors};

        {error, eacces} ->
            {none, Errors};

        {error, Reason} ->
            {none, [{Full_path, Reason} | Errors]}
    end.

-file("src/polly.gleam", 356).
-spec init_stat(
    fun((simplifile:file_type(), binary()) -> boolean()),
    integer(),
    binary(),
    binary(),
    simplifile:file_info(),
    list({binary(), simplifile:file_error()})
) -> {gleam@option:option(vfs()), list({binary(), simplifile:file_error()})}.
init_stat(Filter, Depth, Name, Full_path, Stat, Errors) ->
    Type_ = simplifile:file_info_type(Stat),
    gleam@bool:guard(
        not Filter(Type_, Full_path),
        {none, Errors},
        fun() -> case Type_ of
                file ->
                    {{some, {file, Name, get_modkey(Stat)}}, Errors};

                directory when Depth =:= 0 ->
                    {{some, {folder, Name, get_modkey(Stat), []}}, Errors};

                directory when Depth =/= 0 ->
                    case readdir(Full_path) of
                        {ok, Entries} ->
                            Depth@1 = Depth - 1,
                            {Children, Errors@1} = init_children(
                                Filter,
                                Depth@1,
                                Full_path,
                                Entries,
                                [],
                                Errors
                            ),
                            {{some, {folder, Name, get_modkey(Stat), Children}},
                                Errors@1};

                        {error, enoent} ->
                            {none, Errors};

                        {error, eacces} ->
                            {none, Errors};

                        {error, Reason} ->
                            {none, [{Full_path, Reason} | Errors]}
                    end;

                _ ->
                    {none, []}
            end end
    ).

-file("src/polly.gleam", 263).
-spec get_initial_roots(options()) -> {ok,
        list({binary(), gleam@option:option(vfs())})} |
    {error, list({binary(), simplifile:file_error()})}.
get_initial_roots(Options) ->
    {options, _, Paths, Max_depth, Filter, Ignore_initial_missing, _} = Options,
    gleam@bool:guard(
        Paths =:= [],
        {error, []},
        fun() ->
            gleam@list:try_map(
                Paths,
                fun(Path) ->
                    case init(Filter, Max_depth, Path, <<""/utf8>>, []) of
                        {{some, Vfs}, []} ->
                            {ok, {Path, {some, Vfs}}};

                        {none, []} ->
                            case Ignore_initial_missing of
                                false ->
                                    {error, [{Path, enoent}]};

                                true ->
                                    {ok, {Path, none}}
                            end;

                        {_, Errors} ->
                            {error, Errors}
                    end
                end
            )
        end
    ).

-file("src/polly.gleam", 217).
?DOC(
    " Tell Polly to start watching all the specified directories for changes.\n"
    "\n"
    " The callbacks are called synchronously while collecting change events since\n"
    " the last run. It is adviseable to move heavier cpu-bound tasks from this\n"
    " callback into their own processes or threads.\n"
    "\n"
    " When running on the Erlang target, this spawns a new linked process.\n"
).
-spec watch(options()) -> {ok, watcher()} |
    {error, list({binary(), simplifile:file_error()})}.
watch(Options) ->
    gleam@result:'try'(
        get_initial_roots(Options),
        fun(Roots) ->
            Emit = fun(_capture) ->
                broadcast(erlang:element(7, Options), _capture)
            end,
            Stop = polly_ffi:repeatedly(
                erlang:element(2, Options),
                Roots,
                fun(_capture@1) -> step(Options, Emit, _capture@1) end
            ),
            {ok, {watcher, Stop}}
        end
    ).

-file("src/polly.gleam", 249).
-spec start_process(options()) -> {ok, gleam@otp@actor:started(watcher())} |
    {error, gleam@otp@actor:start_error()}.
start_process(Options) ->
    gleam@result:'try'(
        begin
            _pipe = get_initial_roots(Options),
            gleam@result:map_error(
                _pipe,
                fun(Errors) -> {init_failed, describe_errors(Errors)} end
            )
        end,
        fun(Roots) ->
            Emit = fun(_capture) ->
                broadcast(erlang:element(7, Options), _capture)
            end,
            {Pid, Stop} = polly_ffi:spawn(
                erlang:element(2, Options),
                Roots,
                fun(_capture@1) -> step(Options, Emit, _capture@1) end
            ),
            {ok, {started, Pid, {watcher, Stop}}}
        end
    ).

-file("src/polly.gleam", 232).
?DOC(
    " Create a child specification for running Polly under a supervisor.\n"
    "\n"
    " This lets you add Polly to your supervision tree, so she'll automatically\n"
    " restart if something goes wrong. The supervisor will make sure she keeps\n"
    " watching your files reliably!\n"
).
-spec supervised(options()) -> gleam@otp@supervision:child_specification(watcher()).
supervised(Options) ->
    gleam@otp@supervision:worker(fun() -> start_process(Options) end).

-file("src/polly.gleam", 243).
?DOC(
    " Create a factory builder for dynamically starting multiple Polly watchers.\n"
    "\n"
    " This is useful when you want to spawn and manage multiple watchers at runtime,\n"
    " each watching different paths with different options. The factory supervisor\n"
    " handles starting, stopping, and supervising all your Polly instances!\n"
).
-spec factory() -> gleam@otp@factory_supervisor:builder(options(), watcher()).
factory() ->
    gleam@otp@factory_supervisor:worker_child(
        fun(Options) -> start_process(Options) end
    ).
