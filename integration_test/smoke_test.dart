import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/cards/presentation/card_grid_item_widget.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_actions.dart';
import 'package:brew_path/features/lessons/presentation/cards/match_tile.dart';
import 'package:brew_path/features/lessons/presentation/lesson_screen.dart';
import 'package:brew_path/features/lessons/presentation/reward_points_line.dart';
import 'package:brew_path/features/monetization/domain/plus_copy.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/profile/presentation/widgets/profile_progress_line.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/main.dart' as app;
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/support/find_mark.dart';

// The only suite that boots the real app: why it exists, why every step must
// assert, and what a relaunch has to tear down first — docs/12-testing.md,
// "The suite, by directory".

/// How long each real-time pump waits before looking again.
const Duration _pumpInterval = Duration(milliseconds: 40);

/// Every string actually on screen, for a failure message.
///
/// A walk that only says what it wanted makes the reader guess what it got.
/// Every hour lost on this suite was spent re-running it to find that out.
String _visibleText(WidgetTester tester) {
  final seen = tester
      .widgetList<Text>(find.byType(Text).hitTestable())
      .map((text) => text.data)
      .whereType<String>()
      .where((label) => label.trim().isNotEmpty)
      .toSet();
  return seen.isEmpty ? '(nothing)' : seen.join(' | ');
}

/// The name the walk types at onboarding and expects to survive a relaunch.
const _name = 'Maya';

/// The lesson the walk plays to completion. It and the two values below are
/// written out rather than read back off the bundle: a walk that asks the app
/// what it is owed cannot notice the app owing nothing.
const _lessonId = 'm1l1';

/// What finishing [_lessonId] once pays.
const _lessonPoints = 10;

/// The collectible [_lessonId] hands over.
const _lessonCardId = 'c1';

/// How many answers one card can take before the walk gives up on it. A
/// concept card spends one per blank; nothing in the course spends this many.
const _answersPerCard = 8;

/// Longer than the usual wait: the completion screen holds a two-second beat
/// before its report, and persists the run behind it.
const _completionBudget = Duration(seconds: 45);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Under `xcodebuild test`, the way CI runs it, Xcode's accessibility client
  // attaches at the app's first frame and the framework then holds a
  // SemanticsHandle the tester never counted — "A SemanticsHandle was active
  // at the end of the test". So show a frame and let the client attach before
  // any test starts; under `flutter test` nothing attaches and the wait simply
  // runs out.
  setUpAll(() async {
    runApp(const SizedBox.shrink());
    final platform = WidgetsBinding.instance.platformDispatcher;
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!platform.semanticsEnabled && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });

  /// Pumps in real time until [target] is hit-testable — or gone, when
  /// [present] is false — and fails naming what never happened. A page sliding
  /// in is in the tree before it is on screen, so waiting on mere existence
  /// hands back a widget every tap misses; pass [tappable] false for one the
  /// walk only reads. Never `pumpAndSettle`, and the [budget] is deliberately
  /// generous; both reasons are in docs/12-testing.md.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder target, {
    required String describe,
    bool present = true,
    bool tappable = true,
    Duration budget = const Duration(seconds: 30),
  }) async {
    final ready = present && tappable ? target.hitTestable() : target;
    final attempts = budget.inMilliseconds ~/ _pumpInterval.inMilliseconds;
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (ready.evaluate().isNotEmpty == present) return;
      await tester.runAsync(() => Future<void>.delayed(_pumpInterval));
      await tester.pump();
    }
    fail(
      'never reached: $describe (waited ${budget.inSeconds}s)\n'
      'on screen: ${_visibleText(tester)}',
    );
  }

  /// Waits for [target] to be tappable, then taps it.
  ///
  /// Acts on the **hit-testable** match, not the raw one. A push transition
  /// mounts both pages at once, so the raw finder can match the outgoing copy
  /// as well and `ensureVisible` fails on "too many elements" — a wait and an
  /// action disagreeing about which widget they meant.
  Future<void> tapWhenReady(
    WidgetTester tester,
    Finder target, {
    required String describe,
  }) async {
    await pumpUntil(tester, target, describe: describe);
    final live = target.hitTestable().first;
    await tester.ensureVisible(live);
    await tester.tap(live);
    await tester.pump();
  }

  /// A button that says [label], only while it is enabled — onboarding's
  /// Continue is dead until its controller accepts the answer, and `tap` on a
  /// disabled button succeeds silently. The label is looked for anywhere under
  /// the button, never as its direct child; docs/12-testing.md, "The smoke
  /// walk's helpers", says what reading it as a direct child cost.
  Finder liveButton(String label) => find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (widget) => widget is FilledButton && widget.onPressed != null,
      description: 'an enabled "$label" button',
    ),
  );

  /// An option the card on screen will still take.
  ///
  /// Two shapes, because the cards draw two: most answer controls are an
  /// `OutlinedButton`, and a match board's tiles are `MatchTile`. Either stops
  /// accepting taps once its card latches, so this empties as the card
  /// commits. Scoped to the player, whose shell is still in the tree behind it.
  Finder liveOption() => find.descendant(
    of: find.byType(LessonScreen),
    matching: find.byWidgetPredicate(
      (widget) => switch (widget) {
        OutlinedButton(:final onPressed) => onPressed != null,
        MatchTile(:final onTap) => onTap != null,
        _ => false,
      },
      description: 'an answerable option',
    ),
  );

  /// Answers the card at [position] and moves on. How many answers that takes
  /// is the card's business — a concept card wants one per blank — so the walk
  /// answers until a way on comes alive rather than counting. That way on is
  /// Continue, or Check answers first on the two kinds that grade a whole
  /// answer. Which option it picks is not the point: this walk is about the
  /// run being recorded, not about scoring well.
  Future<void> answerAndContinue(WidgetTester tester, int position) async {
    final onward = liveButton(AppLabels.continueLabel);
    final commit = liveButton(AppLabels.checkAnswers);
    for (var answer = 0; answer < _answersPerCard; answer++) {
      if (onward.evaluate().isNotEmpty || commit.evaluate().isNotEmpty) break;
      if (liveOption().evaluate().isEmpty) {
        fail(
          'card $position offers nothing to answer and no way on\n'
          'on screen: ${_visibleText(tester)}',
        );
      }
      // A different option each time, not always the first. A concept card
      // offers one pair per blank and every option stays live until it is
      // checked, so re-tapping the first only ever re-answers one blank and
      // the card never fills.
      final options = liveOption();
      final option = options.at(answer % options.evaluate().length);
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump();
    }
    // `multi` and `concept` gather a whole answer before they will grade it,
    // so their one button says Check answers until it is pressed and only
    // then becomes Continue.
    if (commit.evaluate().isNotEmpty) {
      await tapWhenReady(
        tester,
        commit,
        describe: 'Check answers on card $position of the lesson',
      );
    }
    await tapWhenReady(
      tester,
      onward,
      describe: 'Continue on card $position of the lesson',
    );
  }

  /// The player's own position meter, scoped for [liveOption]'s reason: the
  /// shell the lesson opens over is still in the tree, and other screens draw
  /// a meter of their own.
  Finder playerMeter() => find.descendant(
    of: find.byType(LessonScreen),
    matching: find.byType(RoastMeter),
  );

  /// Plays the open lesson from the card showing to its last, leaving the
  /// caller on the completion screen. The card count comes off the meter, so
  /// a lesson that grows a card is played whole rather than abandoned.
  Future<void> playToCompletion(WidgetTester tester) async {
    final total = tester.widget<RoastMeter>(playerMeter()).total;
    for (var position = 1; position <= total; position++) {
      await pumpUntil(
        tester,
        find.descendant(
          of: find.byType(LessonScreen),
          matching: find.byWidgetPredicate(
            (widget) => widget is RoastMeter && widget.position == position,
            description: 'RoastMeter on card $position',
          ),
        ),
        describe: 'card $position of the lesson',
      );
      await answerAndContinue(tester, position);
    }
  }

  /// Whether a previous test in this file has already launched the app.
  var launched = false;

  /// Launches the app and skips the wake-up, leaving the caller on whatever
  /// the onboarding gate chose.
  ///
  /// A relaunch tears the previous app down first: the tree is unmounted and
  /// its database closed, so the next `app.main()` opens the file rather than
  /// racing a live handle over the same bytes, which drift warns can corrupt.
  Future<void> launch(WidgetTester tester) async {
    if (launched) {
      runApp(const SizedBox.shrink());
      await tester.pump();
      await AppDatabaseService.instance.close();
    }
    launched = true;
    app.main();
    await tester.pump();
    await pumpUntil(
      tester,
      find.byType(LoadingScreen),
      describe: 'the loading screen on launch',
    );
    // Tap-anywhere skip, so the walk does not sit through the wake-up. The
    // screen is asserted above rather than guarded by an `if`.
    await tester.tap(find.byType(LoadingScreen));
    await pumpUntil(
      tester,
      find.byType(LoadingScreen),
      describe: 'the loading screen to hand over',
      present: false,
    );
  }

  testWidgets('a cold launch walks onboarding and lands on Learn', (
    tester,
  ) async {
    await launch(tester);

    // Each screen is landmarked on the control the walk then uses, so the
    // assertion and the action cannot drift apart.
    // Welcome has no button — the whole screen advances — so the walk taps
    // its heading, which is also the landmark proving this is Welcome and not
    // Meet Roasty wearing its route (#383).
    await tapWhenReady(
      tester,
      find.text('Learn coffee.\nGrow a tree.'),
      describe: 'the welcome screen',
    );

    await tapWhenReady(
      tester,
      liveButton('Start learning'),
      describe: 'the Meet Roasty screen',
    );

    // The last step, and the only one that takes typing rather than a tap.
    // The goal and brewer pickers used to sit between here and Meet Roasty;
    // ADR-0010 cut both, so Meet Roasty hands straight over to the name.
    //
    // A name is entered rather than skipped so the walk proves the field
    // reaches storage — the returning launch below reads it back.
    await pumpUntil(tester, find.byType(TextField), describe: 'the name step');
    await tester.enterText(find.byType(TextField), _name);
    await tester.pump();
    await tapWhenReady(
      tester,
      liveButton('Continue'),
      describe: 'the name step accepting a name',
    );

    // The intro's last step (ADR-0010, #242). Declined rather than bought:
    // the store is the no-op service in this build, so buying is not a path a
    // walk can drive — and declining is the exit every learner has.
    await tapWhenReady(
      tester,
      find.text(PlusCopy.maybeLater),
      describe: 'the Plus offer that ends onboarding',
    );

    // The Tour is offered on the first launch that reaches Learn with it
    // unseen — this one. The offer is a non-dismissible modal, and it is
    // triggered by the same event that draws the Today card, so a walk that
    // waits for the card without answering the offer is a race: on a slow
    // runner the card is found first and the test passes, on a fast machine
    // the offer covers it and the test fails. Answer it, then look for Learn.
    await tapWhenReady(
      tester,
      find.widgetWithText(TextButton, TourCopy.introDecline),
      describe: 'the Tour offer on the first launch that reaches Learn',
    );
    await pumpUntil(
      tester,
      find.text(AppLabels.continueLearning.toUpperCase()),
      describe: 'the Learn tab after onboarding',
    );
  });

  testWidgets('a returning launch skips onboarding and opens real content', (
    tester,
  ) async {
    // Everything a returning launch has to prove, in one test rather than
    // spread over several: each of these needs the launch above to have gone
    // to disk, and splitting them made every one of them depend on the order
    // the file happened to run in.
    await launch(tester);

    // Storage: the answers the previous test gave were written to an on-disk
    // database, and a fresh process reads them back. Nothing else in the repo
    // exercises that — every widget test seeds the flag in memory instead.
    await pumpUntil(
      tester,
      find.text(AppLabels.continueLearning.toUpperCase()),
      describe: 'the Learn tab on a returning launch',
    );

    // The previous launch answered the Tour offer, and that answer was
    // written to the same on-disk database. A returning launch that offered
    // the Tour again would mean the write did not survive the process.
    await pumpUntil(
      tester,
      find.widgetWithText(TextButton, TourCopy.introDecline),
      describe: 'no second Tour offer on a returning launch',
      present: false,
    );
    expect(
      find.text('What brings you here?'),
      findsNothing,
      reason: 'onboarding persisted, so it must not be offered again',
    );

    // The other half of that proof, and the only one a learner can see: the
    // name typed into the previous launch survived the process and is on the
    // Profile header. A value written, closed, reopened and rendered.
    await tapWhenReady(
      tester,
      findMark(AppIcon.leaf, active: false),
      describe: 'the Profile tab',
    );
    await pumpUntil(
      tester,
      find.text('Hello, $_name.'),
      describe: 'the Profile greeting carrying the name from onboarding',
    );

    // Back to Learn, because the walk continues there. The detour above is a
    // read, not a destination — leaving the walk on Profile made the content
    // section below hunt for a lesson card on the wrong tab, which is how it
    // failed the first time this check was added.
    await tapWhenReady(
      tester,
      findMark(AppIcon.cup, active: false),
      describe: 'the Learn tab after the Profile detour',
    );

    // Content: authored material loads from the bundle as it ships, and the
    // immersive flow opens over the shell. Opened by the card's own control,
    // never by a lesson title — hardcoding authored copy is what broke this
    // walk twice. The lesson is then played whole, because the run has to be
    // real for the launch after it to have anything to find.
    await tapWhenReady(
      tester,
      find.widgetWithText(FilledButton, AppLabels.beginLesson),
      describe: "today's lesson card",
    );

    // The meter on card one proves the bundle loaded: its `total` is the
    // lesson's own card count. Asserted on the widget and its numbers, never
    // on the string it draws — this waited for `Step 1 of` until the counter
    // became `01 / 08`, and since the job runs on push only, `main` went red
    // with no PR to catch it (#437). Numbers cannot rot the way a format can.
    await pumpUntil(
      tester,
      find.descendant(
        of: find.byType(LessonScreen),
        matching: find.byWidgetPredicate(
          (widget) => widget is RoastMeter && widget.position == 1,
          description: 'RoastMeter on card one',
        ),
      ),
      describe: "today's lesson opening on its first card",
    );
    expect(
      tester.widget<RoastMeter>(playerMeter()).total,
      greaterThan(1),
      reason: 'the card count must come from the authored lesson, not a stub',
    );

    // Which lesson a fresh install queues, named rather than assumed: the
    // launch below asserts what finishing *this* one is worth, and a walk that
    // played whatever came up could not.
    expect(
      tester.widget<LessonScreen>(find.byType(LessonScreen)).lessonId,
      _lessonId,
    );

    await playToCompletion(tester);

    // The completion screen is built off the write that recorded the run, so
    // reaching its footer means the run is in the database. The next lesson is
    // the action here because m1l1 does not close its module.
    await pumpUntil(
      tester,
      liveButton(nextLessonLabel),
      describe: 'the completion screen offering the next lesson',
      budget: _completionBudget,
    );
    expect(
      tester.widget<RewardPointsLine>(find.byType(RewardPointsLine)).points,
      _lessonPoints,
    );
  });

  testWidgets('a relaunch still holds the lesson, its points and its card', (
    tester,
  ) async {
    // The restart #116 is about. The run above went to an on-disk database,
    // the app was torn down, and this is a fresh process reading the same
    // file. Nothing here replays anything: every fact is read back.
    await launch(tester);

    await tapWhenReady(
      tester,
      findMark(AppIcon.leaf, active: false),
      describe: 'the Profile tab',
    );
    // The line is built before its providers resolve, so the wait is on the
    // numbers rather than on the widget — which would be satisfied by the
    // zeroes it draws while it loads.
    await pumpUntil(
      tester,
      find.byWidgetPredicate(
        (widget) =>
            widget is ProfileProgressLine &&
            widget.lessons == 1 &&
            widget.points == _lessonPoints,
        description: 'one lesson and $_lessonPoints points on Profile',
      ),
      describe: 'the completion and its points surviving the relaunch',
      tappable: false,
    );

    await tapWhenReady(
      tester,
      findMark(AppIcon.cards, active: false),
      describe: 'the Cards tab',
    );
    await pumpUntil(
      tester,
      find.byWidgetPredicate(
        (widget) =>
            widget is CardGridItemWidget &&
            widget.placed.item.card.id == _lessonCardId &&
            widget.placed.item.isCollected,
        description: 'the collectible $_lessonCardId, held',
      ),
      describe: 'the card the lesson handed over surviving the relaunch',
      tappable: false,
    );
  });
}
