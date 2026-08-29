import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Tracking on the kicker, which the design sets in mono small caps.
const double _kickerTracking = 1.6;

/// The closing line a card sets off from its body — a rule, a takeaway, a note.
///
/// One treatment for every card that has one: a hairline, a mono kicker, then
/// the line itself in the display face at heading size in full ink. Only
/// [label] changes between callers.
///
/// It is deliberately **not** grey body copy. The line sits directly under a
/// card's body, and set in the same size and colour it reads as one more
/// paragraph of that body rather than a different class of thing.
///
/// Read as a single node so a screen reader delivers the kicker and the line
/// together, rather than a bare label followed by an unattached sentence.
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
      label: '$label. $text',
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
                letterSpacing: _kickerTracking,
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
