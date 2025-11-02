import gleam/option.{None, Some}
import gleeunit/should
import pondering_my_orb/spell
import pondering_my_orb/wand
import vec/vec3.{Vec3}

pub fn create_wand_test() {
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.1,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  test_wand.name |> should.equal("Test Wand")
  test_wand.max_mana |> should.equal(100.0)
  test_wand.current_mana |> should.equal(100.0)
  wand.spell_count(test_wand) |> should.equal(0)
}

pub fn set_spell_test() {
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.1,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark_spell = spell.spark(visuals)

  let result = wand.set_spell(test_wand, 0, spark_spell)

  result |> should.be_ok()

  case result {
    Ok(updated_wand) -> {
      wand.spell_count(updated_wand) |> should.equal(1)
      case wand.get_spell(updated_wand, 0) {
        Ok(Some(_)) -> Nil
        _ -> panic as "Expected spell in slot 0"
      }
    }
    Error(_) -> panic as "Expected Ok result"
  }
}

pub fn cast_with_enough_mana_test() {
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.1,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark_spell = spell.spark(visuals)

  let assert Ok(wand_with_spell) = wand.set_spell(test_wand, 0, spark_spell)

  let #(result, updated_wand) =
    wand.cast(
      wand_with_spell,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      None,
    )

  case result {
    wand.CastSuccess(projectiles:, remaining_mana:, ..) -> {
      // Should have created one projectile
      projectiles |> should.have_length(1)
      // Mana should be reduced
      remaining_mana |> should.not_equal(100.0)
      // Spark costs 5.0 mana
      remaining_mana |> should.equal(95.0)
    }
    _ -> panic as "Expected CastSuccess"
  }
}

pub fn cast_without_enough_mana_test() {
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 3,
      max_mana: 3.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.1,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark_spell = spell.spark(visuals)

  let assert Ok(wand_with_spell) = wand.set_spell(test_wand, 0, spark_spell)

  let #(result, _) =
    wand.cast(
      wand_with_spell,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      None,
    )

  case result {
    wand.NotEnoughMana(required:, available:) -> {
      required |> should.equal(5.0)
      available |> should.equal(3.0)
    }
    _ -> panic as "Expected NotEnoughMana"
  }
}

pub fn cast_with_multicast_test() {
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 5,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.1,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let double_spell = spell.double_spell()
  let spark_spell = spell.spark(visuals)

  // Set up: Double Spell, Spark, Spark
  let assert Ok(wand1) = wand.set_spell(test_wand, 0, double_spell)
  let assert Ok(wand2) = wand.set_spell(wand1, 1, spark_spell)
  let assert Ok(wand_with_spells) = wand.set_spell(wand2, 2, spark_spell)

  let #(result, _) =
    wand.cast(
      wand_with_spells,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      None,
    )

  case result {
    wand.CastSuccess(projectiles:, remaining_mana:, ..) -> {
      // Should cast 2 sparks (double spell casts next 2 spells)
      projectiles |> should.have_length(2)
      // Mana should be 100.0 - (0.0 for double + 5.0 + 5.0) = 90.0
      remaining_mana |> should.equal(90.0)
    }
    _ -> panic as "Expected CastSuccess"
  }
}

pub fn recharge_mana_test() {
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.1,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  // Manually set mana to 50
  let wand_with_low_mana = wand.Wand(..test_wand, current_mana: 50.0)

  // Recharge for 2 seconds at 10.0/second = 20.0 mana
  let recharged = wand.recharge_mana(wand_with_low_mana, 2.0)

  recharged.current_mana |> should.equal(70.0)

  // Test that it doesn't exceed max
  let recharged_more = wand.recharge_mana(recharged, 10.0)
  recharged_more.current_mana |> should.equal(100.0)
}

pub fn reorder_slots_test() {
  let test_wand =
    wand.new(
      name: "Test Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.1,
      recharge_time: 0.5,
      spells_per_cast: 1,
      spread: 0.0,
    )

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let fireball = spell.fireball(visuals)

  let assert Ok(wand1) = wand.set_spell(test_wand, 0, spark)
  let assert Ok(wand2) = wand.set_spell(wand1, 1, fireball)

  // Reorder: move slot 0 to slot 2
  let assert Ok(reordered) = wand.reorder_slots(wand2, 0, 2)

  // Slot 0 should now be fireball
  case wand.get_spell(reordered, 0) {
    Ok(Some(spell.DamageSpell(spell.Fireball, _))) -> Nil
    _ -> panic as "Expected Fireball in slot 0"
  }

  // Slot 2 should now be spark
  case wand.get_spell(reordered, 2) {
    Ok(Some(spell.DamageSpell(spell.Spark, _))) -> Nil
    _ -> panic as "Expected Spark in slot 2"
  }
}
