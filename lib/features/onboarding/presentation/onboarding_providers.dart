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

/// The answers the intro collects, until [complete] writes them.
///
/// **Only `name` is live.** ADR-0010 moved the goal and brewer questions to
/// v2; their screens are parked rather than deleted (#407), so the two fields
/// stay for those screens to compile against. Nothing a user can reach writes
/// either one, and [complete] persists neither.
///
/// `keepAlive: true` so the notifier cannot be disposed between the screen
/// reading it and the write finishing — an auto-disposed notifier throws on
/// the `state =` inside [complete].
@Riverpod(keepAlive: true)
class OnboardingDraft extends _$OnboardingDraft {
  @override
  ({String? goal, String? brewer, String? name}) build() =>
      (goal: null, brewer: null, name: null);

  /// Sets the chosen goal key. Parked — see the class doc.
  void setGoal(String value) {
    state = (goal: value, brewer: state.brewer, name: state.name);
  }

  /// Sets the chosen brewer key. Parked — see the class doc.
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

  /// Finishes onboarding, keeping the name if one was given.
  ///
  /// Never throws on a missing answer: the one step left is skippable, so
  /// arriving here with nothing typed is the ordinary path.
  Future<void> complete() async {
    // ignore: only_use_keep_alive_inside_keep_alive — one-shot read in an action method doesn't subscribe, so keepAlive is unaffected
    final repo = ref.read(onboardingRepositoryProvider);
    await repo.markOnboardingComplete(name: state.name);
    state = (goal: null, brewer: null, name: null);
    ref.invalidate(onboardingCompletedProvider);
  }
}
