import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import { CustomType as $CustomType } from "../gleam.mjs";

export class RenderStats extends $CustomType {
  constructor(draw_calls, triangles) {
    super();
    this.draw_calls = draw_calls;
    this.triangles = triangles;
  }
}
export const RenderStats$RenderStats = (draw_calls, triangles) =>
  new RenderStats(draw_calls, triangles);
export const RenderStats$isRenderStats = (value) =>
  value instanceof RenderStats;
export const RenderStats$RenderStats$draw_calls = (value) => value.draw_calls;
export const RenderStats$RenderStats$0 = (value) => value.draw_calls;
export const RenderStats$RenderStats$triangles = (value) => value.triangles;
export const RenderStats$RenderStats$1 = (value) => value.triangles;

/**
 * Get render statistics from the WebGL renderer.
 *
 * Returns the number of draw calls and triangles rendered in the current frame.
 * Use this for optimization - fewer draw calls generally means better performance.
 *
 * ## Example
 *
 * ```gleam
 * import tiramisu/debug
 * import gleam/io
 * import gleam/int
 *
 * pub fn update(model: Model, msg: Msg, ctx: tiramisu.Context) {
 *   let stats = debug.get_render_stats(ctx.renderer)
 *
 *   // Track draw calls for optimization
 *   case stats.draw_calls > 100 {
 *     True -> io.println("Too many draw calls: " <> int.to_string(stats.draw_calls))
 *     False -> Nil
 *   }
 *
 *   // ... rest of update logic
 * }
 * ```
 */
export function get_render_stats(renderer) {
  let $ = $savoiardi.get_render_stats(renderer);
  let draw_calls;
  let triangles;
  draw_calls = $[0];
  triangles = $[1];
  return new RenderStats(draw_calls, triangles);
}
