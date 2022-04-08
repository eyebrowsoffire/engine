import 'dart:wasm';

import 'color.dart';
import 'raw/raw_paint.dart';

enum StrokeCap {
  butt,
  round,
  square,
}

// These enum values must be kept in sync with SkPaint::Join.
enum StrokeJoin {
  miter,
  round,
  bevel,
}

enum PaintingStyle {
  fill,
  stroke,
}

enum BlendMode {
  // This list comes from Skia's SkXfermode.h and the values (order) should be
  // kept in sync.
  // See: https://skia.org/user/api/skpaint#SkXfermode
  clear,
  src,
  dst,
  srcOver,
  dstOver,
  srcIn,
  dstIn,
  srcOut,
  dstOut,
  srcATop,
  dstATop,
  xor,
  plus,
  modulate,

  // Following blend modes are defined in the CSS Compositing standard.
  screen, // The last coeff mode.
  overlay,
  darken,
  lighten,
  colorDodge,
  colorBurn,
  hardLight,
  softLight,
  difference,
  exclusion,
  multiply, // The last separable mode.
  hue,
  saturation,
  color,
  luminosity,
}

class Paint {
  PaintHandle _handle;

  PaintHandle get handle => _handle;

  factory Paint() {
    return Paint._fromHandle(paint_create());
  }

  Paint._fromHandle(this._handle);

  BlendMode _cachedBlendMode = BlendMode.srcOver;

  BlendMode get blendMode {
    return _cachedBlendMode;
  }

  set blendMode(BlendMode blendMode) {
    if (_cachedBlendMode != blendMode) {
      paint_setBlendMode(_handle, blendMode.index.toWasmI32());
    }
  }

  PaintingStyle get style {
    return PaintingStyle.values[paint_getPaintStyle(_handle).toIntSigned()];
  }

  set style(PaintingStyle style) {
    paint_setPaintStyle(_handle, style.index.toWasmI32());
  }

  double get strokeWidth {
    return paint_getStrokeWidth(_handle).toDouble();
  }

  set strokeWidth(double width) {
    paint_setStrokeWidth(_handle, width.toWasmF32());
  }

  StrokeCap get strokeCap {
    return StrokeCap.values[paint_getStrokeCap(_handle).toIntSigned()];
  }

  set strokeCap(StrokeCap cap) {
    paint_setStrokeCap(_handle, cap.index.toWasmI32());
  }

  StrokeJoin get strokeJoin {
    return StrokeJoin.values[paint_getStrokeJoin(_handle).toIntSigned()];
  }

  set strokeJoin(StrokeJoin join) {
    paint_setStrokeJoin(_handle, join.index.toWasmI32());
  }

  bool get isAntiAlias {
    return paint_getAntiAlias(_handle).toIntSigned() != 0;
  }
  set isAntiAlias(bool value) {
    paint_setAntiAlias(_handle, value ? 1.toWasmI32() : 0.toWasmI32());
  }

  Color get color {
    return Color(paint_getColorInt(_handle).toIntSigned());
  }

  set color(Color color) {
    paint_setColorInt(_handle, color.value.toWasmI32());
  }
}
