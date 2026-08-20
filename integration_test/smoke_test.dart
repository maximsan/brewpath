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
/// job proves the app compiles, never that it runs.
///
/// **The walk asserts every screen it lands on.** This suite rotted once
/// because two of its steps failed silently — a skip guarded by `if` that
/// no-opped when its copy changed, and a landmark (`BREWPATH`) that two
/// different screens render, so it passed on the wrong one. Nothing here may
/// continue when a step did not happen.
///
/// The three tests share one app install and run in order: the first completes
/// onboarding, the second proves it persisted to real storage across a
/// relaunch, the third opens real content.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps in real time until [target] can actually be tapped — or is gone,
  /// when [present] is false — and fails naming what never happened.
  ///
  /// Never `pumpAndSettle`: Roasty idles on an infinite animation, which that
  /// waits on forever — the hang that made this suite look like a ten-minute
  /// job when the build takes forty seconds. Real-time pumps also let Drift's
  /// FFI and the asset bundle make progress, which a fake-async pump does not.
  ///
  /// **Hit-testable, not merely present.** A page sliding in exists in the
  /// tree well before it is on screen, so waiting for existence hands back a
  /// widget whose centre is still off the right-hand edge and every tap misses
  /// it. Waiting until it can receive a pointer is the same thing the walk
  /// needs next, so the wait and the action cannot disagree.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder target, {
    required String describe,
    bool present = true,
    int attempts = 150,
  }) async {
    final settled = present ? target.hitTestable() : target;
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (settled.evaluate().isNotEmpty == present) return;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
    fail('never reached: $describe');
  }

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
    // screen is asserted above rather than guarded by an `if`: a skip that
    // silently does nothing is how this suite spent months passing on the
    // wrong screen.
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

    // Welcome. Landmarked on its own call to action — the thing we then tap,
    // so the assertion and the target cannot drift apart.
    final plantSeed = find.widgetWithText(FilledButton, 'Plant your seed');
    await pumpUntil(tester, plantSeed, describe: 'the welcome screen');
    await tester.ensureVisible(plantSeed);
    await tester.tap(plantSeed);

    // Goal.
    await pumpUntil(
      tester,
      find.text('What brings you here?'),
      describe: 'the goal picker',
    );
    await tester.tap(find.text('Brew better at home'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));

    // Brewer.
    await pumpUntil(
      tester,
      find.text('What do you brew with?'),
      describe: 'the brewer picker',
    );
    await tester.tap(find.text('V60'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));

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

  testWidgets('real content opens from the real bundle', (tester) async {
    // Deliberately stops at the first step. Playing a lesson through is five
    // steps across three interaction kinds, and the widget suite already
    // drives each of them properly; doing it again here bought brittleness
    // and nothing else — this test used to answer one question and expect a
    // five-step lesson to be finished.
    //
    // What is left is the part only this suite can prove: authored content
    // loads from the bundle as it ships, and the immersive flow opens over the
    // shell on a real device.
    await tester.tap(find.text('Where Coffee Comes From'));
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
