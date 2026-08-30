import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/challenges/presentation/challenge_stat_row.dart';
import 'package:brew_path/features/profile/domain/settings_providers.dart';
import 'package:brew_path/features/profile/presentation/widgets/lesson_progress_rollup.dart';
import 'package:brew_path/features/profile/presentation/widgets/preference_tile.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_progress_line.dart';
import 'package:brew_path/features/profile/presentation/widgets/streak_card.dart';
import 'package:brew_path/features/profile/presentation/widgets/tree_hero_card.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/mastery_rollup.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/saved/presentation/saved_entry_card.dart';
import 'package:brew_path/features/studio/presentation/studio_door_tile.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gap between Profile's stacked cards. The design sets 12 between the cards
/// and 24 above the two it treats as headline — the tree and the streak.
const double _cardGap = AppSpacing.sm;
const double _headlineGap = AppSpacing.gutter;

/// Above the closing line — the design's 22, its own value on this screen.
const double _joinedGap = AppSpacing.lg - 2;

/// Profile tab: the tree, the streak, what has been learned, and — until #429
/// moves them — the app's preferences.
class ProfileScreen extends ConsumerWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(totalPointsProvider);
    final streak = ref.watch(streakProvider);
    final lessons = ref.watch(completedLessonsProvider);
    final treeStage = ref.watch(treeStageProvider);
    final weekDays = ref.watch(weekStripDaysProvider).asData?.value;
    final grove = ref.watch(groveTreatmentProvider);
    final course = ref.watch(coreLessonProgressProvider).asData?.value;
    final joined = ref.watch(joinedDateProvider).asData?.value;

    final records = lessons.asData?.value ?? const [];
    final rollup = rollUpMastery(
      records.map((record) => record.mastery),
      total: course?.total ?? records.length,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.xs,
              AppSpacing.gutter,
              AppSpacing.gutter,
            ),
            sliver: SliverList.list(
              children: [
                treeStage.when(
                  data: (stage) => TreeHeroCard(
                    stage: stage,
                    // A grove still loading paints the real art rather than
                    // blocking the tree on it.
                    treatment: grove.asData?.value ?? GroveTreatment.identity,
                    completed: course?.completed ?? 0,
                    total: course?.total ?? 0,
                    onTap: () => context.pushNamed(AppRoutes.profileTree.name),
                  ),
                  loading: CoffeeTreePlaceholder.new,
                  error: (_, _) => const CoffeeTreePlaceholder(),
                ),
                const SizedBox(height: _headlineGap),
                StreakCard(
                  days: streak.asData?.value ?? 0,
                  weekDays: weekDays,
                  onTap: () => context.goNamed(AppRoutes.profileStreak.name),
                ),
                const SizedBox(height: AppSpacing.base),
                ProfileProgressLine(
                  lessons: records.length,
                  points: points.asData?.value ?? 0,
                ),
                // Absent until a lesson holds a score: an empty bar under a
                // heading says the learner is behind, when in fact they have
                // not started.
                if (rollup.scored > 0) ...[
                  const SizedBox(height: _cardGap),
                  LessonProgressRollup(
                    rollup: rollup,
                    onPractice: () => context.goNamed(AppRoutes.path.name),
                  ),
                ],
                const SizedBox(height: _cardGap),
                const ChallengeStatRow(),
                // The entries the design closes on, in its order: the Studio
                // door, then Saved. The Duel and Courses cards beside them are
                // gated off in the design and are not owed for v1.
                const SizedBox(height: _cardGap),
                const StudioDoorTile(),
                const SizedBox(height: _cardGap),
                const SavedEntryCard(),
                const SizedBox(height: _headlineGap),
                const _CustomizeSection(),
                if (joined != null) ...[
                  const SizedBox(height: _joinedGap),
                  _JoinedLine(joined: joined),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The month the learner joined, closing the screen.
///
/// Mono at the micro step, not [SmallcapsLabel]: the design sets this line in
/// `ff-mono` at `--t-micro` (`screens.jsx:2798-2802`), where smallcaps is Plex
/// Sans at the label step. The tracking is the same, the face and size are not.
class _JoinedLine extends StatelessWidget {
  const _JoinedLine({required this.joined});

  final DateTime joined;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Joined ${monthYear(joined)}'.toUpperCase(),
      style: AppText.micro(mood: context.mood),
    );
  }
}

/// The app's preferences, still on Profile.
///
/// Its own widget so it reads its own settings: #429 moves them to Settings,
/// where the design keeps them, and a section that owns its state is a deletion
/// rather than an unpicking. The Studio door used to sit under this heading;
/// it has moved up to the entry stack, which is where the design draws it.
class _CustomizeSection extends ConsumerWidget {
  const _CustomizeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SmallcapsLabel('Customize'),
        const SizedBox(height: _cardGap),
        _CustomizeGrid(
          soundEnabled: settings?.soundEnabled ?? true,
          hapticsEnabled: settings?.hapticsEnabled ?? true,
          onToggleSound: controller.toggleSound,
          onToggleHaptics: controller.toggleHaptics,
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
