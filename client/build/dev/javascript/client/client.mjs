import * as $bool from "../gleam_stdlib/gleam/bool.mjs";
import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $tiramisu from "../tiramisu/tiramisu.mjs";
import * as $effect from "../tiramisu/tiramisu/effect.mjs";
import * as $geometry from "../tiramisu/tiramisu/geometry.mjs";
import * as $input from "../tiramisu/tiramisu/input.mjs";
import * as $material from "../tiramisu/tiramisu/material.mjs";
import * as $physics from "../tiramisu/tiramisu/physics.mjs";
import * as $scene from "../tiramisu/tiramisu/scene.mjs";
import * as $transform from "../tiramisu/tiramisu/transform.mjs";
import * as $ui from "../tiramisu/tiramisu/ui.mjs";
import * as $vec3 from "../vec/vec/vec3.mjs";
import * as $altar from "./client/altar.mjs";
import * as $assets from "./client/assets.mjs";
import * as $enemy from "./client/enemy.mjs";
import * as $game_physics from "./client/game_physics.mjs";
import * as $map from "./client/map.mjs";
import * as $player from "./client/player.mjs";
import * as $magic from "./client/player/magic.mjs";
import * as $game_ui from "./client/ui.mjs";
import { Ok, toList, CustomType as $CustomType, makeError, divideFloat } from "./gleam.mjs";

const FILEPATH = "src/client.gleam";

export class Tick extends $CustomType {}
export const Msg$Tick = () => new Tick();
export const Msg$isTick = (value) => value instanceof Tick;

/**
 * Player tick - handles movement, casting, projectiles
 */
export class PlayerMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$PlayerMsg = ($0) => new PlayerMsg($0);
export const Msg$isPlayerMsg = (value) => value instanceof PlayerMsg;
export const Msg$PlayerMsg$0 = (value) => value[0];

/**
 * Enemy tick - handles spawning, movement, attacks
 */
export class EnemyMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$EnemyMsg = ($0) => new EnemyMsg($0);
export const Msg$isEnemyMsg = (value) => value instanceof EnemyMsg;
export const Msg$EnemyMsg$0 = (value) => value[0];

/**
 * Wrapped map module messages
 */
export class MapMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$MapMsg = ($0) => new MapMsg($0);
export const Msg$isMapMsg = (value) => value instanceof MapMsg;
export const Msg$MapMsg$0 = (value) => value[0];

/**
 * Physics step messages
 */
export class PhysicsMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$PhysicsMsg = ($0) => new PhysicsMsg($0);
export const Msg$isPhysicsMsg = (value) => value instanceof PhysicsMsg;
export const Msg$PhysicsMsg$0 = (value) => value[0];

/**
 * Altar tick - handles altar spawning and pickup
 */
export class AltarMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$AltarMsg = ($0) => new AltarMsg($0);
export const Msg$isAltarMsg = (value) => value instanceof AltarMsg;
export const Msg$AltarMsg$0 = (value) => value[0];

/**
 * Asset loading messages
 */
export class AssetsMsg extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$AssetsMsg = ($0) => new AssetsMsg($0);
export const Msg$isAssetsMsg = (value) => value instanceof AssetsMsg;
export const Msg$AssetsMsg$0 = (value) => value[0];

/**
 * Bridge messages from UI
 */
export class FromBridge extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$FromBridge = ($0) => new FromBridge($0);
export const Msg$isFromBridge = (value) => value instanceof FromBridge;
export const Msg$FromBridge$0 = (value) => value[0];

export class Model extends $CustomType {
  constructor(assets, player, enemy, map, altar, physics, bridge, edit_mode) {
    super();
    this.assets = assets;
    this.player = player;
    this.enemy = enemy;
    this.map = map;
    this.altar = altar;
    this.physics = physics;
    this.bridge = bridge;
    this.edit_mode = edit_mode;
  }
}
export const Model$Model = (assets, player, enemy, map, altar, physics, bridge, edit_mode) =>
  new Model(assets, player, enemy, map, altar, physics, bridge, edit_mode);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$assets = (value) => value.assets;
export const Model$Model$0 = (value) => value.assets;
export const Model$Model$player = (value) => value.player;
export const Model$Model$1 = (value) => value.player;
export const Model$Model$enemy = (value) => value.enemy;
export const Model$Model$2 = (value) => value.enemy;
export const Model$Model$map = (value) => value.map;
export const Model$Model$3 = (value) => value.map;
export const Model$Model$altar = (value) => value.altar;
export const Model$Model$4 = (value) => value.altar;
export const Model$Model$physics = (value) => value.physics;
export const Model$Model$5 = (value) => value.physics;
export const Model$Model$bridge = (value) => value.bridge;
export const Model$Model$6 = (value) => value.bridge;
export const Model$Model$edit_mode = (value) => value.edit_mode;
export const Model$Model$7 = (value) => value.edit_mode;

function init(bridge, _) {
  let $ = $assets.init();
  let assets_model;
  let assets_effect;
  assets_model = $[0];
  assets_effect = $[1];
  let assets_effect$1 = $effect.map(
    assets_effect,
    (var0) => { return new AssetsMsg(var0); },
  );
  let $1 = $player.init();
  let player_model;
  let player_effect;
  player_model = $1[0];
  player_effect = $1[1];
  let player_effect$1 = $effect.map(
    player_effect,
    (var0) => { return new PlayerMsg(var0); },
  );
  let $2 = $enemy.init();
  let enemy_model;
  let enemy_effect;
  enemy_model = $2[0];
  enemy_effect = $2[1];
  let enemy_effect$1 = $effect.map(
    enemy_effect,
    (var0) => { return new EnemyMsg(var0); },
  );
  let $3 = $map.init();
  let map_model;
  let map_effect;
  map_model = $3[0];
  map_effect = $3[1];
  let map_effect$1 = $effect.map(
    map_effect,
    (var0) => { return new MapMsg(var0); },
  );
  let $4 = $altar.init();
  let altar_model;
  let altar_effect;
  altar_model = $4[0];
  altar_effect = $4[1];
  let altar_effect$1 = $effect.map(
    altar_effect,
    (var0) => { return new AltarMsg(var0); },
  );
  let $5 = $game_physics.init();
  let physics_model;
  physics_model = $5[0];
  let physics_world = $physics.new_world(
    new $physics.WorldConfig(new $vec3.Vec3(0.0, 0.0, 0.0)),
  );
  let model = new Model(
    assets_model,
    player_model,
    enemy_model,
    map_model,
    altar_model,
    physics_model,
    bridge,
    false,
  );
  let main_tick_effect = $effect.dispatch(new Tick());
  let physics_tick_effect = $effect.dispatch(
    new PhysicsMsg(new $game_physics.Tick()),
  );
  let health_ui_effect = $ui.send_to_ui(
    bridge,
    new $game_ui.HealthUpdated(player_model.health),
  );
  let wand_ui_effect = $ui.send_to_ui(
    bridge,
    new $game_ui.WandStateUpdated(
      new $game_ui.WandInfo(
        $player.get_active_wand(player_model),
        $player.get_wand_cast_index(player_model),
      ),
    ),
  );
  let active_wand_ui_effect = $ui.send_to_ui(
    bridge,
    new $game_ui.ActiveWandChanged(
      $player.get_active_wand_index(player_model),
      4,
    ),
  );
  let effects = $effect.batch(
    toList([
      main_tick_effect,
      assets_effect$1,
      player_effect$1,
      enemy_effect$1,
      map_effect$1,
      altar_effect$1,
      physics_tick_effect,
      health_ui_effect,
      wand_ui_effect,
      active_wand_ui_effect,
    ]),
  );
  return [model, effects, new $option.Some(physics_world)];
}

function update(model, msg, ctx) {
  if (msg instanceof Tick) {
    let _block;
    let $1 = $input.is_key_just_pressed(ctx.input, new $input.KeyI());
    if ($1) {
      let toggled = !model.edit_mode;
      let _block$1;
      let _pipe = $player.get_all_wands_with_cast_indices(model.player);
      _block$1 = $list.map(
        _pipe,
        (pair) => { return new $game_ui.WandInfo(pair[0], pair[1]); },
      );
      let wands_info = _block$1;
      let ui_effect = $ui.send_to_ui(
        model.bridge,
        new $game_ui.EditModeToggled(toggled, wands_info),
      );
      let _block$2;
      if (toggled) {
        _block$2 = $effect.none();
      } else {
        _block$2 = $effect.batch(
          toList([
            $effect.dispatch(new PlayerMsg(new $player.Tick())),
            $effect.dispatch(
              new PlayerMsg(new $player.MagicMsg(new $magic.Tick())),
            ),
            $effect.dispatch(new EnemyMsg(new $enemy.Tick())),
            $effect.dispatch(new PhysicsMsg(new $game_physics.Tick())),
            $effect.dispatch(new AltarMsg(new $altar.Tick())),
          ]),
        );
      }
      let restart_effects = _block$2;
      _block = [toggled, $effect.batch(toList([ui_effect, restart_effects]))];
    } else {
      _block = [model.edit_mode, $effect.none()];
    }
    let $ = _block;
    let new_edit_mode;
    let edit_mode_effect;
    new_edit_mode = $[0];
    edit_mode_effect = $[1];
    return [
      new Model(
        model.assets,
        model.player,
        model.enemy,
        model.map,
        model.altar,
        model.physics,
        model.bridge,
        new_edit_mode,
      ),
      $effect.batch(toList([$effect.dispatch(new Tick()), edit_mode_effect])),
      ctx.physics_world,
    ];
  } else if (msg instanceof PlayerMsg) {
    let player_msg = msg[0];
    return $bool.guard(
      model.edit_mode,
      [model, $effect.none(), ctx.physics_world],
      () => {
        let $ = $player.update(
          model.player,
          player_msg,
          ctx,
          (var0) => { return new PlayerMsg(var0); },
        );
        let new_player;
        let player_effect;
        new_player = $[0];
        player_effect = $[1];
        let health_ui_effect = $ui.send_to_ui(
          model.bridge,
          new $game_ui.HealthUpdated(new_player.health),
        );
        let wand_ui_effect = $ui.send_to_ui(
          model.bridge,
          new $game_ui.WandStateUpdated(
            new $game_ui.WandInfo(
              $player.get_active_wand(new_player),
              $player.get_wand_cast_index(new_player),
            ),
          ),
        );
        let active_wand_ui_effect = $ui.send_to_ui(
          model.bridge,
          new $game_ui.ActiveWandChanged(
            $player.get_active_wand_index(new_player),
            4,
          ),
        );
        let all_effects = $effect.batch(
          toList([
            player_effect,
            health_ui_effect,
            wand_ui_effect,
            active_wand_ui_effect,
          ]),
        );
        return [
          new Model(
            model.assets,
            new_player,
            model.enemy,
            model.map,
            model.altar,
            model.physics,
            model.bridge,
            model.edit_mode,
          ),
          all_effects,
          ctx.physics_world,
        ];
      },
    );
  } else if (msg instanceof EnemyMsg) {
    let enemy_msg = msg[0];
    return $bool.guard(
      model.edit_mode,
      [model, $effect.none(), ctx.physics_world],
      () => {
        let $ = $enemy.update(
          model.enemy,
          enemy_msg,
          ctx,
          (dmg) => { return new PlayerMsg(new $player.DamageReceived(dmg)); },
          (position) => { return new AltarMsg(new $altar.EnemyDied(position)); },
          (var0) => { return new EnemyMsg(var0); },
        );
        let new_enemy;
        let enemy_effect;
        new_enemy = $[0];
        enemy_effect = $[1];
        return [
          new Model(
            model.assets,
            model.player,
            new_enemy,
            model.map,
            model.altar,
            model.physics,
            model.bridge,
            model.edit_mode,
          ),
          enemy_effect,
          ctx.physics_world,
        ];
      },
    );
  } else if (msg instanceof MapMsg) {
    let map_msg = msg[0];
    let $ = $map.update(model.map, map_msg);
    let new_map;
    let map_effect;
    new_map = $[0];
    map_effect = $[1];
    let wrapped_effect = $effect.map(
      map_effect,
      (var0) => { return new MapMsg(var0); },
    );
    let new_model = new Model(
      model.assets,
      model.player,
      model.enemy,
      new_map,
      model.altar,
      model.physics,
      model.bridge,
      model.edit_mode,
    );
    return [new_model, wrapped_effect, ctx.physics_world];
  } else if (msg instanceof PhysicsMsg) {
    let physics_msg = msg[0];
    return $bool.guard(
      model.edit_mode,
      [model, $effect.none(), ctx.physics_world],
      () => {
        let $ = $game_physics.update(
          physics_msg,
          ctx,
          model.player,
          model.enemy,
          (id, dmg) => {
            return new EnemyMsg(new $enemy.ProjectileHasHitEnemy(id, dmg));
          },
          (id) => {
            return new PlayerMsg(
              new $player.MagicMsg(new $magic.RemoveProjectile(id)),
            );
          },
          (positions, player_pos) => {
            return new EnemyMsg(
              new $enemy.PhysicsUpdatedPosition(positions, player_pos),
            );
          },
          (var0) => { return new PhysicsMsg(var0); },
        );
        let physics_model;
        let physics_effect;
        physics_model = $[0];
        physics_effect = $[1];
        let updated_enemy = $option.unwrap(
          physics_model.updated_enemy,
          model.enemy,
        );
        return [
          new Model(
            model.assets,
            model.player,
            updated_enemy,
            model.map,
            model.altar,
            physics_model,
            model.bridge,
            model.edit_mode,
          ),
          physics_effect,
          physics_model.stepped_world,
        ];
      },
    );
  } else if (msg instanceof AltarMsg) {
    let altar_msg = msg[0];
    let $ = model.edit_mode;
    if ($) {
      return [model, $effect.none(), ctx.physics_world];
    } else {
      let $1 = $altar.update(
        model.altar,
        altar_msg,
        ctx,
        model.player.position,
        (w) => {
          return new PlayerMsg(new $player.MagicMsg(new $magic.PickUpWand(w)));
        },
        (var0) => { return new AltarMsg(var0); },
      );
      let new_altar;
      let altar_effect;
      new_altar = $1[0];
      altar_effect = $1[1];
      return [
        new Model(
          model.assets,
          model.player,
          model.enemy,
          model.map,
          new_altar,
          model.physics,
          model.bridge,
          model.edit_mode,
        ),
        altar_effect,
        ctx.physics_world,
      ];
    }
  } else if (msg instanceof AssetsMsg) {
    let assets_msg = msg[0];
    let $ = $assets.update(model.assets, assets_msg);
    let new_assets;
    let assets_effect;
    new_assets = $[0];
    assets_effect = $[1];
    let wrapped_effect = $effect.map(
      assets_effect,
      (var0) => { return new AssetsMsg(var0); },
    );
    return [
      new Model(
        new_assets,
        model.player,
        model.enemy,
        model.map,
        model.altar,
        model.physics,
        model.bridge,
        model.edit_mode,
      ),
      wrapped_effect,
      ctx.physics_world,
    ];
  } else {
    return [model, $effect.none(), ctx.physics_world];
  }
}

function view_loading_screen(model) {
  let $ = $assets.get_progress(model.assets);
  let assets_loaded;
  let assets_total;
  assets_loaded = $[0];
  assets_total = $[1];
  let $1 = $map.get_progress(model.map);
  let map_loaded;
  let map_total;
  map_loaded = $1[0];
  map_total = $1[1];
  let total_loaded = assets_loaded + map_loaded;
  let total_assets = assets_total + map_total;
  let progress = divideFloat(
    $int.to_float(total_loaded),
    $int.to_float(total_assets)
  );
  let $2 = $geometry.box(new $vec3.Vec3(1.0, 1.0, 1.0));
  let geo;
  if ($2 instanceof Ok) {
    geo = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client",
      378,
      "view_loading_screen",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 11508,
        end: 11567,
        pattern_start: 11519,
        pattern_end: 11526
      }
    )
  }
  let _block;
  let _pipe = $material.new$();
  let _pipe$1 = $material.with_color(_pipe, 0x4ecdc4);
  _block = $material.build(_pipe$1);
  let $3 = _block;
  let mat;
  if ($3 instanceof Ok) {
    mat = $3[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client",
      379,
      "view_loading_screen",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $3,
        start: 11570,
        end: 11670,
        pattern_start: 11581,
        pattern_end: 11588
      }
    )
  }
  let loading_cube = $scene.mesh(
    "loading-cube",
    geo,
    mat,
    (() => {
      let _pipe$2 = $transform.at(new $vec3.Vec3(0.0, 0.0, 0.0));
      return $transform.with_scale(
        _pipe$2,
        new $vec3.Vec3(
          1.0 + (progress * 2.0),
          1.0 + (progress * 2.0),
          1.0 + (progress * 2.0),
        ),
      );
    })(),
    new $option.None(),
  );
  return $scene.empty("root", $transform.identity, toList([loading_cube]));
}

function view_game(model, ctx) {
  let player_nodes = $player.view(model.player, ctx, model.assets);
  let enemy_nodes = $enemy.view(model.enemy, ctx);
  let map_nodes = $map.view(model.map);
  let altar_nodes = $altar.view(model.altar, ctx);
  return $scene.empty(
    "root",
    $transform.identity,
    $list.flatten(toList([player_nodes, enemy_nodes, map_nodes, altar_nodes])),
  );
}

function view(model, ctx) {
  let all_loaded = $assets.is_loaded(model.assets) && $map.is_loaded(model.map);
  if (all_loaded) {
    return view_game(model, ctx);
  } else {
    return view_loading_screen(model);
  }
}

export function main() {
  let bridge = $ui.new_bridge();
  let $ = $game_ui.start(bridge);
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client",
      69,
      "main",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1782,
        end: 1822,
        pattern_start: 1793,
        pattern_end: 1798
      }
    )
  }
  let _block;
  let _pipe = $tiramisu.application(
    (_capture) => { return init(bridge, _capture); },
    update,
    view,
  );
  _block = $tiramisu.start(
    _pipe,
    "#game",
    new $tiramisu.FullScreen(),
    new $option.Some([bridge, (var0) => { return new FromBridge(var0); }]),
  );
  let $1 = _block;
  if (!($1 instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client",
      72,
      "main",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 1879,
        end: 2068,
        pattern_start: 1890,
        pattern_end: 1897
      }
    )
  }
  return undefined;
}
