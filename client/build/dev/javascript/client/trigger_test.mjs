import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $duration from "../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../iv/iv.mjs";
import * as $vec3 from "../vec/vec/vec3.mjs";
import * as $spell from "./client/magic_system/spell.mjs";
import * as $wand from "./client/magic_system/wand.mjs";
import { toList, Empty as $Empty, makeError, isEqual } from "./gleam.mjs";

const FILEPATH = "test/trigger_test.gleam";

/**
 * Test: Spark with trigger should have trigger payload after casting
 */
export function spark_with_trigger_has_payload_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.spark_with_trigger()));
  _block = $iv.append(_pipe$1, new $option.Some($spell.fireball()));
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
  let projectiles;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      44,
      "spark_with_trigger_has_payload_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 1045,
        end: 1111,
        pattern_start: 1056,
        pattern_end: 1102
      }
    )
  }
  let projectile;
  if (projectiles instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      47,
      "spark_with_trigger_has_payload_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: projectiles,
        start: 1170,
        end: 1207,
        pattern_start: 1181,
        pattern_end: 1193
      }
    )
  } else {
    let $1 = projectiles.tail;
    if ($1 instanceof $Empty) {
      projectile = projectiles.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "trigger_test",
        47,
        "spark_with_trigger_has_payload_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: projectiles,
          start: 1170,
          end: 1207,
          pattern_start: 1181,
          pattern_end: 1193
        }
      )
    }
  }
  let $2 = projectile.trigger_payload;
  if (!$option.is_some($2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      50,
      "spark_with_trigger_has_payload_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [{ kind: "expression", value: $2, start: 1268, end: 1294 }],
        start: 1246,
        end: 1295,
        expression_start: 1253
      }
    )
  }
  return undefined;
}

/**
 * Test: Add Trigger modifier should add trigger to next damage spell
 */
export function add_trigger_modifier_adds_trigger_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.add_trigger()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.spark()));
  _block = $iv.append(_pipe$2, new $option.Some($spell.fireball()));
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
  let projectiles;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      88,
      "add_trigger_modifier_adds_trigger_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 2216,
        end: 2282,
        pattern_start: 2227,
        pattern_end: 2273
      }
    )
  }
  let projectile;
  if (projectiles instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      91,
      "add_trigger_modifier_adds_trigger_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: projectiles,
        start: 2343,
        end: 2380,
        pattern_start: 2354,
        pattern_end: 2366
      }
    )
  } else {
    let $1 = projectiles.tail;
    if ($1 instanceof $Empty) {
      projectile = projectiles.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "trigger_test",
        91,
        "add_trigger_modifier_adds_trigger_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: projectiles,
          start: 2343,
          end: 2380,
          pattern_start: 2354,
          pattern_end: 2366
        }
      )
    }
  }
  let $2 = projectile.trigger_payload;
  if (!$option.is_some($2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      94,
      "add_trigger_modifier_adds_trigger_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [{ kind: "expression", value: $2, start: 2471, end: 2497 }],
        start: 2449,
        end: 2498,
        expression_start: 2456
      }
    )
  }
  return undefined;
}

/**
 * Test: Triggered projectile with payload has correct structure
 */
export function triggered_projectile_structure_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.spark_with_trigger()));
  _block = $iv.append(_pipe$1, new $option.Some($spell.fireball()));
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
  let projectiles;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      131,
      "triggered_projectile_structure_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 3338,
        end: 3404,
        pattern_start: 3349,
        pattern_end: 3395
      }
    )
  }
  let projectile;
  if (projectiles instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      134,
      "triggered_projectile_structure_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: projectiles,
        start: 3448,
        end: 3485,
        pattern_start: 3459,
        pattern_end: 3471
      }
    )
  } else {
    let $1 = projectiles.tail;
    if ($1 instanceof $Empty) {
      projectile = projectiles.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "trigger_test",
        134,
        "triggered_projectile_structure_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: projectiles,
          start: 3448,
          end: 3485,
          pattern_start: 3459,
          pattern_end: 3471
        }
      )
    }
  }
  let $2 = projectile.trigger_payload;
  let payload;
  if ($2 instanceof $option.Some) {
    payload = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      137,
      "triggered_projectile_structure_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 3565,
        end: 3625,
        pattern_start: 3576,
        pattern_end: 3596
      }
    )
  }
  let $3 = payload.final_damage;
  let $4 = 5.0;
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      138,
      "triggered_projectile_structure_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 3635, end: 3655 },
        right: { kind: "literal", value: $4, start: 3659, end: 3662 },
        start: 3628,
        end: 3662,
        expression_start: 3635
      }
    )
  }
  return undefined;
}

/**
 * Test: Trigger without payload spell doesn't crash
 */
export function trigger_without_payload_doesnt_crash_test() {
  let _block;
  let _pipe = $iv.new$();
  _block = $iv.append(_pipe, new $option.Some($spell.spark_with_trigger()));
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
  let projectiles;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      174,
      "trigger_without_payload_doesnt_crash_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 4492,
        end: 4558,
        pattern_start: 4503,
        pattern_end: 4549
      }
    )
  }
  let projectile;
  if (projectiles instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      177,
      "trigger_without_payload_doesnt_crash_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: projectiles,
        start: 4592,
        end: 4629,
        pattern_start: 4603,
        pattern_end: 4615
      }
    )
  } else {
    let $1 = projectiles.tail;
    if ($1 instanceof $Empty) {
      projectile = projectiles.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "trigger_test",
        177,
        "trigger_without_payload_doesnt_crash_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: projectiles,
          start: 4592,
          end: 4629,
          pattern_start: 4603,
          pattern_end: 4615
        }
      )
    }
  }
  let $2 = projectile.trigger_payload;
  if (!$option.is_none($2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      180,
      "trigger_without_payload_doesnt_crash_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [{ kind: "expression", value: $2, start: 4714, end: 4740 }],
        start: 4692,
        end: 4741,
        expression_start: 4699
      }
    )
  }
  return undefined;
}

/**
 * Test: Payload spell is consumed and not cast separately
 */
export function trigger_consumes_payload_spell_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.spark_with_trigger()));
  _block = $iv.append(_pipe$1, new $option.Some($spell.fireball()));
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
  let projectiles;
  let next_cast_index;
  let casting_indices;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
    next_cast_index = result.next_cast_index;
    casting_indices = result.casting_indices;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      218,
      "trigger_consumes_payload_spell_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 5651,
        end: 5806,
        pattern_start: 5662,
        pattern_end: 5797
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 1;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      227,
      "trigger_consumes_payload_spell_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 5931, end: 5955 },
        right: { kind: "literal", value: $2, start: 5959, end: 5960 },
        start: 5924,
        end: 5960,
        expression_start: 5931
      }
    )
  }
  let $3 = 0;
  if (!(next_cast_index === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      231,
      "trigger_consumes_payload_spell_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: next_cast_index,
          start: 6105,
          end: 6120
        },
        right: { kind: "literal", value: $3, start: 6124, end: 6125 },
        start: 6098,
        end: 6125,
        expression_start: 6105
      }
    )
  }
  let sorted_indices = $list.sort(casting_indices, $int.compare);
  let $4 = toList([0, 1]);
  if (!(isEqual(sorted_indices, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      235,
      "trigger_consumes_payload_spell_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: sorted_indices,
          start: 6277,
          end: 6291
        },
        right: { kind: "literal", value: $4, start: 6295, end: 6301 },
        start: 6270,
        end: 6301,
        expression_start: 6277
      }
    )
  }
  return undefined;
}

/**
 * Test: Add Trigger with modifiers between it and the damage spell
 */
export function add_trigger_with_modifiers_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.add_trigger()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.add_damage()));
  let _pipe$3 = $iv.append(_pipe$2, new $option.Some($spell.spark()));
  _block = $iv.append(_pipe$3, new $option.Some($spell.fireball()));
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
  let projectiles;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      274,
      "add_trigger_with_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 7273,
        end: 7339,
        pattern_start: 7284,
        pattern_end: 7330
      }
    )
  }
  let projectile;
  if (projectiles instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      275,
      "add_trigger_with_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: projectiles,
        start: 7342,
        end: 7379,
        pattern_start: 7353,
        pattern_end: 7365
      }
    )
  } else {
    let $1 = projectiles.tail;
    if ($1 instanceof $Empty) {
      projectile = projectiles.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "trigger_test",
        275,
        "add_trigger_with_modifiers_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: projectiles,
          start: 7342,
          end: 7379,
          pattern_start: 7353,
          pattern_end: 7365
        }
      )
    }
  }
  let $2 = projectile.spell.final_damage;
  let $3 = 13.0;
  if (!($2 === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      279,
      "add_trigger_with_modifiers_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 7506, end: 7535 },
        right: { kind: "literal", value: $3, start: 7539, end: 7543 },
        start: 7499,
        end: 7543,
        expression_start: 7506
      }
    )
  }
  let $4 = projectile.trigger_payload;
  if (!$option.is_some($4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      282,
      "add_trigger_with_modifiers_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [{ kind: "expression", value: $4, start: 7602, end: 7628 }],
        start: 7580,
        end: 7629,
        expression_start: 7587
      }
    )
  }
  return undefined;
}

/**
 * Test: Trigger with modifiers between trigger and payload
 */
export function trigger_with_intermediate_modifiers_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.spark_with_trigger()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.add_damage()));
  _block = $iv.append(_pipe$2, new $option.Some($spell.fireball()));
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
  let projectiles;
  let casting_indices;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
    casting_indices = result.casting_indices;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      321,
      "trigger_with_intermediate_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 8605,
        end: 8722,
        pattern_start: 8616,
        pattern_end: 8713
      }
    )
  }
  let projectile;
  if (projectiles instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      328,
      "trigger_with_intermediate_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: projectiles,
        start: 8782,
        end: 8819,
        pattern_start: 8793,
        pattern_end: 8805
      }
    )
  } else {
    let $1 = projectiles.tail;
    if ($1 instanceof $Empty) {
      projectile = projectiles.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "trigger_test",
        328,
        "trigger_with_intermediate_modifiers_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: projectiles,
          start: 8782,
          end: 8819,
          pattern_start: 8793,
          pattern_end: 8805
        }
      )
    }
  }
  let sorted_indices = $list.sort(casting_indices, $int.compare);
  let $2 = toList([0, 1, 2]);
  if (!(isEqual(sorted_indices, $2))) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      332,
      "trigger_with_intermediate_modifiers_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: sorted_indices,
          start: 8964,
          end: 8978
        },
        right: { kind: "literal", value: $2, start: 8982, end: 8991 },
        start: 8957,
        end: 8991,
        expression_start: 8964
      }
    )
  }
  let $3 = projectile.trigger_payload;
  let payload;
  if ($3 instanceof $option.Some) {
    payload = $3[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      337,
      "trigger_with_intermediate_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $3,
        start: 9139,
        end: 9199,
        pattern_start: 9150,
        pattern_end: 9170
      }
    )
  }
  let $4 = payload.final_damage;
  let $5 = 15.0;
  if (!($4 === $5)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      338,
      "trigger_with_intermediate_modifiers_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 9209, end: 9229 },
        right: { kind: "literal", value: $5, start: 9233, end: 9237 },
        start: 9202,
        end: 9237,
        expression_start: 9209
      }
    )
  }
  return undefined;
}

/**
 * Test: Multiple modifiers applied to payload
 */
export function trigger_multiple_payload_modifiers_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.spark_with_trigger()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.add_mana()));
  let _pipe$3 = $iv.append(_pipe$2, new $option.Some($spell.add_damage()));
  _block = $iv.append(_pipe$3, new $option.Some($spell.fireball()));
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
  let projectiles;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      377,
      "trigger_multiple_payload_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 10206,
        end: 10272,
        pattern_start: 10217,
        pattern_end: 10263
      }
    )
  }
  let projectile;
  if (projectiles instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      378,
      "trigger_multiple_payload_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: projectiles,
        start: 10275,
        end: 10312,
        pattern_start: 10286,
        pattern_end: 10298
      }
    )
  } else {
    let $1 = projectiles.tail;
    if ($1 instanceof $Empty) {
      projectile = projectiles.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "trigger_test",
        378,
        "trigger_multiple_payload_modifiers_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: projectiles,
          start: 10275,
          end: 10312,
          pattern_start: 10286,
          pattern_end: 10298
        }
      )
    }
  }
  let $2 = projectile.trigger_payload;
  let payload;
  if ($2 instanceof $option.Some) {
    payload = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "trigger_test",
      379,
      "trigger_multiple_payload_modifiers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 10315,
        end: 10375,
        pattern_start: 10326,
        pattern_end: 10346
      }
    )
  }
  let $3 = payload.final_damage;
  let $4 = 15.0;
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      382,
      "trigger_multiple_payload_modifiers_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 10442, end: 10462 },
        right: { kind: "literal", value: $4, start: 10466, end: 10470 },
        start: 10435,
        end: 10470,
        expression_start: 10442
      }
    )
  }
  let $5 = payload.total_mana_cost;
  let $6 = -15.0;
  if (!($5 === $6)) {
    throw makeError(
      "assert",
      FILEPATH,
      "trigger_test",
      385,
      "trigger_multiple_payload_modifiers_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $5, start: 10536, end: 10559 },
        right: { kind: "literal", value: $6, start: 10563, end: 10568 },
        start: 10529,
        end: 10568,
        expression_start: 10536
      }
    )
  }
  return undefined;
}
