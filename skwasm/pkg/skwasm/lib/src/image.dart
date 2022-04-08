import 'dart:typed_data';

enum ImageByteFormat {
  rawRgba,
  rawStraightRgba,
  rawUnmodified,
  png,
}

class Image {
  int get width {
    throw UnimplementedError();
  }

  int get height {
    throw UnimplementedError();
  }

  Future<ByteData?> toByteData(
      {ImageByteFormat format = ImageByteFormat.rawRgba}) {
    throw UnimplementedError();
  }

  void dispose() {
    throw UnimplementedError();
  }

  bool get debugDisposed {
    throw UnimplementedError();
  }

  Image clone() => this;

  bool isCloneOf(Image other) => other == this;

  List<StackTrace>? debugGetOpenHandleStackTraces() => null;

  @override
  String toString() => '[$width\u00D7$height]';
}
