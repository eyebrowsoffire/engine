import 'dart:wasm';
import 'dart:ffi';
import 'dart:convert';

class Stack extends Opaque {}
typedef StackPointer = Pointer<Stack>;

/// Generic linear memory allocation
@pragma("wasm:import", "skwasm.stackAlloc")
external Pointer<Int8> stackAlloc(WasmI32 length);

@pragma("wasm:import", "skwasm.stackSave")
external StackPointer stackSave();

@pragma("wasm:import", "skwasm.stackRestore")
external void stackRestore(StackPointer pointer);

class _StackScope {
  Pointer<Int8> convertString(String string) {
    final utf8Encoder = utf8.encoder;
    final encoded = utf8Encoder.convert(string);
    final pointer = stackAlloc((encoded.length + 1).toWasmI32());
    for (int i = 0; i < encoded.length; i++) {
      pointer[i] = encoded[i];
    }
    pointer[encoded.length] = 0;
    return pointer;
  }
}

T withStackScope<T>(T Function(_StackScope scope) f)
{
  final stack = stackSave();
  final T result = f(_StackScope());
  stackRestore(stack); 
  return result;
}
