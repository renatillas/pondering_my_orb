import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}
import tiramisu/effect
import tiramisu/texture.{type Texture}

// =============================================================================
// TYPES
// =============================================================================

/// Identifier for each texture asset
pub type TextureId {
  SparkProjectile
  LightningProjectile
  OrbitingShardsProjectile
}

/// Loading state for assets
pub type LoadState {
  Loading(loaded: Int, total: Int)
  Loaded
  Failed(String)
}

pub type Model {
  Model(load_state: LoadState, textures: Dict(TextureId, Texture))
}

pub type Msg {
  TextureLoaded(TextureId, Texture)
  TextureLoadFailed(TextureId)
}

// =============================================================================
// CONSTANTS
// =============================================================================

/// All textures to load with their paths
fn texture_paths() -> List(#(TextureId, String)) {
  [
    #(SparkProjectile, "spell_projectiles/spark.png"),
    #(LightningProjectile, "spell_projectiles/lightning_bolt.png"),
    #(OrbitingShardsProjectile, "spell_projectiles/orbiting_shard.png"),
  ]
}

fn total_textures() -> Int {
  list.length(texture_paths())
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, effect.Effect(Msg)) {
  let model =
    Model(
      load_state: Loading(loaded: 0, total: total_textures()),
      textures: dict.new(),
    )

  // Load all textures
  let load_effects =
    texture_paths()
    |> list.map(fn(entry) {
      let #(id, path) = entry
      texture.load(path, TextureLoaded(id, _), TextureLoadFailed(id))
    })
    |> effect.batch

  #(model, load_effects)
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    TextureLoaded(id, tex) -> {
      let new_textures = dict.insert(model.textures, id, tex)
      let new_loaded = dict.size(new_textures)
      let new_state = case new_loaded >= total_textures() {
        True -> Loaded
        False -> Loading(loaded: new_loaded, total: total_textures())
      }
      #(Model(load_state: new_state, textures: new_textures), effect.none())
    }

    TextureLoadFailed(id) -> {
      let error_msg = "Failed to load texture: " <> texture_id_to_string(id)
      #(Model(..model, load_state: Failed(error_msg)), effect.none())
    }
  }
}

// =============================================================================
// HELPERS
// =============================================================================

/// Check if all assets are loaded
pub fn is_loaded(model: Model) -> Bool {
  model.load_state == Loaded
}

/// Get loading progress as (loaded, total)
pub fn get_progress(model: Model) -> #(Int, Int) {
  case model.load_state {
    Loading(loaded, total) -> #(loaded, total)
    Loaded -> #(total_textures(), total_textures())
    Failed(_) -> #(0, total_textures())
  }
}

/// Get a texture by ID
pub fn get_texture(model: Model, id: TextureId) -> Option(Texture) {
  dict.get(model.textures, id)
  |> option.from_result
}

/// Map a texture path to its TextureId
pub fn texture_id_for_path(path: String) -> Option(TextureId) {
  texture_paths()
  |> list.find(fn(entry) { entry.1 == path })
  |> option.from_result
  |> option.map(fn(entry) { entry.0 })
}

fn texture_id_to_string(id: TextureId) -> String {
  case id {
    SparkProjectile -> "SparkProjectile"
    LightningProjectile -> "LightningProjectile"
    OrbitingShardsProjectile -> "OrbitingShardsProjectile"
  }
}
