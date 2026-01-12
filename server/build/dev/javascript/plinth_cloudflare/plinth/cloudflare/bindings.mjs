import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import * as $decode from "../../../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $result from "../../../gleam_stdlib/gleam/result.mjs";
import * as $d1 from "../../plinth/cloudflare/d1.mjs";
import * as $do from "../../plinth/cloudflare/durable_object.mjs";
import * as $queue from "../../plinth/cloudflare/queue.mjs";
import * as $r2 from "../../plinth/cloudflare/r2.mjs";
import * as $workflow from "../../plinth/cloudflare/workflow.mjs";
import {
  get,
  cast_to_d1_database,
  cast_to_r2_bucket,
  cast_to_durable_object_namespace,
  cast_to_queue,
  cast_to_workflow,
} from "../../plinth_cloudflare_bindings_ffi.mjs";

export function secret(env, key) {
  let decoder = $decode.field(key, $decode.string, $decode.success);
  return $decode.run(env, decoder);
}

export function d1_database(env, binding) {
  return $result.try$(
    get(env, binding),
    (raw) => { return cast_to_d1_database(raw); },
  );
}

export function r2_bucket(env, binding) {
  return $result.try$(
    get(env, binding),
    (raw) => { return cast_to_r2_bucket(raw); },
  );
}

export function durable_object_namespace(env, binding) {
  return $result.try$(
    get(env, binding),
    (raw) => { return cast_to_durable_object_namespace(raw); },
  );
}

export function queue(env, binding) {
  return $result.try$(
    get(env, binding),
    (raw) => { return cast_to_queue(raw); },
  );
}

export function workflow(env, binding) {
  return $result.try$(
    get(env, binding),
    (raw) => { return cast_to_workflow(raw); },
  );
}
