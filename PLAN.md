# Room Selection System - Implementation Plan

**Project**: Pondering My Orb  
**Feature**: Multi-Room Support with Start Screen  
**Type**: Major Refactor  
**Estimated Effort**: 1-2 days  
**Risk Level**: Medium-High  

---

## 🎯 Objectives

Transform the game from a single hardcoded room to a full multi-room system with:
- **Start Screen** - Player name entry and room browser
- **Dynamic Rooms** - Players can create and join rooms on-demand
- **Room Registry** - Server manages multiple concurrent game rooms
- **State Management** - Client transitions between StartScreen → Connecting → InGame

---

## 📊 Current State

### Client
- Auto-connects to `ws://localhost:8080` on page load
- Hardcoded player name: "LocalPlayer"
- No lobby or room selection
- Game starts immediately with 3D rendering

### Server
- One hardcoded room: "game_room"
- Room created at server startup
- No room management infrastructure
- `room_id` parameter in `JoinRoom` message is ignored

---

## 🏗️ Architecture Overview

### Application States

```
┌─────────────────┐
│  START SCREEN   │ ← New! (Lustre UI only)
│  - Enter name   │
│  - Room browser │
│  - Create room  │
└────────┬────────┘
         │ (Join Room)
         ▼
┌─────────────────┐
│   CONNECTING    │ ← New! (Loading state)
│  - WebSocket    │
│  - Wait for OK  │
└────────┬────────┘
         │ (RoomJoined)
         ▼
┌─────────────────┐
│    IN-GAME      │ ← Existing (3D + HUD)
│  - 3D gameplay  │
│  - Health/Mana  │
│  - Wand UI      │
└─────────────────┘
```

### State Transitions

| From | To | Trigger |
|------|------|---------|
| StartScreen | Connecting | User clicks "Join Room" |
| Connecting | InGame | `RoomJoined` message received |
| Connecting | StartScreen | Connection error or timeout |
| InGame | StartScreen | User leaves or disconnected |

---

## 📋 Implementation Phases

### **Phase 1: Server - Room Registry Infrastructure**

#### 1.1 Create Shared Types (`shared/src/shared/room_info.gleam`)

```gleam
pub type RoomInfo {
  RoomInfo(
    id: String,
    name: String,
    player_count: Int,
    max_players: Int,
    status: RoomStatus,
    created_at: timestamp.Timestamp,
  )
}

pub type RoomStatus {
  Waiting  // < 2 players
  Active   // 2+ players, game in progress
}
```

**JSON Encoding/Decoding:**
- `encode(info: RoomInfo) -> json.Json`
- `decoder() -> decode.Decoder(RoomInfo)`

#### 1.2 Extend Network Protocol (`shared/src/shared/game_message.gleam`)

**New Client Messages:**
```gleam
pub type ClientMessage {
  // Existing...
  
  // New:
  ListRooms
  CreateRoom(room_name: String, max_players: Int)
  // JoinRoom already exists, but room_id becomes meaningful
}
```

**New Server Messages:**
```gleam
pub type ServerMessage {
  // Existing...
  
  // New:
  RoomList(rooms: List(room_info.RoomInfo))
  RoomCreated(room_id: String, room_info: room_info.RoomInfo)
  RoomFull(room_id: String)
  RoomNotFound(room_id: String)
}
```

#### 1.3 Create Room Registry Actor (`server/src/server/room_registry.gleam`)

**State:**
```gleam
pub type State {
  State(
    rooms: dict.Dict(String, RoomState),
    player_factory: process.Name,
    projectile_factory: process.Name,
    enemy_factory: process.Name,
    wand_factory: process.Name,
    next_room_id: Int,
  )
}

pub type RoomState {
  RoomState(
    info: room_info.RoomInfo,
    actor: process.Subject(room.Msg),
    connections: set.Set(ewe.WebsocketConnection),
  )
}
```

**Messages:**
```gleam
pub type Msg {
  // From WebSocket handler
  ClientConnected(
    conn: ewe.WebsocketConnection,
    reply: process.Subject(OutgoingMsg)
  )
  ClientDisconnected(conn: ewe.WebsocketConnection)
  ClientMessage(conn: ewe.WebsocketConnection, data: BitArray)
  
  // From room actors
  RoomPlayerCountChanged(room_id: String, count: Int)
  RoomStatusChanged(room_id: String, status: room_info.RoomStatus)
  RoomEmpty(room_id: String)
}

pub type OutgoingMsg {
  SendFrame(BitArray)
  Disconnect
}
```

**Key Behaviors:**

- **CreateRoom**:
  1. Validate room name (1-50 chars, valid characters)
  2. Check for duplicate names
  3. Generate unique room_id: `"room_<timestamp>_<counter>"`
  4. Start new room actor via `room.start()`
  5. Add to `rooms` dict
  6. Reply with `RoomCreated` message

- **JoinRoom**:
  1. Validate room exists
  2. Check max_players limit
  3. Forward connection to room actor
  4. Update room connection set

- **ListRooms**:
  1. Collect all room info from `rooms` dict
  2. Send `RoomList` message to client

- **RoomEmpty**:
  1. Remove from `rooms` dict
  2. Room actor will be garbage collected

#### 1.4 Update Server Entry Point (`server/src/server.gleam`)

**Before:**
```gleam
let game_room_name = process.new_name("game_room")
let room = supervision.worker(fn() {
  room.start(game_room_name, ...)
})
```

**After:**
```gleam
let room_registry_name = process.new_name("room_registry")
let registry = supervision.worker(fn() {
  room_registry.start(
    room_registry_name,
    player_factory_name,
    projectile_factory_name,
    enemy_factory_name,
    wand_factory_name,
  )
})

// WebSocket routes to room_registry instead of room
ewe.new(fn(request) {
  ewe.upgrade_websocket(
    request,
    on_init: fn(conn, selector) {
      let self = process.new_subject()
      actor.send(
        process.named_subject(room_registry_name),
        room_registry.ClientConnected(conn, self),
      )
      #(self, process.select(selector, self))
    },
    // ... rest of handlers route through registry
  )
})
```

#### 1.5 Modify Room Actor (`server/src/server/room.gleam`)

**Add to State:**
```gleam
pub type State {
  State(
    // Existing fields...
    
    // New:
    room_id: String,
    room_registry: Option(process.Subject(room_registry.Msg)),
  )
}
```

**Notify Registry on Player Count Changes:**
```gleam
// In handle_player_joined:
case state.room_registry {
  Some(registry) -> {
    actor.send(registry, room_registry.RoomPlayerCountChanged(
      state.room_id,
      dict.size(state.player_actors),
    ))
  }
  None -> Nil
}

// When starting tick loop (first player):
case state.room_registry {
  Some(registry) -> {
    actor.send(registry, room_registry.RoomStatusChanged(
      state.room_id,
      room_info.Active,
    ))
  }
  None -> Nil
}

// When stopping tick loop (last player):
case state.room_registry {
  Some(registry) -> {
    actor.send(registry, room_registry.RoomEmpty(state.room_id))
  }
  None -> Nil
}
```

---

### **Phase 2: Client - Application State Management**

#### 2.1 Create AppState Type (`client/src/client.gleam`)

```gleam
pub type AppState {
  StartScreen(start_screen.Model)
  Connecting(connecting.Model)
  InGame(game.Model)
}

pub type Model {
  Model(
    state: AppState,
    network: network.Model,
    bridge: bridge_ui.Bridge(bridge.BridgeMsg),
  )
}
```

#### 2.2 Refactor Init Function

**Before:**
```gleam
pub fn init(ctx, bridge) {
  // Initialize all game modules
  let #(map_model, map_effect) = map.init()
  let #(player_model, player_effect) = player.init()
  // ... etc
  
  // Auto-connect
  let connect_effect = effect.dispatch(
    NetworkMsg(network.Connect("ws://localhost:8080", "LocalPlayer"))
  )
}
```

**After:**
```gleam
pub fn init(ctx, bridge) {
  let #(network_model, network_effect) = network.init()
  let #(start_screen_model, start_screen_effect) = start_screen.init()
  
  let model = Model(
    state: StartScreen(start_screen_model),
    network: network_model,
    bridge: bridge,
  )
  
  // NO auto-connect - wait for user action
  #(model, effect.batch([...]), option.None)
}
```

#### 2.3 Update Message Type

```gleam
pub type Msg {
  // Existing
  NetworkMsg(network.Msg)
  FromBridge(bridge.BridgeMsg)
  
  // New
  StartScreenMsg(start_screen.Msg)
  ConnectingMsg(connecting.Msg)
  GameMsg(GameMsg)  // Rename existing to distinguish
  
  // State transitions
  TransitionToConnecting(room_id: String, player_name: String)
  TransitionToInGame
  TransitionToStartScreen(reason: String)
}
```

#### 2.4 Implement State Transitions in Update

```gleam
pub fn update(model: Model, msg: Msg, ctx: Context) {
  case msg {
    TransitionToConnecting(room_id, player_name) -> {
      let #(connecting_model, connecting_effect) = 
        connecting.init(room_id, player_name)
      
      // Connect to WebSocket
      let connect_effect = effect.dispatch(
        NetworkMsg(network.Connect("ws://localhost:8080", player_name))
      )
      
      #(
        Model(..model, state: Connecting(connecting_model)),
        effect.batch([...]),
        option.None,
      )
    }
    
    TransitionToInGame -> {
      // Initialize game modules NOW (lazy initialization)
      let #(map_model, _) = map.init()
      let #(player_model, _) = player.init()
      // ... etc
      
      let game_model = GameModel(
        map: map_model,
        player: player_model,
        // ...
      )
      
      #(
        Model(..model, state: InGame(game_model)),
        effect.none(),
        option.None,
      )
    }
    
    TransitionToStartScreen(reason) -> {
      // Clean up game state
      // Disconnect network if needed
      let #(start_screen_model, start_screen_effect) = start_screen.init()
      
      #(
        Model(..model, state: StartScreen(start_screen_model)),
        start_screen_effect,
        option.None,
      )
    }
    
    // Delegate to current state
    StartScreenMsg(ss_msg) -> {
      case model.state {
        StartScreen(ss_model) -> {
          let #(new_ss, ss_effect) = start_screen.update(ss_model, ss_msg)
          #(
            Model(..model, state: StartScreen(new_ss)),
            effect.map(ss_effect, StartScreenMsg),
            option.None,
          )
        }
        _ -> #(model, effect.none(), option.None)
      }
    }
    
    // Similar for ConnectingMsg and GameMsg...
  }
}
```

#### 2.5 Update View Function

```gleam
pub fn view(model: Model, ctx: Context) -> scene.Node {
  case model.state {
    StartScreen(_) -> {
      // Hide 3D game, show only UI
      scene.empty(id: "root", children: [])
    }
    
    Connecting(_) -> {
      // Show loading screen (handled by Lustre UI)
      scene.empty(id: "root", children: [])
    }
    
    InGame(game_model) -> {
      // Existing game rendering
      render_game(game_model, ctx)
    }
  }
}
```

#### 2.6 Update Network Module (`client/src/client/network.gleam`)

**Add Room Management Messages:**
```gleam
pub type Msg {
  // Existing...
  
  // New:
  RequestRoomList
  RequestCreateRoom(room_name: String, max_players: Int)
  RequestJoinRoom(room_id: String)
}
```

**Update Handler:**
```gleam
pub fn update(model: Model, msg: Msg, ...) {
  case msg {
    RequestRoomList -> {
      let effect = send_client_message(
        model,
        game_message.ListRooms,
      )
      #(model, effect)
    }
    
    RequestCreateRoom(name, max) -> {
      let effect = send_client_message(
        model,
        game_message.CreateRoom(name, max),
      )
      #(model, effect)
    }
    
    RequestJoinRoom(room_id) -> {
      // Will be sent after WebSocket connects
      // Store room_id in model for pending join
      #(Model(..model, pending_room_join: Some(room_id)), effect.none())
    }
    
    // ... rest
  }
}
```

---

### **Phase 3: Client - Start Screen UI**

#### 3.1 Create Start Screen Module (`client/src/client/start_screen.gleam`)

**Model:**
```gleam
pub type Model {
  Model(
    player_name: String,
    player_name_error: Option(String),
    rooms: List(room_info.RoomInfo),
    loading_rooms: Bool,
    show_create_modal: Bool,
    new_room_name: String,
    new_room_max_players: Int,
    error: Option(String),
  )
}
```

**Messages:**
```gleam
pub type Msg {
  // Input
  PlayerNameChanged(String)
  PlayerNameBlurred
  
  // Room browser
  RefreshRoomsClicked
  JoinRoomClicked(room_id: String)
  
  // Create room
  CreateRoomClicked
  CreateRoomCancelled
  CreateRoomConfirmed
  NewRoomNameChanged(String)
  NewRoomMaxPlayersChanged(Int)
  
  // Network responses (dispatched from parent)
  RoomListReceived(List(room_info.RoomInfo))
  RoomCreatedReceived(String, room_info.RoomInfo)
  RoomListError(String)
}
```

**Init:**
```gleam
pub fn init() -> #(Model, effect.Effect(Msg)) {
  let model = Model(
    player_name: "",
    player_name_error: None,
    rooms: [],
    loading_rooms: False,
    show_create_modal: False,
    new_room_name: "",
    new_room_max_players: 8,
    error: None,
  )
  
  // Request room list on init
  #(model, effect.dispatch(RefreshRoomsClicked))
}
```

**Update:**
```gleam
pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    PlayerNameChanged(name) -> {
      #(Model(..model, player_name: name, player_name_error: None), effect.none())
    }
    
    PlayerNameBlurred -> {
      let error = validate_player_name(model.player_name)
      #(Model(..model, player_name_error: error), effect.none())
    }
    
    RefreshRoomsClicked -> {
      // This will be caught by parent and sent to network
      #(Model(..model, loading_rooms: True), effect.none())
    }
    
    JoinRoomClicked(room_id) -> {
      case validate_player_name(model.player_name) {
        Some(error) -> {
          #(Model(..model, player_name_error: Some(error)), effect.none())
        }
        None -> {
          // Emit message to parent to transition state
          #(model, effect.none())
        }
      }
    }
    
    CreateRoomClicked -> {
      #(Model(..model, show_create_modal: True), effect.none())
    }
    
    CreateRoomCancelled -> {
      #(
        Model(..model, show_create_modal: False, new_room_name: ""),
        effect.none(),
      )
    }
    
    CreateRoomConfirmed -> {
      // Validate and emit to parent
      case validate_room_name(model.new_room_name) {
        Some(error) -> {
          #(Model(..model, error: Some(error)), effect.none())
        }
        None -> {
          // Emit create room request to parent
          #(model, effect.none())
        }
      }
    }
    
    RoomListReceived(rooms) -> {
      #(
        Model(..model, rooms: rooms, loading_rooms: False, error: None),
        effect.none(),
      )
    }
    
    RoomListError(error) -> {
      #(
        Model(..model, loading_rooms: False, error: Some(error)),
        effect.none(),
      )
    }
  }
}

fn validate_player_name(name: String) -> Option(String) {
  case string.length(name) {
    len if len < 3 -> Some("Name must be at least 3 characters")
    len if len > 20 -> Some("Name must be less than 20 characters")
    _ -> {
      // Check alphanumeric + spaces
      case string.to_graphemes(name) |> list.all(is_valid_char) {
        True -> None
        False -> Some("Name must contain only letters, numbers, and spaces")
      }
    }
  }
}

fn validate_room_name(name: String) -> Option(String) {
  case string.length(name) {
    len if len < 1 -> Some("Room name is required")
    len if len > 50 -> Some("Room name must be less than 50 characters")
    _ -> None
  }
}
```

**View:**
```gleam
pub fn view(model: Model) -> element.Element(Msg) {
  html.div(
    [
      class("min-h-screen bg-gray-900 text-white flex items-center justify-center p-4"),
    ],
    [
      html.div([class("max-w-2xl w-full space-y-8")], [
        // Title
        html.h1([class("text-6xl font-bold text-center mb-8")], [
          text("🔮 PONDERING MY ORB 🔮"),
        ]),
        
        // Player name input
        player_name_input(model),
        
        // Room browser
        room_browser(model),
        
        // Create room button
        html.div([class("flex justify-center")], [
          html.button(
            [
              class("px-6 py-3 bg-green-600 hover:bg-green-700 rounded-lg font-semibold"),
              event.on_click(CreateRoomClicked),
            ],
            [text("CREATE NEW ROOM")],
          ),
        ]),
        
        // Error display
        case model.error {
          Some(err) -> error_banner(err)
          None -> element.none()
        },
        
        // Create room modal
        case model.show_create_modal {
          True -> create_room_modal(model)
          False -> element.none()
        },
      ]),
    ],
  )
}

fn player_name_input(model: Model) -> element.Element(Msg) {
  html.div([class("space-y-2")], [
    html.label([class("block text-sm font-medium")], [
      text("Player Name"),
    ]),
    html.input([
      attribute.type_("text"),
      attribute.placeholder("Enter your name..."),
      attribute.value(model.player_name),
      class("w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg focus:outline-none focus:border-blue-500"),
      event.on_input(PlayerNameChanged),
      event.on_blur(PlayerNameBlurred),
    ]),
    case model.player_name_error {
      Some(err) -> 
        html.p([class("text-red-400 text-sm")], [text(err)])
      None -> element.none()
    },
  ])
}

fn room_browser(model: Model) -> element.Element(Msg) {
  html.div([class("bg-gray-800 rounded-lg p-4 space-y-4")], [
    // Header
    html.div([class("flex justify-between items-center")], [
      html.h2([class("text-xl font-semibold")], [text("AVAILABLE ROOMS")]),
      html.button(
        [
          class("px-3 py-1 bg-gray-700 hover:bg-gray-600 rounded"),
          event.on_click(RefreshRoomsClicked),
          attribute.disabled(model.loading_rooms),
        ],
        [text("🔄 Refresh")],
      ),
    ]),
    
    // Room list
    case model.loading_rooms {
      True -> loading_spinner()
      False -> room_list(model.rooms)
    },
  ])
}

fn room_list(rooms: List(room_info.RoomInfo)) -> element.Element(Msg) {
  case rooms {
    [] -> 
      html.div([class("text-center text-gray-500 py-8")], [
        text("No rooms available. Create one to start playing!"),
      ])
    _ -> 
      html.div([class("space-y-2")], list.map(rooms, room_card))
  }
}

fn room_card(room: room_info.RoomInfo) -> element.Element(Msg) {
  let status_color = case room.status {
    room_info.Active -> "bg-green-500"
    room_info.Waiting -> "bg-yellow-500"
  }
  
  let status_text = case room.status {
    room_info.Active -> "Active"
    room_info.Waiting -> "Waiting"
  }
  
  html.div(
    [class("bg-gray-700 rounded-lg p-4 flex items-center justify-between")],
    [
      html.div([class("flex items-center space-x-4")], [
        html.div([class("w-3 h-3 rounded-full " <> status_color)], []),
        html.div([], [
          html.div([class("font-semibold text-lg")], [text(room.name)]),
          html.div([class("text-sm text-gray-400")], [
            text(status_text <> " • " <> int.to_string(room.player_count) <> "/" <> int.to_string(room.max_players) <> " players"),
          ]),
        ]),
      ]),
      html.button(
        [
          class("px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded font-semibold"),
          event.on_click(JoinRoomClicked(room.id)),
          attribute.disabled(room.player_count >= room.max_players),
        ],
        [text("JOIN")],
      ),
    ],
  )
}

fn create_room_modal(model: Model) -> element.Element(Msg) {
  html.div(
    [
      class("fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"),
      event.on_click(CreateRoomCancelled),
    ],
    [
      html.div(
        [
          class("bg-gray-800 rounded-lg p-6 max-w-md w-full"),
          event.on_click(fn(e) { e.stop_propagation() }),
        ],
        [
          html.h2([class("text-2xl font-bold mb-4")], [text("Create New Room")]),
          
          // Room name input
          html.div([class("space-y-2 mb-4")], [
            html.label([class("block text-sm font-medium")], [text("Room Name")]),
            html.input([
              attribute.type_("text"),
              attribute.placeholder("My Awesome Room"),
              attribute.value(model.new_room_name),
              class("w-full px-4 py-2 bg-gray-700 border border-gray-600 rounded focus:outline-none focus:border-blue-500"),
              event.on_input(NewRoomNameChanged),
            ]),
          ]),
          
          // Max players selector
          html.div([class("space-y-2 mb-6")], [
            html.label([class("block text-sm font-medium")], [text("Max Players")]),
            html.select(
              [
                class("w-full px-4 py-2 bg-gray-700 border border-gray-600 rounded"),
                event.on_input(fn(val) {
                  case int.parse(val) {
                    Ok(n) -> NewRoomMaxPlayersChanged(n)
                    Error(_) -> NewRoomMaxPlayersChanged(8)
                  }
                }),
              ],
              [
                html.option([attribute.value("4")], [text("4 Players")]),
                html.option([attribute.value("8"), attribute.selected(True)], [text("8 Players")]),
                html.option([attribute.value("16")], [text("16 Players")]),
              ],
            ),
          ]),
          
          // Buttons
          html.div([class("flex space-x-4")], [
            html.button(
              [
                class("flex-1 px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded"),
                event.on_click(CreateRoomCancelled),
              ],
              [text("Cancel")],
            ),
            html.button(
              [
                class("flex-1 px-4 py-2 bg-green-600 hover:bg-green-700 rounded font-semibold"),
                event.on_click(CreateRoomConfirmed),
              ],
              [text("Create")],
            ),
          ]),
        ],
      ),
    ],
  )
}

fn loading_spinner() -> element.Element(Msg) {
  html.div([class("flex justify-center py-8")], [
    html.div([class("animate-spin h-8 w-8 border-4 border-blue-500 border-t-transparent rounded-full")], []),
  ])
}

fn error_banner(message: String) -> element.Element(Msg) {
  html.div([class("bg-red-600 text-white p-4 rounded-lg")], [
    text(message),
  ])
}
```

---

### **Phase 4: Client - Connecting Screen**

#### 4.1 Create Connecting Module (`client/src/client/connecting.gleam`)

**Model:**
```gleam
pub type Model {
  Model(
    room_id: String,
    room_name: Option(String),
    player_name: String,
    started_at: timestamp.Timestamp,
    timeout_ms: Int,
  )
}
```

**Messages:**
```gleam
pub type Msg {
  CheckTimeout
  ConnectionTimedOut
}
```

**Init:**
```gleam
pub fn init(room_id: String, player_name: String) -> #(Model, effect.Effect(Msg)) {
  let model = Model(
    room_id: room_id,
    room_name: None,
    player_name: player_name,
    started_at: timestamp.now(),
    timeout_ms: 10000,  // 10 seconds
  )
  
  // Start timeout checker
  let timeout_effect = effect.from(fn(dispatch) {
    set_timeout(10000, fn() { dispatch(ConnectionTimedOut) })
  })
  
  #(model, timeout_effect)
}
```

**View:**
```gleam
pub fn view(model: Model) -> element.Element(Msg) {
  html.div(
    [class("min-h-screen bg-gray-900 text-white flex items-center justify-center")],
    [
      html.div([class("text-center space-y-4")], [
        // Spinner
        html.div([class("flex justify-center mb-4")], [
          html.div([class("animate-spin h-16 w-16 border-4 border-blue-500 border-t-transparent rounded-full")], []),
        ]),
        
        // Text
        html.h2([class("text-2xl font-semibold")], [
          text("Connecting to room..."),
        ]),
        html.p([class("text-gray-400")], [
          text("Player: " <> model.player_name),
        ]),
      ]),
    ],
  )
}
```

---

### **Phase 5: Integration & Testing**

#### 5.1 Wire State Transitions

In `client.gleam`, handle these key transitions:

```gleam
// In update function:
case msg {
  // From start screen - user clicks join
  StartScreenMsg(start_screen.JoinRoomClicked(room_id)) -> {
    case model.state {
      StartScreen(ss_model) -> {
        effect.dispatch(TransitionToConnecting(
          room_id,
          ss_model.player_name,
        ))
      }
      _ -> effect.none()
    }
  }
  
  // From network - room joined successfully
  NetworkMsg(network.ReceivedMessage(data)) -> {
    case game_message.decode_server_message(data) {
      Ok(game_message.RoomJoined(player_id, players)) -> {
        case model.state {
          Connecting(_) -> {
            effect.dispatch(TransitionToInGame)
          }
          _ -> effect.none()
        }
      }
      // Handle other messages...
    }
  }
  
  // Connection timeout or error
  ConnectingMsg(connecting.ConnectionTimedOut) -> {
    effect.dispatch(TransitionToStartScreen(
      "Connection timed out. Please try again.",
    ))
  }
}
```

#### 5.2 Update HTML to Support State Visibility

Modify `client/dist/index.html`:

```html
<body>
  <div id="game" style="display: none;"></div>  <!-- Hidden by default -->
  <div id="ui"></div>
</body>
```

Update `client.gleam` to show/hide game div:
```gleam
// Use FFI to toggle visibility
@external(javascript, "./client_ffi.mjs", "showGameCanvas")
fn show_game_canvas() -> Nil

@external(javascript, "./client_ffi.mjs", "hideGameCanvas")
fn hide_game_canvas() -> Nil

// In state transitions:
TransitionToInGame -> {
  show_game_canvas()
  // ... rest
}

TransitionToStartScreen(_) -> {
  hide_game_canvas()
  // ... rest
}
```

Create `client/src/client_ffi.mjs`:
```javascript
export function showGameCanvas() {
  document.getElementById('game').style.display = 'block';
}

export function hideGameCanvas() {
  document.getElementById('game').style.display = 'none';
}
```

#### 5.3 Testing Checklist

- [ ] Single player can create a room
- [ ] Single player can join a room
- [ ] Room appears in room list for other clients
- [ ] Multiple players can join the same room
- [ ] Room player count updates in real-time
- [ ] Room status changes from Waiting → Active with 2+ players
- [ ] Room is removed from list when last player leaves
- [ ] Room registry handles 10+ concurrent rooms
- [ ] Invalid player names are rejected
- [ ] Full rooms cannot be joined
- [ ] Connection timeout works
- [ ] Refresh room list updates correctly

---

### **Phase 6: Polish & Edge Cases**

#### 6.1 Duplicate Player Names

In `server/room.gleam`:
```gleam
fn ensure_unique_player_name(name: String, existing_names: List(String)) -> String {
  case list.contains(existing_names, name) {
    False -> name
    True -> {
      // Try name_2, name_3, etc.
      find_available_name(name, 2, existing_names)
    }
  }
}

fn find_available_name(base: String, n: Int, existing: List(String)) -> String {
  let candidate = base <> "_" <> int.to_string(n)
  case list.contains(existing, candidate) {
    False -> candidate
    True -> find_available_name(base, n + 1, existing)
  }
}
```

#### 6.2 LocalStorage for Player Name

In `client/start_screen.gleam`:
```gleam
// On init, load from localStorage
pub fn init() -> #(Model, effect.Effect(Msg)) {
  let saved_name = get_saved_player_name()
  
  let model = Model(
    player_name: option.unwrap(saved_name, ""),
    // ... rest
  )
  
  #(model, ...)
}

// On player name change, save to localStorage
PlayerNameChanged(name) -> {
  save_player_name(name)
  #(Model(..model, player_name: name), effect.none())
}

@external(javascript, "./start_screen_ffi.mjs", "savePlayerName")
fn save_player_name(name: String) -> Nil

@external(javascript, "./start_screen_ffi.mjs", "getSavedPlayerName")
fn get_saved_player_name() -> Option(String)
```

Create `client/src/client/start_screen_ffi.mjs`:
```javascript
export function savePlayerName(name) {
  localStorage.setItem('pondering_player_name', name);
}

export function getSavedPlayerName() {
  const name = localStorage.getItem('pondering_player_name');
  return name ? { type: 'Some', value: name } : { type: 'None' };
}
```

#### 6.3 Keyboard Shortcuts

In `start_screen.gleam`:
```gleam
// Add global keydown listener
pub fn init() -> #(Model, effect.Effect(Msg)) {
  let model = ...
  
  let keyboard_effect = effect.from(fn(dispatch) {
    add_keyboard_listener(fn(key) {
      case key {
        "Enter" -> dispatch(TryJoinFirstRoom)
        "Escape" -> dispatch(CreateRoomCancelled)
        _ -> Nil
      }
    })
  })
  
  #(model, effect.batch([..., keyboard_effect]))
}
```

#### 6.4 Leave Room Button

In `client/ui.gleam`, add leave button:
```gleam
fn view(model: Model) -> Element(Msg) {
  html.div([class("fixed inset-0 pointer-events-none z-10")], [
    // Top-right: Leave Room button
    html.div([class("absolute top-4 right-4 pointer-events-auto")], [
      html.button(
        [
          class("px-4 py-2 bg-red-600 hover:bg-red-700 rounded"),
          event.on_click(LeaveRoomClicked),
        ],
        [text("Leave Room")],
      ),
    ]),
    
    // Existing UI...
  ])
}
```

Handle in `client.gleam`:
```gleam
UIMsg(ui.LeaveRoomClicked) -> {
  // Disconnect and return to start screen
  let disconnect_effect = effect.dispatch(
    NetworkMsg(network.Disconnect)
  )
  let transition_effect = effect.dispatch(
    TransitionToStartScreen("You left the room.")
  )
  
  #(model, effect.batch([disconnect_effect, transition_effect]), option.None)
}
```

---

## 📁 File Changes Summary

### New Files (8)
1. `shared/src/shared/room_info.gleam` - RoomInfo types
2. `server/src/server/room_registry.gleam` - Room registry actor
3. `client/src/client/start_screen.gleam` - Start screen UI
4. `client/src/client/connecting.gleam` - Connecting screen
5. `client/src/client_ffi.mjs` - Canvas visibility FFI
6. `client/src/client/start_screen_ffi.mjs` - LocalStorage FFI
7. `PLAN.md` - This file
8. `ARCHITECTURE.md` - Updated architecture docs (optional)

### Modified Files (10)
1. `shared/src/shared/game_message.gleam` - New message types
2. `server/src/server.gleam` - Use room_registry
3. `server/src/server/room.gleam` - Notify registry
4. `client/src/client.gleam` - AppState management
5. `client/src/client/network.gleam` - Room requests
6. `client/src/client/ui.gleam` - Leave button
7. `client/dist/index.html` - Hidden game div
8. `shared/gleam.toml` - Add timestamp dependency (if needed)
9. `client/gleam.toml` - Add any new dependencies
10. `server/gleam.toml` - Add any new dependencies

### Lines of Code Estimate
- **Server**: ~800 lines (room_registry: 500, room modifications: 100, room_info: 100, messages: 100)
- **Client**: ~1200 lines (start_screen: 400, connecting: 150, client refactor: 400, network: 100, FFI: 50, messages: 100)
- **Total**: ~2000 lines

---

## ⚠️ Risk Mitigation

### High-Risk Areas
1. **State synchronization** between registry and rooms
2. **Network message ordering** (ListRooms response after join)
3. **Actor lifecycle** (room cleanup, factory supervision)
4. **Client state transitions** (race conditions)

### Mitigation Strategies
1. **Phase-by-phase implementation** - Test each phase thoroughly
2. **Feature flag** - Add `?legacy=true` to use old single-room flow
3. **Extensive logging** - Add debug logs for state transitions
4. **Unit tests** for room_registry actor
5. **Integration tests** with multiple browser tabs

---

## 🎯 Success Criteria

- [ ] Players can create rooms with custom names
- [ ] Room browser shows all active rooms
- [ ] Player count updates in real-time
- [ ] Multiple players can join the same room
- [ ] Empty rooms are cleaned up automatically
- [ ] 10+ concurrent rooms work without issues
- [ ] Connection errors are handled gracefully
- [ ] UI is responsive and intuitive
- [ ] No regressions in existing gameplay

---

## 📚 Additional Features (Future)

After this refactor is stable, consider:
- Private rooms with passwords
- Room search/filter
- Player avatars/colors
- Room settings (difficulty, game mode)
- Spectator mode
- Chat system
- Persistent stats
- Reconnection handling

---

**Status**: Ready to implement  
**Next Step**: Begin Phase 1 - Server Infrastructure
