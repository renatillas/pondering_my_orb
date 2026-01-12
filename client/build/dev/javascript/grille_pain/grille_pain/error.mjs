import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $lustre from "../../lustre/lustre.mjs";
import { CustomType as $CustomType } from "../gleam.mjs";

export class LustreError extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const GrillePainError$LustreError = ($0) => new LustreError($0);
export const GrillePainError$isLustreError = (value) =>
  value instanceof LustreError;
export const GrillePainError$LustreError$0 = (value) => value[0];

export class ContextError extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const GrillePainError$ContextError = ($0) => new ContextError($0);
export const GrillePainError$isContextError = (value) =>
  value instanceof ContextError;
export const GrillePainError$ContextError$0 = (value) => value[0];

export function lustre(res) {
  return $result.map_error(res, (var0) => { return new LustreError(var0); });
}

export function context(res, context) {
  return $result.replace_error(res, new ContextError(context));
}
