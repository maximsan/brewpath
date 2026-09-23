/// Where a run of lesson copy says a glossary term, so the run can draw it as
/// a link to the term peek sheet.
///
/// A sibling of the mention rule: both ask whether copy says a term as a
/// whole word (`term_words.dart`), but a mention answers yes or no for a whole
/// course, while a link needs the position and the spelling on the page.
library;

import 'package:brew_path/features/dictionary/domain/term_words.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:flutter/foundation.dart';

/// One run of a text: plain copy, or the words that stand for a term.
typedef TermTextSegment = ({String text, String? termId});

/// One surface form a term goes by, already lowercased.
typedef _Alias = ({String alias, String termId});

/// The most links the design lets one run of copy carry.
const int maxTermLinksPerText = 4;

/// The surface forms a learner's own dictionary may be linked by.
///
/// Built from the tier-aware view's terms, so a free learner is never handed a
/// link to an entry the view does not hold. Compiled once and matched against
/// many runs of copy, as the design's own index is.
@immutable
class TermLinkIndex {
  const TermLinkIndex._(this._aliases);

  /// Compiles the index [terms] can be linked by.
  ///
  /// A term is indexed under its aliases, or under its own name when it
  /// carries none — the design's rule, which is why *Origin Coffee Boards*
  /// links only by the acronyms it lists.
  factory TermLinkIndex.of(List<DictionaryTerm> terms) {
    final aliases = <({_Alias entry, int rank})>[];
    for (final (rank, term) in terms.indexed) {
      final forms = term.aliases.isEmpty ? [term.term] : term.aliases;
      for (final form in forms) {
        final alias = form.toLowerCase();
        if (alias.isEmpty) continue;
        aliases.add((entry: (alias: alias, termId: term.id), rank: rank));
      }
    }
    // Longest first, so a term containing another links once, as the longer
    // one. Bank order breaks a tie, so the same copy always links the same way.
    aliases.sort((first, second) {
      final byLength = second.entry.alias.length.compareTo(
        first.entry.alias.length,
      );
      return byLength != 0 ? byLength : first.rank.compareTo(second.rank);
    });

    return TermLinkIndex._([for (final indexed in aliases) indexed.entry]);
  }

  /// The index of a learner with no dictionary yet, which links nothing.
  static const TermLinkIndex empty = TermLinkIndex._([]);

  final List<_Alias> _aliases;

  /// Splits [text] into plain runs and linked runs.
  ///
  /// One link per term at its first occurrence, [maxTermLinksPerText] in all;
  /// past the cap the rest of the text stays plain. A run that says nothing in
  /// the index comes back whole.
  List<TermTextSegment> segmentsIn(String text) {
    final segments = <TermTextSegment>[];
    final linked = <String>{};
    var cut = 0;
    var at = 0;

    while (at < text.length && linked.length < maxTermLinksPerText) {
      final hit = isWordChar(at == 0 ? null : text[at - 1])
          ? null
          : _matchAt(text, at);
      if (hit == null) {
        at++;
        continue;
      }
      final end = at + hit.alias.length;
      if (linked.add(hit.termId)) {
        if (at > cut) {
          segments.add((text: text.substring(cut, at), termId: null));
        }
        segments.add((text: text.substring(at, end), termId: hit.termId));
        cut = end;
      }
      at = end;
    }
    if (cut < text.length || segments.isEmpty) {
      segments.add((text: text.substring(cut), termId: null));
    }
    return segments;
  }

  /// The longest alias standing as a whole word at [at], or null for none.
  _Alias? _matchAt(String text, int at) {
    for (final entry in _aliases) {
      final end = at + entry.alias.length;
      if (end > text.length) continue;
      if (text.substring(at, end).toLowerCase() != entry.alias) continue;
      if (!standsAlone(text, at, entry.alias.length)) continue;
      return entry;
    }
    return null;
  }
}
