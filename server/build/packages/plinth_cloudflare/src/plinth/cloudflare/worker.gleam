import gleam/javascript/promise.{type Promise}

pub type Context

@external(javascript, "../../plinth_cloudflare_worker_ffi.mjs", "wait_until")
pub fn wait_until(ctx: Context, promise: Promise(t)) -> Nil
