import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $game_messages from "../../shared/shared/game_messages.mjs";
import {
  JoinRoom,
  LeaveRoom,
  Ping,
  PlayerJoined,
  PlayerLeft,
  PlayerStates,
  PlayerUpdate,
  Pong,
  RoomJoined,
  SpellCast,
  SpellCastBroadcast,
} from "../../shared/shared/game_messages.mjs";
import * as $id from "../../shared/shared/id.mjs";
import { PlayerId, RoomId } from "../../shared/shared/id.mjs";
import * as $player_state from "../../shared/shared/player_state.mjs";
import { PlayerState } from "../../shared/shared/player_state.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { Vec3 } from "../../vec/vec/vec3.mjs";
import { Ok, toList, CustomType as $CustomType } from "../gleam.mjs";
import {
  getCurrentTimestamp as get_current_timestamp,
  intToString as int_to_string,
} from "../server_ffi.mjs";

export class GameRoomState extends $CustomType {
  constructor(players, next_player_id) {
    super();
    this.players = players;
    this.next_player_id = next_player_id;
  }
}
export const GameRoomState$GameRoomState = (players, next_player_id) =>
  new GameRoomState(players, next_player_id);
export const GameRoomState$isGameRoomState = (value) =>
  value instanceof GameRoomState;
export const GameRoomState$GameRoomState$players = (value) => value.players;
export const GameRoomState$GameRoomState$0 = (value) => value.players;
export const GameRoomState$GameRoomState$next_player_id = (value) =>
  value.next_player_id;
export const GameRoomState$GameRoomState$1 = (value) => value.next_player_id;

/**
 * Initialize a new game room state.
 */
export function init() {
  return new GameRoomState($dict.new$(), 1);
}

/**
 * Handle a player leaving the room.
 * 
 * @ignore
 */
function handle_leave(state, player_id) {
  let new_state = new GameRoomState(
    $dict.delete$(state.players, player_id),
    state.next_player_id,
  );
  let broadcast_msg = new PlayerLeft(new PlayerId(player_id));
  let _block;
  let _pipe = $dict.keys(new_state.players);
  _block = $list.map(_pipe, (pid) => { return [pid, broadcast_msg]; });
  let messages = _block;
  return [new_state, messages];
}

/**
 * Handle a player position update.
 * 
 * @ignore
 */
function handle_player_update(state, player_id, position, rotation) {
  let $ = $dict.get(state.players, player_id);
  if ($ instanceof Ok) {
    let player = $[0];
    let updated_player = new PlayerState(
      player.id,
      position,
      rotation,
      player.health,
      player.max_health,
      player.active_wand_index,
    );
    let new_state = new GameRoomState(
      $dict.insert(state.players, player_id, updated_player),
      state.next_player_id,
    );
    return [new_state, toList([])];
  } else {
    return [state, toList([])];
  }
}

/**
 * Handle a spell cast.
 * 
 * @ignore
 */
function handle_spell_cast(state, player_id, wand_index, direction) {
  let broadcast_msg = new SpellCastBroadcast(
    new PlayerId(player_id),
    wand_index,
    direction,
  );
  let _block;
  let _pipe = $dict.keys(state.players);
  _block = $list.map(_pipe, (pid) => { return [pid, broadcast_msg]; });
  let messages = _block;
  return [state, messages];
}

/**
 * Get all player states for periodic broadcast.
 */
export function get_player_states(state) {
  return $dict.values(state.players);
}

/**
 * Broadcast player states to all connected players.
 */
export function broadcast_states(state) {
  let states = get_player_states(state);
  let msg = new PlayerStates(states);
  let _pipe = $dict.keys(state.players);
  return $list.map(_pipe, (pid) => { return [pid, msg]; });
}

/**
 * Handle a ping request.
 * 
 * @ignore
 */
function handle_ping(state, player_id, client_timestamp) {
  let server_timestamp = get_current_timestamp();
  let pong_msg = new Pong(client_timestamp, server_timestamp);
  return [state, toList([[player_id, pong_msg]])];
}

/**
 * Handle a player joining the room.
 * 
 * @ignore
 */
function handle_join(state, room_id, _) {
  let player_id = "player_" + int_to_string(state.next_player_id);
  let new_player = new PlayerState(
    new PlayerId(player_id),
    new Vec3(0.0, 0.0, 0.0),
    0.0,
    100.0,
    100.0,
    0,
  );
  let new_state = new GameRoomState(
    $dict.insert(state.players, player_id, new_player),
    state.next_player_id + 1,
  );
  let existing_players = $dict.values(state.players);
  let join_msg = new RoomJoined(
    new RoomId(room_id),
    new PlayerId(player_id),
    existing_players,
  );
  let broadcast_msg = new PlayerJoined(new_player);
  let _block;
  let _pipe = $dict.keys(state.players);
  let _pipe$1 = $list.map(_pipe, (pid) => { return [pid, broadcast_msg]; });
  _block = $list.prepend(_pipe$1, [player_id, join_msg]);
  let messages = _block;
  return [new_state, messages];
}

/**
 * Handle an incoming message from a player.
 */
export function handle_message(state, player_id, msg) {
  if (msg instanceof JoinRoom) {
    let room_id = msg.room_id;
    let player_name = msg.player_name;
    return handle_join(state, room_id, player_name);
  } else if (msg instanceof LeaveRoom) {
    return handle_leave(state, player_id);
  } else if (msg instanceof PlayerUpdate) {
    let position = msg.position;
    let rotation = msg.rotation;
    return handle_player_update(state, player_id, position, rotation);
  } else if (msg instanceof SpellCast) {
    let wand_index = msg.wand_index;
    let direction = msg.direction;
    return handle_spell_cast(state, player_id, wand_index, direction);
  } else {
    let timestamp = msg.timestamp;
    return handle_ping(state, player_id, timestamp);
  }
}
