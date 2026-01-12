/// Shared projectile types for client-server communication.
/// Server-authoritative projectile state that is synchronized over the network.
import gleam/dynamic/decode
import gleam/json
import shared/id
import shared/vec3 as shared_vec3
import vec/vec3

/// Core projectile state synchronized between client and server.
/// The server is authoritative for this data.
pub type Projectile {
  Projectile(
    id: Int,
    owner_id: id.Id,
    position: vec3.Vec3(Float),
    direction: vec3.Vec3(Float),
    damage: Float,
    speed: Float,
    size: Float,
    lifetime: Float,
  )
}

// ----------------------------------------------------------------------------
// JSON Encoding
// ----------------------------------------------------------------------------

/// Encode a Projectile to JSON for network transmission.
pub fn encode(projectile: Projectile) -> json.Json {
  let assert id.Player(owner) = projectile.owner_id
  json.object([
    #("id", json.int(projectile.id)),
    #("owner_id", json.int(owner)),
    #("position", shared_vec3.encode(projectile.position)),
    #("direction", shared_vec3.encode(projectile.direction)),
    #("damage", json.float(projectile.damage)),
    #("speed", json.float(projectile.speed)),
    #("size", json.float(projectile.size)),
    #("lifetime", json.float(projectile.lifetime)),
  ])
}

// ----------------------------------------------------------------------------
// JSON Decoding
// ----------------------------------------------------------------------------

/// Decoder for Projectile from JSON.
pub fn decoder() -> decode.Decoder(Projectile) {
  use id <- decode.field("id", decode.int)
  use owner_id <- decode.field("owner_id", decode.int)
  use position <- decode.field("position", shared_vec3.decoder())
  use direction <- decode.field("direction", shared_vec3.decoder())
  use damage <- decode.field("damage", decode.float)
  use speed <- decode.field("speed", decode.float)
  use size <- decode.field("size", decode.float)
  use lifetime <- decode.field("lifetime", decode.float)
  decode.success(Projectile(
    id,
    id.Player(owner_id),
    position,
    direction,
    damage,
    speed,
    size,
    lifetime,
  ))
}
