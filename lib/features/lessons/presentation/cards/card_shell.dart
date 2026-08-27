import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The commit a card offers before it has latched, in place of Continue.
///
/// Its own value rather than a label and a callback passed loose, because the
/// shell shows the action only when both are present — one nullable field
/// makes that unrepresentable rather than merely unlikely.
@immutable
class CardCommit {
  /// Creates a [CardCommit].
  const CardCommit({required this.label, required this.onCommit});

  /// What the button says, e.g. `Check answers`.
  final String label;

  /// Null while the card has nothing to commit, which disables the button.
  final VoidCallback? onCommit;
}

/// Letter-spacing for the small-caps eyebrow above a card's title.
const double _eyebrowTracking = 1.2;

/// The frame every card renders inside.
///
/// It owns one rule, and it owns it in one place so no card can forget it:
/// continuing is gated on the card having latched. A card that has not been
/// answered has no way forward, and there is no second label for a wrong
/// answer — moving on is moving on, whatever the learner scored.
///
/// A kind that commits **separately** from answering — `multi`, where a set is
/// not finished until the learner says so — passes [commit]. The shell then
/// shows that action in place of Continue until the card latches, which is the
/// design's single swapping button and keeps the rule here rather than letting
/// a card draw a second one of its own.
class CardShell extends StatelessWidget {
  /// Creates a [CardShell].
  const CardShell({
    required this.latched,
    required this.onContinue,
    required this.children,
    this.label,
    this.title,
    this.commit,
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

  /// The action shown instead of Continue until the card latches, for a kind
  /// that commits separately from answering. Null for every other kind, which
  /// shows a disabled Continue while it waits.
  final CardCommit? commit;

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
        if (commit != null && !latched)
          FilledButton(
            onPressed: commit!.onCommit,
            child: Text(commit!.label),
          )
        else
          FilledButton(
            onPressed: latched ? onContinue : null,
            child: const Text(AppLabels.continueLabel),
          ),
      ],
    );
  }
}
