////
//// Main Lustre UI application for all game screens.
////
//// This module creates the UI that handles:
//// - Start screen (room selection and player setup)
//// - Connecting screen (loading state)
//// - In-game HUD (health, mana, and wand information)
////
//// It communicates with the Tiramisu game engine via a bidirectional bridge.
////
//// ## Architecture
////
//// The UI is a Lustre application that:
//// 1. Receives state updates from the game via bridge messages  
//// 2. Displays the appropriate screen based on app state
//// 3. Sends user actions back to the game via the bridge
////

import client/bridge
import client/start_screen
import client/ui/health_bar
import client/ui/mana_bar
import client/ui/wand_ui
import gleam/int
import gleam/option
import lustre
import lustre/attribute.{class}
import lustre/effect
import lustre/element.{type Element, text}
import lustre/element/html
import shared/room_info
import tiramisu/ui as bridge_ui

// =============================================================================
// TYPES
// =============================================================================

/// Which screen the UI is currently displaying
pub type AppState {
  StartScreen
  Connecting(room_id: String, player_name: String)
  InGame
}

/// UI application model containing current display state
pub type Model {
  Model(
    bridge: bridge_ui.Bridge(bridge.BridgeMsg),
    app_state: AppState,
    // Start screen state
    player_name: String,
    rooms: List(room_info.RoomInfo),
    loading: Bool,
    error: option.Option(String),
    new_room_name: String,
    new_room_max_players: String,
    // In-game HUD state
    health: #(Float, Float),
    mana: #(Float, Float),
    wand_info: option.Option(bridge.WandInfo),
  )
}

/// UI messages
pub type Msg {
  FromBridge(bridge.BridgeMsg)
  // Start screen local actions
  PlayerNameChanged(String)
  RefreshRooms
  JoinRoom(room_id: String)
  NewRoomNameChanged(String)
  NewRoomMaxPlayersChanged(String)
  SubmitCreateRoom
  // Error dismissed
  DismissError
}

// =============================================================================
// INIT
// =============================================================================

/// Initialize the UI starting with the start screen
fn init(bridge: bridge_ui.Bridge(bridge.BridgeMsg)) {
  #(
    Model(
      bridge: bridge,
      app_state: StartScreen,
      player_name: "",
      rooms: [],
      loading: False,
      error: option.None,
      new_room_name: "",
      new_room_max_players: "4",
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

/// Handle UI messages
fn update(model: Model, msg: Msg) {
  case msg {
    // App state transitions from game
    FromBridge(bridge.ShowStartScreen) -> #(
      Model(..model, app_state: StartScreen),
      effect.none(),
    )

    FromBridge(bridge.ShowConnecting(room_id, player_name)) -> #(
      Model(..model, app_state: Connecting(room_id, player_name)),
      effect.none(),
    )

    FromBridge(bridge.ShowInGame) -> #(
      Model(..model, app_state: InGame),
      effect.none(),
    )

    // Data updates from game
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

    FromBridge(bridge.UpdateRoomList(rooms)) -> #(
      Model(..model, rooms: rooms, loading: False),
      effect.none(),
    )

    FromBridge(bridge.ShowError(err)) -> #(
      Model(..model, error: option.Some(err), loading: False),
      effect.none(),
    )

    // These messages should come from UI, not from bridge - ignore them
    FromBridge(bridge.UIPlayerNameChanged(_))
    | FromBridge(bridge.UIRefreshRooms)
    | FromBridge(bridge.UIJoinRoom(_))
    | FromBridge(bridge.UICreateRoom(_, _)) -> #(model, effect.none())

    // Local UI actions - send to game via bridge
    PlayerNameChanged(name) -> #(
      Model(..model, player_name: name),
      bridge_ui.send(model.bridge, bridge.UIPlayerNameChanged(name)),
    )

    RefreshRooms -> #(
      Model(..model, loading: True),
      bridge_ui.send(model.bridge, bridge.UIRefreshRooms),
    )

    JoinRoom(room_id) -> #(
      model,
      bridge_ui.send(model.bridge, bridge.UIJoinRoom(room_id)),
    )

    NewRoomNameChanged(name) -> #(
      Model(..model, new_room_name: name),
      effect.none(),
    )

    NewRoomMaxPlayersChanged(value) -> #(
      Model(..model, new_room_max_players: value),
      effect.none(),
    )

    SubmitCreateRoom -> {
      case int.parse(model.new_room_max_players) {
        Ok(max_players) -> #(
          model,
          bridge_ui.send(
            model.bridge,
            bridge.UICreateRoom(model.new_room_name, max_players),
          ),
        )
        Error(_) -> #(model, effect.none())
      }
    }

    DismissError -> #(Model(..model, error: option.None), effect.none())
  }
}

// =============================================================================
// VIEW
// =============================================================================

/// Render the appropriate screen based on app state
fn view(model: Model) -> Element(Msg) {
  // Wrapper with state class for CSS targeting
  let state_class = case model.app_state {
    StartScreen -> "start-screen"
    Connecting(_, _) -> "connecting"
    InGame -> "in-game"
  }

  let content = case model.app_state {
    StartScreen -> view_start_screen(model)
    Connecting(room_id, player_name) -> view_connecting(room_id, player_name)
    InGame -> view_in_game_hud(model)
  }

  html.div([class("app-state-wrapper " <> state_class)], [content])
}

/// Render the start screen (room selection)
fn view_start_screen(model: Model) -> Element(Msg) {
  start_screen.view(start_screen.Model(
    player_name: model.player_name,
    rooms: model.rooms,
    loading: model.loading,
    error: model.error,
    new_room_name: model.new_room_name,
    new_room_max_players: model.new_room_max_players,
  ))
  |> element.map(map_start_screen_msg)
}

/// Map start_screen.Msg to our Msg type
fn map_start_screen_msg(ss_msg: start_screen.Msg) -> Msg {
  case ss_msg {
    start_screen.PlayerNameChanged(name) -> PlayerNameChanged(name)
    start_screen.RefreshRooms -> RefreshRooms
    start_screen.JoinRoom(room_id) -> JoinRoom(room_id)
    start_screen.NewRoomNameChanged(name) -> NewRoomNameChanged(name)
    start_screen.NewRoomMaxPlayersChanged(value) ->
      NewRoomMaxPlayersChanged(value)
    start_screen.SubmitCreateRoom -> SubmitCreateRoom
    start_screen.RoomListReceived(_) | start_screen.RoomListError(_) ->
      // These are handled by bridge updates, not user actions
      DismissError
  }
}

/// Render the connecting screen
fn view_connecting(room_id: String, player_name: String) -> Element(Msg) {
  html.div(
    [
      class(
        "fixed inset-0 z-50 bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900 flex items-center justify-center pointer-events-auto",
      ),
    ],
    [
      html.div([class("text-center space-y-6")], [
        html.div([class("animate-pulse")], [
          html.div([class("text-8xl mb-4")], [text("🔮")]),
        ]),
        html.h1([class("text-4xl font-bold text-white")], [
          text("Connecting..."),
        ]),
        html.div([class("space-y-2 text-lg")], [
          html.p([class("text-blue-300")], [
            text("Joining room: "),
            html.span([class("font-semibold text-white")], [text(room_id)]),
          ]),
          html.p([class("text-blue-300")], [
            text("Player: "),
            html.span([class("font-semibold text-white")], [text(player_name)]),
          ]),
        ]),
        html.div([class("flex justify-center gap-2 mt-8")], [
          html.div(
            [class("w-3 h-3 bg-blue-400 rounded-full animate-bounce")],
            [],
          ),
          html.div(
            [class("w-3 h-3 bg-blue-400 rounded-full animate-bounce delay-100")],
            [],
          ),
          html.div(
            [class("w-3 h-3 bg-blue-400 rounded-full animate-bounce delay-200")],
            [],
          ),
        ]),
      ]),
    ],
  )
}

/// Render the in-game HUD overlay
fn view_in_game_hud(model: Model) -> Element(Msg) {
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
