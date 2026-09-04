import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The Keep Sharp state of the Today card: one recommended practice type for
/// the day, the type's own completion rule, and a CTA to its surface. Once
/// the recommendation's rule is met, the card acknowledges with an animated
/// Roasty and a short phrase — the whole reward (§6): no repeat points, no
/// tree growth. With no recommendation (empty pool) it degrades to a quiet
/// caught-up note — never a dead end promising future modules.
class KeepSharpCardBody extends StatelessWidget {
  /// Creates a [KeepSharpCardBody].
  const KeepSharpCardBody({
    required this.recommendation,
    this.acknowledged = false,
    super.key,
  });

  /// The day's pick, or null when no registered type has material.
  final KeepSharpRecommendation? recommendation;

  /// Whether today's recommended type has met its own completion rule —
  /// derived per-day from existing activity records, stored nowhere.
  final bool acknowledged;

  static const double _mutedAlpha = 0.8;
  static const double _iconSm = 18;
  static const double _ackRoastySize = 72;

  /// Shown until the authored lines load; never persisted.
  static const String _fallbackPhrase = 'Done for today.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final recommended = recommendation;

    return Padding(
      padding: EdgeInsets.all(OffTokens.todayHeroPadding.value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconMark(AppIcon.bolt, size: _iconSm, color: mood.accentInk),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'KEEP SHARP',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: mood.accentInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (recommended == null)
            _quietState(theme, mood)
          else if (acknowledged)
            _acknowledgedBody(theme, mood)
          else
            _recommendationBody(context, theme, mood, recommended),
        ],
      ),
    );
  }

  Widget _acknowledgedBody(ThemeData theme, MoodColors mood) {
    return CompanionCelebration(
      reaction: CompanionReaction.keepSharpComplete,
      size: _ackRoastySize,
      // Beside the phrase rather than in a bubble: this one sits inside the
      // Today card, where a bubble would fight the card's own frame.
      builder: (context, companion, line) {
        final phrase = line ?? _fallbackPhrase;
        return Semantics(
          label: 'Keep Sharp complete for today. $phrase',
          child: Row(
            children: [
              companion,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  phrase,
                  // `labelLarge` is `bodyMedium`'s rung in the control face.
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: mood.accentInk,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _recommendationBody(
    BuildContext context,
    ThemeData theme,
    MoodColors mood,
    KeepSharpRecommendation recommended,
  ) {
    final copy = keepSharpCopyFor(recommended.type);
    return Semantics(
      label:
          "Keep Sharp: today's recommendation is ${copy.title}. ${copy.rule}",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            copy.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: mood.accentInk,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            copy.rule,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mood.accentInk.withValues(alpha: _mutedAlpha),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Sized by Material, not `PrimaryButton`: this is an action
          // inside a card, not the screen's CTA.
          FilledButton(
            onPressed: () => context.goTo(recommended.destination),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Widget _quietState(ThemeData theme, MoodColors mood) {
    return Semantics(
      label:
          'Keep Sharp: no recommendation today. '
          'Practice anything below to keep your streak alive.',
      child: Text(
        'Practice anything below to keep your streak alive.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: mood.accentInk.withValues(alpha: _mutedAlpha),
        ),
      ),
    );
  }
}
