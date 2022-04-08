import 'dart:ffi';
import 'dart:wasm';

import 'raw_paint.dart';
import 'raw_path.dart';

class CanvasWrapper extends Opaque {}
typedef CanvasHandle = Pointer<CanvasWrapper>;

@pragma('wasm:import', 'skwasm.canvas_destroy')
external void canvas_destroy(CanvasHandle canvas);

@pragma('wasm:import', 'skwasm.canvas_drawCircle')
external void canvas_drawCircle(
    CanvasHandle canvas, WasmF32 x, WasmF32 y, WasmF32 radius, PaintHandle paint);

@pragma('wasm:import', 'skwasm.canvas_drawPath')
external void canvas_drawPath(CanvasHandle canvas, PathHandle path, PaintHandle paint);
