import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Keep Sharp state of the Today card: one recommended practice type for
/// the day, the type's own completion rule, and a CTA to its surface. With no
/// recommendation (empty pool) it degrades to a quiet caught-up note — never
/// a dead end promising future modules.
class KeepSharpCardBody extends StatelessWidget {
  /// Creates a [KeepSharpCardBody].
  const KeepSharpCardBody({required this.recommendation, super.key});

  /// The day's pick, or null when no registered type has material.
  final KeepSharpRecommendation? recommendation;

  static const double _eyebrowLetterSpacing = 1.2;
  static const double _mutedAlpha = 0.8;
  static const double _iconSm = 18;

  /// The hero card's inner padding — matches the lesson body in
  /// `today_card_widget.dart`; no `AppSpacing` token sits at 20.
  static const double _cardPadding = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final recommended = recommendation;

    return Padding(
      padding: const EdgeInsets.all(_cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, size: _iconSm, color: mood.accentInk),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'KEEP SHARP',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: mood.accentInk,
                  letterSpacing: _eyebrowLetterSpacing,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (recommended == null)
            _quietState(theme, mood)
          else
            _recommendationBody(context, theme, mood, recommended),
        ],
      ),
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
              fontWeight: FontWeight.w700,
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
          FilledButton(
            onPressed: () => context.goNamed(
              recommended.routeName,
              pathParameters: recommended.pathParams,
            ),
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
