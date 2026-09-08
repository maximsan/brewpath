import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/learn/presentation/module_art_banner.dart';
import 'package:brew_path/features/learn/presentation/today_card_widget.dart';
import 'package:brew_path/features/learn/presentation/today_lesson_body.dart';
import 'package:brew_path/features/learn/presentation/today_locked_body.dart';
import 'package:brew_path/features/monetization/domain/locked_row_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/features/monetization/domain/plus_pitch_provider.dart';
import 'package:brew_path/shared/models/lesson_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/content_fixtures.dart';

final LessonModel _lesson = testLesson(
  id: 'm1l4',
  title: 'Why altitude matters',
);

/// Seven lessons, the fixture lesson fourth among them.
const List<String> _moduleLessons = [
  'm1l1',
  'm1l2',
  'm1l3',
  'm1l4',
  'm1l5',
  'm1l6',
  'm1l7',
];

/// The lesson's module, illustrated — the picture the bank names for Beans.
final ModuleModel _module = testModule(
  lessonIds: _moduleLessons,
  art: 'assets/modules/m1-beans.png',
  artPos: '50% 42%',
);

/// The wall's eyebrow as it is lettered: smallcaps, so uppercase.
final String _wallEyebrow = LockedRowCopy.continuesInFoundations.toUpperCase();

const _pitch = PlusPitch(
  remainingLessons: 29,
  lockedGames: 4,
  referenceTerms: 8,
  savedFreeCap: 5,
);

const int _ahead = 29;

Future<void> _pump(
  WidgetTester tester, {
  required bool isLocked,
  int? lessonsAhead = _ahead,
  ModuleModel? module,
}) => tester.pumpWidget(
  ProviderScope(
    // A counted pitch, so tapping the card does not wait on the banks.
    overrides: [plusPitchProvider.overrideWith((ref) async => _pitch)],
    child: MaterialApp(
      theme: AppTheme.darkRoast,
      home: Scaffold(
        body: TodayCardWidget(
          today: _lesson,
          module: module,
          isLocked: isLocked,
          lessonsAhead: lessonsAhead,
        ),
      ),
    ),
  ),
);

Finder _lockMarks() => find.byWidgetPredicate(
  (widget) => widget is IconMark && widget.icon == AppIcon.lock,
);

void main() {
  group('the day is the learner’s to open', () {
    testWidgets('the card is the ordinary lesson card', (tester) async {
      await _pump(tester, isLocked: false);

      expect(find.byType(TodayLessonBody), findsOneWidget);
      // The eyebrow is the module, as the design prints it.
      expect(find.text(_lesson.moduleLabel), findsOneWidget);
      expect(find.text(AppLabels.beginLesson), findsOneWidget);
      expect(_lockMarks(), findsNothing);
      expect(find.text(LockedRowCopy.unlockFoundations), findsNothing);
    });

    testWidgets('without its module it has no picture and no position', (
      tester,
    ) async {
      // Nothing rather than something wrong: the modules resolve on their
      // own schedule, and the card does not wait for them.
      await _pump(tester, isLocked: false);

      expect(find.byType(Image), findsNothing);
      expect(find.textContaining('LESSON '), findsNothing);
    });

    testWidgets('with its module it carries the picture and the position', (
      tester,
    ) async {
      await _pump(tester, isLocked: false, module: _module);

      expect(find.byType(ModuleArtBanner), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      // Fourth of seven, three minutes: the design's one mono line.
      expect(find.text('LESSON 4/7 · ~3 MIN'), findsOneWidget);
    });

    testWidgets('the position is read as a sentence', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, isLocked: false, module: _module);

      expect(
        find.bySemanticsLabel('Lesson 4 of 7, about 3 minutes'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('${AppLabels.beginLesson}: ${_lesson.title}'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a module without a picture draws no frame for one', (
      tester,
    ) async {
      await _pump(
        tester,
        isLocked: false,
        module: testModule(lessonIds: _moduleLessons),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.text('LESSON 4/7 · ~3 MIN'), findsOneWidget);
    });
  });

  group('the day is behind the purchase', () {
    testWidgets('the lesson is shown, not hidden', (tester) async {
      // Hiding it would leave the day's lead card either empty or pointing at
      // work the learner has already done.
      await _pump(tester, isLocked: true);

      expect(find.byType(TodayLockedBody), findsOneWidget);
      expect(find.text(_lesson.title), findsOneWidget);
    });

    testWidgets('the eyebrow is the wall', (tester) async {
      await _pump(tester, isLocked: true);

      expect(find.text(_wallEyebrow), findsOneWidget);
      // The module number the unlocked card prints is gone: the eyebrow has
      // replaced it, and two statements of place would say it twice.
      expect(find.text(_lesson.moduleLabel), findsNothing);
    });

    testWidgets('one lock, and it is on the action', (tester) async {
      // The design draws a single mark, on the button. The eyebrow says the
      // same thing in words, so a second lock there would state it twice —
      // which is the rule ADR-0016 keeps a row to.
      await _pump(tester, isLocked: true);

      expect(_lockMarks(), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: _lockMarks(),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the count is what buying opens', (tester) async {
      await _pump(tester, isLocked: true);

      expect(
        find.text(LockedRowCopy.lessonsAhead(_ahead).toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('the action says what it costs, never Begin', (tester) async {
      // The button must never read Begin and then raise a wall.
      await _pump(tester, isLocked: true);

      expect(find.text(LockedRowCopy.unlockFoundations), findsOneWidget);
      expect(find.text(AppLabels.beginLesson), findsNothing);
    });

    testWidgets('the wall keeps the module picture', (tester) async {
      // The same card, saying something else: the picture is the module's,
      // and the module has not changed.
      await _pump(tester, isLocked: true, module: _module);

      expect(find.byType(ModuleArtBanner), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('the lock and its reason are announced', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, isLocked: true);

      expect(
        find.bySemanticsLabel(LockedRowCopy.continuesInFoundations),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(LockedRowCopy.lessonsAheadSemantics(_ahead)),
        findsOneWidget,
      );
      // The action is the one thing there is to activate, so it names the
      // lesson it would open rather than leaving that to the title above.
      expect(
        find.bySemanticsLabel(LockedRowCopy.unlockToContinue(_lesson.title)),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('an uncounted card says nothing rather than zero', (
      tester,
    ) async {
      // `0 LESSONS AHEAD` on a card whose whole point is how much course is
      // left is the wrong half of a flash to show.
      await _pump(tester, isLocked: true, lessonsAhead: null);

      expect(find.textContaining('AHEAD'), findsNothing);
      // Everything that does not depend on the count still stands.
      expect(find.text(_wallEyebrow), findsOneWidget);
      expect(find.text(LockedRowCopy.unlockFoundations), findsOneWidget);
    });

    testWidgets('the action raises the offer', (tester) async {
      await _pump(tester, isLocked: true);

      await tester.tap(find.text(LockedRowCopy.unlockFoundations));
      await tester.pumpAndSettle();

      expect(find.text(PlusCopy.title), findsOneWidget);
    });

    testWidgets('so does the card itself', (tester) async {
      // Where someone meets the wall, and a dead card would say no without
      // saying what it costs.
      await _pump(tester, isLocked: true);

      await tester.tap(find.text(_lesson.title));
      await tester.pumpAndSettle();

      expect(find.text(PlusCopy.title), findsOneWidget);
    });
  });
}
