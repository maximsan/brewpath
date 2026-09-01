import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The dictionary's practice row: one slim chip per drill
/// (`dictionary.jsx:271-296`).
///
/// **The row exists with one chip in it.** #98's *Guess the term* adds the
/// second; building the row now rather than a lone button means that ticket
/// adds a chip instead of re-laying-out this screen.
class DictionaryQuickChips extends ConsumerWidget {
  /// Creates a [DictionaryQuickChips].
  const DictionaryQuickChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: FlashcardsCopy.title,
            // The deck's own count, not the saved one. A chip promising
            // twelve that opens onto four is exactly the lie the deck
            // provider exists to prevent.
            count: ref.watch(flashcardDeckSizeProvider).asData?.value,
            onTap: () => context.pushNamed(AppRoutes.flashcards.name),
          ),
        ),
      ],
    );
  }
}

/// One chip: what the drill is, and how much material it has.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.count, required this.onTap});

  final String label;

  /// How many cards are behind it — null while the deck is still resolving,
  /// when the chip shows its name alone rather than a zero it may have to
  /// take back.
  final int? count;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      button: true,
      label: count == null ? label : '$label, $count cards',
      excludeSemantics: true,
      child: Material(
        color: mood.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          side: BorderSide(color: mood.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: mood.ink,
                    ),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$count',
                    style: AppText.label(mood: mood, face: AppFace.mono),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
