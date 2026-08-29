import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/profile/presentation/widgets/lesson_progress_rollup.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/mastery_rollup.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The rollup card against results it can actually be handed. The fold itself
/// is `mastery_rollup_test.dart`'s; what this pins is what the card says.
void main() {
  const mood = MoodColors.darkRoast;

  Future<void> pumpRollup(
    WidgetTester tester, {
    required List<MasteryResult> results,
    required int total,
    VoidCallback? onPractice,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkRoast,
        home: Scaffold(
          body: LessonProgressRollup(
            rollup: rollUpMastery(results, total: total),
            onPractice: onPractice ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('names the counts the design puts in its legend', (tester) async {
    await pumpRollup(
      tester,
      results: const [
        MasteryResult(correct: 5, total: 5),
        MasteryResult(correct: 4, total: 5),
        MasteryResult(correct: 3, total: 5),
      ],
      total: 10,
    );

    expect(find.text('LESSON PROGRESS'), findsOneWidget);
    expect(find.text('3 / 10 DONE'), findsOneWidget);
    expect(find.text('2 solid'), findsOneWidget);
    expect(find.text('1 need practice'), findsOneWidget);
  });

  testWidgets('a perfect run is solid, not a third state', (tester) async {
    await pumpRollup(
      tester,
      results: const [MasteryResult(correct: 5, total: 5)],
      total: 4,
    );

    expect(find.text('1 solid'), findsOneWidget);
    expect(find.text('0 need practice'), findsOneWidget);
  });

  testWidgets('the muted zero still shows, so the pair stays a pair', (
    tester,
  ) async {
    await pumpRollup(
      tester,
      results: const [MasteryResult(correct: 5, total: 5)],
      total: 4,
    );

    final zero = tester.widget<Text>(find.text('0 need practice'));

    expect(
      zero.style?.color,
      mood.inkMute,
      reason: 'nothing to practise is quiet, not absent',
    );
  });

  testWidgets('taps through to practice', (tester) async {
    var practised = false;
    await pumpRollup(
      tester,
      results: const [MasteryResult(correct: 3, total: 5)],
      total: 4,
      onPractice: () => practised = true,
    );

    await tester.tap(find.byType(LessonProgressRollup));

    expect(practised, isTrue);
  });

  testWidgets('survives a narrow phone without overflowing', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRollup(
      tester,
      results: const [
        MasteryResult(correct: 5, total: 5),
        MasteryResult(correct: 1, total: 5),
      ],
      total: 32,
    );

    expect(tester.takeException(), isNull);
  });
}
