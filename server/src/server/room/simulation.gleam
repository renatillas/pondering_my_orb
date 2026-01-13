/// Manages server-authoritative game simulation.
/// Processes player inputs and runs physics/game logic at fixed tick rate.
import gleam/dict.{type Dict}
import gleam/list
import gleam/time/duration
import server/game_simulation
import server/game_tick
import shared/game_messages.{type PlayerAction}
import shared/game_state.{type GameState}
import shared/player
import vec/vec3

// =============================================================================
// TYPES
// =============================================================================

/// Simulation module state
pub type Model {
  Model(
    game_state: GameState,
    tick_scheduler: game_tick.TickScheduler,
    player_inputs: Dict(player.Id, PlayerAction),
  )
}

/// Simulation events
pub type Msg {
  Tick
  PlayerInput(player_id: player.Id, action: PlayerAction)
}

/// Events that this module can dispatch to other modules
pub type OutMsg {
  BroadcastGameState(tick: Int, state: GameState)
  BroadcastGameEvents(events: List(game_simulation.GameEvent))
  ScheduleNextTick(delay_ms: Int)
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> Model {
  Model(
    game_state: game_state.new(),
    tick_scheduler: game_tick.new(),
    player_inputs: dict.new(),
  )
}

// =============================================================================
// UPDATE
// =============================================================================

/// Update the simulation state based on messages
pub fn update(model: Model, msg: Msg) -> #(Model, List(OutMsg)) {
  case msg {
    Tick -> handle_tick(model)
    PlayerInput(player_id, action) ->
      handle_player_input(model, player_id, action)
  }
}

// =============================================================================
// HANDLERS
// =============================================================================

fn handle_tick(model: Model) -> #(Model, List(OutMsg)) {
  // Advance tick counter
  let new_scheduler = game_tick.advance_tick(model.tick_scheduler)
  let current_tick = game_tick.current_tick(new_scheduler)

  // Get delta time for physics
  let delta_time = game_tick.get_delta_time()

  // Run game simulation
  let #(new_game_state, events) =
    game_simulation.tick(model.game_state, model.player_inputs, delta_time)

  // Clear input buffer
  let new_model =
    Model(
      game_state: new_game_state,
      tick_scheduler: new_scheduler,
      player_inputs: dict.new(),
    )

  // Dispatch events
  let out_msgs = [
    BroadcastGameState(current_tick, new_game_state),
    BroadcastGameEvents(events),
    ScheduleNextTick(game_tick.next_tick_delay_ms()),
  ]

  #(new_model, out_msgs)
}

fn handle_player_input(
  model: Model,
  player_id: player.Id,
  action: PlayerAction,
) -> #(Model, List(OutMsg)) {
  // Buffer the input for the next tick
  let new_inputs = dict.insert(model.player_inputs, player_id, action)
  let new_model = Model(..model, player_inputs: new_inputs)

  #(new_model, [])
}

// =============================================================================
// QUERIES
// =============================================================================

/// Get the current game state
pub fn get_game_state(model: Model) -> GameState {
  model.game_state
}

/// Get the current tick number
pub fn get_current_tick(model: Model) -> Int {
  game_tick.current_tick(model.tick_scheduler)
}

/// Add a player to the simulation
pub fn add_player(model: Model, player_state: player.Player) -> Model {
  let new_game_players =
    dict.insert(model.game_state.players, player_state.id, player_state)
  let new_game_state =
    game_state.GameState(..model.game_state, players: new_game_players)

  Model(..model, game_state: new_game_state)
}

/// Remove a player from the simulation
pub fn remove_player(model: Model, player_id: player.Id) -> Model {
  let new_game_players = dict.delete(model.game_state.players, player_id)
  let new_game_state =
    game_state.GameState(..model.game_state, players: new_game_players)

  Model(..model, game_state: new_game_state)
}

/// Update a player's position in the simulation
pub fn update_player_position(
  model: Model,
  player_id: player.Id,
  position: vec3.Vec3(Float),
) -> Model {
  case dict.get(model.game_state.players, player_id) {
    Ok(player_state) -> {
      let updated_player = player.Player(..player_state, position: position)
      let new_game_players =
        dict.insert(model.game_state.players, player_id, updated_player)
      let new_game_state =
        game_state.GameState(..model.game_state, players: new_game_players)

      Model(..model, game_state: new_game_state)
    }
    Error(_) -> model
  }
}
