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

/// One level of a guide explained — *Light*, *Medium*, *Dark* for the roast
/// guide — in the order the design draws them under the illustration.
///
/// The design once paired these with a label/value table; that table was
/// dropped, so a note is now the whole of what the sheet says about a level.
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

    /// The explanation of each level, drawn under the illustration. Only the
    /// roast and grind guides carry them; every other guide's drawing is its
    /// own explanation.
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
}
