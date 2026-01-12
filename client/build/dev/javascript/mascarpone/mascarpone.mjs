import * as $argv from "../argv/argv.mjs";
import * as $filepath from "../filepath/filepath.mjs";
import * as $process from "../gleam_erlang/gleam/erlang/process.mjs";
import * as $io from "../gleam_stdlib/gleam/io.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../gleam_stdlib/gleam/option.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import * as $string from "../gleam_stdlib/gleam/string.mjs";
import * as $operating_system from "../operating_system/operating_system.mjs";
import * as $shellout from "../shellout/shellout.mjs";
import * as $shore from "../shore/shore.mjs";
import * as $key from "../shore/shore/key.mjs";
import * as $style from "../shore/shore/style.mjs";
import * as $ui from "../shore/shore/ui.mjs";
import * as $simplifile from "../simplifile/simplifile.mjs";
import * as $snag from "../snag/snag.mjs";
import * as $tom from "../tom/tom.mjs";
import { Ok, Error, toList, CustomType as $CustomType } from "./gleam.mjs";

class Welcome extends $CustomType {}

class LustreChoice extends $CustomType {}

class TemplateChoice extends $CustomType {}

class DesktopBundleChoice extends $CustomType {}

class Generating extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Complete extends $CustomType {}

class Failed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StepPending extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StepInProgress extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StepComplete extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StepFailed extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}

class TwoDGame extends $CustomType {}

class ThreeDGame extends $CustomType {}

class PhysicsDemo extends $CustomType {}

class Model extends $CustomType {
  constructor(step, project_name, include_lustre, include_physics, template, bundle_desktop) {
    super();
    this.step = step;
    this.project_name = project_name;
    this.include_lustre = include_lustre;
    this.include_physics = include_physics;
    this.template = template;
    this.bundle_desktop = bundle_desktop;
  }
}

class NextStep extends $CustomType {}

class SetLustre extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class SetTemplate extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class SkipTemplate extends $CustomType {}

class SetDesktopBundle extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StartGeneration extends $CustomType {}

class InstallLustreDevTools extends $CustomType {}

class UpdateGleamToml extends $CustomType {}

class InstallNpmPackages extends $CustomType {}

class CreateGitignore extends $CustomType {}

class CreateMainFile extends $CustomType {}

class InstallNwBuilder extends $CustomType {}

class SetupDesktopBundle extends $CustomType {}

class GenerationComplete extends $CustomType {}

class GenerationFailed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class StatusPending extends $CustomType {}

class StatusInProgress extends $CustomType {}

class StatusComplete extends $CustomType {}

class StatusFailed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}

class Linux extends $CustomType {}

class MacOS extends $CustomType {}

class Windows extends $CustomType {}

class X64 extends $CustomType {}

class Arm64 extends $CustomType {}

class Aarch64 extends $CustomType {}

function init(project_name) {
  return [
    new Model(new Welcome(), project_name, true, false, new None(), false),
    toList([]),
  ];
}

function generate_steps_list(model) {
  let base_steps = toList([
    new StepPending("Installing Lustre dev tools"),
    new StepPending("Updating gleam.toml"),
    new StepPending("Installing Three.js and Rapier3D"),
    new StepPending("Creating .gitignore"),
    new StepPending("Creating index.html"),
  ]);
  let _block;
  let $ = model.template;
  if ($ instanceof Some) {
    _block = $list.append(
      base_steps,
      toList([new StepPending("Creating main game file")]),
    );
  } else {
    _block = base_steps;
  }
  let with_template = _block;
  let $1 = model.bundle_desktop;
  if ($1) {
    return $list.append(
      with_template,
      toList([
        new StepPending("Installing nw-builder"),
        new StepPending("Setting up desktop bundle"),
      ]),
    );
  } else {
    return with_template;
  }
}

function update_step_status(model, step_name, status) {
  let $ = model.step;
  if ($ instanceof Generating) {
    let steps = $[0];
    let updated_steps = $list.map(
      steps,
      (step) => {
        if (step instanceof StepPending) {
          let name = step[0];
          if (name === step_name) {
            if (status instanceof StatusPending) {
              return step;
            } else if (status instanceof StatusInProgress) {
              return new StepInProgress(name);
            } else if (status instanceof StatusComplete) {
              return new StepComplete(name);
            } else {
              let err = status[0];
              return new StepFailed(name, err);
            }
          } else {
            return step;
          }
        } else if (step instanceof StepInProgress) {
          let name = step[0];
          if (name === step_name) {
            if (status instanceof StatusComplete) {
              return new StepComplete(name);
            } else if (status instanceof StatusFailed) {
              let err = status[0];
              return new StepFailed(name, err);
            } else {
              return step;
            }
          } else {
            return step;
          }
        } else {
          return step;
        }
      },
    );
    return new Model(
      new Generating(updated_steps),
      model.project_name,
      model.include_lustre,
      model.include_physics,
      model.template,
      model.bundle_desktop,
    );
  } else {
    return model;
  }
}

function view_welcome() {
  return $ui.col(
    toList([
      $ui.text_styled(
        "╔═══════════════════════════════════╗",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text_styled(
        "║   🎮 Tiramisu Project Creator 🎮  ║",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text_styled(
        "║   Gleam 3D Game Engine            ║",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text_styled(
        "╚═══════════════════════════════════╝",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text(""),
      $ui.text("Welcome to Tiramisu! 🍰"),
      $ui.text(""),
      $ui.text(
        "This wizard will help you set up Tiramisu for your game project.",
      ),
      $ui.text(""),
      $ui.hr(),
      $ui.text(""),
      $ui.text_styled(
        "Press Enter to continue",
        new Some(new $style.Yellow()),
        new None(),
      ),
      $ui.text(""),
      $ui.button("Continue", new $key.Enter(), new NextStep()),
    ]),
  );
}

function view_lustre_choice() {
  return $ui.col(
    toList([
      $ui.text_styled(
        "Lustre Integration",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text(""),
      $ui.text("Lustre allows you to create UI overlays for your game"),
      $ui.text("(menus, HUDs, dialogs, etc.) using a reactive framework."),
      $ui.text(""),
      $ui.hr(),
      $ui.text(""),
      $ui.text("Include Lustre?"),
      $ui.text(""),
      $ui.button(
        "[Y] Yes (recommended)",
        new $key.Char("y"),
        new SetLustre(true),
      ),
      $ui.button("[N] No", new $key.Char("n"), new SetLustre(false)),
    ]),
  );
}

function view_template_choice() {
  return $ui.col(
    toList([
      $ui.text_styled(
        "Project Template",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text(""),
      $ui.text_styled(
        "⚠️  WARNING: Selecting a template is DESTRUCTIVE!",
        new Some(new $style.Red()),
        new None(),
      ),
      $ui.text_styled(
        "It will OVERWRITE your existing game code in src/",
        new Some(new $style.Red()),
        new None(),
      ),
      $ui.text(""),
      $ui.text("If you're setting up NW.js for an existing project,"),
      $ui.text("press [S] to skip template selection."),
      $ui.text(""),
      $ui.hr(),
      $ui.text(""),
      $ui.button(
        "[1] 2D Game - Orthographic camera and sprite setup",
        new $key.Char("1"),
        new SetTemplate(new TwoDGame()),
      ),
      $ui.button(
        "[2] 3D Game - Perspective camera with lighting",
        new $key.Char("2"),
        new SetTemplate(new ThreeDGame()),
      ),
      $ui.button(
        "[3] Physics Demo - Physics-enabled objects",
        new $key.Char("3"),
        new SetTemplate(new PhysicsDemo()),
      ),
      $ui.text(""),
      $ui.button(
        "[S] Skip - Don't create/overwrite game files",
        new $key.Char("s"),
        new SkipTemplate(),
      ),
    ]),
  );
}

function view_desktop_bundle_choice() {
  return $ui.col(
    toList([
      $ui.text_styled(
        "Desktop Bundle for NW.js",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text(""),
      $ui.text("Bundle for desktop will:"),
      $ui.text("  • Install nw-builder to manage NW.js builds"),
      $ui.text("  • Configure package.json with NW.js settings"),
      $ui.text("  • Set up build configuration for all platforms"),
      $ui.text(""),
      $ui.text("After setup, run 'bun run build' to create platform builds"),
      $ui.text(""),
      $ui.hr(),
      $ui.text(""),
      $ui.text("Bundle for desktop?"),
      $ui.text(""),
      $ui.button("[Y] Yes", new $key.Char("y"), new SetDesktopBundle(true)),
      $ui.button("[N] No", new $key.Char("n"), new SetDesktopBundle(false)),
    ]),
  );
}

function view_generating(steps) {
  let header = toList([
    $ui.text_styled(
      "╔═══════════════════════════════════╗",
      new Some(new $style.Cyan()),
      new None(),
    ),
    $ui.text_styled(
      "║     Setting up your project...    ║",
      new Some(new $style.Cyan()),
      new None(),
    ),
    $ui.text_styled(
      "╚═══════════════════════════════════╝",
      new Some(new $style.Cyan()),
      new None(),
    ),
    $ui.text(""),
  ]);
  let step_views = $list.map(
    steps,
    (step) => {
      if (step instanceof StepPending) {
        let name = step[0];
        return $ui.text_styled(
          "  ⏸  " + name,
          new Some(new $style.White()),
          new None(),
        );
      } else if (step instanceof StepInProgress) {
        let name = step[0];
        return $ui.text_styled(
          ("  ⏳ " + name) + "...",
          new Some(new $style.Yellow()),
          new None(),
        );
      } else if (step instanceof StepComplete) {
        let name = step[0];
        return $ui.text_styled(
          "  ✓  " + name,
          new Some(new $style.Green()),
          new None(),
        );
      } else {
        let name = step[0];
        return $ui.text_styled(
          "  ✗  " + name,
          new Some(new $style.Red()),
          new None(),
        );
      }
    },
  );
  return $ui.col($list.append(header, step_views));
}

function view_error(msg) {
  return $ui.col(
    toList([
      $ui.text_styled(
        "❌ Error occurred",
        new Some(new $style.Red()),
        new None(),
      ),
      $ui.text(""),
      $ui.text(msg),
    ]),
  );
}

function template_name(template) {
  if (template instanceof TwoDGame) {
    return "2D Game";
  } else if (template instanceof ThreeDGame) {
    return "3D Game";
  } else {
    return "Physics Demo";
  }
}

function view_complete(model) {
  let _block;
  let $ = model.template;
  if ($ instanceof Some) {
    let t = $[0];
    _block = template_name(t);
  } else {
    _block = "None (skipped)";
  }
  let template_text = _block;
  let base_items = toList([
    $ui.text_styled(
      "✅ Project setup complete!",
      new Some(new $style.Green()),
      new None(),
    ),
    $ui.text(""),
    $ui.text("Project: " + model.project_name),
    $ui.text("Template: " + template_text),
    $ui.text(
      "Lustre: " + (() => {
        let $1 = model.include_lustre;
        if ($1) {
          return "Yes";
        } else {
          return "No";
        }
      })(),
    ),
    $ui.text(
      "Physics: " + (() => {
        let $1 = model.include_physics;
        if ($1) {
          return "Yes";
        } else {
          return "No";
        }
      })(),
    ),
    $ui.text(
      "Desktop Bundle: " + (() => {
        let $1 = model.bundle_desktop;
        if ($1) {
          return "Yes";
        } else {
          return "No";
        }
      })(),
    ),
    $ui.text(""),
    $ui.hr(),
    $ui.text(""),
    $ui.text("Next steps:"),
    $ui.text(""),
  ]);
  let _block$1;
  let $1 = model.bundle_desktop;
  if ($1) {
    _block$1 = toList([
      $ui.text("1. Build platform distributions:"),
      $ui.text_styled(
        "   bun run build",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text(""),
      $ui.text(
        ("2. Find your builds in ./" + model.project_name) + "_desktop_bundle/:",
      ),
      $ui.text(
        ("   • " + model.project_name) + "_desktop_bundle/nwjs-v*-linux-x64/",
      ),
      $ui.text(
        ("   • " + model.project_name) + "_desktop_bundle/nwjs-v*-win-x64/",
      ),
      $ui.text(
        ("   • " + model.project_name) + "_desktop_bundle/nwjs-v*-osx-arm64/",
      ),
      $ui.text(""),
      $ui.text("3. Or run in dev mode:"),
      $ui.text_styled(
        "   gleam run -m lustre/dev start",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text("   Then open http://localhost:1234 in your browser"),
    ]);
  } else {
    _block$1 = toList([
      $ui.text("1. Start the dev server:"),
      $ui.text_styled(
        "   gleam run -m lustre/dev start",
        new Some(new $style.Cyan()),
        new None(),
      ),
      $ui.text(""),
      $ui.text("2. Open http://localhost:1234 in your browser"),
    ]);
  }
  let next_steps = _block$1;
  let footer = toList([
    $ui.text(""),
    $ui.text("Happy game development! 🎮"),
    $ui.text(""),
    $ui.text("Press Ctrl + X to leave"),
  ]);
  return $ui.col($list.flatten(toList([base_items, next_steps, footer])));
}

function view(model) {
  let $ = model.step;
  if ($ instanceof Welcome) {
    return view_welcome();
  } else if ($ instanceof LustreChoice) {
    return view_lustre_choice();
  } else if ($ instanceof TemplateChoice) {
    return view_template_choice();
  } else if ($ instanceof DesktopBundleChoice) {
    return view_desktop_bundle_choice();
  } else if ($ instanceof Generating) {
    let steps = $[0];
    return view_generating(steps);
  } else if ($ instanceof Complete) {
    return view_complete(model);
  } else {
    let msg = $[0];
    return view_error(msg);
  }
}

function find_root(loop$path) {
  while (true) {
    let path = loop$path;
    let toml = $filepath.join(path, "gleam.toml");
    let $ = $simplifile.is_file(toml);
    if ($ instanceof Ok) {
      let $1 = $[0];
      if ($1) {
        return path;
      } else {
        loop$path = $filepath.join(path, "..");
      }
    } else {
      loop$path = $filepath.join(path, "..");
    }
  }
}

function install_lustre_dev_tools() {
  let root = find_root(".");
  let _pipe = $shellout.command(
    "gleam",
    toList(["run", "-m", "lustre/dev", "add", "bun"]),
    root,
    toList([]),
  );
  let _pipe$1 = $result.map_error(
    _pipe,
    (error) => {
      return $snag.new$("Failed to install Lustre dev tools: " + error[1]);
    },
  );
  return $result.replace(_pipe$1, undefined);
}

function get_project_name() {
  let root = find_root(".");
  let toml_path = $filepath.join(root, "gleam.toml");
  return $result.try$(
    (() => {
      let _pipe = $simplifile.read(toml_path);
      return $snag.map_error(
        _pipe,
        (_) => { return "Could not read gleam.toml"; },
      );
    })(),
    (content) => {
      return $result.try$(
        (() => {
          let _pipe = $tom.parse(content);
          return $snag.map_error(
            _pipe,
            (_) => { return "Could not parse gleam.toml"; },
          );
        })(),
        (toml) => {
          return $result.try$(
            (() => {
              let _pipe = $tom.get_string(toml, toList(["name"]));
              return $snag.map_error(
                _pipe,
                (_) => { return "Could not find project name in gleam.toml"; },
              );
            })(),
            (name) => { return new Ok(name); },
          );
        },
      );
    },
  );
}

function update_gleam_toml(project_name, include_lustre) {
  let root = find_root(".");
  let toml_path = $filepath.join(root, "gleam.toml");
  return $result.try$(
    (() => {
      let _pipe = $simplifile.read(toml_path);
      return $snag.map_error(
        _pipe,
        (_) => { return "Could not read gleam.toml"; },
      );
    })(),
    (content) => {
      let _block;
      let $ = $string.contains(content, "target =");
      if ($) {
        _block = content;
      } else {
        _block = $string.replace(
          content,
          ("name = \"" + project_name) + "\"",
          ("name = \"" + project_name) + "\"\ntarget = \"javascript\"",
        );
      }
      let content$1 = _block;
      return $result.try$(
        (() => {
          let _pipe = $simplifile.write(toml_path, content$1);
          return $snag.map_error(
            _pipe,
            (_) => { return "Could not write gleam.toml"; },
          );
        })(),
        (_) => {
          return $result.try$(
            (() => {
              let _pipe = $shellout.command(
                "gleam",
                toList(["add", "tiramisu"]),
                root,
                toList([]),
              );
              return $snag.map_error(
                _pipe,
                (error) => {
                  return "Failed to add tiramisu dependency: " + error[1];
                },
              );
            })(),
            (_) => {
              return $result.try$(
                (() => {
                  let _pipe = $shellout.command(
                    "gleam",
                    toList(["add", "vec"]),
                    root,
                    toList([]),
                  );
                  return $snag.map_error(
                    _pipe,
                    (error) => {
                      return "Failed to add vec dependency: " + error[1];
                    },
                  );
                })(),
                (_) => {
                  return $result.try$(
                    (() => {
                      let _pipe = $shellout.command(
                        "gleam",
                        toList(["add", "--dev", "lustre_dev_tools"]),
                        root,
                        toList([]),
                      );
                      return $snag.map_error(
                        _pipe,
                        (error) => {
                          return "Failed to add lustre_dev_tools dependency: " + error[1];
                        },
                      );
                    })(),
                    (_) => {
                      return $result.try$(
                        (() => {
                          if (include_lustre) {
                            let _pipe = $shellout.command(
                              "gleam",
                              toList(["add", "lustre"]),
                              root,
                              toList([]),
                            );
                            return $snag.map_error(
                              _pipe,
                              (error) => {
                                return "Failed to add lustre dependency: " + error[1];
                              },
                            );
                          } else {
                            return new Ok("");
                          }
                        })(),
                        (_) => {
                          return $result.try$(
                            (() => {
                              let _pipe = $simplifile.read(toml_path);
                              return $snag.map_error(
                                _pipe,
                                (_) => { return "Could not read gleam.toml"; },
                              );
                            })(),
                            (content) => {
                              let lustre_config = "\n\n[tools.lustre.html]\nscripts = [\n  { type = \"importmap\", content = \"{ \\\"imports\\\": { \\\"three\\\": \\\"https://cdn.jsdelivr.net/npm/three@0.180.0/build/three.module.js\\\", \\\"three/addons/\\\": \\\"https://cdn.jsdelivr.net/npm/three@0.180.0/examples/jsm/\\\", \\\"@dimforge/rapier3d-compat\\\": \\\"https://cdn.jsdelivr.net/npm/@dimforge/rapier3d-compat@0.11.2/+esm\\\" } }\" }\n]\nstylesheets = [\n  { content = \"body { margin: 0; padding: 0; overflow: hidden; }\" }\n]\n";
                              let _block$1;
                              let $1 = $string.contains(
                                content,
                                "[tools.lustre.html]",
                              );
                              if ($1) {
                                _block$1 = content;
                              } else {
                                _block$1 = content + lustre_config;
                              }
                              let final_content = _block$1;
                              let _pipe = $simplifile.write(
                                toml_path,
                                final_content,
                              );
                              return $snag.map_error(
                                _pipe,
                                (_) => { return "Could not write gleam.toml"; },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

function create_gitignore() {
  let root = find_root(".");
  let gitignore_path = $filepath.join(root, ".gitignore");
  let content = "*.beam\n*.ez\n/build\nerl_crash.dump\n/priv\n.DS_Store\nnode_modules/\n.lustre/\ndist/\n*_desktop_bundle/";
  let _pipe = $simplifile.write(gitignore_path, content);
  return $snag.map_error(_pipe, (_) => { return "Could not write .gitignore"; });
}

function generate_2d_template() {
  return "/// 2D Game Example - Orthographic Camera\nimport gleam/float\nimport gleam/option\nimport tiramisu\nimport tiramisu/background\nimport tiramisu/camera\nimport tiramisu/effect.{type Effect}\nimport tiramisu/geometry\nimport tiramisu/light\nimport tiramisu/material\nimport tiramisu/scene\nimport tiramisu/transform\nimport vec/vec3\n\npub type Model {\n  Model(time: Float)\n}\n\npub type Msg {\n  Tick\n}\n\npub fn main() -> Nil {\n  tiramisu.run(\n    dimensions: option.None,\n    background: background.Color(0x1a1a2e),\n    init: init,\n    update: update,\n    view: view,\n  )\n}\n\nfn init(_ctx: tiramisu.Context(String)) -> #(Model, Effect(Msg), option.Option(_)) {\n  #(Model(time: 0.0), effect.tick(Tick), option.None)\n}\n\nfn update(\n  model: Model,\n  msg: Msg,\n  ctx: tiramisu.Context(String),\n) -> #(Model, Effect(Msg), option.Option(_)) {\n  case msg {\n    Tick -> {\n      let new_time = model.time +. ctx.delta_time /. 1000.0\n      #(Model(time: new_time), effect.tick(Tick), option.None)\n    }\n  }\n}\n\nfn view(model: Model, ctx: tiramisu.Context(String)) -> List(scene.Node(String)) {\n  let cam = camera.camera_2d(\n    width: float.round(ctx.canvas_width),\n    height: float.round(ctx.canvas_height),\n  )\n  let assert Ok(sprite_geom) = geometry.plane(width: 50.0, height: 50.0)\n  let assert Ok(sprite_mat) = material.basic(color: 0xff0066, transparent: False, opacity: 1.0, map: option.None)\n\n  [\n    scene.camera(\n      id: \"camera\",\n      camera: cam,\n      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 20.0)),\n      look_at: option.None,\n      active: True,\n      viewport: option.None,\n    ),\n    scene.light(\n      id: \"ambient\",\n      light: {\n        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 1.0)\n        light\n      },\n      transform: transform.identity,\n    ),\n    scene.mesh(\n      id: \"sprite\",\n      geometry: sprite_geom,\n      material: sprite_mat,\n      transform: \n        transform.at(position: vec3.Vec3(0.0, 0.0, 0.0))\n        |> transform.with_euler_rotation(vec3.Vec3(0.0, 0.0, model.time)),\n      physics: option.None,\n    ),\n  ]\n}\n";
}

function generate_3d_template() {
  return "/// 3D Game Example - Perspective Camera with Lighting\nimport gleam/option\nimport tiramisu\nimport tiramisu/background\nimport tiramisu/camera\nimport tiramisu/effect.{type Effect}\nimport tiramisu/geometry\nimport tiramisu/light\nimport tiramisu/material\nimport tiramisu/scene\nimport tiramisu/transform\nimport vec/vec3\n\npub type Model {\n  Model(time: Float)\n}\n\npub type Msg {\n  Tick\n}\n\npub fn main() -> Nil {\n  tiramisu.run(\n    dimensions: option.None,\n    background: background.Color(0x1a1a2e),\n    init: init,\n    update: update,\n    view: view,\n  )\n}\n\nfn init(_ctx: tiramisu.Context(String)) -> #(Model, Effect(Msg), option.Option(_)) {\n  #(Model(time: 0.0), effect.tick(Tick), option.None)\n}\n\nfn update(\n  model: Model,\n  msg: Msg,\n  ctx: tiramisu.Context(String),\n) -> #(Model, Effect(Msg), option.Option(_)) {\n  case msg {\n    Tick -> {\n      let new_time = model.time +. ctx.delta_time\n      #(Model(time: new_time), effect.tick(Tick), option.None)\n    }\n  }\n}\n\nfn view(model: Model, _ctx: tiramisu.Context(String)) -> List(scene.Node(String)) {\n  let assert Ok(cam) = camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)\n  let assert Ok(sphere_geom) = geometry.sphere(radius: 1.0, width_segments: 32, height_segments: 32)\n  let assert Ok(sphere_mat) = material.new() |> material.with_color(0x0066ff) |> material.build\n  let assert Ok(ground_geom) = geometry.plane(width: 20.0, height: 20.0)\n  let assert Ok(ground_mat) = material.new() |> material.with_color(0x808080) |> material.build\n\n  [\n    scene.camera(\n      id: \"camera\",\n      camera: cam,\n      transform: transform.at(position: vec3.Vec3(0.0, 5.0, 10.0)),\n      look_at: option.Some(vec3.Vec3(0.0, 0.0, 0.0)),\n      active: True,\n      viewport: option.None,\n    ),\n    scene.light(\n      id: \"ambient\",\n      light: {\n        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)\n        light\n      },\n      transform: transform.identity,\n    ),\n    scene.light(\n      id: \"directional\",\n      light: {\n        let assert Ok(light) = light.directional(color: 0xffffff, intensity: 0.8)\n        light\n      },\n      transform: transform.at(position: vec3.Vec3(10.0, 10.0, 10.0)),\n    ),\n    scene.mesh(\n      id: \"sphere\",\n      geometry: sphere_geom,\n      material: sphere_mat,\n      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0)),\n      physics: option.None,\n    ),\n    scene.mesh(\n      id: \"ground\",\n      geometry: ground_geom,\n      material: ground_mat,\n      transform: \n        transform.at(position: vec3.Vec3(0.0, -2.0, 0.0)) \n        |> transform.with_euler_rotation(vec3.Vec3(-1.57, 0.0, 0.0)),\n      physics: option.None,\n    ),\n  ]\n}\n";
}

function generate_physics_template() {
  return "/// Physics Demo - Falling Cubes\n/// Demonstrates physics simulation with Rapier3D\nimport gleam/option\nimport tiramisu\nimport tiramisu/background\nimport tiramisu/camera\nimport tiramisu/effect.{type Effect}\nimport tiramisu/geometry\nimport tiramisu/light\nimport tiramisu/material\nimport tiramisu/physics\nimport tiramisu/scene\nimport tiramisu/transform\nimport vec/vec3\n\npub type Id {\n  Camera\n  Ambient\n  Directional\n  Ground\n  Cube1\n  Cube2\n}\n\npub type Model {\n  Model\n}\n\npub type Msg {\n  Tick\n}\n\npub fn main() -> Nil {\n  tiramisu.run(\n    dimensions: option.None,\n    background: background.Color(0x1a1a2e),\n    init: init,\n    update: update,\n    view: view,\n  )\n}\n\nfn init(_ctx: tiramisu.Context(Id)) -> #(Model, Effect(Msg), option.Option(_)) {\n  // Initialize physics world with gravity\n  let physics_world =\n    physics.new_world(\n      physics.WorldConfig(gravity: vec3.Vec3(0.0, -9.81, 0.0)),\n    )\n\n  #(Model, effect.tick(Tick), option.Some(physics_world))\n}\n\nfn update(\n  model: Model,\n  msg: Msg,\n  ctx: tiramisu.Context(Id),\n) -> #(Model, Effect(Msg), option.Option(_)) {\n  let assert option.Some(physics_world) = ctx.physics_world\n  case msg {\n    Tick -> {\n      let new_physics_world = physics.step(physics_world)\n      #(model, effect.tick(Tick), option.Some(new_physics_world))\n    }\n  }\n}\n\nfn view(_model: Model, ctx: tiramisu.Context(Id)) -> List(scene.Node(Id)) {\n  let assert option.Some(physics_world) = ctx.physics_world\n  let assert Ok(cam) = camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)\n\n  let assert Ok(cube_geom) = geometry.box(width: 1.0, height: 1.0, depth: 1.0)\n  let assert Ok(cube1_mat) = material.new() |> material.with_color(0xff4444) |> material.build\n  let assert Ok(cube2_mat) = material.new() |> material.with_color(0x44ff44) |> material.build\n\n  let assert Ok(ground_geom) = geometry.box(width: 20.0, height: 0.2, depth: 20.0)\n  let assert Ok(ground_mat) = material.new() |> material.with_color(0x808080) |> material.build\n\n  [\n    scene.camera(\n      id: Camera,\n      camera: cam,\n      transform: transform.at(position: vec3.Vec3(0.0, 10.0, 15.0)),\n      look_at: option.Some(vec3.Vec3(0.0, 0.0, 0.0)),\n      active: True,\n      viewport: option.None,\n    ),\n    scene.light(\n      id: Ambient,\n      light: {\n        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)\n        light\n      },\n      transform: transform.identity,\n    ),\n    scene.light(\n      id: Directional,\n      light: {\n        let assert Ok(light) = light.directional(color: 0xffffff, intensity: 2.0)\n        light\n      },\n      transform: transform.at(position: vec3.Vec3(5.0, 10.0, 7.5)),\n    ),\n    // Ground (static physics body)\n    scene.mesh(\n      id: Ground,\n      geometry: ground_geom,\n      material: ground_mat,\n      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0)),\n      physics: option.Some(\n        physics.new_rigid_body(physics.Fixed)\n        |> physics.with_collider(physics.Box(transform.identity, 20.0, 0.2, 20.0))\n        |> physics.with_restitution(0.0)\n        |> physics.build(),\n      ),\n    ),\n    // Falling cube 1 (dynamic physics body)\n    scene.mesh(\n      id: Cube1,\n      geometry: cube_geom,\n      material: cube1_mat,\n      transform: case physics.get_transform(physics_world, Cube1) {\n        Ok(t) -> t\n        Error(Nil) -> transform.at(position: vec3.Vec3(-2.0, 5.0, 0.0))\n      },\n      physics: option.Some(\n        physics.new_rigid_body(physics.Dynamic)\n        |> physics.with_collider(physics.Box(transform.identity, 1.0, 1.0, 1.0))\n        |> physics.with_mass(1.0)\n        |> physics.with_restitution(0.5)\n        |> physics.with_friction(0.5)\n        |> physics.build(),\n      ),\n    ),\n    // Falling cube 2 (dynamic physics body)\n    scene.mesh(\n      id: Cube2,\n      geometry: cube_geom,\n      material: cube2_mat,\n      transform: case physics.get_transform(physics_world, Cube2) {\n        Ok(t) -> t\n        Error(Nil) -> transform.at(position: vec3.Vec3(2.0, 7.0, 0.0))\n      },\n      physics: option.Some(\n        physics.new_rigid_body(physics.Dynamic)\n        |> physics.with_collider(physics.Box(transform.identity, 1.0, 1.0, 1.0))\n        |> physics.with_mass(1.0)\n        |> physics.with_restitution(0.6)\n        |> physics.with_friction(0.3)\n        |> physics.build(),\n      ),\n    ),\n  ]\n}\n";
}

function create_main_file(project_name, template) {
  let root = find_root(".");
  let src_dir = $filepath.join(root, "src");
  let main_path = $filepath.join(src_dir, project_name + ".gleam");
  let _block;
  if (template instanceof TwoDGame) {
    _block = generate_2d_template();
  } else if (template instanceof ThreeDGame) {
    _block = generate_3d_template();
  } else {
    _block = generate_physics_template();
  }
  let content = _block;
  let _pipe = $simplifile.write(main_path, content);
  return $snag.map_error(_pipe, (_) => { return "Could not write main file"; });
}

function detect_platform() {
  let $ = $operating_system.name();
  if ($ === "nt") {
    return new Ok(new Windows());
  } else if ($ === "darwin") {
    return new Ok(new MacOS());
  } else {
    return new Ok(new Linux());
  }
}

function detect_architecture() {
  let $ = $operating_system.name();
  if ($ === "darwin") {
    return new Aarch64();
  } else {
    return new X64();
  }
}

function get_bun_platform_string(platform) {
  if (platform instanceof Linux) {
    return "linux";
  } else if (platform instanceof MacOS) {
    return "darwin";
  } else {
    return "windows";
  }
}

function get_bun_arch_string(arch) {
  if (arch instanceof X64) {
    return "x64";
  } else if (arch instanceof Arm64) {
    return "arm64";
  } else {
    return "aarch64";
  }
}

function run_bundle_build() {
  let root = find_root(".");
  return $result.try$(
    detect_platform(),
    (platform) => {
      let arch = detect_architecture();
      let platform_str = get_bun_platform_string(platform);
      let arch_str = get_bun_arch_string(arch);
      let bun_path = $filepath.join(
        root,
        (((".lustre/bin/bun-" + platform_str) + "-") + arch_str) + "/bun",
      );
      return $result.try$(
        (() => {
          let _pipe = $simplifile.is_file(bun_path);
          return $snag.map_error(
            _pipe,
            (error) => {
              return "Could not check for bun executable: " + $simplifile.describe_error(
                error,
              );
            },
          );
        })(),
        (bun_exists) => {
          if (bun_exists) {
            $io.println("📦 Running bun run build...");
            let _pipe = $shellout.command(
              bun_path,
              toList(["run", "build"]),
              root,
              toList([]),
            );
            let _pipe$1 = $snag.map_error(
              _pipe,
              (error) => {
                return "Failed to run bun build command: " + error[1];
              },
            );
            return $result.replace(_pipe$1, undefined);
          } else {
            return new Error(
              $snag.new$(
                ("Bun executable not found at " + bun_path) + ". Make sure lustre_dev_tools is properly installed.",
              ),
            );
          }
        },
      );
    },
  );
}

function handle_bundle_command() {
  $io.println("🎮 Starting desktop bundle build...");
  $io.println("");
  let $ = run_bundle_build();
  if ($ instanceof Ok) {
    $io.println("");
    $io.println("✅ Desktop bundle build complete!");
    return $io.println(
      "   Check the build directory for platform distributions.",
    );
  } else {
    let err = $[0];
    $io.println_error("");
    return $io.println_error(
      "❌ Bundle build failed: " + $snag.pretty_print(err),
    );
  }
}

function install_npm_packages() {
  let root = find_root(".");
  return $result.try$(
    detect_platform(),
    (platform) => {
      let arch = detect_architecture();
      let platform_str = get_bun_platform_string(platform);
      let arch_str = get_bun_arch_string(arch);
      let bun_path = $filepath.join(
        root,
        (((".lustre/bin/bun-" + platform_str) + "-") + arch_str) + "/bun",
      );
      return $result.try$(
        (() => {
          let _pipe = $simplifile.is_file(bun_path);
          return $snag.map_error(
            _pipe,
            (error) => {
              return "Could not check for bun executable: " + $simplifile.describe_error(
                error,
              );
            },
          );
        })(),
        (bun_exists) => {
          if (bun_exists) {
            return $result.try$(
              (() => {
                let _pipe = $shellout.command(
                  bun_path,
                  toList(["add", "three@^0.180.0"]),
                  root,
                  toList([]),
                );
                return $snag.map_error(
                  _pipe,
                  (error) => {
                    return "Failed to install three.js 0.180.0: " + error[1];
                  },
                );
              })(),
              (_) => {
                let _pipe = $shellout.command(
                  bun_path,
                  toList(["add", "@dimforge/rapier3d-compat@^0.11.2"]),
                  root,
                  toList([]),
                );
                let _pipe$1 = $snag.map_error(
                  _pipe,
                  (error) => {
                    return "Failed to install Rapier3D: " + error[1];
                  },
                );
                return $result.replace(_pipe$1, undefined);
              },
            );
          } else {
            return new Error(
              $snag.new$(
                ("Bun executable not found at " + bun_path) + ". Make sure lustre_dev_tools is properly installed.",
              ),
            );
          }
        },
      );
    },
  );
}

function install_nwbuilder() {
  let root = find_root(".");
  return $result.try$(
    detect_platform(),
    (platform) => {
      let arch = detect_architecture();
      let platform_str = get_bun_platform_string(platform);
      let arch_str = get_bun_arch_string(arch);
      let bun_path = $filepath.join(
        root,
        (((".lustre/bin/bun-" + platform_str) + "-") + arch_str) + "/bun",
      );
      return $result.try$(
        (() => {
          let _pipe = $simplifile.is_file(bun_path);
          return $snag.map_error(
            _pipe,
            (error) => {
              return "Could not check for bun executable: " + $simplifile.describe_error(
                error,
              );
            },
          );
        })(),
        (bun_exists) => {
          if (bun_exists) {
            let _pipe = $shellout.command(
              bun_path,
              toList(["add", "--dev", "nw-builder@^4.16.0"]),
              root,
              toList([]),
            );
            let _pipe$1 = $snag.map_error(
              _pipe,
              (error) => { return "Failed to install nw-builder: " + error[1]; },
            );
            return $result.replace(_pipe$1, undefined);
          } else {
            return new Error(
              $snag.new$(
                ("Bun executable not found at " + bun_path) + ". Make sure lustre_dev_tools is properly installed.",
              ),
            );
          }
        },
      );
    },
  );
}

function create_package_json(project_name, with_nwjs) {
  let _block;
  if (with_nwjs) {
    _block = (((",\n  \"main\": \"index.html\",\n  \"window\": {\n    \"title\": \"" + project_name) + "\",\n    \"width\": 1920,\n    \"height\": 1080,\n    \"nodejs\": true\n  },\n  \"scripts\": {\n    \"build\": \"gleam run -m lustre/dev build && cp package.json dist/ && nwbuild --glob=false dist\"\n  },\n  \"nwbuild\": {\n    \"flavor\": \"sdk\",\n    \"srcDir\": \"dist\",\n    \"mode\": \"build\",\n    \"glob\": false,\n    \"logLevel\": \"info\",\n    \"app\": {\n      \"icon\": \"\",\n      \"LSApplicationCategoryType\": \"public.app-category.games\",\n      \"NSHumanReadableCopyright\": \"Copyright © 2025\",\n      \"NSLocalNetworkUsageDescription\": \"This application uses the local network.\"\n    },\n    \"outDir\": \"./") + project_name) + "_desktop_bundle\",\n    \"macCategory\": \"public.app-category.games\",\n    \"cacheDir\": \"./node_modules/nw\"\n  },\n  \"devDependencies\": {\n    \"nw-builder\": \"^4.16.0\"\n  },\n  \"node-remote\": [\"https://cdn.jsdelivr.net/*\"]";
  } else {
    _block = "";
  }
  let nwjs_config = _block;
  return ((("{\n  \"name\": \"" + project_name) + "\",\n  \"version\": \"1.0.0\"") + nwjs_config) + ",\n  \"dependencies\": {\n    \"three\": \"^0.180.0\",\n    \"@dimforge/rapier3d-compat\": \"^0.11.2\"\n  }\n}";
}

function setup_desktop_bundle(project_name) {
  let root = find_root(".");
  let package_json_path = $filepath.join(root, "package.json");
  let package_json_content = create_package_json(project_name, true);
  let _pipe = $simplifile.write(package_json_path, package_json_content);
  return $snag.map_error(
    _pipe,
    (_) => { return "Could not write package.json"; },
  );
}

function update(model, msg) {
  if (msg instanceof NextStep) {
    let _block;
    let $ = model.step;
    if ($ instanceof Welcome) {
      _block = new LustreChoice();
    } else if ($ instanceof LustreChoice) {
      _block = new TemplateChoice();
    } else if ($ instanceof TemplateChoice) {
      _block = new DesktopBundleChoice();
    } else if ($ instanceof DesktopBundleChoice) {
      _block = new Complete();
    } else if ($ instanceof Generating) {
      _block = new Complete();
    } else if ($ instanceof Complete) {
      _block = $;
    } else {
      _block = new Complete();
    }
    let next_step = _block;
    return [
      new Model(
        next_step,
        model.project_name,
        model.include_lustre,
        model.include_physics,
        model.template,
        model.bundle_desktop,
      ),
      toList([]),
    ];
  } else if (msg instanceof SetLustre) {
    let value = msg[0];
    return [
      new Model(
        new TemplateChoice(),
        model.project_name,
        value,
        model.include_physics,
        model.template,
        model.bundle_desktop,
      ),
      toList([]),
    ];
  } else if (msg instanceof SetTemplate) {
    let template = msg[0];
    return [
      new Model(
        new DesktopBundleChoice(),
        model.project_name,
        model.include_lustre,
        model.include_physics,
        new Some(template),
        model.bundle_desktop,
      ),
      toList([]),
    ];
  } else if (msg instanceof SkipTemplate) {
    return [
      new Model(
        new DesktopBundleChoice(),
        model.project_name,
        model.include_lustre,
        model.include_physics,
        new None(),
        model.bundle_desktop,
      ),
      toList([]),
    ];
  } else if (msg instanceof SetDesktopBundle) {
    let value = msg[0];
    let updated_model = new Model(
      model.step,
      model.project_name,
      model.include_lustre,
      model.include_physics,
      model.template,
      value,
    );
    let steps = generate_steps_list(updated_model);
    return [
      new Model(
        new Generating(steps),
        updated_model.project_name,
        updated_model.include_lustre,
        updated_model.include_physics,
        updated_model.template,
        updated_model.bundle_desktop,
      ),
      toList([() => { return new StartGeneration(); }]),
    ];
  } else if (msg instanceof StartGeneration) {
    return [model, toList([() => { return new UpdateGleamToml(); }])];
  } else if (msg instanceof InstallLustreDevTools) {
    let updated_model = update_step_status(
      model,
      "Installing Lustre dev tools",
      new StatusInProgress(),
    );
    let $ = install_lustre_dev_tools();
    if ($ instanceof Ok) {
      return [
        update_step_status(
          updated_model,
          "Installing Lustre dev tools",
          new StatusComplete(),
        ),
        toList([() => { return new InstallNpmPackages(); }]),
      ];
    } else {
      let err = $[0];
      return [
        update_step_status(
          updated_model,
          "Installing Lustre dev tools",
          new StatusFailed($snag.pretty_print(err)),
        ),
        toList([() => { return new GenerationFailed($snag.pretty_print(err)); }]),
      ];
    }
  } else if (msg instanceof UpdateGleamToml) {
    let updated_model = update_step_status(
      model,
      "Updating gleam.toml",
      new StatusInProgress(),
    );
    let $ = update_gleam_toml(model.project_name, model.include_lustre);
    if ($ instanceof Ok) {
      return [
        update_step_status(
          updated_model,
          "Updating gleam.toml",
          new StatusComplete(),
        ),
        toList([() => { return new InstallLustreDevTools(); }]),
      ];
    } else {
      let err = $[0];
      return [
        update_step_status(
          updated_model,
          "Updating gleam.toml",
          new StatusFailed($snag.pretty_print(err)),
        ),
        toList([() => { return new GenerationFailed($snag.pretty_print(err)); }]),
      ];
    }
  } else if (msg instanceof InstallNpmPackages) {
    let updated_model = update_step_status(
      model,
      "Installing Three.js and Rapier3D",
      new StatusInProgress(),
    );
    let $ = install_npm_packages();
    if ($ instanceof Ok) {
      return [
        update_step_status(
          updated_model,
          "Installing Three.js and Rapier3D",
          new StatusComplete(),
        ),
        toList([() => { return new CreateGitignore(); }]),
      ];
    } else {
      let err = $[0];
      return [
        update_step_status(
          updated_model,
          "Installing Three.js and Rapier3D",
          new StatusFailed($snag.pretty_print(err)),
        ),
        toList([() => { return new GenerationFailed($snag.pretty_print(err)); }]),
      ];
    }
  } else if (msg instanceof CreateGitignore) {
    let updated_model = update_step_status(
      model,
      "Creating .gitignore",
      new StatusInProgress(),
    );
    let $ = create_gitignore();
    if ($ instanceof Ok) {
      return [
        update_step_status(
          updated_model,
          "Creating .gitignore",
          new StatusComplete(),
        ),
        toList([
          () => {
            let $1 = model.template;
            if ($1 instanceof Some) {
              return new CreateMainFile();
            } else {
              let $2 = model.bundle_desktop;
              if ($2) {
                return new InstallNwBuilder();
              } else {
                return new GenerationComplete();
              }
            }
          },
        ]),
      ];
    } else {
      let err = $[0];
      return [
        update_step_status(
          updated_model,
          "Creating .gitignore",
          new StatusFailed($snag.pretty_print(err)),
        ),
        toList([() => { return new GenerationFailed($snag.pretty_print(err)); }]),
      ];
    }
  } else if (msg instanceof CreateMainFile) {
    let updated_model = update_step_status(
      model,
      "Creating main game file",
      new StatusInProgress(),
    );
    let $ = create_main_file(
      model.project_name,
      $option.unwrap(model.template, new ThreeDGame()),
    );
    if ($ instanceof Ok) {
      let $1 = model.bundle_desktop;
      if ($1) {
        return [
          update_step_status(
            updated_model,
            "Creating main game file",
            new StatusComplete(),
          ),
          toList([() => { return new InstallNwBuilder(); }]),
        ];
      } else {
        return [
          update_step_status(
            updated_model,
            "Creating main game file",
            new StatusComplete(),
          ),
          toList([() => { return new GenerationComplete(); }]),
        ];
      }
    } else {
      let err = $[0];
      return [
        update_step_status(
          updated_model,
          "Creating main game file",
          new StatusFailed($snag.pretty_print(err)),
        ),
        toList([() => { return new GenerationFailed($snag.pretty_print(err)); }]),
      ];
    }
  } else if (msg instanceof InstallNwBuilder) {
    let updated_model = update_step_status(
      model,
      "Installing nw-builder",
      new StatusInProgress(),
    );
    let $ = install_nwbuilder();
    if ($ instanceof Ok) {
      return [
        update_step_status(
          updated_model,
          "Installing nw-builder",
          new StatusComplete(),
        ),
        toList([() => { return new SetupDesktopBundle(); }]),
      ];
    } else {
      let err = $[0];
      return [
        update_step_status(
          updated_model,
          "Installing nw-builder",
          new StatusFailed($snag.pretty_print(err)),
        ),
        toList([() => { return new GenerationFailed($snag.pretty_print(err)); }]),
      ];
    }
  } else if (msg instanceof SetupDesktopBundle) {
    let updated_model = update_step_status(
      model,
      "Setting up desktop bundle",
      new StatusInProgress(),
    );
    let $ = setup_desktop_bundle(model.project_name);
    if ($ instanceof Ok) {
      return [
        update_step_status(
          updated_model,
          "Setting up desktop bundle",
          new StatusComplete(),
        ),
        toList([() => { return new GenerationComplete(); }]),
      ];
    } else {
      let err = $[0];
      return [
        update_step_status(
          updated_model,
          "Setting up desktop bundle",
          new StatusFailed($snag.pretty_print(err)),
        ),
        toList([() => { return new GenerationFailed($snag.pretty_print(err)); }]),
      ];
    }
  } else if (msg instanceof GenerationComplete) {
    return [
      new Model(
        new Complete(),
        model.project_name,
        model.include_lustre,
        model.include_physics,
        model.template,
        model.bundle_desktop,
      ),
      toList([]),
    ];
  } else {
    let err = msg[0];
    return [
      new Model(
        new Failed(err),
        model.project_name,
        model.include_lustre,
        model.include_physics,
        model.template,
        model.bundle_desktop,
      ),
      toList([]),
    ];
  }
}
