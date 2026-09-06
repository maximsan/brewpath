import 'package:brew_path/app/tab_large_title.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/section_header.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/challenges/domain/challenge_providers.dart';
import 'package:brew_path/features/challenges/presentation/active_challenge_card.dart';
import 'package:brew_path/features/challenges/presentation/saved_challenges_list.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/learn/domain/learn_providers.dart';
import 'package:brew_path/features/learn/domain/lesson_position.dart';
import 'package:brew_path/features/learn/presentation/practice/practice_group.dart';
import 'package:brew_path/features/learn/presentation/practice_any_lesson_widget.dart';
import 'package:brew_path/features/learn/presentation/practice_drills_widget.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:brew_path/features/mini_games/domain/mini_game_providers.dart';
import 'package:brew_path/features/mini_games/presentation/mini_games_catalog_widget.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/lesson_access.dart';
import 'package:brew_path/features/progress/presentation/freeze_save_notice_card.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_providers.dart';
import 'package:brew_path/features/tour/presentation/tour_stop.dart';
import 'package:brew_path/features/tour/presentation/tour_stops.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far a practice row's highlight reaches past its text.
const double _rowBleed = AppSpacing.xs;

/// The bleed given back, for everything that is not a row.
const EdgeInsets _inGutter = EdgeInsets.symmetric(horizontal: _rowBleed);

/// The Learn tab's one scrollable list, and the two Tour stops anchored in it.
///
/// The design's page runs at the 24 gutter (`.px-24`). The practice shelf's
/// rows bleed a stop past their text into it (`margin: 0 -8px`), so the list
/// is padded to the gutter *less* that stop and everything that is not a row
/// pads it back — which is what [_inGutter] is for.
class LearnListView extends ConsumerWidget {
  /// Creates a [LearnListView].
  const LearnListView({super.key});

  /// No room at the top: [TabLargeTitle] leaves it.
  static const _padding = EdgeInsets.fromLTRB(
    AppSpacing.gutter - _rowBleed,
    0,
    AppSpacing.gutter - _rowBleed,
    AppSpacing.gutter,
  );

  /// The design's `paddingTop: 32` above PRACTICE.
  static const _sectionGap = SizedBox(height: AppSpacing.xl);

  /// The design's `marginBottom: 12` under PRACTICE.
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
    final challenge = ref.watch(activeChallengeProvider).asData?.value;
    final tourRunning = ref.watch(tourRunningProvider);
    // Unresolved reads as not owned, the rule `courseEntitlement` states, and
    // it is read once here rather than in each row that needs it.
    final hasCourse =
        ref.watch(courseEntitlementProvider).asData?.value ?? false;

    return ListView(
      padding: _padding,
      physics: const AlwaysScrollableScrollPhysics(),
      scrollCacheExtent: tourRunning
          ? const ScrollCacheExtent.viewport(_tourCacheViewports)
          : null,
      children: [
        // Below the header's entries, not beside them: the day's date is not
        // a fixed string, and the long ones reach across to where they float.
        Padding(
          padding: _inGutter,
          child: TabLargeTitle(
            AppRoutes.learn,
            topGap: OffTokens.tabTitleClearOfEntries.value,
          ),
        ),
        // The save beat leads the tab: someone returning after a miss is
        // the most fragile learner in the app, and reassurance comes
        // before the day's ask. Renders nothing when no save is due.
        const Padding(padding: _inGutter, child: FreezeSaveNoticeCard()),
        SizedBox(height: OffTokens.todayLeadGap.value),
        _TodayLead(hasCourse: hasCourse),
        // The brew in play sits under the day's lesson: a sibling card,
        // because what to learn and what to go and make are two questions
        // and a learner can have both open at once.
        if (challenge != null) ...[
          _headerGap,
          Padding(
            padding: _inGutter,
            child: ActiveChallengeCard(challenge: challenge),
          ),
        ],
        const Padding(padding: _inGutter, child: SavedChallengesList()),
        _sectionGap,
        _PracticeShelf(hasCourse: hasCourse),
      ],
    );
  }
}

/// Stop 1 of the Tour: the eyebrow that names the state of the day, and the
/// card under it.
class _TodayLead extends ConsumerWidget {
  const _TodayLead({required this.hasCourse});

  final bool hasCourse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayLessonProvider);
    final modules = ref.watch(modulesWithProgressProvider).asData?.value;
    final todayLesson = today.asData?.value;
    final todayModule = todayLesson == null || modules == null
        ? null
        : moduleOwning(modules, todayLesson.moduleId);
    // Today's lesson is by definition the first *unfinished* one, so the
    // "a finished lesson never locks" arm of ADR-0016 can never apply to it.
    final todayLocked =
        todayLesson != null &&
        isLessonPurchaseLocked(
          lessonId: todayLesson.id,
          hasCourse: hasCourse,
          isCompleted: false,
        );

    return TourStop(
      stopKey: TourStops.today,
      title: TourCopy.todayTitle,
      description: TourCopy.todayBody,
      child: Padding(
        padding: _inGutter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The eyebrow is what tells a caught-up learner that the accent
            // card below is a *state* of the day rather than a new kind of
            // work. Without it the Keep Sharp card reads as another lesson.
            //
            // Held back until the lesson resolves: "all caught up" is the
            // pending state's shape too, and congratulating someone for a day
            // they have not been read yet would be the wrong half of a flash
            // to show.
            if (today.hasValue) ...[
              SmallcapsLabel(
                today.requireValue == null
                    ? AppLabels.allCaughtUp
                    : AppLabels.continueLearning,
              ),
              SizedBox(height: OffTokens.todayLeadGap.value),
            ],
            TodayCardWidget(
              today: todayLesson,
              module: todayModule,
              isLocked: todayLocked,
              lessonsAhead: ref.watch(lessonsAheadProvider).asData?.value,
              keepSharp: ref
                  .watch(keepSharpRecommendationProvider)
                  .asData
                  ?.value,
              keepSharpDone:
                  ref.watch(keepSharpAcknowledgedTodayProvider).asData?.value ??
                  false,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stop 2 of the Tour: PRACTICE, and its groups.
///
/// One stop for both groups. They are one idea to a learner — "practice, your
/// way" — and spotlighting the replay list alone would teach that mini-games
/// are something else.
class _PracticeShelf extends ConsumerWidget {
  const _PracticeShelf({required this.hasCourse});

  final bool hasCourse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finishedLessons =
        ref.watch(completedLessonsWithModuleProvider).asData?.value ??
        const <LessonWithModule>[];
    final miniGames =
        ref.watch(miniGameFormatsProvider).asData?.value ?? const [];

    return TourStop(
      stopKey: TourStops.practice,
      title: TourCopy.practiceTitle,
      description: TourCopy.practiceBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: _inGutter,
            child: SectionHeader(AppLabels.practiceSection),
          ),
          LearnListView._headerGap,
          // Only once there is something finished to revisit — the design
          // lists no empty group.
          if (finishedLessons.isNotEmpty)
            PracticeGroup(
              label: AppLabels.practiceLessonsGroup,
              count: finishedLessons.length,
              children: [PracticeAnyLessonWidget(lessons: finishedLessons)],
            ),
          PracticeGroup(
            label: AppLabels.practiceGamesGroup,
            count: PracticeDrillsWidget.rowCount + miniGames.length,
            isLast: true,
            children: [
              // The dictionary drills lead the group (ADR-0004): free, always
              // visible, and a learner's cheapest way to protect the day.
              PracticeDrillsWidget(hasCourse: hasCourse),
              // This row gates its tap on `hasCourse`, so an unlocked frame
              // let someone start a paid game for free.
              MiniGamesCatalogWidget(formats: miniGames, hasCourse: hasCourse),
            ],
          ),
        ],
      ),
    );
  }
}
