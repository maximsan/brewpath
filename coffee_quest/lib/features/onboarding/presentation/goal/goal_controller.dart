import 'package:flutter/foundation.dart';

/// Holds the goal pick state for `GoalScreen`. The sibling of `BrewerController`
/// but synchronous — selecting a goal and advancing has no async/persistence
/// gap, so there is no `submitting` state.
///
/// [onSubmit] receives the chosen option index; the screen maps it to a key,
/// records it on `OnboardingDraft`, and navigates to the brewer step.
class GoalController extends ChangeNotifier {
  GoalController({required void Function(int selectedIndex) onSubmit})
    : _onSubmit = onSubmit;

  final void Function(int selectedIndex) _onSubmit;

  int? _selectedIndex;

  int? get selectedIndex => _selectedIndex;
  bool get canSubmit => _selectedIndex != null;

  void pick(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Forwards the selection via [onSubmit]. No-op with no selection.
  void submit() {
    if (!canSubmit) return;
    _onSubmit(_selectedIndex!);
  }
}
