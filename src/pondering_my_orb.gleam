import gleam/float
import gleam/list
import gleam/option
import gleam/time/duration
import iv
import pondering_my_orb/player/magic
import tiramisu
import tiramisu/effect.{type Effect}
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui
import vec/vec3

import pondering_my_orb/altar
import pondering_my_orb/bridge_msg.{type BridgeMsg}
import pondering_my_orb/enemy
import pondering_my_orb/game_physics
import pondering_my_orb/magic_system/wand
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
  /// Bridge messages from UI
  FromBridge(BridgeMsg)
}

pub type Model {
  Model(
    player: player.Model,
    enemy: enemy.Model,
    map: map.Model,
    altar: altar.Model,
    physics: game_physics.Model,
    bridge: ui.Bridge(BridgeMsg),
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
  bridge: ui.Bridge(BridgeMsg),
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
    ui.send_to_ui(
      bridge,
      bridge_msg.PlayerStateUpdated(
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
  let physics_tick_effect = effect.dispatch(PhysicsMsg(game_physics.Tick))

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
    // Handle bridge messages from UI
    FromBridge(bridge_msg_value) -> {
      case bridge_msg_value {
        // UI → Game actions: dispatch to player module
        bridge_msg.SelectSlot(index) -> #(
          model,
          effect.dispatch(PlayerMsg(player.MagicMsg(magic.SelectSlot(index)))),
          ctx.physics_world,
        )
        bridge_msg.PlaceSpellInSlot(spell_id, slot_index) -> #(
          model,
          effect.dispatch(
            PlayerMsg(
              player.MagicMsg(magic.PlaceSpellInSlot(spell_id, slot_index)),
            ),
          ),
          ctx.physics_world,
        )
        bridge_msg.RemoveSpellFromSlot(slot_index) -> #(
          model,
          effect.dispatch(
            PlayerMsg(player.MagicMsg(magic.RemoveSpellFromSlot(slot_index))),
          ),
          ctx.physics_world,
        )
        bridge_msg.ReorderWandSlots(from, to) -> #(
          model,
          effect.dispatch(
            PlayerMsg(player.MagicMsg(magic.ReorderWandSlots(from, to))),
          ),
          ctx.physics_world,
        )
        // Game → UI messages: ignore on game side
        bridge_msg.PlayerStateUpdated(..) | bridge_msg.ToggleEditMode -> #(
          model,
          effect.none(),
          ctx.physics_world,
        )
      }
    }

    PlayerMsg(player_msg) -> {
      // Use current altar model for proximity check (one frame delay - async update)
      let altar_nearby = get_nearby_altar_info(model.altar)

      let #(new_player, player_effect) =
        player.update(
          model.player,
          player_msg,
          ctx,
          bridge: model.bridge,
          altar_nearby: altar_nearby,
          effect_mapper: PlayerMsg,
        )

      // Dispatch async update of altar player position with NEW position
      let altar_pos_effect =
        effect.dispatch(AltarMsg(altar.UpdatePlayerPos(new_player.position)))

      #(
        Model(..model, player: new_player),
        effect.batch([player_effect, altar_pos_effect]),
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
          spawn_altar: fn(pos) { AltarMsg(altar.SpawnAltar(pos)) },
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
          enemy_took_projectile_damage: fn(id, dmg) {
            EnemyMsg(enemy.TakeProjectileDamage(id, dmg))
          },
          remove_projectile: fn(id) {
            PlayerMsg(player.MagicMsg(magic.RemoveProjectile(id)))
          },
          update_altar_player_pos: fn(pos) {
            AltarMsg(altar.UpdatePlayerPos(pos))
          },
          update_enemy_positions: fn(positions, player_pos) {
            EnemyMsg(enemy.UpdatePositionsFromPhysics(positions, player_pos))
          },
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
      let #(new_altar, altar_effect) =
        altar.update(
          model.altar,
          altar_msg,
          ctx,
          pick_up_wand: fn(w) {
            PlayerMsg(player.MagicMsg(magic.PickUpWand(w)))
          },
          effect_mapper: AltarMsg,
        )
      #(Model(..model, altar: new_altar), altar_effect, ctx.physics_world)
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

// =============================================================================
// HELPERS
// =============================================================================

fn get_nearby_altar_info(
  altar_model: altar.Model,
) -> option.Option(bridge_msg.WandDisplayInfo) {
  case altar.get_nearest_altar(altar_model) {
    option.Some(nearby) -> {
      let w = nearby.wand
      option.Some(bridge_msg.WandDisplayInfo(
        name: w.name,
        slot_count: iv.size(w.slots),
        spells_per_cast: w.spells_per_cast,
        cast_delay_ms: float.round(duration.to_seconds(w.cast_delay) *. 1000.0),
        recharge_time_ms: float.round(
          duration.to_seconds(w.recharge_time) *. 1000.0,
        ),
        max_mana: w.max_mana,
        mana_recharge_rate: w.mana_recharge_rate,
        spread: w.spread,
        spell_names: wand.get_spell_names(w),
      ))
    }
    option.None -> option.None
  }
}
