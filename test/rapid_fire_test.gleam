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

/// Test: Verify Rapid Fire's cast_delay_addition value
pub fn rapid_fire_has_negative_cast_delay_addition_test() {
  let rapid_fire = spell.rapid_fire()

  let assert spell.ModifierSpell(kind: modifier, ..) = rapid_fire

  // Rapid Fire should have -170ms cast delay addition
  assert modifier.cast_delay_addition == duration.milliseconds(-170)
}

/// Test: Spark's base cast_delay_addition
pub fn spark_has_positive_cast_delay_addition_test() {
  let visuals = test_visuals()
  let spark = spell.spark(visuals)

  let assert spell.DamageSpell(kind: damage_spell, ..) = spark

  // Spark has +50ms cast delay addition
  assert damage_spell.cast_delay_addition == duration.milliseconds(50)
}

/// Test: apply_modifiers correctly applies cast_delay_addition
pub fn apply_modifiers_reduces_cast_delay_test() {
  let visuals = test_visuals()
  let spark = spell.spark(visuals)

  let assert spell.DamageSpell(id: spark_id, kind: spark_damage) = spark
  let assert spell.ModifierSpell(kind: rapid_fire_mod, ..) = spell.rapid_fire()

  let modifiers = iv.new() |> iv.append(rapid_fire_mod)

  let modified = spell.apply_modifiers(spark_id, spark_damage, modifiers)

  // Spark (+50ms) + Rapid Fire (-170ms) = -120ms
  echo duration.approximate(modified.final_cast_delay)

  assert modified.final_cast_delay == duration.milliseconds(-120)
}

/// Test: wand.cast returns correct total_cast_delay_addition with Rapid Fire
pub fn wand_cast_with_rapid_fire_reduces_cast_delay_test() {
  let visuals = test_visuals()

  // Wand: [Rapid Fire, Spark]
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
      cast_delay: duration.milliseconds(100),
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

  let assert wand.CastSuccess(total_cast_delay_addition:, ..) = result

  // Rapid Fire (-170ms) + Spark (+50ms) = -120ms
  echo duration.approximate(total_cast_delay_addition)

  assert total_cast_delay_addition == duration.milliseconds(-120)
}

/// Test: duration.add with negative values
pub fn duration_add_negative_test() {
  let base = duration.milliseconds(100)
  let negative = duration.milliseconds(-120)
  let result = duration.add(base, negative)

  echo #("base", duration.approximate(base))
  echo #("negative", duration.approximate(negative))
  echo #("result", duration.approximate(result))

  // 100 + (-120) = -20ms
  assert result == duration.milliseconds(-20)
}

/// Test: Verify the final cooldown calculation matches player logic
pub fn final_cooldown_calculation_test() {
  let visuals = test_visuals()

  // Simulate player's wand settings
  let wand_cast_delay = duration.milliseconds(150)
  let wand_recharge_time = duration.milliseconds(330)

  // Wand: [Rapid Fire, Spark]
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
      cast_delay: wand_cast_delay,
      recharge_time: wand_recharge_time,
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
    total_cast_delay_addition: delay,
    total_recharge_time_addition: recharge_addition,
    did_wrap: wrapped,
    ..,
  ) = result

  echo #("delay", duration.approximate(delay))
  echo #("recharge_addition", duration.approximate(recharge_addition))
  echo #("wrapped", wrapped)

  // Player's cooldown calculation (matching try_cast_spell logic)
  let total_delay = duration.add(wand_cast_delay, delay)
  echo #("total_delay (cast_delay + delay)", duration.approximate(total_delay))

  let final_cooldown = case wrapped {
    True -> {
      let recharge = duration.add(wand_recharge_time, recharge_addition)
      duration.add(total_delay, recharge)
    }
    False -> total_delay
  }
  echo #("final_cooldown", duration.approximate(final_cooldown))

  // With Rapid Fire (-170ms) + Spark (+50ms) = -120ms
  // 150 + (-120) = 30ms cooldown
  assert final_cooldown == duration.milliseconds(30)
}

/// Test: Subsequent casts with 4 slots (2 filled, 2 empty)
pub fn subsequent_casts_with_empty_slots_test() {
  let visuals = test_visuals()

  // Player's wand: 4 slots, only first 2 filled
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.rapid_fire()))
    |> iv.append(option.Some(spell.spark(visuals)))
    |> iv.append(option.None)
    |> iv.append(option.None)

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: duration.milliseconds(150),
      recharge_time: duration.milliseconds(330),
      spells_per_cast: 1,
      spread: 0.0,
    )

  // First cast starts at index 0
  let #(result1, wand1) =
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
    next_cast_index: next_index1,
    total_cast_delay_addition: delay1,
    did_wrap: wrapped1,
    ..,
  ) = result1

  echo #("Cast 1 - next_index", next_index1)
  echo #("Cast 1 - delay", duration.approximate(delay1))
  echo #("Cast 1 - wrapped", wrapped1)

  // Second cast starts where first left off
  let #(result2, _wand2) =
    wand.cast(
      wand1,
      next_index1,
      vec3.Vec3(0.0, 0.0, 0.0),
      vec3.Vec3(1.0, 0.0, 0.0),
      1,
      option.None,
      option.None,
      [],
    )

  let assert wand.CastSuccess(
    next_cast_index: next_index2,
    total_cast_delay_addition: delay2,
    did_wrap: wrapped2,
    ..,
  ) = result2

  echo #("Cast 2 - next_index", next_index2)
  echo #("Cast 2 - delay", duration.approximate(delay2))
  echo #("Cast 2 - wrapped", wrapped2)

  // Second cast should wrap and find RapidFire again
  // So delay should still be -120ms (RapidFire + Spark)
  assert delay2 == duration.milliseconds(-120)
}

/// Test: Multiple Rapid Fire modifiers stack
pub fn multiple_rapid_fire_stack_test() {
  let visuals = test_visuals()

  // Wand: [Rapid Fire, Rapid Fire, Spark]
  let slots =
    iv.new()
    |> iv.append(option.Some(spell.rapid_fire()))
    |> iv.append(option.Some(spell.rapid_fire()))
    |> iv.append(option.Some(spell.spark(visuals)))

  let test_wand =
    wand.Wand(
      name: "Test Wand",
      slots:,
      max_mana: 100.0,
      current_mana: 100.0,
      mana_recharge_rate: 30.0,
      cast_delay: duration.milliseconds(100),
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

  let assert wand.CastSuccess(total_cast_delay_addition:, ..) = result

  // 2x Rapid Fire (-340ms) + Spark (+50ms) = -290ms
  echo duration.approximate(total_cast_delay_addition)

  assert total_cast_delay_addition == duration.milliseconds(-290)
}
