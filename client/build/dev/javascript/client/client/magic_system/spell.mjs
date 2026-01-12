import * as $float from "../../../gleam_stdlib/gleam/float.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $duration from "../../../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../../../iv/iv.mjs";
import * as $vec2 from "../../../vec/vec/vec2.mjs";
import * as $vec3 from "../../../vec/vec/vec3.mjs";
import { Ok, toList, CustomType as $CustomType, makeError } from "../../gleam.mjs";

const FILEPATH = "src/client/magic_system/spell.gleam";

export class Fireball extends $CustomType {}
export const Id$Fireball = () => new Fireball();
export const Id$isFireball = (value) => value instanceof Fireball;

export class LightningBolt extends $CustomType {}
export const Id$LightningBolt = () => new LightningBolt();
export const Id$isLightningBolt = (value) => value instanceof LightningBolt;

export class Spark extends $CustomType {}
export const Id$Spark = () => new Spark();
export const Id$isSpark = (value) => value instanceof Spark;

export class SparkWithTrigger extends $CustomType {}
export const Id$SparkWithTrigger = () => new SparkWithTrigger();
export const Id$isSparkWithTrigger = (value) =>
  value instanceof SparkWithTrigger;

export class Piercing extends $CustomType {}
export const Id$Piercing = () => new Piercing();
export const Id$isPiercing = (value) => value instanceof Piercing;

export class DoubleSpell extends $CustomType {}
export const Id$DoubleSpell = () => new DoubleSpell();
export const Id$isDoubleSpell = (value) => value instanceof DoubleSpell;

export class AddMana extends $CustomType {}
export const Id$AddMana = () => new AddMana();
export const Id$isAddMana = (value) => value instanceof AddMana;

export class AddDamage extends $CustomType {}
export const Id$AddDamage = () => new AddDamage();
export const Id$isAddDamage = (value) => value instanceof AddDamage;

export class OrbitingSpell extends $CustomType {}
export const Id$OrbitingSpell = () => new OrbitingSpell();
export const Id$isOrbitingSpell = (value) => value instanceof OrbitingSpell;

export class RapidFire extends $CustomType {}
export const Id$RapidFire = () => new RapidFire();
export const Id$isRapidFire = (value) => value instanceof RapidFire;

export class AddTrigger extends $CustomType {}
export const Id$AddTrigger = () => new AddTrigger();
export const Id$isAddTrigger = (value) => value instanceof AddTrigger;

export class DamageSpell extends $CustomType {
  constructor(id, ui_sprite, kind) {
    super();
    this.id = id;
    this.ui_sprite = ui_sprite;
    this.kind = kind;
  }
}
export const Spell$DamageSpell = (id, ui_sprite, kind) =>
  new DamageSpell(id, ui_sprite, kind);
export const Spell$isDamageSpell = (value) => value instanceof DamageSpell;
export const Spell$DamageSpell$id = (value) => value.id;
export const Spell$DamageSpell$0 = (value) => value.id;
export const Spell$DamageSpell$ui_sprite = (value) => value.ui_sprite;
export const Spell$DamageSpell$1 = (value) => value.ui_sprite;
export const Spell$DamageSpell$kind = (value) => value.kind;
export const Spell$DamageSpell$2 = (value) => value.kind;

export class ModifierSpell extends $CustomType {
  constructor(id, ui_sprite, kind) {
    super();
    this.id = id;
    this.ui_sprite = ui_sprite;
    this.kind = kind;
  }
}
export const Spell$ModifierSpell = (id, ui_sprite, kind) =>
  new ModifierSpell(id, ui_sprite, kind);
export const Spell$isModifierSpell = (value) => value instanceof ModifierSpell;
export const Spell$ModifierSpell$id = (value) => value.id;
export const Spell$ModifierSpell$0 = (value) => value.id;
export const Spell$ModifierSpell$ui_sprite = (value) => value.ui_sprite;
export const Spell$ModifierSpell$1 = (value) => value.ui_sprite;
export const Spell$ModifierSpell$kind = (value) => value.kind;
export const Spell$ModifierSpell$2 = (value) => value.kind;

export class MulticastSpell extends $CustomType {
  constructor(id, ui_sprite, kind) {
    super();
    this.id = id;
    this.ui_sprite = ui_sprite;
    this.kind = kind;
  }
}
export const Spell$MulticastSpell = (id, ui_sprite, kind) =>
  new MulticastSpell(id, ui_sprite, kind);
export const Spell$isMulticastSpell = (value) =>
  value instanceof MulticastSpell;
export const Spell$MulticastSpell$id = (value) => value.id;
export const Spell$MulticastSpell$0 = (value) => value.id;
export const Spell$MulticastSpell$ui_sprite = (value) => value.ui_sprite;
export const Spell$MulticastSpell$1 = (value) => value.ui_sprite;
export const Spell$MulticastSpell$kind = (value) => value.kind;
export const Spell$MulticastSpell$2 = (value) => value.kind;

export const Spell$id = (value) => value.id;
export const Spell$ui_sprite = (value) => value.ui_sprite;

export class Fixed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const MulticastCount$Fixed = ($0) => new Fixed($0);
export const MulticastCount$isFixed = (value) => value instanceof Fixed;
export const MulticastCount$Fixed$0 = (value) => value[0];

export class AllRemaining extends $CustomType {}
export const MulticastCount$AllRemaining = () => new AllRemaining();
export const MulticastCount$isAllRemaining = (value) =>
  value instanceof AllRemaining;

export class Multicast extends $CustomType {
  constructor(name, mana_cost, spell_count, draw_add, ui_sprite) {
    super();
    this.name = name;
    this.mana_cost = mana_cost;
    this.spell_count = spell_count;
    this.draw_add = draw_add;
    this.ui_sprite = ui_sprite;
  }
}
export const MulticastSpell$Multicast = (name, mana_cost, spell_count, draw_add, ui_sprite) =>
  new Multicast(name, mana_cost, spell_count, draw_add, ui_sprite);
export const MulticastSpell$isMulticast = (value) => value instanceof Multicast;
export const MulticastSpell$Multicast$name = (value) => value.name;
export const MulticastSpell$Multicast$0 = (value) => value.name;
export const MulticastSpell$Multicast$mana_cost = (value) => value.mana_cost;
export const MulticastSpell$Multicast$1 = (value) => value.mana_cost;
export const MulticastSpell$Multicast$spell_count = (value) =>
  value.spell_count;
export const MulticastSpell$Multicast$2 = (value) => value.spell_count;
export const MulticastSpell$Multicast$draw_add = (value) => value.draw_add;
export const MulticastSpell$Multicast$3 = (value) => value.draw_add;
export const MulticastSpell$Multicast$ui_sprite = (value) => value.ui_sprite;
export const MulticastSpell$Multicast$4 = (value) => value.ui_sprite;

export class LoopRepeat extends $CustomType {}
export const SpritesheetLoop$LoopRepeat = () => new LoopRepeat();
export const SpritesheetLoop$isLoopRepeat = (value) =>
  value instanceof LoopRepeat;

export class LoopOnce extends $CustomType {}
export const SpritesheetLoop$LoopOnce = () => new LoopOnce();
export const SpritesheetLoop$isLoopOnce = (value) => value instanceof LoopOnce;

export class LoopPingPong extends $CustomType {}
export const SpritesheetLoop$LoopPingPong = () => new LoopPingPong();
export const SpritesheetLoop$isLoopPingPong = (value) =>
  value instanceof LoopPingPong;

export class FireExplosion extends $CustomType {}
export const HitEffectType$FireExplosion = () => new FireExplosion();
export const HitEffectType$isFireExplosion = (value) =>
  value instanceof FireExplosion;

export class GenericExplosion extends $CustomType {}
export const HitEffectType$GenericExplosion = () => new GenericExplosion();
export const HitEffectType$isGenericExplosion = (value) =>
  value instanceof GenericExplosion;

export class IceShatter extends $CustomType {}
export const HitEffectType$IceShatter = () => new IceShatter();
export const HitEffectType$isIceShatter = (value) =>
  value instanceof IceShatter;

export class LightBurst extends $CustomType {}
export const HitEffectType$LightBurst = () => new LightBurst();
export const HitEffectType$isLightBurst = (value) =>
  value instanceof LightBurst;

export class NoEffect extends $CustomType {}
export const HitEffectType$NoEffect = () => new NoEffect();
export const HitEffectType$isNoEffect = (value) => value instanceof NoEffect;

export class StaticSprite extends $CustomType {
  constructor(texture_path, size) {
    super();
    this.texture_path = texture_path;
    this.size = size;
  }
}
export const ProjectileVisual$StaticSprite = (texture_path, size) =>
  new StaticSprite(texture_path, size);
export const ProjectileVisual$isStaticSprite = (value) =>
  value instanceof StaticSprite;
export const ProjectileVisual$StaticSprite$texture_path = (value) =>
  value.texture_path;
export const ProjectileVisual$StaticSprite$0 = (value) => value.texture_path;
export const ProjectileVisual$StaticSprite$size = (value) => value.size;
export const ProjectileVisual$StaticSprite$1 = (value) => value.size;

export class SpellVisuals extends $CustomType {
  constructor(projectile, hit_effect, base_tint, emissive_intensity) {
    super();
    this.projectile = projectile;
    this.hit_effect = hit_effect;
    this.base_tint = base_tint;
    this.emissive_intensity = emissive_intensity;
  }
}
export const SpellVisuals$SpellVisuals = (projectile, hit_effect, base_tint, emissive_intensity) =>
  new SpellVisuals(projectile, hit_effect, base_tint, emissive_intensity);
export const SpellVisuals$isSpellVisuals = (value) =>
  value instanceof SpellVisuals;
export const SpellVisuals$SpellVisuals$projectile = (value) => value.projectile;
export const SpellVisuals$SpellVisuals$0 = (value) => value.projectile;
export const SpellVisuals$SpellVisuals$hit_effect = (value) => value.hit_effect;
export const SpellVisuals$SpellVisuals$1 = (value) => value.hit_effect;
export const SpellVisuals$SpellVisuals$base_tint = (value) => value.base_tint;
export const SpellVisuals$SpellVisuals$2 = (value) => value.base_tint;
export const SpellVisuals$SpellVisuals$emissive_intensity = (value) =>
  value.emissive_intensity;
export const SpellVisuals$SpellVisuals$3 = (value) => value.emissive_intensity;

export class Damage extends $CustomType {
  constructor(name, mana_cost, damage, projectile_speed, projectile_lifetime, projectile_size, cast_delay_addition, critical_chance, spread, visuals, has_trigger) {
    super();
    this.name = name;
    this.mana_cost = mana_cost;
    this.damage = damage;
    this.projectile_speed = projectile_speed;
    this.projectile_lifetime = projectile_lifetime;
    this.projectile_size = projectile_size;
    this.cast_delay_addition = cast_delay_addition;
    this.critical_chance = critical_chance;
    this.spread = spread;
    this.visuals = visuals;
    this.has_trigger = has_trigger;
  }
}
export const DamageSpell$Damage = (name, mana_cost, damage, projectile_speed, projectile_lifetime, projectile_size, cast_delay_addition, critical_chance, spread, visuals, has_trigger) =>
  new Damage(name,
  mana_cost,
  damage,
  projectile_speed,
  projectile_lifetime,
  projectile_size,
  cast_delay_addition,
  critical_chance,
  spread,
  visuals,
  has_trigger);
export const DamageSpell$isDamage = (value) => value instanceof Damage;
export const DamageSpell$Damage$name = (value) => value.name;
export const DamageSpell$Damage$0 = (value) => value.name;
export const DamageSpell$Damage$mana_cost = (value) => value.mana_cost;
export const DamageSpell$Damage$1 = (value) => value.mana_cost;
export const DamageSpell$Damage$damage = (value) => value.damage;
export const DamageSpell$Damage$2 = (value) => value.damage;
export const DamageSpell$Damage$projectile_speed = (value) =>
  value.projectile_speed;
export const DamageSpell$Damage$3 = (value) => value.projectile_speed;
export const DamageSpell$Damage$projectile_lifetime = (value) =>
  value.projectile_lifetime;
export const DamageSpell$Damage$4 = (value) => value.projectile_lifetime;
export const DamageSpell$Damage$projectile_size = (value) =>
  value.projectile_size;
export const DamageSpell$Damage$5 = (value) => value.projectile_size;
export const DamageSpell$Damage$cast_delay_addition = (value) =>
  value.cast_delay_addition;
export const DamageSpell$Damage$6 = (value) => value.cast_delay_addition;
export const DamageSpell$Damage$critical_chance = (value) =>
  value.critical_chance;
export const DamageSpell$Damage$7 = (value) => value.critical_chance;
export const DamageSpell$Damage$spread = (value) => value.spread;
export const DamageSpell$Damage$8 = (value) => value.spread;
export const DamageSpell$Damage$visuals = (value) => value.visuals;
export const DamageSpell$Damage$9 = (value) => value.visuals;
export const DamageSpell$Damage$has_trigger = (value) => value.has_trigger;
export const DamageSpell$Damage$10 = (value) => value.has_trigger;

export class Modifier extends $CustomType {
  constructor(name, mana_cost, damage_multiplier, damage_addition, projectile_speed_multiplier, projectile_speed_addition, projectile_size_multiplier, projectile_size_addition, projectile_lifetime_multiplier, projectile_lifetime_addition, cast_delay_multiplier, cast_delay_addition, recharge_multiplier, recharge_addition, critical_chance_multiplier, critical_chance_addition, spread_multiplier, spread_addition, ui_sprite, adds_trigger, visual_tint) {
    super();
    this.name = name;
    this.mana_cost = mana_cost;
    this.damage_multiplier = damage_multiplier;
    this.damage_addition = damage_addition;
    this.projectile_speed_multiplier = projectile_speed_multiplier;
    this.projectile_speed_addition = projectile_speed_addition;
    this.projectile_size_multiplier = projectile_size_multiplier;
    this.projectile_size_addition = projectile_size_addition;
    this.projectile_lifetime_multiplier = projectile_lifetime_multiplier;
    this.projectile_lifetime_addition = projectile_lifetime_addition;
    this.cast_delay_multiplier = cast_delay_multiplier;
    this.cast_delay_addition = cast_delay_addition;
    this.recharge_multiplier = recharge_multiplier;
    this.recharge_addition = recharge_addition;
    this.critical_chance_multiplier = critical_chance_multiplier;
    this.critical_chance_addition = critical_chance_addition;
    this.spread_multiplier = spread_multiplier;
    this.spread_addition = spread_addition;
    this.ui_sprite = ui_sprite;
    this.adds_trigger = adds_trigger;
    this.visual_tint = visual_tint;
  }
}
export const ModifierSpell$Modifier = (name, mana_cost, damage_multiplier, damage_addition, projectile_speed_multiplier, projectile_speed_addition, projectile_size_multiplier, projectile_size_addition, projectile_lifetime_multiplier, projectile_lifetime_addition, cast_delay_multiplier, cast_delay_addition, recharge_multiplier, recharge_addition, critical_chance_multiplier, critical_chance_addition, spread_multiplier, spread_addition, ui_sprite, adds_trigger, visual_tint) =>
  new Modifier(name,
  mana_cost,
  damage_multiplier,
  damage_addition,
  projectile_speed_multiplier,
  projectile_speed_addition,
  projectile_size_multiplier,
  projectile_size_addition,
  projectile_lifetime_multiplier,
  projectile_lifetime_addition,
  cast_delay_multiplier,
  cast_delay_addition,
  recharge_multiplier,
  recharge_addition,
  critical_chance_multiplier,
  critical_chance_addition,
  spread_multiplier,
  spread_addition,
  ui_sprite,
  adds_trigger,
  visual_tint);
export const ModifierSpell$isModifier = (value) => value instanceof Modifier;
export const ModifierSpell$Modifier$name = (value) => value.name;
export const ModifierSpell$Modifier$0 = (value) => value.name;
export const ModifierSpell$Modifier$mana_cost = (value) => value.mana_cost;
export const ModifierSpell$Modifier$1 = (value) => value.mana_cost;
export const ModifierSpell$Modifier$damage_multiplier = (value) =>
  value.damage_multiplier;
export const ModifierSpell$Modifier$2 = (value) => value.damage_multiplier;
export const ModifierSpell$Modifier$damage_addition = (value) =>
  value.damage_addition;
export const ModifierSpell$Modifier$3 = (value) => value.damage_addition;
export const ModifierSpell$Modifier$projectile_speed_multiplier = (value) =>
  value.projectile_speed_multiplier;
export const ModifierSpell$Modifier$4 = (value) =>
  value.projectile_speed_multiplier;
export const ModifierSpell$Modifier$projectile_speed_addition = (value) =>
  value.projectile_speed_addition;
export const ModifierSpell$Modifier$5 = (value) =>
  value.projectile_speed_addition;
export const ModifierSpell$Modifier$projectile_size_multiplier = (value) =>
  value.projectile_size_multiplier;
export const ModifierSpell$Modifier$6 = (value) =>
  value.projectile_size_multiplier;
export const ModifierSpell$Modifier$projectile_size_addition = (value) =>
  value.projectile_size_addition;
export const ModifierSpell$Modifier$7 = (value) =>
  value.projectile_size_addition;
export const ModifierSpell$Modifier$projectile_lifetime_multiplier = (value) =>
  value.projectile_lifetime_multiplier;
export const ModifierSpell$Modifier$8 = (value) =>
  value.projectile_lifetime_multiplier;
export const ModifierSpell$Modifier$projectile_lifetime_addition = (value) =>
  value.projectile_lifetime_addition;
export const ModifierSpell$Modifier$9 = (value) =>
  value.projectile_lifetime_addition;
export const ModifierSpell$Modifier$cast_delay_multiplier = (value) =>
  value.cast_delay_multiplier;
export const ModifierSpell$Modifier$10 = (value) => value.cast_delay_multiplier;
export const ModifierSpell$Modifier$cast_delay_addition = (value) =>
  value.cast_delay_addition;
export const ModifierSpell$Modifier$11 = (value) => value.cast_delay_addition;
export const ModifierSpell$Modifier$recharge_multiplier = (value) =>
  value.recharge_multiplier;
export const ModifierSpell$Modifier$12 = (value) => value.recharge_multiplier;
export const ModifierSpell$Modifier$recharge_addition = (value) =>
  value.recharge_addition;
export const ModifierSpell$Modifier$13 = (value) => value.recharge_addition;
export const ModifierSpell$Modifier$critical_chance_multiplier = (value) =>
  value.critical_chance_multiplier;
export const ModifierSpell$Modifier$14 = (value) =>
  value.critical_chance_multiplier;
export const ModifierSpell$Modifier$critical_chance_addition = (value) =>
  value.critical_chance_addition;
export const ModifierSpell$Modifier$15 = (value) =>
  value.critical_chance_addition;
export const ModifierSpell$Modifier$spread_multiplier = (value) =>
  value.spread_multiplier;
export const ModifierSpell$Modifier$16 = (value) => value.spread_multiplier;
export const ModifierSpell$Modifier$spread_addition = (value) =>
  value.spread_addition;
export const ModifierSpell$Modifier$17 = (value) => value.spread_addition;
export const ModifierSpell$Modifier$ui_sprite = (value) => value.ui_sprite;
export const ModifierSpell$Modifier$18 = (value) => value.ui_sprite;
export const ModifierSpell$Modifier$adds_trigger = (value) =>
  value.adds_trigger;
export const ModifierSpell$Modifier$19 = (value) => value.adds_trigger;
export const ModifierSpell$Modifier$visual_tint = (value) => value.visual_tint;
export const ModifierSpell$Modifier$20 = (value) => value.visual_tint;

export class Projectile extends $CustomType {
  constructor(id, spell, position, direction, time_alive, visuals, trigger_payload) {
    super();
    this.id = id;
    this.spell = spell;
    this.position = position;
    this.direction = direction;
    this.time_alive = time_alive;
    this.visuals = visuals;
    this.trigger_payload = trigger_payload;
  }
}
export const Projectile$Projectile = (id, spell, position, direction, time_alive, visuals, trigger_payload) =>
  new Projectile(id,
  spell,
  position,
  direction,
  time_alive,
  visuals,
  trigger_payload);
export const Projectile$isProjectile = (value) => value instanceof Projectile;
export const Projectile$Projectile$id = (value) => value.id;
export const Projectile$Projectile$0 = (value) => value.id;
export const Projectile$Projectile$spell = (value) => value.spell;
export const Projectile$Projectile$1 = (value) => value.spell;
export const Projectile$Projectile$position = (value) => value.position;
export const Projectile$Projectile$2 = (value) => value.position;
export const Projectile$Projectile$direction = (value) => value.direction;
export const Projectile$Projectile$3 = (value) => value.direction;
export const Projectile$Projectile$time_alive = (value) => value.time_alive;
export const Projectile$Projectile$4 = (value) => value.time_alive;
export const Projectile$Projectile$visuals = (value) => value.visuals;
export const Projectile$Projectile$5 = (value) => value.visuals;
export const Projectile$Projectile$trigger_payload = (value) =>
  value.trigger_payload;
export const Projectile$Projectile$6 = (value) => value.trigger_payload;

export class ModifiedSpell extends $CustomType {
  constructor(base, final_damage, final_speed, final_size, final_lifetime, final_cast_delay, final_recharge_time, final_critical_chance, final_spread, total_mana_cost) {
    super();
    this.base = base;
    this.final_damage = final_damage;
    this.final_speed = final_speed;
    this.final_size = final_size;
    this.final_lifetime = final_lifetime;
    this.final_cast_delay = final_cast_delay;
    this.final_recharge_time = final_recharge_time;
    this.final_critical_chance = final_critical_chance;
    this.final_spread = final_spread;
    this.total_mana_cost = total_mana_cost;
  }
}
export const ModifiedSpell$ModifiedSpell = (base, final_damage, final_speed, final_size, final_lifetime, final_cast_delay, final_recharge_time, final_critical_chance, final_spread, total_mana_cost) =>
  new ModifiedSpell(base,
  final_damage,
  final_speed,
  final_size,
  final_lifetime,
  final_cast_delay,
  final_recharge_time,
  final_critical_chance,
  final_spread,
  total_mana_cost);
export const ModifiedSpell$isModifiedSpell = (value) =>
  value instanceof ModifiedSpell;
export const ModifiedSpell$ModifiedSpell$base = (value) => value.base;
export const ModifiedSpell$ModifiedSpell$0 = (value) => value.base;
export const ModifiedSpell$ModifiedSpell$final_damage = (value) =>
  value.final_damage;
export const ModifiedSpell$ModifiedSpell$1 = (value) => value.final_damage;
export const ModifiedSpell$ModifiedSpell$final_speed = (value) =>
  value.final_speed;
export const ModifiedSpell$ModifiedSpell$2 = (value) => value.final_speed;
export const ModifiedSpell$ModifiedSpell$final_size = (value) =>
  value.final_size;
export const ModifiedSpell$ModifiedSpell$3 = (value) => value.final_size;
export const ModifiedSpell$ModifiedSpell$final_lifetime = (value) =>
  value.final_lifetime;
export const ModifiedSpell$ModifiedSpell$4 = (value) => value.final_lifetime;
export const ModifiedSpell$ModifiedSpell$final_cast_delay = (value) =>
  value.final_cast_delay;
export const ModifiedSpell$ModifiedSpell$5 = (value) => value.final_cast_delay;
export const ModifiedSpell$ModifiedSpell$final_recharge_time = (value) =>
  value.final_recharge_time;
export const ModifiedSpell$ModifiedSpell$6 = (value) =>
  value.final_recharge_time;
export const ModifiedSpell$ModifiedSpell$final_critical_chance = (value) =>
  value.final_critical_chance;
export const ModifiedSpell$ModifiedSpell$7 = (value) =>
  value.final_critical_chance;
export const ModifiedSpell$ModifiedSpell$final_spread = (value) =>
  value.final_spread;
export const ModifiedSpell$ModifiedSpell$8 = (value) => value.final_spread;
export const ModifiedSpell$ModifiedSpell$total_mana_cost = (value) =>
  value.total_mana_cost;
export const ModifiedSpell$ModifiedSpell$9 = (value) => value.total_mana_cost;

export function default_modifier(name, ui_sprite) {
  return new Modifier(
    name,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    $duration.milliseconds(0),
    1.0,
    $duration.nanoseconds(0),
    1.0,
    $duration.nanoseconds(0),
    1.0,
    0.0,
    1.0,
    0.0,
    ui_sprite,
    false,
    0xFFFFFF,
  );
}

/**
 * Apply additive modifiers to base spell stats
 * 
 * @ignore
 */
function apply_additive_modifiers(base_spell, modifiers) {
  return $iv.fold(
    modifiers,
    [
      base_spell.damage,
      base_spell.projectile_speed,
      base_spell.projectile_size,
      base_spell.projectile_lifetime,
      base_spell.cast_delay_addition,
      $duration.milliseconds(0),
      base_spell.critical_chance,
      base_spell.spread,
    ],
    (acc, mod) => {
      let damage;
      let speed;
      let size;
      let lifetime;
      let cast_delay;
      let recharge_time;
      let crit_chance;
      let spread;
      damage = acc[0];
      speed = acc[1];
      size = acc[2];
      lifetime = acc[3];
      cast_delay = acc[4];
      recharge_time = acc[5];
      crit_chance = acc[6];
      spread = acc[7];
      return [
        damage + mod.damage_addition,
        speed + mod.projectile_speed_addition,
        size + mod.projectile_size_addition,
        $duration.add(lifetime, mod.projectile_lifetime_addition),
        $duration.add(cast_delay, mod.cast_delay_addition),
        $duration.add(recharge_time, mod.recharge_addition),
        crit_chance + mod.critical_chance_addition,
        spread + mod.spread_addition,
      ];
    },
  );
}

/**
 * Apply multiplicative modifiers to stats
 * 
 * @ignore
 */
function apply_multiplicative_modifiers(stats, base_mana_cost, modifiers) {
  let damage;
  let speed;
  let size;
  let lifetime;
  let cast_delay;
  let recharge_time;
  let crit_chance;
  let spread;
  damage = stats[0];
  speed = stats[1];
  size = stats[2];
  lifetime = stats[3];
  cast_delay = stats[4];
  recharge_time = stats[5];
  crit_chance = stats[6];
  spread = stats[7];
  return $iv.fold(
    modifiers,
    [
      damage,
      speed,
      size,
      lifetime,
      cast_delay,
      recharge_time,
      crit_chance,
      spread,
      base_mana_cost,
    ],
    (acc, mod) => {
      let damage$1;
      let speed$1;
      let size$1;
      let lifetime$1;
      let cast_delay$1;
      let recharge_time$1;
      let crit_chance$1;
      let spread$1;
      let mana_cost;
      damage$1 = acc[0];
      speed$1 = acc[1];
      size$1 = acc[2];
      lifetime$1 = acc[3];
      cast_delay$1 = acc[4];
      recharge_time$1 = acc[5];
      crit_chance$1 = acc[6];
      spread$1 = acc[7];
      mana_cost = acc[8];
      return [
        damage$1 * mod.damage_multiplier,
        speed$1 * mod.projectile_speed_multiplier,
        size$1 * mod.projectile_size_multiplier,
        (() => {
          let _pipe = lifetime$1;
          let _pipe$1 = $duration.to_seconds(_pipe);
          let _pipe$2 = $float.multiply(
            _pipe$1,
            mod.projectile_lifetime_multiplier,
          );
          let _pipe$3 = $float.multiply(_pipe$2, 1000.0);
          let _pipe$4 = $float.round(_pipe$3);
          return $duration.milliseconds(_pipe$4);
        })(),
        (() => {
          let _pipe = cast_delay$1;
          let _pipe$1 = $duration.to_seconds(_pipe);
          let _pipe$2 = $float.multiply(_pipe$1, mod.cast_delay_multiplier);
          let _pipe$3 = $float.multiply(_pipe$2, 1000.0);
          let _pipe$4 = $float.round(_pipe$3);
          return $duration.milliseconds(_pipe$4);
        })(),
        (() => {
          let _pipe = recharge_time$1;
          let _pipe$1 = $duration.to_seconds(_pipe);
          let _pipe$2 = $float.multiply(_pipe$1, mod.recharge_multiplier);
          let _pipe$3 = $float.multiply(_pipe$2, 1000.0);
          let _pipe$4 = $float.round(_pipe$3);
          return $duration.milliseconds(_pipe$4);
        })(),
        crit_chance$1 * mod.critical_chance_multiplier,
        spread$1 * mod.spread_multiplier,
        mana_cost + mod.mana_cost,
      ];
    },
  );
}

/**
 * Apply a list of modifiers to a damaging spell
 */
export function apply_modifiers(id, ui_sprite, spell, modifiers) {
  let after_additions = apply_additive_modifiers(spell, modifiers);
  let $ = apply_multiplicative_modifiers(
    after_additions,
    spell.mana_cost,
    modifiers,
  );
  let final_damage;
  let final_speed;
  let final_size;
  let final_lifetime;
  let final_cast_delay;
  let final_recharge_time;
  let final_critical_chance;
  let final_spread;
  let total_mana_cost;
  final_damage = $[0];
  final_speed = $[1];
  final_size = $[2];
  final_lifetime = $[3];
  final_cast_delay = $[4];
  final_recharge_time = $[5];
  final_critical_chance = $[6];
  final_spread = $[7];
  total_mana_cost = $[8];
  return new ModifiedSpell(
    new DamageSpell(id, ui_sprite, spell),
    final_damage,
    final_speed,
    final_size,
    final_lifetime,
    final_cast_delay,
    final_recharge_time,
    final_critical_chance,
    final_spread,
    total_mana_cost,
  );
}

/**
 * Basic projectile spell
 */
export function spark() {
  return new DamageSpell(
    new Spark(),
    "spell_icons/spark.png",
    new Damage(
      "Spark",
      5.0,
      3.0,
      50.0,
      $duration.seconds(2),
      1.0,
      $duration.milliseconds(50),
      0.05,
      5.0,
      new SpellVisuals(
        new StaticSprite(
          "spell_projectiles/spark.png",
          new $vec2.Vec2(1.0, 1.0),
        ),
        new NoEffect(),
        0xFFFFFF,
        1.0,
      ),
      false,
    ),
  );
}

/**
 * Heavy damage spell - Beam type that connects player to enemy
 */
export function lightning() {
  return new DamageSpell(
    new LightningBolt(),
    "spell_icons/lightning_bolt.png",
    new Damage(
      "Lightning Bolt",
      100.0,
      100.0,
      100.0,
      $duration.milliseconds(1000),
      1.0,
      $duration.milliseconds(0),
      0.15,
      0.0,
      new SpellVisuals(
        new StaticSprite(
          "spell_projectiles/lightning_bolt.png",
          new $vec2.Vec2(0.5, 0.5),
        ),
        new NoEffect(),
        0xFFFFFF,
        1.0,
      ),
      false,
    ),
  );
}

/**
 * Firebolt - Explodes on impact, damaging enemies in an area and setting them on fire
 */
export function fireball() {
  return new DamageSpell(
    new Fireball(),
    "spell_icons/fireball.png",
    new Damage(
      "Firebolt",
      15.0,
      5.0,
      10.0,
      $duration.milliseconds(2500),
      2.0,
      $duration.milliseconds(0),
      0.1,
      10.0,
      new SpellVisuals(
        new StaticSprite(
          "spell_projectiles/fireball.png",
          new $vec2.Vec2(2.0, 2.0),
        ),
        new NoEffect(),
        0xFFFFFF,
        1.0,
      ),
      false,
    ),
  );
}

/**
 * Orbiting Spell - Creates a projectile that orbits around the player and damages enemies on contact
 */
export function orbiting_spell() {
  return new DamageSpell(
    new OrbitingSpell(),
    "spell_icons/orbiting_shards.png",
    new Damage(
      "Orbiting Spell",
      20.0,
      4.0,
      2.0,
      $duration.seconds(30),
      1.5,
      $duration.milliseconds(0),
      0.05,
      0.0,
      new SpellVisuals(
        new StaticSprite(
          "spell_projectiles/orbiting_shards.png",
          new $vec2.Vec2(1.5, 1.5),
        ),
        new NoEffect(),
        0xFFFFFF,
        1.0,
      ),
      false,
    ),
  );
}

export function rapid_fire() {
  return new ModifierSpell(
    new RapidFire(),
    "spell_icons/rapid_fire.png",
    (() => {
      let _record = default_modifier("Rapid Fire", "spell_icons/rapid_fire.png");
      return new Modifier(
        _record.name,
        _record.mana_cost,
        _record.damage_multiplier,
        _record.damage_addition,
        _record.projectile_speed_multiplier,
        _record.projectile_speed_addition,
        _record.projectile_size_multiplier,
        _record.projectile_size_addition,
        _record.projectile_lifetime_multiplier,
        _record.projectile_lifetime_addition,
        _record.cast_delay_multiplier,
        $duration.milliseconds(-170),
        _record.recharge_multiplier,
        $duration.milliseconds(-330),
        _record.critical_chance_multiplier,
        _record.critical_chance_addition,
        _record.spread_multiplier,
        _record.spread_addition,
        _record.ui_sprite,
        _record.adds_trigger,
        _record.visual_tint,
      );
    })(),
  );
}

/**
 * Double Spell - casts 2 spells at once (no mana cost)
 */
export function double_spell() {
  return new MulticastSpell(
    new DoubleSpell(),
    "spell_icons/double_spell.png",
    new Multicast(
      "Double Spell",
      0.0,
      new Fixed(2),
      2,
      "spell_icons/double_spell.png",
    ),
  );
}

export function add_mana() {
  return new ModifierSpell(
    new AddMana(),
    "spell_icons/mana.png",
    (() => {
      let _record = default_modifier("Add Mana", "spell_icons/mana.png");
      return new Modifier(
        _record.name,
        -30.0,
        _record.damage_multiplier,
        _record.damage_addition,
        _record.projectile_speed_multiplier,
        _record.projectile_speed_addition,
        _record.projectile_size_multiplier,
        _record.projectile_size_addition,
        _record.projectile_lifetime_multiplier,
        _record.projectile_lifetime_addition,
        _record.cast_delay_multiplier,
        $duration.milliseconds(17),
        _record.recharge_multiplier,
        _record.recharge_addition,
        _record.critical_chance_multiplier,
        _record.critical_chance_addition,
        _record.spread_multiplier,
        _record.spread_addition,
        _record.ui_sprite,
        _record.adds_trigger,
        _record.visual_tint,
      );
    })(),
  );
}

export function add_damage() {
  return new ModifierSpell(
    new AddDamage(),
    "spell_icons/add_damage.png",
    (() => {
      let _record = default_modifier("Add Damage", "spell_icons/add_damage.png");
      return new Modifier(
        _record.name,
        _record.mana_cost,
        _record.damage_multiplier,
        10.0,
        _record.projectile_speed_multiplier,
        _record.projectile_speed_addition,
        _record.projectile_size_multiplier,
        _record.projectile_size_addition,
        _record.projectile_lifetime_multiplier,
        _record.projectile_lifetime_addition,
        _record.cast_delay_multiplier,
        _record.cast_delay_addition,
        _record.recharge_multiplier,
        _record.recharge_addition,
        _record.critical_chance_multiplier,
        _record.critical_chance_addition,
        _record.spread_multiplier,
        _record.spread_addition,
        _record.ui_sprite,
        _record.adds_trigger,
        _record.visual_tint,
      );
    })(),
  );
}

export function piercing() {
  return new ModifierSpell(
    new Piercing(),
    "spell_icons/piercing.png",
    (() => {
      let _record = default_modifier("Piercing", "spell_icons/piercing.png");
      return new Modifier(
        _record.name,
        130.0,
        _record.damage_multiplier,
        _record.damage_addition,
        _record.projectile_speed_multiplier,
        _record.projectile_speed_addition,
        _record.projectile_size_multiplier,
        _record.projectile_size_addition,
        _record.projectile_lifetime_multiplier,
        _record.projectile_lifetime_addition,
        _record.cast_delay_multiplier,
        _record.cast_delay_addition,
        _record.recharge_multiplier,
        _record.recharge_addition,
        _record.critical_chance_multiplier,
        _record.critical_chance_addition,
        _record.spread_multiplier,
        _record.spread_addition,
        _record.ui_sprite,
        _record.adds_trigger,
        _record.visual_tint,
      );
    })(),
  );
}

/**
 * Spark with Trigger - fires a projectile that casts another spell upon collision
 */
export function spark_with_trigger() {
  return new DamageSpell(
    new SparkWithTrigger(),
    "spell_icons/spark_with_trigger.png",
    new Damage(
      "Spark with Trigger",
      10.0,
      3.0,
      50.0,
      $duration.seconds(2),
      1.0,
      $duration.milliseconds(50),
      0.05,
      -1.0,
      new SpellVisuals(
        new StaticSprite(
          "spell_projectiles/spark.png",
          new $vec2.Vec2(1.5, 1.5),
        ),
        new NoEffect(),
        0xFFFFFF,
        1.0,
      ),
      true,
    ),
  );
}

/**
 * Add Trigger - makes the next projectile cast another spell upon collision
 */
export function add_trigger() {
  return new ModifierSpell(
    new AddTrigger(),
    "spell_icons/add_trigger.png",
    (() => {
      let _record = default_modifier(
        "Add Trigger",
        "spell_icons/add_trigger.png",
      );
      return new Modifier(
        _record.name,
        10.0,
        _record.damage_multiplier,
        _record.damage_addition,
        _record.projectile_speed_multiplier,
        _record.projectile_speed_addition,
        _record.projectile_size_multiplier,
        _record.projectile_size_addition,
        _record.projectile_lifetime_multiplier,
        _record.projectile_lifetime_addition,
        _record.cast_delay_multiplier,
        _record.cast_delay_addition,
        _record.recharge_multiplier,
        _record.recharge_addition,
        _record.critical_chance_multiplier,
        _record.critical_chance_addition,
        _record.spread_multiplier,
        _record.spread_addition,
        _record.ui_sprite,
        true,
        _record.visual_tint,
      );
    })(),
  );
}

export function name(spell) {
  if (spell instanceof DamageSpell) {
    let kind = spell.kind;
    return kind.name;
  } else if (spell instanceof ModifierSpell) {
    let kind = spell.kind;
    return kind.name;
  } else {
    let kind = spell.kind;
    return kind.name;
  }
}

export function all_spells() {
  return toList([
    spark(),
    fireball(),
    lightning(),
    orbiting_spell(),
    spark_with_trigger(),
    add_damage(),
    rapid_fire(),
    add_mana(),
    piercing(),
    double_spell(),
    add_trigger(),
  ]);
}

export function random_spell() {
  let _block;
  let _pipe = all_spells();
  let _pipe$1 = $list.shuffle(_pipe);
  _block = $list.first(_pipe$1);
  let $ = _block;
  let spell;
  if ($ instanceof Ok) {
    spell = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "client/magic_system/spell",
      597,
      "random_spell",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 14287,
        end: 14368,
        pattern_start: 14298,
        pattern_end: 14307
      }
    )
  }
  return spell;
}
