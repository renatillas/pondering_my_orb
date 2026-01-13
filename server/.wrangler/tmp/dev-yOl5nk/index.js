var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// .wrangler/tmp/bundle-ouh2YL/checked-fetch.js
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
  static fromArray(array4, tail) {
    let t = tail || new Empty();
    for (let i = array4.length - 1; i >= 0; --i) {
      t = new NonEmpty(array4[i], t);
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
    let length6 = 0;
    while (current) {
      current = current.tail;
      length6++;
    }
    return length6 - 1;
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
var List$isNonEmpty = /* @__PURE__ */ __name((value) => value instanceof NonEmpty, "List$isNonEmpty");
var List$NonEmpty$first = /* @__PURE__ */ __name((value) => value.head, "List$NonEmpty$first");
var List$NonEmpty$rest = /* @__PURE__ */ __name((value) => value.tail, "List$NonEmpty$rest");
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
  byteAt(index5) {
    if (index5 < 0 || index5 >= this.byteSize) {
      return void 0;
    }
    return bitArrayByteAt(this.rawBuffer, this.bitOffset, index5);
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
function bitArrayByteAt(buffer, bitOffset, index5) {
  if (bitOffset === 0) {
    return buffer[index5] ?? 0;
  } else {
    const a = buffer[index5] << bitOffset & 255;
    const b = buffer[index5 + 1] >> 8 - bitOffset;
    return a | b;
  }
}
__name(bitArrayByteAt, "bitArrayByteAt");
var UtfCodepoint = class {
  static {
    __name(this, "UtfCodepoint");
  }
  constructor(value) {
    this.value = value;
  }
};
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
var Result$Ok = /* @__PURE__ */ __name((value) => new Ok(value), "Result$Ok");
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
var Result$Error = /* @__PURE__ */ __name((detail) => new Error2(detail), "Result$Error");
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
    let [keys2, get9] = getters(a);
    const ka = keys2(a);
    const kb = keys2(b);
    if (ka.length !== kb.length) return false;
    for (let k of ka) {
      values2.push(get9(a, k), get9(b, k));
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
function remainderInt(a, b) {
  if (b === 0) {
    return 0;
  } else {
    return a % b;
  }
}
__name(remainderInt, "remainderInt");
function divideInt(a, b) {
  return Math.trunc(divideFloat(a, b));
}
__name(divideInt, "divideInt");
function divideFloat(a, b) {
  if (b === 0) {
    return 0;
  } else {
    return a / b;
  }
}
__name(divideFloat, "divideFloat");
function makeError(variant, file, module, line, fn, message, extra) {
  let error = new globalThis.Error(message);
  error.gleam_error = variant;
  error.file = file;
  error.module = module;
  error.line = line;
  error.function = fn;
  error.fn = fn;
  for (let k in extra) error[k] = extra[k];
  return error;
}
__name(makeError, "makeError");

// build/dev/javascript/gleam_stdlib/dict.mjs
var referenceMap = /* @__PURE__ */ new WeakMap();
var tempDataView = /* @__PURE__ */ new DataView(
  /* @__PURE__ */ new ArrayBuffer(8)
);
var referenceUID = 0;
function hashByReference(o) {
  const known = referenceMap.get(o);
  if (known !== void 0) {
    return known;
  }
  const hash = referenceUID++;
  if (referenceUID === 2147483647) {
    referenceUID = 0;
  }
  referenceMap.set(o, hash);
  return hash;
}
__name(hashByReference, "hashByReference");
function hashMerge(a, b) {
  return a ^ b + 2654435769 + (a << 6) + (a >> 2) | 0;
}
__name(hashMerge, "hashMerge");
function hashString(s) {
  let hash = 0;
  const len = s.length;
  for (let i = 0; i < len; i++) {
    hash = Math.imul(31, hash) + s.charCodeAt(i) | 0;
  }
  return hash;
}
__name(hashString, "hashString");
function hashNumber(n) {
  tempDataView.setFloat64(0, n);
  const i = tempDataView.getInt32(0);
  const j = tempDataView.getInt32(4);
  return Math.imul(73244475, i >> 16 ^ i) ^ j;
}
__name(hashNumber, "hashNumber");
function hashBigInt(n) {
  return hashString(n.toString());
}
__name(hashBigInt, "hashBigInt");
function hashObject(o) {
  const proto = Object.getPrototypeOf(o);
  if (proto !== null && typeof proto.hashCode === "function") {
    try {
      const code = o.hashCode(o);
      if (typeof code === "number") {
        return code;
      }
    } catch {
    }
  }
  if (o instanceof Promise || o instanceof WeakSet || o instanceof WeakMap) {
    return hashByReference(o);
  }
  if (o instanceof Date) {
    return hashNumber(o.getTime());
  }
  let h = 0;
  if (o instanceof ArrayBuffer) {
    o = new Uint8Array(o);
  }
  if (Array.isArray(o) || o instanceof Uint8Array) {
    for (let i = 0; i < o.length; i++) {
      h = Math.imul(31, h) + getHash(o[i]) | 0;
    }
  } else if (o instanceof Set) {
    o.forEach((v) => {
      h = h + getHash(v) | 0;
    });
  } else if (o instanceof Map) {
    o.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
  } else {
    const keys2 = Object.keys(o);
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      const v = o[k];
      h = h + hashMerge(getHash(v), hashString(k)) | 0;
    }
  }
  return h;
}
__name(hashObject, "hashObject");
function getHash(u) {
  if (u === null) return 1108378658;
  if (u === void 0) return 1108378659;
  if (u === true) return 1108378657;
  if (u === false) return 1108378656;
  switch (typeof u) {
    case "number":
      return hashNumber(u);
    case "string":
      return hashString(u);
    case "bigint":
      return hashBigInt(u);
    case "object":
      return hashObject(u);
    case "symbol":
      return hashByReference(u);
    case "function":
      return hashByReference(u);
    default:
      return 0;
  }
}
__name(getHash, "getHash");
var Dict = class {
  static {
    __name(this, "Dict");
  }
  constructor(size5, root) {
    this.size = size5;
    this.root = root;
  }
};
var bits = 5;
var mask = (1 << bits) - 1;
var noElementMarker = Symbol();
var generationKey = Symbol();
var emptyNode = /* @__PURE__ */ newNode(0);
var emptyDict = /* @__PURE__ */ new Dict(0, emptyNode);
var errorNil = /* @__PURE__ */ Result$Error(void 0);
function makeNode(generation, datamap, nodemap, data2) {
  return {
    // A node is a high-arity (32 in practice) hybrid tree node.
    // Hybrid means that it stores data directly as well as pointers to child nodes.
    //
    // Each node contains 2 bitmaps:
    // - The datamap has a bit set if that slot in the node contains direct data
    // - The nodemap has a bit set if that slot in the node contains another node.
    //
    // Both are exclusive to on another, so datamap & nodemap == 0.
    //
    // Every key/hash value directly correlates to a specific bit by using a trie
    // suffix (least significant bits first) encoding.
    // For example, if the last 5 bits of the hash are 1101, the bit to check for
    // that value is the 13th bit.
    datamap,
    nodemap,
    // The slots itself are stored in a single contiguous array that contains
    // both direct k/v-pairs and child nodes.
    //
    // The direct children come first, followed by the child nodes in _reverse order_:
    //
    //              7654321
    //     datamap: 1000100
    //     nodemap:   10011
    //     data: [key3, value3, key7, value7, child5, child2, child1]
    //            ------------------------->  <---------------------
    //                     datamap                    nodemap
    //
    // Every `1` bit in the datamap corresponds to a pair of [key, value] entries,
    // and every `1` bit in the nodemap corresponds to a child node entry.
    //
    // Children are stored in reverse order to avoid having to store or calculate an
    // "offset" value to skip over the direct children.
    data: data2,
    // The generation is used to track which nodes need to be copied during transient updates.
    // Using a symbol here makes `isEqual` ignore this field.
    [generationKey]: generation
  };
}
__name(makeNode, "makeNode");
function newNode(generation) {
  return makeNode(generation, 0, 0, []);
}
__name(newNode, "newNode");
function copyNode(node, generation) {
  if (node[generationKey] === generation) {
    return node;
  }
  const newData = node.data.slice(0);
  return makeNode(generation, node.datamap, node.nodemap, newData);
}
__name(copyNode, "copyNode");
function copyAndSet(node, generation, idx, val) {
  if (node.data[idx] === val) {
    return node;
  }
  node = copyNode(node, generation);
  node.data[idx] = val;
  return node;
}
__name(copyAndSet, "copyAndSet");
function copyAndInsertPair(node, generation, bit, idx, key, val) {
  const data2 = node.data;
  const length6 = data2.length;
  const newData = new Array(length6 + 2);
  let readIndex = 0;
  let writeIndex = 0;
  while (readIndex < idx) newData[writeIndex++] = data2[readIndex++];
  newData[writeIndex++] = key;
  newData[writeIndex++] = val;
  while (readIndex < length6) newData[writeIndex++] = data2[readIndex++];
  return makeNode(generation, node.datamap | bit, node.nodemap, newData);
}
__name(copyAndInsertPair, "copyAndInsertPair");
function copyAndRemovePair(node, generation, bit, idx) {
  node = copyNode(node, generation);
  const data2 = node.data;
  const length6 = data2.length;
  for (let w = idx, r = idx + 2; r < length6; ++r, ++w) {
    data2[w] = data2[r];
  }
  data2.pop();
  data2.pop();
  node.datamap ^= bit;
  return node;
}
__name(copyAndRemovePair, "copyAndRemovePair");
function make() {
  return emptyDict;
}
__name(make, "make");
function size(dict2) {
  return dict2.size;
}
__name(size, "size");
function get(dict2, key) {
  const result2 = lookup(dict2.root, key, getHash(key));
  return result2 !== noElementMarker ? Result$Ok(result2) : errorNil;
}
__name(get, "get");
function lookup(node, key, hash) {
  for (let shift = 0; shift < 32; shift += bits) {
    const data2 = node.data;
    const bit = hashbit(hash, shift);
    if (node.nodemap & bit) {
      node = data2[data2.length - 1 - index(node.nodemap, bit)];
    } else if (node.datamap & bit) {
      const dataidx = Math.imul(index(node.datamap, bit), 2);
      return isEqual(key, data2[dataidx]) ? data2[dataidx + 1] : noElementMarker;
    } else {
      return noElementMarker;
    }
  }
  const overflow = node.data;
  for (let i = 0; i < overflow.length; i += 2) {
    if (isEqual(key, overflow[i])) {
      return overflow[i + 1];
    }
  }
  return noElementMarker;
}
__name(lookup, "lookup");
function toTransient(dict2) {
  return {
    generation: nextGeneration(dict2),
    root: dict2.root,
    size: dict2.size,
    dict: dict2
  };
}
__name(toTransient, "toTransient");
function fromTransient(transient) {
  if (transient.root === transient.dict.root) {
    return transient.dict;
  }
  return new Dict(transient.size, transient.root);
}
__name(fromTransient, "fromTransient");
function nextGeneration(dict2) {
  const root = dict2.root;
  if (root[generationKey] < Number.MAX_SAFE_INTEGER) {
    return root[generationKey] + 1;
  }
  const queue2 = [root];
  while (queue2.length) {
    const node = queue2.pop();
    node[generationKey] = 0;
    const nodeStart = data.length - popcount(node.nodemap);
    for (let i = nodeStart; i < node.data.length; ++i) {
      queue2.push(node.data[i]);
    }
  }
  return 1;
}
__name(nextGeneration, "nextGeneration");
var globalTransient = /* @__PURE__ */ toTransient(emptyDict);
function insert(dict2, key, value) {
  globalTransient.generation = nextGeneration(dict2);
  globalTransient.size = dict2.size;
  const hash = getHash(key);
  const root = insertIntoNode(globalTransient, dict2.root, key, value, hash, 0);
  if (root === dict2.root) {
    return dict2;
  }
  return new Dict(globalTransient.size, root);
}
__name(insert, "insert");
function insertIntoNode(transient, node, key, value, hash, shift) {
  const data2 = node.data;
  const generation = transient.generation;
  if (shift > 32) {
    for (let i = 0; i < data2.length; i += 2) {
      if (isEqual(key, data2[i])) {
        return copyAndSet(node, generation, i + 1, value);
      }
    }
    transient.size += 1;
    return copyAndInsertPair(node, generation, 0, data2.length, key, value);
  }
  const bit = hashbit(hash, shift);
  if (node.nodemap & bit) {
    const nodeidx2 = data2.length - 1 - index(node.nodemap, bit);
    let child2 = data2[nodeidx2];
    child2 = insertIntoNode(transient, child2, key, value, hash, shift + bits);
    return copyAndSet(node, generation, nodeidx2, child2);
  }
  const dataidx = Math.imul(index(node.datamap, bit), 2);
  if ((node.datamap & bit) === 0) {
    transient.size += 1;
    return copyAndInsertPair(node, generation, bit, dataidx, key, value);
  }
  if (isEqual(key, data2[dataidx])) {
    return copyAndSet(node, generation, dataidx + 1, value);
  }
  const childShift = shift + bits;
  let child = emptyNode;
  child = insertIntoNode(transient, child, key, value, hash, childShift);
  const key2 = data2[dataidx];
  const value2 = data2[dataidx + 1];
  const hash2 = getHash(key2);
  child = insertIntoNode(transient, child, key2, value2, hash2, childShift);
  transient.size -= 1;
  const length6 = data2.length;
  const nodeidx = length6 - 1 - index(node.nodemap, bit);
  const newData = new Array(length6 - 1);
  let readIndex = 0;
  let writeIndex = 0;
  while (readIndex < dataidx) newData[writeIndex++] = data2[readIndex++];
  readIndex += 2;
  while (readIndex <= nodeidx) newData[writeIndex++] = data2[readIndex++];
  newData[writeIndex++] = child;
  while (readIndex < length6) newData[writeIndex++] = data2[readIndex++];
  return makeNode(generation, node.datamap ^ bit, node.nodemap | bit, newData);
}
__name(insertIntoNode, "insertIntoNode");
function destructiveTransientDelete(key, transient) {
  const hash = getHash(key);
  transient.root = deleteFromNode(transient, transient.root, key, hash, 0);
  return transient;
}
__name(destructiveTransientDelete, "destructiveTransientDelete");
function deleteFromNode(transient, node, key, hash, shift) {
  const data2 = node.data;
  const generation = transient.generation;
  if (shift > 32) {
    for (let i = 0; i < data2.length; i += 2) {
      if (isEqual(key, data2[i])) {
        transient.size -= 1;
        return copyAndRemovePair(node, generation, 0, i);
      }
    }
    return node;
  }
  const bit = hashbit(hash, shift);
  const dataidx = Math.imul(index(node.datamap, bit), 2);
  if ((node.nodemap & bit) !== 0) {
    const nodeidx = data2.length - 1 - index(node.nodemap, bit);
    let child = data2[nodeidx];
    child = deleteFromNode(transient, child, key, hash, shift + bits);
    if (child.nodemap !== 0 || child.data.length > 2) {
      return copyAndSet(node, generation, nodeidx, child);
    }
    const length6 = data2.length;
    const newData = new Array(length6 + 1);
    let readIndex = 0;
    let writeIndex = 0;
    while (readIndex < dataidx) newData[writeIndex++] = data2[readIndex++];
    newData[writeIndex++] = child.data[0];
    newData[writeIndex++] = child.data[1];
    while (readIndex < nodeidx) newData[writeIndex++] = data2[readIndex++];
    readIndex++;
    while (readIndex < length6) newData[writeIndex++] = data2[readIndex++];
    return makeNode(generation, node.datamap | bit, node.nodemap ^ bit, newData);
  }
  if ((node.datamap & bit) === 0 || !isEqual(key, data2[dataidx])) {
    return node;
  }
  transient.size -= 1;
  return copyAndRemovePair(node, generation, bit, dataidx);
}
__name(deleteFromNode, "deleteFromNode");
function map(dict2, fun) {
  const generation = nextGeneration(dict2);
  const root = copyNode(dict2.root, generation);
  const queue2 = [root];
  while (queue2.length) {
    const node = queue2.pop();
    const data2 = node.data;
    const edgesStart = data2.length - popcount(node.nodemap);
    for (let i = 0; i < edgesStart; i += 2) {
      data2[i + 1] = fun(data2[i], data2[i + 1]);
    }
    for (let i = edgesStart; i < data2.length; ++i) {
      data2[i] = copyNode(data2[i], generation);
      queue2.push(data2[i]);
    }
  }
  return new Dict(dict2.size, root);
}
__name(map, "map");
function fold(dict2, state, fun) {
  const queue2 = [dict2.root];
  while (queue2.length) {
    const node = queue2.pop();
    const data2 = node.data;
    const edgesStart = data2.length - popcount(node.nodemap);
    for (let i = 0; i < edgesStart; i += 2) {
      state = fun(state, data2[i], data2[i + 1]);
    }
    for (let i = edgesStart; i < data2.length; ++i) {
      queue2.push(data2[i]);
    }
  }
  return state;
}
__name(fold, "fold");
function popcount(n) {
  n -= n >>> 1 & 1431655765;
  n = (n & 858993459) + (n >>> 2 & 858993459);
  return Math.imul(n + (n >>> 4) & 252645135, 16843009) >>> 24;
}
__name(popcount, "popcount");
function index(bitmap, bit) {
  return popcount(bitmap & bit - 1);
}
__name(index, "index");
function hashbit(hash, shift) {
  return 1 << (hash >>> shift & mask);
}
__name(hashbit, "hashbit");

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

// build/dev/javascript/gleam_stdlib/gleam/dict.mjs
function delete$(dict2, key) {
  let _pipe = toTransient(dict2);
  let _pipe$1 = ((_capture) => {
    return destructiveTransientDelete(key, _capture);
  })(
    _pipe
  );
  return fromTransient(_pipe$1);
}
__name(delete$, "delete$");
function keys(dict2) {
  return fold(
    dict2,
    toList([]),
    (acc, key, _) => {
      return prepend(key, acc);
    }
  );
}
__name(keys, "keys");
function values(dict2) {
  return fold(
    dict2,
    toList([]),
    (acc, _, value) => {
      return prepend(value, acc);
    }
  );
}
__name(values, "values");

// build/dev/javascript/gleam_stdlib/gleam/order.mjs
var Lt = class extends CustomType {
  static {
    __name(this, "Lt");
  }
};
var Eq = class extends CustomType {
  static {
    __name(this, "Eq");
  }
};
var Gt = class extends CustomType {
  static {
    __name(this, "Gt");
  }
};
function break_tie(order, other) {
  if (order instanceof Lt) {
    return order;
  } else if (order instanceof Eq) {
    return other;
  } else {
    return order;
  }
}
__name(break_tie, "break_tie");

// build/dev/javascript/gleam_stdlib/gleam/int.mjs
function compare(a, b) {
  let $ = a === b;
  if ($) {
    return new Eq();
  } else {
    let $1 = a < b;
    if ($1) {
      return new Lt();
    } else {
      return new Gt();
    }
  }
}
__name(compare, "compare");

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
function inspect2(term) {
  let _pipe = term;
  let _pipe$1 = inspect(_pipe);
  return identity(_pipe$1);
}
__name(inspect2, "inspect");

// build/dev/javascript/gleam_stdlib/gleam/dynamic/decode.mjs
var DecodeError = class extends CustomType {
  static {
    __name(this, "DecodeError");
  }
  constructor(expected, found, path) {
    super();
    this.expected = expected;
    this.found = found;
    this.path = path;
  }
};
var Decoder = class extends CustomType {
  static {
    __name(this, "Decoder");
  }
  constructor(function$) {
    super();
    this.function = function$;
  }
};
var int2 = /* @__PURE__ */ new Decoder(decode_int);
var float2 = /* @__PURE__ */ new Decoder(decode_float);
var string2 = /* @__PURE__ */ new Decoder(decode_string);
function run(data2, decoder7) {
  let $ = decoder7.function(data2);
  let maybe_invalid_data;
  let errors;
  maybe_invalid_data = $[0];
  errors = $[1];
  if (errors instanceof Empty) {
    return new Ok(maybe_invalid_data);
  } else {
    return new Error2(errors);
  }
}
__name(run, "run");
function success(data2) {
  return new Decoder((_) => {
    return [data2, toList([])];
  });
}
__name(success, "success");
function map3(decoder7, transformer) {
  return new Decoder(
    (d) => {
      let $ = decoder7.function(d);
      let data2;
      let errors;
      data2 = $[0];
      errors = $[1];
      return [transformer(data2), errors];
    }
  );
}
__name(map3, "map");
function run_decoders(loop$data, loop$failure, loop$decoders) {
  while (true) {
    let data2 = loop$data;
    let failure2 = loop$failure;
    let decoders = loop$decoders;
    if (decoders instanceof Empty) {
      return failure2;
    } else {
      let decoder7 = decoders.head;
      let decoders$1 = decoders.tail;
      let $ = decoder7.function(data2);
      let layer;
      let errors;
      layer = $;
      errors = $[1];
      if (errors instanceof Empty) {
        return layer;
      } else {
        loop$data = data2;
        loop$failure = failure2;
        loop$decoders = decoders$1;
      }
    }
  }
}
__name(run_decoders, "run_decoders");
function one_of(first3, alternatives) {
  return new Decoder(
    (dynamic_data) => {
      let $ = first3.function(dynamic_data);
      let layer;
      let errors;
      layer = $;
      errors = $[1];
      if (errors instanceof Empty) {
        return layer;
      } else {
        return run_decoders(dynamic_data, layer, alternatives);
      }
    }
  );
}
__name(one_of, "one_of");
function optional(inner) {
  return new Decoder(
    (data2) => {
      let $ = is_null(data2);
      if ($) {
        return [new None(), toList([])];
      } else {
        let $1 = inner.function(data2);
        let data$1;
        let errors;
        data$1 = $1[0];
        errors = $1[1];
        return [new Some(data$1), errors];
      }
    }
  );
}
__name(optional, "optional");
function decode_error(expected, found) {
  return toList([
    new DecodeError(expected, classify_dynamic(found), toList([]))
  ]);
}
__name(decode_error, "decode_error");
function run_dynamic_function(data2, name2, f) {
  let $ = f(data2);
  if ($ instanceof Ok) {
    let data$1 = $[0];
    return [data$1, toList([])];
  } else {
    let placeholder = $[0];
    return [
      placeholder,
      toList([new DecodeError(name2, classify_dynamic(data2), toList([]))])
    ];
  }
}
__name(run_dynamic_function, "run_dynamic_function");
function decode_int(data2) {
  return run_dynamic_function(data2, "Int", int);
}
__name(decode_int, "decode_int");
function decode_float(data2) {
  return run_dynamic_function(data2, "Float", float);
}
__name(decode_float, "decode_float");
function failure(placeholder, name2) {
  return new Decoder((d) => {
    return [placeholder, decode_error(name2, d)];
  });
}
__name(failure, "failure");
function decode_string(data2) {
  return run_dynamic_function(data2, "String", string);
}
__name(decode_string, "decode_string");
function push_path(layer, path) {
  let decoder7 = one_of(
    string2,
    toList([
      (() => {
        let _pipe = int2;
        return map3(_pipe, to_string);
      })()
    ])
  );
  let path$1 = map2(
    path,
    (key) => {
      let key$1 = identity(key);
      let $ = run(key$1, decoder7);
      if ($ instanceof Ok) {
        let key$2 = $[0];
        return key$2;
      } else {
        return "<" + classify_dynamic(key$1) + ">";
      }
    }
  );
  let errors = map2(
    layer[1],
    (error) => {
      return new DecodeError(
        error.expected,
        error.found,
        append2(path$1, error.path)
      );
    }
  );
  return [layer[0], errors];
}
__name(push_path, "push_path");
function index3(loop$path, loop$position, loop$inner, loop$data, loop$handle_miss) {
  while (true) {
    let path = loop$path;
    let position = loop$position;
    let inner = loop$inner;
    let data2 = loop$data;
    let handle_miss = loop$handle_miss;
    if (path instanceof Empty) {
      let _pipe = data2;
      let _pipe$1 = inner(_pipe);
      return push_path(_pipe$1, reverse(position));
    } else {
      let key = path.head;
      let path$1 = path.tail;
      let $ = index2(data2, key);
      if ($ instanceof Ok) {
        let $1 = $[0];
        if ($1 instanceof Some) {
          let data$1 = $1[0];
          loop$path = path$1;
          loop$position = prepend(key, position);
          loop$inner = inner;
          loop$data = data$1;
          loop$handle_miss = handle_miss;
        } else {
          return handle_miss(data2, prepend(key, position));
        }
      } else {
        let kind = $[0];
        let $1 = inner(data2);
        let default$;
        default$ = $1[0];
        let _pipe = [
          default$,
          toList([new DecodeError(kind, classify_dynamic(data2), toList([]))])
        ];
        return push_path(_pipe, reverse(position));
      }
    }
  }
}
__name(index3, "index");
function subfield(field_path, field_decoder, next) {
  return new Decoder(
    (data2) => {
      let $ = index3(
        field_path,
        toList([]),
        field_decoder.function,
        data2,
        (data3, position) => {
          let $12 = field_decoder.function(data3);
          let default$;
          default$ = $12[0];
          let _pipe = [
            default$,
            toList([new DecodeError("Field", "Nothing", toList([]))])
          ];
          return push_path(_pipe, reverse(position));
        }
      );
      let out;
      let errors1;
      out = $[0];
      errors1 = $[1];
      let $1 = next(out).function(data2);
      let out$1;
      let errors2;
      out$1 = $1[0];
      errors2 = $1[1];
      return [out$1, append2(errors1, errors2)];
    }
  );
}
__name(subfield, "subfield");
function at(path, inner) {
  return new Decoder(
    (data2) => {
      return index3(
        path,
        toList([]),
        inner.function,
        data2,
        (data3, position) => {
          let $ = inner.function(data3);
          let default$;
          default$ = $[0];
          let _pipe = [
            default$,
            toList([new DecodeError("Field", "Nothing", toList([]))])
          ];
          return push_path(_pipe, reverse(position));
        }
      );
    }
  );
}
__name(at, "at");
function field(field_name, field_decoder, next) {
  return subfield(toList([field_name]), field_decoder, next);
}
__name(field, "field");

// build/dev/javascript/gleam_stdlib/gleam_stdlib.mjs
function identity(x) {
  return x;
}
__name(identity, "identity");
function to_string(term) {
  return term.toString();
}
__name(to_string, "to_string");
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
function ceiling(float4) {
  return Math.ceil(float4);
}
__name(ceiling, "ceiling");
function round2(float4) {
  return Math.round(float4);
}
__name(round2, "round");
function power2(base, exponent) {
  return Math.pow(base, exponent);
}
__name(power2, "power");
function random_uniform() {
  const random_uniform_result = Math.random();
  if (random_uniform_result === 1) {
    return random_uniform();
  }
  return random_uniform_result;
}
__name(random_uniform, "random_uniform");
function classify_dynamic(data2) {
  if (typeof data2 === "string") {
    return "String";
  } else if (typeof data2 === "boolean") {
    return "Bool";
  } else if (data2 instanceof Result) {
    return "Result";
  } else if (data2 instanceof List) {
    return "List";
  } else if (data2 instanceof BitArray) {
    return "BitArray";
  } else if (data2 instanceof Dict) {
    return "Dict";
  } else if (Number.isInteger(data2)) {
    return "Int";
  } else if (Array.isArray(data2)) {
    return `Array`;
  } else if (typeof data2 === "number") {
    return "Float";
  } else if (data2 === null) {
    return "Nil";
  } else if (data2 === void 0) {
    return "Nil";
  } else {
    const type = typeof data2;
    return type.charAt(0).toUpperCase() + type.slice(1);
  }
}
__name(classify_dynamic, "classify_dynamic");
function inspect(v) {
  return new Inspector().inspect(v);
}
__name(inspect, "inspect");
function float_to_string(float4) {
  const string4 = float4.toString().replace("+", "");
  if (string4.indexOf(".") >= 0) {
    return string4;
  } else {
    const index5 = string4.indexOf("e");
    if (index5 >= 0) {
      return string4.slice(0, index5) + ".0" + string4.slice(index5);
    } else {
      return string4 + ".0";
    }
  }
}
__name(float_to_string, "float_to_string");
var Inspector = class {
  static {
    __name(this, "Inspector");
  }
  #references = /* @__PURE__ */ new Set();
  inspect(v) {
    const t = typeof v;
    if (v === true) return "True";
    if (v === false) return "False";
    if (v === null) return "//js(null)";
    if (v === void 0) return "Nil";
    if (t === "string") return this.#string(v);
    if (t === "bigint" || Number.isInteger(v)) return v.toString();
    if (t === "number") return float_to_string(v);
    if (v instanceof UtfCodepoint) return this.#utfCodepoint(v);
    if (v instanceof BitArray) return this.#bit_array(v);
    if (v instanceof RegExp) return `//js(${v})`;
    if (v instanceof Date) return `//js(Date("${v.toISOString()}"))`;
    if (v instanceof globalThis.Error) return `//js(${v.toString()})`;
    if (v instanceof Function) {
      const args = [];
      for (const i of Array(v.length).keys())
        args.push(String.fromCharCode(i + 97));
      return `//fn(${args.join(", ")}) { ... }`;
    }
    if (this.#references.size === this.#references.add(v).size) {
      return "//js(circular reference)";
    }
    let printed;
    if (Array.isArray(v)) {
      printed = `#(${v.map((v2) => this.inspect(v2)).join(", ")})`;
    } else if (v instanceof List) {
      printed = this.#list(v);
    } else if (v instanceof CustomType) {
      printed = this.#customType(v);
    } else if (v instanceof Dict) {
      printed = this.#dict(v);
    } else if (v instanceof Set) {
      return `//js(Set(${[...v].map((v2) => this.inspect(v2)).join(", ")}))`;
    } else {
      printed = this.#object(v);
    }
    this.#references.delete(v);
    return printed;
  }
  #object(v) {
    const name2 = Object.getPrototypeOf(v)?.constructor?.name || "Object";
    const props = [];
    for (const k of Object.keys(v)) {
      props.push(`${this.inspect(k)}: ${this.inspect(v[k])}`);
    }
    const body2 = props.length ? " " + props.join(", ") + " " : "";
    const head = name2 === "Object" ? "" : name2 + " ";
    return `//js(${head}{${body2}})`;
  }
  #dict(map11) {
    let body2 = "dict.from_list([";
    let first3 = true;
    body2 = fold(map11, body2, (body3, key, value) => {
      if (!first3) body3 = body3 + ", ";
      first3 = false;
      return body3 + "#(" + this.inspect(key) + ", " + this.inspect(value) + ")";
    });
    return body2 + "])";
  }
  #customType(record) {
    const props = Object.keys(record).map((label) => {
      const value = this.inspect(record[label]);
      return isNaN(parseInt(label)) ? `${label}: ${value}` : value;
    }).join(", ");
    return props ? `${record.constructor.name}(${props})` : record.constructor.name;
  }
  #list(list3) {
    if (list3 instanceof Empty) {
      return "[]";
    }
    let char_out = 'charlist.from_string("';
    let list_out = "[";
    let current = list3;
    while (current instanceof NonEmpty) {
      let element = current.head;
      current = current.tail;
      if (list_out !== "[") {
        list_out += ", ";
      }
      list_out += this.inspect(element);
      if (char_out) {
        if (Number.isInteger(element) && element >= 32 && element <= 126) {
          char_out += String.fromCharCode(element);
        } else {
          char_out = null;
        }
      }
    }
    if (char_out) {
      return char_out + '")';
    } else {
      return list_out + "]";
    }
  }
  #string(str) {
    let new_str = '"';
    for (let i = 0; i < str.length; i++) {
      const char = str[i];
      switch (char) {
        case "\n":
          new_str += "\\n";
          break;
        case "\r":
          new_str += "\\r";
          break;
        case "	":
          new_str += "\\t";
          break;
        case "\f":
          new_str += "\\f";
          break;
        case "\\":
          new_str += "\\\\";
          break;
        case '"':
          new_str += '\\"';
          break;
        default:
          if (char < " " || char > "~" && char < "\xA0") {
            new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
          } else {
            new_str += char;
          }
      }
    }
    new_str += '"';
    return new_str;
  }
  #utfCodepoint(codepoint2) {
    return `//utfcodepoint(${String.fromCodePoint(codepoint2.value)})`;
  }
  #bit_array(bits2) {
    if (bits2.bitSize === 0) {
      return "<<>>";
    }
    let acc = "<<";
    for (let i = 0; i < bits2.byteSize - 1; i++) {
      acc += bits2.byteAt(i).toString();
      acc += ", ";
    }
    if (bits2.byteSize * 8 === bits2.bitSize) {
      acc += bits2.byteAt(bits2.byteSize - 1).toString();
    } else {
      const trailingBitsCount = bits2.bitSize % 8;
      acc += bits2.byteAt(bits2.byteSize - 1) >> 8 - trailingBitsCount;
      acc += `:size(${trailingBitsCount})`;
    }
    acc += ">>";
    return acc;
  }
};
function index2(data2, key) {
  if (data2 instanceof Dict) {
    const result2 = get(data2, key);
    return new Ok(result2.isOk() ? new Some(result2[0]) : new None());
  }
  if (data2 instanceof WeakMap || data2 instanceof Map) {
    const token = {};
    const entry = data2.get(key, token);
    if (entry === token) return new Ok(new None());
    return new Ok(new Some(entry));
  }
  const key_is_int = Number.isInteger(key);
  if (key_is_int && key >= 0 && key < 8 && data2 instanceof List) {
    let i = 0;
    for (const value of data2) {
      if (i === key) return new Ok(new Some(value));
      i++;
    }
    return new Error2("Indexable");
  }
  if (key_is_int && Array.isArray(data2) || data2 && typeof data2 === "object" || data2 && Object.getPrototypeOf(data2) === Object.prototype) {
    if (key in data2) return new Ok(new Some(data2[key]));
    return new Ok(new None());
  }
  return new Error2(key_is_int ? "Indexable" : "Dict");
}
__name(index2, "index");
function float(data2) {
  if (typeof data2 === "number") return new Ok(data2);
  return new Error2(0);
}
__name(float, "float");
function int(data2) {
  if (Number.isInteger(data2)) return new Ok(data2);
  return new Error2(0);
}
__name(int, "int");
function string(data2) {
  if (typeof data2 === "string") return new Ok(data2);
  return new Error2("");
}
__name(string, "string");
function is_null(data2) {
  return data2 === null || data2 === void 0;
}
__name(is_null, "is_null");

// build/dev/javascript/gleam_stdlib/gleam/float.mjs
function power(base, exponent) {
  let fractional = ceiling(exponent) - exponent > 0;
  let $ = base < 0 && fractional || base === 0 && exponent < 0;
  if ($) {
    return new Error2(void 0);
  } else {
    return new Ok(power2(base, exponent));
  }
}
__name(power, "power");
function square_root(x) {
  return power(x, 0.5);
}
__name(square_root, "square_root");
function negate(x) {
  return -1 * x;
}
__name(negate, "negate");
function round(x) {
  let $ = x >= 0;
  if ($) {
    return round2(x);
  } else {
    return 0 - round2(negate(x));
  }
}
__name(round, "round");
function sum_loop(loop$numbers, loop$initial) {
  while (true) {
    let numbers = loop$numbers;
    let initial = loop$initial;
    if (numbers instanceof Empty) {
      return initial;
    } else {
      let first3 = numbers.head;
      let rest = numbers.tail;
      loop$numbers = rest;
      loop$initial = first3 + initial;
    }
  }
}
__name(sum_loop, "sum_loop");
function sum(numbers) {
  return sum_loop(numbers, 0);
}
__name(sum, "sum");
function add2(a, b) {
  return a + b;
}
__name(add2, "add");
function multiply(a, b) {
  return a * b;
}
__name(multiply, "multiply");
function subtract(a, b) {
  return a - b;
}
__name(subtract, "subtract");

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
function reverse(list3) {
  return reverse_and_prepend(list3, toList([]));
}
__name(reverse, "reverse");
function map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list3 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list3 instanceof Empty) {
      return reverse(acc);
    } else {
      let first$1 = list3.head;
      let rest$1 = list3.tail;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = prepend(fun(first$1), acc);
    }
  }
}
__name(map_loop, "map_loop");
function map2(list3, fun) {
  return map_loop(list3, fun, toList([]));
}
__name(map2, "map");
function append_loop(loop$first, loop$second) {
  while (true) {
    let first3 = loop$first;
    let second = loop$second;
    if (first3 instanceof Empty) {
      return second;
    } else {
      let first$1 = first3.head;
      let rest$1 = first3.tail;
      loop$first = rest$1;
      loop$second = prepend(first$1, second);
    }
  }
}
__name(append_loop, "append_loop");
function append2(first3, second) {
  return append_loop(reverse(first3), second);
}
__name(append2, "append");
function prepend2(list3, item) {
  return prepend(item, list3);
}
__name(prepend2, "prepend");
function fold2(loop$list, loop$initial, loop$fun) {
  while (true) {
    let list3 = loop$list;
    let initial = loop$initial;
    let fun = loop$fun;
    if (list3 instanceof Empty) {
      return initial;
    } else {
      let first$1 = list3.head;
      let rest$1 = list3.tail;
      loop$list = rest$1;
      loop$initial = fun(initial, first$1);
      loop$fun = fun;
    }
  }
}
__name(fold2, "fold");
function key_set_loop(loop$list, loop$key, loop$value, loop$inspected) {
  while (true) {
    let list3 = loop$list;
    let key = loop$key;
    let value = loop$value;
    let inspected = loop$inspected;
    if (list3 instanceof Empty) {
      return reverse(prepend([key, value], inspected));
    } else {
      let k = list3.head[0];
      if (isEqual(k, key)) {
        let rest$1 = list3.tail;
        return reverse_and_prepend(inspected, prepend([k, value], rest$1));
      } else {
        let first$1 = list3.head;
        let rest$1 = list3.tail;
        loop$list = rest$1;
        loop$key = key;
        loop$value = value;
        loop$inspected = prepend(first$1, inspected);
      }
    }
  }
}
__name(key_set_loop, "key_set_loop");
function key_set(list3, key, value) {
  return key_set_loop(list3, key, value, toList([]));
}
__name(key_set, "key_set");
function each(loop$list, loop$f) {
  while (true) {
    let list3 = loop$list;
    let f = loop$f;
    if (list3 instanceof Empty) {
      return void 0;
    } else {
      let first$1 = list3.head;
      let rest$1 = list3.tail;
      f(first$1);
      loop$list = rest$1;
      loop$f = f;
    }
  }
}
__name(each, "each");

// build/dev/javascript/gleam_stdlib/gleam/result.mjs
function map_error(result2, fun) {
  if (result2 instanceof Ok) {
    return result2;
  } else {
    let error = result2[0];
    return new Error2(fun(error));
  }
}
__name(map_error, "map_error");
function try$(result2, fun) {
  if (result2 instanceof Ok) {
    let x = result2[0];
    return fun(x);
  } else {
    return result2;
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
function json_to_string(json) {
  return JSON.stringify(json);
}
__name(json_to_string, "json_to_string");
function object(entries) {
  return Object.fromEntries(entries);
}
__name(object, "object");
function identity2(x) {
  return x;
}
__name(identity2, "identity");
function array(list3) {
  const array4 = [];
  while (List$isNonEmpty(list3)) {
    array4.push(List$NonEmpty$first(list3));
    list3 = List$NonEmpty$rest(list3);
  }
  return array4;
}
__name(array, "array");
function do_null() {
  return null;
}
__name(do_null, "do_null");
function decode(string4) {
  try {
    const result2 = JSON.parse(string4);
    return Result$Ok(result2);
  } catch (err) {
    return Result$Error(getJsonDecodeError(err, string4));
  }
}
__name(decode, "decode");
function getJsonDecodeError(stdErr, json) {
  if (isUnexpectedEndOfInput(stdErr)) return DecodeError$UnexpectedEndOfInput();
  return toUnexpectedByteError(stdErr, json);
}
__name(getJsonDecodeError, "getJsonDecodeError");
function isUnexpectedEndOfInput(err) {
  const unexpectedEndOfInputRegex = /((unexpected (end|eof))|(end of data)|(unterminated string)|(json( parse error|\.parse)\: expected '(\:|\}|\])'))/i;
  return unexpectedEndOfInputRegex.test(err.message);
}
__name(isUnexpectedEndOfInput, "isUnexpectedEndOfInput");
function toUnexpectedByteError(err, json) {
  let converters = [
    v8UnexpectedByteError,
    oldV8UnexpectedByteError,
    jsCoreUnexpectedByteError,
    spidermonkeyUnexpectedByteError
  ];
  for (let converter of converters) {
    let result2 = converter(err, json);
    if (result2) return result2;
  }
  return DecodeError$UnexpectedByte("");
}
__name(toUnexpectedByteError, "toUnexpectedByteError");
function v8UnexpectedByteError(err) {
  const regex = /unexpected token '(.)', ".+" is not valid JSON/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const byte = toHex(match[1]);
  return DecodeError$UnexpectedByte(byte);
}
__name(v8UnexpectedByteError, "v8UnexpectedByteError");
function oldV8UnexpectedByteError(err) {
  const regex = /unexpected token (.) in JSON at position (\d+)/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const byte = toHex(match[1]);
  return DecodeError$UnexpectedByte(byte);
}
__name(oldV8UnexpectedByteError, "oldV8UnexpectedByteError");
function spidermonkeyUnexpectedByteError(err, json) {
  const regex = /(unexpected character|expected .*) at line (\d+) column (\d+)/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const line = Number(match[2]);
  const column = Number(match[3]);
  const position = getPositionFromMultiline(line, column, json);
  const byte = toHex(json[position]);
  return DecodeError$UnexpectedByte(byte);
}
__name(spidermonkeyUnexpectedByteError, "spidermonkeyUnexpectedByteError");
function jsCoreUnexpectedByteError(err) {
  const regex = /unexpected (identifier|token) "(.)"/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const byte = toHex(match[2]);
  return DecodeError$UnexpectedByte(byte);
}
__name(jsCoreUnexpectedByteError, "jsCoreUnexpectedByteError");
function toHex(char) {
  return "0x" + char.charCodeAt(0).toString(16).toUpperCase();
}
__name(toHex, "toHex");
function getPositionFromMultiline(line, column, string4) {
  if (line === 1) return column - 1;
  let currentLn = 1;
  let position = 0;
  string4.split("").find((char, idx) => {
    if (char === "\n") currentLn += 1;
    if (currentLn === line) {
      position = idx + column;
      return true;
    }
    return false;
  });
  return position;
}
__name(getPositionFromMultiline, "getPositionFromMultiline");

// build/dev/javascript/gleam_json/gleam/json.mjs
var UnexpectedEndOfInput = class extends CustomType {
  static {
    __name(this, "UnexpectedEndOfInput");
  }
};
var DecodeError$UnexpectedEndOfInput = /* @__PURE__ */ __name(() => new UnexpectedEndOfInput(), "DecodeError$UnexpectedEndOfInput");
var UnexpectedByte = class extends CustomType {
  static {
    __name(this, "UnexpectedByte");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var DecodeError$UnexpectedByte = /* @__PURE__ */ __name(($0) => new UnexpectedByte($0), "DecodeError$UnexpectedByte");
var UnableToDecode = class extends CustomType {
  static {
    __name(this, "UnableToDecode");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function do_parse(json, decoder7) {
  return try$(
    decode(json),
    (dynamic_value) => {
      let _pipe = run(dynamic_value, decoder7);
      return map_error(
        _pipe,
        (var0) => {
          return new UnableToDecode(var0);
        }
      );
    }
  );
}
__name(do_parse, "do_parse");
function parse3(json, decoder7) {
  return do_parse(json, decoder7);
}
__name(parse3, "parse");
function to_string3(json) {
  return json_to_string(json);
}
__name(to_string3, "to_string");
function string3(input) {
  return identity2(input);
}
__name(string3, "string");
function int3(input) {
  return identity2(input);
}
__name(int3, "int");
function float3(input) {
  return identity2(input);
}
__name(float3, "float");
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
function preprocessed_array(from2) {
  return array(from2);
}
__name(preprocessed_array, "preprocessed_array");
function array2(entries, inner_type) {
  let _pipe = entries;
  let _pipe$1 = map2(_pipe, inner_type);
  return preprocessed_array(_pipe$1);
}
__name(array2, "array");

// build/dev/javascript/plinth_cloudflare/plinth_cloudflare_durable_object_ffi.mjs
function id_from_name(namespace, name2) {
  return namespace.idFromName(name2);
}
__name(id_from_name, "id_from_name");
function get2(namespace, id4, options) {
  return namespace.get(id4, options);
}
__name(get2, "get");
function stub_fetch(stub, request) {
  return stub.fetch(request);
}
__name(stub_fetch, "stub_fetch");
function storage(state) {
  return state.storage;
}
__name(storage, "storage");
function set_alarm(storage2, scheduled_time) {
  return storage2.setAlarm(scheduled_time);
}
__name(set_alarm, "set_alarm");
function new_websocket_pair() {
  return new WebSocketPair();
}
__name(new_websocket_pair, "new_websocket_pair");
function websocket_pair_client(pair2) {
  return pair2[0];
}
__name(websocket_pair_client, "websocket_pair_client");
function websocket_pair_server(pair2) {
  return pair2[1];
}
__name(websocket_pair_server, "websocket_pair_server");
function accept_websocket(state, websocket) {
  state.acceptWebSocket(websocket);
}
__name(accept_websocket, "accept_websocket");
function websocket_send(websocket, message) {
  websocket.send(message);
}
__name(websocket_send, "websocket_send");
function websocket_close(websocket, code, reason) {
  websocket.close(code, reason);
}
__name(websocket_close, "websocket_close");
function websocket_serialize_attachment(websocket, attachment) {
  websocket.serializeAttachment(attachment);
}
__name(websocket_serialize_attachment, "websocket_serialize_attachment");
function websocket_deserialize_attachment(websocket) {
  return websocket.deserializeAttachment();
}
__name(websocket_deserialize_attachment, "websocket_deserialize_attachment");

// build/dev/javascript/plinth_cloudflare/plinth/cloudflare/durable_object.mjs
function get3(namespace, id4, location_hint) {
  let options = nullable(
    location_hint,
    (hint) => {
      return object2(toList([["locationHint", string3(hint)]]));
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

// build/dev/javascript/server/server.mjs
function forward_to_stub(stub, request) {
  return stub_fetch(stub, request);
}
__name(forward_to_stub, "forward_to_stub");
function handle_websocket(js_request, env, room_id) {
  let $ = durable_object_namespace(env, "GAME_ROOM");
  if ($ instanceof Ok) {
    let namespace = $[0];
    let do_id = id_from_name(namespace, room_id);
    let stub = get3(namespace, do_id, new None());
    return forward_to_stub(stub, js_request);
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

// build/dev/javascript/gleam_time/gleam/time/duration.mjs
var Duration = class extends CustomType {
  static {
    __name(this, "Duration");
  }
  constructor(seconds3, nanoseconds2) {
    super();
    this.seconds = seconds3;
    this.nanoseconds = nanoseconds2;
  }
};
function normalise(duration) {
  let multiplier = 1e9;
  let nanoseconds$1 = remainderInt(duration.nanoseconds, multiplier);
  let overflow = duration.nanoseconds - nanoseconds$1;
  let seconds$1 = duration.seconds + divideInt(overflow, multiplier);
  let $ = nanoseconds$1 >= 0;
  if ($) {
    return new Duration(seconds$1, nanoseconds$1);
  } else {
    return new Duration(seconds$1 - 1, multiplier + nanoseconds$1);
  }
}
__name(normalise, "normalise");
function compare3(left, right) {
  let parts = /* @__PURE__ */ __name((x) => {
    let $2 = x.seconds >= 0;
    if ($2) {
      return [x.seconds, x.nanoseconds];
    } else {
      return [x.seconds * -1 - 1, 1e9 - x.nanoseconds];
    }
  }, "parts");
  let $ = parts(left);
  let ls;
  let lns;
  ls = $[0];
  lns = $[1];
  let $1 = parts(right);
  let rs;
  let rns;
  rs = $1[0];
  rns = $1[1];
  let _pipe = compare(ls, rs);
  return break_tie(_pipe, compare(lns, rns));
}
__name(compare3, "compare");
function add3(left, right) {
  let _pipe = new Duration(
    left.seconds + right.seconds,
    left.nanoseconds + right.nanoseconds
  );
  return normalise(_pipe);
}
__name(add3, "add");
function seconds2(amount) {
  return new Duration(amount, 0);
}
__name(seconds2, "seconds");
function milliseconds(amount) {
  let remainder = amount % 1e3;
  let overflow = amount - remainder;
  let nanoseconds$1 = remainder * 1e6;
  let seconds$1 = globalThis.Math.trunc(overflow / 1e3);
  let _pipe = new Duration(seconds$1, nanoseconds$1);
  return normalise(_pipe);
}
__name(milliseconds, "milliseconds");
function to_seconds(duration) {
  let seconds$1 = identity(duration.seconds);
  let nanoseconds$1 = identity(duration.nanoseconds);
  return seconds$1 + nanoseconds$1 / 1e9;
}
__name(to_seconds, "to_seconds");

// build/dev/javascript/gleam_time/gleam_time_ffi.mjs
function system_time() {
  const now2 = Date.now();
  const milliseconds2 = now2 % 1e3;
  const nanoseconds2 = milliseconds2 * 1e6;
  const seconds3 = (now2 - milliseconds2) / 1e3;
  return [seconds3, nanoseconds2];
}
__name(system_time, "system_time");

// build/dev/javascript/gleam_time/gleam/time/timestamp.mjs
var Timestamp = class extends CustomType {
  static {
    __name(this, "Timestamp");
  }
  constructor(seconds3, nanoseconds2) {
    super();
    this.seconds = seconds3;
    this.nanoseconds = nanoseconds2;
  }
};
function normalise2(timestamp2) {
  let multiplier = 1e9;
  let nanoseconds2 = remainderInt(timestamp2.nanoseconds, multiplier);
  let overflow = timestamp2.nanoseconds - nanoseconds2;
  let seconds3 = timestamp2.seconds + divideInt(overflow, multiplier);
  let $ = nanoseconds2 >= 0;
  if ($) {
    return new Timestamp(seconds3, nanoseconds2);
  } else {
    return new Timestamp(seconds3 - 1, multiplier + nanoseconds2);
  }
}
__name(normalise2, "normalise");
function system_time2() {
  let $ = system_time();
  let seconds3;
  let nanoseconds2;
  seconds3 = $[0];
  nanoseconds2 = $[1];
  return normalise2(new Timestamp(seconds3, nanoseconds2));
}
__name(system_time2, "system_time");
function from_unix_seconds(seconds3) {
  return new Timestamp(seconds3, 0);
}
__name(from_unix_seconds, "from_unix_seconds");
function to_unix_seconds(timestamp2) {
  let seconds3 = identity(timestamp2.seconds);
  let nanoseconds2 = identity(timestamp2.nanoseconds);
  return seconds3 + nanoseconds2 / 1e9;
}
__name(to_unix_seconds, "to_unix_seconds");
function to_unix_seconds_and_nanoseconds(timestamp2) {
  return [timestamp2.seconds, timestamp2.nanoseconds];
}
__name(to_unix_seconds_and_nanoseconds, "to_unix_seconds_and_nanoseconds");

// build/dev/javascript/plinth_cloudflare/plinth_cloudflare_response_ffi.mjs
function is_websocket_upgrade(request) {
  return request.headers.get("Upgrade") === "websocket";
}
__name(is_websocket_upgrade, "is_websocket_upgrade");
function websocket_upgrade_response(client) {
  return Promise.resolve(new Response(null, {
    status: 101,
    webSocket: client
  }));
}
__name(websocket_upgrade_response, "websocket_upgrade_response");
function error_response(status2, message) {
  return Promise.resolve(new Response(message, { status: status2 }));
}
__name(error_response, "error_response");

// build/dev/javascript/vec/vec/vec3.mjs
var Vec3 = class extends CustomType {
  static {
    __name(this, "Vec3");
  }
  constructor(x, y, z) {
    super();
    this.x = x;
    this.y = y;
    this.z = z;
  }
};
function to_list2(vector) {
  return toList([vector.x, vector.y, vector.z]);
}
__name(to_list2, "to_list");
function map7(vector, fun) {
  return new Vec3(fun(vector.x), fun(vector.y), fun(vector.z));
}
__name(map7, "map");
function map22(a, b, fun) {
  return new Vec3(fun(a.x, b.x), fun(a.y, b.y), fun(a.z, b.z));
}
__name(map22, "map2");

// build/dev/javascript/shared/shared/health.mjs
var Health = class extends CustomType {
  static {
    __name(this, "Health");
  }
  constructor(current, max2) {
    super();
    this.current = current;
    this.max = max2;
  }
};
function new$2(max2) {
  return new Health(max2, max2);
}
__name(new$2, "new$");
function encode(health) {
  return object2(
    toList([
      ["current", float3(health.current)],
      ["max", float3(health.max)]
    ])
  );
}
__name(encode, "encode");

// build/dev/javascript/shared/shared/vec3.mjs
function encode2(v) {
  return object2(
    toList([
      ["x", float3(v.x)],
      ["y", float3(v.y)],
      ["z", float3(v.z)]
    ])
  );
}
__name(encode2, "encode");
function decoder() {
  return field(
    "x",
    float2,
    (x) => {
      return field(
        "y",
        float2,
        (y) => {
          return field(
            "z",
            float2,
            (z) => {
              return success(new Vec3(x, y, z));
            }
          );
        }
      );
    }
  );
}
__name(decoder, "decoder");

// build/dev/javascript/gleam_community_maths/maths.mjs
function sin(float4) {
  return Math.sin(float4);
}
__name(sin, "sin");
function pi() {
  return Math.PI;
}
__name(pi, "pi");
function cos(float4) {
  return Math.cos(float4);
}
__name(cos, "cos");

// build/dev/javascript/gleam_community_maths/gleam_community/maths.mjs
function cos2(x) {
  return cos(x);
}
__name(cos2, "cos");
function sin2(x) {
  return sin(x);
}
__name(sin2, "sin");
function pi2() {
  return pi();
}
__name(pi2, "pi");

// build/dev/javascript/iv/iv/internal/constants.mjs
var error_nil = /* @__PURE__ */ new Error2(void 0);

// build/dev/javascript/iv/iv_ffi.mjs
var singleton = /* @__PURE__ */ __name((x) => [x], "singleton");
var pair = /* @__PURE__ */ __name((x, y) => [x, y], "pair");
var append3 = /* @__PURE__ */ __name((xs, x) => [...xs, x], "append");
var prepend3 = /* @__PURE__ */ __name((xs, x) => [x, ...xs], "prepend");
var concat4 = /* @__PURE__ */ __name((xs, ys) => [...xs, ...ys], "concat");
var get1 = /* @__PURE__ */ __name((idx, xs) => xs[idx - 1], "get1");
var set1 = /* @__PURE__ */ __name((idx, xs, x) => xs.with(idx - 1, x), "set1");
var length4 = /* @__PURE__ */ __name((xs) => xs.length, "length");
var map9 = /* @__PURE__ */ __name((xs, f) => xs.map(f), "map");
var bsl = /* @__PURE__ */ __name((a, b) => a << b, "bsl");
var bsr = /* @__PURE__ */ __name((a, b) => a >> b, "bsr");

// build/dev/javascript/iv/iv/internal/vector.mjs
function map_add(xs, delta) {
  return map9(xs, (x) => {
    return x + delta;
  });
}
__name(map_add, "map_add");
function fold_loop(loop$xs, loop$state, loop$idx, loop$len, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let state = loop$state;
    let idx = loop$idx;
    let len = loop$len;
    let fun = loop$fun;
    let $ = idx <= len;
    if ($) {
      loop$xs = xs;
      loop$state = fun(state, get1(idx, xs));
      loop$idx = idx + 1;
      loop$len = len;
      loop$fun = fun;
    } else {
      return state;
    }
  }
}
__name(fold_loop, "fold_loop");
function fold4(xs, state, fun) {
  let len = length4(xs);
  return fold_loop(xs, state, 1, len, fun);
}
__name(fold4, "fold");
function fold_skip_first(xs, state, fun) {
  let len = length4(xs);
  return fold_loop(xs, state, 2, len, fun);
}
__name(fold_skip_first, "fold_skip_first");

// build/dev/javascript/iv/iv/internal/node.mjs
var Balanced = class extends CustomType {
  static {
    __name(this, "Balanced");
  }
  constructor(size5, children) {
    super();
    this.size = size5;
    this.children = children;
  }
};
var Unbalanced = class extends CustomType {
  static {
    __name(this, "Unbalanced");
  }
  constructor(sizes, children) {
    super();
    this.sizes = sizes;
    this.children = children;
  }
};
var Leaf = class extends CustomType {
  static {
    __name(this, "Leaf");
  }
  constructor(children) {
    super();
    this.children = children;
  }
};
var Concatenated = class extends CustomType {
  static {
    __name(this, "Concatenated");
  }
  constructor(merged) {
    super();
    this.merged = merged;
  }
};
var NoFreeSlot = class extends CustomType {
  static {
    __name(this, "NoFreeSlot");
  }
  constructor(left, right) {
    super();
    this.left = left;
    this.right = right;
  }
};
var branch_bits = 5;
var branch_factor = 32;
function size3(node) {
  if (node instanceof Balanced) {
    let size$1 = node.size;
    return size$1;
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    return get1(length4(sizes), sizes);
  } else {
    let children = node.children;
    return length4(children);
  }
}
__name(size3, "size");
function compute_sizes(nodes) {
  let first_size = size3(get1(1, nodes));
  return fold_skip_first(
    nodes,
    singleton(first_size),
    (sizes, node) => {
      let size$1 = get1(length4(sizes), sizes) + size3(node);
      return append3(sizes, size$1);
    }
  );
}
__name(compute_sizes, "compute_sizes");
function find_size(loop$sizes, loop$size_idx_plus_one, loop$index) {
  while (true) {
    let sizes = loop$sizes;
    let size_idx_plus_one = loop$size_idx_plus_one;
    let index5 = loop$index;
    let $ = get1(size_idx_plus_one, sizes) > index5;
    if ($) {
      return size_idx_plus_one - 1;
    } else {
      loop$sizes = sizes;
      loop$size_idx_plus_one = size_idx_plus_one + 1;
      loop$index = index5;
    }
  }
}
__name(find_size, "find_size");
function fold5(node, state, fun) {
  if (node instanceof Balanced) {
    let children = node.children;
    return fold4(
      children,
      state,
      (state2, node2) => {
        return fold5(node2, state2, fun);
      }
    );
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return fold4(
      children,
      state,
      (state2, node2) => {
        return fold5(node2, state2, fun);
      }
    );
  } else {
    let children = node.children;
    return fold4(children, state, fun);
  }
}
__name(fold5, "fold");
function balanced(shift, nodes) {
  let len = length4(nodes);
  let last_child = get1(len, nodes);
  let max_size = bsl(1, shift);
  let size$1 = max_size * (len - 1) + size3(last_child);
  return new Balanced(size$1, nodes);
}
__name(balanced, "balanced");
function branch(shift, nodes) {
  let len = length4(nodes);
  let max_size = bsl(1, shift);
  let sizes = compute_sizes(nodes);
  let _block;
  if (len === 1) {
    _block = 0;
  } else {
    _block = get1(len - 1, sizes);
  }
  let prefix_size = _block;
  let is_balanced = prefix_size === max_size * (len - 1);
  if (is_balanced) {
    let size$1 = get1(len, sizes);
    return new Balanced(size$1, nodes);
  } else {
    return new Unbalanced(sizes, nodes);
  }
}
__name(branch, "branch");
function get7(loop$node, loop$shift, loop$index) {
  while (true) {
    let node = loop$node;
    let shift = loop$shift;
    let index5 = loop$index;
    if (node instanceof Balanced) {
      let children = node.children;
      let node_index = bsr(index5, shift);
      let index$1 = index5 - bsl(node_index, shift);
      let child = get1(node_index + 1, children);
      loop$node = child;
      loop$shift = shift - branch_bits;
      loop$index = index$1;
    } else if (node instanceof Unbalanced) {
      let sizes = node.sizes;
      let children = node.children;
      let start_search_index = bsr(index5, shift);
      let node_index = find_size(sizes, start_search_index + 1, index5);
      let _block;
      if (node_index === 0) {
        _block = index5;
      } else {
        _block = index5 - get1(node_index, sizes);
      }
      let index$1 = _block;
      let child = get1(node_index + 1, children);
      loop$node = child;
      loop$shift = shift - branch_bits;
      loop$index = index$1;
    } else {
      let children = node.children;
      return get1(index5 + 1, children);
    }
  }
}
__name(get7, "get");
function direct_append_balanced(left_shift, left, left_children, right_shift, right) {
  let left_len = length4(left_children);
  let left_last = get1(left_len, left_children);
  let $ = direct_concat(left_shift - branch_bits, left_last, right_shift, right);
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = set1(left_len, left_children, updated);
    return new Concatenated(balanced(left_shift, children));
  } else if (left_len < 32) {
    let node = $.right;
    let children = append3(left_children, node);
    let $1 = size3(left_last) === bsl(1, left_shift);
    if ($1) {
      return new Concatenated(balanced(left_shift, children));
    } else {
      return new Concatenated(branch(left_shift, children));
    }
  } else {
    let node = $.right;
    return new NoFreeSlot(left, balanced(left_shift, singleton(node)));
  }
}
__name(direct_append_balanced, "direct_append_balanced");
function direct_concat(left_shift, left, right_shift, right) {
  if (left instanceof Balanced) {
    if (right instanceof Balanced) {
      if (left_shift > right_shift) {
        let cl = left.children;
        return direct_append_balanced(left_shift, left, cl, right_shift, right);
      } else if (right_shift > left_shift) {
        let cr = right.children;
        return direct_prepend_balanced(left_shift, left, right_shift, right, cr);
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = length4(cl) + length4(cr) <= branch_factor;
        if ($) {
          let merged = concat4(cl, cr);
          let left_last = get1(length4(cl), cl);
          let $1 = size3(left_last) === bsl(1, left_shift);
          if ($1) {
            return new Concatenated(balanced(left_shift, merged));
          } else {
            return new Concatenated(branch(left_shift, merged));
          }
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else if (right instanceof Unbalanced) {
      if (left_shift > right_shift) {
        let cl = left.children;
        return direct_append_balanced(left_shift, left, cl, right_shift, right);
      } else if (right_shift > left_shift) {
        let sr = right.sizes;
        let cr = right.children;
        return direct_prepend_unbalanced(
          left_shift,
          left,
          right_shift,
          right,
          cr,
          sr
        );
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = length4(cl) + length4(cr) <= branch_factor;
        if ($) {
          return new Concatenated(branch(left_shift, concat4(cl, cr)));
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else {
      let cl = left.children;
      return direct_append_balanced(left_shift, left, cl, right_shift, right);
    }
  } else if (left instanceof Unbalanced) {
    if (right instanceof Balanced) {
      if (left_shift > right_shift) {
        let sizes = left.sizes;
        let cl = left.children;
        return direct_append_unbalanced(
          left_shift,
          left,
          cl,
          sizes,
          right_shift,
          right
        );
      } else if (right_shift > left_shift) {
        let cr = right.children;
        return direct_prepend_balanced(left_shift, left, right_shift, right, cr);
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = length4(cl) + length4(cr) <= branch_factor;
        if ($) {
          return new Concatenated(branch(left_shift, concat4(cl, cr)));
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else if (right instanceof Unbalanced) {
      if (left_shift > right_shift) {
        let sizes = left.sizes;
        let cl = left.children;
        return direct_append_unbalanced(
          left_shift,
          left,
          cl,
          sizes,
          right_shift,
          right
        );
      } else if (right_shift > left_shift) {
        let sr = right.sizes;
        let cr = right.children;
        return direct_prepend_unbalanced(
          left_shift,
          left,
          right_shift,
          right,
          cr,
          sr
        );
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = length4(cl) + length4(cr) <= branch_factor;
        if ($) {
          return new Concatenated(branch(left_shift, concat4(cl, cr)));
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else {
      let sizes = left.sizes;
      let cl = left.children;
      return direct_append_unbalanced(
        left_shift,
        left,
        cl,
        sizes,
        right_shift,
        right
      );
    }
  } else if (right instanceof Balanced) {
    let cr = right.children;
    return direct_prepend_balanced(left_shift, left, right_shift, right, cr);
  } else if (right instanceof Unbalanced) {
    let sr = right.sizes;
    let cr = right.children;
    return direct_prepend_unbalanced(
      left_shift,
      left,
      right_shift,
      right,
      cr,
      sr
    );
  } else {
    let cl = left.children;
    let cr = right.children;
    let $ = length4(cl) + length4(cr) <= branch_factor;
    if ($) {
      return new Concatenated(new Leaf(concat4(cl, cr)));
    } else {
      return new NoFreeSlot(left, right);
    }
  }
}
__name(direct_concat, "direct_concat");
function direct_append_unbalanced(left_shift, left, left_children, sizes, right_shift, right) {
  let left_len = length4(left_children);
  let left_last = get1(left_len, left_children);
  let $ = direct_concat(left_shift - branch_bits, left_last, right_shift, right);
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = set1(left_len, left_children, updated);
    let last_size = get1(left_len, sizes) + size3(updated);
    let sizes$1 = set1(left_len, sizes, last_size);
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else if (left_len < 32) {
    let node = $.right;
    let children = append3(left_children, node);
    let sizes$1 = append3(
      sizes,
      get1(left_len, sizes) + size3(node)
    );
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else {
    let node = $.right;
    return new NoFreeSlot(left, balanced(left_shift, singleton(node)));
  }
}
__name(direct_append_unbalanced, "direct_append_unbalanced");
function direct_prepend_balanced(left_shift, left, right_shift, right, right_children) {
  let right_len = length4(right_children);
  let right_first = get1(1, right_children);
  let $ = direct_concat(
    left_shift,
    left,
    right_shift - branch_bits,
    right_first
  );
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = set1(1, right_children, updated);
    return new Concatenated(branch(right_shift, children));
  } else if (right_len < 32) {
    let node = $.left;
    let children = prepend3(right_children, node);
    return new Concatenated(branch(right_shift, children));
  } else {
    let node = $.left;
    return new NoFreeSlot(balanced(right_shift, singleton(node)), right);
  }
}
__name(direct_prepend_balanced, "direct_prepend_balanced");
function direct_prepend_unbalanced(left_shift, left, right_shift, right, right_children, sizes) {
  let right_len = length4(right_children);
  let right_first = get1(1, right_children);
  let $ = direct_concat(
    left_shift,
    left,
    right_shift - branch_bits,
    right_first
  );
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = set1(1, right_children, updated);
    let size_delta = size3(updated) - size3(right_first);
    let sizes$1 = map_add(sizes, size_delta);
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else if (right_len < 32) {
    let node = $.left;
    let children = prepend3(right_children, node);
    let node_size = size3(node);
    let _block;
    let _pipe = sizes;
    let _pipe$1 = map_add(_pipe, node_size);
    _block = prepend3(_pipe$1, node_size);
    let sizes$1 = _block;
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else {
    let node = $.left;
    return new NoFreeSlot(balanced(right_shift, singleton(node)), right);
  }
}
__name(direct_prepend_unbalanced, "direct_prepend_unbalanced");

// build/dev/javascript/iv/iv.mjs
var Empty2 = class extends CustomType {
  static {
    __name(this, "Empty");
  }
};
var Array2 = class extends CustomType {
  static {
    __name(this, "Array");
  }
  constructor(shift, root) {
    super();
    this.shift = shift;
    this.root = root;
  }
};
function array3(shift, nodes) {
  let $ = length4(nodes);
  if ($ === 0) {
    return new Empty2();
  } else if ($ === 1) {
    return new Array2(shift, get1(1, nodes));
  } else {
    let shift$1 = shift + branch_bits;
    return new Array2(shift$1, branch(shift$1, nodes));
  }
}
__name(array3, "array");
function new$6() {
  return new Empty2();
}
__name(new$6, "new$");
function wrap(item) {
  return new Array2(0, new Leaf(singleton(item)));
}
__name(wrap, "wrap");
function size4(array4) {
  if (array4 instanceof Empty2) {
    return 0;
  } else {
    let root = array4.root;
    return size3(root);
  }
}
__name(size4, "size");
function get8(array4, index5) {
  if (array4 instanceof Empty2) {
    return error_nil;
  } else {
    let shift = array4.shift;
    let root = array4.root;
    let $ = 0 <= index5 && index5 < size3(root);
    if ($) {
      return new Ok(get7(root, shift, index5));
    } else {
      return error_nil;
    }
  }
}
__name(get8, "get");
function direct_concat2(left, right) {
  if (left instanceof Empty2) {
    return right;
  } else if (right instanceof Empty2) {
    return left;
  } else {
    let left_shift = left.shift;
    let left$1 = left.root;
    let right_shift = right.shift;
    let right$1 = right.root;
    let _block;
    let $ = left_shift > right_shift;
    if ($) {
      _block = left_shift;
    } else {
      _block = right_shift;
    }
    let shift = _block;
    let $1 = direct_concat(left_shift, left$1, right_shift, right$1);
    if ($1 instanceof Concatenated) {
      let root = $1.merged;
      return new Array2(shift, root);
    } else {
      let left$2 = $1.left;
      let right$2 = $1.right;
      return array3(shift, pair(left$2, right$2));
    }
  }
}
__name(direct_concat2, "direct_concat");
function append4(array4, item) {
  return direct_concat2(array4, wrap(item));
}
__name(append4, "append");
function prepend4(array4, item) {
  return direct_concat2(wrap(item), array4);
}
__name(prepend4, "prepend");
function fold7(array4, state, fun) {
  if (array4 instanceof Empty2) {
    return state;
  } else {
    let root = array4.root;
    return fold5(root, state, fun);
  }
}
__name(fold7, "fold");

// build/dev/javascript/vec/vec/vec3f.mjs
var FILEPATH = "src/vec/vec3f.gleam";
function add4(a, b) {
  let _pipe = a;
  return map22(_pipe, b, add2);
}
__name(add4, "add");
function subtract2(a, b) {
  let _pipe = a;
  return map22(_pipe, b, subtract);
}
__name(subtract2, "subtract");
function length_squared(vector) {
  let _pipe = vector;
  let _pipe$1 = to_list2(_pipe);
  let _pipe$2 = map2(_pipe$1, (element) => {
    return element * element;
  });
  return sum(_pipe$2);
}
__name(length_squared, "length_squared");
function length5(vector) {
  let _block;
  let _pipe = vector;
  let _pipe$1 = length_squared(_pipe);
  _block = square_root(_pipe$1);
  let $ = _block;
  let length$1;
  if ($ instanceof Ok) {
    length$1 = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "vec/vec3f",
      324,
      "length",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 7053,
        end: 7126,
        pattern_start: 7064,
        pattern_end: 7074
      }
    );
  }
  return length$1;
}
__name(length5, "length");
function distance_squared(a, b) {
  let _pipe = a;
  let _pipe$1 = map22(_pipe, b, subtract);
  return length_squared(_pipe$1);
}
__name(distance_squared, "distance_squared");
function distance(a, b) {
  let _block;
  let _pipe = distance_squared(a, b);
  _block = square_root(_pipe);
  let $ = _block;
  let distance$1;
  if ($ instanceof Ok) {
    distance$1 = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "vec/vec3f",
      391,
      "distance",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 8626,
        end: 8697,
        pattern_start: 8637,
        pattern_end: 8649
      }
    );
  }
  return distance$1;
}
__name(distance, "distance");
function scale(vector, scalar) {
  let _pipe = vector;
  return map7(
    _pipe,
    (_capture) => {
      return multiply(_capture, scalar);
    }
  );
}
__name(scale, "scale");
function normalize(vector) {
  let _pipe = vector;
  return scale(
    _pipe,
    divideFloat(
      1,
      (() => {
        let _pipe$1 = vector;
        return length5(_pipe$1);
      })()
    )
  );
}
__name(normalize, "normalize");
function direction(a, b) {
  let _pipe = b;
  let _pipe$1 = subtract2(_pipe, a);
  return normalize(_pipe$1);
}
__name(direction, "direction");

// build/dev/javascript/shared/shared/spell.mjs
var DamageSpell = class extends CustomType {
  static {
    __name(this, "DamageSpell");
  }
  constructor(id4, ui_sprite, kind) {
    super();
    this.id = id4;
    this.ui_sprite = ui_sprite;
    this.kind = kind;
  }
};
var ModifierSpell = class extends CustomType {
  static {
    __name(this, "ModifierSpell");
  }
  constructor(id4, ui_sprite, kind) {
    super();
    this.id = id4;
    this.ui_sprite = ui_sprite;
    this.kind = kind;
  }
};
var Projectile = class extends CustomType {
  static {
    __name(this, "Projectile");
  }
  constructor(id4, spell, position, direction2, time_alive, visuals, trigger_payload) {
    super();
    this.id = id4;
    this.spell = spell;
    this.position = position;
    this.direction = direction2;
    this.time_alive = time_alive;
    this.visuals = visuals;
    this.trigger_payload = trigger_payload;
  }
};
var ModifiedSpell = class extends CustomType {
  static {
    __name(this, "ModifiedSpell");
  }
  constructor(base, final_damage, final_speed, final_size, final_lifetime, final_cast_delay, final_recharge_time, final_critical_chance, final_spread, total_mana_cost) {
    super();
    this.base = base;
    this.final_damage = final_damage;
    this.final_speed = final_speed;
    this.final_size = final_size;
    this.final_lifetime = final_lifetime;
    this.final_cast_delay = final_cast_delay;
    this.final_recharge_time = final_recharge_time;
    this.final_critical_chance = final_critical_chance;
    this.final_spread = final_spread;
    this.total_mana_cost = total_mana_cost;
  }
};
function apply_additive_modifiers(base_spell, modifiers) {
  return fold7(
    modifiers,
    [
      base_spell.damage,
      base_spell.projectile_speed,
      base_spell.projectile_size,
      base_spell.projectile_lifetime,
      base_spell.cast_delay_addition,
      milliseconds(0),
      base_spell.critical_chance,
      base_spell.spread
    ],
    (acc, mod) => {
      let damage;
      let speed;
      let size5;
      let lifetime;
      let cast_delay;
      let recharge_time;
      let crit_chance;
      let spread;
      damage = acc[0];
      speed = acc[1];
      size5 = acc[2];
      lifetime = acc[3];
      cast_delay = acc[4];
      recharge_time = acc[5];
      crit_chance = acc[6];
      spread = acc[7];
      return [
        damage + mod.damage_addition,
        speed + mod.projectile_speed_addition,
        size5 + mod.projectile_size_addition,
        add3(lifetime, mod.projectile_lifetime_addition),
        add3(cast_delay, mod.cast_delay_addition),
        add3(recharge_time, mod.recharge_addition),
        crit_chance + mod.critical_chance_addition,
        spread + mod.spread_addition
      ];
    }
  );
}
__name(apply_additive_modifiers, "apply_additive_modifiers");
function apply_multiplicative_modifiers(stats, base_mana_cost, modifiers) {
  let damage;
  let speed;
  let size5;
  let lifetime;
  let cast_delay;
  let recharge_time;
  let crit_chance;
  let spread;
  damage = stats[0];
  speed = stats[1];
  size5 = stats[2];
  lifetime = stats[3];
  cast_delay = stats[4];
  recharge_time = stats[5];
  crit_chance = stats[6];
  spread = stats[7];
  return fold7(
    modifiers,
    [
      damage,
      speed,
      size5,
      lifetime,
      cast_delay,
      recharge_time,
      crit_chance,
      spread,
      base_mana_cost
    ],
    (acc, mod) => {
      let damage$1;
      let speed$1;
      let size$1;
      let lifetime$1;
      let cast_delay$1;
      let recharge_time$1;
      let crit_chance$1;
      let spread$1;
      let mana_cost;
      damage$1 = acc[0];
      speed$1 = acc[1];
      size$1 = acc[2];
      lifetime$1 = acc[3];
      cast_delay$1 = acc[4];
      recharge_time$1 = acc[5];
      crit_chance$1 = acc[6];
      spread$1 = acc[7];
      mana_cost = acc[8];
      return [
        damage$1 * mod.damage_multiplier,
        speed$1 * mod.projectile_speed_multiplier,
        size$1 * mod.projectile_size_multiplier,
        (() => {
          let _pipe = lifetime$1;
          let _pipe$1 = to_seconds(_pipe);
          let _pipe$2 = multiply(
            _pipe$1,
            mod.projectile_lifetime_multiplier
          );
          let _pipe$3 = multiply(_pipe$2, 1e3);
          let _pipe$4 = round(_pipe$3);
          return milliseconds(_pipe$4);
        })(),
        (() => {
          let _pipe = cast_delay$1;
          let _pipe$1 = to_seconds(_pipe);
          let _pipe$2 = multiply(_pipe$1, mod.cast_delay_multiplier);
          let _pipe$3 = multiply(_pipe$2, 1e3);
          let _pipe$4 = round(_pipe$3);
          return milliseconds(_pipe$4);
        })(),
        (() => {
          let _pipe = recharge_time$1;
          let _pipe$1 = to_seconds(_pipe);
          let _pipe$2 = multiply(_pipe$1, mod.recharge_multiplier);
          let _pipe$3 = multiply(_pipe$2, 1e3);
          let _pipe$4 = round(_pipe$3);
          return milliseconds(_pipe$4);
        })(),
        crit_chance$1 * mod.critical_chance_multiplier,
        spread$1 * mod.spread_multiplier,
        mana_cost + mod.mana_cost
      ];
    }
  );
}
__name(apply_multiplicative_modifiers, "apply_multiplicative_modifiers");
function apply_modifiers(id4, ui_sprite, spell, modifiers) {
  let after_additions = apply_additive_modifiers(spell, modifiers);
  let $ = apply_multiplicative_modifiers(
    after_additions,
    spell.mana_cost,
    modifiers
  );
  let final_damage;
  let final_speed;
  let final_size;
  let final_lifetime;
  let final_cast_delay;
  let final_recharge_time;
  let final_critical_chance;
  let final_spread;
  let total_mana_cost;
  final_damage = $[0];
  final_speed = $[1];
  final_size = $[2];
  final_lifetime = $[3];
  final_cast_delay = $[4];
  final_recharge_time = $[5];
  final_critical_chance = $[6];
  final_spread = $[7];
  total_mana_cost = $[8];
  return new ModifiedSpell(
    new DamageSpell(id4, ui_sprite, spell),
    final_damage,
    final_speed,
    final_size,
    final_lifetime,
    final_cast_delay,
    final_recharge_time,
    final_critical_chance,
    final_spread,
    total_mana_cost
  );
}
__name(apply_modifiers, "apply_modifiers");

// build/dev/javascript/shared/shared/wand.mjs
var Wand = class extends CustomType {
  static {
    __name(this, "Wand");
  }
  constructor(name2, slots, max_mana, current_mana, mana_recharge_rate, cast_delay, recharge_time, spells_per_cast, spread) {
    super();
    this.name = name2;
    this.slots = slots;
    this.max_mana = max_mana;
    this.current_mana = current_mana;
    this.mana_recharge_rate = mana_recharge_rate;
    this.cast_delay = cast_delay;
    this.recharge_time = recharge_time;
    this.spells_per_cast = spells_per_cast;
    this.spread = spread;
  }
};
var CastSuccess = class extends CustomType {
  static {
    __name(this, "CastSuccess");
  }
  constructor(projectiles, remaining_mana, next_cast_index, casting_indices, did_wrap, total_cast_delay_addition, total_recharge_time_addition) {
    super();
    this.projectiles = projectiles;
    this.remaining_mana = remaining_mana;
    this.next_cast_index = next_cast_index;
    this.casting_indices = casting_indices;
    this.did_wrap = did_wrap;
    this.total_cast_delay_addition = total_cast_delay_addition;
    this.total_recharge_time_addition = total_recharge_time_addition;
  }
};
var NotEnoughMana = class extends CustomType {
  static {
    __name(this, "NotEnoughMana");
  }
  constructor(required, available) {
    super();
    this.required = required;
    this.available = available;
  }
};
var NoSpellToCast = class extends CustomType {
  static {
    __name(this, "NoSpellToCast");
  }
};
var WandEmpty = class extends CustomType {
  static {
    __name(this, "WandEmpty");
  }
};
var CastContext = class extends CustomType {
  static {
    __name(this, "CastContext");
  }
  constructor(position, direction2, target_position, player_center, existing_projectiles, projectile_starting_index) {
    super();
    this.position = position;
    this.direction = direction2;
    this.target_position = target_position;
    this.player_center = player_center;
    this.existing_projectiles = existing_projectiles;
    this.projectile_starting_index = projectile_starting_index;
  }
};
var CastState = class extends CustomType {
  static {
    __name(this, "CastState");
  }
  constructor(current_index, remaining_draw, accumulated_modifiers, projectiles, casting_indices, total_mana_used, total_cast_delay_addition, total_recharge_time_addition, projectile_id, wrapped_during_cast, original_start_index, spells_per_cast) {
    super();
    this.current_index = current_index;
    this.remaining_draw = remaining_draw;
    this.accumulated_modifiers = accumulated_modifiers;
    this.projectiles = projectiles;
    this.casting_indices = casting_indices;
    this.total_mana_used = total_mana_used;
    this.total_cast_delay_addition = total_cast_delay_addition;
    this.total_recharge_time_addition = total_recharge_time_addition;
    this.projectile_id = projectile_id;
    this.wrapped_during_cast = wrapped_during_cast;
    this.original_start_index = original_start_index;
    this.spells_per_cast = spells_per_cast;
  }
};
function is_index_wrapped(index5, wand_length) {
  return index5 >= wand_length;
}
__name(is_index_wrapped, "is_index_wrapped");
function has_completed_cycle(current_index, original_start_index, wand_length, wrapped_flag) {
  let wrapped_index = remainderInt(current_index, wand_length);
  return wrapped_flag && wrapped_index >= original_start_index;
}
__name(has_completed_cycle, "has_completed_cycle");
function check_mana_sufficient(wand, current_mana_used, additional_cost) {
  let new_total = current_mana_used + additional_cost;
  let $ = wand.current_mana >= new_total;
  if ($) {
    return new Ok(new_total);
  } else {
    return new Error2([new_total, wand.current_mana]);
  }
}
__name(check_mana_sufficient, "check_mana_sufficient");
function advance_to_next_slot(state, wrapped_index, wrapped_flag) {
  return new CastState(
    state.current_index + 1,
    state.remaining_draw,
    state.accumulated_modifiers,
    state.projectiles,
    prepend(wrapped_index, state.casting_indices),
    state.total_mana_used,
    state.total_cast_delay_addition,
    state.total_recharge_time_addition,
    state.projectile_id,
    wrapped_flag,
    state.original_start_index,
    state.spells_per_cast
  );
}
__name(advance_to_next_slot, "advance_to_next_slot");
function has_trigger_modifier(modifiers) {
  return fold7(
    modifiers,
    false,
    (acc, mod) => {
      return acc || mod.adds_trigger;
    }
  );
}
__name(has_trigger_modifier, "has_trigger_modifier");
function collect_indices_loop(loop$current, loop$end, loop$wand_length, loop$acc) {
  while (true) {
    let current = loop$current;
    let end = loop$end;
    let wand_length = loop$wand_length;
    let acc = loop$acc;
    let $ = current > end;
    if ($) {
      return reverse(acc);
    } else {
      let wrapped_index = remainderInt(current, wand_length);
      loop$current = current + 1;
      loop$end = end;
      loop$wand_length = wand_length;
      loop$acc = prepend(wrapped_index, acc);
    }
  }
}
__name(collect_indices_loop, "collect_indices_loop");
function collect_indices_between(start_index, end_index, wand_length) {
  return collect_indices_loop(start_index, end_index, wand_length, toList([]));
}
__name(collect_indices_between, "collect_indices_between");
function collect_modifiers_loop(loop$slots, loop$current, loop$end, loop$wand_length, loop$acc) {
  while (true) {
    let slots = loop$slots;
    let current = loop$current;
    let end = loop$end;
    let wand_length = loop$wand_length;
    let acc = loop$acc;
    let $ = current >= end;
    if ($) {
      return acc;
    } else {
      let wrapped_index = remainderInt(current, wand_length);
      let _block;
      let $1 = get8(slots, wrapped_index);
      if ($1 instanceof Ok) {
        let $2 = $1[0];
        if ($2 instanceof Some) {
          let $3 = $2[0];
          if ($3 instanceof ModifierSpell) {
            let kind = $3.kind;
            _block = append4(acc, kind);
          } else {
            _block = acc;
          }
        } else {
          _block = acc;
        }
      } else {
        _block = acc;
      }
      let new_acc = _block;
      loop$slots = slots;
      loop$current = current + 1;
      loop$end = end;
      loop$wand_length = wand_length;
      loop$acc = new_acc;
    }
  }
}
__name(collect_modifiers_loop, "collect_modifiers_loop");
function collect_modifiers_between(slots, start_index, end_index, wand_length) {
  return collect_modifiers_loop(
    slots,
    start_index,
    end_index,
    wand_length,
    new$6()
  );
}
__name(collect_modifiers_between, "collect_modifiers_between");
function find_next_damage_spell_loop(loop$slots, loop$current_index, loop$original_start, loop$length, loop$iterations) {
  while (true) {
    let slots = loop$slots;
    let current_index = loop$current_index;
    let original_start = loop$original_start;
    let length6 = loop$length;
    let iterations = loop$iterations;
    let $ = iterations >= length6;
    if ($) {
      return new Error2(void 0);
    } else {
      let wrapped_index = remainderInt(current_index, length6);
      let is_wrapped = current_index >= length6;
      let would_go_backwards = is_wrapped && wrapped_index <= original_start;
      if (would_go_backwards) {
        return new Error2(void 0);
      } else {
        let $1 = get8(slots, wrapped_index);
        if ($1 instanceof Ok) {
          let $2 = $1[0];
          if ($2 instanceof Some) {
            let $3 = $2[0];
            if ($3 instanceof DamageSpell) {
              let id4 = $3.id;
              let ui_sprite = $3.ui_sprite;
              let kind = $3.kind;
              return new Ok([id4, ui_sprite, kind, current_index]);
            } else {
              loop$slots = slots;
              loop$current_index = current_index + 1;
              loop$original_start = original_start;
              loop$length = length6;
              loop$iterations = iterations + 1;
            }
          } else {
            loop$slots = slots;
            loop$current_index = current_index + 1;
            loop$original_start = original_start;
            loop$length = length6;
            loop$iterations = iterations + 1;
          }
        } else {
          loop$slots = slots;
          loop$current_index = current_index + 1;
          loop$original_start = original_start;
          loop$length = length6;
          loop$iterations = iterations + 1;
        }
      }
    }
  }
}
__name(find_next_damage_spell_loop, "find_next_damage_spell_loop");
function find_next_damage_spell(slots, start_index) {
  let length6 = size4(slots);
  return find_next_damage_spell_loop(slots, start_index, start_index, length6, 0);
}
__name(find_next_damage_spell, "find_next_damage_spell");
function build_trigger_payload(slots, current_index) {
  let $ = find_next_damage_spell(slots, current_index + 1);
  if ($ instanceof Ok) {
    let payload_id = $[0][0];
    let ui_sprite = $[0][1];
    let payload_spell = $[0][2];
    let payload_index = $[0][3];
    let wand_length = size4(slots);
    let payload_modifiers = collect_modifiers_between(
      slots,
      current_index + 1,
      payload_index,
      wand_length
    );
    let payload_modified = apply_modifiers(
      payload_id,
      ui_sprite,
      payload_spell,
      payload_modifiers
    );
    return [new Some(payload_modified), new Some(payload_index)];
  } else {
    return [new None(), new None()];
  }
}
__name(build_trigger_payload, "build_trigger_payload");
function calculate_trigger_payload(damaging, accumulated_modifiers, slots, current_index) {
  let needs_trigger = damaging.has_trigger || has_trigger_modifier(
    accumulated_modifiers
  );
  if (needs_trigger) {
    return build_trigger_payload(slots, current_index);
  } else {
    return [new None(), new None()];
  }
}
__name(calculate_trigger_payload, "calculate_trigger_payload");
function update_indices_for_payload(state, wand_slots, wrapped_index, payload_index_opt) {
  if (payload_index_opt instanceof Some) {
    let payload_index = payload_index_opt[0];
    let wand_length = size4(wand_slots);
    let indices_to_add = collect_indices_between(
      state.current_index + 1,
      payload_index,
      wand_length
    );
    let all_indices = append2(
      indices_to_add,
      prepend(wrapped_index, state.casting_indices)
    );
    return [payload_index + 1, all_indices];
  } else {
    return [
      state.current_index + 1,
      prepend(wrapped_index, state.casting_indices)
    ];
  }
}
__name(update_indices_for_payload, "update_indices_for_payload");
function check_slots_from(loop$slots, loop$current, loop$length) {
  while (true) {
    let slots = loop$slots;
    let current = loop$current;
    let length6 = loop$length;
    let $ = current >= length6;
    if ($) {
      return false;
    } else {
      let $1 = get8(slots, current);
      if ($1 instanceof Ok) {
        let $2 = $1[0];
        if ($2 instanceof Some) {
          return true;
        } else {
          loop$slots = slots;
          loop$current = current + 1;
          loop$length = length6;
        }
      } else {
        loop$slots = slots;
        loop$current = current + 1;
        loop$length = length6;
      }
    }
  }
}
__name(check_slots_from, "check_slots_from");
function has_any_spell_from(slots, start_index) {
  let length6 = size4(slots);
  return check_slots_from(slots, start_index, length6);
}
__name(has_any_spell_from, "has_any_spell_from");
function create_success_result(wand, state, wrapped_flag) {
  let new_mana = wand.current_mana - state.total_mana_used;
  let updated_wand = new Wand(
    wand.name,
    wand.slots,
    wand.max_mana,
    new_mana,
    wand.mana_recharge_rate,
    wand.cast_delay,
    wand.recharge_time,
    wand.spells_per_cast,
    wand.spread
  );
  let wand_length = size4(wand.slots);
  let next_index = remainderInt(state.current_index, wand_length);
  let has_spells_ahead = has_any_spell_from(wand.slots, next_index);
  let did_wrap = wrapped_flag || !has_spells_ahead;
  return [
    new CastSuccess(
      state.projectiles,
      new_mana,
      next_index,
      state.casting_indices,
      did_wrap,
      state.total_cast_delay_addition,
      state.total_recharge_time_addition
    ),
    updated_wand
  ];
}
__name(create_success_result, "create_success_result");
function apply_spread(direction2, spread_degrees) {
  let _block;
  let _pipe = new Vec3(direction2.x, 0, direction2.z);
  _block = normalize(_pipe);
  let flat_dir = _block;
  if (spread_degrees === 0) {
    return flat_dir;
  } else {
    let spread_radians = spread_degrees * pi2() / 180;
    let random_factor = random_uniform() * 2 - 1;
    let angle = random_factor * spread_radians;
    let cos_angle = cos2(angle);
    let sin_angle = sin2(angle);
    let _pipe$1 = new Vec3(
      flat_dir.x * cos_angle - flat_dir.z * sin_angle,
      0,
      flat_dir.x * sin_angle + flat_dir.z * cos_angle
    );
    return normalize(_pipe$1);
  }
}
__name(apply_spread, "apply_spread");
function encode3(wand) {
  let cast_delay_ms = round(
    to_seconds(wand.cast_delay) * 1e3
  );
  let recharge_time_ms = round(
    to_seconds(wand.recharge_time) * 1e3
  );
  return object2(
    toList([
      ["name", string3(wand.name)],
      ["max_mana", float3(wand.max_mana)],
      ["current_mana", float3(wand.current_mana)],
      ["mana_recharge_rate", float3(wand.mana_recharge_rate)],
      ["cast_delay_ms", int3(cast_delay_ms)],
      ["recharge_time_ms", int3(recharge_time_ms)],
      ["spells_per_cast", int3(wand.spells_per_cast)],
      ["spread", float3(wand.spread)]
    ])
  );
}
__name(encode3, "encode");
function process_empty_slot(wand, state, wrapped_index, wrapped_flag, context) {
  let next_state = advance_to_next_slot(state, wrapped_index, wrapped_flag);
  return process_with_draw(wand, next_state, context);
}
__name(process_empty_slot, "process_empty_slot");
function process_with_draw(wand, state, context) {
  let wand_length = size4(wand.slots);
  if (wand_length === 0) {
    return [new WandEmpty(), wand];
  } else {
    let $ = state.remaining_draw <= 0;
    if ($) {
      let $1 = state.projectiles;
      if ($1 instanceof Empty) {
        return [new NoSpellToCast(), wand];
      } else {
        return create_success_result(wand, state, state.wrapped_during_cast);
      }
    } else {
      return process_next_spell(wand, state, context, wand_length);
    }
  }
}
__name(process_with_draw, "process_with_draw");
function process_next_spell(wand, state, context, wand_length) {
  let wrapped_index = remainderInt(state.current_index, wand_length);
  let is_wrapping = is_index_wrapped(state.current_index, wand_length);
  let wrapped_flag = state.wrapped_during_cast || is_wrapping;
  let completed_cycle = has_completed_cycle(
    state.current_index,
    state.original_start_index,
    wand_length,
    wrapped_flag
  );
  if (completed_cycle) {
    let $ = state.projectiles;
    if ($ instanceof Empty) {
      return [new NoSpellToCast(), wand];
    } else {
      return create_success_result(wand, state, wrapped_flag);
    }
  } else {
    return process_spell_at_index(
      wand,
      state,
      wrapped_index,
      wrapped_flag,
      context
    );
  }
}
__name(process_next_spell, "process_next_spell");
function process_spell_at_index(wand, state, wrapped_index, wrapped_flag, context) {
  let $ = get8(wand.slots, wrapped_index);
  if ($ instanceof Ok) {
    let $1 = $[0];
    if ($1 instanceof Some) {
      let current_spell = $1[0];
      if (current_spell instanceof DamageSpell) {
        let id4 = current_spell.id;
        let ui_sprite = current_spell.ui_sprite;
        let kind = current_spell.kind;
        return process_damage_spell(
          wand,
          id4,
          ui_sprite,
          kind,
          wrapped_index,
          wrapped_flag,
          state,
          context
        );
      } else if (current_spell instanceof ModifierSpell) {
        let kind = current_spell.kind;
        return process_modifier_spell(
          wand,
          state,
          kind,
          wrapped_index,
          wrapped_flag,
          context
        );
      } else {
        let kind = current_spell.kind;
        return process_multicast_spell(
          wand,
          state,
          kind,
          wrapped_index,
          wrapped_flag,
          context
        );
      }
    } else {
      return process_empty_slot(
        wand,
        state,
        wrapped_index,
        wrapped_flag,
        context
      );
    }
  } else {
    return [new WandEmpty(), wand];
  }
}
__name(process_spell_at_index, "process_spell_at_index");
function cast(wand, start_index, position, direction2, projectile_starting_index, target_position, player_center, existing_projectiles) {
  let $ = start_index >= size4(wand.slots);
  if ($) {
    return [new WandEmpty(), wand];
  } else {
    let context = new CastContext(
      position,
      direction2,
      target_position,
      player_center,
      existing_projectiles,
      projectile_starting_index
    );
    let initial_state = new CastState(
      start_index,
      wand.spells_per_cast,
      new$6(),
      toList([]),
      toList([]),
      0,
      milliseconds(0),
      milliseconds(0),
      projectile_starting_index,
      false,
      start_index,
      wand.spells_per_cast
    );
    return process_with_draw(wand, initial_state, context);
  }
}
__name(cast, "cast");
function process_modifier_spell(wand, state, modifier, wrapped_index, wrapped_flag, context) {
  let new_modifiers = prepend4(state.accumulated_modifiers, modifier);
  let _block;
  let _pipe = advance_to_next_slot(state, wrapped_index, wrapped_flag);
  _block = ((s) => {
    return new CastState(
      s.current_index,
      s.remaining_draw,
      new_modifiers,
      s.projectiles,
      s.casting_indices,
      s.total_mana_used,
      s.total_cast_delay_addition,
      s.total_recharge_time_addition,
      s.projectile_id,
      s.wrapped_during_cast,
      s.original_start_index,
      s.spells_per_cast
    );
  })(_pipe);
  let next_state = _block;
  return process_with_draw(wand, next_state, context);
}
__name(process_modifier_spell, "process_modifier_spell");
function process_multicast_spell(wand, state, multicast, wrapped_index, wrapped_flag, context) {
  let new_draw = state.remaining_draw - 1 + multicast.draw_add;
  let $ = check_mana_sufficient(
    wand,
    state.total_mana_used,
    multicast.mana_cost
  );
  if ($ instanceof Ok) {
    let new_mana_used = $[0];
    let _block;
    let _pipe = advance_to_next_slot(state, wrapped_index, wrapped_flag);
    _block = ((s) => {
      return new CastState(
        s.current_index,
        new_draw,
        s.accumulated_modifiers,
        s.projectiles,
        s.casting_indices,
        new_mana_used,
        s.total_cast_delay_addition,
        s.total_recharge_time_addition,
        s.projectile_id,
        s.wrapped_during_cast,
        s.original_start_index,
        s.spells_per_cast
      );
    })(_pipe);
    let next_state = _block;
    return process_with_draw(wand, next_state, context);
  } else {
    let required = $[0][0];
    let available = $[0][1];
    return [new NotEnoughMana(required, available), wand];
  }
}
__name(process_multicast_spell, "process_multicast_spell");
function process_damage_spell(wand, id4, ui_sprite, spell, wrapped_index, wrapped_flag, state, context) {
  let modified = apply_modifiers(
    id4,
    ui_sprite,
    spell,
    state.accumulated_modifiers
  );
  let new_cast_delay = add3(
    state.total_cast_delay_addition,
    modified.final_cast_delay
  );
  let new_recharge_time = add3(
    state.total_recharge_time_addition,
    modified.final_recharge_time
  );
  let $ = check_mana_sufficient(
    wand,
    state.total_mana_used,
    modified.total_mana_cost
  );
  if ($ instanceof Ok) {
    let new_mana_used = $[0];
    let spread_direction = apply_spread(
      context.direction,
      wand.spread + modified.final_spread
    );
    let projectile_position = context.position;
    let $1 = calculate_trigger_payload(
      spell,
      state.accumulated_modifiers,
      wand.slots,
      state.current_index
    );
    let trigger_payload;
    let payload_info;
    trigger_payload = $1[0];
    payload_info = $1[1];
    let projectile = new Projectile(
      state.projectile_id,
      modified,
      projectile_position,
      spread_direction,
      milliseconds(0),
      spell.visuals,
      trigger_payload
    );
    let _block;
    let $2 = state.remaining_draw - 1 >= state.spells_per_cast;
    if ($2) {
      _block = state.accumulated_modifiers;
    } else {
      _block = new$6();
    }
    let new_accumulated_modifiers = _block;
    let $3 = update_indices_for_payload(
      state,
      wand.slots,
      wrapped_index,
      payload_info
    );
    let next_index;
    let updated_casting_indices;
    next_index = $3[0];
    updated_casting_indices = $3[1];
    let next_state = new CastState(
      next_index,
      state.remaining_draw - 1,
      new_accumulated_modifiers,
      prepend(projectile, state.projectiles),
      updated_casting_indices,
      new_mana_used,
      new_cast_delay,
      new_recharge_time,
      state.projectile_id + 1,
      wrapped_flag,
      state.original_start_index,
      state.spells_per_cast
    );
    return process_with_draw(wand, next_state, context);
  } else {
    let required = $[0][0];
    let available = $[0][1];
    return [new NotEnoughMana(required, available), wand];
  }
}
__name(process_damage_spell, "process_damage_spell");

// build/dev/javascript/shared/shared/player.mjs
var Player = class extends CustomType {
  static {
    __name(this, "Player");
  }
  constructor(id4, name2, position, rotation, health, active_wand_slot, wands, movement_state) {
    super();
    this.id = id4;
    this.name = name2;
    this.position = position;
    this.rotation = rotation;
    this.health = health;
    this.active_wand_slot = active_wand_slot;
    this.wands = wands;
    this.movement_state = movement_state;
  }
};
var WandInventory = class extends CustomType {
  static {
    __name(this, "WandInventory");
  }
  constructor(slot_0, slot_1, slot_2, slot_3) {
    super();
    this.slot_0 = slot_0;
    this.slot_1 = slot_1;
    this.slot_2 = slot_2;
    this.slot_3 = slot_3;
  }
};
var Idle = class extends CustomType {
  static {
    __name(this, "Idle");
  }
};
var MovingToPosition = class extends CustomType {
  static {
    __name(this, "MovingToPosition");
  }
  constructor(target, speed) {
    super();
    this.target = target;
    this.speed = speed;
  }
};
var Id = class extends CustomType {
  static {
    __name(this, "Id");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function new$7(id4, name2, position) {
  return new Player(
    id4,
    name2,
    position,
    0,
    new$2(100),
    0,
    new WandInventory(
      new None(),
      new None(),
      new None(),
      new None()
    ),
    new Idle()
  );
}
__name(new$7, "new$");
function encode_optional_wand(wand_opt) {
  if (wand_opt instanceof Some) {
    let w = wand_opt[0];
    return encode3(w);
  } else {
    return null$();
  }
}
__name(encode_optional_wand, "encode_optional_wand");
function encode_wand_inventory(inv) {
  return object2(
    toList([
      ["slot_0", encode_optional_wand(inv.slot_0)],
      ["slot_1", encode_optional_wand(inv.slot_1)],
      ["slot_2", encode_optional_wand(inv.slot_2)],
      ["slot_3", encode_optional_wand(inv.slot_3)]
    ])
  );
}
__name(encode_wand_inventory, "encode_wand_inventory");
function encode_movement_state(state) {
  if (state instanceof Idle) {
    return object2(toList([["type", string3("idle")]]));
  } else {
    let target = state.target;
    let speed = state.speed;
    return object2(
      toList([
        ["type", string3("moving")],
        ["target", encode2(target)],
        ["speed", float3(speed)]
      ])
    );
  }
}
__name(encode_movement_state, "encode_movement_state");
function encode4(state) {
  let $ = state.id;
  let player_id;
  player_id = $[0];
  return object2(
    toList([
      ["id", int3(player_id)],
      ["name", string3(state.name)],
      ["position", encode2(state.position)],
      ["rotation", float3(state.rotation)],
      ["health", encode(state.health)],
      ["active_wand_slot", int3(state.active_wand_slot)],
      ["wands", encode_wand_inventory(state.wands)],
      ["movement_state", encode_movement_state(state.movement_state)]
    ])
  );
}
__name(encode4, "encode");

// build/dev/javascript/shared/shared/enemy.mjs
function encode_enemy_type(enemy_type) {
  return string3("zombie");
}
__name(encode_enemy_type, "encode_enemy_type");
function encode5(enemy) {
  let $ = enemy.id;
  let enemy_id;
  enemy_id = $[0];
  let _block;
  let $1 = enemy.target_player;
  if ($1 instanceof Some) {
    let pid = $1[0][0];
    _block = int3(pid);
  } else {
    _block = null$();
  }
  let target_id = _block;
  return object2(
    toList([
      ["id", int3(enemy_id)],
      ["enemy_type", encode_enemy_type(enemy.enemy_type)],
      ["position", encode2(enemy.position)],
      ["velocity", encode2(enemy.velocity)],
      ["health", encode(enemy.health)],
      ["target_player", target_id]
    ])
  );
}
__name(encode5, "encode");

// build/dev/javascript/shared/shared/projectile.mjs
var Projectile2 = class extends CustomType {
  static {
    __name(this, "Projectile");
  }
  constructor(id4, owner_id, spell, position, velocity, time_alive, visuals, trigger_payload) {
    super();
    this.id = id4;
    this.owner_id = owner_id;
    this.spell = spell;
    this.position = position;
    this.velocity = velocity;
    this.time_alive = time_alive;
    this.visuals = visuals;
    this.trigger_payload = trigger_payload;
  }
};
var Id2 = class extends CustomType {
  static {
    __name(this, "Id");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function encode6(proj) {
  let $ = proj.id;
  let proj_id;
  proj_id = $[0];
  let $1 = proj.owner_id;
  let owner_id_int;
  owner_id_int = $1[0];
  let _block;
  let _pipe = to_seconds(proj.time_alive) * 1e3;
  _block = round(_pipe);
  let time_alive_ms = _block;
  return object2(
    toList([
      ["id", int3(proj_id)],
      ["owner_id", int3(owner_id_int)],
      ["position", encode2(proj.position)],
      ["velocity", encode2(proj.velocity)],
      ["time_alive_ms", int3(time_alive_ms)]
    ])
  );
}
__name(encode6, "encode");

// build/dev/javascript/shared/shared/room.mjs
var Id3 = class extends CustomType {
  static {
    __name(this, "Id");
  }
  constructor($0) {
    super();
    this[0] = $0;
  }
};

// build/dev/javascript/shared/shared/game_messages.mjs
var JoinRoom = class extends CustomType {
  static {
    __name(this, "JoinRoom");
  }
  constructor(room_id, player_name) {
    super();
    this.room_id = room_id;
    this.player_name = player_name;
  }
};
var LeaveRoom = class extends CustomType {
  static {
    __name(this, "LeaveRoom");
  }
};
var PlayerInput = class extends CustomType {
  static {
    __name(this, "PlayerInput");
  }
  constructor(tick2, action) {
    super();
    this.tick = tick2;
    this.action = action;
  }
};
var PlayerUpdate = class extends CustomType {
  static {
    __name(this, "PlayerUpdate");
  }
  constructor(position) {
    super();
    this.position = position;
  }
};
var Ping = class extends CustomType {
  static {
    __name(this, "Ping");
  }
  constructor(timestamp2) {
    super();
    this.timestamp = timestamp2;
  }
};
var None2 = class extends CustomType {
  static {
    __name(this, "None");
  }
};
var MoveToPosition = class extends CustomType {
  static {
    __name(this, "MoveToPosition");
  }
  constructor(target) {
    super();
    this.target = target;
  }
};
var SwitchWand = class extends CustomType {
  static {
    __name(this, "SwitchWand");
  }
  constructor(slot) {
    super();
    this.slot = slot;
  }
};
var CastSpell = class extends CustomType {
  static {
    __name(this, "CastSpell");
  }
  constructor(target) {
    super();
    this.target = target;
  }
};
var RoomJoined = class extends CustomType {
  static {
    __name(this, "RoomJoined");
  }
  constructor(room_id, player_id, players) {
    super();
    this.room_id = room_id;
    this.player_id = player_id;
    this.players = players;
  }
};
var PlayerJoined = class extends CustomType {
  static {
    __name(this, "PlayerJoined");
  }
  constructor(player) {
    super();
    this.player = player;
  }
};
var PlayerLeft = class extends CustomType {
  static {
    __name(this, "PlayerLeft");
  }
  constructor(player_id) {
    super();
    this.player_id = player_id;
  }
};
var PlayerStates = class extends CustomType {
  static {
    __name(this, "PlayerStates");
  }
  constructor(states) {
    super();
    this.states = states;
  }
};
var GameStateUpdate = class extends CustomType {
  static {
    __name(this, "GameStateUpdate");
  }
  constructor(tick2, players, projectiles, enemies) {
    super();
    this.tick = tick2;
    this.players = players;
    this.projectiles = projectiles;
    this.enemies = enemies;
  }
};
var ProjectileSpawned = class extends CustomType {
  static {
    __name(this, "ProjectileSpawned");
  }
  constructor(projectile) {
    super();
    this.projectile = projectile;
  }
};
var ProjectileDestroyed = class extends CustomType {
  static {
    __name(this, "ProjectileDestroyed");
  }
  constructor(id4, reason) {
    super();
    this.id = id4;
    this.reason = reason;
  }
};
var EnemySpawned = class extends CustomType {
  static {
    __name(this, "EnemySpawned");
  }
  constructor(enemy) {
    super();
    this.enemy = enemy;
  }
};
var EnemyDied = class extends CustomType {
  static {
    __name(this, "EnemyDied");
  }
  constructor(id4) {
    super();
    this.id = id4;
  }
};
var PlayerDamaged = class extends CustomType {
  static {
    __name(this, "PlayerDamaged");
  }
  constructor(player_id, damage, new_health) {
    super();
    this.player_id = player_id;
    this.damage = damage;
    this.new_health = new_health;
  }
};
var Pong = class extends CustomType {
  static {
    __name(this, "Pong");
  }
  constructor(client_timestamp, server_timestamp) {
    super();
    this.client_timestamp = client_timestamp;
    this.server_timestamp = server_timestamp;
  }
};
var HitEnemy = class extends CustomType {
  static {
    __name(this, "HitEnemy");
  }
  constructor(enemy_id) {
    super();
    this.enemy_id = enemy_id;
  }
};
var HitPlayer = class extends CustomType {
  static {
    __name(this, "HitPlayer");
  }
  constructor(player_id) {
    super();
    this.player_id = player_id;
  }
};
var Expired = class extends CustomType {
  static {
    __name(this, "Expired");
  }
};
function player_action_decoder() {
  return field(
    "type",
    string2,
    (action_type) => {
      if (action_type === "none") {
        return success(new None2());
      } else if (action_type === "move_to_position") {
        return field(
          "target",
          decoder(),
          (target) => {
            return success(new MoveToPosition(target));
          }
        );
      } else if (action_type === "switch_wand") {
        return field(
          "slot",
          int2,
          (slot) => {
            return success(new SwitchWand(slot));
          }
        );
      } else if (action_type === "cast_spell") {
        return field(
          "target",
          decoder(),
          (target) => {
            return success(new CastSpell(target));
          }
        );
      } else {
        return failure(new None2(), "PlayerAction");
      }
    }
  );
}
__name(player_action_decoder, "player_action_decoder");
function decode_client_message(data2) {
  let decoder7 = field(
    "type",
    string2,
    (msg_type) => {
      if (msg_type === "join_room") {
        return field(
          "room_id",
          string2,
          (room_id) => {
            return field(
              "player_name",
              string2,
              (player_name) => {
                return success(new JoinRoom(room_id, player_name));
              }
            );
          }
        );
      } else if (msg_type === "leave_room") {
        return success(new LeaveRoom());
      } else if (msg_type === "player_input") {
        return field(
          "tick",
          int2,
          (tick2) => {
            return field(
              "action",
              player_action_decoder(),
              (action) => {
                return success(new PlayerInput(tick2, action));
              }
            );
          }
        );
      } else if (msg_type === "player_update") {
        return field(
          "position",
          decoder(),
          (position) => {
            return success(new PlayerUpdate(position));
          }
        );
      } else if (msg_type === "ping") {
        return field(
          "timestamp",
          int2,
          (timestamp2) => {
            return success(
              new Ping(from_unix_seconds(timestamp2))
            );
          }
        );
      } else {
        return failure(new LeaveRoom(), "ClientMessage");
      }
    }
  );
  let _pipe = parse3(data2, decoder7);
  return map_error(
    _pipe,
    (error) => {
      return "Failed to parse client message" + inspect2(error);
    }
  );
}
__name(decode_client_message, "decode_client_message");
function encode_destroy_reason(reason) {
  if (reason instanceof HitEnemy) {
    let enemy_id = reason.enemy_id;
    let eid;
    eid = enemy_id[0];
    return object2(
      toList([["type", string3("hit_enemy")], ["enemy_id", int3(eid)]])
    );
  } else if (reason instanceof HitPlayer) {
    let player_id = reason.player_id;
    let pid;
    pid = player_id[0];
    return object2(
      toList([
        ["type", string3("hit_player")],
        ["player_id", int3(pid)]
      ])
    );
  } else {
    return object2(toList([["type", string3("expired")]]));
  }
}
__name(encode_destroy_reason, "encode_destroy_reason");
function encode_server_message(msg) {
  let _block;
  if (msg instanceof RoomJoined) {
    let room_id = msg.room_id;
    let player_id = msg.player_id;
    let players = msg.players;
    let room_serial;
    room_serial = room_id[0];
    let player_serial;
    player_serial = player_id[0];
    _block = object2(
      toList([
        ["type", string3("room_joined")],
        ["room_id", int3(room_serial)],
        ["player_id", int3(player_serial)],
        ["players", array2(players, encode4)]
      ])
    );
  } else if (msg instanceof PlayerJoined) {
    let player_state = msg.player;
    _block = object2(
      toList([
        ["type", string3("player_joined")],
        ["player", encode4(player_state)]
      ])
    );
  } else if (msg instanceof PlayerLeft) {
    let player_id = msg.player_id;
    let player_serial;
    player_serial = player_id[0];
    _block = object2(
      toList([
        ["type", string3("player_left")],
        ["player_id", int3(player_serial)]
      ])
    );
  } else if (msg instanceof PlayerStates) {
    let states = msg.states;
    _block = object2(
      toList([
        ["type", string3("player_states")],
        ["states", array2(states, encode4)]
      ])
    );
  } else if (msg instanceof GameStateUpdate) {
    let tick2 = msg.tick;
    let players = msg.players;
    let projectiles = msg.projectiles;
    let enemies = msg.enemies;
    _block = object2(
      toList([
        ["type", string3("game_state_update")],
        ["tick", int3(tick2)],
        ["players", array2(players, encode4)],
        ["projectiles", array2(projectiles, encode6)],
        ["enemies", array2(enemies, encode5)]
      ])
    );
  } else if (msg instanceof ProjectileSpawned) {
    let proj = msg.projectile;
    _block = object2(
      toList([
        ["type", string3("projectile_spawned")],
        ["projectile", encode6(proj)]
      ])
    );
  } else if (msg instanceof ProjectileDestroyed) {
    let id4 = msg.id;
    let reason = msg.reason;
    let proj_id;
    proj_id = id4[0];
    _block = object2(
      toList([
        ["type", string3("projectile_destroyed")],
        ["id", int3(proj_id)],
        ["reason", encode_destroy_reason(reason)]
      ])
    );
  } else if (msg instanceof EnemySpawned) {
    let enm = msg.enemy;
    _block = object2(
      toList([
        ["type", string3("enemy_spawned")],
        ["enemy", encode5(enm)]
      ])
    );
  } else if (msg instanceof EnemyDied) {
    let id4 = msg.id;
    let enemy_id;
    enemy_id = id4[0];
    _block = object2(
      toList([["type", string3("enemy_died")], ["id", int3(enemy_id)]])
    );
  } else if (msg instanceof PlayerDamaged) {
    let player_id = msg.player_id;
    let damage = msg.damage;
    let new_health = msg.new_health;
    let pid;
    pid = player_id[0];
    _block = object2(
      toList([
        ["type", string3("player_damaged")],
        ["player_id", int3(pid)],
        ["damage", float3(damage)],
        ["new_health", float3(new_health)]
      ])
    );
  } else if (msg instanceof Pong) {
    let client_timestamp = msg.client_timestamp;
    let server_timestamp = msg.server_timestamp;
    _block = object2(
      toList([
        ["type", string3("pong")],
        [
          "client_timestamp",
          int3(
            to_unix_seconds_and_nanoseconds(client_timestamp)[0]
          )
        ],
        [
          "server_timestamp",
          int3(
            to_unix_seconds_and_nanoseconds(server_timestamp)[0]
          )
        ]
      ])
    );
  } else {
    let message = msg.message;
    _block = object2(
      toList([
        ["type", string3("error")],
        ["message", string3(message)]
      ])
    );
  }
  let _pipe = _block;
  return to_string3(_pipe);
}
__name(encode_server_message, "encode_server_message");

// build/dev/javascript/shared/shared/game_state.mjs
var GameState = class extends CustomType {
  static {
    __name(this, "GameState");
  }
  constructor(tick2, players, projectiles, enemies) {
    super();
    this.tick = tick2;
    this.players = players;
    this.projectiles = projectiles;
    this.enemies = enemies;
  }
};
function new$8() {
  return new GameState(0, make(), make(), make());
}
__name(new$8, "new$");

// build/dev/javascript/server/server/game_simulation.mjs
var ProjectileCreated = class extends CustomType {
  static {
    __name(this, "ProjectileCreated");
  }
  constructor(projectile) {
    super();
    this.projectile = projectile;
  }
};
var ProjectileDestroyed2 = class extends CustomType {
  static {
    __name(this, "ProjectileDestroyed");
  }
  constructor(id4, reason) {
    super();
    this.id = id4;
    this.reason = reason;
  }
};
var EnemySpawned2 = class extends CustomType {
  static {
    __name(this, "EnemySpawned");
  }
  constructor(enemy) {
    super();
    this.enemy = enemy;
  }
};
var EnemyDied2 = class extends CustomType {
  static {
    __name(this, "EnemyDied");
  }
  constructor(id4) {
    super();
    this.id = id4;
  }
};
var HitEnemy2 = class extends CustomType {
  static {
    __name(this, "HitEnemy");
  }
  constructor(enemy_id) {
    super();
    this.enemy_id = enemy_id;
  }
};
var HitPlayer2 = class extends CustomType {
  static {
    __name(this, "HitPlayer");
  }
  constructor(player_id) {
    super();
    this.player_id = player_id;
  }
};
var Expired2 = class extends CustomType {
  static {
    __name(this, "Expired");
  }
};
function apply_events_to_state(game_state, events) {
  return fold2(
    events,
    game_state,
    (state, event) => {
      if (event instanceof ProjectileCreated) {
        let projectile = event.projectile;
        let new_projectiles = insert(
          state.projectiles,
          projectile.id,
          projectile
        );
        return new GameState(
          state.tick,
          state.players,
          new_projectiles,
          state.enemies
        );
      } else if (event instanceof ProjectileDestroyed2) {
        let id4 = event.id;
        let new_projectiles = delete$(state.projectiles, id4);
        return new GameState(
          state.tick,
          state.players,
          new_projectiles,
          state.enemies
        );
      } else if (event instanceof EnemySpawned2) {
        return state;
      } else if (event instanceof EnemyDied2) {
        let id4 = event.id;
        let new_enemies = delete$(state.enemies, id4);
        return new GameState(
          state.tick,
          state.players,
          state.projectiles,
          new_enemies
        );
      } else {
        return state;
      }
    }
  );
}
__name(apply_events_to_state, "apply_events_to_state");
function get_active_wand(player_state) {
  let $ = player_state.active_wand_slot;
  if ($ === 0) {
    return player_state.wands.slot_0;
  } else if ($ === 1) {
    return player_state.wands.slot_1;
  } else if ($ === 2) {
    return player_state.wands.slot_2;
  } else if ($ === 3) {
    return player_state.wands.slot_3;
  } else {
    return new None();
  }
}
__name(get_active_wand, "get_active_wand");
function update_player_wand(player_state, slot, new_wand) {
  let _block;
  if (slot === 0) {
    let _record = player_state.wands;
    _block = new WandInventory(
      new Some(new_wand),
      _record.slot_1,
      _record.slot_2,
      _record.slot_3
    );
  } else if (slot === 1) {
    let _record = player_state.wands;
    _block = new WandInventory(
      _record.slot_0,
      new Some(new_wand),
      _record.slot_2,
      _record.slot_3
    );
  } else if (slot === 2) {
    let _record = player_state.wands;
    _block = new WandInventory(
      _record.slot_0,
      _record.slot_1,
      new Some(new_wand),
      _record.slot_3
    );
  } else if (slot === 3) {
    let _record = player_state.wands;
    _block = new WandInventory(
      _record.slot_0,
      _record.slot_1,
      _record.slot_2,
      new Some(new_wand)
    );
  } else {
    _block = player_state.wands;
  }
  let new_wands = _block;
  return new Player(
    player_state.id,
    player_state.name,
    player_state.position,
    player_state.rotation,
    player_state.health,
    player_state.active_wand_slot,
    new_wands,
    player_state.movement_state
  );
}
__name(update_player_wand, "update_player_wand");
function spell_projectile_to_game_projectile(spell_proj, owner_id) {
  let _block;
  let $ = spell_proj.spell.base;
  if ($ instanceof DamageSpell) {
    let damage_spell = $.kind;
    let speed2 = damage_spell.projectile_speed;
    _block = speed2;
  } else {
    _block = 100;
  }
  let speed = _block;
  let velocity = scale(spell_proj.direction, speed);
  return new Projectile2(
    new Id2(spell_proj.id),
    owner_id,
    spell_proj.spell,
    spell_proj.position,
    velocity,
    spell_proj.time_alive,
    spell_proj.visuals,
    spell_proj.trigger_payload
  );
}
__name(spell_projectile_to_game_projectile, "spell_projectile_to_game_projectile");
function process_player_action(players, events, player_id, player_state, action) {
  if (action instanceof None2) {
    return [players, events];
  } else if (action instanceof MoveToPosition) {
    let target = action.target;
    let movement_speed = 5;
    let new_movement_state = new MovingToPosition(
      target,
      movement_speed
    );
    let updated_player = new Player(
      player_state.id,
      player_state.name,
      player_state.position,
      player_state.rotation,
      player_state.health,
      player_state.active_wand_slot,
      player_state.wands,
      new_movement_state
    );
    let new_players = insert(players, player_id, updated_player);
    return [new_players, events];
  } else if (action instanceof SwitchWand) {
    let slot = action.slot;
    let $ = slot >= 0 && slot <= 3;
    if ($) {
      let updated_player = new Player(
        player_state.id,
        player_state.name,
        player_state.position,
        player_state.rotation,
        player_state.health,
        slot,
        player_state.wands,
        player_state.movement_state
      );
      let new_players = insert(players, player_id, updated_player);
      return [new_players, events];
    } else {
      return [players, events];
    }
  } else {
    let target = action.target;
    let wand_option = get_active_wand(player_state);
    if (wand_option instanceof Some) {
      let active_wand = wand_option[0];
      let direction2 = direction(player_state.position, target);
      let $ = cast(
        active_wand,
        0,
        player_state.position,
        direction2,
        0,
        new Some(target),
        new Some(player_state.position),
        toList([])
      );
      let cast_result;
      let updated_wand;
      cast_result = $[0];
      updated_wand = $[1];
      if (cast_result instanceof CastSuccess) {
        let projectiles = cast_result.projectiles;
        let updated_player = update_player_wand(
          player_state,
          player_state.active_wand_slot,
          updated_wand
        );
        let new_players = insert(players, player_id, updated_player);
        let new_events = map2(
          projectiles,
          (spell_projectile) => {
            let projectile = spell_projectile_to_game_projectile(
              spell_projectile,
              player_id
            );
            return new ProjectileCreated(projectile);
          }
        );
        return [new_players, append2(events, new_events)];
      } else {
        return [players, events];
      }
    } else {
      return [players, events];
    }
  }
}
__name(process_player_action, "process_player_action");
function process_player_inputs(game_state, player_inputs) {
  let $ = fold(
    player_inputs,
    [game_state.players, toList([])],
    (acc, player_id, action) => {
      let players;
      let events2;
      players = acc[0];
      events2 = acc[1];
      let $1 = get(players, player_id);
      if ($1 instanceof Ok) {
        let player_state = $1[0];
        return process_player_action(
          players,
          events2,
          player_id,
          player_state,
          action
        );
      } else {
        return acc;
      }
    }
  );
  let new_players;
  let events;
  new_players = $[0];
  events = $[1];
  return [
    new GameState(
      game_state.tick,
      new_players,
      game_state.projectiles,
      game_state.enemies
    ),
    events
  ];
}
__name(process_player_inputs, "process_player_inputs");
function simulate_player_movement(game_state, delta_time) {
  let dt_seconds = to_seconds(delta_time);
  let new_players = map(
    game_state.players,
    (_, player_state) => {
      let $ = player_state.movement_state;
      if ($ instanceof Idle) {
        return player_state;
      } else {
        let target = $.target;
        let speed = $.speed;
        let current_pos = player_state.position;
        let distance2 = distance(current_pos, target);
        let max_movement = speed * dt_seconds;
        let $1 = distance2 <= 0.1 || max_movement >= distance2;
        if ($1) {
          return new Player(
            player_state.id,
            player_state.name,
            target,
            player_state.rotation,
            player_state.health,
            player_state.active_wand_slot,
            player_state.wands,
            new Idle()
          );
        } else {
          let direction2 = direction(current_pos, target);
          let movement_vec = scale(direction2, max_movement);
          let new_pos = add4(current_pos, movement_vec);
          return new Player(
            player_state.id,
            player_state.name,
            new_pos,
            player_state.rotation,
            player_state.health,
            player_state.active_wand_slot,
            player_state.wands,
            player_state.movement_state
          );
        }
      }
    }
  );
  return new GameState(
    game_state.tick,
    new_players,
    game_state.projectiles,
    game_state.enemies
  );
}
__name(simulate_player_movement, "simulate_player_movement");
function simulate_enemy_movement(game_state, _) {
  return game_state;
}
__name(simulate_enemy_movement, "simulate_enemy_movement");
function simulate_projectiles(game_state, delta_time) {
  let dt_seconds = to_seconds(delta_time);
  let $ = fold(
    game_state.projectiles,
    [make(), toList([])],
    (acc, proj_id, projectile) => {
      let projectiles_acc;
      let events_acc;
      projectiles_acc = acc[0];
      events_acc = acc[1];
      let _block;
      let $1 = projectile.spell.base;
      if ($1 instanceof DamageSpell) {
        let damage_spell = $1.kind;
        let lifetime2 = damage_spell.projectile_lifetime;
        _block = lifetime2;
      } else {
        _block = seconds2(5);
      }
      let lifetime = _block;
      let new_time_alive = add3(projectile.time_alive, delta_time);
      let $2 = compare3(new_time_alive, lifetime);
      if ($2 instanceof Lt) {
        let movement = scale(projectile.velocity, dt_seconds);
        let new_position = add4(projectile.position, movement);
        let updated_projectile = new Projectile2(
          projectile.id,
          projectile.owner_id,
          projectile.spell,
          new_position,
          projectile.velocity,
          new_time_alive,
          projectile.visuals,
          projectile.trigger_payload
        );
        let new_projectiles = insert(
          projectiles_acc,
          proj_id,
          updated_projectile
        );
        return [new_projectiles, events_acc];
      } else if ($2 instanceof Eq) {
        let event = new ProjectileDestroyed2(proj_id, new Expired2());
        return [projectiles_acc, prepend(event, events_acc)];
      } else {
        let event = new ProjectileDestroyed2(proj_id, new Expired2());
        return [projectiles_acc, prepend(event, events_acc)];
      }
    }
  );
  let updated_projectiles;
  let destroyed_events;
  updated_projectiles = $[0];
  destroyed_events = $[1];
  return [
    new GameState(
      game_state.tick,
      game_state.players,
      updated_projectiles,
      game_state.enemies
    ),
    destroyed_events
  ];
}
__name(simulate_projectiles, "simulate_projectiles");
function check_collisions(game_state) {
  return [game_state, toList([])];
}
__name(check_collisions, "check_collisions");
function tick(game_state, player_inputs, delta_time) {
  let events = toList([]);
  let $ = process_player_inputs(game_state, player_inputs);
  let new_game_state;
  let input_events;
  new_game_state = $[0];
  input_events = $[1];
  let events$1 = append2(events, input_events);
  let new_game_state$1 = apply_events_to_state(new_game_state, input_events);
  let new_game_state$2 = simulate_player_movement(new_game_state$1, delta_time);
  let $1 = simulate_projectiles(new_game_state$2, delta_time);
  let new_game_state$3;
  let projectile_events;
  new_game_state$3 = $1[0];
  projectile_events = $1[1];
  let events$2 = append2(events$1, projectile_events);
  let new_game_state$4 = simulate_enemy_movement(new_game_state$3, delta_time);
  let $2 = check_collisions(new_game_state$4);
  let new_game_state$5;
  let collision_events;
  new_game_state$5 = $2[0];
  collision_events = $2[1];
  let events$3 = append2(events$2, collision_events);
  return [new_game_state$5, events$3];
}
__name(tick, "tick");

// build/dev/javascript/server/server/game_tick.mjs
var TickScheduler = class extends CustomType {
  static {
    __name(this, "TickScheduler");
  }
  constructor(current_tick2, last_tick_time) {
    super();
    this.current_tick = current_tick2;
    this.last_tick_time = last_tick_time;
  }
};
var tick_duration_ms = 50;
function new$9() {
  return new TickScheduler(0, system_time2());
}
__name(new$9, "new$");
function advance_tick(scheduler) {
  return new TickScheduler(scheduler.current_tick + 1, system_time2());
}
__name(advance_tick, "advance_tick");
function current_tick(scheduler) {
  return scheduler.current_tick;
}
__name(current_tick, "current_tick");
function get_delta_time() {
  return milliseconds(tick_duration_ms);
}
__name(get_delta_time, "get_delta_time");
function next_tick_delay_ms() {
  return tick_duration_ms;
}
__name(next_tick_delay_ms, "next_tick_delay_ms");

// build/dev/javascript/server/server/game_room_do.mjs
var FILEPATH2 = "src/server/game_room_do.gleam";
var GameRoomDOState = class extends CustomType {
  static {
    __name(this, "GameRoomDOState");
  }
  constructor(players, next_player_id, game_state, tick_scheduler, player_inputs) {
    super();
    this.players = players;
    this.next_player_id = next_player_id;
    this.game_state = game_state;
    this.tick_scheduler = tick_scheduler;
    this.player_inputs = player_inputs;
  }
};
var PlayerInfo = class extends CustomType {
  static {
    __name(this, "PlayerInfo");
  }
  constructor(state, ws) {
    super();
    this.state = state;
    this.ws = ws;
  }
};
function init_state() {
  return new GameRoomDOState(
    make(),
    1,
    new$8(),
    new$9(),
    make()
  );
}
__name(init_state, "init_state");
function handle_websocket_upgrade(state, _) {
  let pair2 = new_websocket_pair();
  let client = websocket_pair_client(pair2);
  let server = websocket_pair_server(pair2);
  accept_websocket(state, server);
  let attachment = object2(toList([["player_id", null$()]]));
  websocket_serialize_attachment(server, attachment);
  return websocket_upgrade_response(client);
}
__name(handle_websocket_upgrade, "handle_websocket_upgrade");
function fetch2(state, request) {
  let $ = is_websocket_upgrade(request);
  if ($) {
    return handle_websocket_upgrade(state, request);
  } else {
    return error_response(400, "Expected WebSocket");
  }
}
__name(fetch2, "fetch");
function handle_leave(room_state, player_id) {
  let new_players = delete$(room_state.players, player_id);
  let $ = get(room_state.players, player_id);
  if ($ instanceof Ok) {
    let player_info = $[0];
    websocket_close(player_info.ws, 1e3, "Player left");
  } else {
  }
  let new_state = new GameRoomDOState(
    new_players,
    room_state.next_player_id,
    room_state.game_state,
    room_state.tick_scheduler,
    room_state.player_inputs
  );
  let broadcast_msg = new PlayerLeft(player_id);
  let _block;
  let _pipe = keys(new_players);
  _block = map2(_pipe, (pid) => {
    return [pid, broadcast_msg];
  });
  let messages2 = _block;
  return [new_state, messages2];
}
__name(handle_leave, "handle_leave");
function handle_player_update(room_state, player_id, position) {
  let $ = get(room_state.players, player_id);
  if ($ instanceof Ok) {
    let player_info = $[0];
    let _block;
    let _record = player_info.state;
    _block = new Player(
      _record.id,
      _record.name,
      position,
      _record.rotation,
      _record.health,
      _record.active_wand_slot,
      _record.wands,
      _record.movement_state
    );
    let updated_state = _block;
    let updated_info = new PlayerInfo(updated_state, player_info.ws);
    let new_players = insert(room_state.players, player_id, updated_info);
    let new_state = new GameRoomDOState(
      new_players,
      room_state.next_player_id,
      room_state.game_state,
      room_state.tick_scheduler,
      room_state.player_inputs
    );
    let _block$1;
    let _pipe = values(new_players);
    _block$1 = map2(_pipe, (info) => {
      return info.state;
    });
    let player_states = _block$1;
    let player_states_msg = new PlayerStates(player_states);
    let _block$2;
    let _pipe$1 = keys(new_players);
    _block$2 = map2(_pipe$1, (pid) => {
      return [pid, player_states_msg];
    });
    let messages2 = _block$2;
    return [new_state, messages2];
  } else {
    return [room_state, toList([])];
  }
}
__name(handle_player_update, "handle_player_update");
function handle_ping(room_state, player_id, client_timestamp) {
  let server_timestamp = system_time2();
  let pong_msg = new Pong(client_timestamp, server_timestamp);
  return [room_state, toList([[player_id, pong_msg]])];
}
__name(handle_ping, "handle_ping");
function broadcast_to_all(players, message) {
  let _pipe = values(players);
  return each(
    _pipe,
    (player_info) => {
      return websocket_send(player_info.ws, message);
    }
  );
}
__name(broadcast_to_all, "broadcast_to_all");
function send_error(ws, error_message) {
  let _block;
  let _pipe = object2(
    toList([
      ["type", string3("error")],
      ["message", string3(error_message)]
    ])
  );
  _block = to_string3(_pipe);
  let error_msg = _block;
  return websocket_send(ws, error_msg);
}
__name(send_error, "send_error");
function decode_player_id(attachment) {
  let decoder7 = at(
    toList(["player_id"]),
    optional(
      (() => {
        let _pipe = int2;
        return map3(_pipe, (var0) => {
          return new Id(var0);
        });
      })()
    )
  );
  return run(attachment, decoder7);
}
__name(decode_player_id, "decode_player_id");
function websocket_close2(_, ws, _1, _2, _3, room_state) {
  let attachment = websocket_deserialize_attachment(ws);
  let $ = decode_player_id(attachment);
  if ($ instanceof Ok) {
    let $1 = $[0];
    if ($1 instanceof Some) {
      let player_id = $1[0];
      let new_players = delete$(room_state.players, player_id);
      broadcast_to_all(
        new_players,
        encode_server_message(new PlayerLeft(player_id))
      );
      return new GameRoomDOState(
        new_players,
        room_state.next_player_id,
        room_state.game_state,
        room_state.tick_scheduler,
        room_state.player_inputs
      );
    } else {
      return room_state;
    }
  } else {
    return room_state;
  }
}
__name(websocket_close2, "websocket_close");
function websocket_error(state, ws, _, room_state) {
  return websocket_close2(state, ws, 1011, "WebSocket error", false, room_state);
}
__name(websocket_error, "websocket_error");
function start_tick_loop(state) {
  let storage2 = storage(state);
  let _block;
  let _pipe = system_time2();
  _block = to_unix_seconds(_pipe);
  let now_seconds = _block;
  let now_ms = round(now_seconds * 1e3);
  let next_tick_ms = now_ms + next_tick_delay_ms();
  let $ = set_alarm(storage2, next_tick_ms);
  return void 0;
}
__name(start_tick_loop, "start_tick_loop");
function handle_join(state, room_state, player_id, ws, _, player_name) {
  let $ = size(room_state.players);
  if ($ === 0) {
    start_tick_loop(state);
  } else {
  }
  let new_player = new$7(player_id, player_name, new Vec3(0, 0, 0));
  let player_info = new PlayerInfo(new_player, ws);
  let _block;
  let _pipe = values(room_state.players);
  _block = map2(_pipe, (info) => {
    return info.state;
  });
  let existing_players = _block;
  let new_players = insert(room_state.players, player_id, player_info);
  let new_state = new GameRoomDOState(
    new_players,
    room_state.next_player_id + 1,
    room_state.game_state,
    room_state.tick_scheduler,
    room_state.player_inputs
  );
  let join_msg = new RoomJoined(
    new Id3(1),
    player_id,
    existing_players
  );
  let broadcast_msg = new PlayerJoined(new_player);
  let _block$1;
  let _pipe$1 = keys(room_state.players);
  let _pipe$2 = map2(_pipe$1, (pid) => {
    return [pid, broadcast_msg];
  });
  _block$1 = prepend2(_pipe$2, [player_id, join_msg]);
  let messages2 = _block$1;
  return [new_state, messages2];
}
__name(handle_join, "handle_join");
function handle_message(state, room_state, player_id, ws, msg) {
  if (msg instanceof JoinRoom) {
    let room_id = msg.room_id;
    let player_name = msg.player_name;
    return handle_join(state, room_state, player_id, ws, room_id, player_name);
  } else if (msg instanceof LeaveRoom) {
    return handle_leave(room_state, player_id);
  } else if (msg instanceof PlayerInput) {
    let action = msg.action;
    let new_inputs = insert(room_state.player_inputs, player_id, action);
    let new_state = new GameRoomDOState(
      room_state.players,
      room_state.next_player_id,
      room_state.game_state,
      room_state.tick_scheduler,
      new_inputs
    );
    return [new_state, toList([])];
  } else if (msg instanceof PlayerUpdate) {
    let position = msg.position;
    return handle_player_update(room_state, player_id, position);
  } else {
    let timestamp2 = msg.timestamp;
    return handle_ping(room_state, player_id, timestamp2);
  }
}
__name(handle_message, "handle_message");
function websocket_message(state, ws, message, room_state) {
  let attachment = websocket_deserialize_attachment(ws);
  let _block;
  let $ = decode_player_id(attachment);
  if ($ instanceof Ok) {
    let $12 = $[0];
    if ($12 instanceof Some) {
      let pid = $12[0];
      _block = pid;
    } else {
      let pid = room_state.next_player_id;
      let new_attachment = object2(toList([["player_id", int3(pid)]]));
      websocket_serialize_attachment(ws, new_attachment);
      _block = new Id(pid);
    }
  } else {
    throw makeError(
      "panic",
      FILEPATH2,
      "server/game_room_do",
      104,
      "websocket_message",
      "Failed to decode player ID from attachment",
      {}
    );
  }
  let player_id = _block;
  let $1 = decode_client_message(message);
  if ($1 instanceof Ok) {
    let msg = $1[0];
    let $2 = handle_message(state, room_state, player_id, ws, msg);
    let new_state;
    let messages2;
    new_state = $2[0];
    messages2 = $2[1];
    each(
      messages2,
      (msg_data) => {
        let target_player_id;
        let server_msg;
        target_player_id = msg_data[0];
        server_msg = msg_data[1];
        let $3 = get(new_state.players, target_player_id);
        if ($3 instanceof Ok) {
          let player_info = $3[0];
          let encoded = encode_server_message(server_msg);
          return websocket_send(player_info.ws, encoded);
        } else {
          return void 0;
        }
      }
    );
    return new_state;
  } else {
    send_error(ws, "Failed to parse message");
    return room_state;
  }
}
__name(websocket_message, "websocket_message");
function broadcast_game_state_update(players, tick2, game_state) {
  let players_list = values(game_state.players);
  let projectiles_list = values(game_state.projectiles);
  let enemies_list = values(game_state.enemies);
  let msg = new GameStateUpdate(
    tick2,
    players_list,
    projectiles_list,
    enemies_list
  );
  let encoded = encode_server_message(msg);
  return broadcast_to_all(players, encoded);
}
__name(broadcast_game_state_update, "broadcast_game_state_update");
function broadcast_events(players, events) {
  return each(
    events,
    (event) => {
      let _block;
      if (event instanceof ProjectileCreated) {
        let projectile = event.projectile;
        _block = new ProjectileSpawned(projectile);
      } else if (event instanceof ProjectileDestroyed2) {
        let id4 = event.id;
        let reason = event.reason;
        let _block$1;
        if (reason instanceof HitEnemy2) {
          let enemy_id = reason.enemy_id;
          _block$1 = new HitEnemy(enemy_id);
        } else if (reason instanceof HitPlayer2) {
          let player_id = reason.player_id;
          _block$1 = new HitPlayer(player_id);
        } else {
          _block$1 = new Expired();
        }
        let destroy_reason = _block$1;
        _block = new ProjectileDestroyed(id4, destroy_reason);
      } else if (event instanceof EnemySpawned2) {
        let enemy = event.enemy;
        _block = new EnemySpawned(enemy);
      } else if (event instanceof EnemyDied2) {
        let id4 = event.id;
        _block = new EnemyDied(id4);
      } else {
        let player_id = event.player_id;
        let damage = event.damage;
        let new_health = event.new_health;
        _block = new PlayerDamaged(player_id, damage, new_health);
      }
      let msg = _block;
      let encoded = encode_server_message(msg);
      return broadcast_to_all(players, encoded);
    }
  );
}
__name(broadcast_events, "broadcast_events");
function process_tick(state, room_state) {
  let new_scheduler = advance_tick(room_state.tick_scheduler);
  let current_tick2 = current_tick(new_scheduler);
  let delta_time = get_delta_time();
  let $ = tick(
    room_state.game_state,
    room_state.player_inputs,
    delta_time
  );
  let new_game_state;
  let events;
  new_game_state = $[0];
  events = $[1];
  let new_state = new GameRoomDOState(
    room_state.players,
    room_state.next_player_id,
    new_game_state,
    new_scheduler,
    make()
  );
  broadcast_game_state_update(new_state.players, current_tick2, new_game_state);
  broadcast_events(new_state.players, events);
  let storage2 = storage(state);
  let _block;
  let _pipe = system_time2();
  _block = to_unix_seconds(_pipe);
  let now_seconds = _block;
  let now_ms = round(now_seconds * 1e3);
  let next_tick_ms = now_ms + next_tick_delay_ms();
  let $1 = set_alarm(storage2, next_tick_ms);
  return new_state;
}
__name(process_tick, "process_tick");

// build/dev/javascript/server/server_ffi.mjs
var GameRoom = class {
  static {
    __name(this, "GameRoom");
  }
  constructor(state, env) {
    this.state = state;
    this.env = env;
    this.roomState = init_state();
  }
  // Handle incoming fetch requests (including WebSocket upgrades)
  async fetch(request) {
    return fetch2(this.state, request);
  }
  // Durable Objects WebSocket Hibernation API handlers
  async webSocketMessage(ws, message) {
    console.log("[GameRoom] WebSocket message received");
    this.roomState = websocket_message(
      this.state,
      ws,
      message,
      this.roomState
    );
  }
  async webSocketClose(ws, code, reason, wasClean) {
    console.log("[GameRoom] WebSocket closed");
    this.roomState = websocket_close2(
      this.state,
      ws,
      code,
      reason,
      wasClean,
      this.roomState
    );
  }
  async webSocketError(ws, error) {
    console.error("[GameRoom] WebSocket error:", error);
    this.roomState = websocket_error(
      this.state,
      ws,
      error,
      this.roomState
    );
  }
  // Durable Objects Alarms API handler
  // Called when a scheduled alarm fires (used for game tick)
  async alarm() {
    console.log("[GameRoom] Alarm fired - processing game tick");
    this.roomState = process_tick(
      this.state,
      this.roomState
    );
  }
};

// build/dev/javascript/server/index.mjs
var server_default = { fetch };

// ../../../../.npm/_npx/32026684e21afda6/node_modules/wrangler/templates/middleware/middleware-ensure-req-body-drained.ts
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

// ../../../../.npm/_npx/32026684e21afda6/node_modules/wrangler/templates/middleware/middleware-miniflare3-json-error.ts
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

// .wrangler/tmp/bundle-ouh2YL/middleware-insertion-facade.js
var __INTERNAL_WRANGLER_MIDDLEWARE__ = [
  middleware_ensure_req_body_drained_default,
  middleware_miniflare3_json_error_default
];
var middleware_insertion_facade_default = server_default;

// ../../../../.npm/_npx/32026684e21afda6/node_modules/wrangler/templates/middleware/common.ts
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

// .wrangler/tmp/bundle-ouh2YL/middleware-loader.entry.ts
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
