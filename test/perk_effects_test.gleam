import gleam/option
import pondering_my_orb/perk
import pondering_my_orb/player

pub fn vampirism_heals_player_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.Vampirism(0.2))

  // Damage player first
  let #(damaged_player, _reflect) = player.take_damage(test_player, 50.0)

  // Deal 100 damage with vampirism (should heal 20 HP)
  let #(_final_damage, _is_crit, _self_damage, heal_amount) =
    player.apply_damage_perks(test_player, 100.0, option.None)

  // Should heal 20 HP (20% of 100)
  assert heal_amount == 20.0

  // Apply the heal
  let healed_hp = damaged_player.current_health +. heal_amount
  assert healed_hp == 50.0 +. 20.0
}

pub fn beefy_ring_scales_with_max_hp_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.BeefyRing(0.2))

  // Player starts with 100 HP, so should get +20% damage
  let #(final_damage, _is_crit, _self_damage, _heal) =
    player.apply_damage_perks(test_player, 100.0, option.None)

  // 100 damage * (1.0 + 100/100 * 0.2) = 100 * 1.2 = 120
  assert final_damage == 120.0
}

pub fn execute_bonus_damage_to_low_hp_enemies_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.Execute(0.3, 2.0))

  // Enemy at 25% HP (below 30% threshold)
  let #(final_damage_low, _is_crit, _self_damage, _heal) =
    player.apply_damage_perks(test_player, 100.0, option.Some(0.25))

  // Should get 2x damage
  assert final_damage_low == 200.0

  // Enemy at 50% HP (above threshold)
  let #(final_damage_high, _is_crit2, _self_damage2, _heal2) =
    player.apply_damage_perks(test_player, 100.0, option.Some(0.5))

  // Should get normal damage
  assert final_damage_high == 100.0
}

pub fn blood_thirst_heals_on_kill_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.BloodThirst(15.0))

  // Damage player first
  let #(damaged_player, _reflect) = player.take_damage(test_player, 30.0)
  assert damaged_player.current_health == 70.0

  // Trigger on_enemy_killed
  let healed_player = player.on_enemy_killed(damaged_player)

  // Should heal 15 HP
  assert healed_player.current_health == 85.0
}

pub fn fragile_strength_halves_hp_doubles_damage_test() {
  let test_player = player.init()
  assert test_player.max_health == 100.0

  let fragile_player = player.apply_perk(test_player, perk.FragileStrength)

  // Max HP should be halved
  assert fragile_player.max_health == 50.0

  // Damage should be doubled
  let #(final_damage, _is_crit, _self_damage, _heal) =
    player.apply_damage_perks(fragile_player, 100.0, option.None)

  assert final_damage == 200.0
}

pub fn glass_cannon_increases_damage_and_damage_taken_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.GlassCannon(1.5, 1.3))

  // Should deal 50% more damage
  let #(final_damage, _is_crit, _self_damage, _heal) =
    player.apply_damage_perks(test_player, 100.0, option.None)

  assert final_damage == 150.0

  // Should take 30% more damage (50 * 1.3 = 65)
  let #(damaged_player, _reflect) = player.take_damage(test_player, 50.0)
  assert damaged_player.current_health == 100.0 -. 65.0
}

pub fn za_warudo_prevents_lethal_damage_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.ZaWarudo)

  // Take lethal damage
  let #(survived_player, _reflect) = player.take_damage(test_player, 999.0)

  // Should survive with 1 HP
  assert survived_player.current_health == 1.0

  // Za Warudo should be consumed
  assert survived_player.perks == []
}

pub fn turbo_skates_reduces_cast_delay_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.TurboSkates(0.05))

  // Player has 10 speed, so 10 * 0.05 = 0.5 (50% cast speed bonus)
  // Effective delay = base_delay / (1 + 0.5) = base_delay / 1.5
  let base_delay = test_player.wand.cast_delay
  let effective_delay = player.get_effective_cast_delay(test_player)

  assert effective_delay == base_delay /. 1.5
}

pub fn mirror_reflects_damage_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.Mirror(0.3))

  // Take 100 damage
  let #(damaged_player, reflected_damage) =
    player.take_damage(test_player, 100.0)

  // Should take full 100 damage
  assert damaged_player.current_health == 0.0

  // Should reflect 30% back (30 damage)
  assert reflected_damage == 30.0
}

pub fn mirror_multiple_stacks_test() {
  let test_player =
    player.init()
    |> player.apply_perk(perk.Mirror(0.3))
    |> player.apply_perk(perk.Mirror(0.2))

  // Take 100 damage
  let #(_damaged_player, reflected_damage) =
    player.take_damage(test_player, 100.0)

  // Should reflect 30% + 20% = 50% back (50 damage)
  assert reflected_damage == 50.0
}
