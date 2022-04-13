import 'dart:ffi';
import 'dart:typed_data';
import 'dart:wasm';

import 'package:skwasm/src/raw/raw_memory.dart';

import 'color.dart';
import 'geometry.dart';
import 'image.dart';
import 'paint.dart';
import 'paragraph.dart';
import 'path.dart';
import 'picture.dart';
import 'raw/raw_canvas.dart';
import 'vertices.dart';

enum PointMode {
  points,
  lines,
  polygon,
}

enum ClipOp {
  difference,
  intersect,
}

class Canvas {
  CanvasHandle _handle;

  Canvas.fromHandle(this._handle);

  void delete() {
    canvas_destroy(_handle);
  }

  void save() {
    canvas_save(_handle);
  }

  void saveLayer(Rect? bounds, Paint paint) {
    if (bounds != null) {
      withStackScope((StackScope s) {
        canvas_saveLayer(_handle, s.convertRect(bounds), paint.handle);
      });
    } else {
      canvas_saveLayer(_handle, nullptr, paint.handle);
    }
  }

  void restore() {
    canvas_restore(_handle);
  }

  int getSaveCount() {
    return canvas_getSaveCount(_handle).toIntSigned();
  }

  void translate(double dx, double dy) {
    canvas_translate(_handle, dx.toWasmF32(), dy.toWasmF32());
  }

  void scale(double sx, [double? sy]) {
    canvas_scale(_handle, sx.toWasmF32(), (sy ?? sx).toWasmF32());
  }

  void rotate(double radians) {
    canvas_rotate(_handle, toDegrees(radians).toWasmF32());
  }

  void skew(double sx, double sy) {
    canvas_skew(_handle, sx.toWasmF32(), sy.toWasmF32());
  }

  void transform(Float64List matrix4) {
    withStackScope((StackScope s) {
      canvas_transform(_handle, s.convertMatrix4toSkM44(matrix4));
    });
  }

  void clipRect(Rect rect,
      {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) {
    withStackScope((StackScope s) {
      canvas_clipRect(_handle, s.convertRect(rect), clipOp.index.toWasmI32(),
          doAntiAlias.toWasmI32());
    });
  }

  void clipRRect(RRect rrect, {bool doAntialias = true}) {
    withStackScope((StackScope s) {
      canvas_clipRRect(_handle, s.convertRRect(rrect), doAntialias.toWasmI32());
    });
  }

  void clipPath(Path path, {bool doAntiAlias = true}) {
    canvas_clipPath(_handle, path.handle, doAntiAlias.toWasmI32());
  }

  void drawColor(Color color, BlendMode blendMode) {
    canvas_drawColor(
        _handle, color.value.toWasmI32(), blendMode.index.toWasmI32());
  }

  void drawLine(Offset p1, Offset p2, Paint paint) {
    canvas_drawLine(_handle, p1.dx.toWasmF32(), p1.dy.toWasmF32(),
        p2.dx.toWasmF32(), p2.dy.toWasmF32(), paint.handle);
  }

  void drawPaint(Paint paint) {
    canvas_drawPaint(_handle, paint.handle);
  }

  void drawRect(Rect rect, Paint paint) {
    withStackScope((StackScope s) {
      canvas_drawRect(_handle, s.convertRect(rect), paint.handle);
    });
  }

  void drawRRect(RRect rrect, Paint paint) {
    withStackScope((StackScope s) {
      canvas_drawRRect(_handle, s.convertRRect(rrect), paint.handle);
    });
  }

  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    withStackScope((StackScope s) {
      canvas_drawDRRect(
          _handle, s.convertRRect(outer), s.convertRRect(inner), paint.handle);
    });
  }

  void drawOval(Rect rect, Paint paint) {
    withStackScope((StackScope s) {
      canvas_drawOval(_handle, s.convertRect(rect), paint.handle);
    });
  }

  void drawCircle(Offset center, double radius, Paint paint) {
    canvas_drawCircle(_handle, center.dx.toWasmF32(), center.dy.toWasmF32(),
        radius.toWasmF32(), paint.handle);
  }

  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    withStackScope((StackScope s) {
      canvas_drawArc(
          _handle,
          s.convertRect(rect),
          toDegrees(startAngle).toWasmF32(),
          toDegrees(sweepAngle).toWasmF32(),
          useCenter.toWasmI32(),
          paint.handle);
    });
  }

  void drawPath(Path path, Paint paint) {
    canvas_drawPath(_handle, path.handle, paint.handle);
  }

  void drawImage(Image image, Offset offset, Paint paint) {
    throw UnimplementedError();
  }

  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    throw UnimplementedError();
  }

  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    throw UnimplementedError();
  }

  void drawPicture(Picture picture) {
    throw UnimplementedError();
  }

  void drawParagraph(Paragraph paragraph, Offset offset) {
    throw UnimplementedError();
  }

  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    throw UnimplementedError();
  }

  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    throw UnimplementedError();
  }

  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    throw UnimplementedError();
  }

  void drawAtlas(
    Image atlas,
    List<RSTransform> transforms,
    List<Rect> rects,
    List<Color>? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    throw UnimplementedError();
  }

  void drawRawAtlas(
    Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    throw UnimplementedError();
  }

  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  ) {
    throw UnimplementedError();
  }
}
