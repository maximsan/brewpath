import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/cards/domain/card_unlock.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The mark's size, matching the sheet's earned face so the two read as one
/// card in two states rather than two layouts.
const double _markSize = 96;

/// What the learner asked for by closing the card sheet.
enum CardSheetIntent {
  /// They pressed the way in: take them to the course.
  goToCourse,
}

/// A card the learner has not earned: its face, and nothing behind it.
///
/// [ADR-0015](../../../../docs/adr/0015-a-link-to-an-unearned-card-shows-its-face-not-its-payload.md)
/// — the art, the title (the sheet's own) and the lesson that earns it, with
/// a way in. **Not** the summary and **not** the keepsake line: those are the
/// lesson's reward, and card ids read `c1`, `c-m2l1`, so this sheet is
/// reachable by guessing as well as by a shared link.
class CardLockedFace extends ConsumerWidget {
  /// Creates a [CardLockedFace] for [card].
  const CardLockedFace({required this.card, super.key});

  /// The card being previewed, which the learner does not hold.
  final CoffeeCardModel card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = context.mood;
    final text = Theme.of(context).textTheme;
    final lessonTitle = ref
        .watch(cardUnlockLessonTitleProvider(card.lessonId))
        .asData
        ?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: IconMark(
            moduleMark(card.iconName),
            size: _markSize,
            // Muted rather than accented: the grid draws an unheld card as a
            // silhouette, and this is the same card in the same state.
            color: mood.inkMute,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          earnLine(lessonTitle: lessonTitle, moduleTag: card.moduleTag),
          style: text.bodyLarge?.copyWith(color: mood.inkMute),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Go to the course',
          // Answers the sheet rather than navigating from inside it. Whoever
          // opened this owns the route it sits on and has to leave that route
          // before going anywhere — a `go` from here would strand the page
          // underneath, still holding a pop nobody coordinates.
          onPressed: () =>
              Navigator.of(context).pop(CardSheetIntent.goToCourse),
        ),
      ],
    );
  }
}
