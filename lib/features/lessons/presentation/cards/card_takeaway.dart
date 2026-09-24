import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The closing line a card sets off from its body — a rule, a takeaway, a note.
///
/// A hairline, a mono kicker, then the line in the display face at heading
/// size in full ink; only [label] changes between callers. Deliberately not
/// grey body copy, which would read as one more paragraph. Read as a single
/// node so the kicker and the line are delivered together.
class CardTakeaway extends StatelessWidget {
  /// Creates a [CardTakeaway].
  const CardTakeaway({required this.label, required this.text, super.key});

  /// The kicker naming what kind of line this is.
  final String label;

  /// The line itself.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      label: context.strings.takeawaySemantics(label, text),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: mood.rule)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: mood.inkMute,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(text, style: AppText.heading(mood: mood)),
          ],
        ),
      ),
    );
  }
}
