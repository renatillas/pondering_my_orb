import gleam/float
import gleam/option.{None}
import gleam_community/maths
import pondering_my_orb/id
import pondering_my_orb/player
import tiramisu/camera
import tiramisu/postprocessing
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}

pub type Camera {
  Camera(
    pointer_locked: Bool,
    distance: Float,
    height: Float,
    position: Vec3(Float),
    rotation: transform.Quaternion,
    shake_time: Float,
    pitch: Float,
  )
}

pub fn init() {
  Camera(
    pointer_locked: False,
    distance: 5.0,
    height: 2.0,
    position: Vec3(0.0, 7.0, -5.0),
    rotation: transform.Quaternion(x: 0.0, y: 0.0, z: 0.0, w: 1.0),
    shake_time: 0.0,
    pitch: 0.0,
  )
}

pub fn update(
  camera: Camera,
  new_pitch new_pitch: Float,
  player player: player.Player,
  delta_time delta_time: Float,
) {
  let shake_time = float.max(0.0, camera.shake_time -. delta_time /. 1000.0)

  let horizontal_distance = camera.distance *. maths.cos(new_pitch)
  let vertical_offset = camera.distance *. maths.sin(new_pitch)

  let behind_x = -1.0 *. maths.sin(player.rotation.y) *. horizontal_distance
  let behind_z = -1.0 *. maths.cos(player.rotation.y) *. horizontal_distance

  // Position camera directly behind player (no smoothing for responsive feel)
  let camera_position =
    Vec3(
      player.position.x +. behind_x,
      player.position.y +. camera.height +. vertical_offset,
      player.position.z +. behind_z,
    )

  // Calculate camera rotation by looking at the player (no smoothing)
  let look_at_target =
    Vec3(player.position.x, player.position.y +. 1.0, player.position.z)
  let from_transform = transform.at(position: camera_position)
  let to_transform = transform.at(position: look_at_target)
  let look_at_transform =
    transform.look_at(from: from_transform, to: to_transform, up: option.None)
  let rotation = transform.rotation_quaternion(look_at_transform)

  Camera(
    ..camera,
    shake_time:,
    position: camera_position,
    rotation:,
    pitch: new_pitch,
  )
}

pub fn view(camera: Camera) {
  let assert Ok(cam) =
    camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  // Use the smoothed camera position from model
  let base_camera_position = camera.position

  // Apply screen shake if active
  let camera_position = case camera.shake_time >. 0.0 {
    True -> {
      // Calculate shake intensity (stronger at start, fades out)
      let shake_intensity = camera.shake_time /. 0.03 *. 0.015

      // Random shake offset (using position as seed for pseudo-randomness)
      let shake_x = { float.random() -. 0.5 } *. shake_intensity
      let shake_y = { float.random() -. 0.5 } *. shake_intensity
      let shake_z = { float.random() -. 0.5 } *. shake_intensity

      Vec3(
        base_camera_position.x +. shake_x,
        base_camera_position.y +. shake_y,
        base_camera_position.z +. shake_z,
      )
    }
    False -> base_camera_position
  }

  // Use the smoothed rotation from camera model instead of recalculating look-at
  let camera_transform =
    transform.at(position: camera_position)
    |> transform.with_quaternion_rotation(camera.rotation)

  let camera_node =
    scene.camera(
      id: id.camera(),
      camera: cam,
      transform: camera_transform,
      look_at: option.None,
      active: True,
      viewport: None,
      postprocessing: option.Some(
        postprocessing.new()
        |> postprocessing.add_pass(postprocessing.clear_pass(option.None))
        |> postprocessing.add_pass(postprocessing.render_pass())
        // Bloom effect for glowing projectiles and explosions
        |> postprocessing.add_pass(postprocessing.bloom(
          strength: 0.3,
          threshold: 0.5,
          radius: 0.5,
        ))
        |> postprocessing.add_pass(postprocessing.color_correction(
          brightness: 0.05,
          contrast: 0.15,
          saturation: 0.2,
        ))
        |> postprocessing.add_pass(postprocessing.pixelate(2))
        |> postprocessing.add_pass(postprocessing.fxaa())
        |> postprocessing.add_pass(postprocessing.output_pass()),
      ),
    )
  camera_node
}
