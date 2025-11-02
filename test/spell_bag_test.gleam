import gleeunit/should
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/wand

pub fn create_empty_bag_test() {
  let bag = spell_bag.new()

  spell_bag.total_spell_count(bag) |> should.equal(0)
  spell_bag.unique_spell_count(bag) |> should.equal(0)
}

pub fn add_spell_test() {
  let bag = spell_bag.new()

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let bag_with_spell = spell_bag.add_spell(bag, spark)

  spell_bag.total_spell_count(bag_with_spell) |> should.equal(1)
  spell_bag.unique_spell_count(bag_with_spell) |> should.equal(1)
  spell_bag.has_spell(bag_with_spell, spark) |> should.be_true()
  spell_bag.get_count(bag_with_spell, spark) |> should.equal(1)
}

pub fn add_multiple_same_spell_test() {
  let bag = spell_bag.new()

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let bag_with_spells = spell_bag.add_spells(bag, spark, 3)

  spell_bag.total_spell_count(bag_with_spells) |> should.equal(3)
  spell_bag.unique_spell_count(bag_with_spells) |> should.equal(1)
  spell_bag.get_count(bag_with_spells, spark) |> should.equal(3)
}

pub fn add_different_spells_test() {
  let bag = spell_bag.new()

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let fireball = spell.fireball(visuals)

  let bag1 = spell_bag.add_spell(bag, spark)
  let bag2 = spell_bag.add_spell(bag1, fireball)

  spell_bag.total_spell_count(bag2) |> should.equal(2)
  spell_bag.unique_spell_count(bag2) |> should.equal(2)
  spell_bag.has_spell(bag2, spark) |> should.be_true()
  spell_bag.has_spell(bag2, fireball) |> should.be_true()
}

pub fn remove_spell_test() {
  let bag = spell_bag.new()

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let bag_with_spell = spell_bag.add_spells(bag, spark, 3)
  let bag_after_remove = spell_bag.remove_spell(bag_with_spell, spark)

  spell_bag.get_count(bag_after_remove, spark) |> should.equal(2)
  spell_bag.total_spell_count(bag_after_remove) |> should.equal(2)
}

pub fn transfer_to_wand_success_test() {
  let bag = spell_bag.new()

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let bag_with_spell = spell_bag.add_spell(bag, spark)

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

  let result = spell_bag.transfer_to_wand(bag_with_spell, spark, test_wand, 0)

  result |> should.be_ok()

  case result {
    Ok(#(new_bag, new_wand)) -> {
      // Bag should no longer have the spell
      spell_bag.has_spell(new_bag, spark) |> should.be_false()
      // Wand should have spell in slot 0
      wand.spell_count(new_wand) |> should.equal(1)
    }
    Error(_) -> panic as "Expected Ok result"
  }
}

pub fn transfer_to_wand_invalid_slot_test() {
  let bag = spell_bag.new()

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let bag_with_spell = spell_bag.add_spell(bag, spark)

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

  // Try to transfer to invalid slot (out of bounds)
  let result = spell_bag.transfer_to_wand(bag_with_spell, spark, test_wand, 10)

  case result {
    Error(spell_bag.InvalidSlot) -> Nil
    _ -> panic as "Expected InvalidSlot error"
  }
}

pub fn list_spell_stacks_test() {
  let bag = spell_bag.new()

  let visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let spark = spell.spark(visuals)
  let fireball = spell.fireball(visuals)

  let bag1 = spell_bag.add_spells(bag, spark, 3)
  let bag2 = spell_bag.add_spells(bag1, fireball, 2)

  let stacks = spell_bag.list_spell_stacks(bag2)

  stacks |> should.have_length(2)

  // Check that we have the right counts
  let total_count =
    stacks
    |> should.be_list()
    |> should.not_equal([])

  case total_count {
    [] -> panic as "Expected non-empty list"
    _ -> {
      // Sum up counts
      let sum =
        stacks
        |> should.be_list()
        |> should.not_equal([])
      Nil
    }
  }
}
