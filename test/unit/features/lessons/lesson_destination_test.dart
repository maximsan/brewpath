// Every lesson destination, resolved against the real route table.
//
// Each case asserts the **exact URL the hand-written string used to produce**.
// That equality is the whole point: this module replaced four literals, and a
// destination that resolves anywhere else is a silent navigation regression,
// which is precisely what a string literal never told us about.
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/domain/lesson_destination.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// A router with the same shape and names as the app's, so `namedLocation`
/// resolves exactly as it does in production. Builders are stubs — nothing
/// here renders; only the paths matter.
GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.learn.path,
      name: AppRoutes.learn.name,
      builder: (_, _) => const SizedBox.shrink(),
      routes: [
        GoRoute(
          path: AppRoutes.lesson.path,
          name: AppRoutes.lesson.name,
          builder: (_, _) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: AppRoutes.lessonComplete.path,
              name: AppRoutes.lessonComplete.name,
              builder: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.practiceLesson.path,
          name: AppRoutes.practiceLesson.name,
          builder: (_, _) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.moduleSummary.path,
          name: AppRoutes.moduleSummary.name,
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    ),
  ],
);

void main() {
  final router = buildRouter();

  String locationOf(RouteDestination destination) => router.namedLocation(
    destination.name,
    pathParameters: destination.pathParams,
    queryParameters: destination.queryParams,
  );

  group('each destination resolves to the URL it replaced', () {
    test('starting a lesson', () {
      expect(locationOf(lessonStart('m1l1')), '/learn/lesson/m1l1');
    });

    test('replaying a finished lesson', () {
      expect(
        locationOf(lessonReplay('m1l1')),
        '/learn/lesson/m1l1?review=true',
      );
    });

    test('a run that records nothing', () {
      expect(
        locationOf(lessonPractice('m1l1')),
        '/learn/practice/lesson/m1l1',
      );
    });

    test('the completion screen carries the mode and the graded pair', () {
      expect(
        locationOf(
          lessonCompletion(
            'm1l1',
            review: false,
            practice: false,
            correct: 4,
            total: 5,
          ),
        ),
        '/learn/lesson/m1l1/complete'
        '?review=false&practice=false&correct=4&total=5',
      );
    });

    test('the module recap', () {
      expect(
        locationOf(moduleSummary('module_beans')),
        '/learn/module-summary/module_beans',
      );
    });

    test('the Learn tab', () {
      expect(locationOf(learnTab), '/learn');
    });
  });

  group('the graded pair survives the trip', () {
    test('a perfect run and a scraped pass are told apart', () {
      // `{4,5}` and `{18,20}` both read 80%; only the pair carries the wrong
      // count the mastery band derives from.
      expect(
        locationOf(
          lessonCompletion(
            'm1l1',
            review: false,
            practice: false,
            correct: 18,
            total: 20,
          ),
        ),
        contains('correct=18&total=20'),
      );
    });

    test('a replay says so, and a practice run says so', () {
      expect(
        locationOf(
          lessonCompletion(
            'm1l1',
            review: true,
            practice: false,
            correct: 1,
            total: 1,
          ),
        ),
        contains('review=true&practice=false'),
      );
    });
  });

  group('the value itself', () {
    test('two destinations for the same route and lesson are equal', () {
      expect(lessonReplay('m1l1'), lessonReplay('m1l1'));
      expect(lessonReplay('m1l1').hashCode, lessonReplay('m1l1').hashCode);
    });

    test('a replay is not the same destination as a fresh start', () {
      expect(lessonReplay('m1l1'), isNot(lessonStart('m1l1')));
    });

    test('the lesson id is part of the identity', () {
      expect(lessonStart('m1l1'), isNot(lessonStart('m1l2')));
    });

    test('no destination names a path', () {
      // The failure this module exists to prevent: a route renamed in
      // `AppRoutes` while a caller keeps sending learners to the old URL.
      for (final destination in [
        lessonStart('m1l1'),
        lessonReplay('m1l1'),
        lessonPractice('m1l1'),
        moduleSummary('m1'),
        learnTab,
      ]) {
        expect(destination.name, isNot(contains('/')));
      }
    });
  });
}
