// The drafting tool treats an unregistered string as prose, which is the safe
// default for words and the wrong one for a key. This reads the committed
// banks and fails when a string that reads like a key is heading for
// translation — the case that would leave a language quietly unusable.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const _generated = 'assets/content/generated';

/// A value that reads as a key rather than as words: one lowercase token.
final _looksLikeAKey = RegExp(r'^[a-z][a-z0-9_-]*$');

/// Asks the tool what it would do with each path, so the test and the tool
/// cannot disagree about the register.
Map<String, String> _classify(List<String> paths) {
  const script = '''
const { classify, mirrorOf } = require('./tool/draft_language/fields.js');
const paths = JSON.parse(process.argv[1]);
process.stdout.write(JSON.stringify(Object.fromEntries(
  paths.map((path) => [path, mirrorOf(path) ? 'mirror' : classify(path)]),
)));
''';
  final result = Process.runSync('node', ['-e', script, jsonEncode(paths)]);
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return (jsonDecode(result.stdout.toString()) as Map<String, dynamic>)
      .cast<String, String>();
}

/// Every string in the committed banks, by the register's path.
Map<String, List<String>> _stringsByPath() {
  final found = <String, List<String>>{};
  void walk(Object? value, String path) {
    if (value is Map) {
      value.forEach(
        (key, item) => walk(item, path.isEmpty ? '$key' : '$path.$key'),
      );
    } else if (value is List) {
      for (final item in value) {
        walk(item, '$path[]');
      }
    } else if (value is String) {
      (found[path] ??= []).add(value);
    }
  }

  for (final file in Directory(_generated).listSync().whereType<File>()) {
    final bank = p.basenameWithoutExtension(file.path);
    final envelope =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final record in envelope['items']! as List) {
      walk(record, bank);
    }
  }
  return found;
}

/// Every path the register names, whatever it names it.
Set<String> _registeredPaths() {
  const script = '''
const f = require('./tool/draft_language/fields.js');
process.stdout.write(JSON.stringify([
  ...Object.keys(f.STRUCTURAL),
  ...Object.keys(f.MIRRORS),
  ...Object.keys(f.OPTIONAL),
  ...f.SEARCH_KEYS,
]));
''';
  final result = Process.runSync('node', ['-e', script]);
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return (jsonDecode(result.stdout.toString()) as List).cast<String>().toSet();
}

/// The option lists a mirrored answer chooses from — keys by design.
Set<String> _mirrorOptionPaths() {
  const script = '''
const { MIRRORS } = require('./tool/draft_language/fields.js');
process.stdout.write(JSON.stringify(Object.values(MIRRORS)));
''';
  final result = Process.runSync('node', ['-e', script]);
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return (jsonDecode(result.stdout.toString()) as List).cast<String>().toSet();
}

void main() {
  test('the register still names a field for every path it claims', () {
    // Not "does classify answer" — it answers 'prose' for anything. This asks
    // the opposite: that every path the register names is one the banks
    // actually carry, so a rename leaves a dead entry rather than silent cover.
    final carried = _stringsByPath().keys.toSet();
    final registered = _registeredPaths();

    expect(
      registered.difference(carried),
      isEmpty,
      reason:
          'the register classifies paths the banks no longer carry — a rename '
          'left these behind, and the real field is now unclassified',
    );
  });

  test('no string that reads like a key is heading for translation', () {
    final byPath = _stringsByPath();
    final classes = _classify(byPath.keys.toList());
    final optionPaths = _mirrorOptionPaths();

    final suspects = <String>[];
    byPath.forEach((path, values) {
      if (classes[path] != 'prose') return;
      if (optionPaths.contains(path)) return;
      if (values.every(_looksLikeAKey.hasMatch)) suspects.add(path);
    });

    expect(
      suspects,
      isEmpty,
      reason:
          'these read as keys but the tool would translate them — classify '
          'each in tool/draft_language/fields.js, or say why it is words',
    );
  });
}
