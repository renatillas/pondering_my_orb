import gleam/dynamic.{type Dynamic}
import gleam/javascript/array.{type Array}
import gleam/javascript/promise.{type Promise}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import plinth/cloudflare/utils
import plinth/javascript/date.{type Date}

pub type Queue

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "send")
fn do_send(queue: Queue, message: Json, options: Json) -> Promise(Nil)

pub fn send(queue, message, content_type, delay_seconds) {
  let options = message_send_options(content_type, delay_seconds)
  do_send(queue, message, options)
}

fn message_send_options(content_type, delay_seconds) {
  utils.sparse([
    #("contentType", json.nullable(content_type, content_type_to_json)),
    #("delaySeconds", json.nullable(delay_seconds, json.int)),
  ])
}

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "send_batch")
fn do_send_batch(
  queue: Queue,
  messages: Array(Json),
  options: Json,
) -> Promise(Nil)

pub fn send_batch(queue, messages, delay_seconds) {
  let messages =
    messages
    |> list.map(message_send_request_to_json)
    |> array.from_list
  let options =
    utils.sparse([#("delaySeconds", json.nullable(delay_seconds, json.int))])
  do_send_batch(queue, messages, options)
}

pub type MessageSendRequest {
  MessageSendRequest(
    body: Json,
    content_type: Option(ContentType),
    delay_seconds: Option(Int),
  )
}

fn message_send_request_to_json(request) {
  let MessageSendRequest(body:, content_type:, delay_seconds:) = request
  json.object([
    #("body", body),
    #("options", message_send_options(content_type, delay_seconds)),
  ])
}

pub type ContentType {
  Text
  Bytes
  Json
  V8
}

fn content_type_to_string(content_type) {
  case content_type {
    Text -> "text"
    Bytes -> "bytes"
    Json -> "json"
    V8 -> "v8"
  }
}

fn content_type_to_json(content_type) {
  json.string(content_type_to_string(content_type))
}

pub type MessageBatch

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "queue")
pub fn queue(batch: MessageBatch) -> String

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "messages")
pub fn messages(batch: MessageBatch) -> Array(Message)

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "ack_all")
pub fn ack_all(batch: MessageBatch) -> Nil

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "retry_all")
fn do_retry_all(batch: MessageBatch, options: Json) -> Nil

pub fn retry_all(batch: MessageBatch, delay_seconds: Option(Int)) -> Nil {
  let options =
    utils.sparse([#("delaySeconds", json.nullable(delay_seconds, json.int))])
  do_retry_all(batch, options)
}

pub type Message

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "id")
pub fn id(message: Message) -> String

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "timestamp")
pub fn timestamp(message: Message) -> Date

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "body")
pub fn body(message: Message) -> Dynamic

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "attempts")
pub fn attempts(message: Message) -> Int

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "ack")
pub fn ack(message: Message) -> Nil

@external(javascript, "../../plinth_cloudflare_queue_ffi.mjs", "retry")
pub fn retry(message: Message, delay_seconds: Option(Int)) -> Nil
