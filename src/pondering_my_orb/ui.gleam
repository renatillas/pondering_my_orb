import ensaimada
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import grille_pain
import iv
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import plinth/javascript/global
import pondering_my_orb/loot
import pondering_my_orb/perk
import pondering_my_orb/pointer_lock
import pondering_my_orb/pointer_lock_request
import pondering_my_orb/score
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/ui/components/perk_slot_machine
import pondering_my_orb/ui/debug_menu
import pondering_my_orb/ui/game_over
import pondering_my_orb/ui/loading_screen
import pondering_my_orb/ui/model
import pondering_my_orb/ui/pause_menu
import pondering_my_orb/ui/spell_rewards
import pondering_my_orb/ui/start_screen
import pondering_my_orb/ui/wand_selection
import pondering_my_orb/wand
import tiramisu/ui as tiramisu_ui

// ============================================================================
// TYPES
// ============================================================================

// Re-export types from ui/model for external modules
pub type WandStatUpdate =
  model.WandStatUpdate

pub type SlotMachineState =
  model.SlotMachineState

pub type AnimationPhase =
  model.AnimationPhase

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
    perk_slot_machine: option.Option(model.SlotMachineState),
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
  UpdateWandStat(model.WandStatUpdate)
  // Pause state synchronization
  SetPaused(Bool)
  // Perk slot machine
  StartPerkSlotMachine(perk.Perk)
  UpdateSlotMachineAnimation(Float)
  ClosePerkSlotMachine
  NoOp
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
  DebugUpdateWandStat(model.WandStatUpdate)
  // Perk slot machine
  PerkSlotMachineStarted
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

// ============================================================================
// INIT
// ============================================================================

pub fn init(wrapper) -> #(Model(tiramisu_msg), effect.Effect(Msg)) {
  #(
    Model(
      game_phase: StartScreen,
      player_health: 100.0,
      player_max_health: 100.0,
      player_mana: 100.0,
      player_max_mana: 100.0,
      wand_slots: iv.new(),
      spell_bag: spell_bag.new(),
      drag_state: ensaimada.NoDrag,
      wrapper:,
      player_xp: 0,
      player_xp_to_next_level: 100,
      player_level: 1,
      score: score.init(),
      spell_rewards: option.None,
      is_paused: False,
      is_settings_open: False,
      resuming: False,
      resume_retry_count: 0,
      casting_spell_indices: [],
      casting_highlight_timer: 0.0,
      spells_per_cast: 1,
      cast_delay: 0.2,
      recharge_time: 0.5,
      time_since_last_cast: 0.0,
      current_spell_index: 0,
      is_recharging: False,
      camera_distance: 5.0,
      wand_max_mana: 100.0,
      wand_mana_recharge_rate: 30.0,
      wand_cast_delay: 0.2,
      wand_recharge_time: 0.5,
      wand_capacity: 3,
      wand_spread: 0.0,
      pending_wand: option.None,
      showing_wand_selection: False,
      is_debug_menu_open: False,
      perk_slot_machine: option.None,
    ),
    effect.batch([
      tiramisu_ui.register_lustre(),
      pointer_lock.setup_pointer_lock_listener(fn() { PointerLockExited }, fn() {
        PointerLockAcquired
      }),
      effect.from(fn(_) {
        let assert Ok(_) = grille_pain.simple()
        Nil
      }),
    ]),
  )
}

// ============================================================================
// UPDATE
// ============================================================================

pub fn update(
  model: Model(tiramisu_msg),
  msg: Msg,
) -> #(Model(tiramisu_msg), effect.Effect(Msg)) {
  case msg {
    GamePhaseChanged(game_phase) -> #(
      Model(..model, game_phase:),
      effect.none(),
    )
    StartButtonClicked -> #(
      model,
      tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GameStarted)),
    )
    RestartButtonClicked -> #(
      model,
      tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GameRestarted)),
    )
    GameStateUpdated(state) -> {
      // During level-up modal, don't overwrite inventory (user is managing it)
      let #(wand_slots, spell_bag) = case model.spell_rewards {
        option.Some(_) -> #(model.wand_slots, model.spell_bag)
        option.None -> #(state.wand_slots, state.spell_bag)
      }

      // Update casting highlight: set timer to 300ms if new indices, otherwise keep current
      let #(casting_indices, timer) = case state.casting_spell_indices {
        [] -> #(model.casting_spell_indices, model.casting_highlight_timer)
        _ -> #(state.casting_spell_indices, 300.0)
      }

      #(
        Model(
          ..model,
          game_phase: model.game_phase,
          player_health: state.player_health,
          player_max_health: state.player_max_health,
          player_mana: state.player_mana,
          player_max_mana: state.player_max_mana,
          wand_slots: wand_slots,
          spell_bag: spell_bag,
          drag_state: model.drag_state,
          player_xp: state.player_xp,
          player_xp_to_next_level: state.player_xp_to_next_level,
          player_level: state.player_level,
          score: state.score,
          casting_spell_indices: casting_indices,
          casting_highlight_timer: timer,
          spells_per_cast: state.spells_per_cast,
          cast_delay: state.cast_delay,
          recharge_time: state.recharge_time,
          time_since_last_cast: state.time_since_last_cast,
          current_spell_index: state.current_spell_index,
          is_recharging: state.is_recharging,
          wand_max_mana: state.wand_max_mana,
          wand_mana_recharge_rate: state.wand_mana_recharge_rate,
          wand_cast_delay: state.wand_cast_delay,
          wand_recharge_time: state.wand_recharge_time,
          wand_capacity: state.wand_capacity,
          wand_spread: state.wand_spread,
          // Preserve UI-only states
          is_paused: model.is_paused,
          is_debug_menu_open: model.is_debug_menu_open,
        ),
        effect.none(),
      )
    }
    WandSortableMsg(sortable_msg) -> {
      let wand_config =
        ensaimada.Config(
          on_reorder: fn(_from, _to) {
            WandSortableMsg(ensaimada.UserMsg(NoOp))
          },
          container_id: "wand-slots",
          container_class: "flex gap-2",
          item_class: "sortable-item",
          dragging_class: "opacity-50 scale-105",
          drag_over_class: "ring-2 ring-blue-400",
          ghost_class: "opacity-30",
          accept_from: ["spell-bag"],
        )

      let #(new_drag_state, maybe_action) =
        ensaimada.update(sortable_msg, model.drag_state, wand_config)

      case maybe_action {
        option.None -> #(
          Model(..model, drag_state: new_drag_state),
          effect.none(),
        )
        option.Some(ensaimada.SameContainer(from_index, to_index)) -> {
          // Reorder within wand
          let new_slots = reorder_array(model.wand_slots, from_index, to_index)
          #(
            Model(..model, wand_slots: new_slots, drag_state: new_drag_state),
            tiramisu_ui.dispatch_to_tiramisu(
              model.wrapper(UpdatePlayerInventory(new_slots, model.spell_bag)),
            ),
          )
        }
        option.Some(ensaimada.CrossContainer(
          from_container,
          from_index,
          _to_container,
          to_index,
        )) -> {
          case from_container {
            "spell-bag" -> {
              // Transfer from bag to wand
              let spell_stacks = spell_bag.list_spell_stacks(model.spell_bag)
              case
                spell_stacks
                |> list.drop(from_index)
                |> list.first()
              {
                Ok(#(spell_to_add, _count)) -> {
                  // Check if target slot already has a spell and add it back to bag
                  let new_bag = case iv.get(model.wand_slots, to_index) {
                    Ok(option.Some(existing_spell)) -> {
                      // Add existing spell back to bag
                      spell_bag.add_spell(model.spell_bag, existing_spell)
                    }
                    _ -> model.spell_bag
                  }

                  // Remove spell from bag
                  let new_bag = spell_bag.remove_spell(new_bag, spell_to_add)

                  // Add to wand at the drop position
                  let new_slots = case
                    iv.set(
                      model.wand_slots,
                      to_index,
                      option.Some(spell_to_add),
                    )
                  {
                    Ok(slots) -> slots
                    Error(_) -> model.wand_slots
                  }

                  #(
                    Model(
                      ..model,
                      wand_slots: new_slots,
                      spell_bag: new_bag,
                      drag_state: new_drag_state,
                    ),
                    tiramisu_ui.dispatch_to_tiramisu(
                      model.wrapper(UpdatePlayerInventory(new_slots, new_bag)),
                    ),
                  )
                }
                Error(_) -> #(
                  Model(..model, drag_state: new_drag_state),
                  effect.none(),
                )
              }
            }
            _ -> #(Model(..model, drag_state: new_drag_state), effect.none())
          }
        }
      }
    }
    BagSortableMsg(sortable_msg) -> {
      let bag_config =
        ensaimada.Config(
          on_reorder: fn(_from, _to) { BagSortableMsg(ensaimada.UserMsg(NoOp)) },
          container_id: "spell-bag",
          container_class: "grid grid-cols-4 gap-2",
          item_class: "sortable-item",
          dragging_class: "opacity-50 scale-105",
          drag_over_class: "[&>div]:ring-2 [&>div]:ring-purple-400",
          ghost_class: "opacity-30",
          accept_from: ["wand-slots"],
        )

      let #(new_drag_state, maybe_action) =
        ensaimada.update(sortable_msg, model.drag_state, bag_config)

      case maybe_action {
        option.None -> #(
          Model(..model, drag_state: new_drag_state),
          effect.none(),
        )
        option.Some(ensaimada.CrossContainer(
          from_container,
          from_index,
          _to_container,
          _to_index,
        )) -> {
          case from_container {
            "wand-slots" -> {
              // Transfer from wand to bag
              case iv.get(model.wand_slots, from_index) {
                Ok(option.Some(spell)) -> {
                  // Remove from wand
                  let new_slots = case
                    iv.set(model.wand_slots, from_index, option.None)
                  {
                    Ok(slots) -> slots
                    Error(_) -> model.wand_slots
                  }

                  // Add to bag
                  let new_bag = spell_bag.add_spell(model.spell_bag, spell)

                  #(
                    Model(
                      ..model,
                      wand_slots: new_slots,
                      spell_bag: new_bag,
                      drag_state: new_drag_state,
                    ),
                    tiramisu_ui.dispatch_to_tiramisu(
                      model.wrapper(UpdatePlayerInventory(new_slots, new_bag)),
                    ),
                  )
                }
                _ -> #(
                  Model(..model, drag_state: new_drag_state),
                  effect.none(),
                )
              }
            }
            _ -> #(Model(..model, drag_state: new_drag_state), effect.none())
          }
        }
        _ -> #(Model(..model, drag_state: new_drag_state), effect.none())
      }
    }
    ShowSpellRewards(rewards) -> #(
      Model(..model, spell_rewards: option.Some(rewards)),
      effect.none(),
    )
    SpellRewardClicked(selected_spell) -> {
      // Add spell to bag and keep modal open
      let updated_bag = spell_bag.add_spell(model.spell_bag, selected_spell)

      // Clear ALL rewards after selection (user can only pick one spell)
      let updated_rewards = option.Some([])

      #(
        Model(..model, spell_bag: updated_bag, spell_rewards: updated_rewards),
        tiramisu_ui.dispatch_to_tiramisu(
          model.wrapper(SpellRewardSelected(selected_spell)),
        ),
      )
    }
    DoneWithLevelUp -> {
      // Send the updated inventory state to the game before closing
      #(
        Model(..model, spell_rewards: option.None),
        effect.batch([
          tiramisu_ui.dispatch_to_tiramisu(
            model.wrapper(UpdatePlayerInventory(
              wand_slots: model.wand_slots,
              spell_bag: model.spell_bag,
            )),
          ),
          tiramisu_ui.dispatch_to_tiramisu(model.wrapper(LevelUpComplete)),
        ]),
      )
    }
    ResumeGame -> {
      // Set resuming flag but keep paused until pointer lock is acquired
      #(
        Model(..model, resuming: True, resume_retry_count: 0),
        effect.batch([
          effect.from(fn(_) { pointer_lock_request.request_pointer_lock_sync() }),
        ]),
      )
    }
    OpenSettings -> #(Model(..model, is_settings_open: True), effect.none())
    CloseSettings -> #(Model(..model, is_settings_open: False), effect.none())
    CameraDistanceChanged(distance) -> #(
      Model(..model, camera_distance: distance),
      tiramisu_ui.dispatch_to_tiramisu(
        model.wrapper(UpdateCameraDistance(distance)),
      ),
    )
    PointerLockExited -> {
      case model.resuming {
        // If we were trying to resume but pointer lock failed/exited, cancel the resume
        True -> #(Model(..model, resuming: False), effect.none())
        // Only auto-pause if we're actually playing and not in level-up and not already paused and not showing wand selection and not showing perk slot machine
        False ->
          case
            model.game_phase,
            model.spell_rewards,
            model.is_paused,
            model.showing_wand_selection,
            model.perk_slot_machine
          {
            Playing, option.None, False, False, option.None -> #(
              Model(..model, is_paused: True),
              tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GamePaused)),
            )
            _, _, _, _, _ -> #(model, effect.none())
          }
      }
    }
    PointerLockAcquired -> {
      // If we were trying to resume, now actually resume the game
      case model.resuming {
        True -> #(
          Model(
            ..model,
            is_paused: False,
            resuming: False,
            resume_retry_count: 0,
          ),
          tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GameResumed)),
        )
        False -> #(model, effect.none())
      }
    }
    LootPickedUp(loot_type) -> {
      // For perks: show toast and apply immediately
      // For wands: show modal for user to decide
      case loot_type {
        loot.PerkLoot(perk_value) -> {
          // Start the slot machine animation
          #(
            model,
            effect.batch([
              effect.from(fn(dispatch) {
                dispatch(StartPerkSlotMachine(perk_value))
              }),
              tiramisu_ui.dispatch_to_tiramisu(model.wrapper(CloseLootUI)),
              effect.from(fn(_) {
                // Exit pointer lock so user can click the continue button
                let _ = pointer_lock_request.exit_pointer_lock()
                Nil
              }),
            ]),
          )
        }
        loot.WandLoot(new_wand) -> {
          // Show wand selection modal, freeze game, and exit pointer lock
          #(
            Model(
              ..model,
              pending_wand: option.Some(new_wand),
              showing_wand_selection: True,
            ),
            effect.batch([
              tiramisu_ui.dispatch_to_tiramisu(model.wrapper(CloseLootUI)),
              effect.from(fn(_) {
                // Exit pointer lock so user can click buttons
                let _ = pointer_lock_request.exit_pointer_lock()
                Nil
              }),
            ]),
          )
        }
      }
    }
    AcceptWand -> {
      // User accepted the new wand
      case model.pending_wand {
        option.Some(new_wand) -> {
          #(
            Model(
              ..model,
              pending_wand: option.None,
              showing_wand_selection: False,
            ),
            effect.batch([
              tiramisu_ui.dispatch_to_tiramisu(
                model.wrapper(ApplyLoot(loot.WandLoot(new_wand))),
              ),
              tiramisu_ui.dispatch_to_tiramisu(model.wrapper(
                WandSelectionComplete,
              )),
              effect.from(fn(_) {
                pointer_lock_request.request_pointer_lock_sync()
              }),
            ]),
          )
        }
        option.None -> #(model, effect.none())
      }
    }
    RejectWand -> {
      // User rejected the new wand
      #(
        Model(..model, pending_wand: option.None, showing_wand_selection: False),
        effect.batch([
          tiramisu_ui.dispatch_to_tiramisu(model.wrapper(WandSelectionComplete)),
          effect.from(fn(_) { pointer_lock_request.request_pointer_lock_sync() }),
        ]),
      )
    }
    // Debug menu
    ToggleDebugMenu -> {
      // Just toggle the UI state, don't send back to game (game already knows)
      // When closing the debug menu, also ensure we're not in resuming state
      #(
        Model(
          ..model,
          is_debug_menu_open: !model.is_debug_menu_open,
          resuming: case model.is_debug_menu_open {
            True -> False
            False -> model.resuming
          },
        ),
        effect.none(),
      )
    }
    AddSpellToBag(spell_id) -> #(
      model,
      tiramisu_ui.dispatch_to_tiramisu(
        model.wrapper(DebugAddSpellToBag(spell_id)),
      ),
    )
    UpdateWandStat(stat_update) -> #(
      model,
      tiramisu_ui.dispatch_to_tiramisu(
        model.wrapper(DebugUpdateWandStat(stat_update)),
      ),
    )
    SetPaused(is_paused) -> #(
      Model(..model, is_paused: is_paused, resuming: case is_paused {
        False -> False
        True -> model.resuming
      }),
      effect.none(),
    )
    StartPerkSlotMachine(selected_perk) -> {
      // Generate 3 random perks for display
      let reel1 = perk.random()
      let reel2 = perk.random()
      let reel3 = perk.random()

      #(
        Model(
          ..model,
          perk_slot_machine: option.Some(model.SlotMachineState(
            selected_perk:,
            reel1:,
            reel2:,
            reel3:,
            animation_phase: model.Spinning,
            time_elapsed: 0.0,
          )),
        ),
        effect.batch([
          // Notify game to freeze
          tiramisu_ui.dispatch_to_tiramisu(model.wrapper(PerkSlotMachineStarted)),
          // Start animation loop
          schedule_slot_machine_tick(),
        ]),
      )
    }
    UpdateSlotMachineAnimation(delta_time) -> {
      case model.perk_slot_machine {
        option.Some(state) -> {
          let new_time = state.time_elapsed +. delta_time /. 1000.0

          // Update animation phase based on time
          let new_phase = case new_time {
            t if t <. 2.0 -> model.Spinning
            t if t <. 2.5 -> model.StoppingLeft
            t if t <. 3.0 -> model.StoppingMiddle
            t if t <. 3.5 -> model.StoppingRight
            _ ->
              case state.animation_phase {
                model.Stopped -> model.Stopped
                _ -> model.Stopped
              }
          }

          // Randomize reels during spinning phase
          let #(new_reel1, new_reel2, new_reel3) = case new_phase {
            model.Spinning ->
              // Change reels every 100ms
              case float.modulo(new_time *. 1000.0, 100.0) {
                Ok(mod) if mod <. delta_time -> #(
                  perk.random(),
                  perk.random(),
                  perk.random(),
                )
                _ -> #(state.reel1, state.reel2, state.reel3)
              }
            _ -> #(state.reel1, state.reel2, state.reel3)
          }

          let next_effect = case new_phase {
            model.Stopped -> effect.none()
            _ -> schedule_slot_machine_tick()
          }

          #(
            Model(
              ..model,
              perk_slot_machine: option.Some(
                model.SlotMachineState(
                  ..state,
                  time_elapsed: new_time,
                  animation_phase: new_phase,
                  reel1: new_reel1,
                  reel2: new_reel2,
                  reel3: new_reel3,
                ),
              ),
            ),
            next_effect,
          )
        }
        option.None -> #(model, effect.none())
      }
    }
    ClosePerkSlotMachine -> {
      case model.perk_slot_machine {
        option.Some(state) -> #(
          Model(..model, perk_slot_machine: option.None),
          tiramisu_ui.dispatch_to_tiramisu(
            model.wrapper(PerkSlotMachineComplete(state.selected_perk)),
          ),
        )
        option.None -> #(model, effect.none())
      }
    }
    NoOp -> #(model, effect.none())
  }
}

fn reorder_array(
  items: iv.Array(a),
  from_index: Int,
  to_index: Int,
) -> iv.Array(a) {
  case iv.get(items, from_index), iv.delete(items, from_index) {
    Ok(removed_item), Ok(list_without_item) -> {
      case iv.insert(list_without_item, to_index, removed_item) {
        Ok(reordered) -> reordered
        Error(_) -> items
      }
    }
    _, _ -> items
  }
}

/// Schedule a slot machine animation tick (16ms ~= 60fps)
fn schedule_slot_machine_tick() -> effect.Effect(Msg) {
  effect.from(fn(dispatch) {
    global.set_timeout(16, fn() { dispatch(UpdateSlotMachineAnimation(16.0)) })
    Nil
  })
}

// ============================================================================
// VIEW
// ============================================================================

pub fn view(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  case model.game_phase {
    StartScreen ->
      element.map(start_screen.view(), fn(msg) {
        case msg {
          start_screen.StartButtonClicked -> StartButtonClicked
        }
      })
    LoadingScreen -> loading_screen.view()
    Playing -> view_playing(model)
    GameOver ->
      element.map(game_over.view(model.score), fn(msg) {
        case msg {
          game_over.RestartButtonClicked -> RestartButtonClicked
        }
      })
  }
}

fn view_playing(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed top-0 left-0 w-full h-full pointer-events-none select-none font-mono",
      ),
    ],
    list.flatten([
      [view_hud(model), view_xp_bar(model)],
      // Modals and overlays
      case model.spell_rewards {
        option.Some(rewards) -> [view_spell_rewards_modal(model, rewards)]
        option.None -> []
      },
      case model.showing_wand_selection, model.pending_wand {
        True, option.Some(new_wand) -> [
          view_wand_selection_modal(model, new_wand),
        ]
        _, _ -> []
      },
      case model.is_paused {
        True -> [view_pause_menu_modal(model)]
        False -> []
      },
      case model.is_debug_menu_open {
        True -> [view_debug_menu_modal(model)]
        False -> []
      },
      case model.perk_slot_machine {
        option.Some(state) -> [
          perk_slot_machine.view(state, ClosePerkSlotMachine),
        ]
        option.None -> []
      },
    ]),
  )
}

fn view_hud(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "absolute top-4 left-4 p-4 bg-gradient-to-br from-purple-900/90 to-indigo-900/90 border-4 border-amber-400 rounded-lg shadow-2xl",
      ),
      attribute.style("image-rendering", "pixelated"),
      attribute.style("backdrop-filter", "blur(4px)"),
      attribute.style("z-index", "350"),
    ],
    [
      // Health section
      html.div([attribute.class("mb-4")], [
        html.div([attribute.class("text-gray-300 text-sm mb-1")], [
          html.text(
            float_to_string_rounded(model.player_health)
            <> " / "
            <> float_to_string_rounded(model.player_max_health),
          ),
        ]),
        render_pixel_bar(
          current: model.player_health,
          max: model.player_max_health,
          color_class: health_color_class(
            model.player_health,
            model.player_max_health,
          ),
          bg_class: "bg-red-950",
        ),
      ]),
      // Mana section
      html.div([attribute.class("mb-4")], [
        html.div([attribute.class("text-gray-300 text-sm mb-1")], [
          html.text(
            float_to_string_rounded(model.player_mana)
            <> " / "
            <> float_to_string_rounded(model.player_max_mana),
          ),
        ]),
        render_pixel_bar(
          current: model.player_mana,
          max: model.player_max_mana,
          color_class: "bg-blue-500",
          bg_class: "bg-blue-950",
        ),
      ]),
      // Wand section
      html.div([], [
        render_cast_delay_bar(
          model.time_since_last_cast,
          model.cast_delay,
          model.recharge_time,
          model.current_spell_index,
          iv.length(model.wand_slots),
          model.is_recharging,
        ),
        render_wand_slots(
          model.wand_slots,
          model.drag_state,
          model.casting_spell_indices,
        ),
      ]),
      // Score section
      html.div([attribute.class("mb-4")], [
        html.div([attribute.class("text-gray-300 text-sm m-1")], [
          html.text(float_to_string_rounded(model.score.total_score)),
        ]),
        // Streak display
        case model.score.current_multiplier >. 1.0 {
          True ->
            html.div([attribute.class("text-orange-400 text-xs")], [
              html.text(
                "STREAK: "
                <> float.to_string(float.to_precision(
                  model.score.current_multiplier,
                  2,
                ))
                <> "x",
              ),
            ])
          False ->
            html.div([attribute.class("text-gray-500 text-xs")], [
              html.text("No streak"),
            ])
        },
      ]),
    ],
  )
}

fn view_xp_bar(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  let xp_percentage = case model.player_xp_to_next_level > 0 {
    True ->
      int.to_float(model.player_xp)
      /. int.to_float(model.player_xp_to_next_level)
      *. 100.0
    False -> 100.0
  }

  html.div(
    [
      attribute.class(
        "absolute bottom-0 left-0 right-0 h-8 bg-gradient-to-r from-purple-900/90 to-indigo-900/90 border-t-4 border-amber-400 shadow-2xl",
      ),
      attribute.style("z-index", "350"),
    ],
    [
      // XP bar fill
      html.div(
        [
          attribute.class(
            "h-full bg-gradient-to-r from-yellow-400 to-amber-500 duration-300 relative overflow-hidden",
          ),
          attribute.style("width", float.to_string(xp_percentage) <> "%"),
        ],
        [
          // Shimmer effect
          html.div(
            [
              attribute.class("absolute inset-0 opacity-30"),
              attribute.style(
                "background",
                "linear-gradient(90deg, transparent, rgba(255,255,255,0.5), transparent)",
              ),
            ],
            [],
          ),
        ],
      ),
      // Level and XP text overlay
      html.div(
        [
          attribute.class(
            "absolute inset-0 flex items-center justify-center text-white font-bold text-sm",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.8)"),
        ],
        [
          html.text(
            "LEVEL "
            <> int.to_string(model.player_level)
            <> " • "
            <> int.to_string(model.player_xp)
            <> " / "
            <> int.to_string(model.player_xp_to_next_level)
            <> " XP",
          ),
        ],
      ),
    ],
  )
}

fn view_spell_rewards_modal(
  model: Model(tiramisu_msg),
  rewards: List(spell.Spell),
) -> element.Element(Msg) {
  let inventory_section =
    html.div([], [
      // Wand section
      html.div([], [
        html.div([attribute.class("flex items-center gap-2 mb-3")], [
          html.span([attribute.class("text-amber-400 text-2xl")], [
            html.text("⚡"),
          ]),
          html.span([attribute.class("text-white font-bold text-xl")], [
            html.text("WAND SLOTS"),
          ]),
        ]),
        render_wand_slots(
          model.wand_slots,
          model.drag_state,
          model.casting_spell_indices,
        ),
      ]),
      // Spell bag section
      html.div([attribute.class("mt-6")], [
        html.div([attribute.class("flex items-center gap-2 mb-3")], [
          html.span([attribute.class("text-purple-400 text-2xl")], [
            html.text("🎒"),
          ]),
          html.span([attribute.class("text-white font-bold text-xl")], [
            html.text("SPELL BAG"),
          ]),
        ]),
        render_spell_bag(model.spell_bag, model.drag_state),
      ]),
    ])

  element.map(spell_rewards.view(rewards, inventory_section), fn(msg) {
    case msg {
      spell_rewards.SpellRewardClicked(spell) -> SpellRewardClicked(spell)
      spell_rewards.DoneWithLevelUp -> DoneWithLevelUp
      spell_rewards.InventoryMsg(ui_msg) -> ui_msg
    }
  })
}

fn view_wand_selection_modal(
  model: Model(tiramisu_msg),
  new_wand: wand.Wand,
) -> element.Element(Msg) {
  element.map(
    wand_selection.view(
      model.wand_slots,
      model.wand_max_mana,
      model.wand_mana_recharge_rate,
      model.wand_cast_delay,
      model.wand_recharge_time,
      model.wand_capacity,
      model.wand_spread,
      new_wand,
    ),
    fn(msg) {
      case msg {
        wand_selection.AcceptWand -> AcceptWand
        wand_selection.RejectWand -> RejectWand
      }
    },
  )
}

fn view_pause_menu_modal(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  element.map(
    pause_menu.view(
      model.is_settings_open,
      model.resuming,
      model.camera_distance,
    ),
    fn(msg) {
      case msg {
        pause_menu.ResumeGame -> ResumeGame
        pause_menu.OpenSettings -> OpenSettings
        pause_menu.CloseSettings -> CloseSettings
        pause_menu.CameraDistanceChanged(distance) ->
          CameraDistanceChanged(distance)
      }
    },
  )
}

fn view_debug_menu_modal(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 bg-black/70 flex items-center justify-center pointer-events-auto z-[1000]",
      ),
    ],
    [
      html.div(
        [
          attribute.class(
            "bg-gradient-to-br from-purple-900 to-indigo-900 p-8 rounded-xl shadow-2xl border-4 border-amber-400 max-w-6xl max-h-[90vh] overflow-y-auto",
          ),
        ],
        [
          // Title
          html.div([attribute.class("flex justify-between items-center mb-6")], [
            html.h2([attribute.class("text-3xl font-bold text-amber-400")], [
              html.text("DEBUG MENU"),
            ]),
            html.div([attribute.class("text-gray-300 text-sm")], [
              html.text("Press M to close"),
            ]),
          ]),
          // Three column layout
          html.div([attribute.class("grid grid-cols-3 gap-6")], [
            // Left column - Add Spells & Inventory
            html.div([], [
              element.map(
                debug_menu.view(
                  model.wand_max_mana,
                  model.wand_mana_recharge_rate,
                  model.wand_cast_delay,
                  model.wand_recharge_time,
                  model.wand_capacity,
                  model.wand_spread,
                ),
                fn(msg) {
                  case msg {
                    debug_menu.AddSpellToBag(spell_id) ->
                      AddSpellToBag(spell_id)
                    debug_menu.UpdateWandStat(stat_update) ->
                      UpdateWandStat(stat_update)
                    debug_menu.NoOp -> NoOp
                  }
                },
              ),
              // Wand Slots
              html.div(
                [
                  attribute.class("mt-6 pt-6 border-t-2 border-amber-500/50"),
                ],
                [
                  html.div([attribute.class("flex items-center gap-2 mb-3")], [
                    html.span([attribute.class("text-amber-400 text-sm")], [
                      html.text("⚡"),
                    ]),
                    html.span(
                      [attribute.class("text-amber-300 font-bold text-sm")],
                      [html.text("WAND SLOTS")],
                    ),
                  ]),
                  render_wand_slots(
                    model.wand_slots,
                    model.drag_state,
                    model.casting_spell_indices,
                  ),
                ],
              ),
              // Spell Bag
              html.div(
                [
                  attribute.class("mt-6 pt-6 border-t-2 border-purple-500/50"),
                ],
                [
                  html.div([attribute.class("flex items-center gap-2 mb-3")], [
                    html.span([attribute.class("text-purple-400 text-sm")], [
                      html.text("🎒"),
                    ]),
                    html.span(
                      [attribute.class("text-purple-300 font-bold text-sm")],
                      [html.text("SPELL BAG")],
                    ),
                  ]),
                  render_spell_bag(model.spell_bag, model.drag_state),
                ],
              ),
            ]),
          ]),
        ],
      ),
    ],
  )
}

// ============================================================================
// HELPER RENDERING FUNCTIONS
// ============================================================================

fn render_pixel_bar(
  current current: Float,
  max max: Float,
  color_class color_class: String,
  bg_class bg_class: String,
) -> element.Element(Msg) {
  let percentage = case max >. 0.0 {
    True -> { current /. max } *. 100.0
    False -> 0.0
  }

  html.div(
    [
      attribute.class(
        "w-48 h-6 "
        <> bg_class
        <> " border-2 border-amber-600 relative overflow-hidden",
      ),
      attribute.style("image-rendering", "pixelated"),
    ],
    [
      html.div(
        [
          attribute.class(color_class <> " h-full duration-300"),
          attribute.style("width", float.to_string(percentage) <> "%"),
        ],
        [],
      ),
      html.div(
        [
          attribute.class("absolute inset-0 opacity-20 pointer-events-none"),
          attribute.style("box-shadow", "inset 0 2px 4px rgba(0,0,0,0.5)"),
        ],
        [],
      ),
    ],
  )
}

fn health_color_class(current: Float, max: Float) -> String {
  let percentage = case max >. 0.0 {
    True -> { current /. max } *. 100.0
    False -> 0.0
  }

  case percentage {
    p if p >. 60.0 -> "bg-green-500"
    p if p >. 30.0 -> "bg-yellow-500"
    _ -> "bg-red-500"
  }
}

fn render_cast_delay_bar(
  time_since_last_cast: Float,
  cast_delay: Float,
  recharge_time: Float,
  current_spell_index: Int,
  total_slots: Int,
  is_recharging: Bool,
) -> element.Element(Msg) {
  let total_cycle_time = case is_recharging {
    True -> recharge_time
    False -> cast_delay
  }

  let progress_percentage = case total_cycle_time >. 0.0 {
    True -> float.min(time_since_last_cast /. total_cycle_time *. 100.0, 100.0)
    False -> 100.0
  }

  let bar_color = case is_recharging {
    True -> "bg-purple-500"
    False -> "bg-yellow-500"
  }

  let status_text = case is_recharging {
    True -> "RECHARGE"
    False ->
      "CAST "
      <> int.to_string(current_spell_index + 1)
      <> "/"
      <> int.to_string(total_slots)
  }

  html.div([attribute.class("mb-2")], [
    html.div([attribute.class("text-gray-300 text-xs mb-1")], [
      html.text(status_text),
    ]),
    html.div(
      [
        attribute.class(
          "w-48 h-2 bg-gray-800 border border-amber-600 relative overflow-hidden",
        ),
      ],
      [
        html.div(
          [
            attribute.class(bar_color <> " h-full"),
            attribute.style(
              "width",
              float.to_string(progress_percentage) <> "%",
            ),
          ],
          [],
        ),
      ],
    ),
  ])
}

fn render_wand_slots(
  slots: iv.Array(option.Option(spell.Spell)),
  drag_state: ensaimada.DragState,
  casting_indices: List(Int),
) -> element.Element(Msg) {
  let sortable_items =
    slots
    |> iv.to_list()
    |> list.index_map(fn(slot, index) {
      ensaimada.item("wand-" <> int.to_string(index), #(slot, index))
    })

  let config =
    ensaimada.Config(
      on_reorder: fn(_from, _to) { WandSortableMsg(ensaimada.UserMsg(NoOp)) },
      container_id: "wand-slots",
      container_class: "flex gap-2 pointer-events-auto",
      item_class: "sortable-item",
      dragging_class: "opacity-50 scale-105",
      drag_over_class: "ring-2 ring-blue-400",
      ghost_class: "opacity-30",
      accept_from: ["spell-bag"],
    )

  element.map(
    ensaimada.container(config, drag_state, sortable_items, fn(item, idx, ds) {
      render_wand_slot_item(item, idx, ds, casting_indices)
    }),
    WandSortableMsg,
  )
}

fn render_wand_slot_item(
  item: ensaimada.Item(#(option.Option(spell.Spell), Int)),
  _index: Int,
  _drag_state: ensaimada.DragState,
  casting_indices: List(Int),
) -> element.Element(Msg) {
  let #(slot, slot_index) = ensaimada.item_data(item)
  let is_casting = list.contains(casting_indices, slot_index)

  let #(content_element, tooltip) = case slot {
    option.Some(spell_item) -> {
      let sprite_path = spell_ui_sprite(spell_item)
      let tooltip_text = spell_tooltip(spell_item)
      #(
        html.img([
          attribute.src(sprite_path),
          attribute.class("w-full h-full object-contain"),
          attribute.style("image-rendering", "pixelated"),
        ]),
        tooltip_text,
      )
    }
    option.None -> #(html.div([], []), "")
  }

  let border_class = case is_casting {
    True ->
      "border-4 border-yellow-400 animate-pulse shadow-[0_0_10px_rgba(250,204,21,0.8)]"
    False -> "border-2"
  }

  let tooltip_attrs = case tooltip {
    "" -> []
    text -> [attribute.attribute("title", text)]
  }

  html.div(
    list.flatten([
      [
        attribute.class(
          "w-12 h-12 "
          <> border_class
          <> " flex items-center justify-center shadow-lg relative hover:scale-110 cursor-move pointer-events-auto",
        ),
        attribute.style("image-rendering", "pixelated"),
      ],
      tooltip_attrs,
    ]),
    [
      content_element,
      html.div(
        [
          attribute.class("absolute inset-0 opacity-20 pointer-events-none"),
          attribute.style("box-shadow", "inset 0 2px 4px rgba(0,0,0,0.5)"),
        ],
        [],
      ),
    ],
  )
}

fn render_spell_bag(
  spell_bag: spell_bag.SpellBag,
  drag_state: ensaimada.DragState,
) -> element.Element(Msg) {
  let spell_stacks = spell_bag.list_spell_stacks(spell_bag)

  let sortable_items =
    spell_stacks
    |> list.index_map(fn(stack, index) {
      ensaimada.item("bag-" <> int.to_string(index), stack)
    })

  let config =
    ensaimada.Config(
      on_reorder: fn(_from, _to) { BagSortableMsg(ensaimada.UserMsg(NoOp)) },
      container_id: "spell-bag",
      container_class: "grid grid-cols-4 gap-2 pointer-events-auto",
      item_class: "sortable-item",
      dragging_class: "opacity-50 scale-105",
      drag_over_class: "[&>div]:ring-2 [&>div]:ring-purple-400",
      ghost_class: "opacity-30",
      accept_from: ["wand-slots"],
    )

  element.map(
    ensaimada.container(
      config,
      drag_state,
      sortable_items,
      render_spell_bag_item,
    ),
    BagSortableMsg,
  )
}

fn render_spell_bag_item(
  item: ensaimada.Item(#(spell.Spell, Int)),
  _index: Int,
  _drag_state: ensaimada.DragState,
) -> element.Element(Msg) {
  let #(spell_item, count) = ensaimada.item_data(item)
  let sprite_path = spell_ui_sprite(spell_item)
  let tooltip_text = spell_tooltip(spell_item)
  let #(bg_class, border_class) = case spell_item {
    spell.DamageSpell(_, _) -> #("bg-red-600", "border-red-400")
    spell.ModifierSpell(_, _) -> #("bg-green-600", "border-green-400")
    spell.MulticastSpell(_, _) -> #("bg-purple-600", "border-purple-400")
  }

  let tooltip_attrs = case tooltip_text {
    "" -> []
    text -> [attribute.attribute("title", text)]
  }

  html.div(
    list.flatten([
      [
        attribute.class(
          "relative w-12 h-12 "
          <> bg_class
          <> " border-2 "
          <> border_class
          <> " flex items-center justify-center shadow-lg hover:scale-110 cursor-move pointer-events-auto",
        ),
        attribute.style("image-rendering", "pixelated"),
      ],
      tooltip_attrs,
    ]),
    [
      html.img([
        attribute.src(sprite_path),
        attribute.class("w-full h-full object-contain p-1"),
        attribute.style("image-rendering", "pixelated"),
      ]),
      // Count badge
      case count > 1 {
        True ->
          html.div(
            [
              attribute.class(
                "absolute -bottom-1 -right-1 w-5 h-5 bg-yellow-500 border border-yellow-300 rounded-full flex items-center justify-center text-xs font-bold text-black",
              ),
            ],
            [html.text(int.to_string(count))],
          )
        False -> html.div([], [])
      },
    ],
  )
}

fn spell_ui_sprite(spell_item: spell.Spell) -> String {
  case spell_item {
    spell.DamageSpell(_, damage_spell) -> damage_spell.ui_sprite
    spell.ModifierSpell(_, modifier_spell) -> modifier_spell.ui_sprite
    spell.MulticastSpell(_, multicast_spell) -> multicast_spell.ui_sprite
  }
}

fn spell_tooltip(spell_item: spell.Spell) -> String {
  case spell_item {
    spell.DamageSpell(_, damage_spell) -> {
      let stats = [
        damage_spell.name,
        "─────────────",
        "Damage: "
          <> float.to_string(float.to_precision(damage_spell.damage, 1)),
        "Speed: "
          <> float.to_string(float.to_precision(
          damage_spell.projectile_speed,
          1,
        )),
        "Lifetime: "
          <> float.to_string(float.to_precision(
          damage_spell.projectile_lifetime,
          1,
        ))
          <> "s",
        "Size: "
          <> float.to_string(float.to_precision(damage_spell.projectile_size, 1)),
        "Mana: "
          <> float.to_string(float.to_precision(damage_spell.mana_cost, 1)),
      ]

      let stats = case damage_spell.cast_delay_addition {
        0.0 -> stats
        delay -> [
          "Cast Delay: +"
            <> float.to_string(float.to_precision(delay, 2))
            <> "s",
          ..stats
        ]
      }

      let stats = case damage_spell.critical_chance {
        0.0 -> stats
        crit -> {
          let crit_percent =
            float.to_string(float.to_precision(crit *. 100.0, 1))
          ["Crit Chance: " <> crit_percent <> "%", ..stats]
        }
      }

      let stats = case damage_spell.spread {
        0.0 -> stats
        spread -> [
          "Spread: +" <> float.to_string(float.to_precision(spread, 1)) <> "°",
          ..stats
        ]
      }

      string.join(list.reverse(stats), "\n")
    }
    spell.ModifierSpell(_, _) -> "Modifier spell"
    spell.MulticastSpell(_, _) -> "Multicast spell"
  }
}

fn float_to_string_rounded(value: Float) -> String {
  float.to_string(float.to_precision(value, 0))
}

pub fn start(wrapper: fn(UiToGameMsg) -> a) -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#ui", wrapper)
  Nil
}
