import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The dictionary drills, leading the Games group (`screens.jsx:948-971`).
///
/// **Always here, and always free**, whatever the learner owns. The drill is
/// over their own saved terms, so there is nothing in it to sell — which is
/// why this row carries no lock and no tier check, unlike every game beneath
/// it.
///
/// **And always here when the deck is empty.** The row is how a learner finds
/// out flashcards exist; hiding it until they have bookmarked something would
/// mean only the learners who already knew could ever discover it. An empty
/// deck opens the drill's teaching state, which is written for exactly this
/// arrival.
///
/// #98's *Guess the term* is the second row this card is built to hold.
class PracticeDrillsWidget extends StatelessWidget {
  /// Creates a [PracticeDrillsWidget].
  const PracticeDrillsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: _DrillRow(
        title: FlashcardsCopy.title,
        eyebrow: FlashcardsCopy.practiceRowEyebrow,
        onTap: () => context.pushNamed(AppRoutes.flashcards.name),
      ),
    );
  }
}

/// One drill, in the shape the game rows beside it take.
class _DrillRow extends StatelessWidget {
  const _DrillRow({
    required this.title,
    required this.eyebrow,
    required this.onTap,
  });

  final String title;
  final String eyebrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Semantics(
      button: true,
      label: '$title. $eyebrow.',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      // The meta treatment the game rows beside it take:
                      // 0.08em, not the smallcaps rung's 0.14em.
                      style: AppText.label(
                        color: mood.inkMute,
                        face: AppFace.mono,
                        tracking: AppTracking.meta,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: mood.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconMark(AppIcon.chevron, color: mood.inkMute),
            ],
          ),
        ),
      ),
    );
  }
}
