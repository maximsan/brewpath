import 'package:brew_path/core/utils/module_icons.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/cards/domain/card_unlock.dart';
import 'package:brew_path/features/cards/presentation/card_art_well.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the learner asked for by closing the card sheet.
enum CardSheetIntent {
  /// They pressed the way in: take them to the course.
  goToCourse,
}

/// A card the learner has not earned: its face, and nothing behind it.
///
/// The art, the title and the lesson that earns it, with a way in — not the
/// summary and not the keepsake line, which are the lesson's reward
/// ([ADR-0015](../../../../docs/adr/0015-a-link-to-an-unearned-card-shows-its-face-not-its-payload.md)).
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
        CardArtWell(
          kind: card.kind,
          fallback: moduleMark(card.iconName),
          // Muted where the earned face takes the accent: a stand-in mark on
          // an unheld card is the state the grid draws as a silhouette.
          fallbackColor: mood.inkMute,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          earnLine(
            context.strings,
            lessonTitle: lessonTitle,
            moduleTag: card.moduleTag,
          ),
          style: text.bodyLarge?.copyWith(color: mood.inkMute),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: context.strings.collectibleGoToCourse,
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
