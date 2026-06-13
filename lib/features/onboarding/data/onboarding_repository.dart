import 'package:coffee_quest/shared/repositories/settings_repository.dart';

/// Snapshot of the onboarding gate. `completed=false` means the user has not
/// yet finished the post-install flow and must be sent through it on launch.
class OnboardingState {
  /// Creates an [OnboardingState].
  const OnboardingState({
    required this.completed,
    required this.goal,
    required this.brewer,
  });

  /// Whether the user has finished onboarding.
  final bool completed;

  /// The chosen goal key, if any.
  final String? goal;

  /// The chosen brewer key, if any.
  final String? brewer;
}

/// Thin wrapper around [SettingsRepository] that exposes only the onboarding
/// gate + selections. Keeps onboarding logic out of the broader settings API.
class OnboardingRepository {
  /// Creates an [OnboardingRepository] backed by a [SettingsRepository].
  OnboardingRepository(this._settings);

  final SettingsRepository _settings;

  /// Returns the current [OnboardingState].
  Future<OnboardingState> getState() async {
    final s = await _settings.getSettings();
    return OnboardingState(
      completed: s.onboardingCompleted,
      goal: s.onboardingGoal,
      brewer: s.onboardingBrewer,
    );
  }

  /// Marks onboarding complete and saves the [goal]/[brewer] selections.
  Future<void> markOnboardingComplete({
    required String goal,
    required String brewer,
  }) async {
    final s = await _settings.getSettings();
    s
      ..onboardingCompleted = true
      ..onboardingGoal = goal
      ..onboardingBrewer = brewer;
    await _settings.saveSettings(s);
  }

  /// Clears the onboarding gate and the saved selections so the next launch
  /// (or redirect re-evaluation) sends the user back through Welcome.
  /// Intended for the debug-only "Reset onboarding" action.
  Future<void> resetOnboarding() async {
    final s = await _settings.getSettings();
    s
      ..onboardingCompleted = false
      ..onboardingGoal = null
      ..onboardingBrewer = null;
    await _settings.saveSettings(s);
  }
}
