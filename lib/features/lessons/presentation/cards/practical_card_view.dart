import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Eyebrow for a card that does not name its own step.
const String _defaultTag = 'HANDS ON';

/// Label above a practical card's closing note.
const String _takeawayLabel = 'Worth knowing';

/// Tracking on the two small-caps labels, which the design sets wider than
/// [CardShell]'s so they read as mono rather than as a heading.
const double _labelTracking = 1.6;

/// Size of the tune mark beside the eyebrow.
const double _tuneMarkSize = 14;

/// The hands-on card: something to go and do, in order.
///
/// Ungraded, and it has nothing to latch on — there is no question here, so
/// continue is live from the first frame exactly as `visual`'s is. It reports
/// no success and cannot move mastery.
///
/// It draws its own eyebrow rather than passing one to [CardShell]: the design
/// gives this kind an **accent** label with a tune mark, where the shell's is
/// muted and unmarked. Passing `label` would put the muted one above the title
/// and leave nowhere for the marked one to go.
class PracticalCardView extends StatelessWidget {
  /// Creates a [PracticalCardView].
  const PracticalCardView({
    required this.card,
    required this.onContinue,
    super.key,
  });

  /// The card's content.
  final PracticalCard card;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardShell(
      latched: true,
      onContinue: onContinue,
      children: [
        _Eyebrow(tag: card.tag.isEmpty ? _defaultTag : card.tag),
        const SizedBox(height: AppSpacing.xs),
        Text(
          card.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final paragraph in card.paragraphs) ...[
          Text(paragraph, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (card.note.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _Takeaway(note: card.note),
        ],
      ],
    );
  }
}

/// The accent label naming the step, with the design's tune mark beside it.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Row(
      children: [
        Icon(Icons.tune, size: _tuneMarkSize, color: mood.accent),
        const SizedBox(width: AppSpacing.xs),
        Text(
          tag,
          style: theme.textTheme.labelSmall?.copyWith(
            color: mood.accent,
            letterSpacing: _labelTracking,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// The closing note, set off by a rule and named.
///
/// Named because a practical card's body is a sequence of instructions, and an
/// unlabelled trailing line reads as one more of them. Read as a single thing
/// rather than two, so a screen reader does not deliver a bare label and then
/// an unattached sentence.
class _Takeaway extends StatelessWidget {
  const _Takeaway({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      label: '$_takeawayLabel. $note',
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
              _takeawayLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: mood.inkMute,
                letterSpacing: _labelTracking,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(note, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
