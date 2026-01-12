import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option, None}

pub type Bucket

pub type Object

pub type ObjectBody

pub type MultipartUpload

// pub fn head(_bucket: Bucket, _key: String) -> Promise(Result(Object, Nil)) {
//   todo
// }

pub type GetOptions {
  GetOptions
}

pub fn get_options() {
  GetOptions
}

@external(javascript, "../../plinth_cloudflare_r2_ffi.mjs", "get")
fn do_get(bucket: Bucket, key: String) -> Promise(Result(ObjectBody, Nil))

pub fn get(
  bucket: Bucket,
  key: String,
  _options: GetOptions,
) -> Promise(Result(ObjectBody, Nil)) {
  do_get(bucket, key)
}

@external(javascript, "../../plinth_cloudflare_r2_ffi.mjs", "read_bytes")
pub fn read_bytes(object: ObjectBody) -> Promise(Result(BitArray, Nil))

pub type PutOptions {
  PutOptions
}

pub fn put_options() {
  PutOptions
}

@external(javascript, "../../plinth_cloudflare_r2_ffi.mjs", "put")
fn do_put(
  bucket: Bucket,
  key: String,
  value: BitArray,
) -> Promise(Result(Object, Nil))

pub fn put(
  bucket: Bucket,
  key: String,
  value: BitArray,
  _options: PutOptions,
) -> Promise(Result(Object, Nil)) {
  do_put(bucket, key, value)
}

// pub fn delete(
//   bucket: Bucket,
//   keys: List(String),
//   options: ListOptions,
// ) -> Promise(Result(Objects, Nil)) {
//   todo
// }

pub type ListOptions {
  ListOptions(
    limit: Option(Int),
    prefix: Option(String),
    cursor: Option(String),
    delimiter: Option(String),
    include: Option(List(String)),
  )
}

pub fn list_options() {
  ListOptions(
    limit: None,
    prefix: None,
    cursor: None,
    delimiter: None,
    include: None,
  )
}

pub type Objects

// pub fn list(bucket: Bucket, options: ListOptions) -> Promise(Objects) {
//   todo
// }

pub type MultipartOptions
