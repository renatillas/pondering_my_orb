/// WandActor - manages individual wand state using OTP actor pattern
import gleam/erlang/process.{type Subject}
import gleam/float
import gleam/option
import gleam/otp/actor
import gleam/time/duration.{type Duration}
import logging
import vec/vec3.{type Vec3}

import shared/spell
import shared/wand

// =============================================================================
// TYPES
// =============================================================================

/// Wand cooldown state (server-only)
pub type WandCooldown {
  WandCooldown(
    /// Time remaining for cast delay
    cast_delay_remaining: Duration,
    /// Time remaining for recharge delay
    recharge_delay_remaining: Duration,
    /// Index where the next cast will start
    next_cast_index: Int,
  )
}

/// Messages sent TO the wand actor
pub type Msg {
  /// Tick for mana regeneration and cooldown updates
  Tick(delta_time: Duration)
  /// Cast spell at target position with given direction
  Cast(
    player_pos: Vec3(Float),
    direction: Vec3(Float),
    target: option.Option(Vec3(Float)),
  )
}

/// Messages sent FROM wand actor back to the player
pub type ToPlayerMsg {
  /// Wand state changed (mana, cooldowns updated)
  WandStateChanged(wand: wand.Wand, cooldown: WandCooldown)
  /// Projectiles spawned from casting
  ProjectilesSpawned(projectiles: List(spell.Projectile))
  /// Cast failed (not enough mana, on cooldown, etc.)
  CastFailed(reason: CastFailureReason)
}

pub type CastFailureReason {
  WandEmpty
  NoSpellToCast
  NotEnoughMana(required: Float, available: Float)
  OnCooldown
}

/// Wand actor state
type State(player_msg) {
  State(
    wand: wand.Wand,
    cooldown: WandCooldown,
    player: Subject(player_msg),
    to_player: fn(ToPlayerMsg) -> player_msg,
  )
}

// =============================================================================
// ACTOR LIFECYCLE
// =============================================================================

pub type SpawnArguments(player_msg) {
  SpawnArguments(
    wand: wand.Wand,
    player: Subject(player_msg),
    to_player: fn(ToPlayerMsg) -> player_msg,
  )
}

/// Start a new wand actor
pub fn start(
  spawn_arguments: SpawnArguments(player_msg),
) -> Result(actor.Started(Subject(Msg)), actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    let empty_cooldown =
      WandCooldown(
        cast_delay_remaining: duration.milliseconds(0),
        recharge_delay_remaining: duration.milliseconds(0),
        next_cast_index: 0,
      )

    let state =
      State(
        wand: spawn_arguments.wand,
        cooldown: empty_cooldown,
        player: spawn_arguments.player,
        to_player: spawn_arguments.to_player,
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
  state: State(player_msg),
  msg: Msg,
) -> actor.Next(State(player_msg), Msg) {
  case msg {
    Tick(delta_time) -> handle_tick(state, delta_time)
    Cast(player_pos:, direction:, target:) ->
      handle_cast(state, player_pos, direction, target)
  }
}

fn handle_tick(
  state: State(player_msg),
  delta_time: Duration,
) -> actor.Next(State(player_msg), Msg) {
  // 1. Recharge mana
  let wand_recharged = wand.recharge_mana(state.wand, delta_time)

  // 2. Decrement cooldowns
  let cooldown_updated = decrement_cooldown(state.cooldown, delta_time)

  // 3. Notify player of state change
  process.send(
    state.player,
    state.to_player(WandStateChanged(wand_recharged, cooldown_updated)),
  )

  let new_state =
    State(..state, wand: wand_recharged, cooldown: cooldown_updated)
  actor.continue(new_state)
}

fn handle_cast(
  state: State(player_msg),
  player_pos: Vec3(Float),
  direction: Vec3(Float),
  target: option.Option(Vec3(Float)),
) -> actor.Next(State(player_msg), Msg) {
  // 1. Check if wand is on cooldown
  let is_cooling_down =
    duration.to_seconds(state.cooldown.cast_delay_remaining) >. 0.0
    || duration.to_seconds(state.cooldown.recharge_delay_remaining) >. 0.0

  case is_cooling_down {
    True -> {
      logging.log(logging.Debug, "Wand is on cooldown")
      process.send(state.player, state.to_player(CastFailed(OnCooldown)))
      actor.continue(state)
    }

    False -> {
      // 2. Cast the spell
      let #(cast_result, updated_wand) =
        wand.cast(
          state.wand,
          state.cooldown.next_cast_index,
          player_pos,
          direction,
          0,
          // projectile_starting_index - will be managed by room
          target,
          option.Some(player_pos),
          [],
          // existing_projectiles - empty for now
        )

      // 3. Handle cast result
      handle_cast_result(state, cast_result, updated_wand)
    }
  }
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Handle the result of a wand cast operation
fn handle_cast_result(
  state: State(player_msg),
  cast_result: wand.CastResult,
  updated_wand: wand.Wand,
) -> actor.Next(State(player_msg), Msg) {
  case cast_result {
    wand.WandEmpty -> {
      logging.log(logging.Debug, "Wand is empty")
      process.send(state.player, state.to_player(CastFailed(WandEmpty)))
      actor.continue(state)
    }

    wand.NoSpellToCast -> {
      logging.log(logging.Debug, "No spell to cast (all modifiers)")
      process.send(state.player, state.to_player(CastFailed(NoSpellToCast)))
      actor.continue(state)
    }

    wand.NotEnoughMana(required:, available:) -> {
      logging.log(
        logging.Debug,
        "Not enough mana. Required: "
          <> float.to_string(required)
          <> ", Available: "
          <> float.to_string(available),
      )
      process.send(
        state.player,
        state.to_player(CastFailed(NotEnoughMana(required, available))),
      )
      actor.continue(state)
    }

    wand.CastSuccess(
      projectiles:,
      remaining_mana: _,
      next_cast_index:,
      casting_indices: _,
      did_wrap:,
      total_cast_delay_addition:,
      total_recharge_time_addition:,
    ) -> {
      // Calculate final cooldowns
      let final_cast_delay =
        duration.add(updated_wand.cast_delay, total_cast_delay_addition)
      let final_cooldown = case did_wrap {
        True ->
          duration.add(
            final_cast_delay,
            duration.add(
              updated_wand.recharge_time,
              total_recharge_time_addition,
            ),
          )
        False -> final_cast_delay
      }

      // Update cooldown state
      let new_cooldown =
        WandCooldown(
          cast_delay_remaining: duration.milliseconds(0),
          recharge_delay_remaining: final_cooldown,
          next_cast_index:,
        )

      // Notify player of projectiles spawned
      process.send(
        state.player,
        state.to_player(ProjectilesSpawned(projectiles)),
      )

      // Notify player of state change
      process.send(
        state.player,
        state.to_player(WandStateChanged(updated_wand, new_cooldown)),
      )

      let new_state = State(..state, wand: updated_wand, cooldown: new_cooldown)
      actor.continue(new_state)
    }
  }
}

/// Decrement a single cooldown
fn decrement_cooldown(
  cooldown: WandCooldown,
  delta_time: Duration,
) -> WandCooldown {
  let cast_remaining_seconds =
    float.max(
      0.0,
      duration.to_seconds(cooldown.cast_delay_remaining)
        -. duration.to_seconds(delta_time),
    )
  let recharge_remaining_seconds =
    float.max(
      0.0,
      duration.to_seconds(cooldown.recharge_delay_remaining)
        -. duration.to_seconds(delta_time),
    )

  WandCooldown(
    cast_delay_remaining: duration.milliseconds(float.round(
      cast_remaining_seconds *. 1000.0,
    )),
    recharge_delay_remaining: duration.milliseconds(float.round(
      recharge_remaining_seconds *. 1000.0,
    )),
    next_cast_index: cooldown.next_cast_index,
  )
}

/// Create a starter wand with basic spells
pub fn create_starter_wand() -> wand.Wand {
  let starter_wand =
    wand.new(
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: duration.milliseconds(100),
      recharge_time: duration.milliseconds(200),
      spells_per_cast: 1,
      spread: 0.0,
    )

  // Add spells to the wand
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 0, spell.spark())
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 1, spell.spark())
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 2, spell.spark())

  starter_wand
}
