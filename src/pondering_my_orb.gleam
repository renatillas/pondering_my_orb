import gleam/list
import gleam/option
import pondering_my_orb/id
import tiramisu
import tiramisu/effect.{type Effect}
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui
import vec/vec3

import pondering_my_orb/enemy
import pondering_my_orb/game_msg
import pondering_my_orb/game_physics
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/player/magic
import pondering_my_orb/ui as game_ui

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    player: player.Model,
    enemy: enemy.Model,
    map: map.Model,
    physics: game_physics.Model,
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
      dimensions: tiramisu.FullScreen,
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

  let #(enemy_model, enemy_effect) = enemy.init()
  let enemy_effect = effect.map(enemy_effect, game_msg.EnemyMsg)

  let #(map_model, map_effect) = map.init()
  let map_effect = effect.map(map_effect, game_msg.MapMsg)

  // Initialize physics module
  let #(physics_model, _physics_effect) = game_physics.init()

  // Create physics world with no gravity (spells float in air)
  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: vec3.Vec3(0.0, 0.0, 0.0)))

  let model =
    Model(
      player: player_model,
      enemy: enemy_model,
      map: map_model,
      physics: physics_model,
      bridge: bridge,
    )

  // Send initial player state to UI
  let #(slots, selected, mana, max_mana, available_spells) =
    player.get_wand_ui_state(player_model)
  let ui_effect =
    ui.to_lustre(
      bridge,
      game_msg.PlayerStateUpdated(
        slots,
        selected,
        mana,
        max_mana,
        available_spells,
        player_model.health,
      ),
    )

  // Get projectiles for initial physics tick
  let projectiles = player.get_projectiles(player_model)

  // Start independent cycles: player tick, enemy tick, and physics tick
  let physics_tick_effect =
    effect.tick(
      game_msg.PhysicsMsg(game_physics.Tick(
        enemy_model,
        player_model.position,
        projectiles,
      )),
    )

  let effects =
    effect.batch([
      player_effect,
      enemy_effect,
      map_effect,
      ui_effect,
      physics_tick_effect,
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
      let #(new_player, player_effect) =
        player.update(model.player, player_msg, ctx)
      #(
        Model(..model, player: new_player),
        effect.map(player_effect, game_msg.PlayerMsg),
        ctx.physics_world,
      )
    }

    game_msg.EnemyMsg(enemy_msg) -> {
      // Update enemies
      let #(new_enemy, enemy_effect) = enemy.update(model.enemy, enemy_msg, ctx)
      let wrapped_enemy_effect = effect.map(enemy_effect, game_msg.EnemyMsg)

      // Check if enemies dealt damage to player
      let damage = enemy.get_damage_to_player(new_enemy)
      let damage_effect = case damage >. 0.0 {
        True -> effect.dispatch(game_msg.PlayerMsg(player.TakeDamage(damage)))
        False -> effect.none()
      }

      let new_model = Model(..model, enemy: new_enemy)

      #(
        new_model,
        effect.batch([wrapped_enemy_effect, damage_effect]),
        ctx.physics_world,
      )
    }

    game_msg.PhysicsMsg(physics_msg) -> {
      let #(new_physics, _) =
        game_physics.update(model.physics, physics_msg, ctx)

      // Convert collision results to effects
      let collision_effects =
        list.map(new_physics.collision_results, fn(result) {
          case result {
            game_physics.ProjectileHitEnemy(proj_id, enemy_id, damage) ->
              effect.batch([
                effect.dispatch(
                  game_msg.EnemyMsg(enemy.TakeProjectileDamage(
                    id.Enemy(enemy_id),
                    damage,
                  )),
                ),
                effect.dispatch(
                  game_msg.PlayerMsg(
                    player.MagicMsg(magic.RemoveProjectile(proj_id)),
                  ),
                ),
              ])
          }
        })

      // Send player state update to UI
      let #(slots, selected, mana, max_mana, available_spells) =
        player.get_wand_ui_state(model.player)
      let ui_effect =
        ui.to_lustre(
          model.bridge,
          game_msg.PlayerStateUpdated(
            slots,
            selected,
            mana,
            max_mana,
            available_spells,
            model.player.health,
          ),
        )

      // Apply physics positions to enemies (preserves spawns from enemy tick)
      // Also updates player_pos so attack calculations use correct position
      let updated_enemy =
        enemy.apply_physics_positions(
          model.enemy,
          new_physics.enemy_positions,
          model.player.position,
        )

      // Schedule next physics tick with fresh player data
      let projectiles = player.get_projectiles(model.player)
      let next_physics_tick =
        effect.tick(
          game_msg.PhysicsMsg(game_physics.Tick(
            updated_enemy,
            model.player.position,
            projectiles,
          )),
        )

      #(
        Model(..model, enemy: updated_enemy, physics: new_physics),
        effect.batch([
          effect.batch(collision_effects),
          ui_effect,
          next_physics_tick,
        ]),
        new_physics.stepped_world,
      )
    }

    game_msg.MapMsg(map_msg) -> {
      let #(new_map, map_effect) = map.update(model.map, map_msg)
      let wrapped_effect = effect.map(map_effect, game_msg.MapMsg)
      let new_model = Model(..model, map: new_map)
      #(new_model, wrapped_effect, ctx.physics_world)
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

fn view(model: Model, ctx: tiramisu.Context) -> scene.Node {
  let player_nodes = player.view(model.player, ctx)
  let enemy_nodes = enemy.view(model.enemy, ctx)
  let map_nodes = map.view(model.map)

  scene.empty(
    id: "root",
    transform: transform.identity,
    children: list.flatten([player_nodes, enemy_nodes, map_nodes]),
  )
}
