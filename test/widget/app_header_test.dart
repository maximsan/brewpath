import 'package:brew_path/app/app_header.dart';
import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/features/saved/domain/saved_providers.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_badge_dot.dart';
import 'package:brew_path/features/saved/presentation/saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A shelf holding [count] rows, so the badge has something to count.
List<SavedGroup> _shelfOf(int count) => count == 0
    ? const []
    : [
        SavedGroup(
          kind: SavedKind.term,
          label: 'Dictionary terms',
          items: [
            for (var i = 0; i < count; i++)
              SavedItem(
                key: 't:term$i',
                kind: SavedKind.term,
                id: 'term$i',
                title: 'Term $i',
                subtitle: 'BEANS',
              ),
          ],
        ),
      ];

/// The header on its own, for the things the whole-app test cannot reach —
/// chiefly the system's reduced-motion setting, which `BrewPathApp` builds its
/// own `MediaQuery` over.
Widget _harness({
  required bool isCollapsed,
  required bool disableAnimations,
  String location = '',
  int savedCount = 0,
}) {
  return ProviderScope(
    overrides: [
      currentDayProvider.overrideWithValue(DateTime(2026, 5, 8)),
      savedShelfProvider.overrideWith(
        (ref) async => _shelfOf(savedCount),
      ),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        // In a Column, as the shell places it: the header takes its natural
        // height and the tab gets the rest.
        child: Scaffold(
          body: Column(
            children: [
              AppHeader(
                location: location.isEmpty ? AppRoutes.learn.path : location,
                isCollapsed: isCollapsed,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    ),
  );
}

double _height(WidgetTester tester) =>
    tester.getSize(find.byType(AppHeader)).height;

void main() {
  testWidgets('collapsing drops the eyebrow and keeps the day', (tester) async {
    await tester.pumpWidget(
      _harness(isCollapsed: false, disableAnimations: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Friday, May 8'), findsOneWidget);
    final atRest = _height(tester);

    await tester.pumpWidget(
      _harness(isCollapsed: true, disableAnimations: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('TODAY'), findsNothing);
    expect(
      find.text('Friday, May 8'),
      findsOneWidget,
      reason: 'the title is what the learner still needs on the way down',
    );
    expect(_height(tester), lessThan(atRest));
  });

  testWidgets('reduced motion settles the collapse in one frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(isCollapsed: false, disableAnimations: true),
    );
    await tester.pumpAndSettle();
    final atRest = _height(tester);

    await tester.pumpWidget(
      _harness(isCollapsed: true, disableAnimations: true),
    );
    await tester.pump();

    expect(
      _height(tester),
      lessThan(atRest),
      reason: 'no transition to wait out when the system asks for none',
    );
  });

  testWidgets('with motion allowed, the collapse takes frames', (tester) async {
    await tester.pumpWidget(
      _harness(isCollapsed: false, disableAnimations: false),
    );
    await tester.pumpAndSettle();
    final atRest = _height(tester);

    await tester.pumpWidget(
      _harness(isCollapsed: true, disableAnimations: false),
    );
    await tester.pump();

    expect(
      _height(tester),
      atRest,
      reason:
          'the first frame has not moved yet — this is what reduced '
          'motion is skipping',
    );
    await tester.pumpAndSettle();
    expect(_height(tester), lessThan(atRest));
  });

  group('the Saved entry', () {
    Future<void> pump(
      WidgetTester tester, {
      required String location,
      int savedCount = 0,
    }) async {
      await tester.pumpWidget(
        _harness(
          isCollapsed: false,
          disableAnimations: true,
          location: location,
          savedCount: savedCount,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Learn, Path and Cards each offer it', (tester) async {
      for (final tab in [
        AppRoutes.learn.path,
        AppRoutes.path.path,
        AppRoutes.cards.path,
      ]) {
        await pump(tester, location: tab);
        expect(
          find.byTooltip(SavedScreen.title),
          findsOneWidget,
          reason: '$tab offers the shelf',
        );
      }
    });

    testWidgets('Profile offers the gear instead of the pair', (tester) async {
      await pump(tester, location: AppRoutes.profile.path);

      expect(find.byTooltip(SavedScreen.title), findsNothing);
      expect(find.byTooltip('Settings'), findsOneWidget);
    });

    testWidgets('it is present even with nothing saved', (tester) async {
      // An empty shelf still opens, and its empty state teaches the bookmark.
      await pump(tester, location: AppRoutes.learn.path);

      expect(find.byTooltip(SavedScreen.title), findsOneWidget);
    });

    testWidgets('the count reaches the label, not just a dot', (tester) async {
      await pump(tester, location: AppRoutes.learn.path, savedCount: 3);

      expect(find.byTooltip('${SavedScreen.title}, 3 items'), findsOneWidget);
    });

    testWidgets('one saved item reads in the singular', (tester) async {
      await pump(tester, location: AppRoutes.learn.path, savedCount: 1);

      expect(find.byTooltip('${SavedScreen.title}, 1 item'), findsOneWidget);
    });

    // Two tests rather than one with two pumps: re-pumping the same tree with
    // a different override leaves the async count briefly unresolved, which
    // reads as zero and makes the assertion about the wrong frame.
    testWidgets('no dot when nothing is saved', (tester) async {
      await pump(tester, location: AppRoutes.learn.path);

      expect(find.byType(SavedBadgeDot), findsNothing);
    });

    testWidgets('a dot once the shelf holds something', (tester) async {
      await pump(tester, location: AppRoutes.learn.path, savedCount: 2);

      expect(find.byType(SavedBadgeDot), findsOneWidget);
    });

    testWidgets('Saved sits before the dictionary', (tester) async {
      await pump(tester, location: AppRoutes.learn.path);

      final saved = tester.getTopLeft(find.byTooltip(SavedScreen.title)).dx;
      final dictionary = tester
          .getTopLeft(find.byIcon(Icons.menu_book_outlined))
          .dx;
      expect(saved, lessThan(dictionary));
    });
  });
}
