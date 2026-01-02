import gleam/int
import gleam/string

pub type Id {
  Player
  Enemy(Int)
  EnemyHealth(Id)
  Projectile(Int)
  Wall(Int)
  Floor(Int)
}

pub fn to_string(body_id: Id) -> String {
  case body_id {
    Player -> "player"
    Enemy(n) -> "enemy_" <> int.to_string(n)
    EnemyHealth(Enemy(id)) -> "enemy_health_" <> int.to_string(id)
    Projectile(n) -> "projectile_" <> int.to_string(n)
    Wall(n) -> "wall_" <> int.to_string(n)
    Floor(n) -> "floor_" <> int.to_string(n)
    _ -> panic as "Unknown Id"
  }
}

pub fn from_string(s: String) -> Id {
  case s {
    "player" -> Player
    _ ->
      case string.split(s, "_") {
        ["enemy", id_str] ->
          case int.parse(id_str) {
            Ok(id) -> Enemy(id)
            Error(_) -> panic as "Unknown enemy Id"
          }
        ["enemy", "health", id_str] ->
          case int.parse(id_str) {
            Ok(id) -> EnemyHealth(Enemy(id))
            Error(_) -> panic as "Unknown enemy health Id"
          }
        ["projectile", id_str] ->
          case int.parse(id_str) {
            Ok(id) -> Projectile(id)
            Error(_) -> panic as "Unknown projectile Id"
          }
        ["wall", id_str] ->
          case int.parse(id_str) {
            Ok(id) -> Wall(id)
            Error(_) -> panic as "Unknown fortified wall Id"
          }
        ["floor", id_str] ->
          case int.parse(id_str) {
            Ok(id) -> Floor(id)
            Error(_) -> panic as "Unknown fortified wall Id"
          }
        _ -> panic as "Unknown Id"
      }
  }
}
