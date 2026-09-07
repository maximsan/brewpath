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

/// The one thing that boots the real app.
///
/// Every other test in this repo runs against in-memory Drift, a cleared asset
/// bundle, and an onboarding flag seeded to `true`. Three failures are
/// invisible to all of them and visible only here: a migration that fails
/// against a real on-disk database, an asset the pubspec does not actually
/// bundle, and a plugin that is not registered on the platform. The `iOS build`
/// job proves the app compiles, never that it runs. Onboarding, in particular,
/// has no other coverage at all — the widget harness seeds past it.
///
/// **Every step asserts.** This suite rotted for months because three of its
/// steps failed silently: a skip guarded by an `if` that no-opped when its copy
/// changed, a landmark (`BREWPATH`) that two different screens render so it
/// passed on the wrong one, and taps dispatched at a page still sliding in from
/// off-screen. Nothing here may continue when a step did not happen, and a
/// failure names the screen it could not reach.
///
/// Two tests, sharing one app install and run in order: the first completes
/// onboarding, the second relaunches to prove it persisted to real storage and
/// then opens authored content. **Two launches, not three** — each `app.main()`
/// opens another database over the same file, and drift is explicit that
/// concurrent instances race.
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

  // When Xcode hosts this run (`xcodebuild test`, the way CI runs it), its
  // accessibility client attaches to the app at the first frame it shows,
  // and the framework then holds a SemanticsHandle of its own. A test in
  // which that happened fails with "A SemanticsHandle was active at the end
  // of the test", because the tester records the handle count when the test
  // starts. So show a frame before any test starts, and give the client a
  // moment to attach. Under `flutter test` nothing attaches and the wait
  // simply runs out.
  setUpAll(() async {
    runApp(const SizedBox.shrink());
    final platform = WidgetsBinding.instance.platformDispatcher;
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!platform.semanticsEnabled && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });

  /// Pumps in real time until [target] can be tapped — or is gone, when
  /// [present] is false — and fails naming what never happened.
  ///
  /// Never `pumpAndSettle`: Roasty idles on an infinite animation, which that
  /// waits on forever. It is what made this suite look like a ten-minute job
  /// when the build takes thirty-five seconds. Real-time pumps also let
  /// Drift's FFI and the asset bundle make progress, which a fake-async pump
  /// on its own does not.
  ///
  /// **Hit-testable, not merely present.** A page sliding in exists in the
  /// tree well before it is on screen, so waiting for existence hands back a
  /// widget whose centre is off the right-hand edge and every tap misses it —
  /// silently, as a warning rather than a failure.
  ///
  /// The [budget] is deliberately generous. A cold CI runner is several times
  /// slower than a warm laptop, and the third launch in a process is the
  /// slowest of all — an eight-second budget passed locally and failed on the
  /// first real run. Nothing is lost by waiting: a genuine hang still fails
  /// here in seconds rather than at the job's cap, which is the whole point of
  /// bounding it per step.
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

  /// A [PrimaryButton]'s underlying button, **only while it is enabled**.
  ///
  /// Onboarding's Continue is dead until its controller accepts the answer, so
  /// a walk that taps on the frame after choosing taps nothing at all — and
  /// `tap` on a disabled button succeeds, which is the silent failure again.
  ///
  /// ⚠️ **The label is looked for anywhere under the button, never as its
  /// direct child.** This read `child is Text` until the button grew an
  /// optional trailing mark and wrapped its label in a `Row` — after which
  /// every wait here timed out against a button that was on screen the whole
  /// time, and the gate stayed red across five merges. What the walk needs is
  /// *an enabled button that says this*; how the button lays its label out is
  /// the button's business.
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
    // **One relaunch, and everything a second launch has to prove.**
    //
    // Each `app.main()` builds another `AppDatabase` over the same file, and
    // drift says plainly what that costs: "race conditions will occur and might
    // corrupt the database". Two launches are fine; a third is not — split
    // across three tests this passed only when the simulator still held an
    // onboarded install from an earlier run, and failed on every clean one.
    // Merging the two is not a shortcut, it is the fix.
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
    // immersive flow opens over the shell.
    //
    // Deliberately stops at the first step. Playing a lesson through is five
    // steps across three interaction kinds, and the widget suite already
    // drives each of them properly — re-driving them here bought brittleness
    // and nothing else. This used to answer one question and expect a
    // five-step lesson to be finished.
    // Opened by the card's own control, never by a lesson title. Hardcoding
    // authored copy is what broke the walk in the first place, and it broke
    // again here: this asked for "Where Coffee Comes From" while the course
    // now opens on "What coffee actually is".
    await tapWhenReady(
      tester,
      find.widgetWithText(FilledButton, AppLabels.beginLesson),
      describe: "today's lesson card",
    );

    // The meter on card one is the proof the bundle loaded: its `total` is the
    // lesson's own card count, so it cannot be mounted without real authored
    // content behind it.
    //
    // Asserted on the **widget and its numbers**, not on the string it draws.
    // This step used to wait for `Step 1 of`, which the player stopped drawing
    // when the counter became `RoastMeter`'s `01 / 08` — the assertion went
    // stale, and because this job runs on push only, `main` went red with no
    // PR to catch it ([#437](https://github.com/maximsan/brewpath/issues/437)).
    // Numbers cannot rot the way a format can.
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
