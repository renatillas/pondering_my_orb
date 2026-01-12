import * as $json from "../../../gleam_json/gleam/json.mjs";
import * as $location from "../../plinth/browser/location.mjs";
import * as $message_event from "../../plinth/browser/message_event.mjs";
import { close, location, postMessage as post_message, onMessage as on_message } from "../../window_ffi.mjs";

export { close, location, on_message, post_message };
