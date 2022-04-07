import 'dart:ffi';
import 'dart:wasm';

import 'raw_canvas.dart';

class SurfaceWrapper extends Opaque {}
typedef SurfaceHandle = Pointer<SurfaceWrapper>;

@pragma('wasm:import', 'skwasm.createSurfaceFromCanvas')
external SurfaceHandle createSurfaceFromCanvas(
    Pointer<Int8> querySelector, WasmI32 width, WasmI32 height);

@pragma('wasm:import', 'skwasm.surface_destroy')
external void surface_destroy(SurfaceHandle surface);

@pragma('wasm:import', 'skwasm.surface_getCanvas')
external CanvasHandle surface_getCanvas(SurfaceHandle surface);

@pragma('wasm:import', 'skwasm.surface_flush')
external void surface_flush(SurfaceHandle surface);
