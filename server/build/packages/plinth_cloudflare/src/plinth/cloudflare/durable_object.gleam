import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/javascript/array.{type Array}
import gleam/javascript/promise.{type Promise}
import gleam/json.{type Json}
import plinth/cloudflare/utils

pub type Namespace

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "id_from_name")
pub fn id_from_name(namespace: Namespace, name: String) -> Id

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "new_unique_id")
fn do_new_unique_id(jurisdiction: Json) -> Id

pub fn new_unique_id(jurisdiction) {
  let options =
    json.nullable(jurisdiction, fn(j) {
      json.object([#("jurisdiction", json.string(j))])
    })
  do_new_unique_id(options)
}

/// This is the string value of the objects id, not its name.
@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "id_from_string")
pub fn id_from_string(namespace: Namespace, id: String) -> Id

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "get")
fn do_get(namespace: Namespace, id: Id, options: Json) -> Stub

pub fn get(namespace, id, location_hint) {
  let options =
    json.nullable(location_hint, fn(hint) {
      json.object([#("locationHint", json.string(hint))])
    })
  do_get(namespace, id, options)
}

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "jurisdiction")
pub fn jurisdiction(namespace: Namespace, jurisdiction: String) -> Namespace

pub type Id

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "to_string")
pub fn to_string(id: Id) -> String

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "equals")
pub fn equals(id: Id, other: Id) -> Bool

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "name")
pub fn name(id: Id) -> String

pub type Stub

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "stub_id")
pub fn stub_id(stub: Stub) -> Id

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "rpc")
fn do_rpc(
  stub: Stub,
  method: String,
  args: Array(Json),
) -> Promise(Result(Json, String))

pub fn rpc(stub, method, args) {
  do_rpc(stub, method, array.from_list(args))
}

pub type State

// @deprecated("A Durable Object will remain active for at least 70 seconds after the last client disconnects if the Durable Object is still waiting on any ongoing work or outbound I/O. So waitUntil is not necessary. It remains part of the DurableObjectState interface to remain compatible with Workers Runtime APIs.")
// pub fn wait_until() 

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "block_concurrency_while")
pub fn block_concurrency_while(
  state: State,
  action: fn() -> Promise(t),
) -> NonConcurrentPromise(t)

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "state_id")
pub fn state_id(state: State) -> Id

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "storage")
pub fn storage(state: State) -> Storage

pub type Storage

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "sql")
pub fn sql(storage: Storage) -> Sql

pub type Sql

pub type SqlStorageCursor

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "exec")
fn do_exec(
  storage: Sql,
  query: String,
  bindings: Array(String),
) -> SqlStorageCursor

pub fn exec(storage, query, bindings) {
  do_exec(storage, query, array.from_list(bindings))
}

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "database_size")
pub fn database_size(storage: Sql) -> Int

pub type GetOptions {
  GetOptions(
    // Default false
    allow_concurrency: Bool,
    // Default false
    no_cache: Bool,
  )
}

pub fn get_default() {
  GetOptions(allow_concurrency: False, no_cache: False)
}

fn get_options_to_arg(options) {
  let GetOptions(allow_concurrency:, no_cache:) = options
  utils.sparse([
    #("allowConcurrency", json.bool(allow_concurrency)),
    #("noCache", json.bool(no_cache)),
  ])
}

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "get_one")
fn do_get_one(
  storage: Storage,
  key: String,
  options: Json,
) -> NonConcurrentPromise(Result(Dynamic, Nil))

// KV is not sync
pub fn get_one(storage: Storage, key: String, options: GetOptions) {
  do_get_one(storage, key, get_options_to_arg(options))
}

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "get_many")
fn do_get_many(
  storage: Storage,
  keys: Array(String),
  options: Json,
) -> NonConcurrentPromise(Result(Dynamic, Nil))

pub fn get_many(storage, keys, options) {
  let keys = array.from_list(keys)
  let args = get_options_to_arg(options)
  do_get_many(storage, keys, args)
}

pub type UpdateOptions {
  UpdateOptions(allow_unconfirmed: Bool, no_cache: Bool)
}

pub fn update_default() {
  UpdateOptions(allow_unconfirmed: False, no_cache: False)
}

fn update_options_to_arg(options) {
  let UpdateOptions(allow_unconfirmed:, no_cache:) = options
  utils.sparse([
    #("allowUnconfirmed", json.bool(allow_unconfirmed)),
    #("noCache", json.bool(no_cache)),
  ])
}

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "put_one")
fn do_put_one(
  storage: Storage,
  key: String,
  value: Json,
  options: Json,
) -> NonConcurrentPromise(Nil)

pub fn put_one(storage, key, value, options) {
  let options = update_options_to_arg(options)
  do_put_one(storage, key, value, options)
}

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "get_alarm")
pub fn get_alarm(storage: Storage) -> NonConcurrentPromise(Result(Int, Nil))

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "set_alarm")
pub fn set_alarm(
  storage: Storage,
  scheduled_time: Int,
) -> NonConcurrentPromise(Nil)

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "delete_alarm")
pub fn delete_alarm(storage: Storage) -> NonConcurrentPromise(Nil)

pub type AlarmInvocationInfo {
  AlarmInvocationInfo(retry_count: Int, is_retry: Bool)
}

pub fn alarm_invocation_info_decoder() {
  use retry_count <- decode.field("retryCount", decode.int)
  use is_retry <- decode.field("isRetry", decode.bool)
  decode.success(AlarmInvocationInfo(retry_count:, is_retry:))
}

pub type NonConcurrentPromise(t)

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "await_")
pub fn await(
  p: NonConcurrentPromise(t),
  then: fn(t) -> NonConcurrentPromise(u),
) -> NonConcurrentPromise(u)

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "resolve")
pub fn resolve(value: t) -> NonConcurrentPromise(t)

@external(javascript, "../../plinth_cloudflare_durable_object_ffi.mjs", "id")
pub fn to_promise(p: NonConcurrentPromise(t)) -> Promise(t)
