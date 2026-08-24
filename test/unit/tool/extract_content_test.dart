import 'dart:convert';
import 'dart:io';

import 'package:brew_path/shared/repositories/bank_envelope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Drives `tool/extract_content.js` as a subprocess, because the behaviour
/// under test is the process contract: what it writes, and what it refuses to
/// write. Node is a CI dependency; `flutter test` stays the only test command.
const _script = 'tool/extract_content.js';
const _prototype = 'prototype';

/// Where a normal run writes — the output that ships in the bundle.
const _committed = 'assets/content/generated';

/// The six files a run reads. Copied into a scratch directory so a broken
/// reference can be seeded without touching `prototype/`, which is read-only.
const _sourceFiles = [
  'data.jsx',
  'dictionary-data.jsx',
  'brew-challenge.jsx',
  'screens.jsx',
  'lesson.jsx',
  'bean-anatomy.jsx',
  'customize.jsx',
  'practical.jsx',
];

const _expectedBanks = [
  'modules.json',
  'lessons.json',
  'collectibles.json',
  'dictionary_terms.json',
  'dictionary_categories.json',
  'visual_guides.json',
  'brew_challenges.json',
  'mini_games.json',
  'card_kind_help.json',
  'mini_game_content.json',
  'grove_varieties.json',
  'grove_lights.json',
];

/// The entry whose rounds live in `bean-anatomy.jsx` behind a `window` getter —
/// the one game that comes back silently empty unless the extractor assembles
/// the cross-file dependency before evaluating.
const _bagpickFormatId = 'g-bagpick';

/// The seven mini-games that shipped before the catalog grew.
///
/// **Frozen ids, not a count.** ADR-0005 grows the catalog to roughly a dozen
/// games and keeps these seven, because they are persisted in stored day-sets
/// and cannot be renumbered. Asserting a size instead would fail the next time
/// a game is authored (#162) while proving nothing about the ids that matter —
/// the mistake this repo has already made with the points ceiling and the
/// collectible count.
const _frozenGameIds = <String>[
  'g-match',
  'g-flavor',
  'g-quiz',
  'g-bagpick',
  'g-tastefix',
  'g-calibrate',
  'g-sequence',
];

/// Every authored entry in the prototype's card-kind help map.
const _helpKindCount = 10;

/// The grove's two axes, both decided and closed: three coffee species, four
/// lights. A count that moves means the decision moved, so the extractor
/// refuses rather than shipping a chooser the ruling does not describe.
const _varietyCount = 3;
const _lightCount = 4;

/// A written bank's whole envelope, decoded.
Map<String, dynamic> _envelope(String out, String bank) =>
    jsonDecode(File(p.join(out, bank)).readAsStringSync())
        as Map<String, dynamic>;

/// The `items` list of a written bank, decoded.
List<Map<String, dynamic>> _items(String out, String bank) =>
    (_envelope(out, bank)['items'] as List).cast<Map<String, dynamic>>();

ProcessResult _run(String source, String out) => Process.runSync('node', [
  _script,
  '--source',
  source,
  '--out',
  out,
]);

void main() {
  late Directory scratch;

  setUp(() => scratch = Directory.systemTemp.createTempSync('extract_content'));
  tearDown(() => scratch.deleteSync(recursive: true));

  String dir(String name) =>
      (Directory(p.join(scratch.path, name))..createSync(recursive: true)).path;

  /// A copy of the prototype's data files that a test may corrupt.
  String seededSource() {
    final source = dir('source');
    for (final file in _sourceFiles) {
      File(p.join(_prototype, file)).copySync(p.join(source, file));
    }
    return source;
  }

  void seedCorruption(String source, String fileName, String from, String to) {
    final file = File(p.join(source, fileName));
    final patched = file.readAsStringSync().replaceFirst(from, to);
    expect(patched, isNot(file.readAsStringSync()), reason: 'seed did nothing');
    file.writeAsStringSync(patched);
  }

  void breakReference(String source, String from, String to) =>
      seedCorruption(source, 'brew-challenge.jsx', from, to);

  /// The refusal contract every corruption test asserts: non-zero exit, the
  /// named culprits on stderr, and nothing written.
  void expectRefusal(String source, {required List<String> naming}) {
    final out = dir('out');
    final result = _run(source, out);

    expect(result.exitCode, isNot(0));
    for (final name in naming) {
      expect(result.stderr.toString(), contains(name));
    }
    expect(Directory(out).listSync(), isEmpty);
  }

  test('a clean run writes every bank', () {
    final out = dir('out');
    final result = _run(_prototype, out);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    expect(
      Directory(out).listSync().map((e) => p.basename(e.path)),
      unorderedEquals(_expectedBanks),
    );
  });

  // Without this, a rename in `prototype/` stays green until someone happens to
  // rerun the extractor: every other test here reads the committed output, so
  // the committed output is what they keep agreeing with. The script's output
  // is deterministic, so byte equality is the whole check.
  test('the committed banks match a fresh extraction', () {
    final out = dir('out');

    expect(_run(_prototype, out).exitCode, 0);

    for (final bank in _expectedBanks) {
      expect(
        File(p.join(out, bank)).readAsStringSync(),
        File(p.join(_committed, bank)).readAsStringSync(),
        reason: '$bank is stale — rerun `node $_script`',
      );
    }
  });

  test('every written bank is stamped with the schema version', () {
    final out = dir('out');

    expect(_run(_prototype, out).exitCode, 0);

    for (final bank in _expectedBanks) {
      expect(
        _envelope(out, bank)['schemaVersion'],
        contentSchemaVersion,
        reason: '$bank went out unstamped',
      );
    }
  });

  // The version is written in JavaScript and read in Dart, which cannot share a
  // constant, so bumping one side alone has to fail here rather than on a
  // learner's device.
  //
  // Strictly this is implied by the two tests above — byte-identical committed
  // output, and a fresh run stamped with the Dart constant. It is kept for what
  // it buys on failure: it needs no `node`, and it names the disagreement
  // instead of reporting a diff in a 233KB file.
  test('the committed banks carry the version this build reads', () {
    for (final bank in _expectedBanks) {
      expect(
        _envelope(_committed, bank)['schemaVersion'],
        contentSchemaVersion,
        reason:
            '$bank disagrees with contentSchemaVersion — bump SCHEMA_VERSION '
            'in $_script and rerun it, or bump the Dart constant to match',
      );
    }
  });

  test('a broken reference is refused, and nothing is written', () {
    final source = seededSource();
    breakReference(source, "lessonId: 'm1l1'", "lessonId: 'm1l99'");
    final out = dir('out');

    final result = _run(source, out);

    expect(result.exitCode, isNot(0));
    expect(Directory(out).listSync(), isEmpty);
  });

  test('the refusal names the offending card and the broken reference', () {
    final source = seededSource();
    breakReference(source, "lessonId: 'm1l1'", "lessonId: 'm1l99'");

    final stderr = _run(source, dir('out')).stderr.toString();

    expect(stderr, contains('bc-m1l1'));
    expect(stderr, contains('m1l99'));
  });

  // The bank exists so its 31 lesson, module and collectible pointers sit
  // inside the validated graph. No screen reads it yet; this is what it is for.
  test('a challenge pointing at a renamed collectible fails the run', () {
    final source = seededSource();
    breakReference(source, "cardId: 'cM1'", "cardId: 'cM1-renamed'");

    expectRefusal(source, naming: ['cM1-renamed']);
  });

  test('the catalog keeps every frozen game id and emits the help map', () {
    final out = dir('out');

    expect(_run(_prototype, out).exitCode, 0);

    final catalog =
        jsonDecode(File(p.join(out, 'mini_games.json')).readAsStringSync())
            as Map<String, dynamic>;
    final ids = (catalog['items'] as List)
        .cast<Map<String, dynamic>>()
        .map((game) => game['id'])
        .toList();
    expect(
      ids,
      containsAll(_frozenGameIds),
      reason: 'a frozen id is persisted in stored day-sets and cannot be lost',
    );
    expect(ids.toSet(), hasLength(ids.length), reason: 'ids are unique');

    final help =
        jsonDecode(File(p.join(out, 'card_kind_help.json')).readAsStringSync())
            as Map<String, dynamic>;
    expect((help['items'] as List).length, _helpKindCount);
  });

  test('the grove carries three species and four lights', () {
    final out = dir('out');

    expect(_run(_prototype, out).exitCode, 0);

    final varieties = _items(out, 'grove_varieties.json');
    expect(varieties.length, _varietyCount);
    expect(
      varieties.map((variety) => variety['id']),
      containsAll(<String>['arabica', 'robusta', 'liberica']),
    );

    final lights = _items(out, 'grove_lights.json');
    expect(lights.length, _lightCount);
    // The bank is the id vocabulary's authority: these are the ids that ship,
    // against the camel-cased ones the snapshot doc once named.
    expect(
      lights.map((light) => light['id']),
      containsAll(<String>['daylight', 'goldenhour', 'moonlit', 'frost']),
    );
  });

  test('every species carries the copy the chooser renders', () {
    final out = dir('out');
    expect(_run(_prototype, out).exitCode, 0);

    for (final variety in _items(out, 'grove_varieties.json')) {
      for (final field in const [
        'name',
        'latin',
        'share',
        'use',
        'origin',
        'grows',
        'cup',
        'tell',
      ]) {
        expect(
          variety[field],
          isA<String>().having((copy) => copy.isNotEmpty, 'non-empty', isTrue),
          reason: "${variety['id']} has no $field",
        );
      }
    }
  });

  test('Arabica is the identity treatment — the unfiltered real art', () {
    final out = dir('out');
    expect(_run(_prototype, out).exitCode, 0);

    final arabica = _items(
      out,
      'grove_varieties.json',
    ).firstWhere((variety) => variety['id'] == 'arabica');

    expect(arabica['leaf'], isEmpty);
    expect(arabica['shape'], anyOf(isEmpty, 'none'));
  });

  test('a grove declaration lost to a rename is refused by name', () {
    final source = seededSource();
    seedCorruption(
      source,
      'customize.jsx',
      'window.TREE_VARIETIES =',
      'window.TREE_VARIETIES_X =',
    );

    expectRefusal(source, naming: ['TREE_VARIETIES', 'customize.jsx']);
  });

  test('a fourth species is refused — the count is the decision', () {
    final source = seededSource();
    seedCorruption(source, 'customize.jsx', "  { id: 'liberica'", """
  { id: 'excelsa', name: 'Excelsa', latin: 'Coffea excelsa', share: '<1%', use: 'Blends',
    origin: 'Chad', grows: 'Low', cup: 'Tart, fruity',
    tell: 'A fourth species nobody decided to ship.',
    shape: 'none', leaf: '', drop: 'later' },
  { id: 'liberica'""");

    expectRefusal(source, naming: ['grove varieties', '4']);
  });

  test('a duplicated species id is refused by name', () {
    final source = seededSource();
    seedCorruption(
      source,
      'customize.jsx',
      "{ id: 'robusta'",
      "{ id: 'arabica'",
    );

    expectRefusal(source, naming: ['arabica', 'duplicates']);
  });

  test('a species that lost its copy is refused by field', () {
    final source = seededSource();
    seedCorruption(
      source,
      'customize.jsx',
      "origin: 'West Africa · Vietnam'",
      "origin: ''",
    );

    expectRefusal(source, naming: ['robusta', 'origin']);
  });

  test('the rollout note survives extraction, unread by anything', () {
    final out = dir('out');
    expect(_run(_prototype, out).exitCode, 0);

    // Emitted because the extractor renames and drops nothing. Nothing in the
    // app may gate on it — all three species ship — but losing it silently
    // would mean the bank no longer mirrors its source.
    for (final variety in _items(out, 'grove_varieties.json')) {
      expect(variety['drop'], isA<String>(), reason: "${variety['id']}");
    }
  });

  test('a light filter carrying junk outside its terms is refused', () {
    final source = seededSource();
    seedCorruption(
      source,
      'customize.jsx',
      "filter: 'saturate(0.5) brightness(1.12) contrast(0.94)'",
      "filter: 'saturate(0.5) garbage junk'",
    );

    expectRefusal(source, naming: ['frost', 'garbage junk']);
  });

  test('a filter argument that is not a value is refused', () {
    final source = seededSource();
    seedCorruption(
      source,
      'customize.jsx',
      "filter: 'saturate(0.5) brightness(1.12) contrast(0.94)'",
      "filter: 'saturate(abc)'",
    );

    expectRefusal(source, naming: ['frost', 'abc']);
  });

  test('a filter primitive the app cannot compose is refused', () {
    final source = seededSource();
    seedCorruption(
      source,
      'customize.jsx',
      "filter: 'saturate(0.5) brightness(1.12) contrast(0.94)'",
      "filter: 'blur(2px)'",
    );

    expectRefusal(source, naming: ['frost', 'blur']);
  });

  test('a fifth light is refused — the count is the decision', () {
    final source = seededSource();
    seedCorruption(
      source,
      'customize.jsx',
      "  { id: 'frost',",
      "  { id: 'dusk', name: 'Dusk', note: 'Late', swatch: '#333', "
          "filter: 'brightness(0.9)' },\n  { id: 'frost',",
    );

    expectRefusal(source, naming: ['grove lights', '5']);
  });

  test('a species missing a field the model requires is refused', () {
    final source = seededSource();
    // Dropped entirely rather than emptied: `leaf` is legitimately empty on
    // Arabica, so only absence is the failure.
    seedCorruption(
      source,
      'customize.jsx',
      "shape: 'scale(1.2, 0.9)', leaf:",
      "shape: 'scale(1.2, 0.9)', leafless:",
    );

    expectRefusal(source, naming: ['robusta', 'leaf']);
  });

  test('a catalog format whose kind has no help entry is refused', () {
    final source = seededSource();
    seedCorruption(
      source,
      'screens.jsx',
      "id: 'g-match', kind: 'match'",
      "id: 'g-match', kind: 'matchless'",
    );

    expectRefusal(source, naming: ['g-match', 'matchless']);
  });

  test('a duplicated catalog format id is refused by name', () {
    final source = seededSource();
    seedCorruption(
      source,
      'screens.jsx',
      "id: 'g-flavor', kind: 'flavor'",
      "id: 'g-match', kind: 'flavor'",
    );

    expectRefusal(source, naming: ['g-match', 'duplicates']);
  });

  test('a renamed catalog declaration is refused by name', () {
    final source = seededSource();
    seedCorruption(
      source,
      'screens.jsx',
      'const MINI_GAMES =',
      'const MINI_GAMES_X =',
    );

    expectRefusal(source, naming: ['MINI_GAMES', 'screens.jsx']);
  });

  test('a renamed help declaration is refused by name', () {
    final source = seededSource();
    seedCorruption(
      source,
      'lesson.jsx',
      'const CARD_KIND_HELP =',
      'const CARD_KIND_HELP_X =',
    );

    expectRefusal(source, naming: ['CARD_KIND_HELP', 'lesson.jsx']);
  });

  test('every game carries non-empty rounds, bagpick included', () {
    final out = dir('out');

    expect(_run(_prototype, out).exitCode, 0);

    final content =
        jsonDecode(
              File(p.join(out, 'mini_game_content.json')).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final items = (content['items'] as List).cast<Map<String, dynamic>>();
    // The two banks describe the same catalog, whatever its size: a game in
    // the catalog with no rounds is the failure worth catching.
    final catalog =
        jsonDecode(File(p.join(out, 'mini_games.json')).readAsStringSync())
            as Map<String, dynamic>;
    expect(
      items.map((item) => item['id']).toSet(),
      (catalog['items'] as List)
          .cast<Map<String, dynamic>>()
          .map((game) => game['id'])
          .toSet(),
    );
    for (final item in items) {
      expect(
        item['rounds'] as List,
        isNotEmpty,
        reason: "format '${item['id']}' extracted with no rounds",
      );
    }

    final bagpick = items.singleWhere((item) => item['id'] == _bagpickFormatId);
    expect(bagpick['rounds'] as List, isNotEmpty);
  });

  test('a format whose rounds come back empty is refused by name', () {
    final source = seededSource();
    seedCorruption(
      source,
      'lesson.jsx',
      "get 'g-bagpick'() { return window.BAGPICK_ROUNDS || []; },",
      "'g-bagpick': [],",
    );

    expectRefusal(source, naming: [_bagpickFormatId, 'has no rounds']);
  });

  test('renaming the bagpick rounds declaration is refused by name', () {
    final source = seededSource();
    seedCorruption(
      source,
      'bean-anatomy.jsx',
      'const BAGPICK_ROUNDS =',
      'const BAGPICK_ROUNDS_X =',
    );

    expectRefusal(source, naming: ['BAGPICK_ROUNDS', 'bean-anatomy.jsx']);
  });

  test('a quiz round whose answer is not a boolean is refused', () {
    final source = seededSource();
    seedCorruption(
      source,
      'lesson.jsx',
      "answer: true, explain: 'True — it is the seed of the coffee cherry.'",
      "answer: 'yes', explain: 'True — it is the seed of the coffee cherry.'",
    );

    expectRefusal(source, naming: ['g-quiz', 'not true or false']);
  });

  test(
    'a format missing from the content bank is refused in both directions',
    () {
      final source = seededSource();
      seedCorruption(source, 'lesson.jsx', "'g-match': [", "'g-matchx': [");

      expectRefusal(
        source,
        naming: [
          "format 'g-match': has no entry",
          "content 'g-matchx': matches no catalog format",
        ],
      );
    },
  );

  test('a round whose kind lost its help entry is refused per round', () {
    final source = seededSource();
    seedCorruption(source, 'lesson.jsx', '  tastefix: {', '  tastefixx: {');

    expectRefusal(
      source,
      naming: ["content 'g-tastefix' round 1", 'no help entry'],
    );
  });

  test('a run never writes into the prototype', () {
    final before = Directory(
      _prototype,
    ).listSync().map((e) => '${e.path}:${e.statSync().modified}').toList();

    _run(_prototype, dir('out'));

    final after = Directory(
      _prototype,
    ).listSync().map((e) => '${e.path}:${e.statSync().modified}').toList();
    expect(after, before);
  });

  group('the visual guides', () {
    void seedGuide(String source, String from, String to) =>
        seedCorruption(source, 'data.jsx', from, to);

    void seedWords(String source, String from, String to) =>
        seedCorruption(source, 'practical.jsx', from, to);

    test('a clean run emits eight guides with their words and unlocks', () {
      final out = dir('out');
      expect(_run(_prototype, out).exitCode, 0);

      final guides = _items(out, 'visual_guides.json');
      expect(guides, hasLength(8));
      expect(
        guides.map((guide) => guide['visualGuide']),
        containsAll(<String>['roast', 'grind', 'variety', 'distribution']),
      );
      for (final guide in guides) {
        for (final field in ['label', 'title', 'summary', 'fact']) {
          expect(guide[field], isNotNull, reason: '${guide['id']} $field');
        }
        expect((guide['unlock'] as Map)['lesson'], isNotNull);
        expect((guide['meta'] as List).length, inInclusiveRange(2, 3));
      }
    });

    test('a guide stripped of its words is refused by field', () {
      final source = seededSource();
      seedWords(source, "title: 'Roast Levels',", "title: '',");
      expectRefusal(source, naming: ['g-roast', 'title']);
    });

    test(
      'a guide whose unlock is not the earliest teaching lesson is refused',
      () {
        final source = seededSource();
        // grind is taught in three lessons; m4l1 is the first of them.
        seedGuide(
          source,
          "{ id: 'g-grind', earned: false, unlock: { lesson: 'm4l1' }",
          "{ id: 'g-grind', earned: false, unlock: { lesson: 'm4l3' }",
        );
        expectRefusal(source, naming: ['g-grind', 'm4l1']);
      },
    );

    test('a guide unlocking at a lesson that does not exist is refused', () {
      final source = seededSource();
      seedGuide(
        source,
        "{ id: 'g-roast', earned: false, unlock: { lesson: 'm3l1' }",
        "{ id: 'g-roast', earned: false, unlock: { lesson: 'm9l9' }",
      );
      expectRefusal(source, naming: ['g-roast', 'm9l9']);
    });

    test('a lesson visual whose subject has no guide is refused', () {
      final source = seededSource();
      // The defect this check exists for: an authored subject with no card.
      // Named by the message, not by the subject — `varietal` contains
      // `variety`, so asserting the subject alone proves nothing.
      seedGuide(source, "visualGuide: 'variety',", "visualGuide: 'varietal',");
      expectRefusal(source, naming: ['which has no guide', 'dead end']);
    });

    test('a second card for one subject is refused', () {
      final source = seededSource();
      // The registry entry, not the lesson card — `data.jsx` carries both, and
      // the shorter string finds the lesson's visual first.
      seedGuide(
        source,
        "kind: 'visualGuide', visualGuide: 'distribution',",
        "kind: 'visualGuide', visualGuide: 'roast',",
      );
      expectRefusal(source, naming: ['second card', 'roast']);
    });

    test('a guide whose words are only whitespace is refused', () {
      final source = seededSource();
      seedWords(source, "title: 'Roast Levels',", "title: '   ',");
      expectRefusal(source, naming: ['g-roast', 'title']);
    });

    test('a meta row that is not a label and a value is refused', () {
      final source = seededSource();
      seedGuide(
        source,
        "meta: [['LIGHT', 'Bright · acidic']",
        "meta: [['LIGHT']",
      );
      expectRefusal(source, naming: ['g-roast', 'meta']);
    });

    /// The two data sets that reached no bank for a release.
    ///
    /// Both were words all along — the cherry's layers in a file the guide
    /// join never opened, the servings in a field it never named. Neither
    /// broke anything: a field nothing reads resolves to nothing and fails no
    /// check, which is why these assert the content is *present*, not merely
    /// that the run succeeds.
    group('the cross-section and the servings table', () {
      void seedLayers(String source, String from, String to) =>
          seedCorruption(source, 'bean-anatomy.jsx', from, to);

      Map<String, dynamic> guideNamed(String out, String subject) => _items(
        out,
        'visual_guides.json',
      ).firstWhere((guide) => guide['visualGuide'] == subject);

      test('a clean run carries six cherry layers, outside in', () {
        final out = dir('out');
        expect(_run(_prototype, out).exitCode, 0);

        final layers = (guideNamed(out, 'anatomy')['layers'] as List)
            .cast<Map<String, dynamic>>();

        expect(layers, hasLength(6));
        expect(
          layers.map((layer) => layer['n']),
          ['01', '02', '03', '04', '05', '06'],
        );
        expect(layers[2]['name'], 'Mucilage', reason: 'the section opens here');
        for (final layer in layers) {
          for (final field in ['name', 'latin', 'fate', 'note']) {
            expect(layer[field], isNotEmpty, reason: '${layer['n']} $field');
          }
        }
      });

      test('a layer carries its words and not its geometry', () {
        final out = dir('out');
        expect(_run(_prototype, out).exitCode, 0);

        final layer =
            (guideNamed(out, 'anatomy')['layers'] as List).first
                as Map<String, dynamic>;
        expect(
          layer.keys,
          unorderedEquals(<String>['n', 'name', 'latin', 'fate', 'note']),
          reason: 'the app draws the rings; a radius here would go stale',
        );
      });

      test('a clean run carries the servings table with its figures', () {
        final out = dir('out');
        expect(_run(_prototype, out).exitCode, 0);

        final rows = (guideNamed(out, 'caffeine')['rows'] as List)
            .cast<Map<String, dynamic>>();

        expect(rows, hasLength(4));
        expect(
          rows.map((row) => row['name']),
          ['Decaf', 'Espresso', 'Drip coffee', 'Cold brew'],
        );
        for (final row in rows) {
          expect(row['serve'], isNotEmpty, reason: '${row['name']} serving');
          expect(row['mg'], isA<int>(), reason: '${row['name']} figure');
        }
      });

      test('only the guides that authored them carry them', () {
        final out = dir('out');
        expect(_run(_prototype, out).exitCode, 0);

        for (final guide in _items(out, 'visual_guides.json')) {
          final subject = guide['visualGuide'];
          expect(
            guide.containsKey('layers'),
            subject == 'anatomy',
            reason: '$subject layers',
          );
          expect(
            guide.containsKey('rows'),
            subject == 'caffeine',
            reason: '$subject rows',
          );
        }
      });

      test('a layer stripped of a word is refused by field', () {
        final source = seededSource();
        seedLayers(source, "latin: 'exocarp'", "latin: ''");
        expectRefusal(source, naming: ['cherry layers', 'latin']);
      });

      test('a seventh cherry layer is refused — the count is the fact', () {
        final source = seededSource();
        seedLayers(
          source,
          "  { n: '06', name: 'Seed',",
          "  { n: '07', name: 'Husk', latin: 'x', fate: 'y', note: 'z' },\n"
              "  { n: '06', name: 'Seed',",
        );
        expectRefusal(source, naming: ['cherry layers', 'a cherry has 6']);
      });

      test('a serving row whose figure is not a number is refused', () {
        final source = seededSource();
        seedWords(source, 'mg: 95 }', "mg: '95' }");
        expectRefusal(source, naming: ['g-caffeine', 'mg']);
      });

      test('a serving row stripped of its serving is refused', () {
        final source = seededSource();
        seedWords(source, "serve: '30 ml shot'", "serve: ''");
        expectRefusal(source, naming: ['g-caffeine', 'serve']);
      });
    });
  });
}
