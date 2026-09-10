import 'dart:convert';
import 'dart:io';

import 'package:brew_path/features/lessons/presentation/cards/card_cue.dart';
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> _bank() {
  final raw = File('assets/content/generated/card_kind_help.json');
  final decoded = jsonDecode(raw.readAsStringSync()) as Map<String, dynamic>;
  return (decoded['items'] as List).cast<Map<String, dynamic>>();
}

void main() {
  group('CardCue', () {
    test('every cue has an entry in the bundled help bank', () {
      final kinds = _bank().map((item) => item['kind']).toSet();

      for (final cue in CardCue.values) {
        expect(
          kinds,
          contains(cue.helpKey),
          reason: '${cue.name} would draw a ? with nothing behind it',
        );
      }
    });

    test('the bank explains nothing the cues cannot reach', () {
      final reachable = CardCue.values.map((cue) => cue.helpKey).toSet();

      for (final item in _bank()) {
        expect(
          reachable,
          contains(item['kind']),
          reason: '${item['kind']} has help no card can open',
        );
      }
    });

    test('carries the design phrase for every kind', () {
      const written = {
        CardCue.mcq: 'Multiple choice · pick one',
        CardCue.multi: 'Select all that apply',
        CardCue.match: 'Match · drag to pair',
        CardCue.slider: 'Calibrate · dial to the target',
        CardCue.sequence: 'Put in order · tap in sequence',
        CardCue.quiz: 'True or false',
        CardCue.flavor: 'Tasting · name the note',
        CardCue.tastefix: 'Taste Fix',
        CardCue.bagpick: 'Blind bag · read the beans',
        CardCue.fill: 'Complete the sentence',
      };

      expect(written.keys, containsAll(CardCue.values));
      written.forEach((cue, phrase) => expect(cue.phrase, phrase));
    });

    test('no phrase is pre-shouted — the type rule sets the case', () {
      for (final cue in CardCue.values) {
        expect(
          cue.phrase,
          isNot(cue.phrase.toUpperCase()),
          reason: '${cue.name} carries its own casing',
        );
      }
    });
  });
}
