import gleam/list
import gleam/option
import tiramisu
import tiramisu/effect.{type Effect}
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui
import vec/vec3

import pondering_my_orb/game_msg
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/ui as game_ui

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    player: player.Model,
    map: map.Model,
    physics_world: physics.PhysicsWorld,
    bridge: ui.Bridge(game_msg.ToUI, game_msg.ToGame),
  )
}

// Use game_msg.ToGame as the message type for tiramisu

// =============================================================================
// MAIN
// =============================================================================

pub fn main() -> Nil {
  // 1. Create bridge for Tiramisu <-> Lustre communication
  let bridge = ui.new_bridge()

  // 2. Start Lustre UI on #ui
  let assert Ok(_) = game_ui.start(bridge)

  // 3. Start Tiramisu game on #game with the bridge
  let assert Ok(Nil) =
    tiramisu.run(
      bridge: option.Some(bridge),
      dimensions: option.None,
      selector: "#game",
      init: init(bridge, _),
      update: update,
      view: view,
    )
  Nil
}

// =============================================================================
// INIT
// =============================================================================

fn init(
  bridge: ui.Bridge(game_msg.ToUI, game_msg.ToGame),
  _ctx: tiramisu.Context,
) -> #(Model, Effect(game_msg.ToGame), option.Option(physics.PhysicsWorld)) {
  let #(player_model, player_effect) = player.init()
  let player_effect = effect.map(player_effect, game_msg.PlayerMsg)

  let #(map_model, map_effect) = map.init()
  let map_effect = effect.map(map_effect, game_msg.MapMsg)

  // Create physics world with no gravity (spells float in air)
  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: vec3.Vec3(0.0, 0.0, 0.0)))

  let model =
    Model(
      player: player_model,
      map: map_model,
      physics_world: physics_world,
      bridge: bridge,
    )

  // Send initial wand state to UI
  let #(slots, selected, mana, max_mana, available_spells) =
    player.get_wand_ui_state(player_model)
  let ui_effect =
    ui.to_lustre(
      bridge,
      game_msg.WandUpdated(slots, selected, mana, max_mana, available_spells),
    )

  // Start independent cycles: player tick and physics tick
  let effects =
    effect.batch([
      player_effect,
      map_effect,
      ui_effect,
      effect.tick(game_msg.PhysicsMsg(game_msg.PreStep)),
    ])

  #(model, effects, option.Some(physics_world))
}

// =============================================================================
// UPDATE
// =============================================================================

fn update(
  model: Model,
  msg: game_msg.ToGame,
  ctx: tiramisu.Context,
) -> #(Model, Effect(game_msg.ToGame), option.Option(physics.PhysicsWorld)) {
  case msg {
    game_msg.PlayerMsg(player_msg) -> {
      // Update player (independent of physics)
      let #(new_player, player_effect) =
        player.update(model.player, player_msg, ctx)
      let wrapped_player_effect = effect.map(player_effect, game_msg.PlayerMsg)

      let new_model = Model(..model, player: new_player)

      #(new_model, wrapped_player_effect, option.None)
    }

    game_msg.PhysicsMsg(game_msg.PreStep) -> {
      // User hook: apply forces, set velocities here
      #(model, effect.dispatch(game_msg.PhysicsMsg(game_msg.Step)), option.None)
    }

    game_msg.PhysicsMsg(game_msg.Step) -> {
      // Step physics world
      let new_physics_world = physics.step(model.physics_world, ctx.delta_time)
      let new_model = Model(..model, physics_world: new_physics_world)

      #(
        new_model,
        effect.dispatch(game_msg.PhysicsMsg(game_msg.PostStep)),
        option.Some(new_physics_world),
      )
    }

    game_msg.PhysicsMsg(game_msg.PostStep) -> {
      // User hook: read collision events, check positions
      // Send wand state update to UI
      let #(slots, selected, mana, max_mana, available_spells) =
        player.get_wand_ui_state(model.player)
      let ui_effect =
        ui.to_lustre(
          model.bridge,
          game_msg.WandUpdated(
            slots,
            selected,
            mana,
            max_mana,
            available_spells,
          ),
        )

      // Schedule next physics frame
      #(
        model,
        effect.batch([
          ui_effect,
          effect.tick(game_msg.PhysicsMsg(game_msg.PreStep)),
        ]),
        option.None,
      )
    }

    game_msg.MapMsg(map_msg) -> {
      let #(new_map, map_effect) = map.update(model.map, map_msg)
      let wrapped_effect = effect.map(map_effect, game_msg.MapMsg)
      let new_model = Model(..model, map: new_map)
      #(new_model, wrapped_effect, option.None)
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

fn view(model: Model, ctx: tiramisu.Context) -> scene.Node {
  let player_nodes = player.view(model.player, ctx)
  let map_nodes = map.view(model.map)

  let all_nodes = list.append(player_nodes, map_nodes)

  scene.empty(id: "root", transform: transform.identity, children: all_nodes)
}
