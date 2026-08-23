/// What the Saved shelf shows: the saved keys, resolved and grouped.
library;

import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:flutter/foundation.dart';

/// One saveable thing, already resolved out of its content bank.
///
/// Deliberately not a content model: the derivation takes titles and
/// subtitles, never lessons and terms, so grouping stays testable with plain
/// records and gains no reason to change when a content model does.
typedef SavedCandidate = ({String id, String title, String subtitle});

/// One row on the shelf.
@immutable
class SavedItem {
  /// Creates a [SavedItem].
  const SavedItem({
    required this.key,
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
  });

  /// The stored key, which is what unsaving this row writes.
  final String key;

  /// What this row points at.
  final SavedKind kind;

  /// The content id, without its prefix.
  final String id;

  /// The row's name — the term, the lesson, the guide.
  final String title;

  /// The line above it: a category, a module, or the guide label.
  final String subtitle;
}

/// One heading and the rows beneath it.
@immutable
class SavedGroup {
  /// Creates a [SavedGroup].
  const SavedGroup({
    required this.kind,
    required this.label,
    required this.items,
  });

  /// The kind every row in this group shares.
  final SavedKind kind;

  /// The heading — "Dictionary terms", "Lessons", "Visual guides".
  final String label;

  /// The rows, in content order. Never empty: an empty group is not built.
  final List<SavedItem> items;
}

/// The order the design fixes, which is **not** the enum's declaration order.
const List<SavedKind> _shelfOrder = [
  SavedKind.term,
  SavedKind.lesson,
  SavedKind.guide,
];

/// Each group's heading.
const Map<SavedKind, String> _labels = {
  SavedKind.term: 'Dictionary terms',
  SavedKind.lesson: 'Lessons',
  SavedKind.guide: 'Visual guides',
};

/// The shelf: [keys] resolved against the content, grouped and ordered.
///
/// Each candidate list arrives **in content order** and that order is
/// preserved, so the shelf reads like the course rather than like a log of
/// when things were saved.
///
/// A key nothing resolves is **skipped**, not rendered broken: content moves,
/// and a shelf that shows a row it cannot open is worse than one that quietly
/// holds fewer. That is also why [savedShelfCount] counts the result rather
/// than the stored set — the badge must never promise a row the shelf cannot
/// draw.
List<SavedGroup> deriveSavedShelf({
  required Set<String> keys,
  required List<SavedCandidate> terms,
  required List<SavedCandidate> lessons,
  required List<SavedCandidate> guides,
}) {
  final candidates = {
    SavedKind.term: terms,
    SavedKind.lesson: lessons,
    SavedKind.guide: guides,
  };

  final groups = <SavedGroup>[];
  for (final kind in _shelfOrder) {
    final items = <SavedItem>[];
    for (final candidate in candidates[kind]!) {
      final key = formatSavedKey(kind, candidate.id);
      if (!keys.contains(key)) continue;
      items.add(
        SavedItem(
          key: key,
          kind: kind,
          id: candidate.id,
          title: candidate.title,
          subtitle: candidate.subtitle,
        ),
      );
    }
    if (items.isNotEmpty) {
      groups.add(SavedGroup(kind: kind, label: _labels[kind]!, items: items));
    }
  }
  return groups;
}

/// How many rows [groups] holds — what the header badge counts.
int savedShelfCount(List<SavedGroup> groups) =>
    groups.fold(0, (total, group) => total + group.items.length);

/// How many rows, said in words — "1 item", "3 items".
///
/// Shared by the shelf's count line and the header button's label, which is
/// the only reason it is here rather than inline: the two must not disagree
/// about how one saved thing is spelled.
String savedItemCount(int count) => '$count ${count == 1 ? 'item' : 'items'}';
