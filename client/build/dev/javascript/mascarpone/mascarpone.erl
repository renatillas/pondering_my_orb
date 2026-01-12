-module(mascarpone).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/mascarpone.gleam").
-export([main/0]).
-export_type([step/0, generation_step/0, template/0, model/0, msg/0, step_status/0, platform/0, architecture/0]).

-type step() :: welcome |
    lustre_choice |
    template_choice |
    desktop_bundle_choice |
    {generating, list(generation_step())} |
    complete |
    {failed, binary()}.

-type generation_step() :: {step_pending, binary()} |
    {step_in_progress, binary()} |
    {step_complete, binary()} |
    {step_failed, binary(), binary()}.

-type template() :: two_d_game | three_d_game | physics_demo.

-type model() :: {model,
        step(),
        binary(),
        boolean(),
        boolean(),
        gleam@option:option(template()),
        boolean()}.

-type msg() :: next_step |
    {set_lustre, boolean()} |
    {set_template, template()} |
    skip_template |
    {set_desktop_bundle, boolean()} |
    start_generation |
    install_lustre_dev_tools |
    update_gleam_toml |
    install_npm_packages |
    create_gitignore |
    create_main_file |
    install_nw_builder |
    setup_desktop_bundle |
    generation_complete |
    {generation_failed, binary()}.

-type step_status() :: status_pending |
    status_in_progress |
    status_complete |
    {status_failed, binary()}.

-type platform() :: linux | mac_o_s | windows.

-type architecture() :: x64 | arm64 | aarch64.

-file("src/mascarpone.gleam", 168).
-spec init(binary()) -> {model(), list(fun(() -> msg()))}.
init(Project_name) ->
    {{model, welcome, Project_name, true, false, none, false}, []}.

-file("src/mascarpone.gleam", 429).
-spec generate_steps_list(model()) -> list(generation_step()).
generate_steps_list(Model) ->
    Base_steps = [{step_pending, <<"Installing Lustre dev tools"/utf8>>},
        {step_pending, <<"Updating gleam.toml"/utf8>>},
        {step_pending, <<"Installing Three.js and Rapier3D"/utf8>>},
        {step_pending, <<"Creating .gitignore"/utf8>>},
        {step_pending, <<"Creating index.html"/utf8>>}],
    With_template = case erlang:element(6, Model) of
        {some, _} ->
            lists:append(
                Base_steps,
                [{step_pending, <<"Creating main game file"/utf8>>}]
            );

        none ->
            Base_steps
    end,
    case erlang:element(7, Model) of
        true ->
            lists:append(
                With_template,
                [{step_pending, <<"Installing nw-builder"/utf8>>},
                    {step_pending, <<"Setting up desktop bundle"/utf8>>}]
            );

        false ->
            With_template
    end.

-file("src/mascarpone.gleam", 453).
-spec update_step_status(model(), binary(), step_status()) -> model().
update_step_status(Model, Step_name, Status) ->
    case erlang:element(2, Model) of
        {generating, Steps} ->
            Updated_steps = gleam@list:map(Steps, fun(Step) -> case Step of
                        {step_pending, Name} when Name =:= Step_name ->
                            case Status of
                                status_in_progress ->
                                    {step_in_progress, Name};

                                status_complete ->
                                    {step_complete, Name};

                                {status_failed, Err} ->
                                    {step_failed, Name, Err};

                                status_pending ->
                                    Step
                            end;

                        {step_in_progress, Name@1} when Name@1 =:= Step_name ->
                            case Status of
                                status_complete ->
                                    {step_complete, Name@1};

                                {status_failed, Err@1} ->
                                    {step_failed, Name@1, Err@1};

                                _ ->
                                    Step
                            end;

                        _ ->
                            Step
                    end end),
            {model,
                {generating, Updated_steps},
                erlang:element(3, Model),
                erlang:element(4, Model),
                erlang:element(5, Model),
                erlang:element(6, Model),
                erlang:element(7, Model)};

        _ ->
            Model
    end.

-file("src/mascarpone.gleam", 499).
-spec view_welcome() -> shore@internal:node_(msg()).
view_welcome() ->
    shore@ui:col(
        [shore@ui:text_styled(
                <<"╔═══════════════════════════════════╗"/utf8>>,
                {some, cyan},
                none
            ),
            shore@ui:text_styled(
                <<"║   🎮 Tiramisu Project Creator 🎮  ║"/utf8>>,
                {some, cyan},
                none
            ),
            shore@ui:text_styled(
                <<"║   Gleam 3D Game Engine            ║"/utf8>>,
                {some, cyan},
                none
            ),
            shore@ui:text_styled(
                <<"╚═══════════════════════════════════╝"/utf8>>,
                {some, cyan},
                none
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(<<"Welcome to Tiramisu! 🍰"/utf8>>),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(
                <<"This wizard will help you set up Tiramisu for your game project."/utf8>>
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:hr(),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text_styled(
                <<"Press Enter to continue"/utf8>>,
                {some, yellow},
                none
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:button(<<"Continue"/utf8>>, enter, next_step)]
    ).

-file("src/mascarpone.gleam", 534).
-spec view_lustre_choice() -> shore@internal:node_(msg()).
view_lustre_choice() ->
    shore@ui:col(
        [shore@ui:text_styled(<<"Lustre Integration"/utf8>>, {some, cyan}, none),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(
                <<"Lustre allows you to create UI overlays for your game"/utf8>>
            ),
            shore@ui:text(
                <<"(menus, HUDs, dialogs, etc.) using a reactive framework."/utf8>>
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:hr(),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(<<"Include Lustre?"/utf8>>),
            shore@ui:text(<<""/utf8>>),
            shore@ui:button(
                <<"[Y] Yes (recommended)"/utf8>>,
                {char, <<"y"/utf8>>},
                {set_lustre, true}
            ),
            shore@ui:button(
                <<"[N] No"/utf8>>,
                {char, <<"n"/utf8>>},
                {set_lustre, false}
            )]
    ).

-file("src/mascarpone.gleam", 550).
-spec view_template_choice() -> shore@internal:node_(msg()).
view_template_choice() ->
    shore@ui:col(
        [shore@ui:text_styled(<<"Project Template"/utf8>>, {some, cyan}, none),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text_styled(
                <<"⚠️  WARNING: Selecting a template is DESTRUCTIVE!"/utf8>>,
                {some, red},
                none
            ),
            shore@ui:text_styled(
                <<"It will OVERWRITE your existing game code in src/"/utf8>>,
                {some, red},
                none
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(
                <<"If you're setting up NW.js for an existing project,"/utf8>>
            ),
            shore@ui:text(<<"press [S] to skip template selection."/utf8>>),
            shore@ui:text(<<""/utf8>>),
            shore@ui:hr(),
            shore@ui:text(<<""/utf8>>),
            shore@ui:button(
                <<"[1] 2D Game - Orthographic camera and sprite setup"/utf8>>,
                {char, <<"1"/utf8>>},
                {set_template, two_d_game}
            ),
            shore@ui:button(
                <<"[2] 3D Game - Perspective camera with lighting"/utf8>>,
                {char, <<"2"/utf8>>},
                {set_template, three_d_game}
            ),
            shore@ui:button(
                <<"[3] Physics Demo - Physics-enabled objects"/utf8>>,
                {char, <<"3"/utf8>>},
                {set_template, physics_demo}
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:button(
                <<"[S] Skip - Don't create/overwrite game files"/utf8>>,
                {char, <<"s"/utf8>>},
                skip_template
            )]
    ).

-file("src/mascarpone.gleam", 594).
-spec view_desktop_bundle_choice() -> shore@internal:node_(msg()).
view_desktop_bundle_choice() ->
    shore@ui:col(
        [shore@ui:text_styled(
                <<"Desktop Bundle for NW.js"/utf8>>,
                {some, cyan},
                none
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(<<"Bundle for desktop will:"/utf8>>),
            shore@ui:text(
                <<"  • Install nw-builder to manage NW.js builds"/utf8>>
            ),
            shore@ui:text(
                <<"  • Configure package.json with NW.js settings"/utf8>>
            ),
            shore@ui:text(
                <<"  • Set up build configuration for all platforms"/utf8>>
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(
                <<"After setup, run 'bun run build' to create platform builds"/utf8>>
            ),
            shore@ui:text(<<""/utf8>>),
            shore@ui:hr(),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(<<"Bundle for desktop?"/utf8>>),
            shore@ui:text(<<""/utf8>>),
            shore@ui:button(
                <<"[Y] Yes"/utf8>>,
                {char, <<"y"/utf8>>},
                {set_desktop_bundle, true}
            ),
            shore@ui:button(
                <<"[N] No"/utf8>>,
                {char, <<"n"/utf8>>},
                {set_desktop_bundle, false}
            )]
    ).

-file("src/mascarpone.gleam", 614).
-spec view_generating(list(generation_step())) -> shore@internal:node_(msg()).
view_generating(Steps) ->
    Header = [shore@ui:text_styled(
            <<"╔═══════════════════════════════════╗"/utf8>>,
            {some, cyan},
            none
        ),
        shore@ui:text_styled(
            <<"║     Setting up your project...    ║"/utf8>>,
            {some, cyan},
            none
        ),
        shore@ui:text_styled(
            <<"╚═══════════════════════════════════╝"/utf8>>,
            {some, cyan},
            none
        ),
        shore@ui:text(<<""/utf8>>)],
    Step_views = gleam@list:map(Steps, fun(Step) -> case Step of
                {step_pending, Name} ->
                    shore@ui:text_styled(
                        <<"  ⏸  "/utf8, Name/binary>>,
                        {some, white},
                        none
                    );

                {step_in_progress, Name@1} ->
                    shore@ui:text_styled(
                        <<<<"  ⏳ "/utf8, Name@1/binary>>/binary, "..."/utf8>>,
                        {some, yellow},
                        none
                    );

                {step_complete, Name@2} ->
                    shore@ui:text_styled(
                        <<"  ✓  "/utf8, Name@2/binary>>,
                        {some, green},
                        none
                    );

                {step_failed, Name@3, _} ->
                    shore@ui:text_styled(
                        <<"  ✗  "/utf8, Name@3/binary>>,
                        {some, red},
                        none
                    )
            end end),
    shore@ui:col(lists:append(Header, Step_views)).

-file("src/mascarpone.gleam", 730).
-spec view_error(binary()) -> shore@internal:node_(msg()).
view_error(Msg) ->
    shore@ui:col(
        [shore@ui:text_styled(<<"❌ Error occurred"/utf8>>, {some, red}, none),
            shore@ui:text(<<""/utf8>>),
            shore@ui:text(Msg)]
    ).

-file("src/mascarpone.gleam", 738).
-spec template_name(template()) -> binary().
template_name(Template) ->
    case Template of
        two_d_game ->
            <<"2D Game"/utf8>>;

        three_d_game ->
            <<"3D Game"/utf8>>;

        physics_demo ->
            <<"Physics Demo"/utf8>>
    end.

-file("src/mascarpone.gleam", 651).
-spec view_complete(model()) -> shore@internal:node_(msg()).
view_complete(Model) ->
    Template_text = case erlang:element(6, Model) of
        {some, T} ->
            template_name(T);

        none ->
            <<"None (skipped)"/utf8>>
    end,
    Base_items = [shore@ui:text_styled(
            <<"✅ Project setup complete!"/utf8>>,
            {some, green},
            none
        ),
        shore@ui:text(<<""/utf8>>),
        shore@ui:text(<<"Project: "/utf8, (erlang:element(3, Model))/binary>>),
        shore@ui:text(<<"Template: "/utf8, Template_text/binary>>),
        shore@ui:text(<<"Lustre: "/utf8, (case erlang:element(4, Model) of
                    true ->
                        <<"Yes"/utf8>>;

                    false ->
                        <<"No"/utf8>>
                end)/binary>>),
        shore@ui:text(<<"Physics: "/utf8, (case erlang:element(5, Model) of
                    true ->
                        <<"Yes"/utf8>>;

                    false ->
                        <<"No"/utf8>>
                end)/binary>>),
        shore@ui:text(
            <<"Desktop Bundle: "/utf8, (case erlang:element(7, Model) of
                    true ->
                        <<"Yes"/utf8>>;

                    false ->
                        <<"No"/utf8>>
                end)/binary>>
        ),
        shore@ui:text(<<""/utf8>>),
        shore@ui:hr(),
        shore@ui:text(<<""/utf8>>),
        shore@ui:text(<<"Next steps:"/utf8>>),
        shore@ui:text(<<""/utf8>>)],
    Next_steps = case erlang:element(7, Model) of
        true ->
            [shore@ui:text(<<"1. Build platform distributions:"/utf8>>),
                shore@ui:text_styled(
                    <<"   bun run build"/utf8>>,
                    {some, cyan},
                    none
                ),
                shore@ui:text(<<""/utf8>>),
                shore@ui:text(
                    <<<<"2. Find your builds in ./"/utf8,
                            (erlang:element(3, Model))/binary>>/binary,
                        "_desktop_bundle/:"/utf8>>
                ),
                shore@ui:text(
                    <<<<"   • "/utf8, (erlang:element(3, Model))/binary>>/binary,
                        "_desktop_bundle/nwjs-v*-linux-x64/"/utf8>>
                ),
                shore@ui:text(
                    <<<<"   • "/utf8, (erlang:element(3, Model))/binary>>/binary,
                        "_desktop_bundle/nwjs-v*-win-x64/"/utf8>>
                ),
                shore@ui:text(
                    <<<<"   • "/utf8, (erlang:element(3, Model))/binary>>/binary,
                        "_desktop_bundle/nwjs-v*-osx-arm64/"/utf8>>
                ),
                shore@ui:text(<<""/utf8>>),
                shore@ui:text(<<"3. Or run in dev mode:"/utf8>>),
                shore@ui:text_styled(
                    <<"   gleam run -m lustre/dev start"/utf8>>,
                    {some, cyan},
                    none
                ),
                shore@ui:text(
                    <<"   Then open http://localhost:1234 in your browser"/utf8>>
                )];

        false ->
            [shore@ui:text(<<"1. Start the dev server:"/utf8>>),
                shore@ui:text_styled(
                    <<"   gleam run -m lustre/dev start"/utf8>>,
                    {some, cyan},
                    none
                ),
                shore@ui:text(<<""/utf8>>),
                shore@ui:text(
                    <<"2. Open http://localhost:1234 in your browser"/utf8>>
                )]
    end,
    Footer = [shore@ui:text(<<""/utf8>>),
        shore@ui:text(<<"Happy game development! 🎮"/utf8>>),
        shore@ui:text(<<""/utf8>>),
        shore@ui:text(<<"Press Ctrl + X to leave"/utf8>>)],
    shore@ui:col(lists:append([Base_items, Next_steps, Footer])).

-file("src/mascarpone.gleam", 485).
-spec view(model()) -> shore@internal:node_(msg()).
view(Model) ->
    case erlang:element(2, Model) of
        welcome ->
            view_welcome();

        lustre_choice ->
            view_lustre_choice();

        template_choice ->
            view_template_choice();

        desktop_bundle_choice ->
            view_desktop_bundle_choice();

        {generating, Steps} ->
            view_generating(Steps);

        complete ->
            view_complete(Model);

        {failed, Msg} ->
            view_error(Msg)
    end.

-file("src/mascarpone.gleam", 785).
-spec find_root(binary()) -> binary().
find_root(Path) ->
    Toml = filepath:join(Path, <<"gleam.toml"/utf8>>),
    case simplifile_erl:is_file(Toml) of
        {ok, false} ->
            find_root(filepath:join(Path, <<".."/utf8>>));

        {error, _} ->
            find_root(filepath:join(Path, <<".."/utf8>>));

        {ok, true} ->
            Path
    end.

-file("src/mascarpone.gleam", 748).
-spec install_lustre_dev_tools() -> {ok, nil} | {error, snag:snag()}.
install_lustre_dev_tools() ->
    Root = find_root(<<"."/utf8>>),
    _pipe = shellout:command(
        <<"gleam"/utf8>>,
        [<<"run"/utf8>>,
            <<"-m"/utf8>>,
            <<"lustre/dev"/utf8>>,
            <<"add"/utf8>>,
            <<"bun"/utf8>>],
        Root,
        []
    ),
    _pipe@1 = gleam@result:map_error(
        _pipe,
        fun(Error) ->
            snag:new(
                <<"Failed to install Lustre dev tools: "/utf8,
                    (erlang:element(2, Error))/binary>>
            )
        end
    ),
    gleam@result:replace(_pipe@1, nil).

-file("src/mascarpone.gleam", 763).
-spec get_project_name() -> {ok, binary()} | {error, snag:snag()}.
get_project_name() ->
    Root = find_root(<<"."/utf8>>),
    Toml_path = filepath:join(Root, <<"gleam.toml"/utf8>>),
    gleam@result:'try'(
        begin
            _pipe = simplifile:read(Toml_path),
            snag:map_error(
                _pipe,
                fun(_) -> <<"Could not read gleam.toml"/utf8>> end
            )
        end,
        fun(Content) ->
            gleam@result:'try'(
                begin
                    _pipe@1 = tom:parse(Content),
                    snag:map_error(
                        _pipe@1,
                        fun(_) -> <<"Could not parse gleam.toml"/utf8>> end
                    )
                end,
                fun(Toml) ->
                    gleam@result:'try'(
                        begin
                            _pipe@2 = tom:get_string(Toml, [<<"name"/utf8>>]),
                            snag:map_error(
                                _pipe@2,
                                fun(_) ->
                                    <<"Could not find project name in gleam.toml"/utf8>>
                                end
                            )
                        end,
                        fun(Name) -> {ok, Name} end
                    )
                end
            )
        end
    ).

-file("src/mascarpone.gleam", 794).
-spec update_gleam_toml(binary(), boolean()) -> {ok, nil} | {error, snag:snag()}.
update_gleam_toml(Project_name, Include_lustre) ->
    Root = find_root(<<"."/utf8>>),
    Toml_path = filepath:join(Root, <<"gleam.toml"/utf8>>),
    gleam@result:'try'(
        begin
            _pipe = simplifile:read(Toml_path),
            snag:map_error(
                _pipe,
                fun(_) -> <<"Could not read gleam.toml"/utf8>> end
            )
        end,
        fun(Content) ->
            Content@1 = case gleam_stdlib:contains_string(
                Content,
                <<"target ="/utf8>>
            ) of
                true ->
                    Content;

                false ->
                    gleam@string:replace(
                        Content,
                        <<<<"name = \""/utf8, Project_name/binary>>/binary,
                            "\""/utf8>>,
                        <<<<"name = \""/utf8, Project_name/binary>>/binary,
                            "\"\ntarget = \"javascript\""/utf8>>
                    )
            end,
            gleam@result:'try'(
                begin
                    _pipe@1 = simplifile:write(Toml_path, Content@1),
                    snag:map_error(
                        _pipe@1,
                        fun(_) -> <<"Could not write gleam.toml"/utf8>> end
                    )
                end,
                fun(_) ->
                    gleam@result:'try'(
                        begin
                            _pipe@2 = shellout:command(
                                <<"gleam"/utf8>>,
                                [<<"add"/utf8>>, <<"tiramisu"/utf8>>],
                                Root,
                                []
                            ),
                            snag:map_error(
                                _pipe@2,
                                fun(Error) ->
                                    <<"Failed to add tiramisu dependency: "/utf8,
                                        (erlang:element(2, Error))/binary>>
                                end
                            )
                        end,
                        fun(_) ->
                            gleam@result:'try'(
                                begin
                                    _pipe@3 = shellout:command(
                                        <<"gleam"/utf8>>,
                                        [<<"add"/utf8>>, <<"vec"/utf8>>],
                                        Root,
                                        []
                                    ),
                                    snag:map_error(
                                        _pipe@3,
                                        fun(Error@1) ->
                                            <<"Failed to add vec dependency: "/utf8,
                                                (erlang:element(2, Error@1))/binary>>
                                        end
                                    )
                                end,
                                fun(_) ->
                                    gleam@result:'try'(
                                        begin
                                            _pipe@4 = shellout:command(
                                                <<"gleam"/utf8>>,
                                                [<<"add"/utf8>>,
                                                    <<"--dev"/utf8>>,
                                                    <<"lustre_dev_tools"/utf8>>],
                                                Root,
                                                []
                                            ),
                                            snag:map_error(
                                                _pipe@4,
                                                fun(Error@2) ->
                                                    <<"Failed to add lustre_dev_tools dependency: "/utf8,
                                                        (erlang:element(
                                                            2,
                                                            Error@2
                                                        ))/binary>>
                                                end
                                            )
                                        end,
                                        fun(_) ->
                                            gleam@result:'try'(
                                                case Include_lustre of
                                                    true ->
                                                        _pipe@5 = shellout:command(
                                                            <<"gleam"/utf8>>,
                                                            [<<"add"/utf8>>,
                                                                <<"lustre"/utf8>>],
                                                            Root,
                                                            []
                                                        ),
                                                        snag:map_error(
                                                            _pipe@5,
                                                            fun(Error@3) ->
                                                                <<"Failed to add lustre dependency: "/utf8,
                                                                    (erlang:element(
                                                                        2,
                                                                        Error@3
                                                                    ))/binary>>
                                                            end
                                                        );

                                                    false ->
                                                        {ok, <<""/utf8>>}
                                                end,
                                                fun(_) ->
                                                    gleam@result:'try'(
                                                        begin
                                                            _pipe@6 = simplifile:read(
                                                                Toml_path
                                                            ),
                                                            snag:map_error(
                                                                _pipe@6,
                                                                fun(_) ->
                                                                    <<"Could not read gleam.toml"/utf8>>
                                                                end
                                                            )
                                                        end,
                                                        fun(Content@2) ->
                                                            Lustre_config = <<"\n\n[tools.lustre.html]
scripts = [
  { type = \"importmap\", content = \"{ \\\"imports\\\": { \\\"three\\\": \\\"https://cdn.jsdelivr.net/npm/three@0.180.0/build/three.module.js\\\", \\\"three/addons/\\\": \\\"https://cdn.jsdelivr.net/npm/three@0.180.0/examples/jsm/\\\", \\\"@dimforge/rapier3d-compat\\\": \\\"https://cdn.jsdelivr.net/npm/@dimforge/rapier3d-compat@0.11.2/+esm\\\" } }\" }
]
stylesheets = [
  { content = \"body { margin: 0; padding: 0; overflow: hidden; }\" }
]
"/utf8>>,
                                                            Final_content = case gleam_stdlib:contains_string(
                                                                Content@2,
                                                                <<"[tools.lustre.html]"/utf8>>
                                                            ) of
                                                                true ->
                                                                    Content@2;

                                                                false ->
                                                                    <<Content@2/binary,
                                                                        Lustre_config/binary>>
                                                            end,
                                                            _pipe@7 = simplifile:write(
                                                                Toml_path,
                                                                Final_content
                                                            ),
                                                            snag:map_error(
                                                                _pipe@7,
                                                                fun(_) ->
                                                                    <<"Could not write gleam.toml"/utf8>>
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
                    )
                end
            )
        end
    ).

-file("src/mascarpone.gleam", 887).
-spec create_gitignore() -> {ok, nil} | {error, snag:snag()}.
create_gitignore() ->
    Root = find_root(<<"."/utf8>>),
    Gitignore_path = filepath:join(Root, <<".gitignore"/utf8>>),
    Content = <<"*.beam
*.ez
/build
erl_crash.dump
/priv
.DS_Store
node_modules/
.lustre/
dist/
*_desktop_bundle/"/utf8>>,
    _pipe = simplifile:write(Gitignore_path, Content),
    snag:map_error(_pipe, fun(_) -> <<"Could not write .gitignore"/utf8>> end).

-file("src/mascarpone.gleam", 924).
-spec generate_2d_template() -> binary().
generate_2d_template() ->
    <<"/// 2D Game Example - Orthographic Camera
import gleam/float
import gleam/option
import tiramisu
import tiramisu/background
import tiramisu/camera
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/light
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

pub type Model {
  Model(time: Float)
}

pub type Msg {
  Tick
}

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x1a1a2e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(_ctx: tiramisu.Context(String)) -> #(Model, Effect(Msg), option.Option(_)) {
  #(Model(time: 0.0), effect.tick(Tick), option.None)
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  case msg {
    Tick -> {
      let new_time = model.time +. ctx.delta_time /. 1000.0
      #(Model(time: new_time), effect.tick(Tick), option.None)
    }
  }
}

fn view(model: Model, ctx: tiramisu.Context(String)) -> List(scene.Node(String)) {
  let cam = camera.camera_2d(
    width: float.round(ctx.canvas_width),
    height: float.round(ctx.canvas_height),
  )
  let assert Ok(sprite_geom) = geometry.plane(width: 50.0, height: 50.0)
  let assert Ok(sprite_mat) = material.basic(color: 0xff0066, transparent: False, opacity: 1.0, map: option.None)

  [
    scene.camera(
      id: \"camera\",
      camera: cam,
      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 20.0)),
      look_at: option.None,
      active: True,
      viewport: option.None,
    ),
    scene.light(
      id: \"ambient\",
      light: {
        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 1.0)
        light
      },
      transform: transform.identity,
    ),
    scene.mesh(
      id: \"sprite\",
      geometry: sprite_geom,
      material: sprite_mat,
      transform: 
        transform.at(position: vec3.Vec3(0.0, 0.0, 0.0))
        |> transform.with_euler_rotation(vec3.Vec3(0.0, 0.0, model.time)),
      physics: option.None,
    ),
  ]
}
"/utf8>>.

-file("src/mascarpone.gleam", 1013).
-spec generate_3d_template() -> binary().
generate_3d_template() ->
    <<"/// 3D Game Example - Perspective Camera with Lighting
import gleam/option
import tiramisu
import tiramisu/background
import tiramisu/camera
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/light
import tiramisu/material
import tiramisu/scene
import tiramisu/transform
import vec/vec3

pub type Model {
  Model(time: Float)
}

pub type Msg {
  Tick
}

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x1a1a2e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(_ctx: tiramisu.Context(String)) -> #(Model, Effect(Msg), option.Option(_)) {
  #(Model(time: 0.0), effect.tick(Tick), option.None)
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(String),
) -> #(Model, Effect(Msg), option.Option(_)) {
  case msg {
    Tick -> {
      let new_time = model.time +. ctx.delta_time
      #(Model(time: new_time), effect.tick(Tick), option.None)
    }
  }
}

fn view(model: Model, _ctx: tiramisu.Context(String)) -> List(scene.Node(String)) {
  let assert Ok(cam) = camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)
  let assert Ok(sphere_geom) = geometry.sphere(radius: 1.0, width_segments: 32, height_segments: 32)
  let assert Ok(sphere_mat) = material.new() |> material.with_color(0x0066ff) |> material.build
  let assert Ok(ground_geom) = geometry.plane(width: 20.0, height: 20.0)
  let assert Ok(ground_mat) = material.new() |> material.with_color(0x808080) |> material.build

  [
    scene.camera(
      id: \"camera\",
      camera: cam,
      transform: transform.at(position: vec3.Vec3(0.0, 5.0, 10.0)),
      look_at: option.Some(vec3.Vec3(0.0, 0.0, 0.0)),
      active: True,
      viewport: option.None,
    ),
    scene.light(
      id: \"ambient\",
      light: {
        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
        light
      },
      transform: transform.identity,
    ),
    scene.light(
      id: \"directional\",
      light: {
        let assert Ok(light) = light.directional(color: 0xffffff, intensity: 0.8)
        light
      },
      transform: transform.at(position: vec3.Vec3(10.0, 10.0, 10.0)),
    ),
    scene.mesh(
      id: \"sphere\",
      geometry: sphere_geom,
      material: sphere_mat,
      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0)),
      physics: option.None,
    ),
    scene.mesh(
      id: \"ground\",
      geometry: ground_geom,
      material: ground_mat,
      transform: 
        transform.at(position: vec3.Vec3(0.0, -2.0, 0.0)) 
        |> transform.with_euler_rotation(vec3.Vec3(-1.57, 0.0, 0.0)),
      physics: option.None,
    ),
  ]
}
"/utf8>>.

-file("src/mascarpone.gleam", 1115).
-spec generate_physics_template() -> binary().
generate_physics_template() ->
    <<"/// Physics Demo - Falling Cubes
/// Demonstrates physics simulation with Rapier3D
import gleam/option
import tiramisu
import tiramisu/background
import tiramisu/camera
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/light
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3

pub type Id {
  Camera
  Ambient
  Directional
  Ground
  Cube1
  Cube2
}

pub type Model {
  Model
}

pub type Msg {
  Tick
}

pub fn main() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x1a1a2e),
    init: init,
    update: update,
    view: view,
  )
}

fn init(_ctx: tiramisu.Context(Id)) -> #(Model, Effect(Msg), option.Option(_)) {
  // Initialize physics world with gravity
  let physics_world =
    physics.new_world(
      physics.WorldConfig(gravity: vec3.Vec3(0.0, -9.81, 0.0)),
    )

  #(Model, effect.tick(Tick), option.Some(physics_world))
}

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context(Id),
) -> #(Model, Effect(Msg), option.Option(_)) {
  let assert option.Some(physics_world) = ctx.physics_world
  case msg {
    Tick -> {
      let new_physics_world = physics.step(physics_world)
      #(model, effect.tick(Tick), option.Some(new_physics_world))
    }
  }
}

fn view(_model: Model, ctx: tiramisu.Context(Id)) -> List(scene.Node(Id)) {
  let assert option.Some(physics_world) = ctx.physics_world
  let assert Ok(cam) = camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  let assert Ok(cube_geom) = geometry.box(width: 1.0, height: 1.0, depth: 1.0)
  let assert Ok(cube1_mat) = material.new() |> material.with_color(0xff4444) |> material.build
  let assert Ok(cube2_mat) = material.new() |> material.with_color(0x44ff44) |> material.build

  let assert Ok(ground_geom) = geometry.box(width: 20.0, height: 0.2, depth: 20.0)
  let assert Ok(ground_mat) = material.new() |> material.with_color(0x808080) |> material.build

  [
    scene.camera(
      id: Camera,
      camera: cam,
      transform: transform.at(position: vec3.Vec3(0.0, 10.0, 15.0)),
      look_at: option.Some(vec3.Vec3(0.0, 0.0, 0.0)),
      active: True,
      viewport: option.None,
    ),
    scene.light(
      id: Ambient,
      light: {
        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
        light
      },
      transform: transform.identity,
    ),
    scene.light(
      id: Directional,
      light: {
        let assert Ok(light) = light.directional(color: 0xffffff, intensity: 2.0)
        light
      },
      transform: transform.at(position: vec3.Vec3(5.0, 10.0, 7.5)),
    ),
    // Ground (static physics body)
    scene.mesh(
      id: Ground,
      geometry: ground_geom,
      material: ground_mat,
      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0)),
      physics: option.Some(
        physics.new_rigid_body(physics.Fixed)
        |> physics.with_collider(physics.Box(transform.identity, 20.0, 0.2, 20.0))
        |> physics.with_restitution(0.0)
        |> physics.build(),
      ),
    ),
    // Falling cube 1 (dynamic physics body)
    scene.mesh(
      id: Cube1,
      geometry: cube_geom,
      material: cube1_mat,
      transform: case physics.get_transform(physics_world, Cube1) {
        Ok(t) -> t
        Error(Nil) -> transform.at(position: vec3.Vec3(-2.0, 5.0, 0.0))
      },
      physics: option.Some(
        physics.new_rigid_body(physics.Dynamic)
        |> physics.with_collider(physics.Box(transform.identity, 1.0, 1.0, 1.0))
        |> physics.with_mass(1.0)
        |> physics.with_restitution(0.5)
        |> physics.with_friction(0.5)
        |> physics.build(),
      ),
    ),
    // Falling cube 2 (dynamic physics body)
    scene.mesh(
      id: Cube2,
      geometry: cube_geom,
      material: cube2_mat,
      transform: case physics.get_transform(physics_world, Cube2) {
        Ok(t) -> t
        Error(Nil) -> transform.at(position: vec3.Vec3(2.0, 7.0, 0.0))
      },
      physics: option.Some(
        physics.new_rigid_body(physics.Dynamic)
        |> physics.with_collider(physics.Box(transform.identity, 1.0, 1.0, 1.0))
        |> physics.with_mass(1.0)
        |> physics.with_restitution(0.6)
        |> physics.with_friction(0.3)
        |> physics.build(),
      ),
    ),
  ]
}
"/utf8>>.

-file("src/mascarpone.gleam", 907).
-spec create_main_file(binary(), template()) -> {ok, nil} | {error, snag:snag()}.
create_main_file(Project_name, Template) ->
    Root = find_root(<<"."/utf8>>),
    Src_dir = filepath:join(Root, <<"src"/utf8>>),
    Main_path = filepath:join(Src_dir, <<Project_name/binary, ".gleam"/utf8>>),
    Content = case Template of
        two_d_game ->
            generate_2d_template();

        three_d_game ->
            generate_3d_template();

        physics_demo ->
            generate_physics_template()
    end,
    _pipe = simplifile:write(Main_path, Content),
    snag:map_error(_pipe, fun(_) -> <<"Could not write main file"/utf8>> end).

-file("src/mascarpone.gleam", 1286).
-spec detect_platform() -> {ok, platform()} | {error, snag:snag()}.
detect_platform() ->
    case operating_system_ffi:name() of
        <<"nt"/utf8>> ->
            {ok, windows};

        <<"darwin"/utf8>> ->
            {ok, mac_o_s};

        _ ->
            {ok, linux}
    end.

-file("src/mascarpone.gleam", 1294).
-spec detect_architecture() -> architecture().
detect_architecture() ->
    case operating_system_ffi:name() of
        <<"darwin"/utf8>> ->
            aarch64;

        _ ->
            x64
    end.

-file("src/mascarpone.gleam", 1302).
-spec get_bun_platform_string(platform()) -> binary().
get_bun_platform_string(Platform) ->
    case Platform of
        linux ->
            <<"linux"/utf8>>;

        mac_o_s ->
            <<"darwin"/utf8>>;

        windows ->
            <<"windows"/utf8>>
    end.

-file("src/mascarpone.gleam", 1310).
-spec get_bun_arch_string(architecture()) -> binary().
get_bun_arch_string(Arch) ->
    case Arch of
        x64 ->
            <<"x64"/utf8>>;

        arm64 ->
            <<"arm64"/utf8>>;

        aarch64 ->
            <<"aarch64"/utf8>>
    end.

-file("src/mascarpone.gleam", 68).
-spec run_bundle_build() -> {ok, nil} | {error, snag:snag()}.
run_bundle_build() ->
    Root = find_root(<<"."/utf8>>),
    gleam@result:'try'(
        detect_platform(),
        fun(Platform) ->
            Arch = detect_architecture(),
            Platform_str = get_bun_platform_string(Platform),
            Arch_str = get_bun_arch_string(Arch),
            Bun_path = filepath:join(
                Root,
                <<<<<<<<".lustre/bin/bun-"/utf8, Platform_str/binary>>/binary,
                            "-"/utf8>>/binary,
                        Arch_str/binary>>/binary,
                    "/bun"/utf8>>
            ),
            gleam@result:'try'(
                begin
                    _pipe = simplifile_erl:is_file(Bun_path),
                    snag:map_error(
                        _pipe,
                        fun(Error) ->
                            <<"Could not check for bun executable: "/utf8,
                                (simplifile:describe_error(Error))/binary>>
                        end
                    )
                end,
                fun(Bun_exists) -> case Bun_exists of
                        false ->
                            {error,
                                snag:new(
                                    <<<<"Bun executable not found at "/utf8,
                                            Bun_path/binary>>/binary,
                                        ". Make sure lustre_dev_tools is properly installed."/utf8>>
                                )};

                        true ->
                            gleam_stdlib:println(
                                <<"📦 Running bun run build..."/utf8>>
                            ),
                            _pipe@1 = shellout:command(
                                Bun_path,
                                [<<"run"/utf8>>, <<"build"/utf8>>],
                                Root,
                                []
                            ),
                            _pipe@2 = snag:map_error(
                                _pipe@1,
                                fun(Error@1) ->
                                    <<"Failed to run bun build command: "/utf8,
                                        (erlang:element(2, Error@1))/binary>>
                                end
                            ),
                            gleam@result:replace(_pipe@2, nil)
                    end end
            )
        end
    ).

-file("src/mascarpone.gleam", 51).
-spec handle_bundle_command() -> nil.
handle_bundle_command() ->
    gleam_stdlib:println(<<"🎮 Starting desktop bundle build..."/utf8>>),
    gleam_stdlib:println(<<""/utf8>>),
    case run_bundle_build() of
        {ok, _} ->
            gleam_stdlib:println(<<""/utf8>>),
            gleam_stdlib:println(<<"✅ Desktop bundle build complete!"/utf8>>),
            gleam_stdlib:println(
                <<"   Check the build directory for platform distributions."/utf8>>
            );

        {error, Err} ->
            gleam_stdlib:println_error(<<""/utf8>>),
            gleam_stdlib:println_error(
                <<"❌ Bundle build failed: "/utf8,
                    (snag:pretty_print(Err))/binary>>
            )
    end.

-file("src/mascarpone.gleam", 1318).
-spec install_npm_packages() -> {ok, nil} | {error, snag:snag()}.
install_npm_packages() ->
    Root = find_root(<<"."/utf8>>),
    gleam@result:'try'(
        detect_platform(),
        fun(Platform) ->
            Arch = detect_architecture(),
            Platform_str = get_bun_platform_string(Platform),
            Arch_str = get_bun_arch_string(Arch),
            Bun_path = filepath:join(
                Root,
                <<<<<<<<".lustre/bin/bun-"/utf8, Platform_str/binary>>/binary,
                            "-"/utf8>>/binary,
                        Arch_str/binary>>/binary,
                    "/bun"/utf8>>
            ),
            gleam@result:'try'(
                begin
                    _pipe = simplifile_erl:is_file(Bun_path),
                    snag:map_error(
                        _pipe,
                        fun(Error) ->
                            <<"Could not check for bun executable: "/utf8,
                                (simplifile:describe_error(Error))/binary>>
                        end
                    )
                end,
                fun(Bun_exists) -> case Bun_exists of
                        false ->
                            {error,
                                snag:new(
                                    <<<<"Bun executable not found at "/utf8,
                                            Bun_path/binary>>/binary,
                                        ". Make sure lustre_dev_tools is properly installed."/utf8>>
                                )};

                        true ->
                            gleam@result:'try'(
                                begin
                                    _pipe@1 = shellout:command(
                                        Bun_path,
                                        [<<"add"/utf8>>,
                                            <<"three@^0.180.0"/utf8>>],
                                        Root,
                                        []
                                    ),
                                    snag:map_error(
                                        _pipe@1,
                                        fun(Error@1) ->
                                            <<"Failed to install three.js 0.180.0: "/utf8,
                                                (erlang:element(2, Error@1))/binary>>
                                        end
                                    )
                                end,
                                fun(_) ->
                                    _pipe@2 = shellout:command(
                                        Bun_path,
                                        [<<"add"/utf8>>,
                                            <<"@dimforge/rapier3d-compat@^0.11.2"/utf8>>],
                                        Root,
                                        []
                                    ),
                                    _pipe@3 = snag:map_error(
                                        _pipe@2,
                                        fun(Error@2) ->
                                            <<"Failed to install Rapier3D: "/utf8,
                                                (erlang:element(2, Error@2))/binary>>
                                        end
                                    ),
                                    gleam@result:replace(_pipe@3, nil)
                                end
                            )
                    end end
            )
        end
    ).

-file("src/mascarpone.gleam", 1375).
-spec install_nwbuilder() -> {ok, nil} | {error, snag:snag()}.
install_nwbuilder() ->
    Root = find_root(<<"."/utf8>>),
    gleam@result:'try'(
        detect_platform(),
        fun(Platform) ->
            Arch = detect_architecture(),
            Platform_str = get_bun_platform_string(Platform),
            Arch_str = get_bun_arch_string(Arch),
            Bun_path = filepath:join(
                Root,
                <<<<<<<<".lustre/bin/bun-"/utf8, Platform_str/binary>>/binary,
                            "-"/utf8>>/binary,
                        Arch_str/binary>>/binary,
                    "/bun"/utf8>>
            ),
            gleam@result:'try'(
                begin
                    _pipe = simplifile_erl:is_file(Bun_path),
                    snag:map_error(
                        _pipe,
                        fun(Error) ->
                            <<"Could not check for bun executable: "/utf8,
                                (simplifile:describe_error(Error))/binary>>
                        end
                    )
                end,
                fun(Bun_exists) -> case Bun_exists of
                        false ->
                            {error,
                                snag:new(
                                    <<<<"Bun executable not found at "/utf8,
                                            Bun_path/binary>>/binary,
                                        ". Make sure lustre_dev_tools is properly installed."/utf8>>
                                )};

                        true ->
                            _pipe@1 = shellout:command(
                                Bun_path,
                                [<<"add"/utf8>>,
                                    <<"--dev"/utf8>>,
                                    <<"nw-builder@^4.16.0"/utf8>>],
                                Root,
                                []
                            ),
                            _pipe@2 = snag:map_error(
                                _pipe@1,
                                fun(Error@1) ->
                                    <<"Failed to install nw-builder: "/utf8,
                                        (erlang:element(2, Error@1))/binary>>
                                end
                            ),
                            gleam@result:replace(_pipe@2, nil)
                    end end
            )
        end
    ).

-file("src/mascarpone.gleam", 1422).
-spec create_package_json(binary(), boolean()) -> binary().
create_package_json(Project_name, With_nwjs) ->
    Nwjs_config = case With_nwjs of
        true ->
            <<<<<<<<",
  \"main\": \"index.html\",
  \"window\": {
    \"title\": \""/utf8,
                            Project_name/binary>>/binary,
                        "\",
    \"width\": 1920,
    \"height\": 1080,
    \"nodejs\": true
  },
  \"scripts\": {
    \"build\": \"gleam run -m lustre/dev build && cp package.json dist/ && nwbuild --glob=false dist\"
  },
  \"nwbuild\": {
    \"flavor\": \"sdk\",
    \"srcDir\": \"dist\",
    \"mode\": \"build\",
    \"glob\": false,
    \"logLevel\": \"info\",
    \"app\": {
      \"icon\": \"\",
      \"LSApplicationCategoryType\": \"public.app-category.games\",
      \"NSHumanReadableCopyright\": \"Copyright © 2025\",
      \"NSLocalNetworkUsageDescription\": \"This application uses the local network.\"
    },
    \"outDir\": \"./"/utf8>>/binary,
                    Project_name/binary>>/binary,
                "_desktop_bundle\",
    \"macCategory\": \"public.app-category.games\",
    \"cacheDir\": \"./node_modules/nw\"
  },
  \"devDependencies\": {
    \"nw-builder\": \"^4.16.0\"
  },
  \"node-remote\": [\"https://cdn.jsdelivr.net/*\"]"/utf8>>;

        false ->
            <<""/utf8>>
    end,
    <<<<<<<<"{
  \"name\": \""/utf8, Project_name/binary>>/binary,
                "\",
  \"version\": \"1.0.0\""/utf8>>/binary,
            Nwjs_config/binary>>/binary,
        ",
  \"dependencies\": {
    \"three\": \"^0.180.0\",
    \"@dimforge/rapier3d-compat\": \"^0.11.2\"
  }
}"/utf8>>.

-file("src/mascarpone.gleam", 1468).
-spec setup_desktop_bundle(binary()) -> {ok, nil} | {error, snag:snag()}.
setup_desktop_bundle(Project_name) ->
    Root = find_root(<<"."/utf8>>),
    Package_json_path = filepath:join(Root, <<"package.json"/utf8>>),
    Package_json_content = create_package_json(Project_name, true),
    _pipe = simplifile:write(Package_json_path, Package_json_content),
    snag:map_error(_pipe, fun(_) -> <<"Could not write package.json"/utf8>> end).

-file("src/mascarpone.gleam", 182).
-spec update(model(), msg()) -> {model(), list(fun(() -> msg()))}.
update(Model, Msg) ->
    case Msg of
        next_step ->
            Next_step = case erlang:element(2, Model) of
                welcome ->
                    lustre_choice;

                lustre_choice ->
                    template_choice;

                template_choice ->
                    desktop_bundle_choice;

                desktop_bundle_choice ->
                    complete;

                {generating, _} ->
                    complete;

                complete ->
                    complete;

                {failed, _} ->
                    complete
            end,
            {{model,
                    Next_step,
                    erlang:element(3, Model),
                    erlang:element(4, Model),
                    erlang:element(5, Model),
                    erlang:element(6, Model),
                    erlang:element(7, Model)},
                []};

        {set_lustre, Value} ->
            {{model,
                    template_choice,
                    erlang:element(3, Model),
                    Value,
                    erlang:element(5, Model),
                    erlang:element(6, Model),
                    erlang:element(7, Model)},
                []};

        {set_template, Template} ->
            {{model,
                    desktop_bundle_choice,
                    erlang:element(3, Model),
                    erlang:element(4, Model),
                    erlang:element(5, Model),
                    {some, Template},
                    erlang:element(7, Model)},
                []};

        skip_template ->
            {{model,
                    desktop_bundle_choice,
                    erlang:element(3, Model),
                    erlang:element(4, Model),
                    erlang:element(5, Model),
                    none,
                    erlang:element(7, Model)},
                []};

        {set_desktop_bundle, Value@1} ->
            Updated_model = {model,
                erlang:element(2, Model),
                erlang:element(3, Model),
                erlang:element(4, Model),
                erlang:element(5, Model),
                erlang:element(6, Model),
                Value@1},
            Steps = generate_steps_list(Updated_model),
            {{model,
                    {generating, Steps},
                    erlang:element(3, Updated_model),
                    erlang:element(4, Updated_model),
                    erlang:element(5, Updated_model),
                    erlang:element(6, Updated_model),
                    erlang:element(7, Updated_model)},
                [fun() -> start_generation end]};

        start_generation ->
            {Model, [fun() -> update_gleam_toml end]};

        install_lustre_dev_tools ->
            Updated_model@1 = update_step_status(
                Model,
                <<"Installing Lustre dev tools"/utf8>>,
                status_in_progress
            ),
            case install_lustre_dev_tools() of
                {ok, _} ->
                    {update_step_status(
                            Updated_model@1,
                            <<"Installing Lustre dev tools"/utf8>>,
                            status_complete
                        ),
                        [fun() -> install_npm_packages end]};

                {error, Err} ->
                    {update_step_status(
                            Updated_model@1,
                            <<"Installing Lustre dev tools"/utf8>>,
                            {status_failed, snag:pretty_print(Err)}
                        ),
                        [fun() ->
                                {generation_failed, snag:pretty_print(Err)}
                            end]}
            end;

        update_gleam_toml ->
            Updated_model@2 = update_step_status(
                Model,
                <<"Updating gleam.toml"/utf8>>,
                status_in_progress
            ),
            case update_gleam_toml(
                erlang:element(3, Model),
                erlang:element(4, Model)
            ) of
                {ok, _} ->
                    {update_step_status(
                            Updated_model@2,
                            <<"Updating gleam.toml"/utf8>>,
                            status_complete
                        ),
                        [fun() -> install_lustre_dev_tools end]};

                {error, Err@1} ->
                    {update_step_status(
                            Updated_model@2,
                            <<"Updating gleam.toml"/utf8>>,
                            {status_failed, snag:pretty_print(Err@1)}
                        ),
                        [fun() ->
                                {generation_failed, snag:pretty_print(Err@1)}
                            end]}
            end;

        install_npm_packages ->
            Updated_model@3 = update_step_status(
                Model,
                <<"Installing Three.js and Rapier3D"/utf8>>,
                status_in_progress
            ),
            case install_npm_packages() of
                {ok, _} ->
                    {update_step_status(
                            Updated_model@3,
                            <<"Installing Three.js and Rapier3D"/utf8>>,
                            status_complete
                        ),
                        [fun() -> create_gitignore end]};

                {error, Err@2} ->
                    {update_step_status(
                            Updated_model@3,
                            <<"Installing Three.js and Rapier3D"/utf8>>,
                            {status_failed, snag:pretty_print(Err@2)}
                        ),
                        [fun() ->
                                {generation_failed, snag:pretty_print(Err@2)}
                            end]}
            end;

        create_gitignore ->
            Updated_model@4 = update_step_status(
                Model,
                <<"Creating .gitignore"/utf8>>,
                status_in_progress
            ),
            case create_gitignore() of
                {ok, _} ->
                    {update_step_status(
                            Updated_model@4,
                            <<"Creating .gitignore"/utf8>>,
                            status_complete
                        ),
                        [fun() -> case erlang:element(6, Model) of
                                    {some, _} ->
                                        create_main_file;

                                    none ->
                                        case erlang:element(7, Model) of
                                            true ->
                                                install_nw_builder;

                                            false ->
                                                generation_complete
                                        end
                                end end]};

                {error, Err@3} ->
                    {update_step_status(
                            Updated_model@4,
                            <<"Creating .gitignore"/utf8>>,
                            {status_failed, snag:pretty_print(Err@3)}
                        ),
                        [fun() ->
                                {generation_failed, snag:pretty_print(Err@3)}
                            end]}
            end;

        create_main_file ->
            Updated_model@5 = update_step_status(
                Model,
                <<"Creating main game file"/utf8>>,
                status_in_progress
            ),
            case create_main_file(
                erlang:element(3, Model),
                gleam@option:unwrap(erlang:element(6, Model), three_d_game)
            ) of
                {ok, _} ->
                    case erlang:element(7, Model) of
                        true ->
                            {update_step_status(
                                    Updated_model@5,
                                    <<"Creating main game file"/utf8>>,
                                    status_complete
                                ),
                                [fun() -> install_nw_builder end]};

                        false ->
                            {update_step_status(
                                    Updated_model@5,
                                    <<"Creating main game file"/utf8>>,
                                    status_complete
                                ),
                                [fun() -> generation_complete end]}
                    end;

                {error, Err@4} ->
                    {update_step_status(
                            Updated_model@5,
                            <<"Creating main game file"/utf8>>,
                            {status_failed, snag:pretty_print(Err@4)}
                        ),
                        [fun() ->
                                {generation_failed, snag:pretty_print(Err@4)}
                            end]}
            end;

        install_nw_builder ->
            Updated_model@6 = update_step_status(
                Model,
                <<"Installing nw-builder"/utf8>>,
                status_in_progress
            ),
            case install_nwbuilder() of
                {ok, _} ->
                    {update_step_status(
                            Updated_model@6,
                            <<"Installing nw-builder"/utf8>>,
                            status_complete
                        ),
                        [fun() -> setup_desktop_bundle end]};

                {error, Err@5} ->
                    {update_step_status(
                            Updated_model@6,
                            <<"Installing nw-builder"/utf8>>,
                            {status_failed, snag:pretty_print(Err@5)}
                        ),
                        [fun() ->
                                {generation_failed, snag:pretty_print(Err@5)}
                            end]}
            end;

        setup_desktop_bundle ->
            Updated_model@7 = update_step_status(
                Model,
                <<"Setting up desktop bundle"/utf8>>,
                status_in_progress
            ),
            case setup_desktop_bundle(erlang:element(3, Model)) of
                {ok, _} ->
                    {update_step_status(
                            Updated_model@7,
                            <<"Setting up desktop bundle"/utf8>>,
                            status_complete
                        ),
                        [fun() -> generation_complete end]};

                {error, Err@6} ->
                    {update_step_status(
                            Updated_model@7,
                            <<"Setting up desktop bundle"/utf8>>,
                            {status_failed, snag:pretty_print(Err@6)}
                        ),
                        [fun() ->
                                {generation_failed, snag:pretty_print(Err@6)}
                            end]}
            end;

        generation_complete ->
            {{model,
                    complete,
                    erlang:element(3, Model),
                    erlang:element(4, Model),
                    erlang:element(5, Model),
                    erlang:element(6, Model),
                    erlang:element(7, Model)},
                []};

        {generation_failed, Err@7} ->
            {{model,
                    {failed, Err@7},
                    erlang:element(3, Model),
                    erlang:element(4, Model),
                    erlang:element(5, Model),
                    erlang:element(6, Model),
                    erlang:element(7, Model)},
                []}
    end.

-file("src/mascarpone.gleam", 27).
-spec run_interactive_mode() -> nil.
run_interactive_mode() ->
    Exit = gleam@erlang@process:new_subject(),
    case get_project_name() of
        {ok, Project_name} ->
            case begin
                _pipe = shore:spec(
                    fun() -> init(Project_name) end,
                    fun view/1,
                    fun update/2,
                    Exit,
                    shore:default_keybinds(),
                    shore:on_update()
                ),
                shore:start(_pipe)
            end of
                {ok, _} -> nil;
                _assert_fail ->
                    erlang:error(#{gleam_error => let_assert,
                                message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                                file => <<?FILEPATH/utf8>>,
                                module => <<"mascarpone"/utf8>>,
                                function => <<"run_interactive_mode"/utf8>>,
                                line => 32,
                                value => _assert_fail,
                                start => 650,
                                'end' => 924,
                                pattern_start => 661,
                                pattern_end => 671})
            end,
            _pipe@1 = Exit,
            gleam_erlang_ffi:'receive'(_pipe@1);

        {error, Err} ->
            gleam_stdlib:println_error(
                <<"\n❌ Error: "/utf8, (snag:pretty_print(Err))/binary>>
            )
    end.

-file("src/mascarpone.gleam", 19).
-spec main() -> nil.
main() ->
    case erlang:element(4, argv:load()) of
        [<<"bundle"/utf8>>] ->
            handle_bundle_command();

        _ ->
            run_interactive_mode()
    end.
