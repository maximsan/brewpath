import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_takeaway.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Size of the tune mark beside the eyebrow.
const double _tuneMarkSize = 14;

/// The hands-on card: something to go and do, in order.
///
/// Ungraded with nothing to latch on, so continue is live from the first
/// frame. It draws its own eyebrow rather than passing one to [CardShell]:
/// the design gives this kind an accent label with a tune mark, where the
/// shell's is muted and unmarked.
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
        _Eyebrow(
          tag: card.tag.isEmpty ? context.strings.practicalHandsOn : card.tag,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(card.title, style: AppText.title(mood: context.mood)),
        const SizedBox(height: AppSpacing.md),
        for (final paragraph in card.paragraphs) ...[
          Text(paragraph, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (card.note.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          CardTakeaway(
            label: context.strings.practicalTakeaway,
            text: card.note,
          ),
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
            color: mood.accentText,
          ),
        ),
      ],
    );
  }
}
