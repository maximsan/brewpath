import 'package:brew_path/features/challenges/presentation/challenge_sheet_shell.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_radii.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

const double _roastySize = 96;
const double _chipPaddingH = 12;
const double _chipPaddingV = 6;
const String _fallbackPhrase = 'Logged. That is a real cup behind you.';

/// What the learner chose to do next from the recap.
enum ChallengeRecapChoice {
  /// Put the challenge back in play.
  brewAgain,

  /// Close the recap.
  done,
}

/// Celebrates a logged brew and offers to run it again.
Future<ChallengeRecapChoice?> showChallengeRecapSheet({
  required BuildContext context,
  required BrewChallenge challenge,
  required int pointsAwarded,
}) => showChallengeSheet<ChallengeRecapChoice>(
  context: context,
  label: 'You logged ${challenge.title}',
  builder: (context) => _RecapBody(
    challenge: challenge,
    pointsAwarded: pointsAwarded,
  ),
);

class _RecapBody extends StatelessWidget {
  const _RecapBody({required this.challenge, required this.pointsAwarded});

  final BrewChallenge challenge;
  final int pointsAwarded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CompanionCelebration(
          reaction: CompanionReaction.challengeComplete,
          size: _roastySize,
          builder: (context, companion, line) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              companion,
              const SizedBox(height: AppSpacing.sm),
              Text(
                line ?? _fallbackPhrase,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(
            challenge.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (pointsAwarded > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: _PointsChip(points: pointsAwarded, mood: mood),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ChallengeRecapChoice.brewAgain),
          child: const Text('Brew it again'),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ChallengeRecapChoice.done),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.points, required this.mood});

  final int points;
  final MoodColors mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _chipPaddingH,
        vertical: _chipPaddingV,
      ),
      decoration: BoxDecoration(
        // Celebration, which is the one thing this colour is for.
        color: mood.warn,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        '+$points points',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: mood.bg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
