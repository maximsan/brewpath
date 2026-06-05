import 'package:coffee_quest/features/onboarding/data/onboarding_repository.dart';

/// In-memory [OnboardingRepository] stand-in for tests: lets the gate result be
/// set directly and records `markOnboardingComplete` / `resetOnboarding` calls,
/// so onboarding logic can be exercised without Drift or platform channels.
class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({OnboardingState? initialState})
    : _state =
          initialState ??
          const OnboardingState(completed: false, goal: null, brewer: null);

  OnboardingState _state;

  /// Args passed to each [markOnboardingComplete] call, in order.
  final List<({String goal, String brewer})> completeCalls = [];
  int resetCalls = 0;

  /// Overrides the state returned by [getState] (e.g. to simulate a returning,
  /// already-onboarded user).
  void setState(OnboardingState state) => _state = state;

  @override
  Future<OnboardingState> getState() async => _state;

  @override
  Future<void> markOnboardingComplete({
    required String goal,
    required String brewer,
  }) async {
    completeCalls.add((goal: goal, brewer: brewer));
    _state = OnboardingState(completed: true, goal: goal, brewer: brewer);
  }

  @override
  Future<void> resetOnboarding() async {
    resetCalls++;
    _state = const OnboardingState(completed: false, goal: null, brewer: null);
  }
}
