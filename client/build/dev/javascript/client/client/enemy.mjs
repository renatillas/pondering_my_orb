import * as $maths from "../../gleam_community_maths/gleam_community/maths.mjs";
import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $order from "../../gleam_stdlib/gleam/order.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $attribute from "../../lustre/lustre/attribute.mjs";
import { attribute, class$ } from "../../lustre/lustre/attribute.mjs";
import * as $element from "../../lustre/lustre/element.mjs";
import * as $html from "../../lustre/lustre/element/html.mjs";
import * as $tiramisu from "../../tiramisu/tiramisu.mjs";
import * as $effect from "../../tiramisu/tiramisu/effect.mjs";
import * as $geometry from "../../tiramisu/tiramisu/geometry.mjs";
import * as $material from "../../tiramisu/tiramisu/material.mjs";
import * as $physics from "../../tiramisu/tiramisu/physics.mjs";
import * as $scene from "../../tiramisu/tiramisu/scene.mjs";
import * as $transform from "../../tiramisu/tiramisu/transform.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { Vec3 } from "../../vec/vec/vec3.mjs";
import * as $vec3f from "../../vec/vec/vec3f.mjs";
import * as $layer from "../client/game_physics/layer.mjs";
import * as $health from "../client/health.mjs";
import * as $id from "../client/id.mjs";
import {
  Ok,
  toList,
  prepend as listPrepend,
  CustomType as $CustomType,
  makeError,
  isEqual,
} from "../gleam.mjs";

const FILEPATH = "src/client/enemy.gleam";

export class Enemy extends $CustomType {
  constructor(id, position, health, damage, speed, attack_cooldown, desired_velocity) {
    super();
    this.id = id;
    this.position = position;
    this.health = health;
    this.damage = damage;
    this.speed = speed;
    this.attack_cooldown = attack_cooldown;
    this.desired_velocity = desired_velocity;
  }
}
export const Enemy$Enemy = (id, position, health, damage, speed, attack_cooldown, desired_velocity) =>
  new Enemy(id,
  position,
  health,
  damage,
  speed,
  attack_cooldown,
  desired_velocity);
export const Enemy$isEnemy = (value) => value instanceof Enemy;
export const Enemy$Enemy$id = (value) => value.id;
export const Enemy$Enemy$0 = (value) => value.id;
export const Enemy$Enemy$position = (value) => value.position;
export const Enemy$Enemy$1 = (value) => value.position;
export const Enemy$Enemy$health = (value) => value.health;
export const Enemy$Enemy$2 = (value) => value.health;
export const Enemy$Enemy$damage = (value) => value.damage;
export const Enemy$Enemy$3 = (value) => value.damage;
export const Enemy$Enemy$speed = (value) => value.speed;
export const Enemy$Enemy$4 = (value) => value.speed;
export const Enemy$Enemy$attack_cooldown = (value) => value.attack_cooldown;
export const Enemy$Enemy$5 = (value) => value.attack_cooldown;
export const Enemy$Enemy$desired_velocity = (value) => value.desired_velocity;
export const Enemy$Enemy$6 = (value) => value.desired_velocity;

export class Model extends $CustomType {
  constructor(enemies, next_enemy_id, spawn_timer, spawn_interval, player_pos, enemy_geometry) {
    super();
    this.enemies = enemies;
    this.next_enemy_id = next_enemy_id;
    this.spawn_timer = spawn_timer;
    this.spawn_interval = spawn_interval;
    this.player_pos = player_pos;
    this.enemy_geometry = enemy_geometry;
  }
}
export const Model$Model = (enemies, next_enemy_id, spawn_timer, spawn_interval, player_pos, enemy_geometry) =>
  new Model(enemies,
  next_enemy_id,
  spawn_timer,
  spawn_interval,
  player_pos,
  enemy_geometry);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$enemies = (value) => value.enemies;
export const Model$Model$0 = (value) => value.enemies;
export const Model$Model$next_enemy_id = (value) => value.next_enemy_id;
export const Model$Model$1 = (value) => value.next_enemy_id;
export const Model$Model$spawn_timer = (value) => value.spawn_timer;
export const Model$Model$2 = (value) => value.spawn_timer;
export const Model$Model$spawn_interval = (value) => value.spawn_interval;
export const Model$Model$3 = (value) => value.spawn_interval;
export const Model$Model$player_pos = (value) => value.player_pos;
export const Model$Model$4 = (value) => value.player_pos;
export const Model$Model$enemy_geometry = (value) => value.enemy_geometry;
export const Model$Model$5 = (value) => value.enemy_geometry;

export class Tick extends $CustomType {}
export const Msg$Tick = () => new Tick();
export const Msg$isTick = (value) => value instanceof Tick;

export class PlayerPositionUpdated extends $CustomType {
  constructor(player_pos) {
    super();
    this.player_pos = player_pos;
  }
}
export const Msg$PlayerPositionUpdated = (player_pos) =>
  new PlayerPositionUpdated(player_pos);
export const Msg$isPlayerPositionUpdated = (value) =>
  value instanceof PlayerPositionUpdated;
export const Msg$PlayerPositionUpdated$player_pos = (value) => value.player_pos;
export const Msg$PlayerPositionUpdated$0 = (value) => value.player_pos;

/**
 * Event: Enemy was hit by a projectile
 */
export class ProjectileHasHitEnemy extends $CustomType {
  constructor(enemy_id, damage) {
    super();
    this.enemy_id = enemy_id;
    this.damage = damage;
  }
}
export const Msg$ProjectileHasHitEnemy = (enemy_id, damage) =>
  new ProjectileHasHitEnemy(enemy_id, damage);
export const Msg$isProjectileHasHitEnemy = (value) =>
  value instanceof ProjectileHasHitEnemy;
export const Msg$ProjectileHasHitEnemy$enemy_id = (value) => value.enemy_id;
export const Msg$ProjectileHasHitEnemy$0 = (value) => value.enemy_id;
export const Msg$ProjectileHasHitEnemy$damage = (value) => value.damage;
export const Msg$ProjectileHasHitEnemy$1 = (value) => value.damage;

/**
 * Event: Physics simulation updated enemy positions
 */
export class PhysicsUpdatedPosition extends $CustomType {
  constructor(positions, player_pos) {
    super();
    this.positions = positions;
    this.player_pos = player_pos;
  }
}
export const Msg$PhysicsUpdatedPosition = (positions, player_pos) =>
  new PhysicsUpdatedPosition(positions, player_pos);
export const Msg$isPhysicsUpdatedPosition = (value) =>
  value instanceof PhysicsUpdatedPosition;
export const Msg$PhysicsUpdatedPosition$positions = (value) => value.positions;
export const Msg$PhysicsUpdatedPosition$0 = (value) => value.positions;
export const Msg$PhysicsUpdatedPosition$player_pos = (value) =>
  value.player_pos;
export const Msg$PhysicsUpdatedPosition$1 = (value) => value.player_pos;

const default_enemy_health = 10.0;

const default_enemy_damage = 10.0;

const default_enemy_speed = 8.0;

const spawn_interval_ms = 2000;

const attack_range = 2.0;

const attack_cooldown_ms = 1000;

const arena_min = -70.0;

const arena_max = 70.0;

const spawn_distance_min = 15.0;

const spawn_distance_max = 30.0;

function view_enemy_health_bar(enemy_health) {
  let percentage = $health.percentage(enemy_health) * 100.0;
  let percentage_str = $float.to_string(percentage);
  let current_str = $int.to_string($float.round($health.current(enemy_health)));
  let max_str = $int.to_string($float.round($health.max(enemy_health)));
  let _block;
  let $ = $health.percentage(enemy_health);
  let p = $;
  if (p > 0.6) {
    _block = "#22c55e";
  } else {
    let p = $;
    if (p > 0.3) {
      _block = "#eab308";
    } else {
      _block = "#ef4444";
    }
  }
  let bar_color = _block;
  let bar_style = ((("width: " + percentage_str) + "%; background-color: ") + bar_color) + "; height: 100%;";
  return $html.div(
    toList([class$("flex flex-col items-center")]),
    toList([
      $html.div(
        toList([
          attribute(
            "style",
            "width: 48px; height: 6px; background-color: #1f2937; border-radius: 4px; overflow: hidden;",
          ),
        ]),
        toList([$html.div(toList([attribute("style", bar_style)]), toList([]))]),
      ),
      $html.div(
        toList([
          attribute(
            "style",
            "font-size: 8px; color: white; font-family: monospace; margin-top: 2px;",
          ),
        ]),
        toList([$element.text((current_str + "/") + max_str)]),
      ),
    ]),
  );
}

/**
 * Get enemies with their desired velocities for physics
 */
export function get_enemies_for_physics(model) {
  return $list.map(model.enemies, (e) => { return [e.id, e.desired_velocity]; });
}

export function id(enemy) {
  return enemy.id;
}

function view_enemy(enemy, physics_world, enemy_geo) {
  let health_pct = $health.percentage(enemy.health);
  let _block;
  let p = health_pct;
  if (p > 0.6) {
    _block = 0xFF0000;
  } else {
    let p = health_pct;
    if (p > 0.3) {
      _block = 0xFF6600;
    } else {
      _block = 0xFF3300;
    }
  }
  let color = _block;
  let _block$1;
  let _pipe = $material.new$();
  let _pipe$1 = $material.with_color(_pipe, color);
  let _pipe$2 = $material.with_emissive(_pipe$1, color);
  let _pipe$3 = $material.with_emissive_intensity(_pipe$2, 0.3);
  _block$1 = $material.build(_pipe$3);
  let $ = _block$1;
  let enemy_mat;
  if ($ instanceof Ok) {
    enemy_mat = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/enemy",
      336,
      "view_enemy",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 10095,
        end: 10280,
        pattern_start: 10106,
        pattern_end: 10119
      }
    )
  }
  let body_id = $id.to_string(enemy.id);
  let _block$2;
  let _pipe$4 = $physics.new_rigid_body(new $physics.Dynamic());
  let _pipe$5 = $physics.with_collider(
    _pipe$4,
    new $physics.Capsule($transform.identity, 1.0, 0.75),
  );
  let _pipe$6 = $physics.with_mass(_pipe$5, 50.0);
  let _pipe$7 = $physics.with_collision_groups(
    _pipe$6,
    toList([$layer.enemy]),
    toList([$layer.player, $layer.map, $layer.projectile, $layer.enemy]),
  );
  let _pipe$8 = $physics.with_collision_events(_pipe$7);
  let _pipe$9 = $physics.with_lock_translation_y(_pipe$8);
  let _pipe$10 = $physics.with_lock_rotation_x(_pipe$9);
  let _pipe$11 = $physics.with_lock_rotation_z(_pipe$10);
  _block$2 = $physics.build(_pipe$11);
  let physics_body = _block$2;
  let _block$3;
  let $1 = $physics.get_transform(physics_world, body_id);
  if ($1 instanceof Ok) {
    let t = $1[0];
    _block$3 = t;
  } else {
    _block$3 = $transform.at(enemy.position);
  }
  let enemy_transform = _block$3;
  let health_bar_label = $scene.css2d(
    $id.to_string(new $id.EnemyHealth(enemy.id)),
    $element.to_string(view_enemy_health_bar(enemy.health)),
    $transform.at(new Vec3(0.0, 1.5, 0.0)),
  );
  let _pipe$12 = $scene.mesh(
    body_id,
    enemy_geo,
    enemy_mat,
    enemy_transform,
    new $option.Some(physics_body),
  );
  return $scene.with_children(_pipe$12, toList([health_bar_label]));
}

export function view(model, ctx) {
  let $ = ctx.physics_world;
  let physics_world;
  if ($ instanceof $option.Some) {
    physics_world = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/enemy",
      317,
      "view",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 9606,
        end: 9663,
        pattern_start: 9617,
        pattern_end: 9643
      }
    )
  }
  return $list.map(
    model.enemies,
    (enemy) => { return view_enemy(enemy, physics_world, model.enemy_geometry); },
  );
}

export function init() {
  let $ = $geometry.box(new Vec3(1.5, 2.0, 1.5));
  let enemy_geo;
  if ($ instanceof Ok) {
    enemy_geo = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/enemy",
      96,
      "init",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 2351,
        end: 2411,
        pattern_start: 2362,
        pattern_end: 2375
      }
    )
  }
  let model = new Model(
    toList([]),
    0,
    $duration.milliseconds(0),
    $duration.milliseconds(spawn_interval_ms),
    new Vec3(0.0, 0.0, 0.0),
    enemy_geo,
  );
  return [model, $effect.dispatch(new Tick())];
}

/**
 * Calculate desired velocities for all enemies based on player position
 * 
 * @ignore
 */
function calculate_velocities(model) {
  let updated_enemies = $list.map(
    model.enemies,
    (enemy) => {
      let to_player = $vec3f.subtract(model.player_pos, enemy.position);
      let distance = $vec3f.length(to_player);
      let $ = distance > attack_range;
      if ($) {
        let direction = $vec3f.normalize(to_player);
        let velocity = $vec3f.scale(direction, enemy.speed);
        return new Enemy(
          enemy.id,
          enemy.position,
          enemy.health,
          enemy.damage,
          enemy.speed,
          enemy.attack_cooldown,
          velocity,
        );
      } else {
        return new Enemy(
          enemy.id,
          enemy.position,
          enemy.health,
          enemy.damage,
          enemy.speed,
          enemy.attack_cooldown,
          new Vec3(0.0, 0.0, 0.0),
        );
      }
    },
  );
  return new Model(
    updated_enemies,
    model.next_enemy_id,
    model.spawn_timer,
    model.spawn_interval,
    model.player_pos,
    model.enemy_geometry,
  );
}

function update_movement(model, _) {
  return calculate_velocities(model);
}

/**
 * Update player position and calculate velocities synchronously
 * Returns updated model and velocities for physics
 */
export function update_for_physics(model, player_pos) {
  let model_with_pos = new Model(
    model.enemies,
    model.next_enemy_id,
    model.spawn_timer,
    model.spawn_interval,
    player_pos,
    model.enemy_geometry,
  );
  let model_with_velocities = calculate_velocities(model_with_pos);
  let velocities = get_enemies_for_physics(model_with_velocities);
  return [model_with_velocities, velocities];
}

function update_attacks(model, dt) {
  let $ = $list.fold(
    model.enemies,
    [toList([]), 0.0],
    (acc, enemy) => {
      let enemies_acc;
      let damage_acc;
      enemies_acc = acc[0];
      damage_acc = acc[1];
      let cooldown_secs = $duration.to_seconds(enemy.attack_cooldown);
      let dt_secs = $duration.to_seconds(dt);
      let new_cooldown_secs = $float.max(0.0, cooldown_secs - dt_secs);
      let new_cooldown = $duration.milliseconds(
        $float.round(new_cooldown_secs * 1000.0),
      );
      let to_player = $vec3f.subtract(model.player_pos, enemy.position);
      let distance = $vec3f.length(to_player);
      let $1 = (distance <= attack_range) && (new_cooldown_secs <= 0.0);
      if ($1) {
        let attacking_enemy = new Enemy(
          enemy.id,
          enemy.position,
          enemy.health,
          enemy.damage,
          enemy.speed,
          $duration.milliseconds(attack_cooldown_ms),
          enemy.desired_velocity,
        );
        return [
          listPrepend(attacking_enemy, enemies_acc),
          damage_acc + enemy.damage,
        ];
      } else {
        let updated_enemy = new Enemy(
          enemy.id,
          enemy.position,
          enemy.health,
          enemy.damage,
          enemy.speed,
          new_cooldown,
          enemy.desired_velocity,
        );
        return [listPrepend(updated_enemy, enemies_acc), damage_acc];
      }
    },
  );
  let updated_enemies;
  let total_damage;
  updated_enemies = $[0];
  total_damage = $[1];
  return [
    new Model(
      updated_enemies,
      model.next_enemy_id,
      model.spawn_timer,
      model.spawn_interval,
      model.player_pos,
      model.enemy_geometry,
    ),
    total_damage,
  ];
}

function spawn_enemy(model) {
  let angle = ($float.random() * 2.0) * 3.14159;
  let distance = spawn_distance_min + ($float.random() * (spawn_distance_max - spawn_distance_min));
  let spawn_x = model.player_pos.x + ($maths.cos(angle) * distance);
  let spawn_z = model.player_pos.z + ($maths.sin(angle) * distance);
  let spawn_x$1 = $float.clamp(spawn_x, arena_min, arena_max);
  let spawn_z$1 = $float.clamp(spawn_z, arena_min, arena_max);
  return new Enemy(
    new $id.Enemy(model.next_enemy_id),
    new Vec3(spawn_x$1, 1.0, spawn_z$1),
    $health.new$(default_enemy_health),
    default_enemy_damage,
    default_enemy_speed,
    $duration.milliseconds(0),
    new Vec3(0.0, 0.0, 0.0),
  );
}

function update_spawning(model, dt) {
  let new_timer = $duration.add(model.spawn_timer, dt);
  let $ = $duration.compare(new_timer, model.spawn_interval);
  if ($ instanceof $order.Lt) {
    return new Model(
      model.enemies,
      model.next_enemy_id,
      new_timer,
      model.spawn_interval,
      model.player_pos,
      model.enemy_geometry,
    );
  } else if ($ instanceof $order.Eq) {
    let new_enemy = spawn_enemy(model);
    return new Model(
      listPrepend(new_enemy, model.enemies),
      model.next_enemy_id + 1,
      $duration.milliseconds(0),
      model.spawn_interval,
      model.player_pos,
      model.enemy_geometry,
    );
  } else {
    let new_enemy = spawn_enemy(model);
    return new Model(
      listPrepend(new_enemy, model.enemies),
      model.next_enemy_id + 1,
      $duration.milliseconds(0),
      model.spawn_interval,
      model.player_pos,
      model.enemy_geometry,
    );
  }
}

function tick(model, ctx) {
  let dt = ctx.delta_time;
  let model$1 = update_spawning(model, dt);
  let model$2 = update_movement(model$1, dt);
  return update_attacks(model$2, dt);
}

/**
 * Update enemies. Accepts taggers for cross-module dispatch.
 */
export function update(
  model,
  msg,
  ctx,
  player_took_damage,
  spawn_altar,
  effect_mapper
) {
  if (msg instanceof Tick) {
    let $ = tick(model, ctx);
    let new_model;
    let damage;
    new_model = $[0];
    damage = $[1];
    let _block;
    let $1 = damage > 0.0;
    if ($1) {
      _block = $effect.dispatch(player_took_damage(damage));
    } else {
      _block = $effect.none();
    }
    let damage_effect = _block;
    return [
      new_model,
      $effect.batch(
        toList([$effect.dispatch(effect_mapper(new Tick())), damage_effect]),
      ),
    ];
  } else if (msg instanceof PlayerPositionUpdated) {
    let player_pos = msg.player_pos;
    let model_with_pos = new Model(
      model.enemies,
      model.next_enemy_id,
      model.spawn_timer,
      model.spawn_interval,
      player_pos,
      model.enemy_geometry,
    );
    let model_with_velocities = calculate_velocities(model_with_pos);
    return [model_with_velocities, $effect.none()];
  } else if (msg instanceof ProjectileHasHitEnemy) {
    let enemy_id = msg.enemy_id;
    let damage = msg.damage;
    let $ = $list.fold(
      model.enemies,
      [toList([]), toList([])],
      (acc, enemy) => {
        let enemies_acc;
        let effects_acc;
        enemies_acc = acc[0];
        effects_acc = acc[1];
        let $1 = isEqual(enemy.id, enemy_id);
        if ($1) {
          let new_health = $health.damage(enemy.health, damage);
          let $2 = $health.is_dead(new_health);
          if ($2) {
            let spawn_effect = $effect.dispatch(spawn_altar(enemy.position));
            return [enemies_acc, listPrepend(spawn_effect, effects_acc)];
          } else {
            return [
              listPrepend(
                new Enemy(
                  enemy.id,
                  enemy.position,
                  new_health,
                  enemy.damage,
                  enemy.speed,
                  enemy.attack_cooldown,
                  enemy.desired_velocity,
                ),
                enemies_acc,
              ),
              effects_acc,
            ];
          }
        } else {
          return [listPrepend(enemy, enemies_acc), effects_acc];
        }
      },
    );
    let updated_enemies;
    let death_effects;
    updated_enemies = $[0];
    death_effects = $[1];
    return [
      new Model(
        updated_enemies,
        model.next_enemy_id,
        model.spawn_timer,
        model.spawn_interval,
        model.player_pos,
        model.enemy_geometry,
      ),
      $effect.batch(death_effects),
    ];
  } else {
    let positions = msg.positions;
    let player_pos = msg.player_pos;
    let updated_enemies = $list.map(
      model.enemies,
      (enemy) => {
        let $ = $list.find(
          positions,
          (p) => { return isEqual(p[0], enemy.id); },
        );
        if ($ instanceof Ok) {
          let new_pos = $[0][1];
          return new Enemy(
            enemy.id,
            new_pos,
            enemy.health,
            enemy.damage,
            enemy.speed,
            enemy.attack_cooldown,
            enemy.desired_velocity,
          );
        } else {
          return enemy;
        }
      },
    );
    return [
      new Model(
        updated_enemies,
        model.next_enemy_id,
        model.spawn_timer,
        model.spawn_interval,
        player_pos,
        model.enemy_geometry,
      ),
      $effect.none(),
    ];
  }
}
