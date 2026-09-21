import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/widgets/settings_nav_row.dart';
import 'package:brew_path/features/profile/presentation/settings/acknowledgements_screen.dart';
import 'package:brew_path/features/profile/presentation/settings/settings_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/widget_harness.dart';

Finder _row(String label) => find.byWidgetPredicate(
  (widget) => widget is SettingsNavRow && widget.label == label,
);

/// Boots the app and routes to About, rather than tapping through Profile and
/// Settings to reach it — those two hops are their own screens' business.
Future<void> _openAbout(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = await pumpWithProviders(tester, const BrewPathApp());
  container.read(appRouterProvider).go('/profile/settings/about');
  // Not `settleLoaders`: it ends on a `pumpAndSettle`, and About mounts
  // Roasty, whose idle animation never ends.
  await pumpWithoutSettling(tester);
}

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('Acknowledgements opens the page the term bank generates', (
    tester,
  ) async {
    await _openAbout(tester);

    await tester.tap(_row(SettingsCopy.acknowledgementsRow));
    await pumpWithoutSettling(tester);

    expect(find.byType(AcknowledgementsScreen), findsOneWidget);
    expect(
      find.byType(SettingsNavRow),
      findsAtLeastNWidgets(2),
      reason: 'the bundled dictionary cites more than one work',
    );
  });

  testWidgets('Open-source licenses opens the page Flutter generates', (
    tester,
  ) async {
    await _openAbout(tester);

    await tester.tap(_row(SettingsCopy.licensesRow));
    await pumpWithoutSettling(tester);

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
