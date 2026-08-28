import 'dart:ui' show Tristate;

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/content_fixtures.dart';
import '../../../support/find_mark.dart';
import '../../../support/widget_harness.dart';

/// Serves one lesson, so the player has something to open.
class _OneLesson extends ContentRepository {
  _OneLesson(this._lesson);

  final LessonModel _lesson;

  @override
  Future<LessonModel?> getLessonById(String id) async =>
      id == _lesson.id ? _lesson : null;
}

void main() {
  setUp(useInMemoryDatabase);

  final lesson = testLesson();

  Future<ProviderContainer> pumpLesson(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/learn/lesson/${lesson.id}',
      routes: [
        GoRoute(
          path: '/learn/lesson/:lessonId',
          name: AppRoutes.lesson.name,
          builder: (context, state) =>
              LessonScreen(lessonId: state.pathParameters['lessonId']!),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        contentRepositoryProvider.overrideWithValue(_OneLesson(lesson)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.cupping,
          routerConfig: router,
        ),
      ),
    );
    await settleLoaders(tester);
    return container;
  }

  testWidgets('the player carries a bookmark for the lesson being read', (
    tester,
  ) async {
    await pumpLesson(tester);

    expect(
      find.byTooltip('Save ${lesson.title}'),
      findsOneWidget,
      reason: 'a lesson is bookmarked while it is read, not off a list after',
    );
  });

  testWidgets('bookmarking writes the lesson key', (tester) async {
    final container = await pumpLesson(tester);

    await tester.tap(findMark(AppIcon.bookmark, active: false));
    await settleLoaders(tester);

    expect(await container.read(savedKeysProvider.future), {'l:${lesson.id}'});
  });

  testWidgets('the bookmark announces its state', (tester) async {
    await pumpLesson(tester);
    final button = find.ancestor(
      of: findMark(AppIcon.bookmark, active: false),
      matching: find.byType(IconButton),
    );

    expect(
      tester.getSemantics(button).flagsCollection.isSelected,
      Tristate.isFalse,
    );

    await tester.tap(button);
    await settleLoaders(tester);

    expect(
      tester
          .getSemantics(
            find.ancestor(
              of: findMark(AppIcon.bookmark, active: true),
              matching: find.byType(IconButton),
            ),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
  });

  testWidgets('tapping again takes it off', (tester) async {
    final container = await pumpLesson(tester);

    await tester.tap(findMark(AppIcon.bookmark, active: false));
    await settleLoaders(tester);
    await tester.tap(findMark(AppIcon.bookmark, active: true));
    await settleLoaders(tester);

    expect(await container.read(savedKeysProvider.future), isEmpty);
  });
}
