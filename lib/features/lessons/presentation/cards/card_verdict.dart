import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The line that says whether a graded card was passed, and what follows it.
///
/// Announced as its own region, because it arrives on commit with no focus
/// change to bring a reader to it: the per-option marks say what each choice
/// was, and only this says how the card went. Without the live region a learner
/// using a screen reader hears every mark and never the outcome.
///
/// **Two callers, not five.** The design source keeps one verdict block for
/// every graded surface, and warns why — nine hand-rolled copies in the
/// prototype drifted apart on gap, type scale and margin. The app has its own
/// copies, and they have already drifted. Porting the block properly across all
/// of them is [#390](https://github.com/maximsan/brewpath/issues/390)'s, which
/// owns the component; this is the shared half of the two cards added with
/// `slider` and `sequence`, so the pair does not land as copies six and seven.
class CardVerdict extends StatelessWidget {
  /// Creates a [CardVerdict].
  const CardVerdict({
    required this.verdict,
    required this.wasCorrect,
    required this.children,
    super.key,
  });

  /// The smallcaps line itself — `DIALED IN`, `IN ORDER`, `NOT QUITE`.
  final String verdict;

  /// Which way the card went, which is the whole of the line's colour.
  final bool wasCorrect;

  /// What the card says under the verdict: its explanation, its reveal.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          label: verdict,
          excludeSemantics: true,
          child: Text(
            verdict,
            style: AppText.label(
              mood: mood,
              color: wasCorrect ? mood.sage : mood.berry,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        ...children,
      ],
    );
  }
}
