import 'package:brew_path/app/current_day.dart';
import 'package:brew_path/features/dictionary/domain/term_of_day.dart';
import 'package:brew_path/features/monetization/domain/course_entitlement.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'term_of_day_providers.g.dart';

/// Today's term, and what the two surfaces showing it need beside it.
@immutable
class TermOfDayView {
  /// Creates a [TermOfDayView].
  const TermOfDayView({
    required this.term,
    required this.categoryLabel,
    required this.date,
    required this.hasCourse,
  });

  /// The term the day landed on.
  final DictionaryTerm term;

  /// Its category's name, or null before the categories have resolved — the
  /// term is worth showing without the kicker over it.
  final String? categoryLabel;

  /// The local day it was picked for. Shown on the screen, and the reason the
  /// banner changes overnight rather than at some hour of its own.
  final DateTime date;

  /// Whether this learner owns the course, which decides where *Read the full
  /// entry* goes.
  final bool hasCourse;
}

/// Today's term, or null when the tier's pool is empty.
///
/// **Unresolved entitlement reads as free**, the direction every gate in the
/// app resolves it: offering a free learner a reference-only term for a frame
/// is the leak, and offering a paying learner a smaller pool for a frame is a
/// rebuild away from being right.
///
/// Watching [currentDayProvider] rather than reading a clock here is what
/// unfreezes this: the day is already on `invalidateDaySurfaces`, so a learner
/// who leaves the app open overnight gets tomorrow's term when they come back
/// rather than the one their last build happened to derive.
@riverpod
Future<TermOfDayView?> termOfDayView(Ref ref) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final dictionary = ref.watch(dictionaryRepositoryProvider);
  final termsFuture = dictionary.getTerms();
  final categoriesFuture = dictionary.getCategories();
  final entitlement = ref.watch(courseEntitlementProvider);
  final date = ref.watch(currentDayProvider);

  final hasCourse = entitlement.asData?.value ?? false;
  final term = termOfDay(
    pool: termOfDayPool(terms: await termsFuture, hasCourse: hasCourse),
    date: date,
  );
  if (term == null) return null;

  return TermOfDayView(
    term: term,
    categoryLabel: (await categoriesFuture)
        .where((category) => category.id == term.categoryId)
        .firstOrNull
        ?.label,
    date: date,
    hasCourse: hasCourse,
  );
}
