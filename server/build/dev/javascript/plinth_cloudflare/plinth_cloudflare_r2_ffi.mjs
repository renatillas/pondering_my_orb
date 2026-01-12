import { Ok, Error, toBitArray } from "./gleam.mjs";

export async function get(bucket, key, options) {
  const object = await bucket.get(key, options)
  if (object === null) {
    return new Error()
  }
  return new Ok(object);
}

export async function read_bytes(object) {
  const bytes = await object.arrayBuffer()
  return new Ok(toBitArray(new Uint8Array(bytes)));
}

export async function put(bucket, key, data, options) {
  const object = await bucket.put(key, data.rawBuffer, options)
  if (object === null) {
    return new Error()
  }
  return new Ok(object);
}