import 'dart:ffi';
import 'raw_picture.dart';

class RawSurface extends Opaque {}
typedef SurfaceHandle = Pointer<RawSurface>;

@Native<SurfaceHandle Function(Pointer<Int8>)>(
  symbol: 'skwasm.surface_createFromCanvas',
  isLeaf: true)
external SurfaceHandle surfaceCreateFromCanvas(Pointer<Int8> querySelector);

@Native<Void Function(SurfaceHandle)>(
  symbol: 'skwasm.surface_destroy',
  isLeaf: true)
external void surfaceDestroy(SurfaceHandle surface);

@Native<Void Function(SurfaceHandle, Int, Int)>(
  symbol: 'skwasm.surface_setCanvasSize',
  isLeaf: true)
external void surfaceSetCanvasSize(
  SurfaceHandle surface,
  int width,
  int height
);

@Native<Void Function(SurfaceHandle, PictureHandle)>(
  symbol: 'skwasm.surface_renderPicture',
  isLeaf: true)
external void surfaceRenderPicture(SurfaceHandle surface, PictureHandle picture);
