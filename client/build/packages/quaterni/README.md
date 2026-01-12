# Quaterni

[![Package Version](https://img.shields.io/hexpm/v/quaterni)](https://hex.pm/packages/quaterni)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/quaterni/)

Pure Gleam quaternion math library for 3D rotations.

Quaternions are a mathematical representation of rotations in 3D space that:
- **Avoid gimbal lock** - no singularities in rotation representation  
- **Provide smooth interpolation** - spherical linear interpolation for natural animation
- **Are more compact** than rotation matrices (4 floats vs 9)
- **Compose efficiently** - quaternion multiplication is fast

## Installation

```sh
gleam add quaterni
```

## Quick Start

```gleam
import quaternion
import vec/vec3

// Create quaternion from axis-angle
let rotation = quaternion.from_axis_angle(vec3.Vec3(0.0, 1.0, 0.0), 1.57)

// Rotate a vector
let point = vec3.Vec3(1.0, 0.0, 0.0)
let rotated = quaternion.rotate(rotation, point)

// Interpolate between rotations
let halfway = quaternion.spherical_linear_interpolation(from: rot1, to: rot2, t: 0.5)
```

## Documentation

Full documentation can be found at <https://hexdocs.pm/quaterni>.

## Development

```sh
gleam test  # Run the test suite
gleam format  # Format code
```
