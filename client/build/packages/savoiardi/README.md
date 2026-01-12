# Savoiardi

[![Package Version](https://img.shields.io/hexpm/v/savoiardi)](https://hex.pm/packages/savoiardi)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/savoiardi/)

Type-safe [Three.js](https://threejs.org/) bindings for Gleam, part of the [tiramisu](https://github.com/renatillas/tiramisu) game engine ecosystem.

## Installation

```sh
gleam add savoiardi
```

## Quick Start

```gleam
import savoiardi
import gleam/option

pub fn main() {
  let renderer = savoiardi.create_renderer(savoiardi.default_renderer_options())

  let scene = savoiardi.create_scene()
    |> savoiardi.set_scene_background_color(0x1a1a2e)

  let camera = savoiardi.create_perspective_camera(75.0, 16.0 /. 9.0, 0.1, 1000.0)

  let geometry = savoiardi.create_box_geometry(1.0, 1.0, 1.0)
  let material = savoiardi.create_basic_material(0xff0000, False, 1.0, option.None)
  let cube = savoiardi.create_mesh(geometry, material)

  savoiardi.add_to_scene(scene: scene, object: cube)
  savoiardi.render(renderer, scene, camera)
}
```

## Features

- **Scene & Renderer** - WebGL rendering with configurable options
- **Cameras** - Perspective and orthographic
- **Geometries** - Box, sphere, plane, cylinder, torus, text, and more
- **Materials** - Basic, PBR, phong, lambert, toon
- **Lights** - Ambient, directional, point, spot, hemisphere
- **Textures** - Loading, filtering, wrapping modes
- **Animation** - Mixers and actions for skeletal/keyframe animation
- **Audio** - Global and positional 3D audio with fade effects
- **Asset Loading** - GLTF, FBX, OBJ, STL, fonts
- **LOD & Instancing** - Level of detail and instanced rendering
- **Particles** - Points-based particle systems
- **CSS Renderers** - CSS2D and CSS3D overlays

## Related Packages

- [vec](https://hexdocs.pm/vec) - Vector mathematics
- [quaterni](https://hexdocs.pm/quaterni) - Quaternion rotations
- [tiramisu](https://github.com/renatillas/tiramisu) - Full game engine

## Documentation

Full API documentation available at [HexDocs](https://hexdocs.pm/savoiardi).
