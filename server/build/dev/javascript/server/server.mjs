import * as $conversation from "../conversation/conversation.mjs";
import { Text } from "../conversation/conversation.mjs";
import * as $http from "../gleam_http/gleam/http.mjs";
import * as $request from "../gleam_http/gleam/http/request.mjs";
import * as $response from "../gleam_http/gleam/http/response.mjs";
import * as $promise from "../gleam_javascript/gleam/javascript/promise.mjs";
import * as $dynamic from "../gleam_stdlib/gleam/dynamic.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import * as $bindings from "../plinth_cloudflare/plinth/cloudflare/bindings.mjs";
import * as $durable_object from "../plinth_cloudflare/plinth/cloudflare/durable_object.mjs";
import * as $worker from "../plinth_cloudflare/plinth/cloudflare/worker.mjs";
import { Ok, Empty as $Empty } from "./gleam.mjs";
import { forwardToStub as forward_to_stub } from "./server_ffi.mjs";

/**
 * Handle WebSocket upgrade requests by forwarding to a Durable Object.
 * 
 * @ignore
 */
function handle_websocket(js_request, env, room_id) {
  let $ = $bindings.durable_object_namespace(env, "GAME_ROOM");
  if ($ instanceof Ok) {
    let namespace = $[0];
    let do_id = $durable_object.id_from_name(namespace, room_id);
    let stub = $durable_object.get(namespace, do_id, new $option.None());
    return forward_to_stub(stub, js_request);
  } else {
    let _pipe = $response.new$(500);
    let _pipe$1 = $response.set_body(
      _pipe,
      new Text("GAME_ROOM binding not found"),
    );
    let _pipe$2 = $conversation.to_js_response(_pipe$1);
    return $promise.resolve(_pipe$2);
  }
}

/**
 * Handle health check endpoint.
 * 
 * @ignore
 */
function handle_health() {
  let _pipe = $response.new$(200);
  let _pipe$1 = $response.set_header(_pipe, "content-type", "application/json");
  let _pipe$2 = $response.set_body(_pipe$1, new Text("{\"status\":\"ok\"}"));
  let _pipe$3 = $conversation.to_js_response(_pipe$2);
  return $promise.resolve(_pipe$3);
}

/**
 * Handle listing available rooms.
 * 
 * @ignore
 */
function handle_list_rooms() {
  let _pipe = $response.new$(200);
  let _pipe$1 = $response.set_header(_pipe, "content-type", "application/json");
  let _pipe$2 = $response.set_body(_pipe$1, new Text("{\"rooms\":[]}"));
  let _pipe$3 = $conversation.to_js_response(_pipe$2);
  return $promise.resolve(_pipe$3);
}

/**
 * Handle room creation.
 * 
 * @ignore
 */
function handle_create_room() {
  let _pipe = $response.new$(201);
  let _pipe$1 = $response.set_header(_pipe, "content-type", "application/json");
  let _pipe$2 = $response.set_body(
    _pipe$1,
    new Text("{\"room_id\":\"new-room\"}"),
  );
  let _pipe$3 = $conversation.to_js_response(_pipe$2);
  return $promise.resolve(_pipe$3);
}

/**
 * Handle 404 Not Found.
 * 
 * @ignore
 */
function handle_not_found() {
  let _pipe = $response.new$(404);
  let _pipe$1 = $response.set_header(_pipe, "content-type", "application/json");
  let _pipe$2 = $response.set_body(
    _pipe$1,
    new Text("{\"error\":\"Not found\"}"),
  );
  let _pipe$3 = $conversation.to_js_response(_pipe$2);
  return $promise.resolve(_pipe$3);
}

/**
 * Main fetch handler for Cloudflare Workers.
 * This is the entry point for all incoming HTTP requests.
 */
export function fetch(js_request, env, _) {
  let req = $conversation.to_gleam_request(js_request);
  let $ = req.method;
  let $1 = $request.path_segments(req);
  if ($1 instanceof $Empty) {
    return handle_not_found();
  } else {
    let $2 = $1.tail;
    if ($2 instanceof $Empty) {
      return handle_not_found();
    } else {
      let $3 = $2.tail;
      if ($3 instanceof $Empty) {
        if ($ instanceof $http.Get) {
          let $4 = $1.head;
          if ($4 === "ws") {
            let room_id = $2.head;
            return handle_websocket(js_request, env, room_id);
          } else if ($4 === "api") {
            let $5 = $2.head;
            if ($5 === "health") {
              return handle_health();
            } else if ($5 === "rooms") {
              return handle_list_rooms();
            } else {
              return handle_not_found();
            }
          } else {
            return handle_not_found();
          }
        } else if ($ instanceof $http.Post) {
          let $4 = $1.head;
          if ($4 === "api") {
            let $5 = $2.head;
            if ($5 === "rooms") {
              return handle_create_room();
            } else {
              return handle_not_found();
            }
          } else {
            return handle_not_found();
          }
        } else {
          return handle_not_found();
        }
      } else {
        return handle_not_found();
      }
    }
  }
}
