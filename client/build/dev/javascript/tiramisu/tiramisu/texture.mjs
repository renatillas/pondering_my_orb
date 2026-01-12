import * as $promise from "../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import * as $vec2 from "../../vec/vec/vec2.mjs";
import { Ok, CustomType as $CustomType } from "../gleam.mjs";
import * as $effect from "../tiramisu/effect.mjs";

export class RepeatWrapping extends $CustomType {}
export const WrapMode$RepeatWrapping = () => new RepeatWrapping();
export const WrapMode$isRepeatWrapping = (value) =>
  value instanceof RepeatWrapping;

export class ClampToEdgeWrapping extends $CustomType {}
export const WrapMode$ClampToEdgeWrapping = () => new ClampToEdgeWrapping();
export const WrapMode$isClampToEdgeWrapping = (value) =>
  value instanceof ClampToEdgeWrapping;

export class MirroredRepeatWrapping extends $CustomType {}
export const WrapMode$MirroredRepeatWrapping = () =>
  new MirroredRepeatWrapping();
export const WrapMode$isMirroredRepeatWrapping = (value) =>
  value instanceof MirroredRepeatWrapping;

export class NearestFilter extends $CustomType {}
export const FilterMode$NearestFilter = () => new NearestFilter();
export const FilterMode$isNearestFilter = (value) =>
  value instanceof NearestFilter;

export class LinearFilter extends $CustomType {}
export const FilterMode$LinearFilter = () => new LinearFilter();
export const FilterMode$isLinearFilter = (value) =>
  value instanceof LinearFilter;

function to_savoiardi_wrap_mode(mode) {
  if (mode instanceof RepeatWrapping) {
    return new $savoiardi.RepeatWrapping();
  } else if (mode instanceof ClampToEdgeWrapping) {
    return new $savoiardi.ClampToEdgeWrapping();
  } else {
    return new $savoiardi.MirroredRepeatWrapping();
  }
}

function to_savoiardi_filter_mode(mode) {
  if (mode instanceof NearestFilter) {
    return new $savoiardi.NearestFilter();
  } else {
    return new $savoiardi.LinearFilter();
  }
}

/**
 * Clone a texture for independent manipulation.
 *
 * This is essential for spritesheet animation when you want multiple sprites
 * to show different frames from the same source texture.
 *
 * ## Example
 *
 * ```gleam
 * let base_texture = asset.get_texture(cache, "spritesheet.png")
 * let player1_texture = texture.clone(base_texture)
 * let player2_texture = texture.clone(base_texture)
 *
 * // Now player1 and player2 can show different frames
 * texture.set_offset(player1_texture, 0.0, 0.0)  // Frame 0
 * texture.set_offset(player2_texture, 0.25, 0.0) // Frame 1
 * ```
 */
export function clone(texture) {
  return $savoiardi.clone_texture(texture);
}

/**
 * Sets the texture UV offset.
 *
 * Controls which portion of the texture starts being displayed.
 * Values range from 0.0 to 1.0.
 *
 * ## Example
 *
 * ```gleam
 * // Show the right half of the texture
 * texture.set_offset(my_texture, vec2.Vec2(0.5, 0.0))
 * ```
 */
export function set_offset(texture, offset) {
  $savoiardi.set_texture_offset(texture, offset.x, offset.y);
  return texture;
}

/**
 * Sets the texture UV repeat (scaling).
 *
 * Controls how much of the texture is displayed.
 * Values range from 0.0 to 1.0 (or higher for tiling).
 *
 * ## Example
 *
 * ```gleam
 * // Show only 1/4 of texture width (for 4-frame horizontal sprite)
 * texture.set_repeat(my_texture, vec2.Vec2(0.25, 1.0))
 * ```
 */
export function set_repeat(texture, repeat) {
  $savoiardi.set_texture_repeat(texture, repeat.x, repeat.y);
  return texture;
}

/**
 * Sets the texture wrapping mode.
 *
 * Controls how the texture behaves at edges when UV coordinates exceed 0-1 range.
 *
 * **Important**: RepeatWrapping only works with power-of-two texture dimensions.
 *
 * ## Example
 *
 * ```gleam
 * // Required for spritesheet animation
 * texture.set_wrap_mode(
 *   my_texture,
 *   texture.RepeatWrapping,
 *   texture.RepeatWrapping,
 * )
 * ```
 */
export function set_wrap_mode(texture, wrap_s, wrap_t) {
  $savoiardi.set_texture_wrap_mode(
    texture,
    to_savoiardi_wrap_mode(wrap_s),
    to_savoiardi_wrap_mode(wrap_t),
  );
  return texture;
}

/**
 * Sets the texture filtering mode.
 *
 * Controls how the texture is sampled when scaled.
 * Use NearestFilter for crisp pixel art, LinearFilter for smooth textures.
 *
 * ## Example
 *
 * ```gleam
 * // Use nearest filtering for crisp pixel art
 * texture.set_filter_mode(
 *   my_texture,
 *   texture.NearestFilter,
 *   texture.NearestFilter,
 * )
 * ```
 */
export function set_filter_mode(texture, min_filter, mag_filter) {
  $savoiardi.set_texture_filter_mode(
    texture,
    to_savoiardi_filter_mode(min_filter),
    to_savoiardi_filter_mode(mag_filter),
  );
  return texture;
}

/**
 * Load a texture from URL
 */
export function load(url, on_success, on_error) {
  let _block;
  let _pipe = $savoiardi.load_texture(url);
  _block = $promise.map(
    _pipe,
    (result) => {
      if (result instanceof Ok) {
        let data = result[0];
        return on_success(data);
      } else {
        return on_error;
      }
    },
  );
  let promise = _block;
  return $effect.from_promise(promise);
}
