import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:brew_path/shared/theme/app_overlay.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:brew_path/shared/theme/overlay_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The blur half of the four overlays, read back out of the design.
///
/// The colours were transcribed once and the radii were not (#379), which was
/// possible because the design states them in a sentence rather than in a
/// declaration. So this reads the sentence: the Scrims-and-dims rule in
/// `prototype/ds-content.js` names a radius per overlay *role*, and each role
/// is mapped below to the token that plays it. A design change to any of the
/// four numbers fails here rather than going unnoticed for another port.
///
/// The bundle's own CSS is checked too, where it has an overlay to check — the
/// sheet backdrop is the only one of the four the prototype actually renders.

/// The blur radius each of the four overlays carries, by the role the design's
/// ruling names it under.
Map<String, double> get _radiusByRole => {
  'modal dim': OverlayColors.dimModal.blurRadius,
  'covering wash': MoodColors.darkRoast.veilStrong.blurRadius,
  'media control': OverlayColors.scrim.blurRadius,
};

/// The design's ruling, as one line of `ds-content.js`.
///
/// Reading prose is the only way to read this rule: the design states the four
/// radii in a sentence and nowhere else. If the sentence is reworded away, that
/// is itself worth stopping for — the rule these tokens answer to has moved.
String get _blurRuling {
  final ruling = File('prototype/ds-content.js')
      .readAsLinesSync()
      .where((line) => line.contains('Blur is part of the token'))
      .toList();

  expect(
    ruling,
    hasLength(1),
    reason:
        'the Scrims-and-dims blur ruling is no longer one line of '
        'prototype/ds-content.js — re-read it and re-point these tests',
  );

  return ruling.single;
}

void main() {
  group("the design's blur ruling", () {
    test('names a radius per role, and the tokens carry those radii', () {
      final stated = <String, double>{
        for (final match in RegExp(
          r'(\d+)px (?:for|behind) (?:the|a) ([a-z ]+?)(?=,|\.|$)',
        ).allMatches(_blurRuling))
          match.group(2)!: double.parse(match.group(1)!),
      };

      expect(
        stated,
        _radiusByRole,
        reason:
            'the ruling reads: $_blurRuling\n'
            "Blur is part of the token's job — a radius stated there and not "
            'carried by the token is the half of the overlay that gets '
            'dropped.',
      );
    });

    test('gives the plain veil none, and the veil carries none', () {
      expect(_blurRuling, contains('none on the plain veil'));

      for (final mood in [MoodColors.cupping, MoodColors.darkRoast]) {
        expect(mood.veil.blurRadius, 0);
        expect(mood.veil.isBlurred, isFalse);
        expect(
          mood.veil.backdropFilter,
          isNull,
          reason:
              'a zero-sigma BackdropFilter still costs a saveLayer over the '
              'whole screen behind it',
        );
      }
    });

    test('the three that blur all say so', () {
      for (final overlay in [
        OverlayColors.dimModal,
        OverlayColors.scrim,
        MoodColors.darkRoast.veilStrong,
      ]) {
        expect(overlay.isBlurred, isTrue);
        expect(overlay.backdropFilter, isNotNull);
      }
    });
  });

  test('the bundle blurs its sheet backdrop at the modal dim radius', () {
    // `.sheet-backdrop` is the one overlay the prototype renders from these
    // tokens, and it writes both halves in the same rule — the pair this
    // ticket exists to keep together, in the design's own hand.
    final css = File('prototype/index.html').readAsStringSync();
    final rule = RegExp(
      r'\.sheet-backdrop\s*\{([^}]*)\}',
    ).firstMatch(css)?.group(1);

    expect(
      rule,
      isNotNull,
      reason: 'the bundle no longer has a sheet backdrop',
    );
    expect(rule, contains('background: var(--dim-modal);'));

    final radius = RegExp(
      r'(?<!-webkit-)backdrop-filter:\s*blur\((\d+)px\)',
    ).firstMatch(rule!);

    expect(radius, isNotNull);
    expect(
      double.parse(radius!.group(1)!),
      OverlayColors.dimModal.blurRadius,
    );
  });

  group('AppOverlay', () {
    test('carries the design px straight through as the filter sigma', () {
      // CSS `blur(<length>)` defines that length as the Gaussian's standard
      // deviation, which is what ImageFilter.blur calls sigma — so the two are
      // the same number and any scaling here would be a bug.
      const overlay = AppOverlay(color: Color(0xFF000000), blurRadius: 5);

      expect(
        overlay.backdropFilter,
        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      );
    });

    test('is one value: colour and radius compare together', () {
      const color = Color(0xFF102030);
      const overlay = AppOverlay(color: color, blurRadius: 5);

      expect(overlay, const AppOverlay(color: color, blurRadius: 5));
      expect(overlay, isNot(const AppOverlay(color: color, blurRadius: 3)));
      expect(
        overlay,
        isNot(const AppOverlay(color: Color(0xFF302010), blurRadius: 5)),
      );
      expect(
        overlay.hashCode,
        const AppOverlay(color: color, blurRadius: 5).hashCode,
      );
    });
  });
}
