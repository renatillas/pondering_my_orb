import { CustomType as $CustomType } from "../gleam.mjs";

export class Backspace extends $CustomType {}
export const Key$Backspace = () => new Backspace();
export const Key$isBackspace = (value) => value instanceof Backspace;

export class Enter extends $CustomType {}
export const Key$Enter = () => new Enter();
export const Key$isEnter = (value) => value instanceof Enter;

export class Left extends $CustomType {}
export const Key$Left = () => new Left();
export const Key$isLeft = (value) => value instanceof Left;

export class Right extends $CustomType {}
export const Key$Right = () => new Right();
export const Key$isRight = (value) => value instanceof Right;

export class Up extends $CustomType {}
export const Key$Up = () => new Up();
export const Key$isUp = (value) => value instanceof Up;

export class Down extends $CustomType {}
export const Key$Down = () => new Down();
export const Key$isDown = (value) => value instanceof Down;

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

export class Tab extends $CustomType {}
export const Key$Tab = () => new Tab();
export const Key$isTab = (value) => value instanceof Tab;

export class BackTab extends $CustomType {}
export const Key$BackTab = () => new BackTab();
export const Key$isBackTab = (value) => value instanceof BackTab;

export class Delete extends $CustomType {}
export const Key$Delete = () => new Delete();
export const Key$isDelete = (value) => value instanceof Delete;

export class Insert extends $CustomType {}
export const Key$Insert = () => new Insert();
export const Key$isInsert = (value) => value instanceof Insert;

export class F extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Key$F = ($0) => new F($0);
export const Key$isF = (value) => value instanceof F;
export const Key$F$0 = (value) => value[0];

export class Char extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Key$Char = ($0) => new Char($0);
export const Key$isChar = (value) => value instanceof Char;
export const Key$Char$0 = (value) => value[0];

export class Null extends $CustomType {}
export const Key$Null = () => new Null();
export const Key$isNull = (value) => value instanceof Null;

export class Esc extends $CustomType {}
export const Key$Esc = () => new Esc();
export const Key$isEsc = (value) => value instanceof Esc;

export class Ctrl extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Key$Ctrl = ($0) => new Ctrl($0);
export const Key$isCtrl = (value) => value instanceof Ctrl;
export const Key$Ctrl$0 = (value) => value[0];

export function from_string(key) {
  if (key === "\u{0007F}") {
    return new Backspace();
  } else if (key === "\r") {
    return new Enter();
  } else if (key === "\u{001B}[D") {
    return new Left();
  } else if (key === "\u{001B}[C") {
    return new Right();
  } else if (key === "\u{001B}[A") {
    return new Up();
  } else if (key === "\u{001B}[B") {
    return new Down();
  } else if (key === "\u{001B}[H") {
    return new Home();
  } else if (key === "\u{001B}[F") {
    return new End();
  } else if (key === "\u{001B}[5~") {
    return new PageUp();
  } else if (key === "\u{001B}[6~") {
    return new PageDown();
  } else if (key === "\t") {
    return new Tab();
  } else if (key === "\u{001B}[Z") {
    return new BackTab();
  } else if (key === "\u{001B}[3~") {
    return new Delete();
  } else if (key === "\u{001B}[2~") {
    return new Insert();
  } else if (key === "\u{001B}") {
    return new Esc();
  } else if (key === "") {
    return new Null();
  } else if (key === "\u{001B}OP") {
    return new F(1);
  } else if (key === "\u{001B}OQ") {
    return new F(2);
  } else if (key === "\u{001B}OR") {
    return new F(3);
  } else if (key === "\u{001B}OS") {
    return new F(4);
  } else if (key === "\u{001B}[15~") {
    return new F(5);
  } else if (key === "\u{001B}[17~") {
    return new F(6);
  } else if (key === "\u{001B}[18~") {
    return new F(7);
  } else if (key === "\u{001B}[19~") {
    return new F(8);
  } else if (key === "\u{001B}[20~") {
    return new F(9);
  } else if (key === "\u{001B}[21~") {
    return new F(10);
  } else if (key === "\u{001B}[23~") {
    return new F(11);
  } else if (key === "\u{001B}[24~") {
    return new F(12);
  } else if (key === "\u{0001}") {
    return new Ctrl("A");
  } else if (key === "\u{0002}") {
    return new Ctrl("B");
  } else if (key === "\u{0003}") {
    return new Ctrl("C");
  } else if (key === "\u{0004}") {
    return new Ctrl("D");
  } else if (key === "\u{0005}") {
    return new Ctrl("E");
  } else if (key === "\u{0006}") {
    return new Ctrl("F");
  } else if (key === "\u{0007}") {
    return new Ctrl("G");
  } else if (key === "\u{0008}") {
    return new Ctrl("H");
  } else if (key === "\u{000B}") {
    return new Ctrl("K");
  } else if (key === "\u{000C}") {
    return new Ctrl("L");
  } else if (key === "\u{000E}") {
    return new Ctrl("N");
  } else if (key === "\u{000F}") {
    return new Ctrl("O");
  } else if (key === "\u{0010}") {
    return new Ctrl("P");
  } else if (key === "\u{0011}") {
    return new Ctrl("Q");
  } else if (key === "\u{0012}") {
    return new Ctrl("R");
  } else if (key === "\u{0013}") {
    return new Ctrl("S");
  } else if (key === "\u{0014}") {
    return new Ctrl("T");
  } else if (key === "\u{0015}") {
    return new Ctrl("U");
  } else if (key === "\u{0016}") {
    return new Ctrl("V");
  } else if (key === "\u{0017}") {
    return new Ctrl("W");
  } else if (key === "\u{0018}") {
    return new Ctrl("X");
  } else if (key === "\u{0019}") {
    return new Ctrl("Y");
  } else if (key === "\u{001A}") {
    return new Ctrl("Z");
  } else {
    let x = key;
    return new Char(x);
  }
}
