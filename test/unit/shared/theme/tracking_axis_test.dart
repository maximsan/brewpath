import 'dart:io';

import 'package:brew_path/shared/theme/app_text.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter_test/flutter_test.dart';

/// The only places in `lib/` allowed to name a `letterSpacing`.
///
/// Everywhere else asks the ladder for one, so a component cannot be lettered
/// by eye at a call site the way fourteen of them were (#410).
const _sanctioned = <String, String>{
  'lib/shared/theme/app_text.dart':
      'the ladder itself — the one place a tracking is resolved to pixels',
  'lib/app/tab_bar_theme.dart':
      'reads OffTokens.tabLabelTracking, a sanctioned exception',
  'lib/core/widgets/tap_cue.dart':
      'reads OffTokens.tapCueTracking, a sanctioned exception',
  'lib/features/lessons/presentation/cards/grinder_dial_view.dart':
      'draws on a canvas grid rather than a rung, so it has no rung to letter '
      'against — see grinder_dial.dart',
};

/// Source with comments removed, so prose about `letterSpacing:` does not read
/// as an instance of it. Same shape as `smallcaps_rule_test.dart`.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

/// Every Dart file under `lib/`, generated ones included — a `.g.dart` that
/// letters its own would be just as off-ladder.
List<String> _libFiles() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path)
        .where((path) => path.endsWith('.dart'))
        .toList()
      ..sort();

void main() {
  group('tracking belongs to the ladder', () {
    test('no call site letters its own', () {
      final offenders = _libFiles()
          .where((path) => !_sanctioned.containsKey(path))
          .where((path) => _code(path).contains('letterSpacing:'))
          .toList();

      expect(
        offenders,
        isEmpty,
        reason:
            'these files pick a letterSpacing instead of asking AppText for '
            'one. If the design letters the component differently, add the '
            'value to AppTracking with its `index.html` citation; if it is a '
            'genuine exception, put it in OffTokens with its reason:\n'
            '${offenders.join('\n')}',
      );
    });

    test('and every sanctioned file still earns its place', () {
      for (final entry in _sanctioned.entries) {
        expect(
          File(entry.key).existsSync(),
          isTrue,
          reason: '${entry.key} is exempted but no longer exists',
        );
        expect(
          _code(entry.key),
          contains('letterSpacing'),
          reason:
              '${entry.key} is exempted as "${entry.value}" but no longer '
              'names a letterSpacing — drop the exemption',
        );
      }
    });
  });

  group('AppTracking', () {
    test('carries the design values, in em', () {
      expect(AppTracking.meta.em, 0.08);
      expect(AppTracking.hint.em, 0.12);
    });

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

      expect(AppText.label().letterSpacing, closeTo(smallcaps * 11, 0.0001));
      expect(AppText.micro().letterSpacing, closeTo(smallcaps * 9.5, 0.0001));
    });
  });

  test('the register keeps only the two trackings that are exceptions', () {
    final trackings = OffTokens.register
        .where((token) => token.value is double)
        .toList();

    expect(
      trackings,
      contains(OffTokens.tabLabelTracking),
      reason: '0.18em is the tab bar alone, too wide to be a rung',
    );
    expect(
      trackings,
      contains(OffTokens.tapCueTracking),
      reason: '0.24em is the tap cue alone, too wide to be a rung',
    );
  });
}
