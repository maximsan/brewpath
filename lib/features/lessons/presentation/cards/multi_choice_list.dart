import 'package:brew_path/features/lessons/presentation/cards/card_option_tile.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/multi_scoring.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The tag naming an answer the learner did not pick.
const String _missedTag = 'Missed';

/// Tint strength behind a row the learner actually picked.
const double _pickedTint = 0.12;

/// The multi-select list a `multi` card picks from.
///
/// Separate from [ChoiceList] rather than a flag on it: that list latches on
/// the **first** tap and never reopens, which is the opposite of what a set
/// needs. Merging the two would put a mode switch through every branch of a
/// widget whose single-commit rule is the thing worth keeping. The row *frame*
/// is shared — see [CardOptionTile].
///
/// It is handed [marks] rather than working them out. The card owns the answer
/// key because it also scores against it, and deriving it twice is how the two
/// become able to disagree.
class MultiChoiceList extends StatelessWidget {
  /// Creates a [MultiChoiceList].
  const MultiChoiceList({
    required this.options,
    required this.selected,
    required this.marks,
    required this.onToggle,
    super.key,
  });

  /// The options, in the order they should appear.
  final List<ChoiceOption> options;

  /// Display indices currently picked.
  final Set<int> selected;

  /// One mark per option, all [MultiMark.none] until the card is committed.
  final List<MultiMark> marks;

  /// Called with the display index the learner tapped.
  final void Function(int index) onToggle;

  bool get _submitted => marks.any((mark) => mark != MultiMark.none);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < options.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _row(
              context,
              option: options[index],
              picked: selected.contains(index),
              mark: marks[index],
              onTap: _submitted ? null : () => onToggle(index),
            ),
          ),
      ],
    );
  }

  /// One option row.
  ///
  /// **Fill, not only a tag, separates a missed answer from a right one.** A
  /// row whose only difference is its text makes the learner read every row to
  /// find the ones they got wrong — the same reasoning `bagpick` records for
  /// its closed cues, and the same reason neither draws the design's dashed
  /// border, which is a painter's job in Flutter and not worth one here.
  Widget _row(
    BuildContext context, {
    required ChoiceOption option,
    required bool picked,
    required MultiMark mark,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final mood = context.mood;

    final border = switch (mark) {
      MultiMark.correct || MultiMark.missed => mood.sage,
      MultiMark.incorrect => mood.berry,
      MultiMark.none => picked ? mood.accent : null,
    };
    // A picked row is filled; an answer the learner never touched is outlined
    // and tagged, so *right* and *should have been picked* never look alike.
    final fill = switch (mark) {
      MultiMark.correct => mood.sage.withValues(alpha: _pickedTint),
      MultiMark.incorrect => mood.berry.withValues(alpha: _pickedTint),
      MultiMark.missed => null,
      MultiMark.none =>
        picked ? mood.accent.withValues(alpha: _pickedTint) : null,
    };
    final icon = switch (mark) {
      MultiMark.correct || MultiMark.missed => Icons.check,
      MultiMark.incorrect => Icons.close,
      MultiMark.none => picked ? Icons.check : null,
    };

    return CardOptionTile(
      onTap: onTap,
      borderColor: border,
      fillColor: fill,
      semanticsLabel: [
        option.text,
        if (picked) 'selected',
        mark.semantics,
      ].nonNulls.join(', '),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.lg,
            child: icon == null
                ? null
                : Icon(icon, size: AppSpacing.md, color: border ?? mood.ink),
          ),
          Expanded(child: Text(option.text, style: theme.textTheme.bodyLarge)),
          if (mark == MultiMark.missed)
            Text(
              _missedTag,
              style: theme.textTheme.labelSmall?.copyWith(
                color: mood.inkMute,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
