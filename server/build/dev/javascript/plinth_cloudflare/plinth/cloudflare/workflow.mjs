import * as $array from "../../../gleam_javascript/gleam/javascript/array.mjs";
import * as $promise from "../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $json from "../../../gleam_json/gleam/json.mjs";
import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import * as $decode from "../../../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $int from "../../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import { None } from "../../../gleam_stdlib/gleam/option.mjs";
import { toList, CustomType as $CustomType } from "../../gleam.mjs";
import * as $utils from "../../plinth/cloudflare/utils.mjs";
import {
  do_ as do_do,
  sleep as do_sleep,
  sleep_until,
  wait_for_event as do_wait_for_event,
  create as do_create,
  create_batch as do_create_batch,
  get,
  id,
  status,
  pause,
  resume,
  restart,
  terminate,
  send_event as do_send_event,
} from "../../plinth_cloudflare_workflow_ffi.mjs";

export { get, id, pause, restart, resume, sleep_until, status, terminate };

export class InitialEvent extends $CustomType {
  constructor(payload, timestamp, instance_id) {
    super();
    this.payload = payload;
    this.timestamp = timestamp;
    this.instance_id = instance_id;
  }
}
export const InitialEvent$InitialEvent = (payload, timestamp, instance_id) =>
  new InitialEvent(payload, timestamp, instance_id);
export const InitialEvent$isInitialEvent = (value) =>
  value instanceof InitialEvent;
export const InitialEvent$InitialEvent$payload = (value) => value.payload;
export const InitialEvent$InitialEvent$0 = (value) => value.payload;
export const InitialEvent$InitialEvent$timestamp = (value) => value.timestamp;
export const InitialEvent$InitialEvent$1 = (value) => value.timestamp;
export const InitialEvent$InitialEvent$instance_id = (value) =>
  value.instance_id;
export const InitialEvent$InitialEvent$2 = (value) => value.instance_id;

export class SentEvent extends $CustomType {
  constructor(type_, payload, timestamp) {
    super();
    this.type_ = type_;
    this.payload = payload;
    this.timestamp = timestamp;
  }
}
export const SentEvent$SentEvent = (type_, payload, timestamp) =>
  new SentEvent(type_, payload, timestamp);
export const SentEvent$isSentEvent = (value) => value instanceof SentEvent;
export const SentEvent$SentEvent$type_ = (value) => value.type_;
export const SentEvent$SentEvent$0 = (value) => value.type_;
export const SentEvent$SentEvent$payload = (value) => value.payload;
export const SentEvent$SentEvent$1 = (value) => value.payload;
export const SentEvent$SentEvent$timestamp = (value) => value.timestamp;
export const SentEvent$SentEvent$2 = (value) => value.timestamp;

export class StepConfig extends $CustomType {
  constructor(retries, timeout) {
    super();
    this.retries = retries;
    this.timeout = timeout;
  }
}
export const StepConfig$StepConfig = (retries, timeout) =>
  new StepConfig(retries, timeout);
export const StepConfig$isStepConfig = (value) => value instanceof StepConfig;
export const StepConfig$StepConfig$retries = (value) => value.retries;
export const StepConfig$StepConfig$0 = (value) => value.retries;
export const StepConfig$StepConfig$timeout = (value) => value.timeout;
export const StepConfig$StepConfig$1 = (value) => value.timeout;

export class Retries extends $CustomType {
  constructor(limit, delay, backoff) {
    super();
    this.limit = limit;
    this.delay = delay;
    this.backoff = backoff;
  }
}
export const Retries$Retries = (limit, delay, backoff) =>
  new Retries(limit, delay, backoff);
export const Retries$isRetries = (value) => value instanceof Retries;
export const Retries$Retries$limit = (value) => value.limit;
export const Retries$Retries$0 = (value) => value.limit;
export const Retries$Retries$delay = (value) => value.delay;
export const Retries$Retries$1 = (value) => value.delay;
export const Retries$Retries$backoff = (value) => value.backoff;
export const Retries$Retries$2 = (value) => value.backoff;

export class Constant extends $CustomType {}
export const Backoff$Constant = () => new Constant();
export const Backoff$isConstant = (value) => value instanceof Constant;

export class Linear extends $CustomType {}
export const Backoff$Linear = () => new Linear();
export const Backoff$isLinear = (value) => value instanceof Linear;

export class Exponential extends $CustomType {}
export const Backoff$Exponential = () => new Exponential();
export const Backoff$isExponential = (value) => value instanceof Exponential;

export class CreateOptions extends $CustomType {
  constructor(id, params) {
    super();
    this.id = id;
    this.params = params;
  }
}
export const CreateOptions$CreateOptions = (id, params) =>
  new CreateOptions(id, params);
export const CreateOptions$isCreateOptions = (value) =>
  value instanceof CreateOptions;
export const CreateOptions$CreateOptions$id = (value) => value.id;
export const CreateOptions$CreateOptions$0 = (value) => value.id;
export const CreateOptions$CreateOptions$params = (value) => value.params;
export const CreateOptions$CreateOptions$1 = (value) => value.params;

export class InstanceStatus extends $CustomType {
  constructor(status, error, output) {
    super();
    this.status = status;
    this.error = error;
    this.output = output;
  }
}
export const InstanceStatus$InstanceStatus = (status, error, output) =>
  new InstanceStatus(status, error, output);
export const InstanceStatus$isInstanceStatus = (value) =>
  value instanceof InstanceStatus;
export const InstanceStatus$InstanceStatus$status = (value) => value.status;
export const InstanceStatus$InstanceStatus$0 = (value) => value.status;
export const InstanceStatus$InstanceStatus$error = (value) => value.error;
export const InstanceStatus$InstanceStatus$1 = (value) => value.error;
export const InstanceStatus$InstanceStatus$output = (value) => value.output;
export const InstanceStatus$InstanceStatus$2 = (value) => value.output;

export class Milliseconds extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Milliseconds = ($0) => new Milliseconds($0);
export const Duration$isMilliseconds = (value) => value instanceof Milliseconds;
export const Duration$Milliseconds$0 = (value) => value[0];

export class Seconds extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Seconds = ($0) => new Seconds($0);
export const Duration$isSeconds = (value) => value instanceof Seconds;
export const Duration$Seconds$0 = (value) => value[0];

export class Minutes extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Minutes = ($0) => new Minutes($0);
export const Duration$isMinutes = (value) => value instanceof Minutes;
export const Duration$Minutes$0 = (value) => value[0];

export class Hours extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Hours = ($0) => new Hours($0);
export const Duration$isHours = (value) => value instanceof Hours;
export const Duration$Hours$0 = (value) => value[0];

export class Days extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Days = ($0) => new Days($0);
export const Duration$isDays = (value) => value instanceof Days;
export const Duration$Days$0 = (value) => value[0];

export class Weeks extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Weeks = ($0) => new Weeks($0);
export const Duration$isWeeks = (value) => value instanceof Weeks;
export const Duration$Weeks$0 = (value) => value[0];

export class Months extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Months = ($0) => new Months($0);
export const Duration$isMonths = (value) => value instanceof Months;
export const Duration$Months$0 = (value) => value[0];

export class Years extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Duration$Years = ($0) => new Years($0);
export const Duration$isYears = (value) => value instanceof Years;
export const Duration$Years$0 = (value) => value[0];

export function initial_event_decoder(payload_decoder) {
  return $decode.field(
    "payload",
    payload_decoder,
    (payload) => {
      return $decode.field(
        "instance_id",
        $decode.string,
        (instance_id) => {
          return $decode.success(
            new InitialEvent(payload, "timestamp", instance_id),
          );
        },
      );
    },
  );
}

export function sent_event_decoder(payload_decoder) {
  return $decode.field(
    "type",
    $decode.string,
    (type_) => {
      return $decode.field(
        "payload",
        payload_decoder,
        (payload) => {
          return $decode.success(new SentEvent(type_, payload, "timestamp"));
        },
      );
    },
  );
}

export function default$() {
  return new StepConfig(new None(), new None());
}

function backoff_to_arg(backoff) {
  let _block;
  if (backoff instanceof Constant) {
    _block = "constant";
  } else if (backoff instanceof Linear) {
    _block = "linear";
  } else {
    _block = "exponential";
  }
  let _pipe = _block;
  return $json.string(_pipe);
}

function create_options_to_arg(options) {
  let id$1;
  let params;
  id$1 = options.id;
  params = options.params;
  return $utils.sparse(
    toList([["id", $json.nullable(id$1, $json.string)], ["params", params]]),
  );
}

export function create(workflow, options) {
  return do_create(workflow, create_options_to_arg(options));
}

export function create_batch(workflow, options) {
  let options$1 = $list.map(options, create_options_to_arg);
  return do_create_batch(workflow, $array.from_list(options$1));
}

export function send_event(instance, type_, payload) {
  return do_send_event(
    instance,
    $utils.sparse(toList([["type", $json.string(type_)], ["payload", payload]])),
  );
}

function human(quantity, unit) {
  return (($int.to_string(quantity) + " ") + unit) + (() => {
    if (quantity === 1) {
      return "";
    } else {
      return "s";
    }
  })();
}

function duration_to_arg(duration) {
  if (duration instanceof Milliseconds) {
    let x = duration[0];
    return $json.int(x);
  } else if (duration instanceof Seconds) {
    let x = duration[0];
    return $json.string(human(x, "second"));
  } else if (duration instanceof Minutes) {
    let x = duration[0];
    return $json.string(human(x, "minute"));
  } else if (duration instanceof Hours) {
    let x = duration[0];
    return $json.string(human(x, "hour"));
  } else if (duration instanceof Days) {
    let x = duration[0];
    return $json.string(human(x, "day"));
  } else if (duration instanceof Weeks) {
    let x = duration[0];
    return $json.string(human(x, "week"));
  } else if (duration instanceof Months) {
    let x = duration[0];
    return $json.string(human(x, "month"));
  } else {
    let x = duration[0];
    return $json.string(human(x, "year"));
  }
}

function retries_to_arg(retries) {
  let limit;
  let delay;
  let backoff;
  limit = retries.limit;
  delay = retries.delay;
  backoff = retries.backoff;
  return $utils.sparse(
    toList([
      ["limit", $json.int(limit)],
      ["delay", duration_to_arg(delay)],
      ["backoff", backoff_to_arg(backoff)],
    ]),
  );
}

function config_to_arg(config) {
  let retries;
  let timeout;
  retries = config.retries;
  timeout = config.timeout;
  return $utils.sparse(
    toList([
      ["retries", $json.nullable(retries, retries_to_arg)],
      ["timeout", $json.nullable(timeout, duration_to_arg)],
    ]),
  );
}

export function do$(step, name, config, callback) {
  return do_do(step, name, config_to_arg(config), callback);
}

export function sleep(step, name, duration) {
  return do_sleep(step, name, duration_to_arg(duration));
}

/**
 * returns an error if it timed out
 */
export function wait_for_event(step, name, type_, timeout) {
  let options = $utils.sparse(
    toList([
      ["type", $json.string(type_)],
      ["timeout", $json.nullable(timeout, duration_to_arg)],
    ]),
  );
  return do_wait_for_event(step, name, options);
}
