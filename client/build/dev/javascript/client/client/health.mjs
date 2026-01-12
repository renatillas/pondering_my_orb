import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import { CustomType as $CustomType, divideFloat } from "../gleam.mjs";

export class Health extends $CustomType {
  constructor(current, max) {
    super();
    this.current = current;
    this.max = max;
  }
}
export const Health$Health = (current, max) => new Health(current, max);
export const Health$isHealth = (value) => value instanceof Health;
export const Health$Health$current = (value) => value.current;
export const Health$Health$0 = (value) => value.current;
export const Health$Health$max = (value) => value.max;
export const Health$Health$1 = (value) => value.max;

/**
 * Create a new Health with full health
 */
export function new$(max) {
  return new Health(max, max);
}

/**
 * Create a Health with specific current and max values
 */
export function with_current(current, max) {
  return new Health($float.clamp(current, 0.0, max), max);
}

/**
 * Apply damage, reducing current health (clamped to 0)
 */
export function damage(health, amount) {
  return new Health($float.max(0.0, health.current - amount), health.max);
}

/**
 * Heal, increasing current health (clamped to max)
 */
export function heal(health, amount) {
  return new Health($float.min(health.max, health.current + amount), health.max);
}

/**
 * Set current health to max
 */
export function restore(health) {
  return new Health(health.max, health.max);
}

/**
 * Check if health is depleted (current <= 0)
 */
export function is_dead(health) {
  return health.current <= 0.0;
}

/**
 * Check if health is full
 */
export function is_full(health) {
  return health.current >= health.max;
}

/**
 * Get health as a percentage (0.0 to 1.0)
 */
export function percentage(health) {
  return divideFloat(health.current, health.max);
}

/**
 * Get current health value
 */
export function current(health) {
  return health.current;
}

/**
 * Get max health value
 */
export function max(health) {
  return health.max;
}
