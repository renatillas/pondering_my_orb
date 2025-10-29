import ensaimada
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import iv
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import plinth/javascript/global
import pondering_my_orb/keyboard
import pondering_my_orb/pointer_lock
import pondering_my_orb/pointer_lock_request
import pondering_my_orb/score
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/visibility
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
    resuming: Bool,
    resume_retry_count: Int,
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
  PauseGame
  ResumeGame
  KeyPressed(String)
  PointerLockExited
  PointerLockAcquired
  RetryResume
  PageHidden
  PageVisible
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
      resuming: False,
      resume_retry_count: 0,
    ),
    effect.batch([
      tiramisu_ui.register_lustre(),
      visibility.setup_visibility_listener(fn() { PageHidden }, fn() {
        PageVisible
      }),
      keyboard.setup_keyboard_listener(KeyPressed),
      pointer_lock.setup_pointer_lock_listener(fn() { PointerLockExited }, fn() {
        PointerLockAcquired
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
            effect.none(),
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
                    effect.none(),
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
                    effect.none(),
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
        spell.DamageSpell(dmg) -> dmg.name
        spell.ModifierSpell(mod) -> mod.name
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
    PauseGame -> {
      // Don't pause if we're in level-up modal
      case model.spell_rewards {
        option.Some(_) -> #(model, effect.none())
        option.None -> {
          io.println("=== UI: Game Paused ===")
          #(
            Model(..model, is_paused: True),
            tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GamePaused)),
          )
        }
      }
    }
    ResumeGame -> {
      io.println("=== UI: Resume Requested - Requesting Pointer Lock ===")
      // Set resuming flag but keep paused until pointer lock is acquired
      // Set up automatic retry every 500ms
      #(
        Model(..model, resuming: True, resume_retry_count: 0),
        effect.batch([
          effect.from(fn(_) { pointer_lock_request.request_pointer_lock_sync() }),
          effect.from(fn(dispatch) {
            global.set_timeout(500, fn() { dispatch(RetryResume) })
            Nil
          }),
        ]),
      )
    }
    PageHidden -> {
      // Auto-pause when user tabs out, but only during gameplay
      case model.game_phase, model.spell_rewards, model.is_paused {
        Playing, option.None, False -> {
          io.println("=== UI: Page Hidden - Auto Pausing ===")
          #(
            Model(..model, is_paused: True),
            tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GamePaused)),
          )
        }
        _, _, _ -> #(model, effect.none())
      }
    }
    KeyPressed(key) -> {
      case key, model.game_phase, model.spell_rewards, model.is_paused {
        // ESC during gameplay - pause
        "Escape", Playing, option.None, False -> {
          io.println("=== UI: ESC Pressed - Pausing ===")
          #(
            Model(..model, is_paused: True),
            tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GamePaused)),
          )
        }
        // SPACE during pause - resume (ESC can't be used because it exits pointer lock)
        " ", Playing, option.None, True -> {
          io.println("=== UI: SPACE Pressed - Requesting Pointer Lock ===")
          // Set resuming flag but keep paused until pointer lock is acquired
          // Set up automatic retry every 500ms
          #(
            Model(..model, resuming: True, resume_retry_count: 0),
            effect.batch([
              effect.from(fn(_) {
                pointer_lock_request.request_pointer_lock_sync()
              }),
              effect.from(fn(dispatch) {
                global.set_timeout(500, fn() { dispatch(RetryResume) })
                Nil
              }),
            ]),
          )
        }
        _, _, _, _ -> #(model, effect.none())
      }
    }
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
        // Only auto-pause if we're actually playing and not in level-up and not already paused
        False ->
          case model.game_phase, model.spell_rewards, model.is_paused {
            Playing, option.None, False -> {
              io.println("=== UI: Pointer Lock Exited - Auto Pausing ===")
              #(
                Model(..model, is_paused: True),
                tiramisu_ui.dispatch_to_tiramisu(model.wrapper(GamePaused)),
              )
            }
            _, _, _ -> #(model, effect.none())
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
    RetryResume -> {
      // Automatically retry pointer lock request if we're still resuming
      case model.resuming {
        True -> {
          let retry_count = model.resume_retry_count + 1
          case retry_count < 10 {
            // Keep retrying (up to 10 times = 5 seconds)
            True -> {
              io.println(
                "=== UI: Retrying Pointer Lock (attempt "
                <> int.to_string(retry_count)
                <> ") ===",
              )
              #(
                Model(..model, resume_retry_count: retry_count),
                effect.batch([
                  effect.from(fn(_) {
                    pointer_lock_request.request_pointer_lock_sync()
                  }),
                  effect.from(fn(dispatch) {
                    global.set_timeout(500, fn() { dispatch(RetryResume) })
                    Nil
                  }),
                ]),
              )
            }
            // Give up after 10 retries
            False -> {
              io.println(
                "=== UI: Pointer Lock Failed After "
                <> int.to_string(retry_count)
                <> " Retries, Giving Up ===",
              )
              #(
                Model(..model, resuming: False, resume_retry_count: 0),
                effect.none(),
              )
            }
          }
        }
        False -> #(model, effect.none())
      }
    }
    PageVisible -> {
      // Don't auto-resume, let the user manually resume
      io.println("=== UI: Page Visible ===")
      #(model, effect.none())
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
          attribute.style("z-index", "200"),
        ],
        [
          // Health section
          html.div([attribute.class("mb-4")], [
            html.div([attribute.class("flex items-center gap-2 mb-2")], [
              html.span([attribute.class("text-red-400 text-lg")], [
                html.text("❤"),
              ]),
              html.span([attribute.class("text-white font-bold")], [
                html.text("HEALTH"),
              ]),
            ]),
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
            html.div([attribute.class("flex items-center gap-2 mb-2")], [
              html.span([attribute.class("text-blue-400 text-lg")], [
                html.text("✦"),
              ]),
              html.span([attribute.class("text-white font-bold")], [
                html.text("MANA"),
              ]),
            ]),
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
            html.div([attribute.class("flex items-center gap-2 mb-2")], [
              html.span([attribute.class("text-amber-400 text-lg")], [
                html.text("⚡"),
              ]),
              html.span([attribute.class("text-white font-bold")], [
                html.text("WAND"),
              ]),
            ]),
            render_wand_slots(model.wand_slots, model.drag_state),
          ]),
          html.div([attribute.class("mb-4")], [
            html.div([attribute.class("flex items-center gap-2 mb-2")], [
              html.span([attribute.class("text-yellow-400 text-lg")], [
                html.text("⭐"),
              ]),
              html.span([attribute.class("text-white font-bold")], [
                html.text("SCORE"),
              ]),
            ]),
            html.div([attribute.class("text-gray-300 text-sm mb-1")], [
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
      // Pause menu - show when paused or resuming (but not during level-up)
      case model.is_paused, model.resuming, model.spell_rewards {
        True, _, option.None | _, True, option.None ->
          view_pause_menu(model.resuming)
        _, _, _ -> html.div([], [])
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
                render_wand_slots(model.wand_slots, model.drag_state),
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

fn view_pause_menu(resuming: Bool) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center bg-black/70 backdrop-blur-sm pointer-events-auto",
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
        [
          // Title
          html.div([attribute.class("text-center mb-8")], [
            html.h2(
              [
                attribute.class("text-5xl font-bold text-blue-300 mb-4"),
                attribute.style(
                  "text-shadow",
                  "0 0 20px rgba(147, 197, 253, 0.8)",
                ),
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
        ],
      ),
    ],
  )
}

fn view_spell_reward_card(reward_spell: spell.Spell) -> element.Element(Msg) {
  let #(name, icon, description, type_label, type_color) = case reward_spell {
    spell.DamageSpell(dmg_spell) -> #(
      dmg_spell.name,
      spell_icon(dmg_spell),
      "Damage: "
        <> float.to_string(float.to_precision(dmg_spell.damage, 1))
        <> " | Speed: "
        <> float.to_string(float.to_precision(dmg_spell.projectile_speed, 1)),
      "DAMAGE",
      "bg-red-600 border-red-400",
    )
    spell.ModifierSpell(mod_spell) -> {
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
        "✨",
        description,
        "MODIFIER",
        "bg-green-600 border-green-400",
      )
    }
  }

  html.button(
    [
      attribute.class(
        "flex flex-col items-center p-6 bg-gray-900/80 border-4 rounded-lg hover:scale-105 hover:bg-gray-800/80 transform transition-all duration-200 cursor-pointer min-w-[200px]",
      ),
      attribute.class(type_color),
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
      // Icon
      html.div([attribute.class("text-6xl mb-3")], [html.text(icon)]),
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
) -> element.Element(Msg) {
  let sortable_items =
    slots
    |> iv.to_list()
    |> list.index_map(fn(slot, index) {
      ensaimada.item("wand-" <> int.to_string(index), slot)
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
      render_wand_slot_item,
    ),
    WandSortableMsg,
  )
}

fn render_wand_slot_item(
  item: ensaimada.Item(option.Option(spell.Spell)),
  _index: Int,
  _drag_state: ensaimada.DragState,
) -> element.Element(Msg) {
  let slot = ensaimada.item_data(item)
  let #(content, bg_class, border_class, text_class) = case slot {
    option.Some(spell.DamageSpell(damage_spell)) -> #(
      spell_icon(damage_spell),
      "bg-red-600",
      "border-red-400",
      "text-white",
    )
    option.Some(spell.ModifierSpell(_)) -> #(
      "✨",
      "bg-green-600",
      "border-green-400",
      "text-white",
    )
    option.None -> #("", "bg-gray-800", "border-gray-600", "text-gray-500")
  }

  html.div(
    [
      attribute.class(
        "w-12 h-12 "
        <> bg_class
        <> " border-2 "
        <> border_class
        <> " flex items-center justify-center text-xl font-bold "
        <> text_class
        <> " shadow-lg relative transition-all hover:scale-110 cursor-move pointer-events-auto",
      ),
      attribute.style("image-rendering", "pixelated"),
    ],
    [
      html.text(content),
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
  let #(icon, bg_class, border_class) = case spell_item {
    spell.DamageSpell(damage_spell) -> #(
      spell_icon(damage_spell),
      "bg-red-600",
      "border-red-400",
    )
    spell.ModifierSpell(_) -> #("✨", "bg-green-600", "border-green-400")
  }

  html.div(
    [
      attribute.class(
        "relative w-12 h-12 "
        <> bg_class
        <> " border-2 "
        <> border_class
        <> " flex items-center justify-center text-xl font-bold text-white shadow-lg transition-all hover:scale-110 cursor-move pointer-events-auto",
      ),
      attribute.style("image-rendering", "pixelated"),
    ],
    [
      html.text(icon),
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

fn spell_icon(spell: spell.DamageSpell) -> String {
  case spell.damage {
    d if d >=. 100.0 -> "🔥"
    d if d >=. 50.0 -> "⚡"
    _ -> "✦"
  }
}

fn float_to_string_rounded(value: Float) -> String {
  value
  |> float.round()
  |> int.to_string()
}

pub fn start(wrapper: fn(UiToGameMsg) -> a) -> Nil {
  let assert Ok(_) =
    lustre.application(init, update, view)
    |> lustre.start("#ui", wrapper)
  Nil
}
