import * as $promise from "../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import { None } from "../../../gleam_stdlib/gleam/option.mjs";
import { CustomType as $CustomType } from "../../gleam.mjs";
import { get as do_get, read_bytes, put as do_put } from "../../plinth_cloudflare_r2_ffi.mjs";

export { read_bytes };

export class GetOptions extends $CustomType {}
export const GetOptions$GetOptions = () => new GetOptions();
export const GetOptions$isGetOptions = (value) => value instanceof GetOptions;

export class PutOptions extends $CustomType {}
export const PutOptions$PutOptions = () => new PutOptions();
export const PutOptions$isPutOptions = (value) => value instanceof PutOptions;

export class ListOptions extends $CustomType {
  constructor(limit, prefix, cursor, delimiter, include) {
    super();
    this.limit = limit;
    this.prefix = prefix;
    this.cursor = cursor;
    this.delimiter = delimiter;
    this.include = include;
  }
}
export const ListOptions$ListOptions = (limit, prefix, cursor, delimiter, include) =>
  new ListOptions(limit, prefix, cursor, delimiter, include);
export const ListOptions$isListOptions = (value) =>
  value instanceof ListOptions;
export const ListOptions$ListOptions$limit = (value) => value.limit;
export const ListOptions$ListOptions$0 = (value) => value.limit;
export const ListOptions$ListOptions$prefix = (value) => value.prefix;
export const ListOptions$ListOptions$1 = (value) => value.prefix;
export const ListOptions$ListOptions$cursor = (value) => value.cursor;
export const ListOptions$ListOptions$2 = (value) => value.cursor;
export const ListOptions$ListOptions$delimiter = (value) => value.delimiter;
export const ListOptions$ListOptions$3 = (value) => value.delimiter;
export const ListOptions$ListOptions$include = (value) => value.include;
export const ListOptions$ListOptions$4 = (value) => value.include;

export function get_options() {
  return new GetOptions();
}

export function get(bucket, key, _) {
  return do_get(bucket, key);
}

export function put_options() {
  return new PutOptions();
}

export function put(bucket, key, value, _) {
  return do_put(bucket, key, value);
}

export function list_options() {
  return new ListOptions(
    new None(),
    new None(),
    new None(),
    new None(),
    new None(),
  );
}
