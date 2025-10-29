import gleam/float
import gleam/option.{None, Some}
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

  let target_camera_position =
    Vec3(
      player.position.x +. behind_x,
      player.position.y +. camera.height +. vertical_offset,
      player.position.z +. behind_z,
    )

  // Lerp camera position towards target (smooth follow)
  let lerp_speed = 25.0
  let lerp_factor = float.min(1.0, lerp_speed *. delta_time /. 1000.0)

  let new_position =
    Vec3(
      camera.position.x
        +. { target_camera_position.x -. camera.position.x }
        *. lerp_factor,
      camera.position.y
        +. { target_camera_position.y -. camera.position.y }
        *. lerp_factor,
      camera.position.z
        +. { target_camera_position.z -. camera.position.z }
        *. lerp_factor,
    )

  // Calculate camera rotation quaternion by looking at the player
  let look_at_target =
    Vec3(player.position.x, player.position.y +. 1.0, player.position.z)
  let from_transform = transform.at(position: new_position)
  let to_transform = transform.at(position: look_at_target)
  let look_at_transform =
    transform.look_at(from: from_transform, to: to_transform, up: option.None)
  let rotation = transform.rotation_quaternion(look_at_transform)

  Camera(
    ..camera,
    shake_time:,
    position: new_position,
    rotation:,
    pitch: new_pitch,
  )
}

pub fn view(camera: Camera, player: player.Player) {
  let assert Ok(cam) =
    camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  let Vec3(player_x, player_y, player_z) = player.position

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

  let look_at_target = Vec3(player_x, player_y +. 1.0, player_z)
  let camera =
    scene.camera(
      id: id.camera(),
      camera: cam,
      transform: transform.at(position: camera_position),
      look_at: Some(look_at_target),
      active: True,
      viewport: None,
      postprocessing: option.Some(
        postprocessing.new()
        |> postprocessing.add_pass(postprocessing.clear_pass(option.None))
        |> postprocessing.add_pass(postprocessing.render_pass())
        // Bloom effect for glowing projectiles and explosions
        |> postprocessing.add_pass(postprocessing.bloom(
          strength: 0.2,
          threshold: 0.7,
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
  camera
}
