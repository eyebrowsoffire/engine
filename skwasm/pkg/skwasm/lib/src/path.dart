import 'dart:ffi';
import 'dart:typed_data';

import './geometry.dart';
import './raw/raw_memory.dart';
import './vector_math.dart';
import './raw/raw_path.dart';
import 'dart:wasm';

enum PathFillType {
  nonZero,
  evenOdd,
}

enum PathDirection {
  clockwise,
  counterClockwise,
}

enum PathArcSize {
  small,
  large,
}

enum PathOperation {
  difference,
  intersect,
  union,
  xor,
  reverseDifference,
}

class Path {
  final PathHandle _handle;

  PathHandle get handle => _handle;

  Path._fromHandle(this._handle);

  factory Path() {
    return Path._fromHandle(path_create());
  }

  factory Path.from(Path source) {
    return Path._fromHandle(path_copy(source._handle));
  }

  PathFillType get fillType {
    return PathFillType.values[path_getFillType(_handle).toIntSigned()];
  }

  set fillType(PathFillType fillType) {
    path_setFillType(_handle, fillType.index.toWasmI32());
  }

  void moveTo(double x, double y) {
    path_moveTo(_handle, x.toWasmF32(), y.toWasmF32());
  }

  void relativeMoveTo(double x, double y) {
    path_relativeMoveTo(_handle, x.toWasmF32(), y.toWasmF32());
  }

  void lineTo(double x, double y) {
    path_lineTo(_handle, x.toWasmF32(), y.toWasmF32());
  }

  void relativeLineTo(double x, double y) {
    path_relativeMoveTo(_handle, x.toWasmF32(), y.toWasmF32());
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    path_quadraticBezierTo(_handle, x1.toWasmF32(), y1.toWasmF32(),
        x2.toWasmF32(), y2.toWasmF32());
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    path_relativeQuadraticBezierTo(_handle, x1.toWasmF32(), y1.toWasmF32(),
        x2.toWasmF32(), y2.toWasmF32());
  }

  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path_cubicTo(_handle, x1.toWasmF32(), y1.toWasmF32(), x2.toWasmF32(),
        y2.toWasmF32(), x3.toWasmF32(), y3.toWasmF32());
  }

  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path_relativeCubicTo(_handle, x1.toWasmF32(), y1.toWasmF32(),
        x2.toWasmF32(), y2.toWasmF32(), x3.toWasmF32(), y3.toWasmF32());
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    path_conicTo(_handle, x1.toWasmF32(), y1.toWasmF32(), x2.toWasmF32(),
        y2.toWasmF32(), w.toWasmF32());
  }

  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    path_relativeConicTo(_handle, x1.toWasmF32(), y1.toWasmF32(),
        x2.toWasmF32(), y2.toWasmF32(), w.toWasmF32());
  }

  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    withStackScope((s) {
      final WasmI32 forceMoveToWasm = forceMoveTo ? 1.toWasmI32() : 0.toWasmI32();
      path_arcToOval(_handle, s.convertRect(rect), startAngle.toWasmF32(),
          sweepAngle.toWasmF32(), forceMoveToWasm);
    });
  }

  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    final PathArcSize arcSize =
        largeArc ? PathArcSize.large : PathArcSize.small;
    final PathDirection pathDirection =
        clockwise ? PathDirection.clockwise : PathDirection.counterClockwise;
    path_arcToRotated(
        _handle,
        radius.x.toWasmF32(),
        radius.y.toWasmF32(),
        rotation.toWasmF32(),
        arcSize.index.toWasmI32(),
        pathDirection.index.toWasmI32(),
        arcEnd.dx.toWasmF32(),
        arcEnd.dy.toWasmF32());
  }

  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    final PathArcSize arcSize =
        largeArc ? PathArcSize.large : PathArcSize.small;
    final PathDirection pathDirection =
        clockwise ? PathDirection.clockwise : PathDirection.counterClockwise;
    path_relativeArcToRotated(
        _handle,
        radius.x.toWasmF32(),
        radius.y.toWasmF32(),
        rotation.toWasmF32(),
        arcSize.index.toWasmI32(),
        pathDirection.index.toWasmI32(),
        arcEndDelta.dx.toWasmF32(),
        arcEndDelta.dy.toWasmF32());
  }

  void addRect(Rect rect) {
    withStackScope((s) {
      path_addRect(_handle, s.convertRect(rect));
    });
  }

  void addOval(Rect rect) {
    withStackScope((s) {
      path_addOval(_handle, s.convertRect(rect));
    });
  }

  void addArc(Rect rect, double startAngle, double sweepAngle) {
    withStackScope((s) {
      path_addArc(_handle, s.convertRect(rect), startAngle.toWasmF32(),
          sweepAngle.toWasmF32());
    });
  }

  void addPolygon(List<Offset> points, bool close) {
    withStackScope((s) {
      final WasmI32 closeWasm = close ? 1.toWasmI32() : 0.toWasmI32();
      path_addPolygon(_handle, s.convertPointArray(points),
          points.length.toWasmI32(), closeWasm);
    });
  }

  void addRRect(RRect rrect) {
    withStackScope((s) {
      path_addRRect(_handle, s.convertRRect(rrect));
    });
  }

  void addPath(Path path, Offset offset, {Float64List? matrix4}) {
    _addPath(path, offset, false, matrix4: matrix4);
  }

  void extendWithPath(Path path, Offset offset, {Float64List? matrix4}) {
    _addPath(path, offset, true, matrix4: matrix4);
  }

  void _addPath(Path path, Offset offset, bool extend, {Float64List? matrix4}) {
    withStackScope((s) {
      final Pointer<Float> convertedMatrix =
          s.convertMatrix4toSkMatrix(matrix4 ?? Matrix4.identity().toFloat64());
      convertedMatrix[2] += offset.dx;
      convertedMatrix[5] += offset.dy;
      final WasmI32 extendWasm = extend ? 1.toWasmI32() : 0.toWasmI32();
      path_addPath(_handle, path._handle, convertedMatrix, extendWasm);
    });
  }

  void close() {
    path_close(_handle);
  }

  void reset() {
    path_reset(_handle);
  }

  bool contains(Offset point) {
    final WasmI32 result =
        path_contains(_handle, point.dx.toWasmF32(), point.dy.toWasmF32());
    return result.toIntSigned() != 0;
  }

  Path shift(Offset offset) {
    return transform(
        Matrix4.translationValues(offset.dx, offset.dy, 0.0).toFloat64());
  }

  Path transform(Float64List matrix4) {
    return withStackScope((s) {
      final PathHandle newPathHandle = path_copy(_handle);
      path_transform(newPathHandle, s.convertMatrix4toSkMatrix(matrix4));
      return Path._fromHandle(newPathHandle);
    });
  }

  Rect getBounds() {
    return withStackScope((s) {
      Pointer<Float> rectBuffer = s.allocFloatArray(4);
      path_getBounds(_handle, rectBuffer);
      return Rect.fromLTRB(
          rectBuffer[0], rectBuffer[1], rectBuffer[2], rectBuffer[3]);
    });
  }

  static Path combine(PathOperation operation, Path path1, Path path2) {
    return Path._fromHandle(path_combine(
        operation.index.toWasmI32(), path1._handle, path2._handle));
  }
}
