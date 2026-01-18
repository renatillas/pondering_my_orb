////
//// Main Lustre UI application for the game HUD.
////
//// This module creates the overlay UI that displays health, mana, and wand
//// information. It communicates with the Tiramisu game engine via a bridge.
////
//// ## Architecture
////
//// The UI is a Lustre application that:
//// 1. Receives state updates from the game via bridge messages
//// 2. Displays the current state using components (health_bar, mana_bar, wand_ui)
//// 3. Can send user actions back to the game (future: slot switching, etc.)
////

import client/bridge
import client/ui/health_bar
import client/ui/mana_bar
import client/ui/wand_ui
import gleam/option
import lustre
import lustre/attribute.{class}
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import tiramisu/ui as bridge_ui

// =============================================================================
// TYPES
// =============================================================================

/// UI application model containing current display state
pub type Model {
  Model(
    bridge: bridge_ui.Bridge(bridge.BridgeMsg),
    health: #(Float, Float),
    mana: #(Float, Float),
    wand_info: option.Option(bridge.WandInfo),
  )
}

/// UI messages (mostly bridge updates from the game)
pub type Msg {
  FromBridge(bridge.BridgeMsg)
}

// =============================================================================
// INIT
// =============================================================================

/// Initialize the UI with default values
fn init(bridge: bridge_ui.Bridge(bridge.BridgeMsg)) {
  #(
    Model(
      bridge: bridge,
      health: #(100.0, 100.0),
      mana: #(100.0, 100.0),
      wand_info: option.None,
    ),
    bridge_ui.register_lustre(bridge, FromBridge),
  )
}

// =============================================================================
// UPDATE
// =============================================================================

/// Handle UI messages (primarily bridge updates from game)
fn update(model: Model, msg: Msg) {
  case msg {
    FromBridge(bridge.UpdateHealth(current, max)) -> #(
      Model(..model, health: #(current, max)),
      effect.none(),
    )

    FromBridge(bridge.UpdateMana(current, max)) -> #(
      Model(..model, mana: #(current, max)),
      effect.none(),
    )

    FromBridge(bridge.UpdateActiveWand(wand_info)) -> #(
      Model(..model, wand_info: option.Some(wand_info)),
      effect.none(),
    )
  }
}

// =============================================================================
// VIEW
// =============================================================================

/// Render the complete UI overlay
fn view(model: Model) -> Element(Msg) {
  html.div([class("fixed inset-0 pointer-events-none z-10")], [
    // Top-left: Health & Mana bars
    html.div([class("absolute top-4 left-4 space-y-2 pointer-events-auto")], [
      health_bar.view(model.health.0, model.health.1),
      mana_bar.view(model.mana.0, model.mana.1),
    ]),
    // Bottom-center: Wand UI
    html.div(
      [
        class("absolute bottom-8 left-1/2 -translate-x-1/2 pointer-events-auto"),
      ],
      [
        case model.wand_info {
          option.Some(wand) -> wand_ui.view(wand)
          option.None -> element.none()
        },
      ],
    ),
  ])
}

// =============================================================================
// START
// =============================================================================

/// Start the Lustre UI application and mount it to #ui div
pub fn start(bridge: bridge_ui.Bridge(bridge.BridgeMsg)) {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#ui", bridge)
  Nil
}
