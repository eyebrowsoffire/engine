import 'dart:wasm';
import 'dart:ffi';

class CanvasWrapper extends Opaque {}
typedef CanvasHandle = Pointer<CanvasWrapper>;

@pragma("wasm:import", "skwasm.canvas_release")
external void canvas_release(CanvasHandle canvas);

@pragma("wasm:import", "skwasm.canvas_drawCircle")
external void canvas_drawCircle(
    CanvasHandle canvas, WasmF32 x, WasmF32 y, WasmF32 radius);
