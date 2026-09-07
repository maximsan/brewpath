import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a graded surface says when the answer was not right.
///
/// Shared because it was not: four surfaces each declared their own private
/// `_notQuite` and two more wrote the literal, for the one line the design
/// repeats more than any other. Six copies of a string is how the wording
/// drifts, which is the same failure one verdict block exists to prevent.
const String notQuiteVerdict = 'Not quite';

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

/// Where the block is standing — the whole of what varies between its hosts.
///
/// A mascot size, a body step and a wrong-answer tone, travelling as one
/// value: the design moves them together, and passing them loose is what let
/// five copies drift into combinations it never draws.
enum VerdictPlacement {
  /// A graded card in the lesson player.
  card(mascot: _mascotOnCard, speaksInBody: false),

  /// The cards the design sets a step larger — `decision` and `recall`, which
  /// pass `bodySize="body"`.
  ///
  /// They talk back rather than mark an answer, and the design gives that
  /// reading the body step the rest of the run reserves for prose.
  conversational(mascot: _mascotOnCard, speaksInBody: true),

  /// A term entry's self-check, drawn smaller and toned **accent** rather than
  /// berry.
  ///
  /// A term entry is reference rather than a graded run: berry is the colour
  /// the lesson player spends on a wrong answer, and a look-up that answers
  /// back in it reads as a worse failure than missing a self-check is.
  reference(mascot: _mascotInReference, speaksInBody: false),

  /// The predict card's held guess — the design's `size={64} bodySize="body"`.
  ///
  /// Smaller than a graded card's mascot and set at the body step: the block
  /// is repeating the learner's own guess back to them, which reads as prose
  /// rather than as a mark.
  heldGuess(mascot: _mascotOnHold, speaksInBody: true),

  /// The recall card's payoff — the design's `art={false} borderTop`.
  ///
  /// The one standing with no mascot. It is a reply to a guess made minutes
  /// ago rather than a verdict on the answer just given, and Roasty has
  /// already spoken above it; a second face would read as a second marking.
  /// The rule off the top is what separates the two.
  openingGuess(mascot: null, speaksInBody: true, rulesOff: true);

  const VerdictPlacement({
    required this.mascot,
    required this.speaksInBody,
    this.rulesOff = false,
  });

  /// The design's mascot size on a graded card, holding a guess, and inside a
  /// term entry.
  static const double _mascotOnCard = 72;
  static const double _mascotOnHold = 64;
  static const double _mascotInReference = 48;

  /// How large Roasty is drawn here, or null where the block draws no mascot.
  final double? mascot;

  /// Whether a rule sits above the block, separating it from what it follows.
  final bool rulesOff;

  /// Whether the explanation takes the body step rather than support.
  final bool speaksInBody;

  /// The colour a wrong answer is named in.
  Color wrongTone(MoodColors mood) =>
      this == VerdictPlacement.reference ? mood.accent : mood.berry;

  /// How the explanation is set here.
  ///
  /// **Muted at either step.** The design's block colours this text
  /// `var(--ink-mute)` whatever `bodySize` it is given — the step says how
  /// much room the explanation takes, never how loudly it speaks — and
  /// `AppText.body` defaults to full ink, so the colour has to be named.
  TextStyle explanationStyle(MoodColors mood) => speaksInBody
      ? AppText.body(color: mood.inkMute)
      : AppText.support(mood: mood);
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
                liveRegion: true,
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
              if (explanation != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  explanation!,
                  style: placement.explanationStyle(mood),
                ),
              ],
              ?extra,
            ],
          ),
        ),
      ],
    );

    if (!placement.rulesOff) return block;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: mood.rule)),
      ),
      child: block,
    );
  }
}
