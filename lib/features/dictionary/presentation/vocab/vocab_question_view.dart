import 'dart:async';

import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/core/widgets/drill_results_view.dart';
import 'package:brew_path/core/widgets/link_button.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/dictionary/domain/vocab_round.dart';
import 'package:brew_path/features/dictionary/presentation/vocab/vocab_copy.dart';
import 'package:brew_path/features/lessons/presentation/cards/choice_list.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// A round plus the framing the screen knows and the generator does not.
typedef VocabQuestion = ({VocabRound round, String? categoryLabel});

/// One question: a definition, four term names, and what happens after.
///
/// The choices are the app's one MCQ list, the same widget every graded lesson
/// card picks with — so right and wrong are marked, spoken and coloured here
/// exactly as they are everywhere else, and a learner does not have to learn a
/// second visual language for the same act.
class VocabQuestionView extends StatelessWidget {
  /// Creates a [VocabQuestionView].
  const VocabQuestionView({
    required this.question,
    required this.picked,
    required this.onPick,
    required this.next,
    super.key,
  });

  /// The round being asked, and the category it sits in.
  final VocabQuestion question;

  /// The learner's committed choice, or null while the question is open.
  final int? picked;

  /// Called once, with the display index of the choice.
  final ValueChanged<int> onPick;

  /// The way on — labelled for the last question or for the ones before it.
  final DrillAction next;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final round = question.round;
    final answered = picked != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (question.categoryLabel case final label?)
              SmallcapsLabel(label, color: mood.inkMute),
            const SizedBox(height: AppSpacing.sm),
            SmallcapsLabel(VocabCopy.questionLead, color: mood.accentText),
            const SizedBox(height: AppSpacing.xs),
            // The definition is the question, set at title size: it is the
            // thing being read, not a label over the thing.
            Text(
              round.answer.shortExplanation,
              style: AppText.title(mood: mood),
            ),
            const SizedBox(height: AppSpacing.lg),
            ChoiceList(
              options: [
                for (final choice in round.choices)
                  ChoiceOption(
                    text: choice.term,
                    isCorrect: choice.id == round.answer.id,
                  ),
              ],
              selectedIndex: picked,
              onSelect: onPick,
              revealAnswer: true,
            ),
            if (answered) ...[
              _Verdict(round: round, picked: picked!),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: next.label,
              // Disabled until the question is answered: the drill scores what
              // was picked, and skipping past would score a round nobody
              // played.
              onPressed: answered ? next.onPressed : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// What the answer was, and the way into the full entry.
///
/// The app's one verdict block, at the size and accent tone the design gives
/// a reference surface — a drill over the dictionary answers back the way a
/// term's self-check does, not the way a lesson marks a run.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.round, required this.picked});

  final VocabRound round;
  final int picked;

  @override
  Widget build(BuildContext context) {
    final isCorrect = round.isCorrect(picked);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: AnswerFeedback(
        verdict: VocabCopy.verdict(round.answer.term, isCorrect: isCorrect),
        outcome: isCorrect ? Verdict.right : Verdict.wrong,
        placement: VerdictPlacement.reference,
        extra: LinkButton(
          label: VocabCopy.readEntry,
          onPressed: () =>
              unawaited(context.pushDictionaryTerm(round.answer.id)),
        ),
      ),
    );
  }
}
