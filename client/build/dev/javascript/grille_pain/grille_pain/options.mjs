import { CustomType as $CustomType } from "../gleam.mjs";

export class Options extends $CustomType {
  constructor(timeout) {
    super();
    this.timeout = timeout;
  }
}
export const Options$Options = (timeout) => new Options(timeout);
export const Options$isOptions = (value) => value instanceof Options;
export const Options$Options$timeout = (value) => value.timeout;
export const Options$Options$0 = (value) => value.timeout;

/**
 * Default options, 5s seconds of timeout.
 */
export function default$() {
  return new Options(5000);
}

/**
 * Define default timeout for toasts. Must be set in milliseconds.
 */
export function timeout(_, timeout) {
  return new Options(timeout);
}
