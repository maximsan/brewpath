import 'package:brew_path/core/constants/app_labels.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/widgets/roast_meter.dart';
import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test/support/find_mark.dart';

// The only suite that boots the real app: why it exists, why every step must
// assert, and why it launches exactly twice — docs/12-testing.md, "The suite,
// by directory".

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
  /// hands back a widget every tap misses. Never `pumpAndSettle`, and the
  /// [budget] is deliberately generous; both reasons are in
  /// docs/12-testing.md, "The smoke walk's helpers".
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder target, {
    required String describe,
    bool present = true,
    Duration budget = const Duration(seconds: 30),
  }) async {
    final ready = present ? target.hitTestable() : target;
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

  /// Launches the app and skips the wake-up, leaving the caller on whatever
  /// the onboarding gate chose.
  Future<void> launch(WidgetTester tester) async {
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
    // One relaunch, carrying everything a second launch has to prove. Each
    // `app.main()` builds another `AppDatabase` over the same file, and drift
    // warns that "race conditions will occur and might corrupt the database".
    // Split across three tests this passed only where the simulator still held
    // an onboarded install; merging the two is the fix, not a shortcut.
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
    // walk twice. It stops at the first step on purpose: the widget suite
    // already drives every interaction kind, and re-driving them here bought
    // brittleness and nothing else.
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
      find.byWidgetPredicate(
        (widget) => widget is RoastMeter && widget.position == 1,
        description: 'RoastMeter on card one',
      ),
      describe: "today's lesson opening on its first card",
    );
    expect(
      tester.widget<RoastMeter>(find.byType(RoastMeter)).total,
      greaterThan(1),
      reason: 'the card count must come from the authored lesson, not a stub',
    );
  });
}
