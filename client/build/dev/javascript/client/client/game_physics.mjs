import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $tiramisu from "../../tiramisu/tiramisu.mjs";
import * as $effect from "../../tiramisu/tiramisu/effect.mjs";
import * as $physics from "../../tiramisu/tiramisu/physics.mjs";
import * as $transform from "../../tiramisu/tiramisu/transform.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import * as $vec3f from "../../vec/vec/vec3f.mjs";
import * as $enemy from "../client/enemy.mjs";
import * as $id from "../client/id.mjs";
import * as $spell from "../client/magic_system/spell.mjs";
import * as $player from "../client/player.mjs";
import { Ok, Error, toList, CustomType as $CustomType, makeError } from "../gleam.mjs";

const FILEPATH = "src/client/game_physics.gleam";

export class Model extends $CustomType {
  constructor(collision_results, enemy_positions, stepped_world, updated_enemy) {
    super();
    this.collision_results = collision_results;
    this.enemy_positions = enemy_positions;
    this.stepped_world = stepped_world;
    this.updated_enemy = updated_enemy;
  }
}
export const Model$Model = (collision_results, enemy_positions, stepped_world, updated_enemy) =>
  new Model(collision_results, enemy_positions, stepped_world, updated_enemy);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$collision_results = (value) => value.collision_results;
export const Model$Model$0 = (value) => value.collision_results;
export const Model$Model$enemy_positions = (value) => value.enemy_positions;
export const Model$Model$1 = (value) => value.enemy_positions;
export const Model$Model$stepped_world = (value) => value.stepped_world;
export const Model$Model$2 = (value) => value.stepped_world;
export const Model$Model$updated_enemy = (value) => value.updated_enemy;
export const Model$Model$3 = (value) => value.updated_enemy;

export class Tick extends $CustomType {}
export const Msg$Tick = () => new Tick();
export const Msg$isTick = (value) => value instanceof Tick;

export class ProjectileHitEnemy extends $CustomType {
  constructor(projectile_id, enemy_id, damage) {
    super();
    this.projectile_id = projectile_id;
    this.enemy_id = enemy_id;
    this.damage = damage;
  }
}
export const CollisionResult$ProjectileHitEnemy = (projectile_id, enemy_id, damage) =>
  new ProjectileHitEnemy(projectile_id, enemy_id, damage);
export const CollisionResult$isProjectileHitEnemy = (value) =>
  value instanceof ProjectileHitEnemy;
export const CollisionResult$ProjectileHitEnemy$projectile_id = (value) =>
  value.projectile_id;
export const CollisionResult$ProjectileHitEnemy$0 = (value) =>
  value.projectile_id;
export const CollisionResult$ProjectileHitEnemy$enemy_id = (value) =>
  value.enemy_id;
export const CollisionResult$ProjectileHitEnemy$1 = (value) => value.enemy_id;
export const CollisionResult$ProjectileHitEnemy$damage = (value) =>
  value.damage;
export const CollisionResult$ProjectileHitEnemy$2 = (value) => value.damage;

export function init() {
  let model = new Model(
    toList([]),
    toList([]),
    new $option.None(),
    new $option.None(),
  );
  return [model, $effect.none()];
}

function build_collision_effects(results, enemy_took_damage, remove_projectile) {
  let _pipe = results;
  let _pipe$1 = $list.map(
    _pipe,
    (result) => {
      let proj_id;
      let enemy_id;
      let damage;
      proj_id = result.projectile_id;
      enemy_id = result.enemy_id;
      damage = result.damage;
      return $effect.batch(
        toList([
          $effect.dispatch(enemy_took_damage(new $id.Enemy(enemy_id), damage)),
          $effect.dispatch(remove_projectile(proj_id)),
        ]),
      );
    },
  );
  return $effect.batch(_pipe$1);
}

function find_projectile_damage(projectiles, projectile_id) {
  return $list.find_map(
    projectiles,
    (p) => {
      let $ = p.id === projectile_id;
      if ($) {
        return new Ok(p.spell.final_damage);
      } else {
        return new Error(undefined);
      }
    },
  );
}

function match_projectile_enemy_collision(body_a, body_b, projectiles) {
  let $ = $id.from_string(body_a);
  let $1 = $id.from_string(body_b);
  if ($ instanceof $id.Enemy && $1 instanceof $id.Projectile) {
    let enemy_id = $[0];
    let proj_id = $1[0];
    let $2 = find_projectile_damage(projectiles, proj_id);
    if ($2 instanceof Ok) {
      let damage = $2[0];
      return new Ok(new ProjectileHitEnemy(proj_id, enemy_id, damage));
    } else {
      return new Error(undefined);
    }
  } else if ($ instanceof $id.Projectile && $1 instanceof $id.Enemy) {
    let proj_id = $[0];
    let enemy_id = $1[0];
    let $2 = find_projectile_damage(projectiles, proj_id);
    if ($2 instanceof Ok) {
      let damage = $2[0];
      return new Ok(new ProjectileHitEnemy(proj_id, enemy_id, damage));
    } else {
      return new Error(undefined);
    }
  } else {
    return new Error(undefined);
  }
}

function process_collisions(events, projectiles) {
  return $list.filter_map(
    events,
    (event) => {
      if (event instanceof $physics.CollisionStarted) {
        let body_a = event.body_a;
        let body_b = event.body_b;
        return match_projectile_enemy_collision(body_a, body_b, projectiles);
      } else {
        return new Error(undefined);
      }
    },
  );
}

function set_projectile_velocities(world, projectiles) {
  return $list.fold(
    projectiles,
    world,
    (w, proj) => {
      let velocity = $vec3f.scale(proj.direction, proj.spell.final_speed);
      return $physics.set_velocity(
        w,
        $id.to_string(new $id.Projectile(proj.id)),
        velocity,
      );
    },
  );
}

function set_enemy_velocities(world, velocities) {
  return $list.fold(
    velocities,
    world,
    (w, data) => {
      let enemy_id;
      let velocity;
      enemy_id = data[0];
      velocity = data[1];
      return $physics.set_velocity(w, $id.to_string(enemy_id), velocity);
    },
  );
}

function read_enemy_positions(world, enemy_ids) {
  return $list.filter_map(
    enemy_ids,
    (enemy_id) => {
      let $ = $physics.get_transform(world, $id.to_string(enemy_id));
      if ($ instanceof Ok) {
        let trans = $[0];
        return new Ok([enemy_id, $transform.position(trans)]);
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Physics tick - coordinates physics simulation and cross-module effects.
 *
 * Accepts tagger functions to dispatch effects to sibling modules without
 * creating import cycles. The parent module provides these taggers.
 */
export function update(
  msg,
  ctx,
  player_model,
  enemy_model,
  enemy_took_projectile_damage,
  remove_projectile,
  update_enemy_positions,
  effect_mapper
) {
  let $ = ctx.physics_world;
  let physics_world;
  if ($ instanceof $option.Some) {
    physics_world = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/game_physics",
      72,
      "update",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 2090,
        end: 2147,
        pattern_start: 2101,
        pattern_end: 2127
      }
    )
  }
  let player_position = player_model.position;
  let projectiles = $player.get_projectiles(player_model);
  let $1 = $enemy.update_for_physics(enemy_model, player_position);
  let updated_enemy;
  let enemy_velocities;
  updated_enemy = $1[0];
  enemy_velocities = $1[1];
  let _block;
  let _pipe = physics_world;
  let _pipe$1 = set_projectile_velocities(_pipe, projectiles);
  _block = set_enemy_velocities(_pipe$1, enemy_velocities);
  let world_with_velocities = _block;
  let stepped_world = $physics.step(world_with_velocities, ctx.delta_time);
  let _block$1;
  let _pipe$2 = stepped_world;
  let _pipe$3 = $physics.get_collision_events(_pipe$2);
  _block$1 = process_collisions(_pipe$3, projectiles);
  let collision_results = _block$1;
  let enemy_ids = $list.map(updated_enemy.enemies, $enemy.id);
  let enemy_positions = read_enemy_positions(stepped_world, enemy_ids);
  let model = new Model(
    collision_results,
    enemy_positions,
    new $option.Some(stepped_world),
    new $option.Some(updated_enemy),
  );
  let effects = $effect.batch(
    toList([
      build_collision_effects(
        collision_results,
        enemy_took_projectile_damage,
        remove_projectile,
      ),
      $effect.dispatch(update_enemy_positions(enemy_positions, player_position)),
      $effect.dispatch(effect_mapper(new Tick())),
    ]),
  );
  return [model, effects];
}
