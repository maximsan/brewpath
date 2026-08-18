import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How far through a run the learner is: one segment per round, filled for the
/// rounds already answered.
///
/// Segments rather than a bar because the count is small and known, and a
/// learner reads "two of six left" off shapes faster than off a fraction.
class RoundProgressStrip extends StatelessWidget {
  /// Creates a [RoundProgressStrip].
  const RoundProgressStrip({
    required this.played,
    required this.total,
    super.key,
  });

  /// Rounds already answered.
  final int played;

  /// Rounds in the run.
  final int total;

  static const double _segmentHeight = 4;
  static const double _segmentGap = 4;
  static const double _emptyAlpha = 0.25;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: 'Round ${played + 1} of $total',
      child: Row(
        children: [
          for (var index = 0; index < total; index++) ...[
            if (index > 0) const SizedBox(width: _segmentGap),
            Expanded(
              child: Container(
                height: _segmentHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  color: index < played
                      ? mood.accent
                      : mood.ink.withValues(alpha: _emptyAlpha),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
