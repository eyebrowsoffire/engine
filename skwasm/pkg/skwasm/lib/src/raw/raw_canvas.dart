import 'dart:wasm';
import 'dart:ffi';

import './raw_path.dart';
import './raw_paint.dart';

class CanvasWrapper extends Opaque {}
typedef CanvasHandle = Pointer<CanvasWrapper>;

@pragma("wasm:import", "skwasm.canvas_release")
external void canvas_release(CanvasHandle canvas);

@pragma("wasm:import", "skwasm.canvas_drawCircle")
external void canvas_drawCircle(
    CanvasHandle canvas, WasmF32 x, WasmF32 y, WasmF32 radius, PaintHandle paint);

@pragma("wasm:import", "skwasm.canvas_drawPath")
external void canvas_drawPath(CanvasHandle canvas, PathHandle path, PaintHandle paint);
