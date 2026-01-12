import { CustomType as $CustomType } from "../gleam.mjs";

/**
 * Triggered before drawing. Contains the number of milliseconds elapsed.
 */
export class Tick extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Event$Tick = ($0) => new Tick($0);
export const Event$isTick = (value) => value instanceof Tick;
export const Event$Tick$0 = (value) => value[0];

/**
 * Triggered when a key is pressed
 */
export class KeyboardPressed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Event$KeyboardPressed = ($0) => new KeyboardPressed($0);
export const Event$isKeyboardPressed = (value) =>
  value instanceof KeyboardPressed;
export const Event$KeyboardPressed$0 = (value) => value[0];

/**
 * Triggered when a key is released
 */
export class KeyboardRelased extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Event$KeyboardRelased = ($0) => new KeyboardRelased($0);
export const Event$isKeyboardRelased = (value) =>
  value instanceof KeyboardRelased;
export const Event$KeyboardRelased$0 = (value) => value[0];

/**
 * Triggered when the mouse is moved. Contains
 * the `x` and `y` value for the mouse position.
 */
export class MouseMoved extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Event$MouseMoved = ($0, $1) => new MouseMoved($0, $1);
export const Event$isMouseMoved = (value) => value instanceof MouseMoved;
export const Event$MouseMoved$0 = (value) => value[0];
export const Event$MouseMoved$1 = (value) => value[1];

/**
 * Triggered when a mouse button is pressed
 */
export class MousePressed extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Event$MousePressed = ($0) => new MousePressed($0);
export const Event$isMousePressed = (value) => value instanceof MousePressed;
export const Event$MousePressed$0 = (value) => value[0];

/**
 * Triggered when a mouse button is released.
 *
 * Note, on the web you might encounter issues where the
 * release event for the right mouse button is not triggered
 * because of the context menu.
 */
export class MouseReleased extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Event$MouseReleased = ($0) => new MouseReleased($0);
export const Event$isMouseReleased = (value) => value instanceof MouseReleased;
export const Event$MouseReleased$0 = (value) => value[0];

export class KeyLeftArrow extends $CustomType {}
export const Key$KeyLeftArrow = () => new KeyLeftArrow();
export const Key$isKeyLeftArrow = (value) => value instanceof KeyLeftArrow;

export class KeyRightArrow extends $CustomType {}
export const Key$KeyRightArrow = () => new KeyRightArrow();
export const Key$isKeyRightArrow = (value) => value instanceof KeyRightArrow;

export class KeyUpArrow extends $CustomType {}
export const Key$KeyUpArrow = () => new KeyUpArrow();
export const Key$isKeyUpArrow = (value) => value instanceof KeyUpArrow;

export class KeyDownArrow extends $CustomType {}
export const Key$KeyDownArrow = () => new KeyDownArrow();
export const Key$isKeyDownArrow = (value) => value instanceof KeyDownArrow;

export class KeySpace extends $CustomType {}
export const Key$KeySpace = () => new KeySpace();
export const Key$isKeySpace = (value) => value instanceof KeySpace;

export class KeyW extends $CustomType {}
export const Key$KeyW = () => new KeyW();
export const Key$isKeyW = (value) => value instanceof KeyW;

export class KeyA extends $CustomType {}
export const Key$KeyA = () => new KeyA();
export const Key$isKeyA = (value) => value instanceof KeyA;

export class KeyS extends $CustomType {}
export const Key$KeyS = () => new KeyS();
export const Key$isKeyS = (value) => value instanceof KeyS;

export class KeyD extends $CustomType {}
export const Key$KeyD = () => new KeyD();
export const Key$isKeyD = (value) => value instanceof KeyD;

export class KeyZ extends $CustomType {}
export const Key$KeyZ = () => new KeyZ();
export const Key$isKeyZ = (value) => value instanceof KeyZ;

export class KeyX extends $CustomType {}
export const Key$KeyX = () => new KeyX();
export const Key$isKeyX = (value) => value instanceof KeyX;

export class KeyC extends $CustomType {}
export const Key$KeyC = () => new KeyC();
export const Key$isKeyC = (value) => value instanceof KeyC;

export class KeyEnter extends $CustomType {}
export const Key$KeyEnter = () => new KeyEnter();
export const Key$isKeyEnter = (value) => value instanceof KeyEnter;

export class KeyEscape extends $CustomType {}
export const Key$KeyEscape = () => new KeyEscape();
export const Key$isKeyEscape = (value) => value instanceof KeyEscape;

export class KeyBackspace extends $CustomType {}
export const Key$KeyBackspace = () => new KeyBackspace();
export const Key$isKeyBackspace = (value) => value instanceof KeyBackspace;

export class MouseButtonLeft extends $CustomType {}
export const MouseButton$MouseButtonLeft = () => new MouseButtonLeft();
export const MouseButton$isMouseButtonLeft = (value) =>
  value instanceof MouseButtonLeft;

export class MouseButtonRight extends $CustomType {}
export const MouseButton$MouseButtonRight = () => new MouseButtonRight();
export const MouseButton$isMouseButtonRight = (value) =>
  value instanceof MouseButtonRight;

export class MouseButtonMiddle extends $CustomType {}
export const MouseButton$MouseButtonMiddle = () => new MouseButtonMiddle();
export const MouseButton$isMouseButtonMiddle = (value) =>
  value instanceof MouseButtonMiddle;
