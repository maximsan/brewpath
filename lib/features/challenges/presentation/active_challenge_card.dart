import 'package:brew_path/features/challenges/domain/challenge_bank.dart';
import 'package:brew_path/shared/models/content/brew_challenge.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

const double _cardRadius = 12;
const double _eyebrowLetterSpacing = 0.6;
const double _iconSm = 18;

/// The Coffee Challenge in play, on Today.
///
/// A **sibling** of the day's lesson card rather than a state of it. The two
/// answer different questions — what to learn next, and what to go and brew —
/// and a learner can have both at once.
class ActiveChallengeCard extends StatelessWidget {
  /// Creates an [ActiveChallengeCard].
  const ActiveChallengeCard({required this.challenge, super.key});

  /// The challenge currently in play.
  final BrewChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final effort = effortParts(challenge.effort);

    return Semantics(
      container: true,
      label: _semanticsLabel(effort),
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        color: mood.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: mood.rule),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _eyebrow(theme, mood),
              const SizedBox(height: AppSpacing.xs),
              Text(
                challenge.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                challenge.instruction,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mood.inkMute,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _effortLine(theme, mood, effort),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eyebrow(ThemeData theme, MoodColors mood) => Row(
    children: [
      Icon(Icons.local_cafe_outlined, size: _iconSm, color: mood.accent),
      const SizedBox(width: AppSpacing.xxs),
      Text(
        'COFFEE CHALLENGE',
        style: theme.textTheme.labelSmall?.copyWith(
          color: mood.accent,
          fontWeight: FontWeight.w700,
          letterSpacing: _eyebrowLetterSpacing,
        ),
      ),
    ],
  );

  Widget _effortLine(
    ThemeData theme,
    MoodColors mood,
    ChallengeEffort effort,
  ) => Text(
    [
      ?effort.trigger,
      ?effort.duration,
    ].join(' · '),
    style: theme.textTheme.labelMedium?.copyWith(color: mood.inkMute),
  );

  String _semanticsLabel(ChallengeEffort effort) => [
    'Coffee Challenge.',
    '${challenge.title}.',
    challenge.instruction,
    ?effort.trigger,
    ?effort.duration,
  ].join(' ');
}
