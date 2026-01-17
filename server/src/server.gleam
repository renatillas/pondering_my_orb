/// Main server entry point using ewe for WebSocket connections
import ewe
import gleam/bit_array
import gleam/erlang/process
import gleam/otp/actor
import gleam/otp/factory_supervisor
import gleam/otp/static_supervisor
import gleam/otp/supervision
import logging
import server/enemy
import server/player
import server/projectile
import server/room
import server/wand
import spectator

pub fn main() {
  logging.configure()
  logging.set_level(logging.Debug)

  let assert Ok(_) = spectator.start()

  // Create factory supervisors for all actor types
  let player_factory_name = process.new_name("player_factory")
  let player_factory =
    factory_supervisor.worker_child(player.start)
    |> factory_supervisor.named(player_factory_name)
    |> factory_supervisor.supervised()

  let projectile_factory_name = process.new_name("projectile_factory")
  let projectile_factory =
    factory_supervisor.worker_child(projectile.start)
    |> factory_supervisor.named(projectile_factory_name)
    |> factory_supervisor.supervised()

  let enemy_factory_name = process.new_name("enemy_factory")
  let enemy_factory =
    factory_supervisor.worker_child(enemy.start)
    |> factory_supervisor.named(enemy_factory_name)
    |> factory_supervisor.supervised()

  let wand_factory_name = process.new_name("wand_factory")
  let wand_factory =
    factory_supervisor.worker_child(wand.start)
    |> factory_supervisor.named(wand_factory_name)
    |> factory_supervisor.supervised()

  // Start the game room actor, passing all factory names
  let game_room_name = process.new_name("game_room")
  let room =
    supervision.worker(fn() {
      room.start(
        game_room_name,
        player_factory_name,
        projectile_factory_name,
        enemy_factory_name,
        wand_factory_name,
      )
    })

  // Create the ewe WebSocket server
  let server =
    ewe.new(fn(request) {
      ewe.upgrade_websocket(
        request,
        on_init: fn(
          conn: ewe.WebsocketConnection,
          selector: process.Selector(room.OutgoingMsg),
        ) {
          // Create a subject for outgoing messages
          let self = process.new_subject()

          // Notify game room of new connection
          actor.send(
            process.named_subject(game_room_name),
            room.ClientConnected(conn, self),
          )

          #(self, process.select(selector, self))
        },
        handler: fn(conn, user_state, message) {
          case message {
            ewe.Binary(data) -> {
              // Send binary message to game room
              actor.send(
                process.named_subject(game_room_name),
                room.ClientMessage(conn, data),
              )
              ewe.websocket_continue(user_state)
            }
            ewe.Text(text) -> {
              // Convert text to binary and send to game room
              actor.send(
                process.named_subject(game_room_name),
                room.ClientMessage(conn, <<text:utf8>>),
              )
              ewe.websocket_continue(user_state)
            }
            ewe.User(room.SendFrame(data)) -> {
              // Convert BitArray to String for text frame
              let assert Ok(text) = bit_array.to_string(data)
              case ewe.send_text_frame(conn, text) {
                Ok(_) -> ewe.websocket_continue(user_state)
                Error(_) -> ewe.websocket_stop_abnormal("Failed to send frame")
              }
            }
            ewe.User(room.Disconnect) -> {
              ewe.send_close_frame(
                conn,
                ewe.NormalClosure("Disconnected by server"),
              )
            }
          }
        },
        on_close: fn(conn, _user_state) {
          actor.send(
            process.named_subject(game_room_name),
            room.ClientDisconnected(conn),
          )
        },
      )
    })
    |> ewe.listening(8080)
    |> ewe.supervised()

  let assert Ok(_sup_tree) =
    static_supervisor.new(static_supervisor.OneForOne)
    |> static_supervisor.add(player_factory)
    |> static_supervisor.add(projectile_factory)
    |> static_supervisor.add(enemy_factory)
    |> static_supervisor.add(wand_factory)
    |> static_supervisor.add(room)
    |> static_supervisor.add(server)
    |> static_supervisor.start()

  process.sleep_forever()
}
