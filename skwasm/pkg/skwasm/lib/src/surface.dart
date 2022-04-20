import 'dart:ffi';
import 'dart:wasm';

import 'canvas.dart';
import 'picture.dart';
import 'raw/raw_memory.dart';
import 'raw/raw_surface.dart';

class Surface {
  final SurfaceHandle _handle;

  factory Surface(String canvasQuerySelector) {
    final SurfaceHandle surfaceHandle = withStackScope((StackScope scope) {
      final Pointer<Int8> pointer = scope.convertString(canvasQuerySelector);
      return surface_createFromCanvas(pointer);
    });
    return Surface._fromHandle(surfaceHandle);
  }

  Surface._fromHandle(this._handle);

  void setSize(int width, int height) {
    surface_setCanvasSize(_handle, width.toWasmI32(), height.toWasmI32());
  }

  void renderPicture(Picture picture) {
    surface_renderPicture(_handle, picture.handle);
  }
}
