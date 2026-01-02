import gleam/float
import gleam/option
import gleam/time/duration
import iv
import vec/vec2
import vec/vec3

pub type Id {
  Fireball
  LightningBolt
  Spark
  SparkWithTrigger
  Piercing
  DoubleSpell
  AddMana
  AddDamage
  OrbitingSpell
  RapidFire
  AddTrigger
}

pub type Spell {
  DamageSpell(id: Id, kind: DamageSpell)
  ModifierSpell(id: Id, kind: ModifierSpell)
  MulticastSpell(id: Id, kind: MulticastSpell)
}

pub type MulticastCount {
  Fixed(Int)
  AllRemaining
}

pub type MulticastSpell {
  Multicast(
    name: String,
    mana_cost: Float,
    spell_count: MulticastCount,
    draw_add: Int,
    ui_sprite: String,
  )
}

/// Loop mode for animated sprites
pub type SpritesheetLoop {
  LoopRepeat
  LoopOnce
  LoopPingPong
}

/// Type of hit effect to play on impact
pub type HitEffectType {
  FireExplosion
  GenericExplosion
  IceShatter
  LightBurst
  NoEffect
}

/// Visual source for a spell projectile - either static texture or animated spritesheet
pub type ProjectileVisual {
  /// Static single-frame sprite (e.g., spark.png)
  StaticSprite(texture_path: String, size: vec2.Vec2(Float))
  /// Animated spritesheet (e.g., FireBall_64x64.png)
  AnimatedSprite(
    spritesheet_path: String,
    columns: Int,
    rows: Int,
    frames: List(Int),
    frame_duration_ms: Int,
    loop_mode: SpritesheetLoop,
    size: vec2.Vec2(Float),
  )
}

/// Visual configuration for spell effects
pub type SpellVisuals {
  SpellVisuals(
    /// Projectile visual (static or animated)
    projectile: ProjectileVisual,
    /// Hit effect to play on impact
    hit_effect: HitEffectType,
    /// Base tint color (0xFFFFFF = no tint, multiplied with texture)
    base_tint: Int,
    /// Emissive intensity for glow effects (0.0 - 2.0)
    emissive_intensity: Float,
  )
}

pub type DamageSpell {
  Damage(
    name: String,
    mana_cost: Float,
    damage: Float,
    projectile_speed: Float,
    projectile_lifetime: duration.Duration,
    projectile_size: Float,
    cast_delay_addition: duration.Duration,
    critical_chance: Float,
    spread: Float,
    visuals: SpellVisuals,
    ui_sprite: String,
    is_beam: Bool,
    has_trigger: Bool,
  )
}

pub type ModifierSpell {
  Modifier(
    name: String,
    mana_cost: Float,
    damage_multiplier: Float,
    damage_addition: Float,
    projectile_speed_multiplier: Float,
    projectile_speed_addition: Float,
    projectile_size_multiplier: Float,
    projectile_size_addition: Float,
    projectile_lifetime_multiplier: Float,
    projectile_lifetime_addition: duration.Duration,
    cast_delay_multiplier: Float,
    cast_delay_addition: duration.Duration,
    recharge_multiplier: Float,
    recharge_addition: duration.Duration,
    critical_chance_multiplier: Float,
    critical_chance_addition: Float,
    spread_multiplier: Float,
    spread_addition: Float,
    ui_sprite: String,
    adds_trigger: Bool,
    /// Tint color to apply to projectile visuals (0xFFFFFF = no tint)
    visual_tint: Int,
  )
}

pub fn default_modifier(name: String, ui_sprite: String) {
  Modifier(
    name:,
    mana_cost: 0.0,
    damage_multiplier: 1.0,
    damage_addition: 0.0,
    projectile_speed_multiplier: 1.0,
    projectile_speed_addition: 0.0,
    projectile_size_multiplier: 1.0,
    projectile_size_addition: 0.0,
    projectile_lifetime_multiplier: 1.0,
    projectile_lifetime_addition: duration.milliseconds(0),
    cast_delay_multiplier: 1.0,
    cast_delay_addition: duration.nanoseconds(0),
    recharge_multiplier: 1.0,
    recharge_addition: duration.nanoseconds(0),
    critical_chance_multiplier: 1.0,
    critical_chance_addition: 0.0,
    spread_multiplier: 1.0,
    spread_addition: 0.0,
    ui_sprite:,
    adds_trigger: False,
    visual_tint: 0xFFFFFF,
  )
}

/// Type of projectile behavior
pub type ProjectileType {
  /// Standard projectile that moves through space
  Standard
  /// Beam that connects two points (like lightning)
  Beam(target_position: vec3.Vec3(Float))
  /// Orbits around a center point (typically the player)
  Orbiting(
    center_position: vec3.Vec3(Float),
    orbit_angle: Float,
    orbit_radius: Float,
    orbit_speed: Float,
  )
}

/// Represents a projectile created by casting a spell
pub type Projectile {
  Projectile(
    id: Int,
    spell: ModifiedSpell,
    position: vec3.Vec3(Float),
    direction: vec3.Vec3(Float),
    time_alive: duration.Duration,
    visuals: SpellVisuals,
    projectile_type: ProjectileType,
    trigger_payload: option.Option(ModifiedSpell),
  )
}

/// Result of applying modifiers to a damaging spell
pub type ModifiedSpell {
  ModifiedSpell(
    base: Spell,
    final_damage: Float,
    final_speed: Float,
    final_size: Float,
    final_lifetime: duration.Duration,
    final_cast_delay: duration.Duration,
    final_recharge_time: duration.Duration,
    final_critical_chance: Float,
    final_spread: Float,
    total_mana_cost: Float,
  )
}

/// Apply additive modifiers to base spell stats
fn apply_additive_modifiers(
  base_spell: DamageSpell,
  modifiers: iv.Array(ModifierSpell),
) -> #(
  Float,
  Float,
  Float,
  duration.Duration,
  duration.Duration,
  duration.Duration,
  Float,
  Float,
) {
  iv.fold(
    modifiers,
    #(
      base_spell.damage,
      base_spell.projectile_speed,
      base_spell.projectile_size,
      base_spell.projectile_lifetime,
      base_spell.cast_delay_addition,
      duration.milliseconds(0),
      base_spell.critical_chance,
      base_spell.spread,
    ),
    fn(acc, mod) {
      let #(
        damage,
        speed,
        size,
        lifetime,
        cast_delay,
        recharge_time,
        crit_chance,
        spread,
      ) = acc
      #(
        damage +. mod.damage_addition,
        speed +. mod.projectile_speed_addition,
        size +. mod.projectile_size_addition,
        duration.add(lifetime, mod.projectile_lifetime_addition),
        duration.add(cast_delay, mod.cast_delay_addition),
        duration.add(recharge_time, mod.recharge_addition),
        crit_chance +. mod.critical_chance_addition,
        spread +. mod.spread_addition,
      )
    },
  )
}

/// Apply multiplicative modifiers to stats
fn apply_multiplicative_modifiers(
  stats: #(
    Float,
    Float,
    Float,
    duration.Duration,
    duration.Duration,
    duration.Duration,
    Float,
    Float,
  ),
  base_mana_cost: Float,
  modifiers: iv.Array(ModifierSpell),
) -> #(
  Float,
  Float,
  Float,
  duration.Duration,
  duration.Duration,
  duration.Duration,
  Float,
  Float,
  Float,
) {
  let #(
    damage,
    speed,
    size,
    lifetime,
    cast_delay,
    recharge_time,
    crit_chance,
    spread,
  ) = stats
  iv.fold(
    modifiers,
    #(
      damage,
      speed,
      size,
      lifetime,
      cast_delay,
      recharge_time,
      crit_chance,
      spread,
      base_mana_cost,
    ),
    fn(acc, mod) {
      let #(
        damage,
        speed,
        size,
        lifetime,
        cast_delay,
        recharge_time,
        crit_chance,
        spread,
        mana_cost,
      ) = acc
      #(
        damage *. mod.damage_multiplier,
        speed *. mod.projectile_speed_multiplier,
        size *. mod.projectile_size_multiplier,
        lifetime
          |> duration.to_seconds
          |> float.multiply(mod.projectile_lifetime_multiplier)
          |> float.multiply(1000.0)
          |> float.round
          |> duration.milliseconds,
        cast_delay
          |> duration.to_seconds
          |> float.multiply(mod.cast_delay_multiplier)
          |> float.multiply(1000.0)
          |> float.round
          |> duration.milliseconds,
        recharge_time
          |> duration.to_seconds
          |> float.multiply(mod.recharge_multiplier)
          |> float.multiply(1000.0)
          |> float.round
          |> duration.milliseconds,
        crit_chance *. mod.critical_chance_multiplier,
        spread *. mod.spread_multiplier,
        mana_cost +. mod.mana_cost,
      )
    },
  )
}

/// Apply a list of modifiers to a damaging spell
pub fn apply_modifiers(
  id: Id,
  base_spell: DamageSpell,
  modifiers: iv.Array(ModifierSpell),
) -> ModifiedSpell {
  let after_additions = apply_additive_modifiers(base_spell, modifiers)
  let #(
    final_damage,
    final_speed,
    final_size,
    final_lifetime,
    final_cast_delay,
    final_recharge_time,
    final_critical_chance,
    final_spread,
    total_mana_cost,
  ) =
    apply_multiplicative_modifiers(
      after_additions,
      base_spell.mana_cost,
      modifiers,
    )

  ModifiedSpell(
    base: DamageSpell(id:, kind: base_spell),
    final_damage:,
    final_speed:,
    final_size:,
    final_lifetime:,
    final_cast_delay:,
    final_recharge_time:,
    final_critical_chance:,
    final_spread:,
    total_mana_cost:,
  )
}

// Pre-defined spells for convenience

/// Basic projectile spell
pub fn spark(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: Spark,
    kind: Damage(
      name: "Spark",
      damage: 3.0,
      projectile_speed: 50.0,
      projectile_lifetime: duration.seconds(2),
      mana_cost: 5.0,
      projectile_size: 1.0,
      cast_delay_addition: duration.milliseconds(50),
      critical_chance: 0.05,
      spread: 5.0,
      visuals:,
      ui_sprite: "spell_icons/spark.png",
      is_beam: False,
      has_trigger: False,
    ),
  )
}

/// Heavy damage spell - Beam type that connects player to enemy
pub fn lightning(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: LightningBolt,
    kind: Damage(
      name: "Lightning Bolt",
      damage: 100.0,
      projectile_speed: 0.0,
      projectile_lifetime: duration.milliseconds(300),
      mana_cost: 100.0,
      projectile_size: 1.0,
      cast_delay_addition: duration.milliseconds(0),
      critical_chance: 0.15,
      spread: 0.0,
      visuals:,
      ui_sprite: "spell_icons/lightning_bolt.png",
      is_beam: True,
      has_trigger: False,
    ),
  )
}

/// Firebolt - Explodes on impact, damaging enemies in an area and setting them on fire
pub fn fireball(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: Fireball,
    kind: Damage(
      name: "Firebolt",
      damage: 5.0,
      projectile_speed: 10.0,
      projectile_lifetime: duration.milliseconds(2500),
      mana_cost: 15.0,
      projectile_size: 2.0,
      cast_delay_addition: duration.milliseconds(0),
      critical_chance: 0.1,
      spread: 10.0,
      visuals:,
      ui_sprite: "spell_icons/fireball.png",
      is_beam: False,
      has_trigger: False,
    ),
  )
}

/// Orbiting Spell - Creates a projectile that orbits around the player and damages enemies on contact
pub fn orbiting_spell(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: OrbitingSpell,
    kind: Damage(
      name: "Orbiting Spell",
      damage: 4.0,
      projectile_speed: 2.0,
      projectile_lifetime: duration.seconds(30),
      mana_cost: 20.0,
      projectile_size: 1.5,
      cast_delay_addition: duration.milliseconds(0),
      critical_chance: 0.05,
      spread: 0.0,
      visuals:,
      ui_sprite: "spell_icons/orbiting_shards.png",
      is_beam: False,
      has_trigger: False,
    ),
  )
}

pub fn rapid_fire() -> Spell {
  ModifierSpell(
    id: RapidFire,
    kind: Modifier(
      ..default_modifier("Rapid Fire", "spell_icons/rapid_fire.png"),
      cast_delay_addition: duration.milliseconds(-170),
      recharge_addition: duration.milliseconds(-330),
    ),
  )
}

/// Double Spell - casts 2 spells at once (no mana cost)
pub fn double_spell() -> Spell {
  MulticastSpell(
    id: DoubleSpell,
    kind: Multicast(
      name: "Double Spell",
      mana_cost: 0.0,
      spell_count: Fixed(2),
      draw_add: 2,
      ui_sprite: "spell_icons/double_spell.png",
    ),
  )
}

pub fn add_mana() -> Spell {
  ModifierSpell(
    id: AddMana,
    kind: Modifier(
      ..default_modifier("Add Mana", "spell_icons/mana.png"),
      mana_cost: -30.0,
      cast_delay_addition: duration.milliseconds(17),
    ),
  )
}

pub fn add_damage() -> Spell {
  ModifierSpell(
    id: AddDamage,
    kind: Modifier(
      ..default_modifier("Add Damage", "spell_icons/add_damage.png"),
      damage_addition: 10.0,
    ),
  )
}

pub fn piercing() -> Spell {
  ModifierSpell(
    id: Piercing,
    kind: Modifier(
      ..default_modifier("Piercing", "spell_icons/piercing.png"),
      mana_cost: 130.0,
    ),
  )
}

/// Spark with Trigger - fires a projectile that casts another spell upon collision
pub fn spark_with_trigger(visuals: SpellVisuals) -> Spell {
  DamageSpell(
    id: SparkWithTrigger,
    kind: Damage(
      name: "Spark with Trigger",
      damage: 3.0,
      projectile_speed: 50.0,
      projectile_lifetime: duration.seconds(2),
      mana_cost: 10.0,
      projectile_size: 1.0,
      cast_delay_addition: duration.milliseconds(50),
      critical_chance: 0.05,
      spread: -1.0,
      visuals:,
      ui_sprite: "spell_icons/spark_trigger.png",
      is_beam: False,
      has_trigger: True,
    ),
  )
}

/// Add Trigger - makes the next projectile cast another spell upon collision
pub fn add_trigger() -> Spell {
  ModifierSpell(
    id: AddTrigger,
    kind: Modifier(
      ..default_modifier("Add Trigger", "spell_icons/add_trigger.png"),
      mana_cost: 10.0,
      adds_trigger: True,
    ),
  )
}

pub fn name(spell: Spell) -> String {
  case spell {
    DamageSpell(_, kind) -> kind.name
    ModifierSpell(_, kind) -> kind.name
    MulticastSpell(_, kind) -> kind.name
  }
}
