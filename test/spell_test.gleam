import gleam/option.{None}
import gleeunit/should
import iv
import pondering_my_orb/spell
import tiramisu/spritesheet

pub fn apply_modifiers_damage_test() {
  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let base_spell =
    spell.Damage(
      name: "Test Spell",
      mana_cost: 10.0,
      damage: 5.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      projectile_size: 1.0,
      cast_delay_addition: 0.1,
      critical_chance: 0.05,
      spread: 5.0,
      visuals: visuals,
      ui_sprite: "test.png",
      on_hit_effects: [],
      is_beam: False,
    )

  let modifier =
    spell.Modifier(
      name: "Damage Boost",
      mana_cost: 5.0,
      damage_multiplier: 2.0,
      damage_addition: 3.0,
      projectile_speed_multiplier: 1.0,
      projectile_speed_addition: 0.0,
      projectile_size_multiplier: 1.0,
      projectile_size_addition: 0.0,
      projectile_lifetime_multiplier: 1.0,
      projectile_lifetime_addition: 0.0,
      cast_delay_multiplier: 1.0,
      cast_delay_addition: 0.0,
      critical_chance_multiplier: 1.0,
      critical_chance_addition: 0.0,
      spread_multiplier: 1.0,
      spread_addition: 0.0,
      ui_sprite: "modifier.png",
    )

  let modifiers = iv.from_list([modifier])
  let modified = spell.apply_modifiers(spell.Spark, base_spell, modifiers)

  // Check that additions are applied first, then multipliers
  // damage: (5.0 + 3.0) * 2.0 = 16.0
  modified.final_damage |> should.equal(16.0)

  // Mana cost should be base + modifier cost
  modified.total_mana_cost |> should.equal(15.0)
}

pub fn apply_modifiers_mana_cost_accumulation_test() {
  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let base_spell =
    spell.Damage(
      name: "Test Spell",
      mana_cost: 10.0,
      damage: 5.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      projectile_size: 1.0,
      cast_delay_addition: 0.1,
      critical_chance: 0.05,
      spread: 5.0,
      visuals: visuals,
      ui_sprite: "test.png",
      on_hit_effects: [],
      is_beam: False,
    )

  let modifier1 =
    spell.Modifier(
      name: "Modifier 1",
      mana_cost: 5.0,
      damage_multiplier: 1.0,
      damage_addition: 0.0,
      projectile_speed_multiplier: 1.0,
      projectile_speed_addition: 0.0,
      projectile_size_multiplier: 1.0,
      projectile_size_addition: 0.0,
      projectile_lifetime_multiplier: 1.0,
      projectile_lifetime_addition: 0.0,
      cast_delay_multiplier: 1.0,
      cast_delay_addition: 0.0,
      critical_chance_multiplier: 1.0,
      critical_chance_addition: 0.0,
      spread_multiplier: 1.0,
      spread_addition: 0.0,
      ui_sprite: "modifier1.png",
    )

  let modifier2 =
    spell.Modifier(
      name: "Modifier 2",
      mana_cost: 7.0,
      damage_multiplier: 1.0,
      damage_addition: 0.0,
      projectile_speed_multiplier: 1.0,
      projectile_speed_addition: 0.0,
      projectile_size_multiplier: 1.0,
      projectile_size_addition: 0.0,
      projectile_lifetime_multiplier: 1.0,
      projectile_lifetime_addition: 0.0,
      cast_delay_multiplier: 1.0,
      cast_delay_addition: 0.0,
      critical_chance_multiplier: 1.0,
      critical_chance_addition: 0.0,
      spread_multiplier: 1.0,
      spread_addition: 0.0,
      ui_sprite: "modifier2.png",
    )

  let modifiers = iv.from_list([modifier1, modifier2])
  let modified = spell.apply_modifiers(spell.Spark, base_spell, modifiers)

  // Total mana should be base (10.0) + modifier1 (5.0) + modifier2 (7.0) = 22.0
  modified.total_mana_cost |> should.equal(22.0)
}

pub fn apply_modifiers_multipliers_test() {
  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let base_spell =
    spell.Damage(
      name: "Test Spell",
      mana_cost: 10.0,
      damage: 10.0,
      projectile_speed: 20.0,
      projectile_lifetime: 2.0,
      projectile_size: 1.0,
      cast_delay_addition: 0.1,
      critical_chance: 0.1,
      spread: 5.0,
      visuals: visuals,
      ui_sprite: "test.png",
      on_hit_effects: [],
      is_beam: False,
    )

  let modifier =
    spell.Modifier(
      name: "Multiplier",
      mana_cost: 5.0,
      damage_multiplier: 3.0,
      damage_addition: 0.0,
      projectile_speed_multiplier: 2.0,
      projectile_speed_addition: 0.0,
      projectile_size_multiplier: 1.5,
      projectile_size_addition: 0.0,
      projectile_lifetime_multiplier: 2.0,
      projectile_lifetime_addition: 0.0,
      cast_delay_multiplier: 1.0,
      cast_delay_addition: 0.0,
      critical_chance_multiplier: 2.0,
      critical_chance_addition: 0.0,
      spread_multiplier: 0.5,
      spread_addition: 0.0,
      ui_sprite: "modifier.png",
    )

  let modifiers = iv.from_list([modifier])
  let modified = spell.apply_modifiers(spell.Spark, base_spell, modifiers)

  modified.final_damage |> should.equal(30.0)
  modified.final_speed |> should.equal(40.0)
  modified.final_size |> should.equal(1.5)
  modified.final_lifetime |> should.equal(4.0)
  modified.final_critical_chance |> should.equal(0.2)
  modified.final_spread |> should.equal(2.5)
}

pub fn apply_modifiers_no_modifiers_test() {
  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let base_spell =
    spell.Damage(
      name: "Test Spell",
      mana_cost: 10.0,
      damage: 5.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      projectile_size: 1.0,
      cast_delay_addition: 0.1,
      critical_chance: 0.05,
      spread: 5.0,
      visuals: visuals,
      ui_sprite: "test.png",
      on_hit_effects: [],
      is_beam: False,
    )

  let modifiers = iv.new()
  let modified = spell.apply_modifiers(spell.Spark, base_spell, modifiers)

  // Should return base values when no modifiers
  modified.final_damage |> should.equal(5.0)
  modified.final_speed |> should.equal(10.0)
  modified.final_size |> should.equal(1.0)
  modified.final_lifetime |> should.equal(2.0)
  modified.final_cast_delay |> should.equal(0.1)
  modified.final_critical_chance |> should.equal(0.05)
  modified.final_spread |> should.equal(5.0)
  modified.total_mana_cost |> should.equal(10.0)
}
