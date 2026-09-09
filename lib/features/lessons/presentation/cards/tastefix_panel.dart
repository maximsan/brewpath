import 'package:brew_path/features/lessons/presentation/cards/graded_picker.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_reaction.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_reaction_box.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_symptoms.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// What the panel calls itself before a fix, and after one that worked.
const String _startingPoint = 'STARTING POINT';
const String _fixed = 'FIXED';

/// The eyebrow over the chips, which names what the row is showing.
const String _tastes = 'TASTES';
const String _result = 'RESULT';

/// How much of its tint the panel washes over the surface — the design's
/// `var(--berry) 8%` unfixed, and `var(--sage) 14%` once balanced.
const double _unfixedWash = 0.08;
const double _balancedWash = 0.14;

/// How much tint the panel's rule carries — `var(--berry) 16%` against
/// `var(--sage) 30%`.
const double _unfixedRule = 0.16;
const double _balancedRule = 0.30;

/// How much berry the unfixed state label carries over muted ink — the
/// design's `color-mix(in oklab, var(--berry) 70%, var(--ink-mute))`.
const double _stateLabelBerry = 0.70;

/// Where the design's `160deg` gradient runs, and the stop it lands on —
/// `var(--surface) 68%` unfixed, and 70% once balanced.
const Alignment _washBegin = Alignment(-0.342, -0.940);
const Alignment _washEnd = Alignment(0.342, 0.940);
const double _unfixedStop = 0.68;
const double _balancedStop = 0.70;

/// The panel's lift — the design's `0 1px 2px` at `var(--ink) 6%`.
const double _liftBlur = 2;
const double _liftDrop = 1;
const double _liftInk = 0.06;

/// The cup the round is asking about, which reacts to the fix chosen.
///
/// Handed to [GradedPicker] as framing rather than built into it: the picker
/// still owns the latch and the one-signal contract, and reports the outcome
/// this reads. See #332.
class TastefixPanel extends StatelessWidget {
  /// Creates a [TastefixPanel].
  const TastefixPanel({
    required this.tags,
    required this.scenario,
    required this.reaction,
    super.key,
  });

  /// What the cup tastes of.
  final List<String> tags;

  /// The setup that rules out the obvious causes.
  final String scenario;

  /// How the cup answered the fix.
  final TastefixReaction reaction;

  @override
  Widget build(BuildContext context) {
    final mood = context.mood;
    final balanced = reaction.isBalanced;
    final tint = balanced ? mood.sage : mood.berry;
    final settle = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : tastefixSettleDuration;

    return TastefixReactionBox(
      reaction: reaction,
      child: AnimatedContainer(
        duration: settle,
        curve: Curves.ease,
        padding: OffTokens.tastefixPanelPadding.value,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _washBegin,
            end: _washEnd,
            colors: [
              Color.alphaBlend(
                tint.withValues(alpha: balanced ? _balancedWash : _unfixedWash),
                mood.surface,
              ),
              mood.surface,
            ],
            stops: [0, if (balanced) _balancedStop else _unfixedStop],
          ),
          border: Border.all(
            color: Color.alphaBlend(
              tint.withValues(alpha: balanced ? _balancedRule : _unfixedRule),
              mood.rule,
            ),
          ),
          borderRadius: BorderRadius.circular(
            OffTokens.tastefixPanelRadius.value,
          ),
          boxShadow: [
            BoxShadow(
              color: mood.ink.withValues(alpha: _liftInk),
              blurRadius: _liftBlur,
              offset: const Offset(0, _liftDrop),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: settle,
              style: AppText.label(
                face: AppFace.mono,
                color: balanced
                    ? mood.sage
                    : Color.lerp(mood.inkMute, mood.berry, _stateLabelBerry),
                tracking: AppTracking.hint,
              ),
              child: Text(balanced ? _fixed : _startingPoint),
            ),
            SizedBox(height: OffTokens.tastefixPanelGap.value),
            Text(scenario, style: AppText.support(color: mood.ink)),
            SizedBox(height: OffTokens.tastefixPanelGap.value),
            Row(
              children: [
                Text(
                  balanced ? _result : _tastes,
                  style: AppText.label(
                    mood: mood,
                    face: AppFace.mono,
                    tracking: AppTracking.hint,
                  ),
                ),
                SizedBox(width: OffTokens.tastefixPanelGap.value),
                Flexible(
                  child: TastefixSymptoms(tags: tags, reaction: reaction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
