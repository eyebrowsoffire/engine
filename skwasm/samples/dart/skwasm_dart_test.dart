import '../../pkg/skwasm/lib/skwasm.dart';
void main() {
  final Surface surface = new Surface("#test-canvas");
  final Canvas canvas = surface.getCanvas();
  canvas.drawCircle(150, 200, 75);
  surface.flush();
}
