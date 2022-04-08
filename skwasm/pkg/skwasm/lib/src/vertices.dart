import 'dart:typed_data';

import 'color.dart';
import 'geometry.dart';

enum VertexMode {
  triangles,
  triangleStrip,
  triangleFan,
}

class Vertices {
  factory Vertices(
    VertexMode mode,
    List<Offset> positions, {
    List<Offset>? textureCoordinates,
    List<Color>? colors,
    List<int>? indices,
  }) {
    throw UnimplementedError();
  }

  factory Vertices.raw(
    VertexMode mode,
    Float32List positions, {
    Float32List? textureCoordinates,
    Int32List? colors,
    Uint16List? indices,
  }) {
    throw UnimplementedError();
  }
}
