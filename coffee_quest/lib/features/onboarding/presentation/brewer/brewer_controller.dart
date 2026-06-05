import 'package:flutter/foundation.dart';

/// Holds the brewer pick + submission state for `BrewerScreen`, keeping the
/// orchestration out of the widget so it can be unit-tested without pumping.
///
/// Persistence and navigation are injected: [onSubmit] receives the chosen
/// option index (the screen maps it to a key and writes through
/// `OnboardingDraft`), and [onFinished] runs once submission completes.
class BrewerController extends ChangeNotifier {
  BrewerController({
    required Future<void> Function(int selectedIndex) onSubmit,
    required VoidCallback onFinished,
  }) : _onSubmit = onSubmit,
       _onFinished = onFinished;

  final Future<void> Function(int selectedIndex) _onSubmit;
  final VoidCallback _onFinished;

  int? _selectedIndex;
  bool _submitting = false;

  int? get selectedIndex => _selectedIndex;
  bool get submitting => _submitting;
  bool get canSubmit => _selectedIndex != null && !_submitting;

  /// Selects an option. Ignored once submission is in flight.
  void pick(int index) {
    if (_submitting) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Persists the selection via [onSubmit], then invokes [onFinished]. Guards
  /// against re-entry and submitting with no selection.
  Future<void> submit() async {
    if (!canSubmit) return;
    _submitting = true;
    notifyListeners();
    await _onSubmit(_selectedIndex!);
    _onFinished();
  }
}
