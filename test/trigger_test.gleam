import gleam/int
import gleam/list
import gleam/option
import gleeunit
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

/// Test: Spark with trigger should have trigger payload after casting
pub fn spark_with_trigger_has_payload_test() {
  let visuals = test_visuals()

  // Wand: [Spark with Trigger, Fireball]
  // Expected: Spark projectile should have fireball as trigger payload
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.spark_with_trigger(visuals)))
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
    wand.cast(
      test_wand,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  case result {
    wand.CastSuccess(projectiles: projectiles, ..) -> {
      // Should cast 1 projectile (the spark with trigger)
      assert list.length(projectiles) == 1

      // Get the projectile
      let assert [projectile] = projectiles

      // Should have a trigger payload
      case projectile.trigger_payload {
        option.Some(_payload) -> {
          // Success - has trigger payload
          Nil
        }
        option.None -> {
          panic as "Expected trigger payload but got None"
        }
      }
    }
    _ -> panic as "Expected CastSuccess"
  }
}

/// Test: Add Trigger modifier should add trigger to next damage spell
pub fn add_trigger_modifier_adds_trigger_test() {
  let visuals = test_visuals()

  // Wand: [Add Trigger, Spark, Fireball]
  // Expected: Spark should get trigger behavior and use fireball as payload
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.add_trigger()))
    |> iv.append(option.Some(spell.spark(visuals)))
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
    wand.cast(
      test_wand,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  case result {
    wand.CastSuccess(projectiles: projectiles, ..) -> {
      // Should cast 1 projectile (spark with added trigger)
      assert list.length(projectiles) == 1

      let assert [projectile] = projectiles

      // Should have a trigger payload from the add_trigger modifier
      case projectile.trigger_payload {
        option.Some(_payload) -> {
          // Success - add_trigger worked
          Nil
        }
        option.None -> {
          panic as "Expected trigger payload from add_trigger modifier"
        }
      }
    }
    _ -> panic as "Expected CastSuccess"
  }
}

/// Test: Triggered projectile with payload has correct structure
pub fn triggered_projectile_structure_test() {
  let visuals = test_visuals()

  // Create a wand with spark with trigger and fireball payload
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.spark_with_trigger(visuals)))
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

  // Cast the spell
  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  case result {
    wand.CastSuccess(projectiles: projectiles, ..) -> {
      // Should have 1 projectile initially
      assert list.length(projectiles) == 1

      let assert [projectile] = projectiles

      // Verify the projectile has a trigger payload
      case projectile.trigger_payload {
        option.Some(payload) -> {
          // Verify payload is a fireball (damage should be 5.0)
          assert payload.final_damage == 5.0
        }
        option.None -> {
          panic as "Expected trigger payload"
        }
      }
    }
    _ -> panic as "Expected CastSuccess"
  }
}

/// Test: Trigger without payload spell doesn't crash
pub fn trigger_without_payload_doesnt_crash_test() {
  let visuals = test_visuals()

  // Wand: [Spark with Trigger] - no payload spell after it
  // Expected: Should cast normally, just without a trigger payload
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.spark_with_trigger(visuals)))

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
    wand.cast(
      test_wand,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  case result {
    wand.CastSuccess(projectiles: projectiles, ..) -> {
      // Should cast 1 projectile
      assert list.length(projectiles) == 1

      let assert [projectile] = projectiles

      // Should NOT have a trigger payload (no spell after it)
      case projectile.trigger_payload {
        option.None -> {
          // Success - no crash and no payload as expected
          Nil
        }
        option.Some(_) -> {
          panic as "Expected no trigger payload when no spell follows"
        }
      }
    }
    _ -> panic as "Expected CastSuccess"
  }
}

/// Test: Payload spell is consumed and not cast separately
pub fn trigger_consumes_payload_spell_test() {
  let visuals = test_visuals()

  // Wand: [Spark with Trigger, Fireball]
  // Expected: Only spark is cast as projectile, fireball becomes payload
  // Fireball should NOT be cast separately
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.spark_with_trigger(visuals)))
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
    wand.cast(
      test_wand,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      next_cast_index: next_cast_index,
      casting_indices: casting_indices,
      ..,
    ) -> {
      // Should cast only 1 projectile (spark with trigger)
      // Fireball is consumed as payload, not cast separately
      assert list.length(projectiles) == 1

      // Next cast should wrap to index 0 (since we consumed both slots)
      // Index after payload (1 + 1 = 2) wraps to 0 in a 2-slot wand
      assert next_cast_index == 0

      // Both indices should be in casting_indices (trigger and payload consumed)
      let sorted_indices = list.sort(casting_indices, int.compare)
      assert sorted_indices == [0, 1]
    }
    _ -> panic as "Expected CastSuccess"
  }
}

/// Test: Add Trigger with modifiers between it and the damage spell
pub fn add_trigger_with_modifiers_test() {
  let visuals = test_visuals()

  // Wand: [Add Trigger, Add Damage, Spark, Fireball]
  // Expected: Add Damage should modify spark, trigger should use fireball
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.add_trigger()))
    |> iv.append(option.Some(spell.add_damage()))
    |> iv.append(option.Some(spell.spark(visuals)))
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
    wand.cast(
      test_wand,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  case result {
    wand.CastSuccess(projectiles: projectiles, ..) -> {
      // Should cast 1 projectile
      assert list.length(projectiles) == 1

      let assert [projectile] = projectiles

      // Verify spark has increased damage from Add Damage modifier
      // Base spark damage is 3.0, Add Damage adds 10.0
      assert projectile.spell.final_damage == 13.0

      // Should have trigger payload
      assert option.is_some(projectile.trigger_payload)
    }
    _ -> panic as "Expected CastSuccess"
  }
}

/// Test: Trigger with modifiers between trigger and payload
pub fn trigger_with_intermediate_modifiers_test() {
  let visuals = test_visuals()

  // Wand: [Spark with Trigger, Add Damage, Fireball]
  // Expected: Spark should consume both Add Damage and Fireball
  // Add Damage and Fireball should NOT be cast separately
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.spark_with_trigger(visuals)))
    |> iv.append(option.Some(spell.add_damage()))
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
    wand.cast(
      test_wand,
      0,
      Vec3(0.0, 0.0, 0.0),
      Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  case result {
    wand.CastSuccess(
      projectiles: projectiles,
      casting_indices: casting_indices,
      ..,
    ) -> {
      // Should cast only 1 projectile (spark with trigger)
      assert list.length(projectiles) == 1

      // All three indices should be consumed (trigger, modifier, payload)
      let sorted_indices = list.sort(casting_indices, int.compare)
      assert sorted_indices == [0, 1, 2]

      // Verify the projectile has a trigger payload
      let assert [projectile] = projectiles
      assert option.is_some(projectile.trigger_payload)
    }
    _ -> panic as "Expected CastSuccess"
  }
}
