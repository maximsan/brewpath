import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How long the explanation takes to appear once an answer is chosen.
const _revealDuration = Duration(milliseconds: 200);

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

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final choices = widget.check.choices;
    // Reduced motion is a system setting, not a preference to re-ask.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.check.question,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: mood.ink),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var index = 0; index < choices.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: _ChoiceTile(
              text: choices[index].text,
              isChosen: _chosen == index,
              // Right and wrong are only ever shown after an answer.
              isCorrect: _chosen == null ? null : choices[index].isCorrect,
              onTap: _chosen == null
                  ? () => setState(() => _chosen = index)
                  : null,
            ),
          ),
        AnimatedSize(
          duration: reduceMotion ? Duration.zero : _revealDuration,
          alignment: Alignment.topCenter,
          child: _chosen == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    widget.check.explanation,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: mood.inkMute),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.text,
    required this.isChosen,
    required this.isCorrect,
    required this.onTap,
  });

  final String text;
  final bool isChosen;

  /// Null until the learner answers, then whether *this* choice was right.
  final bool? isCorrect;
  final VoidCallback? onTap;

  /// The outline colour: neutral before an answer, then green for the right
  /// choice and amber for a wrong one the learner picked.
  Color _borderColor(MoodColors mood) {
    if (isCorrect == null) return mood.rule;
    if (isCorrect!) return mood.sage;
    return isChosen ? mood.warn : mood.rule;
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final answered = isCorrect != null;

    return Semantics(
      button: onTap != null,
      selected: isChosen,
      label: answered ? '$text, ${isCorrect! ? 'correct' : 'incorrect'}' : text,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.chrome),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.chrome),
              border: Border.all(color: _borderColor(mood)),
            ),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: mood.ink),
            ),
          ),
        ),
      ),
    );
  }
}
