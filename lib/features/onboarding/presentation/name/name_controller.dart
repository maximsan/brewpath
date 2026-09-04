import 'package:flutter/foundation.dart';

/// Holds the typed name and submission state for `NameScreen`, keeping the
/// orchestration out of the widget so it can be unit-tested without pumping.
///
/// Persistence and navigation are injected: `onSubmit` receives the name to
/// keep — null when the learner skipped — and `onFinished` runs once the write
/// completes.
///
/// **Continue and skip are two answers, not one button in two moods.** The
/// design gives the step both, and skip keeps nothing even when the field has
/// something in it: a learner who types and then skips has changed their mind,
/// and saving what they abandoned would be reading the field over the choice.
class NameController extends ChangeNotifier {
  /// Creates a [NameController].
  NameController({
    required Future<void> Function(String? name) onSubmit,
    required VoidCallback onFinished,
  }) : _onSubmit = onSubmit,
       _onFinished = onFinished;

  final Future<void> Function(String? name) _onSubmit;
  final VoidCallback _onFinished;

  String _typed = '';
  bool _submitting = false;

  /// Whether a submission is currently in flight.
  bool get submitting => _submitting;

  /// The name as it would be kept: trimmed, or null when nothing was typed.
  ///
  /// Trailing spaces are not a name, and a learner who typed only spaces has
  /// given none — so both collapse to the same "no name" the greeting already
  /// handles.
  String? get name {
    final trimmed = _typed.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Whether the name can be kept. False on an empty or blank field, which is
  /// what greys the design's Continue out.
  bool get canContinue => !_submitting && name != null;

  /// Records what the learner has typed. Ignored once submission is in flight.
  void type(String value) {
    if (_submitting) return;
    _typed = value;
    notifyListeners();
  }

  /// Finishes the step keeping the typed name.
  Future<void> submit() async {
    if (!canContinue) return;
    await _finish(name);
  }

  /// Finishes the step keeping nothing.
  Future<void> skip() async {
    if (_submitting) return;
    await _finish(null);
  }

  Future<void> _finish(String? name) async {
    _submitting = true;
    notifyListeners();
    await _onSubmit(name);
    _onFinished();
  }
}
