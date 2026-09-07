import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How a slot stands. The design's blank has five states; these are the two
/// that render today, on the recall card's payoff.
///
/// `empty`, `guess` and `filled` arrive with the concept card and the predict
/// cloze, which still draw their own blanks (#546) — a state with no call site
/// would be vocabulary nobody speaks.
enum FillSlotState {
  /// The authored answer. Sage, the colour of something learned.
  right,

  /// A word that was not it. Berry, the alert colour.
  wrong;

  /// The colour the word and its rule are named in.
  Color tone(MoodColors mood) => switch (this) {
    FillSlotState.right => mood.sage,
    FillSlotState.wrong => mood.berry,
  };
}

/// The blank: one inline slot for every fill-in-the-blank mechanic in the app.
///
/// A word on a 2px rule, sized so slots do not jitter between a short word and
/// a long one. Set in mono unless [inherit] is set, which the design uses where
/// the slot sits inside display type and should keep the sentence's own face.
class FillSlot extends StatelessWidget {
  /// Creates a [FillSlot].
  const FillSlot({
    required this.word,
    required this.state,
    this.inherit = false,
    super.key,
  });

  /// The design's `min-width: 74px` — a slot holds its width so a sentence
  /// does not reflow as words land in it.
  static const double minWidth = 74;

  /// The design's `border-bottom: 2px`.
  static const double _ruleWeight = 2;

  /// The design's `padding: 0 6px 1px`, which sits between the app's `xxs` and
  /// `xs` steps and belongs to this component rather than to the scale.
  static const _padding = EdgeInsets.only(left: 6, right: 6, bottom: 1);

  /// The word in the slot.
  final String word;

  /// How it stands.
  final FillSlotState state;

  /// Whether the word keeps the surrounding face instead of switching to mono.
  final bool inherit;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final tone = state.tone(mood);

    return Container(
      constraints: const BoxConstraints(minWidth: minWidth),
      padding: _padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: tone, width: _ruleWeight),
        ),
      ),
      child: Text(
        word,
        textAlign: TextAlign.center,
        style: inherit
            ? DefaultTextStyle.of(context).style.copyWith(color: tone)
            : AppText.body(color: tone, face: AppFace.mono),
      ),
    );
  }
}

/// [slot] as an inline span, vertically centred on the line it sits in.
///
/// The design's slot is an `inline-block` inside a sentence; a `WidgetSpan` is
/// the Flutter shape of that, and the baseline alignment keeps the rule sitting
/// under the words around it rather than under the whole line box.
InlineSpan fillSlotSpan(FillSlot slot) => WidgetSpan(
  alignment: PlaceholderAlignment.middle,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
    child: slot,
  ),
);
