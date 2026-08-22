import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictionary_category.freezed.dart';
part 'dictionary_category.g.dart';

/// One of the dictionary's categories, as the bank stores it.
///
/// Categories are content, not layout: the home grid draws its labels and
/// one-line descriptions from here rather than from Dart constants, so a
/// rename in the design source cannot leave the app describing a category the
/// design no longer has.
@freezed
abstract class DictionaryCategory with _$DictionaryCategory {
  /// Creates a [DictionaryCategory].
  const factory DictionaryCategory({
    required String id,
    required String label,

    /// The category's illustration key. Named, not drawn, here — the grid
    /// falls back to a generic mark until a drawing for it exists.
    required String glyph,

    /// One line saying what is inside, shown under the label on the grid.
    @JsonKey(name: 'short') required String summary,
  }) = _DictionaryCategory;

  /// Creates a [DictionaryCategory] from decoded JSON.
  factory DictionaryCategory.fromJson(Map<String, dynamic> json) =>
      _$DictionaryCategoryFromJson(json);
}
