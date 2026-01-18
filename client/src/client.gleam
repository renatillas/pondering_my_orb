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
import client/enemy
import client/map
import client/network
import client/player
import client/projectile
import client/ui

import shared/game_message
import shared/spell
import shared/wand

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    map: map.Model,
    player: player.Model,
    enemy: enemy.Model,
    projectile: projectile.Model,
    network: network.Model,
    bridge: bridge_ui.Bridge(bridge.BridgeMsg),
  )
}

pub type Msg {
  MapMsg(map.Msg)
  PlayerMsg(player.Msg)
  EnemyMsg(enemy.Msg)
  ProjectileMsg(projectile.Msg)
  NetworkMsg(network.Msg)
  FromBridge(bridge.BridgeMsg)
}

// =============================================================================
// INIT
// =============================================================================

pub fn init(
  _ctx: tiramisu.Context,
  bridge: bridge_ui.Bridge(bridge.BridgeMsg),
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  let #(map_model, map_effect) = map.init()
  let #(player_model, player_effect) = player.init()
  let #(enemy_model, enemy_effect) = enemy.init()
  let #(projectile_model, projectile_effect) = projectile.init()
  let #(network_model, network_effect) = network.init()

  let model =
    Model(
      map: map_model,
      player: player_model,
      enemy: enemy_model,
      projectile: projectile_model,
      network: network_model,
      bridge: bridge,
    )

  let effects =
    effect.batch([
      effect.map(map_effect, MapMsg),
      effect.map(player_effect, PlayerMsg),
      effect.map(enemy_effect, EnemyMsg),
      effect.map(projectile_effect, ProjectileMsg),
      effect.map(network_effect, NetworkMsg),
    ])

  // Auto-connect to server
  let connect_effect =
    effect.dispatch(
      NetworkMsg(network.Connect(
        server_url: "ws://localhost:8080",
        player_name: "LocalPlayer",
      )),
    )

  // Send initial player state to UI
  let initial_ui_update = send_player_state_to_ui(bridge, player_model)

  #(
    model,
    effect.batch([effects, connect_effect, initial_ui_update]),
    option.None,
  )
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
    // No cooldown, always ready
    max -> {
      let progress =
        100.0
        -. { int.to_float(cooldown_remaining_ms) /. int.to_float(max) *. 100.0 }
      // Clamp to 0-100 range
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
    // Handle bridge messages from UI (future: slot switching, etc.)
    FromBridge(_bridge_msg) -> #(model, effect.none(), option.None)

    MapMsg(map_msg) -> {
      let #(new_map, map_effect) = map.update(model.map, map_msg)
      #(
        Model(..model, map: new_map),
        effect.map(map_effect, MapMsg),
        option.None,
      )
    }

    PlayerMsg(player_msg) -> {
      let #(new_player, player_effect, physics_world) =
        player.update(
          model.player,
          player_msg,
          ctx,
          PlayerMsg,
          // Tagger: Route client messages to network
          fn(client_msg) { NetworkMsg(network.SendMessage(client_msg)) },
        )

      // Send player state updates to UI via bridge
      let ui_effects = send_player_state_to_ui(model.bridge, new_player)

      #(
        Model(..model, player: new_player),
        effect.batch([player_effect, ui_effects]),
        physics_world,
      )
    }

    EnemyMsg(enemy_msg) -> {
      let #(new_enemy, enemy_effect) =
        enemy.update(model.enemy, enemy_msg, ctx, EnemyMsg)
      #(Model(..model, enemy: new_enemy), enemy_effect, option.None)
    }

    ProjectileMsg(projectile_msg) -> {
      let #(new_projectile, projectile_effect) =
        projectile.update(model.projectile, projectile_msg, ctx, ProjectileMsg)
      #(
        Model(..model, projectile: new_projectile),
        projectile_effect,
        option.None,
      )
    }

    NetworkMsg(network_msg) -> {
      // Handle network messages and route server messages to appropriate modules
      case network_msg {
        network.ReceivedMessage(data) -> {
          // Decode and route server message
          case game_message.decode_server_message(data) {
            Ok(server_msg) -> {
              handle_server_message(model, server_msg, ctx)
            }
            Error(_err) -> {
              // Failed to decode, just update network module
              let #(new_network, network_effect) =
                network.update(
                  model.network,
                  network_msg,
                  NetworkMsg,
                  fn(_) { NetworkMsg(network.SocketClosed) },
                  ctx,
                )
              #(
                Model(..model, network: new_network),
                network_effect,
                option.None,
              )
            }
          }
        }

        _ -> {
          // Other network messages (Connect, Disconnect, etc.)
          let #(new_network, network_effect) =
            network.update(
              model.network,
              network_msg,
              NetworkMsg,
              fn(server_msg) {
                PlayerMsg(player.ServerMessageReceived(server_msg))
              },
              ctx,
            )
          #(Model(..model, network: new_network), network_effect, option.None)
        }
      }
    }
  }
}

/// Route server messages to appropriate modules (can dispatch to multiple)
fn handle_server_message(
  model: Model,
  server_msg: game_message.ServerMessage,
  _ctx: tiramisu.Context,
) -> #(Model, effect.Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case server_msg {
    game_message.GameStateUpdate(
      _tick,
      _players,
      _player_wands,
      projectile_list,
      enemy_list,
    ) -> {
      // Convert lists to dicts
      let projectiles_dict =
        projectile_list
        |> list.map(fn(p) { #(p.id, p) })
        |> dict.from_list()

      let enemies_dict =
        enemy_list
        |> list.map(fn(e) { #(e.id, e) })
        |> dict.from_list()

      // Dispatch to all three modules
      let dispatch_effects =
        effect.batch([
          effect.dispatch(PlayerMsg(player.ServerMessageReceived(server_msg))),
          effect.dispatch(EnemyMsg(enemy.UpdateFromServer(enemies_dict))),
          effect.dispatch(
            ProjectileMsg(projectile.UpdateFromServer(projectiles_dict)),
          ),
        ])

      #(model, dispatch_effects, option.None)
    }

    _ -> {
      // Other messages go to player module only
      #(
        model,
        effect.dispatch(PlayerMsg(player.ServerMessageReceived(server_msg))),
        option.None,
      )
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> scene.Node {
  let player_nodes = player.view(model.player, ctx)
  let enemy_nodes = enemy.view(model.enemy, ctx)
  let projectile_nodes = projectile.view(model.projectile, ctx)
  let map_nodes = map.view(model.map)

  // Combine all scenes into a root node
  let all_nodes =
    [player_nodes, enemy_nodes, projectile_nodes, map_nodes]
    |> list.flatten()

  scene.empty(id: "root", transform: transform.identity, children: all_nodes)
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
