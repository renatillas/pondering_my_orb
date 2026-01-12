/// Main entry point for the Cloudflare Worker.
/// Handles HTTP requests and routes them appropriately.

import conversation.{type JsRequest, type JsResponse, Text}
import gleam/dynamic
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise.{type Promise}
import gleam/option
import plinth/cloudflare/bindings
import plinth/cloudflare/durable_object.{type Stub}
import plinth/cloudflare/worker.{type Context}

/// Main fetch handler for Cloudflare Workers.
/// This is the entry point for all incoming HTTP requests.
pub fn fetch(
  js_request: JsRequest,
  env: dynamic.Dynamic,
  _ctx: Context,
) -> Promise(JsResponse) {
  let req = conversation.to_gleam_request(js_request)

  case req.method, request.path_segments(req) {
    // WebSocket upgrade for game connections
    http.Get, ["ws", room_id] -> handle_websocket(js_request, env, room_id)

    // API endpoints
    http.Get, ["api", "health"] -> handle_health()
    http.Get, ["api", "rooms"] -> handle_list_rooms()
    http.Post, ["api", "rooms"] -> handle_create_room()

    // Default: Not found
    _, _ -> handle_not_found()
  }
}

/// Handle WebSocket upgrade requests by forwarding to a Durable Object.
fn handle_websocket(
  js_request: JsRequest,
  env: dynamic.Dynamic,
  room_id: String,
) -> Promise(JsResponse) {
  // Get the Durable Object namespace from the environment
  case bindings.durable_object_namespace(env, "GAME_ROOM") {
    Ok(namespace) -> {
      // Create or get the Durable Object ID from the room name
      let do_id = durable_object.id_from_name(namespace, room_id)

      // Get the stub to communicate with the Durable Object
      let stub = durable_object.get(namespace, do_id, option.None)

      // Forward the request to the Durable Object
      // The Durable Object will handle the WebSocket upgrade
      forward_to_stub(stub, js_request)
    }
    Error(_) -> {
      response.new(500)
      |> response.set_body(Text("GAME_ROOM binding not found"))
      |> conversation.to_js_response
      |> promise.resolve
    }
  }
}

/// Forward a request to a Durable Object stub.
@external(javascript, "./server_ffi.mjs", "forwardToStub")
fn forward_to_stub(stub: Stub, request: JsRequest) -> Promise(JsResponse)

/// Handle health check endpoint.
fn handle_health() -> Promise(JsResponse) {
  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(Text("{\"status\":\"ok\"}"))
  |> conversation.to_js_response
  |> promise.resolve
}

/// Handle listing available rooms.
fn handle_list_rooms() -> Promise(JsResponse) {
  // For now, return an empty list
  // In a real implementation, this would query a database or KV store
  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(Text("{\"rooms\":[]}"))
  |> conversation.to_js_response
  |> promise.resolve
}

/// Handle room creation.
fn handle_create_room() -> Promise(JsResponse) {
  // For now, return a placeholder response
  // In a real implementation, this would create a new room entry
  response.new(201)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(Text("{\"room_id\":\"new-room\"}"))
  |> conversation.to_js_response
  |> promise.resolve
}

/// Handle 404 Not Found.
fn handle_not_found() -> Promise(JsResponse) {
  response.new(404)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(Text("{\"error\":\"Not found\"}"))
  |> conversation.to_js_response
  |> promise.resolve
}
