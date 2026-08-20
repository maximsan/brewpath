import 'package:brew_path/features/challenges/presentation/challenge_stat_row.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/widgets/preference_tile.dart';
import 'package:brew_path/features/profile/presentation/widgets/premium_card.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_header.dart';
import 'package:brew_path/features/profile/presentation/widgets/stat_tile.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gap between the Profile's stacked sections. Off the `AppSpacing` scale by
/// one notch — the design sets this page's section rhythm at 28.
const double _sectionGap = 28;

/// Profile tab: progress stats, the premium CTA, and preferences.
class ProfileScreen extends ConsumerWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(totalXpProvider);
    final streak = ref.watch(streakProvider);
    final lessons = ref.watch(completedLessonsProvider);
    final cards = ref.watch(collectedCardsProvider);
    final settings = ref.watch(settingsControllerProvider);
    final treeStage = ref.watch(treeStageProvider);
    final grove = ref.watch(groveTreatmentProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: ProfileHeaderDelegate(
                title: 'Profile',
                onClose: () => context.go('/learn'),
                onSettings: () => context.go('/profile/settings'),
              ),
            ),
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
                        treatment:
                            grove.asData?.value ?? GroveTreatment.identity,
                      ),
                      loading: CoffeeTreePlaceholder.new,
                      error: (_, _) => const CoffeeTreePlaceholder(),
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                  const PremiumCard(),
                  const SizedBox(height: _sectionGap),
                  const _SectionTitle('Your progress'),
                  const SizedBox(height: 12),
                  _StatsGrid(
                    xp: xp.asData?.value ?? 0,
                    streakDays: streak.asData?.value ?? 0,
                    lessonsCompleted: lessons.asData?.value.length ?? 0,
                    cardsCollected: cards.asData?.value.length ?? 0,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const ChallengeStatRow(),
                  const SizedBox(height: _sectionGap),
                  const _SectionTitle('Customize'),
                  const SizedBox(height: 12),
                  _CustomizeGrid(
                    soundEnabled: settings.asData?.value.soundEnabled ?? true,
                    hapticsEnabled:
                        settings.asData?.value.hapticsEnabled ?? true,
                    onToggleSound: () => ref
                        .read(settingsControllerProvider.notifier)
                        .toggleSound(),
                    onToggleHaptics: () => ref
                        .read(settingsControllerProvider.notifier)
                        .toggleHaptics(),
                    onComingSoon: () => _showComingSoon(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Coming soon.'),
          duration: Duration(seconds: 2),
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
    required this.xp,
    required this.streakDays,
    required this.lessonsCompleted,
    required this.cardsCollected,
  });

  final int xp;
  final int streakDays;
  final int lessonsCompleted;
  final int cardsCollected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: [
        StatTile(icon: Icons.bolt, label: 'Total XP', value: '$xp'),
        StatTile(
          icon: Icons.local_fire_department,
          label: 'Day streak',
          value: '$streakDays',
        ),
        StatTile(
          icon: Icons.check_circle,
          label: 'Lessons',
          value: '$lessonsCompleted',
        ),
        StatTile(icon: Icons.style, label: 'Cards', value: '$cardsCollected'),
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
    required this.onComingSoon,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback onToggleHaptics;
  final VoidCallback onComingSoon;

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
        PreferenceTile.action(
          icon: Icons.notifications_outlined,
          title: 'Daily reminder',
          subtitle: 'Pick a time to brew up a lesson',
          trailingText: 'Soon',
          onTap: onComingSoon,
        ),
        PreferenceTile.action(
          icon: Icons.palette_outlined,
          title: 'Theme',
          subtitle: 'Light, dark, or follow system',
          trailingText: 'Soon',
          onTap: onComingSoon,
        ),
      ],
    );
  }
}
