import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None}
import pondering_my_orb/map
import pondering_my_orb/spell
import tiramisu/asset
import tiramisu/spritesheet
import tiramisu/transform
import vec/vec3.{Vec3}

/// Bundle of all loaded game assets
pub type AssetBundle {
  AssetBundle(
    // Map assets
    ground: map.Obstacle(map.Ground),
    foliage: map.Obstacle(map.Box),
    // XP system
    xp_spritesheet: spritesheet.Spritesheet,
    xp_animation: spritesheet.Animation,
    // Enemy sprites
    enemy1_spritesheet: spritesheet.Spritesheet,
    enemy1_animation: spritesheet.Animation,
    enemy2_spritesheet: spritesheet.Spritesheet,
    enemy2_animation: spritesheet.Animation,
    // Player sprites
    player_idle_spritesheet: spritesheet.Spritesheet,
    player_idle_animation: spritesheet.Animation,
    player_attacking_spritesheet: spritesheet.Spritesheet,
    player_attacking_animation: spritesheet.Animation,
    // Spell visuals
    spell_visuals: Dict(spell.Id, spell.SpellVisuals),
  )
}

/// Load all game assets and return a bundle
pub fn load_assets(cache: asset.AssetCache) -> AssetBundle {
  // Load tree models
  let assert Ok(tree01_fbx) =
    asset.get_fbx(cache, "tree_pack_1.1/models/tree01.fbx")
  let assert Ok(tree01_texture) =
    asset.get_texture(cache, "tree_pack_1.1/textures/tree01.png")
  let assert Ok(tree05_fbx) =
    asset.get_fbx(cache, "tree_pack_1.1/models/tree05.fbx")
  let assert Ok(tree05_texture) =
    asset.get_texture(cache, "tree_pack_1.1/textures/tree05.png")
  let assert Ok(tree10_fbx) =
    asset.get_fbx(cache, "tree_pack_1.1/models/tree10.fbx")
  let assert Ok(tree10_texture) =
    asset.get_texture(cache, "tree_pack_1.1/textures/tree10.png")
  let assert Ok(tree15_fbx) =
    asset.get_fbx(cache, "tree_pack_1.1/models/tree15.fbx")
  let assert Ok(tree15_texture) =
    asset.get_texture(cache, "tree_pack_1.1/textures/tree15.png")

  let foliage_models = [
    tree01_fbx.scene,
    tree05_fbx.scene,
    tree10_fbx.scene,
    tree15_fbx.scene,
  ]

  let foliage_textures = [
    tree01_texture,
    tree05_texture,
    tree10_texture,
    tree15_texture,
  ]

  // Load XP coin texture and create spritesheet
  let assert Ok(xp_texture) = asset.get_texture(cache, "spr_coin_azu.png")
  let assert Ok(xp_spritesheet) =
    spritesheet.from_grid(xp_texture, columns: 4, rows: 1)

  let xp_animation =
    spritesheet.animation(
      name: "idle",
      frames: [0, 1, 2, 3],
      frame_duration: 500.0,
      loop: spritesheet.Repeat,
    )

  // Load fireball texture and create spritesheet
  let assert Ok(fireball_texture) =
    asset.get_texture(cache, "SPRITESHEET_Files/FireBall_2_64x64.png")
  let assert Ok(fireball_spritesheet) =
    spritesheet.from_grid(fireball_texture, columns: 45, rows: 1)

  let fireball_animation =
    spritesheet.animation(
      name: "fireball",
      frames: list.range(1, 45),
      frame_duration: 50.0,
      loop: spritesheet.Repeat,
    )

  // Load explosion texture and create spritesheet
  let assert Ok(explosion_texture) =
    asset.get_texture(cache, "SPRITESHEET_Files/Explosion_2_64x64.png")
  let assert Ok(explosion_spritesheet) =
    spritesheet.from_grid(explosion_texture, columns: 44, rows: 1)

  let explosion_animation =
    spritesheet.animation(
      name: "explosion",
      frames: list.range(1, 44),
      frame_duration: 40.0,
      loop: spritesheet.Once,
    )

  // Load spark texture and create spritesheet
  let assert Ok(spark_texture) =
    asset.get_texture(cache, "spell_projectiles/spark.png")
  let assert Ok(spark_spritesheet) =
    spritesheet.from_grid(spark_texture, columns: 1, rows: 1)
  let spark_animation =
    spritesheet.animation(
      name: "spark",
      frames: list.range(1, 45),
      frame_duration: 50.0,
      loop: spritesheet.Repeat,
    )

  // Load spark explosion texture and create spritesheet
  let assert Ok(spark_explosion_texture) =
    asset.get_texture(cache, "SPRITESHEET_Files/IceShatter_2_96x96.png")
  let assert Ok(spark_explosion_spritesheet) =
    spritesheet.from_grid(spark_explosion_texture, columns: 49, rows: 1)

  let spark_explosion_animation =
    spritesheet.animation(
      name: "explosion",
      frames: list.range(1, 44),
      frame_duration: 40.0,
      loop: spritesheet.Once,
    )

  // Create spell visuals for fireball
  let fireball_visuals =
    spell.SpellVisuals(
      projectile_spritesheet: fireball_spritesheet,
      projectile_animation: fireball_animation,
      hit_spritesheet: explosion_spritesheet,
      hit_animation: explosion_animation,
    )

  let spark_visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spark_spritesheet,
      projectile_animation: spark_animation,
      hit_spritesheet: spark_explosion_spritesheet,
      hit_animation: spark_explosion_animation,
    )

  // Load lightning bolt texture and create spritesheet
  let assert Ok(lightning_bolt_texture) =
    asset.get_texture(cache, "spell_projectiles/lightning_bolt.png")
  let assert Ok(lightning_bolt_spritesheet) =
    spritesheet.from_grid(lightning_bolt_texture, columns: 1, rows: 1)
  let lightning_bolt_animation =
    spritesheet.animation(
      name: "projectile",
      frames: [0],
      frame_duration: 50.0,
      loop: spritesheet.Repeat,
    )

  let lightning_bolt_visuals =
    spell.SpellVisuals(
      projectile_spritesheet: lightning_bolt_spritesheet,
      projectile_animation: lightning_bolt_animation,
      hit_spritesheet: explosion_spritesheet,
      hit_animation: explosion_animation,
    )

  // Load player sprite textures (single frame images)
  let assert Ok(mago_idle_texture) =
    asset.get_texture(cache, "player/mago_idle.png")
  let assert Ok(mago_idle_spritesheet) =
    spritesheet.from_grid(mago_idle_texture, columns: 1, rows: 1)
  let mago_idle_animation =
    spritesheet.animation(
      name: "idle",
      frames: [0],
      frame_duration: 150.0,
      loop: spritesheet.Repeat,
    )

  let assert Ok(mago_attacking_texture) =
    asset.get_texture(cache, "player/mago_attacking.png")
  let assert Ok(mago_attacking_spritesheet) =
    spritesheet.from_grid(mago_attacking_texture, columns: 1, rows: 1)
  let mago_attacking_animation =
    spritesheet.animation(
      name: "attacking",
      frames: [0],
      frame_duration: 80.0,
      loop: spritesheet.Repeat,
    )

  // Load enemy sprite textures
  let assert Ok(enemy1_texture) = asset.get_texture(cache, "enemy_1.png")
  let assert Ok(enemy1_spritesheet) =
    spritesheet.from_grid(enemy1_texture, columns: 1, rows: 1)
  let enemy1_animation =
    spritesheet.animation(
      name: "idle",
      frames: [0],
      frame_duration: 150.0,
      loop: spritesheet.Repeat,
    )

  let assert Ok(enemy2_texture) = asset.get_texture(cache, "enemy_2.png")
  let assert Ok(enemy2_spritesheet) =
    spritesheet.from_grid(enemy2_texture, columns: 1, rows: 1)
  let enemy2_animation =
    spritesheet.animation(
      name: "idle",
      frames: [0],
      frame_duration: 150.0,
      loop: spritesheet.Repeat,
    )

  // Create random tree and bush instances
  let foliage_instances =
    list.range(0, 39)
    |> list.map(fn(_) {
      let x = { float.random() *. 90.0 } -. 45.0
      let z = { float.random() *. 90.0 } -. 45.0

      // Random rotation around Y axis for variety
      let rotation_y = float.random() *. 6.28318

      transform.identity
      |> transform.with_position(vec3.Vec3(x, 0.0, z))
      |> transform.with_euler_rotation(vec3.Vec3(0.0, rotation_y, 0.0))
      |> transform.with_scale(vec3.Vec3(0.03, 0.03, 0.03))
    })

  // Interleave models and textures with transforms by repeating them enough times
  let repeated_models =
    list.flatten([
      foliage_models,
      foliage_models,
      foliage_models,
      foliage_models,
      foliage_models,
      foliage_models,
    ])

  let repeated_textures =
    list.flatten([
      foliage_textures,
      foliage_textures,
      foliage_textures,
      foliage_textures,
      foliage_textures,
      foliage_textures,
    ])

  // Create triplets of (model, texture, transform)
  let foliage_triplets =
    list.zip(repeated_models, repeated_textures)
    |> list.zip(foliage_instances)
    |> list.map(fn(pair) {
      let #(#(model, texture), transform) = pair
      #(model, texture, transform)
    })
    |> list.take(40)

  let foliage = map.foliage(foliage_triplets)

  let ground =
    list.flatten(
      list.map(list.range(0, 36), fn(x) {
        list.map(list.range(0, 36), fn(z) {
          transform.identity
          |> transform.with_position(Vec3(
            int.to_float(x) -. 18.0,
            0.0,
            int.to_float(z) -. 18.0,
          ))
          |> transform.with_scale(Vec3(0.05, 0.05, 0.05))
        })
      }),
    )
    |> map.ground

  let spell_visuals =
    dict.new()
    |> dict.insert(spell.Fireball, fireball_visuals)
    |> dict.insert(spell.Spark, spark_visuals)
    |> dict.insert(spell.LightningBolt, lightning_bolt_visuals)

  AssetBundle(
    ground: ground,
    foliage: foliage,
    xp_spritesheet: xp_spritesheet,
    xp_animation: xp_animation,
    enemy1_spritesheet: enemy1_spritesheet,
    enemy1_animation: enemy1_animation,
    enemy2_spritesheet: enemy2_spritesheet,
    enemy2_animation: enemy2_animation,
    player_idle_spritesheet: mago_idle_spritesheet,
    player_idle_animation: mago_idle_animation,
    player_attacking_spritesheet: mago_attacking_spritesheet,
    player_attacking_animation: mago_attacking_animation,
    spell_visuals: spell_visuals,
  )
}

/// List of all assets to load
pub fn get_asset_list() -> List(asset.AssetType) {
  [
    // Load a selection of tree models
    asset.FBXAsset("tree_pack_1.1/models/tree01.fbx", None),
    asset.FBXAsset("tree_pack_1.1/models/tree05.fbx", None),
    asset.FBXAsset("tree_pack_1.1/models/tree10.fbx", None),
    asset.FBXAsset("tree_pack_1.1/models/tree15.fbx", None),
    // Load textures for trees and bushes
    asset.TextureAsset("tree_pack_1.1/textures/tree01.png"),
    asset.TextureAsset("tree_pack_1.1/textures/tree05.png"),
    asset.TextureAsset("tree_pack_1.1/textures/tree10.png"),
    asset.TextureAsset("tree_pack_1.1/textures/tree15.png"),
    asset.TextureAsset("tree_pack_1.1/textures/bush01.png"),
    asset.TextureAsset("tree_pack_1.1/textures/bush03.png"),
    asset.TextureAsset("tree_pack_1.1/textures/bush05.png"),
    // Other assets
    asset.TextureAsset("spr_coin_azu.png"),
    asset.TextureAsset("SPRITESHEET_Files/FireBall_2_64x64.png"),
    asset.TextureAsset("SPRITESHEET_Files/Explosion_2_64x64.png"),
    asset.TextureAsset("spell_projectiles/spark.png"),
    asset.TextureAsset("SPRITESHEET_Files/IceShatter_2_96x96.png"),
    asset.TextureAsset("player/mago_idle.png"),
    asset.TextureAsset("player/mago_attacking.png"),
    asset.TextureAsset("spell_projectiles/lightning_bolt.png"),
    // Enemy sprites
    asset.TextureAsset("enemy_1.png"),
    asset.TextureAsset("enemy_2.png"),
  ]
}
