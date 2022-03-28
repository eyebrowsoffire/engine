import 'dart:wasm';
import 'dart:ffi';

@pragma("wasm:import", "skwasm.stackAlloc")
external Pointer<Int8> stackAlloc(WasmI32 length);

@pragma("wasm:import", "skwasm.createSurfaceFromCanvas")
external WasmI32 createSurfaceFromCanvas(
    Pointer<Int8> querySelector, WasmI32 width, WasmI32 height);

@pragma("wasm:import", "skwasm.surface_getCanvas")
external WasmI32 surface_getCanvas(WasmI32 surface);

@pragma("wasm:import", "skwasm.surface_flush")
external void surface_flush(WasmI32 surface);

@pragma("wasm:import", "skwasm.canvas_drawCircle")
external void canvas_drawCircle(
    WasmI32 canvas, WasmF32 x, WasmF32 y, WasmF32 radius);

class SkwasmModule {
  SkwasmModule._constructor();

  static final SkwasmModule _instance = SkwasmModule._constructor();

  factory SkwasmModule() {
    return _instance;
  }

  SkwasmModule._internal();
}