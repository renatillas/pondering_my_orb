import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/int
import gleam/javascript/array.{type Array}
import gleam/javascript/promise.{type Promise}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None}
import plinth/cloudflare/utils

pub type Entrypoint

pub type InitialEvent(t) {
  InitialEvent(payload: t, timestamp: String, instance_id: String)
}

pub fn initial_event_decoder(payload_decoder) {
  use payload <- decode.field("payload", payload_decoder)
  // TODO date
  // use timestamp <- decode.field("timestamp", decode.string)
  use instance_id <- decode.field("instance_id", decode.string)
  decode.success(InitialEvent(payload, "timestamp", instance_id))
}

pub type SentEvent(t) {
  SentEvent(type_: String, payload: t, timestamp: String)
}

pub fn sent_event_decoder(payload_decoder) {
  use type_ <- decode.field("type", decode.string)
  use payload <- decode.field("payload", payload_decoder)

  decode.success(SentEvent(type_, payload, "timestamp"))
}

pub type Step

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "do_")
fn do_do(
  step: Step,
  name: String,
  config: json.Json,
  callback: fn() -> Promise(Json),
) -> Promise(Dynamic)

pub fn do(step, name, config, callback) {
  do_do(step, name, config_to_arg(config), callback)
}

pub type StepConfig {
  StepConfig(retries: Option(Retries), timeout: Option(Duration))
}

fn config_to_arg(config) {
  let StepConfig(retries:, timeout:) = config
  utils.sparse([
    #("retries", json.nullable(retries, retries_to_arg)),
    #("timeout", json.nullable(timeout, duration_to_arg)),
  ])
}

pub fn default() {
  StepConfig(retries: None, timeout: None)
}

pub type Retries {
  Retries(
    limit: Int,
    // initial delay
    delay: Duration,
    backoff: Backoff,
  )
}

fn retries_to_arg(retries) {
  let Retries(limit:, delay:, backoff:) = retries
  utils.sparse([
    #("limit", json.int(limit)),
    #("delay", duration_to_arg(delay)),
    #("backoff", backoff_to_arg(backoff)),
  ])
}

pub type Backoff {
  Constant
  Linear
  Exponential
}

fn backoff_to_arg(backoff) {
  case backoff {
    Constant -> "constant"
    Linear -> "linear"
    Exponential -> "exponential"
  }
  |> json.string
}

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "sleep")
fn do_sleep(step: Step, name: String, duration: json.Json) -> Promise(Nil)

pub fn sleep(step, name, duration) {
  do_sleep(step, name, duration_to_arg(duration))
}

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "sleep_until")
pub fn sleep_until(step: Step, name: String, until: Int) -> Promise(Nil)

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "wait_for_event")
fn do_wait_for_event(
  step: Step,
  name: String,
  options: json.Json,
) -> Promise(Result(Dynamic, String))

/// returns an error if it timed out
pub fn wait_for_event(
  step,
  name: String,
  type_: String,
  timeout: Option(Duration),
) {
  let options =
    utils.sparse([
      #("type", json.string(type_)),
      #("timeout", json.nullable(timeout, duration_to_arg)),
    ])
  do_wait_for_event(step, name, options)
}

pub type Workflow

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "create")
fn do_create(workflow: Workflow, options: json.Json) -> Promise(Instance)

pub fn create(workflow, options) {
  do_create(workflow, create_options_to_arg(options))
}

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "create_batch")
fn do_create_batch(
  workflow: Workflow,
  options: Array(json.Json),
) -> Promise(Array(Instance))

pub fn create_batch(workflow, options) {
  let options = list.map(options, create_options_to_arg)
  do_create_batch(workflow, array.from_list(options))
}

pub type CreateOptions {
  CreateOptions(id: Option(String), params: json.Json)
}

fn create_options_to_arg(options) {
  let CreateOptions(id:, params:) = options
  utils.sparse([#("id", json.nullable(id, json.string)), #("params", params)])
}

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "get")
pub fn get(workflow: Workflow, id: String) -> Promise(Result(Instance, String))

pub type Instance

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "id")
pub fn id(instance: Instance) -> String

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "status")
pub fn status(instance: Instance) -> Promise(InstanceStatus)

pub type InstanceStatus {
  InstanceStatus(status: String, error: Option(String), output: Dynamic)
}

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "pause")
pub fn pause(instance: Instance) -> Promise(Nil)

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "resume")
pub fn resume(instance: Instance) -> Promise(Nil)

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "restart")
pub fn restart(instance: Instance) -> Promise(Nil)

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "terminate")
pub fn terminate(instance: Instance) -> Promise(Nil)

@external(javascript, "../../plinth_cloudflare_workflow_ffi.mjs", "send_event")
fn do_send_event(instance: Instance, options: json.Json) -> Promise(Nil)

pub fn send_event(instance, type_, payload) {
  do_send_event(
    instance,
    utils.sparse([#("type", json.string(type_)), #("payload", payload)]),
  )
}

pub type Duration {
  Milliseconds(Int)
  Seconds(Int)
  Minutes(Int)
  Hours(Int)
  Days(Int)
  Weeks(Int)
  Months(Int)
  Years(Int)
}

fn duration_to_arg(duration) {
  case duration {
    Milliseconds(x) -> json.int(x)
    Seconds(x) -> json.string(human(x, "second"))
    Minutes(x) -> json.string(human(x, "minute"))
    Hours(x) -> json.string(human(x, "hour"))
    Days(x) -> json.string(human(x, "day"))
    Weeks(x) -> json.string(human(x, "week"))
    Months(x) -> json.string(human(x, "month"))
    Years(x) -> json.string(human(x, "year"))
  }
}

fn human(quantity, unit) {
  int.to_string(quantity)
  <> " "
  <> unit
  <> case quantity {
    1 -> ""
    _ -> "s"
  }
}
