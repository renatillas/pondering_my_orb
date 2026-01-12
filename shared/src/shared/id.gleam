import gleam/int
import gleam/string

pub type Id {
  Player(Int)
  Enemy(Int)
  EnemyHealth(Id)
  Projectile(Int)
  Wall(Int)
  Floor(Int)
  Altar(Int)
  Room(Int)
}

pub fn to_string(body_id: Id) -> String {
  case body_id {
    Player(n) -> "player_" <> int.to_string(n)
    Enemy(n) -> "enemy_" <> int.to_string(n)
    EnemyHealth(Enemy(id)) -> "enemy_health_" <> int.to_string(id)
    Projectile(n) -> "projectile_" <> int.to_string(n)
    Wall(n) -> "wall_" <> int.to_string(n)
    Floor(n) -> "floor_" <> int.to_string(n)
    Altar(n) -> "altar_" <> int.to_string(n)
    _ -> panic as "Unknown Id"
  }
}

pub fn from_string(s: String) -> Id {
  case string.split(s, "_") {
    ["player", id_str] -> {
      let assert Ok(id) = int.parse(id_str)
      Player(id)
    }
    ["enemy", id_str] -> {
      let assert Ok(id) = int.parse(id_str)
      Enemy(id)
    }
    ["enemy", "health", id_str] -> {
      let assert Ok(id) = int.parse(id_str)
      EnemyHealth(Enemy(id))
    }
    ["projectile", id_str] -> {
      let assert Ok(id) = int.parse(id_str)
      Projectile(id)
    }
    ["wall", id_str] -> {
      let assert Ok(id) = int.parse(id_str)
      Wall(id)
    }
    ["floor", id_str] -> {
      let assert Ok(id) = int.parse(id_str)
      Floor(id)
    }
    ["altar", id_str] -> {
      let assert Ok(id) = int.parse(id_str)
      Altar(id)
    }
    _ -> panic as "Unknown Id"
  }
}

pub fn to_serial(id: Id) -> Int {
  case id {
    Player(n) -> n
    Enemy(n) -> n
    EnemyHealth(Enemy(n)) -> n
    Projectile(n) -> n
    Wall(n) -> n
    Floor(n) -> n
    Altar(n) -> n
    Room(n) -> n
    _ -> panic
  }
}
