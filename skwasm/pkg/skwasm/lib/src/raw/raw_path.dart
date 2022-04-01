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

// @pragma("wasm:import", "skwasm.addArc")
// external void path_addArc(PathHandle path, )
