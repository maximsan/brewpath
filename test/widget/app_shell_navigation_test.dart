import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/find_mark.dart';
import '../support/widget_harness.dart';

/// The header the four tabs share, and the rule about where it does *not*
/// draw. Asserted against the real router and the real screens, because the
/// question is which chrome a location gets — and only the whole app can
/// answer it.
Finder _sharedHeader() => find.byType(AppHeader);
Finder _headerTitled(String title) => find.widgetWithText(AppHeader, title);
Finder _dictionaryButton() => find.byIcon(Icons.menu_book_outlined);
Finder _savedButton() => find.byTooltip(SavedScreen.title);
Finder _settingsButton() => findMark(AppIcon.gear);

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

      await tester.tap(findMark(AppIcon.route, active: false));
      await settleLoaders(tester);
      expect(_headerTitled('Beginner Foundations'), findsOneWidget);

      await tester.tap(findMark(AppIcon.cards, active: false));
      await settleLoaders(tester);
      expect(_headerTitled('Collection'), findsOneWidget);

      await tester.tap(findMark(AppIcon.leaf, active: false));
      await settleLoaders(tester);
      expect(_headerTitled('PROFILE'), findsOneWidget);
    });

    testWidgets('carry the Dictionary button, except Profile', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());
      expect(_dictionaryButton(), findsOneWidget);
      expect(_settingsButton(), findsNothing);

      await tester.tap(findMark(AppIcon.leaf, active: false));
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
      for (final tab in [AppIcon.route, AppIcon.cards, AppIcon.leaf]) {
        await tester.tap(findMark(tab, active: false));
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

    testWidgets('the shelf is reached from the header', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await tester.tap(_savedButton());
      await settleLoaders(tester);

      expect(find.widgetWithText(AppBar, SavedScreen.title), findsOneWidget);
      expect(
        _sharedHeader(),
        findsNothing,
        reason: 'the shelf is a pushed page: a back arrow, not the tab entries',
      );
    });

    testWidgets('backing out of the shelf returns to the tab it came from', (
      tester,
    ) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await tester.tap(findMark(AppIcon.route, active: false));
      await settleLoaders(tester);
      await tester.tap(_savedButton());
      await settleLoaders(tester);
      expect(find.widgetWithText(AppBar, SavedScreen.title), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await settleLoaders(tester);

      expect(
        _headerTitled('Beginner Foundations'),
        findsOneWidget,
        reason: 'checking what you kept must not cost you your tab',
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

    testWidgets('a mini-game shows no chrome either', (tester) async {
      final container = await pumpWithProviders(tester, const BrewPathApp());

      container.read(appRouterProvider).go('/learn/mini-game/g-match');
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

    await tester.tap(findMark(AppIcon.route, active: false));
    await settleLoaders(tester);
    expect(_headerTitled('Beginner Foundations'), findsOneWidget);

    await tester.tap(findMark(AppIcon.cup, active: false));
    await settleLoaders(tester);

    // Learn kept its stack — still on the module, still without the header.
    expect(find.widgetWithText(AppBar, 'Module'), findsOneWidget);
    expect(_sharedHeader(), findsNothing);
  });

  group('collapse on scroll', () {
    /// The header's height right now. Its collapse is a height change, so this
    /// is the honest thing to assert — not an internal flag.
    double headerHeight(WidgetTester tester) =>
        tester.getSize(find.byType(AppHeader)).height;

    /// Drags the visible tab upward far enough to pass the threshold.
    Future<void> scrollTab(WidgetTester tester) async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -240));
      await tester.pumpAndSettle();
    }

    testWidgets('scrolling a tab collapses its header', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());
      final atRest = headerHeight(tester);
      expect(_headerTitled('TODAY'), findsOneWidget);

      await scrollTab(tester);

      expect(headerHeight(tester), lessThan(atRest));
      expect(
        _headerTitled('TODAY'),
        findsNothing,
        reason: 'the eyebrow goes; the title is what the learner still needs',
      );
    });

    testWidgets('scrolling back to the top restores it', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());
      final atRest = headerHeight(tester);

      await scrollTab(tester);
      expect(headerHeight(tester), lessThan(atRest));

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await tester.pumpAndSettle();

      expect(headerHeight(tester), atRest);
      expect(_headerTitled('TODAY'), findsOneWidget);
    });

    testWidgets('each tab keeps its own collapse across a switch', (
      tester,
    ) async {
      await pumpWithProviders(tester, const BrewPathApp());
      final atRest = headerHeight(tester);

      await scrollTab(tester);
      expect(headerHeight(tester), lessThan(atRest));

      await tester.tap(findMark(AppIcon.route, active: false));
      await settleLoaders(tester);
      expect(
        headerHeight(tester),
        atRest,
        reason: 'Path was never scrolled, so it must not inherit the collapse',
      );

      await tester.tap(findMark(AppIcon.cup, active: false));
      await settleLoaders(tester);
      expect(
        headerHeight(tester),
        lessThan(atRest),
        reason: 'Learn is found exactly as it was left',
      );
    });
  });
}
