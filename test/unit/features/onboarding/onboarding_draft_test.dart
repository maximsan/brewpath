import 'package:brew_path/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_onboarding_repository.dart';

/// The draft after the v1 cut (ADR-0010): the name is the only answer the
/// flow still collects, and it is optional.
void main() {
  late FakeOnboardingRepository fake;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => fake = FakeOnboardingRepository());

  group('OnboardingDraft', () {
    test('starts with nothing answered', () {
      expect(makeContainer().read(onboardingDraftProvider), (
        goal: null,
        brewer: null,
        name: null,
      ));
    });

    test('the parked setters still fill their fields', () {
      // The goal and brewer screens are parked rather than deleted (#407), so
      // these stay for them to compile against. Nothing a user can reach calls
      // either, and `complete` persists neither — asserted below.
      final container = makeContainer();
      container.read(onboardingDraftProvider.notifier)
        ..setGoal('brew_better')
        ..setBrewer('v60');

      expect(container.read(onboardingDraftProvider), (
        goal: 'brew_better',
        brewer: 'v60',
        name: null,
      ));
    });

    test('complete persists the name and neither parked answer', () async {
      final container = makeContainer();
      final notifier = container.read(onboardingDraftProvider.notifier)
        ..setGoal('brew_better')
        ..setBrewer('v60')
        ..setName('Maya');

      await notifier.complete();

      expect(fake.completeCalls, ['Maya']);
    });

    test('a name given at the step is trimmed and persisted', () async {
      final container = makeContainer();
      final notifier = container.read(onboardingDraftProvider.notifier)
        ..setName('  Maya  ');

      expect(container.read(onboardingDraftProvider).name, 'Maya');

      await notifier.complete();

      expect(fake.completeCalls, ['Maya']);
      expect(container.read(onboardingDraftProvider), (
        goal: null,
        brewer: null,
        name: null,
      ));
    });

    test('a skipped or blank name persists as no name at all', () async {
      final container = makeContainer();
      final notifier = container.read(onboardingDraftProvider.notifier)
        ..setName('   ');

      await notifier.complete();

      expect(fake.completeCalls, [null]);
    });

    test(
      'completing without touching the step is a skip, not an error',
      () async {
        // The step is optional, so finishing it untouched has to work. It used
        // to throw, because goal and brewer were required and were not set.
        final container = makeContainer();

        await container.read(onboardingDraftProvider.notifier).complete();

        expect(fake.completeCalls, [null]);
      },
    );

    test('complete refreshes the onboardingCompleted gate', () async {
      final container = makeContainer();
      expect(await container.read(onboardingCompletedProvider.future), isFalse);

      await container.read(onboardingDraftProvider.notifier).complete();

      expect(await container.read(onboardingCompletedProvider.future), isTrue);
    });
  });
}
