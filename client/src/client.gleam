import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/time/duration
import iv
import tiramisu
import tiramisu/effect
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui as bridge_ui

import client/bridge
import client/connecting
import client/enemy
import client/map
import client/network
import client/player
import client/projectile
import client/start_screen
import client/ui

import shared/game_message
import shared/player as shared_player
import shared/spell
import shared/wand

// =============================================================================
// TYPES
// =============================================================================

/// Application state - manages transitions between screens
pub type AppState {
  StartScreen(start_screen.Model)
  Connecting(connecting.Model)
  InGame(GameModel)
}

/// Game model - only used when in InGame state
pub type GameModel {
  GameModel(
    map: map.Model,
    player: player.Model,
    enemy: enemy.Model,
    projectile: projectile.Model,
  )
}

/// Root model
pub type Model {
  Model(
    state: AppState,
    network: network.Model,
    bridge: bridge_ui.Bridge(bridge.BridgeMsg),
  )
}

/// Root messages
pub type Msg {
  // State-specific messages
  StartScreenMsg(start_screen.Msg)
  ConnectingMsg(connecting.Msg)
  GameMsg(GameMsg)

  // Network messages (shared across states)
  NetworkMsg(network.Msg)

  // UI bridge messages
  FromBridge(bridge.BridgeMsg)

  // State transition messages
  TransitionToConnecting(room_id: String, player_name: String)
  TransitionToInGame(
    player_id: shared_player.Id,
    existing_players: List(shared_player.Player),
  )
  TransitionToStartScreen(reason: String)
}

/// Messages when in game state
pub type GameMsg {
  MapMsg(map.Msg)
  PlayerMsg(player.Msg)
  EnemyMsg(enemy.Msg)
  ProjectileMsg(projectile.Msg)
}

// =============================================================================
// INIT
// =============================================================================

pub fn init(
  _ctx: tiramisu.Context,
  bridge: bridge_ui.Bridge(bridge.BridgeMsg),
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  // Initialize network (shared across all states)
  let #(network_model, network_effect) = network.init()

  // Start in StartScreen state
  let #(start_screen_model, _) = start_screen.init()

  let model =
    Model(
      state: StartScreen(start_screen_model),
      network: network_model,
      bridge: bridge,
    )

  let effects =
    effect.batch([
      effect.map(network_effect, NetworkMsg),
      // Notify UI to show start screen
      bridge_ui.send_to_ui(bridge, bridge.ShowStartScreen),
      // Connect to server immediately (but don't join a room yet)
      effect.dispatch(
        NetworkMsg(network.Connect(
          server_url: "wss://pondering-my-orb.fly.dev",
          player_name: "",
        )),
      ),
    ])

  #(model, effects, option.None)
}

// =============================================================================
// HELPERS
// =============================================================================

/// Convert a spell to SpellInfo for UI display
fn spell_to_spell_info(spell: spell.Spell) -> bridge.SpellInfo {
  case spell {
    spell.DamageSpell(_, ui_sprite, kind) ->
      bridge.SpellInfo(
        name: kind.name,
        icon_path: ui_sprite,
        mana_cost: kind.mana_cost,
      )
    spell.ModifierSpell(_, ui_sprite, kind) ->
      bridge.SpellInfo(
        name: kind.name,
        icon_path: ui_sprite,
        mana_cost: kind.mana_cost,
      )
    spell.MulticastSpell(_, ui_sprite, kind) ->
      bridge.SpellInfo(
        name: kind.name,
        icon_path: ui_sprite,
        mana_cost: kind.mana_cost,
      )
  }
}

/// Convert a wand to WandInfo for UI display
fn wand_to_wand_info(
  wand: wand.Wand,
  cooldown_remaining_ms: Int,
) -> bridge.WandInfo {
  let cast_delay_ms =
    wand.cast_delay
    |> duration.to_seconds()
    |> float.multiply(1000.0)
    |> float.round()

  let recharge_time_ms =
    wand.recharge_time
    |> duration.to_seconds()
    |> float.multiply(1000.0)
    |> float.round()

  // Calculate max possible cooldown (cast_delay + recharge_time)
  let max_cooldown_ms = cast_delay_ms + recharge_time_ms

  // Calculate progress: 0% (cooling down) to 100% (ready to fire)
  let cooldown_progress = case max_cooldown_ms {
    0 -> 100.0
    max -> {
      let progress =
        100.0
        -. { int.to_float(cooldown_remaining_ms) /. int.to_float(max) *. 100.0 }
      float.max(0.0, float.min(100.0, progress))
    }
  }

  // Convert iv.Array to List
  let slot_count = iv.size(wand.slots)
  let spells_list =
    list.range(0, slot_count - 1)
    |> list.map(fn(index) {
      case iv.get(wand.slots, index) {
        Ok(option.Some(spell)) -> option.Some(spell_to_spell_info(spell))
        Ok(option.None) -> option.None
        Error(_) -> option.None
      }
    })

  bridge.WandInfo(
    slot_count: slot_count,
    spells: spells_list,
    current_mana: wand.current_mana,
    max_mana: wand.max_mana,
    spread: wand.spread,
    cast_delay_ms: cast_delay_ms,
    recharge_time_ms: recharge_time_ms,
    cooldown_progress: cooldown_progress,
  )
}

/// Send player state updates to the UI via bridge
fn send_player_state_to_ui(
  bridge: bridge_ui.Bridge(bridge.BridgeMsg),
  player_model: player.Model,
) -> effect.Effect(Msg) {
  let health = player_model.player.health

  // Get mana from active wand (if available)
  let active_slot = player_model.player.active_wand_slot
  let active_wand = case player_model.wand_inventory {
    option.Some(inv) ->
      case active_slot {
        0 -> inv.slot_0
        1 -> inv.slot_1
        2 -> inv.slot_2
        3 -> inv.slot_3
        _ -> option.None
      }
    option.None -> option.None
  }

  let mana_effect = case active_wand {
    option.Some(wand) ->
      bridge_ui.send_to_ui(
        bridge,
        bridge.UpdateMana(wand.current_mana, wand.max_mana),
      )
    option.None -> bridge_ui.send_to_ui(bridge, bridge.UpdateMana(0.0, 100.0))
  }

  // Get cooldown for active wand slot
  let #(cd0, cd1, cd2, cd3) = player_model.wand_cooldowns_ms
  let active_cooldown = case active_slot {
    0 -> cd0
    1 -> cd1
    2 -> cd2
    3 -> cd3
    _ -> 0
  }

  let wand_effect = case active_wand {
    option.Some(wand) ->
      bridge_ui.send_to_ui(
        bridge,
        bridge.UpdateActiveWand(wand_to_wand_info(wand, active_cooldown)),
      )
    option.None -> effect.none()
  }

  // Send health, mana, and wand updates to UI
  effect.batch([
    bridge_ui.send_to_ui(
      bridge,
      bridge.UpdateHealth(health.current, health.max),
    ),
    mana_effect,
    wand_effect,
  ])
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case msg {
    // State transition messages
    TransitionToConnecting(room_id, player_name) ->
      handle_transition_to_connecting(model, room_id, player_name, ctx)

    TransitionToInGame(player_id, existing_players) ->
      handle_transition_to_ingame(model, player_id, existing_players, ctx)

    TransitionToStartScreen(reason) ->
      handle_transition_to_start_screen(model, reason, ctx)

    // Bridge messages (from UI)
    FromBridge(bridge_msg) -> handle_bridge_message(model, bridge_msg, ctx)

    // Network messages (handled in all states)
    NetworkMsg(network_msg) -> handle_network_message(model, network_msg, ctx)

    // State-specific messages
    StartScreenMsg(ss_msg) -> handle_start_screen_message(model, ss_msg)

    ConnectingMsg(conn_msg) -> handle_connecting_message(model, conn_msg)

    GameMsg(game_msg) -> handle_game_message(model, game_msg, ctx)
  }
}

// State transition handlers

fn handle_transition_to_connecting(
  model: Model,
  room_id: String,
  player_name: String,
  _ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  let #(connecting_model, _connecting_effect) =
    connecting.init(room_id, player_name)

  // Send JoinRoom message (already connected from init)
  let join_effect =
    effect.dispatch(
      NetworkMsg(
        network.SendMessage(game_message.JoinRoom(room_id, player_name)),
      ),
    )

  // Notify UI of state change
  let ui_effect =
    bridge_ui.send_to_ui(
      model.bridge,
      bridge.ShowConnecting(room_id, player_name),
    )

  #(
    Model(..model, state: Connecting(connecting_model)),
    effect.batch([join_effect, ui_effect]),
    option.None,
  )
}

fn handle_transition_to_ingame(
  model: Model,
  player_id: shared_player.Id,
  existing_players: List(shared_player.Player),
  _ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  // Initialize game modules NOW (lazy initialization)
  let #(map_model, map_effect) = map.init()
  let #(player_model, player_effect) = player.init()
  let #(enemy_model, enemy_effect) = enemy.init()
  let #(projectile_model, projectile_effect) = projectile.init()

  let game_model =
    GameModel(
      map: map_model,
      player: player_model,
      enemy: enemy_model,
      projectile: projectile_model,
    )

  // Forward RoomJoined to player module to initialize player ID
  let room_joined_effect =
    effect.dispatch(
      GameMsg(
        PlayerMsg(
          player.ServerMessageReceived(game_message.RoomJoined(
            player_id,
            existing_players,
          )),
        ),
      ),
    )

  // Dispatch all initialization effects (map loading, player tick, etc)
  let init_effects =
    effect.batch([
      effect.map(map_effect, fn(m) { GameMsg(MapMsg(m)) }),
      effect.map(player_effect, fn(m) { GameMsg(PlayerMsg(m)) }),
      effect.map(enemy_effect, fn(m) { GameMsg(EnemyMsg(m)) }),
      effect.map(projectile_effect, fn(m) { GameMsg(ProjectileMsg(m)) }),
    ])

  // Send initial UI state and notify of state change
  let ui_effects =
    effect.batch([
      send_player_state_to_ui(model.bridge, player_model),
      bridge_ui.send_to_ui(model.bridge, bridge.ShowInGame),
      room_joined_effect,
      init_effects,
    ])

  #(Model(..model, state: InGame(game_model)), ui_effects, option.None)
}

fn handle_transition_to_start_screen(
  model: Model,
  _reason: String,
  _ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  let #(start_screen_model, _start_screen_effect) = start_screen.init()

  // Disconnect if connected
  let disconnect_effect = effect.dispatch(NetworkMsg(network.Disconnect))

  // Notify UI of state change
  let ui_effect = bridge_ui.send_to_ui(model.bridge, bridge.ShowStartScreen)

  #(
    Model(..model, state: StartScreen(start_screen_model)),
    effect.batch([disconnect_effect, ui_effect]),
    option.None,
  )
}

// Message handlers

fn handle_network_message(
  model: Model,
  network_msg: network.Msg,
  ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case network_msg {
    network.ReceivedMessage(data) -> {
      // Decode and route server message
      case game_message.decode_server_message(data) {
        Ok(server_msg) -> {
          handle_server_message(model, server_msg, ctx)
        }
        Error(_err) -> {
          // Failed to decode
          let #(new_network, network_effect) =
            network.update(
              model.network,
              network_msg,
              NetworkMsg,
              fn(_) { NetworkMsg(network.SocketClosed) },
              ctx,
            )
          #(Model(..model, network: new_network), network_effect, option.None)
        }
      }
    }

    _ -> {
      // Other network messages
      let #(new_network, network_effect) =
        network.update(
          model.network,
          network_msg,
          NetworkMsg,
          fn(_server_msg) { NetworkMsg(network.SocketClosed) },
          ctx,
        )
      #(Model(..model, network: new_network), network_effect, option.None)
    }
  }
}

fn handle_server_message(
  model: Model,
  server_msg: game_message.ServerMessage,
  _ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case server_msg {
    // Room joined - transition to InGame
    game_message.RoomJoined(player_id, existing_players) -> {
      case model.state {
        Connecting(_) -> {
          // Transition to game with player ID and existing players
          effect.dispatch(TransitionToInGame(player_id, existing_players))
          |> fn(eff) { #(model, eff, option.None) }
        }
        _ -> #(model, effect.none(), option.None)
      }
    }

    // Game state update - forward to game if in InGame state
    game_message.GameStateUpdate(
      _tick,
      _players,
      _player_wands,
      projectile_list,
      enemy_list,
    ) -> {
      case model.state {
        InGame(_game_model) -> {
          // Convert lists to dicts
          let projectiles_dict =
            projectile_list
            |> list.map(fn(p) { #(p.id, p) })
            |> dict.from_list()

          let enemies_dict =
            enemy_list
            |> list.map(fn(e) { #(e.id, e) })
            |> dict.from_list()

          // Dispatch to game modules
          let dispatch_effects =
            effect.batch([
              effect.dispatch(
                GameMsg(PlayerMsg(player.ServerMessageReceived(server_msg))),
              ),
              effect.dispatch(
                GameMsg(EnemyMsg(enemy.UpdateFromServer(enemies_dict))),
              ),
              effect.dispatch(
                GameMsg(
                  ProjectileMsg(projectile.UpdateFromServer(projectiles_dict)),
                ),
              ),
            ])

          #(model, dispatch_effects, option.None)
        }
        _ -> #(model, effect.none(), option.None)
      }
    }

    // Room list received - forward to start screen
    game_message.RoomList(rooms) -> {
      // Send room list to UI via bridge
      let ui_effect =
        bridge_ui.send_to_ui(model.bridge, bridge.UpdateRoomList(rooms))
      #(model, ui_effect, option.None)
    }

    // Other server messages forward to game if in InGame
    _ -> {
      case model.state {
        InGame(_game_model) -> {
          #(
            model,
            effect.dispatch(
              GameMsg(PlayerMsg(player.ServerMessageReceived(server_msg))),
            ),
            option.None,
          )
        }
        _ -> #(model, effect.none(), option.None)
      }
    }
  }
}

fn handle_start_screen_message(
  model: Model,
  ss_msg: start_screen.Msg,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case model.state {
    StartScreen(ss_model) -> {
      let #(new_ss, _) = start_screen.update(ss_model, ss_msg)

      // Check for join room request
      case ss_msg {
        start_screen.JoinRoom(room_id) -> {
          // Transition to connecting
          #(
            Model(..model, state: StartScreen(new_ss)),
            effect.dispatch(TransitionToConnecting(room_id, new_ss.player_name)),
            option.None,
          )
        }
        start_screen.RefreshRooms -> {
          // Request room list from server
          #(
            Model(..model, state: StartScreen(new_ss)),
            effect.dispatch(
              NetworkMsg(network.SendMessage(game_message.ListRooms)),
            ),
            option.None,
          )
        }
        _ -> {
          #(
            Model(..model, state: StartScreen(new_ss)),
            effect.none(),
            option.None,
          )
        }
      }
    }
    _ -> #(model, effect.none(), option.None)
  }
}

fn handle_connecting_message(
  model: Model,
  conn_msg: connecting.Msg,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case model.state {
    Connecting(conn_model) -> {
      let #(_new_conn, _) = connecting.update(conn_model, conn_msg)

      // Handle timeout
      case conn_msg {
        connecting.Timeout -> {
          #(
            model,
            effect.dispatch(TransitionToStartScreen("Connection timed out")),
            option.None,
          )
        }
      }
    }
    _ -> #(model, effect.none(), option.None)
  }
}

fn handle_bridge_message(
  model: Model,
  bridge_msg: bridge.BridgeMsg,
  ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case bridge_msg {
    // UI actions
    bridge.UIPlayerNameChanged(name) -> {
      // Update local state
      #(
        model,
        effect.dispatch(StartScreenMsg(start_screen.PlayerNameChanged(name))),
        option.None,
      )
    }

    bridge.UIRefreshRooms -> {
      // Request room list from server
      #(
        model,
        effect.batch([
          effect.dispatch(StartScreenMsg(start_screen.RefreshRooms)),
          effect.dispatch(
            NetworkMsg(network.SendMessage(game_message.ListRooms)),
          ),
        ]),
        option.None,
      )
    }

    bridge.UIJoinRoom(room_id) -> {
      // Get player name from start screen state
      case model.state {
        StartScreen(ss_model) -> {
          #(
            model,
            effect.dispatch(TransitionToConnecting(
              room_id,
              ss_model.player_name,
            )),
            option.None,
          )
        }
        _ -> #(model, effect.none(), option.None)
      }
    }

    bridge.UICreateRoom(name, max_players) -> {
      // Send create room message to server
      #(
        model,
        effect.dispatch(
          NetworkMsg(
            network.SendMessage(game_message.CreateRoom(name, max_players)),
          ),
        ),
        option.None,
      )
    }

    // Game → UI messages (shouldn't come from UI, but ignore gracefully)
    bridge.ShowStartScreen
    | bridge.ShowConnecting(_, _)
    | bridge.ShowInGame
    | bridge.UpdateHealth(_, _)
    | bridge.UpdateMana(_, _)
    | bridge.UpdateActiveWand(_)
    | bridge.UpdateRoomList(_)
    | bridge.ShowError(_) -> #(model, effect.none(), option.None)
  }
}

fn handle_game_message(
  model: Model,
  game_msg: GameMsg,
  ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case model.state {
    InGame(game_model) -> {
      case game_msg {
        MapMsg(map_msg) -> {
          let #(new_map, map_effect) = map.update(game_model.map, map_msg)
          let new_game_model = GameModel(..game_model, map: new_map)
          #(
            Model(..model, state: InGame(new_game_model)),
            effect.map(map_effect, fn(m) { GameMsg(MapMsg(m)) }),
            option.None,
          )
        }

        PlayerMsg(player_msg) -> {
          let #(new_player, player_effect, physics_world) =
            player.update(
              game_model.player,
              player_msg,
              ctx,
              fn(m) { GameMsg(PlayerMsg(m)) },
              fn(client_msg) { NetworkMsg(network.SendMessage(client_msg)) },
            )

          let new_game_model = GameModel(..game_model, player: new_player)

          // Send player state updates to UI
          let ui_effects = send_player_state_to_ui(model.bridge, new_player)

          #(
            Model(..model, state: InGame(new_game_model)),
            effect.batch([player_effect, ui_effects]),
            physics_world,
          )
        }

        EnemyMsg(enemy_msg) -> {
          let #(new_enemy, enemy_effect) =
            enemy.update(game_model.enemy, enemy_msg, ctx, fn(m) {
              GameMsg(EnemyMsg(m))
            })
          let new_game_model = GameModel(..game_model, enemy: new_enemy)
          #(
            Model(..model, state: InGame(new_game_model)),
            enemy_effect,
            option.None,
          )
        }

        ProjectileMsg(projectile_msg) -> {
          let #(new_projectile, projectile_effect) =
            projectile.update(game_model.projectile, projectile_msg, ctx, fn(m) {
              GameMsg(ProjectileMsg(m))
            })
          let new_game_model =
            GameModel(..game_model, projectile: new_projectile)
          #(
            Model(..model, state: InGame(new_game_model)),
            projectile_effect,
            option.None,
          )
        }
      }
    }
    _ -> #(model, effect.none(), option.None)
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> scene.Node {
  case model.state {
    StartScreen(_) | Connecting(_) -> {
      // Hide 3D game, show only UI (handled by Lustre)
      scene.empty(id: "root", transform: transform.identity, children: [])
    }

    InGame(game_model) -> {
      // Render game
      let player_nodes = player.view(game_model.player, ctx)
      let enemy_nodes = enemy.view(game_model.enemy, ctx)
      let projectile_nodes = projectile.view(game_model.projectile, ctx)
      let map_nodes = map.view(game_model.map)

      let all_nodes =
        [player_nodes, enemy_nodes, projectile_nodes, map_nodes]
        |> list.flatten()

      scene.empty(
        id: "root",
        transform: transform.identity,
        children: all_nodes,
      )
    }
  }
}

// =============================================================================
// MAIN
// =============================================================================

pub fn main() {
  // Create the bridge for Tiramisu-Lustre communication
  let bridge = bridge_ui.new_bridge()

  // Start the Lustre UI application
  ui.start(bridge)

  // Create the game application with the bridge
  let init_with_bridge = fn(ctx) { init(ctx, bridge) }

  tiramisu.application(init_with_bridge, update, view)
  |> tiramisu.start(
    "#game",
    tiramisu.FullScreen,
    option.Some(#(bridge, FromBridge)),
  )
}
