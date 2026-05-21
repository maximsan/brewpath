import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/features/learn/domain/learn_providers.dart';
import 'package:coffee_quest/features/lessons/presentation/lesson_completion_screen.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  testWidgets(
    'completing a lesson refreshes "Today\'s lesson" to the next lesson',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // A live listener keeps the auto-dispose provider alive across the
      // completion, so the test observes the invalidation triggered by
      // LessonCompletionScreen rather than an unrelated fresh recompute.
      final sub = container.listen(todayLessonProvider, (_, _) {});
      addTearDown(sub.close);

      final before = await tester.runAsync(
        () => container.read(todayLessonProvider.future),
      );
      expect(before?.id, 'lesson_where_coffee');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LessonCompletionScreen(lessonId: 'lesson_where_coffee'),
          ),
        ),
      );
      await settleLoaders(tester);
      expect(find.text('Lesson complete!'), findsOneWidget);

      // The completion invalidated todayLessonProvider, so it now resolves to
      // the next uncompleted lesson instead of the stale finished one.
      final after = await tester.runAsync(
        () => container.read(todayLessonProvider.future),
      );
      expect(after?.id, 'lesson_arabica_robusta');
      expect(after?.id, isNot('lesson_where_coffee'));
    },
  );
}
