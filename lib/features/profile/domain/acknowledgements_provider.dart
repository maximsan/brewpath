import 'package:brew_path/features/profile/domain/acknowledgements.dart';
import 'package:brew_path/shared/models/content/dictionary_term.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'acknowledgements_provider.g.dart';

/// The works the Acknowledgements page lists.
///
/// Read off the whole bank rather than `dictionaryView`, which narrows terms
/// to the learner's tier: credit is owed for every entry that ships, and a
/// free learner seeing a shorter list would be crediting fewer works.
@riverpod
Future<List<DictionarySource>> acknowledgements(Ref ref) async =>
    acknowledgedSources(
      await ref.watch(dictionaryRepositoryProvider).getTerms(),
    );
