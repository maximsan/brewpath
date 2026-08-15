import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Letter-spacing for the small-caps eyebrow above a card's title.
const double _eyebrowTracking = 1.2;

/// The frame every card renders inside.
///
/// It owns one rule, and it owns it in one place so no card can forget it:
/// continuing is gated on the card having latched. A card that has not been
/// answered has no way forward, and there is no second label for a wrong
/// answer — moving on is moving on, whatever the learner scored.
class CardShell extends StatelessWidget {
  /// Creates a [CardShell].
  const CardShell({
    required this.latched,
    required this.onContinue,
    required this.children,
    this.label,
    this.title,
    super.key,
  });

  /// Whether the card has been committed. Until it is, continue stays disabled.
  final bool latched;

  /// Called when the learner moves on.
  final CardAdvance onContinue;

  /// The card's own body.
  final List<Widget> children;

  /// Small-caps eyebrow, e.g. `CONCEPT` or `AT THE SHELF`.
  final String? label;

  /// The card's heading, where its kind has one.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: mood.inkMute,
              letterSpacing: _eyebrowTracking,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ...children,
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: latched ? onContinue : null,
          child: const Text(AppLabels.continueLabel),
        ),
      ],
    );
  }
}
