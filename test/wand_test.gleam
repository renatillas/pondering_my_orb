import gleam/float
import gleeunit
import pondering_my_orb/spell
import pondering_my_orb/wand
import vec/vec3.{Vec3}

pub fn main() {
  gleeunit.main()
}

// Helper function to create test visuals
fn test_visuals() -> spell.SpellVisuals {
  spell.SpellVisuals(
    projectile_spritesheet: spell.mock_spritesheet(),
    projectile_animation: spell.mock_animation(),
    hit_spritesheet: spell.mock_spritesheet(),
    hit_animation: spell.mock_animation(),
  )
}

// Test: Single spell wand should wrap after one cast
pub fn single_spell_wand_wraps_test() {
  // Create a wand with 1 spell
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 1,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.2,
      recharge_time: 1.0,
      spells_per_cast: 1,
    )

  // Add a simple damage spell directly without visuals for testing
  let test_spell =
    spell.damaging_spell(
      name: "Test Spell",
      damage: 10.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      mana_cost: 5.0,
      projectile_size: 1.0,
      visuals: test_visuals(),
      ui_sprite: "test.png",
      on_hit_effects: [],
    )
  let assert Ok(test_wand) = wand.set_spell(test_wand, 0, test_spell)

  // Cast from index 0
  let #(result, _wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0)

  // Verify cast succeeded
  let assert wand.CastSuccess(
    projectiles:,
    remaining_mana:,
    next_cast_index:,
    casting_indices: _,
    did_wrap:,
  ) = result

  // Should have created 1 projectile
  let assert [_projectile] = projectiles

  // Next index should be 0 (wrapped)
  assert next_cast_index == 0

  // Should indicate wrapping occurred
  assert did_wrap == True

  // Should have used mana
  assert remaining_mana <. 100.0

  Nil
}

// Test: Multi-spell wand should NOT wrap until last spell
pub fn multi_spell_wand_no_wrap_test() {
  // Create a wand with 3 spells
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.2,
      recharge_time: 1.0,
      spells_per_cast: 1,
    )

  // Add spells
  let test_spell =
    spell.damaging_spell(
      name: "Test Spell",
      damage: 10.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      mana_cost: 5.0,
      projectile_size: 1.0,
      visuals: test_visuals(),
      ui_sprite: "test.png",
      on_hit_effects: [],
    )
  let assert Ok(test_wand) = wand.set_spell(test_wand, 0, test_spell)
  let assert Ok(test_wand) = wand.set_spell(test_wand, 1, test_spell)
  let assert Ok(test_wand) = wand.set_spell(test_wand, 2, test_spell)

  // Cast first spell (index 0)
  let #(result, _wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0)

  let assert wand.CastSuccess(did_wrap: did_wrap1, next_cast_index: next1, ..) =
    result

  // First cast should NOT wrap
  assert did_wrap1 == False
  assert next1 == 1

  // Cast second spell (index 1)
  let #(result, _wand) =
    wand.cast(test_wand, 1, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 1)

  let assert wand.CastSuccess(did_wrap: did_wrap2, next_cast_index: next2, ..) =
    result

  // Second cast should NOT wrap
  assert did_wrap2 == False
  assert next2 == 2

  // Cast third spell (index 2) - this is the LAST spell
  let #(result, _wand) =
    wand.cast(test_wand, 2, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 2)

  let assert wand.CastSuccess(did_wrap: did_wrap3, next_cast_index: next3, ..) =
    result

  // Third cast SHOULD wrap (last spell in wand)
  assert did_wrap3 == True
  assert next3 == 0
}

// Test: Wand with no spells
pub fn empty_wand_test() {
  let test_wand =
    wand.new(
      name: "Empty Wand",
      slot_count: 5,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.2,
      recharge_time: 1.0,
      spells_per_cast: 1,
    )

  // Try to cast with no spells
  let #(result, _wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0)

  // Should return NoSpellToCast or WandEmpty
  assert result == wand.NoSpellToCast || result == wand.WandEmpty
}

// Test: Wand with empty slots after last spell
pub fn wand_with_empty_slots_test() {
  // Create a wand with 5 slots but only 1 spell in slot 0
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 5,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.2,
      recharge_time: 1.0,
      spells_per_cast: 1,
    )

  let test_spell =
    spell.damaging_spell(
      name: "Test Spell",
      damage: 10.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      mana_cost: 5.0,
      projectile_size: 1.0,
      visuals: test_visuals(),
      ui_sprite: "test.png",
      on_hit_effects: [],
    )
  let assert Ok(test_wand) = wand.set_spell(test_wand, 0, test_spell)

  let #(result, _wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0)

  let assert wand.CastSuccess(did_wrap: did_wrap, next_cast_index: next, ..) =
    result

  // Should wrap even though next_index < slot_count
  // because there are no more spells ahead
  assert did_wrap == True
  assert next == 1
}

// Test: Double Spell multicast - should fire 2 projectiles in one cast
pub fn double_spell_multicast_test() {
  // Create wand with spells_per_cast = 1
  let test_wand =
    wand.new(
      name: "Multicast Wand",
      slot_count: 4,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.2,
      recharge_time: 1.0,
      spells_per_cast: 1,
    )

  // Setup: [Double Spell, Fireball, Spark, Lightning]
  let visuals = test_visuals()
  let double = spell.double_spell()
  let fireball =
    spell.damaging_spell(
      name: "Fireball",
      damage: 20.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      mana_cost: 10.0,
      projectile_size: 1.0,
      visuals: visuals,
      ui_sprite: "fireball.png",
      on_hit_effects: [],
    )
  let spark =
    spell.damaging_spell(
      name: "Spark",
      damage: 10.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      mana_cost: 5.0,
      projectile_size: 1.0,
      visuals: visuals,
      ui_sprite: "spark.png",
      on_hit_effects: [],
    )
  let lightning =
    spell.damaging_spell(
      name: "Lightning",
      damage: 100.0,
      projectile_speed: 30.0,
      projectile_lifetime: 1.0,
      mana_cost: 35.0,
      projectile_size: 0.2,
      visuals: visuals,
      ui_sprite: "lightning.png",
      on_hit_effects: [],
    )

  let assert Ok(test_wand) = wand.set_spell(test_wand, 0, double)
  let assert Ok(test_wand) = wand.set_spell(test_wand, 1, fireball)
  let assert Ok(test_wand) = wand.set_spell(test_wand, 2, spark)
  let assert Ok(test_wand) = wand.set_spell(test_wand, 3, lightning)

  // Cast from index 0
  // Draw: 1 -> process Double (draw = 1 - 1 + 2 = 2)
  //       2 -> process Fireball (draw = 2 - 1 = 1), create projectile
  //       1 -> process Spark (draw = 1 - 1 = 0), create projectile
  //       0 -> draw exhausted, stop
  let #(result, _wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0)

  let assert wand.CastSuccess(
    projectiles: projectiles,
    next_cast_index: next_index,
    did_wrap: did_wrap,
    ..,
  ) = result

  // Should have fired 2 projectiles (Fireball + Spark)
  let assert [_proj1, _proj2] = projectiles

  // Next index should be 3 (Lightning not processed yet)
  assert next_index == 3

  // Should NOT wrap (more spells ahead)
  assert did_wrap == False
}

// Test: Modifiers accumulate within a cast state
pub fn modifier_accumulation_test() {
  let test_wand =
    wand.new(
      name: "Modifier Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.2,
      recharge_time: 1.0,
      spells_per_cast: 3,
    )

  // Setup: [Damage Modifier, Speed Modifier, Fireball]
  let visuals = test_visuals()
  let damage_mod =
    spell.modifier_spell(
      name: "Heavy Shot",
      damage_multiplier: 2.0,
      damage_addition: 5.0,
      projectile_speed_multiplier: 1.0,
      projectile_speed_addition: 0.0,
      projectile_size_multiplier: 1.0,
      projectile_size_addition: 0.0,
      projectile_lifetime_multiplier: 1.0,
      projectile_lifetime_addition: 0.0,
      mana_cost: 5.0,
      ui_sprite: "heavy.png",
    )
  let speed_mod =
    spell.modifier_spell(
      name: "Accelerating Shot",
      damage_multiplier: 1.0,
      damage_addition: 0.0,
      projectile_speed_multiplier: 3.0,
      projectile_speed_addition: 10.0,
      projectile_size_multiplier: 1.0,
      projectile_size_addition: 0.0,
      projectile_lifetime_multiplier: 1.0,
      projectile_lifetime_addition: 0.0,
      mana_cost: 3.0,
      ui_sprite: "speed.png",
    )
  let fireball =
    spell.damaging_spell(
      name: "Fireball",
      damage: 20.0,
      projectile_speed: 10.0,
      projectile_lifetime: 2.0,
      mana_cost: 10.0,
      projectile_size: 1.0,
      visuals: visuals,
      ui_sprite: "fireball.png",
      on_hit_effects: [],
    )

  let assert Ok(test_wand) = wand.set_spell(test_wand, 0, damage_mod)
  let assert Ok(test_wand) = wand.set_spell(test_wand, 1, speed_mod)
  let assert Ok(test_wand) = wand.set_spell(test_wand, 2, fireball)

  let #(result, _wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0)

  let assert wand.CastSuccess(projectiles: projectiles, ..) = result
  let assert [projectile] = projectiles

  // Damage: (20 + 5) * 2.0 = 50.0
  assert projectile.spell.final_damage == 50.0

  // Speed: (10 + 10) * 3.0 = 60.0
  assert projectile.spell.final_speed == 60.0
}

// Test: Timing calculation for reload
pub fn reload_timing_test() {
  let cast_delay = 0.2
  let recharge_time = 1.0

  // According to Noita: wait max(cast_delay, recharge_time)
  let max_delay = float.max(cast_delay, recharge_time)

  // Timer should start at: cast_delay - max_delay
  let expected_start = cast_delay -. max_delay

  assert expected_start == -0.8

  // Timer should go from -0.8 to cast_delay (0.2)
  // Total duration: 0.2 - (-0.8) = 1.0 second
  let total_duration = cast_delay -. expected_start
  assert total_duration == 1.0
}
