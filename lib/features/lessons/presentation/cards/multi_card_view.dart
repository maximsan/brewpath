import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/multi_choice_list.dart';
import 'package:brew_path/features/lessons/presentation/cards/multi_scoring.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The cue above a multi card's prompt.
const String _cue = 'Select all that apply';

/// The commit affordance, before anything has been checked.
const String _checkLabel = 'Check answers';

/// Verdicts, which name the all-or-nothing rule rather than a score.
const String _allCorrect = 'All correct';

/// The select-all-that-apply card: pick freely, then commit the whole set.
///
/// Two things separate it from every other graded card. Choices **toggle**
/// until a separate commit, because a set is not answered until it is
/// finished; and it is scored **all-or-nothing**, which is the boundary's rule
/// rather than this card's invention — a fraction would have to mean something
/// to mastery, and mastery counts whole cards. See `card_boundary.dart`.
///
/// The single button swaps between *Check answers* and *Continue*, as the
/// design has it — the shell owns that swap, so this card still does not draw
/// its own way forward.
///
/// It takes its fields rather than the `MultiCard`, unlike the display-only
/// kinds next to it in the switch. That is the seeding rule, not an
/// oversight: every card whose options are shuffled is handed them already
/// shuffled, so one place owns the seed and a replay moves every card the
/// same way. `GradedPicker` is handed its options for the same reason.
class MultiCardView extends StatefulWidget {
  /// Creates a [MultiCardView].
  const MultiCardView({
    required this.prompt,
    required this.explanation,
    required this.options,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The question.
  final String prompt;

  /// Shown once committed, whatever the outcome.
  final String explanation;

  /// The choices, already in display order.
  final List<ChoiceOption> options;

  /// Fired once, only when the committed set is exactly right.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<MultiCardView> createState() => _MultiCardViewState();
}

class _MultiCardViewState extends State<MultiCardView> {
  final Set<int> _selected = {};
  bool _submitted = false;

  /// Derived here and nowhere else: this card both scores against the key and
  /// hands the list its marks, so a second derivation could only disagree.
  List<bool> get _answerKey => [
    for (final option in widget.options) option.isCorrect,
  ];

  bool get _wasCorrect =>
      isMultiCorrect(selected: _selected, isCorrect: _answerKey);

  /// One mark per option — all [MultiMark.none] until the card is committed.
  List<MultiMark> get _marks => [
    for (var index = 0; index < widget.options.length; index++)
      if (!_submitted)
        MultiMark.none
      else
        markFor(index: index, selected: _selected, isCorrect: _answerKey),
  ];

  void _toggle(int index) {
    if (_submitted) return;
    setState(() {
      if (!_selected.remove(index)) _selected.add(index);
    });
  }

  void _check() {
    if (_submitted || _selected.isEmpty) return;
    // Latched before the callback, for the reason `graded_picker` records.
    final correct = _wasCorrect;
    setState(() => _submitted = true);
    if (correct) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final verdict = _wasCorrect ? _allCorrect : notQuiteVerdict;

    return CardShell(
      latched: _submitted,
      onContinue: widget.onContinue,
      label: _cue,
      commit: CardCommit(
        label: _checkLabel,
        onCommit: _selected.isEmpty ? null : _check,
      ),
      children: [
        Text(widget.prompt, style: AppText.title(mood: mood)),
        const SizedBox(height: AppSpacing.md),
        MultiChoiceList(
          options: widget.options,
          selected: _selected,
          marks: _marks,
          submitted: _submitted,
          onToggle: _toggle,
        ),
        if (_submitted) ...[
          const SizedBox(height: AppSpacing.md),
          AnswerFeedback(
            verdict: verdict,
            outcome: _wasCorrect ? Verdict.right : Verdict.wrong,
            explanation: widget.explanation,
          ),
        ],
      ],
    );
  }
}
