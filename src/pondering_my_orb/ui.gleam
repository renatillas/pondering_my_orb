import ensaimada
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import iv
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
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
    inventory_open: Bool,
    wrapper: fn(UiToGameMsg) -> tiramisu_msg,
    player_xp: Int,
    player_xp_to_next_level: Int,
    player_level: Int,
    total_score: Float,
    total_survival_points: Float,
    total_kill_points: Float,
    total_kills: Int,
    current_multiplier: Float,
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
  ToggleInventory
  SyncInventoryToGame
  NoOp
}

pub type UiToGameMsg {
  GameStarted
  GameRestarted
  UpdatePlayerInventory(
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
  )
}

pub type GameState {
  GameState(
    player_health: Float,
    player_max_health: Float,
    player_mana: Float,
    player_max_mana: Float,
    wand_slots: iv.Array(option.Option(spell.Spell)),
    spell_bag: spell_bag.SpellBag,
    inventory_open: Bool,
    player_xp: Int,
    player_xp_to_next_level: Int,
    player_level: Int,
    total_score: Float,
    total_survival_points: Float,
    total_kill_points: Float,
    total_kills: Int,
    current_multiplier: Float,
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
      inventory_open: False,
      wrapper:,
      player_xp: 0,
      player_xp_to_next_level: 100,
      player_level: 1,
      total_score: 0.0,
      total_survival_points: 0.0,
      total_kill_points: 0.0,
      total_kills: 0,
      current_multiplier: 1.0,
    ),
    tiramisu_ui.register_lustre(),
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
      // Detect inventory closing (transition from True to False) and sync changes
      let sync_effect = case model.inventory_open, state.inventory_open {
        True, False ->
          tiramisu_ui.dispatch_to_tiramisu(
            model.wrapper(UpdatePlayerInventory(
              model.wand_slots,
              model.spell_bag,
            )),
          )
        _, _ -> effect.none()
      }

      // Don't overwrite wand_slots and spell_bag when inventory is open
      // to preserve user's drag-and-drop changes
      let #(wand_slots, spell_bag) = case model.inventory_open {
        True -> #(model.wand_slots, model.spell_bag)
        False -> #(state.wand_slots, state.spell_bag)
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
          inventory_open: state.inventory_open,
          player_xp: state.player_xp,
          player_xp_to_next_level: state.player_xp_to_next_level,
          player_level: state.player_level,
          total_score: state.total_score,
          total_survival_points: state.total_survival_points,
          total_kill_points: state.total_kill_points,
          total_kills: state.total_kills,
          current_multiplier: state.current_multiplier,
        ),
        sync_effect,
      )
    }
    ToggleInventory -> {
      // When closing inventory, sync changes back to game
      let sync_effect = case model.inventory_open {
        True ->
          tiramisu_ui.dispatch_to_tiramisu(
            model.wrapper(UpdatePlayerInventory(
              model.wand_slots,
              model.spell_bag,
            )),
          )
        False -> effect.none()
      }

      #(Model(..model, inventory_open: !model.inventory_open), sync_effect)
    }
    SyncInventoryToGame -> #(model, effect.none())
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
              "WASD - Move | Mouse - Look | I - Inventory | ESC - Exit Pointer Lock",
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
              html.text(float_to_string_rounded(model.total_score)),
            ]),
            // Streak display
            case model.current_multiplier >. 1.0 {
              True ->
                html.div([attribute.class("text-orange-400 text-xs")], [
                  html.text(
                    "STREAK: "
                    <> float.to_string(float.to_precision(
                      model.current_multiplier,
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
      // Inventory screen (spell bag) - only show when inventory is open
      case model.inventory_open {
        True ->
          html.div(
            [
              attribute.class(
                "absolute inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm pointer-events-auto",
              ),
              attribute.style("z-index", "100"),
            ],
            [
              html.div(
                [
                  attribute.class(
                    "p-8 bg-gradient-to-br from-purple-900/95 to-indigo-900/95 border-4 border-amber-400 rounded-lg shadow-2xl pointer-events-auto",
                  ),
                  attribute.style("image-rendering", "pixelated"),
                  attribute.style("max-width", "800px"),
                ],
                [
                  html.div(
                    [attribute.class("flex items-center justify-between mb-4")],
                    [
                      html.div([attribute.class("flex items-center gap-2")], [
                        html.span(
                          [attribute.class("text-purple-400 text-2xl")],
                          [
                            html.text("📦"),
                          ],
                        ),
                        html.span(
                          [
                            attribute.class(
                              "text-white font-bold text-2xl tracking-wider",
                            ),
                          ],
                          [html.text("SPELL BAG")],
                        ),
                      ]),
                      html.div([attribute.class("text-gray-300 text-sm")], [
                        html.text("Press I to close"),
                      ]),
                    ],
                  ),
                  render_spell_bag(model.spell_bag, model.drag_state),
                ],
              ),
            ],
          )
        False -> html.div([], [])
      },
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
                <> float.to_string(float.to_precision(model.total_score, 2)),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total survival points: "
                <> int.to_string(float.round(model.total_survival_points)),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total kill points: "
                <> int.to_string(float.round(model.total_kill_points)),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text("Total kills: " <> int.to_string(model.total_kills)),
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
  bag: spell_bag.SpellBag,
  drag_state: ensaimada.DragState,
) -> element.Element(Msg) {
  let spell_stacks = spell_bag.list_spell_stacks(bag)

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
      render_bag_spell_item,
    ),
    BagSortableMsg,
  )
}

fn render_bag_spell_item(
  item: ensaimada.Item(#(spell.Spell, Int)),
  _index: Int,
  _drag_state: ensaimada.DragState,
) -> element.Element(Msg) {
  let #(spell_item, count) = ensaimada.item_data(item)
  let #(content, bg_class, border_class, text_class) = case spell_item {
    spell.DamageSpell(damage_spell) -> #(
      spell_icon(damage_spell),
      "bg-red-600",
      "border-red-400",
      "text-white",
    )
    spell.ModifierSpell(_) -> #(
      "✨",
      "bg-green-600",
      "border-green-400",
      "text-white",
    )
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
      // Count badge
      case count > 1 {
        True ->
          html.div(
            [
              attribute.class(
                "absolute -top-1 -right-1 bg-amber-500 border border-amber-700 rounded-full w-5 h-5 flex items-center justify-center text-xs font-bold text-black",
              ),
            ],
            [html.text(int.to_string(count))],
          )
        False -> html.div([], [])
      },
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
