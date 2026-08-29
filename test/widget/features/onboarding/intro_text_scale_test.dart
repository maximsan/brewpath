import 'package:brew_path/features/onboarding/presentation/meet_roasty/meet_roasty_screen.dart';
import 'package:brew_path/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/intro_router.dart';

/// The intro screens must survive a large text scale on a small phone.
///
/// They are the first thing a learner sees, and a learner who needs 2x text is
/// the one most likely to be met by a clipped screen with no way forward — the
/// CTA and the tap cue both sit at the foot, which is what a `RenderFlex`
/// overflow eats first.
///
/// An overflow is reported through `FlutterError.onError`, not by failing a
/// finder, so it is captured explicitly here rather than hoped for.
Future<List<String>> _overflowsAt(
  WidgetTester tester,
  double textScale,
  String location,
) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) => errors.add(details.exceptionAsString());

  tester.view.physicalSize = const Size(375, 667);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: introRouter(initialLocation: location),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  FlutterError.onError = previous;
  return errors.where((error) => error.contains('overflowed')).toList();
}

void main() {
  for (final scale in <double>[1, 1.5, 2]) {
    testWidgets('Welcome survives text scale $scale', (tester) async {
      expect(await _overflowsAt(tester, scale, '/welcome'), isEmpty);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('Meet Roasty survives text scale $scale', (tester) async {
      expect(await _overflowsAt(tester, scale, '/meet-roasty'), isEmpty);
      expect(find.byType(MeetRoastyScreen), findsOneWidget);
    });
  }
}
