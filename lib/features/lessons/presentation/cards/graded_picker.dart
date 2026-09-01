import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_boundary.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_shell.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The verdict five of the six picking kinds close on (`lesson.jsx:410`,
/// `:1496`, `:1546`, `active-cards.jsx:227`).
///
/// `decision` and `tastefix` answer in their own words instead — see
/// [PickerCopy.verdict].
String defaultPickerVerdict({required bool wasCorrect}) =>
    wasCorrect ? 'CORRECT' : 'NOT QUITE';

/// The copy slots the three graded picking kinds fill differently.
///
/// Grouped into one value rather than passed loose because they travel
/// together and always have: every graded picker has something to ask, an
/// explanation to give afterwards, and optional framing around both.
@immutable
class PickerCopy {
  /// Creates a [PickerCopy].
  const PickerCopy({
    required this.prompt,
    required this.explain,
    this.label,
    this.title,
    this.scenario,
    this.footnote,
    this.verdict = defaultPickerVerdict,
  });

  /// The question itself.
  final String prompt;

  /// The explanation shown once committed. Takes whether the learner was
  /// right, because `decision` authors a separate reading for each outcome.
  final String Function({required bool wasCorrect}) explain;

  /// Small-caps eyebrow.
  final String? label;

  /// Heading above the question.
  final String? title;

  /// Situation set out before the question.
  final String? scenario;

  /// A closing line under the explanation — a takeaway, or a note.
  final String? footnote;

  /// The line the verdict block leads with. Takes the outcome for the same
  /// reason [explain] does: `decision` calls it *good call* against *that
  /// would backfire*, and `tastefix` *good fix* — neither is a right-or-wrong
  /// pair the default could reach.
  final String Function({required bool wasCorrect}) verdict;
}

/// A graded card: pick one option, and the card latches on that choice.
///
/// Success is reported once, at the moment of a correct commit. A wrong answer
/// reports nothing at all — it marks the options and explains itself here,
/// which is the whole of its consequence. See `card_boundary.dart`.
class GradedPicker extends StatefulWidget {
  /// Creates a [GradedPicker].
  const GradedPicker({
    required this.options,
    required this.copy,
    required this.onSolved,
    required this.onContinue,
    super.key,
  });

  /// The options, already in display order.
  final List<ChoiceOption> options;

  /// What this kind says around the choices.
  final PickerCopy copy;

  /// Fired once, only if the committed choice was correct.
  final CardSolved onSolved;

  /// Fired when the learner moves on.
  final CardAdvance onContinue;

  @override
  State<GradedPicker> createState() => _GradedPickerState();
}

class _GradedPickerState extends State<GradedPicker> {
  int? _selectedIndex;

  bool get _latched => _selectedIndex != null;
  bool get _wasCorrect => _latched && widget.options[_selectedIndex!].isCorrect;

  void _commit(int index) {
    // Latching before the callback matters: the host may rebuild synchronously
    // on the success signal, and a card that had not yet latched would accept a
    // second tap.
    setState(() => _selectedIndex = index);
    if (widget.options[index].isCorrect) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final copy = widget.copy;

    return CardShell(
      latched: _latched,
      onContinue: widget.onContinue,
      label: copy.label,
      title: copy.title,
      children: [
        if (copy.scenario != null) ...[
          Text(copy.scenario!, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          copy.prompt,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ChoiceList(
          options: widget.options,
          selectedIndex: _selectedIndex,
          onSelect: _commit,
          revealAnswer: true,
        ),
        if (_latched) ...[
          const SizedBox(height: AppSpacing.md),
          AnswerFeedback(
            verdict: copy.verdict(wasCorrect: _wasCorrect),
            outcome: _wasCorrect ? Verdict.right : Verdict.wrong,
            explanation: copy.explain(wasCorrect: _wasCorrect),
          ),
          if (copy.footnote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              copy.footnote!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mood.inkMute,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
