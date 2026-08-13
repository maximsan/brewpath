import 'dart:math';

import 'package:brew_path/features/companion/domain/companion_lines.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompanionLines', () {
    test('fromJson parses reaction-keyed variant lists', () {
      final lines = CompanionLines.fromJson(const {
        'lessonComplete': ['a', 'b'],
        'wrong': ['c'],
      });
      expect(
        lines.lineFor(CompanionReaction.wrong),
        'c',
      );
    });

    test('lineFor returns null when a reaction has no authored lines', () {
      final lines = CompanionLines.fromJson(const {
        'lessonComplete': ['a'],
      });
      expect(lines.lineFor(CompanionReaction.moduleComplete), isNull);
    });

    test('lineFor picks a variant deterministically with a seeded Random', () {
      final lines = CompanionLines.fromJson(const {
        'lessonComplete': ['a', 'b', 'c'],
      });
      final picked = lines.lineFor(
        CompanionReaction.lessonComplete,
        random: Random(1),
      );
      expect(['a', 'b', 'c'], contains(picked));
      // Same seed -> same pick (stable selection).
      expect(
        lines.lineFor(CompanionReaction.lessonComplete, random: Random(1)),
        picked,
      );
    });
  });
}
