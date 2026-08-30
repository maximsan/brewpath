import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/foundation.dart';

/// What the chooser is showing, before the learner commits to it.
///
/// Held apart from the planted [Grove] so backing out costs nothing: the
/// screen edits this, and only [GroveDraft.grove] ever reaches the snapshot.
/// Keeping it a value rather than widget state is what lets "is confirm live"
/// be answered — and tested — without pumping anything.
@immutable
class GroveDraft {
  /// Creates a [GroveDraft].
  const GroveDraft({required this.variety, required this.light});

  /// Opens a draft on what is currently planted.
  factory GroveDraft.of(Grove planted) =>
      GroveDraft(variety: planted.variety, light: planted.light);

  /// The species being previewed.
  final String variety;

  /// The light it is previewed under.
  final String light;

  /// This draft as a grove, ready to be written.
  Grove get grove => Grove(variety: variety, light: light);

  /// The same draft with a different species.
  GroveDraft withVariety(String id) => GroveDraft(variety: id, light: light);

  /// The same draft under a different light.
  GroveDraft withLight(String id) => GroveDraft(variety: variety, light: id);

  /// Whether this differs from what is [planted] — which is what makes the
  /// confirm live.
  ///
  /// Compared by value, not by "has the learner touched anything": a learner
  /// who picks Robusta and changes their mind back has nothing to apply, and
  /// writing anyway would move the last-writer-wins stamp for no change and
  /// beat a real edit from another device.
  bool isDirtyAgainst(Grove planted) => grove != planted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroveDraft && other.variety == variety && other.light == light;

  @override
  int get hashCode => Object.hash(variety, light);
}
