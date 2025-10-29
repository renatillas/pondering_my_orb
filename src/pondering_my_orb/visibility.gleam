import lustre/effect

pub type VisibilityMsg {
  PageHidden
  PageVisible
}

@external(javascript, "./visibility.ffi.mjs", "setup_visibility_listener_ffi")
fn setup_visibility_listener_ffi(
  on_hidden: fn() -> msg,
  on_visible: fn() -> msg,
  dispatch: fn(msg) -> Nil,
) -> Nil

pub fn setup_visibility_listener(
  on_hidden: fn() -> msg,
  on_visible: fn() -> msg,
) -> effect.Effect(msg) {
  effect.from(fn(dispatch) {
    setup_visibility_listener_ffi(on_hidden, on_visible, dispatch)
  })
}
