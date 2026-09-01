import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// *Study n terms as flashcards* — the shelf's way into the drill
/// (`library.jsx:188-200`).
///
/// **It counts the deck, not the group above it.** The shelf lists every saved
/// term; the deck is the ones this learner can be dealt. Where those differ,
/// the row says the number the drill will actually show — a row offering to
/// study twelve that opens onto four is worse than no row.
///
/// Absent when the deck is empty, which is the one place the drill's teaching
/// empty state would say nothing new: a learner looking at their own shelf can
/// already see that no terms are on it.
class SavedStudyRow extends ConsumerWidget {
  /// Creates a [SavedStudyRow].
  const SavedStudyRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(flashcardDeckSizeProvider).asData?.value ?? 0;
    if (cards == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final mood = context.mood;
    final label = FlashcardsCopy.studyRow(cards);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: mood.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          side: BorderSide(color: mood.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushNamed(AppRoutes.flashcards.name),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: mood.ink,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconMark(AppIcon.chevron, color: mood.inkMute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
