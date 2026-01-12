import * as $colour from "../../gleam_community_colour/gleam_community/colour.mjs";
import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $effect from "../../tiramisu/tiramisu/effect.mjs";
import * as $geometry from "../../tiramisu/tiramisu/geometry.mjs";
import * as $light from "../../tiramisu/tiramisu/light.mjs";
import * as $material from "../../tiramisu/tiramisu/material.mjs";
import * as $model from "../../tiramisu/tiramisu/model.mjs";
import * as $physics from "../../tiramisu/tiramisu/physics.mjs";
import * as $scene from "../../tiramisu/tiramisu/scene.mjs";
import * as $transform from "../../tiramisu/tiramisu/transform.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import * as $layer from "../client/game_physics/layer.mjs";
import * as $id from "../client/id.mjs";
import * as $generator from "../client/map/generator.mjs";
import { Ok, toList, CustomType as $CustomType, makeError, divideFloat } from "../gleam.mjs";

const FILEPATH = "src/client/map.gleam";

export class Loading extends $CustomType {
  constructor(loaded, total) {
    super();
    this.loaded = loaded;
    this.total = total;
  }
}
export const LoadState$Loading = (loaded, total) => new Loading(loaded, total);
export const LoadState$isLoading = (value) => value instanceof Loading;
export const LoadState$Loading$loaded = (value) => value.loaded;
export const LoadState$Loading$0 = (value) => value.loaded;
export const LoadState$Loading$total = (value) => value.total;
export const LoadState$Loading$1 = (value) => value.total;

export class Loaded extends $CustomType {}
export const LoadState$Loaded = () => new Loaded();
export const LoadState$isLoaded = (value) => value instanceof Loaded;

export class Failed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const LoadState$Failed = ($0) => new Failed($0);
export const LoadState$isFailed = (value) => value instanceof Failed;
export const LoadState$Failed$0 = (value) => value[0];

export class Model extends $CustomType {
  constructor(load_state, arena, models) {
    super();
    this.load_state = load_state;
    this.arena = arena;
    this.models = models;
  }
}
export const Model$Model = (load_state, arena, models) =>
  new Model(load_state, arena, models);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$load_state = (value) => value.load_state;
export const Model$Model$0 = (value) => value.load_state;
export const Model$Model$arena = (value) => value.arena;
export const Model$Model$1 = (value) => value.arena;
export const Model$Model$models = (value) => value.models;
export const Model$Model$2 = (value) => value.models;

export class ModelLoaded extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Msg$ModelLoaded = ($0, $1) => new ModelLoaded($0, $1);
export const Msg$isModelLoaded = (value) => value instanceof ModelLoaded;
export const Msg$ModelLoaded$0 = (value) => value[0];
export const Msg$ModelLoaded$1 = (value) => value[1];

export class LoadFailed extends $CustomType {}
export const Msg$LoadFailed = () => new LoadFailed();
export const Msg$isLoadFailed = (value) => value instanceof LoadFailed;

const model_scale = 0.1;

/**
 * All models to load with their paths
 * 
 * @ignore
 */
function model_paths() {
  return toList([
    ["floor", "medieval/Models/floor.fbx"],
    ["wall", "medieval/Models/wall-fortified.fbx"],
  ]);
}

function total_models() {
  return $list.length(model_paths());
}

export function init() {
  let map_model = new Model(
    new Loading(0, total_models()),
    $generator.create_arena(),
    $dict.new$(),
  );
  let _block;
  let _pipe = model_paths();
  let _pipe$1 = $list.map(
    _pipe,
    (entry) => {
      let key;
      let path;
      key = entry[0];
      path = entry[1];
      return $model.load_fbx(
        path,
        (_capture) => { return new ModelLoaded(key, _capture); },
        new LoadFailed(),
      );
    },
  );
  _block = $effect.batch(_pipe$1);
  let load_effects = _block;
  return [map_model, load_effects];
}

/**
 * Check if all map assets are loaded
 */
export function is_loaded(model) {
  return model.load_state instanceof Loaded;
}

/**
 * Get loading progress as (loaded, total)
 */
export function get_progress(model) {
  let $ = model.load_state;
  if ($ instanceof Loading) {
    let loaded = $.loaded;
    let total = $.total;
    return [loaded, total];
  } else if ($ instanceof Loaded) {
    return [total_models(), total_models()];
  } else {
    return [0, total_models()];
  }
}

export function update(map_model, msg) {
  if (msg instanceof ModelLoaded) {
    let key = msg[0];
    let data = msg[1];
    let new_models = $dict.insert(map_model.models, key, data);
    let new_loaded = $dict.size(new_models);
    let _block;
    let $ = new_loaded >= total_models();
    if ($) {
      _block = new Loaded();
    } else {
      _block = new Loading(new_loaded, total_models());
    }
    let new_state = _block;
    return [new Model(new_state, map_model.arena, new_models), $effect.none()];
  } else {
    return [
      new Model(
        new Failed("Failed to load models"),
        map_model.arena,
        map_model.models,
      ),
      $effect.none(),
    ];
  }
}

function loading_indicator(loaded, total) {
  let $ = $geometry.box(new $vec3.Vec3(1.0, 1.0, 1.0));
  let geo;
  if ($ instanceof Ok) {
    geo = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/map",
      145,
      "loading_indicator",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 3816,
        end: 3875,
        pattern_start: 3827,
        pattern_end: 3834
      }
    )
  }
  let _block;
  let _pipe = $material.new$();
  let _pipe$1 = $material.with_color(_pipe, 0x4ecdc4);
  _block = $material.build(_pipe$1);
  let $1 = _block;
  let mat;
  if ($1 instanceof Ok) {
    mat = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/map",
      146,
      "loading_indicator",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 3878,
        end: 3978,
        pattern_start: 3889,
        pattern_end: 3896
      }
    )
  }
  let progress = divideFloat($int.to_float(loaded), $int.to_float(total));
  return $scene.mesh(
    "loading-cube",
    geo,
    mat,
    (() => {
      let _pipe$2 = $transform.at(new $vec3.Vec3(0.0, 0.0, 0.0));
      return $transform.with_scale(
        _pipe$2,
        new $vec3.Vec3(1.0 + progress, 1.0 + progress, 1.0 + progress),
      );
    })(),
    new $option.None(),
  );
}

function error_indicator() {
  let $ = $geometry.box(new $vec3.Vec3(2.0, 2.0, 2.0));
  let geo;
  if ($ instanceof Ok) {
    geo = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/map",
      168,
      "error_indicator",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 4380,
        end: 4439,
        pattern_start: 4391,
        pattern_end: 4398
      }
    )
  }
  let _block;
  let _pipe = $material.new$();
  let _pipe$1 = $material.with_color(_pipe, 0xff0000);
  _block = $material.build(_pipe$1);
  let $1 = _block;
  let mat;
  if ($1 instanceof Ok) {
    mat = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/map",
      169,
      "error_indicator",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 4442,
        end: 4542,
        pattern_start: 4453,
        pattern_end: 4460
      }
    )
  }
  return $scene.mesh(
    "error-cube",
    geo,
    mat,
    $transform.identity,
    new $option.None(),
  );
}

/**
 * Create a physics body for wall elements
 * Layer 2 = Ground/Walls, collides with Player (0) and Enemies (1)
 * Zero friction to allow smooth sliding along walls
 * 
 * @ignore
 */
function create_wall_physics() {
  let _pipe = $physics.new_rigid_body(new $physics.Fixed());
  let _pipe$1 = $physics.with_collider(
    _pipe,
    new $physics.Box($transform.identity, new $vec3.Vec3(10.0, 10.0, 10.0)),
  );
  let _pipe$2 = $physics.with_collision_groups(
    _pipe$1,
    toList([$layer.map]),
    toList([$layer.player, $layer.enemy]),
  );
  let _pipe$3 = $physics.with_friction(_pipe$2, 0.0);
  return $physics.build(_pipe$3);
}

function create_lights() {
  let $ = $light.ambient(0.2, 0xffffff);
  let ambient_light;
  if ($ instanceof Ok) {
    ambient_light = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/map",
      269,
      "create_lights",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 7381,
        end: 7458,
        pattern_start: 7392,
        pattern_end: 7409
      }
    )
  }
  let ambient = $scene.light("ambient", ambient_light, $transform.identity);
  let _block;
  let _pipe = $light.directional(
    1.5,
    (() => {
      let _pipe = $colour.white;
      return $colour.to_rgb_hex(_pipe);
    })(),
  );
  let _pipe$1 = $result.map(
    _pipe,
    (_capture) => { return $light.with_shadows(_capture, true); },
  );
  _block = $result.try$(
    _pipe$1,
    (_capture) => { return $light.with_shadow_resolution(_capture, 4096); },
  );
  let $1 = _block;
  let dir_light;
  if ($1 instanceof Ok) {
    dir_light = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/map",
      278,
      "create_lights",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 7616,
        end: 7826,
        pattern_start: 7627,
        pattern_end: 7640
      }
    )
  }
  let directional = $scene.light(
    "sun",
    dir_light,
    $transform.at(new $vec3.Vec3(-30.0, 60.0, -30.0)),
  );
  let $2 = $light.hemisphere(0.3, 0x87ceeb, 0x8b7355);
  let hemi_light;
  if ($2 instanceof Ok) {
    hemi_light = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/map",
      290,
      "create_lights",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 8028,
        end: 8162,
        pattern_start: 8039,
        pattern_end: 8053
      }
    )
  }
  let hemisphere = $scene.light("hemisphere", hemi_light, $transform.identity);
  return toList([ambient, directional, hemisphere]);
}

function render_element(key, id_constructor, map_model, element, index) {
  let $ = $dict.get(map_model.models, key);
  if ($ instanceof Ok) {
    let fbx = $[0];
    let _block;
    let $1 = id_constructor(index);
    if ($1 instanceof $id.Wall) {
      _block = new $option.Some(create_wall_physics());
    } else {
      _block = new $option.None();
    }
    let physics_body = _block;
    return new Ok(
      $scene.object_3d(
        $id.to_string(id_constructor(index)),
        $model.get_fbx_scene(fbx),
        (() => {
          let _pipe = $transform.at(element.position);
          let _pipe$1 = $transform.with_scale(
            _pipe,
            new $vec3.Vec3(model_scale, model_scale, model_scale),
          );
          return $transform.with_euler_rotation(
            _pipe$1,
            new $vec3.Vec3(0.0, element.rotation, 0.0),
          );
        })(),
        new $option.None(),
        physics_body,
        new $option.None(),
        false,
      ),
    );
  } else {
    return $;
  }
}

function render_arena(map_model) {
  let _block;
  let _pipe = map_model.arena.elements;
  let _pipe$1 = $list.index_map(
    _pipe,
    (element, index) => {
      if (element instanceof $generator.Floor) {
        return render_element(
          "floor",
          (var0) => { return new $id.Floor(var0); },
          map_model,
          element,
          index,
        );
      } else {
        return render_element(
          "wall",
          (var0) => { return new $id.Wall(var0); },
          map_model,
          element,
          index,
        );
      }
    },
  );
  _block = $list.filter_map(_pipe$1, (x) => { return x; });
  let element_nodes = _block;
  let light_nodes = create_lights();
  return $list.flatten(toList([light_nodes, element_nodes]));
}

export function view(map_model) {
  let $ = map_model.load_state;
  if ($ instanceof Loading) {
    let loaded = $.loaded;
    let total = $.total;
    return toList([loading_indicator(loaded, total)]);
  } else if ($ instanceof Loaded) {
    return render_arena(map_model);
  } else {
    return toList([error_indicator()]);
  }
}
