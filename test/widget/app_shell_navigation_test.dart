import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

/// The header the four tabs share, and the rule about where it does *not*
/// draw. Asserted against the real router and the real screens, because the
/// question is which chrome a location gets — and only the whole app can
/// answer it.
Finder _sharedHeader() => find.byType(AppHeader);
Finder _headerTitled(String title) => find.widgetWithText(AppHeader, title);
Finder _dictionaryButton() => find.byIcon(Icons.menu_book_outlined);
Finder _settingsButton() => find.byIcon(Icons.settings_outlined);

void main() {
  setUp(useInMemoryDatabase);

  group('the four tabs', () {
    testWidgets('start on Learn, under the shared header', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());
      expect(_sharedHeader(), findsOneWidget);
      expect(_headerTitled('TODAY'), findsOneWidget);
    });

    testWidgets('each names itself in the design vocabulary', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await tester.tap(find.byIcon(Icons.route_outlined));
      await settleLoaders(tester);
      expect(_headerTitled('Beginner Foundations'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.style_outlined));
      await settleLoaders(tester);
      expect(_headerTitled('Collection'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline));
      await settleLoaders(tester);
      expect(_headerTitled('PROFILE'), findsOneWidget);
    });

    testWidgets('carry the Dictionary button, except Profile', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());
      expect(_dictionaryButton(), findsOneWidget);
      expect(_settingsButton(), findsNothing);

      await tester.tap(find.byIcon(Icons.person_outline));
      await settleLoaders(tester);
      expect(
        _dictionaryButton(),
        findsNothing,
        reason:
            'the profile variant swaps the entries, it does not add to them',
      );
      expect(_settingsButton(), findsOneWidget);
    });

    testWidgets('there is only ever one header on screen', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());
      for (final icon in [
        Icons.route_outlined,
        Icons.style_outlined,
        Icons.person_outline,
      ]) {
        await tester.tap(find.byIcon(icon));
        await settleLoaders(tester);
        expect(_sharedHeader(), findsOneWidget);
      }
    });
  });

  group('pushed pages', () {
    testWidgets('bring their own bar and never the tab header', (tester) async {
      final container = await pumpWithProviders(tester, const BrewPathApp());

      container.read(appRouterProvider).go('/learn/module/module_beans');
      await settleLoaders(tester);

      expect(find.widgetWithText(AppBar, 'Module'), findsOneWidget);
      expect(
        _sharedHeader(),
        findsNothing,
        reason: 'a pushed page carries a back arrow, not the tab entries',
      );
    });

    testWidgets('the dictionary is reached from the header', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await tester.tap(_dictionaryButton());
      await settleLoaders(tester);

      expect(find.widgetWithText(AppBar, 'Dictionary'), findsOneWidget);
      expect(_sharedHeader(), findsNothing);
    });
  });

  group('immersive flows', () {
    testWidgets('a lesson shows no chrome at all', (tester) async {
      final container = await pumpWithProviders(tester, const BrewPathApp());

      container.read(appRouterProvider).go('/learn/lesson/m1l1');
      await settleLoaders(tester);

      expect(_sharedHeader(), findsNothing);
    });
  });

  testWidgets('a branch keeps its own stack across tab switches', (
    tester,
  ) async {
    final container = await pumpWithProviders(tester, const BrewPathApp());

    container.read(appRouterProvider).go('/learn/module/module_beans');
    await settleLoaders(tester);
    expect(find.widgetWithText(AppBar, 'Module'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.route_outlined));
    await settleLoaders(tester);
    expect(_headerTitled('Beginner Foundations'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.school_outlined));
    await settleLoaders(tester);

    // Learn kept its stack — still on the module, still without the header.
    expect(find.widgetWithText(AppBar, 'Module'), findsOneWidget);
    expect(_sharedHeader(), findsNothing);
  });
}
