import * as $promise from "../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import { Ok, CustomType as $CustomType } from "../gleam.mjs";
import * as $effect from "../tiramisu/effect.mjs";

/**
 * Solid color background (hex color, e.g., 0x111111)
 */
export class Color extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Background$Color = ($0) => new Color($0);
export const Background$isColor = (value) => value instanceof Color;
export const Background$Color$0 = (value) => value[0];

/**
 * 2D texture background loaded from URL or path
 */
export class Texture extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Background$Texture = ($0) => new Texture($0);
export const Background$isTexture = (value) => value instanceof Texture;
export const Background$Texture$0 = (value) => value[0];

/**
 * Equirectangular (360° spherical) texture background
 */
export class EquirectangularTexture extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Background$EquirectangularTexture = ($0) =>
  new EquirectangularTexture($0);
export const Background$isEquirectangularTexture = (value) =>
  value instanceof EquirectangularTexture;
export const Background$EquirectangularTexture$0 = (value) => value[0];

/**
 * TODO: This should be a type instead of a list of strings
 * Cube texture (skybox) with 6 face images [px, nx, py, ny, pz, nz]
 */
export class CubeTexture extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Background$CubeTexture = ($0) => new CubeTexture($0);
export const Background$isCubeTexture = (value) => value instanceof CubeTexture;
export const Background$CubeTexture$0 = (value) => value[0];

/**
 * Set the scene background dynamically.
 *
 * Use `ctx.scene` from the game context to get the scene reference.
 *
 * ## Example
 *
 * ```gleam
 * fn update(model: Model, msg: Msg, ctx: tiramisu.Context) {
 *   case msg {
 *     LoadSkybox -> {
 *       let effect = background.set(
 *         ctx.scene,
 *         background.CubeTexture(["px.jpg", "nx.jpg", "py.jpg", "ny.jpg", "pz.jpg", "nz.jpg"]),
 *         SkyboxLoaded,
 *         SkyboxFailed,
 *       )
 *       #(model, effect, ctx.physics_world)
 *     }
 *   }
 * }
 * ```
 */
export function set(game_scene, background, on_success, on_error) {
  return $effect.from(
    (dispatch) => {
      if (background instanceof Color) {
        let color = background[0];
        let $ = $savoiardi.set_scene_background_color(game_scene, color);
        
        return dispatch(on_success);
      } else if (background instanceof Texture) {
        let url = background[0];
        let _pipe = $savoiardi.load_texture(url);
        $promise.map(
          _pipe,
          (result) => {
            if (result instanceof Ok) {
              let texture = result[0];
              let $ = $savoiardi.set_scene_background_texture(
                game_scene,
                texture,
              );
              
              return dispatch(on_success);
            } else {
              return dispatch(on_error);
            }
          },
        )
        return undefined;
      } else if (background instanceof EquirectangularTexture) {
        let url = background[0];
        let _pipe = $savoiardi.load_equirectangular_texture(url);
        $promise.map(
          _pipe,
          (result) => {
            if (result instanceof Ok) {
              let texture = result[0];
              let $ = $savoiardi.set_scene_background_texture(
                game_scene,
                texture,
              );
              
              return dispatch(on_success);
            } else {
              return dispatch(on_error);
            }
          },
        )
        return undefined;
      } else {
        let urls = background[0];
        let _pipe = $savoiardi.load_cube_texture(urls);
        $promise.tap(
          _pipe,
          (result) => {
            if (result instanceof Ok) {
              let cube_texture = result[0];
              let $ = $savoiardi.set_scene_background_cube_texture(
                game_scene,
                cube_texture,
              );
              
              return dispatch(on_success);
            } else {
              return dispatch(on_error);
            }
          },
        )
        return undefined;
      }
    },
  );
}
