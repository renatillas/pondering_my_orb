export function request_pointer_lock_sync() {
  const canvas = document.querySelector('canvas');
  if (!canvas) {
    console.warn('[PointerLock] No canvas element found for pointer lock');
    return;
  }

  // Focus the canvas first to ensure it receives pointer lock
  canvas.focus();

  // Try different vendor-specific APIs
  const requestFn =
    canvas.requestPointerLock ||
    canvas.webkitRequestPointerLock ||
    canvas.mozRequestPointerLock;

  if (requestFn) {
    console.log('[PointerLock] Requesting pointer lock...');
    requestFn.call(canvas);
  } else {
    console.warn('[PointerLock] Pointer Lock API not supported');
  }
}

export function exit_pointer_lock() {
  const exitFn =
    document.exitPointerLock ||
    document.webkitExitPointerLock ||
    document.mozExitPointerLock;

  if (exitFn) {
    console.log('[PointerLock] Exiting pointer lock...');
    exitFn.call(document);
  } else {
    console.warn('[PointerLock] Exit Pointer Lock API not supported');
  }
}
