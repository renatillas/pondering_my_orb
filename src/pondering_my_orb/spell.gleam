/// Spell System - Inspired by Noita
/// Defines spell types, properties, and how modifiers affect damaging spells
import gleam/list

/// Represents the different types of spells
pub type Spell {
  /// Damaging spells that create projectiles and deal damage
  DamageSpell(DamageSpell)
  /// Modifier spells that enhance the next damaging spell
  ModifierSpell(ModifierSpell)
}

pub type DamageSpell {
  Damage(
    name: String,
    mana_cost: Float,
    damage: Float,
    projectile_speed: Float,
    projectile_lifetime: Float,
    projectile_size: Float,
    color: Int,
  )
}

pub type ModifierSpell {
  Modifier(
    name: String,
    mana_cost: Float,
    damage_multiplier: Float,
    speed_multiplier: Float,
    size_multiplier: Float,
    lifetime_multiplier: Float,
  )
}

/// Represents a projectile created by casting a spell
pub type Projectile {
  Projectile(
    id: Int,
    spell: ModifiedSpell,
    position: #(Float, Float, Float),
    direction: #(Float, Float, Float),
    time_alive: Float,
  )
}

/// Result of applying modifiers to a damaging spell
pub type ModifiedSpell {
  ModifiedSpell(
    base: Spell,
    final_damage: Float,
    final_speed: Float,
    final_size: Float,
    final_lifetime: Float,
    total_mana_cost: Float,
  )
}

/// Create a new damaging spell
pub fn damaging_spell(
  name name: String,
  damage damage: Float,
  projectile_speed projectile_speed: Float,
  projectile_lifetime projectile_lifetime: Float,
  mana_cost mana_cost: Float,
  projectile_size projectile_size: Float,
  color color: Int,
) -> Spell {
  DamageSpell(Damage(
    name: name,
    damage: damage,
    projectile_speed: projectile_speed,
    projectile_lifetime: projectile_lifetime,
    mana_cost: mana_cost,
    projectile_size: projectile_size,
    color: color,
  ))
}

/// Create a new modifier spell
pub fn modifier_spell(
  name name: String,
  damage_multiplier damage_multiplier: Float,
  speed_multiplier speed_multiplier: Float,
  size_multiplier size_multiplier: Float,
  lifetime_multiplier lifetime_multiplier: Float,
  mana_cost mana_cost: Float,
) -> Spell {
  ModifierSpell(Modifier(
    name: name,
    damage_multiplier: damage_multiplier,
    speed_multiplier: speed_multiplier,
    size_multiplier: size_multiplier,
    lifetime_multiplier: lifetime_multiplier,
    mana_cost: mana_cost,
  ))
}

/// Apply a list of modifiers to a damaging spell
pub fn apply_modifiers(
  base_spell: DamageSpell,
  modifiers: List(ModifierSpell),
) -> ModifiedSpell {
  // Fold over all modifiers to calculate final values
  let #(damage_mult, speed_mult, size_mult, lifetime_mult, total_mana) =
    list.fold(
      modifiers,
      #(1.0, 1.0, 1.0, 1.0, base_spell.mana_cost),
      fn(acc, mod) {
        let #(d, s, sz, l, m) = acc
        #(
          d *. mod.damage_multiplier,
          s *. mod.speed_multiplier,
          sz *. mod.size_multiplier,
          l *. mod.lifetime_multiplier,
          m +. mod.mana_cost,
        )
      },
    )

  ModifiedSpell(
    base: DamageSpell(base_spell),
    final_damage: base_spell.damage *. damage_mult,
    final_speed: base_spell.projectile_speed *. speed_mult,
    final_size: base_spell.projectile_size *. size_mult,
    final_lifetime: base_spell.projectile_lifetime *. lifetime_mult,
    total_mana_cost: total_mana,
  )
}

// Pre-defined spells for convenience

/// Basic projectile spell
pub fn spark() -> Spell {
  damaging_spell(
    name: "Spark",
    damage: 10.0,
    projectile_speed: 15.0,
    projectile_lifetime: 2.0,
    mana_cost: 5.0,
    projectile_size: 0.3,
    color: 0xffff44,
  )
}

/// Powerful projectile spell
pub fn fireball() -> Spell {
  damaging_spell(
    name: "Fireball",
    damage: 50.0,
    projectile_speed: 10.0,
    projectile_lifetime: 3.0,
    mana_cost: 20.0,
    projectile_size: 0.8,
    color: 0xff4400,
  )
}

/// Heavy damage spell
pub fn lightning() -> Spell {
  damaging_spell(
    name: "Lightning Bolt",
    damage: 100.0,
    projectile_speed: 30.0,
    projectile_lifetime: 1.0,
    mana_cost: 35.0,
    projectile_size: 0.2,
    color: 0x00ffff,
  )
}

/// Damage boost modifier
pub fn heavy_shot() -> Spell {
  modifier_spell(
    name: "Heavy Shot",
    damage_multiplier: 2.0,
    speed_multiplier: 0.01,
    size_multiplier: 1.5,
    lifetime_multiplier: 1.0,
    mana_cost: 10.0,
  )
}

/// Speed boost modifier
pub fn homing() -> Spell {
  modifier_spell(
    name: "Homing",
    damage_multiplier: 1.0,
    speed_multiplier: 1.3,
    size_multiplier: 1.0,
    lifetime_multiplier: 1.5,
    mana_cost: 15.0,
  )
}

/// Triple damage modifier
pub fn triple_spell() -> Spell {
  modifier_spell(
    name: "Triple Spell",
    damage_multiplier: 0.7,
    speed_multiplier: 1.0,
    size_multiplier: 0.8,
    lifetime_multiplier: 1.0,
    mana_cost: 20.0,
  )
}
