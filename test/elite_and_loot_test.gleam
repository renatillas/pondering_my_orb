import gleeunit
import pondering_my_orb/enemy
import pondering_my_orb/id
import pondering_my_orb/loot
import pondering_my_orb/perk
import pondering_my_orb/player
import pondering_my_orb/spell
import pondering_my_orb/wand
import tiramisu/physics as tiramisu
import tiramisu/transform
import vec/vec3.{Vec3}

pub fn main() {
  gleeunit.main()
}

pub fn elite_enemy_has_correct_stats_test() {
  let elite =
    enemy.elite(
      id: id.enemy(1),
      position: Vec3(0.0, 0.0, 0.0),
      enemy_type: enemy.EnemyType1,
    )

  // Elite should have enhanced stats
  assert elite.is_elite == True
  assert elite.max_health == 50.0
  assert elite.damage == 15.0
  assert elite.xp_value == 50
}

pub fn basic_enemy_not_elite_test() {
  let basic =
    enemy.basic(
      id: id.enemy(2),
      position: Vec3(0.0, 0.0, 0.0),
      enemy_type: enemy.EnemyType1,
    )

  // Basic enemies are not elite
  assert basic.is_elite == False
  assert basic.xp_value == 10
}

pub fn perk_health_boost_increases_health_test() {
  let initial_player = player.init()
  let perk_value = perk.HealthBoost(1.5)
  // 50% boost

  let boosted_player = player.apply_perk(initial_player, perk_value)

  // Max health should be 1.5x the original
  assert boosted_player.max_health == initial_player.max_health *. 1.5
}

pub fn perk_speed_boost_increases_speed_test() {
  let initial_player = player.init()
  let perk_value = perk.SpeedBoost(1.25)
  // 25% boost

  let boosted_player = player.apply_perk(initial_player, perk_value)

  // Speed should be 1.25x the original
  assert boosted_player.speed == initial_player.speed *. 1.25
}

pub fn perk_mana_regen_boost_increases_regen_test() {
  let initial_player = player.init()
  let perk_value = perk.ManaRegenBoost(1.3)

  let boosted_player = player.apply_perk(initial_player, perk_value)

  // Mana regen should be increased
  assert boosted_player.wand.mana_recharge_rate
    == initial_player.wand.mana_recharge_rate *. 1.3
}

pub fn loot_drop_can_be_picked_up_when_close_test() {
  let spell_visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let available_spells = [
    spell.spark(spell_visuals),
    spell.fireball(spell_visuals),
  ]

  let loot_drop =
    loot.generate_elite_drop(
      id.loot_drop(1),
      Vec3(5.0, 0.0, 5.0),
      available_spells,
    )

  let player_close = player.init() |> player.with_position(Vec3(5.0, 0.0, 5.0))
  let player_far = player.init() |> player.with_position(Vec3(50.0, 0.0, 50.0))

  // Player should be able to pick up loot when close
  assert loot.can_pickup(loot_drop, player_close.position, 2.0) == True

  // Player should not be able to pick up loot when far
  assert loot.can_pickup(loot_drop, player_far.position, 2.0) == False
}

pub fn random_wand_generation_creates_valid_wand_test() {
  let spell_visuals =
    spell.SpellVisuals(
      projectile_spritesheet: spell.mock_spritesheet(),
      projectile_animation: spell.mock_animation(),
      hit_spritesheet: spell.mock_spritesheet(),
      hit_animation: spell.mock_animation(),
    )

  let available_spells = [
    spell.spark(spell_visuals),
    spell.fireball(spell_visuals),
    spell.lightning(spell_visuals),
  ]

  let generated_wand = loot.generate_random_wand(available_spells)

  // Wand should have valid stats
  assert generated_wand.max_mana >. 0.0
  assert generated_wand.mana_recharge_rate >. 0.0
  assert generated_wand.cast_delay >. 0.0
}

pub fn player_pickup_loot_applies_wand_test() {
  let new_wand = wand.new_random("Test Wand")

  // Create a proper physics body for the test
  let physics_body =
    tiramisu.new_rigid_body(tiramisu.Dynamic)
    |> tiramisu.with_collider(tiramisu.Box(
      offset: transform.identity,
      width: 0.6,
      height: 0.6,
      depth: 0.6,
    ))
    |> tiramisu.build()

  let loot_drop =
    loot.LootDrop(
      id: id.loot_drop(1),
      loot_type: loot.WandLoot(new_wand),
      position: Vec3(1.0, 0.0, 1.0),
      physics_body:,
    )

  let initial_player =
    player.init() |> player.with_position(Vec3(1.0, 0.0, 1.0))
  let original_wand_name = initial_player.wand.name

  let #(updated_player, picked_up_ids) =
    player.pickup_loot(initial_player, [loot_drop], 2.0)

  // Player should have picked up the loot
  assert picked_up_ids == [id.loot_drop(1)]

  // Player's wand should be replaced
  assert updated_player.wand.name == "Test Wand"
  assert updated_player.wand.name != original_wand_name
}

pub fn player_pickup_loot_applies_perk_test() {
  let perk_value = perk.SpeedBoost(2.0)
  // Double speed

  // Create a proper physics body for the test
  let physics_body =
    tiramisu.new_rigid_body(tiramisu.Dynamic)
    |> tiramisu.with_collider(tiramisu.Box(
      offset: transform.identity,
      width: 0.6,
      height: 0.6,
      depth: 0.6,
    ))
    |> tiramisu.build()

  let loot_drop =
    loot.LootDrop(
      id: id.loot_drop(2),
      loot_type: loot.PerkLoot(perk_value),
      position: Vec3(1.0, 0.0, 1.0),
      physics_body:,
    )

  let initial_player =
    player.init() |> player.with_position(Vec3(1.0, 0.0, 1.0))
  let original_speed = initial_player.speed

  let #(updated_player, picked_up_ids) =
    player.pickup_loot(initial_player, [loot_drop], 2.0)

  // Player should have picked up the loot
  assert picked_up_ids == [id.loot_drop(2)]

  // Player's speed should be doubled
  assert updated_player.speed == original_speed *. 2.0
}

pub fn perk_info_displays_correct_percentage_test() {
  let health_boost = perk.HealthBoost(1.25)
  // 25% boost
  let info = perk.get_info(health_boost)

  assert info.name == "Health Boost"
  assert info.description == "Increases max health by 25%"
}
