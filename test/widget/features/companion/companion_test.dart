import 'package:coffee_quest/features/companion/domain/companion_reaction.dart';
import 'package:coffee_quest/features/companion/domain/roasty_state.dart';
import 'package:coffee_quest/features/companion/presentation/companion.dart';
import 'package:coffee_quest/features/companion/presentation/companion_handle.dart';
import 'package:coffee_quest/features/companion/presentation/roasty.dart';
import 'package:coffee_quest/features/progress/domain/progress_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

RoastyState _stateOf(WidgetTester tester) =>
    tester.widget<Roasty>(find.byType(Roasty)).state;

void main() {
  testWidgets('a reaction plays then reverts to the baseline mood', (
    tester,
  ) async {
    final handle = CompanionHandle();
    addTearDown(handle.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [streakProvider.overrideWith((ref) => 0)],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: Companion(handle: handle, animate: false)),
          ),
        ),
      ),
    );
    await tester.pump();

    // Baseline: no streak -> idle mood.
    expect(_stateOf(tester), RoastyState.idle);

    // Fire a one-shot reaction.
    handle.react(CompanionReaction.lessonComplete);
    await tester.pump();
    expect(_stateOf(tester), RoastyState.lesson);

    // After the lesson one-shot's duration, it auto-reverts to the mood.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(_stateOf(tester), RoastyState.idle);
  });
}
