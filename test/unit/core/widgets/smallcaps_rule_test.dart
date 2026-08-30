import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The three sites the divergence register named in §7.1 — the shared section
/// header, the dictionary entry's block labels, and Settings' group labels.
///
/// Not "every smallcaps in the app": more sites letter their own kickers, and
/// whether each is a mistake or a deliberate off-token choice is the owner's
/// call, recorded in `OffTokens` the way the tab bar's is. This pins the three
/// that were ruled on.
const _theThreeNamedSites = <String>[
  'lib/core/widgets/section_header.dart',
  'lib/features/dictionary/presentation/term_entry_body.dart',
  // Settings' group labels moved into the section widget the whole settings
  // surface now builds them with (#395): one label component, so the screen
  // and the four screens behind it cannot letter their headings differently.
  'lib/features/profile/presentation/settings/settings_sub_screen.dart',
];

/// Source with comments removed, so prose about `letterSpacing:` does not read
/// as an instance of it. Same shape as `unthemed_constants_guard_test.dart`.
String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

void main() {
  group('the three sites §7.1 named', () {
    test('each builds a SmallcapsLabel rather than a Text of its own', () {
      for (final path in _theThreeNamedSites) {
        expect(
          _code(path),
          contains('SmallcapsLabel('),
          reason:
              '$path hand-rolled the design’s one smallcaps rule; it should '
              'construct the widget that carries it',
        );
      }
    });

    test('and none of them letters its own', () {
      final offenders = _theThreeNamedSites
          .where((path) => _code(path).contains('letterSpacing:'))
          .toList();

      // Tracking, not weight. Weight is a separate sweep (#380), and one of
      // these files still carries a `w600` on an unrelated tile — asserting on
      // it here would tie this rule to a fault it does not own.
      expect(
        offenders,
        isEmpty,
        reason:
            'tracking belongs to the rule, not to a call site picking a number '
            'that looks about right:\n${offenders.join('\n')}',
      );
    });
  });
}
