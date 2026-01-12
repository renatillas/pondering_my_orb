import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $string from "../../gleam_stdlib/gleam/string.mjs";
import { Ok, Empty as $Empty, CustomType as $CustomType, makeError } from "../gleam.mjs";

const FILEPATH = "src/client/id.gleam";

export class Player extends $CustomType {}
export const Id$Player = () => new Player();
export const Id$isPlayer = (value) => value instanceof Player;

export class Enemy extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Id$Enemy = ($0) => new Enemy($0);
export const Id$isEnemy = (value) => value instanceof Enemy;
export const Id$Enemy$0 = (value) => value[0];

export class EnemyHealth extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Id$EnemyHealth = ($0) => new EnemyHealth($0);
export const Id$isEnemyHealth = (value) => value instanceof EnemyHealth;
export const Id$EnemyHealth$0 = (value) => value[0];

export class Projectile extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Id$Projectile = ($0) => new Projectile($0);
export const Id$isProjectile = (value) => value instanceof Projectile;
export const Id$Projectile$0 = (value) => value[0];

export class Wall extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Id$Wall = ($0) => new Wall($0);
export const Id$isWall = (value) => value instanceof Wall;
export const Id$Wall$0 = (value) => value[0];

export class Floor extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Id$Floor = ($0) => new Floor($0);
export const Id$isFloor = (value) => value instanceof Floor;
export const Id$Floor$0 = (value) => value[0];

export class Altar extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Id$Altar = ($0) => new Altar($0);
export const Id$isAltar = (value) => value instanceof Altar;
export const Id$Altar$0 = (value) => value[0];

export function to_string(body_id) {
  if (body_id instanceof Player) {
    return "player";
  } else if (body_id instanceof Enemy) {
    let n = body_id[0];
    return "enemy_" + $int.to_string(n);
  } else if (body_id instanceof EnemyHealth) {
    let $ = body_id[0];
    if ($ instanceof Enemy) {
      let id = $[0];
      return "enemy_health_" + $int.to_string(id);
    } else {
      throw makeError(
        "panic",
        FILEPATH,
        "client/id",
        23,
        "to_string",
        "Unknown Id",
        {}
      )
    }
  } else if (body_id instanceof Projectile) {
    let n = body_id[0];
    return "projectile_" + $int.to_string(n);
  } else if (body_id instanceof Wall) {
    let n = body_id[0];
    return "wall_" + $int.to_string(n);
  } else if (body_id instanceof Floor) {
    let n = body_id[0];
    return "floor_" + $int.to_string(n);
  } else {
    let n = body_id[0];
    return "altar_" + $int.to_string(n);
  }
}

export function from_string(s) {
  if (s === "player") {
    return new Player();
  } else {
    let $ = $string.split(s, "_");
    if ($ instanceof $Empty) {
      throw makeError(
        "panic",
        FILEPATH,
        "client/id",
        62,
        "from_string",
        "Unknown Id",
        {}
      )
    } else {
      let $1 = $.tail;
      if ($1 instanceof $Empty) {
        throw makeError(
          "panic",
          FILEPATH,
          "client/id",
          62,
          "from_string",
          "Unknown Id",
          {}
        )
      } else {
        let $2 = $1.tail;
        if ($2 instanceof $Empty) {
          let $3 = $.head;
          if ($3 === "enemy") {
            let id_str = $1.head;
            let $4 = $int.parse(id_str);
            if ($4 instanceof Ok) {
              let id = $4[0];
              return new Enemy(id);
            } else {
              throw makeError(
                "panic",
                FILEPATH,
                "client/id",
                35,
                "from_string",
                "Unknown enemy Id",
                {}
              )
            }
          } else if ($3 === "projectile") {
            let id_str = $1.head;
            let $4 = $int.parse(id_str);
            if ($4 instanceof Ok) {
              let id = $4[0];
              return new Projectile(id);
            } else {
              throw makeError(
                "panic",
                FILEPATH,
                "client/id",
                45,
                "from_string",
                "Unknown projectile Id",
                {}
              )
            }
          } else if ($3 === "wall") {
            let id_str = $1.head;
            let $4 = $int.parse(id_str);
            if ($4 instanceof Ok) {
              let id = $4[0];
              return new Wall(id);
            } else {
              throw makeError(
                "panic",
                FILEPATH,
                "client/id",
                50,
                "from_string",
                "Unknown fortified wall Id",
                {}
              )
            }
          } else if ($3 === "floor") {
            let id_str = $1.head;
            let $4 = $int.parse(id_str);
            if ($4 instanceof Ok) {
              let id = $4[0];
              return new Floor(id);
            } else {
              throw makeError(
                "panic",
                FILEPATH,
                "client/id",
                55,
                "from_string",
                "Unknown floor Id",
                {}
              )
            }
          } else if ($3 === "altar") {
            let id_str = $1.head;
            let $4 = $int.parse(id_str);
            if ($4 instanceof Ok) {
              let id = $4[0];
              return new Altar(id);
            } else {
              throw makeError(
                "panic",
                FILEPATH,
                "client/id",
                60,
                "from_string",
                "Unknown altar Id",
                {}
              )
            }
          } else {
            throw makeError(
              "panic",
              FILEPATH,
              "client/id",
              62,
              "from_string",
              "Unknown Id",
              {}
            )
          }
        } else {
          let $3 = $2.tail;
          if ($3 instanceof $Empty) {
            let $4 = $.head;
            if ($4 === "enemy") {
              let $5 = $1.head;
              if ($5 === "health") {
                let id_str = $2.head;
                let $6 = $int.parse(id_str);
                if ($6 instanceof Ok) {
                  let id = $6[0];
                  return new EnemyHealth(new Enemy(id));
                } else {
                  throw makeError(
                    "panic",
                    FILEPATH,
                    "client/id",
                    40,
                    "from_string",
                    "Unknown enemy health Id",
                    {}
                  )
                }
              } else {
                throw makeError(
                  "panic",
                  FILEPATH,
                  "client/id",
                  62,
                  "from_string",
                  "Unknown Id",
                  {}
                )
              }
            } else {
              throw makeError(
                "panic",
                FILEPATH,
                "client/id",
                62,
                "from_string",
                "Unknown Id",
                {}
              )
            }
          } else {
            throw makeError(
              "panic",
              FILEPATH,
              "client/id",
              62,
              "from_string",
              "Unknown Id",
              {}
            )
          }
        }
      }
    }
  }
}
