import 'package:brew_path/features/dictionary/domain/dictionary_derivations.dart';
import 'package:brew_path/shared/theme/mood_colors.dart';
import 'package:flutter/material.dart';

/// How each [DictionaryStatus] is worded and coloured.
///
/// The wording is the accessible label too: the three states must not be
/// carried by a ring shape alone, so every surface that draws a status ring
/// also announces this text.
extension DictionaryStatusStyle on DictionaryStatus {
  /// The word a learner reads, and a screen reader announces.
  String get label => switch (this) {
    DictionaryStatus.learned => 'Learned',
    DictionaryStatus.toLearn => 'To learn',
    DictionaryStatus.reference => 'Reference',
  };

  /// How the entry heads the block naming where a term sits on the path.
  String get pathLabel => switch (this) {
    DictionaryStatus.learned => 'Where you learned it',
    DictionaryStatus.toLearn => "Where you'll learn it",
    DictionaryStatus.reference => 'Not on the path',
  };

  /// The mark's colour. Reference is deliberately the muted one — it is not a
  /// lesser version of "not yet", it is off the path entirely.
  Color colorFrom(MoodColors mood) => switch (this) {
    DictionaryStatus.learned => mood.sage,
    DictionaryStatus.toLearn => mood.accent,
    DictionaryStatus.reference => mood.inkMute,
  };

  /// Whether the mark is drawn filled. Only a learned term is filled — the
  /// design's rule is that an outline means "not yet".
  bool get isFilled => this == DictionaryStatus.learned;
}
