import gleam/list
import gleam/set
import pondering_my_orb/spell
import pondering_my_orb/wand
import tote/bag

pub opaque type SpellBag {
  SpellBag(spells: bag.Bag(spell.Spell))
}

pub type AddResult {
  Added(new_count: Int)
  StackLimitReached
}

pub type RemoveError {
  NotFound
}

pub fn new() -> SpellBag {
  SpellBag(spells: bag.new())
}

pub fn add_spell(bag: SpellBag, spell: spell.Spell) -> SpellBag {
  let spells = bag.insert(into: bag.spells, copies: 1, of: spell)
  SpellBag(spells:)
}

pub fn add_spells(bag: SpellBag, spell: spell.Spell, count: Int) -> SpellBag {
  let spells = bag.insert(into: bag.spells, copies: count, of: spell)
  SpellBag(spells:)
}

pub fn remove_spell(bag: SpellBag, spell: spell.Spell) {
  bag.remove(from: bag.spells, copies: 1, of: spell)
}

pub fn get_count(bag: SpellBag, spell: spell.Spell) -> Int {
  bag.copies(in: bag.spells, of: spell)
}

pub fn has_spell(bag: SpellBag, spell: spell.Spell) -> Bool {
  bag.contains(bag.spells, spell)
}

/// Get all unique spells in the bag
pub fn list_spells(bag: SpellBag) -> List(spell.Spell) {
  bag.spells
  |> bag.to_list
  |> list.map(fn(spell_and_count) {
    let #(spell, _) = spell_and_count
    spell
  })
}

/// Get all spell stacks (spell + count)
pub fn list_spell_stacks(bag: SpellBag) -> List(#(spell.Spell, Int)) {
  bag.spells
  |> bag.to_list
}

/// Get the total number of spell instances (including duplicates)
pub fn total_spell_count(bag: SpellBag) -> Int {
  bag.spells
  |> bag.size()
}

/// Get the number of unique spells in the bag
pub fn unique_spell_count(bag: SpellBag) -> Int {
  bag.spells |> bag.to_set() |> set.size()
}

/// Transfer a spell from the bag to a wand slot
pub fn transfer_to_wand(
  bag: SpellBag,
  spell: spell.Spell,
  wand: wand.Wand,
  slot_index: Int,
) -> Result(#(SpellBag, wand.Wand), TransferError) {
  // Check if we have the spell
  let new_bag = remove_spell(bag, spell)
  // Try to add to wand
  case wand.set_spell(wand, slot_index, spell) {
    Ok(new_wand) -> Ok(#(SpellBag(new_bag), new_wand))
    Error(Nil) -> {
      // Failed to add to wand, return spell to bag
      Error(InvalidSlot)
    }
  }
}

/// Transfer errors
pub type TransferError {
  SpellNotFound
  InvalidSlot
}
