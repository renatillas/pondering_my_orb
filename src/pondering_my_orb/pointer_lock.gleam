import lustre/effect

@external(javascript, "./pointer_lock.ffi.mjs", "setup_pointer_lock_listener_ffi")
fn setup_pointer_lock_listener_ffi(
  on_lock_exit: fn() -> msg,
  on_lock_acquired: fn() -> msg,
  dispatch: fn(msg) -> Nil,
) -> Nil

pub fn setup_pointer_lock_listener(
  on_lock_exit: fn() -> msg,
  on_lock_acquired: fn() -> msg,
) -> effect.Effect(msg) {
  effect.from(fn(dispatch) {
    setup_pointer_lock_listener_ffi(on_lock_exit, on_lock_acquired, dispatch)
  })
}
