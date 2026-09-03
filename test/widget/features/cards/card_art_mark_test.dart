import 'dart:convert';
import 'dart:io';

import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/core/icons/icon_mark.dart';
import 'package:brew_path/features/cards/presentation/card_art_mark.dart';
import 'package:brew_path/shared/theme/art_colors.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 56.0;

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.darkRoast,
    home: Scaffold(body: Center(child: child)),
  ),
);

SvgAssetLoader _loaderOf(WidgetTester tester) =>
    tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
        as SvgAssetLoader;

/// The sentinels the extractor actually wrote, so this cannot pass by agreeing
/// with a stale copy of the list.
Map<String, String> get _sentinels =>
    ((jsonDecode(File('assets/card_art/index.json').readAsStringSync())
                as Map<String, dynamic>)['sentinels']
            as Map<String, dynamic>)
        .cast<String, String>();

Color _hex(String value) =>
    Color(0xFF000000 | int.parse(value.substring(1), radix: 16));

void main() {
  testWidgets('draws the art the design drew for the kind', (tester) async {
    await _pump(
      tester,
      const CardArtMark(
        kind: 'botanical',
        fallback: AppIcon.beans,
        size: _size,
      ),
    );

    expect(_loaderOf(tester).assetName, 'assets/card_art/botanical.svg');
  });

  testWidgets('a kind with no art falls back to the module mark', (
    tester,
  ) async {
    // Content can name a kind before anyone re-runs the extractor. A card with
    // no picture beats a card with a hole in it.
    await _pump(
      tester,
      const CardArtMark(
        kind: 'not-a-kind',
        fallback: AppIcon.beans,
        size: _size,
      ),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(IconMark), findsOneWidget);
  });

  testWidgets('every sentinel the extractor writes is mapped to a token', (
    tester,
  ) async {
    await _pump(
      tester,
      const CardArtMark(
        kind: 'layers',
        fallback: AppIcon.beans,
        size: _size,
      ),
    );
    final mapper = _loaderOf(tester).colorMapper;
    expect(mapper, isNotNull);

    const mood = MoodColors.darkRoast;
    for (final entry in _sentinels.entries) {
      final sentinel = _hex(entry.value);
      final mapped = mapper!.substitute('id', 'path', 'fill', sentinel);

      expect(
        mapped,
        isNot(sentinel),
        reason:
            '${entry.key} still renders as its stand-in, which paints magenta '
            'over the drawing',
      );
      // Mood tokens flip; the illustration palette does not. Both are real
      // colours from a real palette, which is all this can assert generically.
      expect(
        mapped == mood.ink ||
            mapped == mood.inkMute ||
            mapped == mood.rule ||
            mapped == mood.surface ||
            mapped == mood.surface2 ||
            mapped == mood.accent ||
            mapped == mood.sage ||
            mapped == mood.berry ||
            ArtColors.byTokenName.containsValue(mapped),
        isTrue,
        reason: '${entry.key} maps to a colour from neither palette',
      );
    }
  });
}
