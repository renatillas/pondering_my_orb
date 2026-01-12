import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $duration from "../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../iv/iv.mjs";
import * as $vec3 from "../vec/vec/vec3.mjs";
import * as $spell from "./client/magic_system/spell.mjs";
import * as $wand from "./client/magic_system/wand.mjs";
import { toList, makeError, isEqual } from "./gleam.mjs";

const FILEPATH = "test/rapid_fire_test.gleam";

/**
 * Test: Verify Rapid Fire's cast_delay_addition value
 */
export function rapid_fire_has_negative_cast_delay_addition_test() {
  let rapid_fire = $spell.rapid_fire();
  let modifier;
  if (rapid_fire instanceof $spell.ModifierSpell) {
    modifier = rapid_fire.kind;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      12,
      "rapid_fire_has_negative_cast_delay_addition_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: rapid_fire,
        start: 296,
        end: 359,
        pattern_start: 307,
        pattern_end: 346
      }
    )
  }
  let $ = modifier.cast_delay_addition;
  let $1 = $duration.milliseconds(-170);
  if (!(isEqual($, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      15,
      "rapid_fire_has_negative_cast_delay_addition_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $, start: 425, end: 453 },
        right: { kind: "expression", value: $1, start: 457, end: 484 },
        start: 418,
        end: 484,
        expression_start: 425
      }
    )
  }
  return undefined;
}

/**
 * Test: Spark's base cast_delay_addition
 */
export function spark_has_positive_cast_delay_addition_test() {
  let spark = $spell.spark();
  let damage_spell;
  if (spark instanceof $spell.DamageSpell) {
    damage_spell = spark.kind;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      22,
      "spark_has_positive_cast_delay_addition_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: spark,
        start: 617,
        end: 677,
        pattern_start: 628,
        pattern_end: 669
      }
    )
  }
  let $ = damage_spell.cast_delay_addition;
  let $1 = $duration.milliseconds(50);
  if (!(isEqual($, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      25,
      "spark_has_positive_cast_delay_addition_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $, start: 729, end: 761 },
        right: { kind: "expression", value: $1, start: 765, end: 790 },
        start: 722,
        end: 790,
        expression_start: 729
      }
    )
  }
  return undefined;
}

/**
 * Test: apply_modifiers correctly applies cast_delay_addition
 */
export function apply_modifiers_reduces_cast_delay_test() {
  let spark = $spell.spark();
  let spark_id;
  let spark_damage;
  if (spark instanceof $spell.DamageSpell) {
    spark_id = spark.id;
    spark_damage = spark.kind;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      32,
      "apply_modifiers_reduces_cast_delay_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: spark,
        start: 940,
        end: 1014,
        pattern_start: 951,
        pattern_end: 1006
      }
    )
  }
  let $ = $spell.rapid_fire();
  let rapid_fire_mod;
  if ($ instanceof $spell.ModifierSpell) {
    rapid_fire_mod = $.kind;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      33,
      "apply_modifiers_reduces_cast_delay_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1017,
        end: 1094,
        pattern_start: 1028,
        pattern_end: 1073
      }
    )
  }
  let _block;
  let _pipe = $iv.new$();
  _block = $iv.append(_pipe, rapid_fire_mod);
  let modifiers = _block;
  let modified = $spell.apply_modifiers(
    spark_id,
    spark.ui_sprite,
    spark_damage,
    modifiers,
  );
  let $1 = modified.final_cast_delay;
  let $2 = $duration.milliseconds(-120);
  if (!(isEqual($1, $2))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      42,
      "apply_modifiers_reduces_cast_delay_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 1309, end: 1334 },
        right: { kind: "expression", value: $2, start: 1338, end: 1365 },
        start: 1302,
        end: 1365,
        expression_start: 1309
      }
    )
  }
  return undefined;
}

/**
 * Test: wand.cast returns correct total_cast_delay_addition with Rapid Fire
 */
export function wand_cast_with_rapid_fire_reduces_cast_delay_test() {
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
    $duration.milliseconds(100),
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
  let total_cast_delay_addition;
  if (result instanceof $wand.CastSuccess) {
    total_cast_delay_addition = result.total_cast_delay_addition;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      78,
      "wand_cast_with_rapid_fire_reduces_cast_delay_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 2167,
        end: 2235,
        pattern_start: 2178,
        pattern_end: 2226
      }
    )
  }
  let $1 = $duration.milliseconds(-120);
  if (!(isEqual(total_cast_delay_addition, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      80,
      "wand_cast_with_rapid_fire_reduces_cast_delay_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: total_cast_delay_addition,
          start: 2246,
          end: 2271
        },
        right: { kind: "expression", value: $1, start: 2275, end: 2302 },
        start: 2239,
        end: 2302,
        expression_start: 2246
      }
    )
  }
  return undefined;
}

/**
 * Test: duration.add with negative values
 */
export function duration_add_negative_test() {
  let base = $duration.milliseconds(100);
  let negative = $duration.milliseconds(-120);
  let result = $duration.add(base, negative);
  let $ = $duration.milliseconds(-20);
  if (!(isEqual(result, $))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      89,
      "duration_add_negative_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: result, start: 2527, end: 2533 },
        right: { kind: "expression", value: $, start: 2537, end: 2563 },
        start: 2520,
        end: 2563,
        expression_start: 2527
      }
    )
  }
  return undefined;
}

/**
 * Test: Verify the final cooldown calculation matches player logic
 */
export function final_cooldown_calculation_test() {
  let wand_cast_delay = $duration.milliseconds(150);
  let wand_recharge_time = $duration.milliseconds(330);
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
    wand_cast_delay,
    wand_recharge_time,
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
  let wrapped;
  let delay;
  let recharge_addition;
  if (result instanceof $wand.CastSuccess) {
    wrapped = result.did_wrap;
    delay = result.total_cast_delay_addition;
    recharge_addition = result.total_recharge_time_addition;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      129,
      "final_cooldown_calculation_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 3462,
        end: 3625,
        pattern_start: 3473,
        pattern_end: 3616
      }
    )
  }
  let total_delay = $duration.add(wand_cast_delay, delay);
  let _block$1;
  if (wrapped) {
    let recharge = $duration.add(wand_recharge_time, recharge_addition);
    _block$1 = $duration.add(total_delay, recharge);
  } else {
    _block$1 = total_delay;
  }
  let final_cooldown = _block$1;
  let $1 = $duration.milliseconds(30);
  if (!(isEqual(final_cooldown, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      149,
      "final_cooldown_calculation_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: final_cooldown,
          start: 4053,
          end: 4067
        },
        right: { kind: "expression", value: $1, start: 4071, end: 4096 },
        start: 4046,
        end: 4096,
        expression_start: 4053
      }
    )
  }
  return undefined;
}

/**
 * Test: Subsequent casts with 4 slots (2 filled, 2 empty)
 */
export function subsequent_casts_with_empty_slots_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.rapid_fire()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.spark()));
  let _pipe$3 = $iv.append(_pipe$2, new $option.None());
  _block = $iv.append(_pipe$3, new $option.None());
  let slots = _block;
  let test_wand = new $wand.Wand(
    "Test Wand",
    slots,
    100.0,
    100.0,
    30.0,
    $duration.milliseconds(150),
    $duration.milliseconds(330),
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
  let result1;
  let wand1;
  result1 = $[0];
  wand1 = $[1];
  let next_index1;
  if (result1 instanceof $wand.CastSuccess) {
    next_index1 = result1.next_cast_index;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      188,
      "subsequent_casts_with_empty_slots_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result1,
        start: 4974,
        end: 5109,
        pattern_start: 4985,
        pattern_end: 5099
      }
    )
  }
  let $1 = $wand.cast(
    wand1,
    next_index1,
    new $vec3.Vec3(0.0, 0.0, 0.0),
    new $vec3.Vec3(1.0, 0.0, 0.0),
    1,
    new $option.None(),
    new $option.None(),
    toList([]),
  );
  let result2;
  result2 = $1[0];
  let delay2;
  if (result2 instanceof $wand.CastSuccess) {
    delay2 = result2.total_cast_delay_addition;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      208,
      "subsequent_casts_with_empty_slots_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result2,
        start: 5360,
        end: 5490,
        pattern_start: 5371,
        pattern_end: 5480
      }
    )
  }
  let $2 = $duration.milliseconds(-120);
  if (!(isEqual(delay2, $2))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      217,
      "subsequent_casts_with_empty_slots_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: delay2, start: 5612, end: 5618 },
        right: { kind: "expression", value: $2, start: 5622, end: 5649 },
        start: 5605,
        end: 5649,
        expression_start: 5612
      }
    )
  }
  return undefined;
}

/**
 * Test: Multiple Rapid Fire modifiers stack
 */
export function multiple_rapid_fire_stack_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.rapid_fire()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.rapid_fire()));
  _block = $iv.append(_pipe$2, new $option.Some($spell.spark()));
  let slots = _block;
  let test_wand = new $wand.Wand(
    "Test Wand",
    slots,
    100.0,
    100.0,
    30.0,
    $duration.milliseconds(100),
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
  let total_cast_delay_addition;
  if (result instanceof $wand.CastSuccess) {
    total_cast_delay_addition = result.total_cast_delay_addition;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "rapid_fire_test",
      254,
      "multiple_rapid_fire_stack_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 6462,
        end: 6530,
        pattern_start: 6473,
        pattern_end: 6521
      }
    )
  }
  let $1 = $duration.milliseconds(-290);
  if (!(isEqual(total_cast_delay_addition, $1))) {
    throw makeError(
      "assert",
      FILEPATH,
      "rapid_fire_test",
      258,
      "multiple_rapid_fire_stack_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: total_cast_delay_addition,
          start: 6595,
          end: 6620
        },
        right: { kind: "expression", value: $1, start: 6624, end: 6651 },
        start: 6588,
        end: 6651,
        expression_start: 6595
      }
    )
  }
  return undefined;
}
