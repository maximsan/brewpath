import 'package:brew_path/features/onboarding/data/onboarding_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_providers.g.dart';

/// Provides the [OnboardingRepository].
@riverpod
OnboardingRepository onboardingRepository(Ref ref) =>
    OnboardingRepository(ref.watch(settingsRepositoryProvider));

/// Async gate: true once the user has finished the onboarding flow.
/// Watched by the router redirect; invalidated by `OnboardingDraft.complete`.
@riverpod
Future<bool> onboardingCompleted(Ref ref) async {
  final repo = ref.watch(onboardingRepositoryProvider);
  final state = await repo.getState();
  return state.completed;
}

/// In-memory selection draft carried across the goal + brewer screens.
/// Reset and persisted to Drift by [complete]. `keepAlive: true` because
/// the goal is picked on one screen and read on the next — without keepAlive,
/// Riverpod auto-disposes the notifier between routes and the goal is lost.
@Riverpod(keepAlive: true)
class OnboardingDraft extends _$OnboardingDraft {
  @override
  ({String? goal, String? brewer, String? name}) build() =>
      (goal: null, brewer: null, name: null);

  /// Sets the chosen goal key.
  void setGoal(String value) {
    state = (goal: value, brewer: state.brewer, name: state.name);
  }

  /// Sets the chosen brewer key.
  void setBrewer(String value) {
    state = (goal: state.goal, brewer: value, name: state.name);
  }

  /// Sets the name the learner asked to be called, or clears it when they
  /// skipped. Trimmed to empty is the same as skipping.
  void setName(String? value) {
    final trimmed = value?.trim();
    state = (
      goal: state.goal,
      brewer: state.brewer,
      name: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }

  /// Persists the goal + brewer selections, then resets the draft.
  Future<void> complete() async {
    final goal = state.goal;
    final brewer = state.brewer;
    if (goal == null || brewer == null) {
      throw StateError(
        'OnboardingDraft.complete() called before both selections were made.',
      );
    }
    // ignore: only_use_keep_alive_inside_keep_alive — one-shot read in an action method doesn't subscribe, so keepAlive is unaffected
    final repo = ref.read(onboardingRepositoryProvider);
    await repo.markOnboardingComplete(
      goal: goal,
      brewer: brewer,
      name: state.name,
    );
    state = (goal: null, brewer: null, name: null);
    ref.invalidate(onboardingCompletedProvider);
  }
}
