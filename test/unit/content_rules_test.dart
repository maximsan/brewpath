import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// The structural content rules, checked against the **committed** banks.
///
/// The extractor already refuses to write when any of these break, so on the
/// face of it this is the same check twice. It is not: the extractor only ever
/// sees output it just produced, and generated content is committed to never
/// being hand-edited — a rule that needs something enforcing it. These run over
/// the files as they actually sit in the repo, so a hand-edit, a bad merge or a
/// half-applied regeneration fails here even though no source changed.
///
/// Only structural rules live here. The word search that decides whether a
/// lesson says a term stays in the extractor alone: re-implementing a heuristic
/// in a second language guarantees the two drift, and then CI fails on
/// something the extractor passed with no way to tell which is right.
const _generated = 'assets/content/generated';

/// A card in canonical form — keys sorted at every depth, so two cards that
/// differ only in key order compare equal.
///
/// This has to agree with the extractor's own fingerprint. A bare `jsonEncode`
/// preserves insertion order, which would let a reordered duplicate pass here
/// while the extractor refuses it — the two sides disagreeing about the same
/// rule, which is the failure this second seam exists to prevent.
Object? _canonicalValue(Object? value) {
  if (value is List) return value.map(_canonicalValue).toList();
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _canonicalValue(value[key])};
  }
  return value;
}

String _canonical(Object? value) => jsonEncode(_canonicalValue(value));

/// The option a learner picks. A decision card's `sub` is not measured, exactly
/// as the extractor does not measure it.
int _optionLength(Map<String, dynamic> option) =>
    (option['t'] as String? ?? '').length;

List<Map<String, dynamic>> _items(String bank) {
  final file = File(p.join(_generated, '$bank.json'));
  final envelope = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return (envelope['items'] as List).cast<Map<String, dynamic>>();
}

void main() {
  late List<Map<String, dynamic>> lessons;
  late List<Map<String, dynamic>> modules;
  late List<Map<String, dynamic>> collectibles;

  setUpAll(() {
    lessons = _items('lessons');
    modules = _items('modules');
    collectibles = _items('collectibles');
  });

  test('every lesson unlocks exactly one collectible', () {
    final byLesson = <String, List<String>>{};
    for (final card in collectibles) {
      final lesson = (card['unlock'] as Map?)?['lesson'] as String?;
      if (lesson == null) continue;
      byLesson.putIfAbsent(lesson, () => []).add(card['id'] as String);
    }

    for (final lesson in lessons) {
      final id = lesson['id'] as String;
      expect(
        byLesson[id],
        hasLength(1),
        reason: 'lesson $id should pay out exactly one collectible',
      );
    }
  });

  test('no two collectibles carry the same name', () {
    // The words are on the lesson, not the collectible: a collectible holds
    // identity only and takes its title from the reward of whatever lesson
    // unlocks it. So the collision can only be authored between two rewards.
    final byTitle = <String, List<String>>{};
    for (final lesson in lessons) {
      final title = (lesson['reward'] as Map?)?['title'] as String?;
      if (title == null) continue;
      byTitle.putIfAbsent(title, () => []).add(lesson['id'] as String);
    }

    final shared = Map.of(byTitle)..removeWhere((_, at) => at.length < 2);
    expect(shared, isEmpty, reason: 'two cards would sit under one name');
  });

  test('no card is repeated between lessons', () {
    final places = <String, List<String>>{};
    for (final lesson in lessons) {
      final cards = (lesson['cards'] as List).cast<Map<String, dynamic>>();
      cards.asMap().forEach((index, card) {
        places
            .putIfAbsent(_canonical(card), () => [])
            .add('${lesson['id']} card ${index + 1}');
      });
    }

    final repeated = Map.of(places)..removeWhere((_, at) => at.length < 2);
    expect(repeated, isEmpty, reason: 'a learner would meet one card twice');
  });

  test('the correct answer is not far longer than its runner-up', () {
    // Structural, so decision 4 runs it on both sides. Scoped to 3+ options
    // exactly as the extractor scopes it: the ratio was calibrated on that
    // population (#100).
    for (final lesson in lessons) {
      for (final card
          in (lesson['cards'] as List).cast<Map<String, dynamic>>()) {
        final options = (card['choices'] ?? card['options']) as List<dynamic>?;
        if (options == null || options.length < 3) continue;

        final texts = options.cast<Map<String, dynamic>>();
        final correct = texts.where((o) => o['correct'] == true).toList();
        if (correct.length != 1) continue;

        final answer = _optionLength(correct.single);
        final runnerUp = texts
            .where((o) => o['correct'] != true)
            .map(_optionLength)
            .fold(0, (a, b) => a > b ? a : b);
        if (runnerUp == 0 || answer == 0) continue;

        expect(
          answer / runnerUp,
          lessThan(1.5),
          reason:
              '${lesson['id']} ${card['kind']}: answer is $answer characters '
              'against a runner-up of $runnerUp',
        );
      }
    }
  });

  test('the g- namespace names one thing per id', () {
    // `g-` prefixes two families authored in different files under different
    // rules. A per-registry check passes a `g-flavor` guide (#106).
    final owners = <String, List<String>>{};
    for (final format in _items('mini_games')) {
      owners.putIfAbsent(format['id'] as String, () => []).add('mini-game');
    }
    for (final guide in _items('visual_guides')) {
      owners.putIfAbsent(guide['id'] as String, () => []).add('visual guide');
    }

    final shared = Map.of(owners)
      ..removeWhere((_, families) => families.length < 2);
    expect(shared, isEmpty, reason: 'one id has to mean one thing across both');
  });

  test('a guide meta table is two or three label-and-value rows', () {
    // Two or three, never "exactly three": `g-variety` and `g-distribution`
    // carry two, so a stricter rule fails on landed content (#106).
    for (final guide in _items('visual_guides')) {
      final meta = (guide['meta'] as List?) ?? const [];
      expect(
        meta.length,
        inInclusiveRange(2, 3),
        reason: '${guide['id']} carries ${meta.length} meta rows',
      );
      for (final row in meta) {
        expect(
          row,
          hasLength(2),
          reason: '${guide['id']} has a row that is not a pair',
        );
      }
    }
  });

  test('the derived fields agree with the source they are generated from', () {
    final byId = {for (final lesson in lessons) lesson['id'] as String: lesson};

    for (final module in modules) {
      final label = 'MODULE ${module['n']} · ${module['label']}';
      for (final entry
          in (module['lessons'] as List).cast<Map<String, dynamic>>()) {
        final lesson = byId[entry['id']];
        expect(
          lesson,
          isNotNull,
          reason: '${entry['id']} is listed but not authored',
        );
        expect(lesson!['moduleLabel'], label);
        expect(entry['title'], lesson['title']);
        expect(entry['points'], lesson['points']);
        expect(entry['time'], lesson['time']);
      }
    }
  });
}
