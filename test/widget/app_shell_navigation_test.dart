import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

Finder _appBarTitled(String title) => find.widgetWithText(AppBar, title);

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('starts on the Learn tab', (tester) async {
    await pumpWithProviders(tester, const BrewPathApp());
    expect(_appBarTitled('Learn'), findsOneWidget);
  });

  testWidgets('each destination switches tabs', (tester) async {
    await pumpWithProviders(tester, const BrewPathApp());

    await tester.tap(find.byIcon(Icons.route_outlined));
    await settleLoaders(tester);
    expect(_appBarTitled('Path'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.style_outlined));
    await settleLoaders(tester);
    expect(_appBarTitled('Cards'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await settleLoaders(tester);
    // Profile uses a SliverPersistentHeader rather than an AppBar — the close
    // icon is unique to the Profile header and proves we landed there.
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('branch navigator stack is preserved across tab switches', (
    tester,
  ) async {
    final container = await pumpWithProviders(tester, const BrewPathApp());

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
