import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_mark.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_mark.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The drill row on Dictionary home — one slim chip per practice surface the
/// dictionary owns.
///
/// Both chips now (#97, #98), in the design's own order: Flashcards leads
/// because it drills what the learner chose to keep, and only it carries a
/// count — the design gives *Guess the term* none, since the whole glossary
/// is not a number worth reading.
class DictionaryQuickChips extends ConsumerWidget {
  /// Creates a [DictionaryQuickChips].
  const DictionaryQuickChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    children: [
      Expanded(
        // The deck's own count, not the saved set's: a chip promising twelve
        // that opens onto four is the lie the deck provider exists to prevent.
        child: _FlashcardsChip(
          cards: ref.watch(flashcardDeckSizeProvider).asData?.value,
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      const Expanded(child: _VocabChip()),
    ],
  );
}

/// Flashcards, with how many cards are behind it.
class _FlashcardsChip extends StatelessWidget {
  const _FlashcardsChip({required this.cards});

  /// Null while the deck is resolving, when the chip shows its name alone
  /// rather than a zero it may have to take back.
  final int? cards;

  /// The mark's drawn size in a chip, from the design's own row.
  static const double _markSize = 18;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: cards == null
          ? FlashcardsCopy.title
          : '${FlashcardsCopy.title}, ${FlashcardsCopy.deckLine(cards!)}',
      excludeSemantics: true,
      child: Material(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          onTap: () => unawaited(context.pushFlashcards()),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: mood.rule),
              borderRadius: BorderRadius.circular(AppRadii.chrome),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                FlashcardsMark(
                  size: _markSize,
                  color: mood.inkMute,
                  accent: mood.accent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    FlashcardsCopy.title,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.support(mood: mood),
                  ),
                ),
                if (cards != null)
                  Text(
                    '$cards',
                    style: AppText.micro(mood: mood, face: AppFace.mono),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VocabChip extends StatelessWidget {
  const _VocabChip();

  /// The mark's drawn size in a chip, from the design's own row.
  static const double _markSize = 18;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Semantics(
      button: true,
      label: VocabCopy.title,
      hint: VocabCopy.rowSubtitle,
      excludeSemantics: true,
      child: Material(
        color: mood.surface,
        borderRadius: BorderRadius.circular(AppRadii.chrome),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          onTap: () => unawaited(
            context.pushNamed(AppRoutes.vocabGame.name),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: mood.rule),
              borderRadius: BorderRadius.circular(AppRadii.chrome),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                VocabMark(
                  size: _markSize,
                  color: mood.inkMute,
                  accent: mood.accent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    VocabCopy.title,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.support(mood: mood),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
