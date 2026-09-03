import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/features/learn/presentation/today_lesson_body.dart';
import 'package:brew_path/features/learn/presentation/today_locked_body.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/features/monetization/domain/free_tier.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_gate_trigger.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/services/payments/granted_payments_service.dart';
import 'package:brew_path/services/payments/payments_provider.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

/// The course wall, asserted against the real app: the real router, the real
/// content banks and the payments stub that ships, which reports no
/// entitlement. So an unmodified boot here *is* a free learner.
///
/// The first lesson past the free set, and the count the locked card pitches,
/// are both read off the shipped bank rather than written down — authoring a
/// lesson must change what these tests assert, not quietly stop them
/// asserting it.
void main() {
  setUp(useInMemoryDatabase);

  /// Tall enough that the lead card is built without scrolling.
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Walks the learner to the end of what free carries.
  Future<void> finishTheFreeLessons() async {
    final progress = ProgressRepository();
    for (final lessonId in freeLessonIds) {
      await progress.saveCompletion(
        lessonId: lessonId,
        xpEarned: 10,
        mastery: const MasteryResult(correct: 5, total: 5),
      );
    }
  }

  /// What the locked card counts once the free set is finished: every lesson
  /// still ahead, course-wide.
  const ahead = 29;

  /// The first lesson the free tier does not carry, in course order.
  const firstPaidLesson = 'm1l4';
  const firstPaidTitle = 'Why altitude matters';

  /// Standing where a paying learner stands, through the seam rather than
  /// round it: the store says the course is owned and nothing else changes.
  ProviderContainer owningTheCourse() => ProviderContainer(
    overrides: [
      paymentsServiceProvider.overrideWith(
        (ref) => const GrantedPaymentsService(),
      ),
    ],
  );

  group('the bank these tests read', () {
    test('still says what the three constants above claim', () async {
      // The guard on every expectation below. Authoring a lesson, or growing
      // the free set, must fail here loudly rather than quietly leave the
      // wall tests asserting about a course that has moved on.
      final lessons = await ContentRepository().getLessons();
      final paid = lessons.where((lesson) => !isLessonFree(lesson.id));

      expect(paid.first.id, firstPaidLesson);
      expect(paid.first.title, firstPaidTitle);
      // Ahead of a learner who has finished exactly the free set.
      expect(paid.length, ahead);
    });
  });

  group('Today past the free lessons', () {
    testWidgets('sells the locked lesson instead of offering it', (
      tester,
    ) async {
      useTallViewport(tester);
      await finishTheFreeLessons();

      await pumpWithProviders(tester, const BrewPathApp());

      // The eyebrow over the card still names the state of the day; the wall
      // is stated inside it.
      expect(find.text(AppLabels.continueLearning.toUpperCase()), findsWidgets);
      expect(find.byType(TodayLockedBody), findsOneWidget);
      expect(find.text(firstPaidTitle), findsWidgets);
      expect(find.text(LockedRowCopy.continuesInFoundations), findsOneWidget);
      expect(
        find.text(LockedRowCopy.lessonsAhead(ahead).toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(LockedRowCopy.unlockFoundations), findsOneWidget);
    });

    testWidgets('raises the offer rather than the player', (tester) async {
      useTallViewport(tester);
      await finishTheFreeLessons();

      await pumpWithProviders(tester, const BrewPathApp());
      await tester.tap(find.text(LockedRowCopy.unlockFoundations));
      await settleLoaders(tester);

      expect(find.text(PlusCopy.title), findsOneWidget);
      expect(find.byType(LessonScreen), findsNothing);
    });

    testWidgets('is the plain lesson card once the course is owned', (
      tester,
    ) async {
      useTallViewport(tester);
      await finishTheFreeLessons();

      await pumpWithProviders(
        tester,
        const BrewPathApp(),
        container: owningTheCourse(),
      );

      expect(find.byType(TodayLessonBody), findsOneWidget);
      expect(find.byType(TodayLockedBody), findsNothing);
      expect(find.text(LockedRowCopy.continuesInFoundations), findsNothing);
      expect(find.text('Start'), findsOneWidget);
    });
  });

  group('the router is the backstop', () {
    testWidgets('a locked lesson opens the offer, never the player', (
      tester,
    ) async {
      // The route, not a row: this is the way round every surface — a deep
      // link, or any caller that navigates without asking first.
      useTallViewport(tester);
      final container = await pumpWithProviders(tester, const BrewPathApp());

      container.read(appRouterProvider).go('/learn/lesson/$firstPaidLesson');
      await settleLoaders(tester);

      expect(find.byType(LessonScreen), findsNothing);
      expect(find.text(PlusCopy.title), findsOneWidget);
      // And it names the lesson that was asked for, so the pitch answers the
      // question the learner actually asked.
      expect(
        find.text(const LockedLesson(title: firstPaidTitle).header),
        findsOneWidget,
      );
    });

    testWidgets('a free lesson opens', (tester) async {
      useTallViewport(tester);
      final container = await pumpWithProviders(tester, const BrewPathApp());

      container.read(appRouterProvider).go('/learn/lesson/${freeLessonIds[1]}');
      await settleLoaders(tester);

      expect(find.byType(LessonScreen), findsOneWidget);
      expect(find.text(PlusCopy.title), findsNothing);
    });

    testWidgets('owning the course opens the locked one too', (tester) async {
      useTallViewport(tester);
      final container = await pumpWithProviders(
        tester,
        const BrewPathApp(),
        container: owningTheCourse(),
      );

      container.read(appRouterProvider).go('/learn/lesson/$firstPaidLesson');
      await settleLoaders(tester);

      expect(find.byType(LessonScreen), findsOneWidget);
      expect(find.text(PlusCopy.title), findsNothing);
    });
  });
}
