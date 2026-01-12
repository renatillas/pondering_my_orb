import * as $array from "../../../gleam_javascript/gleam/javascript/array.mjs";
import * as $promise from "../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import { CustomType as $CustomType } from "../../gleam.mjs";
import { prepare, bind as do_bind, run, raw, first, batch as do_batch, exec } from "../../plinth_cloudflare_d1_ffi.mjs";

export { exec, first, prepare, raw, run };

export class RunResult extends $CustomType {
  constructor(success, meta, results) {
    super();
    this.success = success;
    this.meta = meta;
    this.results = results;
  }
}
export const RunResult$RunResult = (success, meta, results) =>
  new RunResult(success, meta, results);
export const RunResult$isRunResult = (value) => value instanceof RunResult;
export const RunResult$RunResult$success = (value) => value.success;
export const RunResult$RunResult$0 = (value) => value.success;
export const RunResult$RunResult$meta = (value) => value.meta;
export const RunResult$RunResult$1 = (value) => value.meta;
export const RunResult$RunResult$results = (value) => value.results;
export const RunResult$RunResult$2 = (value) => value.results;

export class ExecResult extends $CustomType {
  constructor(count, duration) {
    super();
    this.count = count;
    this.duration = duration;
  }
}
export const ExecResult$ExecResult = (count, duration) =>
  new ExecResult(count, duration);
export const ExecResult$isExecResult = (value) => value instanceof ExecResult;
export const ExecResult$ExecResult$count = (value) => value.count;
export const ExecResult$ExecResult$0 = (value) => value.count;
export const ExecResult$ExecResult$duration = (value) => value.duration;
export const ExecResult$ExecResult$1 = (value) => value.duration;

export function bind(statement, values) {
  return do_bind(statement, $array.from_list(values));
}

export function batch(db, statements) {
  return do_batch(db, $array.from_list(statements));
}
