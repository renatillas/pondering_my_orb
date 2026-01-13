import gleam/option
import tiramisu
import tiramisu/effect
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform

import client/map
import client/network
import client/player

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(map: map.Model, player: player.Model, network: network.Model)
}

pub type Msg {
  MapMsg(map.Msg)
  PlayerMsg(player.Msg)
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
  let #(network_model, network_effect) = network.init()

  let model =
    Model(map: map_model, player: player_model, network: network_model)

  let effects =
    effect.batch([
      effect.map(map_effect, MapMsg),
      effect.map(player_effect, PlayerMsg),
      effect.map(network_effect, NetworkMsg),
    ])

  // Auto-connect to server
  let connect_effect =
    effect.dispatch(
      NetworkMsg(network.Connect(
        server_url: "ws://localhost:8787",
        room_id: "test-room",
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
          // effect_mapper
          fn(client_msg) {
            // TAGGER: Route client messages to network
            NetworkMsg(network.SendMessage(client_msg))
          },
        )
      #(Model(..model, player: new_player), player_effect, physics_world)
    }

    NetworkMsg(network_msg) -> {
      let #(new_network, network_effect) =
        network.update(
          model.network,
          network_msg,
          NetworkMsg,
          // effect_mapper
          fn(server_msg) {
            // TAGGER: Route server messages to player
            PlayerMsg(player.ServerMessageReceived(server_msg))
          },
          ctx,
        )
      #(Model(..model, network: new_network), network_effect, option.None)
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model, ctx: tiramisu.Context) -> scene.Node {
  let player_scene = player.view(model.player, ctx)
  let map_scenes = map.view(model.map)

  // Combine all scenes into a root node
  scene.empty(id: "root", transform: transform.identity, children: [
    player_scene,
    ..map_scenes
  ])
}

// =============================================================================
// MAIN
// =============================================================================

pub fn main() {
  tiramisu.application(init, update, view)
  |> tiramisu.start("#game", tiramisu.FullScreen, option.None)
}
