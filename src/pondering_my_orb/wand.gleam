import gleam/float
import gleam/option.{type Option, None, Some}
import gleam/result
import iv
import pondering_my_orb/spell.{type Spell}
import tiramisu/spritesheet
import vec/vec3.{type Vec3}

/// Represents a wand with spell slots
pub type Wand {
  Wand(
    name: String,
    slots: iv.Array(Option(Spell)),
    max_mana: Float,
    current_mana: Float,
    mana_recharge_rate: Float,
    cast_delay: Float,
    recharge_time: Float,
    spells_per_cast: Int,
  )
}

/// Result of casting from a wand
pub type CastResult {
  /// Successfully cast spells (can be multiple due to draw system)
  CastSuccess(
    projectiles: List(spell.Projectile),
    remaining_mana: Float,
    next_cast_index: Int,
    casting_indices: List(Int),
    did_wrap: Bool,
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
  spells_per_cast spells_per_cast: Int,
) -> Wand {
  Wand(
    name:,
    slots: iv.repeat(None, slot_count),
    max_mana:,
    current_mana: max_mana,
    mana_recharge_rate:,
    cast_delay:,
    recharge_time:,
    spells_per_cast:,
  )
}

pub fn set_spell(wand: Wand, slot_index: Int, spell: Spell) -> Result(Wand, Nil) {
  case iv.get(wand.slots, slot_index) {
    Ok(None) -> {
      use slots <- result.map(iv.set(
        wand.slots,
        at: slot_index,
        to: Some(spell),
      ))
      Wand(..wand, slots:)
    }
    Error(Nil) | Ok(Some(_)) -> Error(Nil)
  }
}

pub fn remove_spell(wand: Wand, slot_index: Int) -> Result(Wand, Nil) {
  use slots <- result.map(iv.delete(from: wand.slots, at: slot_index))
  Wand(..wand, slots:)
}

pub fn get_spell(wand: Wand, slot_index: Int) -> Result(Option(Spell), Nil) {
  wand.slots
  |> iv.get(slot_index)
}

/// Cast spells from the wand starting at a given index using the draw system
/// Processes spells until draw is exhausted, collecting all projectiles
pub fn cast(
  wand: Wand,
  start_index: Int,
  position: Vec3(Float),
  direction: Vec3(Float),
  projectile_starting_index: Int,
) -> #(CastResult, Wand) {
  case start_index >= iv.length(wand.slots) {
    True -> #(WandEmpty, wand)
    False -> {
      // Start with the wand's spells_per_cast as initial draw
      process_with_draw(
        wand,
        start_index,
        wand.spells_per_cast,
        iv.new(),
        [],
        [],
        0.0,
        position,
        direction,
        projectile_starting_index,
      )
    }
  }
}

/// Process spells with the draw system
/// Continues processing spells until draw is exhausted, with wrapping support
fn process_with_draw(
  wand: Wand,
  current_index: Int,
  remaining_draw: Int,
  accumulated_modifiers: iv.Array(spell.ModifierSpell),
  projectiles: List(spell.Projectile),
  casting_indices: List(Int),
  total_mana_used: Float,
  position: Vec3(Float),
  direction: Vec3(Float),
  projectile_id: Int,
) -> #(CastResult, Wand) {
  let wand_length = iv.length(wand.slots)

  // Check if wand is empty
  case wand_length {
    0 -> #(WandEmpty, wand)
    _ -> {
      // Check if we're out of draw
      case remaining_draw <= 0 {
        True -> {
          // End of cast cycle
          case projectiles {
            [] -> #(NoSpellToCast, wand)
            _ -> {
              let new_mana = wand.current_mana -. total_mana_used
              let updated_wand = Wand(..wand, current_mana: new_mana)

              let next_index = current_index % wand_length
              let wrapped_past_end = current_index >= wand_length
              let has_spells_ahead = has_any_spell_from(wand.slots, next_index)

              // Wrap if we exceeded slot count OR no spells remain
              let did_wrap = wrapped_past_end || !has_spells_ahead

              #(
                CastSuccess(
                  projectiles:,
                  remaining_mana: new_mana,
                  next_cast_index: next_index,
                  casting_indices:,
                  did_wrap:,
                ),
                updated_wand,
              )
            }
          }
        }
        False -> {
          // Wrap index if we've gone past the end
          let wrapped_index = current_index % wand_length

          // Get current spell slot
          case iv.get(wand.slots, wrapped_index) {
            Error(_) -> #(WandEmpty, wand)
            Ok(None) -> {
              // Empty slot, consume 1 draw and continue
              process_with_draw(
                wand,
                current_index + 1,
                remaining_draw - 1,
                accumulated_modifiers,
                projectiles,
                [wrapped_index, ..casting_indices],
                total_mana_used,
                position,
                direction,
                projectile_id,
              )
            }
            Ok(Some(current_spell)) -> {
              // Process the spell based on type
              case current_spell {
                spell.ModifierSpell(mod) -> {
                  // Modifiers: accumulate and consume 1 draw
                  let new_modifiers = iv.prepend(accumulated_modifiers, mod)
                  let new_mana_used = total_mana_used +. mod.mana_cost

                  // Check mana
                  case wand.current_mana >=. new_mana_used {
                    True ->
                      process_with_draw(
                        wand,
                        current_index + 1,
                        remaining_draw - 1,
                        new_modifiers,
                        projectiles,
                        [wrapped_index, ..casting_indices],
                        new_mana_used,
                        position,
                        direction,
                        projectile_id,
                      )
                    False -> #(
                      NotEnoughMana(
                        required: new_mana_used,
                        available: wand.current_mana,
                      ),
                      wand,
                    )
                  }
                }

                spell.MulticastSpell(multicast) -> {
                  // Multicast: consume 1 draw, add draw_add, process next spells
                  let new_draw = remaining_draw - 1 + multicast.draw_add
                  let new_mana_used = total_mana_used +. multicast.mana_cost

                  // Check mana
                  case wand.current_mana >=. new_mana_used {
                    True ->
                      process_with_draw(
                        wand,
                        current_index + 1,
                        new_draw,
                        accumulated_modifiers,
                        projectiles,
                        [wrapped_index, ..casting_indices],
                        new_mana_used,
                        position,
                        direction,
                        projectile_id,
                      )
                    False -> #(
                      NotEnoughMana(
                        required: new_mana_used,
                        available: wand.current_mana,
                      ),
                      wand,
                    )
                  }
                }

                spell.DamageSpell(damaging) -> {
                  // Damage spell: create projectile, consume 1 draw
                  let modified =
                    spell.apply_modifiers(damaging, accumulated_modifiers)
                  let new_mana_used =
                    total_mana_used +. modified.total_mana_cost

                  // Check mana
                  case wand.current_mana >=. new_mana_used {
                    True -> {
                      let projectile =
                        spell.Projectile(
                          id: projectile_id,
                          spell: modified,
                          position: position,
                          direction: direction,
                          time_alive: 0.0,
                          animation_state: spritesheet.initial_state(
                            "projectile",
                          ),
                          visuals: damaging.visuals,
                        )

                      process_with_draw(
                        wand,
                        current_index + 1,
                        remaining_draw - 1,
                        iv.new(),
                        [projectile, ..projectiles],
                        [wrapped_index, ..casting_indices],
                        new_mana_used,
                        position,
                        direction,
                        projectile_id + 1,
                      )
                    }
                    False -> #(
                      NotEnoughMana(
                        required: new_mana_used,
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
    }
  }
}

pub fn recharge_mana(wand: Wand, delta_time: Float) -> Wand {
  let new_mana =
    float.min(
      wand.max_mana,
      wand.current_mana +. wand.mana_recharge_rate *. delta_time,
    )
  Wand(..wand, current_mana: new_mana)
}

pub fn spell_count(wand: Wand) -> Int {
  wand.slots
  |> iv.filter(fn(slot) {
    case slot {
      Some(_) -> True
      None -> False
    }
  })
  |> iv.length
}

pub fn is_slot_empty(wand: Wand, slot_index: Int) -> Bool {
  case get_spell(wand, slot_index) {
    Ok(None) -> True
    Ok(Some(_)) -> False
    Error(Nil) -> True
  }
}

pub fn reorder_slots(
  wand: Wand,
  from_index: Int,
  to_index: Int,
) -> Result(Wand, Nil) {
  use new_slots <- result.map(reorder_array(wand.slots, from_index, to_index))
  Wand(..wand, slots: new_slots)
}

fn reorder_array(
  items: iv.Array(a),
  from_index: Int,
  to_index: Int,
) -> Result(iv.Array(a), Nil) {
  case iv.get(items, from_index), iv.delete(items, from_index) {
    Ok(removed_item), Ok(list_without_item) -> {
      iv.insert(list_without_item, to_index, removed_item)
    }
    _, _ -> Ok(items)
  }
}

/// Check if there are any spells from start_index to end of slots
fn has_any_spell_from(slots: iv.Array(Option(Spell)), start_index: Int) -> Bool {
  let length = iv.length(slots)
  check_slots_from(slots, start_index, length)
}

fn check_slots_from(
  slots: iv.Array(Option(Spell)),
  current: Int,
  length: Int,
) -> Bool {
  case current >= length {
    True -> False
    False -> {
      case iv.get(slots, current) {
        Ok(Some(_)) -> True
        _ -> check_slots_from(slots, current + 1, length)
      }
    }
  }
}
