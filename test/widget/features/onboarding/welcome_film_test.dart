import 'package:brew_path/features/onboarding/presentation/meet_roasty/meet_roasty_screen.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/sound_toggle.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_video_player_platform.dart';
import '../../../support/intro_router.dart';

/// Welcome *with a film*.
///
/// The other Welcome tests run against the fallback, because the real decoders
/// are native and never register under `flutter test`. That leaves the film and
/// everything sitting on it — the sound control — unreachable. A stand-in
/// platform makes the initialised path testable, which is the only path a
/// learner ever sees.
Future<FakeVideoPlayerPlatform> _pumpWelcome(
  WidgetTester tester, {
  bool reduceMotion = false,
}) async {
  final platform = FakeVideoPlayerPlatform.installed();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: introRouter(initialLocation: '/welcome'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return platform;
}

void main() {
  testWidgets('the film arrives muted, with the control to unmute', (
    tester,
  ) async {
    final platform = await _pumpWelcome(tester);

    expect(find.byType(SoundToggle), findsOneWidget);
    expect(platform.volumes.first, 0, reason: 'silent on arrival');
    expect(
      tester.getSemantics(find.byType(SoundToggle)).label,
      'Turn sound on',
    );
  });

  testWidgets('pressing it unmutes, and does not leave the screen', (
    tester,
  ) async {
    final platform = await _pumpWelcome(tester);

    await tester.tap(find.byType(SoundToggle));
    await tester.pump();

    expect(platform.volumes.last, greaterThan(0));
    expect(
      find.byType(WelcomeScreen),
      findsOneWidget,
      reason: 'reaching for the sound must not advance the intro',
    );
    expect(find.byType(MeetRoastyScreen), findsNothing);
  });

  testWidgets('the sound does not follow the learner to the next screen', (
    tester,
  ) async {
    final platform = await _pumpWelcome(tester);

    await tester.tap(find.byType(SoundToggle));
    await tester.pump();
    expect(platform.volumes.last, greaterThan(0));

    // Now leave, unmuted, the way an impatient learner would.
    await tester.tap(find.byType(WelcomeScreen));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(MeetRoastyScreen), findsOneWidget);
    expect(
      platform.volumes.last,
      0,
      reason: 'the track is silenced on the way out, not merely left behind',
    );
  });

  testWidgets('reduced motion holds the frame instead of looping', (
    tester,
  ) async {
    final platform = await _pumpWelcome(tester, reduceMotion: true);

    expect(platform.looping, isFalse);
    expect(platform.plays, 0, reason: 'nothing moves under reduced motion');
  });

  testWidgets('without reduced motion it loops and plays', (tester) async {
    final platform = await _pumpWelcome(tester);

    expect(platform.looping, isTrue);
    expect(platform.plays, greaterThan(0));
  });
}
