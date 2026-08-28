import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/onboarding/presentation/meet_roasty/meet_roasty_screen.dart';
import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_onboarding_repository.dart';
import '../../../support/intro_router.dart';

/// The intro is three screens in one order — ADR-0010's v1 cut. Walked end to
/// end here rather than asserted screen by screen: the order is the thing the
/// app got wrong (Meet Roasty wore Welcome's route and Welcome did not exist),
/// and no per-screen test can catch that.
/// Pumps past a route transition. `pumpAndSettle` never returns here —
/// Roasty's idle animation loops forever — so the frames are counted out.
Future<void> _settleRoute(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('Loading, then Welcome, then Meet Roasty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(),
          ),
        ],
        child: MaterialApp.router(routerConfig: introRouter()),
      ),
    );

    await tester.pump();
    expect(find.byType(LoadingScreen), findsOneWidget);

    // Tap-anywhere skips the wake-up.
    await tester.tap(find.byType(LoadingScreen));
    await _settleRoute(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(MeetRoastyScreen), findsNothing);

    await tester.tap(find.text('Learn coffee.\nGrow a tree.'));
    await _settleRoute(tester);
    expect(find.byType(MeetRoastyScreen), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
  });
}
