import gleam/bool
import gleam/list
import gleam/option.{Some}
import pondering_my_orb/damage_number
import pondering_my_orb/enemy
import pondering_my_orb/game_state.{type Model, Playing}
import pondering_my_orb/id
import pondering_my_orb/loot
import pondering_my_orb/map
import pondering_my_orb/player
import pondering_my_orb/spell
import pondering_my_orb/xp_shard
import pondering_my_orb/camera as game_camera
import tiramisu/light
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{Vec3}

pub fn render(model: Model) -> scene.Node(id.Id) {
  use <- bool.guard(
    model.game_phase != Playing,
    return: scene.empty(id.scene(), transform.identity, []),
  )

  let camera = game_camera.view(model.camera)

  let ground = case model.ground {
    Some(ground) -> [map.view_ground(ground, id.ground())]
    _ -> []
  }

  let foliage = case model.foliage {
    Some(foliage) -> [map.view_foliage(foliage, id.box())]
    _ -> []
  }

  // Render projectiles with sprites
  let projectiles =
    spell.view(id.projectile, model.projectiles, model.camera.position)

  // Render explosions with sprites
  let explosions =
    list.map(model.projectile_hits, spell.view_hits(_, model.camera.position))

  // Render XP shards
  let xp_shards = case model.xp_spritesheet, model.xp_animation {
    Some(sheet), Some(animation) ->
      list.map(model.xp_shards, fn(shard) {
        xp_shard.render(shard, model.camera.position, sheet, animation)
      })
    _, _ -> []
  }

  // Render loot drops
  let loot_drops = list.map(model.loot_drops, loot.render)

  // Render damage numbers
  let damage_numbers =
    list.map(model.damage_numbers, damage_number.render(
      _,
      model.camera.position,
    ))

  // Pass camera position for billboard rotation
  let enemies = model.enemies |> list.map(enemy.render(_, model.camera.position))

  scene.empty(
    id: id.scene(),
    transform: transform.identity,
    children: list.flatten([
      enemies,
      ground,
      foliage,
      projectiles,
      explosions,
      xp_shards,
      loot_drops,
      damage_numbers,
      [
        player.view(id.player(), model.player),
        camera,
        scene.light(
          id: id.ambient(),
          light: {
            let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.5)
            light
          },
          transform: transform.identity,
        ),
        scene.light(
          id: id.directional(),
          light: {
            let assert Ok(light) =
              light.directional(color: 0xffffff, intensity: 2.0)
            light
          },
          transform: transform.at(position: Vec3(5.0, 10.0, 7.5)),
        ),
      ],
    ]),
  )
}
