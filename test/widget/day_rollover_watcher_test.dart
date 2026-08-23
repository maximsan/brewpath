import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/day_rollover_watcher.dart';
import 'package:brew_path/features/learn/domain/keep_sharp_providers.dart';
import 'package:brew_path/features/progress/domain/progress_providers.dart';
import 'package:brew_path/features/progress/domain/streak_status.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Proves the watcher recomputes the day-dependent surfaces on a resume that
/// crossed midnight, and leaves them alone on a resume that did not.
///
/// The providers are overridden with counting stubs and kept alive by a
/// listener, so a rebuild is observable: an invalidated provider re-runs its
/// body on the next read, a cached one does not.
void main() {
  late int streakBuilds;
  late int recommendationBuilds;
  late int acknowledgedBuilds;
  late int dayBuilds;

  setUp(() {
    streakBuilds = 0;
    recommendationBuilds = 0;
    acknowledgedBuilds = 0;
    dayBuilds = 0;
  });

  ProviderContainer containerWithStubs() => ProviderContainer(
    overrides: [
      streakStatusProvider.overrideWith((ref) async {
        streakBuilds++;
        return StreakStatus.idle;
      }),
      keepSharpRecommendationProvider.overrideWith((ref) async {
        recommendationBuilds++;
        return null;
      }),
      keepSharpAcknowledgedTodayProvider.overrideWith((ref) async {
        acknowledgedBuilds++;
        return false;
      }),
      // The app header's day. Counted here because it is the fourth surface,
      // and the one this file's own doc warned would be added later and
      // silently missed.
      currentDayProvider.overrideWith((ref) {
        dayBuilds++;
        return DateTime(2026, 8, 20);
      }),
    ],
  );

  /// Reads all three so they are built once and held by a listener.
  Future<void> primeAndHold(ProviderContainer container) async {
    container
      ..listen(currentDayProvider, (_, _) {})
      ..listen(streakStatusProvider, (_, _) {})
      ..listen(keepSharpRecommendationProvider, (_, _) {})
      ..listen(keepSharpAcknowledgedTodayProvider, (_, _) {});
    await container.read(streakStatusProvider.future);
    await container.read(keepSharpRecommendationProvider.future);
    await container.read(keepSharpAcknowledgedTodayProvider.future);
  }

  /// The full background-and-return cycle. `AppLifecycleListener` reports a
  /// resume as a transition, so the app has to leave the foreground first.
  Future<void> backgroundAndResume(WidgetTester tester) async {
    const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pump();
  }

  Future<void> pumpWatcher(
    WidgetTester tester, {
    required ProviderContainer container,
    required DateTime Function() clock,
  }) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: DayRolloverWatcher(clock: clock, child: const SizedBox()),
    ),
  );

  testWidgets('a resume that crossed midnight recomputes the day surfaces', (
    tester,
  ) async {
    final container = containerWithStubs();
    addTearDown(container.dispose);

    var now = DateTime(2026, 8, 20, 23, 55);
    await pumpWatcher(tester, container: container, clock: () => now);
    await primeAndHold(container);
    expect(streakBuilds, 1);

    now = DateTime(2026, 8, 21, 0, 5);
    await backgroundAndResume(tester);

    await container.read(streakStatusProvider.future);
    await container.read(keepSharpRecommendationProvider.future);
    await container.read(keepSharpAcknowledgedTodayProvider.future);
    expect(
      dayBuilds,
      2,
      reason: "the header's day must recompute, or it shows yesterday",
    );
    expect(streakBuilds, 2, reason: 'the streak is folded against a new today');
    expect(recommendationBuilds, 2, reason: 'the rotation moved on');
    // In production this one would also rebuild via its watch on the
    // recommendation. The stubs here have no such edge — which is the point:
    // it proves the watcher refreshes this surface itself, rather than
    // inheriting it from wiring that lives in another feature.
    expect(
      acknowledgedBuilds,
      2,
      reason: 'yesterday was acknowledged, not today',
    );
  });

  testWidgets('a resume within the same day leaves the surfaces alone', (
    tester,
  ) async {
    final container = containerWithStubs();
    addTearDown(container.dispose);

    var now = DateTime(2026, 8, 20, 9);
    await pumpWatcher(tester, container: container, clock: () => now);
    await primeAndHold(container);

    now = DateTime(2026, 8, 20, 17, 30);
    await backgroundAndResume(tester);

    await container.read(streakStatusProvider.future);
    await container.read(keepSharpRecommendationProvider.future);
    await container.read(keepSharpAcknowledgedTodayProvider.future);
    expect(streakBuilds, 1, reason: 'an ordinary app-switch must not churn');
    expect(recommendationBuilds, 1);
    expect(acknowledgedBuilds, 1);
  });

  testWidgets('a clock moved back across a day also recomputes', (
    tester,
  ) async {
    final container = containerWithStubs();
    addTearDown(container.dispose);

    var now = DateTime(2026, 8, 21, 9);
    await pumpWatcher(tester, container: container, clock: () => now);
    await primeAndHold(container);

    now = DateTime(2026, 8, 20, 9);
    await backgroundAndResume(tester);

    await container.read(streakStatusProvider.future);
    expect(streakBuilds, 2);
  });

  testWidgets('a second resume on the new day does not recompute again', (
    tester,
  ) async {
    final container = containerWithStubs();
    addTearDown(container.dispose);

    var now = DateTime(2026, 8, 20, 23, 55);
    await pumpWatcher(tester, container: container, clock: () => now);
    await primeAndHold(container);

    now = DateTime(2026, 8, 21, 0, 5);
    await backgroundAndResume(tester);
    await container.read(streakStatusProvider.future);
    expect(streakBuilds, 2);

    now = DateTime(2026, 8, 21, 8);
    await backgroundAndResume(tester);
    await container.read(streakStatusProvider.future);
    expect(
      streakBuilds,
      2,
      reason: 'the day it last looked at is now recorded',
    );
  });

  testWidgets('it renders its child untouched', (tester) async {
    final container = containerWithStubs();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: DayRolloverWatcher(
          clock: () => DateTime(2026, 8, 20, 9),
          child: const SizedBox(key: Key('child')),
        ),
      ),
    );

    expect(find.byKey(const Key('child')), findsOneWidget);
  });
}
