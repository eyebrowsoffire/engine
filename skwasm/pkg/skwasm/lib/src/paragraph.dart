import 'geometry.dart';
import 'hash_codes.dart';

class LineMetrics {
  factory LineMetrics({
    required bool hardBreak,
    required double ascent,
    required double descent,
    required double unscaledAscent,
    required double height,
    required double width,
    required double left,
    required double baseline,
    required int lineNumber,
  }) {
    throw UnimplementedError();
  }

  bool get hardBreak {
    throw UnimplementedError();
  }

  double get ascent {
    throw UnimplementedError();
  }

  double get descent {
    throw UnimplementedError();
  }

  double get unscaledAscent {
    throw UnimplementedError();
  }

  double get height {
    throw UnimplementedError();
  }

  double get width {
    throw UnimplementedError();
  }

  double get left {
    throw UnimplementedError();
  }

  double get baseline {
    throw UnimplementedError();
  }

  int get lineNumber {
    throw UnimplementedError();
  }
}

enum BoxHeightStyle {
  tight,
  max,
  includeLineSpacingMiddle,
  includeLineSpacingTop,
  includeLineSpacingBottom,
  strut,
}

enum BoxWidthStyle {
  // Provide tight bounding boxes that fit widths to the runs of each line
  // independently.
  tight,
  max,
}

// The order of this enum must match the order of the values in TextDirection.h's TextDirection.
enum TextDirection {
  rtl,
  ltr,
}

class TextBox {
  const TextBox.fromLTRBD(
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.direction,
  );
  final double left;
  final double top;
  final double right;
  final double bottom;
  final TextDirection direction;
  Rect toRect() => Rect.fromLTRB(left, top, right, bottom);
  double get start {
    return (direction == TextDirection.ltr) ? left : right;
  }

  double get end {
    return (direction == TextDirection.ltr) ? right : left;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TextBox &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom &&
        other.direction == direction;
  }

  @override
  int get hashCode => hashValues(left, top, right, bottom, direction);

  @override
  String toString() {
    return 'TextBox.fromLTRBD(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, ${right.toStringAsFixed(1)}, ${bottom.toStringAsFixed(1)}, $direction)';
  }
}

enum TextAffinity {
  upstream,
  downstream,
}

class TextPosition {
  const TextPosition({
    required this.offset,
    this.affinity = TextAffinity.downstream,
  })  : assert(offset != null), // ignore: unnecessary_null_comparison
        assert(affinity != null); // ignore: unnecessary_null_comparison
  final int offset;
  final TextAffinity affinity;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TextPosition &&
        other.offset == offset &&
        other.affinity == affinity;
  }

  @override
  int get hashCode => hashValues(offset, affinity);

  @override
  String toString() {
    return '$runtimeType(offset: $offset, affinity: $affinity)';
  }
}

class TextRange {
  const TextRange({
    required this.start,
    required this.end,
  })  : assert(start >= -1),
        assert(end >= -1);
  const TextRange.collapsed(int offset)
      : assert(offset >= -1),
        start = offset,
        end = offset;
  static const TextRange empty = TextRange(start: -1, end: -1);
  final int start;
  final int end;
  bool get isValid => start >= 0 && end >= 0;
  bool get isCollapsed => start == end;
  bool get isNormalized => end >= start;
  String textBefore(String text) {
    assert(isNormalized);
    return text.substring(0, start);
  }

  String textAfter(String text) {
    assert(isNormalized);
    return text.substring(end);
  }

  String textInside(String text) {
    assert(isNormalized);
    return text.substring(start, end);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TextRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => hashValues(
        start.hashCode,
        end.hashCode,
      );

  @override
  String toString() => 'TextRange(start: $start, end: $end)';
}

class ParagraphConstraints {
  const ParagraphConstraints({
    required this.width,
  }) : assert(width != null); // ignore: unnecessary_null_comparison
  final double width;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ParagraphConstraints && other.width == width;
  }

  @override
  int get hashCode => width.hashCode;

  @override
  String toString() => '$runtimeType(width: $width)';
}

class Paragraph {
  double get width {
    throw UnimplementedError();
  }

  double get height {
    throw UnimplementedError();
  }

  double get longestLine {
    throw UnimplementedError();
  }

  double get minIntrinsicWidth {
    throw UnimplementedError();
  }

  double get maxIntrinsicWidth {
    throw UnimplementedError();
  }

  double get alphabeticBaseline {
    throw UnimplementedError();
  }

  double get ideographicBaseline {
    throw UnimplementedError();
  }

  bool get didExceedMaxLines {
    throw UnimplementedError();
  }

  void layout(ParagraphConstraints constraints) {
    throw UnimplementedError();
  }

  List<TextBox> getBoxesForRange(int start, int end,
      {BoxHeightStyle boxHeightStyle = BoxHeightStyle.tight,
      BoxWidthStyle boxWidthStyle = BoxWidthStyle.tight}) {
    throw UnimplementedError();
  }

  TextPosition getPositionForOffset(Offset offset) {
    throw UnimplementedError();
  }

  TextRange getWordBoundary(TextPosition position) {
    throw UnimplementedError();
  }

  TextRange getLineBoundary(TextPosition position) {
    throw UnimplementedError();
  }

  List<TextBox> getBoxesForPlaceholders() {
    throw UnimplementedError();
  }

  List<LineMetrics> computeLineMetrics() {
    throw UnimplementedError();
  }
}
