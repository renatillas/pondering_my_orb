export function setup_visibility_listener_ffi(on_hidden, on_visible, dispatch) {
  const handler = () => {
    if (document.hidden) {
      dispatch(on_hidden());
    } else {
      dispatch(on_visible());
    }
  };

  document.addEventListener("visibilitychange", handler);
}
