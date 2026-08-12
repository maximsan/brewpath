import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The un-themed half of the token layer: values that must never flip with the
/// mood. Documentation says they don't; this says they *can't*.
///
/// Each file is checked for the two properties that make mood-dependence
/// unrepresentable rather than merely discouraged:
///
///  1. the holder is an `abstract final class` — it cannot be extended,
///     implemented, mixed in or instantiated, so there is no instance to vary
///     and no subclass to override a value;
///  2. the code names nothing it could vary *on* — no `BuildContext`, no
///     `Theme`, no `MoodColors` — so an `of(context)` accessor cannot be
///     written without first importing the very thing this layer excludes.
const _unthemedFiles = <String>[
  'lib/shared/theme/art_colors.dart',
  'lib/shared/theme/overlay_colors.dart',
  'lib/shared/theme/app_radii.dart',
  'lib/shared/theme/app_spacing.dart',
  'lib/shared/theme/off_token.dart',
];

/// Prose is exempt: these files *discuss* `BuildContext` and moods at length,
/// and should. Only what the compiler sees is checked.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

/// Whether [code] names [identifier] as an identifier of its own — not as a
/// fragment of a longer one, which would flag `material.dart` for "art".
bool _mentions(String code, String identifier) =>
    RegExp('\\b$identifier\\b').hasMatch(code);

void main() {
  for (final path in _unthemedFiles) {
    group(path, () {
      test('holds its constants on an abstract final class', () {
        expect(
          _code(path),
          contains('abstract final class'),
          reason:
              'a plain class can be extended or implemented, and a subclass '
              'is a place to make these values vary',
        );
      });

      test('names nothing it could vary by mood on', () {
        for (final forbidden in const [
          'BuildContext',
          'Theme',
          'ThemeExtension',
          'MoodColors',
          'context',
        ]) {
          expect(
            _mentions(_code(path), forbidden),
            isFalse,
            reason:
                '$path refers to $forbidden, which is the first half of an '
                'accessor that varies by mood',
          );
        }
      });
    });
  }

  test('the escape hatch cannot be subclassed into a mood accessor', () {
    expect(
      _code('lib/shared/theme/off_token.dart'),
      contains('final class OffToken<'),
      reason:
          'a plain OffToken could be extended with a value getter that reads '
          'the mood — the one thing this layer exists to prevent',
    );
  });

  test('the mood tokens do not reach back the other way', () {
    final moodColors = _code('lib/shared/theme/mood_colors.dart');

    for (final forbidden in const [
      'scrim',
      'dimModal',
      'ArtColors',
      'OverlayColors',
    ]) {
      expect(
        _mentions(moodColors, forbidden),
        isFalse,
        reason:
            'MoodColors has taken on $forbidden — a fixed value held as a '
            'theme value is one mood-block edit away from flipping',
      );
    }
  });
}
