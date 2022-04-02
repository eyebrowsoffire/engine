import 'dart:wasm';
import 'dart:ffi';

class Path extends Opaque {}
typedef PathHandle = Pointer<Path>;

typedef PathFillType = WasmI32;

@pragma("wasm:import", "skwasm.path_create")
external PathHandle path_create();

@pragma("wasm:import", "skwasm.path_destroy")
external void path_destroy(PathHandle path);

@pragma("wasm:import", "skwasm.path_setFillType")
external void path_setFillType(PathHandle path, PathFillType fillType);

@pragma("wasm:import", "skwasm.path_getFillType")
external PathFillType path_getFillType(PathHandle path);

@pragma("wasm:import", "skwasm.addArc")
external void path_addArc(PathHandle path, Pointer<Float> ovalRect, WasmF32 startAngleDegrees, WasmF32 sweepAngleDegrees);

@pragma("wasm:import", "skwasm.addOval")
external void path_addOval(PathHandle path, Pointer<Float> ovalRect, WasmI32 counterClockwise, WasmI32 startIndex);

@pragma("wasm:import", "skwasm.addPath")
external void path_addPath(PathHandle path, PathHandle other, Pointer<Float> matrix33, WasmI32 extendPath);

