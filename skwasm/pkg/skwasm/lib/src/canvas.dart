import 'dart:wasm';
import './geometry.dart';
import './paint.dart';
import './path.dart';
import './raw/raw_canvas.dart';

class Canvas {
  CanvasHandle _handle;

  Canvas(this._handle);

  void drawCircle(Offset center, double radius, Paint paint) {
    canvas_drawCircle(_handle, center.dx.toWasmF32(), center.dy.toWasmF32(),
        radius.toWasmF32(), paint.handle);
  }

  void drawPath(Path path, Paint paint) {
    canvas_drawPath(_handle, path.handle, paint.handle);
  }
}
