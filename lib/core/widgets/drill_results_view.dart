import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// What a finished drill scored, and the words that go under it.
///
/// The words are the caller's: the bands are shared (the design's 80% and 50%
/// switches), but a mini-game and a vocab drill say different things at them,
/// and copy is the one part of a results screen that should read as though it
/// were written for the game it follows.
typedef DrillOutcome = ({
  int score,
  int total,
  String encouragement,
  bool celebratory,
});

/// One of the two ways out of a results screen.
typedef DrillAction = ({String label, VoidCallback onPressed});

/// The end of a run: what was scored, a word about it, and the two ways out.
///
/// **One results screen for every drill in the app.** The mini-game player and
/// the vocab game both mount this, so the app cannot grow two ideas of what
/// finishing looks like — the same failure the roast meter was consolidated to
/// end (#381), one layer up.
///
/// Nothing here is written anywhere. The score exists for the length of this
/// screen and is then gone, which is what makes a drill replayable without
/// inflating anything; the *fact* that a run finished is recorded by the
/// player, not by its results.
class DrillResultsView extends StatelessWidget {
  /// Creates a [DrillResultsView].
  const DrillResultsView({
    required this.outcome,
    required this.primary,
    required this.secondary,
    super.key,
  });

  /// The score and the words for it.
  final DrillOutcome outcome;

  /// The filled action — running it back, on both drills.
  final DrillAction primary;

  /// The quieter way out.
  final DrillAction secondary;

  static const double _companionSize = 120;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Semantics(
                  label:
                      'Run complete. You scored ${outcome.score} '
                      'out of ${outcome.total}. ${outcome.encouragement}',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The score decides the pose: the module-sized
                      // celebration at or above the mark, the lesson-sized one
                      // below. No line — the encouragement below says it.
                      CompanionCelebration(
                        reaction: outcome.celebratory
                            ? CompanionReaction.moduleComplete
                            : CompanionReaction.lessonComplete,
                        size: _companionSize,
                        builder: (context, companion, line) => companion,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '${outcome.score} / ${outcome.total}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: mood.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        outcome.encouragement,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: mood.inkMute,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                PrimaryButton(
                  label: primary.label,
                  onPressed: primary.onPressed,
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: secondary.onPressed,
                    child: Text(secondary.label),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
