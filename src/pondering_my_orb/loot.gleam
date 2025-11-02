import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import pondering_my_orb/id.{type Id}
import pondering_my_orb/perk.{type Perk}
import pondering_my_orb/spell.{type Spell}
import pondering_my_orb/wand.{type Wand}
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3}

/// Types of loot that can drop
pub type LootType {
  WandLoot(wand: Wand)
  PerkLoot(perk: Perk)
}

/// Represents a piece of loot in the world
pub type LootDrop {
  LootDrop(
    id: Id,
    loot_type: LootType,
    position: Vec3(Float),
    physics_body: physics.RigidBody,
  )
}

/// Generate a random wand with spells
pub fn generate_random_wand(available_spells: List(Spell)) -> Wand {
  // Random wand stats
  let slot_count = case float.random() {
    r if r <. 0.3 -> 2
    r if r <. 0.7 -> 3
    r if r <. 0.9 -> 4
    _ -> 5
  }

  let cast_delay = 0.1 +. float.random() *. 0.15
  let recharge_time = 0.25 +. float.random() *. 0.25
  let max_mana = 100.0 +. float.random() *. 100.0
  let mana_recharge_rate = 30.0 +. float.random() *. 25.0
  let spread = float.random() *. 10.0

  let wand =
    wand.new(
      name: "Elite Wand",
      slot_count:,
      max_mana:,
      mana_recharge_rate:,
      cast_delay:,
      recharge_time:,
      spells_per_cast: 1,
      spread:,
    )

  // Fill some slots with random spells
  let spell_count = int.max(1, { slot_count * 2 } / 3)

  populate_wand_slots(wand, available_spells, spell_count, 0)
}

fn populate_wand_slots(
  wand: Wand,
  available_spells: List(Spell),
  remaining: Int,
  current_slot: Int,
) -> Wand {
  case remaining <= 0 {
    True -> wand
    False -> {
      // Pick a random spell
      let spell_index =
        float.random()
        |> float.multiply(int.to_float(list.length(available_spells)))
        |> float.floor()
        |> float.round()
        |> int.max(0)
        |> int.min(list.length(available_spells) - 1)

      let maybe_spell =
        list.drop(available_spells, spell_index)
        |> list.first()

      case maybe_spell {
        Ok(spell) -> {
          let updated_wand =
            wand.set_spell(wand, current_slot, spell)
            |> result.unwrap(wand)

          populate_wand_slots(
            updated_wand,
            available_spells,
            remaining - 1,
            current_slot + 1,
          )
        }
        Error(_) ->
          populate_wand_slots(
            wand,
            available_spells,
            remaining - 1,
            current_slot + 1,
          )
      }
    }
  }
}

/// Generate random loot drop from an elite enemy
pub fn generate_elite_drop(
  id: Id,
  position: Vec3(Float),
  available_spells: List(Spell),
) -> LootDrop {
  let loot_type = case float.random() {
    r if r <. 0.7 -> {
      // 70% chance for wand
      WandLoot(generate_random_wand(available_spells))
    }
    _ -> {
      // 30% chance for perk
      PerkLoot(perk.random())
    }
  }

  let physics_body =
    physics.new_rigid_body(physics.Dynamic)
    |> physics.with_collider(physics.Box(
      offset: transform.identity,
      width: 0.6,
      height: 0.6,
      depth: 0.6,
    ))
    |> physics.with_friction(0.5)
    |> physics.build()

  LootDrop(id:, loot_type:, position:, physics_body:)
}

/// Render a loot drop in the scene
pub fn render(loot: LootDrop) -> scene.Node(Id) {
  let color = case loot.loot_type {
    WandLoot(_) -> 0x8b4513
    // Brown for wands
    PerkLoot(_) -> 0xffd700
    // Gold for perks
  }

  let assert Ok(box) = geometry.box(width: 0.6, height: 0.6, depth: 0.6)

  let assert Ok(material) =
    material.new() |> material.with_color(color) |> material.build()

  scene.mesh(
    id: loot.id,
    geometry: box,
    material:,
    transform: transform.at(position: loot.position),
    physics: option.Some(loot.physics_body),
  )
}

/// Update loot drop physics position
pub fn update_position(
  loot: LootDrop,
  physics_world: physics.PhysicsWorld(Id),
) -> LootDrop {
  let new_position =
    physics.get_transform(physics_world, loot.id)
    |> result.map(transform.position)
    |> result.unwrap(or: loot.position)

  LootDrop(..loot, position: new_position)
}

/// Check if player is close enough to pick up loot
pub fn can_pickup(
  loot: LootDrop,
  player_position: Vec3(Float),
  pickup_range: Float,
) -> Bool {
  let dx = loot.position.x -. player_position.x
  let dy = loot.position.y -. player_position.y
  let dz = loot.position.z -. player_position.z
  let distance_squared = dx *. dx +. dy *. dy +. dz *. dz
  distance_squared <. pickup_range *. pickup_range
}
