import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How long the explanation takes to appear once an answer is chosen.
const _revealDuration = Duration(milliseconds: 200);

/// The verdict on a self-check, in the design's own words.
const String _correct = 'Correct';

/// A term's self-check: one question, a few choices, and an explanation that
/// appears once the learner answers.
///
/// The explanation shows whether the answer was right or wrong — a wrong guess
/// should still teach.
class TermSelfCheck extends StatefulWidget {
  /// Creates a [TermSelfCheck].
  const TermSelfCheck({required this.check, super.key});

  /// The check to ask.
  final DictionaryCheck check;

  @override
  State<TermSelfCheck> createState() => _TermSelfCheckState();
}

class _TermSelfCheckState extends State<TermSelfCheck> {
  int? _chosen;

  /// Whether the choice taken was the right one. False until one is taken,
  /// which the verdict block never sees — it draws nothing until `_chosen`.
  bool get _wasCorrect {
    final chosen = _chosen;
    return chosen != null && widget.check.choices[chosen].isCorrect;
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final choices = widget.check.choices;
    // Reduced motion is a system setting, not a preference to re-ask.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The question in the display face: it is the card's heading.
        Text(widget.check.question, style: AppText.heading(mood: mood)),
        const SizedBox(height: AppSpacing.base),
        for (var index = 0; index < choices.length; index++) ...[
          if (index > 0) Divider(height: 1, thickness: 1, color: mood.rule),
          _ChoiceRow(
            text: choices[index].text,
            isChosen: _chosen == index,
            // Right and wrong are only ever shown after an answer.
            isCorrect: _chosen == null ? null : choices[index].isCorrect,
            onTap: _chosen == null
                ? () => setState(() => _chosen = index)
                : null,
          ),
        ],
        // The explanation, once an answer is in.
        //
        // ⚠️ **Reduced motion drops the animator, rather than giving it a zero
        // duration.** `AnimatedSize` re-dirties itself inside its own
        // `performLayout` when asked to finish instantly, and the framework
        // asserts on it — so "no animation" has to mean no animator.
        if (reduceMotion)
          _Explanation(
            chosen: _chosen,
            wasCorrect: _wasCorrect,
            text: widget.check.explanation,
          )
        else
          AnimatedSize(
            duration: _revealDuration,
            alignment: Alignment.topCenter,
            child: _Explanation(
              chosen: _chosen,
              wasCorrect: _wasCorrect,
              text: widget.check.explanation,
            ),
          ),
      ],
    );
  }
}

/// One answer as a row: a radio mark, then the text, ruled off from the next.
///
/// Neutral before an answer; then the right choice turns sage and a wrong
/// one the learner picked turns amber, on the mark rather than a box.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.text,
    required this.isChosen,
    required this.isCorrect,
    required this.onTap,
  });

  /// The design's `20` radio mark, and its `1px` ring.
  static const double _mark = 20;

  final String text;
  final bool isChosen;

  /// Null until the learner answers, then whether *this* choice was right.
  final bool? isCorrect;
  final VoidCallback? onTap;

  Color _markColor(MoodColors mood) {
    if (isCorrect == null) return mood.rule;
    if (isCorrect!) return mood.sage;
    return isChosen ? mood.warn : mood.rule;
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final answered = isCorrect != null;
    final color = _markColor(mood);
    // Filled once it carries a verdict the learner took part in.
    final filled = answered && (isChosen || isCorrect!);

    return Semantics(
      button: onTap != null,
      selected: isChosen,
      label: answered ? '$text, ${isCorrect! ? 'correct' : 'incorrect'}' : text,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: _mark,
                  height: _mark,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? color : null,
                    border: Border.all(color: color),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    text,
                    style: AppText.body(mood: mood, face: AppFace.control),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The verdict under the choices, absent until the learner answers.
///
/// It used to reveal the explanation silently, with no verdict line and
/// nothing announced — so a reader heard each tile's mark and never how the
/// check went. It closes on the shared block now, like every graded surface.
class _Explanation extends StatelessWidget {
  const _Explanation({
    required this.chosen,
    required this.wasCorrect,
    required this.text,
  });

  final int? chosen;

  /// Whether the choice they took was the right one.
  final bool wasCorrect;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (chosen == null) return const SizedBox.shrink();
    return AnswerFeedback(
      verdict: wasCorrect ? _correct : context.strings.verdictNotQuite,
      outcome: wasCorrect ? Verdict.right : Verdict.wrong,
      explanation: text,
      placement: VerdictPlacement.reference,
    );
  }
}
