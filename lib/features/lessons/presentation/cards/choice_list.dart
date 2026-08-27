import 'package:brew_path/features/lessons/presentation/cards/card_option_tile.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Tint behind a marked option. The design tints a right answer more strongly
/// than a wrong one, so a bad run does not read as a wall of red.
const double _correctTint = 0.12;
const double _incorrectTint = 0.08;

/// One option in a [ChoiceList], already in display order.
@immutable
class ChoiceOption {
  /// Creates a [ChoiceOption].
  const ChoiceOption({
    required this.text,
    required this.isCorrect,
    this.subtitle,
  });

  /// What the learner reads.
  final String text;

  /// Secondary line, where the kind authors one.
  final String? subtitle;

  /// Whether this is the answer. Ignored entirely when the list does not
  /// reveal — an ungraded card knows its answer without marking it.
  final bool isCorrect;
}

/// The single-select list every picking card shares.
///
/// It latches on the first tap and never unlatches: afterwards nothing responds
/// and the marks stay put. The list does not decide what a selection *means* —
/// it reports the index and lets the card own the consequence, which is what
/// keeps one widget serving both graded and ungraded kinds.
class ChoiceList extends StatelessWidget {
  /// Creates a [ChoiceList].
  const ChoiceList({
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    required this.revealAnswer,
    super.key,
  });

  /// The options, in the order they should appear.
  final List<ChoiceOption> options;

  /// The committed choice, or null while the card is still open.
  final int? selectedIndex;

  /// Called with the display index of the learner's choice, once.
  final void Function(int index) onSelect;

  /// Whether a committed list marks right and wrong.
  ///
  /// False for a card that takes a guess without grading it — marking there
  /// would answer a question the card is deliberately holding open.
  final bool revealAnswer;

  bool get _latched => selectedIndex != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < options.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _option(
              context,
              option: options[index],
              mark: _markFor(index),
              onTap: _latched ? null : () => onSelect(index),
            ),
          ),
      ],
    );
  }

  _OptionMark _markFor(int index) {
    if (!_latched || !revealAnswer) {
      return index == selectedIndex ? _OptionMark.chosen : _OptionMark.none;
    }
    if (options[index].isCorrect) return _OptionMark.correct;
    if (index == selectedIndex) return _OptionMark.wrong;
    return _OptionMark.none;
  }

  /// One option, in the shared frame.
  ///
  /// A mark is carried by border colour **and** a tint, as
  /// `.mcq-choice.correct` / `.incorrect` have it — sage at 12%, berry at 8%,
  /// the weaker one so a bad run does not read as a wall of red. The border
  /// stays hairline in every state; the design never thickens it.
  Widget _option(
    BuildContext context, {
    required ChoiceOption option,
    required _OptionMark mark,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final subtitle = option.subtitle;

    return CardOptionTile(
      onTap: onTap,
      borderColor: switch (mark) {
        _OptionMark.correct => mood.sage,
        _OptionMark.wrong => mood.berry,
        _OptionMark.chosen => mood.accent,
        _OptionMark.none => null,
      },
      fillColor: switch (mark) {
        _OptionMark.correct => mood.sage.withValues(alpha: _correctTint),
        _OptionMark.wrong => mood.berry.withValues(alpha: _incorrectTint),
        _OptionMark.chosen || _OptionMark.none => null,
      },
      semanticsLabel: [
        option.text,
        subtitle,
        mark.semantics,
      ].nonNulls.join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(option.text, style: theme.textTheme.bodyLarge),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: mood.inkMute),
            ),
          ],
        ],
      ),
    );
  }
}

/// How a committed option is drawn — and, for a screen reader, said.
enum _OptionMark {
  none(null),
  chosen('chosen'),
  correct('correct answer'),
  wrong('your answer, incorrect');

  const _OptionMark(this.semantics);

  /// Spoken suffix, because the mark is otherwise carried by colour alone.
  final String? semantics;
}
