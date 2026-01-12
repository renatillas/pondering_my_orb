import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $set from "../../gleam_stdlib/gleam/set.mjs";
import * as $vec2 from "../../vec/vec/vec2.mjs";
import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  isEqual,
} from "../gleam.mjs";

class InputState extends $CustomType {
  constructor(keyboard, mouse, gamepad, touch) {
    super();
    this.keyboard = keyboard;
    this.mouse = mouse;
    this.gamepad = gamepad;
    this.touch = touch;
  }
}

class KeyboardState extends $CustomType {
  constructor(pressed_keys, just_pressed_keys, just_released_keys) {
    super();
    this.pressed_keys = pressed_keys;
    this.just_pressed_keys = just_pressed_keys;
    this.just_released_keys = just_released_keys;
  }
}

class MouseState extends $CustomType {
  constructor(x, y, delta_x, delta_y, wheel_delta, left_button, middle_button, right_button) {
    super();
    this.x = x;
    this.y = y;
    this.delta_x = delta_x;
    this.delta_y = delta_y;
    this.wheel_delta = wheel_delta;
    this.left_button = left_button;
    this.middle_button = middle_button;
    this.right_button = right_button;
  }
}

export class ButtonState extends $CustomType {
  constructor(pressed, just_pressed, just_released) {
    super();
    this.pressed = pressed;
    this.just_pressed = just_pressed;
    this.just_released = just_released;
  }
}
export const ButtonState$ButtonState = (pressed, just_pressed, just_released) =>
  new ButtonState(pressed, just_pressed, just_released);
export const ButtonState$isButtonState = (value) =>
  value instanceof ButtonState;
export const ButtonState$ButtonState$pressed = (value) => value.pressed;
export const ButtonState$ButtonState$0 = (value) => value.pressed;
export const ButtonState$ButtonState$just_pressed = (value) =>
  value.just_pressed;
export const ButtonState$ButtonState$1 = (value) => value.just_pressed;
export const ButtonState$ButtonState$just_released = (value) =>
  value.just_released;
export const ButtonState$ButtonState$2 = (value) => value.just_released;

export class GamepadState extends $CustomType {
  constructor(connected, buttons, axes) {
    super();
    this.connected = connected;
    this.buttons = buttons;
    this.axes = axes;
  }
}
export const GamepadState$GamepadState = (connected, buttons, axes) =>
  new GamepadState(connected, buttons, axes);
export const GamepadState$isGamepadState = (value) =>
  value instanceof GamepadState;
export const GamepadState$GamepadState$connected = (value) => value.connected;
export const GamepadState$GamepadState$0 = (value) => value.connected;
export const GamepadState$GamepadState$buttons = (value) => value.buttons;
export const GamepadState$GamepadState$1 = (value) => value.buttons;
export const GamepadState$GamepadState$axes = (value) => value.axes;
export const GamepadState$GamepadState$2 = (value) => value.axes;

export class TouchState extends $CustomType {
  constructor(touches, touches_just_started, touches_just_ended) {
    super();
    this.touches = touches;
    this.touches_just_started = touches_just_started;
    this.touches_just_ended = touches_just_ended;
  }
}
export const TouchState$TouchState = (touches, touches_just_started, touches_just_ended) =>
  new TouchState(touches, touches_just_started, touches_just_ended);
export const TouchState$isTouchState = (value) => value instanceof TouchState;
export const TouchState$TouchState$touches = (value) => value.touches;
export const TouchState$TouchState$0 = (value) => value.touches;
export const TouchState$TouchState$touches_just_started = (value) =>
  value.touches_just_started;
export const TouchState$TouchState$1 = (value) => value.touches_just_started;
export const TouchState$TouchState$touches_just_ended = (value) =>
  value.touches_just_ended;
export const TouchState$TouchState$2 = (value) => value.touches_just_ended;

export class Touch extends $CustomType {
  constructor(id, position) {
    super();
    this.id = id;
    this.position = position;
  }
}
export const Touch$Touch = (id, position) => new Touch(id, position);
export const Touch$isTouch = (value) => value instanceof Touch;
export const Touch$Touch$id = (value) => value.id;
export const Touch$Touch$0 = (value) => value.id;
export const Touch$Touch$position = (value) => value.position;
export const Touch$Touch$1 = (value) => value.position;

export class KeyA extends $CustomType {}
export const Key$KeyA = () => new KeyA();
export const Key$isKeyA = (value) => value instanceof KeyA;

export class KeyB extends $CustomType {}
export const Key$KeyB = () => new KeyB();
export const Key$isKeyB = (value) => value instanceof KeyB;

export class KeyC extends $CustomType {}
export const Key$KeyC = () => new KeyC();
export const Key$isKeyC = (value) => value instanceof KeyC;

export class KeyD extends $CustomType {}
export const Key$KeyD = () => new KeyD();
export const Key$isKeyD = (value) => value instanceof KeyD;

export class KeyE extends $CustomType {}
export const Key$KeyE = () => new KeyE();
export const Key$isKeyE = (value) => value instanceof KeyE;

export class KeyF extends $CustomType {}
export const Key$KeyF = () => new KeyF();
export const Key$isKeyF = (value) => value instanceof KeyF;

export class KeyG extends $CustomType {}
export const Key$KeyG = () => new KeyG();
export const Key$isKeyG = (value) => value instanceof KeyG;

export class KeyH extends $CustomType {}
export const Key$KeyH = () => new KeyH();
export const Key$isKeyH = (value) => value instanceof KeyH;

export class KeyI extends $CustomType {}
export const Key$KeyI = () => new KeyI();
export const Key$isKeyI = (value) => value instanceof KeyI;

export class KeyJ extends $CustomType {}
export const Key$KeyJ = () => new KeyJ();
export const Key$isKeyJ = (value) => value instanceof KeyJ;

export class KeyK extends $CustomType {}
export const Key$KeyK = () => new KeyK();
export const Key$isKeyK = (value) => value instanceof KeyK;

export class KeyL extends $CustomType {}
export const Key$KeyL = () => new KeyL();
export const Key$isKeyL = (value) => value instanceof KeyL;

export class KeyM extends $CustomType {}
export const Key$KeyM = () => new KeyM();
export const Key$isKeyM = (value) => value instanceof KeyM;

export class KeyN extends $CustomType {}
export const Key$KeyN = () => new KeyN();
export const Key$isKeyN = (value) => value instanceof KeyN;

export class KeyO extends $CustomType {}
export const Key$KeyO = () => new KeyO();
export const Key$isKeyO = (value) => value instanceof KeyO;

export class KeyP extends $CustomType {}
export const Key$KeyP = () => new KeyP();
export const Key$isKeyP = (value) => value instanceof KeyP;

export class KeyQ extends $CustomType {}
export const Key$KeyQ = () => new KeyQ();
export const Key$isKeyQ = (value) => value instanceof KeyQ;

export class KeyR extends $CustomType {}
export const Key$KeyR = () => new KeyR();
export const Key$isKeyR = (value) => value instanceof KeyR;

export class KeyS extends $CustomType {}
export const Key$KeyS = () => new KeyS();
export const Key$isKeyS = (value) => value instanceof KeyS;

export class KeyT extends $CustomType {}
export const Key$KeyT = () => new KeyT();
export const Key$isKeyT = (value) => value instanceof KeyT;

export class KeyU extends $CustomType {}
export const Key$KeyU = () => new KeyU();
export const Key$isKeyU = (value) => value instanceof KeyU;

export class KeyV extends $CustomType {}
export const Key$KeyV = () => new KeyV();
export const Key$isKeyV = (value) => value instanceof KeyV;

export class KeyW extends $CustomType {}
export const Key$KeyW = () => new KeyW();
export const Key$isKeyW = (value) => value instanceof KeyW;

export class KeyX extends $CustomType {}
export const Key$KeyX = () => new KeyX();
export const Key$isKeyX = (value) => value instanceof KeyX;

export class KeyY extends $CustomType {}
export const Key$KeyY = () => new KeyY();
export const Key$isKeyY = (value) => value instanceof KeyY;

export class KeyZ extends $CustomType {}
export const Key$KeyZ = () => new KeyZ();
export const Key$isKeyZ = (value) => value instanceof KeyZ;

export class Digit0 extends $CustomType {}
export const Key$Digit0 = () => new Digit0();
export const Key$isDigit0 = (value) => value instanceof Digit0;

export class Digit1 extends $CustomType {}
export const Key$Digit1 = () => new Digit1();
export const Key$isDigit1 = (value) => value instanceof Digit1;

export class Digit2 extends $CustomType {}
export const Key$Digit2 = () => new Digit2();
export const Key$isDigit2 = (value) => value instanceof Digit2;

export class Digit3 extends $CustomType {}
export const Key$Digit3 = () => new Digit3();
export const Key$isDigit3 = (value) => value instanceof Digit3;

export class Digit4 extends $CustomType {}
export const Key$Digit4 = () => new Digit4();
export const Key$isDigit4 = (value) => value instanceof Digit4;

export class Digit5 extends $CustomType {}
export const Key$Digit5 = () => new Digit5();
export const Key$isDigit5 = (value) => value instanceof Digit5;

export class Digit6 extends $CustomType {}
export const Key$Digit6 = () => new Digit6();
export const Key$isDigit6 = (value) => value instanceof Digit6;

export class Digit7 extends $CustomType {}
export const Key$Digit7 = () => new Digit7();
export const Key$isDigit7 = (value) => value instanceof Digit7;

export class Digit8 extends $CustomType {}
export const Key$Digit8 = () => new Digit8();
export const Key$isDigit8 = (value) => value instanceof Digit8;

export class Digit9 extends $CustomType {}
export const Key$Digit9 = () => new Digit9();
export const Key$isDigit9 = (value) => value instanceof Digit9;

export class F1 extends $CustomType {}
export const Key$F1 = () => new F1();
export const Key$isF1 = (value) => value instanceof F1;

export class F2 extends $CustomType {}
export const Key$F2 = () => new F2();
export const Key$isF2 = (value) => value instanceof F2;

export class F3 extends $CustomType {}
export const Key$F3 = () => new F3();
export const Key$isF3 = (value) => value instanceof F3;

export class F4 extends $CustomType {}
export const Key$F4 = () => new F4();
export const Key$isF4 = (value) => value instanceof F4;

export class F5 extends $CustomType {}
export const Key$F5 = () => new F5();
export const Key$isF5 = (value) => value instanceof F5;

export class F6 extends $CustomType {}
export const Key$F6 = () => new F6();
export const Key$isF6 = (value) => value instanceof F6;

export class F7 extends $CustomType {}
export const Key$F7 = () => new F7();
export const Key$isF7 = (value) => value instanceof F7;

export class F8 extends $CustomType {}
export const Key$F8 = () => new F8();
export const Key$isF8 = (value) => value instanceof F8;

export class F9 extends $CustomType {}
export const Key$F9 = () => new F9();
export const Key$isF9 = (value) => value instanceof F9;

export class F10 extends $CustomType {}
export const Key$F10 = () => new F10();
export const Key$isF10 = (value) => value instanceof F10;

export class F11 extends $CustomType {}
export const Key$F11 = () => new F11();
export const Key$isF11 = (value) => value instanceof F11;

export class F12 extends $CustomType {}
export const Key$F12 = () => new F12();
export const Key$isF12 = (value) => value instanceof F12;

export class ArrowUp extends $CustomType {}
export const Key$ArrowUp = () => new ArrowUp();
export const Key$isArrowUp = (value) => value instanceof ArrowUp;

export class ArrowDown extends $CustomType {}
export const Key$ArrowDown = () => new ArrowDown();
export const Key$isArrowDown = (value) => value instanceof ArrowDown;

export class ArrowLeft extends $CustomType {}
export const Key$ArrowLeft = () => new ArrowLeft();
export const Key$isArrowLeft = (value) => value instanceof ArrowLeft;

export class ArrowRight extends $CustomType {}
export const Key$ArrowRight = () => new ArrowRight();
export const Key$isArrowRight = (value) => value instanceof ArrowRight;

export class ShiftLeft extends $CustomType {}
export const Key$ShiftLeft = () => new ShiftLeft();
export const Key$isShiftLeft = (value) => value instanceof ShiftLeft;

export class ShiftRight extends $CustomType {}
export const Key$ShiftRight = () => new ShiftRight();
export const Key$isShiftRight = (value) => value instanceof ShiftRight;

export class ControlLeft extends $CustomType {}
export const Key$ControlLeft = () => new ControlLeft();
export const Key$isControlLeft = (value) => value instanceof ControlLeft;

export class ControlRight extends $CustomType {}
export const Key$ControlRight = () => new ControlRight();
export const Key$isControlRight = (value) => value instanceof ControlRight;

export class AltLeft extends $CustomType {}
export const Key$AltLeft = () => new AltLeft();
export const Key$isAltLeft = (value) => value instanceof AltLeft;

export class AltRight extends $CustomType {}
export const Key$AltRight = () => new AltRight();
export const Key$isAltRight = (value) => value instanceof AltRight;

export class MetaLeft extends $CustomType {}
export const Key$MetaLeft = () => new MetaLeft();
export const Key$isMetaLeft = (value) => value instanceof MetaLeft;

export class MetaRight extends $CustomType {}
export const Key$MetaRight = () => new MetaRight();
export const Key$isMetaRight = (value) => value instanceof MetaRight;

export class Space extends $CustomType {}
export const Key$Space = () => new Space();
export const Key$isSpace = (value) => value instanceof Space;

export class Enter extends $CustomType {}
export const Key$Enter = () => new Enter();
export const Key$isEnter = (value) => value instanceof Enter;

export class Escape extends $CustomType {}
export const Key$Escape = () => new Escape();
export const Key$isEscape = (value) => value instanceof Escape;

export class Tab extends $CustomType {}
export const Key$Tab = () => new Tab();
export const Key$isTab = (value) => value instanceof Tab;

export class Backspace extends $CustomType {}
export const Key$Backspace = () => new Backspace();
export const Key$isBackspace = (value) => value instanceof Backspace;

export class Delete extends $CustomType {}
export const Key$Delete = () => new Delete();
export const Key$isDelete = (value) => value instanceof Delete;

export class Insert extends $CustomType {}
export const Key$Insert = () => new Insert();
export const Key$isInsert = (value) => value instanceof Insert;

export class Home extends $CustomType {}
export const Key$Home = () => new Home();
export const Key$isHome = (value) => value instanceof Home;

export class End extends $CustomType {}
export const Key$End = () => new End();
export const Key$isEnd = (value) => value instanceof End;

export class PageUp extends $CustomType {}
export const Key$PageUp = () => new PageUp();
export const Key$isPageUp = (value) => value instanceof PageUp;

export class PageDown extends $CustomType {}
export const Key$PageDown = () => new PageDown();
export const Key$isPageDown = (value) => value instanceof PageDown;

export class CapsLock extends $CustomType {}
export const Key$CapsLock = () => new CapsLock();
export const Key$isCapsLock = (value) => value instanceof CapsLock;

export class Minus extends $CustomType {}
export const Key$Minus = () => new Minus();
export const Key$isMinus = (value) => value instanceof Minus;

export class Equal extends $CustomType {}
export const Key$Equal = () => new Equal();
export const Key$isEqual = (value) => value instanceof Equal;

export class BracketLeft extends $CustomType {}
export const Key$BracketLeft = () => new BracketLeft();
export const Key$isBracketLeft = (value) => value instanceof BracketLeft;

export class BracketRight extends $CustomType {}
export const Key$BracketRight = () => new BracketRight();
export const Key$isBracketRight = (value) => value instanceof BracketRight;

export class Backslash extends $CustomType {}
export const Key$Backslash = () => new Backslash();
export const Key$isBackslash = (value) => value instanceof Backslash;

export class Semicolon extends $CustomType {}
export const Key$Semicolon = () => new Semicolon();
export const Key$isSemicolon = (value) => value instanceof Semicolon;

export class Quote extends $CustomType {}
export const Key$Quote = () => new Quote();
export const Key$isQuote = (value) => value instanceof Quote;

export class Comma extends $CustomType {}
export const Key$Comma = () => new Comma();
export const Key$isComma = (value) => value instanceof Comma;

export class Period extends $CustomType {}
export const Key$Period = () => new Period();
export const Key$isPeriod = (value) => value instanceof Period;

export class Slash extends $CustomType {}
export const Key$Slash = () => new Slash();
export const Key$isSlash = (value) => value instanceof Slash;

export class Backquote extends $CustomType {}
export const Key$Backquote = () => new Backquote();
export const Key$isBackquote = (value) => value instanceof Backquote;

export class Numpad0 extends $CustomType {}
export const Key$Numpad0 = () => new Numpad0();
export const Key$isNumpad0 = (value) => value instanceof Numpad0;

export class Numpad1 extends $CustomType {}
export const Key$Numpad1 = () => new Numpad1();
export const Key$isNumpad1 = (value) => value instanceof Numpad1;

export class Numpad2 extends $CustomType {}
export const Key$Numpad2 = () => new Numpad2();
export const Key$isNumpad2 = (value) => value instanceof Numpad2;

export class Numpad3 extends $CustomType {}
export const Key$Numpad3 = () => new Numpad3();
export const Key$isNumpad3 = (value) => value instanceof Numpad3;

export class Numpad4 extends $CustomType {}
export const Key$Numpad4 = () => new Numpad4();
export const Key$isNumpad4 = (value) => value instanceof Numpad4;

export class Numpad5 extends $CustomType {}
export const Key$Numpad5 = () => new Numpad5();
export const Key$isNumpad5 = (value) => value instanceof Numpad5;

export class Numpad6 extends $CustomType {}
export const Key$Numpad6 = () => new Numpad6();
export const Key$isNumpad6 = (value) => value instanceof Numpad6;

export class Numpad7 extends $CustomType {}
export const Key$Numpad7 = () => new Numpad7();
export const Key$isNumpad7 = (value) => value instanceof Numpad7;

export class Numpad8 extends $CustomType {}
export const Key$Numpad8 = () => new Numpad8();
export const Key$isNumpad8 = (value) => value instanceof Numpad8;

export class Numpad9 extends $CustomType {}
export const Key$Numpad9 = () => new Numpad9();
export const Key$isNumpad9 = (value) => value instanceof Numpad9;

export class NumpadAdd extends $CustomType {}
export const Key$NumpadAdd = () => new NumpadAdd();
export const Key$isNumpadAdd = (value) => value instanceof NumpadAdd;

export class NumpadSubtract extends $CustomType {}
export const Key$NumpadSubtract = () => new NumpadSubtract();
export const Key$isNumpadSubtract = (value) => value instanceof NumpadSubtract;

export class NumpadMultiply extends $CustomType {}
export const Key$NumpadMultiply = () => new NumpadMultiply();
export const Key$isNumpadMultiply = (value) => value instanceof NumpadMultiply;

export class NumpadDivide extends $CustomType {}
export const Key$NumpadDivide = () => new NumpadDivide();
export const Key$isNumpadDivide = (value) => value instanceof NumpadDivide;

export class NumpadDecimal extends $CustomType {}
export const Key$NumpadDecimal = () => new NumpadDecimal();
export const Key$isNumpadDecimal = (value) => value instanceof NumpadDecimal;

export class NumpadEnter extends $CustomType {}
export const Key$NumpadEnter = () => new NumpadEnter();
export const Key$isNumpadEnter = (value) => value instanceof NumpadEnter;

export class NumLock extends $CustomType {}
export const Key$NumLock = () => new NumLock();
export const Key$isNumLock = (value) => value instanceof NumLock;

export class AudioVolumeUp extends $CustomType {}
export const Key$AudioVolumeUp = () => new AudioVolumeUp();
export const Key$isAudioVolumeUp = (value) => value instanceof AudioVolumeUp;

export class AudioVolumeDown extends $CustomType {}
export const Key$AudioVolumeDown = () => new AudioVolumeDown();
export const Key$isAudioVolumeDown = (value) =>
  value instanceof AudioVolumeDown;

export class AudioVolumeMute extends $CustomType {}
export const Key$AudioVolumeMute = () => new AudioVolumeMute();
export const Key$isAudioVolumeMute = (value) =>
  value instanceof AudioVolumeMute;

export class MediaPlayPause extends $CustomType {}
export const Key$MediaPlayPause = () => new MediaPlayPause();
export const Key$isMediaPlayPause = (value) => value instanceof MediaPlayPause;

export class MediaStop extends $CustomType {}
export const Key$MediaStop = () => new MediaStop();
export const Key$isMediaStop = (value) => value instanceof MediaStop;

export class MediaTrackNext extends $CustomType {}
export const Key$MediaTrackNext = () => new MediaTrackNext();
export const Key$isMediaTrackNext = (value) => value instanceof MediaTrackNext;

export class MediaTrackPrevious extends $CustomType {}
export const Key$MediaTrackPrevious = () => new MediaTrackPrevious();
export const Key$isMediaTrackPrevious = (value) =>
  value instanceof MediaTrackPrevious;

export class PrintScreen extends $CustomType {}
export const Key$PrintScreen = () => new PrintScreen();
export const Key$isPrintScreen = (value) => value instanceof PrintScreen;

export class ScrollLock extends $CustomType {}
export const Key$ScrollLock = () => new ScrollLock();
export const Key$isScrollLock = (value) => value instanceof ScrollLock;

export class Pause extends $CustomType {}
export const Key$Pause = () => new Pause();
export const Key$isPause = (value) => value instanceof Pause;

export class ContextMenu extends $CustomType {}
export const Key$ContextMenu = () => new ContextMenu();
export const Key$isContextMenu = (value) => value instanceof ContextMenu;

export class Custom extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Key$Custom = ($0) => new Custom($0);
export const Key$isCustom = (value) => value instanceof Custom;
export const Key$Custom$0 = (value) => value[0];

export class ButtonA extends $CustomType {}
export const GamepadButton$ButtonA = () => new ButtonA();
export const GamepadButton$isButtonA = (value) => value instanceof ButtonA;

export class ButtonB extends $CustomType {}
export const GamepadButton$ButtonB = () => new ButtonB();
export const GamepadButton$isButtonB = (value) => value instanceof ButtonB;

export class ButtonX extends $CustomType {}
export const GamepadButton$ButtonX = () => new ButtonX();
export const GamepadButton$isButtonX = (value) => value instanceof ButtonX;

export class ButtonY extends $CustomType {}
export const GamepadButton$ButtonY = () => new ButtonY();
export const GamepadButton$isButtonY = (value) => value instanceof ButtonY;

export class LeftBumper extends $CustomType {}
export const GamepadButton$LeftBumper = () => new LeftBumper();
export const GamepadButton$isLeftBumper = (value) =>
  value instanceof LeftBumper;

export class RightBumper extends $CustomType {}
export const GamepadButton$RightBumper = () => new RightBumper();
export const GamepadButton$isRightBumper = (value) =>
  value instanceof RightBumper;

export class LeftTrigger extends $CustomType {}
export const GamepadButton$LeftTrigger = () => new LeftTrigger();
export const GamepadButton$isLeftTrigger = (value) =>
  value instanceof LeftTrigger;

export class RightTrigger extends $CustomType {}
export const GamepadButton$RightTrigger = () => new RightTrigger();
export const GamepadButton$isRightTrigger = (value) =>
  value instanceof RightTrigger;

export class Select extends $CustomType {}
export const GamepadButton$Select = () => new Select();
export const GamepadButton$isSelect = (value) => value instanceof Select;

export class Start extends $CustomType {}
export const GamepadButton$Start = () => new Start();
export const GamepadButton$isStart = (value) => value instanceof Start;

export class LeftStick extends $CustomType {}
export const GamepadButton$LeftStick = () => new LeftStick();
export const GamepadButton$isLeftStick = (value) => value instanceof LeftStick;

export class RightStick extends $CustomType {}
export const GamepadButton$RightStick = () => new RightStick();
export const GamepadButton$isRightStick = (value) =>
  value instanceof RightStick;

export class DPadUp extends $CustomType {}
export const GamepadButton$DPadUp = () => new DPadUp();
export const GamepadButton$isDPadUp = (value) => value instanceof DPadUp;

export class DPadDown extends $CustomType {}
export const GamepadButton$DPadDown = () => new DPadDown();
export const GamepadButton$isDPadDown = (value) => value instanceof DPadDown;

export class DPadLeft extends $CustomType {}
export const GamepadButton$DPadLeft = () => new DPadLeft();
export const GamepadButton$isDPadLeft = (value) => value instanceof DPadLeft;

export class DPadRight extends $CustomType {}
export const GamepadButton$DPadRight = () => new DPadRight();
export const GamepadButton$isDPadRight = (value) => value instanceof DPadRight;

export class HomeButton extends $CustomType {}
export const GamepadButton$HomeButton = () => new HomeButton();
export const GamepadButton$isHomeButton = (value) =>
  value instanceof HomeButton;

export class LeftStickX extends $CustomType {}
export const GamepadAxis$LeftStickX = () => new LeftStickX();
export const GamepadAxis$isLeftStickX = (value) => value instanceof LeftStickX;

export class LeftStickY extends $CustomType {}
export const GamepadAxis$LeftStickY = () => new LeftStickY();
export const GamepadAxis$isLeftStickY = (value) => value instanceof LeftStickY;

export class RightStickX extends $CustomType {}
export const GamepadAxis$RightStickX = () => new RightStickX();
export const GamepadAxis$isRightStickX = (value) =>
  value instanceof RightStickX;

export class RightStickY extends $CustomType {}
export const GamepadAxis$RightStickY = () => new RightStickY();
export const GamepadAxis$isRightStickY = (value) =>
  value instanceof RightStickY;

export class LeftButton extends $CustomType {}
export const MouseButton$LeftButton = () => new LeftButton();
export const MouseButton$isLeftButton = (value) => value instanceof LeftButton;

export class RightButton extends $CustomType {}
export const MouseButton$RightButton = () => new RightButton();
export const MouseButton$isRightButton = (value) =>
  value instanceof RightButton;

export class MiddleButton extends $CustomType {}
export const MouseButton$MiddleButton = () => new MiddleButton();
export const MouseButton$isMiddleButton = (value) =>
  value instanceof MiddleButton;

class InputBindings extends $CustomType {
  constructor(key_to_action, mouse_to_action, gamepad_to_action) {
    super();
    this.key_to_action = key_to_action;
    this.mouse_to_action = mouse_to_action;
    this.gamepad_to_action = gamepad_to_action;
  }
}

class BufferedInput extends $CustomType {
  constructor(buffer, buffer_frames, frame_counter) {
    super();
    this.buffer = buffer;
    this.buffer_frames = buffer_frames;
    this.frame_counter = frame_counter;
  }
}

class BufferedAction extends $CustomType {
  constructor(action, frame) {
    super();
    this.action = action;
    this.frame = frame;
  }
}

export function new$() {
  return new InputState(
    new KeyboardState($set.new$(), $set.new$(), $set.new$()),
    new MouseState(
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      new ButtonState(false, false, false),
      new ButtonState(false, false, false),
      new ButtonState(false, false, false),
    ),
    toList([]),
    new TouchState(toList([]), toList([]), toList([])),
  );
}

/**
 * Get mouse position
 */
export function mouse_position(input) {
  return new $vec2.Vec2(input.mouse.x, input.mouse.y);
}

/**
 * Get mouse delta
 */
export function mouse_delta(input) {
  return new $vec2.Vec2(input.mouse.delta_x, input.mouse.delta_y);
}

/**
 * Check if left mouse button is pressed
 */
export function is_left_button_pressed(input) {
  return input.mouse.left_button.pressed;
}

/**
 * Check if left mouse button was just pressed
 */
export function is_left_button_just_pressed(input) {
  return input.mouse.left_button.just_pressed;
}

/**
 * Check if right mouse button is pressed
 */
export function is_right_button_pressed(input) {
  return input.mouse.right_button.pressed;
}

/**
 * Check if right mouse button was just pressed
 */
export function is_right_button_just_pressed(input) {
  return input.mouse.right_button.just_pressed;
}

/**
 * Get mouse wheel delta
 */
export function mouse_wheel_delta(input) {
  return input.mouse.wheel_delta;
}

/**
 * Get current touches
 */
export function touches(input) {
  return input.touch.touches;
}

/**
 * Get touches that just started
 */
export function touches_just_started(input) {
  return input.touch.touches_just_started;
}

/**
 * Get touches that just ended
 */
export function touches_just_ended(input) {
  return input.touch.touches_just_ended;
}

/**
 * Get touch count
 */
export function touch_count(input) {
  return $list.length(input.touch.touches);
}

/**
 * Check if there was any user interaction this frame (for audio context resume)
 * Returns True if any key was just pressed, mouse button clicked, or touch started
 */
export function has_user_interaction(input) {
  let has_key_press = !$set.is_empty(input.keyboard.just_pressed_keys);
  let has_mouse_click = (input.mouse.left_button.just_pressed || input.mouse.middle_button.just_pressed) || input.mouse.right_button.just_pressed;
  let has_touch_start = !$list.is_empty(input.touch.touches_just_started);
  return (has_key_press || has_mouse_click) || has_touch_start;
}

function list_get(loop$list, loop$index) {
  while (true) {
    let list = loop$list;
    let index = loop$index;
    if (list instanceof $Empty) {
      return new Error(undefined);
    } else if (index === 0) {
      let x = list.head;
      return new Ok(x);
    } else {
      let n = index;
      let rest = list.tail;
      loop$list = rest;
      loop$index = n - 1;
    }
  }
}

/**
 * Check if gamepad at index is connected
 */
export function is_gamepad_connected(input, index) {
  let $ = list_get(input.gamepad, index);
  if ($ instanceof Ok) {
    let gamepad = $[0];
    return gamepad.connected;
  } else {
    return false;
  }
}

function gamepad_button_to_index(button) {
  if (button instanceof ButtonA) {
    return 0;
  } else if (button instanceof ButtonB) {
    return 1;
  } else if (button instanceof ButtonX) {
    return 2;
  } else if (button instanceof ButtonY) {
    return 3;
  } else if (button instanceof LeftBumper) {
    return 4;
  } else if (button instanceof RightBumper) {
    return 5;
  } else if (button instanceof LeftTrigger) {
    return 6;
  } else if (button instanceof RightTrigger) {
    return 7;
  } else if (button instanceof Select) {
    return 8;
  } else if (button instanceof Start) {
    return 9;
  } else if (button instanceof LeftStick) {
    return 10;
  } else if (button instanceof RightStick) {
    return 11;
  } else if (button instanceof DPadUp) {
    return 12;
  } else if (button instanceof DPadDown) {
    return 13;
  } else if (button instanceof DPadLeft) {
    return 14;
  } else if (button instanceof DPadRight) {
    return 15;
  } else {
    return 16;
  }
}

/**
 * Get gamepad button value
 */
export function gamepad_button(input, gamepad_index, button) {
  let button_index = gamepad_button_to_index(button);
  let $ = list_get(input.gamepad, gamepad_index);
  if ($ instanceof Ok) {
    let gamepad = $[0];
    let _pipe = list_get(gamepad.buttons, button_index);
    return $result.unwrap(_pipe, 0.0);
  } else {
    return 0.0;
  }
}

/**
 * Check if gamepad button is pressed
 */
export function is_gamepad_button_pressed(input, gamepad_index, button) {
  return gamepad_button(input, gamepad_index, button) > 0.5;
}

function gamepad_axis_to_index(axis) {
  if (axis instanceof LeftStickX) {
    return 0;
  } else if (axis instanceof LeftStickY) {
    return 1;
  } else if (axis instanceof RightStickX) {
    return 2;
  } else {
    return 3;
  }
}

/**
 * Get gamepad axis value
 */
export function gamepad_axis(input, gamepad_index, axis) {
  let axis_index = gamepad_axis_to_index(axis);
  let $ = list_get(input.gamepad, gamepad_index);
  if ($ instanceof Ok) {
    let gamepad = $[0];
    let _pipe = list_get(gamepad.axes, axis_index);
    return $result.unwrap(_pipe, 0.0);
  } else {
    return 0.0;
  }
}

export function key_to_code(key) {
  if (key instanceof KeyA) {
    return "KeyA";
  } else if (key instanceof KeyB) {
    return "KeyB";
  } else if (key instanceof KeyC) {
    return "KeyC";
  } else if (key instanceof KeyD) {
    return "KeyD";
  } else if (key instanceof KeyE) {
    return "KeyE";
  } else if (key instanceof KeyF) {
    return "KeyF";
  } else if (key instanceof KeyG) {
    return "KeyG";
  } else if (key instanceof KeyH) {
    return "KeyH";
  } else if (key instanceof KeyI) {
    return "KeyI";
  } else if (key instanceof KeyJ) {
    return "KeyJ";
  } else if (key instanceof KeyK) {
    return "KeyK";
  } else if (key instanceof KeyL) {
    return "KeyL";
  } else if (key instanceof KeyM) {
    return "KeyM";
  } else if (key instanceof KeyN) {
    return "KeyN";
  } else if (key instanceof KeyO) {
    return "KeyO";
  } else if (key instanceof KeyP) {
    return "KeyP";
  } else if (key instanceof KeyQ) {
    return "KeyQ";
  } else if (key instanceof KeyR) {
    return "KeyR";
  } else if (key instanceof KeyS) {
    return "KeyS";
  } else if (key instanceof KeyT) {
    return "KeyT";
  } else if (key instanceof KeyU) {
    return "KeyU";
  } else if (key instanceof KeyV) {
    return "KeyV";
  } else if (key instanceof KeyW) {
    return "KeyW";
  } else if (key instanceof KeyX) {
    return "KeyX";
  } else if (key instanceof KeyY) {
    return "KeyY";
  } else if (key instanceof KeyZ) {
    return "KeyZ";
  } else if (key instanceof Digit0) {
    return "Digit0";
  } else if (key instanceof Digit1) {
    return "Digit1";
  } else if (key instanceof Digit2) {
    return "Digit2";
  } else if (key instanceof Digit3) {
    return "Digit3";
  } else if (key instanceof Digit4) {
    return "Digit4";
  } else if (key instanceof Digit5) {
    return "Digit5";
  } else if (key instanceof Digit6) {
    return "Digit6";
  } else if (key instanceof Digit7) {
    return "Digit7";
  } else if (key instanceof Digit8) {
    return "Digit8";
  } else if (key instanceof Digit9) {
    return "Digit9";
  } else if (key instanceof F1) {
    return "F1";
  } else if (key instanceof F2) {
    return "F2";
  } else if (key instanceof F3) {
    return "F3";
  } else if (key instanceof F4) {
    return "F4";
  } else if (key instanceof F5) {
    return "F5";
  } else if (key instanceof F6) {
    return "F6";
  } else if (key instanceof F7) {
    return "F7";
  } else if (key instanceof F8) {
    return "F8";
  } else if (key instanceof F9) {
    return "F9";
  } else if (key instanceof F10) {
    return "F10";
  } else if (key instanceof F11) {
    return "F11";
  } else if (key instanceof F12) {
    return "F12";
  } else if (key instanceof ArrowUp) {
    return "ArrowUp";
  } else if (key instanceof ArrowDown) {
    return "ArrowDown";
  } else if (key instanceof ArrowLeft) {
    return "ArrowLeft";
  } else if (key instanceof ArrowRight) {
    return "ArrowRight";
  } else if (key instanceof ShiftLeft) {
    return "ShiftLeft";
  } else if (key instanceof ShiftRight) {
    return "ShiftRight";
  } else if (key instanceof ControlLeft) {
    return "ControlLeft";
  } else if (key instanceof ControlRight) {
    return "ControlRight";
  } else if (key instanceof AltLeft) {
    return "AltLeft";
  } else if (key instanceof AltRight) {
    return "AltRight";
  } else if (key instanceof MetaLeft) {
    return "MetaLeft";
  } else if (key instanceof MetaRight) {
    return "MetaRight";
  } else if (key instanceof Space) {
    return "Space";
  } else if (key instanceof Enter) {
    return "Enter";
  } else if (key instanceof Escape) {
    return "Escape";
  } else if (key instanceof Tab) {
    return "Tab";
  } else if (key instanceof Backspace) {
    return "Backspace";
  } else if (key instanceof Delete) {
    return "Delete";
  } else if (key instanceof Insert) {
    return "Insert";
  } else if (key instanceof Home) {
    return "Home";
  } else if (key instanceof End) {
    return "End";
  } else if (key instanceof PageUp) {
    return "PageUp";
  } else if (key instanceof PageDown) {
    return "PageDown";
  } else if (key instanceof CapsLock) {
    return "CapsLock";
  } else if (key instanceof Minus) {
    return "Minus";
  } else if (key instanceof Equal) {
    return "Equal";
  } else if (key instanceof BracketLeft) {
    return "BracketLeft";
  } else if (key instanceof BracketRight) {
    return "BracketRight";
  } else if (key instanceof Backslash) {
    return "Backslash";
  } else if (key instanceof Semicolon) {
    return "Semicolon";
  } else if (key instanceof Quote) {
    return "Quote";
  } else if (key instanceof Comma) {
    return "Comma";
  } else if (key instanceof Period) {
    return "Period";
  } else if (key instanceof Slash) {
    return "Slash";
  } else if (key instanceof Backquote) {
    return "Backquote";
  } else if (key instanceof Numpad0) {
    return "Numpad0";
  } else if (key instanceof Numpad1) {
    return "Numpad1";
  } else if (key instanceof Numpad2) {
    return "Numpad2";
  } else if (key instanceof Numpad3) {
    return "Numpad3";
  } else if (key instanceof Numpad4) {
    return "Numpad4";
  } else if (key instanceof Numpad5) {
    return "Numpad5";
  } else if (key instanceof Numpad6) {
    return "Numpad6";
  } else if (key instanceof Numpad7) {
    return "Numpad7";
  } else if (key instanceof Numpad8) {
    return "Numpad8";
  } else if (key instanceof Numpad9) {
    return "Numpad9";
  } else if (key instanceof NumpadAdd) {
    return "NumpadAdd";
  } else if (key instanceof NumpadSubtract) {
    return "NumpadSubtract";
  } else if (key instanceof NumpadMultiply) {
    return "NumpadMultiply";
  } else if (key instanceof NumpadDivide) {
    return "NumpadDivide";
  } else if (key instanceof NumpadDecimal) {
    return "NumpadDecimal";
  } else if (key instanceof NumpadEnter) {
    return "NumpadEnter";
  } else if (key instanceof NumLock) {
    return "NumLock";
  } else if (key instanceof AudioVolumeUp) {
    return "AudioVolumeUp";
  } else if (key instanceof AudioVolumeDown) {
    return "AudioVolumeDown";
  } else if (key instanceof AudioVolumeMute) {
    return "AudioVolumeMute";
  } else if (key instanceof MediaPlayPause) {
    return "MediaPlayPause";
  } else if (key instanceof MediaStop) {
    return "MediaStop";
  } else if (key instanceof MediaTrackNext) {
    return "MediaTrackNext";
  } else if (key instanceof MediaTrackPrevious) {
    return "MediaTrackPrevious";
  } else if (key instanceof PrintScreen) {
    return "PrintScreen";
  } else if (key instanceof ScrollLock) {
    return "ScrollLock";
  } else if (key instanceof Pause) {
    return "Pause";
  } else if (key instanceof ContextMenu) {
    return "ContextMenu";
  } else {
    let code = key[0];
    return code;
  }
}

/**
 * Check if a key is currently pressed
 */
export function is_key_pressed(input, key) {
  let key_code = key_to_code(key);
  return $set.contains(input.keyboard.pressed_keys, key_code);
}

/**
 * Check if a key was just pressed this frame
 */
export function is_key_just_pressed(input, key) {
  let key_code = key_to_code(key);
  return $set.contains(input.keyboard.just_pressed_keys, key_code);
}

/**
 * Check if a key was just released this frame
 */
export function is_key_just_released(input, key) {
  let key_code = key_to_code(key);
  return $set.contains(input.keyboard.just_released_keys, key_code);
}

/**
 * Get axis value with dead zone applied
 */
export function get_axis_with_deadzone(input, gamepad_index, axis, deadzone) {
  let value = gamepad_axis(input, gamepad_index, axis);
  let $ = (value > deadzone) || (value < (0.0 - deadzone));
  if ($) {
    return value;
  } else {
    return 0.0;
  }
}

/**
 * Check if left stick is moved in any direction
 */
export function is_left_stick_active(input, gamepad_index, threshold) {
  let x = gamepad_axis(input, gamepad_index, new LeftStickX());
  let y = gamepad_axis(input, gamepad_index, new LeftStickY());
  return (((x > threshold) || (x < (0.0 - threshold))) || (y > threshold)) || (y < (0.0 - threshold));
}

/**
 * Check if right stick is moved in any direction
 */
export function is_right_stick_active(input, gamepad_index, threshold) {
  let x = gamepad_axis(input, gamepad_index, new RightStickX());
  let y = gamepad_axis(input, gamepad_index, new RightStickY());
  return (((x > threshold) || (x < (0.0 - threshold))) || (y > threshold)) || (y < (0.0 - threshold));
}

/**
 * Convenience: Check if primary gamepad (index 0) is connected
 */
export function is_primary_connected(input) {
  return is_gamepad_connected(input, 0);
}

/**
 * Convenience: Check button on primary gamepad
 */
export function is_primary_gamepad_button_pressed(input, button) {
  return is_gamepad_button_pressed(input, 0, button);
}

/**
 * Convenience: Get button value on primary gamepad
 */
export function get_primary_button(input, button) {
  return gamepad_button(input, 0, button);
}

/**
 * Convenience: Get axis value on primary gamepad
 */
export function get_primary_axis(input, axis) {
  return gamepad_axis(input, 0, axis);
}

/**
 * Create a new empty input bindings configuration
 */
export function new_bindings() {
  return new InputBindings(toList([]), toList([]), toList([]));
}

/**
 * Bind a keyboard key to an action
 *
 * ## Example
 *
 * ```gleam
 * let bindings = input.new_bindings()
 *   |> input.bind_key(input.Space, Jump)
 *   |> input.bind_key(input.KeyW, MoveForward)
 * ```
 */
export function bind_key(bindings, key, action) {
  return new InputBindings(
    listPrepend([key, action], bindings.key_to_action),
    bindings.mouse_to_action,
    bindings.gamepad_to_action,
  );
}

/**
 * Bind a mouse button to an action
 */
export function bind_mouse_button(bindings, button, action) {
  return new InputBindings(
    bindings.key_to_action,
    listPrepend([button, action], bindings.mouse_to_action),
    bindings.gamepad_to_action,
  );
}

/**
 * Bind a gamepad button to an action
 */
export function bind_gamepad_button(bindings, button, action) {
  return new InputBindings(
    bindings.key_to_action,
    bindings.mouse_to_action,
    listPrepend([button, action], bindings.gamepad_to_action),
  );
}

/**
 * Check if an action is currently pressed
 *
 * Returns True if any input bound to this action is pressed.
 *
 * ## Example
 *
 * ```gleam
 * if input.is_action_pressed(ctx.input, bindings, Jump) {
 *   // Player wants to jump
 * }
 * ```
 */
export function is_action_pressed(input, bindings, action) {
  let key_pressed = $list.any(
    bindings.key_to_action,
    (binding) => {
      let key;
      let bound_action;
      key = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && is_key_pressed(input, key);
    },
  );
  let mouse_pressed = $list.any(
    bindings.mouse_to_action,
    (binding) => {
      let button;
      let bound_action;
      button = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && (() => {
        if (button instanceof LeftButton) {
          return is_left_button_pressed(input);
        } else if (button instanceof RightButton) {
          return is_right_button_pressed(input);
        } else {
          return input.mouse.middle_button.pressed;
        }
      })();
    },
  );
  let gamepad_pressed = $list.any(
    bindings.gamepad_to_action,
    (binding) => {
      let button;
      let bound_action;
      button = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && is_gamepad_button_pressed(
        input,
        0,
        button,
      );
    },
  );
  return (key_pressed || mouse_pressed) || gamepad_pressed;
}

/**
 * Check if an action was just pressed this frame
 *
 * Returns True if any input bound to this action was just pressed.
 */
export function is_action_just_pressed(input, bindings, action) {
  let key_just_pressed = $list.any(
    bindings.key_to_action,
    (binding) => {
      let key;
      let bound_action;
      key = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && is_key_just_pressed(input, key);
    },
  );
  let mouse_just_pressed = $list.any(
    bindings.mouse_to_action,
    (binding) => {
      let button;
      let bound_action;
      button = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && (() => {
        if (button instanceof LeftButton) {
          return is_left_button_just_pressed(input);
        } else if (button instanceof RightButton) {
          return is_right_button_just_pressed(input);
        } else {
          return input.mouse.middle_button.just_pressed;
        }
      })();
    },
  );
  let gamepad_just_pressed = $list.any(
    bindings.gamepad_to_action,
    (binding) => {
      let button;
      let bound_action;
      button = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && is_gamepad_button_pressed(
        input,
        0,
        button,
      );
    },
  );
  return (key_just_pressed || mouse_just_pressed) || gamepad_just_pressed;
}

/**
 * Check if an action was just released this frame
 */
export function is_action_just_released(input, bindings, action) {
  let key_just_released = $list.any(
    bindings.key_to_action,
    (binding) => {
      let key;
      let bound_action;
      key = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && is_key_just_released(input, key);
    },
  );
  let mouse_just_released = $list.any(
    bindings.mouse_to_action,
    (binding) => {
      let button;
      let bound_action;
      button = binding[0];
      bound_action = binding[1];
      return (isEqual(bound_action, action)) && (() => {
        if (button instanceof LeftButton) {
          return input.mouse.left_button.just_released;
        } else if (button instanceof RightButton) {
          return input.mouse.right_button.just_released;
        } else {
          return input.mouse.middle_button.just_released;
        }
      })();
    },
  );
  let $ = false;
  
  return key_just_released || mouse_just_released;
}

/**
 * Get the analog value (0.0 to 1.0) for an action
 *
 * Useful for actions that can have analog input like gamepad triggers.
 * Returns 1.0 for digital inputs (keyboard/mouse) when pressed, 0.0 when not pressed.
 */
export function get_action_value(input, bindings, action) {
  let _block;
  let _pipe = $list.find_map(
    bindings.key_to_action,
    (binding) => {
      let key;
      let bound_action;
      key = binding[0];
      bound_action = binding[1];
      let $ = (isEqual(bound_action, action)) && is_key_pressed(input, key);
      if ($) {
        return new Ok(1.0);
      } else {
        return new Error(undefined);
      }
    },
  );
  _block = $result.unwrap(_pipe, 0.0);
  let key_value = _block;
  let _block$1;
  let _pipe$1 = $list.find_map(
    bindings.mouse_to_action,
    (binding) => {
      let button;
      let bound_action;
      button = binding[0];
      bound_action = binding[1];
      let $ = isEqual(bound_action, action);
      if ($) {
        if (button instanceof LeftButton) {
          let $1 = is_left_button_pressed(input);
          if ($1) {
            return new Ok(1.0);
          } else {
            return new Error(undefined);
          }
        } else if (button instanceof RightButton) {
          let $1 = is_right_button_pressed(input);
          if ($1) {
            return new Ok(1.0);
          } else {
            return new Error(undefined);
          }
        } else {
          let $1 = input.mouse.middle_button.pressed;
          if ($1) {
            return new Ok(1.0);
          } else {
            return new Error(undefined);
          }
        }
      } else {
        return new Error(undefined);
      }
    },
  );
  _block$1 = $result.unwrap(_pipe$1, 0.0);
  let mouse_value = _block$1;
  let _block$2;
  let _pipe$2 = $list.find_map(
    bindings.gamepad_to_action,
    (binding) => {
      let button;
      let bound_action;
      button = binding[0];
      bound_action = binding[1];
      let $ = isEqual(bound_action, action);
      if ($) {
        return new Ok(gamepad_button(input, 0, button));
      } else {
        return new Error(undefined);
      }
    },
  );
  _block$2 = $result.unwrap(_pipe$2, 0.0);
  let gamepad_value = _block$2;
  let $ = key_value > 0.0;
  if ($) {
    return key_value;
  } else {
    let $1 = mouse_value > 0.0;
    if ($1) {
      return mouse_value;
    } else {
      return gamepad_value;
    }
  }
}

/**
 * Create a new buffered input system
 */
export function with_buffer(buffer_frames) {
  return new BufferedInput(toList([]), buffer_frames, 0);
}

/**
 * Update the input buffer each frame
 *
 * Call this once per frame in your update function to:
 * 1. Add newly pressed actions to the buffer
 * 2. Remove expired actions from the buffer
 *
 * ## Example
 *
 * ```gleam
 * let buffered = input.update_buffer(
 *   model.buffered_input,
 *   ctx.input,
 *   bindings,
 * )
 * ```
 */
export function update_buffer(buffered, input, bindings) {
  let frame = buffered.frame_counter + 1;
  let new_actions = $list.filter_map(
    $list.flatten(
      toList([
        $list.map(bindings.key_to_action, (pair) => { return pair[1]; }),
        $list.map(bindings.mouse_to_action, (pair) => { return pair[1]; }),
        $list.map(bindings.gamepad_to_action, (pair) => { return pair[1]; }),
      ]),
    ),
    (action) => {
      let $ = is_action_just_pressed(input, bindings, action);
      if ($) {
        return new Ok(new BufferedAction(action, frame));
      } else {
        return new Error(undefined);
      }
    },
  );
  let updated_buffer = $list.append(buffered.buffer, new_actions);
  let cutoff_frame = frame - buffered.buffer_frames;
  let cleaned_buffer = $list.filter(
    updated_buffer,
    (buffered_action) => { return buffered_action.frame >= cutoff_frame; },
  );
  return new BufferedInput(cleaned_buffer, buffered.buffer_frames, frame);
}

/**
 * Check if an action was pressed within the buffer window
 *
 * Returns True if the action was pressed in the last N frames (where N is buffer_frames).
 * This allows for more forgiving input timing.
 *
 * ## Example
 *
 * ```gleam
 * // Allow jump input to be buffered - player can press jump slightly
 * // before landing and it will still work
 * let can_jump = is_grounded
 *   && input.was_action_pressed_buffered(buffered, bindings, Jump)
 * ```
 */
export function was_action_pressed_buffered(buffered, action) {
  return $list.any(
    buffered.buffer,
    (buffered_action) => { return isEqual(buffered_action.action, action); },
  );
}

/**
 * Consume a buffered action (remove it from buffer)
 *
 * Use this when you've acted on a buffered input to prevent it from being
 * used multiple times.
 *
 * ## Example
 *
 * ```gleam
 * let can_jump = is_grounded
 *   && input.was_action_pressed_buffered(buffered, Jump)
 *
 * case can_jump {
 *   True -> {
 *     // Perform jump
 *     let buffered = input.consume_buffered_action(buffered, Jump)
 *     // ...
 *   }
 *   False -> // ...
 * }
 * ```
 */
export function consume_buffered_action(buffered, action) {
  let _block;
  let $ = $list.split_while(
    buffered.buffer,
    (buffered_action) => { return !isEqual(buffered_action.action, action); },
  );
  let $1 = $[1];
  if ($1 instanceof $Empty) {
    let before = $[0];
    _block = before;
  } else {
    let before = $[0];
    let after = $1.tail;
    _block = $list.append(before, after);
  }
  let updated_buffer = _block;
  return new BufferedInput(
    updated_buffer,
    buffered.buffer_frames,
    buffered.frame_counter,
  );
}

/**
 * Clear all buffered actions
 *
 * Useful when switching game states or when you want to reset the buffer.
 */
export function clear_buffer(buffered) {
  return new BufferedInput(
    toList([]),
    buffered.buffer_frames,
    buffered.frame_counter,
  );
}

/**
 * Build a KeyboardState (internal use only)
 * 
 * @ignore
 */
export function build_keyboard_state(pressed, just_pressed, just_released) {
  return new KeyboardState(pressed, just_pressed, just_released);
}

/**
 * Build a MouseState (internal use only)
 * 
 * @ignore
 */
export function build_mouse_state(
  x,
  y,
  delta_x,
  delta_y,
  wheel_delta,
  left_pressed,
  left_just_pressed,
  left_just_released,
  middle_pressed,
  middle_just_pressed,
  middle_just_released,
  right_pressed,
  right_just_pressed,
  right_just_released
) {
  return new MouseState(
    x,
    y,
    delta_x,
    delta_y,
    wheel_delta,
    new ButtonState(left_pressed, left_just_pressed, left_just_released),
    new ButtonState(middle_pressed, middle_just_pressed, middle_just_released),
    new ButtonState(right_pressed, right_just_pressed, right_just_released),
  );
}

/**
 * Build a Touch (internal use only)
 * 
 * @ignore
 */
export function build_touch(id, position) {
  return new Touch(id, position);
}

/**
 * Build a TouchState (internal use only)
 * 
 * @ignore
 */
export function build_touch_state(active, just_started, just_ended) {
  return new TouchState(active, just_started, just_ended);
}

/**
 * Build a GamepadState (internal use only)
 * 
 * @ignore
 */
export function build_gamepad_state(connected, buttons, axes) {
  return new GamepadState(connected, buttons, axes);
}

/**
 * Build an InputState (internal use only)
 * 
 * @ignore
 */
export function build_input_state(keyboard, mouse, gamepads, touch) {
  return new InputState(keyboard, mouse, gamepads, touch);
}

/**
 * Get keyboard state (internal use only)
 * 
 * @ignore
 */
export function get_keyboard_state(input) {
  return input.keyboard;
}

/**
 * Get mouse state (internal use only)
 * 
 * @ignore
 */
export function get_mouse_state(input) {
  return input.mouse;
}

/**
 * Get touch state (internal use only)
 * 
 * @ignore
 */
export function get_touch_state(input) {
  return input.touch;
}

/**
 * Get gamepad list (internal use only)
 * 
 * @ignore
 */
export function get_gamepad_list(input) {
  return input.gamepad;
}

/**
 * Get pressed keys set (internal use only)
 * 
 * @ignore
 */
export function get_pressed_keys(input) {
  return input.keyboard.pressed_keys;
}

/**
 * Get just pressed keys set (internal use only)
 * 
 * @ignore
 */
export function get_just_pressed_keys(input) {
  return input.keyboard.just_pressed_keys;
}

/**
 * Get just released keys set (internal use only)
 * 
 * @ignore
 */
export function get_just_released_keys(input) {
  return input.keyboard.just_released_keys;
}

/**
 * Get active touches list (internal use only)
 * 
 * @ignore
 */
export function get_active_touches(input) {
  return input.touch.touches;
}

/**
 * Get mouse x position (internal use only)
 * 
 * @ignore
 */
export function get_mouse_x(input) {
  return input.mouse.x;
}

/**
 * Get mouse y position (internal use only)
 * 
 * @ignore
 */
export function get_mouse_y(input) {
  return input.mouse.y;
}

/**
 * Get mouse delta x (internal use only)
 * 
 * @ignore
 */
export function get_mouse_delta_x(input) {
  return input.mouse.delta_x;
}

/**
 * Get mouse delta y (internal use only)
 * 
 * @ignore
 */
export function get_mouse_delta_y(input) {
  return input.mouse.delta_y;
}

/**
 * Get mouse wheel delta (internal use only)
 * 
 * @ignore
 */
export function get_mouse_wheel_delta(input) {
  return input.mouse.wheel_delta;
}

/**
 * Get left button state (internal use only)
 * 
 * @ignore
 */
export function get_left_button_state(input) {
  return input.mouse.left_button;
}

/**
 * Get middle button state (internal use only)
 * 
 * @ignore
 */
export function get_middle_button_state(input) {
  return input.mouse.middle_button;
}

/**
 * Get right button state (internal use only)
 * 
 * @ignore
 */
export function get_right_button_state(input) {
  return input.mouse.right_button;
}
