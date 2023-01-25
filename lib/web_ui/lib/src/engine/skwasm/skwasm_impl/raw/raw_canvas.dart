import 'dart:ffi';

import 'raw_geometry.dart';
import 'raw_paint.dart';
import 'raw_path.dart';
import 'raw_picture.dart';

class CanvasWrapper extends Opaque {}
typedef CanvasHandle = Pointer<CanvasWrapper>;

@Native<Void Function(CanvasHandle)>(symbol: 'skwasm.canvas_destroy', isLeaf: true)
external void canvasDestroy(CanvasHandle canvas);

@Native<Void Function(CanvasHandle)>(symbol: 'skwasm.canvas_save', isLeaf: true)
external void canvasSave(CanvasHandle canvas);

@Native<Void Function(CanvasHandle, RawRect, PaintHandle)>(symbol: 'skwasm.canvas_saveLayer', isLeaf: true)
external void canvasSaveLayer(
    CanvasHandle canvas, RawRect rect, PaintHandle paint);

@Native<Void Function(CanvasHandle)>(symbol: 'skwasm.canvas_restore', isLeaf: true)
external void canvasRestore(CanvasHandle canvas);

@Native<Int Function(CanvasHandle)>(symbol: 'skwasm.canvas_getSaveCount', isLeaf: true)
external int canvasGetSaveCount(CanvasHandle canvas);

@Native<Void Function(CanvasHandle, Float, Float)>(symbol: 'skwasm.canvas_translate', isLeaf: true)
external void canvasTranslate(CanvasHandle canvas, double dx, double dy);

@Native<Void Function(CanvasHandle, Float, Float)>(symbol: 'skwasm.canvas_scale', isLeaf: true)
external void canvasScale(CanvasHandle canvas, double sx, double sy);

@Native<Void Function(CanvasHandle, Float)>(symbol: 'skwasm.canvas_rotate', isLeaf: true)
external void canvasRotate(CanvasHandle canvas, double degrees);

@Native<Void Function(CanvasHandle, Float, Float)>(symbol: 'skwasm.canvas_skew', isLeaf: true)
external void canvasSkew(CanvasHandle canvas, double sx, double sy);

@Native<Void Function(CanvasHandle, RawMatrix44)>(symbol: 'skwasm.canvas_transform', isLeaf: true)
external void canvasTransform(CanvasHandle canvas, RawMatrix44 matrix);

@Native<Void Function(CanvasHandle, RawRect, Int, Bool)>(symbol: 'skwasm.canvas_clipRect', isLeaf: true)
external void canvasClipRect(
    CanvasHandle canvas, RawRect rect, int op, bool antialias);

@Native<Void Function(CanvasHandle, RawRRect, Bool)>(symbol: 'skwasm.canvas_clipRRect', isLeaf: true)
external void canvasClipRRect(
    CanvasHandle canvas, RawRRect rrect, bool antialias);

@Native<Void Function(CanvasHandle, PathHandle, Bool)>(symbol: 'skwasm.canvas_clipPath', isLeaf: true)
external void canvasClipPath(
    CanvasHandle canvas, PathHandle path, bool antialias);

@Native<Void Function(CanvasHandle, Int32, Int)>(symbol: 'skwasm.canvas_drawColor', isLeaf: true)
external void canvasDrawColor(
    CanvasHandle canvas, int color, int blendMode);

@Native<Void Function(CanvasHandle, Float, Float, Float, Float, PaintHandle)>(symbol: 'skwasm.canvas_drawLine', isLeaf: true)
external void canvasDrawLine(CanvasHandle canvas, double x1, double y1,
    double x2, double y2, PaintHandle paint);

@Native<Void Function(CanvasHandle, PaintHandle)>(symbol: 'skwasm.canvas_drawPaint', isLeaf: true)
external void canvasDrawPaint(CanvasHandle canvas, PaintHandle paint);

@Native<Void Function(CanvasHandle, RawRect, PaintHandle)>(symbol: 'skwasm.canvas_drawRect', isLeaf: true)
external void canvasDrawRect(
    CanvasHandle canvas, RawRect rect, PaintHandle paint);

@Native<Void Function(CanvasHandle, RawRRect, PaintHandle)>(symbol: 'skwasm.canvas_drawRRect', isLeaf: true)
external void canvasDrawRRect(
    CanvasHandle canvas, RawRRect rrect, PaintHandle paint);

@Native<Void Function(CanvasHandle, RawRRect, RawRRect, PaintHandle)>(symbol: 'skwasm.canvas_drawDRRect', isLeaf: true)
external void canvasDrawDRRect(
    CanvasHandle canvas, RawRRect outer, RawRRect inner, PaintHandle paint);

@Native<Void Function(CanvasHandle, RawRect, PaintHandle)>(symbol: 'skwasm.canvas_drawOval', isLeaf: true)
external void canvasDrawOval(
    CanvasHandle canvas, RawRect oval, PaintHandle paint);

@Native<Void Function(CanvasHandle, Float, Float, Float, PaintHandle)>(symbol: 'skwasm.canvas_drawCircle', isLeaf: true)
external void canvasDrawCircle(CanvasHandle canvas, double x, double y,
    double radius, PaintHandle paint);

@Native<Void Function(CanvasHandle, RawRect, Float, Float, Bool, PaintHandle)>(symbol: 'skwasm.canvas_drawCircle', isLeaf: true)
external void canvasDrawArc(
    CanvasHandle canvas,
    RawRect rect,
    double startAngleDegrees,
    double sweepAngleDegrees,
    bool useCenter,
    PaintHandle paint);

@Native<Void Function(CanvasHandle, PathHandle, PaintHandle)>(symbol: 'skwasm.canvas_drawPath', isLeaf: true)
external void canvasDrawPath(
    CanvasHandle canvas, PathHandle path, PaintHandle paint);

@Native<Void Function(CanvasHandle, PictureHandle)>(symbol: 'skwasm.canvas_drawPicture', isLeaf: true)
external void canvasDrawPicture(CanvasHandle canvas, PictureHandle picture);
