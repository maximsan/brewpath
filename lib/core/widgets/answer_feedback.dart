import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// Which way a graded surface went, and everything that follows from it.
///
/// One enum rather than a `bool` and a colour and a mascot state passed
/// separately: those three always move together, and it was passing them
/// separately that let five copies drift — one reached for `mood.warn` where
/// the rest used `mood.berry`, and nothing could tell that was a mistake.
enum Verdict {
  /// The learner got it.
  right(RoastyState.correct),

  /// They did not.
  wrong(RoastyState.wrong);

  const Verdict(this.mascotState);

  /// How Roasty takes the news.
  final RoastyState mascotState;

  /// The verdict line's own colour — sage when right, and when wrong the
  /// [wrongTone] the surface asks for.
  Color labelColour(MoodColors mood, Color wrongTone) =>
      this == Verdict.right ? mood.sage : wrongTone;
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
class AnswerFeedback extends StatelessWidget {
  /// Creates an [AnswerFeedback] — the graded-card treatment.
  const AnswerFeedback({
    required this.verdict,
    required this.outcome,
    this.explanation,
    this.extra,
    super.key,
  }) : _mascotSize = _mascotOnCard,
       _usesAccentWhenWrong = false;

  /// The dictionary's self-check, which the design draws smaller and tones
  /// **accent** rather than berry (`dictionary.jsx:491`).
  ///
  /// A term entry is reference rather than a graded run: berry is the colour
  /// the lesson player spends on a wrong answer, and a look-up that answers
  /// back in it reads as a worse failure than missing a self-check is.
  const AnswerFeedback.reference({
    required this.verdict,
    required this.outcome,
    this.explanation,
    super.key,
  }) : extra = null,
       _mascotSize = _mascotInReference,
       _usesAccentWhenWrong = true;

  /// The design's default mascot size on a graded card.
  static const double _mascotOnCard = 72;

  /// Its size inside a term entry, where the block sits in a tighter column.
  static const double _mascotInReference = 48;

  /// The line itself — `ALL CORRECT`, `CLEAN BOARD`, `NOT QUITE`.
  ///
  /// Rendered uppercase, because the case is the design's treatment of the
  /// line rather than part of what it says. Assistive technology is given the
  /// string as written, for the same reason `SmallcapsLabel` does it.
  final String verdict;

  /// Which way it went.
  final Verdict outcome;

  /// What the surface explains under the line, if it explains anything.
  final String? explanation;

  /// Anything the surface adds below the explanation — the sequence card's
  /// correct-order reveal is the one that needed it.
  final Widget? extra;

  final double _mascotSize;
  final bool _usesAccentWhenWrong;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final wrongTone = _usesAccentWhenWrong ? mood.accent : mood.berry;

    return Row(
      children: [
        Roasty(state: outcome.mascotState, size: _mascotSize),
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
                    color: outcome.labelColour(mood, wrongTone),
                  ),
                ),
              ),
              if (explanation != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(explanation!, style: AppText.support(mood: mood)),
              ],
              ?extra,
            ],
          ),
        ),
      ],
    );
  }
}
