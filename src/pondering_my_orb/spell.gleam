import iv

pub type Spell {
  DamageSpell(DamageSpell)
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
    projectile_lifetime_addition: Float,
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
) -> Spell {
  DamageSpell(Damage(
    name: name,
    damage: damage,
    projectile_speed: projectile_speed,
    projectile_lifetime: projectile_lifetime,
    mana_cost: mana_cost,
    projectile_size: projectile_size,
  ))
}

/// Create a new modifier spell
pub fn modifier_spell(
  name name: String,
  damage_multiplier damage_multiplier: Float,
  damage_addition damage_addition: Float,
  projectile_speed_multiplier projectile_speed_multiplier: Float,
  projectile_speed_addition projectile_speed_addition: Float,
  projectile_size_multiplier projectile_size_multiplier: Float,
  projectile_size_addition projectile_size_addition: Float,
  projectile_lifetime_multiplier projectile_lifetime_multiplier: Float,
  projectile_lifetime_addition projectile_lifetime_addition: Float,
  mana_cost mana_cost: Float,
) -> Spell {
  ModifierSpell(Modifier(
    name:,
    mana_cost:,
    damage_multiplier:,
    damage_addition:,
    projectile_speed_multiplier:,
    projectile_speed_addition:,
    projectile_size_multiplier:,
    projectile_size_addition:,
    projectile_lifetime_multiplier:,
    projectile_lifetime_addition:,
  ))
}

/// Apply a list of modifiers to a damaging spell
pub fn apply_modifiers(
  base_spell: DamageSpell,
  modifiers: iv.Array(ModifierSpell),
) -> ModifiedSpell {
  // Fold over all modifiers to calculate final values
  let #(damage, speed, size, lifetime) =
    iv.fold(
      modifiers,
      #(
        base_spell.damage,
        base_spell.projectile_speed,
        base_spell.projectile_size,
        base_spell.projectile_lifetime,
      ),
      fn(acc, mod) {
        let #(damage, speed, size, lifetime) = acc
        #(
          damage +. mod.damage_addition,
          speed +. mod.projectile_speed_addition,
          size +. mod.projectile_size_addition,
          lifetime +. mod.projectile_lifetime_addition,
        )
      },
    )
  let #(final_damage, final_speed, final_size, final_lifetime, total_mana_cost) =
    iv.fold(
      modifiers,
      #(damage, speed, size, lifetime, base_spell.mana_cost),
      fn(acc, mod) {
        let #(damage, speed, size, lifetime, mana_cost) = acc
        #(
          damage *. mod.damage_multiplier,
          speed *. mod.projectile_speed_multiplier,
          size *. mod.projectile_size_multiplier,
          lifetime *. mod.projectile_lifetime_multiplier,
          mana_cost *. mod.projectile_lifetime_multiplier,
        )
      },
    )

  ModifiedSpell(
    base: DamageSpell(base_spell),
    final_damage:,
    final_speed:,
    final_size:,
    final_lifetime:,
    total_mana_cost:,
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
  )
}
