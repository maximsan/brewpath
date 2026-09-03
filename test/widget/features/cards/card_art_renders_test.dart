import 'package:brew_path/app/app_theme.dart';
import 'package:brew_path/core/icons/app_icon.dart';
import 'package:brew_path/features/cards/domain/card_art.dart';
import 'package:brew_path/features/cards/presentation/card_art_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every art, actually drawn.
///
/// The extractor proves the markup is *written*; only a renderer proves it can
/// be *read*. These are machine-translated from JSX, so a malformed attribute
/// or an element `flutter_svg` cannot parse would otherwise reach a learner's
/// screen as a blank tile with nothing failing anywhere.
void main() {
  for (final kind in cardArtKinds) {
    testWidgets('$kind draws', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkRoast,
          home: Scaffold(
            body: Center(
              child: CardArtMark(
                kind: kind,
                fallback: AppIcon.beans,
                size: 150,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
