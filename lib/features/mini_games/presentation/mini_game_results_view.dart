import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/companion/presentation/companion_handle.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_run.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// The end of a run: what was scored, a word about it, and the two ways out.
///
/// Nothing here is written anywhere — no points, no tree growth, no cards, no
/// progress. The score exists for the length of this screen and then it is
/// gone, which is what makes a mini-game replayable without inflating anything.
class MiniGameResultsView extends StatefulWidget {
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

  @override
  State<MiniGameResultsView> createState() => _MiniGameResultsViewState();
}

class _MiniGameResultsViewState extends State<MiniGameResultsView> {
  final CompanionHandle _companionHandle = CompanionHandle();
  bool _reacted = false;

  static const double _companionSize = 120;

  @override
  void dispose() {
    _companionHandle.dispose();
    super.dispose();
  }

  void _reactOnce() {
    if (_reacted) return;
    _reacted = true;
    final celebratory = isCelebratoryRun(
      score: widget.score,
      total: widget.total,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _companionHandle.react(
        celebratory
            ? CompanionReaction.moduleComplete
            : CompanionReaction.lessonComplete,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    _reactOnce();
    final encouragement = runEncouragement(
      score: widget.score,
      total: widget.total,
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
                      'Run complete. You scored ${widget.score} '
                      'out of ${widget.total}. $encouragement',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Companion(
                        handle: _companionHandle,
                        size: _companionSize,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '${widget.score} / ${widget.total}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: mood.ink,
                          fontWeight: FontWeight.w700,
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onPlayAgain,
                    child: const Text('Play again'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.onDone,
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
