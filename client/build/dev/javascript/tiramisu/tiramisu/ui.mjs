import * as $lustre_effect from "../../lustre/lustre/effect.mjs";
import { CustomType as $CustomType } from "../gleam.mjs";
import * as $game_effect from "../tiramisu/effect.mjs";
import {
  createBridge as create_bridge_ffi,
  registerLustre as register_lustre_ffi,
  sendToGame as send_to_game_ffi,
  sendToLustre as send_to_lustre_ffi,
} from "./ui.ffi.mjs";

class Bridge extends $CustomType {
  constructor(bridge) {
    super();
    this.bridge = bridge;
  }
}

/**
 * Get the internal bridge object (for use by tiramisu.start).
 * 
 * @ignore
 */
export function get_internal(bridge) {
  return bridge.bridge;
}

/**
 * Create a new bridge for Tiramisu-Lustre communication.
 *
 * ## Example
 *
 * ```gleam
 * let bridge = ui.new_bridge()
 * ```
 */
export function new_bridge() {
  return new Bridge(create_bridge_ffi());
}

/**
 * Register Lustre's dispatch with a wrapper function.
 *
 * The wrapper converts bridge messages to Lustre's internal message type.
 * Call this in your Lustre `init` function.
 *
 * ## Example
 *
 * ```gleam
 * pub type Msg {
 *   FromBridge(BridgeMsg)
 *   // ... other messages
 * }
 *
 * fn init(bridge) {
 *   #(Model(bridge: bridge), ui.register_lustre(bridge, FromBridge))
 * }
 * ```
 */
export function register_lustre(bridge, wrapper) {
  return $lustre_effect.from(
    (dispatch) => {
      return register_lustre_ffi(
        bridge.bridge,
        (msg) => { return dispatch(wrapper(msg)); },
      );
    },
  );
}

/**
 * Send a message across the bridge to the game.
 *
 * ## Example
 *
 * ```gleam
 * fn update(model, msg) {
 *   case msg {
 *     ButtonClicked -> #(model, ui.send(model.bridge, SelectSlot(0)))
 *   }
 * }
 * ```
 */
export function send(bridge, msg) {
  return $lustre_effect.from(
    (_) => { return send_to_game_ffi(bridge.bridge, msg); },
  );
}

/**
 * Send a message across the bridge to the UI.
 *
 * ## Example
 *
 * ```gleam
 * fn update(model, msg, ctx) {
 *   case msg {
 *     Tick -> #(model, ui.send_to_ui(bridge, UpdateScore(10)), ...)
 *   }
 * }
 * ```
 */
export function send_to_ui(bridge, msg) {
  return $game_effect.from(
    (_) => { return send_to_lustre_ffi(bridge.bridge, msg); },
  );
}
