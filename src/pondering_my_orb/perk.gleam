import gleam/float
import gleam/int

/// Represents different types of perks that can affect gameplay
pub type Perk {
  /// Increases max health by a percentage
  HealthBoost(multiplier: Float)
  /// Increases movement speed by a percentage
  SpeedBoost(multiplier: Float)
  /// Increases mana regeneration rate by a percentage
  ManaRegenBoost(multiplier: Float)
  /// Increases max mana by a percentage
  MaxManaBoost(multiplier: Float)
  /// Reduces cast delay by a percentage
  CastSpeedBoost(multiplier: Float)
  /// Reduces recharge time by a percentage
  RechargeSpeedBoost(multiplier: Float)
  /// Increases all damage by a percentage
  DamageBoost(multiplier: Float)
  /// Increases projectile speed by a percentage
  ProjectileSpeedBoost(multiplier: Float)
  /// Increases passive healing rate
  PassiveHealBoost(multiplier: Float)
  /// Reduces passive heal delay
  QuickHeal(delay_reduction: Float)
}

/// Metadata about a perk for UI display
pub type PerkInfo {
  PerkInfo(perk: Perk, name: String, description: String)
}

/// Get perk information for display
pub fn get_info(perk: Perk) -> PerkInfo {
  case perk {
    HealthBoost(mult) -> {
      let percent = float.round({ mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Health Boost",
        description: "Increases max health by " <> int.to_string(percent) <> "%",
      )
    }

    SpeedBoost(mult) -> {
      let percent = float.round({ mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Speed Boost",
        description: "Increases movement speed by "
          <> int.to_string(percent)
          <> "%",
      )
    }

    ManaRegenBoost(mult) -> {
      let percent = float.round({ mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Mana Regen",
        description: "Increases mana regeneration by "
          <> int.to_string(percent)
          <> "%",
      )
    }

    MaxManaBoost(mult) -> {
      let percent = float.round({ mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Max Mana",
        description: "Increases max mana by " <> int.to_string(percent) <> "%",
      )
    }

    CastSpeedBoost(mult) -> {
      let percent = float.round({ 1.0 -. mult } *. 100.0)
      PerkInfo(
        perk:,
        name: "Cast Speed",
        description: "Reduces cast delay by " <> int.to_string(percent) <> "%",
      )
    }

    RechargeSpeedBoost(mult) -> {
      let percent = float.round({ 1.0 -. mult } *. 100.0)
      PerkInfo(
        perk:,
        name: "Quick Reload",
        description: "Reduces wand recharge time by "
          <> int.to_string(percent)
          <> "%",
      )
    }

    DamageBoost(mult) -> {
      let percent = float.round({ mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Damage Boost",
        description: "Increases all damage by " <> int.to_string(percent) <> "%",
      )
    }

    ProjectileSpeedBoost(mult) -> {
      let percent = float.round({ mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Projectile Speed",
        description: "Increases projectile speed by "
          <> int.to_string(percent)
          <> "%",
      )
    }

    PassiveHealBoost(mult) -> {
      let percent = float.round({ mult -. 1.0 } *. 100.0)
      PerkInfo(
        perk:,
        name: "Regeneration",
        description: "Increases passive healing by "
          <> int.to_string(percent)
          <> "%",
      )
    }

    QuickHeal(reduction) -> {
      PerkInfo(
        perk:,
        name: "Quick Heal",
        description: "Reduces healing delay by "
          <> float.to_string(reduction)
          <> "s",
      )
    }
  }
}

/// Generate a random perk
pub fn random() -> Perk {
  let roll = float.random()

  case roll {
    r if r <. 0.1 -> HealthBoost(1.25)
    r if r <. 0.2 -> SpeedBoost(1.15)
    r if r <. 0.3 -> ManaRegenBoost(1.3)
    r if r <. 0.4 -> MaxManaBoost(1.25)
    r if r <. 0.5 -> CastSpeedBoost(0.85)
    r if r <. 0.6 -> RechargeSpeedBoost(0.85)
    r if r <. 0.7 -> DamageBoost(1.2)
    r if r <. 0.8 -> ProjectileSpeedBoost(1.15)
    r if r <. 0.9 -> PassiveHealBoost(1.5)
    _ -> QuickHeal(1.5)
  }
}
