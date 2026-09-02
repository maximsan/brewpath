import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/bean_gauge.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/presentation/path_lesson_row.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

final LessonModel _lesson = testLesson(title: 'Where coffee grows');

const _pitch = PlusPitch(
  remainingLessons: 29,
  lockedGames: 4,
  referenceTerms: 8,
  savedFreeCap: 5,
);

Future<void> _pump(
  WidgetTester tester, {
  required bool isCompleted,
  required bool isCurrent,
  MasteryResult mastery = MasteryResult.unscored,
  bool isLast = false,
  bool isPurchaseLocked = false,
}) => tester.pumpWidget(
  ProviderScope(
    // A counted pitch, so tapping the lock does not wait on the banks.
    overrides: [plusPitchProvider.overrideWith((ref) async => _pitch)],
    child: MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(
        body: PathLessonRow(
          entry: PathLesson(
            lesson: _lesson,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isPurchaseLocked: isPurchaseLocked,
            mastery: mastery,
          ),
          isLast: isLast,
        ),
      ),
    ),
  ),
);

BeanGauge _bean(WidgetTester tester) =>
    tester.widget<BeanGauge>(find.byType(BeanGauge));

void main() {
  test('the four arms are distinct', () {
    // Sanity guard for the table below: the mood tokens the arms map to must
    // not collide, or the tests could pass on a coincidence.
    const mood = MoodColors.darkRoast;
    expect({mood.inkMute, mood.accent, mood.sage}, hasLength(3));
  });

  testWidgets('complete and scored fills to the ratio in sage', (tester) async {
    await _pump(
      tester,
      isCompleted: true,
      isCurrent: false,
      mastery: const MasteryResult(correct: 4, total: 5),
    );

    expect(_bean(tester).fill, 0.8);
    expect(_bean(tester).color, MoodColors.darkRoast.sage);
  });

  testWidgets('complete but unscored is a muted empty bean', (tester) async {
    // The deliberately neutral arm — never a full sage one.
    await _pump(tester, isCompleted: true, isCurrent: false);

    expect(_bean(tester).fill, 0);
    expect(_bean(tester).color, MoodColors.darkRoast.inkMute);
  });

  testWidgets('needs-practice takes the accent', (tester) async {
    await _pump(
      tester,
      isCompleted: true,
      isCurrent: false,
      mastery: const MasteryResult(correct: 3, total: 5),
    );

    expect(_bean(tester).color, MoodColors.darkRoast.accent);
  });

  testWidgets('an unplayed current lesson shows the 45% nudge', (tester) async {
    await _pump(tester, isCompleted: false, isCurrent: true);

    expect(_bean(tester).fill, 0.45);
    expect(_bean(tester).color, MoodColors.darkRoast.accent);
  });

  testWidgets('an upcoming lesson is an empty sage bean', (tester) async {
    await _pump(tester, isCompleted: false, isCurrent: false);

    expect(_bean(tester).fill, 0);
    expect(_bean(tester).color, MoodColors.darkRoast.sage);
  });

  testWidgets('the node sits on the page canvas, not the card surface', (
    tester,
  ) async {
    await _pump(tester, isCompleted: true, isCurrent: false);

    final well = tester.widget<Container>(
      find
          .ancestor(
            of: find.byType(BeanGauge),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = well.decoration! as BoxDecoration;

    expect(decoration.color, MoodColors.darkRoast.bg);
    expect(decoration.shape, BoxShape.circle);
  });

  testWidgets('the current lesson tints its own well', (tester) async {
    // `.lesson-row.current .path-node` is the accent at 7% *over* the page,
    // not the page. It stays opaque either way — a translucent disc would let
    // the spine show through the stop it exists to punch.
    await _pump(tester, isCompleted: false, isCurrent: true);

    final well = tester.widget<Container>(
      find
          .ancestor(
            of: find.byType(BeanGauge),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = well.decoration! as BoxDecoration;

    expect(decoration.color, isNot(MoodColors.darkRoast.bg));
    expect(decoration.color!.a, 1.0);
  });

  testWidgets('the row carries no Review button', (tester) async {
    // The design's `.lesson-row` has no button in it: the whole row opens the
    // lesson, and a finished one is replayed the same way it was played.
    // `Review` belonged to the module screen, which is gone (#394, #435).
    await _pump(tester, isCompleted: true, isCurrent: false);

    expect(find.text('Review'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('a lesson needing practice says so, once', (tester) async {
    await _pump(
      tester,
      isCompleted: true,
      isCurrent: false,
      mastery: const MasteryResult(correct: 1, total: 4),
    );

    expect(find.text('PRACTICE'), findsOneWidget);
  });

  testWidgets('a lesson that went well says nothing', (tester) async {
    await _pump(
      tester,
      isCompleted: true,
      isCurrent: false,
      mastery: const MasteryResult(correct: 4, total: 4),
    );

    // The bean's fill is the report; a second label would repeat it.
    expect(find.text('PERFECT'), findsNothing);
    expect(find.text('SOLID'), findsNothing);
  });

  testWidgets('the current lesson is named as current', (tester) async {
    await _pump(tester, isCompleted: false, isCurrent: true);

    expect(find.text(AppLabels.currentLesson.toUpperCase()), findsOneWidget);
  });

  group('the purchase lock', () {
    testWidgets("draws one mark, in the row's own trailing slot", (
      tester,
    ) async {
      await _pump(
        tester,
        isCompleted: false,
        isCurrent: false,
        isPurchaseLocked: true,
      );

      // Exactly one — the spine beside it carries no lock of its own, which is
      // the whole of #91's part 1.
      final locks = find.byWidgetPredicate(
        (widget) => widget is IconMark && widget.icon == AppIcon.lock,
      );
      expect(locks, findsOneWidget);
      expect(
        tester.widget<IconMark>(locks).color,
        MoodColors.darkRoast.accent,
        reason: 'accent, not ink-mute: buying is something to do',
      );
    });

    testWidgets('fades the whole row rather than the mark alone', (
      tester,
    ) async {
      await _pump(
        tester,
        isCompleted: false,
        isCurrent: false,
        isPurchaseLocked: true,
      );

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(PathLessonRow),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.4);
    });

    testWidgets('announces the state and its reason', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        isCompleted: false,
        isCurrent: false,
        isPurchaseLocked: true,
      );

      expect(
        find.bySemanticsLabel(
          LockedRowCopy.purchaseLockedSemantics(_lesson.title),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('raises the offer instead of opening the lesson', (
      tester,
    ) async {
      await _pump(
        tester,
        isCompleted: false,
        isCurrent: false,
        isPurchaseLocked: true,
      );

      await tester.tap(find.byType(PathLessonRow));
      await tester.pumpAndSettle();

      // The sheet, not a route: the row is the visible edge of the purchase.
      expect(find.text(PlusCopy.title), findsOneWidget);
    });

    testWidgets('the next lesson in order stops reading as current', (
      tester,
    ) async {
      // It genuinely is next, and the design still drops the eyebrow and the
      // wash: pointing at a step nobody can take is not guidance.
      await _pump(
        tester,
        isCompleted: false,
        isCurrent: true,
        isPurchaseLocked: true,
      );

      expect(find.text(AppLabels.currentLesson.toUpperCase()), findsNothing);

      // The bean still fills as current — it marks where the learner got to.
      expect(_bean(tester).color, MoodColors.darkRoast.accent);
    });

    testWidgets('an unlocked row carries no lock at all', (tester) async {
      await _pump(tester, isCompleted: false, isCurrent: false);

      expect(
        find.byWidgetPredicate(
          (widget) => widget is IconMark && widget.icon == AppIcon.lock,
        ),
        findsNothing,
      );
    });
  });
}
