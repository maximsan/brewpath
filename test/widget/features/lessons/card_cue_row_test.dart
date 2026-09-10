import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/core/widgets/icon_badge.dart';
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
  Future<Map<String, CardKindHelp>> getByKind() async {
    final entry = this.entry;
    return entry == null ? {} : {entry.kind: entry};
  }
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

  group('the well', () {
    Future<void> openDrawer(WidgetTester tester, {CardKindHelp? entry}) async {
      await pump(tester, entry: entry ?? _matchHelp);
      await tester.tap(find.text('?'));
      await tester.pumpAndSettle();
    }

    testWidgets("heads the drawer with this kind's own mark", (tester) async {
      await openDrawer(tester);

      final well = find.byType(HelpWell);
      expect(well, findsOneWidget);
      expect(tester.widget<HelpWell>(well).mark, AppIcon.match);
      expect(
        tester
            .widget<IconMark>(
              find.descendant(of: well, matching: find.byType(IconMark)),
            )
            .icon,
        AppIcon.match,
      );
    });

    testWidgets('is a 44 square holding a 22 mark', (tester) async {
      await openDrawer(tester);

      expect(tester.getSize(find.byType(HelpWell)), const Size(44, 44));
      expect(
        tester
            .widget<IconMark>(
              find.descendant(
                of: find.byType(HelpWell),
                matching: find.byType(IconMark),
              ),
            )
            .size,
        22,
      );
      expect(
        tester.getSize(
          find.descendant(
            of: find.byType(HelpWell),
            matching: find.byType(IconMark),
          ),
        ),
        const Size(22, 22),
      );
    });

    testWidgets('is an outlined well, in the rule and the second surface', (
      tester,
    ) async {
      await openDrawer(tester);

      final mood = AppTheme.darkRoast.extension<MoodColors>()!;
      final badge = tester.widget<IconBadge>(
        find.descendant(
          of: find.byType(HelpWell),
          matching: find.byType(IconBadge),
        ),
      );

      expect(badge.background, mood.surface2);
      expect(badge.borderColor, mood.rule);
      expect(badge.foreground, mood.ink);
    });

    testWidgets('sits a 14 gutter from the eyebrow beside it', (tester) async {
      await openDrawer(tester);

      final wellRight = tester.getTopRight(find.byType(HelpWell)).dx;
      final eyebrowLeft = tester
          .getTopLeft(find.text(howToPlayLabel.toUpperCase()))
          .dx;

      expect(eyebrowLeft - wellRight, 14);
    });
  });
}
