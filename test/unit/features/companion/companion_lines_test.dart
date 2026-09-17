import 'dart:math';

import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/shared/models/content/companion_line.dart';
import 'package:brew_path/shared/repositories/content_assembly.dart';
import 'package:flutter_test/flutter_test.dart';

CompanionLine _line(String id, String occasion, String text) =>
    CompanionLine(id: id, occasion: occasion, text: text);

void main() {
  group('CompanionLines', () {
    test('fromRecords groups a bank by the reaction each line answers', () {
      final lines = CompanionLines.fromRecords([
        _line('rl-a', 'lessonComplete', 'a'),
        _line('rl-b', 'lessonComplete', 'b'),
        _line('rl-c', 'challengeComplete', 'c'),
      ]);

      expect(lines.lineFor(CompanionReaction.challengeComplete), 'c');
    });

    test('fromRecords refuses an occasion that names no reaction', () {
      expect(
        () => CompanionLines.fromRecords([
          _line('rl-typo', 'lessonComplet', 'a'),
        ]),
        throwsA(
          isA<ContentFormatException>().having(
            (error) => error.message,
            'message',
            allOf(contains('rl-typo'), contains('lessonComplet')),
          ),
        ),
      );
    });

    test('lineFor returns null when a reaction has no authored lines', () {
      final lines = CompanionLines.fromRecords([
        _line('rl-a', 'lessonComplete', 'a'),
      ]);
      expect(lines.lineFor(CompanionReaction.moduleComplete), isNull);
    });

    test('lineFor picks a variant deterministically with a seeded Random', () {
      final lines = CompanionLines.fromRecords([
        _line('rl-a', 'lessonComplete', 'a'),
        _line('rl-b', 'lessonComplete', 'b'),
        _line('rl-c', 'lessonComplete', 'c'),
      ]);
      final picked = lines.lineFor(
        CompanionReaction.lessonComplete,
        random: Random(1),
      );
      expect(['a', 'b', 'c'], contains(picked));
      expect(
        lines.lineFor(CompanionReaction.lessonComplete, random: Random(1)),
        picked,
      );
    });
  });
}
