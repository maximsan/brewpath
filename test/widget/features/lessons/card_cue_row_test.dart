import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/widgets/primary_button.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_cue.dart';
import 'package:brew_path/features/lessons/presentation/cards/card_cue_row.dart';
import 'package:brew_path/features/lessons/presentation/cards/help_drawer.dart';
import 'package:brew_path/shared/models/content/card_kind_help.dart';
import 'package:brew_path/shared/repositories/card_kind_help_repository.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _matchHelp = CardKindHelp(
  kind: 'match',
  title: 'Match pairs',
  blurb: 'Drag each trait onto the item it belongs to.',
  steps: [
    'Drag a trait onto its match',
    'It locks in when it is right',
    'Clear the board with no wrong drops',
  ],
);

class _FakeHelp extends CardKindHelpRepository {
  _FakeHelp({this.entry = _matchHelp});

  final CardKindHelp? entry;

  @override
  Future<CardKindHelp?> getForKind(String kind) async => entry;
}

void main() {
  Future<void> pump(
    WidgetTester tester, {
    CardKindHelp? entry = _matchHelp,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardKindHelpRepositoryProvider.overrideWith(
            (ref) => _FakeHelp(entry: entry),
          ),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.darkRoast,
          home: const Scaffold(body: CardCueRow(cue: CardCue.match)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('names the format in the design phrase, set upper case', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('MATCH · DRAG TO PAIR'), findsOneWidget);
  });

  testWidgets('is announced as written, not shouted', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    expect(find.bySemanticsLabel('Match · drag to pair'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('takes the accent, which is what the design colours it', (
    tester,
  ) async {
    for (final theme in [AppTheme.cupping, AppTheme.darkRoast]) {
      await pump(tester, theme: theme);

      final cue = tester.widget<Text>(find.text('MATCH · DRAG TO PAIR'));
      expect(cue.style?.color, theme.extension<MoodColors>()!.accent);
    }
  });

  group('the help button', () {
    testWidgets('carries a 44x44 target and the How to play label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester);

      expect(find.bySemanticsLabel(howToPlayLabel), findsOneWidget);
      expect(
        tester.getSize(find.bySemanticsLabel(howToPlayLabel)),
        const Size(44, 44),
      );

      handle.dispose();
    });

    testWidgets('opens the drawer on the bank entry behind it', (tester) async {
      await pump(tester);

      await tester.tap(find.text('?'));
      await tester.pumpAndSettle();

      expect(find.text(howToPlayLabel.toUpperCase()), findsOneWidget);
      expect(find.text('Match pairs'), findsOneWidget);
      expect(find.text(_matchHelp.blurb), findsOneWidget);
      for (final step in _matchHelp.steps) {
        expect(find.text(step), findsOneWidget);
      }
      expect(find.text('01'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
    });

    testWidgets('Got it is the only way out, and it closes', (tester) async {
      await pump(tester);
      await tester.tap(find.text('?'));
      await tester.pumpAndSettle();

      expect(find.byType(PrimaryButton), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Match pairs'), findsNothing);
    });

    testWidgets('never draws with nothing behind it', (tester) async {
      await pump(tester, entry: null);

      expect(find.text('?'), findsNothing);
      expect(find.text('MATCH · DRAG TO PAIR'), findsOneWidget);
    });
  });
}
