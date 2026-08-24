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
/// One row of the guide's table: what it is called, what it is, and — where
/// the guide glosses its terms — the sentence saying what that is like.
typedef VisualGuideMetaRow = ({String label, String value, String? detail});

/// One term of a guide explained — the sentence under a row of its table.
///
/// Distinct from a meta row on purpose: `LIGHT / Bright · acidic` labels the
/// roast, and this says what living with it is like. Paired by [term] rather
/// than by position, because the table and the prose are authored in two
/// different registries and nothing forces their order to agree.
@freezed
abstract class VisualGuideNote with _$VisualGuideNote {
  /// Creates a [VisualGuideNote].
  const factory VisualGuideNote({
    required String term,
    required String detail,
  }) = _VisualGuideNote;

  /// Creates a [VisualGuideNote] from decoded JSON.
  factory VisualGuideNote.fromJson(Map<String, dynamic> json) =>
      _$VisualGuideNoteFromJson(json);
}

/// One layer of the coffee cherry, skin to seed.
///
/// The whole content of the cross-section: tapping a ring reveals exactly
/// these five fields. [fate] is the layer's end at the mill — *"Stripped at
/// the mill"*, *"This is your coffee"* — which is what turns six rings into a
/// story about what happens to a cherry on its way to a cup.
///
/// The ring's colour and radius are **not** here: the drawing owns its own
/// geometry through the illustration palette, so a redrawn cross-section
/// cannot be contradicted by a stale radius in the bank.
@freezed
abstract class CherryLayer with _$CherryLayer {
  /// Creates a [CherryLayer].
  const factory CherryLayer({
    /// The layer's place, outside in, as the drawing numbers it: `01`–`06`.
    /// A string because it is shown as one — a zero-padded chip on the band.
    @JsonKey(name: 'n') required String number,

    required String name,

    /// The botanical name — `exocarp`, `pectin gel`, `endosperm`.
    required String latin,

    /// What becomes of this layer: stripped, hulled, or brewed.
    required String fate,

    /// The sentences shown when this layer is the selected one.
    required String note,
  }) = _CherryLayer;

  /// Creates a [CherryLayer] from decoded JSON.
  factory CherryLayer.fromJson(Map<String, dynamic> json) =>
      _$CherryLayerFromJson(json);
}

/// One brew in a guide's servings table: what it is, how much of it, and how
/// much caffeine that carries.
///
/// [milligrams] is a number rather than authored text because the bar beside
/// each row is drawn from it, scaled against the largest row in the table.
@freezed
abstract class ServingRow with _$ServingRow {
  /// Creates a [ServingRow].
  const factory ServingRow({
    required String name,

    /// The serving this figure is for — `240 ml cup`, `30 ml shot`. The half
    /// of the table a guide titled *Caffeine, Per Serving* cannot do without.
    @JsonKey(name: 'serve') required String serving,

    @JsonKey(name: 'mg') required int milligrams,
  }) = _ServingRow;

  /// Creates a [ServingRow] from decoded JSON.
  factory ServingRow.fromJson(Map<String, dynamic> json) =>
      _$ServingRowFromJson(json);
}

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

    /// What each term in the table actually means. Empty for the guides whose
    /// drawing carries the explanation — anatomy's cross-section is the
    /// reference, so it has no rows to gloss.
    @Default(<VisualGuideNote>[]) List<VisualGuideNote> notes,

    /// The cherry's six layers, outside in. Only the anatomy guide carries
    /// them; every other guide's reference is the drawing itself.
    @Default(<CherryLayer>[]) List<CherryLayer> layers,

    /// The servings table, where the guide has one. Only caffeine does.
    @Default(<ServingRow>[]) List<ServingRow> rows,

    /// The closing thought, where the guide has one: the misreading it exists
    /// to head off, or the thing a learner should take away.
    String? note,
  }) = _VisualGuide;

  const VisualGuide._();

  /// Creates a [VisualGuide] from decoded JSON.
  factory VisualGuide.fromJson(Map<String, dynamic> json) =>
      _$VisualGuideFromJson(json);

  /// The lesson that earns this guide.
  String get unlockLessonId => unlock.lesson;

  /// The meta table as named rows, each carrying its gloss where one exists.
  ///
  /// The table and the prose are authored in two different registries, so they
  /// are joined **by term** rather than by position — case-insensitively,
  /// because the table shouts (`LIGHT`) where the prose speaks (`Light`). The
  /// extractor refuses to write a note whose term names no row, so a gloss can
  /// never go quietly missing here.
  List<VisualGuideMetaRow> get metaRows => [
    for (final row in meta)
      (
        label: row.first,
        value: row.last,
        detail: _detailFor(row.first),
      ),
  ];

  String? _detailFor(String label) {
    final wanted = label.toLowerCase();
    for (final note in notes) {
      if (note.term.toLowerCase() == wanted) return note.detail;
    }
    return null;
  }
}
