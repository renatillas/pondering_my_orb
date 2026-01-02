import gleam/list
import gleam/option
import pondering_my_orb/player/magic
import tiramisu
import tiramisu/effect.{type Effect}
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui
import vec/vec3

import pondering_my_orb/altar
import pondering_my_orb/enemy
import pondering_my_orb/game_physics
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/ui as game_ui

// =============================================================================
// TYPES
// =============================================================================
pub type Msg {
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
}

pub type Model {
  Model(
    player: player.Model,
    enemy: enemy.Model,
    map: map.Model,
    altar: altar.Model,
    physics: game_physics.Model,
    bridge: ui.Bridge(game_ui.Msg, Msg),
  )
}

// =============================================================================
// MAIN
// =============================================================================

pub fn main() -> Nil {
  // 1. Create bridge for Tiramisu <-> Lustre communication
  let bridge = ui.new_bridge()

  // 2. Start Lustre UI on #ui
  let assert Ok(_) =
    game_ui.start(
      bridge,
      fn(index) { PlayerMsg(player.MagicMsg(magic.SelectSlot(index))) },
      fn(id, index) {
        PlayerMsg(player.MagicMsg(magic.PlaceSpellInSlot(id, index)))
      },
      fn(index) { PlayerMsg(player.MagicMsg(magic.RemoveSpellFromSlot(index))) },
      fn(from, to) {
        PlayerMsg(player.MagicMsg(magic.ReorderWandSlots(from, to)))
      },
    )

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
  bridge: ui.Bridge(game_ui.Msg, Msg),
  _ctx: tiramisu.Context,
) -> #(Model, Effect(Msg), option.Option(physics.PhysicsWorld)) {
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
      player: player_model,
      enemy: enemy_model,
      map: map_model,
      altar: altar_model,
      physics: physics_model,
      bridge: bridge,
    )

  // Send initial player state to UI
  let #(slots, selected, mana, max_mana, spell_bag) =
    player.get_wand_ui_state(player_model)
  let wand_names = player.get_wand_names(player_model)
  let active_wand_index = player.get_active_wand_index(player_model)
  let ui_effect =
    ui.to_lustre(
      bridge,
      game_ui.PlayerStateUpdated(
        slots,
        selected,
        mana,
        max_mana,
        spell_bag,
        player_model.health,
        wand_names,
        active_wand_index,
        option.None,
      ),
    )

  // Start independent cycles: player tick, enemy tick, and physics tick
  let physics_tick_effect = effect.tick(PhysicsMsg(game_physics.Tick))

  let effects =
    effect.batch([
      player_effect,
      enemy_effect,
      map_effect,
      altar_effect,
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
  msg: Msg,
  ctx: tiramisu.Context,
) -> #(Model, Effect(Msg), option.Option(physics.PhysicsWorld)) {
  case msg {
    PlayerMsg(player_msg) -> {
      let #(new_player, player_effect) =
        player.update(model.player, player_msg, ctx)
      #(
        Model(..model, player: new_player),
        effect.map(player_effect, PlayerMsg),
        ctx.physics_world,
      )
    }

    EnemyMsg(enemy_msg) -> {
      let #(new_enemy, enemy_effect) =
        enemy.update(
          model.enemy,
          enemy_msg,
          ctx,
          player_took_damage: fn(dmg) { PlayerMsg(player.TakeDamage(dmg)) },
          effect_mapper: EnemyMsg,
        )
      #(Model(..model, enemy: new_enemy), enemy_effect, ctx.physics_world)
    }

    PhysicsMsg(physics_msg) -> {
      let #(result, physics_effect) =
        game_physics.update(
          msg: physics_msg,
          ctx: ctx,
          player_model: model.player,
          enemy_model: model.enemy,
          altar_model: model.altar,
          bridge: model.bridge,
          spawn_altar: fn(pos) { AltarMsg(altar.SpawnAltar(pos)) },
          enemy_took_projectile_damage: fn(id, dmg) {
            EnemyMsg(enemy.TakeProjectileDamage(id, dmg))
          },
          remove_projectile: fn(id) {
            PlayerMsg(player.MagicMsg(magic.RemoveProjectile(id)))
          },
          player_state_updated: game_ui.PlayerStateUpdated,
          pick_up_wand: fn(w) { PlayerMsg(player.MagicMsg(magic.PickUpWand(w))) },
          remove_altar: fn(id) { AltarMsg(altar.RemoveAltar(id)) },
          constructor_wand_display_info: game_ui.WandDisplayInfo,
          toggle_edit_mode: game_ui.ToggleEditMode,
          effect_mapper: PhysicsMsg,
        )

      #(
        Model(
          ..model,
          physics: result.physics,
          enemy: result.enemy,
          altar: result.altar,
        ),
        physics_effect,
        result.stepped_world,
      )
    }

    MapMsg(map_msg) -> {
      let #(new_map, map_effect) = map.update(model.map, map_msg)
      let wrapped_effect = effect.map(map_effect, MapMsg)
      let new_model = Model(..model, map: new_map)
      #(new_model, wrapped_effect, ctx.physics_world)
    }

    AltarMsg(altar_msg) -> {
      let #(new_altar, altar_effect) = altar.update(model.altar, altar_msg, ctx)
      let wrapped_effect = effect.map(altar_effect, AltarMsg)
      let new_model = Model(..model, altar: new_altar)
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
  let altar_nodes = altar.view(model.altar, ctx)

  scene.empty(
    id: "root",
    transform: transform.identity,
    children: list.flatten([player_nodes, enemy_nodes, map_nodes, altar_nodes]),
  )
}
