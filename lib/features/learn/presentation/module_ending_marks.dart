import 'package:brew_path/features/progress/presentation/freeze_mark.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// *Freeze earned*, as the module ending says it: one centred line under the
/// points rather than a list of one.
class FreezeEarnedLine extends StatelessWidget {
  /// Creates a [FreezeEarnedLine].
  const FreezeEarnedLine({super.key});

  /// The design's `FreezeMark size={14}` here.
  static const double markSize = 14;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final label = context.strings.moduleFreezeEarned;

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
