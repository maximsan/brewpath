import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/shared/models/content/content_card.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Eyebrow for a card that does not name its own step.
const String _defaultTag = 'HANDS ON';

/// Label above a practical card's closing note.
const String _takeawayLabel = 'Worth knowing';

/// Tint strength behind the takeaway block.
const double _takeawayTint = 0.10;

/// The hands-on card: something to go and do, in order.
///
/// Ungraded, and it has nothing to latch on — there is no question here, so
/// continue is live from the first frame exactly as `visual`'s is. It reports
/// no success and cannot move mastery.
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
      label: card.tag.isEmpty ? _defaultTag : card.tag,
      title: card.title,
      children: [
        for (final paragraph in card.paragraphs) ...[
          Text(paragraph, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (card.note.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _Takeaway(note: card.note),
        ],
      ],
    );
  }
}

/// The closing note, labelled so it reads as an aside rather than a step.
///
/// Labelled because a practical card's body is a sequence of instructions, and
/// an unlabelled trailing line reads as one more of them.
class _Takeaway extends StatelessWidget {
  const _Takeaway({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: mood.sage.withValues(alpha: _takeawayTint),
        borderRadius: BorderRadius.circular(AppRadii.chrome),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _takeawayLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: mood.inkMute,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(note, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
