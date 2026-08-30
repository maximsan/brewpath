import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/active_challenge_card.dart';
import 'package:brew_path/features/challenges/presentation/saved_challenges_list.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/presentation/practice_any_lesson_widget.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/presentation/mini_games_catalog_widget.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/progress/presentation/freeze_save_notice_card.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/tour_stop.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Learn tab's one scrollable list, and the three Tour stops anchored in
/// it.
class LearnListView extends ConsumerWidget {
  /// Creates a [LearnListView].
  const LearnListView({super.key});

  static const _padding = EdgeInsets.all(AppSpacing.md);
  static const _sectionGap = SizedBox(height: AppSpacing.lg);
  static const _headerGap = SizedBox(height: AppSpacing.sm);

  /// How much off-screen list to keep mounted while the Tour is running.
  ///
  /// The vendor-documented caveat: auto-scroll is
  /// `Scrollable.ensureVisible`, which needs the target's *element* mounted,
  /// and a `ListView(children:)` still mounts its children lazily even though
  /// it builds the widgets eagerly. Of the two mitigations the research doc
  /// lists, this is the one that fits a fixed, small child list — a
  /// `ScrollController` pre-scroll would have to guess a pixel offset that
  /// changes with the challenge card, the freeze notice and the module count.
  ///
  /// Applied only while the Tour runs, because mounting the whole list on every
  /// open is a cost paid by every learner for a thing that happens once.
  ///
  /// Expressed in viewports rather than pixels on purpose: the list's height
  /// varies with the challenge card, the freeze notice and the module count,
  /// and a pixel figure that covered a tall phone would be a guess that a
  /// small one outgrows. Five viewports clears the whole tab on any device the
  /// app supports.
  static const _tourCacheViewports = 5.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayLessonProvider);
    final keepSharp = ref.watch(keepSharpRecommendationProvider);
    final keepSharpDone = ref.watch(keepSharpAcknowledgedTodayProvider);
    final finishedLessons = ref.watch(completedLessonsWithModuleProvider);
    final miniGames = ref.watch(miniGameFormatsProvider);
    final entitlement = ref.watch(courseEntitlementProvider);
    final challenge = ref.watch(activeChallengeProvider).asData?.value;
    final tourRunning = ref.watch(tourRunningProvider);

    return ListView(
      padding: _padding,
      physics: const AlwaysScrollableScrollPhysics(),
      scrollCacheExtent: tourRunning
          ? const ScrollCacheExtent.viewport(_tourCacheViewports)
          : null,
      children: [
        // The save beat leads the tab: someone returning after a miss is
        // the most fragile learner in the app, and reassurance comes
        // before the day's ask. Renders nothing when no save is due.
        const FreezeSaveNoticeCard(),
        TourStop(
          stopKey: TourStops.today,
          title: TourCopy.todayTitle,
          description: TourCopy.todayBody,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The eyebrow is what tells a caught-up learner that the accent
              // card below is a *state* of the day rather than a new kind of
              // work. Without it the Keep Sharp card reads as another lesson.
              //
              // Held back until the lesson resolves: "all caught up" is the
              // pending state's shape too, and congratulating someone for a
              // day they have not been read yet would be the wrong half of a
              // flash to show.
              if (today.hasValue) ...[
                SmallcapsLabel(
                  today.requireValue == null
                      ? AppLabels.allCaughtUp
                      : AppLabels.continueLearning,
                ),
                _headerGap,
              ],
              TodayCardWidget(
                today: today.asData?.value,
                keepSharp: keepSharp.asData?.value,
                keepSharpDone: keepSharpDone.asData?.value ?? false,
              ),
            ],
          ),
        ),
        // The brew in play sits under the day's lesson: a sibling card,
        // because what to learn and what to go and make are two questions
        // and a learner can have both open at once.
        if (challenge != null) ...[
          _headerGap,
          ActiveChallengeCard(challenge: challenge),
        ],
        const SavedChallengesList(),
        _sectionGap,
        // Stop 2 spans both practice sections. They are one idea to a learner —
        // "practice, your way" — and spotlighting the replay list alone would
        // teach that mini-games are something else.
        TourStop(
          stopKey: TourStops.practice,
          title: TourCopy.practiceTitle,
          description: TourCopy.practiceBody,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(AppLabels.practiceSection),
              _headerGap,
              const SectionHeader(AppLabels.practiceLessonsGroup),
              _headerGap,
              PracticeAnyLessonWidget(
                lessons: finishedLessons.asData?.value ?? const [],
              ),
              _sectionGap,
              const SectionHeader(AppLabels.practiceGamesGroup),
              _headerGap,
              MiniGamesCatalogWidget(
                formats: miniGames.asData?.value ?? const [],
                // Unresolved entitlement reads as **owned**. A learner who
                // bought the course must never catch a frame of locks on
                // their own shelf; a missing lock for one frame costs the
                // free learner nothing, and the wrong lock insults the payer.
                hasCourse: entitlement.asData?.value ?? true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
