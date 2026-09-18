import 'dart:math' as math;

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The design's `size = 20` ring.
const double _markSize = 20;

/// Learned: a `color-mix(sage 22%, surface)` fill inside a
/// `color-mix(sage 55%, rule)` ring, with the check at half the ring's size.
const double _learnedFill = 0.22;
const double _learnedRing = 0.55;
const double _checkSize = 10;

/// To learn: a `1.5px dashed var(--rule)` ring around a `4px` dot at half ink.
const double _dashedStroke = 1.5;
const double _dashLength = 3;
const double _dashGap = 3;
const double _dotSize = 4;
const double _dotAlpha = 0.5;

/// Reference: a hairline ring with a `7 × 1.5` dash — off the path, not "not
/// yet", which the dashed ring would promise.
const double _dashWidth = 7;
const double _dashHeight = 1.5;
const double _dashAlpha = 0.55;

/// Where a term sits on the path, as one 20px mark.
///
/// **Never drawn alone.** Hue and shape are what a screen reader cannot
/// report, so every surface pairs this with the status word; it carries no
/// semantics of its own for that reason.
class StatusMark extends StatelessWidget {
  /// Creates a [StatusMark].
  const StatusMark({required this.status, super.key});

  /// The state being drawn.
  final DictionaryStatus status;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return switch (status) {
      DictionaryStatus.learned => Container(
        width: _markSize,
        height: _markSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.alphaBlend(
            mood.sage.withValues(alpha: _learnedFill),
            mood.surface,
          ),
          border: Border.all(
            color: Color.alphaBlend(
              mood.sage.withValues(alpha: _learnedRing),
              mood.rule,
            ),
          ),
        ),
        child: Center(
          child: IconMark(AppIcon.check, size: _checkSize, color: mood.sage),
        ),
      ),
      // Sized explicitly: a CustomPaint with a child takes the child's size,
      // and the dot alone would shrink the ring to nothing.
      DictionaryStatus.toLearn => SizedBox.square(
        dimension: _markSize,
        child: CustomPaint(
          painter: _DashedRingPainter(color: mood.rule),
          child: Center(
            child: Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mood.inkMute.withValues(alpha: _dotAlpha),
              ),
            ),
          ),
        ),
      ),
      DictionaryStatus.reference => Container(
        width: _markSize,
        height: _markSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: mood.rule),
        ),
        child: Center(
          child: Container(
            width: _dashWidth,
            height: _dashHeight,
            decoration: BoxDecoration(
              color: mood.inkMute.withValues(alpha: _dashAlpha),
              borderRadius: BorderRadius.circular(_dashHeight),
            ),
          ),
        ),
      ),
    };
  }
}

/// A dashed circle — CSS's `border: dashed` has no Flutter counterpart.
class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _dashedStroke
      ..strokeCap = StrokeCap.round;
    final radius = (math.min(size.width, size.height) - _dashedStroke) / 2;
    final ring = Path()
      ..addOval(
        Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      );
    for (final metric in ring.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashLength),
          paint,
        );
        distance += _dashLength + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}
