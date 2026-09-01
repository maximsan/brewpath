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

/// Which way a graded surface went, and everything that follows from it.
///
/// One enum rather than a `bool` and a colour and a mascot state passed
/// separately: those three always move together, and it was passing them
/// separately that let five copies drift — one reached for `mood.warn` where
/// the rest used `mood.berry`, and nothing could tell that was a mistake.
enum Verdict {
  /// The learner got it. Sage, and Roasty pleased.
  right(RoastyState.correct),

  /// They did not. The surface's own wrong tone, and Roasty sorry about it.
  wrong(RoastyState.wrong);

  const Verdict(this.mascotState);

  /// How Roasty takes the news.
  final RoastyState mascotState;
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
  /// pass `bodySize="body"` (`active-cards.jsx:172`, `:227`).
  ///
  /// They talk back rather than mark an answer, and the design gives that
  /// reading the body step the rest of the run reserves for prose.
  conversational(mascot: _mascotOnCard, speaksInBody: true),

  /// A term entry's self-check (`dictionary.jsx:491`), drawn smaller and toned
  /// **accent** rather than berry.
  ///
  /// A term entry is reference rather than a graded run: berry is the colour
  /// the lesson player spends on a wrong answer, and a look-up that answers
  /// back in it reads as a worse failure than missing a self-check is.
  reference(mascot: _mascotInReference, speaksInBody: false);

  const VerdictPlacement({required this.mascot, required this.speaksInBody});

  /// The design's mascot size on a graded card, and inside a term entry.
  static const double _mascotOnCard = 72;
  static const double _mascotInReference = 48;

  /// How large Roasty is drawn here.
  final double mascot;

  /// Whether the explanation takes the body step rather than support.
  final bool speaksInBody;

  /// The colour a wrong answer is named in.
  Color wrongTone(MoodColors mood) =>
      this == VerdictPlacement.reference ? mood.accent : mood.berry;

  /// How the explanation is set here.
  TextStyle explanationStyle(MoodColors mood) =>
      speaksInBody ? AppText.body(mood: mood) : AppText.support(mood: mood);
}

/// The verdict block that closes every graded surface in the product.
///
/// The design's `AnswerFeedback` (`prototype/roasty.jsx:744`): the mascot, then
/// a mono verdict line and the explanation under it. **One component, and the
/// design source says why** — nine hand-rolled copies of it once drifted apart
/// in the prototype, and the five this replaced in `lib/` had already started
/// to, on type step (`labelSmall` against `titleSmall`) and on wrong-state
/// colour (`berry` against `warn`).
///
/// **The verdict is a live region.** It arrives on commit with no focus change
/// to bring a reader to it, so the per-option marks say what each choice was
/// and only this says how the card went. Without it a learner using a screen
/// reader hears every mark and never the outcome — which bites hardest where
/// right and wrong are separated by colour and a word.
///
/// Reduced motion needs nothing here: [Roasty] holds a single frame when
/// `MediaQuery.disableAnimations` is set.
///
/// It sits in `core/` while reaching into `features/companion`, which nothing
/// else here does. The mascot is half of what the design's block *is*, so the
/// alternative is a shared widget that cannot draw it — or moving the whole
/// companion out of `features/` to spare one import.
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

  /// The line itself — *All correct*, *Clean board*, *Not quite*.
  ///
  /// **Written in sentence case and rendered uppercase**, because the case
  /// is the design's treatment of the line rather than part of what it says.
  /// Assistive technology is given the string as written, for the same
  /// reason `SmallcapsLabel` does it — a caller that pre-shouts its verdict
  /// makes the screen reader shout it too.
  final String verdict;

  /// Which way it went.
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

    return Row(
      children: [
        Roasty(state: outcome.mascotState, size: placement.mascot),
        const SizedBox(width: AppSpacing.base),
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
                    color: outcome == Verdict.right
                        ? mood.sage
                        : placement.wrongTone(mood),
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
  }
}
