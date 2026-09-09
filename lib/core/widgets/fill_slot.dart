import 'package:brew_path/core/widgets/dash_runs.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// How a slot stands. The design draws five, and every one has a call site:
/// `empty` and `guess` on the predict cloze, `filled` on a concept sentence
/// before it is checked, `right` and `wrong` after — and on the recall payoff.
enum FillSlotState {
  /// Nothing in it yet. Muted ink under a dashed rule, waiting.
  empty,

  /// A word is in, and nothing has judged it. Full ink.
  filled,

  /// The learner's ungraded claim on the predict card. Accent, because it is
  /// theirs rather than a verdict on it.
  guess,

  /// The authored answer. Sage, the colour of something learned.
  right,

  /// A word that was not it. Berry, the alert colour.
  wrong;

  /// Whether the rule under the word is dashed rather than solid.
  bool get isDashed => this == FillSlotState.empty;

  /// The colour the word is named in.
  Color ink(MoodColors mood) => switch (this) {
    FillSlotState.empty => mood.inkMute,
    FillSlotState.filled => mood.ink,
    FillSlotState.guess => mood.accent,
    FillSlotState.right => mood.sage,
    FillSlotState.wrong => mood.berry,
  };

  /// The colour of the rule under it. The two ungraded states mix the accent
  /// into the hairline rather than taking it whole — the design's
  /// `color-mix(in oklab, accent 55%, rule)` waiting, and 70% once filled.
  Color rule(MoodColors mood) => switch (this) {
    FillSlotState.empty => Color.lerp(mood.rule, mood.accent, _waiting)!,
    FillSlotState.filled => Color.lerp(mood.rule, mood.accent, _locked)!,
    _ => ink(mood),
  };

  /// How much accent the rule carries in each of the two ungraded states.
  static const double _waiting = 0.55;
  static const double _locked = 0.70;
}

/// The blank: one inline slot for every fill-in-the-blank mechanic in the app
/// — a concept sentence, the predict cloze, and the recall payoff.
///
/// A word on a 2px rule, sized so a sentence does not reflow as words land in
/// it. Set in mono unless [inherit] is set, which the design uses where the
/// slot sits inside display type and should keep the sentence's own face.
class FillSlot extends StatelessWidget {
  /// Creates a [FillSlot].
  const FillSlot({
    required this.state,
    this.word,
    this.inherit = false,
    super.key,
  });

  /// The design's `border-bottom: 2px`.
  static const double _ruleWeight = 2;

  /// The slot sets its own `line-height: 1.15`, tighter than the paragraph it
  /// sits in. The design says why: the rule follows the slot's own box, so the
  /// paragraph's leading would drop it off the baseline.
  static const double _ruleHugsWord = 1.15;

  /// Holds the slot's height open when there is no word in it yet.
  static const String _blank = '\u00a0';

  /// The word in the slot, or null while it waits for one.
  final String? word;

  /// How it stands.
  final FillSlotState state;

  /// Whether the word keeps the surrounding face instead of switching to mono.
  final bool inherit;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final ink = state.ink(mood);
    final rule = state.rule(mood);

    final body = Container(
      constraints: BoxConstraints(minWidth: OffTokens.fillSlotMinWidth.value),
      padding: OffTokens.fillSlotPadding.value,
      // The side is declared even when the rule is dashed, and simply not
      // painted: it is what reserves the strip the dashes are drawn into, so a
      // slot is the same height before and after a word lands in it.
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: state.isDashed ? rule.withValues(alpha: 0) : rule,
            width: _ruleWeight,
          ),
        ),
      ),
      child: Text(
        (word == null || word!.isEmpty) ? _blank : word!,
        textAlign: TextAlign.center,
        style:
            (inherit
                    ? DefaultTextStyle.of(context).style
                    : AppText.body(face: AppFace.mono))
                .copyWith(color: ink, height: _ruleHugsWord),
      ),
    );

    if (!state.isDashed) return body;
    return CustomPaint(
      foregroundPainter: _DashedUnderline(colour: rule, weight: _ruleWeight),
      child: body,
    );
  }
}

/// The dashed rule under an empty slot. A painter because `Border` has no
/// dash, and only the bottom edge is drawn — the design's `border-bottom`.
class _DashedUnderline extends CustomPainter {
  const _DashedUnderline({required this.colour, required this.weight});

  final Color colour;
  final double weight;

  @override
  void paint(Canvas canvas, Size size) {
    // Half the stroke up from the edge, so the line sits inside the box the
    // way a solid `BorderSide` does rather than straddling it.
    final baseline = size.height - weight / 2;
    final brush = Paint()
      ..color = colour
      ..strokeWidth = weight;

    for (final run in dashRuns(
      size.width,
      dash: dashPatternLength,
      gap: dashPatternGap,
    )) {
      canvas.drawLine(
        Offset(run.from, baseline),
        Offset(run.to, baseline),
        brush,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedUnderline old) =>
      old.colour != colour || old.weight != weight;
}

/// [slot] as an inline span sharing the baseline of the line it sits in — the
/// design's `inline-block`, whose padding and rule hang below that baseline
/// rather than pushing the slot off it. **No outer margin**: the
/// `padding: 0 6px 1px` is inside the chip, so a following full stop sits tight
/// against it, and spacing around a slot is written into the surrounding text.
InlineSpan fillSlotSpan(FillSlot slot) => WidgetSpan(
  alignment: PlaceholderAlignment.baseline,
  baseline: TextBaseline.alphabetic,
  child: slot,
);
