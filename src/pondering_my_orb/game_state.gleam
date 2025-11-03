import gleam/dict.{type Dict}
import gleam/option.{type Option, None}
import pondering_my_orb/camera
import pondering_my_orb/damage_number
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id.{type Id}
import pondering_my_orb/loot
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/score
import pondering_my_orb/spell
import pondering_my_orb/ui
import pondering_my_orb/xp_shard
import tiramisu/asset
import tiramisu/input
import tiramisu/spritesheet
import vec/vec3.{type Vec3}

pub type GamePhase {
  StartScreen
  LoadingScreen
  Playing
  GameOver
}

pub type Model {
  Model(
    game_phase: GamePhase,
    restarted: Bool,
    // Map
    ground: Option(map.Obstacle(map.Ground)),
    foliage: Option(map.Obstacle(map.Box)),
    // Player
    player: player.Player,
    player_bindings: input.InputBindings(player.PlayerAction),
    pending_player_knockback: Option(Vec3(Float)),
    // Camera settings
    camera: camera.Camera,
    // Projectiles
    projectiles: List(spell.Projectile),
    projectile_hits: List(spell.ProjectileHit(Id)),
    next_projectile_id: Int,
    // Enemies
    enemies: List(Enemy(Id)),
    enemy_spawner_id: Option(Int),
    next_enemy_id: Int,
    enemy_spawn_interval_ms: Int,
    game_time_elapsed_ms: Float,
    enemy1_spritesheet: Option(spritesheet.Spritesheet),
    enemy1_animation: Option(spritesheet.Animation),
    enemy2_spritesheet: Option(spritesheet.Spritesheet),
    enemy2_animation: Option(spritesheet.Animation),
    // XP System
    xp_shards: List(xp_shard.XPShard),
    next_xp_shard_id: Int,
    xp_spritesheet: Option(spritesheet.Spritesheet),
    xp_animation: Option(spritesheet.Animation),
    // Loot System
    loot_drops: List(loot.LootDrop),
    next_loot_drop_id: Int,
    // Damage Numbers
    damage_numbers: List(damage_number.DamageNumber),
    next_damage_number_id: Int,
    // Spell Effects
    visuals: Dict(spell.Id, spell.SpellVisuals),
    // Level-up rewards
    showing_spell_rewards: Bool,
    // Wand selection
    showing_wand_selection: Bool,
    // Pause state
    is_paused: Bool,
    // Debug menu
    is_debug_menu_open: Bool,
    // Score
    score: score.Score,
  )
}

pub type Msg {
  Tick
  // Game Phase
  GameStarted
  PlayerDied
  GameRestarted
  // Map
  AssetsLoaded(assets: asset.BatchLoadResult)
  // Enemies
  EnemySpawnStarted(Int)
  EnemySpawned
  EnemySpawnIntervalDecreased
  EnemyAttacksPlayer(damage: Float, enemy_position: Vec3(Float))
  // Projectiles
  ProjectileDamagedEnemy(Id, Float, Vec3(Float), List(spell.SpellEffect))
  EnemyKilled(Id)
  // XP & Leveling
  PlayerLeveledUp(new_level: Int)
  // Camera
  PointerLocked
  PointerLockFailed
  // UI
  UIMessage(ui.UiToGameMsg)
}

pub fn init_model() -> Model {
  Model(
    game_phase: StartScreen,
    restarted: False,
    ground: None,
    foliage: None,
    player: player.init(),
    player_bindings: player.default_bindings(),
    pending_player_knockback: None,
    camera: camera.init(),
    projectiles: [],
    projectile_hits: [],
    next_projectile_id: 0,
    enemies: [],
    enemy_spawner_id: None,
    next_enemy_id: 0,
    enemy_spawn_interval_ms: 2000,
    game_time_elapsed_ms: 0.0,
    enemy1_spritesheet: None,
    enemy1_animation: None,
    enemy2_spritesheet: None,
    enemy2_animation: None,
    xp_shards: [],
    next_xp_shard_id: 0,
    xp_spritesheet: None,
    xp_animation: None,
    loot_drops: [],
    next_loot_drop_id: 0,
    damage_numbers: [],
    next_damage_number_id: 0,
    showing_spell_rewards: False,
    showing_wand_selection: False,
    is_paused: False,
    is_debug_menu_open: False,
    score: score.init(),
    visuals: dict.new(),
  )
}
