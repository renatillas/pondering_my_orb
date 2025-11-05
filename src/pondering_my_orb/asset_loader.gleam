import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import pondering_my_orb/spell
import tiramisu/asset
import tiramisu/spritesheet

/// Bundle of all loaded game assets
pub type AssetBundle {
  AssetBundle(
    // Map assets
    floor_tile: asset.Object3D,
    tower_base: asset.Object3D,
    tower_middle: asset.Object3D,
    tower_edge: asset.Object3D,
    tower_top: asset.Object3D,
    crate: asset.Object3D,
    crate_small: asset.Object3D,
    barrel: asset.Object3D,
    stairs_stone: asset.Object3D,
    stairs_wood: asset.Object3D,
    bricks: asset.Object3D,
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
  // Load floor tile
  let assert Ok(floor_fbx) = asset.get_fbx(cache, "medieval/Models/floor.fbx")

  // Load tower parts
  let assert Ok(tower_base_fbx) =
    asset.get_fbx(cache, "medieval/Models/tower-base.fbx")
  let assert Ok(tower_middle_fbx) =
    asset.get_fbx(cache, "medieval/Models/tower.fbx")
  let assert Ok(tower_top_fbx) =
    asset.get_fbx(cache, "medieval/Models/tower-top.fbx")
  let assert Ok(tower_edge_fbx) =
    asset.get_fbx(cache, "medieval/Models/tower-edge.fbx")

  // Load props and decoration
  let assert Ok(crate_fbx) =
    asset.get_fbx(cache, "medieval/Models/detail-crate.fbx")
  let assert Ok(crate_small_fbx) =
    asset.get_fbx(cache, "medieval/Models/detail-crate-small.fbx")
  let assert Ok(barrel_fbx) =
    asset.get_fbx(cache, "medieval/Models/detail-barrel.fbx")
  let assert Ok(stairs_stone_fbx) =
    asset.get_fbx(cache, "medieval/Models/stairs-stone.fbx")
  let assert Ok(stairs_wood_fbx) =
    asset.get_fbx(cache, "medieval/Models/stairs-wood.fbx")
  let assert Ok(bricks_fbx) = asset.get_fbx(cache, "medieval/Models/bricks.fbx")

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

  // Load spark texture and create spritesheet
  let assert Ok(orbiting_shard_texture) =
    asset.get_texture(cache, "spell_projectiles/orbiting_shard.png")
  let assert Ok(orbiting_shard_spritesheet) =
    spritesheet.from_grid(orbiting_shard_texture, columns: 1, rows: 1)
  let orbiting_shard_animation =
    spritesheet.animation(
      name: "shard",
      frames: list.range(1, 45),
      frame_duration: 50.0,
      loop: spritesheet.Repeat,
    )

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

  let orbiting_shard_visuals =
    spell.SpellVisuals(
      projectile_spritesheet: orbiting_shard_spritesheet,
      projectile_animation: orbiting_shard_animation,
      hit_spritesheet: spark_explosion_spritesheet,
      hit_animation: spark_explosion_animation,
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
  let assert Ok(player_idle_spritesheet) =
    spritesheet.from_grid(mago_idle_texture, columns: 1, rows: 1)
  let player_idle_animation =
    spritesheet.animation(
      name: "idle",
      frames: [0],
      frame_duration: 150.0,
      loop: spritesheet.Repeat,
    )

  let assert Ok(mago_attacking_texture) =
    asset.get_texture(cache, "player/mago_attacking.png")
  let assert Ok(player_attacking_spritesheet) =
    spritesheet.from_grid(mago_attacking_texture, columns: 1, rows: 1)
  let player_attacking_animation =
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

  let spell_visuals =
    dict.new()
    |> dict.insert(spell.Fireball, fireball_visuals)
    |> dict.insert(spell.Spark, spark_visuals)
    |> dict.insert(spell.LightningBolt, lightning_bolt_visuals)
    |> dict.insert(spell.OrbitingSpell, orbiting_shard_visuals)
    |> dict.insert(spell.SparkWithTrigger, spark_visuals)

  AssetBundle(
    floor_tile: floor_fbx.scene,
    tower_base: tower_base_fbx.scene,
    tower_middle: tower_middle_fbx.scene,
    tower_edge: tower_edge_fbx.scene,
    tower_top: tower_top_fbx.scene,
    crate: crate_fbx.scene,
    crate_small: crate_small_fbx.scene,
    barrel: barrel_fbx.scene,
    stairs_stone: stairs_stone_fbx.scene,
    stairs_wood: stairs_wood_fbx.scene,
    bricks: bricks_fbx.scene,
    xp_spritesheet:,
    xp_animation:,
    enemy1_spritesheet:,
    enemy1_animation:,
    enemy2_spritesheet:,
    enemy2_animation:,
    player_idle_spritesheet:,
    player_idle_animation:,
    player_attacking_spritesheet:,
    player_attacking_animation:,
    spell_visuals:,
  )
}

/// List of all assets to load
pub fn get_asset_list() -> List(asset.AssetType) {
  [
    // Medieval assets
    asset.FBXAsset(
      "medieval/Models/floor.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/tower-base.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/tower.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/tower-edge.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/tower-top.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/detail-crate.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/detail-crate-small.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/detail-barrel.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/stairs-stone.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/stairs-wood.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.FBXAsset(
      "medieval/Models/bricks.fbx",
      option.Some("medieval/Models/Textures/"),
    ),
    asset.TextureAsset("spr_coin_azu.png"),
    asset.TextureAsset("SPRITESHEET_Files/FireBall_2_64x64.png"),
    asset.TextureAsset("SPRITESHEET_Files/Explosion_2_64x64.png"),
    asset.TextureAsset("spell_projectiles/spark.png"),
    asset.TextureAsset("SPRITESHEET_Files/IceShatter_2_96x96.png"),
    asset.TextureAsset("player/mago_idle.png"),
    asset.TextureAsset("player/mago_attacking.png"),
    asset.TextureAsset("spell_projectiles/lightning_bolt.png"),
    asset.TextureAsset("spell_projectiles/orbiting_shard.png"),
    // Enemy sprites
    asset.TextureAsset("enemy_1.png"),
    asset.TextureAsset("enemy_2.png"),
  ]
}
