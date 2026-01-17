import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/otp/factory_supervisor
import gleam/time/duration.{type Duration}
import logging
import vec/vec3.{type Vec3}
import vec/vec3f

import server/wand as wand_actor
import shared/player
import shared/projectile
import shared/spell
import shared/wand

// =============================================================================
// TYPES
// =============================================================================

/// Messages sent TO the player actor
pub type Msg {
  /// Tick for movement and forwarding to wands
  Tick(delta_time: Duration)
  /// WASD movement input
  Move(w: Bool, a: Bool, s: Bool, d: Bool)
  /// Switch active wand
  SwitchWand(slot: Int)
  /// Cast spell at target using active wand
  CastSpell(target: Vec3(Float))
  /// Message from WandActor
  WandMessage(slot: Int, msg: wand_actor.ToPlayerMsg)
}

/// Messages sent FROM player actor back to the room
pub type ToRoomMsg {
  /// Notify that projectile should be spawned
  SpawnProjectile(projectile: projectile.Projectile, player_id: player.Id)
  /// Notify that player state changed
  StateChanged(player_id: player.Id, state: PlayerState)
}

/// Server-side player state - for networking to clients
pub type PlayerState {
  PlayerState(
    /// Core player data (networked to clients)
    player: player.Player,
    /// Wand inventory (networked to clients, updated from WandActors)
    wands: player.WandInventory,
  )
}

/// Player actor state
type State(room_msg) {
  State(
    player_state: PlayerState,
    /// WandActor subjects (one per slot)
    wand_actors: #(
      option.Option(Subject(wand_actor.Msg)),
      option.Option(Subject(wand_actor.Msg)),
      option.Option(Subject(wand_actor.Msg)),
      option.Option(Subject(wand_actor.Msg)),
    ),
    room: Subject(room_msg),
    to_room: fn(ToRoomMsg) -> room_msg,
    wand_factory: factory_supervisor.Supervisor(
      wand_actor.SpawnArguments(Msg),
      Subject(wand_actor.Msg),
    ),
    self: Subject(Msg),
  )
}

// =============================================================================
// ACTOR LIFECYCLE
// =============================================================================

pub type SpawnArguments(room_msg) {
  SpawnArguments(
    player_id: player.Id,
    player_name: String,
    initial_position: Vec3(Float),
    room: Subject(room_msg),
    to_room: fn(ToRoomMsg) -> room_msg,
    wand_factory: factory_supervisor.Supervisor(
      wand_actor.SpawnArguments(Msg),
      Subject(wand_actor.Msg),
    ),
  )
}

/// Start a new player actor
pub fn start(
  spawn_arguments: SpawnArguments(room_msg),
) -> Result(actor.Started(Subject(Msg)), actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    // Create initial player state
    let player_state =
      PlayerState(
        player: player.new(
          spawn_arguments.player_id,
          spawn_arguments.player_name,
          spawn_arguments.initial_position,
        ),
        wands: player.WandInventory(
          slot_0: option.None,
          slot_1: option.None,
          slot_2: option.None,
          slot_3: option.None,
        ),
      )

    // Create wand tagger for slot 0

    // Spawn starter wand in slot 0
    let starter_wand = wand_actor.create_starter_wand()
    let wand_spawn_args =
      wand_actor.SpawnArguments(
        wand: starter_wand,
        player: self,
        to_player: WandMessage(0, _),
      )

    let wand_0 = case
      factory_supervisor.start_child(
        spawn_arguments.wand_factory,
        wand_spawn_args,
      )
    {
      Ok(started) -> option.Some(started.data)
      Error(_) -> panic as "Failed to spawn starter wand actor"
    }

    // Update player state with starter wand
    let player_state = case wand_0 {
      option.Some(_) ->
        PlayerState(
          ..player_state,
          wands: player.WandInventory(
            slot_0: option.Some(starter_wand),
            slot_1: option.None,
            slot_2: option.None,
            slot_3: option.None,
          ),
        )
      option.None -> player_state
    }

    let state =
      State(
        player_state: player_state,
        wand_actors: #(wand_0, option.None, option.None, option.None),
        room: spawn_arguments.room,
        to_room: spawn_arguments.to_room,
        wand_factory: spawn_arguments.wand_factory,
        self: self,
      )

    actor.initialised(state)
    |> actor.returning(self)
    |> Ok
  })
  |> actor.on_message(handle_message)
  |> actor.start
}

// =============================================================================
// MESSAGE HANDLING
// =============================================================================

fn handle_message(
  state: State(room_msg),
  msg: Msg,
) -> actor.Next(State(room_msg), Msg) {
  case msg {
    Tick(delta_time) -> handle_tick(state, delta_time)
    Move(w, a, s, d) -> handle_move(state, w, a, s, d)
    SwitchWand(slot) -> handle_switch_wand(state, slot)
    CastSpell(target) -> handle_cast_spell(state, target)
    WandMessage(slot:, msg:) -> handle_wand_message(state, slot, msg)
  }
}

fn handle_tick(
  state: State(room_msg),
  delta_time: Duration,
) -> actor.Next(State(room_msg), Msg) {
  // 1. Update player movement
  let player_with_movement =
    update_movement(state.player_state.player, delta_time)

  // 2. Forward tick to all wand actors (they will respond with WandStateChanged)
  case state.wand_actors.0 {
    option.Some(wand) -> process.send(wand, wand_actor.Tick(delta_time))
    option.None -> Nil
  }
  case state.wand_actors.1 {
    option.Some(wand) -> process.send(wand, wand_actor.Tick(delta_time))
    option.None -> Nil
  }
  case state.wand_actors.2 {
    option.Some(wand) -> process.send(wand, wand_actor.Tick(delta_time))
    option.None -> Nil
  }
  case state.wand_actors.3 {
    option.Some(wand) -> process.send(wand, wand_actor.Tick(delta_time))
    option.None -> Nil
  }

  // 3. Notify room of state change (wand states will be updated via WandMessage)
  let new_player_state =
    PlayerState(..state.player_state, player: player_with_movement)
  process.send(
    state.room,
    state.to_room(StateChanged(new_player_state.player.id, new_player_state)),
  )

  let new_state = State(..state, player_state: new_player_state)
  actor.continue(new_state)
}

fn handle_move(
  state: State(room_msg),
  w: Bool,
  a: Bool,
  s: Bool,
  d: Bool,
) -> actor.Next(State(room_msg), Msg) {
  // Convert WASD to forward/right components
  let forward = case w, s {
    True, False -> 1.0
    False, True -> -1.0
    _, _ -> 0.0
  }

  let right = case d, a {
    True, False -> 1.0
    False, True -> -1.0
    _, _ -> 0.0
  }

  // Isometric camera transformation:
  // Camera is positioned at (+X, +Y, +Z) looking toward origin
  // Forward (W) = move away from camera = (-X, -Z) direction  
  // Right (D) = move right on screen = (+X, -Z) direction
  // Both at 45° angles, so we use 1/sqrt(2) = 0.7071
  let camera_angle = 0.7071067811865476

  // Transform camera-space input to world-space direction
  let direction_x = camera_angle *. { right -. forward }
  let direction_z = 0.0 -. camera_angle *. { forward +. right }
  let direction = vec3.Vec3(direction_x, 0.0, direction_z)

  // Normalize diagonal movement (so moving diagonally isn't faster)
  let magnitude = vec3f.length(direction)
  let velocity = case magnitude >. 0.0 {
    True -> {
      let normalized = vec3f.scale(direction, by: 1.0 /. magnitude)
      vec3f.scale(normalized, by: state.player_state.player.speed)
    }
    False -> vec3.Vec3(0.0, 0.0, 0.0)
  }

  // Update player velocity (server-authoritative)
  let new_player_state =
    PlayerState(
      ..state.player_state,
      player: player.Player(..state.player_state.player, velocity: velocity),
    )

  let new_state = State(..state, player_state: new_player_state)
  actor.continue(new_state)
}

fn handle_switch_wand(
  state: State(room_msg),
  slot: Int,
) -> actor.Next(State(room_msg), Msg) {
  // Validate slot range (0-3)
  case slot >= 0 && slot < 4 {
    True -> {
      let new_player_state =
        PlayerState(
          ..state.player_state,
          player: player.Player(
            ..state.player_state.player,
            active_wand_slot: slot,
          ),
        )
      let new_state = State(..state, player_state: new_player_state)
      actor.continue(new_state)
    }
    False -> {
      logging.log(logging.Warning, "Invalid wand slot: " <> int.to_string(slot))
      actor.continue(state)
    }
  }
}

fn handle_cast_spell(
  state: State(room_msg),
  target: Vec3(Float),
) -> actor.Next(State(room_msg), Msg) {
  // Get active wand actor
  let active_slot = state.player_state.player.active_wand_slot
  let active_wand_actor = case active_slot {
    0 -> state.wand_actors.0
    1 -> state.wand_actors.1
    2 -> state.wand_actors.2
    3 -> state.wand_actors.3
    _ -> option.None
  }

  case active_wand_actor {
    option.None -> {
      logging.log(logging.Debug, "No wand equipped in active slot")
      actor.continue(state)
    }

    option.Some(wand_actor_subject) -> {
      // Calculate direction from player position to target
      let player_pos = state.player_state.player.position
      let direction = vec3f.direction(player_pos, to: target)

      // Send Cast message to wand actor
      process.send(
        wand_actor_subject,
        wand_actor.Cast(
          player_pos: player_pos,
          direction: direction,
          target: option.Some(target),
        ),
      )

      actor.continue(state)
    }
  }
}

fn handle_wand_message(
  state: State(room_msg),
  slot: Int,
  msg: wand_actor.ToPlayerMsg,
) -> actor.Next(State(room_msg), Msg) {
  case msg {
    wand_actor.WandStateChanged(wand:, cooldown: _) -> {
      // Update wand in player state for networking
      let new_wands = set_wand_at_slot(state.player_state.wands, slot, wand)
      let new_player_state = PlayerState(..state.player_state, wands: new_wands)
      let new_state = State(..state, player_state: new_player_state)
      actor.continue(new_state)
    }

    wand_actor.ProjectilesSpawned(projectiles:) -> {
      // Convert spell.Projectile to shared/projectile.Projectile and send to room
      list.each(projectiles, fn(spell_proj: spell.Projectile) {
        let proj =
          projectile.Projectile(
            id: projectile.Id(spell_proj.id),
            owner_id: state.player_state.player.id,
            spell: spell_proj.spell,
            position: spell_proj.position,
            velocity: vec3f.scale(
              spell_proj.direction,
              by: spell_proj.spell.final_speed,
            ),
            time_alive: spell_proj.time_alive,
            visuals: spell_proj.visuals,
            trigger_payload: spell_proj.trigger_payload,
          )

        process.send(
          state.room,
          state.to_room(SpawnProjectile(proj, state.player_state.player.id)),
        )
      })

      actor.continue(state)
    }

    wand_actor.CastFailed(_reason) -> {
      // Just log for now, could send feedback to client later
      actor.continue(state)
    }
  }
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Set wand at a specific slot (0-3)
fn set_wand_at_slot(
  wands: player.WandInventory,
  slot: Int,
  wand_value: wand.Wand,
) -> player.WandInventory {
  case slot {
    0 ->
      player.WandInventory(
        slot_0: option.Some(wand_value),
        slot_1: wands.slot_1,
        slot_2: wands.slot_2,
        slot_3: wands.slot_3,
      )
    1 ->
      player.WandInventory(
        slot_0: wands.slot_0,
        slot_1: option.Some(wand_value),
        slot_2: wands.slot_2,
        slot_3: wands.slot_3,
      )
    2 ->
      player.WandInventory(
        slot_0: wands.slot_0,
        slot_1: wands.slot_1,
        slot_2: option.Some(wand_value),
        slot_3: wands.slot_3,
      )
    3 ->
      player.WandInventory(
        slot_0: wands.slot_0,
        slot_1: wands.slot_1,
        slot_2: wands.slot_2,
        slot_3: option.Some(wand_value),
      )
    _ -> wands
  }
}

/// Update player movement based on movement_state
fn update_movement(p: player.Player, delta_time: Duration) -> player.Player {
  let dt_seconds = duration.to_seconds(delta_time)

  // Apply velocity to position (velocity is set by handle_move)
  let movement = vec3f.scale(p.velocity, by: dt_seconds)
  let new_position = vec3f.add(p.position, movement)

  player.Player(..p, position: new_position)
}

/// Convert PlayerState to shared/player.Player for network transmission
pub fn to_shared_player(state: PlayerState) -> player.Player {
  state.player
}
