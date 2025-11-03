import ensaimada
import gleam/option
import iv
import pondering_my_orb/loot
import pondering_my_orb/perk
import pondering_my_orb/score
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/wand

pub type Model(tiramisu_msg) {
  Model(
    game_phase: GamePhase,
    player_health: Float,
    player_max_health: Float,
    player_mana: Float,
    player_max_mana: Float,
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
    drag_state: ensaimada.DragState,
    wrapper: fn(UiToGameMsg) -> tiramisu_msg,
    player_xp: Int,
    player_xp_to_next_level: Int,
    player_level: Int,
    score: score.Score,
    spell_rewards: option.Option(List(spell.Spell)),
    is_paused: Bool,
    is_settings_open: Bool,
    resuming: Bool,
    resume_retry_count: Int,
    casting_spell_indices: List(Int),
    casting_highlight_timer: Float,
    spells_per_cast: Int,
    cast_delay: Float,
    recharge_time: Float,
    time_since_last_cast: Float,
    current_spell_index: Int,
    is_recharging: Bool,
    camera_distance: Float,
    // Wand stats
    wand_max_mana: Float,
    wand_mana_recharge_rate: Float,
    wand_cast_delay: Float,
    wand_recharge_time: Float,
    wand_capacity: Int,
    wand_spread: Float,
    // Wand selection
    pending_wand: option.Option(wand.Wand),
    showing_wand_selection: Bool,
    // Debug menu
    is_debug_menu_open: Bool,
    // Perk slot machine
    perk_slot_machine: option.Option(SlotMachineState),
  )
}

pub type GamePhase {
  StartScreen
  LoadingScreen
  Playing
  GameOver
}

pub type Msg {
  GameStateUpdated(GameState)
  GamePhaseChanged(GamePhase)
  StartButtonClicked
  RestartButtonClicked
  WandSortableMsg(ensaimada.Msg(Msg))
  BagSortableMsg(ensaimada.Msg(Msg))
  ShowSpellRewards(List(spell.Spell))
  SpellRewardClicked(spell.Spell)
  DoneWithLevelUp
  ResumeGame
  OpenSettings
  CloseSettings
  CameraDistanceChanged(Float)
  PointerLockExited
  PointerLockAcquired
  LootPickedUp(loot.LootType)
  AcceptWand
  RejectWand
  // Debug menu
  ToggleDebugMenu
  AddSpellToBag(spell.Id)
  UpdateWandStat(WandStatUpdate)
  // Pause state synchronization
  SetPaused(Bool)
  // Perk slot machine
  StartPerkSlotMachine(perk.Perk)
  UpdateSlotMachineAnimation(Float)
  ClosePerkSlotMachine
  NoOp
}

pub type WandStatUpdate {
  SetMaxMana(Float)
  SetManaRechargeRate(Float)
  SetCastDelay(Float)
  SetRechargeTime(Float)
  SetSpread(Float)
  SetCapacity(Int)
}

pub type UiToGameMsg {
  GameStarted
  GameRestarted
  UpdatePlayerInventory(
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
  )
  SpellRewardSelected(spell.Spell)
  LevelUpComplete
  GamePaused
  GameResumed
  UpdateCameraDistance(Float)
  ApplyLoot(loot.LootType)
  CloseLootUI
  WandSelectionComplete
  // Debug menu
  DebugMenuOpened
  DebugMenuClosed
  DebugAddSpellToBag(spell.Id)
  DebugUpdateWandStat(WandStatUpdate)
  // Perk slot machine
  PerkSlotMachineComplete(perk.Perk)
}

pub type GameState {
  GameState(
    player_health: Float,
    player_max_health: Float,
    player_mana: Float,
    player_max_mana: Float,
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
    player_xp: Int,
    player_xp_to_next_level: Int,
    player_level: Int,
    score: score.Score,
    casting_spell_indices: List(Int),
    spells_per_cast: Int,
    cast_delay: Float,
    recharge_time: Float,
    time_since_last_cast: Float,
    current_spell_index: Int,
    is_recharging: Bool,
    wand_max_mana: Float,
    wand_mana_recharge_rate: Float,
    wand_cast_delay: Float,
    wand_recharge_time: Float,
    wand_capacity: Int,
    wand_spread: Float,
  )
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
