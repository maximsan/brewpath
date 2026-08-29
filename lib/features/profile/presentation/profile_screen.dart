import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/challenges/presentation/challenge_stat_row.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/widgets/preference_tile.dart';
import 'package:brew_path/features/profile/presentation/widgets/stat_tile.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/progress/presentation/week_strip.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gap between the Profile's stacked sections. Off the `AppSpacing` scale by
/// one notch — the design sets this page's section rhythm at 28.
const double _sectionGap = 28;

/// Profile tab: progress stats and preferences.
class ProfileScreen extends ConsumerWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(totalPointsProvider);
    final streak = ref.watch(streakProvider);
    final lessons = ref.watch(completedLessonsProvider);
    final cards = ref.watch(collectedCardsProvider);
    final settings = ref.watch(settingsControllerProvider);
    final treeStage = ref.watch(treeStageProvider);
    final weekDays = ref.watch(weekStripDaysProvider).asData?.value;
    final grove = ref.watch(groveTreatmentProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.list(
              children: [
                Center(
                  child: treeStage.when(
                    data: (stage) => CoffeeTree(
                      stage: stage,
                      // A grove still loading paints the real art rather
                      // than blocking the tree on it.
                      treatment: grove.asData?.value ?? GroveTreatment.identity,
                    ),
                    loading: CoffeeTreePlaceholder.new,
                    error: (_, _) => const CoffeeTreePlaceholder(),
                  ),
                ),
                const SizedBox(height: _sectionGap),
                const _SectionTitle('Your progress'),
                const SizedBox(height: 12),
                _StatsGrid(
                  points: points.asData?.value ?? 0,
                  streakDays: streak.asData?.value ?? 0,
                  lessonsCompleted: lessons.asData?.value.length ?? 0,
                  cardsCollected: cards.asData?.value.length ?? 0,
                  onStreakTap: () =>
                      context.goNamed(AppRoutes.profileStreak.name),
                  streakFooter: weekDays == null
                      ? null
                      : WeekStrip(days: weekDays, size: WeekStripSize.small),
                ),
                const SizedBox(height: AppSpacing.sm),
                const ChallengeStatRow(),
                const SizedBox(height: _sectionGap),
                const _SectionTitle('Customize'),
                const SizedBox(height: 12),
                _CustomizeGrid(
                  soundEnabled: settings.asData?.value.soundEnabled ?? true,
                  hapticsEnabled: settings.asData?.value.hapticsEnabled ?? true,
                  onToggleSound: () => ref
                      .read(settingsControllerProvider.notifier)
                      .toggleSound(),
                  onToggleHaptics: () => ref
                      .read(settingsControllerProvider.notifier)
                      .toggleHaptics(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: context.mood.ink,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.points,
    required this.streakDays,
    required this.lessonsCompleted,
    required this.cardsCollected,
    required this.onStreakTap,
    required this.streakFooter,
  });

  final int points;
  final int streakDays;
  final int lessonsCompleted;
  final int cardsCollected;
  final VoidCallback onStreakTap;
  final Widget? streakFooter;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: [
        StatTile.mark(
          mark: AppIcon.bean,
          label: 'Total points',
          value: '$points',
        ),
        StatTile(
          icon: Icons.local_fire_department,
          label: 'Day streak',
          value: '$streakDays',
          onTap: onStreakTap,
          footer: streakFooter,
        ),
        StatTile.mark(
          mark: AppIcon.check,
          label: 'Lessons',
          value: '$lessonsCompleted',
        ),
        StatTile.mark(
          mark: AppIcon.cards,
          label: 'Cards',
          value: '$cardsCollected',
        ),
      ],
    );
  }
}

class _CustomizeGrid extends StatelessWidget {
  const _CustomizeGrid({
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.onToggleSound,
    required this.onToggleHaptics,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback onToggleHaptics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: [
        PreferenceTile.toggle(
          icon: Icons.volume_up_outlined,
          title: 'Sound',
          subtitle: 'Lesson and mini-game audio',
          value: soundEnabled,
          onChanged: (_) => onToggleSound(),
        ),
        PreferenceTile.toggle(
          icon: Icons.vibration,
          title: 'Haptics',
          subtitle: 'Subtle taps on actions',
          value: hapticsEnabled,
          onChanged: (_) => onToggleHaptics(),
        ),
        // The reminder and the theme used to sit here reading "Soon". Both
        // ship in Settings now (#395), so the tiles were promising a learner
        // something they already have — behind the gear at the top of this
        // screen. Whether the two toggles left here should also defer to
        // Settings is the Profile rebuild's call (#393).
      ],
    );
  }
}
