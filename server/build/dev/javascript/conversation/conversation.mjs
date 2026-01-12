import * as $request from "../gleam_http/gleam/http/request.mjs";
import * as $response from "../gleam_http/gleam/http/response.mjs";
import * as $promise from "../gleam_javascript/gleam/javascript/promise.mjs";
import * as $dynamic from "../gleam_stdlib/gleam/dynamic.mjs";
import {
  toGleamRequest as to_gleam_request,
  toJsRequest as to_js_request,
  toJsResponse as to_js_response,
  readText as read_text,
  readBits as read_bits,
  readJson as read_json,
  readForm as read_form,
} from "./ffi.mjs";
import { CustomType as $CustomType } from "./gleam.mjs";

export {
  read_bits,
  read_form,
  read_json,
  read_text,
  to_gleam_request,
  to_js_request,
  to_js_response,
};

/**
 * A text body.
 */
export class Text extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const ResponseBody$Text = ($0) => new Text($0);
export const ResponseBody$isText = (value) => value instanceof Text;
export const ResponseBody$Text$0 = (value) => value[0];

/**
 * A BitArray body.
 */
export class Bits extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const ResponseBody$Bits = ($0) => new Bits($0);
export const ResponseBody$isBits = (value) => value instanceof Bits;
export const ResponseBody$Bits$0 = (value) => value[0];

/**
 * A [`JsReadableStream`](#JsReadableStream) body. This is useful for sending
 * files without reading them into memory. (For example: using the
 * `Deno.openSync(path).readable` API.)
 */
export class Stream extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const ResponseBody$Stream = ($0) => new Stream($0);
export const ResponseBody$isStream = (value) => value instanceof Stream;
export const ResponseBody$Stream$0 = (value) => value[0];

export class FormData extends $CustomType {
  constructor(values, files) {
    super();
    this.values = values;
    this.files = files;
  }
}
export const FormData$FormData = (values, files) => new FormData(values, files);
export const FormData$isFormData = (value) => value instanceof FormData;
export const FormData$FormData$values = (value) => value.values;
export const FormData$FormData$0 = (value) => value.values;
export const FormData$FormData$files = (value) => value.files;
export const FormData$FormData$1 = (value) => value.files;

export class UploadedFile extends $CustomType {
  constructor(file_name) {
    super();
    this.file_name = file_name;
  }
}
export const UploadedFile$UploadedFile = (file_name) =>
  new UploadedFile(file_name);
export const UploadedFile$isUploadedFile = (value) =>
  value instanceof UploadedFile;
export const UploadedFile$UploadedFile$file_name = (value) => value.file_name;
export const UploadedFile$UploadedFile$0 = (value) => value.file_name;

export class AlreadyRead extends $CustomType {}
export const ReadError$AlreadyRead = () => new AlreadyRead();
export const ReadError$isAlreadyRead = (value) => value instanceof AlreadyRead;

/**
 * Failed to parse JSON or form body.
 */
export class ParseError extends $CustomType {
  constructor(message) {
    super();
    this.message = message;
  }
}
export const ReadError$ParseError = (message) => new ParseError(message);
export const ReadError$isParseError = (value) => value instanceof ParseError;
export const ReadError$ParseError$message = (value) => value.message;
export const ReadError$ParseError$0 = (value) => value.message;

/**
 * Failed to read request body.
 */
export class ReadError extends $CustomType {
  constructor(message) {
    super();
    this.message = message;
  }
}
export const ReadError$ReadError = (message) => new ReadError(message);
export const ReadError$isReadError = (value) => value instanceof ReadError;
export const ReadError$ReadError$message = (value) => value.message;
export const ReadError$ReadError$0 = (value) => value.message;
