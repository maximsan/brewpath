import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/core/widgets/fill_slot.dart';
import 'package:brew_path/features/lessons/domain/held_guess.dart';
import 'package:brew_path/l10n/app_strings.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Closes the loop the opening card opened: a reply to the guess made minutes
/// ago, not a second verdict on the answer just given. The guess and the answer
/// render as [FillSlot]s — the same chips the guess was made with. A guess that
/// missed takes the ungraded standing rather than the wrong one, because being
/// wrong here is what the lesson was for.
class RecallPayoff extends StatelessWidget {
  /// Creates a [RecallPayoff].
  const RecallPayoff({required this.guess, super.key});

  /// The guess the opening card held.
  final HeldGuess guess;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final strings = context.strings;
    final style = VerdictPlacement.openingGuess.explanationStyle(mood);

    return AnswerFeedback(
      verdict: strings.payoffOpeningGuess,
      outcome: guess.wasRight ? Verdict.right : Verdict.held,
      placement: VerdictPlacement.openingGuess,
      // The reading is a sentence with chips set into it, so it arrives as
      // `extra` rather than as the plain-string explanation above it.
      extra: Semantics(
        label: spokenPayoff(strings, guess),
        excludeSemantics: true,
        child: Text.rich(
          TextSpan(children: _sentence(strings), style: style),
        ),
      ),
    );
  }

  List<InlineSpan> _sentence(AppLocalizations strings) => [
    TextSpan(text: '${strings.payoffOpener} '),
    fillSlotSpan(
      FillSlot(
        word: guess.pick,
        state: guess.wasRight ? FillSlotState.right : FillSlotState.wrong,
      ),
    ),
    if (guess.wasRight)
      TextSpan(text: ' ${strings.payoffAndRight}')
    else ...[
      // No leading space: the full stop belongs to the chip before it.
      TextSpan(text: '${strings.payoffButActually} '),
      fillSlotSpan(
        FillSlot(word: guess.answer, state: FillSlotState.right),
      ),
      TextSpan(text: ' ${strings.payoffNowYouKnow}'),
    ],
  ];
}

/// The payoff as one sentence, for a reader that cannot see the chips: a
/// `WidgetSpan` announces nothing, so a screen reader would otherwise hear it
/// with its two most important words missing.
String spokenPayoff(AppLocalizations strings, HeldGuess guess) => guess.wasRight
    ? strings.payoffSpokenRight(
        strings.payoffOpener,
        guess.pick,
        strings.payoffAndRight,
      )
    : strings.payoffSpokenWrong(
        strings.payoffOpener,
        guess.pick,
        strings.payoffButActually,
        guess.answer,
        strings.payoffNowYouKnow,
      );
