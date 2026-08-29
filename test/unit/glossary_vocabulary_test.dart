import 'dart:io';

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
      (
        // Added with the Plus gate (#89). The paid tier is the highest-
        // consequence copy in the app — it is what a learner reads at the
        // moment they decide to pay — and the surface that got it wrong was
        // the one the design made most prominent.
        pattern: RegExp(r'\bPremium\b'),
        term: 'Premium',
        instead: 'Plus',
        allow: const <String>{},
        why:
            'the paid tier is Plus everywhere (#30); the Profile card that '
            'said Premium was deleted with #355, and the gate sheet that '
            'replaced it must not reintroduce the word',
      ),
    ];

/// The live documentation — everything an agent reads as current.
///
/// History is not swept: `CHANGELOG` records what shipped under the name it
/// shipped under, `archive/` is a tombstone ledger, and `plans/` and
/// `research/` are bannered point-in-time snapshots. Rewriting any of them
/// would make the record wrong rather than current. `prototype/` is the
/// read-only design source.
const _liveDocRoots = <String>[
  'docs/design',
  'docs/adr',
  'docs/agents',
  'learning',
];

/// The history that is deliberately **not** swept, named one file at a time.
///
/// A deny-list rather than a list of what to check, so a doc added tomorrow is
/// guarded by default. The opposite — naming the live files — silently stops
/// covering anything new, which is the failure this whole guard exists to stop.
const _historyNotSwept = <String>{'docs/CHANGELOG.md', 'docs/decisions.md'};

/// The repo-root docs an agent reads as current.
///
/// `CONTEXT.md` is **not** among them, and cannot be: it is where a retired
/// term is retired, so its `_Avoid_` lines name every word these rules forbid.
/// Sweeping the glossary would mean the glossary could not state its own rule.
const _rootDocs = <String>['CLAUDE.md', 'AGENTS.md', 'README.md'];

/// Prose is held to a **narrower** rule than copy, and deliberately so.
///
/// In `lib/` any occurrence is a string a learner reads, so the bare term is
/// the rule. Documentation is different: it has to be able to *name* a retired
/// term in order to retire it — `CONTEXT.md` lists it under _Avoid_, §5.1 says
/// *"'XP' no longer appears in the source"*, `PRODUCT.md` describes the engine
/// the app used to have. A guard that failed on those would fire on every
/// honest sentence and teach everyone to bypass it.
///
/// So docs are checked for the **misuse shape** — the term used as the name of
/// the thing — rather than for the term. Only *Field Guide* qualifies, because
/// only it has one: the category reading is always *module Field Guide(s)* or
/// *Field Guide card*, while every legitimate use is an authored card title
/// (*Beans Field Guide*) or ordinary English (*A FIELD GUIDE TO COFFEE*).
///
/// *XP* has no such shape and is not swept here; §5.1 and `PRODUCT.md` discuss
/// it correctly and at length.
///
/// **Favourites is deliberately absent too, and was tried.** The glossary rules
/// it out as a name for the Saved shelf, but `docs/design/` exists to describe
/// the prototype — it quotes that screen's own copy (*Title "Favorites"*), it
/// names its seed data, and `learning/` names the real Dart
/// identifiers of a `FavoritesScreen` the course had the learner build. Every
/// one is legitimate, and no pattern separates them from misuse. A guard firing
/// on all of those would be bypassed within a week, so the term stays a review
/// matter rather than a checked one.
final _ruledOutInProse =
    <({RegExp pattern, String term, String instead, String why})>[
      (
        pattern: RegExp(
          r'\b(module\s+Field\s+Guides?|Field\s+Guide\s+cards?)\b',
          caseSensitive: false,
        ),
        term: 'Field Guide (as the category)',
        instead: 'Module Reward',
        why:
            'the five module collectibles are Module Rewards (#106, #222); '
            'they keep their authored titles — Beans Field Guide and its '
            'siblings — so a title is fine and a category is not',
      ),
      (
        // No innocent sense: nothing in this product is a "training" anything
        // any more, so the bare term is the rule here.
        pattern: RegExp(
          r'\btraining\s+(cards?|guides?)\b',
          caseSensitive: false,
        ),
        term: 'training card / training guide',
        instead: 'visual guide',
        why: 'the eight illustrated references are visual guides (#106)',
      ),
    ];

Iterable<File> _liveDocs() sync* {
  for (final root in _liveDocRoots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    yield* dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'));
  }
  // Every top-level doc except the history, so a new one is covered the day it
  // lands rather than the day someone remembers to list it.
  yield* Directory('docs')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .where((file) => !_historyNotSwept.contains(file.path));

  for (final path in _rootDocs) {
    final file = File(path);
    if (file.existsSync()) yield file;
  }
}

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

  for (final rule in _ruledOutInProse) {
    test('no live doc says ${rule.term}', () {
      final offenders = <String>[];
      for (final file in _liveDocs()) {
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          if (rule.pattern.hasMatch(lines[index])) {
            offenders.add('${file.path}:${index + 1}: ${lines[index].trim()}');
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
