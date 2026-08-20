import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/content_fixtures.dart';

/// A lesson plays its cards and ends at completion — with no dead end in the
/// middle, whatever the course happens to author.
class _FakeContent extends ContentRepository {
  _FakeContent(this._lesson);

  final LessonModel _lesson;

  @override
  Future<LessonModel?> getLessonById(String id) async =>
      id == _lesson.id ? _lesson : null;
}

void main() {
  /// The completion route's query, captured so a test can assert the graded
  /// pair the run reported.
  late Map<String, String> completedWith;

  Future<void> pumpLesson(WidgetTester tester, LessonModel lesson) async {
    completedWith = {};
    final router = GoRouter(
      initialLocation: '/learn/lesson/${lesson.id}',
      routes: [
        GoRoute(
          path: '/learn/lesson/:lessonId',
          name: AppRoutes.lesson.name,
          builder: (context, state) =>
              LessonScreen(lessonId: state.pathParameters['lessonId']!),
        ),
        GoRoute(
          path: '/learn/lesson/:lessonId/complete',
          name: AppRoutes.lessonComplete.name,
          builder: (context, state) {
            completedWith = state.uri.queryParameters;
            return const Scaffold(body: Text('Completion screen'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contentRepositoryProvider.overrideWith((ref) => _FakeContent(lesson)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
  }

  /// Advances past a card by tapping whatever moves it on.
  Future<void> advance(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('shows the module label, the title and the run position', (
    tester,
  ) async {
    await pumpLesson(tester, testLesson());

    expect(find.text('MODULE 1 · BEANS'), findsOneWidget);
    expect(find.text('What coffee actually is'), findsOneWidget);
    expect(find.text('Step 1 of 2'), findsOneWidget);
  });

  testWidgets('plays every card and ends at the completion screen', (
    tester,
  ) async {
    await pumpLesson(tester, testLesson());

    // Card 1 — the concept card, ungraded.
    await advance(tester, 'Continue');
    expect(find.text('Step 2 of 2'), findsOneWidget);

    // Card 2 — the graded one. Answer, then move on.
    await advance(tester, 'A seed');
    await advance(tester, 'Continue');

    expect(find.text('Completion screen'), findsOneWidget);
  });

  testWidgets('reports the graded pair, not the card count', (tester) async {
    await pumpLesson(tester, testLesson());

    await advance(tester, 'Continue');
    await advance(tester, 'A seed');
    await advance(tester, 'Continue');

    // Two cards, one of them graded and answered right. Counting the concept
    // card would cap the run below full marks for having been taught.
    expect(completedWith['correct'], '1');
    expect(completedWith['total'], '1');
  });

  testWidgets('skips a card no renderer can draw rather than dead-ending', (
    tester,
  ) async {
    await pumpLesson(
      tester,
      testLesson(
        cards: [testConceptCard(), testUnplayableCard(), testMcqCard()],
      ),
    );

    // Three authored, two playable — and the run reaches the end.
    expect(find.text('Step 1 of 2'), findsOneWidget);
    await advance(tester, 'Continue');
    await advance(tester, 'A seed');
    await advance(tester, 'Continue');

    expect(find.text('Completion screen'), findsOneWidget);
  });

  testWidgets('says so when a lesson has nothing it can draw', (tester) async {
    await pumpLesson(tester, testLesson(cards: [testUnplayableCard()]));

    expect(find.text('This lesson cannot be played yet.'), findsOneWidget);
  });

  testWidgets('says so when the lesson does not exist', (tester) async {
    completedWith = {};
    final router = GoRouter(
      initialLocation: '/learn/lesson/nope',
      routes: [
        GoRoute(
          path: '/learn/lesson/:lessonId',
          name: AppRoutes.lesson.name,
          builder: (context, state) =>
              LessonScreen(lessonId: state.pathParameters['lessonId']!),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contentRepositoryProvider.overrideWith(
            (ref) => _FakeContent(testLesson()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('Lesson not found'), findsOneWidget);
  });
}
