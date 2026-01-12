import * as $array from "../../../gleam_javascript/gleam/javascript/array.mjs";
import * as $promise from "../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $json from "../../../gleam_json/gleam/json.mjs";
import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import * as $decode from "../../../gleam_stdlib/gleam/dynamic/decode.mjs";
import { toList, CustomType as $CustomType } from "../../gleam.mjs";
import * as $utils from "../../plinth/cloudflare/utils.mjs";
import {
  id_from_name,
  new_unique_id as do_new_unique_id,
  id_from_string,
  get as do_get,
  jurisdiction,
  to_string,
  equals,
  name,
  stub_id,
  rpc as do_rpc,
  block_concurrency_while,
  state_id,
  storage,
  sql,
  exec as do_exec,
  database_size,
  get_one as do_get_one,
  get_many as do_get_many,
  put_one as do_put_one,
  get_alarm,
  set_alarm,
  delete_alarm,
  await_ as await$,
  resolve,
  id as to_promise,
} from "../../plinth_cloudflare_durable_object_ffi.mjs";

export {
  await$,
  block_concurrency_while,
  database_size,
  delete_alarm,
  equals,
  get_alarm,
  id_from_name,
  id_from_string,
  jurisdiction,
  name,
  resolve,
  set_alarm,
  sql,
  state_id,
  storage,
  stub_id,
  to_promise,
  to_string,
};

export class GetOptions extends $CustomType {
  constructor(allow_concurrency, no_cache) {
    super();
    this.allow_concurrency = allow_concurrency;
    this.no_cache = no_cache;
  }
}
export const GetOptions$GetOptions = (allow_concurrency, no_cache) =>
  new GetOptions(allow_concurrency, no_cache);
export const GetOptions$isGetOptions = (value) => value instanceof GetOptions;
export const GetOptions$GetOptions$allow_concurrency = (value) =>
  value.allow_concurrency;
export const GetOptions$GetOptions$0 = (value) => value.allow_concurrency;
export const GetOptions$GetOptions$no_cache = (value) => value.no_cache;
export const GetOptions$GetOptions$1 = (value) => value.no_cache;

export class UpdateOptions extends $CustomType {
  constructor(allow_unconfirmed, no_cache) {
    super();
    this.allow_unconfirmed = allow_unconfirmed;
    this.no_cache = no_cache;
  }
}
export const UpdateOptions$UpdateOptions = (allow_unconfirmed, no_cache) =>
  new UpdateOptions(allow_unconfirmed, no_cache);
export const UpdateOptions$isUpdateOptions = (value) =>
  value instanceof UpdateOptions;
export const UpdateOptions$UpdateOptions$allow_unconfirmed = (value) =>
  value.allow_unconfirmed;
export const UpdateOptions$UpdateOptions$0 = (value) => value.allow_unconfirmed;
export const UpdateOptions$UpdateOptions$no_cache = (value) => value.no_cache;
export const UpdateOptions$UpdateOptions$1 = (value) => value.no_cache;

export class AlarmInvocationInfo extends $CustomType {
  constructor(retry_count, is_retry) {
    super();
    this.retry_count = retry_count;
    this.is_retry = is_retry;
  }
}
export const AlarmInvocationInfo$AlarmInvocationInfo = (retry_count, is_retry) =>
  new AlarmInvocationInfo(retry_count, is_retry);
export const AlarmInvocationInfo$isAlarmInvocationInfo = (value) =>
  value instanceof AlarmInvocationInfo;
export const AlarmInvocationInfo$AlarmInvocationInfo$retry_count = (value) =>
  value.retry_count;
export const AlarmInvocationInfo$AlarmInvocationInfo$0 = (value) =>
  value.retry_count;
export const AlarmInvocationInfo$AlarmInvocationInfo$is_retry = (value) =>
  value.is_retry;
export const AlarmInvocationInfo$AlarmInvocationInfo$1 = (value) =>
  value.is_retry;

export function new_unique_id(jurisdiction) {
  let options = $json.nullable(
    jurisdiction,
    (j) => { return $json.object(toList([["jurisdiction", $json.string(j)]])); },
  );
  return do_new_unique_id(options);
}

export function get(namespace, id, location_hint) {
  let options = $json.nullable(
    location_hint,
    (hint) => {
      return $json.object(toList([["locationHint", $json.string(hint)]]));
    },
  );
  return do_get(namespace, id, options);
}

export function rpc(stub, method, args) {
  return do_rpc(stub, method, $array.from_list(args));
}

export function exec(storage, query, bindings) {
  return do_exec(storage, query, $array.from_list(bindings));
}

export function get_default() {
  return new GetOptions(false, false);
}

function get_options_to_arg(options) {
  let allow_concurrency;
  let no_cache;
  allow_concurrency = options.allow_concurrency;
  no_cache = options.no_cache;
  return $utils.sparse(
    toList([
      ["allowConcurrency", $json.bool(allow_concurrency)],
      ["noCache", $json.bool(no_cache)],
    ]),
  );
}

export function get_one(storage, key, options) {
  return do_get_one(storage, key, get_options_to_arg(options));
}

export function get_many(storage, keys, options) {
  let keys$1 = $array.from_list(keys);
  let args = get_options_to_arg(options);
  return do_get_many(storage, keys$1, args);
}

export function update_default() {
  return new UpdateOptions(false, false);
}

function update_options_to_arg(options) {
  let allow_unconfirmed;
  let no_cache;
  allow_unconfirmed = options.allow_unconfirmed;
  no_cache = options.no_cache;
  return $utils.sparse(
    toList([
      ["allowUnconfirmed", $json.bool(allow_unconfirmed)],
      ["noCache", $json.bool(no_cache)],
    ]),
  );
}

export function put_one(storage, key, value, options) {
  let options$1 = update_options_to_arg(options);
  return do_put_one(storage, key, value, options$1);
}

export function alarm_invocation_info_decoder() {
  return $decode.field(
    "retryCount",
    $decode.int,
    (retry_count) => {
      return $decode.field(
        "isRetry",
        $decode.bool,
        (is_retry) => {
          return $decode.success(new AlarmInvocationInfo(retry_count, is_retry));
        },
      );
    },
  );
}
