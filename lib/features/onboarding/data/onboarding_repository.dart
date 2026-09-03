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
  Future<void> markOnboardingComplete({String? name}) async {
    final s = await _settings.getSettings();
    s
      ..onboardingCompleted = true
      ..learnerName = name;
    await _settings.saveSettings(s);
  }

  /// Clears the onboarding gate so the next launch (or redirect
  /// re-evaluation) sends the user back through Welcome.
  /// Intended for the debug-only "Reset onboarding" action.
  ///
  /// `tourSeen` goes with the gate. This action exists to replay the app's
  /// introductions from the start, and the Tour is the second half of them —
  /// leaving it set would send the tester back through Welcome and then drop
  /// them on a Learn tab with no Tour, which is a state no real device reaches.
  Future<void> resetOnboarding() async {
    final s = await _settings.getSettings();
    s
      ..onboardingCompleted = false
      ..tourSeen = false;
    await _settings.saveSettings(s);
  }
}
