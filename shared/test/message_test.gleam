import gleam/option
import shared/enemy
import shared/game_event
import shared/game_message
import shared/health
import shared/player
import shared/projectile
import vec/vec3

// =============================================================================
// CLIENT MESSAGE TESTS
// =============================================================================

pub fn player_input_move_encoding_test() {
  let msg =
    game_message.PlayerInput(
      tick: 42,
      action: game_message.MoveToPosition(vec3.Vec3(10.0, 0.0, 5.0)),
    )

  let encoded = game_message.encode_client_message(msg)
  assert Ok(msg) == game_message.decode_client_message(encoded)
}

pub fn player_input_switch_wand_encoding_test() {
  let msg =
    game_message.PlayerInput(tick: 10, action: game_message.SwitchWand(2))

  let encoded = game_message.encode_client_message(msg)
  assert Ok(msg) == game_message.decode_client_message(encoded)
}

pub fn player_input_cast_spell_encoding_test() {
  let msg =
    game_message.PlayerInput(
      tick: 100,
      action: game_message.CastSpell(vec3.Vec3(15.0, 0.0, 20.0)),
    )

  let encoded = game_message.encode_client_message(msg)
  assert Ok(msg) == game_message.decode_client_message(encoded)
}

pub fn player_input_none_encoding_test() {
  let msg = game_message.PlayerInput(tick: 5, action: game_message.None)

  let encoded = game_message.encode_client_message(msg)
  assert Ok(msg) == game_message.decode_client_message(encoded)
}

pub fn join_room_encoding_test() {
  let msg = game_message.JoinRoom("room-1", "TestPlayer")
  let encoded = game_message.encode_client_message(msg)
  assert Ok(msg) == game_message.decode_client_message(encoded)
}

pub fn leave_room_encoding_test() {
  let msg = game_message.LeaveRoom
  let encoded = game_message.encode_client_message(msg)
  assert Ok(msg) == game_message.decode_client_message(encoded)
}

pub fn player_update_legacy_encoding_test() {
  let msg = game_message.PlayerUpdate(vec3.Vec3(5.0, 1.0, 10.0))
  let encoded = game_message.encode_client_message(msg)
  assert Ok(msg) == game_message.decode_client_message(encoded)
}

// =============================================================================
// SERVER MESSAGE TESTS
// =============================================================================

pub fn game_state_update_encoding_test() {
  let test_player =
    player.new(player.Id(1), "TestPlayer", vec3.Vec3(0.0, 0.0, 0.0))
  let test_enemy =
    enemy.Enemy(
      id: enemy.Id(1),
      enemy_type: enemy.Zombie,
      position: vec3.Vec3(10.0, 0.0, 10.0),
      velocity: vec3.Vec3(0.0, 0.0, 0.0),
      health: health.new(50.0),
      target_player: option.None,
    )

  let msg =
    game_message.GameStateUpdate(
      tick: 123,
      players: [test_player],
      projectiles: [],
      enemies: [test_enemy],
    )

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn enemy_spawned_encoding_test() {
  let test_enemy =
    enemy.Enemy(
      id: enemy.Id(5),
      position: vec3.Vec3(5.0, 0.0, 5.0),
      velocity: vec3.Vec3(1.0, 0.0, 1.0),
      health: health.new(100.0),
      target_player: option.Some(player.Id(1)),
      enemy_type: enemy.Zombie,
    )

  let event = game_event.EnemySpawned(test_enemy)
  let msg = game_message.GameEvent(event)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn enemy_died_encoding_test() {
  let event = game_event.EnemyDied(enemy.Id(10))
  let msg = game_message.GameEvent(event)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn player_damaged_encoding_test() {
  let event = game_event.PlayerDamaged(player.Id(2), 25.0, 75.0)
  let msg = game_message.GameEvent(event)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn projectile_destroyed_hit_enemy_test() {
  let event =
    game_event.ProjectileDestroyed(
      projectile.Id(1),
      game_event.HitEnemy(enemy.Id(5)),
    )
  let msg = game_message.GameEvent(event)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn projectile_destroyed_expired_test() {
  let event =
    game_event.ProjectileDestroyed(projectile.Id(2), game_event.Expired)
  let msg = game_message.GameEvent(event)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn projectile_destroyed_hit_player_test() {
  let event =
    game_event.ProjectileDestroyed(
      projectile.Id(3),
      game_event.HitPlayer(player.Id(1)),
    )
  let msg = game_message.GameEvent(event)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn room_joined_encoding_test() {
  let test_players = [
    player.new(player.Id(1), "Player1", vec3.Vec3(0.0, 0.0, 0.0)),
    player.new(player.Id(2), "Player2", vec3.Vec3(5.0, 0.0, 5.0)),
  ]

  let msg = game_message.RoomJoined(player.Id(1), test_players)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn player_joined_encoding_test() {
  let test_player =
    player.new(player.Id(3), "NewPlayer", vec3.Vec3(2.0, 0.0, 3.0))

  let msg = game_message.PlayerJoined(test_player)

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn player_left_encoding_test() {
  let msg = game_message.PlayerLeft(player.Id(5))

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}

pub fn error_encoding_test() {
  let msg = game_message.Error("Something went wrong")

  let encoded = game_message.encode_server_message(msg)
  assert Ok(msg) == game_message.decode_server_message(encoded)
}
