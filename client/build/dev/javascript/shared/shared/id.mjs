import { CustomType as $CustomType } from "../gleam.mjs";

export class PlayerId extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const PlayerId$PlayerId = ($0) => new PlayerId($0);
export const PlayerId$isPlayerId = (value) => value instanceof PlayerId;
export const PlayerId$PlayerId$0 = (value) => value[0];

export class RoomId extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const RoomId$RoomId = ($0) => new RoomId($0);
export const RoomId$isRoomId = (value) => value instanceof RoomId;
export const RoomId$RoomId$0 = (value) => value[0];

export class ProjectileId extends $CustomType {
  constructor(caster, local_id) {
    super();
    this.caster = caster;
    this.local_id = local_id;
  }
}
export const ProjectileId$ProjectileId = (caster, local_id) =>
  new ProjectileId(caster, local_id);
export const ProjectileId$isProjectileId = (value) =>
  value instanceof ProjectileId;
export const ProjectileId$ProjectileId$caster = (value) => value.caster;
export const ProjectileId$ProjectileId$0 = (value) => value.caster;
export const ProjectileId$ProjectileId$local_id = (value) => value.local_id;
export const ProjectileId$ProjectileId$1 = (value) => value.local_id;

export class EnemyId extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const EnemyId$EnemyId = ($0) => new EnemyId($0);
export const EnemyId$isEnemyId = (value) => value instanceof EnemyId;
export const EnemyId$EnemyId$0 = (value) => value[0];

/**
 * Convert a PlayerId to its string representation.
 */
export function player_id_to_string(id) {
  let s;
  s = id[0];
  return s;
}

/**
 * Create a PlayerId from a string.
 */
export function player_id_from_string(s) {
  return new PlayerId(s);
}

/**
 * Convert a RoomId to its string representation.
 */
export function room_id_to_string(id) {
  let s;
  s = id[0];
  return s;
}

/**
 * Create a RoomId from a string.
 */
export function room_id_from_string(s) {
  return new RoomId(s);
}
