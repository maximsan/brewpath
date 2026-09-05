import 'package:brew_path/app/tab_large_title.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/challenges/presentation/challenge_stat_row.dart';
import 'package:brew_path/features/profile/presentation/widgets/lesson_progress_rollup.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_progress_line.dart';
import 'package:brew_path/features/profile/presentation/widgets/streak_card.dart';
import 'package:brew_path/features/profile/presentation/widgets/tree_hero_card.dart';
import 'package:brew_path/features/progress/domain/completed_lessons.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/mastery_rollup.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/presentation/coffee_tree.dart';
import 'package:brew_path/features/saved/presentation/saved_entry_card.dart';
import 'package:brew_path/features/studio/presentation/studio_door_tile.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gap between Profile's stacked cards: the design sets 12 between them, and
/// 24 in the one place it wants air — under the tree, above the streak.
const double _cardGap = AppSpacing.sm;
const double _headlineGap = AppSpacing.gutter;

/// Above the closing line — the design's 22, its own value on this screen.
const double _joinedGap = AppSpacing.lg - 2;

/// Profile tab: the tree, the streak, what has been learned, and the doors on
/// out of it.
///
/// No preferences. Across the whole of the design's tab
/// (`prototype/screens.jsx:2546-2808`) there is not one — they live in
/// Settings, which the header gear opens.
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

    final records = lessons.asData?.value ?? const CompletedLessons();
    final rollup = rollUpMastery(
      records.mastery.values,
      total: course?.total ?? records.count,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            // No room at the top: `TabLargeTitle` leaves it.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              AppSpacing.gutter,
            ),
            sliver: SliverList.list(
              children: [
                // Below the entries for Learn's reason: the greeting carries
                // a name the learner typed, so its width is theirs to set.
                TabLargeTitle(
                  AppRoutes.profile,
                  topGap: OffTokens.tabTitleClearOfEntries.value,
                ),
                const SizedBox(height: _headlineGap),
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
                  lessons: records.count,
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
                const SizedBox(height: _cardGap),
                // The entries the design closes on, in its order: the Studio
                // door, then Saved. The Duel and Courses cards beside them are
                // gated off in the design and are not owed for v1. No heading
                // over them: `Customize` belonged to the preferences, and they
                // are Settings' (#429).
                const StudioDoorTile(),
                const SizedBox(height: _cardGap),
                const SavedEntryCard(),
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
