import 'dart:ffi';
import 'dart:wasm';

import 'canvas.dart';
import 'raw/raw_memory.dart';
import 'raw/raw_surface.dart';

class Surface {
  final SurfaceHandle handle;

  factory Surface(String canvasQuerySelector, int width, int height) {
    final SurfaceHandle surfaceHandle = withStackScope((StackScope scope) {
      final Pointer<Int8> pointer = scope.convertString(canvasQuerySelector);
      return createSurfaceFromCanvas(pointer, width.toWasmI32(), height.toWasmI32());
    });
    return Surface.constructor(surfaceHandle);
  }

  Surface.constructor(this.handle);

  void flush() {
    surface_flush(handle);
  }

  Canvas getCanvas() {
    return Canvas(surface_getCanvas(handle));
  }
}