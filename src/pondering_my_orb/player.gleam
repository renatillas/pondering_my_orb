import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam_community/maths
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/wand
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

const mouse_sensitivity = 0.003

const jumping_speed = 500.0

const passive_heal_delay = 6.0

const passive_heal_rate = 2

const passive_heal_interval = 0.5

pub type PlayerAction {
  Forward
  Backward
  Left
  Right
  Jump
}

pub type AutoCast {
  AutoCast(time_since_last_cast: Float, current_spell_index: Int)
}

pub type Player {
  Player(
    // Health
    max_health: Int,
    current_health: Int,
    // Movement
    speed: Float,
    position: Vec3(Float),
    rotation: Vec3(Float),
    velocity: Vec3(Float),
    // Taking damage
    time_since_taking_damage: Float,
    // Healing
    passive_heal_delay: Float,
    passive_heal_rate: Int,
    passive_heal_interval: Float,
    time_since_last_passive_heal: Float,
    // Spell casting
    wand: wand.Wand,
    spell_bag: spell_bag.SpellBag,
    auto_cast: AutoCast,
  )
}

pub fn new(
  health health: Int,
  speed speed: Float,
  position position: Vec3(Float),
  rotation rotation: Vec3(Float),
  time_since_taking_damage time_since_taking_damage: Float,
  passive_heal_delay passive_heal_delay: Float,
  passive_heal_rate passive_heal_rate: Int,
  passive_heal_interval passive_heal_interval: Float,
  time_since_last_passive_heal time_since_last_passive_heal: Float,
  wand wand: wand.Wand,
  spell_bag spell_bag: spell_bag.SpellBag,
  auto_cast auto_cast: AutoCast,
) -> Player {
  Player(
    max_health: health,
    current_health: health,
    speed:,
    position:,
    rotation:,
    time_since_taking_damage:,
    passive_heal_delay:,
    passive_heal_rate:,
    passive_heal_interval:,
    time_since_last_passive_heal:,
    wand:,
    spell_bag:,
    auto_cast:,
    velocity: vec3f.zero,
  )
}

pub fn render(id: id, player: Player) {
  let assert Ok(capsule) =
    geometry.cylinder(
      radius_top: 0.5,
      radius_bottom: 0.5,
      height: 2.5,
      radial_segments: 10,
    )

  let assert Ok(material) =
    material.new() |> material.with_color(0xffff00) |> material.build()
  scene.mesh(
    id:,
    geometry: capsule,
    material:,
    transform: transform.at(player.position)
      |> transform.with_euler_rotation(player.rotation),
    physics: option.Some(
      physics.new_rigid_body(physics.Dynamic)
      |> physics.with_collider(physics.Capsule(
        offset: transform.identity,
        half_height: 1.0,
        radius: 0.5,
      ))
      |> physics.with_restitution(0.0)
      |> physics.with_mass(70.0)
      |> physics.with_friction(0.0)
      |> physics.with_lock_rotation_x()
      |> physics.with_lock_rotation_z()
      |> physics.build(),
    ),
  )
}

pub fn init() -> Player {
  let assert Ok(wand) =
    wand.new(
      name: "Player's Wand",
      slot_count: 5,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: 0.01,
      recharge_time: 0.5,
    )
    |> wand.set_spell(0, spell.spark())

  let spell_bag =
    spell_bag.new()
    |> spell_bag.add_spells(spell.spark(), 3)
    |> spell_bag.add_spells(spell.fireball(), 2)
    |> spell_bag.add_spell(spell.lightning())

  new(
    health: 100,
    speed: 5.0,
    position: Vec3(0.0, 2.0, 0.0),
    rotation: Vec3(0.0, 0.0, 0.0),
    time_since_taking_damage: 0.0,
    passive_heal_delay:,
    passive_heal_rate:,
    passive_heal_interval:,
    time_since_last_passive_heal: 0.0,
    wand:,
    spell_bag:,
    auto_cast: AutoCast(time_since_last_cast: 0.0, current_spell_index: 0),
  )
}

pub fn with_position(player: Player, position: Vec3(Float)) -> Player {
  Player(..player, position: position)
}

pub fn default_bindings() -> input.InputBindings(PlayerAction) {
  input.new_bindings()
  |> input.bind_key(input.KeyW, Forward)
  |> input.bind_key(input.KeyS, Backward)
  |> input.bind_key(input.KeyA, Left)
  |> input.bind_key(input.KeyD, Right)
  |> input.bind_key(input.Space, Jump)
}

fn direction_from_yaw(yaw: Float) -> #(#(Float, Float), #(Float, Float)) {
  let forward_x = maths.sin(yaw)
  let forward_z = maths.cos(yaw)
  let right_x = maths.cos(yaw)
  let right_z = -1.0 *. maths.sin(yaw)

  #(#(forward_x, forward_z), #(right_x, right_z))
}

fn calculate_velocity(
  input_state: input.InputState,
  bindings: input.InputBindings(PlayerAction),
  player_move_speed: Float,
  player_velocity: Vec3(Float),
  directions: #(#(Float, Float), #(Float, Float)),
) -> Vec3(Float) {
  let #(forward_x, forward_z) = directions.0
  let #(right_x, right_z) = directions.1

  let velocity_x = case
    input.is_action_pressed(input_state, bindings, Forward),
    input.is_action_pressed(input_state, bindings, Backward)
  {
    True, False -> forward_x *. player_move_speed
    False, True -> -1.0 *. forward_x *. player_move_speed
    _, _ -> 0.0
  }

  let velocity_z = case
    input.is_action_pressed(input_state, bindings, Forward),
    input.is_action_pressed(input_state, bindings, Backward)
  {
    True, False -> forward_z *. player_move_speed
    False, True -> -1.0 *. forward_z *. player_move_speed
    _, _ -> 0.0
  }

  let velocity_x = case
    input.is_action_pressed(input_state, bindings, Left),
    input.is_action_pressed(input_state, bindings, Right)
  {
    True, False -> velocity_x +. right_x *. player_move_speed
    False, True -> velocity_x -. right_x *. player_move_speed
    _, _ -> velocity_x
  }

  let velocity_z = case
    input.is_action_pressed(input_state, bindings, Left),
    input.is_action_pressed(input_state, bindings, Right)
  {
    True, False -> velocity_z +. right_z *. player_move_speed
    False, True -> velocity_z -. right_z *. player_move_speed
    _, _ -> velocity_z
  }

  Vec3(velocity_x, player_velocity.y, velocity_z)
}

pub fn handle_input(
  player: Player,
  velocity player_velocity: Vec3(Float),
  input_state input_state: input.InputState,
  bindings bindings: input.InputBindings(PlayerAction),
  pointer_locked pointer_locked: Bool,
  camera_pitch camera_pitch: Float,
  physics_world physics_world: physics.PhysicsWorld(id),
  pointer_locked_msg pointer_locked_msg: msg,
  pointer_lock_failed_msg pointer_lock_failed_msg: msg,
) -> #(Player, Vec3(Float), Float, List(Effect(msg))) {
  let effects =
    handle_pointer_locked(
      pointer_locked,
      input_state,
      pointer_locked_msg,
      pointer_lock_failed_msg,
    )
  let Vec3(_player_pitch, player_yaw, player_roll) = player.rotation
  let #(mouse_dx, mouse_dy) = input.mouse_delta(input_state)

  // Update player yaw (horizontal rotation only)
  let player_yaw = case pointer_locked {
    True -> player_yaw -. mouse_dx *. mouse_sensitivity
    False -> player_yaw
  }

  // Update camera pitch (vertical rotation, separate from player)
  let camera_pitch = case pointer_locked {
    True -> {
      let new_pitch = camera_pitch +. mouse_dy *. mouse_sensitivity
      // Clamp pitch to prevent camera flipping (roughly -89 to 89 degrees)
      let max_pitch = maths.pi() /. 2.0 -. 0.1
      let min_pitch = -1.0 *. max_pitch
      case new_pitch {
        p if p >. max_pitch -> max_pitch
        p if p <. min_pitch -> min_pitch
        _ -> new_pitch
      }
    }
    False -> camera_pitch
  }

  let direction = direction_from_yaw(player_yaw)

  let velocity =
    calculate_velocity(
      input_state,
      bindings,
      player.speed,
      player_velocity,
      direction,
    )

  let impulse = calculate_jump(player, physics_world, input_state, bindings)

  let updated_player =
    Player(..player, rotation: Vec3(0.0, player_yaw, player_roll), velocity:)

  #(updated_player, impulse, camera_pitch, effects)
}

fn calculate_jump(
  player: Player,
  physics_world: physics.PhysicsWorld(id),
  input_state: input.InputState,
  bindings: input.InputBindings(PlayerAction),
) -> Vec3(Float) {
  let raycast_origin =
    Vec3(player.position.x, player.position.y -. 1.6, player.position.z)

  // Cast ray downward to detect ground
  let raycast_direction = Vec3(0.0, -1.0, 0.0)

  case
    physics.raycast(
      physics_world,
      origin: raycast_origin,
      direction: raycast_direction,
      max_distance: 1.0,
    ),
    input.is_action_just_pressed(input_state, bindings, Jump)
  {
    Ok(_), True -> {
      echo "JUMP! Applying impulse"
      Vec3(0.0, jumping_speed, 0.0)
    }
    _, _ -> vec3f.zero
  }
}

pub fn take_damage(player: Player, damage: Int) -> Player {
  let new_health = player.current_health - damage
  let capped_health = case new_health < 0 {
    True -> 0
    False -> new_health
  }

  echo "Player took "
    <> int.to_string(damage)
    <> " damage! Health: "
    <> int.to_string(capped_health)
    <> "/"
    <> int.to_string(player.max_health)

  Player(..player, current_health: capped_health, time_since_taking_damage: 0.0)
}

pub fn update(
  player: Player,
  nearest_enemy: Result(Enemy(id), Nil),
  delta_time: Float,
) -> #(Player, Option(spell.Projectile)) {
  let #(player, cast_result) =
    result.map(nearest_enemy, cast_spell(player, _, delta_time /. 1000.0))
    |> result.unwrap(#(player, Error(Nil)))

  let #(player, projectile) = case cast_result {
    Ok(wand.CastSuccess(projectile, remaining_mana, next_cast_index)) -> {
      let player =
        Player(
          ..player,
          wand: wand.Wand(..player.wand, current_mana: remaining_mana),
          auto_cast: AutoCast(
            time_since_last_cast: player.auto_cast.time_since_last_cast,
            current_spell_index: next_cast_index,
          ),
        )

      #(player, Some(projectile))
    }
    Ok(wand.NotEnoughMana(_required, _available)) -> {
      // Keep current index, don't reset timer - wait for more mana
      #(player, None)
    }
    Ok(wand.NoSpellToCast) -> {
      // No damage spell found, reset to beginning after recharge_time
      let player =
        Player(
          ..player,
          auto_cast: AutoCast(
            time_since_last_cast: -1.0 *. player.wand.recharge_time,
            current_spell_index: 0,
          ),
        )
      #(player, None)
    }
    Ok(wand.WandEmpty) -> {
      // Finished all spells, reset to beginning after recharge_time
      let player =
        Player(
          ..player,
          auto_cast: AutoCast(
            time_since_last_cast: -1.0 *. player.wand.recharge_time,
            current_spell_index: 0,
          ),
        )
      #(player, None)
    }
    Error(_) -> {
      #(player, None)
    }
  }

  let time_since_taking_damage =
    player.time_since_taking_damage +. delta_time /. 1000.0

  let player = Player(..player, time_since_taking_damage:)

  let player = case time_since_taking_damage >=. player.passive_heal_delay {
    True -> {
      let time_since_last_passive_heal =
        player.time_since_last_passive_heal +. delta_time /. 1000.0

      case time_since_last_passive_heal >=. player.passive_heal_interval {
        True -> passive_heal(player)
        False -> Player(..player, time_since_last_passive_heal:)
      }
    }
    False -> player
  }

  let player =
    Player(
      ..player,
      wand: wand.recharge_mana(player.wand, delta_time /. 1000.0),
    )

  #(player, projectile)
}

fn cast_spell(
  player: Player,
  nearest_enemy: Enemy(id),
  delta_time: Float,
) -> #(Player, Result(wand.CastResult, Nil)) {
  let time_since_last_cast = player.auto_cast.time_since_last_cast +. delta_time
  case time_since_last_cast >=. player.wand.cast_delay {
    True -> {
      let normalized_direction =
        Vec3(
          nearest_enemy.position.x -. player.position.x,
          nearest_enemy.position.y -. player.position.y,
          nearest_enemy.position.z -. player.position.z,
        )
        |> vec3f.normalize()

      let #(cast_result, wand) =
        wand.cast(
          player.wand,
          player.auto_cast.current_spell_index,
          player.position,
          normalized_direction,
          0,
        )

      #(
        Player(
          ..player,
          auto_cast: AutoCast(
            time_since_last_cast: 0.0,
            current_spell_index: player.auto_cast.current_spell_index,
          ),
          wand:,
        ),
        Ok(cast_result),
      )
    }
    False -> #(
      Player(
        ..player,
        auto_cast: AutoCast(
          time_since_last_cast,
          current_spell_index: player.auto_cast.current_spell_index,
        ),
      ),
      Error(Nil),
    )
  }
}

pub fn nearest_enemy_position(
  player: Player,
  enemies: List(Enemy(id)),
) -> Result(Enemy(id), Nil) {
  let nearest_enemy_position =
    list.sort(enemies, fn(enemy1, enemy2) {
      float.compare(
        vec3f.distance_squared(enemy1.position, player.position),
        vec3f.distance_squared(enemy2.position, player.position),
      )
    })
    |> list.first()
  nearest_enemy_position
}

fn passive_heal(player: Player) -> Player {
  let new_health = player.current_health + player.passive_heal_rate
  let capped_health = case new_health > player.max_health {
    True -> player.max_health
    False -> new_health
  }

  echo "Player healed "
    <> int.to_string(player.passive_heal_rate)
    <> " HP! Health: "
    <> int.to_string(capped_health)
    <> "/"
    <> int.to_string(player.max_health)

  Player(
    ..player,
    current_health: capped_health,
    time_since_last_passive_heal: 0.0,
  )
}

fn handle_pointer_locked(
  pointer_locked: Bool,
  input: input.InputState,
  pointer_locked_msg: msg,
  pointer_lock_failed_msg: msg,
) -> List(Effect(msg)) {
  let should_request_lock = case pointer_locked {
    False -> input.is_left_button_just_pressed(input)
    True -> False
  }

  let pointer_lock_effect = case should_request_lock {
    True ->
      effect.request_pointer_lock(
        on_success: pointer_locked_msg,
        on_error: pointer_lock_failed_msg,
      )
    False -> effect.none()
  }

  let exit_lock_effect = case
    input.is_key_just_pressed(input, input.Escape),
    pointer_locked
  {
    True, True -> effect.exit_pointer_lock()
    _, _ -> effect.none()
  }

  [pointer_lock_effect, exit_lock_effect]
}
