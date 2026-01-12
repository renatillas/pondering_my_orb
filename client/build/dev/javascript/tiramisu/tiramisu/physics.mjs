import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $quaternion from "../../quaterni/quaternion.mjs";
import * as $vec3 from "../../vec/vec/vec3.mjs";
import {
  Ok,
  Error,
  toList,
  prepend as listPrepend,
  CustomType as $CustomType,
  makeError,
} from "../gleam.mjs";
import {
  addBodyForce as add_body_force_ffi,
  applyBodyImpulse as apply_body_impulse_ffi,
  setBodyLinvel as set_body_linvel_ffi,
  getBodyLinvel as get_body_linvel_ffi,
  setBodyAngvel as set_body_angvel_ffi,
  getBodyAngvel as get_body_angvel_ffi,
  addBodyTorque as add_body_torque_ffi,
  applyBodyTorqueImpulse as apply_body_torque_impulse_ffi,
  getBodyTranslation as get_body_translation_ffi,
  getBodyRotation as get_body_rotation_ffi,
  createRay as create_ray_ffi,
  castRayAndGetNormal as cast_ray_and_get_normal_ffi,
  rayPointAt as ray_point_at_ffi,
  getHitColliderHandle as get_hit_collider_handle_ffi,
  getHitToi as get_hit_toi_ffi,
  getHitNormal as get_hit_normal_ffi,
  createWorld as create_world_ffi,
  createEventQueue as create_event_queue_ffi,
  stepWorld as step_world_ffi,
  createDynamicBodyDesc as create_dynamic_body_desc_ffi,
  createKinematicBodyDesc as create_kinematic_body_desc_ffi,
  createFixedBodyDesc as create_fixed_body_desc_ffi,
  setBodyTranslation as set_body_desc_translation_ffi,
  setBodyRotation as set_body_desc_rotation_ffi,
  setBodyTranslation2 as set_body_translation_ffi,
  setBodyRotation2 as set_body_rotation_ffi,
  isBodySleeping as is_body_sleeping_ffi,
  setLinearDamping as set_linear_damping_ffi,
  setAngularDamping as set_angular_damping_ffi,
  setCCDEnabled as set_ccd_enabled_ffi,
  setEnabledTranslations as set_enabled_translations_ffi,
  setEnabledRotations as set_enabled_rotations_ffi,
  createRigidBody as create_rigid_body_ffi,
  removeRigidBody as remove_rigid_body_ffi,
  createCuboidColliderDesc as create_cuboid_collider_desc_ffi,
  createBallColliderDesc as create_ball_collider_desc_ffi,
  createCapsuleColliderDesc as create_capsule_collider_desc_ffi,
  createCylinderColliderDesc as create_cylinder_collider_desc_ffi,
  setColliderRestitution as set_collider_restitution_ffi,
  setColliderFriction as set_collider_friction_ffi,
  setColliderMass as set_collider_mass_ffi,
  setColliderCollisionGroups as set_collider_collision_groups_ffi,
  setColliderActiveEvents as set_collider_active_events_ffi,
  getActiveEvents as get_active_events_ffi,
  setColliderSensor as set_collider_sensor_ffi,
  setColliderTranslation as set_collider_translation_ffi,
  setColliderRotation as set_collider_rotation_ffi,
  createCollider as create_collider_ffi,
  getColliderHandle as get_collider_handle_ffi,
  getBodyNumColliders as get_body_num_colliders_ffi,
  getBodyCollider as get_body_collider_ffi,
  drainCollisionEventsToList as drain_collision_events_ffi,
  createCharacterController as create_character_controller_ffi,
  setCharacterUpVector as set_character_up_vector_ffi,
  setCharacterSlide as set_character_slide_ffi,
  computeCharacterMovement as compute_character_movement_ffi,
  getCharacterComputedMovement as get_character_computed_movement_ffi,
  getCharacterComputedGrounded as get_character_computed_grounded_ffi,
  setBodyNextKinematicTranslation as set_body_next_kinematic_translation_ffi,
} from "../rapier.ffi.mjs";
import * as $transform from "../tiramisu/transform.mjs";

const FILEPATH = "src/tiramisu/physics.gleam";

class PhysicsWorld extends $CustomType {
  constructor(world, queue, bodies, rapier_bodies, pending_commands, collider_to_body, collision_events, character_controllers) {
    super();
    this.world = world;
    this.queue = queue;
    this.bodies = bodies;
    this.rapier_bodies = rapier_bodies;
    this.pending_commands = pending_commands;
    this.collider_to_body = collider_to_body;
    this.collision_events = collision_events;
    this.character_controllers = character_controllers;
  }
}

class ApplyForce extends $CustomType {
  constructor(id, force) {
    super();
    this.id = id;
    this.force = force;
  }
}

class ApplyImpulse extends $CustomType {
  constructor(id, impulse) {
    super();
    this.id = id;
    this.impulse = impulse;
  }
}

class SetVelocity extends $CustomType {
  constructor(id, velocity) {
    super();
    this.id = id;
    this.velocity = velocity;
  }
}

class SetAngularVelocity extends $CustomType {
  constructor(id, velocity) {
    super();
    this.id = id;
    this.velocity = velocity;
  }
}

class ApplyTorque extends $CustomType {
  constructor(id, torque) {
    super();
    this.id = id;
    this.torque = torque;
  }
}

class ApplyTorqueImpulse extends $CustomType {
  constructor(id, impulse) {
    super();
    this.id = id;
    this.impulse = impulse;
  }
}

class SetKinematicTranslation extends $CustomType {
  constructor(id, position) {
    super();
    this.id = id;
    this.position = position;
  }
}

export class Dynamic extends $CustomType {}
export const Body$Dynamic = () => new Dynamic();
export const Body$isDynamic = (value) => value instanceof Dynamic;

export class Kinematic extends $CustomType {}
export const Body$Kinematic = () => new Kinematic();
export const Body$isKinematic = (value) => value instanceof Kinematic;

export class Fixed extends $CustomType {}
export const Body$Fixed = () => new Fixed();
export const Body$isFixed = (value) => value instanceof Fixed;

/**
 * Box collider with size (width, height, depth)
 */
export class Box extends $CustomType {
  constructor(offset, size) {
    super();
    this.offset = offset;
    this.size = size;
  }
}
export const ColliderShape$Box = (offset, size) => new Box(offset, size);
export const ColliderShape$isBox = (value) => value instanceof Box;
export const ColliderShape$Box$offset = (value) => value.offset;
export const ColliderShape$Box$0 = (value) => value.offset;
export const ColliderShape$Box$size = (value) => value.size;
export const ColliderShape$Box$1 = (value) => value.size;

/**
 * Sphere collider with radius
 */
export class Sphere extends $CustomType {
  constructor(offset, radius) {
    super();
    this.offset = offset;
    this.radius = radius;
  }
}
export const ColliderShape$Sphere = (offset, radius) =>
  new Sphere(offset, radius);
export const ColliderShape$isSphere = (value) => value instanceof Sphere;
export const ColliderShape$Sphere$offset = (value) => value.offset;
export const ColliderShape$Sphere$0 = (value) => value.offset;
export const ColliderShape$Sphere$radius = (value) => value.radius;
export const ColliderShape$Sphere$1 = (value) => value.radius;

/**
 * Capsule collider (cylinder with rounded caps)
 */
export class Capsule extends $CustomType {
  constructor(offset, half_height, radius) {
    super();
    this.offset = offset;
    this.half_height = half_height;
    this.radius = radius;
  }
}
export const ColliderShape$Capsule = (offset, half_height, radius) =>
  new Capsule(offset, half_height, radius);
export const ColliderShape$isCapsule = (value) => value instanceof Capsule;
export const ColliderShape$Capsule$offset = (value) => value.offset;
export const ColliderShape$Capsule$0 = (value) => value.offset;
export const ColliderShape$Capsule$half_height = (value) => value.half_height;
export const ColliderShape$Capsule$1 = (value) => value.half_height;
export const ColliderShape$Capsule$radius = (value) => value.radius;
export const ColliderShape$Capsule$2 = (value) => value.radius;

/**
 * Cylinder collider
 */
export class Cylinder extends $CustomType {
  constructor(offset, half_height, radius) {
    super();
    this.offset = offset;
    this.half_height = half_height;
    this.radius = radius;
  }
}
export const ColliderShape$Cylinder = (offset, half_height, radius) =>
  new Cylinder(offset, half_height, radius);
export const ColliderShape$isCylinder = (value) => value instanceof Cylinder;
export const ColliderShape$Cylinder$offset = (value) => value.offset;
export const ColliderShape$Cylinder$0 = (value) => value.offset;
export const ColliderShape$Cylinder$half_height = (value) => value.half_height;
export const ColliderShape$Cylinder$1 = (value) => value.half_height;
export const ColliderShape$Cylinder$radius = (value) => value.radius;
export const ColliderShape$Cylinder$2 = (value) => value.radius;

export const ColliderShape$offset = (value) => value.offset;

export class AxisLock extends $CustomType {
  constructor(lock_translation_x, lock_translation_y, lock_translation_z, lock_rotation_x, lock_rotation_y, lock_rotation_z) {
    super();
    this.lock_translation_x = lock_translation_x;
    this.lock_translation_y = lock_translation_y;
    this.lock_translation_z = lock_translation_z;
    this.lock_rotation_x = lock_rotation_x;
    this.lock_rotation_y = lock_rotation_y;
    this.lock_rotation_z = lock_rotation_z;
  }
}
export const AxisLock$AxisLock = (lock_translation_x, lock_translation_y, lock_translation_z, lock_rotation_x, lock_rotation_y, lock_rotation_z) =>
  new AxisLock(lock_translation_x,
  lock_translation_y,
  lock_translation_z,
  lock_rotation_x,
  lock_rotation_y,
  lock_rotation_z);
export const AxisLock$isAxisLock = (value) => value instanceof AxisLock;
export const AxisLock$AxisLock$lock_translation_x = (value) =>
  value.lock_translation_x;
export const AxisLock$AxisLock$0 = (value) => value.lock_translation_x;
export const AxisLock$AxisLock$lock_translation_y = (value) =>
  value.lock_translation_y;
export const AxisLock$AxisLock$1 = (value) => value.lock_translation_y;
export const AxisLock$AxisLock$lock_translation_z = (value) =>
  value.lock_translation_z;
export const AxisLock$AxisLock$2 = (value) => value.lock_translation_z;
export const AxisLock$AxisLock$lock_rotation_x = (value) =>
  value.lock_rotation_x;
export const AxisLock$AxisLock$3 = (value) => value.lock_rotation_x;
export const AxisLock$AxisLock$lock_rotation_y = (value) =>
  value.lock_rotation_y;
export const AxisLock$AxisLock$4 = (value) => value.lock_rotation_y;
export const AxisLock$AxisLock$lock_rotation_z = (value) =>
  value.lock_rotation_z;
export const AxisLock$AxisLock$5 = (value) => value.lock_rotation_z;

export class CollisionGroups extends $CustomType {
  constructor(membership, filter) {
    super();
    this.membership = membership;
    this.filter = filter;
  }
}
export const CollisionGroups$CollisionGroups = (membership, filter) =>
  new CollisionGroups(membership, filter);
export const CollisionGroups$isCollisionGroups = (value) =>
  value instanceof CollisionGroups;
export const CollisionGroups$CollisionGroups$membership = (value) =>
  value.membership;
export const CollisionGroups$CollisionGroups$0 = (value) => value.membership;
export const CollisionGroups$CollisionGroups$filter = (value) => value.filter;
export const CollisionGroups$CollisionGroups$1 = (value) => value.filter;

export class CharacterController extends $CustomType {
  constructor(offset, up_vector, slide_enabled) {
    super();
    this.offset = offset;
    this.up_vector = up_vector;
    this.slide_enabled = slide_enabled;
  }
}
export const CharacterController$CharacterController = (offset, up_vector, slide_enabled) =>
  new CharacterController(offset, up_vector, slide_enabled);
export const CharacterController$isCharacterController = (value) =>
  value instanceof CharacterController;
export const CharacterController$CharacterController$offset = (value) =>
  value.offset;
export const CharacterController$CharacterController$0 = (value) =>
  value.offset;
export const CharacterController$CharacterController$up_vector = (value) =>
  value.up_vector;
export const CharacterController$CharacterController$1 = (value) =>
  value.up_vector;
export const CharacterController$CharacterController$slide_enabled = (value) =>
  value.slide_enabled;
export const CharacterController$CharacterController$2 = (value) =>
  value.slide_enabled;

class RigidBody extends $CustomType {
  constructor(kind, mass, restitution, friction, linear_damping, angular_damping, collider, ccd_enabled, axis_locks, collision_groups, character_controller, track_collision_events, is_sensor) {
    super();
    this.kind = kind;
    this.mass = mass;
    this.restitution = restitution;
    this.friction = friction;
    this.linear_damping = linear_damping;
    this.angular_damping = angular_damping;
    this.collider = collider;
    this.ccd_enabled = ccd_enabled;
    this.axis_locks = axis_locks;
    this.collision_groups = collision_groups;
    this.character_controller = character_controller;
    this.track_collision_events = track_collision_events;
    this.is_sensor = is_sensor;
  }
}

export class WorldConfig extends $CustomType {
  constructor(gravity) {
    super();
    this.gravity = gravity;
  }
}
export const WorldConfig$WorldConfig = (gravity) => new WorldConfig(gravity);
export const WorldConfig$isWorldConfig = (value) =>
  value instanceof WorldConfig;
export const WorldConfig$WorldConfig$gravity = (value) => value.gravity;
export const WorldConfig$WorldConfig$0 = (value) => value.gravity;

export class RaycastHit extends $CustomType {
  constructor(id, point, normal, distance) {
    super();
    this.id = id;
    this.point = point;
    this.normal = normal;
    this.distance = distance;
  }
}
export const RaycastHit$RaycastHit = (id, point, normal, distance) =>
  new RaycastHit(id, point, normal, distance);
export const RaycastHit$isRaycastHit = (value) => value instanceof RaycastHit;
export const RaycastHit$RaycastHit$id = (value) => value.id;
export const RaycastHit$RaycastHit$0 = (value) => value.id;
export const RaycastHit$RaycastHit$point = (value) => value.point;
export const RaycastHit$RaycastHit$1 = (value) => value.point;
export const RaycastHit$RaycastHit$normal = (value) => value.normal;
export const RaycastHit$RaycastHit$2 = (value) => value.normal;
export const RaycastHit$RaycastHit$distance = (value) => value.distance;
export const RaycastHit$RaycastHit$3 = (value) => value.distance;

/**
 * Two bodies started colliding
 */
export class CollisionStarted extends $CustomType {
  constructor(body_a, body_b) {
    super();
    this.body_a = body_a;
    this.body_b = body_b;
  }
}
export const CollisionEvent$CollisionStarted = (body_a, body_b) =>
  new CollisionStarted(body_a, body_b);
export const CollisionEvent$isCollisionStarted = (value) =>
  value instanceof CollisionStarted;
export const CollisionEvent$CollisionStarted$body_a = (value) => value.body_a;
export const CollisionEvent$CollisionStarted$0 = (value) => value.body_a;
export const CollisionEvent$CollisionStarted$body_b = (value) => value.body_b;
export const CollisionEvent$CollisionStarted$1 = (value) => value.body_b;

/**
 * Two bodies stopped colliding
 */
export class CollisionEnded extends $CustomType {
  constructor(body_a, body_b) {
    super();
    this.body_a = body_a;
    this.body_b = body_b;
  }
}
export const CollisionEvent$CollisionEnded = (body_a, body_b) =>
  new CollisionEnded(body_a, body_b);
export const CollisionEvent$isCollisionEnded = (value) =>
  value instanceof CollisionEnded;
export const CollisionEvent$CollisionEnded$body_a = (value) => value.body_a;
export const CollisionEvent$CollisionEnded$0 = (value) => value.body_a;
export const CollisionEvent$CollisionEnded$body_b = (value) => value.body_b;
export const CollisionEvent$CollisionEnded$1 = (value) => value.body_b;

export const CollisionEvent$body_a = (value) => value.body_a;
export const CollisionEvent$body_b = (value) => value.body_b;

class RigidBodyBuilder extends $CustomType {
  constructor(kind, collider, mass, restitution, friction, linear_damping, angular_damping, ccd_enabled, axis_locks, collision_groups, character_controller, track_collision_events, is_sensor) {
    super();
    this.kind = kind;
    this.collider = collider;
    this.mass = mass;
    this.restitution = restitution;
    this.friction = friction;
    this.linear_damping = linear_damping;
    this.angular_damping = angular_damping;
    this.ccd_enabled = ccd_enabled;
    this.axis_locks = axis_locks;
    this.collision_groups = collision_groups;
    this.character_controller = character_controller;
    this.track_collision_events = track_collision_events;
    this.is_sensor = is_sensor;
  }
}

/**
 * Create a new rigid body builder.
 *
 * Start here to build a physics body using the fluent builder pattern.
 * You must call `with_collider()` before `build()`.
 *
 * **Body Types:**
 * - `Dynamic`: Moves and responds to forces (balls, characters, props)
 * - `Kinematic`: Programmatically controlled, doesn't respond to forces (elevators, doors)
 * - `Fixed`: Static, immovable (walls, floors, terrain)
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/physics
 * import tiramisu/transform
 *
 * // Dynamic ball
 * let ball = physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_collider(physics.Sphere(
 *     offset: transform.identity,
 *     radius: 1.0,
 *   ))
 *   |> physics.with_mass(5.0)
 *   |> physics.with_restitution(0.8)
 *   |> physics.build()
 *
 * // Static ground
 * let ground = physics.new_rigid_body(physics.Fixed)
 *   |> physics.with_collider(physics.Box(
 *     offset: transform.identity,
 *     width: 50.0,
 *     height: 1.0,
 *     depth: 50.0,
 *   ))
 *   |> physics.build()
 * ```
 */
export function new_rigid_body(body_type) {
  return new RigidBodyBuilder(
    body_type,
    new $option.None(),
    new $option.None(),
    0.3,
    0.5,
    0.0,
    0.0,
    false,
    new AxisLock(false, false, false, false, false, false),
    new $option.None(),
    new $option.None(),
    false,
    false,
  );
}

export function with_collider(builder, collider) {
  return new RigidBodyBuilder(
    builder.kind,
    new $option.Some(collider),
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Set the mass in kilograms (for Dynamic bodies).
 *
 * **Mass** affects how forces and collisions influence the body.
 * Default: Calculated from volume and density if not specified.
 *
 * ## Example
 *
 * ```gleam
 * physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_mass(70.0)  // Average human = 70kg
 * ```
 */
export function with_mass(builder, mass) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    new $option.Some(mass),
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Set restitution (bounciness).
 *
 * **Restitution**: 0.0 = no bounce, 1.0 = perfect bounce (energy conserved)
 * Default: 0.3
 *
 * ## Example
 *
 * ```gleam
 * // Bouncy ball
 * physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_restitution(0.9)  // Very bouncy
 *
 * // Non-bouncy box
 * physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_restitution(0.1)  // Barely bounces
 * ```
 */
export function with_restitution(builder, restitution) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Set friction coefficient.
 *
 * **Friction**: 0.0 = ice (no friction), 1.0+ = very grippy
 * Default: 0.5
 *
 * ## Example
 *
 * ```gleam
 * // Slippery ice
 * physics.new_rigid_body(physics.Fixed)
 *   |> physics.with_friction(0.05)
 *
 * // Grippy rubber
 * physics.new_rigid_body(physics.Fixed)
 *   |> physics.with_friction(0.9)
 * ```
 */
export function with_friction(builder, friction) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Set linear damping (air resistance for translation).
 *
 * **Damping**: 0.0 = no resistance, higher = more drag
 * Useful for simulating air/water resistance. Default: 0.0
 *
 * ## Example
 *
 * ```gleam
 * // Underwater physics
 * physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_linear_damping(2.0)  // Heavy water resistance
 * ```
 */
export function with_linear_damping(builder, damping) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Set angular damping (air resistance for rotation).
 *
 * **Damping**: 0.0 = no resistance, higher = more drag
 * Prevents bodies from spinning forever. Default: 0.0
 */
export function with_angular_damping(builder, damping) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Enable Continuous Collision Detection (CCD).
 *
 * CCD prevents fast-moving objects from tunneling through thin obstacles.
 * Use for bullets, fast-moving balls, or high-velocity objects.
 *
 * ## Example
 *
 * ```gleam
 * // Bullet that shouldn't pass through walls
 * physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_collider(physics.Sphere(transform.identity, 0.1))
 *   |> physics.with_body_ccd_enabled()
 * ```
 */
export function with_body_ccd_enabled(builder) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    true,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Lock translation on the X axis
 */
export function with_lock_translation_x(builder) {
  let locks = builder.axis_locks;
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    new AxisLock(
      true,
      locks.lock_translation_y,
      locks.lock_translation_z,
      locks.lock_rotation_x,
      locks.lock_rotation_y,
      locks.lock_rotation_z,
    ),
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Lock translation on the Y axis
 */
export function with_lock_translation_y(builder) {
  let locks = builder.axis_locks;
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    new AxisLock(
      locks.lock_translation_x,
      true,
      locks.lock_translation_z,
      locks.lock_rotation_x,
      locks.lock_rotation_y,
      locks.lock_rotation_z,
    ),
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Lock translation on the Z axis
 */
export function with_lock_translation_z(builder) {
  let locks = builder.axis_locks;
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    new AxisLock(
      locks.lock_translation_x,
      locks.lock_translation_y,
      true,
      locks.lock_rotation_x,
      locks.lock_rotation_y,
      locks.lock_rotation_z,
    ),
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Lock rotation on the X axis (pitch)
 */
export function with_lock_rotation_x(builder) {
  let locks = builder.axis_locks;
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    new AxisLock(
      locks.lock_translation_x,
      locks.lock_translation_y,
      locks.lock_translation_z,
      true,
      locks.lock_rotation_y,
      locks.lock_rotation_z,
    ),
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Lock rotation on the Y axis (yaw)
 */
export function with_lock_rotation_y(builder) {
  let locks = builder.axis_locks;
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    new AxisLock(
      locks.lock_translation_x,
      locks.lock_translation_y,
      locks.lock_translation_z,
      locks.lock_rotation_x,
      true,
      locks.lock_rotation_z,
    ),
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Lock rotation on the Z axis (roll)
 */
export function with_lock_rotation_z(builder) {
  let locks = builder.axis_locks;
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    new AxisLock(
      locks.lock_translation_x,
      locks.lock_translation_y,
      locks.lock_translation_z,
      locks.lock_rotation_x,
      locks.lock_rotation_y,
      true,
    ),
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Set collision groups for filtering which objects can collide
 *
 * ## Example
 *
 * ```gleam
 * // Player belongs to layer 0, collides with enemies (1) and ground (2)
 * let body = physics.new_rigid_body(physics.Dynamic)
 *   |> physics.body_collider(physics.Capsule(1.0, 0.5))
 *   |> physics.body_collision_groups(
 *     membership: [0],
 *     filter: [1, 2]
 *   )
 *   |> physics.build_body()
 * ```
 */
export function with_collision_groups(builder, membership, filter) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    new $option.Some(new CollisionGroups(membership, filter)),
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Add a character controller for collision-aware kinematic movement.
 *
 * Character controllers are perfect for player characters and NPCs, providing:
 * - Automatic collision detection and response
 * - Sliding along surfaces
 * - Configurable offset from obstacles
 *
 * **Note**: Character controllers are only useful for Kinematic bodies.
 *
 * ## Example
 *
 * ```gleam
 * // Player character with character controller
 * let player = physics.new_rigid_body(physics.Kinematic)
 *   |> physics.with_collider(physics.Capsule(
 *     offset: transform.identity,
 *     half_height: 0.9,
 *     radius: 0.3,
 *   ))
 *   |> physics.with_character_controller(
 *     offset: 0.01,
 *     up_vector: vec3.Vec3(0.0, 1.0, 0.0),
 *     slide_enabled: True,
 *   )
 *   |> physics.build()
 * ```
 */
export function with_character_controller(
  builder,
  offset,
  up_vector,
  slide_enabled
) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    new $option.Some(new CharacterController(offset, up_vector, slide_enabled)),
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Enable collision event tracking for this body.
 *
 * By default, collision events are not tracked to minimize performance overhead.
 * Call this method if you need to receive collision events via `get_collision_events()`.
 *
 * **Performance Note:** Only enable collision events for bodies where you actually
 * need to detect collisions (e.g., player, enemies, collectibles). Static decorations
 * and particle effects typically don't need event tracking.
 *
 * ## Example
 *
 * ```gleam
 * // Player needs collision events (e.g., for damage detection)
 * let player = physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_collider(physics.Capsule(
 *     offset: transform.identity,
 *     half_height: 0.9,
 *     radius: 0.3,
 *   ))
 *   |> physics.with_collision_events()  // Enable events
 *   |> physics.build()
 *
 * // Static ground doesn't need events
 * let ground = physics.new_rigid_body(physics.Fixed)
 *   |> physics.with_collider(physics.Box(
 *     offset: transform.identity,
 *     width: 50.0,
 *     height: 1.0,
 *     depth: 50.0,
 *   ))
 *   |> physics.build()  // No events, saves performance
 * ```
 */
export function with_collision_events(builder) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    true,
    builder.is_sensor,
  );
}

/**
 * Make this collider a sensor (trigger).
 *
 * Sensors detect collisions and generate events, but don't cause physical
 * response (no pushing, bouncing, or blocking). Perfect for:
 * - Projectiles that should pass through targets
 * - Trigger zones (checkpoints, damage areas)
 * - Collectibles that don't block movement
 *
 * **Note**: Sensor colliders still need `with_collision_events()` to receive
 * collision events.
 *
 * ## Example
 *
 * ```gleam
 * // Projectile that detects hits but passes through enemies
 * let bullet = physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_collider(physics.Sphere(transform.identity, 0.1))
 *   |> physics.with_sensor()
 *   |> physics.with_collision_events()
 *   |> physics.build()
 * ```
 */
export function with_sensor(builder) {
  return new RigidBodyBuilder(
    builder.kind,
    builder.collider,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    true,
  );
}

/**
 * Build the final rigid body from the builder.
 *
 * This function is type-safe - you cannot call it without first calling `with_collider()`.
 *
 * ## Example
 *
 * ```gleam
 * let body = physics.new_rigid_body(physics.Dynamic)
 *   |> physics.with_collider(physics.Sphere(transform.identity, 1.0))
 *   |> physics.with_mass(5.0)
 *   |> physics.build()  // Returns RigidBody ready to use
 * ```
 */
export function build(builder) {
  let $ = builder.collider;
  let collider;
  if ($ instanceof $option.Some) {
    collider = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "tiramisu/physics",
      786,
      "build",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 22764,
        end: 22815,
        pattern_start: 22775,
        pattern_end: 22796
      }
    )
  }
  return new RigidBody(
    builder.kind,
    builder.mass,
    builder.restitution,
    builder.friction,
    builder.linear_damping,
    builder.angular_damping,
    collider,
    builder.ccd_enabled,
    builder.axis_locks,
    builder.collision_groups,
    builder.character_controller,
    builder.track_collision_events,
    builder.is_sensor,
  );
}

/**
 * Queue a force to be applied to a rigid body during the next physics step.
 * Returns updated world with the command queued.
 *
 * ## Example
 *
 * ```gleam
 * let world = physics.apply_force(world, "player", vec3.Vec3(0.0, 100.0, 0.0))
 * let world = physics.step(world, ctx.delta_time)  // Force is applied here
 * ```
 */
export function apply_force(world, id, force) {
  let command = new ApplyForce(id, force);
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    listPrepend(command, world.pending_commands),
    world.collider_to_body,
    world.collision_events,
    world.character_controllers,
  );
}

/**
 * Queue an impulse to be applied to a rigid body during the next physics step.
 * Returns updated world with the command queued.
 *
 * ## Example
 *
 * ```gleam
 * // Jump
 * let world = physics.apply_impulse(world, "player", vec3.Vec3(0.0, 10.0, 0.0))
 * ```
 */
export function apply_impulse(world, id, impulse) {
  let command = new ApplyImpulse(id, impulse);
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    listPrepend(command, world.pending_commands),
    world.collider_to_body,
    world.collision_events,
    world.character_controllers,
  );
}

/**
 * Queue a velocity change for a rigid body during the next physics step.
 * Returns updated world with the command queued.
 */
export function set_velocity(world, id, velocity) {
  let command = new SetVelocity(id, velocity);
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    listPrepend(command, world.pending_commands),
    world.collider_to_body,
    world.collision_events,
    world.character_controllers,
  );
}

/**
 * Queue a kinematic translation change for a kinematic rigid body during the next physics step.
 * This is the proper way to move kinematic bodies in Rapier.
 * Returns updated world with the command queued.
 */
export function set_kinematic_translation(world, id, position) {
  let command = new SetKinematicTranslation(id, position);
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    listPrepend(command, world.pending_commands),
    world.collider_to_body,
    world.collision_events,
    world.character_controllers,
  );
}

/**
 * Queue an angular velocity change for a rigid body during the next physics step.
 * Returns updated world with the command queued.
 */
export function set_angular_velocity(world, id, velocity) {
  let command = new SetAngularVelocity(id, velocity);
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    listPrepend(command, world.pending_commands),
    world.collider_to_body,
    world.collision_events,
    world.character_controllers,
  );
}

/**
 * Queue a torque to be applied to a rigid body during the next physics step.
 * Returns updated world with the command queued.
 */
export function apply_torque(world, id, torque) {
  let command = new ApplyTorque(id, torque);
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    listPrepend(command, world.pending_commands),
    world.collider_to_body,
    world.collision_events,
    world.character_controllers,
  );
}

/**
 * Queue a torque impulse to be applied to a rigid body during the next physics step.
 * Returns updated world with the command queued.
 */
export function apply_torque_impulse(world, id, impulse) {
  let command = new ApplyTorqueImpulse(id, impulse);
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    listPrepend(command, world.pending_commands),
    world.collider_to_body,
    world.collision_events,
    world.character_controllers,
  );
}

/**
 * Get all collision events that occurred during the last physics step.
 *
 * Events are automatically collected when `step()` is called and stored in the world.
 *
 * ## Example
 *
 * ```gleam
 * let physics_world = physics.step(physics_world)
 * let collision_events = physics.get_collision_events(physics_world)
 *
 * list.each(collision_events, fn(event) {
 *   case event {
 *     physics.CollisionStarted(a, b) ->
 *       io.println(a <> " started colliding with " <> b)
 *     physics.CollisionEnded(a, b) ->
 *       io.println(a <> " ended colliding with " <> b)
 *   }
 * })
 * ```
 */
export function get_collision_events(world) {
  return world.collision_events;
}

/**
 * Convert list of collision layer indices (0-15) to a 16-bit bitmask
 *
 * For example, [0, 2, 3] becomes 0b0000000000001101 = 0x000D
 * 
 * @ignore
 */
function layers_to_bitmask(layers) {
  return $list.fold(
    layers,
    0,
    (mask, layer) => {
      let $ = (layer >= 0) && (layer <= 15);
      if ($) {
        let bit = $int.bitwise_shift_left(1, layer);
        return $int.bitwise_or(mask, bit);
      } else {
        return mask;
      }
    },
  );
}

/**
 * Pack membership and filter bitmasks into a single 32-bit value
 *
 * Rapier format: 16 upper bits = membership, 16 lower bits = filter
 * For example: membership=0x000D, filter=0x0004 -> 0x000D0004
 * 
 * @ignore
 */
function pack_collision_groups(membership, filter) {
  let membership_shifted = $int.bitwise_shift_left(membership, 16);
  return $int.bitwise_or(membership_shifted, filter);
}

/**
 * Convert CollisionGroups to Rapier's 32-bit packed format
 * 
 * @ignore
 */
export function collision_groups_to_bitmask(groups) {
  let membership_mask = layers_to_bitmask(groups.membership);
  let filter_mask = layers_to_bitmask(groups.filter);
  return pack_collision_groups(membership_mask, filter_mask);
}

/**
 * Get the current velocity of a rigid body
 */
export function get_velocity(world, id) {
  return $result.try$(
    $dict.get(world.rapier_bodies, id),
    (rapier_body) => {
      let vel = get_body_linvel_ffi(rapier_body);
      return new Ok(new $vec3.Vec3(vel.x, vel.y, vel.z));
    },
  );
}

/**
 * Get the current angular velocity of a rigid body
 */
export function get_angular_velocity(world, id) {
  return $result.try$(
    $dict.get(world.rapier_bodies, id),
    (rapier_body) => {
      let vel = get_body_angvel_ffi(rapier_body);
      return new Ok(new $vec3.Vec3(vel.x, vel.y, vel.z));
    },
  );
}

/**
 * Get the current transform of a rigid body.
 *
 * Queries the physics simulation directly, so it always returns the latest position
 * even for bodies that were just created in the current frame.
 *
 * ## Example
 *
 * ```gleam
 * let cube_transform = case physics.get_transform(physics_world, Cube1) {
 *   Ok(t) -> t
 *   Error(_) -> transform.at(position: vec3.Vec3(0.0, 10.0, 0.0))
 * }
 * ```
 */
export function get_transform(physics_world, id) {
  return $result.try$(
    $dict.get(physics_world.rapier_bodies, id),
    (rapier_body) => {
      let translation = get_body_translation_ffi(rapier_body);
      let rotation_quat = get_body_rotation_ffi(rapier_body);
      return new Ok(
        (() => {
          let _pipe = $transform.identity;
          let _pipe$1 = $transform.with_position(
            _pipe,
            new $vec3.Vec3(translation.x, translation.y, translation.z),
          );
          return $transform.with_quaternion_rotation(_pipe$1, rotation_quat);
        })(),
      );
    },
  );
}

/**
 * Get the raw position and quaternion rotation from a rigid body.
 *
 * This returns the rotation as a quaternion directly from Rapier,
 * avoiding conversion to Euler angles which can cause rotation errors.
 *
 * This is used internally by the renderer for physics synchronization.
 *
 * ## Example
 *
 * ```gleam
 * case physics.get_body_transform_raw(physics_world, Cube1) {
 *   Ok(#(position, quaternion)) -> {
 *     // Use position and quaternion directly
 *   }
 *   Error(_) -> // Handle missing body
 * }
 * ```
 * 
 * @ignore
 */
export function get_body_transform_raw(physics_world, id) {
  return $result.try$(
    $dict.get(physics_world.rapier_bodies, id),
    (rapier_body) => {
      let translation = get_body_translation_ffi(rapier_body);
      let quaternion = get_body_rotation_ffi(rapier_body);
      return new Ok([translation, quaternion]);
    },
  );
}

function for_each_body_internal(rapier_bodies, world, callback) {
  let ids = $dict.keys(rapier_bodies);
  return $list.each(
    ids,
    (id) => {
      let $ = get_transform(world, id);
      if ($ instanceof Ok) {
        let transform = $[0];
        return callback(id, transform);
      } else {
        return undefined;
      }
    },
  );
}

/**
 * Iterate over all physics bodies and call a function for each
 * This keeps all internal field access within the physics module
 * 
 * @ignore
 */
export function for_each_body(world, callback) {
  return for_each_body_internal(world.rapier_bodies, world, callback);
}

/**
 * Cast a ray and return the first hit
 *
 * Useful for shooting mechanics, line-of-sight checks, and ground detection.
 *
 * ## Example
 *
 * ```gleam
 * // Cast ray downward from player position
 * let origin = player_position
 * let direction = vec3.Vec3(0.0, -1.0, 0.0)
 *
 * case physics.raycast(world, origin, direction, max_distance: 10.0) {
 *   Ok(hit) -> {
 *     // Found ground at hit.distance units below player
 *     io.println("Hit body with ID")
 *   }
 *   Error(Nil) -> {
 *     // No ground found within 10 units
 *   }
 * }
 * ```
 */
export function raycast(world, origin, direction, max_distance) {
  let ray = create_ray_ffi(
    origin.x,
    origin.y,
    origin.z,
    direction.x,
    direction.y,
    direction.z,
  );
  let $ = cast_ray_and_get_normal_ffi(world.world, ray, max_distance, true);
  if ($ instanceof Ok) {
    let hit_info = $[0];
    let collider_handle = get_hit_collider_handle_ffi(hit_info);
    let $1 = $dict.get(world.collider_to_body, collider_handle);
    if ($1 instanceof Ok) {
      let id = $1[0];
      let toi = get_hit_toi_ffi(hit_info);
      let point = ray_point_at_ffi(ray, toi);
      let normal = get_hit_normal_ffi(hit_info);
      return new Ok(
        new RaycastHit(
          id,
          new $vec3.Vec3(point.x, point.y, point.z),
          new $vec3.Vec3(normal.x, normal.y, normal.z),
          toi,
        ),
      );
    } else {
      return new Error(undefined);
    }
  } else {
    return new Error(undefined);
  }
}

/**
 * Initialize the global physics world
 * Takes a WorldConfig as Dynamic and extracts gravity
 * 
 * @ignore
 */
function create_world(config) {
  let world = create_world_ffi(
    config.gravity.x,
    config.gravity.y,
    config.gravity.z,
  );
  let queue = create_event_queue_ffi(true);
  return [world, queue];
}

/**
 * Create a new physics world.
 *
 * Call this in your `init()` function and store the world in your Model.
 * Return it as the third element of the init triple so Tiramisu can manage it.
 *
 * **Gravity**: Typical Earth gravity is `Vec3(0.0, -9.81, 0.0)`.
 * Use `Vec3(0.0, 0.0, 0.0)` for zero-gravity space games.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/physics
 * import vec/vec3
 * import gleam/option
 *
 * type Model {
 *   Model(physics_world: physics.PhysicsWorld(String))
 * }
 *
 * fn init(ctx) {
 *   let world = physics.new_world(physics.WorldConfig(
 *     gravity: vec3.Vec3(0.0, -9.81, 0.0),  // Earth gravity
 *   ))
 *
 *   #(
 *     Model(physics_world: world),
 *     effect.none(),
 *     option.Some(world),  // Return world for Tiramisu to manage
 *   )
 * }
 * ```
 */
export function new_world(config) {
  let $ = create_world(config);
  let world;
  let queue;
  world = $[0];
  queue = $[1];
  return new PhysicsWorld(
    world,
    queue,
    $dict.new$(),
    $dict.new$(),
    toList([]),
    $dict.new$(),
    toList([]),
    $dict.new$(),
  );
}

/**
 * Check if a rigid body exists in the physics world
 * This is used by the renderer to determine if a body needs to be created or updated
 * 
 * @ignore
 */
export function has_body(world, id) {
  return $dict.has_key(world.rapier_bodies, id);
}

/**
 * Update a rigid body's transform in the physics world
 * This is called by the renderer when a scene node's transform is updated
 * Primarily useful for Kinematic bodies that are controlled programmatically
 * 
 * @ignore
 */
export function update_body_transform(world, id, transform) {
  let $ = $dict.get(world.rapier_bodies, id);
  if ($ instanceof Ok) {
    let rapier_body = $[0];
    let position = $transform.position(transform);
    let quaternion = $transform.rotation_quaternion(transform);
    set_body_translation_ffi(
      rapier_body,
      position.x,
      position.y,
      position.z,
      true,
    );
    set_body_rotation_ffi(
      rapier_body,
      quaternion.x,
      quaternion.y,
      quaternion.z,
      quaternion.w,
      true,
    );
    return world;
  } else {
    return world;
  }
}

/**
 * Iterate over all physics bodies with raw quaternion data and body type.
 *
 * This is used by the renderer for physics synchronization, avoiding
 * quaternion-to-Euler conversion which can cause rotation errors.
 * 
 * @ignore
 */
export function for_each_body_raw(world, callback) {
  let ids = $dict.keys(world.rapier_bodies);
  return $list.each(
    ids,
    (id) => {
      let $ = $dict.get(world.rapier_bodies, id);
      let $1 = get_body_transform_raw(world, id);
      let $2 = $dict.get(world.bodies, id);
      if ($ instanceof Ok && $1 instanceof Ok && $2 instanceof Ok) {
        let rapier_body = $[0];
        let body_config = $2[0];
        let position = $1[0][0];
        let quaternion = $1[0][1];
        let $3 = body_config.kind;
        if ($3 instanceof Dynamic) {
          let $4 = is_body_sleeping_ffi(rapier_body);
          if ($4) {
            return undefined;
          } else {
            return callback(id, position, quaternion, body_config.kind);
          }
        } else if ($3 instanceof Kinematic) {
          return callback(id, position, quaternion, body_config.kind);
        } else {
          return callback(id, position, quaternion, body_config.kind);
        }
      } else {
        return undefined;
      }
    },
  );
}

/**
 * Get all collider handles for a rigid body
 * 
 * @ignore
 */
function get_body_collider_handles(body, num_colliders) {
  let _pipe = $list.range(0, num_colliders - 1);
  return $list.filter_map(
    _pipe,
    (i) => {
      let $ = get_body_collider_ffi(body, i);
      if ($ instanceof Ok) {
        let collider = $[0];
        return new Ok(get_collider_handle_ffi(collider));
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Remove a rigid body from the physics world
 * This is called by the renderer when a scene node with physics is removed
 * 
 * @ignore
 */
export function remove_body(world, id) {
  let $ = $dict.get(world.rapier_bodies, id);
  if ($ instanceof Ok) {
    let rapier_body = $[0];
    let num_colliders = get_body_num_colliders_ffi(rapier_body);
    let collider_handles = get_body_collider_handles(rapier_body, num_colliders);
    let updated_collider_map = $list.fold(
      collider_handles,
      world.collider_to_body,
      (map, handle) => { return $dict.delete$(map, handle); },
    );
    remove_rigid_body_ffi(world.world, rapier_body);
    return new PhysicsWorld(
      world.world,
      world.queue,
      $dict.delete$(world.bodies, id),
      $dict.delete$(world.rapier_bodies, id),
      world.pending_commands,
      updated_collider_map,
      world.collision_events,
      world.character_controllers,
    );
  } else {
    return world;
  }
}

/**
 * Drain collision events from the Rapier event queue
 * Converts collider handles to body IDs using the collider_to_body mapping
 * 
 * @ignore
 */
function drain_collision_events(world, collider_to_body) {
  let raw_events = drain_collision_events_ffi(world.queue);
  return $list.filter_map(
    raw_events,
    (raw_event) => {
      let handle1;
      let handle2;
      let started;
      handle1 = raw_event[0];
      handle2 = raw_event[1];
      started = raw_event[2];
      let $ = $dict.get(collider_to_body, handle1);
      let $1 = $dict.get(collider_to_body, handle2);
      if ($ instanceof Ok && $1 instanceof Ok) {
        let body_id1 = $[0];
        let body_id2 = $1[0];
        if (started) {
          return new Ok(new CollisionStarted(body_id1, body_id2));
        } else {
          return new Ok(new CollisionEnded(body_id1, body_id2));
        }
      } else {
        return new Error(undefined);
      }
    },
  );
}

/**
 * Create a rigid body in the physics world
 * This is called by the renderer when a scene node with physics is added
 * 
 * @ignore
 */
export function create_body(world, id, config, transform) {
  let _block;
  let $ = config.kind;
  if ($ instanceof Dynamic) {
    _block = create_dynamic_body_desc_ffi();
  } else if ($ instanceof Kinematic) {
    _block = create_kinematic_body_desc_ffi();
  } else {
    _block = create_fixed_body_desc_ffi();
  }
  let body_desc = _block;
  let pos = $transform.position(transform);
  set_body_desc_translation_ffi(body_desc, pos.x, pos.y, pos.z);
  let quat = $transform.rotation_quaternion(transform);
  set_body_desc_rotation_ffi(body_desc, quat.x, quat.y, quat.z, quat.w);
  set_linear_damping_ffi(body_desc, config.linear_damping);
  set_angular_damping_ffi(body_desc, config.angular_damping);
  let $1 = config.ccd_enabled;
  if ($1) {
    set_ccd_enabled_ffi(body_desc, true)
  } else {
    undefined
  }
  set_enabled_translations_ffi(
    body_desc,
    !config.axis_locks.lock_translation_x,
    !config.axis_locks.lock_translation_y,
    !config.axis_locks.lock_translation_z,
    true,
  );
  set_enabled_rotations_ffi(
    body_desc,
    !config.axis_locks.lock_rotation_x,
    !config.axis_locks.lock_rotation_y,
    !config.axis_locks.lock_rotation_z,
    true,
  );
  let rapier_body = create_rigid_body_ffi(world.world, body_desc);
  let _block$1;
  let $3 = config.collider;
  if ($3 instanceof Box) {
    let offset = $3.offset;
    let size = $3.size;
    _block$1 = [
      create_cuboid_collider_desc_ffi(size.x / 2.0, size.y / 2.0, size.z / 2.0),
      offset,
    ];
  } else if ($3 instanceof Sphere) {
    let offset = $3.offset;
    let radius = $3.radius;
    _block$1 = [create_ball_collider_desc_ffi(radius), offset];
  } else if ($3 instanceof Capsule) {
    let offset = $3.offset;
    let half_height = $3.half_height;
    let radius = $3.radius;
    _block$1 = [create_capsule_collider_desc_ffi(half_height, radius), offset];
  } else {
    let offset = $3.offset;
    let half_height = $3.half_height;
    let radius = $3.radius;
    _block$1 = [create_cylinder_collider_desc_ffi(half_height, radius), offset];
  }
  let $2 = _block$1;
  let collider_desc;
  let offset;
  collider_desc = $2[0];
  offset = $2[1];
  let pos$1 = $transform.position(offset);
  set_collider_translation_ffi(collider_desc, pos$1.x, pos$1.y, pos$1.z);
  let quat$1 = $transform.rotation_quaternion(offset);
  set_collider_rotation_ffi(
    collider_desc,
    quat$1.x,
    quat$1.y,
    quat$1.z,
    quat$1.w,
  );
  set_collider_restitution_ffi(collider_desc, config.restitution);
  set_collider_friction_ffi(collider_desc, config.friction);
  let $4 = config.mass;
  if ($4 instanceof $option.Some) {
    let mass = $4[0];
    set_collider_mass_ffi(collider_desc, mass)
  } else {
    undefined
  }
  let $5 = config.collision_groups;
  if ($5 instanceof $option.Some) {
    let groups = $5[0];
    let bitmask = collision_groups_to_bitmask(groups);
    set_collider_collision_groups_ffi(collider_desc, bitmask)
  } else {
    undefined
  }
  let $6 = config.track_collision_events;
  if ($6) {
    set_collider_active_events_ffi(collider_desc, get_active_events_ffi())
  } else {
    undefined
  }
  let $7 = config.is_sensor;
  if ($7) {
    set_collider_sensor_ffi(collider_desc, true)
  } else {
    undefined
  }
  let collider = create_collider_ffi(world.world, collider_desc, rapier_body);
  let collider_handle = get_collider_handle_ffi(collider);
  let _block$2;
  let $8 = config.character_controller;
  if ($8 instanceof $option.Some) {
    let controller_config = $8[0];
    let controller = create_character_controller_ffi(
      world.world,
      controller_config.offset,
    );
    set_character_up_vector_ffi(
      controller,
      controller_config.up_vector.x,
      controller_config.up_vector.y,
      controller_config.up_vector.z,
    );
    set_character_slide_ffi(controller, controller_config.slide_enabled);
    _block$2 = $dict.insert(world.character_controllers, id, controller);
  } else {
    _block$2 = world.character_controllers;
  }
  let character_controllers = _block$2;
  return new PhysicsWorld(
    world.world,
    world.queue,
    $dict.insert(world.bodies, id, config),
    $dict.insert(world.rapier_bodies, id, rapier_body),
    world.pending_commands,
    $dict.insert(world.collider_to_body, collider_handle, id),
    world.collision_events,
    character_controllers,
  );
}

/**
 * Check if a character is grounded (on the ground).
 * This uses the character controller's computed grounded state.
 * Must have called compute_character_movement for this body first in this frame.
 */
export function is_character_grounded(world, id) {
  let $ = $dict.get(world.character_controllers, id);
  if ($ instanceof Ok) {
    let controller = $[0];
    let grounded = get_character_computed_grounded_ffi(controller);
    return new Ok(grounded);
  } else {
    return new Error(undefined);
  }
}

/**
 * Apply a single physics command via FFI
 * 
 * @ignore
 */
function apply_command(command, rapier_bodies) {
  if (command instanceof ApplyForce) {
    let id = command.id;
    let force = command.force;
    return $result.try$(
      $dict.get(rapier_bodies, id),
      (rapier_body) => {
        add_body_force_ffi(rapier_body, force.x, force.y, force.z, true);
        return new Ok(undefined);
      },
    );
  } else if (command instanceof ApplyImpulse) {
    let id = command.id;
    let impulse = command.impulse;
    return $result.try$(
      $dict.get(rapier_bodies, id),
      (rapier_body) => {
        apply_body_impulse_ffi(
          rapier_body,
          impulse.x,
          impulse.y,
          impulse.z,
          true,
        );
        return new Ok(undefined);
      },
    );
  } else if (command instanceof SetVelocity) {
    let id = command.id;
    let velocity = command.velocity;
    return $result.try$(
      $dict.get(rapier_bodies, id),
      (rapier_body) => {
        set_body_linvel_ffi(
          rapier_body,
          velocity.x,
          velocity.y,
          velocity.z,
          true,
        );
        return new Ok(undefined);
      },
    );
  } else if (command instanceof SetAngularVelocity) {
    let id = command.id;
    let velocity = command.velocity;
    return $result.try$(
      $dict.get(rapier_bodies, id),
      (rapier_body) => {
        set_body_angvel_ffi(
          rapier_body,
          velocity.x,
          velocity.y,
          velocity.z,
          true,
        );
        return new Ok(undefined);
      },
    );
  } else if (command instanceof ApplyTorque) {
    let id = command.id;
    let torque = command.torque;
    return $result.try$(
      $dict.get(rapier_bodies, id),
      (rapier_body) => {
        add_body_torque_ffi(rapier_body, torque.x, torque.y, torque.z, true);
        return new Ok(undefined);
      },
    );
  } else if (command instanceof ApplyTorqueImpulse) {
    let id = command.id;
    let impulse = command.impulse;
    return $result.try$(
      $dict.get(rapier_bodies, id),
      (rapier_body) => {
        apply_body_torque_impulse_ffi(
          rapier_body,
          impulse.x,
          impulse.y,
          impulse.z,
          true,
        );
        return new Ok(undefined);
      },
    );
  } else {
    let id = command.id;
    let position = command.position;
    return $result.try$(
      $dict.get(rapier_bodies, id),
      (rapier_body) => {
        set_body_next_kinematic_translation_ffi(
          rapier_body,
          position.x,
          position.y,
          position.z,
        );
        return new Ok(undefined);
      },
    );
  }
}

/**
 * Step the physics simulation forward with variable timestep
 * This should be called in your update function each frame
 *
 * **IMPORTANT**: Pass `ctx.delta_time` for frame-rate independent physics!
 *
 * ## Example
 * ```gleam
 * fn update(model, msg, ctx) {
 *   let world = physics.step(model.physics_world, ctx.delta_time)
 *   #(Model(..model, physics_world: world), effect.none(), option.None)
 * }
 * ```
 *
 * Returns updated world with new transforms for all bodies
 */
export function step(world, delta_time) {
  let _pipe = world.pending_commands;
  let _pipe$1 = $list.reverse(_pipe);
  $list.each(
    _pipe$1,
    (command) => {
      let $ = apply_command(command, world.rapier_bodies);
      
      return undefined;
    },
  )
  let delta_time_seconds = $duration.to_seconds(delta_time);
  step_world_ffi(world.world, world.queue, delta_time_seconds);
  let _block;
  let _pipe$2 = world.collider_to_body;
  _block = ((_capture) => { return drain_collision_events(world, _capture); })(
    _pipe$2,
  );
  let collision_events = _block;
  return new PhysicsWorld(
    world.world,
    world.queue,
    world.bodies,
    world.rapier_bodies,
    toList([]),
    world.collider_to_body,
    collision_events,
    world.character_controllers,
  );
}

function create_vec3_object(x, y, z) {
  return new $vec3.Vec3(x, y, z);
}

/**
 * Compute collision-aware movement for a kinematic character.
 * Returns the actual movement that can be safely applied without penetrating colliders.
 * Must have created a character controller for this body first.
 */
export function compute_character_movement(world, id, desired_translation) {
  let $ = $dict.get(world.character_controllers, id);
  if ($ instanceof Ok) {
    let controller = $[0];
    let $1 = $dict.get(world.rapier_bodies, id);
    if ($1 instanceof Ok) {
      let rapier_body = $1[0];
      let num_colliders = get_body_num_colliders_ffi(rapier_body);
      let $2 = num_colliders > 0;
      if ($2) {
        let $3 = get_body_collider_ffi(rapier_body, 0);
        if ($3 instanceof Ok) {
          let collider = $3[0];
          let desired_translation_obj = create_vec3_object(
            desired_translation.x,
            desired_translation.y,
            desired_translation.z,
          );
          compute_character_movement_ffi(
            world.world,
            controller,
            collider,
            desired_translation_obj,
          );
          let safe_movement = get_character_computed_movement_ffi(controller);
          return new Ok(safe_movement);
        } else {
          return new Error(undefined);
        }
      } else {
        return new Error(undefined);
      }
    } else {
      return new Error(undefined);
    }
  } else {
    return new Error(undefined);
  }
}
