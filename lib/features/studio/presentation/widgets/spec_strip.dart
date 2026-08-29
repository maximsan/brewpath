import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// One labelled fact about the selected species.
///
/// The design's `.form-row`: the label in **sans** small-caps (`index.html:302`
/// — not mono, though every other small-caps label in the app is), the value in
/// mono against the right edge, and a hairline under every row but the last
/// (`.form-row:last-child { border-bottom: none }`). The same shape a
/// dictionary term carries, so the grove reads as course material rather than
/// as decoration.
class SpecRow extends StatelessWidget {
  /// Creates a [SpecRow].
  const SpecRow({
    required this.label,
    required this.value,
    this.last = false,
    super.key,
  });

  /// What the fact is called.
  final String label;

  /// The fact, as the bank authored it.
  final String value;

  /// Whether this is the strip's last row, which carries no hairline.
  final bool last;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: mood.rule)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label.toUpperCase(),
              style: AppText.label(mood: mood),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppText.support(mood: mood, face: AppFace.mono),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
