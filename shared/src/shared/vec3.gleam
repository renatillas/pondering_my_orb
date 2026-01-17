/// Vec3 JSON encoding/decoding utilities for network transmission.
import gleam/dynamic/decode
import gleam/int
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

/// Decoder for a float that also accepts integers (e.g., 1 instead of 1.0)
fn float_or_int_decoder() -> decode.Decoder(Float) {
  decode.one_of(decode.float, [
    decode.int
    |> decode.map(int.to_float),
  ])
}

/// Decoder for Vec3(Float) from JSON.
/// Accepts both floats and integers (e.g., {"x": 1, "y": 2.5, "z": 3})
pub fn decoder() -> decode.Decoder(Vec3(Float)) {
  use x <- decode.field("x", float_or_int_decoder())
  use y <- decode.field("y", float_or_int_decoder())
  use z <- decode.field("z", float_or_int_decoder())
  decode.success(Vec3(x, y, z))
}

/// Linear interpolation between two Vec3 positions
pub fn lerp(from: Vec3(Float), to: Vec3(Float), t: Float) -> Vec3(Float) {
  Vec3(
    from.x +. { { to.x -. from.x } *. t },
    from.y +. { { to.y -. from.y } *. t },
    from.z +. { { to.z -. from.z } *. t },
  )
}
