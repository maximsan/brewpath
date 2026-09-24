import 'package:brew_path/core/widgets/verdict_placement.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/dictionary/presentation/term_linked_text.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

export 'package:brew_path/core/widgets/verdict_placement.dart';

/// How the surface stands, and everything that follows from it. One enum
/// rather than a bool, a colour and a mascot state passed separately: those
/// move together, and passing them loose is what let five copies drift — one
/// reached for `mood.warn` where the rest used `mood.berry`. Three standings,
/// because the design's block reads `graded = true | false | null`, and the
/// null branch is a guess it holds rather than marks.
enum Verdict {
  /// The learner got it. Sage, and Roasty pleased.
  right(RoastyState.correct),

  /// They did not. The surface's own wrong tone, and Roasty sorry about it.
  wrong(RoastyState.wrong),

  /// Nothing has been graded. Roasty holds the answer on a card rather than
  /// marking it, and the line stays ink-mute — the design colours the label
  /// with meaning, so an ungraded line may take neither the right colour nor
  /// the wrong one.
  held(RoastyState.card);

  const Verdict(this.mascotState);

  /// How Roasty takes the news.
  final RoastyState mascotState;

  /// The colour the line is named in, here.
  Color tone(MoodColors mood, VerdictPlacement placement) => switch (this) {
    Verdict.right => mood.sage,
    Verdict.wrong => placement.wrongTone(mood),
    Verdict.held => mood.inkMute,
  };
}

/// The block that closes every graded surface — and holds the one guess that is
/// never graded: a mascot, a mono verdict line, the explanation under it. One
/// component, because nine hand-rolled copies drifted apart in the design. The
/// verdict is a **live region**: it arrives on commit with no focus change, so
/// without it a screen reader hears every mark and never the outcome.
class AnswerFeedback extends StatelessWidget {
  /// Creates an [AnswerFeedback].
  const AnswerFeedback({
    required this.verdict,
    required this.outcome,
    this.explanation,
    this.extra,
    this.placement = VerdictPlacement.card,
    super.key,
  });

  /// The line itself — *All correct*, *Clean board*, *Not quite*. Written in
  /// sentence case and rendered uppercase, because the case is the design's
  /// treatment of the line rather than part of what it says; assistive
  /// technology is given the string as written, so a caller that pre-shouts its
  /// verdict does not make the screen reader shout it too.
  final String verdict;

  /// How it stands — graded either way, or held.
  final Verdict outcome;

  /// What the surface explains under the line, if it explains anything.
  final String? explanation;

  /// Anything the surface adds below the explanation — the sequence card's
  /// correct-order reveal is the one that needed it.
  final Widget? extra;

  /// Where this one is standing.
  final VerdictPlacement placement;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final mascot = placement.mascot;

    final block = Row(
      children: [
        if (mascot != null) ...[
          Roasty(state: outcome.mascotState, size: mascot),
          const SizedBox(width: AppSpacing.base),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: placement.announces,
                label: verdict,
                excludeSemantics: true,
                child: Text(
                  verdict.toUpperCase(),
                  style: AppText.label(
                    face: AppFace.mono,
                    color: outcome.tone(mood, placement),
                  ),
                ),
              ),
              if (explanation case final explanation?) ...[
                const SizedBox(height: AppSpacing.xs),
                if (placement.linksTerms)
                  TermLinkedText(
                    text: explanation,
                    style: placement.explanationStyle(mood),
                  )
                else
                  Text(explanation, style: placement.explanationStyle(mood)),
              ],
              ?extra,
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: placement.room),
      child: placement.rulesOff ? _ruledOff(block, mood) : block,
    );
  }

  /// The rule the payoff opens on, with the design's room under it.
  Widget _ruledOff(Widget block, MoodColors mood) => Container(
    width: double.infinity,
    padding: EdgeInsets.only(top: OffTokens.verdictRuleGap.value),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: mood.rule)),
    ),
    child: block,
  );
}
