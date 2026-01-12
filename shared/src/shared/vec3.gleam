/// Vec3 JSON encoding/decoding utilities for network transmission.
import gleam/dynamic/decode
import gleam/json
import vec/vec3.{type Vec3, Vec3}

/// Encode a Vec3(Float) to JSON.
pub fn encode(v: Vec3(Float)) -> json.Json {
  json.object([
    #("x", json.float(v.x)),
    #("y", json.float(v.y)),
    #("z", json.float(v.z)),
  ])
}

/// Decoder for Vec3(Float) from JSON.
pub fn decoder() -> decode.Decoder(Vec3(Float)) {
  use x <- decode.field("x", decode.float)
  use y <- decode.field("y", decode.float)
  use z <- decode.field("z", decode.float)
  decode.success(Vec3(x, y, z))
}
