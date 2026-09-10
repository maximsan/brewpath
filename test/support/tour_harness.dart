import 'package:brew_path/app/app.dart';
import 'package:brew_path/features/tour/domain/tour_copy.dart';
import 'package:brew_path/features/tour/domain/tour_step.dart';
import 'package:brew_path/shared/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_harness.dart';

/// Tall enough for the whole Learn list, which most Tour suites need.
const Size tallTourViewport = Size(400, 2400);

/// Sets the viewport for a Tour suite; [size] is a phone where the suite must
/// be able to scroll.
void useTourViewport(WidgetTester tester, {Size size = tallTourViewport}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Clears the flag the harness seeds, so the app boots owing the Tour.
Future<void> armTheTour() async {
  final repo = SettingsRepository();
  final settings = await repo.getSettings()
    ..tourSeen = false;
  await repo.saveSettings(settings);
}

/// The flag as the database holds it now.
Future<bool> tourSeenOnDisk() async =>
    (await SettingsRepository().getSettings()).tourSeen;

/// Drives the running Tour without `pumpAndSettle`, which never returns while
/// Roasty idles on an infinite animation behind the layer. `runAsync` is what
/// lets the real Drift write behind `markTourSeen` land between frames.
Future<void> letTheTourRun(WidgetTester tester) async {
  for (var frame = 0; frame < 20; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Waits for the write behind an ending to land, watching the disk rather than
/// counting frames: under a loaded runner Drift takes longer than twenty.
Future<void> awaitTourSeenWritten(WidgetTester tester) async {
  const attempts = 200;
  for (var attempt = 0; attempt < attempts; attempt++) {
    if (await tester.runAsync(tourSeenOnDisk) ?? false) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('tourSeen was never written');
}

/// Boots the app owing the Tour, the way a first launch does, onto the first
/// stop, and hands back the container so a test can drive the router.
Future<ProviderContainer> bootIntoTheTour(
  WidgetTester tester, {
  Size viewport = tallTourViewport,
}) async {
  useTourViewport(tester, size: viewport);
  await armTheTour();

  final container = await pumpWithProviders(tester, const BrewPathApp());
  await letTheTourRun(tester);
  return container;
}

/// Next, until the last stop's card is up.
Future<void> walkToTheLastStop(WidgetTester tester) async {
  for (var stop = 0; stop < TourStep.count - 1; stop++) {
    await tester.tap(find.text(TourCopy.stopNext));
    await letTheTourRun(tester);
  }
}
