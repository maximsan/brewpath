import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The accent wash behind a screen the app is pleased about — the design's
/// `radial-gradient(circle at 50% 40%, …accent 14%…, transparent 60%)`.
///
/// Every host names its own instance below rather than passing three numbers at
/// a call site, so the washes can be read against each other in one place: the
/// higher the thing being lit, the higher and stronger the wash.
class CelebrationGlow extends StatelessWidget {
  /// Creates a [CelebrationGlow].
  const CelebrationGlow({
    required this.strength,
    required this.centre,
    required this.edge,
    super.key,
  });

  /// The wash behind the module's own celebration.
  static const CelebrationGlow celebration = CelebrationGlow(
    strength: 0.14,
    centre: Alignment(0, -0.2),
    edge: 0.6,
  );

  /// The wash behind the reward card.
  static const CelebrationGlow reward = CelebrationGlow(
    strength: 0.18,
    centre: Alignment(0, -0.4),
    edge: 0.55,
  );

  /// The wash behind the Plus offer — `ellipse at 50% 16%`, `accent 16%`,
  /// `transparent 58%`. The highest of the four, because it lights a hero
  /// sitting under the top bar.
  static const CelebrationGlow offer = CelebrationGlow(
    strength: 0.16,
    centre: Alignment(0, -0.68),
    edge: 0.58,
  );

  /// The wash behind the purchase welcome — `ellipse at 50% 28%`, `accent 20%`.
  static const CelebrationGlow purchase = CelebrationGlow(
    strength: 0.20,
    centre: Alignment(0, -0.44),
    edge: 0.58,
  );

  /// How much accent the wash carries at its centre.
  final double strength;

  /// Where the wash is brightest.
  final Alignment centre;

  /// Where the wash has faded out entirely — `transparent 60%` on the
  /// celebration, `55%` behind the card.
  final double edge;

  @override
  Widget build(BuildContext context) {
    final accent = context.mood.accent;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: centre,
            colors: [
              accent.withValues(alpha: strength),
              accent.withValues(alpha: 0),
            ],
            stops: [0, edge],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
