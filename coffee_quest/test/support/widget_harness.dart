import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:coffee_quest/shared/storage/app_database.dart';

/// Shared widget-test setup: a fresh in-memory Drift DB wired into
/// [AppDatabaseService] and stubbed package_info, so screens render against
/// real content assets and an empty user state without platform channels.
AppDatabase useInMemoryDatabase() {
  final db = AppDatabase(NativeDatabase.memory());
  AppDatabaseService.instance = db;
  addTearDown(db.close);

  PackageInfo.setMockInitialValues(
    appName: 'Coffee Quest',
    packageName: 'dev.maximsan.coffeequest',
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
    final stillLoading =
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    if (!stillLoading && i >= 2) return;
  }
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
