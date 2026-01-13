/// Manages WebSocket connections and player lifecycle.
/// Handles joining, leaving, and connection errors.
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/time/duration
import plinth/cloudflare/durable_object.{type WebSocket}
import shared/player
import shared/spell
import shared/wand
import vec/vec3.{type Vec3, Vec3}

// =============================================================================
// TYPES
// =============================================================================

/// Information about a connected player
pub type PlayerInfo {
  PlayerInfo(state: player.Player, ws: WebSocket)
}

/// Connection module state
pub type Model {
  Model(players: Dict(player.Id, PlayerInfo), next_player_id: Int)
}

/// Connection events
pub type Msg {
  PlayerJoined(player_id: player.Id, ws: WebSocket, name: String)
  PlayerLeft(player_id: player.Id)
  PlayerDisconnected(player_id: player.Id, code: Int, reason: String)
  ConnectionError(player_id: player.Id)
}

/// Events that this module can dispatch to other modules
pub type OutMsg {
  BroadcastPlayerJoined(player: player.Player, except: Option(player.Id))
  BroadcastPlayerLeft(player_id: player.Id)
  NotifyPlayerJoined(
    player_id: player.Id,
    ws: WebSocket,
    existing_players: List(player.Player),
  )
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> Model {
  Model(players: dict.new(), next_player_id: 1)
}

// =============================================================================
// UPDATE
// =============================================================================

/// Update the connection state based on messages
pub fn update(model: Model, msg: Msg) -> #(Model, List(OutMsg)) {
  case msg {
    PlayerJoined(player_id, ws, name) -> handle_join(model, player_id, ws, name)

    PlayerLeft(player_id) -> handle_leave(model, player_id)

    PlayerDisconnected(player_id, code, reason) ->
      handle_disconnect(model, player_id, code, reason)

    ConnectionError(player_id) -> handle_error(model, player_id)
  }
}

// =============================================================================
// HANDLERS
// =============================================================================

fn handle_join(
  model: Model,
  player_id: player.Id,
  ws: WebSocket,
  name: String,
) -> #(Model, List(OutMsg)) {
  // Create new player with starter wand
  let new_player =
    player.new(player_id, name, Vec3(0.0, 0.9, 0.0))
    |> give_starter_wand()

  let player_info = PlayerInfo(state: new_player, ws: ws)

  // Get existing players before adding new one
  let existing_players =
    dict.values(model.players)
    |> list.map(fn(info) { info.state })

  // Add new player
  let new_players = dict.insert(model.players, player_id, player_info)

  let new_model =
    Model(
      ..model,
      players: new_players,
      next_player_id: model.next_player_id + 1,
    )

  // Dispatch events
  let out_msgs = [
    NotifyPlayerJoined(player_id, ws, existing_players),
    BroadcastPlayerJoined(new_player, Some(player_id)),
  ]

  #(new_model, out_msgs)
}

fn handle_leave(model: Model, player_id: player.Id) -> #(Model, List(OutMsg)) {
  // Close WebSocket if still connected
  case dict.get(model.players, player_id) {
    Ok(player_info) ->
      durable_object.websocket_close(player_info.ws, 1000, "Player left")
    Error(_) -> Nil
  }

  // Remove player
  let new_players = dict.delete(model.players, player_id)
  let new_model = Model(..model, players: new_players)

  // Broadcast to remaining players
  #(new_model, [BroadcastPlayerLeft(player_id)])
}

fn handle_disconnect(
  model: Model,
  player_id: player.Id,
  _code: Int,
  _reason: String,
) -> #(Model, List(OutMsg)) {
  let player.Id(pid) = player_id
  io.println("[Connection] Player " <> int.to_string(pid) <> " disconnected")

  // Remove player
  let new_players = dict.delete(model.players, player_id)
  let new_model = Model(..model, players: new_players)

  // Broadcast to remaining players
  #(new_model, [BroadcastPlayerLeft(player_id)])
}

fn handle_error(model: Model, player_id: player.Id) -> #(Model, List(OutMsg)) {
  io.println("[Connection] WebSocket error for player")

  // Treat as disconnect
  handle_disconnect(model, player_id, 1011, "WebSocket error")
}

// =============================================================================
// QUERIES
// =============================================================================

/// Get all connected players
pub fn get_players(model: Model) -> Dict(player.Id, PlayerInfo) {
  model.players
}

/// Get a specific player
pub fn get_player(model: Model, player_id: player.Id) -> Result(PlayerInfo, Nil) {
  dict.get(model.players, player_id)
}

/// Get the next player ID to assign
pub fn next_player_id(model: Model) -> player.Id {
  player.Id(model.next_player_id)
}

/// Get count of connected players
pub fn player_count(model: Model) -> Int {
  dict.size(model.players)
}

/// Update a player's state
pub fn update_player(
  model: Model,
  player_id: player.Id,
  player_state: player.Player,
) -> Model {
  case dict.get(model.players, player_id) {
    Ok(player_info) -> {
      let updated_info = PlayerInfo(..player_info, state: player_state)
      let new_players = dict.insert(model.players, player_id, updated_info)
      Model(..model, players: new_players)
    }
    Error(_) -> model
  }
}

// =============================================================================
// HELPERS
// =============================================================================

/// Give a player a starter wand with basic spells
fn give_starter_wand(new_player: player.Player) -> player.Player {
  let starter_wand =
    wand.new(
      name: "Starter Wand",
      slot_count: 3,
      max_mana: 100.0,
      mana_recharge_rate: 10.0,
      cast_delay: duration.milliseconds(100),
      recharge_time: duration.milliseconds(200),
      spells_per_cast: 1,
      spread: 0.0,
    )

  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 0, spell.spark())
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 1, spell.spark())
  let assert Ok(starter_wand) = wand.set_spell(starter_wand, 2, spell.spark())

  let new_wands =
    player.WandInventory(
      slot_0: option.Some(starter_wand),
      slot_1: option.None,
      slot_2: option.None,
      slot_3: option.None,
    )

  player.Player(..new_player, wands: new_wands, active_wand_slot: 0)
}
