/// Wand System - Handles spell casting with modifiers
/// Spells are cast from left to right, with modifiers affecting the next damaging spell
import gleam/float
import gleam/list
import gleam/option
import gleam/result
import iv
import pondering_my_orb/spell

/// Represents a wand with spell slots
pub type Wand {
  Wand(
    name: String,
    slots: iv.Array(option.Option(spell.Spell)),
    max_mana: Float,
    current_mana: Float,
    mana_recharge_rate: Float,
    cast_delay: Float,
    recharge_time: Float,
  )
}

/// Result of casting from a wand
pub type CastResult {
  /// Successfully cast a spell
  CastSuccess(
    projectile: spell.Projectile,
    remaining_mana: Float,
    next_cast_index: Int,
  )
  /// Not enough mana to cast
  NotEnoughMana(required: Float, available: Float)
  /// No damaging spell found (all modifiers)
  NoSpellToCast
  /// Reached end of wand
  WandEmpty
}

/// Create a new wand
pub fn new(
  name name: String,
  slot_count slot_count: Int,
  max_mana max_mana: Float,
  mana_recharge_rate mana_recharge_rate: Float,
  cast_delay cast_delay: Float,
  recharge_time recharge_time: Float,
) -> Wand {
  Wand(
    name: name,
    slots: iv.repeat(option.None, slot_count),
    max_mana: max_mana,
    current_mana: max_mana,
    mana_recharge_rate: mana_recharge_rate,
    cast_delay: cast_delay,
    recharge_time: recharge_time,
  )
}

/// Set a spell in a specific slot
pub fn set_spell(
  wand: Wand,
  slot_index: Int,
  spell: spell.Spell,
) -> Result(Wand, Nil) {
  use slots <- result.map(iv.insert(
    into: wand.slots,
    at: slot_index,
    this: option.Some(spell),
  ))
  Wand(..wand, slots:)
}

/// Remove a spell from a specific slot
pub fn remove_spell(wand: Wand, slot_index: Int) -> Result(Wand, Nil) {
  use slots <- result.map(iv.delete(from: wand.slots, at: slot_index))
  Wand(..wand, slots:)
}

/// Get a spell from a specific slot
pub fn get_spell(
  wand: Wand,
  slot_index: Int,
) -> Result(option.Option(spell.Spell), Nil) {
  wand.slots
  |> iv.get(slot_index)
}

/// Cast spells from the wand starting at a given index
/// Collects modifiers until a damaging spell is found, then applies them
pub fn cast(
  wand: Wand,
  start_index: Int,
  position: #(Float, Float, Float),
  direction: #(Float, Float, Float),
  projectile_starting_index: Int,
) -> #(CastResult, Wand) {
  case start_index >= iv.length(wand.slots) {
    True -> #(WandEmpty, wand)
    False -> {
      // Collect spells from start_index onwards
      let spells_to_cast =
        wand.slots
        |> iv.drop_first(start_index)
        |> iv.filter_map(fn(slot) {
          case slot {
            option.Some(spell) -> Ok(spell)
            option.None -> Error(Nil)
          }
        })

      // Process the spell sequence
      process_spell_sequence(
        wand,
        spells_to_cast,
        [],
        start_index,
        position,
        direction,
        projectile_starting_index,
      )
    }
  }
}

/// Process a sequence of spells, collecting modifiers until a damaging spell is found
fn process_spell_sequence(
  wand: Wand,
  spells: iv.Array(spell.Spell),
  accumulated_modifiers: List(spell.ModifierSpell),
  current_index: Int,
  position: #(Float, Float, Float),
  direction: #(Float, Float, Float),
  projectile_starting_index: Int,
) -> #(CastResult, Wand) {
  case spells == iv.new() {
    True -> {
      // No more spells to process
      case accumulated_modifiers {
        [] -> #(WandEmpty, wand)
        _ -> #(NoSpellToCast, wand)
      }
    }
    False -> {
      let assert Ok(spell) = iv.first(from: spells)
      let rest = iv.drop_first(from: spells, up_to: 1)
      case spell {
        spell.ModifierSpell(mod) -> {
          // Accumulate this modifier and continue
          let new_modifiers = [mod, ..accumulated_modifiers]
          process_spell_sequence(
            wand,
            rest,
            new_modifiers,
            current_index + 1,
            position,
            direction,
            projectile_starting_index + current_index,
          )
        }
        spell.DamageSpell(damaging) -> {
          // Found a damaging spell - apply modifiers and cast
          let modified =
            spell.apply_modifiers(damaging, list.reverse(accumulated_modifiers))

          // Check if we have enough mana
          case wand.current_mana >=. modified.total_mana_cost {
            True -> {
              let projectile =
                spell.Projectile(
                  id: projectile_starting_index + current_index,
                  spell: modified,
                  position: position,
                  direction: direction,
                  time_alive: 0.0,
                )
              let new_mana = wand.current_mana -. modified.total_mana_cost
              let updated_wand = Wand(..wand, current_mana: new_mana)
              #(
                CastSuccess(
                  projectile: projectile,
                  remaining_mana: new_mana,
                  next_cast_index: current_index + 1,
                ),
                updated_wand,
              )
            }
            False -> {
              #(
                NotEnoughMana(
                  required: modified.total_mana_cost,
                  available: wand.current_mana,
                ),
                wand,
              )
            }
          }
        }
      }
    }
  }
}

/// Recharge mana over time (call this each frame with delta_time)
pub fn recharge_mana(wand: Wand, delta_time: Float) -> Wand {
  let new_mana =
    float.min(
      wand.max_mana,
      wand.current_mana +. wand.mana_recharge_rate *. delta_time,
    )
  Wand(..wand, current_mana: new_mana)
}

/// Get the number of spells in the wand
pub fn spell_count(wand: Wand) -> Int {
  wand.slots
  |> iv.filter(fn(slot) {
    case slot {
      option.Some(_) -> True
      option.None -> False
    }
  })
  |> iv.length
}

/// Check if a slot is empty
pub fn is_slot_empty(wand: Wand, slot_index: Int) -> Bool {
  case get_spell(wand, slot_index) {
    Ok(option.None) -> True
    Ok(option.Some(_)) -> False
    Error(Nil) -> True
  }
}

// Pre-defined wands for convenience

/// Basic wand with 3 slots
pub fn basic_wand() -> Wand {
  new(
    name: "Basic Wand",
    slot_count: 3,
    max_mana: 100.0,
    mana_recharge_rate: 10.0,
    cast_delay: 0.2,
    recharge_time: 0.5,
  )
}

/// Advanced wand with 6 slots and higher mana
pub fn advanced_wand() -> Wand {
  new(
    name: "Advanced Wand",
    slot_count: 6,
    max_mana: 200.0,
    mana_recharge_rate: 15.0,
    cast_delay: 0.15,
    recharge_time: 0.3,
  )
}

/// Rapid fire wand with many slots but low mana
pub fn rapid_wand() -> Wand {
  new(
    name: "Rapid Wand",
    slot_count: 10,
    max_mana: 150.0,
    mana_recharge_rate: 20.0,
    cast_delay: 0.05,
    recharge_time: 1.0,
  )
}

/// Reorder slots in a wand by moving an item from one index to another
pub fn reorder_slots(
  wand: Wand,
  from_index: Int,
  to_index: Int,
) -> Result(Wand, Nil) {
  // Use a helper to reorder the list
  use new_slots <- result.map(reorder_list(wand.slots, from_index, to_index))
  Wand(..wand, slots: new_slots)
}

fn reorder_list(
  items: iv.Array(a),
  from_index: Int,
  to_index: Int,
) -> Result(iv.Array(a), Nil) {
  // Remove the item at from_index
  case iv.get(items, from_index), iv.delete(items, from_index) {
    Ok(removed_item), Ok(list_without_item) -> {
      // Insert it at to_index
      iv.insert(list_without_item, to_index, removed_item)
    }
    _, _ -> Ok(items)
  }
}
