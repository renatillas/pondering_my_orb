import gleam/list
import pondering_my_orb/chest
import pondering_my_orb/id.{type Id}
import pondering_my_orb/loot
import pondering_my_orb/perk
import pondering_my_orb/xp_shard
import tiramisu/effect.{type Effect}
import tiramisu/ui as tiramisu_ui
import vec/vec3.{type Vec3}

/// Check for XP shard collection
pub fn collect_xp_shards(
  xp_shards: List(xp_shard.XPShard),
  player_position: Vec3(Float),
) -> #(List(xp_shard.XPShard), Int) {
  list.fold(xp_shards, #([], 0), fn(acc, shard) {
    let #(shards, xp) = acc
    case xp_shard.should_collect(shard, player_position) {
      True -> #(shards, xp + xp_shard.xp_value)
      False -> #([shard, ..shards], xp)
    }
  })
}

/// Check for loot pickups and generate effects
pub fn collect_loot(
  loot_drops: List(loot.LootDrop),
  player_position: Vec3(Float),
  ui_msg_constructor: fn(loot.LootType) -> ui_msg,
) -> #(List(loot.LootDrop), List(Effect(msg))) {
  let #(picked_up_ids, effects) =
    list.fold(loot_drops, #([], []), fn(acc, loot_drop) {
      let #(ids, effects) = acc
      case loot.can_pickup(loot_drop, player_position, 2.0) {
        True -> {
          let new_effect =
            tiramisu_ui.dispatch_to_lustre(ui_msg_constructor(
              loot_drop.loot_type,
            ))
          #([loot_drop.id, ..ids], [new_effect, ..effects])
        }
        False -> acc
      }
    })

  // Remove picked up loot
  let remaining_loot =
    list.filter(loot_drops, fn(loot_drop) {
      !list.contains(picked_up_ids, loot_drop.id)
    })

  #(remaining_loot, effects)
}

/// Check for chest opening and generate effects
pub fn open_chests(
  chests: List(chest.Chest),
  player_position: Vec3(Float),
  chest_opened_msg: fn(Id, perk.Perk) -> msg,
) -> #(List(chest.Chest), List(Effect(msg))) {
  let #(opened_chests, effects) =
    list.fold(chests, #([], []), fn(acc, chest_item) {
      let #(opened, effects) = acc
      case chest.can_open(chest_item, player_position, 2.5) {
        True -> {
          let new_effect =
            effect.from(fn(dispatch) {
              dispatch(chest_opened_msg(chest_item.id, chest_item.perk))
            })
          #([chest_item.id, ..opened], [new_effect, ..effects])
        }
        False -> acc
      }
    })

  // Mark opened chests as opened
  let updated_chests =
    list.map(chests, fn(chest_item) {
      case list.contains(opened_chests, chest_item.id) {
        True -> chest.open(chest_item)
        False -> chest_item
      }
    })

  #(updated_chests, effects)
}
