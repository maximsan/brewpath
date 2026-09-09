import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/dictionary/presentation/category_index.dart';
import 'package:brew_path/features/lessons/presentation/lesson_completion_header.dart';
import 'package:brew_path/features/lessons/presentation/reward_points_line.dart';
import 'package:brew_path/features/profile/presentation/widgets/lesson_progress_rollup.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_progress_line.dart';
import 'package:brew_path/features/profile/presentation/widgets/tree_hero_card.dart';
import 'package:brew_path/features/progress/domain/grove_treatment.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/mastery_rollup.dart';
import 'package:brew_path/features/progress/presentation/tree_progress_bar.dart';
import 'package:brew_path/shared/models/content/dictionary_category.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The count lines the design letters below the smallcaps rule, each at its own
// width rather than at one shared step — 0.06em through 0.12em. Every one sat
// at whatever its rung set until it was told otherwise. Asserted on what is
// rendered, not on the source: a token named in a file says nothing about
// which line took it. The challenge row and the dictionary count are asserted
// the same way in their own suites, where their harnesses already live.
const _beans = DictionaryCategory(
  id: 'beans',
  label: 'Beans and Botany',
  glyph: 'cherry',
  summary: 'The plant, the seed, where it grows.',
);
const _arabica = DictionaryTerm(
  id: 'arabica',
  term: 'Arabica',
  categoryId: 'beans',
  shortExplanation: 'The species behind most specialty coffee.',
  lessonId: 'm1l2',
);
const _robusta = DictionaryTerm(
  id: 'robusta',
  term: 'Robusta',
  categoryId: 'beans',
  shortExplanation: 'The backbone of instant coffee.',
  lessonId: 'm1l2',
);

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

  testWidgets('a run’s position counter is lettered as a hint', (tester) async {
    await pump(
      tester,
      const RoastMeter(position: 3, total: 8, semanticsLabel: 'Card 3 of 8'),
    );

    expect(
      letteringOf(tester, '03 / 08'),
      lettered(AppTracking.hint, labelSize),
    );
  });

  testWidgets('the core-lessons count is lettered as a meta line', (
    tester,
  ) async {
    await pump(
      tester,
      const TreeProgressBar(completed: 5, total: 32, nextStageName: 'Sapling'),
    );

    expect(
      letteringOf(tester, '5 / 32'),
      lettered(AppTracking.meta, labelSize),
    );
  });

  testWidgets('the stage still to come is lettered as a tag, in mono', (
    tester,
  ) async {
    await pump(
      tester,
      const TreeProgressBar(completed: 5, total: 32, nextStageName: 'Sapling'),
    );

    final line = tester.widget<Text>(find.text('NEXT · SAPLING'));
    expect(line.style!.letterSpacing, lettered(AppTracking.tag, labelSize));
    expect(
      line.style!.fontFamily,
      AppText.label(face: AppFace.mono).fontFamily,
    );
  });

  testWidgets('the tree hero’s count is lettered as a tag', (tester) async {
    await pump(
      tester,
      TreeHeroCard(
        stage: 1,
        treatment: GroveTreatment.identity,
        completed: 5,
        total: 32,
        onTap: () {},
      ),
    );

    expect(
      letteringOf(tester, '5 / 32 CORE LESSONS'),
      lettered(AppTracking.tag, labelSize),
    );
  });

  testWidgets('a dictionary category’s term count is lettered as one', (
    tester,
  ) async {
    await pump(
      tester,
      CategoryIndex(
        categories: const [_beans],
        terms: const [_arabica, _robusta],
        onOpen: (_) {},
      ),
    );

    expect(letteringOf(tester, '2'), lettered(AppTracking.count, labelSize));
  });

  test('a count sits between a bare figure and a meta line', () {
    expect(AppTracking.count.em, 0.06);
    expect(AppTracking.count.em, greaterThan(AppTracking.figure.em));
    expect(AppTracking.count.em, lessThan(AppTracking.meta.em));
  });
}
