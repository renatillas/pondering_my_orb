import gleam/dict
import gleam/time/duration
import server/game_simulation
import shared/game_messages
import shared/game_state
import shared/player
import vec/vec3.{Vec3}

pub fn player_movement_test() {
  // Create a game state with one player
  let player_state = player.new(player.Id(1), "TestPlayer", Vec3(0.0, 0.0, 0.0))
  let players = dict.from_list([#(player.Id(1), player_state)])
  let game_state =
    game_state.GameState(
      tick: 0,
      players: players,
      projectiles: dict.new(),
      enemies: dict.new(),
      next_projectile_id: 0,
      next_enemy_id: 0,
    )

  // Send a MoveToPosition input
  let target = Vec3(10.0, 0.0, 0.0)
  let inputs =
    dict.from_list([#(player.Id(1), game_messages.MoveToPosition(target))])

  // Run one tick
  let dt = duration.milliseconds(50)
  // 20 Hz tick rate
  let #(new_state, _events) = game_simulation.tick(game_state, inputs, dt)

  // Player should have started moving
  let assert Ok(updated_player) = dict.get(new_state.players, player.Id(1))

  // Check that movement state changed to MovingToPosition
  case updated_player.movement_state {
    player.MovingToPosition(_, _) -> Nil
    player.Idle -> panic as "Player should be moving"
  }

  // Player should have moved (position should not be 0,0,0 anymore)
  // After 50ms at 10 units/sec, should move 0.5 units
  let x_pos = vec3.x(updated_player.position)
  assert 0.4 <=. x_pos
  assert x_pos <=. 0.6
}

pub fn wand_switching_test() {
  // Create a player
  let player_state = player.new(player.Id(1), "TestPlayer", Vec3(0.0, 0.0, 0.0))
  let assert 0 = player_state.active_wand_slot
  // Default slot

  let players = dict.from_list([#(player.Id(1), player_state)])
  let game_state =
    game_state.GameState(
      tick: 0,
      players: players,
      projectiles: dict.new(),
      enemies: dict.new(),
      next_projectile_id: 0,
      next_enemy_id: 0,
    )

  // Switch to slot 2
  let inputs = dict.from_list([#(player.Id(1), game_messages.SwitchWand(2))])

  let dt = duration.milliseconds(50)
  let #(new_state, _events) = game_simulation.tick(game_state, inputs, dt)

  let assert Ok(updated_player) = dict.get(new_state.players, player.Id(1))
  let assert 2 = updated_player.active_wand_slot
}
