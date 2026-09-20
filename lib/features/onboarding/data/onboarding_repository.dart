import 'package:brew_path/shared/repositories/settings_repository.dart';

/// Snapshot of the onboarding gate. `completed=false` means the user has not
/// yet finished the post-install flow and must be sent through it on launch.
class OnboardingState {
  /// Creates an [OnboardingState].
  const OnboardingState({required this.completed});

  /// Whether the user has finished onboarding.
  final bool completed;
}

/// Thin wrapper around [SettingsRepository] that exposes only the onboarding
/// gate. Keeps onboarding logic out of the broader settings API.
class OnboardingRepository {
  /// Creates an [OnboardingRepository] backed by a [SettingsRepository].
  OnboardingRepository(this._settings);

  final SettingsRepository _settings;

  /// Returns the current [OnboardingState].
  Future<OnboardingState> getState() async {
    final s = await _settings.getSettings();
    return OnboardingState(completed: s.onboardingCompleted);
  }

  /// Marks onboarding complete, keeping [name] when the learner gave one.
  ///
  /// A null [name] — the learner skipped — leaves the stored name **alone**:
  /// skipping is declining to answer, not asking to be forgotten, and
  /// *Restart onboarding* replays the flow without touching `learnerName`.
  /// Clearing one is Settings' job (#406).
  Future<void> markOnboardingComplete({String? name}) async {
    final s = await _settings.getSettings()
      ..onboardingCompleted = true;
    if (name != null) s.learnerName = name;
    await _settings.saveSettings(s);
  }

  /// Clears the onboarding gate, so the next launch sends the learner back
  /// through Welcome. The debug-only "Reset onboarding" action.
  ///
  /// `tourSeen`, the micro-tips' seen list and the swipe surfaces' used list
  /// go with it: this replays the app's introductions, and leaving a set would
  /// drop the tester on a Learn tab with no Tour, no tips and no swipe hints.
  Future<void> resetOnboarding() async {
    final s = await _settings.getSettings();
    s
      ..onboardingCompleted = false
      ..tourSeen = false
      ..tipsSeen = ''
      ..swipesUsed = '';
    await _settings.saveSettings(s);
  }
}
