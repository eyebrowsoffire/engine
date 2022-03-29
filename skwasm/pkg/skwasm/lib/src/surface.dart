import 'dart:convert';
import 'dart:ffi';
import 'dart:wasm';

import './canvas.dart';
import './raw_imports.dart';

class Surface {
  final SurfaceHandle handle;

  factory Surface(String canvasQuerySelector, int width, int height) {
    final utf8Encoder = utf8.encoder;
    final encoded = utf8Encoder.convert(canvasQuerySelector);
    final pointer = stackAlloc((encoded.length + 1).toWasmI32());
    for (int i = 0; i < encoded.length; i++) {
      pointer[i] = encoded[i];
    }
    pointer[encoded.length] = 0;
    final SurfaceHandle surface =
        createSurfaceFromCanvas(pointer, width.toWasmI32(), height.toWasmI32());
    return Surface.constructor(surface);
  }

  Surface.constructor(this.handle);

  void flush() {
    surface_flush(handle);
  }

  Canvas getCanvas() {
    return Canvas(surface_getCanvas(handle));
  }
}