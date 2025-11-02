import gleam/list
import gleam/option
import gleeunit
import gleeunit/should
import iv
import pondering_my_orb/spell
import pondering_my_orb/wand
import vec/vec3.{Vec3}

pub fn main() {
  gleeunit.main()
}

// Helper to create test visuals
fn test_visuals() -> spell.SpellVisuals {
  spell.SpellVisuals(
    projectile_spritesheet: spell.mock_spritesheet(),
    projectile_animation: spell.mock_animation(),
    hit_spritesheet: spell.mock_spritesheet(),
    hit_animation: spell.mock_animation(),
  )
}

/// Test: Double spell with 2 fireballs should cast both
pub fn double_spell_casts_two_spells_test() {
  let visuals = test_visuals()

  // Wand: [Double Spell, Fireball, Fireball]
  // spells_per_cast = 1
  // Expected: Double spell adds 2 draw, so it casts both fireballs
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.double_spell()))
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.fireball(visuals)))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: 0.2,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0, option.None)

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      casting_indices: casting_indices,
      ..,
    ) -> {
      // Should cast 2 projectiles
      projectiles
      |> list.length
      |> should.equal(2)

      // Should highlight: double_spell (0), fireball (1), fireball (2)
      // Indices are added in reverse order
      casting_indices
      |> list.reverse
      |> should.equal([0, 1, 2])
    }
    wand.NotEnoughMana(..) -> should.fail()
    wand.NoSpellToCast -> should.fail()
    wand.WandEmpty -> should.fail()
  }
}

/// Test: Double spell with only 1 spell after it should cast that 1 spell
pub fn double_spell_with_one_spell_test() {
  let visuals = test_visuals()

  // Wand: [Double Spell, Fireball]
  // Expected: Casts 1 fireball (only 1 available)
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.double_spell()))
    |> iv.append(option.Some(spell.fireball(visuals)))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: 0.2,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0, option.None)

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      casting_indices: casting_indices,
      ..,
    ) -> {
      // Should cast 1 projectile
      projectiles
      |> list.length
      |> should.equal(1)

      // Should highlight: double_spell (0), fireball (1)
      casting_indices
      |> list.reverse
      |> should.equal([0, 1])
    }
    _ -> should.fail()
  }
}

/// Test: Double spell at end of wand with wrapping
pub fn double_spell_wrapping_test() {
  let visuals = test_visuals()

  // Wand: [Fireball, Fireball, Double Spell]
  // Start at index 2 (double spell)
  // Expected: Should wrap and cast the 2 fireballs from the start
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.double_spell()))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: 0.2,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(test_wand, 2, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0, option.None)

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      next_cast_index: next_cast_index,
      casting_indices: casting_indices,
      did_wrap: did_wrap,
      ..,
    ) -> {
      // Should cast 2 projectiles
      projectiles
      |> list.length
      |> should.equal(2)

      // Should wrap back to start
      did_wrap
      |> should.be_true()

      // Next cast should be at index 2 (after wrapping)
      next_cast_index
      |> should.equal(2)

      // Should highlight: double_spell (2), fireball (0), fireball (1)
      casting_indices
      |> list.reverse
      |> should.equal([2, 0, 1])
    }
    _ -> should.fail()
  }
}

/// Test: Multiple double spells in a row
pub fn multiple_double_spells_test() {
  let visuals = test_visuals()

  // Wand: [Double Spell, Double Spell, Fireball, Fireball, Fireball, Fireball]
  // spells_per_cast = 1
  // Expected: First double adds +2 draw (total 2), second adds +2 draw (total 3)
  // So it should cast 3 fireballs
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.double_spell()))
    |> iv.append(option.Some(spell.double_spell()))
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.fireball(visuals)))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: 0.2,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0, option.None)

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      casting_indices: casting_indices,
      ..,
    ) -> {
      // First double: draw = 1 - 1 + 2 = 2
      // Second double: draw = 2 - 1 + 2 = 3
      // Three fireballs: draw = 3 - 1 - 1 - 1 = 0
      // Should cast 3 projectiles
      projectiles
      |> list.length
      |> should.equal(3)

      // Should highlight: double (0), double (1), fireball (2), fireball (3), fireball (4)
      casting_indices
      |> list.reverse
      |> should.equal([0, 1, 2, 3, 4])
    }
    _ -> should.fail()
  }
}

/// Test: Double spell with empty slot after it
pub fn double_spell_with_empty_slot_test() {
  let visuals = test_visuals()

  // Wand: [Double Spell, Empty, Fireball, Fireball]
  // Expected: Should skip empty slot and cast 2 fireballs
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.double_spell()))
    |> iv.append(option.None)
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.fireball(visuals)))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: 0.2,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0, option.None)

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      casting_indices: casting_indices,
      ..,
    ) -> {
      // Should cast 2 projectiles (skipping the empty slot)
      projectiles
      |> list.length
      |> should.equal(2)

      // Should highlight: double_spell (0), empty (1), fireball (2), fireball (3)
      casting_indices
      |> list.reverse
      |> should.equal([0, 1, 2, 3])
    }
    _ -> should.fail()
  }
}

/// Test: Double spell with modifier before damage spell
pub fn double_spell_with_modifier_test() {
  let visuals = test_visuals()

  // Wand: [Double Spell, Add Mana, Fireball, Fireball]
  // Expected: Add Mana modifies both fireballs, reduces mana cost
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.double_spell()))
    |> iv.append(option.Some(spell.add_mana()))
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.Some(spell.fireball(visuals)))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: 0.2,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(test_wand, 0, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0, option.None)

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      remaining_mana: remaining_mana,
      casting_indices: casting_indices,
      ..,
    ) -> {
      // Should cast 2 projectiles
      projectiles
      |> list.length
      |> should.equal(2)

      // Fireball normally costs 15.0 mana each
      // Add Mana reduces cost by 30.0
      // So each modified fireball costs 15.0 - 30.0 = -15.0 (gains 15 mana!)
      // Total mana change: -15 * 2 = -30 (gain 30 mana)
      // Expected remaining: 100.0 - (-30.0) = 130.0
      remaining_mana
      |> should.equal(130.0)

      // Should highlight all used slots
      casting_indices
      |> list.reverse
      |> should.equal([0, 1, 2, 3])
    }
    _ -> should.fail()
  }
}

/// Test: Double spell wrapping with partial spells available
pub fn double_spell_wrapping_partial_test() {
  let visuals = test_visuals()

  // Wand: [Fireball, Empty, Double Spell]
  // Start at index 2 (double spell)
  // Expected: Should wrap and cast 1 fireball (only 1 available after wrapping)
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.fireball(visuals)))
    |> iv.append(option.None)
    |> iv.append(option.Some(spell.double_spell()))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: 0.2,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(test_wand, 2, Vec3(0.0, 0.0, 0.0), Vec3(1.0, 0.0, 0.0), 0, option.None)

  case result {
    wand.CastSuccess(projectiles: projectiles, did_wrap: did_wrap, ..) -> {
      // Should cast 1 projectile (only 1 available)
      projectiles
      |> list.length
      |> should.equal(1)

      // Should wrap
      did_wrap
      |> should.be_true()
    }
    _ -> should.fail()
  }
}
