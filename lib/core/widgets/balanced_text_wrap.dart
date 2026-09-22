import 'package:flutter/painting.dart';

/// How many halvings the search takes: 12 puts a 400-px box inside a tenth of
/// a pixel, and a fixed count keeps the layout work bounded.
const int _searchSteps = 12;

/// The narrowest box that still holds [text] in the number of lines it takes
/// at [maxWidth] — the design's `textWrap: 'balance'`, which Flutter has no
/// flag of its own for.
///
/// Laying the text out that narrow is what evens the lines: the last one can
/// no longer hold a single word while the ones above it run full.
double balancedWrapWidth({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required TextDirection textDirection,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  if (!maxWidth.isFinite || maxWidth <= 0) return maxWidth;

  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
    // So `width` reports the longest line rather than the box it was given,
    // which is how a candidate too narrow to hold the text is spotted.
    textWidthBasis: TextWidthBasis.longestLine,
  );
  int linesAt(double width) {
    painter.layout(maxWidth: width);
    return painter.computeLineMetrics().length;
  }

  try {
    final lines = linesAt(maxWidth);
    if (lines < 2) return maxWidth;

    var tooNarrow = 0.0;
    var fits = maxWidth;
    for (var step = 0; step < _searchSteps; step++) {
      final candidate = (tooNarrow + fits) / 2;
      // A candidate narrower than the longest word does not gain a line — the
      // word just hangs out of the box — so overflow is the second rejection.
      if (linesAt(candidate) <= lines && painter.width <= candidate) {
        fits = candidate;
      } else {
        tooNarrow = candidate;
      }
    }
    return fits;
  } finally {
    painter.dispose();
  }
}
