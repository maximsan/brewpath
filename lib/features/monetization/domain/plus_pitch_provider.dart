import 'package:brew_path/features/monetization/domain/plus_pitch.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/dictionary_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_pitch_provider.g.dart';

/// The pitch's quantities, read off the shipped banks.
///
/// The joining is here rather than in the sheet so the derivation stays a pure
/// function over three lists — testable against the real content without
/// pumping a widget, which is the only way a wrong count fails fast.
@riverpod
Future<PlusPitch> plusPitch(Ref ref) async {
  final content = ref.watch(contentRepositoryProvider);
  final dictionary = ref.watch(dictionaryRepositoryProvider);

  return derivePlusPitch(
    lessons: await content.getLessons(),
    games: await content.getMiniGameFormats(),
    terms: await dictionary.getTerms(),
  );
}
