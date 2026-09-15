import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_destination.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/dictionary/presentation/flashcards_copy.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The shelf's way into the flashcards drill, on the terms group header.
///
/// **Set at type weight, not object weight**: the same smallcaps as the group
/// label it sits opposite, differing only in accent and a small arrow. A
/// bordered pill outweighed the label beside it and made a secondary route
/// read louder than the group it belongs to. Padding restores the tap target.
class SavedStudyRow extends ConsumerWidget {
  /// Creates a [SavedStudyRow].
  const SavedStudyRow({super.key});

  /// The design's `padding: 6px 4px` — a tap target without visible mass.
  static const EdgeInsets _tapPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xs,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The deck, not the group above it: the shelf lists every saved term,
    // the deck is the ones this learner can be dealt (#468).
    final cards = ref.watch(flashcardDeckSizeProvider).asData?.value ?? 0;
    final mood = context.mood;

    void open() => unawaited(context.pushActivity(flashcardReview));

    return Semantics(
      // Its own node: inside the group's list item it would otherwise merge
      // with the header and the first row into one announcement.
      container: true,
      button: true,
      label: cards == 0 ? FlashcardsCopy.title : FlashcardsCopy.studyRow(cards),
      // The pill only names the destination, so the deck size lives here —
      // and so does the tap, since excluding the children drops the InkWell's.
      onTap: open,
      excludeSemantics: true,
      child: InkWell(
        onTap: open,
        child: Padding(
          padding: _tapPadding,
          // The group label already carries the count, so the route only
          // names its destination.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmallcapsLabel(FlashcardsCopy.title, color: mood.accentText),
              const SizedBox(width: AppSpacing.xs),
              IconMark(AppIcon.chevron, color: mood.accentText),
            ],
          ),
        ),
      ),
    );
  }
}
