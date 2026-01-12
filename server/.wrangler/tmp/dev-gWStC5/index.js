var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// .wrangler/tmp/bundle-JrVlNH/checked-fetch.js
var urls = /* @__PURE__ */ new Set();
function checkURL(request, init) {
  const url = request instanceof URL ? request : new URL(
    (typeof request === "string" ? new Request(request, init) : request).url
  );
  if (url.port && url.port !== "443" && url.protocol === "https:") {
    if (!urls.has(url.toString())) {
      urls.add(url.toString());
      console.warn(
        `WARNING: known issue with \`fetch()\` requests to custom HTTPS ports in published Workers:
 - ${url.toString()} - the custom port will be ignored when the Worker is published using the \`wrangler deploy\` command.
`
      );
    }
  }
}
__name(checkURL, "checkURL");
globalThis.fetch = new Proxy(globalThis.fetch, {
  apply(target, thisArg, argArray) {
    const [request, init] = argArray;
    checkURL(request, init);
    return Reflect.apply(target, thisArg, argArray);
  }
});

// build/dev/javascript/prelude.mjs
var CustomType = class {
  static {
    __name(this, "CustomType");
  }
  withFields(fields) {
    let properties = Object.keys(this).map(
      (label) => label in fields ? fields[label] : this[label]
    );
    return new this.constructor(...properties);
  }
};
var List = class {
  static {
    __name(this, "List");
  }
  static fromArray(array2, tail) {
    let t = tail || new Empty();
    for (let i = array2.length - 1; i >= 0; --i) {
      t = new NonEmpty(array2[i], t);
    }
    return t;
  }
  [Symbol.iterator]() {
    return new ListIterator(this);
  }
  toArray() {
    return [...this];
  }
  atLeastLength(desired) {
    let current = this;
    while (desired-- > 0 && current) current = current.tail;
    return current !== void 0;
  }
  hasLength(desired) {
    let current = this;
    while (desired-- > 0 && current) current = current.tail;
    return desired === -1 && current instanceof Empty;
  }
  countLength() {
    let current = this;
    let length4 = 0;
    while (current) {
      current = current.tail;
      length4++;
    }
    return length4 - 1;
  }
};
function prepend(element, tail) {
  return new NonEmpty(element, tail);
}
__name(prepend, "prepend");
function toList(elements, tail) {
  return List.fromArray(elements, tail);
}
__name(toList, "toList");
var ListIterator = class {
  static {
    __name(this, "ListIterator");
  }
  #current;
  constructor(current) {
    this.#current = current;
  }
  next() {
    if (this.#current instanceof Empty) {
      return { done: true };
    } else {
      let { head, tail } = this.#current;
      this.#current = tail;
      return { value: head, done: false };
    }
  }
};
var Empty = class extends List {
  static {
    __name(this, "Empty");
  }
};
var NonEmpty = class extends List {
  static {
    __name(this, "NonEmpty");
  }
  constructor(head, tail) {
    super();
    this.head = head;
    this.tail = tail;
  }
};
var BitArray = class {
  static {
    __name(this, "BitArray");
  }
  /**
   * The size in bits of this bit array's data.
   *
   * @type {number}
   */
  bitSize;
  /**
   * The size in bytes of this bit array's data. If this bit array doesn't store
   * a whole number of bytes then this value is rounded up.
   *
   * @type {number}
   */
  byteSize;
  /**
   * The number of unused high bits in the first byte of this bit array's
   * buffer prior to the start of its data. The value of any unused high bits is
   * undefined.
   *
   * The bit offset will be in the range 0-7.
   *
   * @type {number}
   */
  bitOffset;
  /**
   * The raw bytes that hold this bit array's data.
   *
   * If `bitOffset` is not zero then there are unused high bits in the first
   * byte of this buffer.
   *
   * If `bitOffset + bitSize` is not a multiple of 8 then there are unused low
   * bits in the last byte of this buffer.
   *
   * @type {Uint8Array}
   */
  rawBuffer;
  /**
   * Constructs a new bit array from a `Uint8Array`, an optional size in
   * bits, and an optional bit offset.
   *
   * If no bit size is specified it is taken as `buffer.length * 8`, i.e. all
   * bytes in the buffer make up the new bit array's data.
   *
   * If no bit offset is specified it defaults to zero, i.e. there are no unused
   * high bits in the first byte of the buffer.
   *
   * @param {Uint8Array} buffer
   * @param {number} [bitSize]
   * @param {number} [bitOffset]
   */
  constructor(buffer, bitSize, bitOffset) {
    if (!(buffer instanceof Uint8Array)) {
      throw globalThis.Error(
        "BitArray can only be constructed from a Uint8Array"
      );
    }
    this.bitSize = bitSize ?? buffer.length * 8;
    this.byteSize = Math.trunc((this.bitSize + 7) / 8);
    this.bitOffset = bitOffset ?? 0;
    if (this.bitSize < 0) {
      throw globalThis.Error(`BitArray bit size is invalid: ${this.bitSize}`);
    }
    if (this.bitOffset < 0 || this.bitOffset > 7) {
      throw globalThis.Error(
        `BitArray bit offset is invalid: ${this.bitOffset}`
      );
    }
    if (buffer.length !== Math.trunc((this.bitOffset + this.bitSize + 7) / 8)) {
      throw globalThis.Error("BitArray buffer length is invalid");
    }
    this.rawBuffer = buffer;
  }
  /**
   * Returns a specific byte in this bit array. If the byte index is out of
   * range then `undefined` is returned.
   *
   * When returning the final byte of a bit array with a bit size that's not a
   * multiple of 8, the content of the unused low bits are undefined.
   *
   * @param {number} index
   * @returns {number | undefined}
   */
  byteAt(index3) {
    if (index3 < 0 || index3 >= this.byteSize) {
      return void 0;
    }
    return bitArrayByteAt(this.rawBuffer, this.bitOffset, index3);
  }
  equals(other) {
    if (this.bitSize !== other.bitSize) {
      return false;
    }
    const wholeByteCount = Math.trunc(this.bitSize / 8);
    if (this.bitOffset === 0 && other.bitOffset === 0) {
      for (let i = 0; i < wholeByteCount; i++) {
        if (this.rawBuffer[i] !== other.rawBuffer[i]) {
          return false;
        }
      }
      const trailingBitsCount = this.bitSize % 8;
      if (trailingBitsCount) {
        const unusedLowBitCount = 8 - trailingBitsCount;
        if (this.rawBuffer[wholeByteCount] >> unusedLowBitCount !== other.rawBuffer[wholeByteCount] >> unusedLowBitCount) {
          return false;
        }
      }
    } else {
      for (let i = 0; i < wholeByteCount; i++) {
        const a = bitArrayByteAt(this.rawBuffer, this.bitOffset, i);
        const b = bitArrayByteAt(other.rawBuffer, other.bitOffset, i);
        if (a !== b) {
          return false;
        }
      }
      const trailingBitsCount = this.bitSize % 8;
      if (trailingBitsCount) {
        const a = bitArrayByteAt(
          this.rawBuffer,
          this.bitOffset,
          wholeByteCount
        );
        const b = bitArrayByteAt(
          other.rawBuffer,
          other.bitOffset,
          wholeByteCount
        );
        const unusedLowBitCount = 8 - trailingBitsCount;
        if (a >> unusedLowBitCount !== b >> unusedLowBitCount) {
          return false;
        }
      }
    }
    return true;
  }
  /**
   * Returns this bit array's internal buffer.
   *
   * @deprecated Use `BitArray.byteAt()` or `BitArray.rawBuffer` instead.
   *
   * @returns {Uint8Array}
   */
  get buffer() {
    bitArrayPrintDeprecationWarning(
      "buffer",
      "Use BitArray.byteAt() or BitArray.rawBuffer instead"
    );
    if (this.bitOffset !== 0 || this.bitSize % 8 !== 0) {
      throw new globalThis.Error(
        "BitArray.buffer does not support unaligned bit arrays"
      );
    }
    return this.rawBuffer;
  }
  /**
   * Returns the length in bytes of this bit array's internal buffer.
   *
   * @deprecated Use `BitArray.bitSize` or `BitArray.byteSize` instead.
   *
   * @returns {number}
   */
  get length() {
    bitArrayPrintDeprecationWarning(
      "length",
      "Use BitArray.bitSize or BitArray.byteSize instead"
    );
    if (this.bitOffset !== 0 || this.bitSize % 8 !== 0) {
      throw new globalThis.Error(
        "BitArray.length does not support unaligned bit arrays"
      );
    }
    return this.rawBuffer.length;
  }
};
function bitArrayByteAt(buffer, bitOffset, index3) {
  if (bitOffset === 0) {
    return buffer[index3] ?? 0;
  } else {
    const a = buffer[index3] << bitOffset & 255;
    const b = buffer[index3 + 1] >> 8 - bitOffset;
    return a | b;
  }
}
__name(bitArrayByteAt, "bitArrayByteAt");
var isBitArrayDeprecationMessagePrinted = {};
function bitArrayPrintDeprecationWarning(name2, message) {
  if (isBitArrayDeprecationMessagePrinted[name2]) {
    return;
  }
  console.warn(
    `Deprecated BitArray.${name2} property used in JavaScript FFI code. ${message}.`
  );
  isBitArrayDeprecationMessagePrinted[name2] = true;
}
__name(bitArrayPrintDeprecationWarning, "bitArrayPrintDeprecationWarning");
var Result = class _Result extends CustomType {
  static {
    __name(this, "Result");
  }
  static isResult(data2) {
    return data2 instanceof _Result;
  }
};
var Ok = class extends Result {
  static {
    __name(this, "Ok");
  }
  constructor(value) {
    super();
    this[0] = value;
  }
  isOk() {
    return true;
  }
};
var Error2 = class extends Result {
  static {
    __name(this, "Error");
  }
  constructor(detail) {
    super();
    this[0] = detail;
  }
  isOk() {
    return false;
  }
};
function isEqual(x, y) {
  let values2 = [x, y];
  while (values2.length) {
    let a = values2.pop();
    let b = values2.pop();
    if (a === b) continue;
    if (!isObject(a) || !isObject(b)) return false;
    let unequal = !structurallyCompatibleObjects(a, b) || unequalDates(a, b) || unequalBuffers(a, b) || unequalArrays(a, b) || unequalMaps(a, b) || unequalSets(a, b) || unequalRegExps(a, b);
    if (unequal) return false;
    const proto = Object.getPrototypeOf(a);
    if (proto !== null && typeof proto.equals === "function") {
      try {
        if (a.equals(b)) continue;
        else return false;
      } catch {
      }
    }
    let [keys, get7] = getters(a);
    const ka = keys(a);
    const kb = keys(b);
    if (ka.length !== kb.length) return false;
    for (let k of ka) {
      values2.push(get7(a, k), get7(b, k));
    }
  }
  return true;
}
__name(isEqual, "isEqual");
function getters(object3) {
  if (object3 instanceof Map) {
    return [(x) => x.keys(), (x, y) => x.get(y)];
  } else {
    let extra = object3 instanceof globalThis.Error ? ["message"] : [];
    return [(x) => [...extra, ...Object.keys(x)], (x, y) => x[y]];
  }
}
__name(getters, "getters");
function unequalDates(a, b) {
  return a instanceof Date && (a > b || a < b);
}
__name(unequalDates, "unequalDates");
function unequalBuffers(a, b) {
  return !(a instanceof BitArray) && a.buffer instanceof ArrayBuffer && a.BYTES_PER_ELEMENT && !(a.byteLength === b.byteLength && a.every((n, i) => n === b[i]));
}
__name(unequalBuffers, "unequalBuffers");
function unequalArrays(a, b) {
  return Array.isArray(a) && a.length !== b.length;
}
__name(unequalArrays, "unequalArrays");
function unequalMaps(a, b) {
  return a instanceof Map && a.size !== b.size;
}
__name(unequalMaps, "unequalMaps");
function unequalSets(a, b) {
  return a instanceof Set && (a.size != b.size || [...a].some((e) => !b.has(e)));
}
__name(unequalSets, "unequalSets");
function unequalRegExps(a, b) {
  return a instanceof RegExp && (a.source !== b.source || a.flags !== b.flags);
}
__name(unequalRegExps, "unequalRegExps");
function isObject(a) {
  return typeof a === "object" && a !== null;
}
__name(isObject, "isObject");
function structurallyCompatibleObjects(a, b) {
  if (typeof a !== "object" && typeof b !== "object" && (!a || !b))
    return false;
  let nonstructural = [Promise, WeakSet, WeakMap, Function];
  if (nonstructural.some((c) => a instanceof c)) return false;
  return a.constructor === b.constructor;
}
__name(structurallyCompatibleObjects, "structurallyCompatibleObjects");

// build/dev/javascript/gleam_stdlib/dict.mjs
var bits = 5;
var mask = (1 << bits) - 1;
var noElementMarker = Symbol();
var generationKey = Symbol();

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var Some = class extends CustomType {
  static {
    __name(this, "Some");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var None = class extends CustomType {
  static {
    __name(this, "None");
  }
};

// build/dev/javascript/gleam_stdlib/gleam/string.mjs
function split2(x, substring) {
  if (substring === "") {
    return graphemes(x);
  } else {
    let _pipe = x;
    let _pipe$1 = identity(_pipe);
    let _pipe$2 = split(_pipe$1, substring);
    return map2(_pipe$2, identity);
  }
}
__name(split2, "split");

// build/dev/javascript/gleam_stdlib/gleam_stdlib.mjs
function identity(x) {
  return x;
}
__name(identity, "identity");
function graphemes(string4) {
  const iterator = graphemes_iterator(string4);
  if (iterator) {
    return List.fromArray(Array.from(iterator).map((item) => item.segment));
  } else {
    return List.fromArray(string4.match(/./gsu));
  }
}
__name(graphemes, "graphemes");
var segmenter = void 0;
function graphemes_iterator(string4) {
  if (globalThis.Intl && Intl.Segmenter) {
    segmenter ||= new Intl.Segmenter();
    return segmenter.segment(string4)[Symbol.iterator]();
  }
}
__name(graphemes_iterator, "graphemes_iterator");
function lowercase(string4) {
  return string4.toLowerCase();
}
__name(lowercase, "lowercase");
function split(xs, pattern) {
  return List.fromArray(xs.split(pattern));
}
__name(split, "split");
var unicode_whitespaces = [
  " ",
  // Space
  "	",
  // Horizontal tab
  "\n",
  // Line feed
  "\v",
  // Vertical tab
  "\f",
  // Form feed
  "\r",
  // Carriage return
  "\x85",
  // Next line
  "\u2028",
  // Line separator
  "\u2029"
  // Paragraph separator
].join("");
var trim_start_regex = /* @__PURE__ */ new RegExp(
  `^[${unicode_whitespaces}]*`
);
var trim_end_regex = /* @__PURE__ */ new RegExp(`[${unicode_whitespaces}]*$`);

// build/dev/javascript/gleam_stdlib/gleam/list.mjs
function reverse_and_prepend(loop$prefix, loop$suffix) {
  while (true) {
    let prefix = loop$prefix;
    let suffix = loop$suffix;
    if (prefix instanceof Empty) {
      return suffix;
    } else {
      let first$1 = prefix.head;
      let rest$1 = prefix.tail;
      loop$prefix = rest$1;
      loop$suffix = prepend(first$1, suffix);
    }
  }
}
__name(reverse_and_prepend, "reverse_and_prepend");
function reverse(list2) {
  return reverse_and_prepend(list2, toList([]));
}
__name(reverse, "reverse");
function map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list2 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list2 instanceof Empty) {
      return reverse(acc);
    } else {
      let first$1 = list2.head;
      let rest$1 = list2.tail;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = prepend(fun(first$1), acc);
    }
  }
}
__name(map_loop, "map_loop");
function map2(list2, fun) {
  return map_loop(list2, fun, toList([]));
}
__name(map2, "map");
function key_set_loop(loop$list, loop$key, loop$value, loop$inspected) {
  while (true) {
    let list2 = loop$list;
    let key = loop$key;
    let value = loop$value;
    let inspected = loop$inspected;
    if (list2 instanceof Empty) {
      return reverse(prepend([key, value], inspected));
    } else {
      let k = list2.head[0];
      if (isEqual(k, key)) {
        let rest$1 = list2.tail;
        return reverse_and_prepend(inspected, prepend([k, value], rest$1));
      } else {
        let first$1 = list2.head;
        let rest$1 = list2.tail;
        loop$list = rest$1;
        loop$key = key;
        loop$value = value;
        loop$inspected = prepend(first$1, inspected);
      }
    }
  }
}
__name(key_set_loop, "key_set_loop");
function key_set(list2, key, value) {
  return key_set_loop(list2, key, value, toList([]));
}
__name(key_set, "key_set");

// build/dev/javascript/gleam_stdlib/gleam/result.mjs
function try$(result, fun) {
  if (result instanceof Ok) {
    let x = result[0];
    return fun(x);
  } else {
    return result;
  }
}
__name(try$, "try$");

// build/dev/javascript/gleam_stdlib/gleam/uri.mjs
function remove_dot_segments_loop(loop$input, loop$accumulator) {
  while (true) {
    let input = loop$input;
    let accumulator = loop$accumulator;
    if (input instanceof Empty) {
      return reverse(accumulator);
    } else {
      let segment = input.head;
      let rest = input.tail;
      let _block;
      if (segment === "") {
        _block = accumulator;
      } else if (segment === ".") {
        _block = accumulator;
      } else if (segment === "..") {
        if (accumulator instanceof Empty) {
          _block = accumulator;
        } else {
          let accumulator$12 = accumulator.tail;
          _block = accumulator$12;
        }
      } else {
        let segment$1 = segment;
        let accumulator$12 = accumulator;
        _block = prepend(segment$1, accumulator$12);
      }
      let accumulator$1 = _block;
      loop$input = rest;
      loop$accumulator = accumulator$1;
    }
  }
}
__name(remove_dot_segments_loop, "remove_dot_segments_loop");
function remove_dot_segments(input) {
  return remove_dot_segments_loop(input, toList([]));
}
__name(remove_dot_segments, "remove_dot_segments");
function path_segments(path) {
  return remove_dot_segments(split2(path, "/"));
}
__name(path_segments, "path_segments");

// build/dev/javascript/gleam_http/gleam/http.mjs
var Get = class extends CustomType {
  static {
    __name(this, "Get");
  }
};
var Post = class extends CustomType {
  static {
    __name(this, "Post");
  }
};
var Head = class extends CustomType {
  static {
    __name(this, "Head");
  }
};
var Put = class extends CustomType {
  static {
    __name(this, "Put");
  }
};
var Delete = class extends CustomType {
  static {
    __name(this, "Delete");
  }
};
var Trace = class extends CustomType {
  static {
    __name(this, "Trace");
  }
};
var Connect = class extends CustomType {
  static {
    __name(this, "Connect");
  }
};
var Options = class extends CustomType {
  static {
    __name(this, "Options");
  }
};
var Patch = class extends CustomType {
  static {
    __name(this, "Patch");
  }
};
var Other = class extends CustomType {
  static {
    __name(this, "Other");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Http = class extends CustomType {
  static {
    __name(this, "Http");
  }
};
var Https = class extends CustomType {
  static {
    __name(this, "Https");
  }
};
function is_valid_token_loop(loop$token) {
  while (true) {
    let token = loop$token;
    if (token === "") {
      return true;
    } else if (token.startsWith("!")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("#")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("$")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("%")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("&")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("'")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("*")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("+")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("-")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith(".")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("^")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("_")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("`")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("|")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("~")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("0")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("1")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("2")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("3")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("4")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("5")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("6")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("7")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("8")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("9")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("A")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("B")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("C")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("D")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("E")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("F")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("G")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("H")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("I")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("J")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("K")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("L")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("M")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("N")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("O")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("P")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("Q")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("R")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("S")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("T")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("U")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("V")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("W")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("X")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("Y")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("Z")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("a")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("b")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("c")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("d")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("e")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("f")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("g")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("h")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("i")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("j")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("k")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("l")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("m")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("n")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("o")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("p")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("q")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("r")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("s")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("t")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("u")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("v")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("w")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("x")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("y")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else if (token.startsWith("z")) {
      let rest = token.slice(1);
      loop$token = rest;
    } else {
      return false;
    }
  }
}
__name(is_valid_token_loop, "is_valid_token_loop");
function is_valid_token(token) {
  if (token === "") {
    return false;
  } else {
    return is_valid_token_loop(token);
  }
}
__name(is_valid_token, "is_valid_token");
function parse_method(method) {
  if (method === "CONNECT") {
    return new Ok(new Connect());
  } else if (method === "DELETE") {
    return new Ok(new Delete());
  } else if (method === "GET") {
    return new Ok(new Get());
  } else if (method === "HEAD") {
    return new Ok(new Head());
  } else if (method === "OPTIONS") {
    return new Ok(new Options());
  } else if (method === "PATCH") {
    return new Ok(new Patch());
  } else if (method === "POST") {
    return new Ok(new Post());
  } else if (method === "PUT") {
    return new Ok(new Put());
  } else if (method === "TRACE") {
    return new Ok(new Trace());
  } else {
    let method$1 = method;
    let $ = is_valid_token(method$1);
    if ($) {
      return new Ok(new Other(method$1));
    } else {
      return new Error2(void 0);
    }
  }
}
__name(parse_method, "parse_method");

// build/dev/javascript/gleam_http/gleam/http/request.mjs
var Request2 = class extends CustomType {
  static {
    __name(this, "Request");
  }
  constructor(method, headers, body2, scheme, host, port, path, query) {
    super();
    this.method = method;
    this.headers = headers;
    this.body = body2;
    this.scheme = scheme;
    this.host = host;
    this.port = port;
    this.path = path;
    this.query = query;
  }
};
function path_segments2(request) {
  let _pipe = request.path;
  return path_segments(_pipe);
}
__name(path_segments2, "path_segments");

// build/dev/javascript/gleam_http/gleam/http/response.mjs
var Response2 = class extends CustomType {
  static {
    __name(this, "Response");
  }
  constructor(status2, headers, body2) {
    super();
    this.status = status2;
    this.headers = headers;
    this.body = body2;
  }
};
function new$(status2) {
  return new Response2(status2, toList([]), "");
}
__name(new$, "new$");
function set_header2(response, key, value) {
  let headers = key_set(response.headers, lowercase(key), value);
  return new Response2(response.status, headers, response.body);
}
__name(set_header2, "set_header");
function set_body(response, body2) {
  return new Response2(response.status, response.headers, body2);
}
__name(set_body, "set_body");

// build/dev/javascript/gleam_javascript/gleam_javascript_ffi.mjs
var PromiseLayer = class _PromiseLayer {
  static {
    __name(this, "PromiseLayer");
  }
  constructor(promise) {
    this.promise = promise;
  }
  static wrap(value) {
    return value instanceof Promise ? new _PromiseLayer(value) : value;
  }
  static unwrap(value) {
    return value instanceof _PromiseLayer ? value.promise : value;
  }
};
function resolve(value) {
  return Promise.resolve(PromiseLayer.wrap(value));
}
__name(resolve, "resolve");

// build/dev/javascript/conversation/ffi.mjs
function toGleamRequest(req) {
  const url = new URL(req.url);
  const method = parse_method(req.method)[0];
  const headers = toList([...req.headers]);
  const body2 = req;
  const scheme = url.protocol === "https:" ? new Https() : new Http();
  const host = url.hostname;
  const port = maybe(+url.port);
  const path = url.pathname;
  const query = maybe(url.search.slice(1));
  return new Request2(
    method,
    headers,
    body2,
    scheme,
    host,
    port,
    path,
    query
  );
}
__name(toGleamRequest, "toGleamRequest");
function toJsResponse(res) {
  const body2 = res.body instanceof Bits ? new Blob([res.body[0].buffer]) : res.body[0];
  return new Response(body2, {
    status: res.status,
    headers: res.headers.toArray()
  });
}
__name(toJsResponse, "toJsResponse");
function maybe(x) {
  if (x) {
    return new Some(x);
  }
  return new None();
}
__name(maybe, "maybe");

// build/dev/javascript/conversation/conversation.mjs
var Text = class extends CustomType {
  static {
    __name(this, "Text");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Bits = class extends CustomType {
  static {
    __name(this, "Bits");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};

// build/dev/javascript/gleam_json/gleam_json_ffi.mjs
function object(entries) {
  return Object.fromEntries(entries);
}
__name(object, "object");
function identity2(x) {
  return x;
}
__name(identity2, "identity");
function do_null() {
  return null;
}
__name(do_null, "do_null");

// build/dev/javascript/gleam_json/gleam/json.mjs
function string2(input) {
  return identity2(input);
}
__name(string2, "string");
function null$() {
  return do_null();
}
__name(null$, "null$");
function nullable(input, inner_type) {
  if (input instanceof Some) {
    let value = input[0];
    return inner_type(value);
  } else {
    return null$();
  }
}
__name(nullable, "nullable");
function object2(entries) {
  return object(entries);
}
__name(object2, "object");

// build/dev/javascript/plinth_cloudflare/plinth_cloudflare_durable_object_ffi.mjs
function id_from_name(namespace, name2) {
  return namespace.idFromName(name2);
}
__name(id_from_name, "id_from_name");
function get2(namespace, id4, options) {
  return namespace.get(id4, options);
}
__name(get2, "get");

// build/dev/javascript/plinth_cloudflare/plinth/cloudflare/durable_object.mjs
function get3(namespace, id4, location_hint) {
  let options = nullable(
    location_hint,
    (hint) => {
      return object2(toList([["locationHint", string2(hint)]]));
    }
  );
  return get2(namespace, id4, options);
}
__name(get3, "get");

// build/dev/javascript/plinth_cloudflare/plinth_cloudflare_bindings_ffi.mjs
function get6(env, key) {
  if (Object.hasOwn(env, key)) {
    return new Ok(env[key]);
  } else {
    return new Error2();
  }
}
__name(get6, "get");
function cast_to_durable_object_namespace(raw2) {
  const isNamespace = raw2 && typeof raw2.idFromName === "function" && typeof raw2.newUniqueId === "function" && typeof raw2.idFromString === "function" && typeof raw2.get === "function" && typeof raw2.jurisdiction === "function";
  return isNamespace ? new Ok(raw2) : new Error2();
}
__name(cast_to_durable_object_namespace, "cast_to_durable_object_namespace");

// build/dev/javascript/plinth_cloudflare/plinth/cloudflare/bindings.mjs
function durable_object_namespace(env, binding) {
  return try$(
    get6(env, binding),
    (raw2) => {
      return cast_to_durable_object_namespace(raw2);
    }
  );
}
__name(durable_object_namespace, "durable_object_namespace");

// build/dev/javascript/server/server_ffi.mjs
function forwardToStub(stub, request) {
  return stub.fetch(request);
}
__name(forwardToStub, "forwardToStub");

// build/dev/javascript/server/server.mjs
function handle_websocket(js_request, env, room_id) {
  let $ = durable_object_namespace(env, "GAME_ROOM");
  if ($ instanceof Ok) {
    let namespace = $[0];
    let do_id = id_from_name(namespace, room_id);
    let stub = get3(namespace, do_id, new None());
    return forwardToStub(stub, js_request);
  } else {
    let _pipe = new$(500);
    let _pipe$1 = set_body(
      _pipe,
      new Text("GAME_ROOM binding not found")
    );
    let _pipe$2 = toJsResponse(_pipe$1);
    return resolve(_pipe$2);
  }
}
__name(handle_websocket, "handle_websocket");
function handle_health() {
  let _pipe = new$(200);
  let _pipe$1 = set_header2(_pipe, "content-type", "application/json");
  let _pipe$2 = set_body(_pipe$1, new Text('{"status":"ok"}'));
  let _pipe$3 = toJsResponse(_pipe$2);
  return resolve(_pipe$3);
}
__name(handle_health, "handle_health");
function handle_list_rooms() {
  let _pipe = new$(200);
  let _pipe$1 = set_header2(_pipe, "content-type", "application/json");
  let _pipe$2 = set_body(_pipe$1, new Text('{"rooms":[]}'));
  let _pipe$3 = toJsResponse(_pipe$2);
  return resolve(_pipe$3);
}
__name(handle_list_rooms, "handle_list_rooms");
function handle_create_room() {
  let _pipe = new$(201);
  let _pipe$1 = set_header2(_pipe, "content-type", "application/json");
  let _pipe$2 = set_body(
    _pipe$1,
    new Text('{"room_id":"new-room"}')
  );
  let _pipe$3 = toJsResponse(_pipe$2);
  return resolve(_pipe$3);
}
__name(handle_create_room, "handle_create_room");
function handle_not_found() {
  let _pipe = new$(404);
  let _pipe$1 = set_header2(_pipe, "content-type", "application/json");
  let _pipe$2 = set_body(
    _pipe$1,
    new Text('{"error":"Not found"}')
  );
  let _pipe$3 = toJsResponse(_pipe$2);
  return resolve(_pipe$3);
}
__name(handle_not_found, "handle_not_found");
function fetch(js_request, env, _) {
  let req = toGleamRequest(js_request);
  let $ = req.method;
  let $1 = path_segments2(req);
  if ($1 instanceof Empty) {
    return handle_not_found();
  } else {
    let $2 = $1.tail;
    if ($2 instanceof Empty) {
      return handle_not_found();
    } else {
      let $3 = $2.tail;
      if ($3 instanceof Empty) {
        if ($ instanceof Get) {
          let $4 = $1.head;
          if ($4 === "ws") {
            let room_id = $2.head;
            return handle_websocket(js_request, env, room_id);
          } else if ($4 === "api") {
            let $5 = $2.head;
            if ($5 === "health") {
              return handle_health();
            } else if ($5 === "rooms") {
              return handle_list_rooms();
            } else {
              return handle_not_found();
            }
          } else {
            return handle_not_found();
          }
        } else if ($ instanceof Post) {
          let $4 = $1.head;
          if ($4 === "api") {
            let $5 = $2.head;
            if ($5 === "rooms") {
              return handle_create_room();
            } else {
              return handle_not_found();
            }
          } else {
            return handle_not_found();
          }
        } else {
          return handle_not_found();
        }
      } else {
        return handle_not_found();
      }
    }
  }
}
__name(fetch, "fetch");

// src/game_state.mjs
var GameState2 = class {
  static {
    __name(this, "GameState");
  }
  constructor() {
    this.tick = 0;
    this.lastTickTime = Date.now();
    this.enemies = /* @__PURE__ */ new Map();
    this.nextEnemyId = 1;
    this.spawnTimer = 0;
    this.projectiles = /* @__PURE__ */ new Map();
    this.nextProjectileId = 1;
    this.config = {
      // Enemy spawning
      spawnInterval: 2e3,
      // ms
      spawnDistanceMin: 15,
      spawnDistanceMax: 30,
      arenaMin: -70,
      arenaMax: 70,
      // Enemy stats
      enemyHealth: 10,
      enemyDamage: 10,
      enemySpeed: 8,
      enemyAttackRange: 2,
      // Projectile defaults
      defaultProjectileSpeed: 50,
      defaultProjectileDamage: 3,
      defaultProjectileSize: 1,
      defaultProjectileLifetime: 2e3
      // ms
    };
  }
  // Reset game state (e.g., when all players leave)
  reset() {
    this.tick = 0;
    this.lastTickTime = Date.now();
    this.enemies.clear();
    this.nextEnemyId = 1;
    this.spawnTimer = 0;
    this.projectiles.clear();
    this.nextProjectileId = 1;
  }
  // Get delta time since last tick
  getDeltaTime() {
    const now2 = Date.now();
    const dt = (now2 - this.lastTickTime) / 1e3;
    this.lastTickTime = now2;
    this.tick++;
    return dt;
  }
  // Convert enemy to network-friendly format
  enemyToState(enemy) {
    return {
      id: enemy.id,
      position: { x: enemy.position.x, y: enemy.position.y, z: enemy.position.z },
      health: enemy.health,
      max_health: enemy.maxHealth
    };
  }
  // Convert projectile to network-friendly format
  projectileToState(proj) {
    return {
      id: proj.id,
      owner_id: proj.ownerId,
      position: { x: proj.position.x, y: proj.position.y, z: proj.position.z },
      direction: { x: proj.direction.x, y: proj.direction.y, z: proj.direction.z },
      damage: proj.damage,
      speed: proj.speed,
      size: proj.size
    };
  }
  // Get full game state for synchronization
  getFullState() {
    return {
      type: "full_game_state",
      tick: this.tick,
      enemies: Array.from(this.enemies.values()).map((e) => this.enemyToState(e)),
      projectiles: Array.from(this.projectiles.values()).map(
        (p) => this.projectileToState(p)
      )
    };
  }
};

// src/enemy_manager.mjs
function updateSpawning2(gameState, players, dt) {
  if (players.size === 0) {
    return null;
  }
  gameState.spawnTimer += dt * 1e3;
  if (gameState.spawnTimer >= gameState.config.spawnInterval) {
    gameState.spawnTimer = 0;
    const playerArray = Array.from(players.values());
    const targetPlayer = playerArray[Math.floor(Math.random() * playerArray.length)];
    if (targetPlayer && targetPlayer.state && targetPlayer.state.position) {
      return spawnEnemy(gameState, targetPlayer.state.position);
    }
  }
  return null;
}
__name(updateSpawning2, "updateSpawning");
function spawnEnemy(gameState, nearPosition) {
  const config = gameState.config;
  const angle = Math.random() * 2 * Math.PI;
  const distance = config.spawnDistanceMin + Math.random() * (config.spawnDistanceMax - config.spawnDistanceMin);
  let x = nearPosition.x + Math.cos(angle) * distance;
  let z = nearPosition.z + Math.sin(angle) * distance;
  x = Math.max(config.arenaMin, Math.min(config.arenaMax, x));
  z = Math.max(config.arenaMin, Math.min(config.arenaMax, z));
  const enemy = {
    id: gameState.nextEnemyId++,
    position: { x, y: 1, z },
    health: config.enemyHealth,
    maxHealth: config.enemyHealth,
    damage: config.enemyDamage,
    speed: config.enemySpeed,
    attackCooldown: 0
  };
  gameState.enemies.set(enemy.id, enemy);
  console.log(`[EnemyManager] Spawned enemy ${enemy.id} at (${x.toFixed(1)}, ${z.toFixed(1)})`);
  return enemy;
}
__name(spawnEnemy, "spawnEnemy");
function updateMovement2(gameState, players, dt) {
  if (players.size === 0) {
    return;
  }
  const playerPositions = Array.from(players.values()).filter((p) => p.state && p.state.position).map((p) => p.state.position);
  if (playerPositions.length === 0) {
    return;
  }
  const config = gameState.config;
  for (const enemy of gameState.enemies.values()) {
    let nearestDist = Infinity;
    let nearestPos = playerPositions[0];
    for (const pos of playerPositions) {
      const dx = pos.x - enemy.position.x;
      const dz = pos.z - enemy.position.z;
      const dist = Math.sqrt(dx * dx + dz * dz);
      if (dist < nearestDist) {
        nearestDist = dist;
        nearestPos = pos;
      }
    }
    if (nearestDist > config.enemyAttackRange) {
      const dx = nearestPos.x - enemy.position.x;
      const dz = nearestPos.z - enemy.position.z;
      if (nearestDist > 0) {
        const dirX = dx / nearestDist;
        const dirZ = dz / nearestDist;
        const oldX = enemy.position.x;
        const oldZ = enemy.position.z;
        enemy.position.x += dirX * enemy.speed * dt;
        enemy.position.z += dirZ * enemy.speed * dt;
        enemy.position.x = Math.max(
          config.arenaMin,
          Math.min(config.arenaMax, enemy.position.x)
        );
        enemy.position.z = Math.max(
          config.arenaMin,
          Math.min(config.arenaMax, enemy.position.z)
        );
        const deltaX = enemy.position.x - oldX;
        const deltaZ = enemy.position.z - oldZ;
        const totalDelta = Math.sqrt(deltaX * deltaX + deltaZ * deltaZ);
        if (totalDelta > 1) {
          console.log(`[EnemyManager] Large movement: Enemy ${enemy.id} moved ${totalDelta.toFixed(2)} units in ${(dt * 1e3).toFixed(1)}ms`);
        }
      }
    }
  }
}
__name(updateMovement2, "updateMovement");

// src/server_ffi.mjs
var GameRoom = class {
  static {
    __name(this, "GameRoom");
  }
  constructor(state, env) {
    this.state = state;
    this.env = env;
    this.sessions = /* @__PURE__ */ new Map();
    this.players = /* @__PURE__ */ new Map();
    this.nextPlayerId = 1;
    this.gameState = new GameState2();
    this.pendingDelta = this.createEmptyDelta();
  }
  createEmptyDelta() {
    return {
      enemy_spawns: [],
      enemy_updates: [],
      enemy_deaths: [],
      projectile_spawns: [],
      projectile_removals: [],
      damage_events: []
    };
  }
  // Handle incoming fetch requests (including WebSocket upgrades)
  async fetch(request) {
    const url = new URL(request.url);
    if (request.headers.get("Upgrade") === "websocket") {
      return this.handleWebSocketUpgrade(request);
    }
    return new Response("Expected WebSocket", { status: 400 });
  }
  // Handle WebSocket upgrade requests
  handleWebSocketUpgrade(request) {
    const pair = new WebSocketPair();
    const [client, server] = Object.values(pair);
    server.accept();
    const playerId = `player_${this.nextPlayerId++}`;
    this.sessions.set(server, playerId);
    server.addEventListener("message", (event) => {
      this.handleMessage(server, playerId, event.data);
    });
    server.addEventListener("close", () => {
      this.handleClose(server, playerId);
    });
    server.addEventListener("error", (error) => {
      console.error("WebSocket error:", error);
      this.handleClose(server, playerId);
    });
    return new Response(null, {
      status: 101,
      webSocket: client
    });
  }
  // Handle incoming WebSocket messages
  handleMessage(ws, playerId, data2) {
    try {
      const msg = JSON.parse(data2);
      switch (msg.type) {
        case "join_room":
          this.handleJoin(ws, playerId, msg.room_id, msg.player_name);
          break;
        case "leave_room":
          this.handleLeave(ws, playerId);
          break;
        case "player_update":
          this.handlePlayerUpdate(ws, playerId, msg.position, msg.rotation);
          break;
        case "spell_cast":
          this.handleSpellCast(ws, playerId, msg.wand_index, msg.direction);
          break;
        case "ping":
          this.handlePing(ws, playerId, msg.timestamp);
          break;
        default:
          this.sendToPlayer(ws, {
            type: "error",
            message: `Unknown message type: ${msg.type}`
          });
      }
    } catch (error) {
      console.error("Error handling message:", error);
      this.sendToPlayer(ws, {
        type: "error",
        message: "Failed to process message"
      });
    }
  }
  // Handle player joining
  async handleJoin(ws, playerId, roomId, playerName) {
    const newPlayer = {
      id: playerId,
      position: { x: 0, y: 0, z: 0 },
      rotation: 0,
      health: 100,
      max_health: 100,
      active_wand_index: 0
    };
    const existingPlayers = Array.from(this.players.values());
    this.players.set(playerId, { state: newPlayer, ws });
    this.sendToPlayer(ws, {
      type: "room_joined",
      room_id: roomId,
      player_id: playerId,
      players: existingPlayers.map((p) => p.state)
    });
    this.sendToPlayer(ws, this.gameState.getFullState());
    this.broadcast(
      {
        type: "player_joined",
        player: newPlayer
      },
      playerId
    );
    if (existingPlayers.length === 0) {
      console.log("[GameRoom] Starting game loop at 60Hz");
      this.gameState.lastTickTime = Date.now();
      await this.state.storage.setAlarm(Date.now() + 16);
    }
  }
  // Handle player leaving
  handleLeave(ws, playerId) {
    this.players.delete(playerId);
    this.sessions.delete(ws);
    this.broadcast({
      type: "player_left",
      player_id: playerId
    });
    if (this.players.size === 0) {
      console.log("[GameRoom] All players left, resetting game state");
      this.gameState.reset();
    }
    ws.close();
  }
  // Handle WebSocket close
  handleClose(ws, playerId) {
    this.players.delete(playerId);
    this.sessions.delete(ws);
    this.broadcast({
      type: "player_left",
      player_id: playerId
    });
    if (this.players.size === 0) {
      console.log("[GameRoom] All players left, resetting game state");
      this.gameState.reset();
    }
  }
  // Handle player position update
  handlePlayerUpdate(ws, playerId, position, rotation) {
    const player = this.players.get(playerId);
    if (player) {
      player.state.position = position;
      player.state.rotation = rotation;
    }
  }
  // Handle spell cast - for now, just broadcast (Phase 2 will make this authoritative)
  handleSpellCast(ws, playerId, wandIndex, direction) {
    this.broadcast({
      type: "spell_cast_broadcast",
      caster_id: playerId,
      wand_index: wandIndex,
      direction
    });
  }
  // Handle ping
  handlePing(ws, playerId, clientTimestamp) {
    this.sendToPlayer(ws, {
      type: "pong",
      client_timestamp: clientTimestamp,
      server_timestamp: Date.now()
    });
  }
  // Send message to a specific player
  sendToPlayer(ws, message) {
    try {
      ws.send(JSON.stringify(message));
    } catch (error) {
      console.error("Error sending to player:", error);
    }
  }
  // Broadcast message to all players (optionally excluding one)
  broadcast(message, excludePlayerId = null) {
    const msgStr = JSON.stringify(message);
    for (const [playerId, player] of this.players) {
      if (playerId !== excludePlayerId) {
        try {
          player.ws.send(msgStr);
        } catch (error) {
          console.error(`Error broadcasting to ${playerId}:`, error);
        }
      }
    }
  }
  // Game loop - runs every ~16ms (60Hz target)
  async alarm() {
    console.log(`[ALARM] Called with ${this.players.size} players`);
    if (this.players.size === 0) {
      return;
    }
    const dt = this.gameState.getDeltaTime();
    const dtMs = dt * 1e3;
    if (dtMs > 25 || dtMs < 10) {
      console.log(`[GameRoom] Alarm fired after ${dtMs.toFixed(1)}ms (target: 16ms)`);
    }
    this.pendingDelta = this.createEmptyDelta();
    const spawnedEnemy = updateSpawning2(this.gameState, this.players, dt);
    if (spawnedEnemy) {
      this.pendingDelta.enemy_spawns.push(this.gameState.enemyToState(spawnedEnemy));
    }
    updateMovement2(this.gameState, this.players, dt);
    for (const enemy of this.gameState.enemies.values()) {
      this.pendingDelta.enemy_updates.push({
        id: enemy.id,
        position: { x: enemy.position.x, y: enemy.position.y, z: enemy.position.z }
      });
    }
    if (this.gameState.enemies.size > 0) {
      const dtMs2 = dt * 1e3;
      console.log(`[GameRoom] Tick ${this.gameState.tick}: dt=${dtMs2.toFixed(1)}ms, enemies=${this.gameState.enemies.size}`);
    }
    const hasUpdates = this.pendingDelta.enemy_spawns.length > 0 || this.pendingDelta.enemy_updates.length > 0 || this.pendingDelta.enemy_deaths.length > 0 || this.pendingDelta.projectile_spawns.length > 0 || this.pendingDelta.projectile_removals.length > 0 || this.pendingDelta.damage_events.length > 0;
    if (hasUpdates) {
      this.broadcast({
        type: "game_delta",
        tick: this.gameState.tick,
        ...this.pendingDelta
      });
    }
    const playerStates = Array.from(this.players.values()).map((p) => p.state);
    if (playerStates.length > 0) {
      this.broadcast({
        type: "player_states",
        states: playerStates
      });
    }
    if (this.players.size > 0) {
      await this.state.storage.setAlarm(Date.now() + 16);
    }
  }
};

// src/index.mjs
var src_default = { fetch };

// ../node_modules/wrangler/templates/middleware/middleware-ensure-req-body-drained.ts
var drainBody = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } finally {
    try {
      if (request.body !== null && !request.bodyUsed) {
        const reader = request.body.getReader();
        while (!(await reader.read()).done) {
        }
      }
    } catch (e) {
      console.error("Failed to drain the unused request body.", e);
    }
  }
}, "drainBody");
var middleware_ensure_req_body_drained_default = drainBody;

// ../node_modules/wrangler/templates/middleware/middleware-miniflare3-json-error.ts
function reduceError(e) {
  return {
    name: e?.name,
    message: e?.message ?? String(e),
    stack: e?.stack,
    cause: e?.cause === void 0 ? void 0 : reduceError(e.cause)
  };
}
__name(reduceError, "reduceError");
var jsonError = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } catch (e) {
    const error = reduceError(e);
    return Response.json(error, {
      status: 500,
      headers: { "MF-Experimental-Error-Stack": "true" }
    });
  }
}, "jsonError");
var middleware_miniflare3_json_error_default = jsonError;

// .wrangler/tmp/bundle-JrVlNH/middleware-insertion-facade.js
var __INTERNAL_WRANGLER_MIDDLEWARE__ = [
  middleware_ensure_req_body_drained_default,
  middleware_miniflare3_json_error_default
];
var middleware_insertion_facade_default = src_default;

// ../node_modules/wrangler/templates/middleware/common.ts
var __facade_middleware__ = [];
function __facade_register__(...args) {
  __facade_middleware__.push(...args.flat());
}
__name(__facade_register__, "__facade_register__");
function __facade_invokeChain__(request, env, ctx, dispatch, middlewareChain) {
  const [head, ...tail] = middlewareChain;
  const middlewareCtx = {
    dispatch,
    next(newRequest, newEnv) {
      return __facade_invokeChain__(newRequest, newEnv, ctx, dispatch, tail);
    }
  };
  return head(request, env, ctx, middlewareCtx);
}
__name(__facade_invokeChain__, "__facade_invokeChain__");
function __facade_invoke__(request, env, ctx, dispatch, finalMiddleware) {
  return __facade_invokeChain__(request, env, ctx, dispatch, [
    ...__facade_middleware__,
    finalMiddleware
  ]);
}
__name(__facade_invoke__, "__facade_invoke__");

// .wrangler/tmp/bundle-JrVlNH/middleware-loader.entry.ts
var __Facade_ScheduledController__ = class ___Facade_ScheduledController__ {
  constructor(scheduledTime, cron, noRetry) {
    this.scheduledTime = scheduledTime;
    this.cron = cron;
    this.#noRetry = noRetry;
  }
  static {
    __name(this, "__Facade_ScheduledController__");
  }
  #noRetry;
  noRetry() {
    if (!(this instanceof ___Facade_ScheduledController__)) {
      throw new TypeError("Illegal invocation");
    }
    this.#noRetry();
  }
};
function wrapExportedHandler(worker) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return worker;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  const fetchDispatcher = /* @__PURE__ */ __name(function(request, env, ctx) {
    if (worker.fetch === void 0) {
      throw new Error("Handler does not export a fetch() function.");
    }
    return worker.fetch(request, env, ctx);
  }, "fetchDispatcher");
  return {
    ...worker,
    fetch(request, env, ctx) {
      const dispatcher = /* @__PURE__ */ __name(function(type, init) {
        if (type === "scheduled" && worker.scheduled !== void 0) {
          const controller = new __Facade_ScheduledController__(
            Date.now(),
            init.cron ?? "",
            () => {
            }
          );
          return worker.scheduled(controller, env, ctx);
        }
      }, "dispatcher");
      return __facade_invoke__(request, env, ctx, dispatcher, fetchDispatcher);
    }
  };
}
__name(wrapExportedHandler, "wrapExportedHandler");
function wrapWorkerEntrypoint(klass) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return klass;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  return class extends klass {
    #fetchDispatcher = /* @__PURE__ */ __name((request, env, ctx) => {
      this.env = env;
      this.ctx = ctx;
      if (super.fetch === void 0) {
        throw new Error("Entrypoint class does not define a fetch() function.");
      }
      return super.fetch(request);
    }, "#fetchDispatcher");
    #dispatcher = /* @__PURE__ */ __name((type, init) => {
      if (type === "scheduled" && super.scheduled !== void 0) {
        const controller = new __Facade_ScheduledController__(
          Date.now(),
          init.cron ?? "",
          () => {
          }
        );
        return super.scheduled(controller);
      }
    }, "#dispatcher");
    fetch(request) {
      return __facade_invoke__(
        request,
        this.env,
        this.ctx,
        this.#dispatcher,
        this.#fetchDispatcher
      );
    }
  };
}
__name(wrapWorkerEntrypoint, "wrapWorkerEntrypoint");
var WRAPPED_ENTRY;
if (typeof middleware_insertion_facade_default === "object") {
  WRAPPED_ENTRY = wrapExportedHandler(middleware_insertion_facade_default);
} else if (typeof middleware_insertion_facade_default === "function") {
  WRAPPED_ENTRY = wrapWorkerEntrypoint(middleware_insertion_facade_default);
}
var middleware_loader_entry_default = WRAPPED_ENTRY;
export {
  GameRoom,
  __INTERNAL_WRANGLER_MIDDLEWARE__,
  middleware_loader_entry_default as default
};
//# sourceMappingURL=index.js.map
