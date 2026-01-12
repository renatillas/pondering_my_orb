import { CustomType as $CustomType } from "../gleam.mjs";

export class Left extends $CustomType {}
export const Align$Left = () => new Left();
export const Align$isLeft = (value) => value instanceof Left;

export class Center extends $CustomType {}
export const Align$Center = () => new Center();
export const Align$isCenter = (value) => value instanceof Center;

export class Right extends $CustomType {}
export const Align$Right = () => new Right();
export const Align$isRight = (value) => value instanceof Right;

/**
 * Absolute width/height
 */
export class Px extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Size$Px = ($0) => new Px($0);
export const Size$isPx = (value) => value instanceof Px;
export const Size$Px$0 = (value) => value[0];

/**
 * A percentage of the parent item width/height
 */
export class Pct extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Size$Pct = ($0) => new Pct($0);
export const Size$isPct = (value) => value instanceof Pct;
export const Size$Pct$0 = (value) => value[0];

export class Fill extends $CustomType {}
export const Size$Fill = () => new Fill();
export const Size$isFill = (value) => value instanceof Fill;

export class Black extends $CustomType {}
export const Color$Black = () => new Black();
export const Color$isBlack = (value) => value instanceof Black;

export class Red extends $CustomType {}
export const Color$Red = () => new Red();
export const Color$isRed = (value) => value instanceof Red;

export class Green extends $CustomType {}
export const Color$Green = () => new Green();
export const Color$isGreen = (value) => value instanceof Green;

export class Yellow extends $CustomType {}
export const Color$Yellow = () => new Yellow();
export const Color$isYellow = (value) => value instanceof Yellow;

export class Blue extends $CustomType {}
export const Color$Blue = () => new Blue();
export const Color$isBlue = (value) => value instanceof Blue;

export class Magenta extends $CustomType {}
export const Color$Magenta = () => new Magenta();
export const Color$isMagenta = (value) => value instanceof Magenta;

export class Cyan extends $CustomType {}
export const Color$Cyan = () => new Cyan();
export const Color$isCyan = (value) => value instanceof Cyan;

export class White extends $CustomType {}
export const Color$White = () => new White();
export const Color$isWhite = (value) => value instanceof White;
