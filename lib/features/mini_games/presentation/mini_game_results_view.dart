import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The end of a run: what was scored, a word about it, and the two ways out.
///
/// Nothing here is written anywhere — no points, no tree growth, no cards, no
/// progress. The score exists for the length of this screen and then it is
/// gone, which is what makes a mini-game replayable without inflating anything.
class MiniGameResultsView extends StatelessWidget {
  /// Creates a [MiniGameResultsView].
  const MiniGameResultsView({
    required this.score,
    required this.total,
    required this.onPlayAgain,
    required this.onDone,
    super.key,
  });

  /// Rounds answered correctly.
  final int score;

  /// Rounds played.
  final int total;

  /// Starts a fresh run, with a fresh order.
  final VoidCallback onPlayAgain;

  /// Returns the learner where they came from.
  final VoidCallback onDone;

  static const double _companionSize = 120;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final encouragement = runEncouragement(
      score: score,
      total: total,
    );

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Semantics(
                  label:
                      'Run complete. You scored $score '
                      'out of $total. $encouragement',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The score decides the pose: the module-sized
                      // celebration at or above the mark, the lesson-sized one
                      // below. No line — the encouragement below says it.
                      CompanionCelebration(
                        reaction: isCelebratoryRun(score: score, total: total)
                            ? CompanionReaction.moduleComplete
                            : CompanionReaction.lessonComplete,
                        size: _companionSize,
                        builder: (context, companion, line) => companion,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '$score / $total',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: mood.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        encouragement,
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
                PrimaryButton(label: 'Play again', onPressed: onPlayAgain),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onDone,
                    child: const Text('Done'),
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
