import gleam/dict
import gleam/list
import gleam/option
import tiramisu
import tiramisu/effect
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform

import client/enemy
import client/map
import client/network
import client/player
import client/projectile

import shared/game_message

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
  )
}

pub type Msg {
  MapMsg(map.Msg)
  PlayerMsg(player.Msg)
  EnemyMsg(enemy.Msg)
  ProjectileMsg(projectile.Msg)
  NetworkMsg(network.Msg)
}

// =============================================================================
// INIT
// =============================================================================

pub fn init(
  _ctx: tiramisu.Context,
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

  #(model, effect.batch([effects, connect_effect]), option.None)
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
      #(Model(..model, player: new_player), player_effect, physics_world)
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
    game_message.GameStateUpdate(_tick, players, projectile_list, enemy_list) -> {
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
  tiramisu.application(init, update, view)
  |> tiramisu.start("#game", tiramisu.FullScreen, option.None)
}
