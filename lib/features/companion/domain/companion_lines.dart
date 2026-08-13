import 'dart:math';

import 'package:brew_path/features/companion/domain/companion_reaction.dart';

/// Speech-line content for the companion, keyed by `CompanionReaction.name`.
/// Each key holds a list of interchangeable variants; [lineFor] picks one at
/// random so repeated moments feel varied. Loaded from
/// `assets/content/companion_lines.json`.
class CompanionLines {
  /// Creates a [CompanionLines] from a `reaction-name -> variants` map.
  const CompanionLines(this._byReaction);

  /// Parses the decoded `companion_lines.json` object.
  factory CompanionLines.fromJson(Map<String, dynamic> json) {
    final map = <String, List<String>>{};
    for (final entry in json.entries) {
      final variants = (entry.value as List<dynamic>).cast<String>();
      map[entry.key] = variants;
    }
    return CompanionLines(map);
  }

  final Map<String, List<String>> _byReaction;

  /// A random line for [reaction], or null when none are authored for it.
  /// Pass [random] to make selection deterministic in tests.
  String? lineFor(CompanionReaction reaction, {Random? random}) {
    final variants = _byReaction[reaction.name];
    if (variants == null || variants.isEmpty) return null;
    return variants[(random ?? _shared).nextInt(variants.length)];
  }

  static final Random _shared = Random();
}
