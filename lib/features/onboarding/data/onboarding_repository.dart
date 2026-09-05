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
  /// A null [name] — the learner skipped — leaves the stored name **alone**
  /// rather than clearing it. Skipping is declining to answer, not asking for
  /// the answer to be forgotten, and the two differ for anyone who already has
  /// a name: Settings' *Restart onboarding* replays the flow without touching
  /// `learnerName`, so a clear here would erase a name they set on purpose.
  /// Clearing one is Settings' job (#406).
  Future<void> markOnboardingComplete({String? name}) async {
    final s = await _settings.getSettings()
      ..onboardingCompleted = true;
    if (name != null) s.learnerName = name;
    await _settings.saveSettings(s);
  }

  /// Clears the onboarding gate so the next launch (or redirect
  /// re-evaluation) sends the user back through Welcome.
  /// Intended for the debug-only "Reset onboarding" action.
  ///
  /// `tourSeen` and the micro-tips' seen list go with the gate. This action
  /// exists to replay the app's introductions from the start, and the Tour and
  /// the tips are the rest of them — leaving either set would send the tester
  /// back through Welcome and then drop them on a Learn tab with no Tour and no
  /// tips, which is a state no real device reaches.
  Future<void> resetOnboarding() async {
    final s = await _settings.getSettings();
    s
      ..onboardingCompleted = false
      ..tourSeen = false
      ..tipsSeen = '';
    await _settings.saveSettings(s);
  }
}
