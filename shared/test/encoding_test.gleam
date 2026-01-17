import gleam/json
import gleam/option
import shared/enemy
import shared/game_state
import shared/health
import shared/player
import vec/vec3

// =============================================================================
// PLAYER ENCODING/DECODING TESTS
// =============================================================================

pub fn player_encoding_roundtrip_test() {
  // Create a test player
  let original_player =
    player.new(player.Id(1), "TestPlayer", vec3.Vec3(1.0, 2.0, 3.0))

  // Encode to JSON then to string
  let json_encoded = player.encode(original_player)
  let json_string = json.to_string(json_encoded)

  // Decode back
  assert Ok(original_player) == json.parse(json_string, player.decoder())
}

pub fn player_with_damaged_health_test() {
  // Create a player with damaged health
  let player =
    player.new(player.Id(2), "DamagedPlayer", vec3.Vec3(0.0, 0.0, 0.0))
  let damaged_health = health.damage(player.health, 50.0)
  let player = player.Player(..player, health: damaged_health)

  // Encode and decode
  let json_encoded = player.encode(player)
  let json_string = json.to_string(json_encoded)
  assert Ok(player) == json.parse(json_string, player.decoder())
}

// =============================================================================
// ENEMY ENCODING/DECODING TESTS
// =============================================================================

pub fn enemy_encoding_roundtrip_test() {
  let enemy =
    enemy.Enemy(
      id: enemy.Id(1),
      enemy_type: enemy.Zombie,
      position: vec3.Vec3(5.0, 0.0, 5.0),
      velocity: vec3.Vec3(1.0, 0.0, 0.5),
      health: health.new(50.0),
      target_player: option.Some(player.Id(1)),
    )

  let json_encoded = enemy.encode(enemy)
  let json_string = json.to_string(json_encoded)
  assert Ok(enemy) == json.parse(json_string, enemy.decoder())
}

pub fn enemy_without_target_test() {
  let enemy =
    enemy.Enemy(
      id: enemy.Id(2),
      enemy_type: enemy.Zombie,
      position: vec3.Vec3(0.0, 0.0, 0.0),
      velocity: vec3.Vec3(0.0, 0.0, 0.0),
      health: health.new(100.0),
      target_player: option.None,
    )

  let json_encoded = enemy.encode(enemy)
  let json_string = json.to_string(json_encoded)
  assert Ok(enemy) == json.parse(json_string, enemy.decoder())
}

// =============================================================================
// GAME STATE ENCODING/DECODING TESTS
// =============================================================================

pub fn game_state_empty_test() {
  let original_state = game_state.new()

  let json_encoded = game_state.encode(original_state)
  let json_string = json.to_string(json_encoded)
  assert Ok(original_state) == json.parse(json_string, game_state.decoder())
}

pub fn game_state_with_entities_test() {
  let original_state =
    game_state.GameState(tick: 42, next_projectile_id: 0, next_enemy_id: 0)

  let json_encoded = game_state.encode(original_state)
  let json_string = json.to_string(json_encoded)
  assert Ok(original_state) == json.parse(json_string, game_state.decoder())
}
