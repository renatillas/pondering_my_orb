export function setup_pointer_lock_listener_ffi(on_lock_exit, on_lock_acquired, dispatch) {
  const handler = () => {
    // Check if pointer lock was exited or acquired
    const lockedElement =
      document.pointerLockElement ||
      document.webkitPointerLockElement ||
      document.mozPointerLockElement;

    if (!lockedElement) {
      // Pointer lock was exited
      dispatch(on_lock_exit());
    } else {
      // Pointer lock was acquired
      dispatch(on_lock_acquired());
    }
  };

  document.addEventListener("pointerlockchange", handler);
  document.addEventListener("webkitpointerlockchange", handler);
  document.addEventListener("mozpointerlockchange", handler);
}
