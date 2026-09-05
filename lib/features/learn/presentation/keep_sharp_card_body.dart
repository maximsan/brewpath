import 'dart:async';

import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/domain/roasty_state.dart';
import 'package:brew_path/features/companion/presentation/companion_celebration.dart';
import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:brew_path/features/monetization/presentation/activity_start.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';

/// The Keep Sharp state of the Today card: one recommended practice type for
/// the day, the type's own completion rule, Roasty resting beside them, and a
/// CTA to its surface. Once the recommendation's rule is met, the card
/// acknowledges with an animated Roasty and a short phrase — the whole reward
/// (§6): no repeat points, no tree growth. With no recommendation (empty
/// pool) it degrades to a quiet caught-up note — never a dead end promising
/// future modules.
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

  /// The rule under the title reads at `opacity: 0.82`.
  static const double _ruleAlpha = 0.82;

  /// The quiet note reads at `opacity: 0.85`.
  static const double _quietAlpha = 0.85;
  static const double _iconSm = 18;
  static const double _ackRoastySize = 72;

  /// The design seats him at `size={84}` beside the title and rule.
  static const double _restingRoastySize = 84;

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
          // Every state's label opens with "Keep Sharp", so the eyebrow is
          // not read out a second time.
          ExcludeSemantics(
            child: Row(
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
          ),
          if (recommended == null) ...[
            const SizedBox(height: AppSpacing.sm),
            _quietState(theme, mood),
          ] else if (acknowledged) ...[
            const SizedBox(height: AppSpacing.sm),
            _acknowledgedBody(theme, mood),
          ] else ...[
            const SizedBox(height: AppSpacing.base),
            _recommendationBody(context, theme, mood, recommended),
          ],
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
          excludeSemantics: true,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              // One label in place of the two texts, so the pick is read
              // once, as a sentence.
              child: Semantics(
                label:
                    "Keep Sharp: today's recommendation is ${copy.title}. "
                    '${copy.rule}',
                excludeSemantics: true,
                child: _titleAndRule(theme, mood, copy),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Decorative: the label beside him already says everything the
            // card says.
            const ExcludeSemantics(
              child: Roasty(
                state: RoastyState.idle,
                size: _restingRoastySize,
                plate: true,
              ),
            ),
          ],
        ),
        SizedBox(height: OffTokens.keepSharpStartGap.value),
        // Sized by Material, not `PrimaryButton`: this is an action
        // inside a card, not the screen's CTA.
        FilledButton(
          onPressed: () =>
              unawaited(context.goToActivity(recommended.destination)),
          child: Text('Start', semanticsLabel: 'Start: ${copy.title}'),
        ),
      ],
    );
  }

  /// The column Roasty rests beside.
  Widget _titleAndRule(ThemeData theme, MoodColors mood, KeepSharpCopy copy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          copy.title,
          style: theme.textTheme.titleMedium?.copyWith(color: mood.accentInk),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          copy.rule,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: mood.accentInk.withValues(alpha: _ruleAlpha),
          ),
        ),
      ],
    );
  }

  Widget _quietState(ThemeData theme, MoodColors mood) {
    return Semantics(
      label:
          'Keep Sharp: no recommendation today. '
          'Practice anything below to keep your streak alive.',
      excludeSemantics: true,
      child: Text(
        'Practice anything below to keep your streak alive.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: mood.accentInk.withValues(alpha: _quietAlpha),
        ),
      ),
    );
  }
}
