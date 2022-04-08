import 'dart:typed_data';
import 'dart:wasm';
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
    throw UnimplementedError();
  }

  void saveLayer(Rect? bounds, Paint paint) {
    throw UnimplementedError();
  }

  void restore() {
    throw UnimplementedError();
  }

  int getSaveCount() {
    throw UnimplementedError();
  }

  void translate(double dx, double dy) {
    throw UnimplementedError();
  }

  void scale(double sx, [double? sy]) {
    throw UnimplementedError();
  }

  void rotate(double radians) {
    throw UnimplementedError();
  }

  void skew(double sx, double sy) {
    throw UnimplementedError();
  }

  void transform(Float64List matrix4) {
    throw UnimplementedError();
  }

  void clipRect(Rect rect,
      {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) {
    throw UnimplementedError();
  }

  void clipRRect(RRect rrect, {bool doAntialias = true}) {
    throw UnimplementedError();
  }

  void clipPath(Path path, {bool doAntiAlias = true}) {
    throw UnimplementedError();
  }

  void drawColor(Color color, BlendMode blendMode) {
    throw UnimplementedError();
  }

  void drawLine(Offset p1, Offset p2, Paint paint) {
    throw UnimplementedError();
  }

  void drawPaint(Paint paint) {
    throw UnimplementedError();
  }

  void drawRect(Rect rect, Paint paint) {
    throw UnimplementedError();
  }

  void drawRRect(RRect rrect, Paint paint) {
    throw UnimplementedError();
  }

  void drawDRRect(RRect outer, RRect intter, Paint paint) {
    throw UnimplementedError();
  }

  void drawOval(Rect rect, Paint paint) {
    throw UnimplementedError();
  }

  void drawCircle(Offset center, double radius, Paint paint) {
    canvas_drawCircle(_handle, center.dx.toWasmF32(), center.dy.toWasmF32(),
        radius.toWasmF32(), paint.handle);
  }

  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    throw UnimplementedError();
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
