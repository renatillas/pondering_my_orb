import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import shared/enemy
import shared/player
import shared/projectile

// =============================================================================
// TYPES
// =============================================================================

pub type GameState {
  GameState(
    tick: Int,
    players: Dict(player.Id, player.Player),
    projectiles: Dict(projectile.Id, projectile.Projectile),
    enemies: Dict(enemy.Id, enemy.Enemy),
    next_projectile_id: Int,
    next_enemy_id: Int,
  )
}

// =============================================================================
// CONSTRUCTORS
// =============================================================================

/// Create an empty game state
pub fn new() -> GameState {
  GameState(
    tick: 0,
    players: dict.new(),
    projectiles: dict.new(),
    enemies: dict.new(),
    next_projectile_id: 0,
    next_enemy_id: 0,
  )
}

// =============================================================================
// JSON ENCODING / DECODING
// =============================================================================

/// Encode a GameState to JSON for network transmission
/// Used for sending full state snapshots
pub fn encode(state: GameState) -> json.Json {
  json.object([
    #("tick", json.int(state.tick)),
    #("players", encode_player_dict(state.players)),
    #("projectiles", encode_projectile_dict(state.projectiles)),
    #("enemies", encode_enemy_dict(state.enemies)),
    #("next_projectile_id", json.int(state.next_projectile_id)),
    #("next_enemy_id", json.int(state.next_enemy_id)),
  ])
}

fn encode_player_dict(players: Dict(player.Id, player.Player)) -> json.Json {
  players
  |> dict.values
  |> json.array(player.encode)
}

fn encode_projectile_dict(
  projectiles: Dict(projectile.Id, projectile.Projectile),
) -> json.Json {
  projectiles
  |> dict.values
  |> json.array(projectile.encode)
}

fn encode_enemy_dict(enemies: Dict(enemy.Id, enemy.Enemy)) -> json.Json {
  enemies
  |> dict.values
  |> json.array(enemy.encode)
}

/// Decoder for GameState from JSON
pub fn decoder() -> decode.Decoder(GameState) {
  use tick <- decode.field("tick", decode.int)
  use players_list <- decode.field("players", decode.list(player.decoder()))
  use projectiles_list <- decode.field(
    "projectiles",
    decode.list(projectile.decoder()),
  )
  use enemies_list <- decode.field("enemies", decode.list(enemy.decoder()))
  use next_projectile_id <- decode.field("next_projectile_id", decode.int)
  use next_enemy_id <- decode.field("next_enemy_id", decode.int)

  // Convert lists to dicts
  let players =
    players_list
    |> list.map(fn(p) { #(p.id, p) })
    |> dict.from_list

  let projectiles =
    projectiles_list
    |> list.map(fn(p) { #(p.id, p) })
    |> dict.from_list

  let enemies =
    enemies_list
    |> list.map(fn(e) { #(e.id, e) })
    |> dict.from_list

  decode.success(GameState(
    tick: tick,
    players: players,
    projectiles: projectiles,
    enemies: enemies,
    next_projectile_id: next_projectile_id,
    next_enemy_id: next_enemy_id,
  ))
}
