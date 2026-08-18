import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/companion/presentation/companion_handle.dart';
import 'package:brew_path/features/learn/domain/keep_sharp.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Keep Sharp state of the Today card: one recommended practice type for
/// the day, the type's own completion rule, and a CTA to its surface. Once
/// the recommendation's rule is met, the card acknowledges with an animated
/// Roasty and a short phrase — the whole reward (§6): no repeat points, no
/// tree growth. With no recommendation (empty pool) it degrades to a quiet
/// caught-up note — never a dead end promising future modules.
class KeepSharpCardBody extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<KeepSharpCardBody> createState() => _KeepSharpCardBodyState();
}

class _KeepSharpCardBodyState extends ConsumerState<KeepSharpCardBody> {
  final CompanionHandle _companionHandle = CompanionHandle();
  String? _line;
  bool _reacted = false;

  static const double _eyebrowLetterSpacing = 1.2;
  static const double _mutedAlpha = 0.8;
  static const double _iconSm = 18;
  static const double _ackRoastySize = 72;

  /// The hero card's inner padding — matches the lesson body in
  /// `today_card_widget.dart`; no `AppSpacing` token sits at 20.
  static const double _cardPadding = 20;

  /// Shown until the authored lines load; never persisted.
  static const String _fallbackPhrase = 'Done for today.';

  @override
  void dispose() {
    _companionHandle.dispose();
    super.dispose();
  }

  void _celebrateOnce() {
    if (_reacted) return;
    _reacted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _companionHandle.react(CompanionReaction.keepSharpComplete);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = context.mood;
    final recommended = widget.recommendation;

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
          else if (widget.acknowledged)
            _acknowledgedBody(theme, mood)
          else
            _recommendationBody(context, theme, mood, recommended),
        ],
      ),
    );
  }

  Widget _acknowledgedBody(ThemeData theme, MoodColors mood) {
    _line ??= ref
        .watch(companionLinesProvider)
        .asData
        ?.value
        .lineFor(CompanionReaction.keepSharpComplete);
    _celebrateOnce();
    final line = _line ?? _fallbackPhrase;

    return Semantics(
      label: 'Keep Sharp complete for today. $line',
      child: Row(
        children: [
          Companion(handle: _companionHandle, size: _ackRoastySize),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              line,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mood.accentInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
