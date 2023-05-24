// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ui/src/engine.dart';
import 'package:ui/src/engine/skwasm/skwasm_impl.dart';
import 'package:ui/ui.dart' as ui;

class SkwasmImage implements ui.Image {
  SkwasmImage(this.handle) {
    _registry.register(this, handle.address, this);
  }

  factory SkwasmImage.fromPixels(
    Uint8List pixels,
    int width,
    int height,
    ui.PixelFormat format, {
    int? rowBytes,
  }) {
    final SkDataHandle dataHandle = skDataCreate(pixels.length);
    final Pointer<Uint8> dataPointer = skDataGetPointer(dataHandle).cast<Uint8>();
    for (int i = 0; i < pixels.length; i++) {
      dataPointer[i] = pixels[i];
    }
    final ImageHandle imageHandle = imageCreateFromPixels(
      dataHandle,
      width,
      height,
      format.index,
      rowBytes ?? 4 * width,
    );
    skDataDispose(dataHandle);
    return SkwasmImage(imageHandle);
  }

  static final DomFinalizationRegistry _registry =
    DomFinalizationRegistry(createSkwasmFinalizer(imageDispose));

  final ImageHandle handle;
  bool _isDisposed = false;

  @override
  void dispose() {
    assert(!_isDisposed);
    _registry.unregister(this);
    imageDispose(handle);
    _isDisposed = true;
  }

  @override
  int get width => imageGetWidth(handle);

  @override
  int get height => imageGetHeight(handle);

  @override
  Future<ByteData?> toByteData(
      {ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba}) {
    return (renderer as SkwasmRenderer).surface.rasterizeImage(this, format);
  }

  @override
  ui.ColorSpace get colorSpace => ui.ColorSpace.sRGB;

  @override
  bool get debugDisposed => _isDisposed;

  @override
  SkwasmImage clone() {
    imageRef(handle);
    return SkwasmImage(handle);
  }

  @override
  bool isCloneOf(ui.Image other) => other is SkwasmImage && handle == other.handle;

  @override
  List<StackTrace>? debugGetOpenHandleStackTraces() => null;

  @override
  String toString() => '[$width\u00D7$height]';
}
