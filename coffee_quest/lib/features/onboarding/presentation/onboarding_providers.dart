import 'package:coffee_quest/features/onboarding/data/onboarding_repository.dart';
import 'package:coffee_quest/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_providers.g.dart';

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
  ({String? goal, String? brewer}) build() => (goal: null, brewer: null);

  void setGoal(String value) {
    state = (goal: value, brewer: state.brewer);
  }

  void setBrewer(String value) {
    state = (goal: state.goal, brewer: value);
  }

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
    await repo.markOnboardingComplete(goal: goal, brewer: brewer);
    state = (goal: null, brewer: null);
    ref.invalidate(onboardingCompletedProvider);
  }
}
