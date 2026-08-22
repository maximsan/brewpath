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
final _ruledOut =
    <
      ({
        RegExp pattern,
        String term,
        String instead,
        String why,
        Set<String> allow,
      })
    >[
      (
        pattern: RegExp(r'\bXP\b'),
        term: 'XP',
        instead: 'points',
        allow: const <String>{},
        why:
            '§5.1 rules the currency is points "throughout — code, copy and '
            'mascot state" (#16, #160)',
      ),
      (
        // **Case-insensitive, with the innocent phrases named.**
        // Capitalisation looked like the discriminator and is not. The
        // design shouts the term for the collectible itself —
        // `onboarding.jsx` carries `eyebrow: 'FIELD GUIDE READY'` on a
        // `state: 'module'` moment — while `settings.jsx`'s "A FIELD GUIDE
        // TO COFFEE" is the ordinary English phrase in the same case. A
        // case-sensitive rule lets the first through; an unqualified one
        // rewrites the second. So the split is by string, not by shape.
        pattern: RegExp(r'\bField Guides?\b', caseSensitive: false),
        term: 'Field Guide',
        instead: 'Module Reward',
        // A guidebook, not the collectible: the subtitle offered to the learner
        // who is "Just curious about coffee". Add a line here only for the
        // ordinary English sense, never to excuse the collectible.
        allow: const <String>{'A quiet field guide. No pressure.'},
        why:
            'the five module collectibles are Module Rewards — the design '
            'names the screen that hands one over ModuleRewardCardScreen, '
            'and the code already said MODULE_REWARDS (#106, #222)',
      ),
    ];

void main() {
  for (final rule in _ruledOut) {
    test('no user-facing string says ${rule.term}', () {
      final offenders = <String>[];
      for (final file in dartSourcesUnder('lib')) {
        for (final literal in stringLiteralsIn(file.readAsStringSync())) {
          if (rule.allow.contains(literal)) continue;
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
