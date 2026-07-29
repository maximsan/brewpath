import 'package:coffee_quest/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// A speech bubble anchored above any companion [child] (a static or animated
/// `Roasty`, or a `Companion`). Pure composition — it has no controller
/// dependency, so it works for both the talking-mascot and full-companion uses.
class CompanionBubble extends StatelessWidget {
  /// Creates a [CompanionBubble].
  const CompanionBubble({
    required this.child,
    required this.text,
    this.maxBubbleWidth = _defaultMaxWidth,
    super.key,
  });

  static const double _defaultMaxWidth = 240;
  static const double _tailSize = 10;
  static const double _radius = 16;

  /// The mascot (or any widget) the bubble points at.
  final Widget child;

  /// The line shown in the bubble.
  final String text;

  /// Caps the bubble width so long lines wrap rather than stretch.
  final double maxBubbleWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
              semanticsLabel: text,
            ),
          ),
        ),
        // Downward tail pointing at the mascot.
        CustomPaint(
          size: const Size(_tailSize * 2, _tailSize),
          painter: _BubbleTailPainter(color: colors.surfaceContainerHighest),
        ),
        child,
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) => old.color != color;
}
