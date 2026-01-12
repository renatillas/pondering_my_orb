import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $effect from "../../tiramisu/tiramisu/effect.mjs";
import * as $texture from "../../tiramisu/tiramisu/texture.mjs";
import { toList, CustomType as $CustomType } from "../gleam.mjs";

export class SparkProjectile extends $CustomType {}
export const TextureId$SparkProjectile = () => new SparkProjectile();
export const TextureId$isSparkProjectile = (value) =>
  value instanceof SparkProjectile;

export class LightningProjectile extends $CustomType {}
export const TextureId$LightningProjectile = () => new LightningProjectile();
export const TextureId$isLightningProjectile = (value) =>
  value instanceof LightningProjectile;

export class OrbitingShardsProjectile extends $CustomType {}
export const TextureId$OrbitingShardsProjectile = () =>
  new OrbitingShardsProjectile();
export const TextureId$isOrbitingShardsProjectile = (value) =>
  value instanceof OrbitingShardsProjectile;

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
  constructor(load_state, textures) {
    super();
    this.load_state = load_state;
    this.textures = textures;
  }
}
export const Model$Model = (load_state, textures) =>
  new Model(load_state, textures);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$load_state = (value) => value.load_state;
export const Model$Model$0 = (value) => value.load_state;
export const Model$Model$textures = (value) => value.textures;
export const Model$Model$1 = (value) => value.textures;

export class TextureLoaded extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Msg$TextureLoaded = ($0, $1) => new TextureLoaded($0, $1);
export const Msg$isTextureLoaded = (value) => value instanceof TextureLoaded;
export const Msg$TextureLoaded$0 = (value) => value[0];
export const Msg$TextureLoaded$1 = (value) => value[1];

export class TextureLoadFailed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$TextureLoadFailed = ($0) => new TextureLoadFailed($0);
export const Msg$isTextureLoadFailed = (value) =>
  value instanceof TextureLoadFailed;
export const Msg$TextureLoadFailed$0 = (value) => value[0];

/**
 * All textures to load with their paths
 * 
 * @ignore
 */
function texture_paths() {
  return toList([
    [new SparkProjectile(), "spell_projectiles/spark.png"],
    [new LightningProjectile(), "spell_projectiles/lightning_bolt.png"],
    [new OrbitingShardsProjectile(), "spell_projectiles/orbiting_shard.png"],
  ]);
}

function total_textures() {
  return $list.length(texture_paths());
}

export function init() {
  let model = new Model(new Loading(0, total_textures()), $dict.new$());
  let _block;
  let _pipe = texture_paths();
  let _pipe$1 = $list.map(
    _pipe,
    (entry) => {
      let id;
      let path;
      id = entry[0];
      path = entry[1];
      return $texture.load(
        path,
        (_capture) => { return new TextureLoaded(id, _capture); },
        new TextureLoadFailed(id),
      );
    },
  );
  _block = $effect.batch(_pipe$1);
  let load_effects = _block;
  return [model, load_effects];
}

/**
 * Check if all assets are loaded
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
    return [total_textures(), total_textures()];
  } else {
    return [0, total_textures()];
  }
}

/**
 * Get a texture by ID
 */
export function get_texture(model, id) {
  let _pipe = $dict.get(model.textures, id);
  return $option.from_result(_pipe);
}

/**
 * Map a texture path to its TextureId
 */
export function texture_id_for_path(path) {
  let _pipe = texture_paths();
  let _pipe$1 = $list.find(_pipe, (entry) => { return entry[1] === path; });
  let _pipe$2 = $option.from_result(_pipe$1);
  return $option.map(_pipe$2, (entry) => { return entry[0]; });
}

function texture_id_to_string(id) {
  if (id instanceof SparkProjectile) {
    return "SparkProjectile";
  } else if (id instanceof LightningProjectile) {
    return "LightningProjectile";
  } else {
    return "OrbitingShardsProjectile";
  }
}

export function update(model, msg) {
  if (msg instanceof TextureLoaded) {
    let id = msg[0];
    let tex = msg[1];
    let new_textures = $dict.insert(model.textures, id, tex);
    let new_loaded = $dict.size(new_textures);
    let _block;
    let $ = new_loaded >= total_textures();
    if ($) {
      _block = new Loaded();
    } else {
      _block = new Loading(new_loaded, total_textures());
    }
    let new_state = _block;
    return [new Model(new_state, new_textures), $effect.none()];
  } else {
    let id = msg[0];
    let error_msg = "Failed to load texture: " + texture_id_to_string(id);
    return [new Model(new Failed(error_msg), model.textures), $effect.none()];
  }
}
