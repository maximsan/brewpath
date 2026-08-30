import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_option_tile.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_tints.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/multi_choice_box.dart';
import 'package:brew_path/features/lessons/presentation/cards/multi_scoring.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The tag naming an answer the learner did not pick.
const String _missedTag = 'MISSED';

/// Tracking on that tag, which the design sets in mono small caps.
const double _tagTracking = 1.4;

/// The design keeps the outline hairline in every state — [CardOptionTile]'s
/// default. Only a pre-submit pick reads heavier: `.ms-choice.on` lays
/// `box-shadow: inset 0 0 0 1px` in the border's own colour over the 1px
/// border, which renders as a 2px edge. Doubling the border is the same pixels
/// in one property — an inset shadow would have to be painted outside
/// `OutlinedButton`'s shape to sit there.
const double _pickedInset = 2;

/// The multi-select list a `multi` card picks from.
///
/// Separate from [ChoiceList] rather than a flag on it: that list latches on
/// the **first** tap and never reopens, which is the opposite of what a set
/// needs. Merging the two would put a mode switch through every branch of a
/// widget whose single-commit rule is the thing worth keeping.
///
/// It is handed [marks] and [submitted] rather than working either out. The
/// card owns the answer key because it also scores against it, and deriving
/// them twice is how the two become able to disagree — a card whose key holds
/// no correct choice would leave every mark [MultiMark.none] after a commit,
/// and a list inferring the commit from the marks would stay open on it.
class MultiChoiceList extends StatelessWidget {
  /// Creates a [MultiChoiceList].
  const MultiChoiceList({
    required this.options,
    required this.selected,
    required this.marks,
    required this.submitted,
    required this.onToggle,
    super.key,
  });

  /// The options, in the order they should appear.
  final List<ChoiceOption> options;

  /// Display indices currently picked.
  final Set<int> selected;

  /// One mark per option, all [MultiMark.none] until the card is committed.
  final List<MultiMark> marks;

  /// Whether the card has been committed, and so is closed to further taps.
  final bool submitted;

  /// Called with the display index the learner tapped.
  final void Function(int index) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < options.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MultiOptionRow(
              text: options[index].text,
              picked: selected.contains(index),
              mark: marks[index],
              onTap: submitted ? null : () => onToggle(index),
            ),
          ),
      ],
    );
  }
}

/// One option row, in the four states the design draws.
class _MultiOptionRow extends StatelessWidget {
  const _MultiOptionRow({
    required this.text,
    required this.picked,
    required this.mark,
    this.onTap,
  });

  final String text;
  final bool picked;
  final MultiMark mark;
  final VoidCallback? onTap;

  /// The design's four states, read straight across.
  ///
  /// A **missed** answer is the only dashed one: it is the one row the learner
  /// did not touch, and drawing it like a right answer would leave them
  /// reading every row to find what they got wrong.
  MultiOptionSkin _skin(MoodColors mood) => switch (mark) {
    MultiMark.correct => MultiOptionSkin(
      border: mood.sage,
      boxBorder: mood.sage,
      fill: mood.sage.withValues(alpha: CardTints.wash),
      boxFill: mood.sage,
      markColor: mood.surface,
      icon: AppIcon.check,
    ),
    MultiMark.incorrect => MultiOptionSkin(
      border: mood.berry,
      boxBorder: mood.berry,
      fill: mood.berry.withValues(alpha: CardTints.wrongWash),
      boxFill: mood.berry,
      markColor: mood.surface,
      icon: AppIcon.cross,
    ),
    MultiMark.missed => MultiOptionSkin(
      border: mood.sage,
      boxBorder: mood.sage,
      fill: null,
      boxFill: Colors.transparent,
      markColor: mood.sage,
      icon: AppIcon.check,
      dashed: true,
    ),
    MultiMark.none =>
      picked
          ? MultiOptionSkin(
              border: mood.accent,
              boxBorder: mood.accent,
              fill: null,
              boxFill: mood.accent,
              markColor: mood.accentInk,
              icon: AppIcon.check,
            )
          : MultiOptionSkin(
              border: mood.rule,
              boxBorder: mood.inkMute,
              fill: null,
              boxFill: Colors.transparent,
              markColor: Colors.transparent,
            ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final skin = _skin(mood);
    final open = mark == MultiMark.none;

    return CardOptionTile(
      onTap: onTap,
      borderColor: skin.border,
      fillColor: skin.fill,
      borderWidth: open && picked ? _pickedInset : null,
      dashed: skin.dashed,
      semanticsLabel: [
        text,
        if (picked) 'selected',
        mark.semantics,
      ].nonNulls.join(', '),
      child: Row(
        children: [
          MultiChoiceBox(skin: skin),
          const SizedBox(width: AppSpacing.base),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
          if (mark == MultiMark.missed)
            Text(
              _missedTag,
              style: theme.textTheme.labelSmall?.copyWith(
                color: mood.inkMute,
                letterSpacing: _tagTracking,
              ),
            ),
        ],
      ),
    );
  }
}
