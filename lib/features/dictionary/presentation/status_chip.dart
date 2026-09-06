import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_status_style.dart';
import 'package:brew_path/features/dictionary/presentation/status_mark.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Where a term sits on the path — a mark and a word, never one alone.
///
/// The design's `StatusChipMini` — a mark and a word in the status's own
/// colour, with **no chip behind it**. It is not a pill; the name is the
/// design's. The mark carries it at a glance; the word carries it for anyone
/// the colour does not reach, which is why the two never separate — the three
/// states differ by hue, and hue is the one thing a screen reader cannot
/// report.
class StatusChip extends StatelessWidget {
  /// Creates a [StatusChip].
  const StatusChip({required this.status, super.key});

  /// The state being shown.
  final DictionaryStatus status;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final colour = status.colorFrom(mood);

    return Semantics(
      label: status.label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusMark(status: status),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.label.toUpperCase(),
            style: AppText.micro(
              mood: mood,
              face: AppFace.mono,
              color: colour,
              tracking: AppTracking.marker,
            ),
          ),
        ],
      ),
    );
  }
}
