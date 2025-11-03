import ensaimada
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import grille_pain
import grille_pain/lustre/toast
import iv
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import pondering_my_orb/loot
import pondering_my_orb/perk
import pondering_my_orb/pointer_lock
import pondering_my_orb/pointer_lock_request
import pondering_my_orb/score
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/wand
import tiramisu/ui as tiramisu_ui

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
    // Wand stats
    wand_max_mana: Float,
    wand_mana_recharge_rate: Float,
    wand_cast_delay: Float,
    wand_recharge_time: Float,
    wand_capacity: Int,
    wand_spread: Float,
  )
}

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
      io.println("=== UI: Spell Reward Clicked ===")
      let spell_name = case selected_spell {
        spell.DamageSpell(_, dmg) -> dmg.name
        spell.ModifierSpell(_, mod) -> mod.name
        spell.MulticastSpell(_, multicast) -> multicast.name
      }
      io.println("UI: Clicked spell: " <> spell_name)

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
      io.println("=== UI: Done with Level Up ===")
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
      io.println("=== UI: Resume Requested - Requesting Pointer Lock ===")
      // Set resuming flag but keep paused until pointer lock is acquired
      // Set up automatic retry every 500ms
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
      io.println("=== UI: Pointer Lock Exited ===")
      case model.resuming {
        // If we were trying to resume but pointer lock failed/exited, cancel the resume
        True -> {
          io.println(
            "=== UI: Pointer Lock Failed During Resume - Staying Paused ===",
          )
          #(Model(..model, resuming: False), effect.none())
        }
        // Only auto-pause if we're actually playing and not in level-up and not already paused and not showing wand selection
        False ->
          case
            model.game_phase,
            model.spell_rewards,
            model.is_paused,
            model.showing_wand_selection
          {
            Playing, option.None, False, False -> {
              io.println("=== UI: Pointer Lock Exited - Auto Pausing ===")
              #(
                Model(..model, is_paused: True),
                tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GamePaused)),
              )
            }
            _, _, _, _ -> #(model, effect.none())
          }
      }
    }
    PointerLockAcquired -> {
      io.println("=== UI: Pointer Lock Acquired ===")
      // If we were trying to resume, now actually resume the game
      case model.resuming {
        True -> {
          io.println("=== UI: Resuming Game Now ===")
          #(
            Model(
              ..model,
              is_paused: False,
              resuming: False,
              resume_retry_count: 0,
            ),
            tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GameResumed)),
          )
        }
        False -> #(model, effect.none())
      }
    }
    LootPickedUp(loot_type) -> {
      // For perks: show toast and apply immediately
      // For wands: show modal for user to decide
      case loot_type {
        loot.PerkLoot(perk_value) -> {
          let perk_info = perk.get_info(perk_value)
          let toast_message =
            "⭐ " <> perk_info.name <> " (" <> perk_info.description <> ")"

          #(
            model,
            effect.batch([
              toast.toast(toast_message),
              tiramisu_ui.dispatch_to_tiramisu(
                model.wrapper(ApplyLoot(loot_type)),
              ),
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
    AddSpellToBag(spell) -> #(
      model,
      tiramisu_ui.dispatch_to_tiramisu(model.wrapper(DebugAddSpellToBag(spell))),
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

pub fn view(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  case model.game_phase {
    StartScreen -> view_start_screen()
    LoadingScreen -> view_loading_screen()
    Playing -> view_playing(model)
    GameOver -> view_game_over_screen(model)
  }
}

fn view_start_screen() -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-purple-900 via-indigo-900 to-black",
      ),
    ],
    [
      // Title
      html.div([attribute.class("text-center mb-12 pointer-events-auto")], [
        html.h1(
          [
            attribute.class(
              "text-7xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-amber-400 to-orange-500 mb-4",
            ),
            attribute.style("text-shadow", "0 0 30px rgba(251, 191, 36, 0.5)"),
          ],
          [html.text("PONDERING MY ORB")],
        ),
        html.p([attribute.class("text-2xl text-purple-300")], [
          html.text("A Magical Spell-Casting Adventure"),
        ]),
      ]),

      // Start button
      html.button(
        [
          attribute.class(
            "px-12 py-6 text-3xl font-bold bg-gradient-to-r from-amber-500 to-orange-600 text-white rounded-lg shadow-2xl hover:scale-110 transform transition-all duration-200 border-4 border-amber-300 pointer-events-auto cursor-pointer",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          event.on_click(StartButtonClicked),
        ],
        [html.text("START GAME")],
      ),

      // Controls info
      html.div(
        [
          attribute.class(
            "absolute bottom-8 left-1/2 transform -translate-x-1/2 text-center text-purple-300 pointer-events-none",
          ),
        ],
        [
          html.p([attribute.class("mb-2")], [html.text("Controls:")]),
          html.p([attribute.class("text-sm")], [
            html.text(
              "WASD - Move | Mouse - Look | ESC - Pause | SPACE - Resume",
            ),
          ]),
        ],
      ),
    ],
  )
}

fn view_loading_screen() -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-purple-900 via-indigo-900 to-black",
      ),
    ],
    [
      html.div([attribute.class("text-center")], [
        html.h2(
          [
            attribute.class("text-5xl font-bold text-amber-400 mb-8"),
            attribute.style("text-shadow", "0 0 20px rgba(251, 191, 36, 0.5)"),
          ],
          [html.text("Loading...")],
        ),

        // Animated loading indicator
        html.div(
          [attribute.class("flex gap-3 justify-center")],
          list.map([1, 2, 3, 4, 5], fn(i) {
            html.div(
              [
                attribute.class(
                  "w-4 h-4 bg-amber-400 rounded-full animate-pulse",
                ),
                attribute.style(
                  "animation-delay",
                  float.to_string(int.to_float(i) *. 0.2) <> "s",
                ),
              ],
              [],
            )
          }),
        ),

        html.p([attribute.class("mt-8 text-purple-300 text-xl")], [
          html.text("Preparing your magical arsenal..."),
        ]),
      ]),
    ],
  )
}

fn view_playing(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed top-0 left-0 w-full h-full pointer-events-none select-none font-mono",
      ),
    ],
    [
      // Top left corner - Player stats (always visible, never blurred)
      html.div(
        [
          attribute.class(
            "absolute top-4 left-4 p-4 bg-gradient-to-br from-purple-900/90 to-indigo-900/90 border-4 border-amber-400 rounded-lg shadow-2xl",
          ),
          attribute.style("image-rendering", "pixelated"),
          attribute.style("backdrop-filter", "blur(4px)"),
          attribute.style("z-index", "350"),
        ],
        list.flatten([
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
              // Cast delay bar
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
        ]),
      ),
      // XP bar at bottom of screen
      html.div(
        [
          attribute.class(
            "absolute bottom-0 left-0 w-full p-4 bg-gradient-to-t from-black/80 to-transparent pointer-events-none",
          ),
          attribute.style("z-index", "150"),
        ],
        [
          html.div(
            [
              attribute.class("max-w-screen-lg mx-auto flex items-center gap-4"),
            ],
            [
              // Level indicator
              html.div(
                [
                  attribute.class(
                    "px-4 py-2 bg-gradient-to-br from-amber-600 to-orange-600 border-2 border-amber-400 rounded-lg shadow-lg",
                  ),
                  attribute.style("image-rendering", "pixelated"),
                ],
                [
                  html.div([attribute.class("text-white font-bold text-xl")], [
                    html.text("LV " <> int.to_string(model.player_level)),
                  ]),
                ],
              ),
              // XP bar
              html.div([attribute.class("flex-1")], [
                html.div([attribute.class("text-amber-300 text-sm mb-1")], [
                  html.text(
                    int.to_string(model.player_xp)
                    <> " / "
                    <> int.to_string(model.player_xp_to_next_level)
                    <> " XP",
                  ),
                ]),
                render_xp_bar(
                  current: int.to_float(model.player_xp),
                  max: int.to_float(model.player_xp_to_next_level),
                ),
              ]),
            ],
          ),
        ],
      ),
      // Spell rewards modal - only show when rewards are available
      case model.spell_rewards {
        option.Some(rewards) -> view_spell_rewards_modal(model, rewards)
        option.None -> html.div([], [])
      },
      // Pause menu - show when paused or resuming (but not during level-up, wand selection, or debug menu)
      case
        model.is_paused,
        model.resuming,
        model.spell_rewards,
        model.showing_wand_selection,
        model.is_debug_menu_open
      {
        True, _, option.None, False, False | _, True, option.None, False, False ->
          view_pause_menu(model)
        _, _, _, _, _ -> html.div([], [])
      },
      // Wand selection modal
      case model.showing_wand_selection, model.pending_wand {
        True, option.Some(new_wand) ->
          view_wand_selection_modal(model, new_wand)
        _, _ -> html.div([], [])
      },
      // Debug menu
      case model.is_debug_menu_open {
        True -> view_debug_menu(model)
        False -> html.div([], [])
      },
    ],
  )
}

fn view_spell_rewards_modal(
  model: Model(tiramisu_msg),
  rewards: List(spell.Spell),
) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center bg-black/70 backdrop-blur-sm pointer-events-auto overflow-y-auto",
      ),
      attribute.style("z-index", "300"),
    ],
    [
      html.div(
        [
          attribute.class(
            "p-8 bg-gradient-to-br from-amber-900/95 to-orange-900/95 border-4 border-yellow-400 rounded-lg shadow-2xl max-w-4xl my-8",
          ),
          attribute.style("image-rendering", "pixelated"),
        ],
        [
          // Title
          html.div([attribute.class("text-center mb-6")], [
            html.h2(
              [
                attribute.class("text-4xl font-bold text-yellow-300 mb-2"),
                attribute.style(
                  "text-shadow",
                  "0 0 20px rgba(251, 191, 36, 0.8)",
                ),
              ],
              [html.text("LEVEL UP!")],
            ),
            html.p([attribute.class("text-xl text-yellow-100")], [
              html.text("Choose a spell and organize your inventory"),
            ]),
          ]),
          // Spell options
          html.div(
            [attribute.class("flex gap-6 justify-center mb-8")],
            list.map(rewards, fn(reward_spell) {
              view_spell_reward_card(reward_spell)
            }),
          ),
          // Inventory management section
          html.div(
            [
              attribute.class(
                "border-t-4 border-yellow-600/50 pt-6 mb-6 space-y-6",
              ),
            ],
            [
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
              html.div([], [
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
            ],
          ),
          // Done button
          html.div([attribute.class("flex justify-center")], [
            html.button(
              [
                attribute.class(
                  "px-8 py-4 text-2xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-green-400 cursor-pointer",
                ),
                attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
                event.on_click(DoneWithLevelUp),
              ],
              [html.text("DONE")],
            ),
          ]),
        ],
      ),
    ],
  )
}

fn view_wand_selection_modal(
  model: Model(tiramisu_msg),
  new_wand: wand.Wand,
) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center z-50 bg-black bg-opacity-75 p-4 pointer-events-auto",
      ),
    ],
    [
      html.div(
        [
          attribute.class(
            "bg-gradient-to-br from-purple-900 to-blue-900 rounded-lg shadow-2xl max-w-5xl w-full p-8 border-4 border-yellow-400",
          ),
        ],
        [
          // Title
          html.h2(
            [
              attribute.class(
                "text-4xl font-bold text-center mb-6 text-yellow-300",
              ),
              attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.7)"),
            ],
            [html.text("🪄 New Wand Found!")],
          ),
          // Comparison container
          html.div([attribute.class("grid grid-cols-2 gap-8 mb-8")], [
            // Current wand
            view_wand_display(
              "Your Current Wand",
              model.wand_slots,
              model.wand_max_mana,
              model.wand_mana_recharge_rate,
              model.wand_cast_delay,
              model.wand_recharge_time,
              model.wand_capacity,
              model.wand_spread,
            ),
            // New wand
            view_wand_display(
              "New Wand",
              new_wand.slots,
              new_wand.max_mana,
              new_wand.mana_recharge_rate,
              new_wand.cast_delay,
              new_wand.recharge_time,
              iv.length(new_wand.slots),
              new_wand.spread,
            ),
          ]),
          // Buttons
          html.div([attribute.class("flex gap-4 justify-center")], [
            html.button(
              [
                attribute.class(
                  "px-8 py-3 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg text-xl transition-colors cursor-pointer",
                ),
                attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
                event.on_click(RejectWand),
              ],
              [html.text("Keep Current")],
            ),
            html.button(
              [
                attribute.class(
                  "px-8 py-3 bg-green-600 hover:bg-green-700 text-white font-bold rounded-lg text-xl transition-colors cursor-pointer",
                ),
                attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
                event.on_click(AcceptWand),
              ],
              [html.text("Take New Wand")],
            ),
          ]),
        ],
      ),
    ],
  )
}

fn view_wand_display(
  title: String,
  slots: iv.Array(option.Option(spell.Spell)),
  max_mana: Float,
  mana_recharge_rate: Float,
  cast_delay: Float,
  recharge_time: Float,
  capacity: Int,
  spread: Float,
) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "bg-gray-800 bg-opacity-50 rounded-lg p-6 border-2 border-gray-600",
      ),
    ],
    [
      html.h3(
        [
          attribute.class("text-2xl font-bold mb-4 text-center text-blue-200"),
          attribute.style("text-shadow", "1px 1px 2px rgba(0,0,0,0.7)"),
        ],
        [html.text(title)],
      ),
      // Wand stats
      html.div([attribute.class("mb-4 space-y-2")], [
        view_wand_stat_compact("Max Mana", max_mana, ""),
        view_wand_stat_compact("Mana Regen", mana_recharge_rate, "/s"),
        view_wand_stat_compact("Cast Delay", cast_delay, "s"),
        view_wand_stat_compact("Recharge", recharge_time, "s"),
        view_wand_stat_compact("Capacity", int.to_float(capacity), ""),
        view_wand_stat_compact("Spread", spread, "°"),
      ]),
      // Spell slots
      html.div([attribute.class("space-y-2")], [
        html.div(
          [
            attribute.class(
              "text-sm font-semibold text-gray-300 mb-2 text-center",
            ),
          ],
          [html.text("Spells:")],
        ),
        html.div(
          [attribute.class("grid grid-cols-3 gap-2")],
          iv.to_list(slots)
            |> list.map(view_spell_slot),
        ),
      ]),
    ],
  )
}

fn view_spell_slot(
  spell_opt: option.Option(spell.Spell),
) -> element.Element(Msg) {
  case spell_opt {
    option.Some(spell_value) -> {
      let #(sprite_path, name) = case spell_value {
        spell.DamageSpell(_, dmg_spell) -> #(
          dmg_spell.ui_sprite,
          dmg_spell.name,
        )
        spell.ModifierSpell(_, mod_spell) -> #(
          mod_spell.ui_sprite,
          mod_spell.name,
        )
        spell.MulticastSpell(_, multicast_spell) -> #(
          multicast_spell.ui_sprite,
          multicast_spell.name,
        )
      }

      html.div(
        [
          attribute.class(
            "bg-gray-700 rounded p-2 flex flex-col items-center justify-center hover:bg-gray-600 transition-colors",
          ),
          attribute.attribute("title", name),
        ],
        [
          html.img([
            attribute.src(sprite_path),
            attribute.class("w-12 h-12 pixelated"),
            attribute.alt(name),
          ]),
          html.div([attribute.class("text-xs text-center mt-1 text-gray-200")], [
            html.text(name),
          ]),
        ],
      )
    }
    option.None ->
      html.div(
        [
          attribute.class(
            "bg-gray-800 rounded p-2 h-20 flex items-center justify-center border-2 border-dashed border-gray-600",
          ),
        ],
        [
          html.span([attribute.class("text-gray-500 text-xs")], [
            html.text("Empty"),
          ]),
        ],
      )
  }
}

fn view_pause_menu(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center bg-black/70 pointer-events-auto",
      ),
      attribute.style("z-index", "300"),
    ],
    [
      html.div(
        [
          attribute.class(
            "p-12 bg-gradient-to-br from-purple-900/95 to-indigo-900/95 border-4 border-blue-400 rounded-lg shadow-2xl",
          ),
          attribute.style("image-rendering", "pixelated"),
        ],
        case model.is_settings_open {
          True -> view_settings_menu(model)
          False -> view_pause_menu_content(model.resuming, model)
        },
      ),
    ],
  )
}

fn view_pause_menu_content(
  resuming: Bool,
  _model: Model(tiramisu_msg),
) -> List(element.Element(Msg)) {
  [
    // Title
    html.div([attribute.class("text-center mb-8")], [
      html.h2(
        [
          attribute.class("text-5xl font-bold text-blue-300 mb-4"),
          attribute.style("text-shadow", "0 0 20px rgba(147, 197, 253, 0.8)"),
        ],
        [
          html.text(case resuming {
            True -> "RESUMING..."
            False -> "PAUSED"
          }),
        ],
      ),
      html.p([attribute.class("text-xl text-blue-100")], [
        html.text(case resuming {
          True -> "Resuming game..."
          False -> "Game is paused"
        }),
      ]),
    ]),
    html.div([attribute.class("flex flex-col gap-4 items-center mb-4")], [
      html.button(
        [
          attribute.class(
            "px-12 py-4 text-2xl font-bold bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-purple-400 cursor-pointer min-w-[300px]",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          attribute.disabled(resuming),
          event.on_click(OpenSettings),
        ],
        [html.text("SETTINGS")],
      ),
    ]),
    // Resume button (disabled when resuming)
    html.div([attribute.class("flex flex-col gap-4 items-center")], [
      html.button(
        [
          attribute.class(case resuming {
            True ->
              "px-12 py-4 text-2xl font-bold bg-gradient-to-r from-gray-600 to-gray-700 text-gray-300 rounded-lg shadow-xl border-4 border-gray-500 cursor-not-allowed min-w-[300px] opacity-50"
            False ->
              "px-12 py-4 text-2xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-green-400 cursor-pointer min-w-[300px]"
          }),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          attribute.disabled(resuming),
          event.on_click(ResumeGame),
        ],
        [html.text("RESUME")],
      ),
      html.div([attribute.class("text-sm text-blue-200 mt-4")], [
        html.text(case resuming {
          True -> "Please wait..."
          False -> "Press SPACE to resume"
        }),
      ]),
    ]),
  ]
}

fn view_settings_menu(model: Model(tiramisu_msg)) -> List(element.Element(Msg)) {
  [
    // Title
    html.div([attribute.class("text-center mb-8")], [
      html.h2(
        [
          attribute.class("text-5xl font-bold text-blue-300 mb-4"),
          attribute.style("text-shadow", "0 0 20px rgba(147, 197, 253, 0.8)"),
        ],
        [html.text("SETTINGS")],
      ),
    ]),
    // Camera distance slider
    html.div([attribute.class("mb-6")], [
      html.label(
        [
          attribute.class("block text-xl text-blue-100 mb-3"),
        ],
        [html.text("Camera Distance")],
      ),
      html.div([attribute.class("flex items-center gap-4")], [
        html.input([
          attribute.type_("range"),
          attribute.min("1.0"),
          attribute.max("15.0"),
          attribute.step("0.5"),
          attribute.value(float.to_string(model.camera_distance)),
          attribute.class(
            "flex-1 h-3 bg-gray-700 rounded-lg appearance-none cursor-pointer slider",
          ),
          attribute.style("-webkit-appearance", "none"),
          attribute.style("appearance", "none"),
          event.on_input(fn(value) {
            case float.parse(value) {
              Ok(distance) -> CameraDistanceChanged(distance)
              Error(Nil) -> {
                let assert Ok(distance) = int.parse(value)
                CameraDistanceChanged(int.to_float(distance))
              }
            }
          }),
        ]),
        html.span(
          [
            attribute.class(
              "text-lg text-blue-200 font-mono min-w-[60px] text-right",
            ),
          ],
          [
            html.text(
              float.to_string(float.to_precision(model.camera_distance, 1)),
            ),
          ],
        ),
      ]),
    ]),
    // Go back button
    html.div([attribute.class("flex justify-center mt-8")], [
      html.button(
        [
          attribute.class(
            "px-8 py-4 text-xl font-bold bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-purple-400 cursor-pointer",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          event.on_click(CloseSettings),
        ],
        [html.text("GO BACK")],
      ),
    ]),
  ]
}

fn view_wand_stat_compact(
  label: String,
  value: Float,
  unit: String,
) -> element.Element(Msg) {
  html.div([attribute.class("flex justify-between")], [
    html.span([attribute.class("text-gray-300")], [html.text(label <> ":")]),
    html.span([attribute.class("font-bold")], [
      html.text(float.to_string(float.to_precision(value, 2)) <> " " <> unit),
    ]),
  ])
}

fn view_spell_reward_card(reward_spell: spell.Spell) -> element.Element(Msg) {
  let #(name, sprite_path, description, type_label, type_color) = case
    reward_spell
  {
    spell.DamageSpell(_, dmg_spell) -> #(
      dmg_spell.name,
      dmg_spell.ui_sprite,
      "Damage: "
        <> float.to_string(float.to_precision(dmg_spell.damage, 1))
        <> " | Speed: "
        <> float.to_string(float.to_precision(dmg_spell.projectile_speed, 1)),
      "DAMAGE",
      "bg-red-600 border-red-400",
    )
    spell.ModifierSpell(_, mod_spell) -> {
      let effects =
        [
          case mod_spell.damage_multiplier {
            m if m != 1.0 ->
              option.Some("DMG x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
          case mod_spell.damage_addition {
            a if a != 0.0 ->
              option.Some("DMG +" <> float.to_string(float.to_precision(a, 1)))
            _ -> option.None
          },
          case mod_spell.projectile_speed_multiplier {
            m if m != 1.0 ->
              option.Some("SPD x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
          case mod_spell.projectile_size_multiplier {
            m if m != 1.0 ->
              option.Some("SIZE x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
          case mod_spell.projectile_lifetime_multiplier {
            m if m != 1.0 ->
              option.Some("LIFE x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
        ]
        |> list.filter_map(fn(opt) {
          case opt {
            option.Some(s) -> Ok(s)
            option.None -> Error(Nil)
          }
        })

      let description = case effects {
        [] -> "No effects"
        _ ->
          list.fold(effects, "", fn(acc, effect) {
            case acc {
              "" -> effect
              _ -> acc <> " | " <> effect
            }
          })
      }

      #(
        mod_spell.name,
        mod_spell.ui_sprite,
        description,
        "MODIFIER",
        "bg-green-600 border-green-400",
      )
    }
    spell.MulticastSpell(_, multicast_spell) -> {
      let description = case multicast_spell.spell_count {
        spell.Fixed(n) -> "Casts " <> int.to_string(n) <> " spells at once"
        spell.AllRemaining -> "Casts all remaining spells"
      }
      #(
        multicast_spell.name,
        multicast_spell.ui_sprite,
        description,
        "MULTICAST",
        "bg-purple-600 border-purple-400",
      )
    }
  }

  let tooltip_text = spell_tooltip(reward_spell)

  html.button(
    [
      attribute.class(
        "flex flex-col items-center p-6 bg-gray-900/80 border-4 rounded-lg hover:scale-105 hover:bg-gray-800/80 transform transition-all duration-200 cursor-pointer min-w-[200px]",
      ),
      attribute.class(type_color),
      attribute.attribute("title", tooltip_text),
      event.on_click(SpellRewardClicked(reward_spell)),
    ],
    [
      // Type label
      html.div(
        [
          attribute.class(
            "text-xs font-bold text-white px-2 py-1 rounded mb-2 " <> type_color,
          ),
        ],
        [html.text(type_label)],
      ),
      // Sprite image
      html.div(
        [attribute.class("w-16 h-16 mb-3 flex items-center justify-center")],
        [
          html.img([
            attribute.src(sprite_path),
            attribute.class("w-full h-full object-contain"),
            attribute.style("image-rendering", "pixelated"),
          ]),
        ],
      ),
      // Name
      html.div(
        [attribute.class("text-xl font-bold text-white mb-2 text-center")],
        [
          html.text(name),
        ],
      ),
      // Description
      html.div(
        [attribute.class("text-sm text-gray-300 text-center leading-tight")],
        [html.text(description)],
      ),
    ],
  )
}

fn view_debug_menu(model: Model(tiramisu_msg)) -> element.Element(Msg) {
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
            // Left column - Add Spells & Spell Bag
            html.div([], [
              html.h3(
                [attribute.class("text-xl font-bold text-amber-300 mb-4")],
                [html.text("Add Spells to Bag")],
              ),
              html.div([attribute.class("space-y-2 mb-6")], [
                debug_spell_button("Spark", spell.Spark),
                debug_spell_button("Fireball", spell.Fireball),
                debug_spell_button("Lightning Bolt", spell.LightningBolt),
                debug_spell_button("Double Spell", spell.DoubleSpell),
                debug_spell_button("Add Mana", spell.AddMana),
                debug_spell_button("Add Damage", spell.AddDamage),
                debug_spell_button("Piercing", spell.Piercing),
                debug_spell_button("Rapid Fire", spell.RapidFire),
                debug_spell_button("Orbitin Shards", spell.OrbitingSpell),
              ]),
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
            // Middle column - Current Wand Stats (Read-only)
            html.div([], [
              html.h3(
                [attribute.class("text-xl font-bold text-amber-300 mb-4")],
                [html.text("Current Wand Stats")],
              ),
              html.div(
                [attribute.class("space-y-3 bg-purple-950/40 p-4 rounded-lg")],
                [
                  view_wand_stat_compact(
                    "Cast Delay",
                    model.wand_cast_delay,
                    "s",
                  ),
                  view_wand_stat_compact(
                    "Recharge Time",
                    model.wand_recharge_time,
                    "s",
                  ),
                  view_wand_stat_compact("Max Mana", model.wand_max_mana, ""),
                  view_wand_stat_compact(
                    "Mana Recharge",
                    model.wand_mana_recharge_rate,
                    "/s",
                  ),
                  html.div([attribute.class("flex justify-between text-sm")], [
                    html.span([attribute.class("text-blue-200")], [
                      html.text("Capacity:"),
                    ]),
                    html.span([attribute.class("text-white font-bold")], [
                      html.text(int.to_string(model.wand_capacity)),
                    ]),
                  ]),
                  view_wand_stat_compact("Spread", model.wand_spread, "°"),
                ],
              ),
            ]),
            // Right column - Wand Stat Sliders (Editable)
            html.div([], [
              html.h3(
                [attribute.class("text-xl font-bold text-amber-300 mb-4")],
                [html.text("Edit Wand Stats")],
              ),
              html.div([attribute.class("space-y-4")], [
                wand_stat_slider(
                  "Max Mana",
                  model.wand_max_mana,
                  0.0,
                  1000.0,
                  fn(val) { UpdateWandStat(SetMaxMana(val)) },
                ),
                wand_stat_slider(
                  "Mana Recharge Rate",
                  model.wand_mana_recharge_rate,
                  0.0,
                  1000.0,
                  fn(val) { UpdateWandStat(SetManaRechargeRate(val)) },
                ),
                wand_stat_slider(
                  "Cast Delay",
                  model.wand_cast_delay,
                  0.0,
                  1.0,
                  fn(val) { UpdateWandStat(SetCastDelay(val)) },
                ),
                wand_stat_slider(
                  "Recharge Time",
                  model.wand_recharge_time,
                  0.0,
                  5.0,
                  fn(val) { UpdateWandStat(SetRechargeTime(val)) },
                ),
                wand_stat_slider(
                  "Spread",
                  model.wand_spread,
                  0.0,
                  50.0,
                  fn(val) { UpdateWandStat(SetSpread(val)) },
                ),
                wand_capacity_slider(
                  "Capacity (Spell Slots)",
                  model.wand_capacity,
                  1,
                  10,
                  fn(val) { UpdateWandStat(SetCapacity(val)) },
                ),
              ]),
            ]),
          ]),
        ],
      ),
    ],
  )
}

fn debug_spell_button(name: String, spell_id: spell.Id) -> element.Element(Msg) {
  html.button(
    [
      attribute.class(
        "w-full px-4 py-2 bg-purple-700 hover:bg-purple-600 text-white rounded-lg transition-colors cursor-pointer",
      ),
      event.on_click(AddSpellToBag(spell_id)),
    ],
    [html.text(name)],
  )
}

fn wand_stat_slider(
  label: String,
  current_value: Float,
  min: Float,
  max: Float,
  on_change: fn(Float) -> Msg,
) -> element.Element(Msg) {
  html.div([], [
    html.label([attribute.class("block text-gray-300 text-sm mb-1")], [
      html.text(label <> ": " <> float_to_string_rounded(current_value)),
    ]),
    html.input([
      attribute.type_("range"),
      attribute.attribute("min", float.to_string(min)),
      attribute.attribute("max", float.to_string(max)),
      attribute.attribute("step", "0.01"),
      attribute.attribute("value", float.to_string(current_value)),
      attribute.class("w-full cursor-pointer"),
      event.on_input(fn(value) {
        case float.parse(value) {
          Ok(val) -> on_change(val)
          Error(_) -> NoOp
        }
      }),
    ]),
  ])
}

fn wand_capacity_slider(
  label: String,
  current_value: Int,
  min: Int,
  max: Int,
  on_change: fn(Int) -> Msg,
) -> element.Element(Msg) {
  html.div([], [
    html.label([attribute.class("block text-gray-300 text-sm mb-1")], [
      html.text(label <> ": " <> int.to_string(current_value)),
    ]),
    html.input([
      attribute.type_("range"),
      attribute.attribute("min", int.to_string(min)),
      attribute.attribute("max", int.to_string(max)),
      attribute.attribute("step", "1"),
      attribute.attribute("value", int.to_string(current_value)),
      attribute.class("w-full cursor-pointer"),
      event.on_input(fn(value) {
        case int.parse(value) {
          Ok(val) -> on_change(val)
          Error(_) -> NoOp
        }
      }),
    ]),
  ])
}

fn view_game_over_screen(model: Model(tiramisu_msg)) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-red-900 via-purple-900 to-black pointer-events-auto",
      ),
    ],
    [
      html.div([attribute.class("text-center mb-12")], [
        html.h1(
          [
            attribute.class(
              "text-8xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-orange-500 mb-6",
            ),
            attribute.style("text-shadow", "0 0 40px rgba(239, 68, 68, 0.5)"),
          ],
          [html.text("GAME OVER")],
        ),

        html.p([attribute.class("text-3xl text-purple-300 mb-8")], [
          html.text("Your journey has ended..."),
        ]),

        // Stats
        html.div(
          [
            attribute.class(
              "bg-black/50 p-8 rounded-lg border-4 border-red-500 mb-8",
            ),
          ],
          [
            html.p([attribute.class("text-2xl text-white mb-2")], [
              html.text("Final Stats"),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total score: "
                <> float.to_string(float.to_precision(
                  model.score.total_score,
                  2,
                )),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total survival points: "
                <> int.to_string(float.round(model.score.total_survival_points)),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total kill points: "
                <> int.to_string(float.round(model.score.total_kill_points)),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total kills: " <> int.to_string(model.score.total_kills),
              ),
            ]),
          ],
        ),
      ]),

      // Restart button
      html.button(
        [
          attribute.class(
            "px-12 py-6 text-3xl font-bold bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-lg shadow-2xl hover:scale-110 transform transition-all duration-200 border-4 border-green-300 cursor-pointer",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          event.on_click(RestartButtonClicked),
        ],
        [html.text("TRY AGAIN")],
      ),
    ],
  )
}

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
      // Filled portion
      html.div(
        [
          attribute.class(color_class <> " h-full"),
          attribute.style("width", float.to_string(percentage) <> "%"),
        ],
        [],
      ),
      // Pixel effect overlay
      html.div(
        [
          attribute.class("absolute inset-0 opacity-30"),
          attribute.style(
            "background",
            "repeating-linear-gradient(0deg, transparent, transparent 1px, rgba(255,255,255,0.1) 1px, rgba(255,255,255,0.1) 2px)",
          ),
          attribute.style("background-size", "2px 2px"),
        ],
        [],
      ),
    ],
  )
}

fn health_color_class(current: Float, max: Float) -> String {
  let percentage = current /. max *. 100.0
  case percentage {
    p if p >=. 75.0 -> "bg-green-500"
    p if p >=. 50.0 -> "bg-lime-500"
    p if p >=. 25.0 -> "bg-orange-500"
    _ -> "bg-red-500"
  }
}

fn render_xp_bar(current current: Float, max max: Float) -> element.Element(Msg) {
  let percentage = case max >. 0.0 {
    True -> { current /. max } *. 100.0
    False -> 0.0
  }

  html.div(
    [
      attribute.class(
        "w-full h-8 bg-gradient-to-r from-purple-950 to-indigo-950 border-2 border-amber-600 relative overflow-hidden",
      ),
      attribute.style("image-rendering", "pixelated"),
    ],
    [
      // Filled portion with gradient
      html.div(
        [
          attribute.class(
            "h-full bg-gradient-to-r from-amber-500 via-yellow-400 to-amber-500",
          ),
          attribute.style("width", float.to_string(percentage) <> "%"),
        ],
        [],
      ),
      // Shine effect overlay
      html.div(
        [
          attribute.class("absolute inset-0 opacity-40"),
          attribute.style(
            "background",
            "repeating-linear-gradient(90deg, transparent, transparent 8px, rgba(255,255,255,0.2) 8px, rgba(255,255,255,0.2) 16px)",
          ),
        ],
        [],
      ),
    ],
  )
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
    ensaimada.container(
      config,
      drag_state,
      sortable_items,
      fn(item, idx, drag_state) {
        render_wand_slot_item(item, idx, drag_state, casting_indices)
      },
    ),
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
          <> " flex items-center justify-center shadow-lg relative transition-all hover:scale-110 cursor-move pointer-events-auto",
        ),
        attribute.style("image-rendering", "pixelated"),
      ],
      tooltip_attrs,
    ]),
    [
      content_element,
      // Inner shadow effect
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
          <> " flex items-center justify-center shadow-lg transition-all hover:scale-110 cursor-move pointer-events-auto",
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

fn float_to_string_rounded(value: Float) -> String {
  value
  |> float.round()
  |> int.to_string()
}

/// Generate tooltip text showing spell stats
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

      // Add cast delay if non-zero
      let stats = case damage_spell.cast_delay_addition {
        0.0 -> stats
        delay -> [
          "Cast Delay: +"
            <> float.to_string(float.to_precision(delay, 2))
            <> "s",
          ..stats
        ]
      }

      // Add critical chance if non-zero
      let stats = case damage_spell.critical_chance {
        0.0 -> stats
        crit -> {
          let crit_percent =
            float.to_string(float.to_precision(crit *. 100.0, 1))
          ["Crit Chance: " <> crit_percent <> "%", ..stats]
        }
      }

      // Add spread if non-zero
      let stats = case damage_spell.spread {
        0.0 -> stats
        spread -> [
          "Spread: +" <> float.to_string(float.to_precision(spread, 1)) <> "°",
          ..stats
        ]
      }

      string.join(list.reverse(stats), "\n")
    }
    spell.ModifierSpell(_, modifier_spell) -> {
      let stats = [modifier_spell.name, "─────────────"]

      // Damage
      let stats = case
        modifier_spell.damage_multiplier,
        modifier_spell.damage_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> "Damage: +" <> float.to_string(float.to_precision(add, 1))
            _, 0.0 ->
              "Damage: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Damage: +"
              <> float.to_string(float.to_precision(add, 1))
              <> ", x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Speed
      let stats = case
        modifier_spell.projectile_speed_multiplier,
        modifier_spell.projectile_speed_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> "Speed: +" <> float.to_string(float.to_precision(add, 1))
            _, 0.0 -> "Speed: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Speed: +"
              <> float.to_string(float.to_precision(add, 1))
              <> ", x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Lifetime
      let stats = case
        modifier_spell.projectile_lifetime_multiplier,
        modifier_spell.projectile_lifetime_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ ->
              "Lifetime: +"
              <> float.to_string(float.to_precision(add, 1))
              <> "s"
            _, 0.0 ->
              "Lifetime: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Lifetime: +"
              <> float.to_string(float.to_precision(add, 1))
              <> "s, x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Size
      let stats = case
        modifier_spell.projectile_size_multiplier,
        modifier_spell.projectile_size_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> "Size: +" <> float.to_string(float.to_precision(add, 1))
            _, 0.0 -> "Size: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Size: +"
              <> float.to_string(float.to_precision(add, 1))
              <> ", x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Cast delay
      let stats = case
        modifier_spell.cast_delay_multiplier,
        modifier_spell.cast_delay_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ ->
              "Cast Delay: +"
              <> float.to_string(float.to_precision(add, 2))
              <> "s"
            _, 0.0 ->
              "Cast Delay: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Cast Delay: +"
              <> float.to_string(float.to_precision(add, 2))
              <> "s, x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Critical chance
      let stats = case
        modifier_spell.critical_chance_multiplier,
        modifier_spell.critical_chance_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> {
              let percent = float.to_string(float.to_precision(add *. 100.0, 1))
              "Crit Chance: +" <> percent <> "%"
            }
            _, 0.0 ->
              "Crit Chance: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ -> {
              let percent = float.to_string(float.to_precision(add *. 100.0, 1))
              "Crit Chance: +"
              <> percent
              <> "%, x"
              <> float.to_string(float.to_precision(mult, 2))
            }
          }
          [text, ..stats]
        }
      }

      // Spread
      let stats = case
        modifier_spell.spread_multiplier,
        modifier_spell.spread_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ ->
              "Spread: +" <> float.to_string(float.to_precision(add, 1)) <> "°"
            _, 0.0 ->
              "Spread: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Spread: +"
              <> float.to_string(float.to_precision(add, 1))
              <> "°, x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Mana cost
      let stats = case modifier_spell.mana_cost {
        0.0 -> stats
        cost -> [
          "Mana: " <> float.to_string(float.to_precision(cost, 1)),
          ..stats
        ]
      }

      string.join(list.reverse(stats), "\n")
    }
    spell.MulticastSpell(_, multicast_spell) -> {
      let count_text = case multicast_spell.spell_count {
        spell.Fixed(n) -> "Casts " <> int.to_string(n) <> " spells"
        spell.AllRemaining -> "Casts all remaining spells"
      }

      string.join(
        [
          multicast_spell.name,
          "─────────────",
          count_text,
          "Mana: "
            <> float.to_string(float.to_precision(multicast_spell.mana_cost, 1)),
        ],
        "\n",
      )
    }
  }
}

fn render_cast_delay_bar(
  time_since_last_cast: Float,
  cast_delay: Float,
  recharge_time: Float,
  current_spell_index: Int,
  wand_slot_count: Int,
  is_recharging: Bool,
) -> element.Element(Msg) {
  // Determine if we're ready to cast or still waiting
  let is_ready = time_since_last_cast >=. cast_delay

  // Calculate wait time based on phase
  let max_delay = float.max(cast_delay, recharge_time)

  // Calculate progress based on which phase we're in
  let #(_progress, percentage) = case is_recharging, is_ready {
    True, _ -> {
      // During recharge (wand reload): show single bar from start to ready
      // Timer goes from (cast_delay - max_delay) to cast_delay
      // Progress goes from 0% to 100% over max_delay duration
      let start_time = cast_delay -. max_delay
      let prog = case max_delay >. 0.0 {
        True -> {
          let elapsed = time_since_last_cast -. start_time
          float.max(0.0, float.min(1.0, elapsed /. max_delay))
        }
        False -> 1.0
      }
      #(prog, prog *. 100.0)
    }
    False, True -> {
      // Ready to cast
      #(1.0, 100.0)
    }
    False, False -> {
      // During normal cast delay: progress from 0 to cast_delay
      let prog = float.min(1.0, time_since_last_cast /. cast_delay)
      #(prog, prog *. 100.0)
    }
  }

  let bar_color = case is_recharging, is_ready {
    True, _ -> "bg-red-500"
    False, True -> "bg-green-500"
    False, False -> "bg-yellow-500"
  }

  // Check if next cast will wrap
  let will_wrap = current_spell_index >= wand_slot_count && wand_slot_count > 0
  let wrapped_index = case wand_slot_count {
    0 -> 0
    _ -> current_spell_index % wand_slot_count
  }

  html.div([attribute.class("mb-2")], [
    // Cast delay label and current spell index
    html.div(
      [attribute.class("flex justify-between text-xs text-gray-300 mb-1")],
      [
        html.span([], [
          html.text(case is_recharging, is_ready {
            True, _ -> "Recharging..."
            False, True -> "Ready to cast!"
            False, False -> "Cast delay..."
          }),
        ]),
        html.span([attribute.class("flex items-center gap-1")], [
          html.text("Next: " <> int.to_string(wrapped_index)),
          case will_wrap {
            True ->
              html.span([attribute.class("text-purple-400 font-bold")], [
                html.text("↻"),
              ])
            False -> html.span([], [])
          },
        ]),
      ],
    ),
    // Progress bar
    html.div(
      [
        attribute.class(
          "w-full h-2 bg-gray-700 rounded-full overflow-hidden border border-gray-600",
        ),
      ],
      [
        html.div(
          [
            attribute.class(bar_color <> " h-full"),
            attribute.style("width", float.to_string(percentage) <> "%"),
          ],
          [],
        ),
      ],
    ),
  ])
}

pub fn start(wrapper: fn(UiToGameMsg) -> a) -> Nil {
  let assert Ok(_) =
    lustre.application(init, update, view)
    |> lustre.start("#ui", wrapper)
  Nil
}
