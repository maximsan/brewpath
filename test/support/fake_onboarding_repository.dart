import 'package:brew_path/features/onboarding/data/onboarding_repository.dart';

/// In-memory [OnboardingRepository] stand-in for tests: lets the gate result be
/// set directly and records `markOnboardingComplete` / `resetOnboarding` calls,
/// so onboarding logic can be exercised without Drift or platform channels.
class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({OnboardingState? initialState})
    : _state = initialState ?? const OnboardingState(completed: false);

  OnboardingState _state;

  /// The name passed to each [markOnboardingComplete] call, in order.
  ///
  /// What the real repository then *does* with a null — leave the stored name
  /// alone rather than clear it — is its own rule, and is covered against a
  /// real database in `onboarding_repository_test.dart`. This records the
  /// argument only, so nothing here can appear to confirm that rule.
  final List<String?> completeCalls = [];
  int resetCalls = 0;

  /// Overrides the state returned by [getState] (e.g. to simulate a returning,
  /// already-onboarded user).
  // ignore: use_setters_to_change_properties — imperative test-arrange helper
  void setState(OnboardingState state) => _state = state;

  @override
  Future<OnboardingState> getState() async => _state;

  @override
  Future<void> markOnboardingComplete({String? name}) async {
    completeCalls.add(name);
    _state = const OnboardingState(completed: true);
  }

  @override
  Future<void> resetOnboarding() async {
    resetCalls++;
    _state = const OnboardingState(completed: false);
  }
}
