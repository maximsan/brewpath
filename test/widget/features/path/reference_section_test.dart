import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/features/path/domain/visual_guide_providers.dart';
import 'package:brew_path/features/path/domain/visual_guide_shelf.dart';
import 'package:brew_path/features/path/presentation/reference_section.dart';
import 'package:brew_path/shared/models/content/visual_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

VisualGuide _guide(String subject, String title) => VisualGuide(
  id: 'g-$subject',
  subject: subject,
  unlock: const VisualGuideUnlock(lesson: 'm1l6'),
  label: 'VISUAL GUIDE',
  title: title,
  summary: 'What $subject is, in one line.',
  fact: 'The one thing worth repeating about $subject.',
  meta: const [
    ['LIGHT', 'Bright · acidic'],
    ['DARK', 'Bitter · smoky'],
  ],
);

final VisualGuide _variety = _guide('variety', 'The Variety Family Tree');
final VisualGuide _roast = _guide('roast', 'Roast Levels');

Widget _harness(VisualGuideShelf shelf, {bool disableAnimations = false}) =>
    ProviderScope(
      overrides: [
        visualGuideShelfForProvider.overrideWith((ref) async => shelf),
      ],
      child: MaterialApp(
        theme: AppTheme.cupping,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Scaffold(
            body: ListView(children: const [ReferenceSection()]),
          ),
        ),
      ),
    );

void main() {
  group('locked', () {
    const locked = VisualGuideShelf(earned: [], remaining: 8);

    testWidgets('says what would put something in it', (tester) async {
      await tester.pumpWidget(_harness(locked));
      await tester.pumpAndSettle();

      expect(find.text('Reference'), findsOneWidget);
      expect(
        find.text('VISUAL GUIDES UNLOCK AS LESSONS TEACH THEM'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('refuses to open rather than opening onto nothing', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(locked));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.text('8 MORE UNLOCK AS YOU LEARN'), findsNothing);
    });
  });

  group('earned', () {
    final some = VisualGuideShelf(earned: [_variety, _roast], remaining: 6);

    testWidgets('is collapsed until opened', (tester) async {
      await tester.pumpWidget(_harness(some));
      await tester.pumpAndSettle();

      expect(find.text('The Variety Family Tree'), findsNothing);

      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();

      expect(find.text('The Variety Family Tree'), findsOneWidget);
      expect(find.text('Roast Levels'), findsOneWidget);
    });

    testWidgets('lists earned guides in order, and says what is left', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(some));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();

      final titles = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      expect(
        titles.indexOf('The Variety Family Tree'),
        lessThan(titles.indexOf('Roast Levels')),
        reason: 'bank order, not completion order',
      );
      expect(find.text('6 MORE UNLOCK AS YOU LEARN'), findsOneWidget);
    });

    testWidgets('drops the count line once nothing is left', (tester) async {
      await tester.pumpWidget(
        _harness(VisualGuideShelf(earned: [_variety], remaining: 0)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();

      expect(find.textContaining('MORE UNLOCK'), findsNothing);
    });

    testWidgets('opening a guide shows its whole entry', (tester) async {
      await tester.pumpWidget(_harness(some));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reference'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Roast Levels'));
      await tester.pumpAndSettle();

      expect(find.text('What roast is, in one line.'), findsOneWidget);
      expect(find.text('Bright · acidic'), findsOneWidget);
      expect(find.text('Bitter · smoky'), findsOneWidget);
      expect(
        find.text('The one thing worth repeating about roast.'),
        findsOneWidget,
      );
    });

    testWidgets('opens without an expansion animation under reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(some, disableAnimations: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reference'));
      await tester.pump();

      expect(
        find.text('Roast Levels'),
        findsOneWidget,
        reason: 'no transition to wait out when the system asks for none',
      );
    });
  });

  testWidgets('an empty bank shows no section at all', (tester) async {
    await tester.pumpWidget(
      _harness(const VisualGuideShelf(earned: [], remaining: 0)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reference'), findsNothing);
  });
}
