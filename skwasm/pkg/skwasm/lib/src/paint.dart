import 'dart:math' as math;
import 'dart:wasm';

import 'lerp.dart';
import 'raw/raw_paint.dart';

Color _scaleAlpha(Color a, double factor) {
  return a.withAlpha(clampInt((a.alpha * factor).round(), 0, 255));
}

class Color {
  const Color(int value)
      : this.value = value & 0xFFFFFFFF; // ignore: unnecessary_this
  const Color.fromARGB(int a, int r, int g, int b)
      : value = (((a & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF;
  const Color.fromRGBO(int r, int g, int b, double opacity)
      : value = ((((opacity * 0xff ~/ 1) & 0xff) << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF;
  final int value;
  int get alpha => (0xff000000 & value) >> 24;
  double get opacity => alpha / 0xFF;
  int get red => (0x00ff0000 & value) >> 16;
  int get green => (0x0000ff00 & value) >> 8;
  int get blue => (0x000000ff & value) >> 0;
  Color withAlpha(int a) {
    return Color.fromARGB(a, red, green, blue);
  }

  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }

  Color withRed(int r) {
    return Color.fromARGB(alpha, r, green, blue);
  }

  Color withGreen(int g) {
    return Color.fromARGB(alpha, red, g, blue);
  }

  Color withBlue(int b) {
    return Color.fromARGB(alpha, red, green, b);
  }

  // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4) as double;
  }

  double computeLuminance() {
    // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
    final double R = _linearizeColorComponent(red / 0xFF);
    final double G = _linearizeColorComponent(green / 0xFF);
    final double B = _linearizeColorComponent(blue / 0xFF);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }

  static Color? lerp(Color? a, Color? b, double t) {
    assert(t != null); // ignore: unnecessary_null_comparison
    if (b == null) {
      if (a == null) {
        return null;
      } else {
        return _scaleAlpha(a, 1.0 - t);
      }
    } else {
      if (a == null) {
        return _scaleAlpha(b, t);
      } else {
        return Color.fromARGB(
          clampInt(lerpInt(a.alpha, b.alpha, t).toInt(), 0, 255),
          clampInt(lerpInt(a.red, b.red, t).toInt(), 0, 255),
          clampInt(lerpInt(a.green, b.green, t).toInt(), 0, 255),
          clampInt(lerpInt(a.blue, b.blue, t).toInt(), 0, 255),
        );
      }
    }
  }

  static Color alphaBlend(Color foreground, Color background) {
    final int alpha = foreground.alpha;
    if (alpha == 0x00) {
      // Foreground completely transparent.
      return background;
    }
    final int invAlpha = 0xff - alpha;
    int backAlpha = background.alpha;
    if (backAlpha == 0xff) {
      // Opaque background case
      return Color.fromARGB(
        0xff,
        (alpha * foreground.red + invAlpha * background.red) ~/ 0xff,
        (alpha * foreground.green + invAlpha * background.green) ~/ 0xff,
        (alpha * foreground.blue + invAlpha * background.blue) ~/ 0xff,
      );
    } else {
      // General case
      backAlpha = (backAlpha * invAlpha) ~/ 0xff;
      final int outAlpha = alpha + backAlpha;
      assert(outAlpha != 0x00);
      return Color.fromARGB(
        outAlpha,
        (foreground.red * alpha + background.red * backAlpha) ~/ outAlpha,
        (foreground.green * alpha + background.green * backAlpha) ~/ outAlpha,
        (foreground.blue * alpha + background.blue * backAlpha) ~/ outAlpha,
      );
    }
  }

  static int getAlphaFromOpacity(double opacity) {
    assert(opacity != null); // ignore: unnecessary_null_comparison
    return (opacity.clamp(0.0, 1.0) * 255).round();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Color && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';
  }
}

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
