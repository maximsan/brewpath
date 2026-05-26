import 'package:coffee_quest/shared/repositories/settings_repository.dart';

/// Snapshot of the onboarding gate. `completed=false` means the user has not
/// yet finished the post-install flow and must be sent through it on launch.
class OnboardingState {
  const OnboardingState({
    required this.completed,
    required this.goal,
    required this.brewer,
  });

  final bool completed;
  final String? goal;
  final String? brewer;
}

/// Thin wrapper around [SettingsRepository] that exposes only the onboarding
/// gate + selections. Keeps onboarding logic out of the broader settings API.
class OnboardingRepository {
  OnboardingRepository(this._settings);

  final SettingsRepository _settings;

  Future<OnboardingState> getState() async {
    final s = await _settings.getSettings();
    return OnboardingState(
      completed: s.onboardingCompleted,
      goal: s.onboardingGoal,
      brewer: s.onboardingBrewer,
    );
  }

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
}
