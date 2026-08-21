import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Guards `docs/adr/`'s numbering, because two sessions cutting branches from
/// the same `main` will both pick the same "next" number and neither PR can see
/// the other. That happened once — two ADR-0005s landed — and the ambiguity is
/// invisible until someone follows a reference by number and gets two answers.
///
/// `docs/adr/README.md` is the rule this enforces: one file per decision, a
/// zero-padded sequential number, numbers never reused, and a superseded record
/// kept in place rather than deleted — which is why gaps are a defect too.
const _adrDir = 'docs/adr';

/// `0007-some-decision.md` → 7. Null for anything that is not an ADR.
int? _numberOf(String fileName) {
  final match = RegExp(r'^(\d{4})-[a-z0-9-]+\.md$').firstMatch(fileName);
  return match == null ? null : int.parse(match.group(1)!);
}

List<File> _adrFiles() =>
    Directory(_adrDir).listSync().whereType<File>().where((file) {
      final name = p.basename(file.path);
      return name != 'README.md' && name.endsWith('.md');
    }).toList();

void main() {
  late List<File> files;

  setUp(() => files = _adrFiles());

  test('every ADR file is named as the convention requires', () {
    for (final file in files) {
      final name = p.basename(file.path);
      expect(
        _numberOf(name),
        isNotNull,
        reason:
            '$name is not `NNNN-kebab-case-title.md` — see $_adrDir/README.md',
      );
    }
  });

  test('no two ADRs share a number', () {
    final byNumber = <int, List<String>>{};
    for (final file in files) {
      final name = p.basename(file.path);
      final number = _numberOf(name);
      if (number == null) continue;
      byNumber.putIfAbsent(number, () => []).add(name);
    }

    final collisions = byNumber.entries
        .where((entry) => entry.value.length > 1)
        .map((entry) => '${entry.key} → ${entry.value}')
        .join('; ');

    expect(
      collisions,
      isEmpty,
      reason:
          'two decisions claim the same number, so a reference to it is '
          'ambiguous. Renumber the one that landed second to the next free '
          'number, and update every link to it: $collisions',
    );
  });

  test('the numbers run 1..N with no gaps', () {
    // Superseded ADRs are kept in place rather than deleted, so a gap means a
    // number was skipped or a record went missing — not that one retired.
    final numbers =
        files
            .map((file) => _numberOf(p.basename(file.path)))
            .whereType<int>()
            .toList()
          ..sort();

    expect(
      numbers,
      [for (var index = 1; index <= numbers.length; index++) index],
      reason: 'ADR numbers must be sequential from 0001 with no gaps',
    );
  });

  test('each ADR heading states the number its filename claims', () {
    // The rename that fixes a collision is exactly where these drift: the file
    // moves and the heading keeps the old number.
    for (final file in files) {
      final name = p.basename(file.path);
      final number = _numberOf(name);
      if (number == null) continue;

      final heading = file.readAsLinesSync().first;
      final padded = number.toString().padLeft(4, '0');
      expect(
        heading,
        startsWith('# ADR-$padded:'),
        reason: '$name opens with "$heading" instead of "# ADR-$padded: …"',
      );
    }
  });
}
