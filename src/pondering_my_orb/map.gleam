import gleam/int
import gleam/list
import gleam/option
import pondering_my_orb/id.{type Id}
import tiramisu/asset
import tiramisu/geometry
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import vec/vec3.{type Vec3, Vec3}

// Map configuration
pub const tile_size = 4.0

pub const tiles_width = 10

pub const tiles_depth = 10

pub opaque type Map {
  Map(
    floor_tile: asset.Object3D,
    tiles: List(Tile),
    tower_base: asset.Object3D,
    tower_middle: asset.Object3D,
    tower_top: asset.Object3D,
    tower_edge: asset.Object3D,
    crate: asset.Object3D,
    crate_small: asset.Object3D,
    barrel: asset.Object3D,
    stairs_stone: asset.Object3D,
    stairs_wood: asset.Object3D,
    bricks: asset.Object3D,
  )
}

pub type Tile {
  Tile(x: Int, z: Int)
}

/// Generate a grid of floor tiles
pub fn generate(
  floor_tile: asset.Object3D,
  tower_base: asset.Object3D,
  tower_middle: asset.Object3D,
  tower_edge: asset.Object3D,
  tower_top: asset.Object3D,
  crate: asset.Object3D,
  crate_small: asset.Object3D,
  barrel: asset.Object3D,
  stairs_stone: asset.Object3D,
  stairs_wood: asset.Object3D,
  bricks: asset.Object3D,
) -> Map {
  let half_width = tiles_width / 2
  let half_depth = tiles_depth / 2

  let tiles =
    list.range(-half_width, half_width - 1)
    |> list.flat_map(fn(x) {
      list.range(-half_depth, half_depth - 1)
      |> list.map(fn(z) { Tile(x:, z:) })
    })

  Map(
    floor_tile:,
    tiles:,
    tower_base:,
    tower_middle:,
    tower_top:,
    tower_edge:,
    crate:,
    crate_small:,
    barrel:,
    stairs_stone:,
    stairs_wood:,
    bricks:,
  )
}

/// Create transform for a single tile position
fn tile_transform(tile: Tile) -> transform.Transform {
  let world_x = int.to_float(tile.x) *. tile_size
  let world_z = int.to_float(tile.z) *. tile_size
  transform.at(Vec3(
    world_x +. tile_size *. 0.5,
    0.0,
    world_z +. tile_size *. 0.5,
  ))
  |> transform.scale_uniform(tile_size /. 100.0)
}

/// Create a large floor collider containing all tiles
fn create_floor_rigidbody() -> scene.Node(Id) {
  let floor_width = int.to_float(tiles_width) *. tile_size
  let floor_depth = int.to_float(tiles_depth) *. tile_size

  // Create an invisible box geometry for the collider
  let assert Ok(geo) =
    geometry.box(width: floor_width, height: 0.5, depth: floor_depth)
  let assert Ok(mat) =
    material.new()
    |> material.with_color(0x00ff00)
    |> material.with_opacity(0.0)
    |> material.with_transparent(True)
    |> material.build()

  scene.mesh(
    id: id.ground(),
    geometry: geo,
    material: mat,
    transform: transform.at(Vec3(0.0, -0.25, 0.0)),
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.identity,
        width: floor_width,
        height: 0.5,
        depth: floor_depth,
      ))
      |> physics.build(),
    ),
  )
}

/// Create the visual parts of the tower structure
fn create_tower_visuals(
  id: Int,
  map: Map,
  tower_pos: Vec3(Float),
) -> scene.Node(Id) {
  scene.empty(id.tower(id), transform.at(tower_pos), [
    // Base
    scene.model_3d(
      id: id.tower(id + 1),
      transform: transform.at(vec3.Vec3(0.0, tile_size *. 0.5, 0.0))
        |> transform.scale_uniform(tile_size /. 100.0),
      object: map.tower_base,
      physics: option.None,
      material: option.None,
      animation: option.None,
    ),
    // Middle section
    scene.model_3d(
      id: id.tower(id + 2),
      transform: transform.at(Vec3(0.0, tile_size *. 1.5, 0.0))
        |> transform.scale_uniform(tile_size /. 100.0),
      object: map.tower_middle,
      physics: option.None,
      material: option.None,
      animation: option.None,
    ),
    // Edge
    scene.model_3d(
      id: id.tower(id + 3),
      transform: transform.at(Vec3(0.0, tile_size *. 2.0, 0.0))
        |> transform.scale_uniform(tile_size /. 100.0),
      object: map.tower_edge,
      physics: option.None,
      material: option.None,
      animation: option.None,
    ),
    // Top
    scene.model_3d(
      id: id.tower(id + 4),
      transform: transform.at(Vec3(0.0, tile_size *. 2.35, 0.0))
        |> transform.scale_uniform(tile_size /. 100.0),
      object: map.tower_top,
      physics: option.None,
      material: option.None,
      animation: option.None,
    ),
    create_tower_collider(),
  ])
}

/// Create the physics collider for the tower
fn create_tower_collider() -> scene.Node(Id) {
  // Tower dimensions
  let tower_width = tile_size
  let tower_height = tile_size *. 2.5
  let tower_depth = tile_size
  // Create an invisible box geometry for the collider
  let assert Ok(geo) =
    geometry.box(width: tower_width, height: tower_height, depth: tower_depth)
  let assert Ok(mat) =
    material.new()
    |> material.with_color(0xff0000)
    |> material.with_opacity(0.0)
    |> material.with_transparent(True)
    |> material.build()

  scene.mesh(
    id: id.tower(10_005),
    geometry: geo,
    material: mat,
    transform: transform.at(Vec3(0.0, tower_height /. 2.0, 0.0)),
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Cylinder(
        offset: transform.identity,
        half_height: tower_height /. 2.0,
        radius: tower_depth /. 2.0 +. 0.1,
      ))
      |> physics.build(),
    ),
  )
}

/// Create a crate at a specific position
fn create_crate(
  id_num: Int,
  map: Map,
  position: Vec3(Float),
  crate_type: CrateType,
) -> scene.Node(Id) {
  let #(crate_obj, size) = case crate_type {
    LargeCrate -> #(map.crate, tile_size *. 0.6)
    SmallCrate -> #(map.crate_small, tile_size *. 0.4)
    Barrel -> #(map.barrel, tile_size *. 0.5)
  }

  let height = size

  scene.empty(id.crate(id_num), transform.at(position), [
    // Visual model
    scene.model_3d(
      id: id.crate(id_num + 1),
      transform: transform.at(Vec3(0.0, height *. 0.5, 0.0))
        |> transform.scale_uniform(tile_size /. 100.0),
      object: crate_obj,
      physics: option.None,
      material: option.None,
      animation: option.None,
    ),
    // Physics collider
    create_crate_collider(id_num + 2, size /. 2.0, height /. 2.0),
  ])
}

/// Create physics collider for a crate
fn create_crate_collider(
  id_num: Int,
  size: Float,
  height: Float,
) -> scene.Node(Id) {
  let assert Ok(geo) = geometry.box(width: size, height:, depth: size)
  let assert Ok(mat) =
    material.new()
    |> material.with_color(0x00ff00)
    |> material.with_opacity(0.0)
    |> material.with_transparent(True)
    |> material.build()

  scene.mesh(
    id: id.crate(id_num),
    geometry: geo,
    material: mat,
    transform: transform.at(Vec3(0.0, height, 0.0)),
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.identity,
        width: size,
        height:,
        depth: size,
      ))
      |> physics.build(),
    ),
  )
}

pub type CrateType {
  LargeCrate
  SmallCrate
  Barrel
}

/// Create an elevation platform (stairs or bricks) at a specific position
fn create_elevation(
  id_num: Int,
  map: Map,
  position: Vec3(Float),
  elevation_type: ElevationType,
  rotation: Float,
) -> scene.Node(Id) {
  let #(elevation_obj, height) = case elevation_type {
    BrickPlatform -> #(map.bricks, tile_size *. 0.3)
  }

  let platform_width = tile_size /. 2.0
  let platform_depth = tile_size /. 2.0

  scene.empty(id.elevation(id_num), transform.at(position), [
    // Visual model
    scene.model_3d(
      id: id.elevation(id_num + 1),
      transform: transform.at(Vec3(0.0, height *. 0.5, 0.0))
        |> transform.rotate_y(rotation)
        |> transform.scale_uniform(tile_size /. 100.0),
      object: elevation_obj,
      physics: option.None,
      material: option.None,
      animation: option.None,
    ),
    // Physics collider
    create_elevation_collider(
      id_num + 2,
      platform_width,
      height,
      platform_depth,
    ),
  ])
}

/// Create physics collider for an elevation platform
fn create_elevation_collider(
  id_num: Int,
  width: Float,
  height: Float,
  depth: Float,
) -> scene.Node(Id) {
  let assert Ok(geo) = geometry.box(width:, height:, depth:)
  let assert Ok(mat) =
    material.new()
    |> material.with_color(0x0000ff)
    |> material.with_opacity(0.0)
    |> material.with_transparent(True)
    |> material.build()

  scene.mesh(
    id: id.elevation(id_num),
    geometry: geo,
    material: mat,
    transform: transform.at(Vec3(0.0, height /. 2.0, 0.0)),
    physics: option.Some(
      physics.new_rigid_body(physics.Fixed)
      |> physics.with_collider(physics.Box(
        offset: transform.identity,
        width:,
        height:,
        depth:,
      ))
      |> physics.build(),
    ),
  )
}

pub type ElevationType {
  BrickPlatform
}

/// View the entire tiled floor with instanced rendering
pub fn view(map: Map) -> List(scene.Node(Id)) {
  let tile_transforms = map.tiles |> list.map(tile_transform)

  // Tower position at corner of the map
  let tower_pos = Vec3(-10.0, 0.0, -10.0)

  // Create crates scattered around the map
  let crates = [
    // Near the spawn area
    create_crate(20_000, map, Vec3(-6.0, 0.0, -6.0), LargeCrate),
    create_crate(20_010, map, Vec3(8.0, 0.0, -8.0), Barrel),
    create_crate(20_020, map, Vec3(-8.0, 0.0, 8.0), SmallCrate),
    // Near the edges
    create_crate(20_030, map, Vec3(12.0, 0.0, 12.0), LargeCrate),
    create_crate(20_040, map, Vec3(-12.0, 0.0, 12.0), Barrel),
    create_crate(20_050, map, Vec3(0.0, 0.0, -12.0), SmallCrate),
    // Additional decoration
    create_crate(20_060, map, Vec3(6.0, 0.0, 6.0), LargeCrate),
    create_crate(20_070, map, Vec3(-4.0, 0.0, 0.0), Barrel),
  ]

  // Create elevation platforms
  let elevations = [
    create_elevation(30_010, map, Vec3(14.0, 0.0, -6.0), BrickPlatform, 0.0),
    create_elevation(30_030, map, Vec3(-14.0, 0.0, 6.0), BrickPlatform, 0.0),
    // Additional platforms for jumping
    create_elevation(30_040, map, Vec3(0.0, 0.0, 14.0), BrickPlatform, 0.0),
    create_elevation(30_050, map, Vec3(4.0, 0.0, -8.0), BrickPlatform, 0.0),
  ]

  list.flatten([
    [
      scene.instanced_model(
        id: id.map(),
        object: map.floor_tile,
        instances: tile_transforms,
        physics: option.None,
        material: option.None,
      ),
      create_floor_rigidbody(),
      create_tower_visuals(10_000, map, tower_pos),
    ],
    crates,
    elevations,
  ])
}

/// Get spawn position on top of the floor
pub fn get_spawn_position() -> Vec3(Float) {
  // Spawn at center, just above the floor
  Vec3(0.0, 2.0, 0.0)
}
