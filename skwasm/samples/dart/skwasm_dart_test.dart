import 'dart:math';
import '../../pkg/skwasm/lib/skwasm.dart';

void main() {
  final Surface surface = Surface('#test-canvas', 400, 400);
  final Canvas canvas = surface.getCanvas();
  final Path path = Path();
  final Random random = Random();
  for(int i = 0; i < 40; i++) {
    final double x = random.nextDouble() * 400;
    final double y = random.nextDouble() * 400;
    final double radius = random.nextDouble() * 45.0 + 5.0;
    canvas.drawCircle(x, y, radius);
  }
  for(double x = 10.0; x < 400.0; x += 20) {
    for(double y = 10.0; y < 400.0; y += 20) {
      canvas.drawCircle(x, y, 5.0);
    }
  }
  surface.flush();
}
