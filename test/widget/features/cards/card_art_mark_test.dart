import 'dart:convert';
import 'dart:io';

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/cards/presentation/card_art_mark.dart';
import 'package:brew_path/features/cards/presentation/card_art_well.dart';
import 'package:brew_path/features/cards/presentation/card_tint.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const double _fallbackSize = 64;
const MoodColors _mood = MoodColors.darkRoast;

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.darkRoast,
    home: Scaffold(
      body: Center(child: SizedBox(width: 150, child: child)),
    ),
  ),
);

SvgAssetLoader _loaderOf(WidgetTester tester) =>
    tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
        as SvgAssetLoader;

Map<String, String> get _sentinels =>
    ((jsonDecode(File('assets/card_art/index.json').readAsStringSync())
                as Map<String, dynamic>)['sentinels']
            as Map<String, dynamic>)
        .cast<String, String>();

Color _hex(String value) =>
    Color(0xFF000000 | int.parse(value.substring(1), radix: 16));

ColorMapper _mapperOf(WidgetTester tester) => _loaderOf(tester).colorMapper!;

Color _mapped(WidgetTester tester, String token) => _mapperOf(
  tester,
).substitute('id', 'path', 'fill', _hex(_sentinels[token]!));

void main() {
  group('what it draws', () {
    testWidgets('the art the design drew for the kind', (tester) async {
      await _pump(
        tester,
        const CardArtMark(
          kind: 'botanical',
          fallback: AppIcon.beans,
          fallbackSize: _fallbackSize,
        ),
      );

      expect(_loaderOf(tester).assetName, 'assets/card_art/botanical.svg');
    });

    testWidgets('a kind with no art falls back to the module mark', (
      tester,
    ) async {
      await _pump(
        tester,
        const CardArtMark(
          kind: 'not-a-kind',
          fallback: AppIcon.beans,
          fallbackSize: _fallbackSize,
        ),
      );

      // `IconMark` is itself an `SvgPicture`, so asserting one exists proves
      // nothing — what matters is which asset is loaded.
      expect(find.byType(IconMark), findsOneWidget);
      expect(
        _loaderOf(tester).assetName,
        isNot(startsWith('assets/card_art/')),
      );
    });

    testWidgets('the fallback keeps the accent the mark had before', (
      tester,
    ) async {
      await _pump(
        tester,
        const CardArtMark(
          kind: 'not-a-kind',
          fallback: AppIcon.beans,
          fallbackSize: _fallbackSize,
        ),
      );

      // The tile and the sheet both drew the module mark in the accent. The
      // ambient IconTheme is muted ink, so leaving the colour off would have
      // quietly changed it.
      expect(
        tester.widget<IconMark>(find.byType(IconMark)).color,
        _mood.accent,
      );
    });

    testWidgets('the fallback takes its own size, not the slot’s', (
      tester,
    ) async {
      await _pump(
        tester,
        const CardArtMark(
          kind: 'not-a-kind',
          fallback: AppIcon.beans,
          fallbackSize: _fallbackSize,
        ),
      );

      // Blown up to the slot it would be cropped by the well's scale.
      expect(
        tester.widget<IconMark>(find.byType(IconMark)).size,
        _fallbackSize,
      );
    });
  });

  group('the colours it maps', () {
    testWidgets('a mood token becomes the mood’s own colour', (
      tester,
    ) async {
      await _pump(
        tester,
        const CardArtMark(
          kind: 'layers',
          fallback: AppIcon.beans,
          fallbackSize: _fallbackSize,
        ),
      );

      // Named one by one: a loop that accepts "any token" passes a sentinel
      // wired to the wrong one.
      expect(_mapped(tester, 'var(--sage)'), _mood.sage);
      expect(_mapped(tester, 'var(--berry)'), _mood.berry);
      expect(_mapped(tester, 'var(--ink)'), _mood.ink);
      expect(_mapped(tester, 'var(--ink-mute)'), _mood.inkMute);
      expect(_mapped(tester, 'var(--rule)'), _mood.rule);
      expect(_mapped(tester, 'var(--surface)'), _mood.surface);
      expect(_mapped(tester, 'var(--surface-2)'), _mood.surface2);
      expect(_mapped(tester, 'var(--accent)'), _mood.accent);
    });

    testWidgets('an illustration token becomes the palette’s', (
      tester,
    ) async {
      await _pump(
        tester,
        const CardArtMark(
          kind: 'layers',
          fallback: AppIcon.beans,
          fallbackSize: _fallbackSize,
        ),
      );

      expect(_mapped(tester, 'var(--art-cherry-skin)'), ArtColors.cherrySkin);
      expect(_mapped(tester, 'var(--art-cherry-seed)'), ArtColors.cherrySeed);
      expect(_mapped(tester, 'var(--art-cream)'), ArtColors.cream);
      expect(_mapped(tester, 'var(--art-ripe)'), ArtColors.ripe);
      expect(_mapped(tester, 'var(--art-roast-dark)'), ArtColors.roastDark);
      expect(_mapped(tester, 'var(--art-seed-crease)'), ArtColors.seedCrease);
    });

    testWidgets('every sentinel the extractor writes is mapped', (
      tester,
    ) async {
      await _pump(
        tester,
        const CardArtMark(
          kind: 'layers',
          fallback: AppIcon.beans,
          fallbackSize: _fallbackSize,
        ),
      );

      for (final entry in _sentinels.entries) {
        expect(
          _mapped(tester, entry.key),
          isNot(_hex(entry.value)),
          reason:
              '${entry.key} still renders as its stand-in, which paints '
              'magenta over the drawing',
        );
      }
    });
  });

  group('the well it sits in', () {
    ColoredBox wellOf(WidgetTester tester) => tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(CardArtWell),
        matching: find.byType(ColoredBox),
      ),
    );

    testWidgets('washes the art in the kind’s own tint', (tester) async {
      await _pump(
        tester,
        const CardArtWell(kind: 'botanical', fallback: AppIcon.beans),
      );

      expect(wellOf(tester).color, cardTint(_mood, 'botanical'));
      expect(_loaderOf(tester).assetName, 'assets/card_art/botanical.svg');
    });

    testWidgets('a kind with no tint still gets a well, on the surface', (
      tester,
    ) async {
      await _pump(
        tester,
        const CardArtWell(kind: 'not-a-kind', fallback: AppIcon.beans),
      );

      expect(wellOf(tester).color, _mood.surface);
      expect(find.byType(IconMark), findsOneWidget);
    });
  });
}
