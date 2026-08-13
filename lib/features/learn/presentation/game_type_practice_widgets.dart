import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shown when the user has no completed lessons containing the chosen game
/// type, so there is nothing to practice yet.
class GameTypeEmptyState extends StatelessWidget {
  /// Creates a [GameTypeEmptyState].
  const GameTypeEmptyState({super.key});

  static const double _iconSize = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: _iconSize,
              color: context.mood.inkMute,
            ),
            const SizedBox(height: 16),
            Text(
              'No practice questions yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Complete a lesson with this game type to unlock practice.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.mood.inkMute,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/learn'),
              child: const Text('Back to Learn'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Terminal screen of a practice drill: a badge, the first-try score, and a
/// reminder that practice runs change nothing, then a Continue button.
class GameTypeSummary extends StatelessWidget {
  /// Creates a [GameTypeSummary].
  const GameTypeSummary({
    required this.correct,
    required this.total,
    super.key,
  });

  /// Number of steps answered correctly on the first attempt.
  final int correct;

  /// Total steps in the drill.
  final int total;

  static const double _badgeSize = 96;
  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _badgeSize,
              height: _badgeSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mood.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center,
                size: _iconSize,
                color: mood.accentInk,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Practice complete!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$correct / $total first-try correct',
              style: theme.textTheme.titleLarge?.copyWith(
                color: mood.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Practice runs do not change your XP, streak, or progress.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mood.inkMute,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/learn'),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact step indicator matching the standard lesson runner's style.
class GameTypeStepProgress extends StatelessWidget {
  /// Creates a [GameTypeStepProgress].
  const GameTypeStepProgress({
    required this.current,
    required this.total,
    super.key,
  });

  /// 1-based index of the current step.
  final int current;

  /// Total steps in the drill.
  final int total;

  static const double _pillRadius = 20;
  static const double _barHeight = 6;
  static const double _barRadius = 3;
  static const double _percentScale = 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final progress = total == 0 ? 0.0 : current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: mood.accent,
                borderRadius: BorderRadius.circular(_pillRadius),
              ),
              child: Text(
                'Step $current of $total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: mood.accentInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * _percentScale).round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: mood.inkMute,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: _barHeight,
          borderRadius: BorderRadius.circular(_barRadius),
          backgroundColor: mood.surface2,
          color: mood.accent,
        ),
      ],
    );
  }
}
