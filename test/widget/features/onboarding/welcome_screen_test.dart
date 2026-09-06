import 'package:brew_path/features/companion/presentation/roasty.dart';
import 'package:brew_path/features/onboarding/presentation/meet_roasty/meet_roasty_screen.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/seed_video_hero.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/intro_router.dart';

/// Welcome reads no onboarding providers — it only navigates — so a plain
/// `ProviderScope` is enough. The video_player platform channel is unavailable
/// under `flutter test`, so the hero always renders its fallback here; that is
/// the state these tests assert against.
Future<void> _pumpWelcome(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: introRouter(initialLocation: '/welcome'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets("carries its own copy, not Meet Roasty's", (tester) async {
    await _pumpWelcome(tester);

    expect(find.text('BREWPATH'), findsOneWidget);
    expect(find.text('Learn coffee.\nGrow a tree.'), findsOneWidget);
    expect(
      find.textContaining('Short, hands-on lessons in the craft of coffee.'),
      findsOneWidget,
    );

    // The copy that used to live here belongs to Meet Roasty.
    expect(find.textContaining('YOUR COMPANION'), findsNothing);
    expect(find.textContaining('Plant your tree.'), findsNothing);
  });

  testWidgets('has no Roasty — the design says so outright', (tester) async {
    await _pumpWelcome(tester);

    expect(find.byType(Roasty), findsNothing);
  });

  testWidgets('holds the film’s first frame when the player cannot start', (
    tester,
  ) async {
    // No platform channel under `flutter test`, so the player fails here the
    // way it does on a simulator with no audio device — and the frame carries
    // the film's still rather than nothing.
    await _pumpWelcome(tester);

    final still = tester.widget<Image>(find.byType(Image));
    expect((still.image as AssetImage).assetName, SeedVideoHero.poster);
  });

  testWidgets('frames the hero 4/3, not square', (tester) async {
    await _pumpWelcome(tester);

    final frame = tester.widget<AspectRatio>(
      find.byType(AspectRatio).first,
    );
    expect(frame.aspectRatio, closeTo(4 / 3, 0.001));
  });

  testWidgets('ships no dead controls', (tester) async {
    await _pumpWelcome(tester);

    expect(find.textContaining('Restore'), findsNothing);
    // The whole screen advances; there is no button to press.
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('the tap cue is on screen on a phone, under the film', (
    tester,
  ) async {
    // The cue used to sit below the fold on every phone: the column was
    // sized by its film *and* a spacer, which doubled its height. A finder
    // matches offscreen widgets, so this measures where the cue lands.
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _pumpWelcome(tester);

    final cue = find.text('TAP ANYWHERE TO CONTINUE');
    final film = find.byType(AspectRatio).first;
    expect(tester.getBottomLeft(cue).dy, lessThanOrEqualTo(852));
    expect(tester.getRect(film).bottom, lessThan(tester.getTopLeft(cue).dy));
    expect(tester.getRect(film).height, greaterThan(0));
  });

  testWidgets('tapping anywhere advances to Meet Roasty', (tester) async {
    await _pumpWelcome(tester);

    expect(find.text('TAP ANYWHERE TO CONTINUE'), findsOneWidget);

    // The screen itself, not a widget on it — "tap anywhere" is the claim.
    await tester.tap(find.byType(WelcomeScreen));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(MeetRoastyScreen), findsOneWidget);
  });
}
