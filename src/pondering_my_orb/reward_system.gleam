import gleam/dict.{type Dict}
import gleam/list
import pondering_my_orb/spell

/// Generate a pool of 3 random spell rewards for leveling up
pub fn generate_spell_rewards(
  visuals: Dict(spell.Id, spell.SpellVisuals),
) -> List(spell.Spell) {
  let assert Ok(fireball_visuals) = dict.get(visuals, spell.Fireball)
  let assert Ok(spark_visuals) = dict.get(visuals, spell.Spark)
  let assert Ok(lightning_bolt_visuals) = dict.get(visuals, spell.LightningBolt)

  // Define a pool of possible spells to choose from
  let possible_spells = [
    spell.fireball(fireball_visuals),
    spell.lightning(lightning_bolt_visuals),
    spell.spark(spark_visuals),
    spell.double_spell(),
    spell.add_mana(),
    spell.add_damage(),
    spell.piercing(),
  ]

  // Shuffle and take 3 random spells
  list.shuffle(possible_spells)
  |> list.take(3)
}
