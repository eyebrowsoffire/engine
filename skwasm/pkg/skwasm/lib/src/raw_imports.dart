import 'dart:wasm';
import 'dart:ffi';


class SurfaceWrapper extends Opaque {}
typedef SurfaceHandle = Pointer<SurfaceWrapper>;

class CanvasWrapper extends Opaque {}
typedef CanvasHandle = Pointer<CanvasWrapper>;

/// Generic linear memory allocation
@pragma("wasm:import", "skwasm.stackAlloc")
external Pointer<Int8> stackAlloc(WasmI32 length);

@pragma("wasm:import", "skwasm.createSurfaceFromCanvas")
external SurfaceHandle createSurfaceFromCanvas(
    Pointer<Int8> querySelector, WasmI32 width, WasmI32 height);

@pragma("wasm:import", "skwasm.surface_getCanvas")
external CanvasHandle surface_getCanvas(SurfaceHandle surface);

@pragma("wasm:import", "skwasm.surface_flush")
external void surface_flush(SurfaceHandle surface);

@pragma("wasm:import", "skwasm.canvas_drawCircle")
external void canvas_drawCircle(
    CanvasHandle canvas, WasmF32 x, WasmF32 y, WasmF32 radius);
