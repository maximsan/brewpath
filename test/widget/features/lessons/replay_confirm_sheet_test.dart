// What a list does when the lesson under the finger is already finished:
// the design asks first, and only a confirm starts the run.
import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/presentation/term_detail_screen.dart';
import 'package:brew_path/features/lessons/domain/replay_confirm.dart';
import 'package:brew_path/features/lessons/presentation/replay_confirm_sheet.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/presentation/path_lesson_row.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/progress_seed.dart';
import '../../../support/widget_harness.dart';

const _lessonId = 'm1l1';

/// A shipped term whose entry names [_lessonId] as where it was learned.
const _termId = 'cherry';
const _openLabel = 'open the lesson';
const _running = 'the lesson is running';

/// A container over a fresh database, with the lesson already finished
/// unless [finished] says otherwise.
///
/// The seed goes through `runAsync`: it is real drift I/O, which never
/// progresses under the test's fake clock.
Future<ProviderContainer> _container(
  WidgetTester tester, {
  bool finished = true,
  DateTime? finishedAt,
}) async {
  await useInMemoryDatabase();
  final container = ProviderContainer();
  addTearDown(container.dispose);
  if (finished) {
    await tester.runAsync(
      () => seedCompletedLesson(
        container.read(snapshotRepositoryProvider),
        _lessonId,
        at: finishedAt ?? DateTime.now().subtract(const Duration(days: 3)),
      ),
    );
  }
  return container;
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool finished = true,
  DateTime? finishedAt,
}) async {
  final container = await _container(
    tester,
    finished: finished,
    finishedAt: finishedAt,
  );

  final router = GoRouter(
    initialLocation: AppRoutes.learn.path,
    routes: [
      GoRoute(
        path: AppRoutes.learn.path,
        name: AppRoutes.learn.name,
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.goToLessonAskingReview(_lessonId),
              child: const Text(_openLabel),
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.lesson.path,
            name: AppRoutes.lesson.name,
            builder: (_, _) => const Text(_running),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.cupping, routerConfig: router),
    ),
  );
  await settleLoaders(tester);
  return container;
}

Future<void> _drain(WidgetTester tester) async {
  for (var frame = 0; frame < 10; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> _tapOpen(WidgetTester tester) async {
  await tester.tap(find.text(_openLabel));
  await _drain(tester);
}

/// The shipped lesson the rows are built from, so a row's title is the one a
/// learner would read.
///
/// Through `runAsync`: the bank is read off the asset bundle, which is real
/// I/O and never resolves under the test's fake clock.
Future<LessonModel> _realLesson(
  WidgetTester tester,
  ProviderContainer container,
) async => (await tester.runAsync(
  () => container.read(contentRepositoryProvider).getLessonById(_lessonId),
))!;

void main() {
  testWidgets('a finished lesson is asked about before it replays', (
    tester,
  ) async {
    await _pump(tester);
    await _tapOpen(tester);

    expect(find.text(ReplayConfirmCopy.confirm), findsOneWidget);
    expect(find.text(ReplayConfirmCopy.cancel), findsOneWidget);
    expect(find.text(_running), findsNothing);
  });

  testWidgets('the sheet says what a second run is worth', (tester) async {
    await _pump(tester);
    await _tapOpen(tester);

    expect(find.text('Points'), findsOneWidget);
    expect(find.text('No change'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text(ReplayConfirmCopy.lastCompleted), findsOneWidget);
  });

  testWidgets('the streak line reads the day, not a fixed promise', (
    tester,
  ) async {
    // Seeded three days back, so nothing has been earned today yet.
    await _pump(tester);
    await _tapOpen(tester);
    expect(find.text(ReplayConfirmCopy.streakCounts), findsOneWidget);
    expect(find.text(ReplayConfirmCopy.streakEarned), findsNothing);
  });

  testWidgets('a day already earned says so instead', (tester) async {
    await _pump(tester, finishedAt: DateTime.now());
    await _tapOpen(tester);

    expect(find.text(ReplayConfirmCopy.streakEarned), findsOneWidget);
    expect(find.text(ReplayConfirmCopy.streakCounts), findsNothing);
    expect(
      find.text(dayName(epochDay(DateTime.now()), today: DateTime.now())),
      findsOneWidget,
    );
  });

  testWidgets('Not now starts nothing', (tester) async {
    await _pump(tester);
    await _tapOpen(tester);

    await tester.tap(find.text(ReplayConfirmCopy.cancel));
    await tester.pumpAndSettle();

    expect(find.text(_running), findsNothing);
    expect(find.text(_openLabel), findsOneWidget);
  });

  testWidgets('confirming plays the run', (tester) async {
    await _pump(tester);
    await _tapOpen(tester);

    await tester.tap(find.text(ReplayConfirmCopy.confirm));
    await tester.pumpAndSettle();

    expect(find.text(_running), findsOneWidget);
  });

  testWidgets('an unfinished lesson starts straight away', (tester) async {
    await _pump(tester, finished: false);
    await _tapOpen(tester);

    expect(find.text(ReplayConfirmCopy.confirm), findsNothing);
    expect(find.text(_running), findsOneWidget);
  });

  testWidgets('a spent free day meets the paywall, and never the sheet', (
    tester,
  ) async {
    final container = await _pump(tester);
    // The free day's two activities, through the real recorder.
    await tester.runAsync(() async {
      final snapshots = container.read(snapshotRepositoryProvider);
      for (var i = 0; i < freeDailyActivities; i++) {
        await recordActivity(
          snapshots,
          type: ActivityType.vocab,
          subject: '',
          now: DateTime.now(),
        );
      }
    });
    await _tapOpen(tester);

    expect(
      find.text(const DailyAllowanceSpent(cap: freeDailyActivities).header),
      findsOneWidget,
    );
    expect(find.text(ReplayConfirmCopy.confirm), findsNothing);
    expect(find.text(_running), findsNothing);
  });

  testWidgets('the Path asks before it replays a row', (tester) async {
    final container = await _container(tester);
    final lesson = await _realLesson(tester, container);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: Scaffold(
            body: PathLessonRow(
              entry: PathLesson(
                lesson: lesson,
                isCompleted: true,
                isCurrent: false,
                isPurchaseLocked: false,
                mastery: const MasteryResult(correct: 5, total: 5),
              ),
              isLast: true,
            ),
          ),
        ),
      ),
    );
    await settleLoaders(tester);

    await tester.tap(find.byType(InkWell).first);
    await _drain(tester);

    expect(find.text(ReplayConfirmCopy.confirm), findsOneWidget);
  });

  testWidgets("a term's lesson row asks before it replays", (tester) async {
    // The fourth route to a finished lesson, and the one #573 never named:
    // a dictionary term says where it was learned, and that is usually a
    // lesson the learner has already been through.
    final container = await _container(tester);
    final lesson = await _realLesson(tester, container);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.cupping,
          home: const TermDetailScreen(termId: _termId),
        ),
      ),
    );
    await settleLoaders(tester);

    await tester.ensureVisible(find.text(lesson.title));
    await tester.tap(find.text(lesson.title));
    await _drain(tester);

    expect(find.text(ReplayConfirmCopy.confirm), findsOneWidget);
  });

  testWidgets('Saved asks before it replays a bookmarked lesson', (
    tester,
  ) async {
    final container = await _container(tester);
    final lesson = await _realLesson(tester, container);
    await tester.runAsync(
      () => toggleSaved(
        container.read(snapshotRepositoryProvider),
        key: formatSavedKey(SavedKind.lesson, _lessonId),
        now: DateTime.now(),
        isPlus: true,
        visible: 0,
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.cupping, home: const SavedScreen()),
      ),
    );
    await settleLoaders(tester);

    await tester.tap(find.text(lesson.title));
    await _drain(tester);

    expect(find.text(ReplayConfirmCopy.confirm), findsOneWidget);
  });
}
