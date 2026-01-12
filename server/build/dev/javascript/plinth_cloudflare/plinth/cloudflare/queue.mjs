import * as $array from "../../../gleam_javascript/gleam/javascript/array.mjs";
import * as $promise from "../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $json from "../../../gleam_json/gleam/json.mjs";
import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $date from "../../../plinth/plinth/javascript/date.mjs";
import { toList, CustomType as $CustomType } from "../../gleam.mjs";
import * as $utils from "../../plinth/cloudflare/utils.mjs";
import {
  send as do_send,
  send_batch as do_send_batch,
  queue,
  messages,
  ack_all,
  retry_all as do_retry_all,
  id,
  timestamp,
  body,
  attempts,
  ack,
  retry,
} from "../../plinth_cloudflare_queue_ffi.mjs";

export { ack, ack_all, attempts, body, id, messages, queue, retry, timestamp };

export class MessageSendRequest extends $CustomType {
  constructor(body, content_type, delay_seconds) {
    super();
    this.body = body;
    this.content_type = content_type;
    this.delay_seconds = delay_seconds;
  }
}
export const MessageSendRequest$MessageSendRequest = (body, content_type, delay_seconds) =>
  new MessageSendRequest(body, content_type, delay_seconds);
export const MessageSendRequest$isMessageSendRequest = (value) =>
  value instanceof MessageSendRequest;
export const MessageSendRequest$MessageSendRequest$body = (value) => value.body;
export const MessageSendRequest$MessageSendRequest$0 = (value) => value.body;
export const MessageSendRequest$MessageSendRequest$content_type = (value) =>
  value.content_type;
export const MessageSendRequest$MessageSendRequest$1 = (value) =>
  value.content_type;
export const MessageSendRequest$MessageSendRequest$delay_seconds = (value) =>
  value.delay_seconds;
export const MessageSendRequest$MessageSendRequest$2 = (value) =>
  value.delay_seconds;

export class Text extends $CustomType {}
export const ContentType$Text = () => new Text();
export const ContentType$isText = (value) => value instanceof Text;

export class Bytes extends $CustomType {}
export const ContentType$Bytes = () => new Bytes();
export const ContentType$isBytes = (value) => value instanceof Bytes;

export class Json extends $CustomType {}
export const ContentType$Json = () => new Json();
export const ContentType$isJson = (value) => value instanceof Json;

export class V8 extends $CustomType {}
export const ContentType$V8 = () => new V8();
export const ContentType$isV8 = (value) => value instanceof V8;

function content_type_to_string(content_type) {
  if (content_type instanceof Text) {
    return "text";
  } else if (content_type instanceof Bytes) {
    return "bytes";
  } else if (content_type instanceof Json) {
    return "json";
  } else {
    return "v8";
  }
}

function content_type_to_json(content_type) {
  return $json.string(content_type_to_string(content_type));
}

function message_send_options(content_type, delay_seconds) {
  return $utils.sparse(
    toList([
      ["contentType", $json.nullable(content_type, content_type_to_json)],
      ["delaySeconds", $json.nullable(delay_seconds, $json.int)],
    ]),
  );
}

export function send(queue, message, content_type, delay_seconds) {
  let options = message_send_options(content_type, delay_seconds);
  return do_send(queue, message, options);
}

function message_send_request_to_json(request) {
  let body$1;
  let content_type;
  let delay_seconds;
  body$1 = request.body;
  content_type = request.content_type;
  delay_seconds = request.delay_seconds;
  return $json.object(
    toList([
      ["body", body$1],
      ["options", message_send_options(content_type, delay_seconds)],
    ]),
  );
}

export function send_batch(queue, messages, delay_seconds) {
  let _block;
  let _pipe = messages;
  let _pipe$1 = $list.map(_pipe, message_send_request_to_json);
  _block = $array.from_list(_pipe$1);
  let messages$1 = _block;
  let options = $utils.sparse(
    toList([["delaySeconds", $json.nullable(delay_seconds, $json.int)]]),
  );
  return do_send_batch(queue, messages$1, options);
}

export function retry_all(batch, delay_seconds) {
  let options = $utils.sparse(
    toList([["delaySeconds", $json.nullable(delay_seconds, $json.int)]]),
  );
  return do_retry_all(batch, options);
}
