/// Start Screen - Room selection and player setup
import gleam/int
import gleam/list
import gleam/option.{type Option, None}
import gleam/string
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event
import shared/room_info

// =============================================================================
// TYPES
// =============================================================================

pub type Model {
  Model(
    player_name: String,
    rooms: List(room_info.RoomInfo),
    loading: Bool,
    error: Option(String),
    new_room_name: String,
    new_room_max_players: String,
  )
}

pub type Msg {
  PlayerNameChanged(String)
  RefreshRooms
  JoinRoom(room_id: String)
  NewRoomNameChanged(String)
  NewRoomMaxPlayersChanged(String)
  SubmitCreateRoom
  RoomListReceived(List(room_info.RoomInfo))
  RoomListError(String)
}

// =============================================================================
// INIT
// =============================================================================

pub fn init() -> #(Model, Nil) {
  #(
    Model(
      player_name: "",
      rooms: [],
      loading: False,
      error: None,
      new_room_name: "",
      new_room_max_players: "4",
    ),
    Nil,
  )
}

// =============================================================================
// UPDATE
// =============================================================================

pub fn update(model: Model, msg: Msg) -> #(Model, Nil) {
  case msg {
    PlayerNameChanged(name) -> {
      #(Model(..model, player_name: name), Nil)
    }

    RefreshRooms -> {
      #(Model(..model, loading: True), Nil)
    }

    JoinRoom(_room_id) -> {
      // Handled by parent
      #(model, Nil)
    }

    NewRoomNameChanged(name) -> {
      #(Model(..model, new_room_name: name), Nil)
    }

    NewRoomMaxPlayersChanged(value) -> {
      #(Model(..model, new_room_max_players: value), Nil)
    }

    SubmitCreateRoom -> {
      // Handled by parent
      #(model, Nil)
    }

    RoomListReceived(rooms) -> {
      #(Model(..model, rooms: rooms, loading: False), Nil)
    }

    RoomListError(error) -> {
      #(Model(..model, error: option.Some(error), loading: False), Nil)
    }
  }
}

// =============================================================================
// VIEW
// =============================================================================

pub fn view(model: Model) -> Element(Msg) {
  html.div(
    [
      class(
        "fixed inset-0 z-50 bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 flex items-center justify-center p-4 overflow-y-auto pointer-events-auto",
      ),
    ],
    [
      html.div([class("max-w-4xl w-full space-y-8")], [
        // Header
        html.div([class("text-center space-y-2")], [
          html.h1([class("text-6xl font-bold text-white mb-2")], [
            text("🔮 Pondering My Orb"),
          ]),
          html.h2([class("text-2xl text-purple-300")], [
            text("Multiplayer Arena"),
          ]),
        ]),
        // Error display
        case model.error {
          option.Some(err) ->
            html.div(
              [
                class(
                  "bg-red-500/20 border border-red-500 rounded-lg p-4 flex items-center justify-between",
                ),
              ],
              [
                html.span([class("text-red-200")], [text("⚠️ " <> err)]),
                html.button(
                  [
                    class(
                      "text-red-200 hover:text-white text-2xl font-bold leading-none",
                    ),
                    event.on_click(RefreshRooms),
                  ],
                  [text("×")],
                ),
              ],
            )
          option.None -> element.none()
        },
        // Main content grid
        html.div([class("grid md:grid-cols-2 gap-6")], [
          // Left column: Player info + Room list
          html.div([class("space-y-6")], [
            // Player name input
            html.div(
              [
                class(
                  "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 space-y-4",
                ),
              ],
              [
                html.label(
                  [class("block text-sm font-semibold text-purple-300")],
                  [
                    text("Your Name"),
                  ],
                ),
                html.input([
                  class(
                    "w-full px-4 py-3 bg-gray-900/50 border border-purple-500/30 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent",
                  ),
                  attribute("type", "text"),
                  attribute("placeholder", "Enter your name"),
                  attribute("value", model.player_name),
                  event.on_input(PlayerNameChanged),
                ]),
              ],
            ),
            // Room list section
            html.div(
              [
                class(
                  "bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 space-y-4",
                ),
              ],
              [
                html.div([class("flex items-center justify-between")], [
                  html.h3([class("text-xl font-bold text-white")], [
                    text("Available Rooms"),
                  ]),
                  html.button(
                    case model.loading {
                      True -> [
                        class(
                          "px-4 py-2 bg-gray-700 cursor-not-allowed rounded-lg text-white font-semibold",
                        ),
                        attribute("disabled", "disabled"),
                      ]
                      False -> [
                        class(
                          "px-4 py-2 bg-purple-600 hover:bg-purple-500 rounded-lg text-white font-semibold transition-colors",
                        ),
                        event.on_click(RefreshRooms),
                      ]
                    },
                    [
                      text(case model.loading {
                        True -> "Loading..."
                        False -> "🔄 Refresh"
                      }),
                    ],
                  ),
                ]),
                view_room_list(model),
              ],
            ),
          ]),
          // Right column: Create room
          html.div(
            [class("bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 space-y-4")],
            [
              html.h3([class("text-xl font-bold text-white")], [
                text("Create New Room"),
              ]),
              html.div([class("space-y-4")], [
                html.div([class("space-y-2")], [
                  html.label(
                    [class("block text-sm font-semibold text-purple-300")],
                    [
                      text("Room Name"),
                    ],
                  ),
                  html.input([
                    class(
                      "w-full px-4 py-3 bg-gray-900/50 border border-purple-500/30 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent",
                    ),
                    attribute("type", "text"),
                    attribute("placeholder", "My Awesome Room"),
                    attribute("value", model.new_room_name),
                    event.on_input(NewRoomNameChanged),
                  ]),
                ]),
                html.div([class("space-y-2")], [
                  html.label(
                    [class("block text-sm font-semibold text-purple-300")],
                    [
                      text("Max Players"),
                    ],
                  ),
                  html.input([
                    class(
                      "w-full px-4 py-3 bg-gray-900/50 border border-purple-500/30 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent",
                    ),
                    attribute("type", "number"),
                    attribute("min", "2"),
                    attribute("max", "8"),
                    attribute("value", model.new_room_max_players),
                    event.on_input(NewRoomMaxPlayersChanged),
                  ]),
                ]),
                html.button(
                  case
                    string.is_empty(model.player_name)
                    || string.is_empty(model.new_room_name)
                  {
                    True -> [
                      class(
                        "w-full px-6 py-3 bg-gray-700 cursor-not-allowed rounded-lg text-gray-400 font-bold text-lg",
                      ),
                      attribute("disabled", "disabled"),
                    ]
                    False -> [
                      class(
                        "w-full px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 rounded-lg text-white font-bold text-lg transition-all",
                      ),
                      event.on_click(SubmitCreateRoom),
                    ]
                  },
                  [text("✨ Create Room")],
                ),
              ]),
            ],
          ),
        ]),
      ]),
    ],
  )
}

fn view_room_list(model: Model) -> Element(Msg) {
  case model.rooms {
    [] ->
      html.div(
        [
          class(
            "flex items-center justify-center h-32 text-gray-400 text-center",
          ),
        ],
        [
          html.p([], [
            text("No rooms available."),
            html.br([]),
            text("Create one or refresh the list!"),
          ]),
        ],
      )
    rooms -> {
      html.div(
        [class("space-y-2 max-h-96 overflow-y-auto")],
        list.map(rooms, fn(room) { view_room(room, model.player_name) }),
      )
    }
  }
}

fn view_room(room: room_info.RoomInfo, player_name: String) -> Element(Msg) {
  let is_full = room.player_count >= room.max_players
  let can_join = !string.is_empty(player_name) && !is_full

  html.div(
    [
      class(
        "bg-gray-900/50 border border-purple-500/20 rounded-lg p-4 flex items-center justify-between hover:border-purple-500/40 transition-colors",
      ),
    ],
    [
      html.div([class("flex-1 space-y-1")], [
        html.div([class("font-semibold text-white text-lg")], [text(room.name)]),
        html.div([class("flex items-center gap-3 text-sm")], [
          html.span([class("text-gray-400")], [
            text(
              "👥 "
              <> int.to_string(room.player_count)
              <> "/"
              <> int.to_string(room.max_players),
            ),
          ]),
          html.span(
            [
              class(case room.status {
                room_info.Waiting -> "text-yellow-400"
                room_info.Active -> "text-green-400"
              }),
            ],
            [
              text(case room.status {
                room_info.Waiting -> "⏳ Waiting"
                room_info.Active -> "⚔️ Active"
              }),
            ],
          ),
        ]),
      ]),
      html.button(
        case can_join {
          True -> [
            class(
              "px-4 py-2 bg-blue-600 hover:bg-blue-500 rounded-lg text-white font-semibold transition-colors",
            ),
            event.on_click(JoinRoom(room.id)),
          ]
          False -> [
            class(
              "px-4 py-2 bg-gray-700 cursor-not-allowed rounded-lg text-gray-500 font-semibold",
            ),
            attribute("disabled", "disabled"),
          ]
        },
        [
          text(case is_full {
            True -> "Full"
            False -> "Join →"
          }),
        ],
      ),
    ],
  )
}
