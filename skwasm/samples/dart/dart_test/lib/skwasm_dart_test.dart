import 'dart:typed_data';
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
  final double globalTime = (milliseconds.toDouble() / 1000.0);
  if (initialTime == null) {
    initialTime = globalTime;
  }
  final double time = globalTime - initialTime!;
  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  canvas.save();

  drawBackground(canvas, time);
  drawSquares(canvas, time);
  drawCircle(canvas, time);
  drawOval(canvas, time);
  drawRotatingRRect(canvas, time);
  drawLines(canvas, time);
  drawPath(canvas, time);
  drawWave(canvas, time);

  canvas.restore();

  final Picture picture = recorder.endRecording();

  surface.renderPicture(picture);
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
  return (amplitude / period) * (period - abs((t % (2.0 * period) - period))) -
      (amplitude / 2.0);
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
  final int beginSaveCount = canvas.getSaveCount();
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

  if (canvas.getSaveCount() != beginSaveCount) {
    throw "Unexpected change in save count.";
  }
}

void drawOval(Canvas canvas, double time) {
  canvas.save();
  canvas.skew(triangle(0.5, 1.0, time), 0.0);
  canvas.drawOval(
      Rect.fromLTWH(175, 100, 20, 40),
      Paint()
        ..color = Color.fromARGB(0xff, 0x11, 0xdd, 0x11)
        ..isAntiAlias = true);
  canvas.restore();
}

void drawLines(Canvas canvas, double time) {
  canvas.save();

  final Float64List matrix = Float64List(16);
  matrix[0] = 1;
  matrix[1] = 0;
  matrix[2] = 0;
  matrix[3] = 0;

  matrix[4] = 0;
  matrix[5] = 1;
  matrix[6] = 0;
  matrix[7] = 0;

  matrix[8] = 0;
  matrix[9] = 0;
  matrix[10] = 1;
  matrix[11] = 0;

  matrix[12] = triangle(25.0, 1.0, time);
  matrix[13] = triangle(25.0, 1.0, time + 0.5);
  matrix[14] = 0;
  matrix[15] = 1;

  canvas.transform(matrix);
  final Paint paint = Paint();
  paint.color = Color.fromARGB(0xff, 158, 102, 255);
  paint.strokeCap = StrokeCap.round;
  paint.style = PaintingStyle.stroke;
  paint.strokeJoin = StrokeJoin.bevel;
  paint.isAntiAlias = true;
  paint.blendMode = BlendMode.srcOver;
  paint.strokeWidth = 5.0;

  final Rect outer = Rect.fromLTWH(85.0, 160.0, 55.0, 55.0);
  final Rect inner = Rect.fromLTWH(90.0, 165.0, 45.0, 45.0);
  canvas.drawDRRect(RRect.fromRectAndRadius(outer, Radius.circular(15.0)),
      RRect.fromRectAndRadius(inner, Radius.circular(10.0)), paint);
  canvas.drawLine(Offset(100.0, 175.0), Offset(125.0, 200.0), paint);
  canvas.drawLine(Offset(125.0, 175.0), Offset(100.0, 200.0), paint);

  canvas.restore();
}

void drawPath(Canvas canvas, double time) {
  final Paint paint = Paint();
  paint.color = Color.fromARGB(0xff, 255, 209, 59);
  paint.strokeCap = StrokeCap.round;
  paint.style = PaintingStyle.stroke;
  paint.strokeJoin = StrokeJoin.bevel;
  paint.isAntiAlias = true;
  paint.blendMode = BlendMode.srcOver;
  paint.strokeWidth = 5.0;
  canvas.saveLayer(null, paint);

  final Path path = Path();
  path.fillType = PathFillType.nonZero;
  path.moveTo(125.0, 300.0);
  path.lineTo(150.0, 300.0);
  path.relativeLineTo(0.0, -25.0);
  path.relativeMoveTo(0.0, 25.0);
  path.quadraticBezierTo(160.0, 250.0, 170.0, 300.0);
  path.relativeQuadraticBezierTo(10.0, -50.0, 20.0, 0.0);
  path.conicTo(200.0, 250.0, 210.0, 300.0, 1.4);
  path.relativeConicTo(10.0, -50.0, 20.0, 0.0, 0.8);

  final Path path2 = Path();
  path2.moveTo(240.0, 300.0);
  path2.arcTo(
      Rect.fromLTRB(230.0, 275.0, 250.0, 325.0), math.pi, math.pi, true);
  path2.arcToPoint(Offset(270.0, 300.0), radius: Radius.elliptical(10.0, 25.0));
  path2.relativeArcToPoint(Offset(20.0, 0.0),
      radius: Radius.elliptical(10.0, 25.0));

  final rect = Rect.fromLTRB(290.0, 280.0, 310.0, 300.0);
  path2.addRect(rect);
  path2.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(10.0)));
  path2.addOval(Rect.fromLTRB(310.0, 280.0, 330.0, 300.0));
  path2.addArc(
      Rect.fromLTRB(310.0, 260.0, 350.0, 300.0), 1.5 * math.pi, math.pi);
  path2.moveTo(330.0, 260.0);

  List<Offset> points = new List.generate(41, (index) {
    double y = ((index % 2) == 0) ? 265.0 : 255.0;
    double x = 330.0 - 5.0 * index;
    return Offset(x, y);
  });
  path2.addPolygon(points, false);

  path.addPath(path2, Offset(0, 0));
  path.close();

  final Float64List matrix = Float64List(16);
  matrix[0] = 1;
  matrix[1] = 0;
  matrix[2] = 0;
  matrix[3] = 0;

  matrix[4] = 0;
  matrix[5] = 1;
  matrix[6] = 0;
  matrix[7] = 0;

  matrix[8] = 0;
  matrix[9] = 0;
  matrix[10] = 1;
  matrix[11] = 0;

  matrix[12] = 0;
  matrix[13] = -20.0;
  matrix[14] = 0;
  matrix[15] = 1;

  final Path pathCopy = path.transform(matrix).shift(Offset(-40.0, 0.0));
  path.reset();

  final Rect pathBounds = pathCopy.getBounds();
  final double clipWidth = 100.0;
  final double clipXPosition = triangle(pathBounds.width / 2.0, 2.0, time);
  final Rect clip = Rect.fromCenter(
      center:
          Offset(pathBounds.center.dx + clipXPosition, pathBounds.center.dy),
      width: clipWidth,
      height: pathBounds.height);
  canvas.clipRect(clip);

  canvas.drawPath(pathCopy, paint);

  canvas.restore();
}

void drawWave(Canvas canvas, double time) {
  canvas.save();

  final Path wavePath = Path();
  wavePath.moveTo(250, 100);
  double bend = triangle(75.0, 0.2, time);
  wavePath.cubicTo(250 + bend, 125, 250 - bend, 150, 250, 175);
  canvas.clipPath(wavePath);

  canvas.drawColor(Color.fromARGB(0xff, 0xff, 0, 0), BlendMode.srcOver);

  canvas.restore();

  canvas.save();
  final Path wavePath2 = Path();
  wavePath2.moveTo(300, 100);
  wavePath2.relativeCubicTo(-bend, 25, bend, 50, 0, 75);
  canvas.clipPath(wavePath2);

  canvas.drawColor(Color.fromARGB(0xff, 0, 0, 0xff), BlendMode.srcOver);

  canvas.restore();
}
