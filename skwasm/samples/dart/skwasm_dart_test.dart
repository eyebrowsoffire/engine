import 'dart:wasm';
import 'dart:ffi';
import 'dart:convert';

@pragma("wasm:import", "skwasm.stackAlloc")
external Pointer<Int8> stackAlloc(WasmI32 length);

@pragma("wasm:import", "skwasm.createSurfaceFromCanvas")
external WasmI32 createSurfaceFromCanvas(Pointer<Int8> querySelector, WasmI32 width, WasmI32 height);

@pragma("wasm:import", "skwasm.surface_getCanvas")
external WasmI32 surface_getCanvas(WasmI32 surface);

@pragma("wasm:import", "skwasm.surface_flush")
external void surface_flush(WasmI32 surface);

@pragma("wasm:import", "skwasm.canvas_drawCircle")
external void canvas_drawCircle(WasmI32 canvas, WasmF32 x, WasmF32 y, WasmF32 radius);

void main() {
  final utf8Encoder = utf8.encoder;
  const querySelector = '#test-canvas';
  final encoded = utf8Encoder.convert(querySelector);
  final pointer = stackAlloc((encoded.length + 1).toWasmI32());
  for(int i = 0; i < encoded.length; i++) {
    pointer[i] = encoded[i];
  }
  pointer[encoded.length] = 0;
  final WasmI32 surface = createSurfaceFromCanvas(pointer, 400.toWasmI32(), 400.toWasmI32());

  final WasmI32 canvas = surface_getCanvas(surface);
  canvas_drawCircle(canvas, 150.0.toWasmF32(), 250.0.toWasmF32(), 75.0.toWasmF32());

  surface_flush(surface);
}

