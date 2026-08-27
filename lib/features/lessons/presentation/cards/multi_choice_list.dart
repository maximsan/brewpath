import 'package:brew_path/features/lessons/presentation/cards/multi_scoring.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Border weight on an option once the card has been checked and marked it.
const double _markedBorder = 2;
const double _plainBorder = 1;

/// The tag naming an answer the learner did not pick.
const String _missedTag = 'Missed';

/// One option in a [MultiChoiceList], already in display order.
@immutable
class MultiOption {
  /// Creates a [MultiOption].
  const MultiOption({required this.text, required this.isCorrect});

  /// What the learner reads.
  final String text;

  /// Whether this is one of the answers.
  final bool isCorrect;
}

/// The multi-select list a `multi` card picks from.
///
/// Separate from `ChoiceList` rather than a flag on it: that list latches on
/// the **first** tap and never reopens, which is the opposite of what a set
/// needs. Merging the two would put a mode switch through every branch of a
/// widget whose single-commit rule is the thing worth keeping.
class MultiChoiceList extends StatelessWidget {
  /// Creates a [MultiChoiceList].
  const MultiChoiceList({
    required this.options,
    required this.selected,
    required this.submitted,
    required this.onToggle,
    super.key,
  });

  /// The options, in the order they should appear.
  final List<MultiOption> options;

  /// Display indices currently picked.
  final Set<int> selected;

  /// Whether the card has been committed; afterwards nothing responds.
  final bool submitted;

  /// Called with the display index the learner tapped.
  final void Function(int index) onToggle;

  @override
  Widget build(BuildContext context) {
    final answerKey = [for (final option in options) option.isCorrect];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < options.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MultiOptionTile(
              option: options[index],
              picked: selected.contains(index),
              mark: submitted
                  ? markFor(
                      index: index,
                      selected: selected,
                      isCorrect: answerKey,
                    )
                  : MultiMark.none,
              onTap: submitted ? null : () => onToggle(index),
            ),
          ),
      ],
    );
  }
}

class _MultiOptionTile extends StatelessWidget {
  const _MultiOptionTile({
    required this.option,
    required this.picked,
    required this.mark,
    this.onTap,
  });

  final MultiOption option;
  final bool picked;
  final MultiMark mark;
  final VoidCallback? onTap;

  Color? _borderColor(MoodColors mood) => switch (mark) {
    MultiMark.correct => mood.sage,
    MultiMark.incorrect => mood.berry,
    MultiMark.missed => mood.sage,
    MultiMark.none => picked ? mood.accent : null,
  };

  /// The box beside the label — ticked while picked, and after the check for
  /// anything that was an answer, picked or not.
  IconData? get _boxIcon => switch (mark) {
    MultiMark.correct || MultiMark.missed => Icons.check,
    MultiMark.incorrect => Icons.close,
    MultiMark.none => picked ? Icons.check : null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final border = _borderColor(mood);
    final icon = _boxIcon;

    return Semantics(
      button: true,
      enabled: onTap != null,
      checked: picked,
      label: [
        option.text,
        if (picked) 'selected',
        mark.semantics,
      ].nonNulls.join(', '),
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.chrome),
          ),
          side: BorderSide(
            color: border ?? mood.rule,
            width: border != null ? _markedBorder : _plainBorder,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: AppSpacing.lg,
              child: icon == null
                  ? null
                  : Icon(icon, size: AppSpacing.md, color: border ?? mood.ink),
            ),
            Expanded(
              child: Text(option.text, style: theme.textTheme.bodyLarge),
            ),
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
      ),
    );
  }
}
