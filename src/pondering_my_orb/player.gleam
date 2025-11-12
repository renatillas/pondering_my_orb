import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam_community/maths
import pondering_my_orb/enemy.{type Enemy}
import pondering_my_orb/id
import pondering_my_orb/loot
import pondering_my_orb/perk
import pondering_my_orb/spell
import pondering_my_orb/spell_bag
import pondering_my_orb/wand
import tiramisu/effect.{type Effect}
import tiramisu/geometry
import tiramisu/input
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/spritesheet
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

const mouse_sensitivity = 0.003

const jumping_speed = 12.0

const passive_heal_delay = 6.0

const passive_heal_rate = 2.0

const passive_heal_interval = 0.5

pub type PlayerAction {
  Forward
  Backward
  Left
  Right
  Jump
}

pub type AutoCast {
  AutoCast(
    time_since_last_cast: Float,
    current_spell_index: Int,
    is_recharging: Bool,
  )
}

pub type Player {
  Player(
    jump_timeout: Float,
    // Health
    max_health: Float,
    current_health: Float,
    // Movement
    speed: Float,
    position: Vec3(Float),
    rotation: Vec3(Float),
    quaternion_rotation: transform.Quaternion,
    velocity: Vec3(Float),
    // Taking damage
    time_since_taking_damage: Float,
    // Healing
    passive_heal_delay: Float,
    passive_heal_rate: Float,
    passive_heal_interval: Float,
    time_since_last_passive_heal: Float,
    healed_amount: Float,
    // Spell casting
    wand: wand.Wand,
    spell_bag: spell_bag.SpellBag,
    auto_cast: AutoCast,
    // XP system
    current_xp: Int,
    xp_to_next_level: Int,
    level: Int,
    // Perks
    perks: List(perk.Perk),
    // Perk state tracking
    time_standing_still: Float,
    is_airborne: Bool,
    // Animation
    idle_spritesheet: Option(spritesheet.Spritesheet),
    idle_animation: Option(spritesheet.Animation),
    attacking_spritesheet: Option(spritesheet.Spritesheet),
    attacking_animation: Option(spritesheet.Animation),
    is_attacking: Bool,
    attack_animation_timer: Float,
    idle_animation_state: spritesheet.AnimationState,
    attacking_animation_state: spritesheet.AnimationState,
  )
}

pub fn new(
  health health: Float,
  speed speed: Float,
  position position: Vec3(Float),
  rotation rotation: Vec3(Float),
  time_since_taking_damage time_since_taking_damage: Float,
  passive_heal_delay passive_heal_delay: Float,
  passive_heal_rate passive_heal_rate: Float,
  passive_heal_interval passive_heal_interval: Float,
  time_since_last_passive_heal time_since_last_passive_heal: Float,
  healed_amount healed_amount: Float,
  wand wand: wand.Wand,
  spell_bag spell_bag: spell_bag.SpellBag,
  auto_cast auto_cast: AutoCast,
) -> Player {
  let quaternion_rotation = transform.euler_to_quaternion(rotation)

  Player(
    jump_timeout: 0.0,
    max_health: health,
    current_health: health,
    speed:,
    position:,
    rotation:,
    quaternion_rotation:,
    time_since_taking_damage:,
    passive_heal_delay:,
    passive_heal_rate:,
    passive_heal_interval:,
    time_since_last_passive_heal:,
    healed_amount:,
    wand:,
    spell_bag:,
    auto_cast:,
    velocity: vec3f.zero,
    current_xp: 0,
    xp_to_next_level: 100,
    level: 1,
    perks: [],
    time_standing_still: 0.0,
    is_airborne: False,
    idle_spritesheet: None,
    idle_animation: None,
    attacking_spritesheet: None,
    attacking_animation: None,
    is_attacking: False,
    attack_animation_timer: 0.0,
    idle_animation_state: spritesheet.initial_state("idle"),
    attacking_animation_state: spritesheet.initial_state("attacking"),
  )
}

pub fn view(player_id: id.Id, player: Player) {
  // Choose animation based on attacking state (timer based)
  let is_showing_attack = player.attack_animation_timer >. 0.0

  let spritesheet = case is_showing_attack {
    True -> player.attacking_spritesheet
    False -> player.idle_spritesheet
  }

  let animation = case is_showing_attack {
    True -> player.attacking_animation
    False -> player.idle_animation
  }

  let animation_state = case is_showing_attack {
    True -> player.attacking_animation_state
    False -> player.idle_animation_state
  }

  // Render sprite if we have the spritesheet loaded
  case spritesheet, animation {
    Some(sheet), Some(anim) -> {
      scene.animated_sprite(
        id: player_id,
        spritesheet: sheet,
        animation: anim,
        state: animation_state,
        width: 2.0,
        height: 2.5,
        transform: transform.at(position: player.position)
          |> transform.with_euler_rotation(player.rotation),
        pixel_art: True,
        physics: option.Some(
          physics.new_rigid_body(physics.Kinematic)
          |> physics.with_collider(physics.Capsule(
            offset: transform.identity,
            half_height: 1.0,
            radius: 0.5,
          ))
          |> physics.with_restitution(0.0)
          |> physics.with_mass(70.0)
          |> physics.with_friction(1.0)
          |> physics.with_linear_damping(0.0)
          |> physics.with_body_ccd_enabled()
          |> physics.with_lock_rotation_x()
          |> physics.with_lock_rotation_y()
          |> physics.with_lock_rotation_z()
          |> physics.with_character_controller(
            offset: 0.001,
            up_vector: Vec3(0.0, 1.0, 0.0),
            slide_enabled: True,
          )
          |> physics.build(),
        ),
      )
    }
    _, _ -> {
      // Fallback to cylinder if sprites not loaded yet
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
        id: player_id,
        geometry: capsule,
        material:,
        transform: transform.at(player.position)
          |> transform.with_euler_rotation(player.rotation),
        physics: option.Some(
          physics.new_rigid_body(physics.Kinematic)
          |> physics.with_collider(physics.Capsule(
            offset: transform.identity,
            half_height: 1.0,
            radius: 0.5,
          ))
          |> physics.with_restitution(0.0)
          |> physics.with_mass(70.0)
          |> physics.with_friction(0.0)
          |> physics.with_linear_damping(0.9)
          |> physics.with_body_ccd_enabled()
          |> physics.with_lock_rotation_x()
          |> physics.with_lock_rotation_y()
          |> physics.with_lock_rotation_z()
          |> physics.with_character_controller(
            offset: 0.001,
            up_vector: Vec3(0.0, 1.0, 0.0),
            slide_enabled: True,
          )
          |> physics.build(),
        ),
      )
    }
  }
}

pub fn init() -> Player {
  let wand = wand.new_random("Player's Wand")

  let spell_bag = spell_bag.new()

  new(
    health: 100.0,
    speed: 25.0,
    position: Vec3(0.0, 2.0, 0.0),
    rotation: Vec3(0.0, 0.0, 0.0),
    time_since_taking_damage: 0.0,
    passive_heal_delay:,
    passive_heal_rate:,
    passive_heal_interval:,
    time_since_last_passive_heal: 0.0,
    healed_amount: 0.0,
    wand:,
    spell_bag:,
    auto_cast: AutoCast(
      time_since_last_cast: 0.0,
      current_spell_index: 0,
      is_recharging: False,
    ),
  )
}

pub fn with_position(player: Player, position: Vec3(Float)) -> Player {
  Player(..player, position: position)
}

pub fn set_spritesheets(
  player: Player,
  idle_spritesheet: spritesheet.Spritesheet,
  idle_animation: spritesheet.Animation,
  attacking_spritesheet: spritesheet.Spritesheet,
  attacking_animation: spritesheet.Animation,
) -> Player {
  Player(
    ..player,
    idle_spritesheet: Some(idle_spritesheet),
    idle_animation: Some(idle_animation),
    attacking_spritesheet: Some(attacking_spritesheet),
    attacking_animation: Some(attacking_animation),
  )
}

pub fn update_animation(player: Player, delta_time: Float) -> Player {
  // Update both animations
  let idle_state = case player.idle_animation {
    Some(anim) ->
      spritesheet.update(player.idle_animation_state, anim, delta_time)
    None -> player.idle_animation_state
  }

  let attacking_state = case player.attacking_animation {
    Some(anim) ->
      spritesheet.update(player.attacking_animation_state, anim, delta_time)
    None -> player.attacking_animation_state
  }

  Player(
    ..player,
    idle_animation_state: idle_state,
    attacking_animation_state: attacking_state,
  )
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

  let forward_pressed = input.is_action_pressed(input_state, bindings, Forward)
  let backward_pressed =
    input.is_action_pressed(input_state, bindings, Backward)

  let velocity_x = case forward_pressed, backward_pressed {
    True, False -> forward_x
    False, True -> -1.0 *. forward_x
    _, _ -> 0.0
  }

  let velocity_z = case
    input.is_action_pressed(input_state, bindings, Forward),
    input.is_action_pressed(input_state, bindings, Backward)
  {
    True, False -> forward_z
    False, True -> -1.0 *. forward_z
    _, _ -> 0.0
  }

  let velocity_x = case
    input.is_action_pressed(input_state, bindings, Left),
    input.is_action_pressed(input_state, bindings, Right)
  {
    True, False -> velocity_x +. right_x
    False, True -> velocity_x -. right_x
    _, _ -> velocity_x
  }

  let velocity_z = case
    input.is_action_pressed(input_state, bindings, Left),
    input.is_action_pressed(input_state, bindings, Right)
  {
    True, False -> velocity_z +. right_z
    False, True -> velocity_z -. right_z
    _, _ -> velocity_z
  }

  Vec3(velocity_x, 0.0, velocity_z)
  |> vec3f.normalize()
  |> vec3f.scale(by: player_move_speed)
  |> vec3.replace_y(player_velocity.y)
}

pub fn handle_input(
  player: Player,
  velocity player_velocity: Vec3(Float),
  input_state input_state: input.InputState,
  bindings bindings: input.InputBindings(PlayerAction),
  pointer_locked pointer_locked: Bool,
  camera_pitch camera_pitch: Float,
  physics_world physics_world: physics.PhysicsWorld(id.Id),
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

  let #(player, impulse, _is_airborne) =
    calculate_jump(player, physics_world, input_state, bindings)

  // Track time standing still for IdleJuice perk
  let is_moving = velocity.x != 0.0 || velocity.z != 0.0
  let time_standing_still = case is_moving {
    True -> 0.0
    False -> player.time_standing_still
  }

  let new_rotation = Vec3(0.0, player_yaw, player_roll)
  let quaternion_rotation = transform.euler_to_quaternion(new_rotation)

  let updated_player =
    Player(
      ..player,
      rotation: new_rotation,
      quaternion_rotation:,
      velocity:,
      time_standing_still:,
    )

  #(updated_player, impulse, camera_pitch, effects)
}

fn calculate_jump(
  player: Player,
  _physics_world: physics.PhysicsWorld(id.Id),
  input_state: input.InputState,
  bindings: input.InputBindings(PlayerAction),
) -> #(Player, Vec3(Float), Bool) {
  // Use stored is_airborne from game state (updated from physics after compute_character_movement)
  let on_ground = !player.is_airborne

  // Use just_pressed for jump - more responsive for platformers
  let jump_just_pressed =
    input.is_action_just_pressed(input_state, bindings, Jump)

  // Allow jumping if just pressed (no need to hold)
  case on_ground, jump_just_pressed, player.jump_timeout <=. 0.0 {
    True, True, True -> {
      // Note: is_airborne will be updated from physics in game loop after this
      #(
        Player(..player, jump_timeout: 0.1),
        Vec3(0.0, jumping_speed, 0.0),
        True,
      )
    }
    _, _, _ -> {
      // is_airborne will be updated from physics in game loop
      #(player, vec3f.zero, player.is_airborne)
    }
  }
}

/// Take damage with perk modifications
/// Returns tuple of (updated_player, reflected_damage)
pub fn take_damage(player: Player, damage: Float) -> #(Player, Float) {
  // Apply damage taken modifiers from perks
  let #(modified_damage, reflected_damage) =
    list.fold(player.perks, #(damage, 0.0), fn(acc, perk_value) {
      let #(current_damage, current_reflect) = acc
      case perk_value {
        // Glass Cannon: take more damage
        perk.GlassCannon(_damage_mult, damage_taken_mult) -> #(
          current_damage *. damage_taken_mult,
          current_reflect,
        )
        // Mirror: reflect damage
        _ -> acc
      }
    })

  let new_health = player.current_health -. modified_damage

  // Check if Za Warudo should activate (prevent lethal damage once)
  let #(final_health, updated_perks) = case new_health <=. 0.0 {
    True -> {
      // Check if player has Za Warudo
      let has_za_warudo =
        list.any(player.perks, fn(p) {
          case p {
            perk.OneLife -> True
            _ -> False
          }
        })

      case has_za_warudo {
        True -> {
          // Remove Za Warudo from perks and survive with 1 HP
          let remaining_perks =
            list.filter(player.perks, fn(p) {
              case p {
                perk.OneLife -> False
                _ -> True
              }
            })
          #(1.0, remaining_perks)
        }
        False -> #(0.0, player.perks)
      }
    }
    False -> #(new_health, player.perks)
  }

  #(
    Player(
      ..player,
      current_health: final_health,
      time_since_taking_damage: 0.0,
      perks: updated_perks,
    ),
    reflected_damage,
  )
}

/// Apply on-kill effects (BloodThirst, etc.)
pub fn on_enemy_killed(player: Player) -> Player {
  let heal_amount =
    list.fold(player.perks, 0.0, fn(acc, perk_value) {
      case perk_value {
        _ -> acc
      }
    })

  case heal_amount >. 0.0 {
    True -> {
      let new_health =
        float.min(player.max_health, player.current_health +. heal_amount)
      Player(..player, current_health: new_health)
    }
    False -> player
  }
}

/// Calculate effective cast delay with TurboSkates bonus
pub fn get_effective_cast_delay(player: Player) -> Float {
  let base_delay = player.wand.cast_delay

  // Apply TurboSkates: movement speed reduces cast delay
  let cast_speed_bonus =
    list.fold(player.perks, 0.0, fn(acc, perk_value) {
      case perk_value {
        _ -> acc
      }
    })

  // Cast speed bonus reduces the delay (higher bonus = lower delay)
  // Bonus of 0.5 (50%) means delay is multiplied by 0.5
  let multiplier = 1.0 /. { 1.0 +. cast_speed_bonus }
  base_delay *. multiplier
}

pub fn update(
  player: Player,
  nearest_enemy: Result(Enemy(id), Nil),
  delta_time: Float,
  player_died_msg: msg,
  next_projectile_id: Int,
  existing_projectiles: List(spell.Projectile),
) -> #(Player, List(spell.Projectile), List(Int), Effect(msg), Int) {
  // Update timer every frame
  let updated_time_since_last_cast =
    player.auto_cast.time_since_last_cast +. delta_time /. 1000.0

  // Clear recharging flag when reload completes
  let effective_cast_delay = get_effective_cast_delay(player)
  let is_reload_complete =
    player.auto_cast.is_recharging
    && updated_time_since_last_cast >=. effective_cast_delay

  let updated_recharging = case is_reload_complete {
    True -> False
    False -> player.auto_cast.is_recharging
  }

  let player_with_updated_timer =
    Player(
      ..player,
      auto_cast: AutoCast(
        ..player.auto_cast,
        time_since_last_cast: updated_time_since_last_cast,
        is_recharging: updated_recharging,
      ),
    )

  let #(player, cast_result, next_projectile_id) =
    result.map(nearest_enemy, cast_spell(
      player_with_updated_timer,
      _,
      delta_time /. 1000.0,
      next_projectile_id,
      existing_projectiles,
    ))
    |> result.unwrap(#(
      player_with_updated_timer,
      Error(Nil),
      next_projectile_id,
    ))

  let #(player, projectiles, casting_indices, is_attacking) = case cast_result {
    Ok(wand.CastSuccess(
      projectiles:,
      remaining_mana:,
      next_cast_index:,
      casting_indices:,
      did_wrap:,
      total_cast_delay_addition:,
      total_recharge_time_addition:,
    )) -> {
      // Determine timing based on whether wand wrapped
      let #(timer, index, recharging) = case did_wrap {
        True -> {
          // Wand wrapped: enter reload, reset to slot 0
          // Total reload time is the max of (cast_delay + spell delays) or (recharge_time + spell recharge additions)
          let total_reload_time =
            float.max(
              player.wand.cast_delay +. total_cast_delay_addition,
              player.wand.recharge_time +. total_recharge_time_addition,
            )
          // Timer needs to count from negative value up to cast_delay
          // to achieve the total reload time
          #(player.wand.cast_delay -. total_reload_time, 0, True)
        }
        False -> {
          // Normal cast: apply cast delay (base + additions from spells), continue to next spell
          // Timer counts up to cast_delay, so we start at a negative value
          // to achieve total delay of (cast_delay + spell delays)
          let total_delay = player.wand.cast_delay +. total_cast_delay_addition
          #(player.wand.cast_delay -. total_delay, next_cast_index, False)
        }
      }

      let updated_player =
        Player(
          ..player,
          wand: wand.Wand(..player.wand, current_mana: remaining_mana),
          auto_cast: AutoCast(
            time_since_last_cast: timer,
            current_spell_index: index,
            is_recharging: recharging,
          ),
          attack_animation_timer: 400.0,
        )

      #(updated_player, projectiles, casting_indices, True)
    }
    Ok(wand.NotEnoughMana(_required, _available)) -> {
      // Wait for mana to recharge
      #(player, [], [], False)
    }
    Ok(wand.NoSpellToCast) | Ok(wand.WandEmpty) -> {
      // No spells available: enter reload
      let max_delay =
        float.max(player.wand.cast_delay, player.wand.recharge_time)
      let player =
        Player(
          ..player,
          auto_cast: AutoCast(
            time_since_last_cast: player.wand.cast_delay -. max_delay,
            current_spell_index: 0,
            is_recharging: True,
          ),
        )
      #(player, [], [], False)
    }
    Error(_) -> {
      #(player, [], [], False)
    }
  }

  let time_since_taking_damage =
    player.time_since_taking_damage +. delta_time /. 1000.0

  let jump_timeout = case player.jump_timeout >. 0.0 {
    True -> player.jump_timeout -. delta_time /. 1000.0
    False -> 0.0
  }

  // Increment time standing still (will be reset in handle_input if moving)
  let time_standing_still = player.time_standing_still +. delta_time /. 1000.0

  let player =
    Player(
      ..player,
      time_since_taking_damage:,
      jump_timeout:,
      time_standing_still:,
    )

  let player = case time_since_taking_damage >=. player.passive_heal_delay {
    True -> {
      let time_since_last_passive_heal =
        player.time_since_last_passive_heal +. delta_time /. 1000.0

      case time_since_last_passive_heal >=. player.passive_heal_interval {
        True -> passive_heal(player, delta_time)
        False -> Player(..player, time_since_last_passive_heal:)
      }
    }
    False -> player
  }

  // Update animations
  let idle_state = case player.idle_animation {
    Some(anim) ->
      spritesheet.update(player.idle_animation_state, anim, delta_time)
    None -> player.idle_animation_state
  }

  let attacking_state = case player.attacking_animation {
    Some(anim) ->
      spritesheet.update(player.attacking_animation_state, anim, delta_time)
    None -> player.attacking_animation_state
  }

  // Decay attack animation timer
  let attack_timer = float.max(0.0, player.attack_animation_timer -. delta_time)

  let player =
    Player(
      ..player,
      wand: wand.recharge_mana(player.wand, delta_time /. 1000.0),
      is_attacking:,
      attack_animation_timer: attack_timer,
      idle_animation_state: idle_state,
      attacking_animation_state: attacking_state,
    )

  let death_effect = case player.current_health <=. 0.0 {
    True -> effect.from(fn(dispatch) { dispatch(player_died_msg) })
    False -> effect.none()
  }

  #(player, projectiles, casting_indices, death_effect, next_projectile_id)
}

fn cast_spell(
  player: Player,
  nearest_enemy: Enemy(id),
  _delta_time: Float,
  next_projectile_id: Int,
  existing_projectiles: List(spell.Projectile),
) -> #(Player, Result(wand.CastResult, Nil), Int) {
  // Timer is already updated in update() function, just check it here
  let time_since_last_cast = player.auto_cast.time_since_last_cast
  let effective_cast_delay = get_effective_cast_delay(player)
  case time_since_last_cast >=. effective_cast_delay {
    True -> {
      let normalized_direction =
        Vec3(
          nearest_enemy.position.x -. player.position.x,
          nearest_enemy.position.y -. player.position.y,
          nearest_enemy.position.z -. player.position.z,
        )
        |> vec3f.normalize()

      // Spawn projectile in front of player with a forward offset
      let spawn_offset = 1.5
      let spawn_position =
        Vec3(
          player.position.x +. normalized_direction.x *. spawn_offset,
          player.position.y +. normalized_direction.y *. spawn_offset,
          player.position.z +. normalized_direction.z *. spawn_offset,
        )

      let #(cast_result, wand) =
        wand.cast(
          player.wand,
          player.auto_cast.current_spell_index,
          spawn_position,
          normalized_direction,
          next_projectile_id,
          option.Some(nearest_enemy.position),
          option.Some(player.position),
          existing_projectiles,
        )

      // Increment projectile ID based on number of projectiles created
      let projectile_count = case cast_result {
        wand.CastSuccess(projectiles:, ..) -> list.length(projectiles)
        _ -> 0
      }
      let new_projectile_id = next_projectile_id + projectile_count

      #(
        Player(
          ..player,
          auto_cast: AutoCast(
            time_since_last_cast: 0.0,
            current_spell_index: player.auto_cast.current_spell_index,
            is_recharging: player.auto_cast.is_recharging,
          ),
          wand:,
        ),
        Ok(cast_result),
        new_projectile_id,
      )
    }
    False -> #(player, Error(Nil), next_projectile_id)
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

fn passive_heal(player: Player, delta_time: Float) -> Player {
  let heal_amount = player.passive_heal_rate *. delta_time /. 1000.0
  let new_healed_amount = player.healed_amount +. heal_amount
  let new_health = player.current_health +. heal_amount

  case new_healed_amount >=. player.passive_heal_rate {
    True -> {
      Player(..player, healed_amount: 0.0, time_since_last_passive_heal: 0.0)
    }
    False ->
      Player(
        ..player,
        healed_amount: new_healed_amount,
        current_health: float.min(player.max_health, new_health),
      )
  }
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

/// Add XP to the player and handle leveling up
/// Returns a tuple of (updated_player, leveled_up)
pub fn add_xp(player: Player, xp: Int) -> #(Player, Bool) {
  let new_xp = player.current_xp + xp

  case new_xp >= player.xp_to_next_level {
    True -> {
      // Level up!
      let remaining_xp = new_xp - player.xp_to_next_level
      let new_level = player.level + 1
      let new_xp_to_next_level = player.xp_to_next_level + 50

      #(
        Player(
          ..player,
          current_xp: remaining_xp,
          xp_to_next_level: new_xp_to_next_level,
          level: new_level,
        ),
        True,
      )
    }
    False -> #(Player(..player, current_xp: new_xp), False)
  }
}

/// Try to pick up loot drops near the player
/// Returns updated player and list of picked up loot IDs
pub fn pickup_loot(
  player: Player,
  loot_drops: List(loot.LootDrop),
  pickup_range: Float,
) -> #(Player, List(id.Id)) {
  list.fold(loot_drops, #(player, []), fn(acc, loot_drop) {
    let #(current_player, picked_up) = acc

    case loot.can_pickup(loot_drop, current_player.position, pickup_range) {
      True -> {
        let updated_player = apply_loot(current_player, loot_drop.loot_type)
        #(updated_player, [loot_drop.id, ..picked_up])
      }
      False -> acc
    }
  })
}

/// Apply loot to player
fn apply_loot(player: Player, loot_type: loot.LootType) -> Player {
  case loot_type {
    loot.WandLoot(new_wand) -> {
      // Replace current wand
      Player(..player, wand: new_wand)
    }
    loot.PerkLoot(perk_value) -> {
      // Apply perk to player
      apply_perk(player, perk_value)
    }
  }
}

/// Apply all damage-modifying perks
/// Returns tuple of (final_damage, is_critical, self_damage, heal_amount)
/// enemy_hp_percent is optional - only used for Execute perk
pub fn apply_damage_perks(
  player: Player,
  base_damage: Float,
  enemy_hp_percent: option.Option(Float),
) -> #(Float, Bool, Float, Float) {
  let #(damage, is_crit, self_damage, heal_amount) =
    list.fold(
      player.perks,
      #(base_damage, False, 0.0, 0.0),
      fn(acc, perk_value) {
        let #(current_damage, already_crit, current_self_damage, current_heal) =
          acc

        case perk_value {
          // Big Bonk: chance for massive crit
          perk.BigBonk(crit_chance, crit_multiplier) -> {
            let roll = float.random()
            case roll <. crit_chance {
              True -> #(
                current_damage *. crit_multiplier,
                True,
                current_self_damage,
                current_heal,
              )
              False -> acc
            }
          }

          // Idle Juice: more damage while standing still
          perk.Trance(max_bonus, time_to_max) -> {
            let idle_progress =
              float.min(1.0, player.time_standing_still /. time_to_max)
            let bonus_multiplier = 1.0 +. max_bonus *. idle_progress
            #(
              current_damage *. bonus_multiplier,
              already_crit,
              current_self_damage,
              current_heal,
            )
          }

          // Berserker's Rage: more damage based on missing HP
          perk.BerserkersRage(max_bonus) -> {
            let missing_hp = 1.0 -. player.current_health /. player.max_health
            let bonus_multiplier = 1.0 +. max_bonus *. missing_hp
            #(
              current_damage *. bonus_multiplier,
              already_crit,
              current_self_damage,
              current_heal,
            )
          }

          // Execute: bonus damage to low HP enemies
          perk.Execute(threshold, multiplier) -> {
            case enemy_hp_percent {
              option.Some(hp_percent) if hp_percent <. threshold -> #(
                current_damage *. multiplier,
                already_crit,
                current_self_damage,
                current_heal,
              )
              _ -> acc
            }
          }

          // Glass Cannon: more damage, more damage taken
          perk.GlassCannon(damage_mult, _damage_taken_mult) -> {
            #(
              current_damage *. damage_mult,
              already_crit,
              current_self_damage,
              current_heal,
            )
          }

          _ -> acc
        }
      },
    )

  #(damage, is_crit, self_damage, heal_amount)
}

/// Check if Big Bonk should trigger and return modified damage and whether it crit
/// Returns tuple of (final_damage, is_critical)
/// DEPRECATED: Use apply_damage_perks instead
pub fn apply_big_bonk(player: Player, base_damage: Float) -> #(Float, Bool) {
  let #(damage, is_crit, _self_damage, _heal) =
    apply_damage_perks(player, base_damage, option.None)
  #(damage, is_crit)
}

/// Apply a perk to the player
pub fn apply_perk(player: Player, perk_value: perk.Perk) -> Player {
  case perk_value {
    // Perks that affect max HP immediately
    perk.GlassCannon(_damage_mult, _damage_taken_mult) -> {
      // Note: damage_mult is stored in perks list for damage calculation
      // damage_taken_mult will be applied when taking damage
      Player(..player, perks: [perk_value, ..player.perks])
    }

    // Passive perks stored in perks list and applied during damage calculation or other events
    perk.BigBonk(..)
    | perk.Trance(..)
    | perk.BerserkersRage(_)
    | perk.OneLife
    | perk.Execute(..) -> Player(..player, perks: [perk_value, ..player.perks])
  }
}
