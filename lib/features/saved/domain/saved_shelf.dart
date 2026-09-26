/// What the Saved shelf shows: the saved keys, resolved and grouped.
library;

import 'package:brew_path/features/saved/domain/saved_key.dart';
import 'package:brew_path/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';

/// One saveable thing, already resolved out of its content bank.
///
/// Deliberately not a content model: the derivation takes titles and
/// subtitles, never lessons and terms, so grouping stays testable with plain
/// records and gains no reason to change when a content model does.
typedef SavedCandidate = ({
  String id,
  String title,
  String subtitle,
  int? moduleNumber,
  String? glyph,
});

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
    this.moduleNumber,
    this.glyph,
  });

  /// The stored key, which is what unsaving this row writes.
  final String key;

  /// What this row points at.
  final SavedKind kind;

  /// The content id, without its prefix.
  final String id;

  /// The row's name — the term, the lesson, the guide.
  final String title;

  /// The content half of the line above it — a category, a module's or a
  /// guide's name. The framing around it is [savedRowSubtitle]'s.
  final String subtitle;

  /// Which module a saved lesson sits in, and null for every other kind.
  ///
  /// A lesson always has one — the shelf reads it off the module it was
  /// gathered from — so [savedRowSubtitle] asserts rather than inventing a
  /// number to render.
  final int? moduleNumber;

  /// The category glyph a term row draws; null for a lesson or a guide.
  final String? glyph;
}

/// One heading and the rows beneath it.
@immutable
class SavedGroup {
  /// Creates a [SavedGroup].
  const SavedGroup({required this.kind, required this.items});

  /// The kind every row in this group shares.
  final SavedKind kind;

  /// The rows, in content order. Never empty: an empty group is not built.
  final List<SavedItem> items;
}

/// The order the design fixes, which is **not** the enum's declaration order.
const List<SavedKind> _shelfOrder = [
  SavedKind.term,
  SavedKind.lesson,
  SavedKind.guide,
];

/// Each group's heading, which the shelf carries as a kind rather than a
/// word — the provider that builds it has no `BuildContext`.
String savedGroupLabel(AppLocalizations strings, SavedKind kind) =>
    switch (kind) {
      SavedKind.term => strings.savedGroupTerms,
      SavedKind.lesson => strings.savedGroupLessons,
      SavedKind.guide => strings.savedGroupGuides,
    };

/// The shelf: [keys] resolved against the content, grouped and ordered.
///
/// Each candidate list arrives in content order and keeps it, so the shelf
/// reads like the course rather than a log of when things were saved. A key
/// nothing resolves is skipped, not drawn broken — which is why
/// [savedShelfCount] counts the result: the badge must never promise a row.
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
          moduleNumber: candidate.moduleNumber,
          glyph: candidate.glyph,
        ),
      );
    }
    if (items.isNotEmpty) {
      groups.add(SavedGroup(kind: kind, items: items));
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
String savedItemCount(AppLocalizations strings, int count) =>
    strings.savedItemCount(count);

/// The line above a saved row: the content's own name, framed by its kind.
String savedRowSubtitle(AppLocalizations strings, SavedItem item) =>
    switch (item.kind) {
      SavedKind.term =>
        item.subtitle.isEmpty ? strings.savedTermSubtitle : item.subtitle,
      SavedKind.lesson => strings.savedLessonSubtitle(
        item.moduleNumber!,
        item.subtitle,
      ),
      SavedKind.guide => strings.savedGuideSubtitle(item.subtitle),
    };
