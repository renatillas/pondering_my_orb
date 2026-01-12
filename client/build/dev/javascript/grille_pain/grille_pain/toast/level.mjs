import { CustomType as $CustomType } from "../../gleam.mjs";

export class Standard extends $CustomType {}
export const Level$Standard = () => new Standard();
export const Level$isStandard = (value) => value instanceof Standard;

export class Info extends $CustomType {}
export const Level$Info = () => new Info();
export const Level$isInfo = (value) => value instanceof Info;

export class Warning extends $CustomType {}
export const Level$Warning = () => new Warning();
export const Level$isWarning = (value) => value instanceof Warning;

export class Error extends $CustomType {}
export const Level$Error = () => new Error();
export const Level$isError = (value) => value instanceof Error;

export class Success extends $CustomType {}
export const Level$Success = () => new Success();
export const Level$isSuccess = (value) => value instanceof Success;

/**
 * Mainly internal use, `to_string` allows you to get the exact representation
 * of the level.
 */
export function to_string(level) {
  if (level instanceof Standard) {
    return "Standard";
  } else if (level instanceof Info) {
    return "Info";
  } else if (level instanceof Warning) {
    return "Warning";
  } else if (level instanceof Error) {
    return "Error";
  } else {
    return "Success";
  }
}
