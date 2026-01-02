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

/// Test: Rapid Fire modifier should reduce recharge time
pub fn rapid_fire_reduces_recharge_test() {
  let visuals = test_visuals()

  // Wand: [Rapid Fire, Spark]
  // Expected: Cast should return negative recharge_time_addition
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.rapid_fire()))
    |> iv.append(option.Some(spell.spark(visuals)))

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

  let assert wand.CastSuccess(total_recharge_time_addition:, ..) = result

  // Rapid Fire has recharge_addition of -0.33 seconds = -330ms
  assert total_recharge_time_addition == duration.milliseconds(-330)
}

/// Test: Multiple modifiers should accumulate recharge additions
pub fn multiple_modifiers_accumulate_recharge_test() {
  let visuals = test_visuals()

  // Create a custom modifier with recharge addition
  let custom_modifier =
    spell.ModifierSpell(
      id: spell.AddDamage,
      kind: spell.Modifier(
        ..spell.default_modifier("Test Modifier", "test.png"),
        recharge_addition: duration.milliseconds(500),
      ),
    )

  // Wand: [Custom Modifier (+0.5), Rapid Fire (-0.33), Spark]
  // Expected: total_recharge_time_addition = 0.5 - 0.33 = 0.17
  let slots =
    iv.new()
    |> iv.append(option.Some(custom_modifier))
    |> iv.append(option.Some(spell.rapid_fire()))
    |> iv.append(option.Some(spell.spark(visuals)))

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

  let assert wand.CastSuccess(total_recharge_time_addition:, ..) = result

  // Should be approximately 0.17 seconds = 170ms
  assert duration.approximate(total_recharge_time_addition)
    == #(170, duration.Millisecond)
}

/// Test: Recharge multiplier should multiply the accumulated recharge additions
pub fn recharge_multiplier_test() {
  let visuals = test_visuals()

  // Create a modifier with recharge multiplier
  let multiplier_modifier =
    spell.ModifierSpell(
      id: spell.AddDamage,
      kind: spell.Modifier(
        ..spell.default_modifier("Multiplier", "test.png"),
        recharge_addition: duration.seconds(1),
        recharge_multiplier: 2.0,
      ),
    )

  // Wand: [Multiplier (add 1.0, multiply by 2.0), Spark]
  // Expected: (0.0 + 1.0) * 2.0 = 2.0
  let slots =
    iv.new()
    |> iv.append(option.Some(multiplier_modifier))
    |> iv.append(option.Some(spell.spark(visuals)))

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

  let assert wand.CastSuccess(total_recharge_time_addition:, ..) = result

  assert duration.approximate(total_recharge_time_addition)
    == #(2, duration.Second)
}

/// Test: Modified spell should contain final_recharge_time
pub fn modified_spell_includes_recharge_time_test() {
  let visuals = test_visuals()
  let spark_spell = spell.spark(visuals)

  let assert spell.DamageSpell(id: spark_id, kind: spark_damage) = spark_spell

  // Create a modifier with recharge addition
  let modifier =
    spell.Modifier(
      ..spell.default_modifier("Test", "test.png"),
      recharge_addition: duration.milliseconds(500),
      recharge_multiplier: 2.0,
    )

  let modifiers = iv.new() |> iv.append(modifier)

  let modified = spell.apply_modifiers(spark_id, spark_damage, modifiers)

  // Check that final_recharge_time is calculated correctly
  // (0.0 + 0.5) * 2.0 = 1.0
  assert duration.approximate(modified.final_recharge_time)
    == #(1, duration.Second)
}
