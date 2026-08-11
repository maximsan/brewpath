import 'package:brew_path/features/onboarding/presentation/loading/loading_screen.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  // Pre-mark onboarding as completed so existing widget tests that boot the
  // full app shell still land on /learn. Onboarding-specific tests build
  // their own router and do not go through this helper.
  await db
      .into(db.userSettings)
      .insert(
        UserSettingsCompanion.insert(
          id: const Value(SettingsRepository.settingsId),
          hapticsEnabled: true,
          soundEnabled: true,
          totalXp: 0,
          streakDays: 0,
          onboardingCompleted: const Value(true),
        ),
      );

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

Future<ProviderContainer> pumpWithProviders(
  WidgetTester tester,
  Widget child,
) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: child),
  );
  await settleLoaders(tester);
  return container;
}
