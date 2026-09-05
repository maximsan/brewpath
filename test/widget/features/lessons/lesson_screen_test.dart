import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/features/saved/presentation/saved_bookmark_button.dart';
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

  testWidgets('shows the run position, and nothing else above the card', (
    tester,
  ) async {
    // "The card is the screen": the design's player carries no lesson title
    // and no module eyebrow, only close, position and save
    // (`prototype/lesson.jsx:188`). Both were printed above every card until
    // #395.
    await pumpLesson(tester, testLesson());

    expect(find.text('01 / 02'), findsOneWidget);
    expect(find.text('MODULE 1 · BEANS'), findsNothing);
    expect(find.text('What coffee actually is'), findsNothing);
  });

  testWidgets('leaves by a close mark, not a back arrow', (tester) async {
    // A player is a surface you exit, not a page you came from.
    await pumpLesson(tester, testLesson());

    Finder markInBar(AppIcon icon) => find.descendant(
      of: find.byType(AppBar),
      matching: find.byWidgetPredicate(
        (widget) => widget is IconMark && widget.icon == icon,
      ),
    );

    expect(markInBar(AppIcon.close), findsOneWidget);
    expect(markInBar(AppIcon.back), findsNothing);
  });

  testWidgets('keeps the save control in the bar beside the position', (
    tester,
  ) async {
    // The design bookmarks a lesson while it is being read; removing the
    // title must not take the control that sat beside it.
    await pumpLesson(tester, testLesson());

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(SavedBookmarkButton),
      ),
      findsOneWidget,
    );
  });

  testWidgets('reports position without ever reporting a score', (
    tester,
  ) async {
    await pumpLesson(tester, testLesson());

    // The header says where the learner is. How well they did belongs to the
    // completion screen — a percentage or a filling bar here would be read as
    // a mark on the run in progress.
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('plays every card and ends at the completion screen', (
    tester,
  ) async {
    await pumpLesson(tester, testLesson());

    // Card 1 — the concept card, ungraded.
    await advance(tester, 'Continue');
    expect(find.text('02 / 02'), findsOneWidget);

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

  // A test that fed this lesson an undrawable card stood here. It cannot be
  // written any more: every kind draws as of #124, and #418 removed the filter
  // that used to leave the others out — a card this build cannot draw is now
  // something the app will not compile with, rather than something a test has
  // to catch.

  testWidgets('says so when a lesson has no cards', (tester) async {
    await pumpLesson(tester, testLesson(cards: []));

    expect(find.text('This lesson has no cards.'), findsOneWidget);
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
