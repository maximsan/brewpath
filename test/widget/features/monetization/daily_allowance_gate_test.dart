import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/dictionary/domain/flashcard_providers.dart';
import 'package:brew_path/features/learn/presentation/today_lesson_body.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/features/monetization/domain/daily_allowance.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/progress/domain/activity_recorder.dart';
import 'package:brew_path/features/saved/presentation/saved_study_row.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/widget_harness.dart';

/// The cap-hit path, through two real rows rather than the extension alone:
/// Today's lesson card, which *goes*, and the shelf's study row, which
/// *pushes*. Both had to keep their own stack behaviour, so both are asserted.
void main() {
  setUp(useInMemoryDatabase);

  final today = DateTime(2026, 9, 5, 10);

  /// What the run and the drill draw when they are reached. Absence of these
  /// is the AC's "never the surface".
  const lessonMark = 'THE LESSON RAN';
  const drillMark = 'THE DRILL DEALT';

  /// Fills today's activity record to [count], through the real recorder.
  Future<void> spend(int count) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    for (var i = 0; i < count; i++) {
      await recordActivity(
        container.read(snapshotRepositoryProvider),
        type: ActivityType.vocab,
        subject: '',
        now: today,
      );
    }
  }

  Future<void> pump(WidgetTester tester, {bool hasCourse = false}) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: AppRoutes.learn.path,
      routes: [
        GoRoute(
          path: AppRoutes.learn.path,
          name: AppRoutes.learn.name,
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TodayLessonBody(lesson: testLesson()),
                  const SavedStudyRow(),
                ],
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: AppRoutes.lesson.path,
              name: AppRoutes.lesson.name,
              builder: (_, _) => const Scaffold(body: Text(lessonMark)),
            ),
            GoRoute(
              path: AppRoutes.flashcards.path,
              name: AppRoutes.flashcards.name,
              builder: (_, _) => const Scaffold(body: Text(drillMark)),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentDayProvider.overrideWithValue(dateOnly(today)),
          courseEntitlementProvider.overrideWith((ref) async => hasCourse),
          flashcardDeckSizeProvider.overrideWith((ref) async => 12),
        ],
        child: MediaQuery(
          // From the view: the default `MediaQueryData` carries `size: zero`,
          // which lays the gate sheet out below the viewport.
          data: MediaQueryData.fromView(tester.view),
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('under the cap', () {
    testWidgets('the lesson runs', (tester) async {
      await pump(tester);

      await tester.tap(find.byType(TodayLessonBody));
      await settleLoaders(tester);

      expect(find.text(lessonMark), findsOneWidget);
      expect(find.text(PlusCopy.title), findsNothing);
    });

    testWidgets('the drill deals', (tester) async {
      await pump(tester);

      await tester.tap(find.byType(SavedStudyRow));
      await settleLoaders(tester);

      expect(find.text(drillMark), findsOneWidget);
      expect(find.text(PlusCopy.title), findsNothing);
    });
  });

  group('at the cap, free', () {
    testWidgets('the third lesson start sells instead of running', (
      tester,
    ) async {
      await spend(freeDailyActivities);
      await pump(tester);

      await tester.tap(find.byType(TodayLessonBody));
      await settleLoaders(tester);

      expect(find.text(PlusCopy.title), findsOneWidget);
      // The whole point of the AC: the surface is never reached, so there is
      // nothing behind the sheet to find once it is dismissed.
      expect(find.text(lessonMark), findsNothing);
    });

    testWidgets('the third drill start sells instead of dealing', (
      tester,
    ) async {
      await spend(freeDailyActivities);
      await pump(tester);

      await tester.tap(find.byType(SavedStudyRow));
      await settleLoaders(tester);

      expect(find.text(PlusCopy.title), findsOneWidget);
      expect(find.text(drillMark), findsNothing);
    });

    testWidgets('the sheet says what was hit', (tester) async {
      await spend(freeDailyActivities);
      await pump(tester);

      await tester.tap(find.byType(TodayLessonBody));
      await settleLoaders(tester);

      expect(
        find.text(const DailyAllowanceSpent(cap: freeDailyActivities).header),
        findsOneWidget,
      );
    });
  });

  testWidgets('Plus is not capped', (tester) async {
    await spend(freeDailyActivities * 2);
    await pump(tester, hasCourse: true);

    await tester.tap(find.byType(TodayLessonBody));
    await tester.pumpAndSettle();

    expect(find.text(lessonMark), findsOneWidget);
    expect(find.text(PlusCopy.title), findsNothing);
  });
}
