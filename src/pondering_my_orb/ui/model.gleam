import pondering_my_orb/perk

// Shared types used by sub-modules

pub type WandStatUpdate {
  SetMaxMana(Float)
  SetManaRechargeRate(Float)
  SetCastDelay(Float)
  SetRechargeTime(Float)
  SetSpread(Float)
  SetCapacity(Int)
}

/// Slot machine animation state for perk reveals
pub type SlotMachineState {
  SlotMachineState(
    selected_perk: perk.Perk,
    // Three reels showing random perks during animation
    reel1: perk.Perk,
    reel2: perk.Perk,
    reel3: perk.Perk,
    animation_phase: AnimationPhase,
    time_elapsed: Float,
  )
}

pub type AnimationPhase {
  Spinning
  // 0.0 - 2.0s: all reels spinning
  StoppingLeft
  // 2.0 - 2.5s: left reel stops
  StoppingMiddle
  // 2.5 - 3.0s: middle reel stops
  StoppingRight
  // 3.0 - 3.5s: right reel stops
  Stopped
  // 3.5s+: show continue button
}
