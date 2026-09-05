import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/bordered_tap_row.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_destination.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// *Study n terms as flashcards* — the shelf's way into the drill.
///
/// **Drawn whenever the shelf has terms**, as the design draws it: this is one
/// of the drill's three entry points, and one that came and went with the deck
/// would be undiscoverable in exactly the state a learner most needs telling
/// about it.
///
/// **It counts the deck, not the group above it.** The shelf lists every saved
/// term; the deck is the ones this learner can be dealt. Where the two differ
/// the row drops the count and offers the drill by name, rather than promising
/// a number the drill would not deal — and the drill's own state explains why
/// ([#468](https://github.com/maximsan/brewpath/issues/468) owns that copy).
class SavedStudyRow extends ConsumerWidget {
  /// Creates a [SavedStudyRow].
  const SavedStudyRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(flashcardDeckSizeProvider).asData?.value ?? 0;

    final theme = Theme.of(context);
    final mood = context.mood;
    final label = cards == 0
        ? FlashcardsCopy.title
        : FlashcardsCopy.studyRow(cards);

    return BorderedTapRow(
      semanticsLabel: label,
      onTap: () => unawaited(context.pushActivity(flashcardReview)),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(color: mood.ink),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconMark(AppIcon.chevron, color: mood.inkMute),
        ],
      ),
    );
  }
}
