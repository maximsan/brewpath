import 'package:brew_path/features/progress/presentation/freeze_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The accent wash behind a celebration face — the design's
/// `radial-gradient(circle at 50% 40%, …accent 14%…, transparent 60%)`.
///
/// Two faces, two washes: the reward side sits higher and stronger
/// (`ellipse at 50% 30%`, 18%), because the card it lights is higher up the
/// screen than the tree is.
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

/// *Freeze earned*, as the module ending says it: one centred line under the
/// points rather than a list of one.
class FreezeEarnedLine extends StatelessWidget {
  /// Creates a [FreezeEarnedLine].
  const FreezeEarnedLine({super.key});

  /// The whole line, written as one sentence because it is drawn as one.
  static const String label = 'Freeze earned · One missed day covered';

  /// The design's `FreezeMark size={14}` here.
  static const double markSize = 14;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FreezeMark(color: mood.accent, size: markSize),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.micro(mood: mood, color: mood.accentText),
            ),
          ),
        ],
      ),
    );
  }
}
