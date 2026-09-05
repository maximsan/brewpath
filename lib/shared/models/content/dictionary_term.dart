import 'package:brew_path/shared/models/content/card_parts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictionary_term.freezed.dart';
part 'dictionary_term.g.dart';

// Field names come from the prototype's vocabulary and are remapped here
// rather than in the extractor, which renames nothing: `pron` is the
// pronunciation respelling, `cat` the category pointer, `short`/`deep` the two
// depths of explanation, and `q` a self-check's question.

/// A work a term's explanation draws on. [url] is absent for print sources.
@freezed
abstract class DictionarySource with _$DictionarySource {
  /// Creates a [DictionarySource].
  const factory DictionarySource({
    required String label,
    String? url,
  }) = _DictionarySource;

  /// Creates a [DictionarySource] from decoded JSON.
  factory DictionarySource.fromJson(Map<String, dynamic> json) =>
      _$DictionarySourceFromJson(json);
}

/// The optional self-check a term carries.
///
/// [choices] reuses the card union's [Choice] rather than declaring a parallel
/// option type: the shape is identical, and one type means one set of rules
/// about what a correct answer looks like.
@freezed
abstract class DictionaryCheck with _$DictionaryCheck {
  /// Creates a [DictionaryCheck].
  const factory DictionaryCheck({
    @JsonKey(name: 'q') required String question,
    required List<Choice> choices,

    /// Shown after the learner answers, so a wrong guess still teaches.
    @JsonKey(name: 'explain') required String explanation,
  }) = _DictionaryCheck;

  /// Creates a [DictionaryCheck] from decoded JSON.
  factory DictionaryCheck.fromJson(Map<String, dynamic> json) =>
      _$DictionaryCheckFromJson(json);
}

/// One dictionary term, as the bank stores it.
///
/// **It carries nothing about the learner.** Whether a term is learned, still
/// ahead, or taught by no lesson at all is derived from [lessonId] against the
/// completed-lesson set — see `dictionaryStatusOf`. Storing it here would make
/// two sources of truth about the same fact.
@freezed
abstract class DictionaryTerm with _$DictionaryTerm {
  /// Creates a [DictionaryTerm].
  const factory DictionaryTerm({
    required String id,

    /// The word itself, as it is displayed.
    required String term,

    /// The category this term belongs to. Always resolves — the extractor
    /// refuses a bank whose pointer does not.
    @JsonKey(name: 'cat') required String categoryId,

    /// The one-line answer to *what does this word mean*. Every term has one,
    /// and it is what a free learner reads: the longer [deepExplanation] comes
    /// with the course (`docs/decisions.md` §12).
    @JsonKey(name: 'short') required String shortExplanation,

    /// Ids of terms worth reading next. May be empty, never absent.
    @JsonKey(name: 'related') @Default(<String>[]) List<String> relatedIds,

    /// Other names the same thing goes by, matched by search.
    @Default(<String>[]) List<String> aliases,

    /// The lesson that teaches this term. **Absent means no lesson teaches
    /// it** — the term is reference-only, and saying otherwise would promise a
    /// lesson the course does not have.
    @JsonKey(name: 'lesson') String? lessonId,

    /// A pronunciation respelling, shipped as text.
    @JsonKey(name: 'pron') String? pronunciation,

    /// The longer explanation, for terms that repay one.
    @JsonKey(name: 'deep') String? deepExplanation,

    /// The term used in the wild, so it is recognisable next time.
    String? example,

    @Default(<DictionarySource>[]) List<DictionarySource> sources,
    DictionaryCheck? check,
  }) = _DictionaryTerm;

  const DictionaryTerm._();

  /// Creates a [DictionaryTerm] from decoded JSON.
  factory DictionaryTerm.fromJson(Map<String, dynamic> json) =>
      _$DictionaryTermFromJson(json);

  /// Whether the course adds anything to the short explanation — the deep
  /// explanation, the example, the self-check or the sources
  /// (`docs/decisions.md` §12). A term with none is a short-only entry, and
  /// offering to unlock its full entry would offer nothing.
  bool get hasFullEntry =>
      deepExplanation != null ||
      example != null ||
      check != null ||
      sources.isNotEmpty;
}
