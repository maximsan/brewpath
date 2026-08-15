import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Border weight on an option once the card has latched and marked it.
const double _markedBorder = 2;
const double _plainBorder = 1;

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
            child: _Option(
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

class _Option extends StatelessWidget {
  const _Option({required this.option, required this.mark, this.onTap});

  final ChoiceOption option;
  final _OptionMark mark;
  final VoidCallback? onTap;

  Color? _borderColor(MoodColors mood) => switch (mark) {
    _OptionMark.correct => mood.sage,
    _OptionMark.wrong => mood.berry,
    _OptionMark.chosen => mood.accent,
    _OptionMark.none => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final border = _borderColor(mood);
    final subtitle = option.subtitle;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: [option.text, subtitle, mark.semantics].nonNulls.join(', '),
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
      ),
    );
  }
}
