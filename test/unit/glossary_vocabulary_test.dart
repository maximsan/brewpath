import 'package:flutter_test/flutter_test.dart';

import '../support/dart_sources.dart';

/// Terms `CONTEXT.md` lists under _Avoid_, held out of what a learner reads.
///
/// A sweep is a one-off; this is what keeps it swept. Both entries below are
/// here because a rename pass already missed something: twelve strings said
/// *XP* when #160 opened, and #212 renamed a wrong number rather than removing
/// it — touching a line is what makes it look reviewed.
///
/// **Scoped to strings a learner can read**, not to identifiers. Storage still
/// carries `totalXp` and `xpEarned` column names, which cannot move without the
/// migration #79 owns, and the content banks carry `fieldGuide*` collectible
/// kinds, which are the read-only prototype's wire vocabulary. Neither is what
/// this rule protects.
///
/// A term belongs here once the glossary rules it *and* it has appeared on
/// screen. Listing every _Avoid_ entry pre-emptively would fail on words with
/// innocent senses — "score" is wrong for points and right in "Best score".
final _ruledOut = <({RegExp pattern, String term, String instead, String why})>[
  (
    pattern: RegExp(r'\bXP\b'),
    term: 'XP',
    instead: 'points',
    why:
        '§5.1 rules the currency is points "throughout — code, copy and '
        'mascot state" (#16, #160)',
  ),
  (
    // Case-sensitive, because the collectible is a proper noun and the
    // ordinary English phrase is not it: onboarding offers "A quiet field
    // guide. No pressure." to the just-curious learner, which is about the
    // app's tone and has nothing to do with the five module collectibles.
    // Matching it would let this guard rewrite good copy.
    pattern: RegExp(r'\bField Guides?\b'),
    term: 'Field Guide',
    instead: 'Module Reward',
    why:
        'the five module collectibles are Module Rewards — the design calls '
        'the screen that hands one over ModuleRewardCardScreen, and the code '
        'already said MODULE_REWARDS (#106, #222)',
  ),
];

void main() {
  for (final rule in _ruledOut) {
    test('no user-facing string says ${rule.term}', () {
      final offenders = <String>[];
      for (final file in dartSourcesUnder('lib')) {
        for (final literal in stringLiteralsIn(file.readAsStringSync())) {
          if (rule.pattern.hasMatch(literal)) {
            offenders.add('${file.path}: "$literal"');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'say ${rule.instead}, not ${rule.term} — ${rule.why}.\n'
            'Found:\n${offenders.join('\n')}',
      );
    });
  }
}
