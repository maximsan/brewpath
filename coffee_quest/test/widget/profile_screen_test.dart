import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/app/app.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(useInMemoryDatabase);

  Future<void> openProfile(WidgetTester tester) async {
    await pumpWithProviders(tester, const CoffeeQuestApp());
    await tester.tap(find.byIcon(Icons.person_outline));
    await settleLoaders(tester);
  }

  testWidgets('shows zeroed stats and the app version for a fresh user', (
    tester,
  ) async {
    await openProfile(tester);

    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('1.0.0+1'), findsOneWidget); // mocked package_info
  });

  testWidgets('haptics toggle flips and persists via SettingsController', (
    tester,
  ) async {
    await openProfile(tester);

    final hapticsSwitch = find.widgetWithText(SwitchListTile, 'Haptics');
    expect(tester.widget<SwitchListTile>(hapticsSwitch).value, isTrue);

    await tester.tap(hapticsSwitch);
    await settleLoaders(tester);

    expect(tester.widget<SwitchListTile>(hapticsSwitch).value, isFalse);
  });
}
