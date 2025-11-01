// Mock FFI functions for testing
// These create minimal objects that satisfy the type checker but aren't actually used

export function mockSpritesheet() {
  return {
    texture: null,
    frameWidth: 1,
    frameHeight: 1,
    columns: 1,
    rows: 1
  };
}

export function mockAnimation() {
  return {
    name: "test",
    frames: [0],
    frameDuration: 1.0,
    loop: { type: "Once" }
  };
}
