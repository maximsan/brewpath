import 'package:brew_path/app/app.dart';
import 'package:brew_path/shared/theme/app_theme_mode.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

/// The mood the app actually resolved to, read off a context beneath
/// `MaterialApp` — this is what the user sees, as opposed to what was
/// requested.
MoodColors _renderedMood(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return Theme.of(context).extension<MoodColors>()!;
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required AppThemeMode initial,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [initialThemeModeProvider.overrideWithValue(initial)],
      child: const BrewPathApp(),
    ),
  );
}

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('the very first frame is already in the stored mood', (
    tester,
  ) async {
    await _pumpApp(tester, initial: AppThemeMode.light);

    // Deliberately a single pump: no settle, no waiting for async providers.
    // The preference is seeded synchronously from bootstrap, so the opening
    // frame must already be Cupping. If it were read through an AsyncValue
    // this would be Dark Roast first and flash.
    await tester.pump();

    expect(_renderedMood(tester).bg, MoodColors.cupping.bg);
  });

  testWidgets('dark preference renders Dark Roast', (tester) async {
    await _pumpApp(tester, initial: AppThemeMode.dark);
    await tester.pump();

    expect(_renderedMood(tester).bg, MoodColors.darkRoast.bg);
  });

  testWidgets('system follows the platform brightness', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await _pumpApp(tester, initial: AppThemeMode.system);
    await tester.pump();
    expect(_renderedMood(tester).bg, MoodColors.cupping.bg);

    // A live OS change, with no restart and no re-pump of the widget tree.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();

    expect(
      _renderedMood(tester).bg,
      MoodColors.darkRoast.bg,
      reason: 'system mode must track the OS without a restart',
    );
  });

  testWidgets('selecting a mode re-themes the running app', (tester) async {
    await _pumpApp(tester, initial: AppThemeMode.dark);
    await tester.pump();
    expect(_renderedMood(tester).bg, MoodColors.darkRoast.bg);

    final context = tester.element(find.byType(Scaffold).first);
    await ProviderScope.containerOf(
      context,
    ).read(themeModeControllerProvider.notifier).select(AppThemeMode.light);
    await tester.pumpAndSettle();

    expect(_renderedMood(tester).bg, MoodColors.cupping.bg);
  });
}
