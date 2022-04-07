import 'package:skwasm/skwasm.dart';
import 'bench_paths_recording.dart';

void main() {
  final Surface surface = Surface('#test-canvas', 400, 400);
  final Canvas canvas = surface.getCanvas();
  for (double x = 10.0; x < 400.0; x += 20) {
    for (double y = 10.0; y < 400.0; y += 20) {
      final Paint paint = Paint();
      paint.isAntiAlias = true;
      paint.color = Color.fromARGB(0xFF, 0xFF, ((x / 400.0) * 255.0).round(),
          ((y / 400.0) * 255.0).round());
      canvas.drawCircle(Offset(x, y), 5.0, paint);
    }
  }

  final Path path = Path();
  path.moveTo(50, 50);
  path.cubicTo(150, 0, 300, 100, 350, 50);
  path.lineTo(350, 350);
  path.cubicTo(300, 400, 150, 300, 50, 350);
  path.close();

  final Paint paint = Paint();
  paint.isAntiAlias = true;
  paint.color = const Color.fromARGB(0xFF, 0x00, 0x00, 0xFF);
  paint.style = PaintingStyle.stroke;
  paint.strokeWidth = 3.0;

  canvas.drawPath(path, paint);
  surface.flush();
}

@pragma('wasm:export', 'benchPaths')
void benchPaths() {
  for(int i = 0; i < 10; i++) {
    createPaths();
    destroyPaths();
  }
}
