import 'package:freezed_annotation/freezed_annotation.dart';

part 'companion_line.freezed.dart';
part 'companion_line.g.dart';

/// One thing Roasty can say, as the extractor emits it.
///
/// [id] is assigned once and kept when [text] is edited — that is what holds a
/// translation onto its line across a re-authoring (ADR-0026).
@freezed
abstract class CompanionLine with _$CompanionLine {
  /// Creates a [CompanionLine].
  const factory CompanionLine({
    required String id,

    /// The `CompanionReaction` this line answers, by enum name.
    required String occasion,
    required String text,
  }) = _CompanionLine;

  /// Creates a [CompanionLine] from decoded JSON.
  factory CompanionLine.fromJson(Map<String, dynamic> json) =>
      _$CompanionLineFromJson(json);
}
