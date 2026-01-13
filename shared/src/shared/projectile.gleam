import gleam/dynamic/decode
import gleam/float
import gleam/json
import gleam/option.{type Option}
import gleam/time/duration
import shared/player
import shared/spell
import shared/vec3 as shared_vec3
import vec/vec2
import vec/vec3.{type Vec3}

// =============================================================================
// TYPES
// =============================================================================

pub type Projectile {
  Projectile(
    id: Id,
    owner_id: player.Id,
    spell: spell.ModifiedSpell,
    position: Vec3(Float),
    velocity: Vec3(Float),
    time_alive: duration.Duration,
    visuals: spell.SpellVisuals,
    trigger_payload: Option(spell.ModifiedSpell),
  )
}

pub type Id {
  Id(Int)
}

// =============================================================================
// JSON ENCODING / DECODING
// =============================================================================

/// Encode a Projectile to JSON for network transmission
/// Note: For MVP we send simplified projectile data
pub fn encode(proj: Projectile) -> json.Json {
  let Id(proj_id) = proj.id
  let player.Id(owner_id_int) = proj.owner_id
  let time_alive_ms =
    duration.to_seconds(proj.time_alive) *. 1000.0 |> float.round

  json.object([
    #("id", json.int(proj_id)),
    #("owner_id", json.int(owner_id_int)),
    #("position", shared_vec3.encode(proj.position)),
    #("velocity", shared_vec3.encode(proj.velocity)),
    #("time_alive_ms", json.int(time_alive_ms)),
    // TODO: Encode spell data when needed for rendering
  ])
}

/// Decoder for Projectile from JSON
pub fn decoder() -> decode.Decoder(Projectile) {
  use id <- decode.field("id", decode.int)
  use owner_id <- decode.field("owner_id", decode.int)
  use position <- decode.field("position", shared_vec3.decoder())
  use velocity <- decode.field("velocity", shared_vec3.decoder())
  use time_alive_ms <- decode.field("time_alive_ms", decode.int)

  // For MVP, create a minimal projectile (spell data will be added later)
  decode.success(Projectile(
    id: Id(id),
    owner_id: player.Id(owner_id),
    spell: create_placeholder_spell(),
    position: position,
    velocity: velocity,
    time_alive: duration.milliseconds(time_alive_ms),
    visuals: create_placeholder_visuals(),
    trigger_payload: option.None,
  ))
}

// =============================================================================
// HELPERS
// =============================================================================

fn create_placeholder_spell() -> spell.ModifiedSpell {
  // Placeholder for MVP - will be replaced with real spell data
  spell.ModifiedSpell(
    base: spell.spark(),
    final_damage: 0.0,
    final_speed: 0.0,
    final_size: 1.0,
    final_lifetime: duration.seconds(1),
    final_cast_delay: duration.milliseconds(0),
    final_recharge_time: duration.milliseconds(0),
    final_critical_chance: 0.0,
    final_spread: 0.0,
    total_mana_cost: 0.0,
  )
}

fn create_placeholder_visuals() -> spell.SpellVisuals {
  spell.SpellVisuals(
    projectile: spell.StaticSprite(
      texture_path: "spell_projectiles/spark.png",
      size: vec2.Vec2(1.0, 1.0),
    ),
    hit_effect: spell.NoEffect,
    base_tint: 0xFFFFFF,
    emissive_intensity: 1.0,
  )
}
