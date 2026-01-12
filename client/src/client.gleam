import client/player/magic
import gleam/bool
import gleam/int
import gleam/list
import gleam/option
import tiramisu
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui
import vec/vec3

import client/altar
import client/assets
import client/enemy
import client/game_physics
import client/map
import client/player
import client/ui as game_ui

// =============================================================================
// TYPES
// =============================================================================
pub type Msg {
  /// Main module tick - handles global input (I key for inventory)
  Tick
  /// Player tick - handles movement, casting, projectiles
  PlayerMsg(player.Msg)
  /// Enemy tick - handles spawning, movement, attacks
  EnemyMsg(enemy.Msg)
  /// Wrapped map module messages
  MapMsg(map.Msg)
  /// Physics step messages
  PhysicsMsg(game_physics.Msg)
  /// Altar tick - handles altar spawning and pickup
  AltarMsg(altar.Msg)
  /// Asset loading messages
  AssetsMsg(assets.Msg)
  /// Bridge messages from UI
  FromBridge(game_ui.BridgeMsg)
}

pub type Model {
  Model(
    assets: assets.Model,
    player: player.Model,
    enemy: enemy.Model,
    map: map.Model,
    altar: altar.Model,
    physics: game_physics.Model,
    bridge: ui.Bridge(game_ui.BridgeMsg),
    edit_mode: Bool,
  )
}

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
    tiramisu.application(init(bridge, _), update, view)
    |> tiramisu.start(
      "#game",
      tiramisu.FullScreen,
      option.Some(#(bridge, FromBridge)),
    )
  Nil
}

// =============================================================================
// INIT
// =============================================================================

fn init(
  bridge: ui.Bridge(game_ui.BridgeMsg),
  _ctx: tiramisu.Context,
) -> #(Model, Effect(Msg), option.Option(physics.PhysicsWorld)) {
  // Initialize assets (textures) first
  let #(assets_model, assets_effect) = assets.init()
  let assets_effect = effect.map(assets_effect, AssetsMsg)

  let #(player_model, player_effect) = player.init()
  let player_effect = effect.map(player_effect, PlayerMsg)

  let #(enemy_model, enemy_effect) = enemy.init()
  let enemy_effect = effect.map(enemy_effect, EnemyMsg)

  let #(map_model, map_effect) = map.init()
  let map_effect = effect.map(map_effect, MapMsg)

  let #(altar_model, altar_effect) = altar.init()
  let altar_effect = effect.map(altar_effect, AltarMsg)

  // Initialize physics module
  let #(physics_model, _physics_effect) = game_physics.init()

  // Create physics world with no gravity (spells float in air)
  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: vec3.Vec3(0.0, 0.0, 0.0)))

  let model =
    Model(
      assets: assets_model,
      player: player_model,
      enemy: enemy_model,
      map: map_model,
      altar: altar_model,
      physics: physics_model,
      bridge: bridge,
      edit_mode: False,
    )

  // Start independent cycles: main tick, player tick, enemy tick, and physics tick
  let main_tick_effect = effect.dispatch(Tick)
  let physics_tick_effect = effect.dispatch(PhysicsMsg(game_physics.Tick))

  // Send initial UI state
  let health_ui_effect =
    ui.send_to_ui(bridge, game_ui.HealthUpdated(player_model.health))
  let wand_ui_effect =
    ui.send_to_ui(
      bridge,
      game_ui.WandStateUpdated(game_ui.WandInfo(
        wand: player.get_active_wand(player_model),
        cast_index: player.get_wand_cast_index(player_model),
      )),
    )
  let active_wand_ui_effect =
    ui.send_to_ui(
      bridge,
      game_ui.ActiveWandChanged(
        index: player.get_active_wand_index(player_model),
        total_wands: 4,
      ),
    )

  let effects =
    effect.batch([
      main_tick_effect,
      assets_effect,
      player_effect,
      enemy_effect,
      map_effect,
      altar_effect,
      physics_tick_effect,
      health_ui_effect,
      wand_ui_effect,
      active_wand_ui_effect,
    ])

  #(model, effects, option.Some(physics_world))
}

// =============================================================================
// UPDATE
// =============================================================================

fn update(
  model: Model,
  msg: Msg,
  ctx: tiramisu.Context,
) -> #(Model, Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case msg {
    // Main tick - handle global input (I key for inventory)
    Tick -> {
      // Check for I key press to toggle inventory
      let #(new_edit_mode, edit_mode_effect) = case
        input.is_key_just_pressed(ctx.input, input.KeyI)
      {
        True -> {
          let toggled = !model.edit_mode
          // Build wand info list for UI
          let wands_info =
            player.get_all_wands_with_cast_indices(model.player)
            |> list.map(fn(pair) {
              game_ui.WandInfo(wand: pair.0, cast_index: pair.1)
            })
          let ui_effect =
            ui.send_to_ui(
              model.bridge,
              game_ui.EditModeToggled(is_open: toggled, wands: wands_info),
            )
          // When unpausing (toggled = False), restart all module tick cycles
          let restart_effects = case toggled {
            False ->
              effect.batch([
                effect.dispatch(PlayerMsg(player.Tick)),
                effect.dispatch(PlayerMsg(player.MagicMsg(magic.Tick))),
                effect.dispatch(EnemyMsg(enemy.Tick)),
                effect.dispatch(PhysicsMsg(game_physics.Tick)),
                effect.dispatch(AltarMsg(altar.Tick)),
              ])
            True -> effect.none()
          }
          #(toggled, effect.batch([ui_effect, restart_effects]))
        }
        False -> #(model.edit_mode, effect.none())
      }

      #(
        Model(..model, edit_mode: new_edit_mode),
        effect.batch([effect.dispatch(Tick), edit_mode_effect]),
        ctx.physics_world,
      )
    }

    // Handle bridge messages from UI
    FromBridge(_) -> #(model, effect.none(), ctx.physics_world)

    PlayerMsg(player_msg) -> {
      use <- bool.guard(model.edit_mode, return: #(
        model,
        effect.none(),
        ctx.physics_world,
      ))

      let #(new_player, player_effect) =
        player.update(model.player, player_msg, ctx, effect_mapper: PlayerMsg)

      // Send UI updates for health and wand state
      let health_ui_effect =
        ui.send_to_ui(model.bridge, game_ui.HealthUpdated(new_player.health))
      let wand_ui_effect =
        ui.send_to_ui(
          model.bridge,
          game_ui.WandStateUpdated(game_ui.WandInfo(
            wand: player.get_active_wand(new_player),
            cast_index: player.get_wand_cast_index(new_player),
          )),
        )
      let active_wand_ui_effect =
        ui.send_to_ui(
          model.bridge,
          game_ui.ActiveWandChanged(
            index: player.get_active_wand_index(new_player),
            total_wands: 4,
          ),
        )

      let all_effects =
        effect.batch([
          player_effect,
          health_ui_effect,
          wand_ui_effect,
          active_wand_ui_effect,
        ])

      #(Model(..model, player: new_player), all_effects, ctx.physics_world)
    }

    EnemyMsg(enemy_msg) -> {
      use <- bool.guard(model.edit_mode, return: #(
        model,
        effect.none(),
        ctx.physics_world,
      ))

      let #(new_enemy, enemy_effect) =
        enemy.update(
          model.enemy,
          enemy_msg,
          ctx,
          player_took_damage: fn(dmg) { PlayerMsg(player.DamageReceived(dmg)) },
          spawn_altar: fn(position) { AltarMsg(altar.EnemyDied(position)) },
          effect_mapper: EnemyMsg,
        )
      #(Model(..model, enemy: new_enemy), enemy_effect, ctx.physics_world)
    }

    PhysicsMsg(physics_msg) -> {
      use <- bool.guard(model.edit_mode, return: #(
        model,
        effect.none(),
        ctx.physics_world,
      ))

      let #(physics_model, physics_effect) =
        game_physics.update(
          msg: physics_msg,
          ctx: ctx,
          player_model: model.player,
          enemy_model: model.enemy,
          enemy_took_projectile_damage: fn(id, dmg) {
            EnemyMsg(enemy.ProjectileHasHitEnemy(id, dmg))
          },
          remove_projectile: fn(id) {
            PlayerMsg(player.MagicMsg(magic.RemoveProjectile(id)))
          },
          update_enemy_positions: fn(positions, player_pos) {
            EnemyMsg(enemy.PhysicsUpdatedPosition(positions, player_pos))
          },
          effect_mapper: PhysicsMsg,
        )

      // Extract updated enemy from physics model (or keep current if None)
      let updated_enemy =
        option.unwrap(physics_model.updated_enemy, model.enemy)

      #(
        Model(..model, physics: physics_model, enemy: updated_enemy),
        physics_effect,
        physics_model.stepped_world,
      )
    }

    MapMsg(map_msg) -> {
      let #(new_map, map_effect) = map.update(model.map, map_msg)
      let wrapped_effect = effect.map(map_effect, MapMsg)
      let new_model = Model(..model, map: new_map)
      #(new_model, wrapped_effect, ctx.physics_world)
    }

    AssetsMsg(assets_msg) -> {
      let #(new_assets, assets_effect) = assets.update(model.assets, assets_msg)
      let wrapped_effect = effect.map(assets_effect, AssetsMsg)
      #(Model(..model, assets: new_assets), wrapped_effect, ctx.physics_world)
    }

    AltarMsg(altar_msg) -> {
      // Skip altar updates when paused (inventory open)
      case model.edit_mode {
        True -> #(model, effect.none(), ctx.physics_world)
        False -> {
          let #(new_altar, altar_effect) =
            altar.update(
              model.altar,
              altar_msg,
              ctx,
              player_pos: model.player.position,
              pick_up_wand: fn(w) {
                PlayerMsg(player.MagicMsg(magic.PickUpWand(w)))
              },
              effect_mapper: AltarMsg,
            )
          #(Model(..model, altar: new_altar), altar_effect, ctx.physics_world)
        }
      }
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

fn view(model: Model, ctx: tiramisu.Context) -> scene.Node {
  // Check if ALL assets are loaded (map FBX models + textures)
  let all_loaded = assets.is_loaded(model.assets) && map.is_loaded(model.map)

  case all_loaded {
    False -> view_loading_screen(model)
    True -> view_game(model, ctx)
  }
}

fn view_loading_screen(model: Model) -> scene.Node {
  // Combine loading progress from assets and map
  let #(assets_loaded, assets_total) = assets.get_progress(model.assets)
  let #(map_loaded, map_total) = map.get_progress(model.map)
  let total_loaded = assets_loaded + map_loaded
  let total_assets = assets_total + map_total

  let progress = int.to_float(total_loaded) /. int.to_float(total_assets)

  // Loading cube that grows with progress
  let assert Ok(geo) = geometry.box(vec3.Vec3(1.0, 1.0, 1.0))
  let assert Ok(mat) =
    material.new()
    |> material.with_color(0x4ecdc4)
    |> material.build()

  let loading_cube =
    scene.mesh(
      id: "loading-cube",
      geometry: geo,
      material: mat,
      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0))
        |> transform.with_scale(vec3.Vec3(
          1.0 +. progress *. 2.0,
          1.0 +. progress *. 2.0,
          1.0 +. progress *. 2.0,
        )),
      physics: option.None,
    )

  scene.empty(id: "root", transform: transform.identity, children: [
    loading_cube,
  ])
}

fn view_game(model: Model, ctx: tiramisu.Context) -> scene.Node {
  let player_nodes = player.view(model.player, ctx, model.assets)
  let enemy_nodes = enemy.view(model.enemy, ctx)
  let map_nodes = map.view(model.map)
  let altar_nodes = altar.view(model.altar, ctx)

  scene.empty(
    id: "root",
    transform: transform.identity,
    children: list.flatten([player_nodes, enemy_nodes, map_nodes, altar_nodes]),
  )
}
