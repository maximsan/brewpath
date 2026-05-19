import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_quest/app/app.dart';
import 'package:coffee_quest/app/app_router.dart';

import '../support/widget_harness.dart';

Finder _appBarTitled(String title) =>
    find.widgetWithText(AppBar, title);

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('starts on the Learn tab', (tester) async {
    await pumpWithProviders(tester, const CoffeeQuestApp());
    expect(_appBarTitled('Learn'), findsOneWidget);
  });

  testWidgets('each destination switches tabs', (tester) async {
    await pumpWithProviders(tester, const CoffeeQuestApp());

    await tester.tap(find.byIcon(Icons.route_outlined));
    await settleLoaders(tester);
    expect(_appBarTitled('Path'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.style_outlined));
    await settleLoaders(tester);
    expect(_appBarTitled('Cards'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await settleLoaders(tester);
    expect(_appBarTitled('Profile'), findsOneWidget);
  });

  testWidgets('branch navigator stack is preserved across tab switches', (
    tester,
  ) async {
    final container = await pumpWithProviders(tester, const CoffeeQuestApp());

    container.read(appRouterProvider).go('/learn/module/module_beans');
    await settleLoaders(tester);
    expect(_appBarTitled('Module'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.route_outlined));
    await settleLoaders(tester);
    expect(_appBarTitled('Path'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.school_outlined));
    await settleLoaders(tester);

    // Learn branch retained its stack — still on the module sub-route.
    expect(_appBarTitled('Module'), findsOneWidget);
  });
}
