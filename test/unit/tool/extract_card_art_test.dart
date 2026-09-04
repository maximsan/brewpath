import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Drives `tool/extract_card_art.js` as a subprocess, because the behaviour
/// under test is the process contract: what it writes, and — the point of the
/// thing — what it refuses to write. Node is a CI dependency; `flutter test`
/// stays the only test command.
const _script = 'tool/extract_card_art.js';
const _source = 'prototype/screens.jsx';

/// What a normal run writes, and ships in the bundle.
const _committed = 'assets/card_art';

late Directory _scratch;

/// A prototype directory holding [screens], so a broken drawing can be seeded
/// without touching `prototype/`, which is read-only.
Directory _seed(String screens) {
  final dir = Directory(p.join(_scratch.path, 'src'))
    ..createSync(recursive: true);
  File(p.join(dir.path, 'screens.jsx')).writeAsStringSync(screens);
  return dir;
}

ProcessResult _run({Directory? source, Directory? out}) =>
    Process.runSync('node', [
      _script,
      if (source != null) ...['--source', source.path],
      if (out != null) ...['--out', out.path],
    ]);

void main() {
  late String screens;

  setUpAll(() => screens = File(_source).readAsStringSync());

  setUp(() {
    _scratch = Directory.systemTemp.createTempSync('card-art-test');
    addTearDown(() => _scratch.deleteSync(recursive: true));
  });

  test('a clean run writes every art the design draws', () {
    final out = Directory(p.join(_scratch.path, 'out'));
    final result = _run(out: out);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final written = out
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.svg'))
        .length;
    expect(written, 37);
  });

  test('what it writes is what is committed', () {
    // The assets in the repo are the extractor's output, not a hand-edited
    // copy of it — otherwise a design change would reach the app only where
    // someone remembered to re-run this.
    final out = Directory(p.join(_scratch.path, 'out'));
    expect(_run(out: out).exitCode, 0);

    for (final fresh in out.listSync().whereType<File>()) {
      final committed = File(p.join(_committed, p.basename(fresh.path)));
      expect(committed.existsSync(), isTrue, reason: fresh.path);
      expect(
        committed.readAsStringSync(),
        fresh.readAsStringSync(),
        reason: '${p.basename(fresh.path)} differs — re-run $_script',
      );
    }
  });

  test('a paint that maps to no token fails the run, and writes nothing', () {
    final out = Directory(p.join(_scratch.path, 'out'));
    final source = _seed(
      screens.replaceFirst('fill="var(--sage)"', 'fill="#C0FFEE"'),
    );

    final result = _run(source: source, out: out);

    expect(result.exitCode, isNot(0));
    expect(result.stderr.toString(), contains('#C0FFEE'));
    expect(
      out.existsSync(),
      isFalse,
      reason: 'a partial write leaves the app mixing new art with stale',
    );
  });

  test('a moved art block fails the run rather than writing half of it', () {
    final out = Directory(p.join(_scratch.path, 'out'));
    final source = _seed(
      screens.replaceFirst('function CardArtBotanical', 'function CardArtGone'),
    );

    final result = _run(source: source, out: out);

    expect(result.exitCode, isNot(0));
    expect(out.existsSync(), isFalse);
  });

  test('the manifest names every art it wrote', () {
    final manifest =
        jsonDecode(File(p.join(_committed, 'index.json')).readAsStringSync())
            as Map<String, dynamic>;
    final arts = (manifest['arts'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(arts, hasLength(37));
    for (final art in arts) {
      expect(
        File(p.join(_committed, '${art['slug']}.svg')).existsSync(),
        isTrue,
        reason: '${art['kind']} is in the manifest with no file',
      );
    }
  });
}
