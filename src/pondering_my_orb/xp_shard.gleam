import gleam_community/maths
import pondering_my_orb/id.{type Id}
import tiramisu/scene
import tiramisu/spritesheet
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f

/// XP amount gained from a single shard
pub const xp_value = 10

pub type XPShard {
  XPShard(
    id: Int,
    position: Vec3(Float),
    animation_state: spritesheet.AnimationState,
  )
}

pub fn new(id: Int, position: Vec3(Float)) -> XPShard {
  XPShard(
    id: id,
    position: position,
    // Start with initial animation state - will be set properly when we have the spritesheet
    animation_state: spritesheet.initial_state("idle"),
  )
}

/// Update XP shard animation
pub fn update(
  shard: XPShard,
  animation: spritesheet.Animation,
  delta_time: Float,
) -> XPShard {
  let new_animation_state =
    spritesheet.update(shard.animation_state, animation, delta_time)

  XPShard(..shard, animation_state: new_animation_state)
}

/// Check if XP shard should be collected by player
pub fn should_collect(shard: XPShard, player_position: Vec3(Float)) -> Bool {
  let distance = vec3f.distance(shard.position, player_position)
  distance <. 1.25
}

/// Render XP shard with animated spritesheet
pub fn render(
  shard: XPShard,
  camera_position: Vec3(Float),
  sheet: spritesheet.Spritesheet,
  animation: spritesheet.Animation,
) -> scene.Node(Id) {
  // Calculate billboard rotation to face camera
  let to_camera = vec3f.subtract(camera_position, shard.position)
  let y_rotation = maths.atan2(to_camera.x, to_camera.z)

  scene.animated_sprite(
    id: id.xp_shard(shard.id),
    spritesheet: sheet,
    animation: animation,
    state: shard.animation_state,
    width: 0.6,
    height: 0.6,
    transform: transform.at(position: shard.position)
      |> transform.with_euler_rotation(Vec3(0.0, y_rotation, 0.0)),
    pixel_art: True,
  )
}
