import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/features/tour/domain/micro_tip.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Marks onboarding, the Tour and every micro-tip as already seen on [db].
///
/// Pre-marked so widget tests that boot the full shell land on `/learn`.
/// `tourSeen` is not optional: the Tour auto-runs the moment Learn shows real
/// data with the flag unset, so without it every shell test would open onto
/// the intro overlay's modal barrier and every tap would miss. The tips are
/// pre-marked for the same reason one step down: a tip is a card over the foot
/// of the screen, and a test tapping something down there would find the tip
/// instead. Tour and tip tests clear what they are about — see
/// test/widget/features/tour/.
///
/// Extracted from [useInMemoryDatabase] so a test that needs a **file-backed**
/// database — one it can close and reopen to assert a real restart — can seed
/// it the same way.
Future<void> seedOnboarded(AppDatabase db) async {
  await db
      .into(db.userSettings)
      .insert(
        UserSettingsCompanion.insert(
          id: const Value(SettingsRepository.settingsId),
          hapticsEnabled: true,
          soundEnabled: true,
          totalXp: 0,
          onboardingCompleted: const Value(true),
          tourSeen: const Value(true),
          tipsSeen: Value(everyMicroTipSeen),
        ),
      );
}

/// The seen list with all seven micro-tips on it, as the settings row stores
/// them.
final String everyMicroTipSeen = MicroTipsSeen.encode({
  for (final tip in MicroTip.values) tip.id,
});

/// Shared widget-test setup: a fresh in-memory Drift DB wired into
/// [AppDatabaseService] and stubbed package_info, so screens render against
/// real content assets and an empty user state without platform channels.
Future<AppDatabase> useInMemoryDatabase() async {
  // `rootBundle` caches the `Future` returned by `loadString`, not just its
  // value. A Future created inside one `testWidgets` test's `FakeAsync` zone
  // delivers its continuations through that (now-dead) zone, so a later test
  // that `await`s the cached Future hangs forever. Dropping the cache each
  // test forces a fresh Future in the live zone.
  rootBundle.clear();

  final db = AppDatabase(NativeDatabase.memory());
  AppDatabaseService.instance = db;
  addTearDown(db.close);

  await seedOnboarded(db);

  PackageInfo.setMockInitialValues(
    appName: 'BrewPath',
    packageName: 'dev.maximsan.brewPath',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );

  return db;
}

/// Pumps until the async providers resolve and the loading spinner is gone.
/// `pumpAndSettle` can't be used while an indeterminate
/// `CircularProgressIndicator` is on screen (it animates forever), so we poll
/// in bounded steps instead.
Future<void> settleLoaders(WidgetTester tester) async {
  await tester.pump(); // build + kick off the async providers
  for (var i = 0; i < 50; i++) {
    // drift (FFI) and rootBundle are *real* async; runAsync lets that I/O
    // actually progress between pumps (fake-async pump alone won't settle it).
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    final stillLoading = find
        .byType(CircularProgressIndicator)
        .evaluate()
        .isNotEmpty;
    if (!stillLoading && i >= 2) break;
  }
  // If the app booted into the onboarding LoadingScreen, tap-skip it so
  // widget tests don't have to sit through the ~6.5 s wake-up animation.
  // Use real-time pumps because `_advance` awaits the async gate future,
  // and `pumpAndSettle` would hang on Roasty's infinite idle animation.
  if (find.byType(LoadingScreen).evaluate().isNotEmpty) {
    await tester.tap(find.byType(LoadingScreen));
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      if (find.byType(LoadingScreen).evaluate().isEmpty) break;
    }
  }
  // Drain any in-flight page transition (e.g. loading → learn after the
  // onboarding gate resolves). Capped so tests don't hang on infinite
  // animations.
  await tester.pumpAndSettle(const Duration(milliseconds: 50));
}

/// Pumps [child] under a real container.
///
/// Pass a [container] built with overrides to stand somewhere the app cannot
/// put itself — owning the course, say, which no shipped build can do until
/// the store is real. The container arrives whole rather than as a list of
/// overrides because Riverpod 3 does not export the `Override` type, so the
/// list cannot be named in a signature.
Future<ProviderContainer> pumpWithProviders(
  WidgetTester tester,
  Widget child, {
  ProviderContainer? container,
}) async {
  final scope = container ?? ProviderContainer();
  addTearDown(scope.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: scope, child: child),
  );
  await settleLoaders(tester);
  return scope;
}
