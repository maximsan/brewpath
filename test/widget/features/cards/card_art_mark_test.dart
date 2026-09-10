import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/cards/presentation/card_art_mark.dart';
import 'package:brew_path/features/cards/presentation/card_art_well.dart';
import 'package:brew_path/features/cards/presentation/card_tint.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

    testWidgets('a hairline stroke resolves to the palette ink', (
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

      expect(
        _mapperOf(tester).substitute(
          'id',
          'circle',
          'stroke',
          _hex(_sentinels['var(--art-hairline)']!),
        ),
        ArtColors.hairline,
      );
    });

    testWidgets(
      "the layers rings draw their hairline at the design's opacity",
      (
        tester,
      ) async {
        // Rendered at 4x the viewBox, so the outer ring's 0.7 stroke is 2.8px
        // wide and its centre pixel carries full stroke coverage.
        const scale = 4.0;
        const size = 100 * scale;
        final boundary = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.cupping,
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: boundary,
                  child: const SizedBox(
                    width: size,
                    height: size,
                    child: CardArtMark(
                      kind: 'layers',
                      fallback: AppIcon.beans,
                      fallbackSize: _fallbackSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        // The asset decodes off the test clock.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump();

        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await tester.runAsync(() => render.toImage());
        final bytes = await tester.runAsync(
          () => image!.toByteData(format: ui.ImageByteFormat.rawStraightRgba),
        );
        Color at(double x, double y) {
          final offset = ((y * size) + x).toInt() * 4;
          return Color.fromARGB(
            bytes!.getUint8(offset + 3),
            bytes.getUint8(offset),
            bytes.getUint8(offset + 1),
            bytes.getUint8(offset + 2),
          );
        }

        // The outer ring: centre (50, 48), r 40 — its stroke sits at x = 90 and
        // its fill, cherry skin, just inside at x = 88.
        final fill = at(88 * scale, 48 * scale);
        // A quarter unit inside the edge: still under the stroke, over the fill.
        final ring = at(89.75 * scale, 48 * scale);
        expect(fill, ArtColors.cherrySkin, reason: 'the fill under the ring');
        expect(ring.a, 1.0, reason: 'the ring pixel is over the fill');

        // Hairline ink at the design's `strokeOpacity="0.24"`, over the fill.
        final expected = Color.alphaBlend(
          ArtColors.hairline.withValues(alpha: 0.24),
          ArtColors.cherrySkin,
        );
        for (final (channel, got, want) in [
          ('r', ring.r, expected.r),
          ('g', ring.g, expected.g),
          ('b', ring.b, expected.b),
        ]) {
          expect(
            (got - want).abs(),
            lessThan(0.06),
            reason: 'ring $channel is $got, the blended hairline is $want',
          );
        }
      },
    );

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
