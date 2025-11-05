import gleam/float
import gleam/int
import gleam/list

/// Represents different types of perks that can affect gameplay
pub type Perk {
  /// Chance to deal massive damage (Big Bonk)
  BigBonk(crit_chance: Float, crit_multiplier: Float)
  /// More damage the longer you stand still (max bonus)
  Trance(max_damage_bonus: Float, time_to_max: Float)
  /// Survive one lethal hit
  OneLife
  /// More damage based on missing HP
  BerserkersRage(max_damage_bonus: Float)
  /// Bonus damage to low HP enemies
  Execute(threshold: Float, damage_multiplier: Float)
  /// More max HP, more damage taken
  GlassCannon(damage_multiplier: Float, damage_taken_multiplier: Float)
}

/// Metadata about a perk for UI display
pub type PerkInfo {
  PerkInfo(perk: Perk, name: String, description: String)
}

/// Get perk information for display
pub fn get_info(perk: Perk) -> PerkInfo {
  case perk {
    BigBonk(crit_chance, crit_multiplier) -> {
      let chance_percent = float.round(crit_chance *. 100.0)
      let multiplier_text = float.round(crit_multiplier)
      PerkInfo(
        perk:,
        name: "Big Bonk",
        description: int.to_string(chance_percent)
          <> "% chance to deal "
          <> int.to_string(multiplier_text)
          <> "x damage",
      )
    }

    Trance(max_bonus, time_to_max) -> {
      let percent = float.round(max_bonus *. 100.0)
      PerkInfo(
        perk:,
        name: "Idle Juice",
        description: "Up to +"
          <> int.to_string(percent)
          <> "% damage while standing still ("
          <> float.to_string(time_to_max)
          <> "s to max)",
      )
    }

    OneLife -> {
      PerkInfo(
        perk:,
        name: "One Life",
        description: "Survive one lethal hit (consumed on use)",
      )
    }

    BerserkersRage(max_bonus) -> {
      let percent = float.round(max_bonus *. 100.0)
      PerkInfo(
        perk:,
        name: "Berserker's Rage",
        description: "Up to +"
          <> int.to_string(percent)
          <> "% damage based on missing HP",
      )
    }

    Execute(threshold, mult) -> {
      let threshold_percent = float.round(threshold *. 100.0)
      let multiplier_text = float.round(mult)
      PerkInfo(
        perk:,
        name: "Executioner",
        description: int.to_string(multiplier_text)
          <> "x damage to enemies below "
          <> int.to_string(threshold_percent)
          <> "% HP",
      )
    }

    GlassCannon(damage_mult, damage_taken_mult) -> {
      let damage_percent = float.round({ damage_mult -. 1.0 } *. 100.0)
      let taken_percent = float.round({ damage_taken_mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Glass Cannon",
        description: "+"
          <> int.to_string(damage_percent)
          <> "% damage, +"
          <> int.to_string(taken_percent)
          <> "% damage taken",
      )
    }
  }
}

/// Perk rarity determines drop chance
pub type PerkRarity {
  Common
  Uncommon
  Rare
  Legendary
}

/// Get weight for a rarity (higher = more common)
fn rarity_weight(rarity: PerkRarity) -> Float {
  case rarity {
    Common -> 10.0
    Uncommon -> 5.0
    Rare -> 2.0
    Legendary -> 0.5
  }
}

/// All available perks with their rarities
fn all_perks() -> List(#(Perk, PerkRarity)) {
  [
    // Common perks - accessible but interesting
    #(Trance(1.0, 5.0), Common),
    // Uncommon perks - interesting mechanics with tradeoffs
    #(Execute(0.3, 2.0), Uncommon),
    #(BerserkersRage(1.0), Uncommon),
    // Rare perks - powerful effects
    #(BigBonk(0.02, 20.0), Rare),
    #(GlassCannon(1.5, 1.3), Rare),
    // Legendary perks - unique game-changers
    #(OneLife, Legendary),
  ]
}

/// Generate a random perk using weighted selection
pub fn random() -> Perk {
  let perks = all_perks()

  // Calculate total weight
  let total_weight =
    perks
    |> list.fold(0.0, fn(sum, perk_entry) {
      let #(_perk, rarity) = perk_entry
      sum +. rarity_weight(rarity)
    })

  // Roll a random number between 0 and total_weight
  let roll = float.random() *. total_weight

  // Find the perk that matches this roll
  let #(selected_perk, _) =
    perks
    |> list.fold_until(#(Trance(1.0, 5.0), 0.0), fn(acc, perk_entry) {
      let #(_current_perk, accumulated_weight) = acc
      let #(perk, rarity) = perk_entry
      let new_weight = accumulated_weight +. rarity_weight(rarity)

      case roll <. new_weight {
        True -> list.Stop(#(perk, new_weight))
        False -> list.Continue(#(perk, new_weight))
      }
    })

  selected_perk
}
