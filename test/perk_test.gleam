import pondering_my_orb/perk
import pondering_my_orb/player

pub fn big_bonk_perk_info_test() {
  let big_bonk = perk.BigBonk(0.02, 20.0)
  let info = perk.get_info(big_bonk)

  assert info.name == "Big Bonk"
  assert info.description == "2% chance to deal 20x damage"
}

pub fn big_bonk_applies_to_player_test() {
  let test_player = player.init()
  let big_bonk = perk.BigBonk(0.02, 20.0)

  let updated_player = player.apply_perk(test_player, big_bonk)

  // Big Bonk should be added to perks list
  assert updated_player.perks == [big_bonk]
}

pub fn big_bonk_damage_always_returns_value_test() {
  let test_player = player.init()
  let big_bonk = perk.BigBonk(0.02, 20.0)
  let player_with_bonk = player.apply_perk(test_player, big_bonk)

  let base_damage = 10.0

  // Test multiple times to ensure it always returns a valid damage value
  let #(damage1, _is_crit1) =
    player.apply_big_bonk(player_with_bonk, base_damage)
  let #(damage2, _is_crit2) =
    player.apply_big_bonk(player_with_bonk, base_damage)
  let #(damage3, _is_crit3) =
    player.apply_big_bonk(player_with_bonk, base_damage)

  // All damages should be either base damage or crit damage (not zero, not negative)
  assert damage1 >. 0.0
  assert damage2 >. 0.0
  assert damage3 >. 0.0
}

pub fn big_bonk_with_no_perks_returns_base_damage_test() {
  let test_player = player.init()
  let base_damage = 10.0

  let #(result_damage, is_crit) =
    player.apply_big_bonk(test_player, base_damage)

  assert result_damage == base_damage
  assert is_crit == False
}

pub fn big_bonk_returns_crit_flag_test() {
  let test_player = player.init()
  // 100% crit chance for testing
  let guaranteed_crit = perk.BigBonk(1.0, 20.0)
  let player_with_bonk = player.apply_perk(test_player, guaranteed_crit)

  let base_damage = 10.0
  let #(result_damage, is_crit) =
    player.apply_big_bonk(player_with_bonk, base_damage)

  // Should always crit with 100% chance
  assert is_crit == True
  assert result_damage == base_damage *. 20.0
}
