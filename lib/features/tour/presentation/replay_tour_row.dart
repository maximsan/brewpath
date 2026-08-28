import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Replay the tour", at the bottom of Profile's Customize section.
///
/// Full width rather than a fifth tile in the grid: the four above it are
/// *settings* the learner leaves in a state, and this one is an action that
/// leaves the screen. Sharing their shape would file it as a preference.
class ReplayTourRow extends ConsumerWidget {
  /// Creates a [ReplayTourRow].
  const ReplayTourRow({super.key});

  static const double _badgeSize = 44;
  static const double _badgeRadius = 12;
  static const double _iconSize = 22;
  static const double _cardRadius = 20;
  static const _padding = EdgeInsets.all(AppSpacing.md);

  void _replay(BuildContext context, WidgetRef ref) {
    // Switch first, then ask. Learn consumes the request as soon as it is
    // raised, and the stops it spotlights have to be the ones on screen.
    context.goNamed(AppRoutes.learn.name);
    ref.read(tourReplayRequestProvider.notifier).request();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mood = context.mood;

    return Material(
      color: mood.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(color: mood.rule),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _replay(context, ref),
        child: Padding(
          padding: _padding,
          child: Row(
            children: [
              const IconBadge.roundedMark(
                mark: AppIcon.rematch,
                size: _badgeSize,
                radius: _badgeRadius,
                iconSize: _iconSize,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TourCopy.replayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: mood.ink,
                      ),
                    ),
                    Text(
                      TourCopy.replayBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: mood.inkMute,
                      ),
                    ),
                  ],
                ),
              ),
              IconMark(AppIcon.chevron, color: mood.inkMute),
            ],
          ),
        ),
      ),
    );
  }
}
