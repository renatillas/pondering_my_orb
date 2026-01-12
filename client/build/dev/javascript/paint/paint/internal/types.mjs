import * as $colour from "../../../gleam_community_colour/gleam_community/colour.mjs";
import { CustomType as $CustomType } from "../../gleam.mjs";

export class Blank extends $CustomType {}
export const Picture$Blank = () => new Blank();
export const Picture$isBlank = (value) => value instanceof Blank;

export class Polygon extends $CustomType {
  constructor($0, closed) {
    super();
    this[0] = $0;
    this.closed = closed;
  }
}
export const Picture$Polygon = ($0, closed) => new Polygon($0, closed);
export const Picture$isPolygon = (value) => value instanceof Polygon;
export const Picture$Polygon$0 = (value) => value[0];
export const Picture$Polygon$closed = (value) => value.closed;
export const Picture$Polygon$1 = (value) => value.closed;

export class Arc extends $CustomType {
  constructor(radius, start, end) {
    super();
    this.radius = radius;
    this.start = start;
    this.end = end;
  }
}
export const Picture$Arc = (radius, start, end) => new Arc(radius, start, end);
export const Picture$isArc = (value) => value instanceof Arc;
export const Picture$Arc$radius = (value) => value.radius;
export const Picture$Arc$0 = (value) => value.radius;
export const Picture$Arc$start = (value) => value.start;
export const Picture$Arc$1 = (value) => value.start;
export const Picture$Arc$end = (value) => value.end;
export const Picture$Arc$2 = (value) => value.end;

export class Text extends $CustomType {
  constructor(text, style) {
    super();
    this.text = text;
    this.style = style;
  }
}
export const Picture$Text = (text, style) => new Text(text, style);
export const Picture$isText = (value) => value instanceof Text;
export const Picture$Text$text = (value) => value.text;
export const Picture$Text$0 = (value) => value.text;
export const Picture$Text$style = (value) => value.style;
export const Picture$Text$1 = (value) => value.style;

export class ImageRef extends $CustomType {
  constructor($0, width_px, height_px) {
    super();
    this[0] = $0;
    this.width_px = width_px;
    this.height_px = height_px;
  }
}
export const Picture$ImageRef = ($0, width_px, height_px) =>
  new ImageRef($0, width_px, height_px);
export const Picture$isImageRef = (value) => value instanceof ImageRef;
export const Picture$ImageRef$0 = (value) => value[0];
export const Picture$ImageRef$width_px = (value) => value.width_px;
export const Picture$ImageRef$1 = (value) => value.width_px;
export const Picture$ImageRef$height_px = (value) => value.height_px;
export const Picture$ImageRef$2 = (value) => value.height_px;

export class Fill extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Picture$Fill = ($0, $1) => new Fill($0, $1);
export const Picture$isFill = (value) => value instanceof Fill;
export const Picture$Fill$0 = (value) => value[0];
export const Picture$Fill$1 = (value) => value[1];

export class Stroke extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Picture$Stroke = ($0, $1) => new Stroke($0, $1);
export const Picture$isStroke = (value) => value instanceof Stroke;
export const Picture$Stroke$0 = (value) => value[0];
export const Picture$Stroke$1 = (value) => value[1];

export class ImageScalingBehaviour extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Picture$ImageScalingBehaviour = ($0, $1) =>
  new ImageScalingBehaviour($0, $1);
export const Picture$isImageScalingBehaviour = (value) =>
  value instanceof ImageScalingBehaviour;
export const Picture$ImageScalingBehaviour$0 = (value) => value[0];
export const Picture$ImageScalingBehaviour$1 = (value) => value[1];

export class Translate extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Picture$Translate = ($0, $1) => new Translate($0, $1);
export const Picture$isTranslate = (value) => value instanceof Translate;
export const Picture$Translate$0 = (value) => value[0];
export const Picture$Translate$1 = (value) => value[1];

export class Scale extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Picture$Scale = ($0, $1) => new Scale($0, $1);
export const Picture$isScale = (value) => value instanceof Scale;
export const Picture$Scale$0 = (value) => value[0];
export const Picture$Scale$1 = (value) => value[1];

export class Rotate extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const Picture$Rotate = ($0, $1) => new Rotate($0, $1);
export const Picture$isRotate = (value) => value instanceof Rotate;
export const Picture$Rotate$0 = (value) => value[0];
export const Picture$Rotate$1 = (value) => value[1];

export class Combine extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Picture$Combine = ($0) => new Combine($0);
export const Picture$isCombine = (value) => value instanceof Combine;
export const Picture$Combine$0 = (value) => value[0];

export class Image extends $CustomType {
  constructor(id) {
    super();
    this.id = id;
  }
}
export const Image$Image = (id) => new Image(id);
export const Image$isImage = (value) => value instanceof Image;
export const Image$Image$id = (value) => value.id;
export const Image$Image$0 = (value) => value.id;

export class ScalingSmooth extends $CustomType {}
export const ImageScalingBehaviour$ScalingSmooth = () => new ScalingSmooth();
export const ImageScalingBehaviour$isScalingSmooth = (value) =>
  value instanceof ScalingSmooth;

export class ScalingPixelated extends $CustomType {}
export const ImageScalingBehaviour$ScalingPixelated = () =>
  new ScalingPixelated();
export const ImageScalingBehaviour$isScalingPixelated = (value) =>
  value instanceof ScalingPixelated;

export class NoStroke extends $CustomType {}
export const StrokeProperties$NoStroke = () => new NoStroke();
export const StrokeProperties$isNoStroke = (value) => value instanceof NoStroke;

export class SolidStroke extends $CustomType {
  constructor($0, $1) {
    super();
    this[0] = $0;
    this[1] = $1;
  }
}
export const StrokeProperties$SolidStroke = ($0, $1) => new SolidStroke($0, $1);
export const StrokeProperties$isSolidStroke = (value) =>
  value instanceof SolidStroke;
export const StrokeProperties$SolidStroke$0 = (value) => value[0];
export const StrokeProperties$SolidStroke$1 = (value) => value[1];

export class FontProperties extends $CustomType {
  constructor(size_px, font_family) {
    super();
    this.size_px = size_px;
    this.font_family = font_family;
  }
}
export const FontProperties$FontProperties = (size_px, font_family) =>
  new FontProperties(size_px, font_family);
export const FontProperties$isFontProperties = (value) =>
  value instanceof FontProperties;
export const FontProperties$FontProperties$size_px = (value) => value.size_px;
export const FontProperties$FontProperties$0 = (value) => value.size_px;
export const FontProperties$FontProperties$font_family = (value) =>
  value.font_family;
export const FontProperties$FontProperties$1 = (value) => value.font_family;

export class Radians extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Angle$Radians = ($0) => new Radians($0);
export const Angle$isRadians = (value) => value instanceof Radians;
export const Angle$Radians$0 = (value) => value[0];
