import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// Dart source never *cites* a prototype file in prose.
///
/// `CLAUDE.md` rules it out: *"Never cite `prototype/` from `lib/` — no file
/// names, no line numbers."* The prototype is replaced wholesale, so a design
/// drop invalidates every line number at once and a rename invalidates the
/// rest — silently. A reader who follows a stale reference lands on unrelated
/// code with nothing to tell them it is wrong, which is worse than no
/// reference at all. Nothing checked it, so ~180 accumulated (#479, #521).
///
/// **Prose, not code.** A path in code is a dependency: the drift guards read
/// the design's CSS and the extractor reads its `.jsx`, and both fail loudly
/// the moment a file moves. That noise is the point of them, and the opposite
/// of the silence this forbids. So the rule reads comments and leaves string
/// literals alone.
///
/// **What to write instead**, in the order worth trying:
/// - a value that looks arbitrary keeps the design's own — `padding: 26px
///   24px`, `cubic-bezier(0.34, 1.1, 0.4, 1)`. It survives a re-drop, it is
///   greppable however the design is reorganised, and it is what stops a
///   correct number being "tidied" onto the spacing scale.
/// - a decision cites the ruling that made it, an ADR or an issue.
///   `docs/README.md` puts those *above* the design, so a comment citing the
///   design for a decision is citing the losing source.
/// - a component keeps the design's own name for it — `.form-row`,
///   `APP_GUIDE_SECTIONS` — which is greppable and does not carry a line.
/// - anything else goes. Most of them restated the code underneath.
void main() {
  /// Named by extension rather than by the `prototype/` prefix: most of what
  /// this found cited the file bare — ``(`settings.jsx:163`)`` — and a rule
  /// that only caught the prefixed form would have missed two thirds of them.
  final citation = RegExp(r'[\w-]+\.(?:jsx|html)');

  /// This test has to name what it forbids in order to forbid it.
  const guardItself = 'test/unit/prototype_citation_guard_test.dart';

  test('no comment cites a prototype file', () {
    final offenders = <String>[
      for (final root in const ['lib', 'test'])
        for (final file in dartSourcesUnder(root))
          if (file.path != guardItself)
            for (final comment in commentsIn(file.readAsStringSync()))
              if (citation.firstMatch(comment) case final hit?)
                '${file.path}  ${hit[0]}',
    ];

    expect(
      offenders,
      isEmpty,
      reason:
          'a comment may not name a prototype file — see this test for what '
          'to write instead. Found ${offenders.length}:\n'
          '${offenders.join('\n')}',
    );
  });
}
