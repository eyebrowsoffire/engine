import 'dart:wasm';
import 'dart:math' as math;

import 'package:skwasm/skwasm.dart';

late Surface surface;
double? initialTime;

void main() {
  surface = Surface('#test-canvas', 400, 400);
}

@pragma('wasm:export', 'tick')
void tick(WasmF32 milliseconds) {
  final Canvas canvas = surface.getCanvas();

  final double globalTime = (milliseconds.toDouble() / 1000.0);
  if (initialTime == null) {
    initialTime = globalTime;
  }
  final double time = globalTime - initialTime!;
  canvas.save();

  drawBackground(canvas, time);
  drawSquares(canvas, time);
  drawCircle(canvas, time);
  drawRotatingRRect(canvas, time);

  canvas.restore();
  surface.flush();
}

void drawBackground(Canvas canvas, double time) {
  canvas.drawColor(Color.fromARGB(0xFF, 147, 187, 201), BlendMode.src);
}

void drawSquares(Canvas canvas, double time) {
  final Paint paint = Paint();
  paint.color = Color.fromARGB(0xFF, 89, 121, 201);
  paint.isAntiAlias = true;
  paint.blendMode = BlendMode.srcOver;
  paint.style = PaintingStyle.fill;
  canvas.drawRect(Rect.fromLTWH(50, 50, 300, 300), paint);

  paint.color = Color.fromARGB(0xFF, 60, 60, 60);
  paint.style = PaintingStyle.stroke;
  paint.strokeWidth = 5.0;

  canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(75, 75, 250, 250), Radius.circular(10)),
      paint);
}

double abs(double value) {
  return (value < 0) ? -value : value;
}

double triangle(double amplitude, double period, double t) {
  return (amplitude / period) * (period - abs((t % (2.0 * period) - period)));
}

void drawCircle(Canvas canvas, double time) {
  final Paint paint = Paint();
  paint.color = Color.fromARGB(0xFF, 235, 73, 197);
  paint.isAntiAlias = true;
  paint.blendMode = BlendMode.srcOver;
  paint.style = PaintingStyle.fill;

  canvas.save();

  canvas.scale(1.0, 1.0 + triangle(0.5, 1.0, time));
  canvas.drawCircle(Offset(115.0, 115.0), 10.0, paint);

  canvas.restore();
}

void drawRotatingRRect(Canvas canvas, double time) {
  canvas.save();
  canvas.translate(175.0, 175.0);
  canvas.rotate(time * math.pi);
  Rect rect = Rect.fromLTWH(-25.0, -25.0, 50.0, 50.0);
  canvas.clipRRect(new RRect.fromRectXY(rect, 10.0, 10.0));
  canvas.saveLayer(rect, Paint());
  canvas.drawPaint(new Paint()..color = Color.fromARGB(127, 0xFF, 0, 0));
  canvas.drawPaint(new Paint()..color = Color.fromARGB(127, 0xFF, 0xFF, 0xFF));

  canvas.restore();
  canvas.restore();
}
