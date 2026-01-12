import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $duration from "../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../iv/iv.mjs";
import * as $vec3 from "../vec/vec/vec3.mjs";
import * as $spell from "./client/magic_system/spell.mjs";
import * as $wand from "./client/magic_system/wand.mjs";
import { toList, makeError, isEqual } from "./gleam.mjs";

const FILEPATH = "test/recharge_modifier_test.gleam";

/**
 * Test: Rapid Fire modifier should reduce recharge time
 */
export function rapid_fire_reduces_recharge_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.rapid_fire()));
  _block = $iv.append(_pipe$1, new $option.Some($spell.spark()));
  let slots = _block;
  let test_wand = new $wand.Wand(
    "Test Wand",
    slots,
    100.0,
    100.0,
    30.0,
    $duration.milliseconds(200),
    $duration.milliseconds(500),
    1,
    0.0,
  );
  let $ = $wand.cast(
    test_wand,
    0,
    new $vec3.Vec3(0.0, 0.0, 0.0),
    new $vec3.Vec3(1.0, 0.0, 0.0),
    0,
    new $option.None(),
    new $option.None(),
    toList([]),
  );
  let result;
  result = $[0];
  let total_recharge_time_addition;
  if (result instanceof $wand.CastSuccess) {
    total_recharge_time_addition = result.total_recharge_time_addition;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "recharge_modifier_test",
      44,
      "rapid_fire_reduces_recharge_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 1000,
        end: 1071,
        pattern_start: 1011,
        pattern_end: 1062
      }
    )
  }
  let $1 = $duration.milliseconds(-330);
  if (!(isEqual(total_recharge_time_addition, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "recharge_modifier_test",
      47,
      "rapid_fire_reduces_recharge_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: total_recharge_time_addition,
          start: 1146,
          end: 1174
        },
        right: { kind: "expression", value: $1, start: 1178, end: 1205 },
        start: 1139,
        end: 1205,
        expression_start: 1146
      }
    )
  }
  return undefined;
}

/**
 * Test: Multiple modifiers should accumulate recharge additions
 */
export function multiple_modifiers_accumulate_recharge_test() {
  let custom_modifier = new $spell.ModifierSpell(
    new $spell.AddDamage(),
    "",
    (() => {
      let _record = $spell.default_modifier("Test Modifier", "test.png");
      return new $spell.Modifier(
        _record.name,
        _record.mana_cost,
        _record.damage_multiplier,
        _record.damage_addition,
        _record.projectile_speed_multiplier,
        _record.projectile_speed_addition,
        _record.projectile_size_multiplier,
        _record.projectile_size_addition,
        _record.projectile_lifetime_multiplier,
        _record.projectile_lifetime_addition,
        _record.cast_delay_multiplier,
        _record.cast_delay_addition,
        _record.recharge_multiplier,
        $duration.milliseconds(500),
        _record.critical_chance_multiplier,
        _record.critical_chance_addition,
        _record.spread_multiplier,
        _record.spread_addition,
        _record.ui_sprite,
        _record.adds_trigger,
        _record.visual_tint,
      );
    })(),
  );
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some(custom_modifier));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.rapid_fire()));
  _block = $iv.append(_pipe$2, new $option.Some($spell.spark()));
  let slots = _block;
  let test_wand = new $wand.Wand(
    "Test Wand",
    slots,
    100.0,
    100.0,
    30.0,
    $duration.milliseconds(200),
    $duration.milliseconds(500),
    1,
    0.0,
  );
  let $ = $wand.cast(
    test_wand,
    0,
    new $vec3.Vec3(0.0, 0.0, 0.0),
    new $vec3.Vec3(1.0, 0.0, 0.0),
    0,
    new $option.None(),
    new $option.None(),
    toList([]),
  );
  let result;
  result = $[0];
  let total_recharge_time_addition;
  if (result instanceof $wand.CastSuccess) {
    total_recharge_time_addition = result.total_recharge_time_addition;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "recharge_modifier_test",
      96,
      "multiple_modifiers_accumulate_recharge_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 2444,
        end: 2515,
        pattern_start: 2455,
        pattern_end: 2506
      }
    )
  }
  let $1 = $duration.approximate(total_recharge_time_addition);
  let $2 = [170, new $duration.Millisecond()];
  if (!(isEqual($1, $2))) {
    throw makeError(
      "assert",
      FILEPATH,
      "recharge_modifier_test",
      99,
      "multiple_modifiers_accumulate_recharge_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 2576, end: 2626 },
        right: { kind: "expression", value: $2, start: 2634, end: 2662 },
        start: 2569,
        end: 2662,
        expression_start: 2576
      }
    )
  }
  return undefined;
}

/**
 * Test: Recharge multiplier should multiply the accumulated recharge additions
 */
export function recharge_multiplier_test() {
  let multiplier_modifier = new $spell.ModifierSpell(
    new $spell.AddDamage(),
    "",
    (() => {
      let _record = $spell.default_modifier("Multiplier", "test.png");
      return new $spell.Modifier(
        _record.name,
        _record.mana_cost,
        _record.damage_multiplier,
        _record.damage_addition,
        _record.projectile_speed_multiplier,
        _record.projectile_speed_addition,
        _record.projectile_size_multiplier,
        _record.projectile_size_addition,
        _record.projectile_lifetime_multiplier,
        _record.projectile_lifetime_addition,
        _record.cast_delay_multiplier,
        _record.cast_delay_addition,
        2.0,
        $duration.seconds(1),
        _record.critical_chance_multiplier,
        _record.critical_chance_addition,
        _record.spread_multiplier,
        _record.spread_addition,
        _record.ui_sprite,
        _record.adds_trigger,
        _record.visual_tint,
      );
    })(),
  );
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some(multiplier_modifier));
  _block = $iv.append(_pipe$1, new $option.Some($spell.spark()));
  let slots = _block;
  let test_wand = new $wand.Wand(
    "Test Wand",
    slots,
    100.0,
    100.0,
    30.0,
    $duration.milliseconds(200),
    $duration.milliseconds(500),
    1,
    0.0,
  );
  let $ = $wand.cast(
    test_wand,
    0,
    new $vec3.Vec3(0.0, 0.0, 0.0),
    new $vec3.Vec3(1.0, 0.0, 0.0),
    0,
    new $option.None(),
    new $option.None(),
    toList([]),
  );
  let result;
  result = $[0];
  let total_recharge_time_addition;
  if (result instanceof $wand.CastSuccess) {
    total_recharge_time_addition = result.total_recharge_time_addition;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "recharge_modifier_test",
      149,
      "recharge_multiplier_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 3844,
        end: 3915,
        pattern_start: 3855,
        pattern_end: 3906
      }
    )
  }
  let $1 = $duration.approximate(total_recharge_time_addition);
  let $2 = [2, new $duration.Second()];
  if (!(isEqual($1, $2))) {
    throw makeError(
      "assert",
      FILEPATH,
      "recharge_modifier_test",
      151,
      "recharge_multiplier_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 3926, end: 3976 },
        right: { kind: "expression", value: $2, start: 3984, end: 4005 },
        start: 3919,
        end: 4005,
        expression_start: 3926
      }
    )
  }
  return undefined;
}

/**
 * Test: Modified spell should contain final_recharge_time
 */
export function modified_spell_includes_recharge_time_test() {
  let spark_spell = $spell.spark();
  let spark_id;
  let ui_sprite;
  let spark_damage;
  if (spark_spell instanceof $spell.DamageSpell) {
    spark_id = spark_spell.id;
    ui_sprite = spark_spell.ui_sprite;
    spark_damage = spark_spell.kind;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "recharge_modifier_test",
      159,
      "modified_spell_includes_recharge_time_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: spark_spell,
        start: 4160,
        end: 4275,
        pattern_start: 4171,
        pattern_end: 4261
      }
    )
  }
  let _block;
  let _record = $spell.default_modifier("Test", "test.png");
  _block = new $spell.Modifier(
    _record.name,
    _record.mana_cost,
    _record.damage_multiplier,
    _record.damage_addition,
    _record.projectile_speed_multiplier,
    _record.projectile_speed_addition,
    _record.projectile_size_multiplier,
    _record.projectile_size_addition,
    _record.projectile_lifetime_multiplier,
    _record.projectile_lifetime_addition,
    _record.cast_delay_multiplier,
    _record.cast_delay_addition,
    2.0,
    $duration.milliseconds(500),
    _record.critical_chance_multiplier,
    _record.critical_chance_addition,
    _record.spread_multiplier,
    _record.spread_addition,
    _record.ui_sprite,
    _record.adds_trigger,
    _record.visual_tint,
  );
  let modifier = _block;
  let _block$1;
  let _pipe = $iv.new$();
  _block$1 = $iv.append(_pipe, modifier);
  let modifiers = _block$1;
  let modified = $spell.apply_modifiers(
    spark_id,
    ui_sprite,
    spark_damage,
    modifiers,
  );
  let $ = $duration.approximate(modified.final_recharge_time);
  let $1 = [1, new $duration.Second()];
  if (!(isEqual($, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "recharge_modifier_test",
      180,
      "modified_spell_includes_recharge_time_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $, start: 4743, end: 4793 },
        right: { kind: "expression", value: $1, start: 4801, end: 4822 },
        start: 4736,
        end: 4822,
        expression_start: 4743
      }
    )
  }
  return undefined;
}
