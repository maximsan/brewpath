import 'package:flutter/foundation.dart';

/// Holds the typed name and submission state for `NameScreen`, keeping the
/// orchestration out of the widget so it can be unit-tested without pumping.
///
/// Persistence and navigation are injected, matching `BrewerController`:
/// `onSubmit` receives the name to keep — null when the learner skipped or
/// typed only whitespace — and `onFinished` runs once submission completes.
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
  /// Trailing spaces are not a name, and a learner who typed only spaces meant
  /// to skip — so both collapse to the same "no name given" the greeting
  /// already handles.
  String? get name {
    final trimmed = _typed.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Whether the step can be finished. Always true when idle: this step is
  /// skippable, and an empty field is a valid answer.
  bool get canSubmit => !_submitting;

  /// Records what the learner has typed. Ignored once submission is in flight.
  void type(String value) {
    if (_submitting) return;
    _typed = value;
    notifyListeners();
  }

  /// Persists via `onSubmit`, then invokes `onFinished`. Guards re-entry.
  Future<void> submit() async {
    if (!canSubmit) return;
    _submitting = true;
    notifyListeners();
    await _onSubmit(name);
    _onFinished();
  }
}
