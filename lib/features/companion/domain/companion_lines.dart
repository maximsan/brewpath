import 'dart:math';

import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/shared/models/content/companion_line.dart';
import 'package:brew_path/shared/repositories/content_assembly.dart';

/// Speech-line content for the companion, keyed by `CompanionReaction.name`.
/// Each key holds a list of interchangeable variants; [lineFor] picks one at
/// random so repeated moments feel varied.
class CompanionLines {
  /// Creates a [CompanionLines] from a `reaction-name -> variants` map.
  const CompanionLines(this._byReaction);

  /// Groups the `companion_lines` bank by the reaction each line answers.
  ///
  /// An occasion naming no reaction throws: the line would never be spoken,
  /// and a companion that quietly says less is indistinguishable from one with
  /// fewer lines authored.
  factory CompanionLines.fromRecords(List<CompanionLine> records) {
    final byReaction = <String, List<String>>{};
    for (final record in records) {
      if (!_reactionNames.contains(record.occasion)) {
        throw ContentFormatException(
          'companion line "${record.id}" answers "${record.occasion}", which '
          'is not a CompanionReaction — rename it or add the reaction',
        );
      }
      byReaction.putIfAbsent(record.occasion, () => []).add(record.text);
    }
    return CompanionLines(byReaction);
  }

  final Map<String, List<String>> _byReaction;

  /// A random line for [reaction], or null when none are authored for it.
  /// Pass [random] to make selection deterministic in tests.
  String? lineFor(CompanionReaction reaction, {Random? random}) {
    final variants = _byReaction[reaction.name];
    if (variants == null || variants.isEmpty) return null;
    return variants[(random ?? _shared).nextInt(variants.length)];
  }

  static final Set<String> _reactionNames = {
    for (final reaction in CompanionReaction.values) reaction.name,
  };

  static final Random _shared = Random();
}
