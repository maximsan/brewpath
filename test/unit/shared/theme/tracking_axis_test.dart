import 'dart:io';

import 'package:brew_path/shared/theme/app_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/dart_sources.dart';

/// Tracking is not a number a call site passes.
///
/// `_Rung` bakes one tracking into each step, so `AppText.label()` could only
/// ever letter at the design's 0.14em — and sixteen call sites worked around
/// that by naming their own, fifteen in logical pixels and one through an
/// `OffToken`. Most were a rounding-by-eye of a real design value; the Coffee
/// Challenge kickers sat at 0.6px against `.challenge-kicker`'s 1.33.
///
/// `AppTracking` is the axis that makes the workaround unnecessary, so this
/// asks who is allowed to name a spacing at all. Its sibling
/// `font_weight_call_sites_test.dart` asks the same of weight.
void main() {
  /// The files allowed to name a letter spacing, and why each earns it.
  const sanctioned = <String, String>{
    'lib/shared/theme/app_text.dart':
        'the ladder itself — the one place a tracking becomes pixels',
    'lib/app/tab_bar_theme.dart':
        'reads OffTokens.tabLabelTracking, a sanctioned exception at 0.18em',
    'lib/core/widgets/tap_cue.dart':
        'reads OffTokens.tapCueTracking, a sanctioned exception at 0.24em',
    'lib/features/lessons/presentation/cards/grinder_dial_view.dart':
        'draws on a canvas grid rather than a rung, so it has no rung to '
        'letter against — see grinder_dial.dart',
  };

  /// What counts as naming a spacing.
  ///
  /// `letterSpacingDelta` is here because `TextStyle.apply` is the other door
  /// to the same property, and the whitespace is loose because `letterSpacing
  /// :` is the same instruction to the formatter's eye and to Dart's.
  const spellings = <String, String>{
    r'letterSpacing\s*:': 'TextStyle.letterSpacing',
    r'letterSpacingDelta\s*:': 'TextStyle.apply(letterSpacingDelta:)',
  };

  test('no call site in lib/ letters its own', () {
    final offenders = <String>[];

    for (final file in dartSourcesUnder('lib')) {
      if (sanctioned.containsKey(file.path)) continue;
      final source = withoutComments(file.readAsStringSync());
      spellings.forEach((pattern, what) {
        for (final match in RegExp(pattern).allMatches(source)) {
          offenders.add('${file.path} reaches for $what: ${match.group(0)}');
        }
      });
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'tracking belongs to the ladder. If the design letters the '
          'component differently, add the value to AppTracking with its '
          '`index.html` citation; if it is a genuine exception, register it '
          'in OffTokens with its reason:\n${offenders.join('\n')}',
    );
  });

  test('the guard would catch a spacing reintroduced by either spelling', () {
    // A guard nobody has seen fail is a guard nobody knows is wired up.
    const reintroduced = '''
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: _eyebrowLetterSpacing,
      ),
      style: AppText.label().apply(letterSpacingDelta : 0.4),
    ''';

    final caught = [
      for (final pattern in spellings.keys)
        ...RegExp(pattern).allMatches(reintroduced).map((m) => m.group(0)!),
    ];

    expect(caught, hasLength(2));
  });

  test('every sanctioned file still earns its exemption', () {
    for (final entry in sanctioned.entries) {
      final source = withoutComments(File(entry.key).readAsStringSync());

      expect(
        spellings.keys.any((pattern) => RegExp(pattern).hasMatch(source)),
        isTrue,
        reason:
            '${entry.key} is exempted as "${entry.value}" but no longer '
            'letters anything — drop the exemption rather than leaving a '
            'hole in the guard',
      );
    }
  });

  group('AppTracking', () {
    test('carries the design values, in em', () {
      expect(AppTracking.reading.em, 0.02);
      expect(AppTracking.figure.em, 0.04);
      expect(AppTracking.meta.em, 0.08);
      expect(AppTracking.hint.em, 0.12);
      expect(AppTracking.marker.em, 0.16);
    });

    test(
      'runs tightest to widest, so a step is comparable to its neighbour',
      () {
        final ems = AppTracking.values.map((step) => step.em).toList();

        expect(ems, orderedEquals(List<double>.from(ems)..sort()));
      },
    );

    test('resolves against the rung it is used on', () {
      const labelSize = 11.0;
      const microSize = 9.5;

      expect(
        AppText.label(tracking: AppTracking.meta).letterSpacing,
        closeTo(AppTracking.meta.em * labelSize, 0.0001),
      );
      expect(
        AppText.micro(tracking: AppTracking.hint).letterSpacing,
        closeTo(AppTracking.hint.em * microSize, 0.0001),
      );
    });

    test('left off, a rung keeps the design’s 0.14em smallcaps rule', () {
      const smallcaps = 0.14;
      const labelSize = 11.0;
      const microSize = 9.5;

      expect(
        AppText.label().letterSpacing,
        closeTo(smallcaps * labelSize, 0.0001),
      );
      expect(
        AppText.micro().letterSpacing,
        closeTo(smallcaps * microSize, 0.0001),
      );
    });
  });
}
