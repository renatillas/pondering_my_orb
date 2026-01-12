import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $duration from "../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../iv/iv.mjs";
import * as $vec3 from "../vec/vec/vec3.mjs";
import * as $spell from "./client/magic_system/spell.mjs";
import * as $wand from "./client/magic_system/wand.mjs";
import { toList, makeError, isEqual } from "./gleam.mjs";

const FILEPATH = "test/double_spell_test.gleam";

/**
 * Test: Double spell with 2 fireballs should cast both
 */
export function double_spell_casts_two_spells_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.double_spell()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.fireball()));
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
      "double_spell_test",
      45,
      "double_spell_casts_two_spells_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 1080,
        end: 1197,
        pattern_start: 1091,
        pattern_end: 1188
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 2;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      52,
      "double_spell_casts_two_spells_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 1239, end: 1263 },
        right: { kind: "literal", value: $2, start: 1267, end: 1268 },
        start: 1232,
        end: 1268,
        expression_start: 1239
      }
    )
  }
  let $3 = $list.reverse(casting_indices);
  let $4 = toList([0, 1, 2]);
  if (!(isEqual($3, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      56,
      "double_spell_casts_two_spells_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 1387, end: 1416 },
        right: { kind: "literal", value: $4, start: 1420, end: 1429 },
        start: 1380,
        end: 1429,
        expression_start: 1387
      }
    )
  }
  return undefined;
}

/**
 * Test: Double spell with only 1 spell after it should cast that 1 spell
 */
export function double_spell_with_one_spell_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.double_spell()));
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
  let casting_indices;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
    casting_indices = result.casting_indices;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "double_spell_test",
      93,
      "double_spell_with_one_spell_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 2272,
        end: 2389,
        pattern_start: 2283,
        pattern_end: 2380
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 1;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      100,
      "double_spell_with_one_spell_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 2430, end: 2454 },
        right: { kind: "literal", value: $2, start: 2458, end: 2459 },
        start: 2423,
        end: 2459,
        expression_start: 2430
      }
    )
  }
  let $3 = $list.reverse(casting_indices);
  let $4 = toList([0, 1]);
  if (!(isEqual($3, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      103,
      "double_spell_with_one_spell_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 2524, end: 2553 },
        right: { kind: "literal", value: $4, start: 2557, end: 2563 },
        start: 2517,
        end: 2563,
        expression_start: 2524
      }
    )
  }
  return undefined;
}

/**
 * Test: Double spell at end of wand with wrapping
 */
export function double_spell_wrapping_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.fireball()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.fireball()));
  _block = $iv.append(_pipe$2, new $option.Some($spell.double_spell()));
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
    2,
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
  let did_wrap;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
    next_cast_index = result.next_cast_index;
    casting_indices = result.casting_indices;
    did_wrap = result.did_wrap;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "double_spell_test",
      142,
      "double_spell_wrapping_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 3488,
        end: 3667,
        pattern_start: 3499,
        pattern_end: 3658
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 2;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      151,
      "double_spell_wrapping_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 3709, end: 3733 },
        right: { kind: "literal", value: $2, start: 3737, end: 3738 },
        start: 3702,
        end: 3738,
        expression_start: 3709
      }
    )
  }
  if (!(did_wrap === true)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      154,
      "double_spell_wrapping_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: did_wrap, start: 3780, end: 3788 },
        right: { kind: "literal", value: true, start: 3792, end: 3796 },
        start: 3773,
        end: 3796,
        expression_start: 3780
      }
    )
  }
  let $3 = 2;
  if (!(next_cast_index === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      157,
      "double_spell_wrapping_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: next_cast_index,
          start: 3860,
          end: 3875
        },
        right: { kind: "literal", value: $3, start: 3879, end: 3880 },
        start: 3853,
        end: 3880,
        expression_start: 3860
      }
    )
  }
  let $4 = $list.reverse(casting_indices);
  let $5 = toList([2, 0, 1]);
  if (!(isEqual($4, $5))) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      160,
      "double_spell_wrapping_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 3959, end: 3988 },
        right: { kind: "literal", value: $5, start: 3992, end: 4001 },
        start: 3952,
        end: 4001,
        expression_start: 3959
      }
    )
  }
  return undefined;
}

/**
 * Test: Multiple double spells in a row
 */
export function multiple_double_spells_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.double_spell()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.double_spell()));
  let _pipe$3 = $iv.append(_pipe$2, new $option.Some($spell.fireball()));
  let _pipe$4 = $iv.append(_pipe$3, new $option.Some($spell.fireball()));
  let _pipe$5 = $iv.append(_pipe$4, new $option.Some($spell.fireball()));
  _block = $iv.append(_pipe$5, new $option.Some($spell.fireball()));
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
      "double_spell_test",
      203,
      "multiple_double_spells_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 5137,
        end: 5254,
        pattern_start: 5148,
        pattern_end: 5245
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 3;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      213,
      "multiple_double_spells_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 5424, end: 5448 },
        right: { kind: "literal", value: $2, start: 5452, end: 5453 },
        start: 5417,
        end: 5453,
        expression_start: 5424
      }
    )
  }
  let $3 = $list.reverse(casting_indices);
  let $4 = toList([0, 1, 2, 3, 4]);
  if (!(isEqual($3, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      216,
      "multiple_double_spells_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 5552, end: 5581 },
        right: { kind: "literal", value: $4, start: 5585, end: 5600 },
        start: 5545,
        end: 5600,
        expression_start: 5552
      }
    )
  }
  return undefined;
}

/**
 * Test: Double spell with empty slot after it
 */
export function double_spell_with_empty_slot_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.double_spell()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.None());
  let _pipe$3 = $iv.append(_pipe$2, new $option.Some($spell.fireball()));
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
  let casting_indices;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
    casting_indices = result.casting_indices;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "double_spell_test",
      255,
      "double_spell_with_empty_slot_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 6520,
        end: 6637,
        pattern_start: 6531,
        pattern_end: 6628
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 2;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      262,
      "double_spell_with_empty_slot_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 6705, end: 6729 },
        right: { kind: "literal", value: $2, start: 6733, end: 6734 },
        start: 6698,
        end: 6734,
        expression_start: 6705
      }
    )
  }
  let $3 = $list.reverse(casting_indices);
  let $4 = toList([0, 1, 2, 3]);
  if (!(isEqual($3, $4))) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      265,
      "double_spell_with_empty_slot_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 6824, end: 6853 },
        right: { kind: "literal", value: $4, start: 6857, end: 6869 },
        start: 6817,
        end: 6869,
        expression_start: 6824
      }
    )
  }
  return undefined;
}

/**
 * Test: Double spell with modifier before damage spell
 */
export function double_spell_with_modifier_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.double_spell()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.Some($spell.add_mana()));
  let _pipe$3 = $iv.append(_pipe$2, new $option.Some($spell.fireball()));
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
  let remaining_mana;
  let casting_indices;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
    remaining_mana = result.remaining_mana;
    casting_indices = result.casting_indices;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "double_spell_test",
      304,
      "double_spell_with_modifier_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 7825,
        end: 7978,
        pattern_start: 7836,
        pattern_end: 7969
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 2;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      312,
      "double_spell_with_modifier_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 8020, end: 8044 },
        right: { kind: "literal", value: $2, start: 8048, end: 8049 },
        start: 8013,
        end: 8049,
        expression_start: 8020
      }
    )
  }
  let $3 = 130.0;
  if (!(remaining_mana === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      319,
      "double_spell_with_modifier_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: remaining_mana,
          start: 8315,
          end: 8329
        },
        right: { kind: "literal", value: $3, start: 8333, end: 8338 },
        start: 8308,
        end: 8338,
        expression_start: 8315
      }
    )
  }
  let $4 = $list.reverse(casting_indices);
  let $5 = toList([0, 1, 2, 3]);
  if (!(isEqual($4, $5))) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      322,
      "double_spell_with_modifier_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 8386, end: 8415 },
        right: { kind: "literal", value: $5, start: 8419, end: 8431 },
        start: 8379,
        end: 8431,
        expression_start: 8386
      }
    )
  }
  return undefined;
}

/**
 * Test: Double spell wrapping with partial spells available
 */
export function double_spell_wrapping_partial_test() {
  let _block;
  let _pipe = $iv.new$();
  let _pipe$1 = $iv.append(_pipe, new $option.Some($spell.fireball()));
  let _pipe$2 = $iv.append(_pipe$1, new $option.None());
  _block = $iv.append(_pipe$2, new $option.Some($spell.double_spell()));
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
    2,
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
  let did_wrap;
  if (result instanceof $wand.CastSuccess) {
    projectiles = result.projectiles;
    did_wrap = result.did_wrap;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "double_spell_test",
      361,
      "double_spell_wrapping_partial_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 9367,
        end: 9457,
        pattern_start: 9378,
        pattern_end: 9444
      }
    )
  }
  let $1 = $list.length(projectiles);
  let $2 = 1;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      365,
      "double_spell_wrapping_partial_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 9517, end: 9541 },
        right: { kind: "literal", value: $2, start: 9545, end: 9546 },
        start: 9510,
        end: 9546,
        expression_start: 9517
      }
    )
  }
  if (!(did_wrap === true)) {
    throw makeError(
      "assert",
      FILEPATH,
      "double_spell_test",
      368,
      "double_spell_wrapping_partial_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: did_wrap, start: 9574, end: 9582 },
        right: { kind: "literal", value: true, start: 9586, end: 9590 },
        start: 9567,
        end: 9590,
        expression_start: 9574
      }
    )
  }
  return undefined;
}
