import 'dart:ffi';
import 'dart:wasm';

import 'canvas.dart';
import 'picture.dart';
import 'raw/raw_memory.dart';
import 'raw/raw_surface.dart';

class Surface {
  final SurfaceHandle _handle;

  factory Surface(String canvasQuerySelector, int width, int height) {
    final SurfaceHandle surfaceHandle = withStackScope((StackScope scope) {
      final Pointer<Int8> pointer = scope.convertString(canvasQuerySelector);
      return surface_createFromCanvas(pointer);
    });
    surface_setCanvasSize(surfaceHandle, width.toWasmI32(), height.toWasmI32());
    return Surface.constructor(surfaceHandle);
  }

  Surface.constructor(this._handle);

  void renderPicture(Picture picture) {
    surface_renderPicture(_handle, picture.handle);
  }
}
