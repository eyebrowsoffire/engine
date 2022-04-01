import 'dart:wasm';
import 'raw/raw_canvas.dart';

class Canvas {
  CanvasHandle handle;

  Canvas(this.handle);

  void drawCircle(double x, double y, double radius) {
    canvas_drawCircle(handle, x.toWasmF32(), y.toWasmF32(), radius.toWasmF32());
  }
}