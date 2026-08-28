import 'dart:io';

import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The overlays that stay fixed, transcribed from the design bundle CSS
/// (`prototype/index.html`). `--veil` / `--veil-strong` are *not* here: they
/// are the page background pulled over the page, so they follow the mood and
/// live on `MoodColors` instead.
const _spec = <String, Color>{
  '--scrim': Color.fromRGBO(0x1B, 0x16, 0x14, 0.58),
  '--scrim-ink': Color(0xFFFBF7EE),
  '--dim-modal': Color.fromRGBO(0x0E, 0x0A, 0x07, 0.62),
};

Map<String, Color> get _tokens => {
  '--scrim': OverlayColors.scrim.color,
  '--scrim-ink': OverlayColors.scrimInk,
  '--dim-modal': OverlayColors.dimModal.color,
};

void main() {
  group('the fixed overlays', () {
    test('are the 3 the design ships, valued 1:1', () {
      expect(_tokens, _spec);
    });

    test('the modal dim darkens the canvas in both moods', () {
      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(
          Color.alphaBlend(
            OverlayColors.dimModal.color,
            mood.bg,
          ).computeLuminance(),
          lessThan(mood.bg.computeLuminance()),
          reason:
              'a dim bound to the mood would lighten the Cupping canvas; a '
              'modal must darken in both moods.',
        );
      }
    });

    test('the scrim darkens the media it sits on', () {
      // Media is whatever the photograph holds — a bright sky or a dark roast
      // shot — and it does not invert with the theme, so the scrim has to pull
      // all of it down without knowing the mood.
      for (final media in const [
        Color(0xFFFFFFFF),
        Color(0xFF808080),
        Color(0xFFC79A63),
      ]) {
        expect(
          Color.alphaBlend(
            OverlayColors.scrim.color,
            media,
          ).computeLuminance(),
          lessThan(media.computeLuminance()),
        );
      }
    });

    test('the scrim ink stays lighter than the scrim over white media', () {
      expect(
        OverlayColors.scrimInk.computeLuminance(),
        greaterThan(
          Color.alphaBlend(
            OverlayColors.scrim.color,
            const Color(0xFFFFFFFF),
          ).computeLuminance(),
        ),
      );
    });
  });

  test('the design declares them identically in every mood', () {
    // Comments are stripped first: the bundle explains --dim-modal in prose
    // that names the very tokens being parsed, and would be read as a value.
    final css = File(
      'prototype/index.html',
    ).readAsStringSync().replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    final declarations = <String, Set<String>>{};
    for (final match in RegExp(
      r'(--scrim|--scrim-ink|--dim-modal)\s*:\s*([^;]+);',
    ).allMatches(css)) {
      declarations
          .putIfAbsent(match.group(1)!, () => <String>{})
          .add(match.group(2)!.trim());
    }

    expect(declarations.keys, unorderedEquals(_spec.keys));
    declarations.forEach((name, values) {
      expect(
        values,
        hasLength(1),
        reason:
            '$name is declared differently per mood in the design bundle, so '
            'it is a theme value after all and does not belong here: $values',
      );
    });
  });
}
