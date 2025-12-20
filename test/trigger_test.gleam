import gleam/int
import gleam/list
import gleam/option
import gleam/time/duration
import iv
import pondering_my_orb/magic_system/spell
import pondering_my_orb/magic_system/wand
import vec/vec2
import vec/vec3

// Helper to create test visuals
fn test_visuals() -> spell.SpellVisuals {
  spell.SpellVisuals(
    projectile: spell.StaticSprite(
      texture_path: "test_sprite.png",
      size: vec2.Vec2(1.0, 1.0),
    ),
    hit_effect: spell.GenericExplosion,
    base_tint: 0xFFFF00,
    emissive_intensity: 1.0,
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
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(projectiles: projectiles, ..) = result

  // Should cast 1 projectile (the spark with trigger)
  let assert [projectile] = projectiles

  // Should have a trigger payload
  assert option.is_some(projectile.trigger_payload)
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
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(projectiles: projectiles, ..) = result

  // Should cast 1 projectile (spark with added trigger)
  let assert [projectile] = projectiles

  // Should have a trigger payload from the add_trigger modifier
  assert option.is_some(projectile.trigger_payload)
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
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  // Cast the spell
  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(projectiles: projectiles, ..) = result

  // Should have 1 projectile initially
  let assert [projectile] = projectiles

  // Verify the projectile has a trigger payload with fireball damage (5.0)
  let assert option.Some(payload) = projectile.trigger_payload
  assert payload.final_damage == 5.0
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
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(projectiles: projectiles, ..) = result

  // Should cast 1 projectile
  let assert [projectile] = projectiles

  // Should NOT have a trigger payload (no spell after it)
  assert option.is_none(projectile.trigger_payload)
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
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(
    projectiles: projectiles,
    next_cast_index: next_cast_index,
    casting_indices: casting_indices,
    ..,
  ) = result

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
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(projectiles: projectiles, ..) = result
  let assert [projectile] = projectiles

  // Verify spark has increased damage from Add Damage modifier
  // Base spark damage is 3.0, Add Damage adds 10.0
  assert projectile.spell.final_damage == 13.0

  // Should have trigger payload
  assert option.is_some(projectile.trigger_payload)
}

/// Test: Trigger with modifiers between trigger and payload
pub fn trigger_with_intermediate_modifiers_test() {
  let visuals = test_visuals()

  // Wand: [Spark with Trigger, Add Damage, Fireball]
  // Expected: Spark should consume both Add Damage and Fireball
  // Add Damage should modify the Fireball payload
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
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(
    projectiles: projectiles,
    casting_indices: casting_indices,
    ..,
  ) = result

  // Should cast only 1 projectile (spark with trigger)
  let assert [projectile] = projectiles

  // All three indices should be consumed (trigger, modifier, payload)
  let sorted_indices = list.sort(casting_indices, int.compare)
  assert sorted_indices == [0, 1, 2]

  // Verify the projectile has a trigger payload
  // Fireball base damage is 5.0, Add Damage adds 10.0
  // So payload should have 15.0 damage
  let assert option.Some(payload) = projectile.trigger_payload
  assert payload.final_damage == 15.0
}

/// Test: Multiple modifiers applied to payload
pub fn trigger_multiple_payload_modifiers_test() {
  let visuals = test_visuals()

  // Wand: [Spark with Trigger, Add Mana, Add Damage, Fireball]
  // Expected: Both modifiers should affect the Fireball payload
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.spark_with_trigger(visuals)))
    |> iv.append(option.Some(spell.add_mana()))
    |> iv.append(option.Some(spell.add_damage()))
    |> iv.append(option.Some(spell.fireball(visuals)))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: duration.milliseconds(200),
      recharge_time: duration.milliseconds(500),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let #(result, _updated_wand) =
    wand.cast(
      test_wand,
      0,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      0,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(projectiles: projectiles, ..) = result
  let assert [projectile] = projectiles
  let assert option.Some(payload) = projectile.trigger_payload

  // Fireball: base damage 5.0 + Add Damage 10.0 = 15.0
  assert payload.final_damage == 15.0

  // Fireball: base mana 15.0 + Add Mana -30.0 = -15.0
  assert payload.total_mana_cost == -15.0
}
