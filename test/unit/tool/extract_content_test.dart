import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Drives `tool/extract_content.js` as a subprocess, because the behaviour
/// under test is the process contract: what it writes, and what it refuses to
/// write. Node is a CI dependency; `flutter test` stays the only test command.
const _script = 'tool/extract_content.js';
const _prototype = 'prototype';

/// Where a normal run writes — the output that ships in the bundle.
const _committed = 'assets/content/generated';

/// The three files a run reads. Copied into a scratch directory so a broken
/// reference can be seeded without touching `prototype/`, which is read-only.
const _sourceFiles = ['data.jsx', 'dictionary-data.jsx', 'brew-challenge.jsx'];

const _expectedBanks = [
  'modules.json',
  'lessons.json',
  'collectibles.json',
  'dictionary_terms.json',
  'brew_challenges.json',
];

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

  void breakReference(String source, String from, String to) {
    final file = File(p.join(source, 'brew-challenge.jsx'));
    final patched = file.readAsStringSync().replaceFirst(from, to);
    expect(patched, isNot(file.readAsStringSync()), reason: 'seed did nothing');
    file.writeAsStringSync(patched);
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
    final out = dir('out');

    final result = _run(source, out);

    expect(result.exitCode, isNot(0));
    expect(result.stderr.toString(), contains('cM1-renamed'));
    expect(Directory(out).listSync(), isEmpty);
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
}
