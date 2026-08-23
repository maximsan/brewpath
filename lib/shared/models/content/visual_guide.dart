import 'package:freezed_annotation/freezed_annotation.dart';

part 'visual_guide.freezed.dart';
part 'visual_guide.g.dart';

// Field names come from the prototype's vocabulary and are remapped here
// rather than in the extractor, which renames nothing: `visualGuide` is the
// guide's subject, the axis its `g:` save key carries.

/// The lesson that earns a guide.
@freezed
abstract class VisualGuideUnlock with _$VisualGuideUnlock {
  /// Creates a [VisualGuideUnlock].
  const factory VisualGuideUnlock({required String lesson}) =
      _VisualGuideUnlock;

  /// Creates a [VisualGuideUnlock] from decoded JSON.
  factory VisualGuideUnlock.fromJson(Map<String, dynamic> json) =>
      _$VisualGuideUnlockFromJson(json);
}

/// One row of a guide's meta table — a label and the value beside it.
///
/// The textual counterpart of the guide's own diagram: `LIGHT / Bright ·
/// acidic` is what the drawing says in words, which is why the drawings carry
/// none.
typedef VisualGuideMetaRow = ({String label, String value});

/// One illustrated reference the course teaches.
///
/// **It carries nothing about the learner.** Whether a guide is earned is
/// derived from [unlock] against completed lessons, exactly as collectibles
/// are, so there is one source of truth about what a learner owns.
///
/// A guide is **never listed beside a collectible** — the two lists are loaded
/// by different accessors and are not concatenated anywhere, because that rule
/// only survives if they never meet in a variable.
@freezed
abstract class VisualGuide with _$VisualGuide {
  /// Creates a [VisualGuide].
  const factory VisualGuide({
    required String id,

    /// The subject this guide covers — `roast`, `grind`, `variety`. The value
    /// a `g:` save key carries, and the axis its drawing is chosen by.
    @JsonKey(name: 'visualGuide') required String subject,

    /// The lesson that earns it: the earliest one that teaches it, which the
    /// extractor refuses to let drift.
    required VisualGuideUnlock unlock,

    required String label,
    required String title,
    required String summary,

    /// The one thing worth repeating to somebody else.
    required String fact,

    /// The meta table on the wire: two or three label/value pairs.
    @Default(<List<String>>[]) List<List<String>> meta,
  }) = _VisualGuide;

  const VisualGuide._();

  /// Creates a [VisualGuide] from decoded JSON.
  factory VisualGuide.fromJson(Map<String, dynamic> json) =>
      _$VisualGuideFromJson(json);

  /// The lesson that earns this guide.
  String get unlockLessonId => unlock.lesson;

  /// The meta table as named pairs, for a renderer that should not be indexing
  /// into lists.
  List<VisualGuideMetaRow> get metaRows => [
    for (final row in meta) (label: row.first, value: row.last),
  ];
}
