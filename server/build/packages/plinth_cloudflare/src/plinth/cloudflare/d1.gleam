import gleam/dynamic.{type Dynamic}
import gleam/javascript/array.{type Array}
import gleam/javascript/promise.{type Promise}

pub type Database

// TODO test errors
@external(javascript, "../../plinth_cloudflare_d1_ffi.mjs", "prepare")
pub fn prepare(db: Database, query: String) -> PreparedStatement

pub type PreparedStatement

@external(javascript, "../../plinth_cloudflare_d1_ffi.mjs", "bind")
fn do_bind(
  statement: PreparedStatement,
  values: Array(String),
) -> PreparedStatement

pub fn bind(statement, values) {
  do_bind(statement, array.from_list(values))
}

pub type RunResult {
  RunResult(success: Bool, meta: Dynamic, results: Array(Dynamic))
}

// Errors if syntax error or selecting a field that doesn't exist
@external(javascript, "../../plinth_cloudflare_d1_ffi.mjs", "run")
pub fn run(statement: PreparedStatement) -> Promise(Result(RunResult, String))

@external(javascript, "../../plinth_cloudflare_d1_ffi.mjs", "raw")
pub fn raw(
  statement: PreparedStatement,
) -> Promise(Result(Array(Array(Dynamic)), String))

@external(javascript, "../../plinth_cloudflare_d1_ffi.mjs", "first")
pub fn first(statement: PreparedStatement) -> Promise(Result(Dynamic, String))

@external(javascript, "../../plinth_cloudflare_d1_ffi.mjs", "batch")
fn do_batch(
  db: Database,
  statements: Array(PreparedStatement),
) -> Promise(Result(Array(RunResult), String))

pub fn batch(db, statements) {
  do_batch(db, array.from_list(statements))
}

pub type ExecResult {
  ExecResult(count: Int, duration: Float)
}

@external(javascript, "../../plinth_cloudflare_d1_ffi.mjs", "exec")
pub fn exec(db: Database, query: String) -> Promise(Result(ExecResult, String))
// This API only works on databases created during D1's alpha period.
// dump
