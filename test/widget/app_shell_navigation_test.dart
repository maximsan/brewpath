import 'package:brew_path/app/app.dart';
import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/app_router.dart';
import 'package:brew_path/app/tab_large_title.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/dictionary/presentation/dictionary_home_screen.dart';
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
      expect(
        find.byType(TabLargeTitle),
        findsOneWidget,
        reason: 'the tab carries the screen while the bar is invisible',
      );
    });

    testWidgets('each names itself in the design vocabulary, once', (
      tester,
    ) async {
      await pumpWithProviders(tester, const BrewPathApp());

      // The name is the tab's own large title now, and the bar stays wordless
      // until the tab scrolls under it — so `findsOneWidget` is the whole
      // point of the pair, not an incidental count (#441).
      for (final tab in [
        (AppIcon.route, 'Beginner Foundations'),
        (AppIcon.cards, 'Collection'),
        (AppIcon.leaf, 'Hello there.'),
      ]) {
        await tester.tap(findMark(tab.$1, active: false));
        await settleLoaders(tester);

        expect(find.text(tab.$2), findsOneWidget);
        expect(_headerTitled(tab.$2), findsNothing);
      }
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

      container.read(appRouterProvider).go('/learn/dictionary');
      await settleLoaders(tester);

      // The name is a page heading rather than a bar title since #398, so
      // arrival is asserted on the screen and the bar is checked for being
      // the pushed kind — which is what this test is actually about.
      expect(find.byType(DictionaryHomeScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
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
        find.text('Beginner Foundations'),
        findsOneWidget,
        reason: 'checking what you kept must not cost you your tab',
      );
    });

    testWidgets('the dictionary is reached from the header', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await tester.tap(_dictionaryButton());
      await settleLoaders(tester);

      expect(find.byType(DictionaryHomeScreen), findsOneWidget);
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

    container.read(appRouterProvider).go('/learn/dictionary');
    await settleLoaders(tester);
    expect(
      find.byType(DictionaryHomeScreen),
      findsOneWidget,
    );

    await tester.tap(findMark(AppIcon.route, active: false));
    await settleLoaders(tester);
    expect(find.text('Beginner Foundations'), findsOneWidget);

    await tester.tap(findMark(AppIcon.cup, active: false));
    await settleLoaders(tester);

    // Learn kept its stack — still on the pushed page, still without the
    // header.
    expect(
      find.byType(DictionaryHomeScreen),
      findsOneWidget,
    );
    expect(_sharedHeader(), findsNothing);
  });

  testWidgets('a tab whose title can grow opens clear of the entries', (
    tester,
  ) async {
    // The bar floats over the tab, so nothing lays the title and the entries
    // out against each other. Three of the four titles are not fixed strings —
    // the day's date, the course name, a greeting carrying a typed name — and
    // at the design's 24 the widest of them paints behind the two buttons.
    await pumpWithProviders(tester, const BrewPathApp());

    Future<void> expectClear(String tab, Finder entry) async {
      expect(
        // The Text, not the widget: the widget's box starts at the top of the
        // screen and the gap it leaves is inside it.
        tester
            .getRect(
              find.descendant(
                of: find.byType(TabLargeTitle),
                matching: find.byType(Text),
              ),
            )
            .top,
        greaterThanOrEqualTo(tester.getRect(entry).bottom),
        reason: '$tab must open below its entries, not behind them',
      );
    }

    await expectClear('Learn', _savedButton());

    await tester.tap(findMark(AppIcon.route, active: false));
    await settleLoaders(tester);
    await expectClear('Path', _savedButton());

    await tester.tap(findMark(AppIcon.leaf, active: false));
    await settleLoaders(tester);
    await expectClear('Profile', _settingsButton());
  });

  group('collapse on scroll', () {
    /// Drags the visible tab upward past the design's 72.
    Future<void> scrollTab(WidgetTester tester) async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -240));
      await tester.pumpAndSettle();
    }

    testWidgets('at the top the bar is wordless and the tab is titled', (
      tester,
    ) async {
      await pumpWithProviders(tester, const BrewPathApp());

      expect(
        _headerTitled('TODAY'),
        findsNothing,
        reason: 'the design keeps the bar invisible until the tab scrolls',
      );
      expect(
        find.byType(TabLargeTitle),
        findsOneWidget,
        reason: 'the tab carries the screen at the top, as the design pairs it',
      );
    });

    testWidgets('scrolling a tab raises its compact title', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await scrollTab(tester);

      expect(
        _headerTitled('TODAY'),
        findsOneWidget,
        reason: 'the bar takes the screen over once the large title has gone',
      );
    });

    testWidgets('scrolling back to the top puts it away again', (tester) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await scrollTab(tester);
      expect(_headerTitled('TODAY'), findsOneWidget);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await tester.pumpAndSettle();

      expect(_headerTitled('TODAY'), findsNothing);
    });

    testWidgets('each tab keeps its own collapse across a switch', (
      tester,
    ) async {
      await pumpWithProviders(tester, const BrewPathApp());

      await scrollTab(tester);
      expect(_headerTitled('TODAY'), findsOneWidget);

      await tester.tap(findMark(AppIcon.route, active: false));
      await settleLoaders(tester);
      expect(
        _headerTitled('YOUR PATH'),
        findsNothing,
        reason: 'Path was never scrolled, so it must not inherit the collapse',
      );

      await tester.tap(findMark(AppIcon.cup, active: false));
      await settleLoaders(tester);
      expect(
        _headerTitled('TODAY'),
        findsOneWidget,
        reason: 'Learn is found exactly as it was left',
      );
    });
  });
}
