import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $set from "../../../gleam_stdlib/gleam/set.mjs";
import * as $bag from "../../../tote/tote/bag.mjs";
import * as $spell from "../../client/magic_system/spell.mjs";
import * as $wand from "../../client/magic_system/wand.mjs";
import { Ok, Error, CustomType as $CustomType } from "../../gleam.mjs";

class SpellBag extends $CustomType {
  constructor(spells) {
    super();
    this.spells = spells;
  }
}

export class SpellNotFound extends $CustomType {}
export const TransferError$SpellNotFound = () => new SpellNotFound();
export const TransferError$isSpellNotFound = (value) =>
  value instanceof SpellNotFound;

export class InvalidSlot extends $CustomType {}
export const TransferError$InvalidSlot = () => new InvalidSlot();
export const TransferError$isInvalidSlot = (value) =>
  value instanceof InvalidSlot;

export function new$() {
  return new SpellBag($bag.new$());
}

export function add_spell(bag, spell) {
  let spells = $bag.insert(bag.spells, 1, spell);
  return new SpellBag(spells);
}

export function add_spells(bag, spell, count) {
  let spells = $bag.insert(bag.spells, count, spell);
  return new SpellBag(spells);
}

export function remove_spell(bag, spell) {
  let new_spells = $bag.remove(bag.spells, 1, spell);
  return new SpellBag(new_spells);
}

export function get_count(bag, spell) {
  return $bag.copies(bag.spells, spell);
}

export function has_spell(bag, spell) {
  return $bag.contains(bag.spells, spell);
}

/**
 * Get all unique spells in the bag
 */
export function list_spells(bag) {
  let _pipe = bag.spells;
  let _pipe$1 = $bag.to_list(_pipe);
  return $list.map(
    _pipe$1,
    (spell_and_count) => {
      let spell;
      spell = spell_and_count[0];
      return spell;
    },
  );
}

/**
 * Get all spell stacks (spell + count)
 */
export function list_spell_stacks(bag) {
  let _pipe = bag.spells;
  return $bag.to_list(_pipe);
}

/**
 * Get the total number of spell instances (including duplicates)
 */
export function total_spell_count(bag) {
  let _pipe = bag.spells;
  return $bag.size(_pipe);
}

/**
 * Get the number of unique spells in the bag
 */
export function unique_spell_count(bag) {
  let _pipe = bag.spells;
  let _pipe$1 = $bag.to_set(_pipe);
  return $set.size(_pipe$1);
}

export function transfer_to_wand(bag, spell, wand, slot_index) {
  let new_bag = remove_spell(bag, spell);
  let $ = $wand.set_spell(wand, slot_index, spell);
  if ($ instanceof Ok) {
    let new_wand = $[0];
    return new Ok([new_bag, new_wand]);
  } else {
    return new Error(new InvalidSlot());
  }
}
