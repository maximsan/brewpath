import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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
/// The three tests share one app install and run in order: the first completes
/// onboarding, the second proves it persisted to real storage across a
/// relaunch, the third opens real content.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder target, {
    required String describe,
    bool present = true,
    int attempts = 200,
  }) async {
    final ready = present ? target.hitTestable() : target;
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (ready.evaluate().isNotEmpty == present) return;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
    fail('never reached: $describe');
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
  Finder liveButton(String label) => find.byWidgetPredicate(
    (widget) =>
        widget is FilledButton &&
        widget.onPressed != null &&
        widget.child is Text &&
        (widget.child! as Text).data == label,
    description: 'an enabled "$label" button',
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
    await tapWhenReady(
      tester,
      liveButton('Plant your seed'),
      describe: 'the welcome screen',
    );

    await tapWhenReady(
      tester,
      find.text('Brew better at home'),
      describe: 'the goal picker',
    );
    await tapWhenReady(
      tester,
      liveButton('Continue'),
      describe: 'the goal picker accepting an answer',
    );

    await tapWhenReady(
      tester,
      find.text('V60'),
      describe: 'the brewer picker',
    );
    await tapWhenReady(
      tester,
      liveButton('Continue'),
      describe: 'the brewer picker accepting an answer',
    );

    await pumpUntil(
      tester,
      find.text("Today's lesson"),
      describe: 'the Learn tab after onboarding',
    );
  });

  testWidgets('a returning launch skips onboarding entirely', (tester) async {
    // The real assertion is about **storage**: the answers the previous test
    // gave were written to an on-disk database, and a fresh process reads them
    // back. Nothing else in the repo exercises that — every widget test seeds
    // the flag in memory instead.
    await launch(tester);

    await pumpUntil(
      tester,
      find.text("Today's lesson"),
      describe: 'the Learn tab on a returning launch',
    );
    expect(
      find.text('What brings you here?'),
      findsNothing,
      reason: 'onboarding persisted, so it must not be offered again',
    );
  });

  testWidgets('authored content opens from the bundle as it ships', (
    tester,
  ) async {
    // Deliberately stops at the first step. Playing a lesson through is five
    // steps across three interaction kinds, and the widget suite already
    // drives each of them properly — re-driving them here bought brittleness
    // and nothing else. This test used to answer one question and expect a
    // five-step lesson to be finished.
    //
    // What remains is the part only this suite can prove: content loads from
    // the bundle as it ships, and the immersive flow opens over the shell.
    //
    // Launches for itself. Each `testWidgets` gets a fresh tree, so leaning on
    // the previous test to have left the app mounted is exactly the kind of
    // unstated assumption that let this suite rot.
    await launch(tester);

    await tapWhenReady(
      tester,
      find.text('Where Coffee Comes From'),
      describe: "today's lesson card",
    );

    await pumpUntil(
      tester,
      find.textContaining('Step 1 of'),
      describe: "today's lesson",
    );
    expect(
      find.textContaining('In which region'),
      findsOneWidget,
      reason: 'the step body came from the bundled content, not a fixture',
    );
  });
}
