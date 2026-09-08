import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:brew_path/core/widgets/fill_slot.dart';
import 'package:brew_path/features/lessons/domain/held_guess.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The label the payoff always leads with, whichever way the guess went.
const String openingGuessLabel = 'Your opening guess';

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
    final style = VerdictPlacement.openingGuess.explanationStyle(mood);

    return AnswerFeedback(
      verdict: openingGuessLabel,
      outcome: guess.wasRight ? Verdict.right : Verdict.held,
      placement: VerdictPlacement.openingGuess,
      // The reading is a sentence with chips set into it, so it arrives as
      // `extra` rather than as the plain-string explanation above it.
      extra: Semantics(
        label: spokenPayoff(guess),
        excludeSemantics: true,
        child: Text.rich(
          TextSpan(children: _sentence(), style: style),
        ),
      ),
    );
  }

  List<InlineSpan> _sentence() => [
    const TextSpan(text: '${PayoffCopy.opener} '),
    fillSlotSpan(
      FillSlot(
        word: guess.pick,
        state: guess.wasRight ? FillSlotState.right : FillSlotState.wrong,
      ),
    ),
    if (guess.wasRight)
      const TextSpan(text: ' ${PayoffCopy.andRight}')
    else ...[
      // No leading space: the full stop belongs to the chip before it.
      const TextSpan(text: '${PayoffCopy.butActually} '),
      fillSlotSpan(
        FillSlot(word: guess.answer, state: FillSlotState.right),
      ),
      const TextSpan(text: ' ${PayoffCopy.nowYouKnow}'),
    ],
  ];
}

/// The payoff's words, in one place because they are said twice — once as
/// spans with chips set into them, and once flat for a reader that cannot see
/// a chip. Split here so a wording edit cannot land on only one of the two.
abstract final class PayoffCopy {
  /// What the sentence opens with, before the guess.
  static const String opener = 'Before the lesson you guessed';

  /// How it closes when the guess landed.
  static const String andRight = '— and you were right.';

  /// How it turns when the guess missed, before the authored answer.
  static const String butActually = ". It's";

  /// How it closes when the guess missed.
  static const String nowYouKnow = '— now you know why.';
}

/// The payoff as one sentence, for a reader that cannot see the chips: a
/// `WidgetSpan` announces nothing, so a screen reader would otherwise hear it
/// with its two most important words missing.
String spokenPayoff(HeldGuess guess) => guess.wasRight
    ? '${PayoffCopy.opener} ${guess.pick} ${PayoffCopy.andRight}'
    : '${PayoffCopy.opener} ${guess.pick}${PayoffCopy.butActually} '
          '${guess.answer} ${PayoffCopy.nowYouKnow}';
