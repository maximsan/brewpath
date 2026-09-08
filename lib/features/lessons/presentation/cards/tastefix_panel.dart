import 'dart:async';

import 'package:brew_path/features/lessons/presentation/cards/graded_picker.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_reaction.dart';
import 'package:brew_path/features/lessons/presentation/cards/tastefix_symptoms.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
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

/// Where the design's `160deg` gradient runs, and the stop it lands on.
const Alignment _washBegin = Alignment(-0.342, -0.940);
const Alignment _washEnd = Alignment(0.342, 0.940);
const double _washStop = 0.7;

/// The cup the round is asking about, which reacts to the fix chosen.
///
/// Composed *around* [GradedPicker] rather than passed into it: the picker owns
/// the latch and the one-signal contract, and this owns what the cup does about
/// it. See #332.
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
    final theme = Theme.of(context);
    final mood = context.mood;
    final balanced = reaction.isBalanced;
    final tint = balanced ? mood.sage : mood.berry;

    return TastefixReactionBox(
      reaction: reaction,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : tastefixSettleDuration,
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
            stops: const [0, _washStop],
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              balanced ? _fixed : _startingPoint,
              style: AppText.label(
                face: AppFace.mono,
                color: balanced
                    ? mood.sage
                    : Color.lerp(mood.inkMute, mood.berry, _stateLabelBerry),
                tracking: AppTracking.hint,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(scenario, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
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
                const SizedBox(width: AppSpacing.sm),
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

/// Plays the panel's own reaction once: a pulse when the fix worked, a shake
/// when it did not, and nothing at all under reduced motion.
class TastefixReactionBox extends StatefulWidget {
  /// Wraps [child] in the reaction [reaction] calls for.
  const TastefixReactionBox({
    required this.reaction,
    required this.child,
    super.key,
  });

  /// How the cup answered the fix.
  final TastefixReaction reaction;

  /// The panel that moves.
  final Widget child;

  @override
  State<TastefixReactionBox> createState() => _TastefixReactionBoxState();
}

class _TastefixReactionBoxState extends State<TastefixReactionBox>
    with SingleTickerProviderStateMixin {
  /// Rests at 0, where both readings are the identity, so a card that is never
  /// answered draws exactly what it would have drawn without a controller.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: tastefixShakeDuration,
  );

  @override
  void didUpdateWidget(TastefixReactionBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reaction = widget.reaction;
    if (reaction == oldWidget.reaction ||
        reaction == TastefixReaction.unfixed) {
      return;
    }
    // Reduced motion lands the reaction in one frame: the chips and the panel
    // are already in their answered state, and only the movement is dropped.
    if (MediaQuery.disableAnimationsOf(context)) return;
    _controller.duration = reaction.isBalanced
        ? tastefixPulseDuration
        : tastefixShakeDuration;
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eased = CurvedAnimation(
      parent: _controller,
      curve: widget.reaction.isBalanced ? Curves.easeOut : Curves.easeInOut,
    );

    return AnimatedBuilder(
      animation: eased,
      builder: (context, child) => widget.reaction.isBalanced
          ? Transform.scale(
              scale: tastefixPulseScale(eased.value),
              child: child,
            )
          : Transform.translate(
              offset: Offset(tastefixShakeOffset(eased.value), 0),
              child: child,
            ),
      child: widget.child,
    );
  }
}
