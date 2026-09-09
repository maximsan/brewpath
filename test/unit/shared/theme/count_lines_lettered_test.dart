import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_header.dart';
import 'package:brew_path/features/lessons/presentation/reward_points_line.dart';
import 'package:brew_path/features/profile/presentation/widgets/lesson_progress_rollup.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_progress_line.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/mastery_rollup.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The four lines the design letters below the smallcaps rule (#551). Each is a
// number that is the subject of its line, and each sat at whatever its rung set
// until it was told otherwise — nothing at all on the support and body rungs,
// the 0.14em kicker rule on the label rung. Asserted on what is rendered, not
// on the source: a token named in the file says nothing about which line
// took it.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(body: child),
    ),
  );

  /// The letter spacing on the one `Text` matching [text], in logical pixels.
  double letteringOf(WidgetTester tester, String text) {
    final widget = tester.widget<Text>(find.text(text));
    return widget.style!.letterSpacing!;
  }

  /// The design writes tracking in `em`; Flutter wants logical pixels, so a
  /// rung's width is its `em` times the size the rung is set at.
  Matcher lettered(AppTracking tracking, double rungSize) =>
      closeTo(tracking.em * rungSize, 0.0001);

  const bodySize = 15.0;
  const supportSize = 13.0;
  const labelSize = 11.0;

  testWidgets('the points a run paid are lettered as a count', (tester) async {
    await pump(tester, const RewardPointsLine(points: 10));

    expect(
      letteringOf(tester, '+10 PTS'),
      lettered(AppTracking.count, supportSize),
    );
  });

  testWidgets('the ending’s score is lettered as a figure', (tester) async {
    await pump(
      tester,
      const LessonCompletionHeader(
        eyebrow: 'LESSON COMPLETE',
        title: 'What coffee actually is',
        mastery: MasteryResult(correct: 4, total: 5),
      ),
    );

    expect(
      letteringOf(tester, '4 / 5 correct'),
      lettered(AppTracking.figure, bodySize),
    );
  });

  testWidgets('Profile’s lessons and points are lettered as a count', (
    tester,
  ) async {
    await pump(tester, const ProfileProgressLine(lessons: 1, points: 10));

    expect(
      letteringOf(tester, '1 LESSON · 10 POINTS'),
      lettered(AppTracking.count, labelSize),
    );
  });

  testWidgets('Profile’s lessons-done count is lettered as one', (
    tester,
  ) async {
    await pump(
      tester,
      LessonProgressRollup(
        rollup: rollUpMastery(
          const [MasteryResult(correct: 5, total: 5)],
          total: 32,
        ),
        onPractice: () {},
      ),
    );

    expect(
      letteringOf(tester, '1 / 32 DONE'),
      lettered(AppTracking.count, labelSize),
    );
  });

  test('a count sits between a bare figure and a meta line', () {
    expect(AppTracking.count.em, 0.06);
    expect(AppTracking.count.em, greaterThan(AppTracking.figure.em));
    expect(AppTracking.count.em, lessThan(AppTracking.meta.em));
  });
}
