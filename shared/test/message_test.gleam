import gleam/option
import shared/enemy
import shared/game_messages
import shared/health
import shared/player
import shared/projectile
import shared/room
import vec/vec3

// =============================================================================
// CLIENT MESSAGE TESTS
// =============================================================================

pub fn player_input_move_encoding_test() {
  let msg =
    game_messages.PlayerInput(
      tick: 42,
      action: game_messages.MoveToPosition(vec3.Vec3(10.0, 0.0, 5.0)),
    )

  let encoded = game_messages.encode_client_message(msg)
  assert Ok(msg) == game_messages.decode_client_message(encoded)
}

pub fn player_input_switch_wand_encoding_test() {
  let msg =
    game_messages.PlayerInput(tick: 10, action: game_messages.SwitchWand(2))

  let encoded = game_messages.encode_client_message(msg)
  assert Ok(msg) == game_messages.decode_client_message(encoded)
}

pub fn player_input_cast_spell_encoding_test() {
  let msg =
    game_messages.PlayerInput(
      tick: 100,
      action: game_messages.CastSpell(vec3.Vec3(15.0, 0.0, 20.0)),
    )

  let encoded = game_messages.encode_client_message(msg)
  assert Ok(msg) == game_messages.decode_client_message(encoded)
}

pub fn player_input_none_encoding_test() {
  let msg = game_messages.PlayerInput(tick: 5, action: game_messages.None)

  let encoded = game_messages.encode_client_message(msg)
  assert Ok(msg) == game_messages.decode_client_message(encoded)
}

pub fn join_room_encoding_test() {
  let msg = game_messages.JoinRoom("room-1", "TestPlayer")

  let encoded = game_messages.encode_client_message(msg)
  assert Ok(msg) == game_messages.decode_client_message(encoded)
}

pub fn leave_room_encoding_test() {
  let msg = game_messages.LeaveRoom

  let encoded = game_messages.encode_client_message(msg)
  assert Ok(msg) == game_messages.decode_client_message(encoded)
}

pub fn player_update_legacy_encoding_test() {
  let msg = game_messages.PlayerUpdate(vec3.Vec3(5.0, 1.0, 10.0))

  let encoded = game_messages.encode_client_message(msg)
  assert Ok(msg) == game_messages.decode_client_message(encoded)
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
    game_messages.GameStateUpdate(
      tick: 123,
      players: [test_player],
      projectiles: [],
      enemies: [test_enemy],
    )

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn enemy_spawned_encoding_test() {
  let test_enemy =
    enemy.Enemy(
      id: enemy.Id(5),
      enemy_type: enemy.Zombie,
      position: vec3.Vec3(5.0, 0.0, 5.0),
      velocity: vec3.Vec3(1.0, 0.0, 1.0),
      health: health.new(100.0),
      target_player: option.Some(player.Id(1)),
    )

  let msg = game_messages.EnemySpawned(test_enemy)

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn enemy_died_encoding_test() {
  let msg = game_messages.EnemyDied(enemy.Id(10))

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn player_damaged_encoding_test() {
  let msg = game_messages.PlayerDamaged(player.Id(2), 25.0, 75.0)

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn projectile_destroyed_hit_enemy_test() {
  let msg =
    game_messages.ProjectileDestroyed(
      projectile.Id(1),
      game_messages.HitEnemy(enemy.Id(5)),
    )

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn projectile_destroyed_expired_test() {
  let msg =
    game_messages.ProjectileDestroyed(projectile.Id(2), game_messages.Expired)

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn projectile_destroyed_hit_player_test() {
  let msg =
    game_messages.ProjectileDestroyed(
      projectile.Id(3),
      game_messages.HitPlayer(player.Id(1)),
    )

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn room_joined_encoding_test() {
  let test_players = [
    player.new(player.Id(1), "Player1", vec3.Vec3(0.0, 0.0, 0.0)),
    player.new(player.Id(2), "Player2", vec3.Vec3(5.0, 0.0, 5.0)),
  ]

  let msg = game_messages.RoomJoined(room.Id(1), player.Id(1), test_players)

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn player_joined_encoding_test() {
  let test_player =
    player.new(player.Id(3), "NewPlayer", vec3.Vec3(2.0, 0.0, 3.0))

  let msg = game_messages.PlayerJoined(test_player)

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn player_left_encoding_test() {
  let msg = game_messages.PlayerLeft(player.Id(5))

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}

pub fn error_encoding_test() {
  let msg = game_messages.Error("Something went wrong")

  let encoded = game_messages.encode_server_message(msg)
  assert Ok(msg) == game_messages.decode_server_message(encoded)
}
