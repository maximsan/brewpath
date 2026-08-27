import 'package:brew_path/core/widgets/dashed_rounded_border.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/multi_scoring.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The tag naming an answer the learner did not pick.
const String _missedTag = 'MISSED';

/// Tracking on that tag, which the design sets in mono small caps.
const double _tagTracking = 1.4;

/// Fill behind a marked row. The design tints a right answer more strongly
/// than a wrong one, so the page does not read as mostly-red on a bad run.
const double _correctTint = 0.12;
const double _incorrectTint = 0.08;

/// The checkbox beside each choice.
const double _boxSize = 22;
const double _boxBorder = 1.5;
const double _boxMark = 15;

/// The design keeps the outline hairline in every state. Only a pre-submit
/// pick reads heavier, and it does so with an inset second line rather than a
/// thicker one — `.ms-choice.on`'s `box-shadow: inset 0 0 0 1px`.
const double _borderWidth = 1;
const double _pickedInset = 2;

/// How one option is drawn, as the design's four states.
///
/// Kept as one value because the row and its box are always drawn from the
/// same state, and splitting them let the two disagree.
@immutable
class _OptionSkin {
  const _OptionSkin({
    required this.border,
    required this.boxBorder,
    required this.fill,
    required this.boxFill,
    required this.markColor,
    this.icon,
    this.dashed = false,
  });

  /// The row's outline.
  final Color border;

  /// The checkbox's outline, which the design mutes while nothing is picked
  /// even though the row around it uses the plain rule.
  final Color boxBorder;

  final Color? fill;
  final Color boxFill;
  final Color markColor;
  final IconData? icon;
  final bool dashed;
}

/// The multi-select list a `multi` card picks from.
///
/// Separate from [ChoiceList] rather than a flag on it: that list latches on
/// the **first** tap and never reopens, which is the opposite of what a set
/// needs. Merging the two would put a mode switch through every branch of a
/// widget whose single-commit rule is the thing worth keeping.
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
            child: _MultiOptionRow(
              text: options[index].text,
              picked: selected.contains(index),
              mark: marks[index],
              onTap: _submitted ? null : () => onToggle(index),
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
  _OptionSkin _skin(MoodColors mood) => switch (mark) {
    MultiMark.correct => _OptionSkin(
      border: mood.sage,
      boxBorder: mood.sage,
      fill: mood.sage.withValues(alpha: _correctTint),
      boxFill: mood.sage,
      markColor: mood.surface,
      icon: Icons.check,
    ),
    MultiMark.incorrect => _OptionSkin(
      border: mood.berry,
      boxBorder: mood.berry,
      fill: mood.berry.withValues(alpha: _incorrectTint),
      boxFill: mood.berry,
      markColor: mood.surface,
      icon: Icons.close,
    ),
    MultiMark.missed => _OptionSkin(
      border: mood.sage,
      boxBorder: mood.sage,
      fill: null,
      boxFill: Colors.transparent,
      markColor: mood.sage,
      icon: Icons.check,
      dashed: true,
    ),
    MultiMark.none =>
      picked
          ? _OptionSkin(
              border: mood.accent,
              boxBorder: mood.accent,
              fill: null,
              boxFill: mood.accent,
              markColor: mood.accentInk,
              icon: Icons.check,
            )
          : _OptionSkin(
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
    final side = BorderSide(
      color: skin.border,
      width: open && picked ? _pickedInset : _borderWidth,
    );

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: [text, if (picked) 'selected', mark.semantics].nonNulls.join(', '),
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: skin.fill,
          padding: const EdgeInsets.all(AppSpacing.md),
          side: skin.dashed ? BorderSide.none : side,
          shape: skin.dashed
              ? DashedRoundedBorder(radius: AppRadii.chrome, side: side)
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.chrome),
                ),
        ),
        child: Row(
          children: [
            _Box(skin: skin, mood: mood),
            const SizedBox(width: AppSpacing.base),
            Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
            if (mark == MultiMark.missed)
              Text(
                _missedTag,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: mood.inkMute,
                  letterSpacing: _tagTracking,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The checkbox the design puts before every choice — dashed when the answer
/// was missed, exactly as its row is.
class _Box extends StatelessWidget {
  const _Box({required this.skin, required this.mood});

  final _OptionSkin skin;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: skin.boxBorder, width: _boxBorder);

    return Container(
      width: _boxSize,
      height: _boxSize,
      decoration: ShapeDecoration(
        color: skin.boxFill,
        shape: skin.dashed
            ? DashedRoundedBorder(radius: AppRadii.editorial, side: side)
            : RoundedRectangleBorder(
                side: side,
                borderRadius: BorderRadius.circular(AppRadii.editorial),
              ),
      ),
      child: skin.icon == null
          ? null
          : Icon(skin.icon, size: _boxMark, color: skin.markColor),
    );
  }
}
