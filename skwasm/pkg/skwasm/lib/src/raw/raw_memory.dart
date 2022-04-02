import 'dart:typed_data';
import 'dart:wasm';
import 'dart:ffi';
import 'dart:convert';
import '../geometry.dart';

class Stack extends Opaque {}
typedef StackPointer = Pointer<Stack>;

/// Generic linear memory allocation
@pragma("wasm:import", "skwasm.stackAlloc")
external Pointer<Void> stackAlloc(WasmI32 length);

@pragma("wasm:import", "skwasm.stackSave")
external StackPointer stackSave();

@pragma("wasm:import", "skwasm.stackRestore")
external void stackRestore(StackPointer pointer);

class _StackScope {
  Pointer<Int8> convertString(String string) {
    final Utf8Encoder utf8Encoder = utf8.encoder;
    final Uint8List encoded = utf8Encoder.convert(string);
    final Pointer<Int8> pointer = _allocInt8Array(encoded.length + 1);
    for (int i = 0; i < encoded.length; i++) {
      pointer[i] = encoded[i];
    }
    pointer[encoded.length] = 0;
    return pointer;
  }

  Pointer<Float> convertMatrix4toSkMatrix(Float64List matrix4) {
    final Pointer<Float> pointer = _allocFloatArray(9);
    final matrixLength = matrix4.length;

    double getVal(int index) {
      return (index < matrixLength) ? matrix4[index] : 0.0;
    }

    pointer[0] = getVal(0);
    pointer[1] = getVal(4);
    pointer[2] = getVal(12);

    pointer[3] = getVal(1);
    pointer[4] = getVal(5);
    pointer[5] = getVal(13);

    pointer[6] = getVal(3);
    pointer[7] = getVal(7);
    pointer[8] = getVal(15);

    return pointer;
  }

  Pointer<Float> convertRect(Rect rect) {
    final Pointer<Float> pointer = _allocFloatArray(4);
    pointer[0] = rect.left;
    pointer[1] = rect.top;
    pointer[2] = rect.right;
    pointer[3] = rect.bottom;
    return pointer;
  }

  Pointer<Int8> _allocInt8Array(int count) {
    final int length = count * sizeOf<Int8>();
    return stackAlloc(length.toWasmI32()).cast<Int8>();
  }

  Pointer<Float> _allocFloatArray(int count) {
    final int length = count * sizeOf<Float>();
    return stackAlloc(length.toWasmI32()).cast<Float>();
  }
}

T withStackScope<T>(T Function(_StackScope scope) f)
{
  final stack = stackSave();
  final T result = f(_StackScope());
  stackRestore(stack); 
  return result;
}
