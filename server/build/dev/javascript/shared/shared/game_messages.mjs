import * as $json from "../../gleam_json/gleam/json.mjs";
import * as $decode from "../../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import { toList, CustomType as $CustomType } from "../gleam.mjs";
import * as $id from "../shared/id.mjs";
import { PlayerId, RoomId } from "../shared/id.mjs";
import * as $player_state from "../shared/player_state.mjs";

/**
 * Request to join a game room.
 */
export class JoinRoom extends $CustomType {
  constructor(room_id, player_name) {
    super();
    this.room_id = room_id;
    this.player_name = player_name;
  }
}
export const ClientMessage$JoinRoom = (room_id, player_name) =>
  new JoinRoom(room_id, player_name);
export const ClientMessage$isJoinRoom = (value) => value instanceof JoinRoom;
export const ClientMessage$JoinRoom$room_id = (value) => value.room_id;
export const ClientMessage$JoinRoom$0 = (value) => value.room_id;
export const ClientMessage$JoinRoom$player_name = (value) => value.player_name;
export const ClientMessage$JoinRoom$1 = (value) => value.player_name;

export class LeaveRoom extends $CustomType {}
export const ClientMessage$LeaveRoom = () => new LeaveRoom();
export const ClientMessage$isLeaveRoom = (value) => value instanceof LeaveRoom;

/**
 * Update the player's position and rotation.
 */
export class PlayerUpdate extends $CustomType {
  constructor(position, rotation) {
    super();
    this.position = position;
    this.rotation = rotation;
  }
}
export const ClientMessage$PlayerUpdate = (position, rotation) =>
  new PlayerUpdate(position, rotation);
export const ClientMessage$isPlayerUpdate = (value) =>
  value instanceof PlayerUpdate;
export const ClientMessage$PlayerUpdate$position = (value) => value.position;
export const ClientMessage$PlayerUpdate$0 = (value) => value.position;
export const ClientMessage$PlayerUpdate$rotation = (value) => value.rotation;
export const ClientMessage$PlayerUpdate$1 = (value) => value.rotation;

/**
 * Cast a spell from a wand.
 */
export class SpellCast extends $CustomType {
  constructor(wand_index, direction) {
    super();
    this.wand_index = wand_index;
    this.direction = direction;
  }
}
export const ClientMessage$SpellCast = (wand_index, direction) =>
  new SpellCast(wand_index, direction);
export const ClientMessage$isSpellCast = (value) => value instanceof SpellCast;
export const ClientMessage$SpellCast$wand_index = (value) => value.wand_index;
export const ClientMessage$SpellCast$0 = (value) => value.wand_index;
export const ClientMessage$SpellCast$direction = (value) => value.direction;
export const ClientMessage$SpellCast$1 = (value) => value.direction;

/**
 * Ping the server to measure latency.
 */
export class Ping extends $CustomType {
  constructor(timestamp) {
    super();
    this.timestamp = timestamp;
  }
}
export const ClientMessage$Ping = (timestamp) => new Ping(timestamp);
export const ClientMessage$isPing = (value) => value instanceof Ping;
export const ClientMessage$Ping$timestamp = (value) => value.timestamp;
export const ClientMessage$Ping$0 = (value) => value.timestamp;

/**
 * Confirmation that the player has joined a room.
 */
export class RoomJoined extends $CustomType {
  constructor(room_id, player_id, players) {
    super();
    this.room_id = room_id;
    this.player_id = player_id;
    this.players = players;
  }
}
export const ServerMessage$RoomJoined = (room_id, player_id, players) =>
  new RoomJoined(room_id, player_id, players);
export const ServerMessage$isRoomJoined = (value) =>
  value instanceof RoomJoined;
export const ServerMessage$RoomJoined$room_id = (value) => value.room_id;
export const ServerMessage$RoomJoined$0 = (value) => value.room_id;
export const ServerMessage$RoomJoined$player_id = (value) => value.player_id;
export const ServerMessage$RoomJoined$1 = (value) => value.player_id;
export const ServerMessage$RoomJoined$players = (value) => value.players;
export const ServerMessage$RoomJoined$2 = (value) => value.players;

/**
 * A new player has joined the room.
 */
export class PlayerJoined extends $CustomType {
  constructor(player) {
    super();
    this.player = player;
  }
}
export const ServerMessage$PlayerJoined = (player) => new PlayerJoined(player);
export const ServerMessage$isPlayerJoined = (value) =>
  value instanceof PlayerJoined;
export const ServerMessage$PlayerJoined$player = (value) => value.player;
export const ServerMessage$PlayerJoined$0 = (value) => value.player;

/**
 * A player has left the room.
 */
export class PlayerLeft extends $CustomType {
  constructor(player_id) {
    super();
    this.player_id = player_id;
  }
}
export const ServerMessage$PlayerLeft = (player_id) =>
  new PlayerLeft(player_id);
export const ServerMessage$isPlayerLeft = (value) =>
  value instanceof PlayerLeft;
export const ServerMessage$PlayerLeft$player_id = (value) => value.player_id;
export const ServerMessage$PlayerLeft$0 = (value) => value.player_id;

/**
 * Periodic state update for all players in the room.
 */
export class PlayerStates extends $CustomType {
  constructor(states) {
    super();
    this.states = states;
  }
}
export const ServerMessage$PlayerStates = (states) => new PlayerStates(states);
export const ServerMessage$isPlayerStates = (value) =>
  value instanceof PlayerStates;
export const ServerMessage$PlayerStates$states = (value) => value.states;
export const ServerMessage$PlayerStates$0 = (value) => value.states;

/**
 * A player has cast a spell.
 */
export class SpellCastBroadcast extends $CustomType {
  constructor(caster_id, wand_index, direction) {
    super();
    this.caster_id = caster_id;
    this.wand_index = wand_index;
    this.direction = direction;
  }
}
export const ServerMessage$SpellCastBroadcast = (caster_id, wand_index, direction) =>
  new SpellCastBroadcast(caster_id, wand_index, direction);
export const ServerMessage$isSpellCastBroadcast = (value) =>
  value instanceof SpellCastBroadcast;
export const ServerMessage$SpellCastBroadcast$caster_id = (value) =>
  value.caster_id;
export const ServerMessage$SpellCastBroadcast$0 = (value) => value.caster_id;
export const ServerMessage$SpellCastBroadcast$wand_index = (value) =>
  value.wand_index;
export const ServerMessage$SpellCastBroadcast$1 = (value) => value.wand_index;
export const ServerMessage$SpellCastBroadcast$direction = (value) =>
  value.direction;
export const ServerMessage$SpellCastBroadcast$2 = (value) => value.direction;

/**
 * An enemy has spawned.
 */
export class EnemySpawned extends $CustomType {
  constructor(enemy_id, position, health) {
    super();
    this.enemy_id = enemy_id;
    this.position = position;
    this.health = health;
  }
}
export const ServerMessage$EnemySpawned = (enemy_id, position, health) =>
  new EnemySpawned(enemy_id, position, health);
export const ServerMessage$isEnemySpawned = (value) =>
  value instanceof EnemySpawned;
export const ServerMessage$EnemySpawned$enemy_id = (value) => value.enemy_id;
export const ServerMessage$EnemySpawned$0 = (value) => value.enemy_id;
export const ServerMessage$EnemySpawned$position = (value) => value.position;
export const ServerMessage$EnemySpawned$1 = (value) => value.position;
export const ServerMessage$EnemySpawned$health = (value) => value.health;
export const ServerMessage$EnemySpawned$2 = (value) => value.health;

/**
 * An enemy has died.
 */
export class EnemyDied extends $CustomType {
  constructor(enemy_id, killer_id) {
    super();
    this.enemy_id = enemy_id;
    this.killer_id = killer_id;
  }
}
export const ServerMessage$EnemyDied = (enemy_id, killer_id) =>
  new EnemyDied(enemy_id, killer_id);
export const ServerMessage$isEnemyDied = (value) => value instanceof EnemyDied;
export const ServerMessage$EnemyDied$enemy_id = (value) => value.enemy_id;
export const ServerMessage$EnemyDied$0 = (value) => value.enemy_id;
export const ServerMessage$EnemyDied$killer_id = (value) => value.killer_id;
export const ServerMessage$EnemyDied$1 = (value) => value.killer_id;

/**
 * Response to a ping.
 */
export class Pong extends $CustomType {
  constructor(client_timestamp, server_timestamp) {
    super();
    this.client_timestamp = client_timestamp;
    this.server_timestamp = server_timestamp;
  }
}
export const ServerMessage$Pong = (client_timestamp, server_timestamp) =>
  new Pong(client_timestamp, server_timestamp);
export const ServerMessage$isPong = (value) => value instanceof Pong;
export const ServerMessage$Pong$client_timestamp = (value) =>
  value.client_timestamp;
export const ServerMessage$Pong$0 = (value) => value.client_timestamp;
export const ServerMessage$Pong$server_timestamp = (value) =>
  value.server_timestamp;
export const ServerMessage$Pong$1 = (value) => value.server_timestamp;

/**
 * An error has occurred.
 */
export class Error extends $CustomType {
  constructor(message) {
    super();
    this.message = message;
  }
}
export const ServerMessage$Error = (message) => new Error(message);
export const ServerMessage$isError = (value) => value instanceof Error;
export const ServerMessage$Error$message = (value) => value.message;
export const ServerMessage$Error$0 = (value) => value.message;

/**
 * Encode a ClientMessage to JSON string for transmission.
 */
export function encode_client_message(msg) {
  let _block;
  if (msg instanceof JoinRoom) {
    let room_id = msg.room_id;
    let player_name = msg.player_name;
    _block = $json.object(
      toList([
        ["type", $json.string("join_room")],
        ["room_id", $json.string(room_id)],
        ["player_name", $json.string(player_name)],
      ]),
    );
  } else if (msg instanceof LeaveRoom) {
    _block = $json.object(toList([["type", $json.string("leave_room")]]));
  } else if (msg instanceof PlayerUpdate) {
    let position = msg.position;
    let rotation = msg.rotation;
    _block = $json.object(
      toList([
        ["type", $json.string("player_update")],
        ["position", $player_state.encode_vec3(position)],
        ["rotation", $json.float(rotation)],
      ]),
    );
  } else if (msg instanceof SpellCast) {
    let wand_index = msg.wand_index;
    let direction = msg.direction;
    _block = $json.object(
      toList([
        ["type", $json.string("spell_cast")],
        ["wand_index", $json.int(wand_index)],
        ["direction", $player_state.encode_vec3(direction)],
      ]),
    );
  } else {
    let timestamp = msg.timestamp;
    _block = $json.object(
      toList([
        ["type", $json.string("ping")],
        ["timestamp", $json.int(timestamp)],
      ]),
    );
  }
  let _pipe = _block;
  return $json.to_string(_pipe);
}

/**
 * Decode a ClientMessage from JSON string.
 */
export function decode_client_message(data) {
  let decoder = $decode.field(
    "type",
    $decode.string,
    (msg_type) => {
      if (msg_type === "join_room") {
        return $decode.field(
          "room_id",
          $decode.string,
          (room_id) => {
            return $decode.field(
              "player_name",
              $decode.string,
              (player_name) => {
                return $decode.success(new JoinRoom(room_id, player_name));
              },
            );
          },
        );
      } else if (msg_type === "leave_room") {
        return $decode.success(new LeaveRoom());
      } else if (msg_type === "player_update") {
        return $decode.field(
          "position",
          $player_state.vec3_decoder(),
          (position) => {
            return $decode.field(
              "rotation",
              $decode.float,
              (rotation) => {
                return $decode.success(new PlayerUpdate(position, rotation));
              },
            );
          },
        );
      } else if (msg_type === "spell_cast") {
        return $decode.field(
          "wand_index",
          $decode.int,
          (wand_index) => {
            return $decode.field(
              "direction",
              $player_state.vec3_decoder(),
              (direction) => {
                return $decode.success(new SpellCast(wand_index, direction));
              },
            );
          },
        );
      } else if (msg_type === "ping") {
        return $decode.field(
          "timestamp",
          $decode.int,
          (timestamp) => { return $decode.success(new Ping(timestamp)); },
        );
      } else {
        return $decode.failure(new LeaveRoom(), "ClientMessage");
      }
    },
  );
  let _pipe = $json.parse(data, decoder);
  return $result.map_error(
    _pipe,
    (_) => { return "Failed to parse client message"; },
  );
}

/**
 * Encode a ServerMessage to JSON string for transmission.
 */
export function encode_server_message(msg) {
  let _block;
  if (msg instanceof RoomJoined) {
    let room_id = msg.room_id;
    let player_id = msg.player_id;
    let players = msg.players;
    let rid;
    rid = room_id[0];
    let pid;
    pid = player_id[0];
    _block = $json.object(
      toList([
        ["type", $json.string("room_joined")],
        ["room_id", $json.string(rid)],
        ["player_id", $json.string(pid)],
        ["players", $json.array(players, $player_state.encode)],
      ]),
    );
  } else if (msg instanceof PlayerJoined) {
    let player = msg.player;
    _block = $json.object(
      toList([
        ["type", $json.string("player_joined")],
        ["player", $player_state.encode(player)],
      ]),
    );
  } else if (msg instanceof PlayerLeft) {
    let player_id = msg.player_id;
    let pid;
    pid = player_id[0];
    _block = $json.object(
      toList([
        ["type", $json.string("player_left")],
        ["player_id", $json.string(pid)],
      ]),
    );
  } else if (msg instanceof PlayerStates) {
    let states = msg.states;
    _block = $json.object(
      toList([
        ["type", $json.string("player_states")],
        ["states", $json.array(states, $player_state.encode)],
      ]),
    );
  } else if (msg instanceof SpellCastBroadcast) {
    let caster_id = msg.caster_id;
    let wand_index = msg.wand_index;
    let direction = msg.direction;
    let cid;
    cid = caster_id[0];
    _block = $json.object(
      toList([
        ["type", $json.string("spell_cast_broadcast")],
        ["caster_id", $json.string(cid)],
        ["wand_index", $json.int(wand_index)],
        ["direction", $player_state.encode_vec3(direction)],
      ]),
    );
  } else if (msg instanceof EnemySpawned) {
    let enemy_id = msg.enemy_id;
    let position = msg.position;
    let health = msg.health;
    _block = $json.object(
      toList([
        ["type", $json.string("enemy_spawned")],
        ["enemy_id", $json.int(enemy_id)],
        ["position", $player_state.encode_vec3(position)],
        ["health", $json.float(health)],
      ]),
    );
  } else if (msg instanceof EnemyDied) {
    let enemy_id = msg.enemy_id;
    let killer_id = msg.killer_id;
    let kid;
    kid = killer_id[0];
    _block = $json.object(
      toList([
        ["type", $json.string("enemy_died")],
        ["enemy_id", $json.int(enemy_id)],
        ["killer_id", $json.string(kid)],
      ]),
    );
  } else if (msg instanceof Pong) {
    let client_timestamp = msg.client_timestamp;
    let server_timestamp = msg.server_timestamp;
    _block = $json.object(
      toList([
        ["type", $json.string("pong")],
        ["client_timestamp", $json.int(client_timestamp)],
        ["server_timestamp", $json.int(server_timestamp)],
      ]),
    );
  } else {
    let message = msg.message;
    _block = $json.object(
      toList([
        ["type", $json.string("error")],
        ["message", $json.string(message)],
      ]),
    );
  }
  let _pipe = _block;
  return $json.to_string(_pipe);
}

/**
 * Decode a ServerMessage from JSON string.
 */
export function decode_server_message(data) {
  let decoder = $decode.field(
    "type",
    $decode.string,
    (msg_type) => {
      if (msg_type === "room_joined") {
        return $decode.field(
          "room_id",
          $decode.string,
          (room_id) => {
            return $decode.field(
              "player_id",
              $decode.string,
              (player_id) => {
                return $decode.field(
                  "players",
                  $decode.list($player_state.decoder()),
                  (players) => {
                    return $decode.success(
                      new RoomJoined(
                        new RoomId(room_id),
                        new PlayerId(player_id),
                        players,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      } else if (msg_type === "player_joined") {
        return $decode.field(
          "player",
          $player_state.decoder(),
          (player) => { return $decode.success(new PlayerJoined(player)); },
        );
      } else if (msg_type === "player_left") {
        return $decode.field(
          "player_id",
          $decode.string,
          (player_id) => {
            return $decode.success(new PlayerLeft(new PlayerId(player_id)));
          },
        );
      } else if (msg_type === "player_states") {
        return $decode.field(
          "states",
          $decode.list($player_state.decoder()),
          (states) => { return $decode.success(new PlayerStates(states)); },
        );
      } else if (msg_type === "spell_cast_broadcast") {
        return $decode.field(
          "caster_id",
          $decode.string,
          (caster_id) => {
            return $decode.field(
              "wand_index",
              $decode.int,
              (wand_index) => {
                return $decode.field(
                  "direction",
                  $player_state.vec3_decoder(),
                  (direction) => {
                    return $decode.success(
                      new SpellCastBroadcast(
                        new PlayerId(caster_id),
                        wand_index,
                        direction,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      } else if (msg_type === "enemy_spawned") {
        return $decode.field(
          "enemy_id",
          $decode.int,
          (enemy_id) => {
            return $decode.field(
              "position",
              $player_state.vec3_decoder(),
              (position) => {
                return $decode.field(
                  "health",
                  $decode.float,
                  (health) => {
                    return $decode.success(
                      new EnemySpawned(enemy_id, position, health),
                    );
                  },
                );
              },
            );
          },
        );
      } else if (msg_type === "enemy_died") {
        return $decode.field(
          "enemy_id",
          $decode.int,
          (enemy_id) => {
            return $decode.field(
              "killer_id",
              $decode.string,
              (killer_id) => {
                return $decode.success(
                  new EnemyDied(enemy_id, new PlayerId(killer_id)),
                );
              },
            );
          },
        );
      } else if (msg_type === "pong") {
        return $decode.field(
          "client_timestamp",
          $decode.int,
          (client_timestamp) => {
            return $decode.field(
              "server_timestamp",
              $decode.int,
              (server_timestamp) => {
                return $decode.success(
                  new Pong(client_timestamp, server_timestamp),
                );
              },
            );
          },
        );
      } else if (msg_type === "error") {
        return $decode.field(
          "message",
          $decode.string,
          (message) => { return $decode.success(new Error(message)); },
        );
      } else {
        return $decode.failure(new Error("unknown"), "ServerMessage");
      }
    },
  );
  let _pipe = $json.parse(data, decoder);
  return $result.map_error(
    _pipe,
    (_) => { return "Failed to parse server message"; },
  );
}
