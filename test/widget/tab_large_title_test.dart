import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/app/header_tier.dart';
import 'package:brew_path/app/tab_large_title.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/widget_harness.dart';

/// The day the header test freezes to, so the two agree on what Learn says.
final _today = DateTime(2026, 5, 8);

Widget _harness(AppRoute route, {EdgeInsets padding = EdgeInsets.zero}) {
  return ProviderScope(
    overrides: [currentDayProvider.overrideWithValue(_today)],
    child: MaterialApp(
      theme: ThemeData(extensions: const [MoodColors.darkRoast]),
      home: MediaQuery(
        data: MediaQueryData(padding: padding),
        child: Scaffold(
          body: SingleChildScrollView(child: TabLargeTitle(route)),
        ),
      ),
    ),
  );
}

void main() {
  setUp(useInMemoryDatabase);

  testWidgets('each tab root is titled by the same words the bar would use', (
    tester,
  ) async {
    for (final root in [
      AppRoutes.learn,
      AppRoutes.path,
      AppRoutes.cards,
      AppRoutes.profile,
    ]) {
      await tester.pumpWidget(_harness(root));
      await tester.pumpAndSettle();

      // One source for both halves of the design's pair: the large title here
      // and the compact one in the bar read the same heading, so they cannot
      // come to disagree about what the screen is called.
      expect(
        find.text(tabHeaderFor(root.path, today: _today)!.title),
        findsOneWidget,
        reason: '${root.path} titles itself',
      );
    }
  });

  testWidgets('it is set at the display step, as a heading', (tester) async {
    await tester.pumpWidget(_harness(AppRoutes.cards));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('Collection')).style?.fontSize,
      AppText.display().fontSize,
    );
    expect(
      tester.getSemantics(find.text('Collection')),
      matchesSemantics(label: 'Collection', isHeader: true),
    );
  });

  testWidgets('it leaves the status bar its room, because nothing else does', (
    tester,
  ) async {
    const inset = 44.0;

    await tester.pumpWidget(_harness(AppRoutes.cards));
    await tester.pumpAndSettle();
    final withoutInset = tester.getTopLeft(find.text('Collection')).dy;

    await tester.pumpWidget(
      _harness(AppRoutes.cards, padding: const EdgeInsets.only(top: inset)),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Collection')).dy,
      withoutInset + inset,
      reason:
          'the header floats over the tab now, so the tab is what makes room '
          'for the status bar',
    );
  });

  testWidgets('a route that is not a tab root draws nothing', (tester) async {
    await tester.pumpWidget(_harness(AppRoutes.dictionary));
    await tester.pumpAndSettle();

    expect(find.byType(Text), findsNothing);
  });
}
